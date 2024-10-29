@isTest
public with sharing class Rvi48Test {
    @TestSetup
    static void makeData(){
        // Geração Account
        Account contaTeste = TestDataFactory.gerarConta();

        // Geração Dados do Corretor
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);

        // Geração Ramo do Seguro
        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);

        // Geração Garantia
        Garantia__c garantia1 = TestDataFactory.gerarGarantia();
        
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
	    ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        // Geração Propduto Técnico
        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        produtoTec.Status__c = 'Ativo';
        produtoTec.Segmento__c = 'Individual';
        update produtoTec;
        
        // Geração Produto Comercial
        Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        produtoCom.Status__c ='ativo';
        produtoCom.Segmento__c = 'Individual';
        update produtoCom;

        // Geração Canal de Distribuição
        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        
        // Geração Orçamento (Opportunity)
        Opportunity orcamentoContratado = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        
        // Geração Modalidade
        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);

        // Geração Quote
        Quote cot = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, orcamentoContratado, modalidade);
        cot.NumeroProposta__c = '00001910';
        cot.Tipo__c = 'Renovação';
        update cot;

        // Geração Contrato
        Contract contrato = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, cot);
        contrato.Oportunidade__c = orcamentoContratado.Id;
        contrato.NumeroPropostaUnico__c = '18-00001910';
        contrato.NumeroApolice__c = '000014419';
        contrato.Tipo__c = 'Renovação';
        contrato.Status = 'Ativo';
        contrato.Endosso__c = '0';
        contrato.VigenciaFinal__c = System.today().addDays(30);
        update contrato;

        // Geração Contratante do Contrato
        ContratanteContrato__c contratanteContrato = TestDataFactory.gerarContratanteContrato(contrato, contaTeste, contaTeste);

        // Geração Grupo do Contrato
        GrupoContrato__c grupoContrato = TestDataFactory.gerarGrupoContrato(contratanteContrato);

        // Geração Segurado do Contrato
        SeguradoContrato__c seguradoContrato = TestDataFactory.gerarSeguradoContrato(grupoContrato, contaTeste);

        // Geração Forma de Pagamento
        FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento();

        // Geração Contratante Proposta
        ContratanteProposta__c contratanteProposta = TestDataFactory.gerarContratanteProposta(contaTeste, cot, formaPagamento);

        // Geração Grupo Proposta
        GrupoProposta__c grupoProposta = TestDataFactory.gerarGrupoProposta(contratanteProposta);

        // Geração Segurado Proposta
        SeguradoProposta__c seguradoProposta = TestDataFactory.gerarSeguradoProposta(contaTeste, grupoProposta, formaPagamento);
        seguradoProposta.GrupoRisco__c = 'DIT-A';
        update seguradoProposta;

        // Geração da Garantia do Segurado da Proposta
        GarantiaSeguradoProposta__c garantiaSeguradoProposta = TestDataFactory.gerarGarantiaSeguradoProposta(garantia1, seguradoProposta);

        // Geração de Profissão
        Profissao__c estatistico = new Profissao__c (
            NomeOcupacao__c = null,
            NomeFantasia__c = null,
            NomeFamilia__c = null,
            NomeSubGrupo__c = null,
            NomeSubGrupoPrincipal__c = null,
            NomeGrandeGrupo__c = 'teste',
            CodigoProfissao__c = null,
            Codigo__c = null,
            CodigoFamilia__c = null,
            CodigoSubGrupo__c = null,
            CodigoSubGrupoPrincipal__c = null,
            CodigoGrandeGrupo__c = '8',
            Name = 'Estatístico',
            Status__c = 'Ativo'
        );
        insert estatistico;

        Profissao__c piloto = new Profissao__c (
            NomeOcupacao__c = null,
            NomeFantasia__c = null,
            NomeFamilia__c = null,
            NomeSubGrupo__c = null,
            NomeSubGrupoPrincipal__c = null,
            NomeGrandeGrupo__c = 'teste',
            CodigoProfissao__c = null,
            Codigo__c = null,
            CodigoFamilia__c = null,
            CodigoSubGrupo__c = null,
            CodigoSubGrupoPrincipal__c = null,
            CodigoGrandeGrupo__c = '8',
            Name = 'Piloto',
            Status__c = 'Ativo'
        );
        insert piloto;

        // Configuração Inicial do Seegurado da Proposta => Campos Fumante = false e Profissão = 'Estatístico' Para o Teste
        //seguradoProposta.Fumante__c = false;
        //seguradoProposta.Profissao__c = estatistico.Id;
        //update seguradoProposta;

   }
    @isTest
    public static void testPerfilAceitacaoSeguradoProposta() {
        // Setup test data
        // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name='Aceitação'];
        System.debug('Perfil Para Teste Perfil Aceitação Segurado Proposta = ' + profiles[0].Name);

        User u = new User (
                            Alias = 'standt', 
                            Email = 'standarduser@testorg.com',
                            EmailEncodingKey = 'UTF-8', 
                            LastName = 'Testing', 
                            LanguageLocaleKey = 'en_US',
                            LocaleSidKey = 'en_US', 
                            ProfileId = profiles[0].Id,
                            TimeZoneSidKey = 'America/Los_Angeles',
                            UserName = uniqueUserName
                          );

        List<SeguradoProposta__c> seguradosProposta = [ SELECT Id, Fumante__c, Profissao__r.Name
                                                        FROM   SeguradoProposta__c
                                                        WHERE  Conta__r.Name = 'Conta 14'
                                                      ];
        System.debug('Total Segurado Proposta Conta 14 = ' + seguradosProposta.size());
        System.debug('Profissão Segurado Proposta = ' + seguradosProposta[0].Profissao__r.Name);

        List<Profissao__c> pilotos = [SELECT Id, Name FROM Profissao__c WHERE Name = 'Piloto'];
        System.debug('Profissão Piloto = ' + pilotos[0].Name);

        // Variável Para Receber a Mensagem de Erro da Regra de Validação
        String msgErro = ' ';

        System.runAs(u) {
            // Alteração do Seegurado da Proposta => Campos Fumante = true e Profissão = 'Piloto'
            seguradosProposta[0].Profissao__c = pilotos[0].Id;
            seguradosProposta[0].Fumante__c = true;
            try {
                update seguradosProposta[0];
            } catch (DmlException e) {
                msgErro = e.getMessage();
                if (msgErro.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                    msgErro = msgErro.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,', ':');
                }
            }
        }
        System.debug('msgErro : ' + msgErro);
        System.assertEquals(msgErro.contains('Alteracao Nao Permitida'), true);
    }
    @isTest
    public static void testPerfilAdministradorPortSeguradoProposta() {
        // Setup test data
        // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name='Administrador Porto'];
        System.debug('Perfil Para Teste Perfil Administrador Porto Segurado Proposta = ' + profiles[0].Name);

        User u = new User (
                            Alias = 'standt', 
                            Email = 'standarduser@testorg.com',
                            EmailEncodingKey = 'UTF-8', 
                            LastName = 'Testing', 
                            LanguageLocaleKey = 'en_US',
                            LocaleSidKey = 'en_US', 
                            ProfileId = profiles[0].Id,
                            TimeZoneSidKey = 'America/Los_Angeles',
                            UserName = uniqueUserName
                          );

        List<SeguradoProposta__c> seguradosProposta = [ SELECT Id, Fumante__c, Profissao__r.Name
                                                        FROM   SeguradoProposta__c
                                                        WHERE  Conta__r.Name = 'Conta 14'
                                                      ];
        System.debug('Total Segurado Proposta Conta 14 = ' + seguradosProposta.size());
        System.debug('Profissão Segurado Proposta = ' + seguradosProposta[0].Profissao__r.Name);

        List<Profissao__c> pilotos = [SELECT Id, Name FROM Profissao__c WHERE Name = 'Piloto'];
        System.debug('Profissão Piloto = ' + pilotos[0].Name);

        // Variável Para Receber a Mensagem de Erro da Regra de Validação
        String msgErro = ' ';

        System.runAs(u) {
            // Alteração do Seegurado da Proposta => Campos Fumante = true e Profissão = 'Piloto'
            seguradosProposta[0].Profissao__c = pilotos[0].Id;
            seguradosProposta[0].Fumante__c = true;
            try {
                update seguradosProposta[0];
            } catch (DmlException e) {
                msgErro = e.getMessage();
                if (msgErro.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                    msgErro = msgErro.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,', ':');
                }
            }
        }
        System.debug('msgErro : ' + msgErro);
        System.assertEquals(msgErro, ' ');
    }
    @isTest
    public static void testPerfilAceitacaoGarantiaSeguradoProposta() {
        // Setup test data
        // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name='Aceitação'];
        System.debug('Perfil Para Teste Perfil Aceitação Garantia Segurado Proposta = ' + profiles[0].Name);

        User u = new User (
                            Alias = 'standt', 
                            Email = 'standarduser@testorg.com',
                            EmailEncodingKey = 'UTF-8', 
                            LastName = 'Testing', 
                            LanguageLocaleKey = 'en_US',
                            LocaleSidKey = 'en_US', 
                            ProfileId = profiles[0].Id,
                            TimeZoneSidKey = 'America/Los_Angeles',
                            UserName = uniqueUserName
                          );

        Date vigenciaInicial = System.today();
        List<GarantiaSeguradoProposta__c> garantiasSeguradoProposta = [ SELECT Id, Garantia__c, Capital__c, Garantia__r.Tipo__c, Garantia__r.Sigla__c
                                                                        FROM   GarantiaSeguradoProposta__c
                                                                        WHERE  Garantia__r.Tipo__c = 'Cobertura'
                                                                        AND    Garantia__r.Sigla__c = 'CAP'
                                                                      ];
        System.debug('Total Garantia Segurado Proposta = ' + garantiasSeguradoProposta.size());

        // Geração de Nova Garantia Para Update
        Garantia__c garantia2 = TestDataFactory.gerarGarantia();
        garantia2.Tipo__c = 'Benefício';
        garantia2.Sigla__c = 'BNF';
        update garantia2;

        // Variável Para Receber a Mensagem de Erro da Regra de Validação
        String msgErro = ' ';

        System.runAs(u) {
            // Alteração do Seegurado da Proposta => Campos Fumante = true e Profissão = 'Piloto'
            garantiasSeguradoProposta[0].Garantia__c = garantia2.Id;
            garantiasSeguradoProposta[0].Capital__c = 9999999;
            try {
                update garantiasSeguradoProposta[0];
            } catch (DmlException e) {
                msgErro = e.getMessage();
                if (msgErro.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                    msgErro = msgErro.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,', ':');
                }
            }
        }
        System.debug('msgErro = ' + msgErro);
        System.assertEquals(msgErro.contains('Alteracao Nao Permitida'), true);
    }
    @isTest
    public static void testPerfilAdministradorPortoGarantiaSeguradoProposta() {
        // Setup test data
        // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name='Administrador Porto'];
        System.debug('Perfil Para Teste Perfil Aceitação Garantia Segurado Proposta = ' + profiles[0].Name);

        User u = new User (
                            Alias = 'standt', 
                            Email = 'standarduser@testorg.com',
                            EmailEncodingKey = 'UTF-8', 
                            LastName = 'Testing', 
                            LanguageLocaleKey = 'en_US',
                            LocaleSidKey = 'en_US', 
                            ProfileId = profiles[0].Id,
                            TimeZoneSidKey = 'America/Los_Angeles',
                            UserName = uniqueUserName
                          );

        Date vigenciaInicial = System.today();
        List<GarantiaSeguradoProposta__c> garantiasSeguradoProposta = [ SELECT Id, Garantia__c, Capital__c, Garantia__r.Tipo__c, Garantia__r.Sigla__c
                                                                        FROM   GarantiaSeguradoProposta__c
                                                                        WHERE  Garantia__r.Tipo__c = 'Cobertura'
                                                                        AND    Garantia__r.Sigla__c = 'CAP'
                                                                      ];
        System.debug('Total Garantia Segurado Proposta = ' + garantiasSeguradoProposta.size());

        // Geração de Nova Garantia Para Update
        Garantia__c garantia2 = TestDataFactory.gerarGarantia();
        garantia2.Tipo__c = 'Benefício';
        garantia2.Sigla__c = 'BNF';
        update garantia2;

        // Variável Para Receber a Mensagem de Erro da Regra de Validação
        String msgErro = ' ';

        System.runAs(u) {
            // Alteração do Seegurado da Proposta => Campos Fumante = true e Profissão = 'Piloto'
            garantiasSeguradoProposta[0].Garantia__c = garantia2.Id;
            garantiasSeguradoProposta[0].Capital__c = 9999999;
            try {
                update garantiasSeguradoProposta[0];
            } catch (DmlException e) {
                msgErro = e.getMessage();
                if (msgErro.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                    msgErro = msgErro.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,', ':');
                }
            }
        }
        System.debug('msgErro = ' + msgErro);
        System.assertEquals(msgErro, ' ');
    }          
}