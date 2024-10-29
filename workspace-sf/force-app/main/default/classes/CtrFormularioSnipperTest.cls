@isTest
public class CtrFormularioSnipperTest {
    
    public static final String MOCK_CONSULTIVO = '{"consultivo":{"codigoOfertaConsultiva":"SNIPER","canalDistribuicao":"COR","susepCorretor":"S5005J","meioComercializacao":"Backoffice","conjuntos":[{"id":1,"titulo":"Simulação de Seguro de Vida","subtitulo":"Para simular seu seguro, você só precisa preencher algumas informações.","informacoes":[{"id":"TIPOCONTRATO","nome":"Tipo de Contrato","descricao":"Selecione seu tipo de contrato","tipo":"Opções fixas","obrigatorio":true,"opcoes":[{"codigo":"VOCE","rotulo":"Plano para você"},{"codigo":"FAMILIA","rotulo":"Plano para sua família"},{"codigo":"TODOS","rotulo":"Plano para todos"}]}],"regrasSequencia":[{"sequencia":1,"proximoConjunto":2}]},{"id":2,"titulo":"Simulação de Seguro de Vida","subtitulo":"Preencha as informações básicas.","informacoes":[{"id":"NOMECOMPLETO","nome":"Teste mockado","tipo":"Texto","obrigatorio":true},{"id":"NASCIMENTO","nome":"Nascimento","tipo":"Data","obrigatorio":true},{"id":"SEXO","nome":"Sexo","tipo":"Opções fixas","obrigatorio":true,"opcoes":[{"codigo":"MASC","rotulo":"Masculino"},{"codigo":"FEM","rotulo":"Feminino"}]},{"id":"FUMANTE","nome":"Fumante","tipo":"Booleano","obrigatorio":true},{"id":"ESTADOCIVIL","nome":"Estado civil","tipo":"Opções fixas","obrigatorio":true,"opcoes":[{"codigo":"SOL","rotulo":"Solteiro"},{"codigo":"CAS","rotulo":"Casado"},{"codigo":"DIV","rotulo":"Divorciado"},{"codigo":"VIU","rotulo":"Viúvo"}]},{"id":"PROFISSAO","nome":"Profissão","tipo":"Opções de serviço","servico":"/consultas/profissao/","obrigatorio":true}],"regrasSequencia":[{"sequencia":1,"proximoConjunto":3}]},{"id":3,"titulo":"Referência para o valor do seguro","subtitulo":"Você pode alterar o valor do seguro depois. Isso é só para iniciarmos.","informacoes":[{"id":"RENDAMENSAL","nome":"Renda mensal","descricao":"Qual sua faixa de renda mensal?","tipo":"Opções fixas","obrigatorio":true,"opcoes":[{"codigo":"0-4000","rotulo":"Até R$ 4.000,00"},{"codigo":"4001-8000","rotulo":"De R$ 4.000,01 a R$ 8.000,00"},{"codigo":"8001-12000","rotulo":"De R$ 8.000,01 a R$ 12.000,00"},{"codigo":"12001-16000","rotulo":"De R$ 12.000,01 a R$ 16.000,00"},{"codigo":"16001-infinito","rotulo":"Acima de R$ 16.000,00"}]}]}]}}';
    public static final String MOCK_ENTRADA_CALCULO = '{"orcamento":null,"consultivo":{"codigoOfertaConsultiva":"VIAGEM","canalDistribuicao":"COR","identificadorRepresentante":"P5005J","meioComercializacao":"SFC","respostas":[{"id":"TIPOCONTRATO","conteudo":"VOCE"},{"id":"DICIO_NOME","conteudo":"FRANCIS LIU"},{"id":"DICIO_CPFVOUCHER","conteudo":"867.213.059-68"},{"id":"DICIO_VOUCHER","conteudo":"PSSVlL01560A0949B784531"},{"id":"TIPO_VIAGEM","conteudo":"NACIONAL"},{"id":"ORIGEM","conteudo":"Brasil"},{"id":"DESTINO","conteudo":"Brasil"},{"id":"DICIO_DATA_SAIDA","conteudo":"2021-09-22"},{"id":"DICIO_DATA_RETORNO","conteudo":"2021-09-25"},{"id":"DICIO_QTD_JOVENS","conteudo":"1"},{"id":"DICIO_QTD_IDOSOS","conteudo":"0"},{"id":"TIPOCONTRATO","conteudo":"VOCE"}]}}';
    public static final String MOCK_VIAGEM_VIDA_ON_CALCULO = '{"orcamento":null,"consultivo":{"codigoOfertaConsultiva":"VIAGEM_VIDA_ON","canalDistribuicao":"COR","identificadorRepresentante":"P5005J","meioComercializacao":"SFC","respostas":[{"id":"TIPOCONTRATO","conteudo":"VOCE"},{"id":"DICIO_NOME","conteudo":"FRANCIS LIU"},{"id":"DICIO_CPFVOUCHER","conteudo":"867.213.059-68"},{"id":"DICIO_VOUCHER","conteudo":"PSSVlL01560A0949B784531"},{"id":"TIPO_VIAGEM","conteudo":"NACIONAL"},{"id":"ORIGEM","conteudo":"Brasil"},{"id":"DESTINO","conteudo":"Brasil"},{"id":"DICIO_DATA_SAIDA","conteudo":"2021-09-22"},{"id":"DICIO_DATA_RETORNO","conteudo":"2021-09-25"},{"id":"DICIO_QTD_JOVENS","conteudo":"1"},{"id":"DICIO_QTD_IDOSOS","conteudo":"0"},{"id":"TIPOCONTRATO","conteudo":"VOCE"}]}}'; //ANNVI-170 - INICIO/FIM
    public static final String MOCK_CALCULOS_CONTRATS = '{ "entradaPessoa": { "destinos": [ { "codigo": "DESTINO", "pais": "BRASIL" } ], "inicioVigencia": "2021-06-23", "finalVigencia": "2021-06-29", "tipoViagem": "NACIONAL", "passageirosIdosos": 0, "passageirosNaoIdosos": 1, "utilizaraMotocicleta": false, "praticaEsportesAventura": false } }';
    public static final String MOCK_RECUSAS = '"recusas":[{"codigo":1, "mensagens":{"cliente":"Prezado cliente, favor selecionar todas as garantias obrigátorias"}}]';
    public static final String MOCK_CONSULTA_VOUCHER = '{"status":"PROCESSADO","servico":"/voucher/consultar-voucher","descricao":"O CPF ainda pode utilizar 2 voucher(s).","dataexecucao":"2024-01-14T23:11:41.177Z","dados":[{"voucher":[{"voucher":"PSSVlL01560A0949B784531","produto":"VIAGEM","datautilizacao":null,"cpf":"331.262.008-26"}],"totalutilizacao":0,"podeutilizar":true}],"codigoprocessamento":0, "mensagemRetorno":"Processamento realizado com sucesso","listaSeguros":{"seguroVida":{"codigoFormaPagamento":"41","ramo":"1391","listaParcelaSeguroVida":{"parcelaSeguroVida":{"valorParcela":"145.74925","numeroParcela":"1"}},"linkApolice":"http://washmlvidanova/servicosvida/obterApolice?param=MSwxMzkxLDE3ODYxNiw1OCwxMzY1","dataTransmissao":"2023-09-18T00:00:00-03:00","nomeComercialProduto":"Porto Vida ON","nomeSegurado":"DANILLO","inicioVigencia":"2023-08-04T00:00:00-03:00","apolice":"178616","sucursal":"1","finalVigencia":"2024-08-03T00:00:00-03:00","listaBeneficiariosSeguro":{"beneficiarioSeguro":{"percentualDistribuicaoCapital":"100"}},"cpf":"33126200826","listaGarantiasContratadas":{"garantiaContratada":[{"nomeGarantia":"Morte","valorCapital":"40000.0"},{"nomeGarantia":"Invalidez Permanente Total ou Parcial por Acidente","valorCapital":"40000.0"}]},"descricaoFormaPagamento":"FRAC. 1A PARCELA CARNE"}},"codigoRetorno":"0","seguroVidaOnAtivo":true,';
    public static final String MOCK_ENTRADA_CALCULO2 = '{"orcamento":{"tipoVigencia":"Periódico","ramoSeguro":0,"tipoSeguro":"Novo","vigenciaFinal":"2024-08-03","qtdDiasVigencia":366,"customizavel":true,"canalDistribuicao":"COR","viagem":null,"varConsultivo":true,"idProdutoSf":"01tL0000007NvMjIAK","ordemPortal":1,"rotulo":"Vida Mais 2_teste","susepOrcamento":"P5005J","remuneracoes":[{"percentual":0,"tipoRemuneracao":"AGENCIAMENTO"},{"percentual":10,"tipoRemuneracao":"CORRETAGEM"}],"dataCalculo":"2023-08-04","numeroPortal":0,"codigoProdutoVida":"VI-PESSOAS","contratantes":[{"tipo":"PRI","numero":1,"grupos":[{"numero":1,"segurados":[{"pessoa":{"tipo":"FIS","enderecos":[{"uf":" ","cidade":" ","complemento":" ","logradouro":" ","bairro":" ","complementoCep":" ","paisResidencia":" ","tipoEndereco":" ","numeroLogradouro":" ","cep":" "}],"nome":"FRANCIS LIU","dadosPessoaFisica":{"grupoProfissao":"DIT-A","cicloVacinal":"1","profissao":"2111-05","temDependentes":true,"tipoContrato":"VOCE","tempoGarantiaRenda":"48","dataNascimento":"1964-05-22","sexo":"MASCULINO","fumante":true,"regimeTrabalho":"CLT","renda":"4000"},"email":""},"numero":1,"coberturas":[{"caracteristica":"Principal","limitemaximo":"10000000","limiteminimo":"30002","moeda":"BRL","sigla":"BAS","valor":"30002.00","franquia":"FR_NORMAL","caracteristicaespecialvalor":"1","caracteristicaespecialtipo":"Ano(s)"},{"caracteristica":"Serviço complementar","limitemaximo":"0","limiteminimo":"0","moeda":"BRL","sigla":"TELEMED","valor":"0.00"}]}],"nome":"FRANCIS LIU","qtdeVidas":1,"coberturas":[{"caracteristica":"Principal","limitemaximo":"10000000","limiteminimo":"30002","moeda":"BRL","sigla":"BAS","valor":"30002.00","franquia":"FR_NORMAL","caracteristicaespecialvalor":"1","caracteristicaespecialtipo":"Ano(s)"},{"caracteristica":"Serviço complementar","limitemaximo":"0","limiteminimo":"0","moeda":"BRL","sigla":"TELEMED","valor":"0.00"}]}]}],"meioComercializacao":"SFC","segmento":"Individual","gerarDocumento":false,"vigenciaInicial":"2023-08-04"},"consultivo":null}';
    public static final String MOCK_ENTRADA = '{"consultivo":{"codigoOfertaConsultiva":"VIDA_INDIVIDUAL","canalDistribuicao":"COR","identificadorRepresentante":"P5005J","meioComercializacao":"Portal","entradaNegocio":"CO2","voltar":false,"nProposta":"18-00037715"},"acao":"CONTRATAR"}';
    
