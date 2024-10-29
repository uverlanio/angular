/********************************************************************************************************************
* OpinCIVTO (Open Insurance)
* @author Squad_VidaDoSeuJeito
* @date 07/10/2021
* Classe para integração com o CIV criada por conta da história PLV-5230
*********************************************************************************************************************/

public class IntegracaoOpinService {

    //Resolve dependências
    private final SensediaServices civ =  SensediaServices.getInstance();//MGRC-1273 - INICIO/FIM

    //Implementa Factory
    private static final IntegracaoOpinService instance = new IntegracaoOpinService();
    public static IntegracaoOpinService getInstance() {
        return instance;
    }

    //Construtor
    public IntegracaoOpinService() { }

    //Envia os dados para o serviço de integração (Aguardando DE...PARA)
    public void enviar(String dadosOpin) {
                        
        //Chamada para o CIV passando o json com os dados do(s) produto(s)
        String retorno = SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.GET, SensediaServices.DOMAIN.AWS_EXTERNO, SensediaServices.INCLUIR_PRODUTO_VIDA_OPIN, dadosOpin);//MGRC-1273 - INICIO/FIM        

        String msgRetorno = 'Falha na requisição';        
        Boolean responseOpin = retorno.contains('"routed":');
        Boolean requestErrorOpin = retorno.contains('"error":');
        Boolean requestErrorCIV = retorno.contains('"Erro ');
        Boolean exceptionIntCIV = true;

        System.debug('dadosOpinCIV>>>> ' + dadosOpin);
        System.debug('retornoCIV>>>> ' + retorno);

        //Tratamento da Response
        if(responseOpin){
            OpinCIVTO.ResponseOpinCIVTO retObject = new OpinCIVTO.ResponseOpinCIVTO();
            retObject = (OpinCIVTO.ResponseOpinCIVTO) JSON.deserialize(retorno, OpinCIVTO.ResponseOpinCIVTO.class);
            System.debug('responseOpin-retObject>>>> ' + retObject);
            if(retObject.routed) {
                msgRetorno = 'Sucesso na requisição';            
                exceptionIntCIV = false;
            } 
        //PLV-5230 - FIX02 - INICIO
        } else if (requestErrorOpin){
            OpinCIVTO.ResponseRequestErrorOpinCIVTO retObject = (OpinCIVTO.ResponseRequestErrorOpinCIVTO) JSON.deserialize(retorno, OpinCIVTO.ResponseRequestErrorOpinCIVTO.class);
            System.debug('requestErrorOpin-retObject>>>> ' + retObject);
            System.debug('msgRetorno = ' + msgRetorno + ' - Erro: ' + retObject.error + ' Motivo: ' + retObject.reason); 
         } else if (requestErrorCIV){
            System.debug('msgRetorno = ' + msgRetorno + ' do CIV'); 
        } 
        //PLV-5230 - FIX02 - FIM

        //Exception caso haja falha na requisição
        if(exceptionIntCIV) throw new IntegracaoOpinServiceException('IntegracaoOpinServiceException - Body: ' + retorno);        
    }

    //Classe para tratamento da Exception
    public class IntegracaoOpinServiceException extends Exception { }
    
}
//PLV-5230 - FIM