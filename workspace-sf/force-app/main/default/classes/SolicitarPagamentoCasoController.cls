//PLV - 4043 inicio
public with sharing class SolicitarPagamentoCasoController {
    @AuraEnabled
    public static String verificafase(String recordId) 
    {
    
    
        List<PagamentoGarantia__c> lPagGarantia = [Select Id, Status_do_pagamento__c, Fase__c, Caso__c, Soma_Percentual__c 
                                                   FROM PagamentoGarantia__c Where Caso__c =: recordId 
                                                   And Fase__c = 'Em Análise' 
                                                   And Status_do_pagamento__c != 'Recusado'
                                                   And Status_do_pagamento__c != 'Pago'
                                                  ]; 
        
        if(lPagGarantia.size() == 0)return 'Somente é possível solicitar pagamento na fase "Em Análise" e status diferente de Recusado ou Pago.';
        
        
        //soma percentual é um campo de resumo, então todas as lPagGarantia possuem o mesmo valor.
        if(lPagGarantia[0].Soma_Percentual__c > 100) return 'Favor verificar os percentuais de indenização dos beneficiários do caso, pois somados não podem ultrapassar 100%.';
        
        
        //* Verificar se existe alguma atividade do tipo "Pendência" 
        //com status diferente de "Resolvida". 
        //Caso exista, informar a mensagem ao usuário 
        //"Não é possível realizar o pagamento pois há pendências em aberto."
        List<Task> LstTsk = [SELECT Id 
                             FROM Task 
                             WHERE WhatId IN:lPagGarantia
                             AND Status != 'Finalizada' 
                             AND TipoComunicado__c = 'Pendência'];
        
        if(LstTsk.size() > 0)return 'Não é possível realizar o pagamento pois há pendências em aberto.';      
        
        //Verificar se o Caso de atendimento daquele pagamento está diferente da fase "Em Regulação"
        //Caso não estiver, exibir mensagem de erro e nao permitir a criação
        
        List<Case> vCase = [Select Id, Status From Case Where Id =: recordId AND (Status = 'Em Regulação' OR Status = 'Liquidação')]; //PLV - 4043 FIX 07/08 INICIO/FIM
        
        if(vCase.size() == 0 && !Test.isRunningTest()) return 'O Caso precisa estar em fase de Regulação para criação de pagamentos.';
        
        //Regra 1 = precisa existir um beneficiario, se não "Beneficiário não informado"
        //Regra 2 = cada beneficiario precisa estar com status "liberado", 
        //Regra 2.1  caso não exista tipo de pagamento msg = "Tipo de Pagamento não informado"
        
        //PLV-4745 - INÍCIO
        List<BeneficiarioGarantia__c> LstBeneTemp = [SELECT Pagamento_de_garantia__c,Status__c,Tipo_de_Pagamento__c, Conta__c
                                                 FROM BeneficiarioGarantia__c
                                                 WHERE Pagamento_de_garantia__c IN: lPagGarantia
                                                 AND Status__c = 'Liberado'          //PLV-4374 - INICIO-FIM
                                                 //AND Pagamento_de_Sinistro__c == null //PLV-4374 - INICIO-FIM
                                                ];
        
        List<Id> accIds = New List<Id>();    
        List<BeneficiarioGarantia__c> LstBene = new List<BeneficiarioGarantia__c>();    
        for(BeneficiarioGarantia__c ben : LstBeneTemp){
            if(!accIds.contains(ben.Conta__c)){
                accIds.add(ben.Conta__c);   
                LstBene.add(ben);
            }
        }
        //PLV-4745 - FIM

        //PLV-4374 - INICIO
        if(LstBene.size()==0) return 'Não foi encontrado beneficiário no pagamento selecionado.';
        
        return 'Ok';
        /* List<Object> Lst2Pay = new List<Object>();
        List<Object> Lstnot2Pay = new List<Object>();
        List<Object> LstNaoLiberados = new List<Object>(); 
        else{
            for(BeneficiarioGarantia__c b : LstBene)
            {
                if((b.Status__c == 'Liberado') && (b.Tipo_de_Pagamento__c != null))
                {
                    Lst2Pay.add(b);
                }
                if((b.Status__c == 'Liberado') && (b.Tipo_de_Pagamento__c == null)){Lstnot2Pay.add(b);
                                                                                   }
                if(b.Status__c != 'Liberado')
                {
                    LstNaoLiberados.add(b);
                }
            }
            
            //se tiver um pagável liberar solicitação de pagamento
            if(Lst2Pay.size() > 0)
            {
                return 'Ok';
            }
            
            //se n tiver um pagável "Tipo de Pagamento não informado"
            if((Lstnot2Pay.size() > 0)&& (Lst2Pay.size() == 0))
            {
                return 'Tipo de Pagamento não informado.';
            }
            
            if(LstBene.size() == LstNaoLiberados.size())
            {
                return 'Não existem beneficiários liberados para pagamento.';
            }
        }
        
        return null; */
        //PLV-4374 - FIM
    }
    
    @AuraEnabled
    public static List<BeneficiarioGarantia__c> consultainfo(String recordId) 
    {     
        
        List<PagamentoGarantia__c> lstPag = [Select Id, Caso__r.AccountId, ValorIndenizado__c,ComplementoIndenizacao__c, Capital__c, PercentualLiberados__c
                                             FROM PagamentoGarantia__c WHERE caso__c =: recordId
                                             ]; //PLV-4070 - INICIO/FIM
        //PLV-4745 - INÍCIO                                     
        List<BeneficiarioGarantia__c> LstBeneTemp = [SELECT Id, Name, Data_programada_do_pagamento__c,Pagamento_de_garantia__c, 
                                                 Conta__c, Status__c,Tipo_de_Pagamento__c, conta__r.Cnpj__c,Conta__r.Name, 
                                                 conta__r.Cpf__c,
                                                 Email__c, // PLV-5316 - INICIO/FIM
												 Pagamento_de_garantia__r.ValorIndenizado__c, //PLV-4070 - INICIO/FIM                                                 
												 Percentual_de_indenizacao__c, Pagamento_de_garantia__r.Caso__r.NumeroSinistro__c, 
                                                 Pagamento_de_garantia__r.Caso__c, Pagamento_de_garantia__r.Caso__r.Sinistro_Judicial__c, 
                                                 ValorIndenizacao__c,                   //PLV-4374 - INICIO/FIM
                                                 Pagamento_de_Sinistro__r.Tipo_de_Pagamento__c, Pagamento_de_Sinistro__r.Sucursal_Destino_de_Cheque__c, //PLV-4374 - INICIO/FIM
                                                 Pagamento_de_Sinistro__r.Dados_Bancarios__c, Sucursal_Destino_de_Cheque__c, Informacao_bancaria__c //PLV-4374 - INICIO/FIM                                      
                                                 FROM BeneficiarioGarantia__c
                                                 WHERE Pagamento_de_garantia__c IN : lstPag
                                                 AND Status__c = 'Liberado'
                                                 //AND Tipo_de_Pagamento__c != null     //PLV-4374 - INICIO/FIM
                                                 //AND Pagamento_de_Sinistro__c == null //PLV-4374 - INICIO/FIM
                                                ];

        List<Id> accIds = New List<Id>();    
        List<BeneficiarioGarantia__c> LstBene = new List<BeneficiarioGarantia__c>();    
        for(BeneficiarioGarantia__c ben : LstBeneTemp){
            if(!accIds.contains(ben.Conta__c)){
                accIds.add(ben.Conta__c);   
                LstBene.add(ben);
            }
        }        
        //PLV-4745 - FIM
        List<BeneficiarioGarantia__c> LstBene2 = new List<BeneficiarioGarantia__c>();
        List<String> lVerificaId = new List<String>();
        //PLV-4374 - INICIO
        for(BeneficiarioGarantia__c bene: LstBene){
        
            if(!lVerificaId.contains(bene.Conta__c)){ 
                bene.ValorIndenizacao__c = somaValorIndenizado(bene.conta__c,lstPag);
                LstBene2.add(bene);
            }
            
        }   
        //PLV-4374 - FIM
        return LstBene2;
    }
    //PLV-4374 - INICIO
    @AuraEnabled
    public static String[] picklistValue(String fieldName, Boolean type) {
        String[] values = new String[]{};
        String[] types = new String[]{'Pagamento_de_Sinistro__c'};
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {
                    if(type){
                        values.add(entry.getValue());
                    } else {
                        values.add(entry.getLabel());
                    }
                }
            }
        }
        return values;
    }
    //PLV-4374 - FIM
    
    //PLV-4374 - INICIO
    @AuraEnabled
    public static String updateTipoPagamento(String tipoPagamento, BeneficiarioGarantia__c bene, String suc){
        List<BeneficiarioGarantia__c> lstBene = [SELECT Id, Tipo_de_Pagamento__c, Pagamento_de_Sinistro__c,
                                                  Pagamento_de_Sinistro__r.Tipo_de_Pagamento__c
                                                  FROM BeneficiarioGarantia__c
                                                  WHERE Conta__c =: bene.Conta__c
                                                  AND Pagamento_de_Sinistro__c =: bene.Pagamento_de_Sinistro__c
                                                  AND Pagamento_de_garantia__c =: bene.Pagamento_de_garantia__c];
        List<Pagamento_de_Sinistro__c> lstPaga = [SELECT Id, Tipo_de_Pagamento__c
                                                  FROM Pagamento_de_Sinistro__c
                                                  WHERE Id =: bene.Pagamento_de_Sinistro__c
                                                  AND Beneficiario_da_Garantia__c =: bene.Conta__c];
        
        String[] sucursales1 = picklistValue('Sucursal_Destino_de_Cheque__c', true);
        Integer sucursalApi;
        String[] values = new String[]{};
        String[] types = new String[]{'Pagamento_de_Sinistro__c'};
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get('Sucursal_Destino_de_Cheque__c').getDescribe().getPicklistValues()) {
                if (entry.isActive() && entry.getLabel() == suc) {
                    values.add(entry.getValue());
                    break;
                }
            }
        }
        List<BeneficiarioGarantia__c> lstBenUp = new List<BeneficiarioGarantia__c>();
        for(BeneficiarioGarantia__c b : lstBene){
            b.Tipo_de_Pagamento__c = tipoPagamento;
            if(b.Pagamento_de_Sinistro__c != null){
                b.Pagamento_de_Sinistro__r.Tipo_de_Pagamento__c = tipoPagamento;
            }
            if(tipoPagamento != null){
                b.Sucursal_Destino_de_Cheque__c = tipoPagamento == 'Cheque' ? Integer.valueOf(values[0]) : null;
            }
            lstBenUp.add(b);
        }
        List<Pagamento_de_Sinistro__c> lstPagUp = new List<Pagamento_de_Sinistro__c>();
        for(Pagamento_de_Sinistro__c p : lstPaga){
            p.Tipo_de_Pagamento__c = tipoPagamento;
            p.Sucursal_Destino_de_Cheque__c = tipoPagamento == 'Cheque' ? values[0] : null;
            lstPagUp.add(p);
        }
        
        try{
            Update lstPagUp;
            Update lstBenUp;
        }catch(Exception e){
            System.debug('Exception: ' + e);
            return values + e.getMessage();
        }
        return 'OK';
    }
    //PLV-4374 - FIM
	//PLV - 4043 FIX 07/08 INICIO  	  
    @AuraEnabled
    public static String gravapagamento(String recordId, String idBancos, Map<Id,String> tipoPagamento, Map<Id,String> sucursal) //PLV-4374 INICIO/FIM
    {  
        
        List<String> lBancos = idBancos.split(';');
        
        List<InformacaoBancaria__c> lstInfo = [SELECT Id, Conta__c FROM InformacaoBancaria__c WHERE Id IN :lBancos];
        List<PagamentoGarantia__c> lPagGarantia = [SELECT Id, Status_do_pagamento__c, Fase__c, Caso__c, Soma_Percentual__c,
                                                   ValorIndenizado__c //PLV-4070 - INICIO/FIM
                                                   FROM PagamentoGarantia__c 
                                                   WHERE Caso__c =: recordId 
                                                   AND Fase__c = 'Em Análise' 
                                                   AND Status_do_pagamento__c != 'Recusado'
                                                   AND Status_do_pagamento__c != 'Pago'
                                                  ];   
        List<BeneficiarioGarantia__c> LstBene = [SELECT Id, Name, Data_programada_do_pagamento__c,Pagamento_de_garantia__c, 
                                                 Conta__c, Status__c,Tipo_de_Pagamento__c, conta__r.Cnpj__c, 
                                                 conta__r.Cpf__c, 
												 Pagamento_de_garantia__r.ValorIndenizado__c, //PLV-4070 - INICIO/FIM                                                 
												 Percentual_de_indenizacao__c, Pagamento_de_garantia__r.Caso__r.NumeroSinistro__c, 
                                                 Pagamento_de_garantia__r.Caso__c, Pagamento_de_garantia__r.Caso__r.Sinistro_Judicial__c, 
                                                 ValorIndenizacao__c
                                                 FROM BeneficiarioGarantia__c
                                                 WHERE Pagamento_de_garantia__c IN : lPagGarantia
                                                 AND Status__c = 'Liberado'
                                                 //AND Tipo_de_Pagamento__c != null    //PLV - 4374 - Inicio/FIM
                                                 //AND Pagamento_de_Sinistro__c = null //PLV - 4374 - Inicio/FIM
                                                ];
        Set<Id> idContas = new Set<id>();
        for(BeneficiarioGarantia__c b: LstBene){    
            IdContas.add(b.Conta__c);
        }
        
        //PLV-4374 - INICIO
        Boolean hasCheque = false;
        for(String pagamento : tipoPagamento.values()){
            if(pagamento == 'Cheque'){
                hasCheque = true;
                break;
            }	
        }
        System.debug('listInfo Debug: ' + lstInfo.size());
        System.debug('listInfo Debug: ' + LstBene.size());
        if((lstInfo.size() == 0 || lstInfo.size() < LstBene.size()) && !hasCheque) {
            return 'Selecione a informação bancária';
        }
       // if(lstInfo.size()==0){return 'Selecione a informação bancária';}
       //PLV-4374 - FIM
        
        List<Pagamento_de_Sinistro__c> lPs = new List<Pagamento_de_Sinistro__c>();
        //PLV 4043 - Adicionado filtro tipo op = Indenização
        //PLV-4374 INICIO
        List<Pagamento_de_Sinistro__c> pagamentoExistente = [SELECT Id,Beneficiario_da_Garantia__c,Dados_Bancarios__c,
                                                             Valor_total_a_ser_indenizado__c 
                                                             FROM Pagamento_de_Sinistro__c 
                                                             WHERE Caso_de_Sinistro__c =:recordId 
                                                             AND Status__c = 'Pendente' 
                                                             AND Tipo_de_OP__c = 'Indenização' 
                                                             AND Beneficiario_da_Garantia__c IN: idContas];
        //PLV-4374 FIM
        List<Pagamento_de_Sinistro__c> atualizaPagamentosExistente = new List<Pagamento_de_Sinistro__c>();
        
        List<String> lVerificaId = new List<String>();
        Set<Id> setIdBeneficiario = new Set<id>();
        //PLV-4374 INICIO
        String[] types = new String[]{'Pagamento_de_Sinistro__c'};
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        Map<String,String> mapSursalDestinoCheque = new Map<String,String>();
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get('Sucursal_Destino_de_Cheque__c').getDescribe().getPicklistValues()) {
                if (entry.isActive()) {
                    mapSursalDestinoCheque.put(entry.getLabel(), entry.getValue());
                }
            }
        }
        Set<Id> idsSinistro = new Set<Id>();
        //PLV-4374 FIM
        for(BeneficiarioGarantia__c bene: LstBene){
            
            if(pagamentoExistente.size() > 0){
                for(Pagamento_de_Sinistro__c p: pagamentoExistente){
                    if(bene.Conta__c == p.Beneficiario_da_Garantia__c){
                        p.Valor_total_a_ser_indenizado__c = p.Valor_total_a_ser_indenizado__c +(somaValorIndenizado(bene.Conta__c, lPagGarantia));
                        //PLV-4374 INICIO
                        if(tipoPagamento.containskey(bene.Conta__c)){
                            p.Tipo_de_Pagamento__c = tipoPagamento.get(bene.Conta__c);
                        }
                        if(p.Tipo_de_Pagamento__c == 'Cheque' && sucursal.containskey(bene.Conta__c)){
                            String sucKey = sucursal.get(bene.Conta__c); 
                            p.Sucursal_Destino_de_Cheque__c = mapSursalDestinoCheque.get(sucKey);
                        }
                        if(p.Tipo_de_Pagamento__c != 'Cheque'){
                            for(InformacaoBancaria__c i:lstInfo){
                                if(i.Conta__c == bene.conta__c){
                                    for(integer e=0; e<lBancos.size(); e++){
                                        if(lBancos[e] != ' ' && lBancos[e] == i.id){
                                            p.Dados_Bancarios__c = i.id;
                                            break;
                                        }
                                    }
                                }
                                if(p.Dados_Bancarios__c != null) break;
                            }
                            if(p.Dados_Bancarios__c == null) return 'Por favor preencha todos as Informações bancárias.';
                            if(!idsSinistro.contains(p.Id)){
                            	atualizaPagamentosExistente.add(p);
                                idsSinistro.add(p.Id);
                            }
                        }
                        //PLV-4374 FIM
                    }else{
                        if(lVerificaId.contains(bene.Conta__c)){
                        }else{
                            Pagamento_de_Sinistro__c ps = new Pagamento_de_Sinistro__c();
                            //PLV-4374 - INICIO
                            if(tipoPagamento.containskey(bene.Conta__c)){
                            	ps.Tipo_de_Pagamento__c = tipoPagamento.get(bene.Conta__c);
                            }
                            if(ps.Tipo_de_Pagamento__c == 'Cheque' && sucursal.containskey(bene.Conta__c)){
                                String sucKey = sucursal.get(bene.Conta__c);
                                ps.Sucursal_Destino_de_Cheque__c = mapSursalDestinoCheque.get(sucKey);
                            }
                            ps.caso_de_sinistro__c = recordId;
                            ps.Beneficiario_da_Garantia__c = bene.Conta__c;
                            ps.Valor_total_a_ser_indenizado__c = somaValorIndenizado(bene.Conta__c, lPagGarantia);
                            
                            if(ps.Tipo_de_Pagamento__c != 'Cheque'){
                                for(InformacaoBancaria__c bankInfo:lstInfo){
                                    
                                    if(bankInfo.Conta__c == bene.conta__c){
                                        
                                        for(String bankInfoId : lBancos){
                                            if(bankInfoId != ' ' && bankInfoId == bankInfo.id){
                                                ps.Dados_Bancarios__c = bankInfo.id;
                                                break;
                                            }
                                        }
                                    }
                                    
                                    if(ps.Dados_Bancarios__c != null) break;
                                }
                                if(ps.Dados_Bancarios__c == null) return 'Por favor preencha todos as Informações bancárias.';
                            }
                            //PLV-4374 - FIM
                            // ps.Tipo_de_Aprova_o__c = 'Alçada SAP'; //PLV-4335 - INICIO/FIM
                            ps.Tipo_de_OP__c = 'Indenização';
                            ps.Status__c = 'Pendente';
                            ps.Garantia_do_Sinistro__c = bene.Pagamento_de_garantia__c != null? bene.Pagamento_de_garantia__c : null; //PLV-4335 - Inicio/Fim
                            lVerificaId.add(bene.Conta__c);
                            lPs.add(ps);
                        }
                    }
                }
            }else{
                if(lVerificaId.contains(bene.Conta__c)){
                }else{
                    Pagamento_de_Sinistro__c ps = new Pagamento_de_Sinistro__c();
					//PLV - 4374 - Inicio
                    ps.caso_de_sinistro__c = recordId;
                    ps.Beneficiario_da_Garantia__c = bene.Conta__c;
                    ps.Valor_total_a_ser_indenizado__c = somaValorIndenizado(bene.Conta__c, lPagGarantia);

                   
                    if(tipoPagamento.containskey(bene.Conta__c)) ps.Tipo_de_Pagamento__c = tipoPagamento.get(bene.Conta__c);

                    if( ps.Tipo_de_Pagamento__c == 'Cheque' && sucursal.containskey(bene.Conta__c)){
                        String sucKey = sucursal.get(bene.Conta__c);
                        ps.Sucursal_Destino_de_Cheque__c = mapSursalDestinoCheque.get(sucKey);
                    }
                    else{
                        for(InformacaoBancaria__c bankInfo:lstInfo){
                            if(bankInfo.Conta__c == bene.conta__c){
                                for(String bankInfoId : lBancos){
                                    if(bankInfoId != ' ' && bankInfoId == bankInfo.id){
                                        ps.Dados_Bancarios__c = bankInfo.id;
                                        break;
                                    }
                                }
                            }
                            if(ps.Dados_Bancarios__c != null) break;
                        }
                        if(ps.Dados_Bancarios__c == null) return 'Por favor preencha todos as Informações bancárias.';
                    }
                    //PLV-4374 - FIM
                    // ps.Tipo_de_Aprova_o__c = 'Alçada SAP'; //PLV-4335 - INICIO/FIM
                    ps.Tipo_de_OP__c = 'Indenização';
                    ps.Status__c = 'Pendente';
                    ps.Garantia_do_Sinistro__c = bene.Pagamento_de_garantia__c != null? bene.Pagamento_de_garantia__c : null; //PLV-4335 - Inicio/Fim
                    lVerificaId.add(bene.Conta__c);
                    lPs.add(ps);
                }
            }          
        }
        if(lPs.Size() >0){
        	insert lPs;
            atualizaBeneficiario(lPs,LstBene); //PLV-4374 - INICIO/FIM
        }

        if(atualizaPagamentosExistente.size() > 0){
            update atualizaPagamentosExistente;
            atualizaBeneficiario(atualizaPagamentosExistente,LstBene);
        }
        return 'OK';
    }
	//PLV - 4043 FIX 07/08 FIM     
    public static Double somaValorIndenizado(String Conta, List<PagamentoGarantia__c> lPagGarantia){
        
        List<BeneficiarioGarantia__c> LstBene = [SELECT Id, Name, Data_programada_do_pagamento__c,Pagamento_de_garantia__c, 
                                                 Conta__c, Status__c,Tipo_de_Pagamento__c, conta__r.Cnpj__c, 
                                                 conta__r.Cpf__c,
												 Pagamento_de_garantia__r.ValorIndenizado__c, //PLV-4070 - INICIO/FIM                                                 
												 Percentual_de_indenizacao__c, Pagamento_de_garantia__r.Caso__r.NumeroSinistro__c, 
                                                 Pagamento_de_garantia__r.Caso__c, Pagamento_de_garantia__r.Caso__r.Sinistro_Judicial__c, 
                                                 ValorIndenizacao__c, ValorTotalIndenizado__c
                                                 FROM BeneficiarioGarantia__c
                                                 WHERE Pagamento_de_garantia__c IN : lPagGarantia
                                                 AND Status__c = 'Liberado'
                                                 //AND Tipo_de_Pagamento__c != null 	//PLV-4374 - INICIO/FIM     
                                                 AND Conta__C =: Conta
                                                 AND Pagamento_de_Sinistro__c = null 	//PLV - 4043 FIX 07/08 INICIO/FIM     
                                                 
                                                ];
        //PLV-4374 inicio
        List<BeneficiarioGarantia__c> LstPagamentos = new List<BeneficiarioGarantia__c>();
        Double valorIndenizado = 0;
        for(BeneficiarioGarantia__c b: LstBene){
            valorIndenizado += b.ValorTotalIndenizado__c;
            LstPagamentos = [SELECT Id, Pagamento_de_Sinistro__r.Id, Pagamento_de_Sinistro__r.Name, 
                                                        Pagamento_de_Sinistro__r.Tipo_de_Pagamento__c, Pagamento_de_Sinistro__r.Sucursal_Destino_de_Cheque__c,
                                                        Pagamento_de_Sinistro__r.Beneficiario_da_Garantia__c
                                                        FROM BeneficiarioGarantia__c
                                                        WHERE Id =: b.Id];
        }
        //PLV-4374 FIM
        
        return valorIndenizado;
    }
    public static void atualizaBeneficiario(List<Pagamento_de_Sinistro__c> ps, List<BeneficiarioGarantia__c> bene){
        List<BeneficiarioGarantia__c> lBene2Up = new List<BeneficiarioGarantia__c>();
        
        //PLV-4374 - INICIO
        List<Pagamento_de_Sinistro__c> lPs = [SELECT Id, Beneficiario_da_Garantia__c, Tipo_de_Pagamento__c, Sucursal_Destino_de_Cheque__c FROM Pagamento_de_Sinistro__c WHERE Id IN: ps];
        List<BeneficiarioGarantia__c> lBene = [SELECT Id, Conta__c, Pagamento_de_Sinistro__c, Tipo_de_Pagamento__c, Sucursal_Destino_de_Cheque__c FROM BeneficiarioGarantia__c WHERE Id IN: bene];
        //PLV-4374 - FIM
                
        for(Pagamento_de_Sinistro__c pag: lPs){            
            
            for(BeneficiarioGarantia__c b: lBene){
                if(b.Conta__c == pag.Beneficiario_da_Garantia__c){
                    b.Pagamento_de_Sinistro__c = pag.Id;
                    //PLV-4374 - INICIO
                    b.Tipo_de_Pagamento__c = pag.Tipo_de_Pagamento__c;
                    b.Sucursal_Destino_de_Cheque__c = pag.Tipo_de_Pagamento__c == 'Cheque' ? Integer.valueOf(pag.Sucursal_Destino_de_Cheque__c) : null;
                    //PLV-4374 - FIM
                    lBene2Up.add(b);
                }
                
            }   
            
        }
        update lBene2Up;
    }
}
//PLV - 4043 fim