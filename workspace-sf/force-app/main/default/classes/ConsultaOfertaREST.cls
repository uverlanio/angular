/**
* Consulta Oferta REST
* @author IF - Globant @ 25/12/2019
* @modified IF - Globant @ 30/12/2019
*
**/
//PLV-3223 - INÍCIO
@RestResource(urlMapping='/consulta/*')
global with sharing class ConsultaOfertaREST extends ServicoRestBase {
    private static final ConsultaOfertaREST instance = new ConsultaOfertaREST();
    global ConsultaOfertaREST(){
        super.setServicoRestBase('ConsultaOferta');
    }
    
    @HttpPost
    global static void processarPost() {
        instance.processarServico('POST');
    }
    
    public override void processarServico(String metodo)
    {
        String retorno;
        try 
        {
            RestRequest req = RestContext.request;
            String endpoint = req.requestURI;
            system.debug('Endpoint: ' + endpoint);
            
            if(metodo == 'POST')
            {
                String payload = req.requestBody.toString();
                System.debug(LoggingLevel.FINEST, 'PAYLOAD RECEBIDO CIV - CONSULTA');
                System.debug(LoggingLevel.FINEST, payload);
                if(endpoint.indexOf('/consulta/orcamento') > -1) {
                    Map<String, Object> mapFiltros = (Map<String, Object>) JSON.deserializeUntyped(payload);
                    String filtroQuery = '';
                    
                    /*if(mapFiltros.get('codigoCorretor') == null || mapFiltros.get('codigoCorretor') == ''){
ConsultaOfertaTO consultaOferta = new ConsultaOfertaTO();
consultaOferta.mensagem = 'Código do corretor não informado';
retorno = JSON.serialize(consultaOferta, true);
this.retonarSucesso(retorno, 200);
}*/
                    if((mapFiltros.get('numero') == null || mapFiltros.get('numero') == '') &&
                       (mapFiltros.get('numeroCpf') == null || mapFiltros.get('numeroCpf') == '') &&
                       (mapFiltros.get('nomeSegurado') == null || mapFiltros.get('nomeSegurado') == '') &&
                       (mapFiltros.get('periodoBusca') == null || mapFiltros.get('periodoBusca') == ''))
                    {
                        ConsultaOfertaTO consultaOferta = new ConsultaOfertaTO();
                        consultaOferta.mensagem = 'Parâmetros insuficientes.';
                        retorno = JSON.serialize(consultaOferta, true);
                        this.retonarSucesso(retorno, 200);
                    }
                    else {
                        if(mapFiltros.get('numero') != null && mapFiltros.get('numero') != '') {
                            filtroQuery += ' AND Numero__c LIKE \'%' + String.escapeSingleQuotes(String.valueOf(mapFiltros.get('numero'))) + '%\'';
                        }
                        if(mapFiltros.get('numeroCpf') != null && mapFiltros.get('numeroCpf') != '') {
                            String cpf = String.escapeSingleQuotes(String.valueOf(mapFiltros.get('numeroCpf')));
                            String cpfFormatado = cpf.left(3) + '.' + cpf.left(6).right(3) + '.' + cpf.left(9).right(3) + '-' + cpf.right(2);
                            
                            filtroQuery += ' AND Account.cpf__c = \'' + cpfFormatado + '\'';
                        }
                        if(mapFiltros.get('nomeSegurado') != null && mapFiltros.get('nomeSegurado') != '') {
                            filtroQuery += ' AND Account.Name = \'' + String.escapeSingleQuotes(String.valueOf(mapFiltros.get('nomeSegurado'))) + '\'';
                        }
                        if(mapFiltros.get('periodoBusca') != null && mapFiltros.get('periodoBusca') != '') {
                            filtroQuery += ' AND CreatedDate = LAST_N_Days:' + String.escapeSingleQuotes(String.valueOf(mapFiltros.get('periodoBusca')));
                        }
                        
                        String query = 'SELECT Id, Numero__c, Name, Produto__r.Name, StageName FROM Opportunity WHERE StageName = \'Disponível para contratação\'' + filtroQuery + ' LIMIT 100';
                        List<Opportunity> lstOrcamentosConsulta = Database.query(query);
                        System.debug('lstOrcamentosConsulta ' + lstOrcamentosConsulta);
                        
                        if(!lstOrcamentosConsulta.isEmpty()) {
                            ConsultaOfertaTO consultaOferta = new ConsultaOfertaTO();
                            List<ConsultaOfertaTO.RetornoConsultaTO> listaOrcamentos = new List<ConsultaOfertaTO.RetornoConsultaTO>();
                            for(Opportunity orcamento : lstOrcamentosConsulta) {
                                ConsultaOfertaTO.RetornoConsultaTO retornoConsulta = new ConsultaOfertaTO.RetornoConsultaTO();
                                retornoConsulta.numero = String.valueOf(orcamento.Numero__c);
                                retornoConsulta.nome = String.valueOf(orcamento.Name);
                                retornoConsulta.status = String.valueOf(orcamento.StageName);
                                retornoConsulta.nomeProduto = String.valueOf(orcamento.Produto__r.Name);
                                listaOrcamentos.add(retornoConsulta);
                            }
                            consultaOferta.retornosConsulta = listaOrcamentos;
                            retorno = JSON.serialize(consultaOferta, true);
                        }
                        else{
                            ConsultaOfertaTO consultaOferta = new ConsultaOfertaTO();
                            consultaOferta.mensagem = 'Não foram encontrados resultados.';
                            retorno = JSON.serialize(consultaOferta, true);
                        }
                        this.retonarSucesso(retorno, 200);
                    }
                }
            }
        }
        catch(Exception e) {
            ConsultaOfertaTO consultaOferta = new ConsultaOfertaTO();
            consultaOferta.mensagem = e.getMessage() + '. Linha: ' + e.getLineNumber();
            retorno = JSON.serialize(consultaOferta, true);
            this.retonarSucesso(retorno, 200);
        }
    }
}
//PLV-3223 - FIM"