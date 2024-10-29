/*********************************************************************************************************************************************************************

@description  API REST para receber o ticket da BCP enviado via CIV.
@author Uverlanio Mauricio
@date 23/01/2023
@Classe criada por conta da história LECVP-72
        
**********************************************************************************************************************************************************************/
//LECVP-72 - INICIO
@RestResource(urlMapping='/contrato/bcp/*')
global class ContratoTcktREST extends ServicoRestBase{
    
    private static final ContratoTcktREST instance = new ContratoTcktREST();
    public ContratoTcktFacade facade = ContratoTcktFacade.getInstance();
    BCPContratoTcktTO bCPContratoTcktTO = new BCPContratoTcktTO();

    global ContratoTcktREST(){
        super.setServicoRestBase('GravarTicketBCP');
    }

    @HttpPost
    global static void processarPost() {
        instance.processarServico('POST');
    }

    global override void processarServico(String metodo) {

        try {
            if(metodo == 'POST'){
                RestRequest req = RestContext.request;
                String endpoint = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
                String payload = RestContext.request.requestBody.toString();

                if(String.isNotBlank(payload)){
                    bCPContratoTcktTO = (BCPContratoTcktTO) JSON.deserialize(payload, BCPContratoTcktTO.class);
                }
                if(endpoint.equals('devolutivas')){
                    String retorno = facade.inserirTicket(bCPContratoTcktTO);
                    this.retonarSucesso(retorno, 200);
                }
            } 
        }catch(Exception e) {
            this.retornarErro(e.getMessage());
        }
    }
}
//LECVP-72 - FIM