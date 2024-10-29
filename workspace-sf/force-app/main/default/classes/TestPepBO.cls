@isTest
private class TestPepBO{

	@TestSetup
    static void setup(){        
        // PLV-3667 - INICIO    
        insert new ContadorCodigo__c(Name='ProdutoTecnico', Numero__c = 0);
        insert new ContadorCodigo__c(Name='ProdutoComercial', Numero__c = 0);

        // PLV-3667 - FIM        
        Map<String, String> paramConsMap = new Map<String,String> ();
        paramConsMap.put('GRUPO_JOVENS_NOME','Passageiros até 70 anos');
        paramConsMap.put('GRUPO_IDOSOS_IDADE_MIN',' 71');
        paramConsMap.put('GRUPO_IDOSOS_IDADE_MAX','90');
        paramConsMap.put('GRUPO_IDOSOS_NOME','Passageiros de 71 a 90 anos');
        paramConsMap.put('GRUPO_JOVENS_IDADE_MAX','70');
        paramConsMap.put('GRUPO_JOVENS_IDADE_MIN','0');

       
        list<ParametrosConstante__c> lstParamCons = new List<ParametrosConstante__c>();
        for(String pc : paramConsMap.keySet()){
            lstParamCons.add( new ParametrosConstante__c (name = pc, Valor__c = paramConsMap.get(pc) ));
        }
        insert lstParamCons;

        //
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        Product2 produtoComercial  = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        Account acc =   (Account) new AccountFactory.PessoaFisica().createRecord();
        acc.IdExterno__c = '34648600606';
        update acc;

        Product2 produtoTecnicoAp = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnicoAp.Status__c = 'Em ativação';
        produtoTecnicoAp.NumeroSusep__c = '123';
        produtoTecnicoAp.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnicoAp;
        produtoTecnicoAp.Status__c = 'Ativo';
        produtoTecnicoAp.ProductCode = '49';
        produtoTecnicoAp.Segmento__c = 'Individual';
        update produtoTecnicoAp;
        Product2 produtoComercialAp = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnicoAp).createRecord();
        produtoComercialAp.Status__c = 'Ativo';
        produtoComercialAp.ProductCode = 'APTLMKT';
        produtoComercialAp.Segmento__c = 'Individual';
        produtoComercialAp.CodigoPrecificaProduto__c = 'APTLMKT';
        update produtoComercialAp;
    

        CanalDistribuicao__c cd = new CanalDistribuicao__c();
        insert cd; 
        Opportunity orcamento = (Opportunity) new OrcamentoFactory.VidaIndividual().createRecord();
        orcamento.Numero__c = '00006395';
        orcamento.StageName = 'Disponível para contratação';
        orcamento.CanalDistribuicao__c = cd.Id;
        orcamento.Produto__c = produtoComercial.Id;
        update orcamento;
		//-167 INICIO
        TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao('CORRETAGEM', 1, 45, null);
        RemuneracaoOrcamento__c remuneracaoOrcamento = TestDataFactory.gerarRemuneracaoOrcamento(orcamento, tipoRemuneracao);
		//-167 FIM
        FormaPagamento__c formaPagamento =  new FormaPagamento__c( Codigo__c = '62', Name = '3X');
        insert formaPagamento;
        CondicaoCobranca__c conCobranca = new CondicaoCobranca__c ( Produto__c = produtoComercial.Id, 
                                                                    QuantidadeParcelas__c = '6',
                                                                    FormaPagamento__c = formaPagamento.Id);
        insert conCobranca;
        insert new PlanoParcelamento__c(FormaPagamento__c = formaPagamento.Id, NumeroParcela__c = 6 );

        List<Quote> listaPropostas = new List<Quote>();
        
        Quote   proposta = new Quote(   Name = '18-00001365', 
                                     OpportunityId = orcamento.Id, 
                                     FormaPagamento__c = formaPagamento.Id, 
                                     VigenciaInicial__c = Date.today(),
                                     CanalDistribuicao__c = cd.Id,
                                     Produto__c = produtoComercial.Id,
                                     Status = 'Em análise',
                                     ReaproveitarAssinatura__c = false, 
                                     VigenciaFinal__c = Date.today().addDays(60));     
        insert proposta;
		
        RemuneracaoProposta__c rp = new RemuneracaoProposta__c (Proposta__c = proposta.Id,
                                                                TipoRemuneracao__c = remuneracaoOrcamento.TipoRemuneracao__c);
        insert rp;


        remuneracaoProduto__c remuneracaoProduto = (remuneracaoProduto__c) new RemuneracaoProdutoFactory(tipoRemuneracao, produtoComercialAp).createRecord();
        update remuneracaoProduto;
        
    }

	@isTest static void testMethod1() {
		// code_block	
	}

	@isTest static void testMethod2() {
		// code_block	
	}
}