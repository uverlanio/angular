/*******************************************************************************************************************************
* Consulta dados de Proposta
* @author Carlos - Meta
* @date 30/07/2020
* Classe criada por conta da história PLV-4205
******************************************************************************************************************************/
@isTest
public  class ConsultaPropostaADMRESTTest {
    @TestSetup
    static void setupUnit(){
        ContadorCodigo__c contadorTecnico = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contadorComercial = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();

        Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(conta).createRecord();
        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(conta).createRecord();
        CanalDistribuicao__c canalDistribuicao = (CanalDistribuicao__c) new CanalDistribuicaoFactory().createRecord(); 
        Modalidade__c modalidade = (Modalidade__c) new ModalidadeFactory(ramoSeguro).createRecord();
        
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        		
        Opportunity orcamento = (Opportunity) new OrcamentoFactory.VidaIndividual(produtoComercial, conta).createRecord();
        Quote proposta = (Quote) new PropostaFactory(produtoComercial, ramoSeguro, conta, dadosCorretor, orcamento, modalidade).createRecord();
        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
		proposta.Produto__c = produtoComercial.Id;
        proposta.Status = 'Em análise';
        proposta.Parceiro__c = '';
        proposta.MeioComercializacao__c = 'CO2';
        proposta.tipo__c = 'Novo';
        proposta.CanalDistribuicao__c = canalDistribuicao.Id;
        proposta.FormaPagamento__c = formaPagamento.Id;
        proposta.Massificados__c = false;
		//PLV-4197 Inicio
		CriticaProposta__c critrica = new CriticaProposta__c();
        critrica.Status__c = 'Pendenciado';
        critrica.MotivoPendencia__c = 'Pendência enviada - Risco Agravado';
		critrica.Proposta__c = proposta.id;
		insert critrica;
		//PLV-4197 Fim

        update proposta;
        //II-208 - INICIO
        TipoRemuneracao__c tipoRemuneracao = new TipoRemuneracao__c(
            Name = 'CORRETAGEM',
            Descricao__c = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit.',
            ModeloRecuperacao__c = 'Integral',
            Codigo__c = 'COR',
            LimiteMinimo__c = 10,
            LimiteMaximo__c = 50
        );
        insert tipoRemuneracao;

        RemuneracaoProposta__c remuneracaoProposta = new RemuneracaoProposta__c(            
            TipoRemuneracao__c = tipoRemuneracao.Id,                    
            Porcentagem_de_Retencao__c = 10.00,
            Percentual__c = 10.00,
            Proposta__c = proposta.Id
        );

        insert remuneracaoProposta;

        FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta = new FavorecidoRemuneracaoProposta__c(
            Conta__c = conta.Id,           
            CorretorLider__c = true,
            Papel__c = 'Corretor',
            Participacao__c = 10.00,
            RemuneracaoProposta__c = remuneracaoProposta.Id,
            Susep__c = 'REN01J',
            SusepEmissao__c = 'REN01J',
            SusepOficialCorretor__c = '123',
            SusepOrcamento__c = 'REN01J',
            AntecipacaoComissao__c = true,
            DadosCorretor__c = dadosCorretor.Id
        );

       insert favorecidoRemuneracaoProposta;
        //II-208 - FIM
        //FNPVVEP-22 INICIO
        Contract contrato = new Contract(
            Name = 'teste',
            AccountId = conta.Id,
            Produto__c = produtoComercial.Id,
            CodigoRamo__c = '1369',
            Proposta__c = proposta.Id,
            NumeroProposta__c = '6767'
        );
        insert contrato;
        //FNPVVEP-22 FIM
    }

    
    @IsTest
    static void valida_parametros(){
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueof('{\"canal\":\"Canal Distribuição Teste 001\"}');
        RestContext.request = req;
        
        Test.startTest();
            ConsultaPropostaADMREST.Response result = ConsultaPropostaADMREST.consultar();
        	System.debug(JSON.serialize(result));
        Test.stopTest();
    }    

    @IsTest
    static void busca_proposta(){
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueof('{\"canal\":\"Canal Distribuição Teste 001\", \"idCanal\": \"001\"}');
        RestContext.request = req;

        Test.startTest();
            ConsultaPropostaADMREST.Response result = ConsultaPropostaADMREST.consultar();
            System.debug('resposta: ' + JSON.serialize(result));
        Test.stopTest();
    }
    //PLV-4197 Inicio
	@IsTest
    static void busca_proposta2(){
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueof('{\"quantidadeDeMeses\":\"2\", \"cpfContratante\": \"00000000787\"}');
        RestContext.request = req;

        Test.startTest();
            ConsultaPropostaADMREST.Response result = ConsultaPropostaADMREST.consultar();
            System.debug('resposta: ' + JSON.serialize(result));
        Test.stopTest();
    }
    @IsTest
    static void busca_proposta3(){
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueof('{\"origem\":\"18\", \"proposta\": \"00027223\"}');
        RestContext.request = req;

        Test.startTest();
            ConsultaPropostaADMREST.Response result = ConsultaPropostaADMREST.consultar();
            System.debug('resposta: ' + JSON.serialize(result));
        Test.stopTest();
    }
	//PLV-4197 Fim

