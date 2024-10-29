/**
 * @author Sys4B - Denisson Santos
 * @date 2020-06-04
 * @description: Classe de teste de BotaoAprovarOfertaController
 * Criada para a história: PLV-3738 - MVP B - Criação de checklist para ativar configurador de oferta.
 */
// PLV-4366 - INÍCIO
@isTest
private class BotaoAprovarOfertaControllerTest {

	@testSetup
	public static void setupMethod() {
        Id userId = UserInfo.getUserId();
		User uManager = [ SELECT Id FROM User WHERE Id !=: userId LIMIT 1 ];
		User uCurrent = new User( Id = userId, ManagerId = uManager.Id );
		update uCurrent;
	}

	@isTest
	static void sucesso() { teste( 0 ); }
  
	@isTest
	static void error1() { teste( 1 ); }
    
	@isTest
	static void error2() { teste( 2 ); }
    
	@isTest
	static void error3() { teste( 3 ); }
    
	@isTest
	static void error4() { teste( 4 ); }
    
	@isTest
	static void error5() { teste( 5 ); }
    
	@isTest
	static void error6() { teste( 6 ); }
    
	@isTest
	static void error7() { teste( 7 ); }

	private static void teste( Integer cenario ) {
		ContadorCodigo__c contadorCodigoTEC = ( ContadorCodigo__c ) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
		ContadorCodigo__c contadorCodigoCom = ( ContadorCodigo__c ) new ContadorCodigoFactory.ProdutoComercial().createRecord();

		Product2 produtoTecnico = ( Product2 ) new produtoFactory.ProdutoTecnico().createRecord();
		produtoTecnico.Status__c = 'Em ativação';
		produtoTecnico.NumeroSusep__c = '123';
		produtoTecnico.VersaoRenovacao__c = 'Versão atual';
		update produtoTecnico;
		produtoTecnico.Status__c = 'Ativo';
		update produtoTecnico;
        
		Product2 produtoComercial = ( Product2 ) new produtoFactory.produtoComercial( produtoTecnico ).createRecord();
		produtoComercial.Status__c = 'Ativo';
		update produtoComercial;
        
        TipoRemuneracao__c tipoRemuneracao = null;
        RemuneracaoProduto__c remuneracaoProduto = null;
        RamoSeguro__c ramoSegurado = null;
        Garantia__c garantia = null;
        RamoGarantia__c ramoGarantia = null;
        GarantiaProduto__c garantiaProdutoTEC = null;
        GarantiaProduto__c garantiaProduto = null;
        
        if ( cenario != 1 ) {
            tipoRemuneracao = ( TipoRemuneracao__c ) new TipoRemuneracaoFactory().createRecord();
            remuneracaoProduto = ( RemuneracaoProduto__c ) new RemuneracaoProdutoFactory( tipoRemuneracao, produtoComercial ).createRecord();
            ramoSegurado = ( RamoSeguro__c ) new RamoSeguroFactory().createRecord();
            garantia = ( garantia__c ) new GarantiaFactory().createRecord();
            ramoGarantia = ( RamoGarantia__c ) new RamoGarantiaFactory( garantia, ramoSegurado ).createRecord();
            garantiaProdutoTEC = ( GarantiaProduto__c ) new GarantiaProdutoFactory.GarantiaProdutoTec( garantia, produtoTecnico, ramoSegurado ).createRecord();
            garantiaProduto = ( GarantiaProduto__c ) new GarantiaProdutoFactory.GarantiaProdutoCom( produtoComercial, garantia, garantiaProdutoTEC, ramoSegurado ).createRecord();
        }
        
		Oferta__c oferta = new Oferta__c( name = 'OfertaDaClasseTeste', produto__c = produtoComercial.id, VigenciaInicio__c = System.today(), Ativo__c = false );
		insert oferta;
        
        OpcaoInformacao__c opcao = null;
        
        if ( cenario == 0 || cenario == 5 || cenario == 6 || cenario == 7 ) {
            GeradorOferta__c gerador = new GeradorOferta__c();
            gerador.CodigoOfertaConsultiva__c = 'ABC';
            gerador.Status__c = 'Ativo';
            gerador.InicioVigencia__c = System.today();
            gerador.FinalVigencia__c = System.today().addDays( 7 );
            insert gerador;
            
            ConjuntoInformacoes__c conjunto = new ConjuntoInformacoes__c();
            conjunto.GeradorOfertas__c = gerador.Id;
            conjunto.Identificador__c = 123;
            conjunto.titulo__c = 'Conjunto X';
            conjunto.subtitulo__c = 'Subtitulo Conjunto X';
            insert conjunto;
            
            InformacaoOferta__c info = new InformacaoOferta__c();
            info.ConjuntoInformacoes__c = conjunto.Id;
            info.Id__c = 'ID_XPTO';
            info.Servico__c = 'Serviço X';
            info.tipo__c = 'Monetário';
            insert info;
            
            opcao = new OpcaoInformacao__c();
            opcao.InformacaoOferta__c = info.Id;
            opcao.Codigo__c = '123';
            insert opcao;
            
            InteligenciaOferta__c inteligenciaOferta = new InteligenciaOferta__c();
            inteligenciaOferta.GeradorOfertas__c = gerador.Id;
            insert inteligenciaOferta;
            
            DecisaoOferta__c decisaoOferta = new DecisaoOferta__c();
            decisaoOferta.InteligenciaOferta__c = inteligenciaOferta.Id;
            decisaoOferta.Oferta__c = oferta.Id;
            insert decisaoOferta;
        }
        
        if ( cenario == 5 || cenario == 6 ) {
            opcao.Codigo__c = 'ABC';
            update opcao;
		}
        
        if ( cenario == 2 ) {
            OfertaGarantiaProduto__c ogp = new OfertaGarantiaProduto__c( GarantiaProduto__c = garantiaProduto.Id, Oferta__c = oferta.Id, Chave__c = 'abc' );
            insert ogp;
            
            OfertaGarantiaProduto__c ogpDuplicate = new OfertaGarantiaProduto__c( GarantiaProduto__c = garantiaProduto.Id, Oferta__c = oferta.Id, Chave__c = 'def' );
            insert ogpDuplicate;
        }
        
        if ( cenario == 0 || cenario == 3 || cenario == 5 || cenario == 7 ) {
            OfertaRemuneracaoProduto__c orp = new OfertaRemuneracaoProduto__c();
            orp.RemuneracaoProduto__c = remuneracaoProduto.Id;
            orp.Oferta__c = oferta.Id;
            orp.TipoCadastro__c = 'Formula';
            orp.Formula__c = 'ID_XPTO';
            insert orp;
        }
        
        if ( cenario == 0 || cenario == 4 || cenario == 6 || cenario == 7 ) {
            GrupoOferta__c grupo = new GrupoOferta__c();
            grupo.Oferta__c = oferta.Id;
            grupo.TipoQuantidadeVidas__c = 'Formula';
            grupo.QuantidadeVidas__c = 'ID_XPTO';
            insert grupo;
        }

		Test.startTest();

		BotaoAprovarOfertaController.submitForApproval( oferta.Id, 'Test comment ' + cenario );

		Test.StopTest();
	}
}
// PLV-4366 - FIM