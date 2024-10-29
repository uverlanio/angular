/**
 * Created by Alessandro Ponte on 03/09/2018.
 */

@RestResource(urlMapping='/contrato/*')
global with sharing class ContractREST extends ServicoRestBase{

    private static final ContractREST instance = new ContractREST();
    public static ContractFacade facade = ContractFacade.getInstance();
    private static GarantiaContratoFacade portocapFacade = GarantiaContratoFacade.getInstance();

    global ContractREST(){
        super.setServicoRestBase('Contrato');
    }

    @HttpPost
    global static void processarPost() {
        instance.processarServico('POST');
    }

    global override void processarServico(String metodo) {

        try {
            if(metodo == 'POST'){
                RestRequest req = RestContext.request;
                String endpoint = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
                String payload = RestContext.request.requestBody.toString();

                // Endpoint de recompra de titulo
                if(endpoint == 'recompra-titulo'){
                    String retorno = facade.recompraTituloCapitalizacao();
                    this.retonarSucesso(JSON.serialize(retorno), 200);
                }else if(endpoint == 'consulta-titulo'){
                    portocapFacade.consultarTituloPortoCap();
                    this.retonarSucesso('{"status" : "ok"}', 200);
                }
                else if(endpoint == 'consulta-contrato-proposta'){
                    System.debug('Executa consulta-contrato-proposta');
                    ConsultarDadosContratoTO.DadosContratoTO retorno = facade.consultarProposta(payload);
                    this.retonarSucesso(JSON.serialize(retorno), 200);
                }
                else if(endpoint == 'consulta-contrato-apolice'){
                    System.debug('Executa consulta-contrato-apolice');
					System.debug('Payload = ' + payload);
                    ConsultarDadosContratoTO.DadosContratoTO retorno = facade.consultarContrato(payload);
                    this.retonarSucesso(JSON.serialize(retorno, true), 200);
					System.debug('retorno = '+ JSON.serialize(retorno));
                }

            }
        }
        catch (Exception e) {
            this.retornarErro(e.getMessage());
        }

    }
}