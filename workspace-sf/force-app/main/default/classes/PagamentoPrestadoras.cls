// CRIAÇÃO EM FUNÇÃO DA HISTORIA PLV-3918
public class PagamentoPrestadoras {
    //PLV-4148-FIX5
    @AuraEnabled
    public static retornoRecordType validaTipoRegistro(String recordType){
       //PLV-3918 - FIX2 - INICIO
       system.debug('validaTipoRegistro IDRECORDtYPE'+recordType);
       //PLV-3918 - FIX2 - FIM
       
       
       //Id recordTypeId = Schema.SObjectType.Requisicao_de_Pagamento__c.getRecordTypeInfosByName().get('Operacional de sinistros').getRecordTypeId();
        retornoRecordType retorno = new retornoRecordType();
        if(recordType == null){
            List<RecordTypeInfo> infos = Requisicao_de_Pagamento__c.SObjectType.getDescribe().getRecordTypeInfos();
            //PLV-4148-FIX7 - INICIO
            for(RecordTypeInfo i : infos){
                system.debug('RecordTypeInfo'+i.getDeveloperName());
                String idUser = UserInfo.getUserId();
                String idPerfil = UserInfo.getProfileId();
                system.debug('usuario'+idUser);
                system.debug('usuario perfil'+idPerfil);
                if(i.available && i.developername != 'Mestre'){
                    system.debug('entrou no tipo de registro'+i.getName());
                    retorno.idRecordType = i.getRecordTypeId();
                	retorno.nomeRecordType = i.getName();
                    break;
                }
               
            }
            //PLV-4148-FIX7 - FIM
            
        }else{
            RecordType nomeRecordType = [select Name, Id, SobjectType 
                                                    from RecordType 
                                                    where SobjectType  = 'Requisicao_de_Pagamento__c' AND Id =: recordType];
                     
            retorno.idRecordType = nomeRecordType.Id;
            retorno.nomeRecordType = nomeRecordType.Name;
        }
           
     
       return retorno;
    }
    
    public class retornoRecordType{
        @AuraEnabled 
        public Id idRecordType{get; set;}
        @AuraEnabled 
        public String nomeRecordType{get; set;}
        
    }
    //PLV-4148-FIX5 - FIM
    @AuraEnabled
    public static List<Pagamento_de_Sinistro__c> buscarPagamentosSinistros(String dtinicio, String dtfim, String parceiro){
       //PLV-3918 - FIX2 - INICIO
       system.debug('buscarPagamentosSinistros');
       //PLV-3918 - FIX2 - FIM
        Date dataInicio = Date.valueOf(dtinicio);
        Date dataFim = Date.valueOf(dtfim);
        //PLV-4148-FIX5 - INICIO
        List<Pagamento_de_Sinistro__c>lretornoPagamentosSinistros = new List<Pagamento_de_Sinistro__c>();
       
        List<Pagamento_de_Sinistro__c> lpagamentosSinistros = [SELECT Valor_Pago__c, Caso_de_Sinistro__c, Caso_de_Sinistro__r.Dataocorrencia__c, Caso_de_Sinistro__r.Data_sinistro_avisado__c,
                                                               Caso_de_Sinistro__r.NumeroSinistro__c, Id, Valor_total_a_ser_indenizado__c, CurrencyIsoCode
                                                               FROM Pagamento_de_Sinistro__c WHERE Status__c = 'Pendente' AND 
                                                               CreatedDate >=: dataInicio AND 
                                                               CreatedDate <=: dataFim AND
                                                               Requisicao_de_Pagamento__c = NULL AND 
                                                               Beneficiario_da_Garantia__c =: parceiro];
       //PLV-3918 - FIX2 - INICIO
       system.debug('buscarPagamentosSinistros:lpagamentosSinistros'+lpagamentosSinistros);
       //PLV-3918 - FIX2 - FIM
            
        return lpagamentosSinistros;
         //PLV-4148-FIX5 - FIM
    }
    @AuraEnabled
    public static void atualizaPagamentoSinistro(Id recordId,List<String> IdsPagSinistro){
        system.debug('recordId'+recordId);
        system.debug('IdsPagSinistro'+IdsPagSinistro);
        List<Pagamento_de_Sinistro__c> lPagamentoSisnitroUpdade = new List<Pagamento_de_Sinistro__c>();
        
        List<Pagamento_de_Sinistro__c> lPagamento_de_Sinistro = [SELECT Id, Requisicao_de_Pagamento__c FROM Pagamento_de_Sinistro__c WHERE Id in:(IdsPagSinistro)];
        for(Pagamento_de_Sinistro__c ps : lPagamento_de_Sinistro){
            ps.Requisicao_de_Pagamento__c = recordId;
            ps.Status__c = 'Liberado';
            lPagamentoSisnitroUpdade.add(ps);
        }
        update lPagamentoSisnitroUpdade;
        //return true;
    }
    
