/**
 * Created by Alessndro Ponte on 05/07/2018.
 */

@IsTest
private class SeletorGarantiasProdutoTest {
  @TestSetup
  static void setup(){
    TestDataFactory.gerarDadosSetup();
    TestDataFactory.gerarProdutoComercialAtivo(false);
  }

  @IsTest
  static void testBehavior() {
    List<Product2> lstProdutoComercial = [SELECT Id FROM Product2 WHERE RecordType.DeveloperName = 'ProdutoComercial'];
    List<Product2> lstProdutoTecnico = [SELECT Id FROM Product2 WHERE RecordType.DeveloperName = 'ProdutoTecnico'];

    List<Id> idsGarantiasSelecionadas  = new List<Id>();

    for(GarantiaProduto__c garantiaProduto : [SELECT Id FROM GarantiaProduto__c]){
      idsGarantiasSelecionadas.add(garantiaProduto.Id);
    }

    Test.startTest();

    List<SeletorGarantiasProdutoController.GarantiaProdutoWrapper> listRetornoGarantiaProdutoTecnico = SeletorGarantiasProdutoController.buscarGarantiasProdutoTecnico(lstProdutoTecnico[0].Id);
    List<SeletorGarantiasProdutoController.GarantiaProdutoWrapper> listRetornoGarantiaProdutoComercial = SeletorGarantiasProdutoController.buscarGarantiasProdutoComercial(lstProdutoComercial[0].Id);
    String retornoRemover = SeletorGarantiasProdutoController.removerGarantiasSelecionadas(idsGarantiasSelecionadas,lstProdutoComercial[0].Id,lstProdutoTecnico[0].Id);
    String retornoSalvar = SeletorGarantiasProdutoController.salvarGarantiasSelecionadas(idsGarantiasSelecionadas[0],lstProdutoComercial[0].Id,lstProdutoTecnico[0].Id, 'Real Brasileiro', 'Garantia gratuita');  // PLV - 3450
    List<String> lstMoeda = SeletorGarantiasProdutoController.getPickListLabelIntoList();

    Test.stopTest();

    System.assert(listRetornoGarantiaProdutoTecnico.size() > 0);
    System.assert(listRetornoGarantiaProdutoComercial.size() > 0);
    // System.assert(retornoSalvar == 'SUCCESS');  // PLV - 3046
     System.assert(retornoRemover == 'SUCCESS');
    System.assert(lstMoeda.size()  > 0);
  }
}