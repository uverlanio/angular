/**************************************************************************************************************************************************************************
 * 
 *  Classe responsável pelas funcionalidades do componente de associação de papeis as contas
 *
 **************************************************************************************************************************************************************************/
public class AssociacaoPapeisController {
	private static AccountBO objContaBo = AccountBO.getInstance();

	/**
     * Busca conta referenciada na página
     *
     * @param contaId - id da conta a ser buscada
     */
    @AuraEnabled
    public static Account buscarContaPapel(String contaId){
        return objContaBo.buscarContaInfomacoesBancarias((Id)contaId);
    }

    /**
     * Busca os serviços referente aos papéis
     *
     */
    @AuraEnabled
    public static String buscarServicosPapel(){
        return JSON.serialize(objContaBo.buscarServicosPapel());
    }

	/**
     * Realiza busca de map contendo a prefixos dos SObjects que podem ser pai de território
     *
     * @return  String - Lista contendo os paises serializados
     */
    @AuraEnabled
    public static void salvarPapeis(Account conta, List<InformacaoBancaria__c> infoBancariosPapeis){
        //PLV-4445 INICIO
        try {
            preencheBancoNew(infoBancariosPapeis);

            if(isValidInfoBancaria(infoBancariosPapeis)) {
                //PLV-4445 FIM
                objContaBo.inserirAssociacaoPapeis((Account)JSON.deserialize(JSON.serialize(conta), Account.class), (List<InformacaoBancaria__c>)JSON.deserialize(JSON.serialize(infoBancariosPapeis), List<InformacaoBancaria__c>.class));
                //PLV-4445 INICIO
            }

        } catch (DmlException de) {
            System.debug('Exception : salvarPapeis : ' + de.getDmlMessage(0) + ',' + de.getMessage() + ',' + de.getStackTraceString());
            throw new AuraHandledException(de.getDmlMessage(0));
        }
    }

    private static void preencheBancoNew(List<InformacaoBancaria__c> informacoesBancarias) {
        Set<String> codigosBanco = new Set<String>();

        for (InformacaoBancaria__c info : informacoesBancarias) {
            if (!String.isBlank(info.Banco__c)) {
                codigosBanco.add(info.Banco__c);
            }
        }

        Map<String, Banco__c> bancosMap = getMapBancos(codigosBanco); 

        for (InformacaoBancaria__c info : informacoesBancarias) {
            if (bancosMap != null && bancosMap.values().size() > 0 && bancosMap.containsKey(info.Banco__c)) {
                info.BancoNew__c = bancosMap.get(info.Banco__c).Id;
            }
            else {
                System.debug('preencheBancoNew : Banco não encontrado!');
                throw new AuraHandledException('Banco não encontrado!');
            }
        } 
    }

    private static Map<String, Banco__c> getMapBancos(Set<String> codigosBanco) {
        Map<String, Banco__c> result = new Map<String, Banco__c>();
        System.debug('codigosBanco: ' + codigosBanco);
        if (codigosBanco.size() > 0) {
            List<Banco__c> bancos = [
                SELECT Id
                    ,CodigoBanco__c 
                    ,Name
                FROM Banco__c
                WHERE CodigoBanco__c IN: codigosBanco
                AND Ativo__c = true
            ];

            if (bancos.size() > 0) {
                for (Banco__c banco : bancos) {
                    result.put(banco.CodigoBanco__c, banco);
                }
            }
        }

        return result;
    }

    private static Boolean isValidInfoBancaria(List<InformacaoBancaria__c> informacoesBancarias) {
        
        if (informacoesBancarias != null) {
            for (InformacaoBancaria__c ib : informacoesBancarias){ 
                
                String validarComposicaoBancariaTO = '{"DadosBancarios": {'+
                    +'"banco": "'+ib.Banco__c+'",'
                    +'"agencia": "'+ib.Agencia__c+'",'
                    +'"contaCorrente": "'+ib.NumeroConta__c+'",'
                    +'"digitoContaCorrente": "'+String.valueOf(ib.Digito__c)+'"}}';

                ValidarComposicaoBancariaTO composicaoBancaria = (ValidarComposicaoBancariaTO)JSON.deserialize(validarComposicaoBancariaTO, ValidarComposicaoBancariaTO.class);
                //MGRC-1822-INICIO
                // String retornoCiv = CIVServices.getInstance().validarComposicaoBancaria(validarComposicaoBancariaTO);
                String retorno = SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.POST, SensediaServices.DOMAIN.AWS_EXTERNO, SensediaServices.VALIDAR_COMPOSICAO_BANCARIA, JSON.serialize(validarComposicaoBancariaTO));
                System.debug('Retorno CIV : ' + retorno);

                Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(retorno);
                //MGRC-1822-FIM
                if (result.get('status') != 0) {
                    throw new AuraHandledException('Informação Bancária Inválida! Banco: ' + ib.Banco__c + ', Agência: ' + ib.Agencia__c 
                        + ', Conta: ' + ib.NumeroConta__c + ', Digito: ' + ib.Digito__c + '.');
                }
            }
        }
        
        return true;
    }
    //PLV 4445 FIM
    
	/**
     * Realiza a exclusão de um papel juntamente com os seus dados dependentes
     *
     * @param contaId - id da conta a ter um papel excluido
     * @param papel - nome do papel a ser excluido
     */
    @AuraEnabled
    public static void excluirPapel(String contaId, String papel){
        objContaBo.excluirAssociacaoPapel((Id)contaId, papel);
    }
           
}