	//PLV-4148 - INICIO
	//PLV-4356 - INCIO 
	@AuraEnabled
    public static List<BeneficiarioGarantia__c> buscarGarantias(String dtinicio, String dtfim, String parceiro, String moeda){
       
       	system.debug('PagamentoPrestadoras.buscarGarantias');
        //List<PagamentoGarantia__c> retornaListaGarantias = new List<PagamentoGarantia__c>();
        List<BeneficiarioGarantia__c > retornaListaGarantias = new List<BeneficiarioGarantia__c>();
        set<Id> retornoIdGarantias = new Set<Id>();
		Date dataInicio = Date.valueOf(dtinicio);
        Date dataFim = Date.valueOf(dtfim);
       
        retornaListaGarantias = [SELECT 
                                 Pagamento_de_garantia__c, 
                                 Conta__r.Name, 
                                 Pagamento_de_garantia__r.Name,
                                 Pagamento_de_garantia__r.Caso__r.NumeroSinistro__c, 
                                 Pagamento_de_garantia__r.Caso__r.Contrato__c, 
								 Pagamento_de_garantia__r.ValorIndenizado__c, 
                                 Pagamento_de_garantia__r.CurrencyIsoCode, 
                                 Pagamento_de_garantia__r.SomaValorBeneficiarios__c
								FROM BeneficiarioGarantia__c 
                                WHERE 
                                 Pagamento_de_Sinistro__r.Id = null AND
                                 Pagamento_de_garantia__r.fase__c = 'Em Análise' AND
                                 Pagamento_de_garantia__r.Caso__r.CreatedDate >=: dataInicio AND
                                 Pagamento_de_garantia__r.Caso__r.CreatedDate <=: dataFim AND
                                 Pagamento_de_garantia__r.Caso__r.Type = 'Sinistro' AND
								 conta__c =: parceiro AND
                                 Pagamento_de_garantia__r.CurrencyIsoCode =: moeda AND
                                 Pagamento_de_garantia__r.SomaValorBeneficiarios__c > 0
                                ];
       
      
		/*List<PagamentoGarantia__c> listPagGarantira = [SELECT 
                                                       	Id, 
                                                        Caso__r.NumeroSinistro__c, 
                                                        Name, 
                                                        caso__r.Account.Name, 
                                                        Caso__r.Contrato__c, 
                                                        ValorIndenizado__c,
                                                        CurrencyIsoCode,
                                                        SomaValorBeneficiarios__c
                                                        
                                                       FROM 
                                                       	PagamentoGarantia__c 
                                                       WHERE 
                                                       	fase__c = 'Em Análise' AND 
                                                        //PLV-4148-FIX2 - INICIO
                                                        Caso__r.CreatedDate >=: dataInicio AND
                                                        Caso__r.CreatedDate <=: dataFim AND
                                                        //PLV-4148-FIX2 - FIM
														Caso__r.Type = 'Sinistro' AND
														Caso__r.Parceiro__r.conta__c =: parceiro AND
                                                        CurrencyIsoCode =: moeda
                                                        //PLV-4148-FIX4 - INICIO
                                                         AND SomaValorBeneficiarios__c > 0
                                                         //PLV-4148-FIX4 - FIM
                                                       
                                                      
                                                      ];
		
       
       system.debug('PagamentoPrestadoras.listPagGarantira = '+ listPagGarantira);
        
       Set<Id> idsPagamentosGarantias = new Set<Id>(); 
        for(PagamentoGarantia__c p : listPagGarantira){
            idsPagamentosGarantias.add(p.Id);
        }
        if(idsPagamentosGarantias.size() > 0){
            List<Pagamento_de_Sinistro__c> idsGarantiasRelacionados = [SELECT
                                             	Garantia_do_Sinistro__c
                                              FROM
                                              Pagamento_de_Sinistro__c
                                              WHERE
                                              Garantia_do_Sinistro__c IN : (idsPagamentosGarantias)
                                             ];
			for(Pagamento_de_Sinistro__c p : idsGarantiasRelacionados){
                   retornoIdGarantias.add(p.Garantia_do_Sinistro__c); 
            }
			for(PagamentoGarantia__c pg : listPagGarantira){
                if(!retornoIdGarantias.contains(pg.Id))
                	retornaListaGarantias.add(pg);
            }           
        }else{
            retornaListaGarantias = listPagGarantira;
        }*/   	
        return retornaListaGarantias;
        
    }
    //PLV-4356 - FIM
    @AuraEnabled
    public static void createPagamentoSinistro(Id recordId,List<String> idsPagamentoGarantias){
                
        List<Pagamento_de_Sinistro__c> lPagSinistro = new List<Pagamento_de_Sinistro__c>();
        List<PagamentoGarantia__c > lPagamentoGarantia = [select 
                                                          Id, Caso__c, ValorIndenizado__c, CurrencyIsoCode,
                                                          //PLV-4148-FIX1 - INICIO
                                                          Garantia_do_segurado_do_contrato__r.SeguradoContrato__r.Conta__c,
                                                          SomaValorBeneficiarios__c
                                                          //PLV-4148-FIX - FIM
                                                          from 
                                                          PagamentoGarantia__c where Id in : (idsPagamentoGarantias)];
        system.debug('lPagamentoGarantia'+lPagamentoGarantia);
        for(PagamentoGarantia__c p : lPagamentoGarantia){
            Pagamento_de_Sinistro__c pgSinistro = new Pagamento_de_Sinistro__c();   
            pgSinistro.Tipo_de_Aprova_o__c				= 'Alçada SAP';
            pgSinistro.Tipo_de_OP__c					= 'Registro';            
            pgSinistro.OP_SAP__c						= null;
            pgSinistro.Status__c						= 'Pendente';
            pgSinistro.Data_Programada_de_Pagamento__c	= null;                           
            pgSinistro.Data_de_pagamento__c				= null;                                      
            pgSinistro.Requisicao_de_Pagamento__c		= null;
            pgSinistro.Sinistro_com_Pendencias__c		= False;
            pgSinistro.Requisicao_de_Pagamento__c = recordId;
            pgSinistro.Caso_de_Sinistro__c = p.Caso__c;
            pgSinistro.CurrencyIsoCode = p.CurrencyIsoCode;
            pgSinistro.Beneficiario_da_Garantia__c = p.Garantia_do_segurado_do_contrato__r.SeguradoContrato__r.Conta__c;
            //PLV-4148 - INICIO
            pgSinistro.Valor_total_a_ser_indenizado__c = p.SomaValorBeneficiarios__c;
            //PLV-4148 - FIM
            
            pgSinistro.Garantia_do_Sinistro__c = p.Id;
            //pgSinistro.Beneficiario_da_Garantia__c	= casoObj.Parceiro__r.conta__c
            lPagSinistro.add(pgSinistro);
                       
            
        }
       
        insert lPagSinistro;
                
        //PLV-4148-FIX5 - INICIO
        Map<Id,Id> mPagamentosSinistros = new Map<Id,Id>();
        system.debug('pagamentos de sinistro insert'+lPagSinistro);
        for(Pagamento_de_Sinistro__c pa : lPagSinistro){
            system.debug('ID pagamento sinistro insert'+pa.Id);
            mPagamentosSinistros.put(pa.Garantia_do_Sinistro__c,pa.Id);
        }
        system.debug('map pagamentos'+mPagamentosSinistros);
        List<BeneficiarioGarantia__c> lbenificiario = [select 
                                                       	   Id, 
                                                           Pagamento_de_Sinistro__c, 
                                                           Requisi_o_de_Pagamento__c, 
                                                           Pagamento_de_garantia__c 
                                                       from 
                                                       BeneficiarioGarantia__c
                                                       where 
                                                       Pagamento_de_garantia__c in: (mPagamentosSinistros.keyset())];
        List<BeneficiarioGarantia__c> lbenificiarioUpdate = new List<BeneficiarioGarantia__c>();
        for(BeneficiarioGarantia__c b : lbenificiario){
           b.Requisi_o_de_Pagamento__c = recordId;
            if(mPagamentosSinistros.containsKey(b.Pagamento_de_garantia__c)){
                b.Pagamento_de_Sinistro__c = mPagamentosSinistros.get(b.Pagamento_de_garantia__c);
            }
           lbenificiarioUpdate.add(b);
            
        }
        update lbenificiarioUpdate;
        //PLV-4148-FIX5 - FIM
        
        system.debug('cria pagamento sinsistro'+idsPagamentoGarantias);
        system.debug('cria pagamento sinsistro'+recordId);
    }
    
