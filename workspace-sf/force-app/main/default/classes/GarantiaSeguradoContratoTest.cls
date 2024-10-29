@isTest
public class GarantiaSeguradoContratoTest {
	    
    @isTest
    public static void testeGarantiaSeguradoContratoPessoaFisica(){
        GarantiaSeguradoContrato__c vGSCTest = (GarantiaSeguradoContrato__c)new GarantiaSeguradoContratoFactory().createRecord();
        
        system.assert([SELECT Nomenclatura_Pesquisa_Garantia_Segurado__c 
                       FROM GarantiaSeguradoContrato__c 
                       WHERE Id = :vGSCTest.Id].Nomenclatura_Pesquisa_Garantia_Segurado__c != null);
    }

    @isTest
    public static void testeGarantiaSeguradoContratoPessoaJuridica(){

    	Account vAccPeJuri = (Account)new AccountFactory.PessoaJuridica().createRecord();
        GrupoContrato__c vGru = (GrupoContrato__c)new GrupoFactory().createRecord();
        
        SeguradoContrato__c vSegContratoTest1 = (SeguradoContrato__c)new SeguradoContratoFactory(vAccPeJuri, vGru).createRecord();

        Garantia__c vGarantia = (Garantia__c)new GarantiaFactory().createRecord();

        GarantiaSeguradoContrato__c vGSCTest1 = (GarantiaSeguradoContrato__c)new GarantiaSeguradoContratoFactory(vSegContratoTest1,vGarantia).createRecord();

        system.assert([SELECT Nomenclatura_Pesquisa_Garantia_Segurado__c 
                       FROM GarantiaSeguradoContrato__c 
                       WHERE Id = :vGSCTest1.Id].Nomenclatura_Pesquisa_Garantia_Segurado__c != null);
    }

    //PLV-5147 - FIX02 - INICIO
    @isTest
    public static void testeBuscaGarantiaSeguradoContrato(){

        ////Data Setup
        GarantiaSeguradoContrato__c vGSCTest = (GarantiaSeguradoContrato__c)new GarantiaSeguradoContratoFactory().createRecord();

        List<GarantiaSeguradoContrato__c> obj = [
            			SELECT id, SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c
                       	FROM GarantiaSeguradoContrato__c WHERE Id = :vGSCTest.Id];
        Set<Id> ctrs = new Set<Id>{obj[0].SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c};
        ////

        Test.startTest();
        List<GarantiaSeguradoContrato__c> lstRet = GarantiaSeguradoContratoDAO.getInstance().buscarGarantiaSeguradoContrado(ctrs);
		Test.stopTest();
        
        //Validação
        System.Assert(lstRet.size() > 0);
    }
    
    @isTest
    public static void testeBuscaGarantiaSeguradoContratoeEndosso(){

        //// Data Setup
        GarantiaSeguradoContrato__c vGSCTest = (GarantiaSeguradoContrato__c)new GarantiaSeguradoContratoFactory().createRecord();

        List<GarantiaSeguradoContrato__c> obj = [
            SELECT id, SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c
               FROM GarantiaSeguradoContrato__c WHERE Id = :vGSCTest.Id];
        Contract ct = new Contract();
        ct.Id = obj[0].SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c;
        ct.Name = ContratoFactory.EMPRESA + '-' + ContratoFactory.SUCURSAL + '-' + ContratoFactory.CODIGORAMO + '-' + ContratoFactory.NUMEROAPOLICE + '-0';
        update ct;
        ////
               
        Test.startTest();
        List<GarantiaSeguradoContrato__c> lstRet = GarantiaSeguradoContratoDAO.getInstance()
            .buscarGarantiaSeguradoContradoeEndosso(ContratoFactory.EMPRESA,
                                                   ContratoFactory.SUCURSAL,
                                                   ContratoFactory.CODIGORAMO,
                                                   ContratoFactory.NUMEROAPOLICE);
        Test.stopTest();
        
        //Validação
        System.Assert(lstRet.size() > 0);
        
        
    }
    //PLV-5147 - FIX02 - FIM
}