    @TestSetup
    static void setupUnit(){
        Account conta = new Account(
            FirstName = 'FRANCIS',
            LastName = 'LIU',
            Sexo__c = 'MASC',
            Fumante__c = 'Não',                      
            Renda__c = 3000.00,
            Cpf__c = '518.179.180-87',
            TipoDocidentificacao__c = 'rg',
            Rg__c = '0000002',
            OrgaoExpedidor__c = 'SSP',            
            EmpresaTrabalhaSocio__c = 'GLOBANT',
            EstadoCivil__c = 'Solteiro (a)',
            Nacionalidade__c = 'Brasileira',            
            RegimeTrabalho__c = 'CLT',
            ResideBrasil__c = true,
            PaisResidencia__c = 'Brasil',
            Pep__c = 'Não',
            PersonBirthdate = System.today().addDays(-20000),
            BillingPostalCode = '09180320' 
            
        );
        insert conta;
        
        Opportunity orcamento = new Opportunity(
            AccountId = conta.Id,
            StageName = 'Em criação',
            Name = 'SFC-00068615',
            CloseDate = System.today().addDays(1),
            Numero__c = '00005555'
        );
        insert orcamento;
        
        ContadorCodigo__c contadorTecnico = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contadorComercial = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
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
        produtoTecnico.ProductCode = '49';
        produtoTecnico.Segmento__c = 'Individual';
        update produtoTecnico;
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        produtoComercial.Status__c = 'Ativo';
        produtoComercial.ProductCode = 'APTLMKT';
        produtoComercial.Segmento__c = 'Individual';
        produtoComercial.CodigoPrecificaProduto__c = 'APTLMKT';
        update produtoComercial;
        
        Quote proposta = new Quote(            
            DependentesFinanceiros__c = false,
            OpportunityId = orcamento.id,
            Name = '18-00037715',
            Produto__c = produtoComercial.id //TKCL-246 FIX05 INICIO/FIM            
        );
        insert proposta;
        
        TipoRemuneracao__c tipoCorretagem = new TipoRemuneracao__c(
            Name = 'CORRETAGEM',
            Descricao__c = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit.',
            ModeloRecuperacao__c = 'Integral',
            Codigo__c = 'COR',
            LimiteMinimo__c = 10,
            LimiteMaximo__c = 50
        );
        insert tipoCorretagem;
        
        TipoRemuneracao__c tipoAgenciamento = new TipoRemuneracao__c(
            Name = 'AGENCIAMENTO',
            Descricao__c = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit.',
            ModeloRecuperacao__c = 'Integral',
            Codigo__c = 'COR',
            LimiteMinimo__c = 10,
            LimiteMaximo__c = 50
        );
        insert tipoAgenciamento;
        
        RemuneracaoOrcamento__c corretagem = new RemuneracaoOrcamento__c(
            Oportunidade__c = orcamento.Id,
            Percentual__c = 10,
            TipoRemuneracao__c = tipoCorretagem.Id
        );
        insert corretagem;
        
        RemuneracaoOrcamento__c agenciamento = new RemuneracaoOrcamento__c(
            Oportunidade__c = orcamento.Id,
            Percentual__c = 100,
            TipoRemuneracao__c = tipoAgenciamento.Id
        );
        insert agenciamento;
        
        Endereco__c enderecoRes = new Endereco__c(
            TipoEndereco__c = 'Residencial', 
            CEP__c = '09180320',//VIDA-179 - INICIO/FIM
            Logradouro__c = 'AVENIDA RIO BRANCO',
            Numero__c = '1400',
            Complemento__c = 'teste',
            Bairro__c = 'teste', 
            Cidade__c = 'teste',
            Estado__c ='SP',
            Conta__c = conta.Id,
            MaisAtual__c = true
        );
        insert enderecoRes;
        
        Endereco__c enderecoCom = new Endereco__c(
            TipoEndereco__c = 'Comercial', 
            CEP__c = '11420410', 
            Logradouro__c = 'AVENIDA RIO BRANCO',
            Numero__c = '1400',
            Complemento__c = 'teste',
            Bairro__c = 'teste', 
            Cidade__c = 'teste',
            Estado__c ='SP',
            Conta__c = conta.Id
        );
        insert enderecoCom;
        
        ContratanteProposta__c contratante = new ContratanteProposta__c(
            Proposta__c = proposta.id            
        );
        insert contratante;
        
        GrupoProposta__c grupo = new GrupoProposta__c(
            ContratanteProposta__c = contratante.id
        );
        insert grupo;
        
        SeguradoProposta__c segurado = new SeguradoProposta__c(
            Nome_do_segurado__c = 'FRANCIS LIU',
            TemDependentes__c = true,
            RegimeTrabalho__c = 'CLT',
            FaixaRenda__c = '20000',
            Renda__c = 4000,
            Email__c = 'teste@teste.com.br',
            Conta__c = conta.Id,
            ResponsavelPagamento__c = conta.Id,
            PremioTotal__c = 58.90,
            GrupoProposta__c = grupo.Id
        );
        insert segurado;
        
        RemuneracaoProposta__c remuneracaoCorretagem = new RemuneracaoProposta__c(            
            TipoRemuneracao__c = tipoCorretagem.Id,                    
            Porcentagem_de_Retencao__c = 10.00,
            Percentual__c = 10.00,
            Proposta__c = proposta.Id
        );
        insert remuneracaoCorretagem;
        
        RemuneracaoProposta__c remuneracaoAgenciamento = new RemuneracaoProposta__c(            
            TipoRemuneracao__c = tipoAgenciamento.Id,                    
            Porcentagem_de_Retencao__c = 10.00,
            Percentual__c = 10.00,
            Proposta__c = proposta.Id
        );
        insert remuneracaoAgenciamento;
        
        FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta = new FavorecidoRemuneracaoProposta__c(
            Conta__c = conta.Id,           
            CorretorLider__c = true,
            Papel__c = 'Corretor',
            Participacao__c = 10.00,
            RemuneracaoProposta__c = remuneracaoAgenciamento.Id,
            Susep__c = 'REN01J',
            SusepEmissao__c = 'REN01J',
            SusepOficialCorretor__c = '123',
            SusepOrcamento__c = 'REN01J',
            AntecipacaoComissao__c = true,
            DadosCorretor__c = dadosCorretor.Id
        );
        insert favorecidoRemuneracaoProposta;
        
        BeneficiarioSeguradoProposta__c beneficiario = new BeneficiarioSeguradoProposta__c(
            SeguradoProposta__c = segurado.Id,
            CpfCnpj__c = '00478394659',
            Nome__c = 'Teste Contrato',
            TipoBeneficiario__c = 'Nome do beneficiário',
            GrauParentesco__c = 'Pai',
            Participacao__c = 100.00,
            Pep__c = 'Nao',
            Sexo__c = 'Masculino',
            ImprimirCertificadoSeguro__c = false,
            Data_de_nascimento__c = System.today(),
            PercentualIndenizacao__c = 100.00
        );
        insert beneficiario;
        
        Garantia__c garantia = new Garantia__c(
            VigenciaInicial__c = System.today(),
            Tipo__c = 'Cobertura',
            Sigla__c = 'AFI'
        );
        insert garantia;
        
        Recordtype rcT = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoTecnico');
        GarantiaProduto__c gproduto = new GarantiaProduto__c(
            Garantia__c = garantia.Id,
            Produto__c = produtoTecnico.Id,
            RamoSeguro__c = ramoSeguro.Id,
            OrdemPrioridade__c = 2,
            RecordTypeId = rcT.Id,
            TipoGarantia__c = 'Cobertura',
            TipoCapital__c = 'Capital uniforme',
            CodigoPromocao__c = 'VITST',
            VersaoTitulo__c = '1'
        );
        
        GarantiaProposta__c garantiaProposta = new GarantiaProposta__c(
            Proposta__c = proposta.Id,
            GarantiaProduto__c = gproduto.Id,
            Garantia__c = gproduto.Garantia__c,
            TipoCapital__c = 'Capital uniforme'
        );
        insert garantiaProposta;
        
        Garantia__c garantia2 = new Garantia__c(
            VigenciaInicial__c = System.today(),
            Tipo__c = 'Cobertura',
            Sigla__c = 'DIA'
        );
        insert garantia2;
        
        Garantia__c garantia3 = new Garantia__c(
            VigenciaInicial__c = System.today(),
            Tipo__c = 'Cobertura',
            Sigla__c = 'DITA'
        );
        insert garantia3;
        
        Garantia__c garantia4 = new Garantia__c(
            VigenciaInicial__c = System.today(),
            Tipo__c = 'Cobertura',
            Sigla__c = 'CKUP'
        );
        insert garantia4;
        
        Garantia__c garantia5 = new Garantia__c(
            VigenciaInicial__c = System.today(),
            Tipo__c = 'Cobertura',
            Sigla__c = 'IPA'
        );
        insert garantia5;
        
        GarantiaProposta__c garantiaProposta2 = new GarantiaProposta__c(
            Proposta__c = proposta.Id,
            GarantiaProduto__c = gproduto.Id,
            Garantia__c = garantia2.Id,
            TipoCapital__c = 'Capital uniforme'
        );
        insert garantiaProposta2;
        
        GarantiaProposta__c garantiaProposta3 = new GarantiaProposta__c(
            Proposta__c = proposta.Id,
            GarantiaProduto__c = gproduto.Id,
            Garantia__c = garantia3.Id,
            TipoCapital__c = 'Capital uniforme'
        );
        insert garantiaProposta3;
        
        GarantiaProposta__c garantiaProposta4 = new GarantiaProposta__c(
            Proposta__c = proposta.Id,
            GarantiaProduto__c = gproduto.Id,
            Garantia__c = garantia4.Id,
            TipoCapital__c = 'Capital uniforme'
        );
        insert garantiaProposta4;
        
        GarantiaProposta__c garantiaProposta5 = new GarantiaProposta__c(
            Proposta__c = proposta.Id,
            GarantiaProduto__c = gproduto.Id,
            Garantia__c = garantia5.Id,
            TipoCapital__c = 'Capital uniforme', 
            Capital__c = 10
        );
        insert garantiaProposta5;
        
    }  
    
