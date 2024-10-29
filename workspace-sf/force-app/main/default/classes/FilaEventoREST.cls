/**
 * Created by Alessndro Ponte on 03/06/2019.
 */
// PLV-2312-28 INICIO
@RestResource(urlMapping='/fila-evento/*')
global with sharing class FilaEventoREST extends ServicoRestBase{
    private static final FilaEventoREST instance = new FilaEventoREST();

    global FilaEventoREST(){
        super.setServicoRestBase('InclusaoEvento');
    }

    @HttpPost
    global static void processarPost() {
        instance.processarServico('POST');
    }

    public override void processarServico(String metodo) {
        try {

            RestRequest req = RestContext.request;
            String uri = req.requestURI;
            List<String> paths = uri.split('/');
            String endpoint = paths[paths.size()-1];

            if(metodo == 'POST'){
                System.debug('TO NO POST');
                String payload;

                if(RestContext.request.requestBody != null) {
                    payload = RestContext.request.requestBody.toString();
                }

                if(endpoint == 'processar-massificados'){
                    // Inicia o batch de processamento de propostas de massificados
                    super.setServicoRestBase('AtualizarSistemasExternosMassificados');
//                    Id jobId = Database.executeBatch(new PropostaMassificadosBatch(0), 4);
                    // Executa o batch de atualizacao dos sistemas externos para todos os lotes
                    Id jobId = Database.executeBatch(new AtualizarSistemasExternosBatch(0), 12);
                    this.retonarSucesso(JSON.serialize(jobId, true), 200);
                }else if(endpoint == 'abortar-processar-massificados'){
                    // Aborta a execucao do batch
                    super.setServicoRestBase('AbortarProcessarPropostasMassificados');
                    ServiceTO.ControleBatchTO controleBatchTO = (ServiceTO.ControleBatchTO) JSON.deserialize(payload, ServiceTO.ControleBatchTO.class);
                    if(!Test.isRunningTest()) {
                        System.abortJob(controleBatchTO.idjob);
                    }
                }
//                else if(endpoint == 'fila-evento'){
//                    List<FilaEventoFacade.retornoFilaEvento> retorno = facade.getInstance().gerarFilaEventos(payload);
//                    this.retonarSucesso(JSON.serialize(retorno, true), 200);
//                }
            }
        }
        catch (Exception e) {
            this.retornarErro(e.getMessage());
        }

    }
}
// PLV-2312-28 FIM