    @AuraEnabled
    public static List<CurrencyType> buscaMoedas(){
        List<CurrencyType> lMoedas = [SELECT Id,IsActive, IsoCode FROM CurrencyType WHERE IsActive = true];
        return lMoedas;
    }
    //PLV-4148 - FIM
	
	//PLV-4501 Inicio
	@AuraEnabled
    public static String criarPagamentoPrestador(Id recordTypeId, String dtinicio, String dtfim, String codigoPrestador, String valorPagamento){
		
		Requisicao_de_Pagamento__c novaRequisicaoPagamento = new Requisicao_de_Pagamento__c();
		
		novaRequisicaoPagamento.Contas_de_Parceiro__c						= codigoPrestador;
		novaRequisicaoPagamento.Data_de_Inicio_de_Periodo__c				= Date.valueOf(dtinicio); 
		novaRequisicaoPagamento.Data_de_Final_de_Periodo__c					= Date.valueOf(dtfim);
		novaRequisicaoPagamento.Quantidade_total_de_sinistros_realizados__c = 0;
		novaRequisicaoPagamento.Status__c									= 'Pendente';
		novaRequisicaoPagamento.Tipo_Cotacao__c								= 'Cotação manual';
		novaRequisicaoPagamento.Tipo_moeda__c								= 'BRL';
		novaRequisicaoPagamento.Valor_da_Cotacao_de_Moeda_Estrangeira__c	= 0;
		novaRequisicaoPagamento.Valor_Total_Prestadora__c					= Decimal.valueOf(valorPagamento);
		novaRequisicaoPagamento.RecordTypeId								= recordTypeId;

		insert novaRequisicaoPagamento;

		return 'ok';
	}
	//PLV-4501 Fim

    //PLV-4604 - INICIO
    @AuraEnabled
    public static Requisicao_de_Pagamento__c criarPagamentoDespesa(Requisicao_de_Pagamento__c requisicao){
        try{
            insert requisicao;
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
        return requisicao;
    }
    //PLV-4604 - FIM
  
}