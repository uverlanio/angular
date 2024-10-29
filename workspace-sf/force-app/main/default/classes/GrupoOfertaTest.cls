/****
@description Classe de teste da Trigger GrupoOfertaTrigger
@author Isabela Fin - Globant
@date 28/07/2020
-Classe criada por conta da historia PLV-4100    
*****/
@isTest
public class GrupoOfertaTest {
    @testSetup
    static void setup(){
        ContadorCodigo__c contadorCodigoTEC = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
		ContadorCodigo__c contadorCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
    	Product2 produtoTecnico = (Product2) new produtoFactory.ProdutoTecnico().createRecord();
		produtoTecnico.Status__c = 'Em ativação';
		produtoTecnico.NumeroSusep__c = '123';
		produtoTecnico.VersaoRenovacao__c = 'Versão atual';
		update produtoTecnico;
		produtoTecnico.Status__c = 'Ativo';
		update produtoTecnico;
		Product2 produtoComercial = (Product2) new produtoFactory.produtoComercial(produtoTecnico).createRecord();
		produtoComercial.Status__c = 'Ativo';
		update produtoComercial;
        
		insert new Oferta__c(Produto__c = produtoComercial.Id, Name = 'TesteOferta', VigenciaInicio__c = System.today());
    }
    @isTest
    static void testInsertDataSucess(){
        Boolean resultInsert;
        Oferta__c oferta = [SELECT Id FROM Oferta__c LIMIT 1];
        Test.startTest();
        System.assertEquals(true, insereGrupos(false, oferta.Id));
        System.assertEquals(false, insereGrupos(false, oferta.Id));
        removeGruposOfertaFromOferta(oferta.Id);
        System.assertEquals(false,insereGrupos(true, oferta.Id));
        System.assertEquals(false,insereGrupos(true, oferta.Id));
        Test.stopTest();
    }
    
    private static Boolean insereGrupos(boolean repeatNumber, Id idOferta){
        List<GrupoOferta__c> gruposOferta = new List<GrupoOferta__c>();
        Decimal numero;
        for(Decimal i=1; i<=5; i++){
            if(repeatNumber && i==3) numero = 1;
            else numero = i;
			gruposOferta.add(new GrupoOferta__c(Oferta__c = idOferta, Numero__c = numero, Name = 'Grupo '+String.valueOf(i)));                
        }
		List<Database.SaveResult> srList = database.insert(gruposOferta, false);
        for(Database.SaveResult sr :srList){
            if(!sr.isSuccess())
                return false;
        }
        return true;
    }
    
    private static void removeGruposOfertaFromOferta(Id idOferta) {
        List<GrupoOferta__c> gruposOferta = [SELECT Id FROM GrupoOferta__c WHERE Oferta__c = :idOferta];
        if(!gruposOferta.isEmpty()) delete gruposOferta;
    }
}