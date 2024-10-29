/**
 * @description       : 
 * @author            : giordano.menezes@globant.com
 * @group             : 
 * @last modified on  : 01-20-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class CriticaPropostaTest {
    
    @testSetup
    static void setup(){
        Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        produtoComercial.Status__c = 'Ativo';
        update produtoComercial;
        
        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        formaPagamento.Codigo__c = '62';
        update formaPagamento;
        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(conta).createRecord();
        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(conta).createRecord();
        Modalidade__c modalidade = (Modalidade__c) new ModalidadeFactory(ramoSeguro).createRecord();    
        Opportunity orcamento = (Opportunity) new OrcamentoFactory.VidaIndividual(produtoComercial, conta).createRecord();
        
        Quote proposta = (Quote) new PropostaFactory(produtoComercial, ramoSeguro, conta, dadosCorretor, orcamento, modalidade).getRecord();
        proposta.Parceiro__c = '';
        insert proposta;
        
        ContratanteProposta__c contratanteProposta = (ContratanteProposta__c) new ContratantePropostaFactory(proposta, formaPagamento).getRecord();
        contratanteProposta.Conta__c = conta.Id;
        insert contratanteProposta;
        
        CriticaProposta__c critDoc = (CriticaProposta__c) new CriticaPropostaFactory.Docusign(proposta).createRecord();
        
        //4591 - Inicio
        CriticaProposta__c critDoc2 = new CriticaProposta__c(
            // INICIO | PLV-4647-VI-Guilherme Brito
            Proposta__c = proposta.Id,
            MomentoAnalise__c = 'Palavra Final',
            Integracao__c = 'DOCUSIGN',
            Status__c = '',
            MensagemInterna__c = 'slaTeste1'
            //FIM| PLV-4647-VI-Guilherme Brito */
        );
        insert critDoc2;
        
        CriticaProposta__c critDoc3 = new CriticaProposta__c(
            // INICIO | PLV-4647-VI-Guilherme Brito
            Proposta__c = proposta.Id,
            MomentoAnalise__c = 'Palavra Final',
            Integracao__c = 'DOCUSIGN',
            Status__c = '', 
            MensagemInterna__c = 'slaTeste2'
            //FIM| PLV-4647-VI-Guilherme Brito */
        );
        insert critDoc3;
        
        CriticaProposta__c critDoc4 = new CriticaProposta__c(
            // INICIO | PLV-4647-VI-Guilherme Brito
            Proposta__c = proposta.Id,
            MomentoAnalise__c = 'Palavra Final',
            Integracao__c = 'DOCUSIGN',
            Status__c = '', 
            MensagemInterna__c = 'slaTeste3'
            //FIM| PLV-4647-VI-Guilherme Brito */
        );
        insert critDoc4;
        
        CriticaProposta__c critDoc5 = new CriticaProposta__c(
            // INICIO | PLV-4647-VI-Guilherme Brito
            Proposta__c = proposta.Id,
            MomentoAnalise__c = 'Recalculo',
            Integracao__c = 'DOCUSIGN',
            Status__c = 'Condicionada',
            MensagemInterna__c = 'slaTeste4'
            //FIM| PLV-4647-VI-Guilherme Brito */
        );
        insert critDoc5;
        //4591 - FIM
        //ANNVI-164 - INICIO
        CriticaProposta__c criticaProposta = new CriticaProposta__c(
            Proposta__c = proposta.Id,
            MomentoAnalise__c = 'Recalculo',
            Integracao__c = 'DOCUSIGN',
            Status__c = 'Liberado',
            Origem__c = 'Salesforce',
            MensagemInterna__c = 'slaTeste'
        );
        insert criticaProposta;
        //ANNVI-164 - FIM
    }

    //PLV-4872 INICIO
    //PLV-5187 - INICIO
    @isTest
    private static void test01() {
        Test.startTest();
        CriticaProposta__c critica = [SELECT Id, Name, Proposta__c, Proposta__r.Tipo__c, Proposta__r.PremioTotal__c FROM CriticaProposta__c LIMIT 1];
        critica.Status__c = 'Liberado';
        
        Quote proposta = [SELECT Id, NumeroPropostaUnico__c,
                          (
                              SELECT Id, QuantidadeParcelas__c, Tipo__c, PremioTotal__c, CartaoCredito__r.Ticket__c, CartaoCredito__r.VencimentoCriptografado__c,
                              Conta__r.RecordTypeId, Conta__r.CPF__c, Conta__r.Cnpj__c FROM Contratantesproposta__r
                          )
                          FROM Quote LIMIT 1];
        
        critica.Proposta__r = proposta;
        critica.DataInicioPendencia__c = System.today();
        critica.DataFimPendencia__c = System.today().addDays(3);
        critica.Data_inicio_resseguro__c = System.today().addDays(5);
        critica.Data_fim_resseguro__c = System.today().addDays(8);

        update critica;
        critica.Status__c = 'Pendente';
        critica.Setor__c = 'Aceitação';
        update critica;
        Test.stopTest();
    }
    //PLV-5187 - FIM
    @isTest
    private static void test02() {
        Test.startTest();
        List<CriticaProposta__c> criticas = [SELECT Id, Name, Proposta__c FROM CriticaProposta__c LIMIT 2];
        criticas[0].Status__c = 'Liberado';
        criticas[1].Status__c = 'Em aprovação';
        criticas[1].MomentoAnalise__c = 'Resseguro';
        update criticas;
        criticas[0].DataInicioPendencia__c = System.today().addDays(5);
        criticas[0].DataFimPendencia__c = System.today().addDays(7);
        criticas[0].Data_inicio_resseguro__c = System.today().addDays(10);
        criticas[0].Data_fim_resseguro__c = System.today().addDays(13);
        criticas[1].DataInicioPendencia__c = System.today().addDays(10);
        criticas[1].DataFimPendencia__c = System.today().addDays(13);
        criticas[1].Data_inicio_resseguro__c = System.today().addDays(5);
        criticas[1].Data_fim_resseguro__c = System.today().addDays(8);
        //update criticas;
        criticas[0].Status__c = 'Pendente';
        criticas[0].Setor__c = 'Emissão';
        criticas[1].Status__c = 'Cancelada';
        update criticas;
        Test.stopTest();
    }
    @isTest
    private static void test03() {
        Test.startTest();
        CriticaProposta__c critica = [SELECT Id, Name, Proposta__c FROM CriticaProposta__c LIMIT 1];
        critica.Status__c = 'Liberado';
        critica.MomentoAnalise__c = 'Palavra Final';
        
        Quote proposta = [SELECT Id, NumeroPropostaUnico__c,
                          (
                              SELECT Id, QuantidadeParcelas__c, PremioTotal__c, CartaoCredito__r.Ticket__c, CartaoCredito__r.VencimentoCriptografado__c,
                              Conta__r.RecordTypeId, Conta__r.CPF__c, Conta__r.Cnpj__c FROM Contratantesproposta__r
                          )
                          FROM Quote LIMIT 1];
        
        critica.Proposta__r = proposta;
        update critica;
        critica.Status__c = 'Pendente';
        critica.MomentoAnalise__c = 'Subscrição';
        critica.Acao__c = 'auto';
        critica.Setor__c = 'Emissão';
        update critica;
        Test.stopTest();
    }
    @isTest
    private static void test04() {
        Test.startTest();
        CriticaProposta__c critica = [SELECT Id, Name, Proposta__c FROM CriticaProposta__c LIMIT 1];
        critica.Status__c = 'Liberado';
        critica.MomentoAnalise__c = 'Palavra Final';
        
        Quote proposta = [SELECT Id, NumeroPropostaUnico__c,
                          (
                              SELECT Id, QuantidadeParcelas__c, PremioTotal__c, CartaoCredito__r.Ticket__c, CartaoCredito__r.VencimentoCriptografado__c,
                              Conta__r.RecordTypeId, Conta__r.CPF__c, Conta__r.Cnpj__c FROM Contratantesproposta__r
                          )
                          FROM Quote LIMIT 1];
        
        critica.Proposta__r = proposta;
        update critica;
        critica.Status__c = 'Pendente';
        critica.MomentoAnalise__c = 'Subscrição';
        critica.Acao__c = 'video';
        critica.Setor__c = 'Emissão';
        update critica;
        Test.stopTest();
    }
    @isTest
    private static void test05() {
        Test.startTest();
        CriticaProposta__c critica = [SELECT Id, Name, Proposta__c FROM CriticaProposta__c LIMIT 1];
        critica.Status__c = 'Liberado';
        
        Quote proposta = [SELECT Id, NumeroPropostaUnico__c,
                          (
                              SELECT Id, QuantidadeParcelas__c, PremioTotal__c, CartaoCredito__r.Ticket__c, CartaoCredito__r.VencimentoCriptografado__c,
                              Conta__r.RecordTypeId, Conta__r.CPF__c, Conta__r.Cnpj__c FROM Contratantesproposta__r
                          )
                          FROM Quote LIMIT 1];
        
        critica.Proposta__r = proposta;
        update critica;
        critica.MotivoPendencia__c = 'Pendência enviada - Exclusao de cobertura'; //II-32 INICIO FIM
        critica.Status__c = 'Pendenciado';
        // LECVPV-140-FIX04 INICIO
        critica.DataInicioPendencia__c = System.today();
        critica.DataFimPendencia__c = System.today().addDays(10);  
        // LECVPV-140-FIX04 FIM
        critica.Setor__c = 'Emissão';
        update critica;
        Test.stopTest();
    }
    @isTest
    private static void test06() {
        Test.startTest();
        CriticaProposta__c critica = [SELECT Id, Name, Proposta__c FROM CriticaProposta__c LIMIT 1];
        System.debug('critica: ' + critica);
        critica.Status__c = 'Liberado';
        update critica;
        critica.Status__c = 'Pendente';
        critica.Acao__c = 'Auto';
        critica.Integracao__c = 'SAMPLE';
        critica.MomentoAnalise__c = 'Subscrição';
        update critica;
        Test.stopTest();
    }
    //PLV-4872 FIM
    //PLV-4494 INICIO
    /*
@isTest
public static void criaCriticaPropostaFilas(){
CriticaProposta__c crit = (CriticaProposta__c) new CriticaPropostaFactory.FilaCoordenador().createRecord();
CriticaProposta__c crit2 = (CriticaProposta__c) new CriticaPropostaFactory.FilaTecnica().createRecord();
CriticaProposta__c crit3 = (CriticaProposta__c) new CriticaPropostaFactory.FilaMedica().createRecord();
}*/
    //PLV-4494 FIM
    
    @isTest
    public static void criaCriticaPropostaLiberacao(){
        Test.startTest();
        CriticaProposta__c critica = [SELECT Id, Name, Proposta__c FROM CriticaProposta__c LIMIT 1];
        critica.Status__c = 'Liberado';
        
        Quote proposta = [SELECT Id, NumeroPropostaUnico__c, Modalidade__c, Modalidade__r.Codigo__c, RamoSeguro__c, RamoSeguro__r.Codigo__c,Produto__r.CodigoPrecificaProduto__c, Produto__r.Empresa__r.CodigoEmpresa__c, //PLV-5493 - INICIO/FIM //PLV-4992 FIX 1 -FIM //TKCL-473 INICIO/FIM
                          (
                              SELECT Id, QuantidadeParcelas__c, PremioTotal__c, Valor_PrimeiraParcela__c, Valor_DemaisParcelas__c, Recorrencia__c, CartaoCredito__r.Ticket__c, CartaoCredito__r.VencimentoCriptografado__c, CartaoCredito__r.NomeTitular__c, //PLV-4992 FIX 1 - INÍCIO/FIM //TKCL-473 INICIO/FIM
                              Conta__r.RecordTypeId, Conta__r.CPF__c, Conta__r.Cnpj__c, FormaPagamento__r.Codigo__c FROM Contratantesproposta__r //ANNVI-48 - INICIO/FIM
                          )
                          FROM Quote LIMIT 1];
        
        critica.Proposta__r = proposta;
        
        // TKCL-473 INICIO
        ServiceTO.CobrancaCartaoOfflineTO autorizacao = new ServiceTO.CobrancaCartaoOfflineTO();
        autorizacao.dtoCobranca(critica);
         // TKCL-473 FIM
        Test.setMock(HttpCalloutMock.class, new CriticaPropostaMock.LiberacaoSucesso(autorizacao.numeroReferencia));
        
        update critica;
        Test.stopTest();
	}
    
    //PLV-4564-VI - INICIO - PEDRO AUGUSTO BRAZ
	@isTest
    public static void criaRecalculoonCondicionada(){
        Test.startTest();
		delete [SELECT Id, Name, Proposta__c FROM CriticaProposta__c WHERE MomentoAnalise__c='Recalculo'];
		
		Quote proposta = [SELECT Id, NumeroPropostaUnico__c FROM Quote LIMIT 1];

		CriticaProposta__c critica = new CriticaProposta__c(
            Proposta__c = proposta.Id,
            MomentoAnalise__c = 'Palavra Final',
            Integracao__c = 'DOCUSIGN',
            Status__c = ''
        );
		insert critica;
		
		critica.Status__c='Condicionada';
		update critica;
        
        
        Test.stopTest();
	}
	//PLV-4564-VI - FIM - PEDRO AUGUSTO BRAZ
    
    @isTest
    public static void testaAutorizaCartaoLiberarCritica(){
        Test.startTest();
        CriticaProposta__c critica = [SELECT Id, Name, Proposta__c FROM CriticaProposta__c LIMIT 1];
        
        Quote proposta = [SELECT Id, NumeroPropostaUnico__c, Modalidade__c, Modalidade__r.Codigo__c, RamoSeguro__c, RamoSeguro__r.Codigo__c,Produto__r.CodigoPrecificaProduto__c, Produto__r.Empresa__r.CodigoEmpresa__c,  //PLV-5493 - INICIO/FIM //PLV-4992 FIX 1 -FIM  //TKCL-473 INICIO/FIM
                          (
                              SELECT Id, QuantidadeParcelas__c, PremioTotal__c, Valor_PrimeiraParcela__c, Valor_DemaisParcelas__c, Recorrencia__c, CartaoCredito__r.Ticket__c, CartaoCredito__r.VencimentoCriptografado__c, CartaoCredito__r.NomeTitular__c, //PLV-4992 FIX 1 - INÍCIO/FIM //TKCL-473 INICIO/FIM
                              Conta__r.RecordTypeId, Conta__r.CPF__c, Conta__r.Cnpj__c, FormaPagamento__r.Codigo__c FROM Contratantesproposta__r //ANNVI-48 - INICIO/FIM
                          )
                          FROM Quote LIMIT 1];
        
        critica.Proposta__r = proposta;
        
        //Caso sucesso
         // TKCL-473 INICIO
         ServiceTO.CobrancaCartaoOfflineTO autorizacao = new ServiceTO.CobrancaCartaoOfflineTO();
         autorizacao.dtoCobranca(critica);
          // TKCL-473 FIM
        CriticaPropostaAutorizacaoCartao.Response resp = testaPost(2, autorizacao.numeroReferencia, 'APROVADO');
        System.assertEquals(true, resp.sucesso);
        //PLV-4944 - INICIO
        //List<Quote> propostas = [SELECT Id, Status FROM Quote WHERE Status = 'Disponível para contratação'];
        //System.assert(propostas.size() == 1);
        //PLV-4944 - FIM
        
        List<CriticaProposta__c> criticas = [SELECT Id, Name, Proposta__c FROM CriticaProposta__c WHERE Status__c = 'Liberado'];
        System.assert(criticas.size() == 2); //ANNVI-164 - INICIO/FIM
        
        //Caso critica ja liberada
         // TKCL-473 INICIO
         ServiceTO.CobrancaCartaoOfflineTO autorizacao2 = new ServiceTO.CobrancaCartaoOfflineTO();
         autorizacao2.dtoCobranca(critica);
          // TKCL-473 FIM
        CriticaPropostaAutorizacaoCartao.Response resp2 = testaPost(2, autorizacao.numeroReferencia, 'APROVADO');
        System.assertEquals(false, resp2.sucesso);
        //PLV-4944 - INICIO
        //List<Quote> propostas2 = [SELECT Id, Status FROM Quote WHERE Status = 'Disponível para contratação'];
        //System.assert(propostas2.size() == 1);
        //PLV-4944 - FIM

        
        List<CriticaProposta__c> criticas2 = [SELECT Id, Name, Proposta__c FROM CriticaProposta__c WHERE Status__c = 'Liberado'];
        System.assert(criticas.size() == 2); //ANNVI-164 - INICIO/FIM
        
        Test.stopTest();
    }
    
    @isTest
    public static void testaAutorizaCartaoRecusarCritica(){
        Test.startTest();
        CriticaProposta__c critica = [SELECT Id, Name, Proposta__c FROM CriticaProposta__c LIMIT 1];
        
        Quote proposta = [SELECT Id, NumeroPropostaUnico__c, Modalidade__c, Modalidade__r.Codigo__c, RamoSeguro__c, RamoSeguro__r.Codigo__c,Produto__r.CodigoPrecificaProduto__c, Produto__r.Empresa__r.CodigoEmpresa__c, //PLV-5493 - INICIO/FIM //PLV-4992 FIX 1 -FIM // TKCL-473 INICIO/FIM
                          (
                              SELECT Id, QuantidadeParcelas__c, PremioTotal__c, Valor_PrimeiraParcela__c, Valor_DemaisParcelas__c, Recorrencia__c,  // TKCL-473 INICIO/FIM
                              CartaoCredito__r.Ticket__c, CartaoCredito__r.VencimentoCriptografado__c, CartaoCredito__r.NomeTitular__c, //PLV-4992 FIX 1 - INÍCIO/FIM
                              Conta__r.RecordTypeId, Conta__r.CPF__c, Conta__r.Cnpj__c, FormaPagamento__r.Codigo__c FROM Contratantesproposta__r //ANNVI-48 - INICIO/FIM
                          )
                          FROM Quote LIMIT 1];
        
        critica.Proposta__r = proposta;
        
         // TKCL-473 INICIO
         ServiceTO.CobrancaCartaoOfflineTO autorizacao = new ServiceTO.CobrancaCartaoOfflineTO();
         autorizacao.dtoCobranca(critica);
          // TKCL-473 FIM
        
        CriticaPropostaAutorizacaoCartao.Response resp = testaPost(3, autorizacao.numeroReferencia, 'REJEITADO');
        System.assertEquals(false, resp.sucesso);
        
        List<Quote> propostas = [SELECT Id, Status FROM Quote WHERE Status = 'Disponível para contratação'];
        System.assert(propostas.size() == 0);
        
        List<CriticaProposta__c> criticas = [SELECT Id, Name, Proposta__c, Status__c FROM CriticaProposta__c WHERE Status__c = 'Recusado'];
        //System.assert(criticas.size() == 2);//PLV-4854-FIX1 - inicio/fim
        
        Test.stopTest();
    }
    
    private static CriticaPropostaAutorizacaoCartao.Response testaPost(Integer cod, String numRef, String mensagem){
        
        CriticaPropostaAutorizacaoCartao.Request criticaRequest = new CriticaPropostaAutorizacaoCartao.Request();
        CriticaPropostaAutorizacaoCartao.RequestStargate criticaStargate = new CriticaPropostaAutorizacaoCartao.RequestStargate();
        criticaStargate.codigo = String.valueOf(cod);
        criticaStargate.numeroReferencia = numRef;
        criticaStargate.codigoGateway = 0;
        criticaStargate.mensagemGateway = 'CAPTURED';
        criticaStargate.codigoAgrupamento = '2100001702';
        criticaStargate.mensagem = mensagem;

        criticaRequest.stargate = criticaStargate;
      //  CriticaPropostaAutorizacaoCartao.RequestGenerico reqGenerico = criticaRequest.obterRequestValido();
        
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(JSON.serialize(criticaRequest));
        System.debug('Body da request: ' + JSON.serialize(criticaRequest));
        RestContext.request = req;
        CriticaPropostaAutorizacaoCartao.Response resp = CriticaPropostaAutorizacaoCartao.processarPost();
        
        System.debug('Resposta >> ' + JSON.serialize(resp));
        return resp;
    }
    //4591 - INICIO
    @isTest
    public static void slaCriticaPendenteAceitacao(){
        /* INICIO | PLV-4647-VI-Guilherme Brito
        Test.startTest();
        CriticaProposta__c critica = [SELECT Id, Status__c, Setor__c, Proposta__c
        // Procedimento__c |INICIO/FIM | PLV-4647-VI-Guilherme Brito
                                      FROM CriticaProposta__c 
                                      // WHERE MensagemInterna__c = 'slaTeste1' INICIO/FIM | PLV-4647-VI-Guilherme Brito
                                      ];
        critica.Status__c = 'Pendente';
        critica.Setor__c = 'Aceitação';
        
        update critica;
        
        CriticaProposta__c criticaVerify = [SELECT Id, Status__c, DataInicioAnalise__c, Setor__c, Proposta__c 
                                            FROM CriticaProposta__c 
                                            WHERE id =: critica.Id];
        Test.stopTest();
        system.assert(criticaVerify.DataInicioAnalise__c != null);
        FIM| PLV-4647-VI-Guilherme Brito */
    }
    @isTest
    public static void slaCriticaPendenteEmissao(){
        /* INICIO | PLV-4647-VI-Guilherme Brito
        Test.startTest();
        CriticaProposta__c critica = [SELECT Id, Status__c, Setor__c, Proposta__c
        // , Procedimento__c |INICIO/FIM | PLV-4647-VI-Guilherme Brito
                                      FROM CriticaProposta__c 
                                      //WHERE MensagemInterna__c = 'slaTeste2' INICIO/FIM | PLV-4647-VI-Guilherme Brito
                                      ];
        critica.Status__c = 'Pendente';
        critica.Setor__c = 'Emissão';
        
        update critica;
        
        CriticaProposta__c criticaVerify = [SELECT Id, Status__c, DataInicioAnalise__c, Setor__c, Proposta__c 
                                            FROM CriticaProposta__c 
                                            WHERE id =: critica.Id];
        Test.stopTest();
        system.assert(criticaVerify.DataInicioAnalise__c != null);
        FIM| PLV-4647-VI-Guilherme Brito */
        
    }
    @isTest
    public static void slaCriticaPendenciadoEmissao(){
        /* INICIO | PLV-4647-VI-Guilherme Brito
        Test.startTest();
        CriticaProposta__c critica = [SELECT Id, Status__c, Setor__c, Proposta__c
        // , Procedimento__c |INICIO/FIM | PLV-4647-VI-Guilherme Brito
                                      FROM CriticaProposta__c 
                                      //WHERE MensagemInterna__c = 'slaTeste3' INICIO/FIM | PLV-4647-VI-Guilherme Brito
                                      ];
        
        critica.Status__c = 'Pendenciado';
        critica.Setor__c = 'Emissão';
        
        update critica;
        
        CriticaProposta__c criticaVerify = [SELECT Id, Status__c, DataInicioPendencia__c, Setor__c, Proposta__c 
                                            FROM CriticaProposta__c 
                                            WHERE id =: critica.Id];
        Test.stopTest();
        system.assert(criticaVerify.DataInicioPendencia__c != null);
        FIM| PLV-4647-VI-Guilherme Brito */
    }
    //4591 - FIM
    
    //PLV-4977 - INICIO
    @isTest
    public static void gravarSegmentoNaProposta_Emissao(){
        Quote proposta = [SELECT Id, Name FROM Quote LIMIT 1];
        CriticaProposta__c critica1 = new CriticaProposta__c(
            Proposta__c = proposta.Id,
            MomentoAnalise__c = 'Análise interna',
            Status__c = 'Não iniciada',
            Setor__c = 'Emissão'
        );
        CriticaProposta__c critica2 = new CriticaProposta__c(
            Proposta__c = proposta.Id,
            MomentoAnalise__c = 'Análise interna',
            Status__c = 'Não iniciada',
            Setor__c = 'Emissão'
        );
        List<CriticaProposta__c> lstCritica = new List<CriticaProposta__c>{critica1, critica2};
        Test.startTest();
		insert lstCritica;
        Test.stopTest();
        proposta = [SELECT Id, Name, isFullEmissao__c FROM Quote WHERE Id =: proposta.Id];
        System.assert(proposta.isFullEmissao__c == true);
    } 

    @isTest
    public static void gravarSegmentoNaProposta_Aceitacao(){
        Quote proposta = [SELECT Id, Name FROM Quote LIMIT 1];
        CriticaProposta__c critica1 = new CriticaProposta__c(
            Proposta__c = proposta.Id,
            MomentoAnalise__c = 'Análise interna',
            Status__c = 'Não iniciada',
            Setor__c = 'Emissão'
        );
        CriticaProposta__c critica2 = new CriticaProposta__c(
            Proposta__c = proposta.Id,
            MomentoAnalise__c = 'Análise interna',
            Status__c = 'Não iniciada',
            Setor__c = 'Aceitação'
        );
        List<CriticaProposta__c> lstCritica = new List<CriticaProposta__c>{critica1, critica2};
        Test.startTest();
		insert lstCritica;
        CriticaProposta__c critica3 = new CriticaProposta__c(
            Proposta__c = proposta.Id,
            MomentoAnalise__c = 'Análise interna',
            Status__c = 'Não iniciada',
            Setor__c = 'Emissão'
        );
        insert critica3;
        Test.stopTest();
        proposta = [SELECT Id, Name, isFullEmissao__c FROM Quote WHERE Id =: proposta.Id];
        System.assert(proposta.isFullEmissao__c == false);
    } 
    //PLV-4977 - FIM

    //PLV-5077 - INICIO
    @isTest
    public static void distribuicaoCriticasLiberado(){
        Quote proposta = [SELECT Id, Name FROM Quote LIMIT 1];
        CriticaProposta__c critica1 = new CriticaProposta__c(
            Proposta__c = proposta.Id,
            MomentoAnalise__c = 'Análise interna',
            Status__c = 'Não iniciada',
            Setor__c = 'Emissão'
        );
        CriticaProposta__c critica2 = new CriticaProposta__c(
            Proposta__c = proposta.Id,
            MomentoAnalise__c = 'Análise interna',
            Status__c = 'Não iniciada',
            Setor__c = 'Emissão'
        );
        CriticaProposta__c critica3 = new CriticaProposta__c(
            Proposta__c = proposta.Id,
            MomentoAnalise__c = 'Análise interna',
            Status__c = 'Pendente',
            Setor__c = 'Aceitação'
        );
        CriticaProposta__c critica4 = new CriticaProposta__c(
            Proposta__c = proposta.Id,
            MomentoAnalise__c = 'Análise interna',
            Status__c = 'Pendente',
            Setor__c = 'Aceitação'
        );
        List<CriticaProposta__c> lstCritica = new List<CriticaProposta__c>{critica1, critica2, critica3, critica4};
        insert lstCritica;
        critica3.Status__c = 'Liberado';
        update critica3;
        Test.startTest();
		critica4.Status__c = 'Liberado';
        update critica4;
        Test.stopTest();
        proposta = [SELECT Id, Name, isFullEmissao__c FROM Quote WHERE Id =: proposta.Id];
        System.assert(proposta.isFullEmissao__c == true);
    } 
    //PLV-5311 - FIX - INICIO
    /*@isTest
    public static void distribuicaoCriticasCondicionado(){
        Quote proposta = [SELECT Id, Name FROM Quote LIMIT 1];
        CriticaProposta__c critica1 = new CriticaProposta__c(
            Proposta__c = proposta.Id,
            MomentoAnalise__c = 'Análise interna',
            Status__c = 'Não iniciada',
            Setor__c = 'Emissão'
        );
        CriticaProposta__c critica2 = new CriticaProposta__c(
            Proposta__c = proposta.Id,
            MomentoAnalise__c = 'Análise interna',
            Status__c = 'Não iniciada',
            Setor__c = 'Emissão'
        );
        CriticaProposta__c critica3 = new CriticaProposta__c(
            Proposta__c = proposta.Id,
            MomentoAnalise__c = 'Análise interna',
            Status__c = 'Não iniciada',
            Setor__c = 'Aceitação'
        );
        CriticaProposta__c critica4 = new CriticaProposta__c(
            Proposta__c = proposta.Id,
            MomentoAnalise__c = 'Análise interna',
            Status__c = 'Não iniciada',
            Setor__c = 'Aceitação'
        );
        List<CriticaProposta__c> lstCritica = new List<CriticaProposta__c>{critica1, critica2, critica3, critica4};
        insert lstCritica;
        critica3.Status__c = 'Condicionada';
        critica3.Setor__c = 'Emissão';
        update critica3;
        Test.startTest();
        critica4.Status__c = 'Condicionada';
        critica4.Setor__c = 'Emissão';
        update critica4;
        Test.stopTest();
        proposta = [SELECT Id, Name, isFullEmissao__c FROM Quote WHERE Id =: proposta.Id];
        System.assert(proposta.isFullEmissao__c == true);
        QueueSObject filaEmissao = [SELECT QueueID FROM QueueSObject WHERE SobjectType = 'CriticaProposta__c' AND Queue.developerName = 'Filaemissao'];
        for(CriticaProposta__c critica : [SELECT Id, Name, OwnerId FROM CriticaProposta__c WHERE Id IN (:critica3.id, :critica4.id)]){
            System.assert(critica.OwnerId == filaEmissao.QueueID);
        }
    }*/
    //PLV-5311 - FIX - FIM
    //PLV-5077 - FIM

     //PLV-5100 - INICIO
     @isTest
     public static void validarLiberacaoPalavraFinal_Test(){
         Quote proposta = [SELECT Id, Name FROM Quote LIMIT 1];
         CriticaProposta__c critica1 = new CriticaProposta__c(
             Proposta__c = proposta.Id,
             MomentoAnalise__c = 'Análise interna',
             Status__c = 'Pendente',
             Setor__c = 'Emissão'
         );
         CriticaProposta__c critica2 = new CriticaProposta__c(
             Proposta__c = proposta.Id,
             MomentoAnalise__c = 'Palavra Final',
             Status__c = 'Não iniciada',
             Setor__c = 'Emissão'
         );
         List<CriticaProposta__c> lstCritica = new List<CriticaProposta__c>{critica1, critica2};
         insert lstCritica;

         Test.startTest();
         //Tenta atualizar a Palavra Final para Liberada mesmo tendo críticas pendentes
         String errorMsg;
         critica2.Status__c = 'Liberado';
         try {
            update critica2;
         }
         catch(Exception e) {
            errorMsg = e.getMessage();
            system.debug(errorMsg);
         }
         Test.stopTest();

         //Verifica a mensagem de erro
         System.assert(errorMsg.contains('Palavra Final'));

     } 
     //PLV-5100 - FIM

     //ANNVI-164 - INICIO
     @IsTest
     static void naoLiberarCriticaDaPropostaStatusNovo(){
        
        Test.startTest();
        
        CriticaProposta__c critica = [SELECT Id, Name, Proposta__c, Origem__c, MomentoAnalise__c, Status__c FROM CriticaProposta__c WHERE Origem__c = 'Salesforce'];
        
        Quote proposta = [SELECT Id, Name, Tipo__c, FormaPagamento__r.Codigo__c, FormaPagamento__r.Name FROM Quote WHERE Id =: critica.Proposta__c];
        proposta.CodigoMotivoDevolucao__c = '14';
        update proposta;

        critica.Status__c = 'Pendente';
        update critica;

        critica.Status__c = 'Recusado';
        critica.MomentoAnalise__c = 'Recalculo';
        update critica;

        critica.Status__c = 'Liberado';
        update critica;        

        Test.stopTest();        
     }

     @IsTest
     static void testarGetNextMomento(){
        
        Test.startTest();
        Set<String> momentosFromCriticas = new Set<String>{'Análise interna','Recalculo', 'Palavra final'};        
       
        String resultado = CriticaPropostaStatus.getNextMomento('Recalculo', momentosFromCriticas);        
       
        System.assertEquals('Palavra final', resultado);
        Test.stopTest();
        
     }

     @IsTest
     static void testartAtCritProHub(){
        
        Test.startTest();
        
        CriticaProposta__c critica = [SELECT Id, Name, Proposta__c, Origem__c, MomentoAnalise__c, Status__c FROM CriticaProposta__c WHERE Origem__c = 'Salesforce'];
        
        Quote proposta = [SELECT Id, Name FROM Quote WHERE Id =: critica.Proposta__c];
        proposta.CodigoMotivoDevolucao__c = '14';
        update proposta;

        critica.Status__c = 'Pendente';
        critica.Origem__c = 'HUB';
        update critica;

        critica.Status__c = 'Liberado';
        update critica;

        Test.stopTest();        
     }

     @IsTest
     static void testarAutProposta(){
        
        Test.startTest();
        
        CriticaProposta__c critica = [SELECT Id, Name, Proposta__c, Origem__c, MomentoAnalise__c, Status__c FROM CriticaProposta__c WHERE Origem__c = 'Salesforce'];
        
        Quote proposta = [SELECT Id, Name, Status FROM Quote WHERE Id =: critica.Proposta__c];
        proposta.CodigoMotivoDevolucao__c = '14';
        update proposta;

        proposta.Status = 'Em aprovação';
        update proposta;

        critica.Status__c = 'Não iniciada';
        update critica;

        proposta.Status = 'Em análise';
        update proposta;

        critica.Status__c = 'Pendente';
        update critica;

        critica.Status__c = 'Liberado';
        update critica;

        Test.stopTest();
        
     }

     @IsTest
     static void testarPropostaTemCritNaoLib(){
        
        Test.startTest();
        
        List<CriticaProposta__c> lstCriticas = [SELECT Id, Status__c FROM CriticaProposta__c WHERE Origem__c = 'Salesforce'];

        Boolean possuiLiberadaOuCancelada = CriticaPropostaStatus.propostaTemCritNaoLib(lstCriticas);

        Test.stopTest();

        System.assertEquals(false, possuiLiberadaOuCancelada);
        
     }
     //ANNVI-164 - FIM
}