/**************************************************************************************************************************************************************************
 *
 *	Classe responsável pelos testes de triggers do objeto RemuneracaoOrcamento__c
 *
 **************************************************************************************************************************************************************************/
@isTest
private class RemuneracaoOrcamentoTest {
	@testSetup
	private static void setup() {
		TestDataFactory.gerarDadosSetup();
	}
    
    //PLV-4698 INICIO
    /* A validação de remuneração por produto foi movida para o odm
    O ODM valida a remuneração do produto e os limites e retorna uma crítica de recusa
	@isTest
	private static void testarTipoRemuneracaoProdutoCanal() {
		Opportunity orcamento = gerarDados();
		
		//Gera os tipo de remuneração
		TipoRemuneracao__c tipoRemuneracaoCorretagem = TestDataFactory.gerarTipoRemuneracao('CORRETAGEM', 1, 100, 'Integral');
		TipoRemuneracao__c tipoRemuneracaoComissao = TestDataFactory.gerarTipoRemuneracao('COMISSAO', 1, 100, 'Integral');
		RemuneracaoOrcamento__c remuneracaoCorretagem;

		//Tenta gerar remuneração do orçamento cujo não exista um produto do canal correspondente
		String erro = 'OK';

		try {
			remuneracaoCorretagem = TestDataFactory.gerarRemuneracaoOrcamento(orcamento, tipoRemuneracaoCorretagem);
		} catch(Exception e) {
			erro = e.getMessage();
		}

		erro = erro.indexOf('Não foi encontrado o produto do canal para este orçamento.') > -1 ? 'Não foi encontrado o produto do canal para este orçamento.' : erro;
		System.assertEquals('Não foi encontrado o produto do canal para este orçamento.', erro);

		//Cria produto do canal relacionado a oportunidade
		Product2 produtoComercial = [Select Id From Product2 Where Id = :orcamento.Produto__c Limit 1];
		CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();

		orcamento.CanalDistribuicao__c = canalDistribuicao.Id;
		update orcamento;

    	ProdutoCanal__c produtoCanal = TestDataFactory.gerarProdutoCanal(canalDistribuicao, produtoComercial);
    	RemuneracaoProduto__c remuneracaoProduto = TestDataFactory.gerarRemuneracaoProduto(produtoComercial, tipoRemuneracaoComissao);
    	RemuneracaoCanal__c remuneracaoProdutoCanal = TestDataFactory.gerarRemuneracaoCanal(produtoCanal, tipoRemuneracaoComissao);

    	//Tenta gerar remuneração do orçamento cujo exista um produto do canal correspondente, mas o tipo de remuneração é diferente
    	//REGRA DEIXOU DE EXISTIR
		//erro = 'OK';

		//try {
		//	remuneracaoCorretagem = TestDataFactory.gerarRemuneracaoOrcamento(orcamento, tipoRemuneracaoCorretagem);
		//} catch(Exception e) {
		//	erro = e.getMessage();
		//}

		//erro = erro.indexOf('Tipo de remuneração não existe no canal.') > -1 ? 'Tipo de remuneração não existe no canal.' : erro;
		//System.assertEquals('Tipo de remuneração não existe no canal.', erro);


		//Tenta gerar remuneração do orçamento cujo exista um produto do canal correspondente
		erro = 'OK';

		RemuneracaoProduto__c remuneracaoProdutoCor = TestDataFactory.gerarRemuneracaoProduto(produtoComercial, tipoRemuneracaoCorretagem);
    	RemuneracaoCanal__c remuneracaoProdutoCanalCor = TestDataFactory.gerarRemuneracaoCanal(produtoCanal, tipoRemuneracaoCorretagem);

		try {
			remuneracaoCorretagem = TestDataFactory.gerarRemuneracaoOrcamento(orcamento, tipoRemuneracaoCorretagem);
		} catch(Exception e) {
			erro = e.getMessage();
		}
		
		System.assertEquals('OK', erro);		
		System.assert(remuneracaoCorretagem.Id != null);
    }

	@isTest
	private static void testarLimitesRemuneracao() {
		Opportunity orcamento = gerarDados();
		
		//Gera os tipo de remuneração
		TipoRemuneracao__c tipoRemuneracaoCorretagem = TestDataFactory.gerarTipoRemuneracao('CORRETAGEM', 1, 100, 'Integral');
		RemuneracaoOrcamento__c remuneracaoCorretagem;

		//Cria produto do canal relacionado a oportunidade
		Product2 produtoComercial = [Select Id From Product2 Where Id = :orcamento.Produto__c Limit 1];
		CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();

		orcamento.CanalDistribuicao__c = canalDistribuicao.Id;
		update orcamento;

    	ProdutoCanal__c produtoCanal = TestDataFactory.gerarProdutoCanal(canalDistribuicao, produtoComercial);
    	RemuneracaoProduto__c remuneracaoProduto = TestDataFactory.gerarRemuneracaoProduto(produtoComercial, tipoRemuneracaoCorretagem);
    	RemuneracaoCanal__c remuneracaoProdutoCanal = TestDataFactory.gerarRemuneracaoCanal(produtoCanal, tipoRemuneracaoCorretagem);

    	//Tenta gerar remuneração do orçamento cujo exista um produto do canal correspondente
		String erro = 'OK';

		try {
			remuneracaoCorretagem = TestDataFactory.gerarRemuneracaoOrcamento(orcamento, tipoRemuneracaoCorretagem);
		} catch(Exception e) {
			erro = e.getMessage();
		}

		System.assertEquals('OK', erro);
		System.assert(remuneracaoCorretagem.Id != null);

		//Tenta atualizar uma remuneração não qual o limite esteja abaixo dos limites do produto comercial
		erro = 'OK';

		try {
			remuneracaoCorretagem.Percentual__c = -10;
			update remuneracaoCorretagem;
		} catch(Exception e) {
			erro = e.getMessage();
		}

		erro = erro.indexOf('Percentual de carregamento abaixo do limite do produto comercial.') > -1 ? 'Percentual de carregamento abaixo do limite do produto comercial.' : erro;
		System.assertEquals('Percentual de carregamento abaixo do limite do produto comercial.', erro);

		//Tenta atualizar uma remuneração não qual o limite esteja acima dos limites do produto comercial
		erro = 'OK';

		try {
			remuneracaoCorretagem.Percentual__c = 1000;
			update remuneracaoCorretagem;
		} catch(Exception e) {
			erro = e.getMessage();
		}

		erro = erro.indexOf('Percentual de carregamento acima do limite do produto comercial.') > -1 ? 'Percentual de carregamento acima do limite do produto comercial.' : erro;
		System.assertEquals('Percentual de carregamento acima do limite do produto comercial.', erro);
    }
    
    */
    //PLV-4698 FIM

