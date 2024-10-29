public class CtrConsultaOfertas {
    // public Map<Integer,Map<String,String>> mapTable {get;set;}
    // public String [] fields {get;set;}
    // public Set<Integer> setCounter {get;set;}
    // public Integer counter {get;set;}
    // public String msg {get;set;}
    
    // public ctrConsultaOfertas(){
    //     counter = 0;
    // }
    
    // private static CIVServices civServ = CIVServices.getInstance();
    // public void consultar() {
    //     String filtro;
    //     String retorno;
    //     Object retornoSemConsultivo;
    //     String retSemConsultivoStr;
    //     String Response;
        
    //     System.debug('ENTRADA '+ ApexPages.currentPage().getParameters());
        
    //     Map<String, String> mEntrada = ApexPages.currentPage().getParameters();
    //     try{
    //         counter = 0;
    //         filtro = mEntrada.get('jsonConsultaOferta');
    //         if(!Test.isRunningTest()) {
    //             Map<String,Object> mapVerify = (Map<String,Object>)JSON.deserializeUntyped(String.valueOf(filtro));
    //             Integer qtdCaracteresNumero = mapVerify.get('numero') != null ? String.valueOf(mapVerify.get('numero')).length() : 0;
    //             if(qtdCaracteresNumero < 4) {
    //                 msg = 'Por favor, digite no mínimo quatro caractéres no campo "Número do Orçamento".';
    //                 return;
    //             }
    //             Response = civServ.consultarOferta(filtro); //MGRC-1657 - INICIO/FIM
    //         }
    //         else{
    //             Map<String,String> mapBody = new Map<String,String>();
    //             //mapBody.put('codigoCorretor', 'P5005J');
    //             mapBody.put('numero', '00005900');
    //             HttpRequest req = new HttpRequest();
    //             req.setBody(JSON.serialize(mapBody));
    //             ConsultaOfertaRESTMock mock = new ConsultaOfertaRESTMock();
    //             HttpResponse resposta = mock.respond(req);
    //             Response = resposta.getBody();
    //         }
    //         system.debug('ResponseOferta: ' + Response);
            
    //         Map<String, Object> mapReturnedObjects = (Map<String, Object>) JSON.deserializeUntyped(Response);
    //         Map<String, Object> mapData = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(mapReturnedObjects.get('data')));
            
    //         msg = null;
    //         if(mapData.get('mensagem') != null) {
    //             mapTable = null;
    //             msg = String.valueOf(mapData.get('mensagem'));
    //             if(msg != 'Não foram encontrados resultados.' && msg != 'Parâmetros insuficientes.') {
    //                 msg = 'Ocorreu um erro inesperado. Por favor, contate o administrador.';
    //             }
    //         }
    //         else{
    //             fields = new List<String>{'Número','Nome','Nome do Produto','Status'};
    //                 List<Object> lstObj = (List<Object>) JSON.deserializeUntyped(JSON.serialize(mapData.get('retornosConsulta')));
    //             mapTable = new Map<Integer,Map<String,String>>();
    //             setCounter = new Set<Integer>();
    //             for(Object obj : lstObj) {
    //                 Map<String,Object> mapRetornosConsulta = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(obj));
    //                 Map<String,String> mapInner = new Map<String,String>();
    //                 mapInner.put('Número', mapRetornosConsulta.get('numero') == null ? '' : String.valueOf(mapRetornosConsulta.get('numero')));
    //                 mapInner.put('Nome', mapRetornosConsulta.get('nome') == null ? '' : String.valueOf(mapRetornosConsulta.get('nome')));
    //                 mapInner.put('Nome do Produto', mapRetornosConsulta.get('nomeproduto') == null ? '' : String.valueOf(mapRetornosConsulta.get('nomeproduto')));
    //                 mapInner.put('Status', mapRetornosConsulta.get('status') == null ? '' : String.valueOf(mapRetornosConsulta.get('status')));
    //                 mapTable.put(counter,mapInner);
    //                 setCounter.add(counter);
    //                 counter++;
    //             }
    //         }
    //     }catch(Exception ex){
    //         System.debug('###### ERROR: (' + ex.getLineNumber() + '): ' + ex.getMessage());							
    //         throw new ServiceException('ERRO de serviço: ' + ex.getMessage() + ' Linha: ' + ex.getLineNumber());
    //     }
    // }
    // public class ServiceException extends Exception { }
}