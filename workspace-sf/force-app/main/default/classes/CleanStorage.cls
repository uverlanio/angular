public class CleanStorage {
    
    public static void cleanContentDocument(){
        List<sObject> toDelStorage = [SELECT Id from ContentDocument where title like '%storage%'];
        System.debug('Apagando arquivos: '+toDelStorage.size());
        delete toDelStorage;
        
        List<sObject> toDelVoucher = [SELECT Id from ContentDocument where title like '%voucher%'];
        System.debug('Apagando arquivos: '+toDelVoucher.size());
        delete toDelVoucher;
    }
    
    public static void cleanObjects(){
        List<String> objetosToDel = new List<String>();
        objetosToDel.add('Contract');
        objetosToDel.add('Quote');
        objetosToDel.add('Opportunity');
        objetosToDel.add('BeneficiarioSeguradoProposta__c');
        objetosToDel.add('BeneficiarioSeguradoContrato__c');
        objetosToDel.add('GarantiaSeguradoProposta__c');
        objetosToDel.add('GarantiaSeguradoContrato__c');
        objetosToDel.add('GarantiaSeguradoOrcamento__c');
        objetosToDel.add('SeguradoProposta__c');
        objetosToDel.add('SeguradoContrato__c');
        objetosToDel.add('SeguradoOrcamento__c');
        objetosToDel.add('ContratanteProposta__c');
        objetosToDel.add('ContratanteContrato__c');
        objetosToDel.add('ContratanteOrcamento__c');
        objetosToDel.add('FavorecidoRemuneracaoContrato__c');
        objetosToDel.add('GarantiaContratanteProposta__c');
        objetosToDel.add('GarantiaContratanteContrato__c');
        objetosToDel.add('GarantiaContratanteOrcamento__c');
        objetosToDel.add('GarantiaContrato__c');
        objetosToDel.add('GarantiaGrupoContrato__c');
        objetosToDel.add('GarantiaSeguradoContrato__c');
        objetosToDel.add('GrupoContrato__c');
        objetosToDel.add('GrupoProposta__c');
        objetosToDel.add('GrupoOrcamento__c');
        objetosToDel.add('RemuneracaoContrato__c');
        objetosToDel.add('GarantiaGrupoOrcamento__c');
        objetosToDel.add('GarantiaGrupoContrato__c');
        objetosToDel.add('GarantiasGrupoProposta__c');
        
        //CONFIGURAR PERIODO
        Date  datafim = System.today().addDays(-4);
        Date  datainit = datafim.addMonths(-10);
        Integer total = 0;
        
        for(String obj : objetosToDel){
            if(obj=='' || total>10000)continue;
            List<sObject> lista = Database.query('SELECT Id FROM '+obj+' WHERE lastmodifieddate > :datainit AND lastmodifieddate < :datafim LIMIT 10000');
            if(lista==null || !lista.isEmpty()){
                System.debug('Objeto: '+ obj +' - Apagando Registros : '+ lista.size());
                total =total+ lista.size();
                if(total<10000)
                    Database.delete(lista,false);
            }else{
                System.debug('Objeto: '+ obj +' VAZIO');
            }
        }
        
        System.debug('Total Apagado: '+ total);
    }
    
    public static void cleanFiles(){
        Date  datafim = System.today().addDays(3);
        Date  datainit = datafim.addMonths(-12);
        
        List<sObject> toDel = [SELECT Id from ContentDocument where title like '%servico%' AND lastmodifieddate > :datainit AND lastmodifieddate < :datafim];
        System.debug('Apagando arquivos: '+toDel.size());
        delete toDel;
        
        toDel = [SELECT Id from ContentDocument where title like '%Servico%' AND lastmodifieddate > :datainit AND lastmodifieddate < :datafim];
        System.debug('Apagando arquivos: '+toDel.size());
        delete toDel;
        
        toDel = [SELECT Id from ContentDocument where title like '%Endosso%' AND lastmodifieddate > :datainit AND lastmodifieddate < :datafim];
        System.debug('Apagando arquivos: '+toDel.size());
        delete toDel;
        
        toDel = [SELECT Id from ContentDocument where title like '%endosso%' AND lastmodifieddate > :datainit AND lastmodifieddate < :datafim];
        System.debug('Apagando arquivos: '+toDel.size());
        delete toDel;
        
        toDel = [SELECT Id from ContentDocument where title like '%voucher%' AND lastmodifieddate > :datainit AND lastmodifieddate < :datafim];
        System.debug('Apagando arquivos: '+toDel.size());
        delete toDel;
        
        toDel = [SELECT Id from ContentDocument where title like '%storage%' AND lastmodifieddate > :datainit AND lastmodifieddate < :datafim];
        System.debug('Apagando arquivos: '+toDel.size());
        delete toDel;
        
        toDel = [SELECT Id from ContentDocument where title like '%Apolice%' AND lastmodifieddate > :datainit AND lastmodifieddate < :datafim];
        System.debug('Apagando arquivos: '+toDel.size());
        delete toDel;
        
        toDel = [SELECT Id from ContentDocument where title like '%Pedro%' AND lastmodifieddate > :datainit AND lastmodifieddate < :datafim];
        System.debug('Apagando arquivos: '+toDel.size());
        delete toDel;
        
        toDel = [SELECT Id from ContentDocument where title like '%Proposta%' AND lastmodifieddate > :datainit AND lastmodifieddate < :datafim];
        System.debug('Apagando arquivos: '+toDel.size());
        delete toDel;
        
        toDel = [SELECT Id from ContentDocument where title like '%CO2%' AND lastmodifieddate > :datainit AND lastmodifieddate < :datafim];
        System.debug('Apagando arquivos: '+toDel.size());
        delete toDel;
        
        toDel = [SELECT Id from ContentDocument where title like '%BAK%' AND lastmodifieddate > :datainit AND lastmodifieddate < :datafim];
        System.debug('Apagando arquivos: '+toDel.size());
        delete toDel;
        
        toDel = [SELECT Id from ContentDocument where title like '%CO2-%' AND lastmodifieddate > :datainit AND lastmodifieddate < :datafim];
        System.debug('Apagando arquivos: '+toDel.size());
        delete toDel;
        
        toDel = [SELECT Id from ContentDocument where title like '%BAK-%' AND lastmodifieddate > :datainit AND lastmodifieddate < :datafim];
        System.debug('Apagando arquivos: '+toDel.size());
        delete toDel;
    }
}