	//@isTest 
	//VALIDACAO NAO ESTÁ MAIS SENDO CHAMADA NA TRIGGER
	private static void testarTipoRemuneracaoRepetido() {
		Opportunity orcamento = gerarDados();

		//Gera os tipo de remuneração
		TipoRemuneracao__c tipoRemuneracaoCorretagem = TestDataFactory.gerarTipoRemuneracao('CORRETAGEM', 1, 100, 'Integral');
		TipoRemuneracao__c tipoRemuneracaoComissao = TestDataFactory.gerarTipoRemuneracao('COMISSAO', 1, 100, 'Integral');

		Product2 produtoComercial = [Select Id From Product2 Where Id = :orcamento.Produto__c Limit 1];
		CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();

		orcamento.CanalDistribuicao__c = canalDistribuicao.Id;
		update orcamento;

    	ProdutoCanal__c produtoCanal = TestDataFactory.gerarProdutoCanal(canalDistribuicao, produtoComercial);
    	RemuneracaoProduto__c remuneracaoProdutoCorretagem = TestDataFactory.gerarRemuneracaoProduto(produtoComercial, tipoRemuneracaoCorretagem);
    	RemuneracaoProduto__c remuneracaoProdutoComissao = TestDataFactory.gerarRemuneracaoProduto(produtoComercial, tipoRemuneracaoComissao);
    	RemuneracaoCanal__c remuneracaoProdutoCanalCorretagem = TestDataFactory.gerarRemuneracaoCanal(produtoCanal, tipoRemuneracaoCorretagem);
    	RemuneracaoCanal__c remuneracaoProdutoCanalComissao = TestDataFactory.gerarRemuneracaoCanal(produtoCanal, tipoRemuneracaoComissao);

		RemuneracaoOrcamento__c remuneracao1 = TestDataFactory.gerarRemuneracaoOrcamento(orcamento, tipoRemuneracaoCorretagem);
		RemuneracaoOrcamento__c remuneracao2;

		//Gera Remuneracao do Orcamento de mesmo tipo que já existe e tenta inserir
		String erro = 'OK';

		try {
			remuneracao2 = TestDataFactory.gerarRemuneracaoOrcamento(orcamento, tipoRemuneracaoCorretagem);

		} catch(Exception e) {
			erro = e.getMessage();
		}

		erro = erro.indexOf('Remuneração já cadastrada') > -1 ? 'Remuneração já cadastrada' : erro;
		System.assertEquals('Remuneração já cadastrada', erro);

		//Gera Remuneracao do Orcamento de mesmo tipo que ainda não existe para o orçamento
		remuneracao2 = TestDataFactory.gerarRemuneracaoOrcamento(orcamento, tipoRemuneracaoComissao);
		System.assert(remuneracao2.Id != null);
	}

