// PLV-2312-28 INICIO
@isTest
public class BotaoCancelarContratoControllerTest {
    @testSetup 
    static void setup(){
        TestDataFactory.gerarDadosSetup();

        // PLV-4606 - Inicio
        Map<String,List<SObject>> mapListObject = TestDataFactory.gerarContrato(true);
        Product2 produto = (Product2) mapListObject.get('Product2')[0];
        produto.Segmento__c = 'Individual';
        update produto;
        // PLV-4606 - Fim
    }
    
    @isTest
    static void testValidarBotaoCancelarContratoController(){
        
        Contract contrato = [SELECT Id From Contract Limit 1];
        
        
        ServiceTO.DetalheOrcamentoCancelamentoTO orcamento = new ServiceTO.DetalheOrcamentoCancelamentoTO();
        orcamento.numeroOrcamento = '05038384';
        ServiceTO.OrcamentoCancelamentoTO orcamentos = new ServiceTO.OrcamentoCancelamentoTO();
        orcamentos.orcamento = orcamento;
        List<ServiceTO.OrcamentoCancelamentoTO> listorcamentos = new List<ServiceTO.OrcamentoCancelamentoTO>();
        listorcamentos.add(orcamentos);
        ServiceTO.OfertasCancelamentoTO oferta = new ServiceTO.OfertasCancelamentoTO();
        oferta.ofertas = listorcamentos;
        ServiceTO.DataCancelamentoTO retornoCalculo = new ServiceTO.DataCancelamentoTO();
        retornoCalculo.data = oferta;
        
        String payloadReturn = JSON.serialize(retornoCalculo);
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payloadReturn, 200, 'OK'));
        
        BotaoCancelarContratoController.cancelarContratoSelecionado(contrato.Id, 'INA');
        
        Test.stopTest();
        
    }

    // PLV-4606 - Inicio - Comentada a função para a criação de uma nova com a mudança do payload
    //PLV-3872 - INICIO - Criação do metodo para cubrir os novos desenvolvimentos
    // PLV-4172 -INICIO
    // @isTest
    // static void testValidarChamadaProposta(){
        
    //     Integer entrada = 22412;
    //     Contract contrato = null;
    //     try{
    //         contrato = [SELECT Id From Contract Limit 1];
    //     }catch(Exception e){
            
    //     }
    //     //PLV-4678 - Inicio
    //     Account contaTeste = TestDataFactory.gerarConta();   
        
    //     TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao('COR', 100, 200, null);
    //     tipoRemuneracao.Name ='AGENCIAMENTO';
    //     update tipoRemuneracao;
    //     TipoRemuneracao__c tipoRemuneracao2 = TestDataFactory.gerarTipoRemuneracao('COR', 100, 200, null);
    //     tipoRemuneracao.Name ='CORRETAGEM';
    //     update tipoRemuneracao2;
        
    //     RemuneracaoContrato__c remuneracaoContrato = TestDataFactory.gerarRemuneracaoContrato(contrato, tipoRemuneracao);
    //     RemuneracaoContrato__c remuneracaoContrato2 = TestDataFactory.gerarRemuneracaoContrato(contrato, tipoRemuneracao2);
    //     DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);
        
    //     FavorecidoRemuneracaoContrato__c favorecidoRemuneracaoContrato = new FavorecidoRemuneracaoContrato__c();
    //     favorecidoRemuneracaoContrato.Conta__c = contaTeste.Id;
    //     favorecidoRemuneracaoContrato.CorretorLider__c = TRUE;
    //     favorecidoRemuneracaoContrato.RemuneracaoContrato__c = remuneracaoContrato.Id;
    //     favorecidoRemuneracaoContrato.Susep__c ='p5005j';
    //     favorecidoRemuneracaoContrato.SusepEmissao__c ='p5005j';
    //     favorecidoRemuneracaoContrato.SusepOrcamento__c='p5005j';
    //     favorecidoRemuneracaoContrato.DadosCorretor__c = dadosCorretor.Id;
    //     favorecidoRemuneracaoContrato.Papel__c ='Corretor';
    //     favorecidoRemuneracaoContrato.Participacao__c =100;
    //     insert favorecidoRemuneracaoContrato;
        
    //     FavorecidoRemuneracaoContrato__c favorecidoRemuneracaoContrato2 = new FavorecidoRemuneracaoContrato__c();
    //     favorecidoRemuneracaoContrato2.Conta__c = contaTeste.Id;
    //     favorecidoRemuneracaoContrato2.CorretorLider__c = TRUE;
    //     favorecidoRemuneracaoContrato2.RemuneracaoContrato__c = remuneracaoContrato2.Id;
    //     favorecidoRemuneracaoContrato2.Susep__c ='p5005j';
    //     favorecidoRemuneracaoContrato2.SusepEmissao__c ='p5005j';
    //     favorecidoRemuneracaoContrato2.SusepOrcamento__c='p5005j';
    //     favorecidoRemuneracaoContrato2.DadosCorretor__c = dadosCorretor.Id;
    //     favorecidoRemuneracaoContrato2.Papel__c ='Corretor';
    //     favorecidoRemuneracaoContrato2.Participacao__c =100;
    //     insert favorecidoRemuneracaoContrato2;
    //     //PLV-4678 - Fim
    //     System.debug('vaeaauhusdh9ahs == > ' + contrato.Id);
    //     Date data = Date.today();
        
    //     String saida = '{"data":[{"proposta":{"vigenciaInicial":"2020-08-01","vigenciaFinal":"2020-12-20","tipoSeguro":"CAN","sucursal":1,"status":"Disponível para contratação","ramoSeguro":1369,"qtdDiasVigencia":141,"origem":18,"numeroOrcamento":22412,"numero":22412,"meioComercializacao":"CO2","empresa":1,"dataCalculo":"2020-07-01","contratantes":[],"codigoEmpresa":0,"canalDistribuicao":"COR","apolice":5260},"devolutivas":[{"tipoRegistro":1,"origem":"INT","numeroCampo":0,"descricao":"EMISSÃO: - registro inserido/atualizado com sucesso.","codigo":0}]}],"meta":{"dataExecucao":"2020-07-01T18:24:54.289Z","mensagem":"OK","servico":"GeracaoProposta","statusHttp":200}}';
    //     String retorno = '';
        
    //     Test.startTest();
        
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(saida, 200, 'OK'));
        
        
    //     try{
    //         retorno = BotaoCancelarContratoController.gerarPropostaEndosso(entrada, contrato.Id, data);
    //     }catch(Exception e){
    //         System.debug('exception do teste ==> ' + e + ' Linha = ' + e.getLineNumber()); //PLV-4678 Inicio/Fim
    //     }
        
        
    //     Test.stopTest();
    // }
    // PLV-4172 -FIM
    //PLV-3872 - FIM
    // PLV-4606 - Fim
    
    //PLV-4270 - INÍCIO
    //PLV-4997 - INICIO
    // @isTest
    // static void outrosTestes() {
    //     String profileName = BotaoCancelarContratoController.obterPerfil();
    //     System.debug( 'profileName: ' + profileName );
        
    //     String retorno = '';
        
    //     Contract contrato = [ SELECT Id From Contract Limit 1 ];
        
    //     try{
    //         retorno = BotaoCancelarContratoController.gerarOrcamentoEndosso( contrato.Id, '', System.today() );
    //     } catch( Exception e ) {
    //         System.debug( 'ERRO:' + e.getLineNumber() + ': ' + e.getMessage() );
    //     }
        
    //     contrato.Status = 'Cancelado';
    //     update contrato;
    //     try{
    //         retorno = BotaoCancelarContratoController.gerarOrcamentoEndosso( contrato.Id, '', System.today() );
    //     } catch( Exception e ) {
    //         System.debug( 'ERRO:' + e.getLineNumber() + ': ' + e.getMessage() );
    //     }

    //     // PLV-4606 - Inicio
    //     contrato.Status = 'Emitido';
    //     update contrato;
    //     try{
    //         retorno = BotaoCancelarContratoController.gerarOrcamentoEndosso( contrato.Id, '', System.today() );
    //     } catch( Exception e ) {
    //         System.debug( 'ERRO:' + e.getLineNumber() + ': ' + e.getMessage() );
    //     }
    //     // PLV-4606 - Fim
    // }
    //PLV-4997 - FIM
	//PLV-4270 - FIM
	
    // PLV-4606 - Inicio  - Comentada a função para a criação de uma nova com a mudança do payload
	//PLV-4678 - Inicio
	// @isTest
	// static void testValidarChamadaPropostaOcorrenciaVigencia(){
        
    //     Integer entrada = 22412;
    //     Contract contrato = null;
    //     try{
    //         contrato = [SELECT Id From Contract Limit 1];
    //     }catch(Exception e){
            
    //     }
    //     //PLV-4678 - Inicio
    //     Account contaTeste = TestDataFactory.gerarConta();   
        
    //     TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao('COR', 100, 200, null);
    //     tipoRemuneracao.Name ='AGENCIAMENTO';
    //     update tipoRemuneracao;
    //     TipoRemuneracao__c tipoRemuneracao2 = TestDataFactory.gerarTipoRemuneracao('COR', 100, 200, null);
    //     tipoRemuneracao.Name ='CORRETAGEM';
    //     update tipoRemuneracao2;
        
    //     RemuneracaoContrato__c remuneracaoContrato = TestDataFactory.gerarRemuneracaoContrato(contrato, tipoRemuneracao);
    //     RemuneracaoContrato__c remuneracaoContrato2 = TestDataFactory.gerarRemuneracaoContrato(contrato, tipoRemuneracao2);
    //     DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);
        
    //     FavorecidoRemuneracaoContrato__c favorecidoRemuneracaoContrato = new FavorecidoRemuneracaoContrato__c();
    //     favorecidoRemuneracaoContrato.Conta__c = contaTeste.Id;
    //     favorecidoRemuneracaoContrato.CorretorLider__c = TRUE;
    //     favorecidoRemuneracaoContrato.RemuneracaoContrato__c = remuneracaoContrato.Id;
    //     favorecidoRemuneracaoContrato.Susep__c ='p5005j';
    //     favorecidoRemuneracaoContrato.SusepEmissao__c ='p5005j';
    //     favorecidoRemuneracaoContrato.SusepOrcamento__c='p5005j';
    //     favorecidoRemuneracaoContrato.DadosCorretor__c = dadosCorretor.Id;
    //     favorecidoRemuneracaoContrato.Papel__c ='Corretor';
    //     favorecidoRemuneracaoContrato.Participacao__c =100;
    //     insert favorecidoRemuneracaoContrato;
        
    //     FavorecidoRemuneracaoContrato__c favorecidoRemuneracaoContrato2 = new FavorecidoRemuneracaoContrato__c();
    //     favorecidoRemuneracaoContrato2.Conta__c = contaTeste.Id;
    //     favorecidoRemuneracaoContrato2.CorretorLider__c = TRUE;
    //     favorecidoRemuneracaoContrato2.RemuneracaoContrato__c = remuneracaoContrato2.Id;
    //     favorecidoRemuneracaoContrato2.Susep__c ='p5005j';
    //     favorecidoRemuneracaoContrato2.SusepEmissao__c ='p5005j';
    //     favorecidoRemuneracaoContrato2.SusepOrcamento__c='p5005j';
    //     favorecidoRemuneracaoContrato2.DadosCorretor__c = dadosCorretor.Id;
    //     favorecidoRemuneracaoContrato2.Papel__c ='Corretor';
    //     favorecidoRemuneracaoContrato2.Participacao__c =100;
    //     insert favorecidoRemuneracaoContrato2;
    //     //PLV-4678 - Fim
    //     System.debug('vaeaauhusdh9ahs == > ' + contrato.Id);
    //     Date data = Date.today();
        
    //     String saida = '{"data":[{"proposta":{"vigenciaInicial":"2020-08-01","vigenciaFinal":"2020-12-20","tipoSeguro":"CAN","sucursal":1,"status":"Disponível para contratação","ramoSeguro":1369,"qtdDiasVigencia":141,"origem":18,"numeroOrcamento":22412,"numero":22412,"meioComercializacao":"CO2","empresa":1,"dataCalculo":"2020-07-01","contratantes":[],"codigoEmpresa":0,"canalDistribuicao":"COR","apolice":5260},"devolutivas":[{"tipoRegistro":1,"origem":"INT","numeroCampo":0,"descricao":"EMISSÃO: - registro inserido/atualizado com sucesso.","codigo":0}]}],"meta":{"dataExecucao":"2020-07-01T18:24:54.289Z","mensagem":"OK","servico":"GeracaoProposta","statusHttp":200}}';
    //     String retorno = '';
        
    //     Test.startTest();
        
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(saida, 200, 'OK'));
        
        
    //     try{
    //         retorno = BotaoCancelarContratoController.gerarPropostaEndosso(entrada, contrato.Id, data + 1);
    //     }catch(Exception e){
    //         System.debug('exception do teste ==> ' + e + ' Linha = ' + e.getLineNumber()); //PLV-4678 Inicio/Fim
    //     }
        
        
    //     Test.stopTest();
    // }
	//PLV-4678 - Fim
    // PLV-4606 - Fim



    // PLV-4606 - Inicio - Nova função de teste para novo Payload de cancelamento (VI e Viagem)
    @isTest
    static void TestCancelamentoVidaIndividual() {
        Contract contrato = null;
        Integer orcamento = null;
        
        Test.startTest();

        try {
            contrato = [SELECT Id, Proposta__r.Opportunity.Numero__c, Produto__r.Id, Produto__r.Segmento__c, Account.Id From Contract Limit 1];
            orcamento = Integer.ValueOf(contrato.Proposta__r.Opportunity.Numero__c);
            system.debug('teste contrato vi');
            system.debug(contrato);
            system.debug(contrato.Produto__r.Segmento__c);

            Account conta = [SELECT Id FROM Account WHERE Id = :contrato.Account.Id];
            Endereco__c enderecoComercial = TestDataFactory.gerarEndereco(conta);
            Endereco__c enderecoResidencial = TestDataFactory.gerarEndereco(conta);
            enderecoResidencial.TipoEndereco__c = 'Residencial';
            update enderecoResidencial;
          

            Date dataCancelamento = System.today();
            String retorno = BotaoCancelarContratoController.gerarPropostaEndosso(orcamento, contrato.Id, dataCancelamento);
            system.debug('teste retorno ' + retorno);
        }catch(Exception e){
            System.debug('exception do teste ==> ' + e + ' Linha = ' + e.getLineNumber()); //PLV-4678 Inicio/Fim
        }

        Test.stopTest();


    }

    @isTest
    static void TestCancelamentoViagem() {
        Contract contrato = null;
        Integer orcamento = null;
        
        Test.startTest();

        try {
            contrato = [SELECT Id, Proposta__r.Opportunity.Numero__c, Produto__r.Id, Produto__r.Segmento__c, Account.Id FROM Contract LIMIT 1];
            orcamento = Integer.ValueOf(contrato.Proposta__r.Opportunity.Numero__c);
            system.debug('teste contrato viagem');
            system.debug(contrato);
            system.debug(contrato.Produto__r.Segmento__c);
            Product2 produto = [SELECT Id, Segmento__c FROM Product2 WHERE Id = :contrato.Produto__r.Id];
            produto.Segmento__c = 'Viagem';
            update produto;

            Account conta = [SELECT Id FROM Account WHERE Id = :contrato.Account.Id];
            Endereco__c enderecoComercial = TestDataFactory.gerarEndereco(conta);
            Endereco__c enderecoResidencial = TestDataFactory.gerarEndereco(conta);
            enderecoResidencial.TipoEndereco__c = 'Residencial';
            update enderecoResidencial;
          

            Date dataCancelamento = System.today();
            String retorno = BotaoCancelarContratoController.gerarPropostaEndosso(orcamento, contrato.Id, dataCancelamento);
            system.debug('teste retorno ' + retorno);
        }catch(Exception e){
            System.debug('exception do teste ==> ' + e + ' Linha = ' + e.getLineNumber()); //PLV-4678 Inicio/Fim
        }

        Test.stopTest();
    }

    @isTest
    static void TestCancelarContratoSelecionado() {
        Contract contrato = null;
        Integer orcamento = null;
        
        Test.startTest();

        try {
            contrato = [SELECT Id FROM Contract LIMIT 1];
            
            String retorno = BotaoCancelarContratoController.cancelarContratoSelecionado(contrato.Id, 'INA');
            system.debug('teste retorno ' + retorno);
        }catch(Exception e){
            System.debug('exception do teste ==> ' + e + ' Linha = ' + e.getLineNumber()); //PLV-4678 Inicio/Fim
        }

        Test.stopTest();
    }
    // PLV-4606 - Fim

    @isTest
    static void gerarOrcamentoEndossoTest(){

        String expectedReturn = '{"data":{"ofertas":[{"orcamento":{"valorTotalPremio":"","tipoSeguro":"CAN","status":"Disponível para contratação","numeroOrcamento":"30339"}}]}}';
        Contract contrato = [SELECT Id, Status FROM Contract LIMIT 1];
        contrato.Status = 'Emitido';
        update contrato;

        Test.startTest();
        String actualReturn = BotaoCancelarContratoController.gerarOrcamentoEndosso(contrato.Id, 'INA', Date.today().addDays(-5));
        Test.stopTest();

        System.assertEquals(expectedReturn, actualReturn);
    }

    @isTest
    static void gerarPremioRecuperAGETest(){

        Account conta = (Account)new AccountFactory.PessoaFisica().createRecord();
        
        Contract contrato = [SELECT Id, Status FROM Contract LIMIT 1];
        ContratanteContrato__c contratanteContrato = new ContratanteContrato__c(Contrato__c = contrato.Id, Conta__c = conta.Id, Tipo__c = 'Principal'); 

        TipoRemuneracao__c tipoRemuneracao = new TipoRemuneracao__c();
		tipoRemuneracao.Name = 'AGENCIAMENTO';
		tipoRemuneracao.Descricao__c = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit.';
		tipoRemuneracao.ModeloRecuperacao__c = 'Integral';
		insert tipoRemuneracao;

        RemuneracaoContrato__c remuneracaoContrato = TestDataFactory.gerarRemuneracaoContrato(contrato, tipoRemuneracao);
        
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(conta);

        FavorecidoRemuneracaoContrato__c favorecidoRemuneracaoContrato = new FavorecidoRemuneracaoContrato__c(
            Conta__c = conta.Id,
            CorretorLider__c = TRUE,
            RemuneracaoContrato__c = remuneracaoContrato.Id,
            Susep__c = 'p5005j',
            SusepEmissao__c = 'p5005j',
            SusepOrcamento__c= 'p5005j',
            DadosCorretor__c = dadosCorretor.Id,
            Papel__c = 'Corretor',
            Participacao__c = 100
        );
        
        insert favorecidoRemuneracaoContrato;

        Test.startTest();
        BotaoCancelarContratoController.gerarPremioRecuperaAGE(contrato.Id, Date.today().addDays(-5));
        Test.stopTest();


    }

    @isTest
    static void testObterPerfil() {
        Profile perfilTeste = [SELECT Id, Name FROM Profile WHERE Name = 'Salesforce API Only System Integrations'];
        
        User usuarioTeste = new User(
            ProfileId = perfilTeste.Id,
            Username = 'userlink@example.com',
            Email = 'userlink@example.com',
            LastName = 'userlink',
            FirstName = 'userlink',
            Alias = 'userlink',
            TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'pt_BR',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR'
        );

        insert usuarioTeste;
        
        Test.startTest();
        System.runAs(usuarioTeste) {
            String perfilObtido = BotaoCancelarContratoController.obterPerfil();
            System.assertEquals('Salesforce API Only System Integrations', perfilObtido, 'O perfil obtido não corresponde ao perfil esperado');
        }
        Test.stopTest();
    }

    //FCVEP-29 - INICIO
    @IsTest
    static void testarValidDtIniVig(){
        
        Test.startTest();

        Contract ctr = [SELECT Id, StartDate, VigenciaFinal__c, DataEmissao__c FROM Contract LIMIT 1];

        ctr.StartDate = System.today();
        ctr.VigenciaFinal__c = System.today().addDays(1);
        
        update ctr;

        ContratanteContrato__c cttCtr = new ContratanteContrato__c(
            Contrato__c = ctr.Id
        );

        insert cttCtr;

        Date dtCancVig = BotaoCancelarContratoController.validarDataInicialVigencia(ctr.Id, System.today());
        System.assertEquals(dtCancVig, System.today(), 'Data de cancelamento dentro da vigência.');
                
        Test.stopTest();        
    }

    @IsTest
    static void testarValidDtIniForaVig(){

        ParcelamentoContratoTO.DataTO parcelaInadimplente = new ParcelamentoContratoTO.DataTO();
        parcelaInadimplente.idfatura = 1;
        parcelaInadimplente.status = 'INADIMPLENTE';
        parcelaInadimplente.datavencimento = String.valueOf(System.today().addDays(1));
        
        Test.startTest();

        Contract ctr = [SELECT Id, StartDate, VigenciaFinal__c, DataEmissao__c FROM Contract LIMIT 1];

        ctr.StartDate = System.today().addYears(-1);
        ctr.VigenciaFinal__c = System.today().addYears(-1);
        ctr.DataEmissao__c = System.today().addDays(1);
        
        update ctr;

        ContratanteContrato__c cttCtr = new ContratanteContrato__c(
            Contrato__c = ctr.Id
        );

        insert cttCtr;

        Date dtVigIniParcInad = BotaoCancelarContratoController.validarDataInicialVigencia(ctr.Id, System.today().addDays(1));
        System.assertEquals(dtVigIniParcInad, Date.valueOf(parcelaInadimplente.datavencimento), 'Data de vencimento da parcela com status inadimplente');
                
        Test.stopTest();        
    }

    @IsTest
    static void testarValidDtIniVigExcp(){
        
        Test.startTest();

        Contract ctr = [SELECT Id, StartDate, VigenciaFinal__c FROM Contract LIMIT 1];

        ctr.StartDate = System.today().addYears(-1);
        ctr.VigenciaFinal__c = System.today().addYears(-1);
        
        update ctr;

        ContratanteContrato__c cttCtr = new ContratanteContrato__c(
            Contrato__c = ctr.Id
        );

        insert cttCtr;

        public_parcelacontrato__x pCtr = new public_parcelacontrato__x(
            idexterno__c = ctr.Id + '_' + cttCtr.Id,
            datavencimento__c = System.today().addDays(1),
            status__c = 'INADIMPLENTE'
        );

        Date dtVigIniParcInad = BotaoCancelarContratoController.validarDataInicialVigencia(null, System.today());
        System.assertEquals(dtVigIniParcInad, pCtr.datavencimento__c, 'Data de vencimento da parcela com status inadimplente');
                
        Test.stopTest();
        
    }

    @IsTest
    static void testRetonarDataParcInadim(){

        Date dataCancelamento = System.today();
        
        Test.startTest();
        
        ParcelamentoContratoTO parcCtrTO = new ParcelamentoContratoTO();
        parcCtrTO.data = new List<ParcelamentoContratoTO.DataTO>();
        ParcelamentoContratoTO.DataTO parcelaPendente = new ParcelamentoContratoTO.DataTO();
        parcelaPendente.status = 'PENDENTE';
        parcelaPendente.datavencimento = String.valueOf(System.today());
        
        ParcelamentoContratoTO.DataTO parcelaInadimplente = new ParcelamentoContratoTO.DataTO();
        parcelaInadimplente.status = 'INADIMPLENTE';
        parcelaInadimplente.datavencimento = String.valueOf(System.today().addDays(1));
        
        parcCtrTO.data.add(parcelaPendente);
        parcCtrTO.data.add(parcelaInadimplente);

        Date dataParcInad = BotaoCancelarContratoController.retonarDataParcInadim(parcCtrTO);

        Test.stopTest();
        
        System.assertNotEquals(dataCancelamento, dataParcInad, 'Data da parcela inadimplente.');
    }
    //FCVEP-29 - FIM
}
// PLV-2312-28 FIM