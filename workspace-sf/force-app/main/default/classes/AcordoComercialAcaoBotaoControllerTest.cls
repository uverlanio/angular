@isTest
private class AcordoComercialAcaoBotaoControllerTest {

    @isTest
    public static void testGerarProdutosAcordoComercial() {

        AcordoComercial__c acordoComercial = new AcordoComercial__c();
        insert acordoComercial;
        
        String result = AcordoComercialAcaoBotaoController.gerarProdutosAcordoComercial(acordoComercial.Id);
        
        RetornoAcaoBotaoTO retorno = (RetornoAcaoBotaoTO) JSON.deserialize(result, RetornoAcaoBotaoTO.class);

    }
}