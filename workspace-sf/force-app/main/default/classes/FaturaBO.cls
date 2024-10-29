public class FaturaBO {

    private static final FaturaBO instancia = new FaturaBO();
    private static FaturaDAO dao = FaturaDAO.getInstance();
    private static HerokuService servicoHeroku = HerokuService.getInstance();

    private static final String FATURA_STATUS_CANCELADA = 'Cancelada';
    private static final String FATURA_STATUS_PAGA = 'Paga';
    private static final String FATURA_STATUS_PENDENTE = 'Pendente';

    public static FaturaBO getInstance(){
        return instancia;
    }

    public List<Fatura__c> buscarFaturas(Set<Id> faturaIds) {
        return dao.buscarFaturasPorIds(faturaIds);
    }

    public String gerarNumeroContratoFinanceiro(String origemProposta, String numeroProposta, String sucursal, String ramo, String apolice, String endosso ){

        return origemProposta.leftPad(2,'0') + numeroProposta.leftPad(8,'0') + sucursal.leftPad(3,'0') + Ramo.leftPad(4,'0') + apolice.leftPad(9,'0') + endosso.leftPad(10,'0');

    }
    //------ Trigger creating Contract
    public void atualizarFaturasPagasHeroku(List<Fatura__c> lstFaturas, Map<Id, Fatura__c> mapOldFaturas) {
        Set<Id> IdsFatura = new Set<Id>();

        // Make sure of the map's instance
        if(mapOldFaturas == null)
            mapOldFaturas = new Map<Id, Fatura__c>();

        // Verify if is a new record or if have changes in the date field
        for(Fatura__c objFatura : lstFaturas) {
            Fatura__c faturaOld = mapOldFaturas.get(objFatura.Id);
        
            if(objFatura.Status__c == 'Paga' && (FaturaOld == null || FaturaOld.Status__c != 'Paga'))
            {
                IdsFatura.add(objFatura.Id);
            }
        } 

        if(IdsFatura.size()>0)
        {
            executaServicoAtualizcao(IdsFatura);
        }
      
    }
    public void gerarControleIntegracao(List<Fatura__c> lstFaturas, Map<Id, Fatura__c> mapOldFaturas) {
        List<ControleIntegracao__c> listControleIntegracao = new List<ControleIntegracao__c>();

        if(mapOldFaturas == null)
            mapOldFaturas = new Map<Id, Fatura__c>();

        for(Fatura__c objFatura : lstFaturas) {
            Fatura__c faturaOld = mapOldFaturas.get(objFatura.Id);

            if(( objFatura.Status__c == FATURA_STATUS_PENDENTE || objFatura.Status__c == FATURA_STATUS_PAGA || objFatura.Status__c == FATURA_STATUS_CANCELADA )
                    && faturaOld.Status__c != objFatura.Status__c && objFatura.TipoFatura__c == 'Cobranca')
            {
                ControleIntegracao__c controleIntegracao = new ControleIntegracao__c(
                        IdObjeto__c = objFatura.Id,
                        CodigoIntegracao__c = '63',
                        DataCriacaoRegistro__c = System.today(),
                        Status__c = 'Pendente'
                );

                listControleIntegracao.add(controleIntegracao);
            }
        }

        if(listControleIntegracao.size() > 0)
        {
            try{
                insert listControleIntegracao;
            }catch (Exception e){
                throw new FaturaException('Erro ao gerar o controle de integração: ' + e.getLineNumber() + ' : ' + e.getMessage());
            }
        }

    }


    @future(callout=true)
    private static void executaServicoAtualizcao(Set<Id> IdsFatura)
    {
        List<FaturaTO.AtualizarParcelaTO> payload = new List<FaturaTO.AtualizarParcelaTO>();

        for(Fatura__c objFatura : FaturaDAO.getInstance().buscarFaturasPorIds(IdsFatura))
        {
            // PLV-2192-27-INICIO
            FaturaTO.AtualizarParcelaTO fatura = new FaturaTO.AtualizarParcelaTO();
            fatura.numeroFatura = objFatura.Name;
            fatura.dataPagamento = String.valueOf(objFatura.DataPagamento__c);

            payload.add(fatura);
            // PLV-2192-27-FIM
        }

        if(!Test.isRunningTest()){
            System.debug('Payload fatura :' + JSON.serialize(payload));
            servicoHeroku.atualizaStatusFatura(payload);
        }
    }

    public class FaturaException extends Exception{}

}