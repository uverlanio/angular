/*********************************************************************************************************************************************************************

@description  Classe que contem a Controller para o Formulario.
@author Renan Martins - Avanxo
@date 03/06/2019
@Hackathon Sniper Atualização 03/06/2019
@Classe criada por conta da história PLV-2318
        
**********************************************************************************************************************************************************************/

@isTest
public class FormularioSniperTest {
    
     @TestSetup
     static void setupUnit(){
        //PLV-5441 - INICIO
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
            BillingPostalCode = '09180320' //VIDA-179 - INICIO/FIM

        );
        insert conta;

        //VIDA-179 - INICIO
        Opportunity orcamento = new Opportunity(
            AccountId = conta.Id,
            StageName = 'Em criação',
            Name = 'SFC-00068615',
            CloseDate = System.today().addDays(1),
            Numero__c = '00005555'
        );
        insert orcamento;

        //VIDA-179 - FIM


        //TKCL-246 FIX05 INICIO
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
        //TKCL-246 FIX05 FIM

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
            Conta__c = conta.Id
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


        //VIDA-179 - INICIO
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
        //VIDA-179 - FIM
     }    
    
    // AV-85 INICIO
    @isTest
    static void testFormularioSnipper() {

        //VIDA-179 - INICIO
        test.startTest();
		
        /*
        Test.setMock(HttpCalloutMock.class,
            new MultiRequestMock(
                new Map<String, HttpCalloutMock>{
                    'http://testes.portoseguro.com.br/fake-endpoint' => new SingleRequestMock(200, 'OK','{"consultivo":{"codigoOfertaConsultiva":"SNIPER","canalDistribuicao":"COR","susepCorretor":"S5005J","meioComercializacao":"Backoffice","conjuntos":[{"id":1,"titulo":"Simulação de Seguro de Vida","subtitulo":"Para simular seu seguro, você só precisa preencher algumas informações.","informacoes":[{"id":"TIPOCONTRATO","nome":"Tipo de Contrato","descricao":"Selecione seu tipo de contrato","tipo":"Opções fixas","obrigatorio":true,"opcoes":[{"codigo":"VOCE","rotulo":"Plano para você"},{"codigo":"FAMILIA","rotulo":"Plano para sua família"},{"codigo":"TODOS","rotulo":"Plano para todos"}]}],"regrasSequencia":[{"sequencia":1,"proximoConjunto":2}]},{"id":2,"titulo":"Simulação de Seguro de Vida","subtitulo":"Preencha as informações básicas.","informacoes":[{"id":"NOMECOMPLETO","nome":"Teste mockado","tipo":"Texto","obrigatorio":true},{"id":"NASCIMENTO","nome":"Nascimento","tipo":"Data","obrigatorio":true},{"id":"SEXO","nome":"Sexo","tipo":"Opções fixas","obrigatorio":true,"opcoes":[{"codigo":"MASC","rotulo":"Masculino"},{"codigo":"FEM","rotulo":"Feminino"}]},{"id":"FUMANTE","nome":"Fumante","tipo":"Booleano","obrigatorio":true},{"id":"ESTADOCIVIL","nome":"Estado civil","tipo":"Opções fixas","obrigatorio":true,"opcoes":[{"codigo":"SOL","rotulo":"Solteiro"},{"codigo":"CAS","rotulo":"Casado"},{"codigo":"DIV","rotulo":"Divorciado"},{"codigo":"VIU","rotulo":"Viúvo"}]},{"id":"PROFISSAO","nome":"Profissão","tipo":"Opções de serviço","servico":"/consultas/profissao/","obrigatorio":true}],"regrasSequencia":[{"sequencia":1,"proximoConjunto":3}]},{"id":3,"titulo":"Referência para o valor do seguro","subtitulo":"Você pode alterar o valor do seguro depois. Isso é só para iniciarmos.","informacoes":[{"id":"RENDAMENSAL","nome":"Renda mensal","descricao":"Qual sua faixa de renda mensal?","tipo":"Opções fixas","obrigatorio":true,"opcoes":[{"codigo":"0-4000","rotulo":"Até R$ 4.000,00"},{"codigo":"4001-8000","rotulo":"De R$ 4.000,01 a R$ 8.000,00"},{"codigo":"8001-12000","rotulo":"De R$ 8.000,01 a R$ 12.000,00"},{"codigo":"12001-16000","rotulo":"De R$ 12.000,01 a R$ 16.000,00"},{"codigo":"16001-infinito","rotulo":"Acima de R$ 16.000,00"}]}]}]}}', null),
                    'http://testes.portoseguro.com.br/fake-endpoint2' => new SingleRequestMock(200, 'OK','{"status":"PROCESSADO","servico":"/voucher/consultar-voucher","descricao":"O CPF ainda pode utilizar 2 voucher(s).","dataexecucao":"2024-01-14T23:11:41.177Z","dados":[{"voucher":[{"voucher":"PSSVlL01560A0949B784531","produto":"VIAGEM_VIDA_ON","datautilizacao":null,"cpf":"331.262.008-26"}],"totalutilizacao":0,"podeutilizar":true}],"codigoprocessamento":0}', null),
                    'http://testes.portoseguro.com.br/fake-endpoint3' => new SingleRequestMock(200, 'OK','{"mensagemRetorno":"Processamento realizado com sucesso","listaSeguros":{"seguroVida":{"codigoFormaPagamento":"41","ramo":"1391","listaParcelaSeguroVida":{"parcelaSeguroVida":{"valorParcela":"145.74925","numeroParcela":"1"}},"linkApolice":"http://washmlvidanova/servicosvida/obterApolice?param=MSwxMzkxLDE3ODYxNiw1OCwxMzY1","dataTransmissao":"2023-09-18T00:00:00-03:00","nomeComercialProduto":"Porto Vida ON","nomeSegurado":"DANILLO","inicioVigencia":"2023-08-04T00:00:00-03:00","apolice":"178616","sucursal":"1","finalVigencia":"2024-08-03T00:00:00-03:00","listaBeneficiariosSeguro":{"beneficiarioSeguro":{"percentualDistribuicaoCapital":"100"}},"cpf":"33126200826","listaGarantiasContratadas":{"garantiaContratada":[{"nomeGarantia":"Morte","valorCapital":"40000.0"},{"nomeGarantia":"Invalidez Permanente Total ou Parcial por Acidente","valorCapital":"40000.0"}]},"descricaoFormaPagamento":"FRAC. 1A PARCELA CARNE"}},"codigoRetorno":"0","seguroVidaOnAtivo":true}',null)
                }
            )
        );


        CtrFormularioSnipper testeSnipper = new CtrFormularioSnipper();   
        */     

        // testeSnipper.EntradaCalculo = '{"orcamento":null,"consultivo":{"codigoOfertaConsultiva":"VIAGEM_VIDA_ON","canalDistribuicao":"COR","identificadorRepresentante":"P5005J","meioComercializacao":"SFC","respostas":[{"id":"TIPOCONTRATO","conteudo":"VOCE"},{"id":"DICIO_NOME","conteudo":"FRANCIS LIU"},{"id":"DICIO_CPFVOUCHER","conteudo":"867.213.059-68"},{"id":"DICIO_VOUCHER","conteudo":"PSSVlL01560A0949B784531"},{"id":"TIPO_VIAGEM","conteudo":"NACIONAL"},{"id":"ORIGEM","conteudo":"Brasil"},{"id":"DESTINO","conteudo":"Brasil"},{"id":"DICIO_DATA_SAIDA","conteudo":"2021-09-22"},{"id":"DICIO_DATA_RETORNO","conteudo":"2021-09-25"},{"id":"DICIO_QTD_JOVENS","conteudo":"1"},{"id":"DICIO_QTD_IDOSOS","conteudo":"0"},{"id":"TIPOCONTRATO","conteudo":"VOCE"}]}}'; 
        // //VIDA-179 - FIM
       

        // testeSnipper.pagOfertas();
        // testeSnipper.redirecionarTela();
        // testeSnipper.entradaCalculo2 = '{"orcamento":{"tipoVigencia":"Periódico","ramoSeguro":0,"tipoSeguro":"Novo","vigenciaFinal":"2024-08-03","qtdDiasVigencia":366,"customizavel":true,"canalDistribuicao":"COR","viagem":null,"varConsultivo":true,"idProdutoSf":"01tL0000007NvMjIAK","ordemPortal":1,"rotulo":"Vida Mais 2_teste","susepOrcamento":"P5005J","remuneracoes":[{"percentual":0,"tipoRemuneracao":"AGENCIAMENTO"},{"percentual":10,"tipoRemuneracao":"CORRETAGEM"}],"dataCalculo":"2023-08-04","numeroPortal":0,"codigoProdutoVida":"VI-PESSOAS","contratantes":[{"tipo":"PRI","numero":1,"grupos":[{"numero":1,"segurados":[{"pessoa":{"tipo":"FIS","enderecos":[{"uf":" ","cidade":" ","complemento":" ","logradouro":" ","bairro":" ","complementoCep":" ","paisResidencia":" ","tipoEndereco":" ","numeroLogradouro":" ","cep":" "}],"nome":"FRANCIS LIU","dadosPessoaFisica":{"grupoProfissao":"DIT-A","cicloVacinal":"1","profissao":"2111-05","temDependentes":true,"tipoContrato":"VOCE","tempoGarantiaRenda":"48","dataNascimento":"1964-05-22","sexo":"MASCULINO","fumante":true,"regimeTrabalho":"CLT","renda":"4000"},"email":""},"numero":1,"coberturas":[{"caracteristica":"Principal","limitemaximo":"10000000","limiteminimo":"30002","moeda":"BRL","sigla":"BAS","valor":"30002.00","franquia":"FR_NORMAL","caracteristicaespecialvalor":"1","caracteristicaespecialtipo":"Ano(s)"},{"caracteristica":"Serviço complementar","limitemaximo":"0","limiteminimo":"0","moeda":"BRL","sigla":"TELEMED","valor":"0.00"}]}],"nome":"FRANCIS LIU","qtdeVidas":1,"coberturas":[{"caracteristica":"Principal","limitemaximo":"10000000","limiteminimo":"30002","moeda":"BRL","sigla":"BAS","valor":"30002.00","franquia":"FR_NORMAL","caracteristicaespecialvalor":"1","caracteristicaespecialtipo":"Ano(s)"},{"caracteristica":"Serviço complementar","limitemaximo":"0","limiteminimo":"0","moeda":"BRL","sigla":"TELEMED","valor":"0.00"}]}]}],"meioComercializacao":"SFC","segmento":"Individual","gerarDocumento":false,"vigenciaInicial":"2023-08-04"},"consultivo":null}'; //RVI-202 INICIO/FIM
        // testeSnipper.pagOfertaPersonalizada();
        
        // testeSnipper.servicosEntrada = '[{"id": "PROFISSAO","servico": "profissoes/consulta"}]';
        // testeSnipper.consultaOpcoesTipoServico();
        
        // testeSnipper.redirecionaEndossoPage(); //PLV-4600
        // testeSnipper.redirecionaEndossoViagemPage(); //PLV-4600
        
        // string entrada = '{"consultivo":{"codigoOfertaConsultiva":"VIDA_INDIVIDUAL","canalDistribuicao":"COR","identificadorRepresentante":"P5005J","meioComercializacao":"Portal","entradaNegocio":"CO2","voltar":false,"nProposta":"18-00037715"},"acao":"CONTRATAR"}';
        // PageReference page = Page.formularioSniper;       
        // Test.setCurrentPage(page);
        // ApexPages.currentPage().getParameters().put('dados', entrada);         
        // testeSnipper.reutilizarDados();

        // testeSnipper.numOrcamentos = '[\"00005555\"]';
        // testeSnipper.gravaJsonCompleto();
        // testeSnipper.jsonResponseCalculo = '{}';
        // testeSnipper.localStorage = '{}';

        // testeSnipper.resetOfertas();

        // //VIDA-179 - INICIO
        // testeSnipper.paramsToReturn = '{"numOrcamento":"00005555","tarefa":1}';
        // testeSnipper.buscarJsonContentDocument();
        //VIDA-179 - FIM


        test.stopTest();
    }
     // AV-85 FIM

    static HttpResponse gerarLinkMock() {
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{\"link\":\"http://app-dev.meios-de-pagamentos.portoseguro.s3-website.ca-central-1.amazonaws.com?data=AQICAHg_3WC1eSAPTTTU0Jo_iH07EZaNzA4GGCEnvYh4-g_xIgEKEazwO8X9y1V42VvwxdjUAAAEmjCCBJYGCSqGSIb3DQEHBqCCBIcwggSDAgEAMIIEfAYJKoZIhvcNAQcBMB4GCWCGSAFlAwQBLjARBAxmq4uPmTT5x-kGYo8CARCAggRN4clqr_2hZwQy43fM5LxpSdKx_3DVeCmR-JbAxehFnyg7JPXWcrsUI1omvaFzGDemc5RKdAqYjpMSweastGu8aoDd-6c70Cushqo3yMvuRKzM9YOaANyoGqkIshOxjqw3Oad9kD-ImCRrB--6WwqXs7hs6vHs50TutAgu8ZzaGI6JqFjJEuS5h6aPtPUnKUg6d_PzMItRvhYNPqqJBz8vQaoAHWPfAc_xLN_l44gipMojUpOduYX6MVNn6Vd3tjIbc6m_Hd_h-HD7e0XAtbUg0noHnpTllXo5FvZnyAhyqJyM6tHLI8zLMrnbYuisQc5TIMBok3ZExzv55aGgRDiULSUB7_PGVdiypHF8DyFq4bt6Ky1ydfK33rG-Q_5XqtNSr0Y6Xon9cmq_odgGdX5dnQU46AXZCH4Ow8Qpd19MoaT-NlUQSrQD2bR-4HZ8Yq1LkZmr-rURdl0S7en8l3bggrnvV1xHiwdkT7EMUWb0t1olCaZX-Wb0Mk5Uu-hDetBFieMmbX89m-UHjrphbpYNLaeneg0nS5aa2bN6uWd4wuzjdGUwXcQDmaiMaDKQuvYDMVb7h2SECVj-_WR1a9tcG-BJvhvFMAzKdV0CgA9bs1nvCbVnr7QtouN2wXs_WErzbObp4rjfZLw4oDdZ0RxhMMogA9ptN2XMxJNQJ21ldcPIjnrrSE8I5KxdjGzXtdMdhRRiC6YelDdUPBY4lLpN82hxIpzLPou2YRz7_YYdNy9yg2IC-7DsoPasscposP7lBOPwR53lJQ2eLctoxdkjKVNjGQrvCmEmFD781nMYnopaWee4yG8VeLXcQW6kp65-N5A_F9TNBAJSPA8-UtLvmLoQ5qIJwV5fPV1_CddU8ec0KU0ihGAPyBOwlcnNmjHfbhA48CrcbmCZJ7iKZMQIcJilSv6o9JS8RzH0HISt-1GfbjRlpYq11aquOBPfqhfhTZ1xz3lBZXdwKK-eh8ZlDUAanrPnjJNKipN_kuiAFVLJhb8J6rRd01IpC8hp-xezj2FAd75PR4na6KLNdFGSkGTneUH4d9EJgSSyBlsLDBQbI85DloFp6_BS_vkS1eU1er_aBD_SS-gfrUnuMtopjUYhKWDVue_Rqzb1doVw7bAxa6C-NmypKSa-0dkGYvgbh6FQsQyttAzmwDZGup8rwxX--DBFGlJhoC50qF0mfWm0LgYwt6OOfl6H4VWooTUlbMi8w5IfImCO6IIWrcORkggn2FRDI8Q_qAMzsV51WBEgeEFNNILO1iocNxYg8Jhh3h7Q34bgwSiMz7CUMlKvuWa8ZYhz8wmwB7x1gul1czOCY1YigeBXxQWagm5pm7ZoAfAmu4nK0GhUxgIrCmo0i6fA7nqEZUg97NeE3lYiFfgdNe28Jot7glTmNplLsNGjQq5FOR_5rwAWVWSUg3bbS8AyJRIz-zakbOEe7qLkUQlamlEIuSCnyAzsMK4f&token=eyJhbGciOiJIUzI1NiJ9.eyJsaW5rSWQiOiIyMWVkYjliNy01YTA2LTM5MDYtODM4NC0zZDdhN2JkMTJiODAiLCJleHAiOjE2NTUyNDMyMDB9.bEEjjx58dWzPL9K_ZoreqVn6Tf4sHHoNdaUd0QFhtaE\"}');
        response.setStatusCode(200);

        return response;
    }

      //PLV-2411-Sniper - Início - Lógica para tratamento de exceção.
    //PLV-2607 - Inicio
      @isTest
     static void testFormularioSnipperJsonRecusa() {
         /*
         test.startTest();
         
         //Referente a Pagina formularioSniper
         //Chamada do Método pagOfertas
         
         String	XmlRecusa = '{ '+
	                            +'"recusas":['+ 
	                        +'{'+ 
		                        +'"codigo":1, '+  
		                        +'"mensagens":{ '+ 
			                        +'"cliente":"Prezado cliente, favor selecionar todas as garantias obrigátorias"'+ 
		                        +'}'+ 
	                        +'}]'+ 
                        +'}';

         Test.setMock(HttpCalloutMock.class, new MockHttpResponse(XmlRecusa, 200, 'OK'));
         System.debug('Variável para forçar o recusa -> XmlRecusa: ' + XmlRecusa);
         
        //  CtrFormularioSnipper.calculoOfertas('teste');         
         //PageReference page = Page.formularioSniper;          
         //Test.setCurrentPage(page);
         
     //PLV2533 - INÍCIO - Alterações da lógica para chamada do CIV Consultivo    
        //CtrFormularioSnipper.consultaProfissao('servico');
     //PLV2533 - FIM - Alterações da lógica para chamada do CIV Consultivo
         
        //Chamada dos Métodos da Classe CtrFormularioSnipper
        //Inicio da lógica para a história - PVL 2389  
         //testeSnipper.pagOfertas();
         //testeSnipper.redirecionarTela();         
         //testeSnipper.pagOfertaPersonalizada();
         
        //Fim da lógica para a história - PVL 2389  
        //PLV-2607 - Fim
         test.stopTest();
         */

     }
    	//PLV-2411-Sniper - Fim - Lógica para tratamento de exceção. 

    //PLV-2607 - Inicio
       @isTest
     static void testFormularioSnipperJsonNulo() {
         /*
         test.startTest();
         
         //Referente a Pagina formularioSniper
         //Chamada do Método pagOfertas
         String	XmlNulo = 'Erro na requisição';

         Test.setMock(HttpCalloutMock.class, new MockHttpResponse(XmlNulo, 406, 'OK'));
         System.debug('Variável para forçar o erro -> XmlNulo: ' + XmlNulo);
         
         try{ 
         CtrFormularioSnipper testeSnipper = new CtrFormularioSnipper();        
         PageReference page = Page.formularioSniper;          
         Test.setCurrentPage(page);
         

         testeSnipper.pagOfertas();
         testeSnipper.redirecionarTela();         
         testeSnipper.pagOfertaPersonalizada();
         }catch(Exception e){
             System.debug('Caiu no catch do teste.');
         }
         test.stopTest();
         */

     } 
    //PLV-2607 - Fim
	
    //PLV-4921 - INICIO
    //RVI-202 DESCOMENTADO PARA SUBIR PERCENTUAL DE TESTE 
    @isTest
    static void testGrupoMdt(){
        /*
        test.startTest();
        List<Constante__mdt> constante = [	SELECT Label FROM Constante__mdt LIMIT 1];
        if(constante.size() > 0){
             CtrFormularioSnipper.buscaMetaGrupo(constante[0].Label);
        }
		test.stopTest();*/
    }
    //RVI-202 DESCOMENTADO PARA SUBIR PERCENTUAL DE TESTE
    //PLV-4921 - FIM

    //VIDA-179 - INICIO
    public class MultiRequestMock implements HttpCalloutMock {
        Map<String, HttpCalloutMock> requests;
    
        public MultiRequestMock(Map<String, HttpCalloutMock> requests) {
            this.requests = requests;
        }
    
        public HttpResponse respond(HTTPRequest req) {
        HttpCalloutMock mock = requests.get(req.getEndpoint());
            if (mock != null) {
                return mock.respond(req);
                } else {
                 throw new MyCustomException('HTTP callout not supported for test methods');
            }
        }
    
        public void addRequestMock(String url, HttpCalloutMock mock) {
            requests.put(url, mock);
        }
    }
    
    public class MyCustomException extends Exception { }	

    public class SingleRequestMock implements HttpCalloutMock {
        protected Integer code;
        protected String status;
        protected String bodyAsString;
        protected Blob bodyAsBlob;
        protected Map<String, String> responseHeaders;

        public SingleRequestMock(Integer code, String status, String body,
                                        Map<String, String> responseHeaders) {
            this.code = code;
            this.status = status;
            this.bodyAsString = body;
            this.bodyAsBlob = null;
            this.responseHeaders = responseHeaders;
        }

        public SingleRequestMock(Integer code, String status, Blob body,
                                        Map<String, String> responseHeaders) {
            this.code = code;
            this.status = status;
            this.bodyAsBlob = body;
            this.bodyAsString = null;
            this.responseHeaders = responseHeaders;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(code);
            resp.setStatus(status);
            if (bodyAsBlob != null) {
                resp.setBodyAsBlob(bodyAsBlob);
            } else {
                resp.setBody(bodyAsString);
            }

            if (responseHeaders != null) {
                for (String key : responseHeaders.keySet()) {
                resp.setHeader(key, responseHeaders.get(key));
                }
            }
            return resp;
        }
    }
    //VIDA-179 - FIM

}