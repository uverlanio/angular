// PLV-4163 - criação classe
public with sharing class BtnPagAdcGarController {

    public class innerPicklist{
        @AuraEnabled public String value {get;set;}
        @AuraEnabled public String label {get;set;}
    }
    
    @AuraEnabled
    public static Map<String,Object> buscarInformacoes(String recordId){
        Map<String,Object> mapToReturn = new Map<String,Object>();
        
        PagamentoGarantia__c garantia = [SELECT Id, Caso__r.Status, JustPagAdc__c, Status_do_pagamento__c FROM PagamentoGarantia__c WHERE Id=:recordId];

        String visible = 'visivel';
        if( garantia.Status_do_pagamento__c == 'Em análise' || garantia.Status_do_pagamento__c == 'Com Pendências' || garantia.Status_do_pagamento__c == 'Aguardando Pagamento' ) visible = 'statusPagamento';
        if(garantia.Caso__r.Status !='Em Regulação' && garantia.Caso__r.Status !='Liquidação') visible = 'casoFase'; // PLV-4163 FIX 3
        if(garantia.Caso__r.Status =='Fechado') visible = 'casoFechado';
        if(!FeatureManagement.checkPermission('canOpenComponent')) visible = 'permissaoPerfil';
        mapToReturn.put('visible', visible );

        if( visible != 'visivel' ) return mapToReturn;            
        
        List<innerPicklist> justPagToReturn = new List<innerPicklist>();
  
        Map<String,String> justPag = new Map<String,String>();
		Schema.DescribeFieldResult fieldResult = PagamentoGarantia__c.JustPagAdc__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
            justPag.put(pickListVal.getValue(), pickListVal.getLabel());
		}

        for(String key : justPag.keyset()){
            innerPicklist entry = new innerPicklist();
            entry.value = key;
            entry.label = justPag.get(key);
            justPagToReturn.add(entry);
        }

        mapToReturn.put('justificativasPagamento',justPagToReturn);

        return mapToReturn;
    }

    // PLV-4163 FIX2 INICIO
    @AuraEnabled
    public static Map<String,Object> criarGarantia(String recordId, String justPag, Decimal valor){
        Map<String,Object> mapToReturn = new Map<String,Object>();
        
        PagamentoGarantia__c garantiaSin =[ SELECT  Id, Name, Garantia_do_segurado_do_contrato__c, Caso__c, Data_da_cotacao_da_moeda_estrangeira__c,
                                                    CurrencyIsoCode, Valor_da_cotacao_em_reais__c, Garantia_do_segurado_do_contrato__r.Capital__c
                                            FROM    PagamentoGarantia__c 
                                            WHERE   Id = :recordId];  

        // PLV-4163 FIX 3 - INICIO
        List<BeneficiarioGarantia__c> benGarList = new List<BeneficiarioGarantia__c> ([
            SELECT  Id, Pagamento_de_garantia__c, Conta__c, Endereco__c, IdExterno__c, CurrencyIsoCode, Name,
                    RelacionamentoSegurado__c, Sucursal_Destino_de_Cheque__c, Tipo_de_Pagamento__c
            FROM    BeneficiarioGarantia__c
            WHERE Pagamento_de_garantia__c = :recordId
        ]);

        PagamentoGarantia__c novaGarantia = new PagamentoGarantia__c();
        novaGarantia = garantiaSin;
        novaGarantia.id = null;
        novaGarantia.Fase__c = 'Em Análise';
        novaGarantia.Status_do_pagamento__c = 'Em análise';
        novaGarantia.JustPagAdc__c = justPag;
        novaGarantia.Capital__c = garantiaSin.Garantia_do_segurado_do_contrato__r.Capital__c;
        novaGarantia.Valor_indenizado__c = valor;        
        novaGarantia.IsPagAdc__c = true;

        
        Savepoint sp = Database.setSavepoint();
        try {

            Case caso = new Case();
            caso.Id = novaGarantia.Caso__c;
            caso.Status_Dependente__c = 'Aguardando Pagamento';
            update caso;

            insert novaGarantia;
        // PLV-4163 FIX 3 - FIM

            List<BeneficiarioGarantia__c> benGarToIns = new List<BeneficiarioGarantia__c>();

        if( !benGarList.isEmpty() ){
            for( BeneficiarioGarantia__c bg : benGarList){
                BeneficiarioGarantia__c bene = bg;
                bene.Id = null;
                bene.Pagamento_de_garantia__c = novaGarantia.Id;
                benGarToIns.add(bene);
            }
        }

            insert benGarToIns;
            mapToReturn.put('sucesso', true);
                    
        } catch (Exception e) {
    	    Database.rollback(sp);
            System.debug('Erro ao criar novo pagamento'+ e.getLineNumber() + ' - '+e.getMessage());           
            mapToReturn.put('sucesso', false);         
            mapToReturn.put('mensagem', 'Erro ao criar novo pagamento: '+ e.getMessage());         
        }

        // PLV-4163 FIX2 FIM

        return mapToReturn;
    }
}