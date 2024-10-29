/**
 * Created by Mariana Ribeiro 02/01/2020.
 */

@IsTest
public class CriarGarantiaRelacionadaControllerTest {
	@TestSetup
    static void setup(){
        TestDataFactory.gerarDadosSetup();
      }
    
    @IsTest
  	static void testBehavior() {
        String erro;

        Product2 produtoTecnico = (Product2) new produtoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        Product2 produtoComercial = (Product2) new produtoFactory.produtoComercial(produtoTecnico).createRecord();
        produtoComercial.Status__c = 'Ativo';
        update produtoComercial;
        
     

		TipoRemuneracao__c TipoRemuneracao = (TipoRemuneracao__c) new TipoRemuneracaoFactory().createRecord(); 
        remuneracaoProduto__c remuneracaoProduto = (remuneracaoProduto__c) new RemuneracaoProdutoFactory(TipoRemuneracao, produtoComercial).createRecord();
        RamoSeguro__c ramoSegurado = (RamoSeguro__c) new RamoSeguroFactory().createRecord();
        Garantia__c garantia = (garantia__c) new GarantiaFactory().createRecord();
        RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSegurado).createRecord(); 
        GarantiaProduto__c garantiaProdutoTEC = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSegurado).createRecord();       
        GarantiaProduto__c garantiaProduto = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garantiaProdutoTEC, ramoSegurado).createRecord();
        
        garantia.Name = 'Morte Acidental';
        update garantia;
        
         //PLV-3667 - INICIO
 		 GarantiaRelacionada__c lGarantia = new GarantiaRelacionada__c();
         lGarantia.RecordTypeId = '012f4000000b5iAAAQ';
         //lGarantia.GarantiaProduto__c = produtoComercial.Id;
         lGarantia.GarantiaProduto__c = garantiaProdutoTEC.Id;        
         lGarantia.Acumulativa__c = true;        
         insert lGarantia;
         lGarantia.Acumulativa__c = false;
         update lGarantia;
         //PLV-3667 - FIM
        


        Test.startTest();

        List<CriarGarantiaRelacionadaController.GarantiaWrapper> lstGarantia =  CriarGarantiaRelacionadaController.pesquisaGarantiaProduto(garantiaProdutoTEC.id, 'Morte');
        String garantiaName =  CriarGarantiaRelacionadaController.buscaNomeGarantiaProduto(garantiaProdutoTEC.id);
        String success =  CriarGarantiaRelacionadaController.salvarGarantias((String)garantiaProdutoTEC.id, 'ProdutoTecnico', (String)garantiaProduto.id, 'Includente', false, false);
		List<String> lstPickList = CriarGarantiaRelacionadaController.getPickListLabelIntoList();
    
        Test.stopTest();
    
        System.assert(lstGarantia.size() > 0);
        System.assert(success == 'Sucesso');
        System.assert(lstPickList.size() > 0);
        
  	}
}