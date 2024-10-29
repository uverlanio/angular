@isTest
public class QuoteDAOTest {
    
    @testSetup
    static void setup() 
    {
        Account contaTeste = TestDataFactory.gerarConta();
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);
        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);
        Garantia__c garantia1 = TestDataFactory.gerarGarantia();
        RamoGarantia__c ramoGarantia = TestDataFactory.gerarRamoGarantia(garantia1, ramoSegurado);
        
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
	    ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        produtoTec.Status__c = 'Ativo';
        update produtoTec;
        
        Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        produtoCom.Status__c ='ativo';
        update produtoCom;

        GarantiaProduto__c garantiaProdutoTec = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTec, garantia1, ramoSegurado);
        GarantiaProduto__c garantiaProdutoCom = TestDataFactory.gerarGarantiaProdutoTecnico(produtoCom, garantia1, ramoSegurado);
        Questionario__c questionarioProdCom = TestDataFactory.gerarQuestionario();
        QuestionarioProduto__c questionarioProduto = TestDataFactory.gerarQuestionarioProduto(questionarioProdCom, produtoCom, garantiaProdutoCom);

        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        canalDistribuicao.Status__c = 'Ativo';
        update canalDistribuicao;
        
        TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao('COR', 100, 200, null);
        
        Opportunity orcamentoContratado = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        GarantiaOrcamento__c garantiaOrcamento = TestDataFactory.gerarGarantiaOrcamento(garantia1, orcamentoContratado);   
        RemuneracaoOrcamento__c remuneracaoOrcamento = TestDataFactory.gerarRemuneracaoOrcamento(orcamentoContratado, tipoRemuneracao);
        ContratanteOrcamento__c contratanteOrcamento = TestDataFactory.gerarContratanteOrcamento(orcamentoContratado, contaTeste);
        GrupoOrcamento__c grupoOrcamento = TestDataFactory.gerarGrupoOrcamento(contratanteOrcamento);
        SeguradoOrcamento__c seguradoOrcamento = TestDataFactory.gerarSeguradoOrcamento(grupoOrcamento);
        
        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);
        FormaPagamento__c formapagamento = TestDataFactory.gerarFormaPagamento();
        
        Quote proposta = new Quote(
                Name = QuoteBO.getInstance().gerarNameProposta('18','00326342'),
                NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta('18','00326342'),
                Produto__c = produtoCom.Id,
                RamoSeguro__c = ramoSegurado.Id,
                Status = 'Em criação',
                VigenciaInicial__c = System.today(),
                VigenciaFinal__c = System.today().addMonths(1),
                Empresa__c = contaTeste.Id,
                CodigoCorretor__c = dadosCorretor.Id,
                DataCalculo__c = System.today(),
                DataCriacaoPortal__c = System.today(),
                TipoVigencia__c = 'Anual',
                MeioComercializacao__c = 'PMC',
                OpportunityId = orcamentoContratado.Id,
                Origem__c = '18',
                Modalidade__c = modalidade.Id,
                NumeroProposta__c = '00326342',
                Parceiro__c = '49546324000119'        
        );
        insert proposta;
        GarantiaProposta__c garantiaProposta = TestDataFactory.gerarGarantiaProposta(proposta, garantiaProdutoTec);
        RemuneracaoProposta__c remuneracaoProposta = TestDataFactory.gerarRemuneracaoProposta(proposta, tipoRemuneracao);
        ContratanteProposta__c contratanteProposta = TestDataFactory.gerarContratanteProposta(contaTeste, proposta, formaPagamento);
        GrupoProposta__c grupoProposta = TestDataFactory.gerarGrupoProposta(contratanteProposta);
        SeguradoProposta__c seguradoProposta = TestDataFactory.gerarSeguradoProposta(contaTeste, grupoProposta, formaPagamento);
        BeneficiarioSeguradoProposta__c beneficiarioSeguradoProposta = TestDataFactory.gerarBeneficiarioSeguradoProposta(contaTeste, seguradoProposta);

        Contract contrato = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, proposta);
        contrato.Oportunidade__c = orcamentoContratado.Id;
        contrato.Proposta__c = proposta.Id;
        update contrato;
        
        Pergunta__c pergunta = new Pergunta__c(
            Pergunta__c = 'Qual a data de hoje',
            TipoResposta__c = 'Opção',
            OpcoesResposta__c = 'Sim;Não'
        );
        insert pergunta;
        
    	Questionario__c questionario = TestDataFactory.gerarQuestionario();
        
    	PerguntaQuestionario__c perguntaQuestionario = new PerguntaQuestionario__c(
            Pergunta__c = pergunta.Id,
            Questionario__c = questionario.Id,
            Numero__c = 1,
            PerguntasOpcao__c = 'Sim;Não'
        );
        insert perguntaQuestionario;
    }
    
    @isTest
    static void buscarPropostasPorIdTest()
    {   
        Set<Id> propostasIds = new Set<Id>();
        for(Quote proposta : [SELECT Id FROM Quote])       
        	propostasIds.add(proposta.Id);
        
        Test.startTest();
        	List<Quote> propostas = QuoteDAO.getInstance().buscarPropostasPorId(propostasIds);
        	System.assert(propostas.size() > 0, 'Falha nos testes da classe QuoteDAO. Método: buscarPropostasPorId. A busca de propostas por uma lista de Ids não encontrou registros.');
        Test.stopTest();
    }
    
    @isTest
    static void verificarPropostasMassificadosTest()
    {        
        Quote proposta = new Quote(
                Name = QuoteBO.getInstance().gerarNameProposta('18','00824369'),
                NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta('18','00824369'),
                Produto__c = [SELECT Id FROM Product2 WHERE RecordType.DeveloperName = 'ProdutoComercial' LIMIT 1].Id,
                RamoSeguro__c = [SELECT Id FROM RamoSeguro__c LIMIT 1].Id,
                VigenciaInicial__c = System.today(),
                VigenciaFinal__c = System.today().addMonths(1),
                Empresa__c = [SELECT Id FROM Account LIMIT 1].Id,
                CodigoCorretor__c = [SELECT Id FROM DadosCorretor__c LIMIT 1].Id,
                DataCalculo__c = System.today(),
                DataCriacaoPortal__c = System.today(),
                TipoVigencia__c = 'Anual',
                OpportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id,
                Origem__c = '18',
                Modalidade__c = [SELECT Id FROM Modalidade__c LIMIT 1].Id,
                NumeroProposta__c = '00824369',
                Parceiro__c = '72800366000156',
            	Status = 'Disponível para contratação',
                MeioComercializacao__c = 'ARQ',
                Massificados__c = true
        );
        insert proposta;
        
        Test.startTest();
        	List<Quote> propostas = QuoteDAO.getInstance().verificarPropostasMassificados();
        	System.assert(propostas.size() > 0, 'Falha nos testes da classe QuoteDAO. Método: verificarPropostasMassificados. A busca de propostas de massificados não encontrou registros.');
        Test.stopTest();
    }
    
    @isTest
    static void buscarPropostasCancelamentoPendentesPorContratoOriginalTest()
    {
        Id contratoId = [SELECT Id FROM Contract LIMIT 1].Id;
        
        Quote proposta = new Quote(
            Name = QuoteBO.getInstance().gerarNameProposta('18','00563821'),
            NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta('18','00563821'),
            Produto__c = [SELECT Id FROM Product2 WHERE RecordType.DeveloperName = 'ProdutoComercial' LIMIT 1].Id,
            RamoSeguro__c = [SELECT Id FROM RamoSeguro__c LIMIT 1].Id,
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addMonths(1),
            Empresa__c = [SELECT Id FROM Account LIMIT 1].Id,
            CodigoCorretor__c = [SELECT Id FROM DadosCorretor__c LIMIT 1].Id,
            DataCalculo__c = System.today(),
            DataCriacaoPortal__c = System.today(),
            TipoVigencia__c = 'Anual',
            OpportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id,
            Origem__c = '18',
            Modalidade__c = [SELECT Id FROM Modalidade__c LIMIT 1].Id,
            NumeroProposta__c = '00563821',
            Parceiro__c = '72800366000156',
            Status = 'Disponível para contratação',
            MeioComercializacao__c = 'ARQ',
            Massificados__c = true,
            ContractId = contratoId,
            Tipo__c = 'Cancelamento'
        );
        insert proposta;
        
        Set<Id> contratosIds = new Set<Id>();
        contratosIds.add(contratoId);
        
        Test.startTest();
        	List<Quote> propostas = QuoteDAO.getInstance().buscarPropostasCancelamentoPendentesPorContratoOriginal(contratosIds);
        	System.assert(propostas.size() > 0, 'Falha nos testes da classe QuoteDAO. Método: buscarPropostasCancelamentoPendentesPorContratoOriginal. A busca de propostas pendentes de cancelamento por contrato original não encontrou registros.');
        Test.stopTest();
    }
    
    @isTest
    static void obterPropostaPorNumeroTest()
    {
        Quote proposta = [SELECT Id, NumeroProposta__c FROM Quote LIMIT 1];       
        
        Test.startTest();
        	List<Quote> propostas = QuoteDAO.getInstance().obterPropostaPorNumero(proposta.NumeroProposta__c);
        	System.assert(propostas.size() > 0, 'Falha nos testes da classe QuoteDAO. Método: obterPropostaPorNumero. A busca de propostas por número não encontrou registros.');
        Test.stopTest();
    }
    
    @isTest
    static void obterPropostaPorNameTest()
    {
        Quote proposta = [SELECT Id, Name FROM Quote LIMIT 1];       
        
        Test.startTest();
        	List<Quote> propostas = QuoteDAO.getInstance().obterPropostaPorName(proposta.Name);
        	System.assert(propostas.size() > 0, 'Falha nos testes da classe QuoteDAO. Método: obterPropostaPorName. A busca de proposta por nome não encontrou registros.');
        Test.stopTest();
    }
    
    @isTest
    static void obterListaPropostasPorNameTest()
    {
        Set<String> propostasNames = new Set<String>();
        for(Quote proposta : [SELECT Id, Name FROM Quote])       
        	propostasNames.add(proposta.Name);
        
        Test.startTest();
        	List<Quote> propostas = QuoteDAO.getInstance().obterListaPropostasPorName(propostasNames);
        	System.assert(propostas.size() > 0, 'Falha nos testes da classe QuoteDAO. Método: obterListaPropostasPorName. A busca de lista de propostas por nome não encontrou registros.');
        Test.stopTest();
    }
    
    @isTest
    static void obterContratoPorQuoteNameTest()
    {
        Quote proposta = [SELECT Id, Name FROM Quote LIMIT 1];
        
        Test.startTest();
        	List<Contract> contratos = QuoteDAO.getInstance().obterContratoPorQuoteName(proposta.Name);
        	System.assert(contratos.size() > 0, 'Falha nos testes da classe QuoteDAO. Método: obterContratoPorQuoteName. A busca de contratos por nome de proposta não encontrou registros.');
        Test.stopTest();
    }
    
    @isTest
    static void buscarRemuneracaoOrcamentoNoOrcamentoTest()
    {
        Set<Id> propostasId = new Set<Id>();
        for(Quote proposta : [SELECT Id FROM Quote])
            propostasId.add(proposta.Id);
        
        Test.startTest();
        	List<Opportunity> orcamentos = QuoteDAO.getInstance().buscarRemuneracaoOrcamentoNoOrcamento(propostasId);
        	System.assert(orcamentos.size() > 0, 'Falha nos testes da classe QuoteDAO. Método: buscarRemuneracaoOrcamentoNoOrcamento. A busca de orçamentos (com remunerações) por ids de propostas não encontrou registros.');
        Test.stopTest();
    }
    
    @isTest
    static void buscarContratantesPropostaPorIdPropostaTest()
    {
        Set<Id> propostasId = new Set<Id>();
        for(Quote proposta : [SELECT Id FROM Quote])
            propostasId.add(proposta.Id);
        
        Test.startTest();
        	List<ContratanteProposta__c> contratantesPropostas = QuoteDAO.getInstance().buscarContratantesPropostaPorIdProposta(propostasId);
        	System.assert(contratantesPropostas.size() > 0, 'Falha nos testes da classe QuoteDAO. Método: buscarContratantesPropostaPorIdProposta. A busca de contratantes de propostas por ids de propostas não encontrou registros.');
        Test.stopTest();
    }
    
    @isTest
    static void buscarBeneficiariosSeguradosPropostaTest()
    {
        Set<Id> propostasId = new Set<Id>();
        for(Quote proposta : [SELECT Id FROM Quote])
            propostasId.add(proposta.Id);
        
        Test.startTest();
        	List<BeneficiarioSeguradoProposta__c> beneficiariosSeguradosPropostas = QuoteDAO.getInstance().buscarBeneficiariosSeguradosProposta(propostasId);
        	System.assert(beneficiariosSeguradosPropostas.size() > 0, 'Falha nos testes da classe QuoteDAO. Método: buscarBeneficiariosSeguradosProposta. A busca de beneficiários de segurados das propostas por ids de propostas não encontrou registros.');
        Test.stopTest();
    }

    @isTest
    static void buscarPerguntasQuestionarioTest()
    {

        Set<Id> questionariosIds = new Set<Id>();
        for(Questionario__c questionario : [SELECT Id FROM Questionario__c])
            questionariosIds.add(questionario.Id);
        
        Test.startTest();
        	List<PerguntaQuestionario__c> perguntasQuestionarios = QuoteDAO.getInstance().buscarPerguntasQuestionario(questionariosIds);
        	System.assert(perguntasQuestionarios.size() > 0, 'Falha nos testes da classe QuoteDAO. Método: buscarPerguntasQuestionario. A busca de perguntas por ids de questionários não encontrou registros.');
        Test.stopTest();
    }
    
    @isTest
    static void buscarQuestionarioPrioritarioTest()
    {
        Set<Id> garantiasProdutosIds = new Set<Id>();
        for(GarantiaProduto__c garantiaProduto : [SELECT Id FROM GarantiaProduto__c])
            garantiasProdutosIds.add(garantiaProduto.Id);
        
        Test.startTest();
        	List<QuestionarioProduto__c> questionariosProdutos = QuoteDAO.getInstance().buscarQuestionarioPrioritario(garantiasProdutosIds);
        	System.assert(questionariosProdutos.size() > 0, 'Falha nos testes da classe QuoteDAO. Método: buscarQuestionarioPrioritario. A busca de questionários de produtos por ids de garantias de produtos não encontrou registros.');
        Test.stopTest();
    }
    
    @isTest
    static void buscarGarantiasPropostaTest()
    {
        Quote proposta = [SELECT Id FROM Quote LIMIT 1];
        
        Test.startTest();
        	List<GarantiaProposta__c> garantiasProposta = QuoteDAO.getInstance().buscarGarantiasProposta(proposta.Id);
        	System.assert(garantiasProposta.size() > 0, 'Falha nos testes da classe QuoteDAO. Método: buscarGarantiasProposta. A busca de garantias da proposta por id da proposta não encontrou registros.');
        Test.stopTest();
    }
    
    @isTest
    static void buscarGarantiasPropostasTest()
    {
        Set<Id> propostasId = new Set<Id>();
        for(Quote proposta : [SELECT Id FROM Quote])
            propostasId.add(proposta.Id);
        
        Test.startTest();
        	List<GarantiaProposta__c> garantiasPropostas = QuoteDAO.getInstance().buscarGarantiasProposta(propostasId);
        	System.assert(garantiasPropostas.size() > 0, 'Falha nos testes da classe QuoteDAO. Método: buscarGarantiasProposta. A busca de garantias das propostas por ids de propostas não encontrou registros.');
        Test.stopTest();
    }
    
    @isTest
    static void buscarListSeguradosPropostaByQuoteTest()
    {
        Set<Id> propostasId = new Set<Id>();
        for(Quote proposta : [SELECT Id FROM Quote])
            propostasId.add(proposta.Id);
        
        Test.startTest();
        	List<SeguradoProposta__c> seguradosPropostas = QuoteDAO.getInstance().buscarListSeguradosPropostaByQuote(propostasId);
        	System.assert(seguradosPropostas.size() > 0, 'Falha nos testes da classe QuoteDAO. Método: buscarListSeguradosPropostaByQuote. A busca de segurados das propostas por ids de propostas não encontrou registros.');
        Test.stopTest();
    }
    
    @isTest
    static void buscarListGrupoPropostaByQuoteTest()
    {
        Set<Id> propostasId = new Set<Id>();
        for(Quote proposta : [SELECT Id FROM Quote])
            propostasId.add(proposta.Id);
        
        Test.startTest();
        	List<GrupoProposta__c> gruposPropostas = QuoteDAO.getInstance().buscarListGrupoPropostaByQuote(propostasId);
        	System.assert(gruposPropostas.size() > 0, 'Falha nos testes da classe QuoteDAO. Método: buscarListGrupoPropostaByQuote. A busca de grupos das propostas por ids de propostas não encontrou registros.');
        Test.stopTest();
    }
    
    @isTest
    static void buscarContratantesPropostaByQuoteTest()
    {
        Set<Id> propostasId = new Set<Id>();
        for(Quote proposta : [SELECT Id FROM Quote])
            propostasId.add(proposta.Id);
        
        Test.startTest();
        	List<ContratanteProposta__c> contratantesPropostas = QuoteDAO.getInstance().buscarContratantesPropostaByQuote(propostasId);
        	System.assert(contratantesPropostas.size() > 0, 'Falha nos testes da classe QuoteDAO. Método: buscarContratantesPropostaByQuote. A busca de contratantes das propostas por ids de propostas não encontrou registros.');
        Test.stopTest();
    }
    
    @isTest
    static void buscarPropostasCancelamentoPorContratoOriginalTest()
    {
        Id contratoId = [SELECT Id FROM Contract LIMIT 1].Id;
        
        Quote proposta = new Quote(
            Name = QuoteBO.getInstance().gerarNameProposta('18','00824378'),
            NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta('18','00824378'),
            Produto__c = [SELECT Id FROM Product2 WHERE RecordType.DeveloperName = 'ProdutoComercial' LIMIT 1].Id,
            RamoSeguro__c = [SELECT Id FROM RamoSeguro__c LIMIT 1].Id,
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addMonths(1),
            Empresa__c = [SELECT Id FROM Account LIMIT 1].Id,
            CodigoCorretor__c = [SELECT Id FROM DadosCorretor__c LIMIT 1].Id,
            DataCalculo__c = System.today(),
            DataCriacaoPortal__c = System.today(),
            TipoVigencia__c = 'Anual',
            OpportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id,
            Origem__c = '18',
            Modalidade__c = [SELECT Id FROM Modalidade__c LIMIT 1].Id,
            NumeroProposta__c = '00824378',
            Parceiro__c = '53593948000164',
            Status = 'Disponível para contratação',
            MeioComercializacao__c = 'ARQ',
            Massificados__c = true,
            ContractId = contratoId,
            Tipo__c = 'Cancelamento'
        );
        insert proposta;
        
        Set<Id> contratosIds = new Set<Id>();
        contratosIds.add(contratoId);
        
        Test.startTest();
        	List<Quote> propostas = QuoteDAO.getInstance().buscarPropostasCancelamentoPorContratoOriginal(contratosIds);
        	System.assert(propostas.size() > 0, 'Falha nos testes da classe QuoteDAO. Método: buscarPropostasCancelamentoPorContratoOriginal. A busca de propostas de cancelamento por contrato original não encontrou registros.');
        Test.stopTest();
    }
}