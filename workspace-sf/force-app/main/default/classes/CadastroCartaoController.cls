/****************************
@description  Classe que contém as regras para o cadastro do cartão na proposta 
@author Rogerio Menezes - Globant
@date 06/10/2023
@Classe criada por conta da história II-86        
****************************/

global class CadastroCartaoController {

    global class DadosProposta{
        public String produto { get; set; }
        public String formaPagamento { get; set; }
    }

    @AuraEnabled(cacheable=true)
    global static String getLinkPortoPag(String codRamo, String descricao, String ofertaSelecionada, String parcelas, String idProposta){
        API_Link_de_Pagamento__mdt metadados = MetadataDAO.getInstance().apiLinkDePgto('API_Link_de_Pagamento');
        APTlmkGeraLinkPgtoCartaoCreditoService service = new APTlmkGeraLinkPgtoCartaoCreditoService();
        RestResponse restResponse = RestContext.response;
        HttpRequest request = new HttpRequest();
        Http http = new Http();
        HttpResponse tokenResponse = service.getToken(metadados);
        String empresa = '14';
		
        if(tokenResponse.getStatusCode() != 200){                
            restResponse.statusCode = tokenResponse.getStatusCode(); 
			return tokenResponse.getBody(); 
        }            

        TokenApiLinkPgtoCartaoCredito tokenLink = new TokenApiLinkPgtoCartaoCredito(tokenResponse.getBody());
		HttpResponse urlResponse = new HttpResponse();

		List<ContratanteProposta__c> qtdParcelas = [SELECT QuantidadeParcelas__c FROM ContratanteProposta__c where Proposta__c =: idProposta];
        parcelas = String.valueOf(qtdParcelas[0].QuantidadeParcelas__c);

		List<Opportunity> codEmpresa = [SELECT Id, Produto__r.Empresa__r.CodigoEmpresa__c FROM Opportunity WHERE Numero__c =: ofertaSelecionada];

		String codEmp = codEmpresa[0].Produto__r.Empresa__r.CodigoEmpresa__c;
		String valorParcela = '1000';

		String codigo = '32';
		if(codEmp == empresa){
			descricao = 'Vida do Seu Jeito';
			codigo = '8b4da283-389d-47d5-83f0-fd8fc6d02708';
		}
		String body = '{"idExterno":"'+ofertaSelecionada+'","expiraEm":"'+ metadados.expiraEm__c +'","nome":"Cliente Fulando de Tal",'+ 
        '"tipoTransacao":"CAPTURA","tipoLink":"REGISTRO_CARTAO","documento":{"tipo":"CPF","numero":"13481182657"},"produto":{"codigo":"'+ codigo +'",'+ 
        '"descricao":"'+ descricao +'"},"metadados":{"tipo_documento_comercial":"01","endosso":"","codigo_empresa":"'+ codEmp +'",'+
        '"composicao_valor_parcela":"01","codigo_ramo":"'+ codRamo +'","parcela":"'+ parcelas + '","contrato_comercial":"","evento_emissao":"1",'
        +'"flag_sinalizador_processo":"O","flag_produto_seguro":"S","codigo_agregador":"","codigo_modalidade":"24","auth_type":"SINGLE"},'+
        '"valorTotal":"'+ valorParcela +'"}';

		urlResponse = service.getLinkPgtoCartaoCredito(body, metadados, tokenLink);
		System.debug('Rogerio urlResponse' + urlResponse.getBody());
		return urlResponse.getBody();
	}

    @AuraEnabled    
    global static void rgstNewCard(String ticket, String bandeira, String idProposta){
        List<ContratanteProposta__c> contratanteProps = [SELECT Id, Proposta__r.AccountId, Proposta__r.Account.Name, CartaoCredito__r.Bandeira__c
                                                        FROM ContratanteProposta__c 
                                                        WHERE Proposta__c = :idProposta LIMIT 1];
        
        ContratanteProposta__c contratanteProp = contratanteProps[0];
        String conta = contratanteProp.Proposta__r.AccountId;
        String nomeConta = contratanteProp.Proposta__r.Account.Name;

        List<CartaoCredito__c> existingCard = [SELECT Id, Bandeira__c FROM CartaoCredito__c WHERE Conta__c = :conta AND Ticket__c = :ticket LIMIT 1];

        CartaoCredito__c newCardCred;
        if(existingCard.isEmpty()){
            newCardCred = new CartaoCredito__c(
                Conta__c = conta,
                Ticket__c = ticket,
                Bandeira__c = bandeira
            );
            insert newCardCred;
        }else{
            newCardCred = existingCard[0];
            if(String.isBlank(existingCard[0].Bandeira__c)) {
                existingCard[0].Bandeira__c = bandeira;
                update existingCard;
            }
        }

        List<ContratanteProposta__c> recordsToUpdate = new List<ContratanteProposta__c>();
        for(ContratanteProposta__c ctrProp : contratanteProps){
            ctrProp.CartaoCredito__c = newCardCred.Id;
            recordsToUpdate.add(ctrProp);
        }
        if(!recordsToUpdate.isEmpty()){
            update recordsToUpdate;
        }
        updateCritica(idProposta);
    }


    @AuraEnabled
    global static void updateCritica(String idProposta){
        String crtLiberado = 'Liberado';
        List<CriticaProposta__c> lstCritica = [SELECT ID,Status__c, Proposta__c, MomentoAnalise__c  
                                                FROM CriticaProposta__c 
                                                WHERE MomentoAnalise__c = 'Palavra final' AND Proposta__c =: idProposta];

        List<CriticaProposta__c> criticaToUpdate = new List<CriticaProposta__c>();
        for(CriticaProposta__c ctrProp : lstCritica){
            ctrProp.Status__c = crtLiberado;
            criticaToUpdate.add(ctrProp);
        }
        if (!criticaToUpdate.isEmpty()) {
            update criticaToUpdate;
        }
    }
    
    @AuraEnabled(cacheable=true)
    global static String getDadosProposta(String idProposta) {

        DadosProposta response = new DadosProposta();
        
        List<Quote> proposta = [SELECT Id, Produto__r.CodigoPrecificaProduto__c 
                                        FROM Quote 
                                        WHERE id = :idProposta LIMIT 1];

        List<ContratanteProposta__c> contratanteProps = [SELECT Id, FormaPagamento__r.Codigo__c 
                                                        FROM ContratanteProposta__c 
                                                        WHERE Proposta__c = :idProposta LIMIT 1];

        if (!proposta.isEmpty()) {
            response.produto = proposta[0].Produto__r.CodigoPrecificaProduto__c;
        }
        if (!contratanteProps.isEmpty()) {
            response.formaPagamento = contratanteProps[0].FormaPagamento__r.Codigo__c;
        }
        return JSON.serialize(response); 
    }  
}