    //II-32 INICIO
    @IsTest
    static void consultaPendenciaTest() {
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf('{"canal":"Canal Distribuição Teste 001", "idCanal": "001", "pendencia": "true", "dataInicio": "2024-04-24", "dataFinal": "2024-06-24", "motivoPendencia": "Pendência Teste"}');
        RestContext.request = req;
        Test.startTest();
        ConsultaPropostaADMREST.Response result = ConsultaPropostaADMREST.consultar();
        System.debug('resposta: ' + JSON.serialize(result));
        Test.stopTest();
    }

    //II-208 - INICIO
    @IsTest
    static void consultaPendenciaFalse() {
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf('{"canal":"Canal Distribuição Teste 001", "idCanal": "001", "pendencia": "false", "dataInicio": "01-01-2023", "dataFinal": "30-06-2023", "motivoPendencia": "Pendência Teste", "quantidadeDeMeses": "6", "nomeSegurado": "Francis Liu", "dataProposta": "08/08/2023", "codigoOferta":"VIDA_INDIVIDUAL", "cpfContratante":"518.179.180-87", "numeroProposta":"00051519"}'); //FNPVVEP-98 INICIO/FIM
        RestContext.request = req;

        Test.startTest();
        ConsultaPropostaADMREST.Response result = ConsultaPropostaADMREST.consultar();
        System.debug('resposta: ' + JSON.serialize(result));
        Test.stopTest();
    }

    @IsTest
    static void consultaPendenciaTrue() {
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf('{"canal":"Canal Distribuição Teste 001", "idCanal": "001", "pendencia": "true", "dataInicio": "01-01-2023", "dataFinal": "30-06-2023", "motivoPendencia": "Pendência Teste", "codigoOferta":"0000059694", "cpfContratante":"518.179.180-87", "numeroProposta":"00051519"}');
        RestContext.request = req;

        Test.startTest();
        ConsultaPropostaADMREST.Response result = ConsultaPropostaADMREST.consultar();
        System.debug('resposta: ' + JSON.serialize(result));
        Test.stopTest();
    }
    //II-208 - FIM

    @IsTest
    static void paramInsuficienteTest() {
        // Configuração do teste
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;

        // Teste do cenário em que os parâmetros são insuficientes
        Test.startTest();
        ConsultaPropostaADMREST.Response result = ConsultaPropostaADMREST.consultar();
        Test.stopTest();

        // Verifica se a mensagem de erro é definida corretamente
        System.assertEquals(-1, result.data.statusChamada);
    }
    //II-32 FIM

    //FNPVVEP-22 INICIO
    @IsTest
    static void busca_propostaContratada(){
        Contract contrato = [SELECT Id, NumeroProposta__c FROM Contract LIMIT 1];
        Quote proposta = [SELECT Id, Status, NumeroProposta__c FROM Quote LIMIT 1];
        proposta.Status = 'Contratada';
        update proposta;
        contrato.NumeroProposta__c = proposta.NumeroProposta__c;
        update contrato;
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueof('{\"canal\":\"Canal Distribuição Teste 001\", \"idCanal\": \"001\"}');
        RestContext.request = req;

        Test.startTest();
            ConsultaPropostaADMREST.Response result = ConsultaPropostaADMREST.consultar();
            System.debug('resposta: ' + JSON.serialize(result));
        Test.stopTest();
    }
    //FNPVVEP-22 FIM

    //FNPVVEP-98 INICIO
    @IsTest
    static void consultaPendenciaTEST1() {
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf('{"canal":"Canal Distribuição Teste 001", "idCanal": "001", "pendencia": "true", "dataInicio": "01-01-2023", "dataFinal": "30-06-2023", "motivoPendencia": "Pendência Teste", "codigoOferta":"VIDA_INDIVIDUAL", "cpfContratante":"518.179.180-87", "numeroProposta":"00051519"}');
        RestContext.request = req;

        Test.startTest();
        ConsultaPropostaADMREST.Response result = ConsultaPropostaADMREST.consultar();
        System.debug('resposta: ' + JSON.serialize(result));
        Test.stopTest();
    }
    //FNPVVEP-98 FIM
}