	private static Opportunity gerarDados(){
		//Gera orçamento e suas dependencias
		// PLV-2312-28 INICIO
		Map<String,List<SObject>> dados = TestDataFactory.gerarOrcamento(false);
		// PLV-2312-28 FIM

		//Busca todas as remuneraçoes do orçamento e apaga para poder facilitar a geração dos testes
		List<RemuneracaoOrcamento__c> remuneracoesOrcamento = [Select Id From RemuneracaoOrcamento__c];
		delete remuneracoesOrcamento;

		List<CanalDistribuicao__c> canaisDistribuicao = [Select Id From CanalDistribuicao__c];
		delete canaisDistribuicao;

		List<ProdutoCanal__c> produtoCanal = [Select Id From ProdutoCanal__c];
		delete produtoCanal;

		List<RemuneracaoProduto__c> remuneracoesProduto = [Select Id From RemuneracaoProduto__c];
		delete remuneracoesProduto;

		List<RemuneracaoCanal__c> remuneracoesCanal = [Select Id From RemuneracaoCanal__c];
		delete remuneracoesCanal;

		return (Opportunity)dados.get('Opportunity').get(0);
	}
    @isTest
    public static void testValidarTipoRemuneracaoExistente(){

		Opportunity orcamento = gerarDados();

		//Gera os tipo de remuneração
		TipoRemuneracao__c tipoRemuneracaoCorretagem = TestDataFactory.gerarTipoRemuneracao('CORRETAGEM', 1, 100, 'Integral');
		TipoRemuneracao__c tipoRemuneracaoComissao = TestDataFactory.gerarTipoRemuneracao('COMISSAO', 1, 100, 'Integral');

		Product2 produtoComercial = [Select Id From Product2 Where Id = :orcamento.Produto__c Limit 1];
		CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();

		orcamento.CanalDistribuicao__c = canalDistribuicao.Id;
		update orcamento;

    	ProdutoCanal__c produtoCanal = TestDataFactory.gerarProdutoCanal(canalDistribuicao, produtoComercial);
    	RemuneracaoProduto__c remuneracaoProdutoCorretagem = TestDataFactory.gerarRemuneracaoProduto(produtoComercial, tipoRemuneracaoCorretagem);
    	RemuneracaoProduto__c remuneracaoProdutoComissao = TestDataFactory.gerarRemuneracaoProduto(produtoComercial, tipoRemuneracaoComissao);
    	RemuneracaoCanal__c remuneracaoProdutoCanalCorretagem = TestDataFactory.gerarRemuneracaoCanal(produtoCanal, tipoRemuneracaoCorretagem);
    	RemuneracaoCanal__c remuneracaoProdutoCanalComissao = TestDataFactory.gerarRemuneracaoCanal(produtoCanal, tipoRemuneracaoComissao);

		RemuneracaoOrcamento__c remuneracao1 = TestDataFactory.gerarRemuneracaoOrcamento(orcamento, tipoRemuneracaoCorretagem);
		RemuneracaoOrcamento__c remuneracao2;


        
        
        List<RemuneracaoOrcamento__c> remuneracoes = new List<RemuneracaoOrcamento__c>();
        remuneracoes.add(remuneracao1);
        
        //test.startTest(); PLV-4698 INICIO/FIM
        
        RemuneracaoOrcamentoBO.getInstance().validarTipoRemuneracaoExistente(remuneracoes);
        
        //test.stopTest();  PLV-4698 INICIO/FIM
        
    }
}