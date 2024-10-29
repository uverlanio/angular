@isTest
private class RemuneracaoMultinivelTriggerHandlerTest {
	
	@testSetup 
	static void setup(){
        TestDataFactory.gerarDadosSetup();

        //testInsertGarantiaProposta();
	}

    @isTest
    public static void testInsertRemuneracaoMultinivel(){
    	
        Account conta = new Account(
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica').Id,
            LastName = 'Teste2',
            Nacionalidade__c = 'Brasileira',
            CPF__c = '00478394659',
            Rg__c = '232323231',
            DataExpedicao__c = Date.today(),
            OrgaoExpedidor__c = '123132',
            PersonBirthDate = Date.valueOf('1980-12-24'),
            EstadoCivil__c = 'Solteiro (a)'
        );
        insert conta;

        Opportunity oportunidade = new Opportunity(
            Name = 'Teste Contrato',
            StageName = 'Em criação',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaIndividual').Id,
            AccountId = conta.Id,
            CloseDate = Date.today()
        );
        insert oportunidade;

        Product2 produtoTec = new Product2(
                Name = 'Nome Produto Teste Versao',
                Status__c = 'Em criação',
                ProductCode = '201700001',
                VigenciaInicial__c = System.today().addDays(3),
                TipoCapital__c = 'Capital uniforme',
                Segmento__c = 'Coletivo',
                TipoResponsavelPagamento__c = 'PAR',
                NumeroSusep__c = '12345',
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id,
                Versao__c                       = 1,
                VersaoMaxima__c                 = true,
                VersaoRenovacao__c              = 'Versão atual'
        );

        insert produtoTec;

        produtoTec.Status__c = 'Em ativação';
		produtoTec.NumeroSusep__c = '1234x';
		update produtoTec;

		produtoTec.Status__c = 'Ativo';
		update produtoTec;

        Product2 produtoComercial = new Product2(
                ProdutoTecnico__c               = produtoTec.Id,
                Name                            = 'Nome Produto Teste Versao',
                Status__c                       = 'Em criação',
                ProductCode                     = '201700001',
                VigenciaInicial__c              = System.today(),
                VigenciaFinal__c                = System.today().addDays(1),
                TipoCapital__c                  = 'Capital uniforme',
                Segmento__c                     = 'Coletivo',
                TipoResponsavelPagamento__c     = 'PAR',
                LimiteTotalCarregamento__c      = 200,
                NumeroSusep__c                  = '12345',
                RecordTypeId                    = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id,
                Versao__c                       = 1,
                VersaoMaxima__c                 = true,
                VersaoRenovacao__c              = 'Versão atual'
        );
        insert produtoComercial;

        produtoComercial.Status__c = 'Ativo';
        update produtoComercial;

        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        ProdutoCanal__c produtoCanal = new ProdutoCanal__c(
                CanalDistribuicao__c = canalDistribuicao.Id,
                Produto__c = produtoComercial.Id
        );
        insert produtoCanal;

        TipoRemuneracao__c tipoRemuneracaoParaCanal = TestDataFactory.gerarTipoRemuneracao();
        RemuneracaoProduto__c remuneracaoProduto = TestDataFactory.gerarRemuneracaoProduto(produtoComercial, tipoRemuneracaoParaCanal);
        //RemuneracaoCanal__c remuneracaoCanal = TestDataFactory.gerarRemuneracaoCanal(produtoCanal, tipoRemuneracaoParaCanal);

        RemuneracaoMultinivel__c remuneracaoMultinivel = new RemuneracaoMultinivel__c();
		remuneracaoMultinivel.ProdutoCanal__c = produtoCanal.Id;
		remuneracaoMultinivel.TipoRemuneracao__c = tipoRemuneracaoParaCanal.Id;
		remuneracaoMultinivel.Tipo__c = 'Nível 1';
		remuneracaoMultinivel.Participacao__c = 10;
		remuneracaoMultinivel.Conta__c = conta.Id;
		insert remuneracaoMultinivel;

		remuneracaoMultinivel.Participacao__c = 12;
		update remuneracaoMultinivel;

		System.assertEquals(true, (remuneracaoMultinivel != null));


    }
	
}