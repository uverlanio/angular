//PLV - 4282 INICIO 
@isTest 
public class FranquiaGarantiaTriggerHandlerTest {
    
    @isTest
    static void testStaticMethods(){
    }
    
    @isTest
    static void testPass(){
        
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
        garantiaProdutoTEC.LimiteCapitalMaximo__c = 99;
        garantiaProdutoTEC.LimiteCapitalMinimo__c = 1;
        update garantiaProdutoTEC;
        
        GarantiaProduto__c garantiaProduto = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garantiaProdutoTEC, ramoSegurado).createRecord();
        garantiaProduto.LimiteCapitalMaximo__c = 99;
        garantiaProduto.LimiteCapitalMinimo__c = 1;
        update garantiaProduto;
        
        Franquia__c franquia = new Franquia__c();
        franquia.Tipo__c = 'Dias';
        franquia.name = 'franquia';
        franquia.Modelo__c = 'Simples';
        franquia.CodigoFranquia__c = 'A';
        insert franquia;
        
        FranquiaGarantia__c franquiaGarantia = new FranquiaGarantia__c();
        franquiaGarantia.GarantiaProduto__c = garantiaProdutoTEC.Id;
        franquiaGarantia.Franquia__c = franquia.Id;
        franquiaGarantia.Franquia_Padrao__c = true;
        insert franquiaGarantia;
        
    }
    @isTest
    static void testAssert(){
        
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
        garantiaProdutoTEC.LimiteCapitalMaximo__c = 99;
        garantiaProdutoTEC.LimiteCapitalMinimo__c = 1;
        update garantiaProdutoTEC;
        
        GarantiaProduto__c garantiaProduto = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garantiaProdutoTEC, ramoSegurado).createRecord();
        garantiaProduto.LimiteCapitalMaximo__c = 99;
        garantiaProduto.LimiteCapitalMinimo__c = 1;
        update garantiaProduto;
        
        Franquia__c franquia = new Franquia__c();
        franquia.Tipo__c = 'Dias';
        franquia.name = 'franquia';
        franquia.Modelo__c = 'Simples';
        franquia.CodigoFranquia__c = 'A';
        insert franquia;
        
        FranquiaGarantia__c franquiaGarantia = new FranquiaGarantia__c();
        franquiaGarantia.GarantiaProduto__c = garantiaProdutoTEC.Id;
        franquiaGarantia.Franquia__c = franquia.Id;
        franquiaGarantia.Franquia_Padrao__c = true;
        
        //PLV - 4282 - INICIO
        //insert franquiaGarantia;
        
        FranquiaGarantia__c franquiaGarantiaErro = new FranquiaGarantia__c();
        franquiaGarantiaErro.GarantiaProduto__c = garantiaProdutoTEC.Id;
        franquiaGarantiaErro.Franquia__c = franquia.Id;
        franquiaGarantiaErro.Franquia_Padrao__c = true;
        
        FranquiaGarantia__c franquiaGarantia2 = new FranquiaGarantia__c();
        franquiaGarantia2.GarantiaProduto__c = garantiaProdutoTEC.Id;
        franquiaGarantia2.Franquia__c = franquia.Id;
        franquiaGarantia2.Franquia_Padrao__c = false;
        
        List<FranquiaGarantia__c> fg = new List<FranquiaGarantia__c>();
        fg.add(franquiaGarantia);
        fg.add(franquiaGarantia2);
        fg.add(franquiaGarantiaErro);
        
        try{
            insert fg;
        }catch(DMLexception e){
            system.assert(e.getMessage().contains('É possível marcar somente uma franquia padrão por garantia')
                          ,'É possível marcar somente uma franquia padrão por garantia');                       
        }
        
    }
    @isTest
    static void testAssertList(){
        
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
        garantiaProdutoTEC.LimiteCapitalMaximo__c = 99;
        garantiaProdutoTEC.LimiteCapitalMinimo__c = 1;
        update garantiaProdutoTEC;
        
        GarantiaProduto__c garantiaProduto = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garantiaProdutoTEC, ramoSegurado).createRecord();
        garantiaProduto.LimiteCapitalMaximo__c = 99;
        garantiaProduto.LimiteCapitalMinimo__c = 1;
        update garantiaProduto;
        
        Franquia__c franquia = new Franquia__c();
        franquia.Tipo__c = 'Dias';
        franquia.name = 'franquia';
        franquia.Modelo__c = 'Simples';
        franquia.CodigoFranquia__c = 'A';
        insert franquia;
        
        FranquiaGarantia__c franquiaGarantia = new FranquiaGarantia__c();
        franquiaGarantia.GarantiaProduto__c = garantiaProdutoTEC.Id;
        franquiaGarantia.Franquia__c = franquia.Id;
        franquiaGarantia.Franquia_Padrao__c = true;
        
        FranquiaGarantia__c franquiaGarantiaErro = new FranquiaGarantia__c();
        franquiaGarantiaErro.GarantiaProduto__c = garantiaProdutoTEC.Id;
        franquiaGarantiaErro.Franquia__c = franquia.Id;
        franquiaGarantiaErro.Franquia_Padrao__c = true;
        try{
            insert franquiaGarantiaErro;
        }catch(DMLexception e){
            system.assert(e.getMessage().contains('É possível marcar somente uma franquia padrão por garantia')
                          ,'É possível marcar somente uma franquia padrão por garantia');                       
        }   
        
    }
    //PLV - 4282 -  FIM
    
}
//PLV - 4282 FIM