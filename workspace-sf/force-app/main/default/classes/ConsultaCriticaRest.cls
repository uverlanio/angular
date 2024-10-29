//II-12 INICIO
@RestResource(urlMapping='/consultaCriticas')
global class ConsultaCriticaRest {

    global class Request {

        global Request(RestRequest req){}		
    
        global List<Criticas> criticas;   
        global List<Recusas> recusas;    //II-48 INICIO-FIM 
    
	}

    global class Criticas {
        public String grupo;
        public String status;

        global Boolean isValid(){
            return (String.isNotBlank(this.grupo) && String.isNotBlank(this.status)) ? true : false;
        }
    }
    //II-48 INICIO
    public class Recusas {
        public Integer codigo;
    }
    //II-48 FIM 
    global class Response {

        global Boolean erro;
	    global List<Retorno> retorno;
	    
    }
    global class Retorno {
        global Decimal prioridade;
        global String texto;
        global String descricao;
    }
    
    @HttpPost
    global static List<Retorno> consultaCriticas(){
        Response response = new Response();
        System.debug('request >>>> '+ RestContext.request.requestBody.toString());
        //II-12 FIX03 INICIO
        String body = RestContext.request.requestBody.toString();
        body = body.replace('}}}', '}]}');
        body = body.replace('"criticas":{' ,'"criticas":[' );
        body = body.replaceAll('"\\d+":', '');
        System.debug('body >>>> '+ body);
        //Request request = (Request) JSON.deserialize(RestContext.request.requestBody.toString(), Request.class);
        Request request = (Request) JSON.deserialize(body, Request.class);
        //II-12 FIX03 FIM
        Map<Id, Mensageria__mdt> mapMetadado = new Map<Id, Mensageria__mdt>();
        Map<Id,String> mapMetaPorDescri = new Map<Id,String>();
        List<String> lstGrupo = new list<String>();
        List<String> lstStatus = new list<String>();
        Map<String,Mensageria__mdt> mapTextoRetorno = new Map<String,Mensageria__mdt>();
        List<Retorno> retornoLst = new List<Retorno>();

        // Busca a descrição do código de recusa, se presente
        //II-48 INICIO
        System.debug('request  >>>'+ request);
        if (request.recusas != null && request.recusas.size() > 0) {
            System.debug('Entrou no if >>>');
            Integer codigoRecusa = request.recusas[0].codigo;
            List<Mensageria__mdt> recusaMetadado = [SELECT Texto__c FROM Mensageria__mdt WHERE Codigo__c =:codigoRecusa LIMIT 1];
            System.debug('recusaMetadado >>>'+ recusaMetadado);
            if (!recusaMetadado.isEmpty()) {
                Retorno retornoRecusa = new Retorno();
                retornoRecusa.prioridade = 0;
                retornoRecusa.texto = recusaMetadado[0].Texto__c;
                retornoRecusa.descricao = '';
                System.debug('entrou no if recusaMetadado >>>');
                System.debug('retornoRecusaPadrao >>>> ' + retornoRecusa);
                retornoLst.add(retornoRecusa);
            }else {
                Retorno retornoRecusaPadrao = new Retorno();
                retornoRecusaPadrao.prioridade = 0;
                retornoRecusaPadrao.texto = '';
                retornoRecusaPadrao.descricao = 'Estamos devolvendo a proposta, em razão da recusa, após análise do risco.';
                System.debug('entrou no else recusaMetadado >>>');
                System.debug('retornoRecusaPadrao >>>> ' + retornoRecusaPadrao);
                retornoLst.add(retornoRecusaPadrao);
            }
        }
        //II-48 FIM

        for(Criticas ctc : request.criticas){
            if (ctc.isValid()) {
                if (ctc.grupo != null && ctc.grupo != '') {
                    lstGrupo.add(ctc.grupo);
                } else {
                    lstGrupo.add('');
                }
        
                if (ctc.status != null && ctc.status != '') {
                    lstStatus.add(ctc.status);
                } else {
                    lstStatus.add('');
                }
            }
        }

        list<Mensageria__mdt> lstMensageria = [SELECT id,Grupo__c,Status__c,Prioridade__c,Texto__c,Label 
                                                    FROM Mensageria__mdt 
                                                    WHERE Grupo__c IN: lstGrupo AND Status__c IN: lstStatus];

        for(Mensageria__mdt mens : lstMensageria){            
                mapTextoRetorno.put(mens.Grupo__c + mens.Status__c, mens);            
        }
        for(Criticas ct : request.criticas){
            Retorno retorno = new Retorno();
            retorno.prioridade = mapTextoRetorno.get(ct.grupo + ct.status) != null ? mapTextoRetorno.get(ct.grupo + ct.status).Prioridade__c : 0;
            retorno.texto = mapTextoRetorno.get(ct.grupo + ct.status) != null ? mapTextoRetorno.get(ct.grupo + ct.status).Texto__c : '';
            retorno.descricao = mapTextoRetorno.get(ct.grupo + ct.status) != null ? mapTextoRetorno.get(ct.grupo + ct.status).Label : '';


            retornoLst.add(retorno);
        }
        System.debug('retornoLst: ' + retornoLst);
        return retornoLst;
    }
}
//II-12 FIM