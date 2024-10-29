@isTest
public class SeguradoContratoTest {

    @isTest
    public static void testeSeguradoContratoPessoaFisica(){
        
        SeguradoContrato__c vSegContratoTest = (SeguradoContrato__c)new SeguradoContratoFactory().createRecord();
        
        system.assert([SELECT Nomenclatura_Pesquisa_Segurado_Contrato__c 
                       FROM SeguradoContrato__c 
                       WHERE Id = :vSegContratoTest.Id].Nomenclatura_Pesquisa_Segurado_Contrato__c != null);
    }
    
    @isTest
    public static void testeSeguradoContratoPessoaJuridica(){
        
        Account vAccPeJuri = (Account)new AccountFactory.PessoaJuridica().createRecord();
        GrupoContrato__c vGru = (GrupoContrato__c)new GrupoFactory().createRecord();
        
        SeguradoContrato__c vSegContratoTest1 = (SeguradoContrato__c)new SeguradoContratoFactory(vAccPeJuri, vGru).createRecord();

        system.assert([SELECT Nomenclatura_Pesquisa_Segurado_Contrato__c 
                               FROM SeguradoContrato__c 
                               WHERE Id = :vSegContratoTest1.Id].Nomenclatura_Pesquisa_Segurado_Contrato__c != null);
    }
}