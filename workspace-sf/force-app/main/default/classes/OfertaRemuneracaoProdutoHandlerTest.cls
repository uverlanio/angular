@isTest
public class OfertaRemuneracaoProdutoHandlerTest {

    @isTest
    static void impedeDelRemuneracaoObrigatoriaTest(){

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

        TipoRemuneracao__c TipoRemuneracao = (TipoRemuneracao__c) new TipoRemuneracaoFactory().createRecord(); 

        remuneracaoProduto__c remuneracaoProduto = (remuneracaoProduto__c) new RemuneracaoProdutoFactory(TipoRemuneracao, produtoComercial).createRecord();

        RamoSeguro__c ramoSegurado = (RamoSeguro__c) new RamoSeguroFactory().createRecord();

        Garantia__c garantia = (garantia__c) new GarantiaFactory().createRecord();

        RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSegurado).createRecord(); 

        GarantiaProduto__c garantiaProdutoTEC = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSegurado).createRecord();

        GarantiaProduto__c garantiaProduto = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garantiaProdutoTEC, ramoSegurado).createRecord();


        Oferta__c Oferta = new Oferta__c(
            name = 'OfertaDaClasseTeste',
            produto__c = produtoComercial.id,
			VigenciaInicio__c = System.today(), //PLV-3690 - MVP B - Configurador de oferta - Criação de vigência da oferta e processo de ativação
            Ativo__c = false
        );
        insert Oferta;
		
		OfertaRemuneracaoProduto__c orp = new OfertaRemuneracaoProduto__c(
        	RemuneracaoProduto__c = remuneracaoProduto.Id,
            Oferta__c = Oferta.Id
        );
        insert orp;
            
        Test.startTest();
            try{
                delete orp;
            }catch(exception e){}
        Test.StopTest();
    }

}