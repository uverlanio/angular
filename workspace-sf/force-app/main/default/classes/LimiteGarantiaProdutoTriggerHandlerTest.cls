/**
 * @author AVX - Leonardo Camacho
 * @date 2019-12-27
 * @description: Classe de teste da classe LimiteGarantiaProdutoTriggerHandler
 * Criada para a história PLV_3046
 */
@IsTest
public class LimiteGarantiaProdutoTriggerHandlerTest {

    @IsTest
    public static void validaLimiteCapitalTest(){

        String erro = '';

        ContadorCodigo__c contadorCodigoTEC = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contadorCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Product2 produtoTecnico = (Product2) new produtoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;

        RamoSeguro__c ramoSegurado = (RamoSeguro__c) new RamoSeguroFactory().createRecord();
        Garantia__c garantia = (garantia__c) new GarantiaFactory().createRecord();
        RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSegurado).createRecord(); 
        GarantiaProduto__c garantiaProdutoTEC = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSegurado).createRecord(); 
        
        Test.startTest();
        try{
        limiteGarantiaProduto__c limiteGPEuro = new limiteGarantiaProduto__c(
            garantiaProduto__c = garantiaProdutoTEC.id,
            CurrencyIsoCode = 'EUR',
            LimiteCapitalMinimo__c = 50,
            LimiteCapitalMaximo__c = 99999999
            );

        insert limiteGPEuro;

        limiteGPEuro.LimiteCapitalMinimo__c = 100;

        update limiteGPEuro;

        limiteGarantiaProduto__c limiteGPDolar = new limiteGarantiaProduto__c(
            garantiaProduto__c = garantiaProdutoTEC.id,
            CurrencyIsoCode = 'USD',
            LimiteCapitalMinimo__c = 50,
            LimiteCapitalMaximo__c = 99999999
            );

        insert limiteGPDolar;

        }catch(DmlException e){
            erro = e.getDmlStatusCode(0);
        }

        System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', erro);        
        Test.stopTest();
    }
}