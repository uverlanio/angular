/*******************************************************************************************************************************
* 
* @author Pedro Augusto - SYS4B
* @date 19/10/2020
* @modifiedAt 
* Classe criada por conta da história PLV-4449
* Serviço para atualizar critica da proposta quando a mesma receber autorização do cartão
******************************************************************************************************************************/
@RestResource(urlMapping='/proposta/critica/autorizacaocartao')
global with sharing class CriticaPropostaAutorizacaoCartao {
    @HttpPost
	global static Response processarPost() {
		System.debug('processarPost');
		RestRequest req = RestContext.request;
		Response responseToSend = new Response();
		String payload = req.requestBody.toString();
		
        System.debug('Giordano payload: '+payload);
        
		try {
          //  Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(payload);
			Request payloadRequest = (Request) JSON.deserialize(payload, Request.class);
            System.debug('Giordano payloadRequest: '+payloadRequest);
            // TKCL-473 INÍCIO
            // obtem o RequestGenerico valido da requisicao (stargate ou portopag)   
             RequestGenerico reqGenerica = payloadRequest.obterRequestValido(); 
             System.debug('Giordano RequestGenerico: '+reqGenerica);
             responseToSend = atualizarCriticas(reqGenerica);
            // TKCL-473 FIM

            System.debug('Danilo responseToSend.sucesso ' +responseToSend.sucesso);
            
         //   System.debug('Danilo reqGenerica.mensagem ' +reqGenerica.mensagem.equals('Ops! Transação já realizada anteriormente. Consulte a forma de pagamento de suas parcelas pelo Portal do Cliente'));

            System.debug('Danilo reqGenerica.isApproved() ' +reqGenerica.isApproved());
            
            if(responseToSend.sucesso && reqGenerica.isApproved()){ // TKCL-473 INÍCIO/FIM
                try {
                    
                    //PLV-4854-FIX6 - inicio
                    if(responseToSend.sucesso == true) {
                    
                        Quote cotacao = new Quote();
                        cotacao.Id = reqGenerica.numeroReferencia.split('\\|')[1];
                        System.debug('cotacao.Id '+cotacao.Id);
                        cotacao.Status = 'Disponível para contratação'; //PLV-4854-FIX6 - inicio/fim
                        cotacao.Chave_de_Agrupamento__c = reqGenerica.codigoAgrupamento != null ? reqGenerica.codigoAgrupamento : '';
                        //update cotacao;
                        reqGenerica.mensagem='Criação do contrato iniciada';
                        responseToSend.sucesso = true;
                        
                    }else{

                        reqGenerica.mensagem= responseToSend.mensagem;
                        responseToSend.sucesso = false;
                        
                    }
                    //PLV-4854-FIX6 - fim
                                        
                } catch (Exception e) {
                    responseToSend.sucesso = false;
                    responseToSend.mensagem = 'Erro ao atualizar proposta: '+e.getCause() +' : '+e.getStackTraceString();
                }
            }else{
                responseToSend.sucesso = false;
            }

			System.debug('responseToSend'+JSON.serialize(responseToSend));	
		} catch (Exception e) {
			responseToSend.sucesso = false;
            responseToSend.mensagem = 'Erro ao atualizar proposta: '+e.getCause() +' : '+e.getStackTraceString();
		}

		return responseToSend;
    }

    global static Response atualizarCriticas(RequestGenerico reqGenerica){  // TKCL-473 INÍCIO/FIM
		System.debug('atualizarCriticas');
        System.debug('reqGenerica.numeroReferencia> ' + reqGenerica.numeroReferencia.split('\\|')[2]); // TKCL-473 INÍCIO/FIM
        CriticaPropostaTriggerHandler.isFirstTime = false;
        Response retorno = new Response();
        List<String> mensagens = new List<String>();
        List<CriticaProposta__c> criticas = [SELECT Id, OwnerId, CurrencyIsoCode, RecordTypeId, Proposta__c, Area__c, Codigo__c, Descricao__c, DataConclusao__c, 
        MensagemCliente__c, MensagemInterna__c, MensagemRepresentante__c, Procedimento__c, //INICIO/FIM | PLV-4647-VI-Guilherme Brito
        Origem__c, Severidade__c, Status__c, Tipo__c, MomentoAnalise__c, Integracao__c , ErrosRecalculo__c // PLV-4901-FIX2
        FROM CriticaProposta__c WHERE Id=:reqGenerica.numeroReferencia.split('\\|')[2]]; // TKCL-473-FIX01 INÍCIO/FIM
        
       // TKCL 473-FIX01 - INICIO
        CriticaProposta__c critica = null;
        if (criticas == null || criticas.isEmpty()) {
            retorno.sucesso = false;  
            retorno.mensagem = 'Critica da proposta inexistente para o número de referência informado.';
            return retorno;
        } else {
            critica = criticas[0];
        }
        // TKCL 473-FIX01 - FIM
        
        System.debug('Giordano Critica retorno: ......' + critica);
        String errosRecalculoOld = critica.ErrosRecalculo__c == null ? '' : string.valueOf( critica.ErrosRecalculo__c); //RVI-304 INICIO/FIM 
        
        //PLV-4854-FIX6 - inicio
        if(reqGenerica.mensagem != null){ // TKCL-473 INÍCIO/FIM
			DateTime now = System.now();
            critica.ErrosRecalculo__c = now.format( 'dd/MM/yyyy HH:mm:ss' ) + ': ' + reqGenerica.mensagem + '\n'+ errosRecalculoOld; //PLV-4854-FIX1 - inicio/fim  // TKCL-473 INÍCIO/FIM         
        // TKCL 473-FIX01 INICIO
        } else if (reqGenerica.getMsgCartao() != null) {  //RVI-304 Ajuste no nome do método para clareza do código
            critica.ErrosRecalculo__c = System.now().format( 'dd/MM/yyyy HH:mm:ss' ) + ': ' + reqGenerica.getMsgCartao() + '\n'+ errosRecalculoOld; //RVI-304 Ajuste no nome do método para clareza do código string.valueOf( critica.ErrosRecalculo__c)
        }
        // TKCL 473-FIX01 FIM
        //PLV-4854-FIX6 - fim

        if(critica.Status__c=='Liberado'){
            retorno.sucesso = false;
            retorno.mensagem = 'A Critica da Proposta já estava liberada';
            return retorno;
        }
        System.debug('Giordano ReqGenerica - Aprovado? '+reqGenerica.isApproved());
        if(reqGenerica.isApproved()){ // TKCL-473 INÍCIO/FIM
            //ANNVI-164 - INICIO
            if(critica.MomentoAnalise__c == 'Palavra final' && propostaTemCritNaoLib(criticas)){
                Quote proposta = [SELECT Id, Status FROM Quote WHERE Id = :critica.Proposta__c];
                if(proposta != null){
                    proposta.Status = 'Disponível para contratação';
                    update proposta;
                }
                
            }
            //ANNVI-164 - FIM
            critica.Status__c = 'Liberado';
            retorno.sucesso = true; //PLV-4854-FIX6 - inicio/fim
        }else{
            critica.Status__c = 'Falha na Integração'; //PLV-4854-FIX1 - inicio/fim
            critica.MensagemInterna__c = reqGenerica.mensagem != null ? reqGenerica.mensagem : reqGenerica.getMsgCartao(); //INICIO/FIM | PLV-4647-VI-Guilherme Brito TKCL-473 INÍCIO/FIM - TKCL-473 FIX01 INÍCIO/FIM //RVI-304 Ajuste no nome do método para clareza do código
            retorno.sucesso = false; //PLV-4854-FIX6 - inicio/fim    
            //PLV-4854-FIX1 - inicio
            /*CriticaProposta__c CriticaToClone = new CriticaProposta__c();
            CriticaToClone = critica.clone();
            CriticaToClone.id = null;
            CriticaToClone.Status__c = 'Pendente';
            CriticaToClone.MensagemInterna__c = ''; //INICIO/FIM | PLV-4647-VI-Guilherme Brito
            
            try {
                insert CriticaToClone;
                retorno.sucesso = true;
                mensagens.add('Nova Critica Inserida: '+CriticaToClone.Id);
            } catch (Exception e) {
                retorno.sucesso = false;
                mensagens.add('Erro ao atualizar inserir crítica de rejeição: '+e.getCause() +' : '+e.getStackTraceString());
            }*/
            //PLV-4854-FIX1 - fim
            
        }
        try {
            upsert critica;
            //retorno.sucesso = true; //PLV-4854-FIX6 - inicio/fim
            mensagens.add('Critica atualizada: '+critica.Id+' - Status: '+critica.Status__c);
        } catch (Exception e) {
            retorno.sucesso = false;
            mensagens.add('Erro ao atualizar crítica: '+e.getCause() +' : '+e.getStackTraceString());
        }
        CriticaPropostaTriggerHandler.isFirstTime = true;
        retorno.mensagem = String.join(mensagens, ',');

		return retorno;
	}

    global class Response {
        global Boolean sucesso {get;set;}
        global String mensagem {get;set;}
    }

    // TKCL-473 INÍCIO

    global class Request {
        global RequestStargate stargate {get;set;}
        global RequestPortopag portopag {get;set;}
        global RequestGenerico obterRequestValido() {
           return stargate != null ? (RequestGenerico) stargate : portopag != null ? (RequestGenerico) portopag : null;
        }
    }

    global abstract class RequestGenerico {
        global String numeroReferencia {get;set;}
        global String codigo { get; set; }
        global Integer grupo { get; set; }
        global String mensagem { get; set; }
        global String codigoAgrupamento {get;set;}

        global abstract Boolean isApproved();
        global abstract String getMsgCartao(); //TKCL 473-FIX01 INICIO/FIM //RVI-304 Ajuste no nome do método para clareza do código 
    }

    global class RequestStargate extends RequestGenerico {
      
        // global Integer codigo {get;set;}
        // global String mensagem {get;set;}
        global Integer codigoGateway {get;set;}
        global String mensagemGateway {get;set;}
        global override Boolean isApproved() {
            System.debug('Danilo Stargate');
            //PLV-5793 INICIO
            if(this.mensagem.equals('Ops! Transação já realizada anteriormente. Consulte a forma de pagamento de suas parcelas pelo Portal do Cliente')){
                return true;
            }
            //PLV-5793 FIM
           return this.codigo == '2';
        }
        //TKCL 473-FIX01 INICIO
        global override String getMsgCartao() { //RVI-304 Ajuste no nome do método para clareza do código
            return this.mensagem;
        }
        //TKCL 473-FIX01 FIM
    }

    global class RequestPortopag extends RequestGenerico {
        global String id { get; set; } 
        global String idExterno { get; set; }
        global String estado { get; set; }
        global List<EmissaoTO.CobrancaTO> cobrancas { get; set; }
        global override Boolean isApproved() {
            if (this.cobrancas != null && !this.cobrancas.isEmpty()) { 
                for(EmissaoTO.CobrancaTO cobranca : this.cobrancas){
                  if(cobranca.estado != null && cobranca.estado.equals('PAGA')){ // TKCL-458 FIX02
                     return true;
                  }
                }
            }
            return false;
            //PLV-5793 FIM
        } 
        //TKCL 473-FIX01 INICIO
        global override String getMsgCartao() { //RVI-304 Ajuste no nome do método para clareza do código
            if (this.cobrancas == null || this.cobrancas.isEmpty()) {
               return this.mensagem;
            }
            // TKCL-458 FIX02 INICIO
            for(EmissaoTO.CobrancaTO cobranca : this.cobrancas){
                if(cobranca.estado!= null && cobranca.estado.equals('PAGA')){
                   return 'APROVADO'; //RVI-304 INICIO/FIM
                }
            }
            return 'REJEITADO';
            // TKCL-458 FIX02 FIM
        } 
        
        //TKCL 473-FIX01 FIM 
    }
    // TKCL-473 FIM

    //ANNVI-164 - INICIO
    public static Boolean propostaTemCritNaoLib(List<CriticaProposta__c> lstCriticas){
        if(lstCriticas == null) return false;
        
        List<String> valoresLiberados = new List<String>{'Liberado' , 'Cancelada'};

        for(CriticaProposta__c ctr : lstCriticas){
            if(!valoresLiberados.contains(ctr.Status__c)) return true;
        }

        return false;
    }
    //ANNVI-164 - FIM
}