    @isTest
    static void testFormularioSnipper() {
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(MOCK_CONSULTIVO,
                                                                 200,
                                                                 'OK'));
        
        CtrFormularioSnipper testeSnipper = new CtrFormularioSnipper();  
        testeSnipper.EntradaCalculo = MOCK_ENTRADA_CALCULO; 
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(MOCK_CONSULTA_VOUCHER + MOCK_RECUSAS + '}',
                                                                 200,
                                                                 'OK'));
        
        testeSnipper.pagOfertas();
        testeSnipper.redirecionarTela();
        testeSnipper.entradaCalculo2 = MOCK_ENTRADA_CALCULO2;
        testeSnipper.dataConvivencia = 'DATA_PREMREC';
        testeSnipper.pagOfertaPersonalizada();
        testeSnipper.servicosEntrada = '[{"id": "PROFISSAO","servico": "profissoes/consulta"}]';
        testeSnipper.consultaOpcoesTipoServico();
        testeSnipper.redirecionaEndossoPage(); 
        testeSnipper.redirecionaEndossoViagemPage();
        string entrada = MOCK_ENTRADA;
        PageReference page = Page.formularioSniper;       
        Test.setCurrentPage(page);
        ApexPages.currentPage().getParameters().put('dados', entrada);         
        testeSnipper.reutilizarDados();
        testeSnipper.numOrcamentos = '[\"00005555\"]';
        testeSnipper.gravaJsonCompleto();
        testeSnipper.jsonResponseCalculo = '{}';
        testeSnipper.localStorage = '{}';
        testeSnipper.resetOfertas();
        testeSnipper.paramsToReturn = '{"numOrcamento":"00005555","tarefa":1}';
        testeSnipper.buscarJsonContentDocument();
        test.stopTest();
    }
    
    //ANNVI-170 - INICIO
    @isTest
    static void testFormSnipperViagVdOn() {

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(MOCK_CONSULTIVO, 200, 'OK'));
        CtrFormularioSnipper testeSnipper = new CtrFormularioSnipper();  
        testeSnipper.EntradaCalculo = MOCK_VIAGEM_VIDA_ON_CALCULO;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(MOCK_CONSULTA_VOUCHER + MOCK_RECUSAS + '}', 200, 'OK'));
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(MOCK_CALCULOS_CONTRATS, 200, 'OK'));

        String json = '{ "servico": "/voucher/gravar-voucher", "status": "PROCESSADO", "codigoprocessamento": 0, "dataexecucao": "2023-10-01T12:00:00Z", "descricao": "Inclusão realizada com sucesso.", "dados": [ { "totalutilizacao": 5, "podeutilizar": true, "voucher": [ { "cpf": "023.456.789-29", "voucher": "PSSVlL01560A0949B784531", "produto": "VIAGEM_VIDA_ON", "datautilizacao": "2023-10-02T10:00:00Z" } ] }, { "totalutilizacao": 3, "podeutilizar": false, "voucher": [ { "cpf": "023.456.789-29", "voucher": "PSSVlL01560A0949B784531", "produto": "VIAGEM_VIDA_ON", "datautilizacao": "2023-10-02T10:00:00Z" } ] } ] }';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(json, 200, 'OK'));
    
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(MOCK_CONSULTA_VOUCHER.replace('"seguroVidaOnAtivo":true,', '"seguroVidaOnAtivo":false}'), 200,'OK'));
        
        testeSnipper.pagOfertas();

        testeSnipper.EntradaCalculo = MOCK_VIAGEM_VIDA_ON_CALCULO.replace('VIAGEM_VIDA_ON', 'VIAGEM');

        testeSnipper.pagOfertas();

        test.stopTest();
    }
    //ANNVI-170 - FIM
    @isTest
    static void testFormularioSnipperErroNaRequisicao() {
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('Erro na requisição',200,'OK'));
        CtrFormularioSnipper testeSnipper = new CtrFormularioSnipper(); 
        test.stopTest();
    }
    
    @isTest
    static void testGrupoMdt(){
        test.startTest();
        List<Constante__mdt> constante = [	SELECT Label FROM Constante__mdt LIMIT 1];
        if(constante.size() > 0){
            CtrFormularioSnipper.buscaMetaGrupo(constante[0].Label);
        }
        test.stopTest();
    }
    
    @isTest
    static void testFormularioSnipperSeguroVidaInativo() {
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(MOCK_CONSULTIVO,
                                                                 200,
                                                                 'OK'));
        
        CtrFormularioSnipper testeSnipper = new CtrFormularioSnipper();  
        
        testeSnipper.EntradaCalculo = MOCK_ENTRADA_CALCULO; 
        
        String modifiedVoucher = MOCK_CONSULTA_VOUCHER.replace('"seguroVidaOnAtivo":true,', '"seguroVidaOnAtivo":false}');
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(modifiedVoucher,
                                                                 200,
                                                                 'OK'));
        
        testeSnipper.pagOfertas();
        test.stopTest();
    }
    
    @isTest
    static void testFormularioSnipperNaoPodeUtilizar() {
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(MOCK_CONSULTIVO,
                                                                 200,
                                                                 'OK'));
        
        CtrFormularioSnipper testeSnipper = new CtrFormularioSnipper();  
        
        testeSnipper.EntradaCalculo = MOCK_ENTRADA_CALCULO;
        
        String modifiedVoucher = MOCK_CONSULTA_VOUCHER.replace('"podeutilizar":true', '"podeutilizar":false');
        String modifiedVoucher2 = modifiedVoucher.replace('"seguroVidaOnAtivo":true,', '"seguroVidaOnAtivo":true}');
        
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(modifiedVoucher2,
                                                                 200,
                                                                 'OK'));
        testeSnipper.pagOfertas();
        test.stopTest();
    }
    
    @isTest
    static void testFormularioSnipperPagOfertasLista2() {
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(MOCK_CONSULTIVO,
                                                                 200,
                                                                 'OK'));
        
        CtrFormularioSnipper testeSnipper = new CtrFormularioSnipper();  
        
        testeSnipper.EntradaCalculo = MOCK_ENTRADA_CALCULO;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('{"status":"PROCESSADO","servico":"/voucher/consultar-voucher","descricao":"O CPF ainda pode utilizar 2 voucher(s).","dataexecucao":"2024-01-14T23:11:41.177Z","dados":[{"voucher":[{"voucher":"PSSVlL01560A0949B784531","produto":"VIAGEM","datautilizacao":null,"cpf":"331.262.008-26"}],"totalutilizacao":0,"podeutilizar":true}],"codigoprocessamento":0, "mensagemRetorno":"Processamento realizado com sucesso","listaSeguros":{"seguroVida":[{"codigoFormaPagamento":"41","ramo":"1391","listaParcelaSeguroVida":{"parcelaSeguroVida":{"valorParcela":"145.74925","numeroParcela":"1"}},"linkApolice":"http://washmlvidanova/servicosvida/obterApolice?param=MSwxMzkxLDE3ODYxNiw1OCwxMzY1","dataTransmissao":"2023-09-18T00:00:00-03:00","nomeComercialProduto":"Porto Vida ON","nomeSegurado":"DANILLO","inicioVigencia":"2023-08-04T00:00:00-03:00","apolice":"178616","sucursal":"1","finalVigencia":"2024-08-03T00:00:00-03:00","listaBeneficiariosSeguro":{"beneficiarioSeguro":{"percentualDistribuicaoCapital":"100"}},"cpf":"33126200826","listaGarantiasContratadas":{"garantiaContratada":[{"nomeGarantia":"Morte","valorCapital":"40000.0"},{"nomeGarantia":"Invalidez Permanente Total ou Parcial por Acidente","valorCapital":"40000.0"}]},"descricaoFormaPagamento":"FRAC. 1A PARCELA CARNE"},{"codigoFormaPagamento":"41","ramo":"1391","listaParcelaSeguroVida":{"parcelaSeguroVida":{"valorParcela":"145.74925","numeroParcela":"1"}},"linkApolice":"http://washmlvidanova/servicosvida/obterApolice?param=MSwxMzkxLDE3ODYxNiw1OCwxMzY1","dataTransmissao":"2023-09-18T00:00:00-03:00","nomeComercialProduto":"Porto Vida ON","nomeSegurado":"DANILLO","inicioVigencia":"2023-08-04T00:00:00-03:00","apolice":"178616","sucursal":"1","finalVigencia":"2024-08-03T00:00:00-03:00","listaBeneficiariosSeguro":{"beneficiarioSeguro":{"percentualDistribuicaoCapital":"100"}},"cpf":"33126200826","listaGarantiasContratadas":{"garantiaContratada":[{"nomeGarantia":"Morte","valorCapital":"40000.0"},{"nomeGarantia":"Invalidez Permanente Total ou Parcial por Acidente","valorCapital":"40000.0"}]},"descricaoFormaPagamento":"FRAC. 1A PARCELA CARNE"}]},"codigoRetorno":"0","seguroVidaOnAtivo":true}',
                                                                 200,
                                                                 'OK'));
        
        testeSnipper.pagOfertas();
        test.stopTest();
    }
    
    @isTest
    static void testFormularioSnipperPagOfertasLista3() {
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(MOCK_CONSULTIVO,
                                                                 200,
                                                                 'OK'));
        
        CtrFormularioSnipper testeSnipper = new CtrFormularioSnipper();  
        
        testeSnipper.EntradaCalculo = MOCK_ENTRADA_CALCULO;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('{"status":"PROCESSADO","servico":"/voucher/consultar-voucher","descricao":"O CPF ainda pode utilizar 2 voucher(s).","dataexecucao":"2024-01-14T23:11:41.177Z","dados":[{"voucher":[{"voucher":"PSSVlL01560A0949B784531","produto":"VIAGEM","datautilizacao":null,"cpf":"331.262.008-26"}],"totalutilizacao":0,"podeutilizar":true}],"codigoprocessamento":0, "mensagemRetorno":"Processamento realizado com sucesso","listaSeguros":{"seguroVida":{"codigoFormaPagamento":"41","ramo":"1391","listaParcelaSeguroVida":{"parcelaSeguroVida":[{"valorParcela":"145.74925","numeroParcela":"1"},{"valorParcela":"145.74925","numeroParcela":"1"}]},"linkApolice":"http://washmlvidanova/servicosvida/obterApolice?param=MSwxMzkxLDE3ODYxNiw1OCwxMzY1","dataTransmissao":"2023-09-18T00:00:00-03:00","nomeComercialProduto":"Porto Vida ON","nomeSegurado":"DANILLO","inicioVigencia":"2023-08-04T00:00:00-03:00","apolice":"178616","sucursal":"1","finalVigencia":"2024-08-03T00:00:00-03:00","listaBeneficiariosSeguro":{"beneficiarioSeguro":{"percentualDistribuicaoCapital":"100"}},"cpf":"33126200826","listaGarantiasContratadas":{"garantiaContratada":[{"nomeGarantia":"Morte","valorCapital":"40000.0"},{"nomeGarantia":"Invalidez Permanente Total ou Parcial por Acidente","valorCapital":"40000.0"}]},"descricaoFormaPagamento":"FRAC. 1A PARCELA CARNE"}},"codigoRetorno":"0","seguroVidaOnAtivo":true}',
                                                                 200,
                                                                 'OK'));
        
        testeSnipper.pagOfertas();
        test.stopTest();
    }
    
    @isTest
    static void testFormularioSnipperPagOfertasLista4() {
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(MOCK_CONSULTIVO,
                                                                 200,
                                                                 'OK'));
        
        CtrFormularioSnipper testeSnipper = new CtrFormularioSnipper();  
        
        testeSnipper.EntradaCalculo = MOCK_ENTRADA_CALCULO;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('{"status":"PROCESSADO","servico":"/voucher/consultar-voucher","descricao":"O CPF ainda pode utilizar 2 voucher(s).","dataexecucao":"2024-01-14T23:11:41.177Z","dados":[{"voucher":[{"voucher":"PSSVlL01560A0949B784531","produto":"VIAGEM","datautilizacao":null,"cpf":"331.262.008-26"}],"totalutilizacao":0,"podeutilizar":true}],"codigoprocessamento":0, "mensagemRetorno":"Processamento realizado com sucesso","listaSeguros":{"seguroVida":[{"codigoFormaPagamento":"41","ramo":"1391","listaParcelaSeguroVida":{"parcelaSeguroVida":[{"valorParcela":"145.74925","numeroParcela":"1"},{"valorParcela":"145.74925","numeroParcela":"1"}]},"linkApolice":"http://washmlvidanova/servicosvida/obterApolice?param=MSwxMzkxLDE3ODYxNiw1OCwxMzY1","dataTransmissao":"2023-09-18T00:00:00-03:00","nomeComercialProduto":"Porto Vida ON","nomeSegurado":"DANILLO","inicioVigencia":"2023-08-04T00:00:00-03:00","apolice":"178616","sucursal":"1","finalVigencia":"2024-08-03T00:00:00-03:00","listaBeneficiariosSeguro":{"beneficiarioSeguro":{"percentualDistribuicaoCapital":"100"}},"cpf":"33126200826","listaGarantiasContratadas":{"garantiaContratada":[{"nomeGarantia":"Morte","valorCapital":"40000.0"},{"nomeGarantia":"Invalidez Permanente Total ou Parcial por Acidente","valorCapital":"40000.0"}]},"descricaoFormaPagamento":"FRAC. 1A PARCELA CARNE"},{"codigoFormaPagamento":"41","ramo":"1391","listaParcelaSeguroVida":{"parcelaSeguroVida":[{"valorParcela":"145.74925","numeroParcela":"1"},{"valorParcela":"145.74925","numeroParcela":"1"}]},"linkApolice":"http://washmlvidanova/servicosvida/obterApolice?param=MSwxMzkxLDE3ODYxNiw1OCwxMzY1","dataTransmissao":"2023-09-18T00:00:00-03:00","nomeComercialProduto":"Porto Vida ON","nomeSegurado":"DANILLO","inicioVigencia":"2023-08-04T00:00:00-03:00","apolice":"178616","sucursal":"1","finalVigencia":"2024-08-03T00:00:00-03:00","listaBeneficiariosSeguro":{"beneficiarioSeguro":{"percentualDistribuicaoCapital":"100"}},"cpf":"33126200826","listaGarantiasContratadas":{"garantiaContratada":[{"nomeGarantia":"Morte","valorCapital":"40000.0"},{"nomeGarantia":"Invalidez Permanente Total ou Parcial por Acidente","valorCapital":"40000.0"}]},"descricaoFormaPagamento":"FRAC. 1A PARCELA CARNE"}]},"codigoRetorno":"0","seguroVidaOnAtivo":true}',
                                                                 200,
                                                                 'OK'));
        
        testeSnipper.pagOfertas();
        test.stopTest();
    }
    
    @isTest
    static void testFormularioSnipperViagem() {
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(MOCK_CONSULTIVO,
                                                                 200,
                                                                 'OK'));
        
        CtrFormularioSnipper testeSnipper = new CtrFormularioSnipper();  
        
        String modifiedEntradaCalculo = MOCK_ENTRADA_CALCULO.replace('"codigoOfertaConsultiva":"VIAGEM"', '"codigoOfertaConsultiva":"VIAGEM"');
        
        testeSnipper.EntradaCalculo = modifiedEntradaCalculo;
        
        String modifiedVoucher = MOCK_CONSULTA_VOUCHER.replace('"seguroVidaOnAtivo":true,', '"seguroVidaOnAtivo":true}');
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(modifiedVoucher,
                                                                 200,
                                                                 'OK'));
        
        testeSnipper.pagOfertas();
        
        testeSnipper.redirecionarTela();
        
        testeSnipper.entradaCalculo2 = MOCK_ENTRADA_CALCULO2;
        testeSnipper.pagOfertaPersonalizada();
        test.stopTest();
    }
    
    @isTest
    static void testFormularioSnipperPagOfertaPersonalizadaErroNaRequisicao() {
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(MOCK_CONSULTIVO,
                                                                 200,
                                                                 'OK'));
        
        CtrFormularioSnipper testeSnipper = new CtrFormularioSnipper();  
        
        testeSnipper.EntradaCalculo = MOCK_ENTRADA_CALCULO;
        
        String modifiedVoucher = MOCK_CONSULTA_VOUCHER.replace('"seguroVidaOnAtivo":true,', '"seguroVidaOnAtivo":true}');
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(modifiedVoucher,
                                                                 200,
                                                                 'OK'));
        
        testeSnipper.pagOfertas();
        
        testeSnipper.redirecionarTela();
        
        testeSnipper.entradaCalculo2 = MOCK_ENTRADA_CALCULO2;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('Erro na requisição',200,'OK'));
        testeSnipper.pagOfertaPersonalizada();
        test.stopTest();
    }
    
    @isTest
    static void testCtrFormularioSnipperCatch() {
        Test.startTest();
        try {
            
            CtrFormularioSnipper ctr = new CtrFormularioSnipper();
            
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains('ERRO de serviço'));
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCalculoOfertasCatch() {
        String calculosContrats = '{"consultivo": {"codigoOfertaConsultiva": "VIAGEM"}}';
        Test.startTest();
        try {
            
            CtrFormularioSnipper.calculoOfertas(calculosContrats);
            
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains('ERRO de serviço'));
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCalculoOfertaPersonalizadaCatch() {
        String calculosContrats = '{"consultivo": {"codigoOfertaConsultiva": "VIAGEM"}}';
        Test.startTest();
        try {
            
            CtrFormularioSnipper.calculoOfertasPersonalizado(calculosContrats);
            
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains('ERRO de serviço'));
        }
        Test.stopTest();
    }
    
    @isTest
    static void testServicoPaises() {
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(MOCK_CONSULTIVO,
                                                                 200,
                                                                 'OK'));
        
        CtrFormularioSnipper testeSnipper = new CtrFormularioSnipper();  
        testeSnipper.servicosEntrada = '[{"id": "PROFISSAO","servico": "paises"}]';
        testeSnipper.consultaOpcoesTipoServico();
        test.stopTest();
    }
    
    @isTest
    static void testServicoConsultaBanco() {
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(MOCK_CONSULTIVO,
                                                                 200,
                                                                 'OK'));
        
        CtrFormularioSnipper testeSnipper = new CtrFormularioSnipper();  
        testeSnipper.servicosEntrada = '[{"id": "PROFISSAO","servico": "Consulta_Banco"}]';
        testeSnipper.consultaOpcoesTipoServico();
        test.stopTest();
    }
    
    @isTest
    static void testReutilizarDadosOutrasGarantias() {
        
        List<Garantia__c> garantias = [SELECT Id, Sigla__c FROM Garantia__c];
        for(Garantia__c garantia : garantias){
            garantia.Sigla__c = garantia.Sigla__c + 'test';
        }
        update garantias;
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(MOCK_CONSULTIVO,
                                                                 200,
                                                                 'OK'));
        
        CtrFormularioSnipper testeSnipper = new CtrFormularioSnipper();  
        
        testeSnipper.EntradaCalculo = MOCK_ENTRADA_CALCULO;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(MOCK_CONSULTA_VOUCHER + MOCK_RECUSAS + '}',
                                                                 200,
                                                                 'OK'));
        
        testeSnipper.pagOfertas();
        testeSnipper.redirecionarTela();
        testeSnipper.entradaCalculo2 = MOCK_ENTRADA_CALCULO2;
        testeSnipper.dataConvivencia = 'DATA_PREMREC';
        testeSnipper.pagOfertaPersonalizada();
        testeSnipper.servicosEntrada = '[{"id": "PROFISSAO","servico": "profissoes/consulta"}]';
        testeSnipper.consultaOpcoesTipoServico();
        testeSnipper.redirecionaEndossoPage(); 
        testeSnipper.redirecionaEndossoViagemPage();
        string entrada = MOCK_ENTRADA;
        PageReference page = Page.formularioSniper;       
        Test.setCurrentPage(page);
        ApexPages.currentPage().getParameters().put('dados', entrada);         
        testeSnipper.reutilizarDados();
        test.stopTest();
    }

    //ANNVI-170 - INICIO
    @IsTest
    static void testarConsultarDadosPessoaBCP(){

        Boolean isException = false;
        String json = '{ "codigoPapel": "12345", "dataNascimento": "01-01-1990", "emails": [ { "dataAtualizacaoEmail": "01-01-2022", "email": "exemplo@email.com", "numseq": 1, "tipoEmail": "TRABALHO" } ], "enderecos": [ { "bairro": "Centro", "cep": "12345-678", "cidade": "São Paulo", "codigoFinalidade": 1, "complemento": "Bloco A, Apt 123", "cplcepnum": "123456789", "descricaoFinalidade": "Residencial", "latitude": "123.456", "logradouro": "Rua Exemplo", "longitude": "789.012", "numero": "123", "pais": "Brasil", "tipoLogradouro": "Rua", "uf": "SP" } ], "estadoCivil": 1, "nome": "Fulano de Tal", "nomeMae": "Maria Silva", "nomePai": "João Silva", "nomePapel": "Papel Exemplo", "nomeSocial": "Fulano de Souza", "nomeTratamento": "Sr. Fulano", "numDocumento": "12345678900", "pescod": 1, "sexo": "M", "telefones": [ { "codigo": 1, "ddd": 11, "ddi": 55, "numero": 987654321, "seqnum": 1, "tipo": "CELULAR" } ], "tipoDocumento": "CPF", "tipoPessoa": "Física", "titularidadeDocumento": "Próprio", "vinculoCorretora": [ { "codigoSusep": "123456", "fimRelacionamento": "01-01-2023", "inicioRelacionamento": "01-01-2022", "seqnum": 1 } ] }';

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(json, 200, 'OK'));

        Test.startTest();

        try{
            CtrFormularioSnipper.consultarDadosPessoaBCP();
        } catch(Exception e){
            isException = true;
        }

        Test.stopTest();

        System.assertEquals(false, isException);        
    }
    //ANNVI-170 - FIM    
}