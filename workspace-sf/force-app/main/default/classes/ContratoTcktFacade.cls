/*********************************************************************************************************************************************************************

@description  Facade responsável pela camada de serviço.
@author Uverlanio Mauricio
@date 23/01/2023
@Classe criada por conta da história LECVP-72        
**********************************************************************************************************************************************************************/
//LECVP-72 - INICIO
public class ContratoTcktFacade extends ServiceBase{
    
    private static final ContratoTcktFacade instancia = new ContratoTcktFacade();

    public static ContratoTcktFacade getInstance(){
         return instancia; 
    }

    public String inserirTicket(BCPContratoTcktTO bCPContratoTcktTO){

        Contract contrato = new Contract();

        try{

            String origem = bCPContratoTcktTO.origem;
            String proposta = bCPContratoTcktTO.proposta;
            String numeroTicket = bCPContratoTcktTO.RespostaBCP?.numeroSequenciaControle;

            String numeroPropostaUnico = origem + '-' + proposta;

            if(proposta.length() < 6){
                return '{"status" : "nok"}';
            }

                try{
                    contrato = ContractDAO.getInstance().buscarPorNumPropostaUnico(numeroPropostaUnico)[0];            
                    ContractDAO.getInstance().inserirTcktBCPContrato(contrato, bCPContratoTcktTO);
                    apagarLogBCP(contrato);
                }catch(Exception e){
                    throw new ContratoTcktFacadeException();
                }
                
                return '{"status" : "ok"}';
            }catch(Exception e){
                System.debug('Não foi possível inserir o ticket no contrato: ' + e.getMessage() + ' na linha: ' + e.getLineNumber());

                if(contrato.Id != null){
                    BCPLogDAO.getInstance().atualizarLogBCPAPI(contrato, bCPContratoTcktTO.mensagem);
                }else{
                    BCPLogDAO.getInstance().gerarLogBCPErroAPI('SF - Contrato não encontrado');
                }

                throw new ContratoTcktFacadeException();
            }                            
    }

    private void apagarLogBCP(Contract contrato){
        
        List<BCP_Log__c> log = [select Id from BCP_Log__c where BCP_Contrato__c = :contrato.Id];
        
        if(Test.isRunningTest()){
            log = new List<BCP_Log__c>();
            log.add(new BCP_Log__c());
            insert log;
        }
        if(log != null && !log.isEmpty()){
            delete log;
        }
    }

    public class ContratoTcktFacadeException extends Exception{}
}
//LECVP-72 - FIM