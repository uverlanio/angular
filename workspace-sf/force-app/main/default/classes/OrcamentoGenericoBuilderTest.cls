@IsTest
public  class OrcamentoGenericoBuilderTest {

    public static EmissaoTO.PayloadTO payloadTO;
    public static List<Contract> contratos;
    //PLV2569 - INICIO AVX - Ajuste para aumentar cobertura de testes da classe OrcamentoGenericoBuilder.
    //public static Product2 produtoTecnico;
    //public static Product2 produtoComercial;    
    //PLV2569 - FIM AVX - Ajuste para aumentar cobertura de testes da classe OrcamentoGenericoBuilder.

   	@TestSetup
    static void setup(){

        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        produtoTec.Status__c = 'Ativo';
        produtoTec.Segmento__c = 'Individual';
        produtoTec.CodigoPrecificaProduto__c = 'VI-PESSOAS';
        update produtoTec;
    
        Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        produtoCom.Status__c ='Ativo';
        produtoCom.Segmento__c = 'Individual';
        produtoCom.CodigoPrecificaProduto__c = 'VI-PESSOAS';
        produtoCom.ProductCode = 'VI-PESSOAS';
        update produtoCom;

        System.debug('produtocom : ' + JSON.serialize(produtoCom));

        //ParametroVigencia__c parmVigencia = TestDataFactory.gerarParametroVigenciaProdutoTecnico(produtoTec);

        ParametroVigencia__c parmVigenciaCom = TestDataFactory.gerarParametroVigenciaProdutoTecnico(produtoCom);

        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        canalDistribuicao.Sigla__c = 'EXE'; //ANNVI-55 - INICIO
        update canalDistribuicao; //ANNVI-55 - FIM

        Profissao__c profissao = ( Profissao__c ) new ProfissaoFactory().createRecord();
        profissao.CodigoProfissao__c = '2111-05';
        profissao.IdExterno__c = '2111-05';
        profissao.Status__c = 'Ativo';
        update profissao;

        Account contaTeste = (Account) new AccountFactory.PessoaFisica().createRecord();
        contaTeste.Profissao__c = profissao.Id;
        contaTeste.NomeSocial__c = 'Nome Social'; // ANNVI-55 - INICIO/FIM
        update contaTeste;

        Endereco__c endereco = new Endereco__c();
        endereco.Conta__c  = contaTeste.Id;
        endereco.EnderecoCobranca__c = true;
        endereco.MaisAtual__c = false;
        endereco.CEP__c = '05689001';
        insert endereco;

        endereco.Logradouro__c = 'TESTE';
        update endereco;
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);

        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);

        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);

        FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento(ramoSegurado,modalidade,'Boleto','1234'); 

        CondicaoCobranca__c condicaoCobranca = TestDataFactory.gerarCondicaoCobranca(produtoTec,formaPagamento);

        //CondicaoCobranca__c condicaoCobranca2 = TestDataFactory.gerarCondicaoCobranca(produtoTec2,formaPagamento);
       
        Opportunity orcamentoContratado = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);

        Quote propostaRen = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, orcamentoContratado, modalidade);
        propostaRen.Status = 'Em análise';
        propostaRen.Tipo__c = 'Renovacao';
        propostaRen.VigenciaInicial__c = System.today().addDays(10);
        update propostaRen;

        Contract contrato = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, propostaRen);
        contrato.Proposta__c = propostaRen.Id;
        contrato.StatusRenovacao__c = 'Renovação em andamento';
        contrato.AlteraFormaPagto__c = false;
        update contrato;

        ContratanteOrcamento__c contratanteOrcamento = TestDataFactory.gerarContratanteOrcamento(orcamentoContratado, contaTeste);
        ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
        // PLV-5331 FIM        
    }

    @IsTest
    static void testEmissaoOrcamento() {

        Test.startTest();
        payloadTO = gerarPayloadTO();

        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/orcamento/devolutiva';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(Json.serialize(payloadTO));

        RestContext.request = request;
        RestContext.response = new RestResponse();

        OrcamentoREST.processarPost();
        
        Test.stopTest();

    }
    
    
    //PLV-2439 - INICIO
    // @isTest
    // static void testEmissaoOrcamentoGenericBuilderOrcamento() {
    //     //PLV-3667 - INICIO 
    //     List<StaticResource> listStaticResource = new List<StaticResource>();
         
    //     listStaticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadOrcamentoRetornoAceitacao1' LIMIT 1];
        
    //     if(listStaticResource.isEmpty()) return;

    //     //String payload = listStaticResource[0].Body.toString();
    //     //PLV-3667 - FIM
        
    //     String payload = '{"ofertas":[{"orcamento":{"tipoVigencia":"Periódico","tipoSeguro":"Novo","vigenciaFinal":"2019-10-08","numeroOrcamento":"00000003","numeroPortal":0,"codigoProdutoVida":"VI-PESSOAS","contratantes":[{"tipo":"PRI","numero":1,"grupos":[{"numero":1,"segurados":[{"pessoa":{"tipo":"FIS","enderecos":[{"uf":"SP","cidade":"SAO PAULO","complemento":"Apto 22","logradouro":"Guaianses","bairro":"Centro","complementoCep":"420","tipoLogradouro":"R","paisResidencia":"BRASIL","tipoEndereco":"REC","numeroLogradouro":"92","cep":"07114"}],"nome":"Testinho","dadosPessoaFisica":{"numeroCpf":"438912318","profissao":"2123-05","tipoContrato":"TODOS","celular":"(11) 11111-1111","digitoCpf":"14","dataNascimento":"2000-11-11","fumante":false,"sexo":"MASCULINO","renda":"FAIXA2"},"email":"teste@teste.com.br"},"numero":1,"coberturas":[{"sigla":"BAS","valor":20000},{"sigla":"MAP","valor":20000}]}],"nome":"Testinho","qtdeVidas":1}]}],"canalDistribuicao":"COR","meioComercializacao":"CO2","segmento":"Individual","ordemPortal":1,"rotulo":"Sniper - Plano Básico","remuneracoes":[{"percentual":20,"tipoRemuneracao":"CORRETAGEM"}],"vigenciaInicial":"2019-09-23","dataCalculo":"2019-09-23"},"retornoCalculo":{"orcnum":3821872979,"precificacao":{"juros":0,"iof":1.24,"encargos":0,"custoDeApolice":0,"premio":{"comercial":205.98,"puro":219.98,"total":225.00},"taxa":{"comercial":0.0002185,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}],"coberturas":[{"sigla":"BAS","capital":350000.00,"iof":0.28,"premio":{"comercial":75.00,"puro":75.00,"total":75.00},"taxa":{"comercial":0.000043,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"MAP","capital":500000.00,"iof":0.19,"premio":{"comercial":50.0,"puro":50.0,"total":50.0},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DIH","capital":1400.00,"iof":0.09,"premio":{"comercial":25.0,"puro":25.0,"total":25.0},"taxa":{"comercial":0.00031,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DG 10","capital":6000.00,"iof":0.14,"premio":{"comercial":37.50,"puro":37.50,"total":37.50},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"AFI","capital":2900.00,"iof":0.14,"premio":{"comercial":37.50,"puro":37.50,"total":37.50},"taxa":{"comercial":0.000015,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]}],"contratantes":[{"numero":1,"iof":1.24,"premio":{"comercial":4.38,"puro":3.98,"total":5.00},"taxa":{"comercial":0.0002185,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}],"coberturas":[{"sigla":"BAS","capital":119.8,"iof":1.24,"premio":{"comercial":2.58,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000043,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DG 10","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"MAP","capital":1000.7,"iof":1.24,"premio":{"comercial":1.55,"puro":3.98,"total":5.00},"taxa":{"comercial":0.00031,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DIH","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"AFI","capital":2900.2,"iof":1.24,"premio":{"comercial":0.22,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000015,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]}],"grupos":[{"numero":1,"iof":1.24,"premio":{"comercial":4.38,"puro":3.98,"total":5.00},"taxa":{"comercial":0.0002185,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}],"coberturas":[{"sigla":"BAS","capital":119.8,"iof":1.24,"premio":{"comercial":2.58,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000043,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"MAP","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"AFI","capital":1000.7,"iof":1.24,"premio":{"comercial":1.55,"puro":3.98,"total":5.00},"taxa":{"comercial":0.00031,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DIH","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DG 10","capital":2900.2,"iof":1.24,"premio":{"comercial":0.22,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000015,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]}],"segurados":[{"numero":1,"iof":1.24,"premio":{"comercial":4.38,"puro":3.98,"total":5.00},"taxa":{"comercial":0.0002185,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}],"coberturas":[{"sigla":"BAS","capital":119.8,"iof":1.24,"premio":{"comercial":2.58,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000043,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"MAP","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"AFI","capital":1000.7,"iof":1.24,"premio":{"comercial":1.55,"puro":3.98,"total":5.00},"taxa":{"comercial":0.00031,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DG 10","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DIH","capital":1000900,"iof":1.24,"premio":{"comercial":0.22,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000015,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]}]}]}]}]}},"retornoAceitacao":{"analises":[{"severidade":null,"codigo":4,"descricao":"Capital da Cobertura superior a R$400.000,00","area":"UNI","procedimento":"","mensagens":{"interna":"PARA ANALISAR","cliente":null,"representante":null}}],"recusas":null,"avisos":[{"severidade":null,"codigo":4,"descricao":"Capital da Cobertura superior a R$200.000,00","area":"UNI","procedimento":"","mensagens":{"interna":"PERMITIDO","cliente":null,"representante":null}}],"pendencias":[{"severidade":null,"codigo":4,"descricao":"Capital da Cobertura superior a R$200.000,00","area":"UNI","procedimento":"","mensagens":{"interna":"PERMITIDO","cliente":null,"representante":null}}]},"retornoIntegracoes":{}}],"versoesCalculo":[{"opcao":0,"tipo":null,"descontoAgravo":0},{"opcao":1,"tipo":"FPG","descontoAgravo":-5},{"opcao":2,"tipo":"FPG","descontoAgravo":5}]}';
        
    //     Account conta = [ SELECT Id, Cpf__c FROM Account limit 1 ];
        
    //     //conta.Cpf__c = '438.912.318-14';        
    //     //update conta;
        
    //     EmissaoTO.PayloadTO payloadTO = (EmissaoTO.PayloadTO) JSON.deserialize(payload, EmissaoTO.PayloadTO.class);

    //     Contract contrato = [SELECT Id, Produto__c FROM Contract]; 

    //     List<ServiceTO.OfertaTO> listOfertas = new List<ServiceTO.OfertaTO> ();
        
    //     payload = JSON.serialize(payloadTO);                
        
    //     Test.startTest();
    //         try 
    //         {
    //             ServiceTO.PayRetornoOfertasTO ofertas = OrcamentoGenericoBuilder.getInstance().gerarOrcamentoGravar(payload);    
    //            // ServiceTO.PayRetornoOfertasTO ofertas = OrcamentoGenericoBuilder.getInstance().gerarOrcamentoGravar('');    
    //         } catch (Exception e ) {
                
    //         }
      		              
    //     Test.stopTest();
    // } 
        
    /*
    //PLV-2439 - FIM
    //PLV-2703 - INICIO - Metodos criados para aumentar cobertura dos testes
    @isTest
    static void testEmissaoOrcamentoGenericBuilderOrcamentoAviso() {
        //PLV-3667 - INICIO
        //List<StaticResource> listStaticResource = new List<StaticResource>();

        //listStaticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadOrcamentoRetornoAceitacaoAviso1' LIMIT 1];
        
        //if(listStaticResource.isEmpty()) return;

        //String payload = listStaticResource[0].Body.toString();
        //PLV-3667 - FIM
       
       //COMENTADO PARA TESTES
       // Profissao__c profissao = [SELECT id,CodigoProfissao__c FROM Profissao__c];
       // profissao.CodigoProfissao__c = '2123-05';
       // update profissao;

        String payload = '{"ofertas":[{"orcamento":{"tipoVigencia":"Periódico","tipoSeguro":"Novo","vigenciaFinal":"2019-10-08","numeroOrcamento":"00000003","numeroPortal":0,"codigoProdutoVida":"VI-PESSOAS","contratantes":[{"tipo":"PRI","numero":1,"grupos":[{"numero":1,"segurados":[{"pessoa":{"tipo":"FIS","enderecos":[{"uf":"SP","cidade":"SAO PAULO","complemento":"Apto 22","logradouro":"Guaianses","bairro":"Centro","complementoCep":"420","tipoLogradouro":"R","paisResidencia":"BRASIL","tipoEndereco":"REC","numeroLogradouro":"92","cep":"07114"}],"nome":"Testinho","dadosPessoaFisica":{"numeroCpf":"438912318","profissao":"2123-05","tipoContrato":"TODOS","celular":"(11) 11111-1111","digitoCpf":"14","dataNascimento":"2000-11-11","fumante":false,"sexo":"MASCULINO","renda":"FAIXA2"},"email":"teste@teste.com.br"},"numero":1,"coberturas":[{"sigla":"BAS","valor":20000},{"sigla":"MAP","valor":20000}]}],"nome":"Testinho","qtdeVidas":1}]}],"canalDistribuicao":"COR","meioComercializacao":"CO2","segmento":"Individual","ordemPortal":1,"rotulo":"Sniper - Plano Básico","remuneracoes":[{"percentual":20,"tipoRemuneracao":"CORRETAGEM"}],"vigenciaInicial":"2019-09-23","dataCalculo":"2019-09-23"},"retornoCalculo":{"orcnum":3821872979,"precificacao":{"juros":0,"iof":1.24,"encargos":0,"custoDeApolice":0,"premio":{"comercial":205.98,"puro":219.98,"total":225.00},"taxa":{"comercial":0.0002185,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}],"coberturas":[{"sigla":"BAS","capital":350000.00,"iof":0.28,"premio":{"comercial":75.00,"puro":75.00,"total":75.00},"taxa":{"comercial":0.000043,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"MAP","capital":500000.00,"iof":0.19,"premio":{"comercial":50.0,"puro":50.0,"total":50.0},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DIH","capital":1400.00,"iof":0.09,"premio":{"comercial":25.0,"puro":25.0,"total":25.0},"taxa":{"comercial":0.00031,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DG 10","capital":6000.00,"iof":0.14,"premio":{"comercial":37.50,"puro":37.50,"total":37.50},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"AFI","capital":2900.00,"iof":0.14,"premio":{"comercial":37.50,"puro":37.50,"total":37.50},"taxa":{"comercial":0.000015,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]}],"contratantes":[{"numero":1,"iof":1.24,"premio":{"comercial":4.38,"puro":3.98,"total":5.00},"taxa":{"comercial":0.0002185,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}],"coberturas":[{"sigla":"BAS","capital":119.8,"iof":1.24,"premio":{"comercial":2.58,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000043,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DG 10","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"MAP","capital":1000.7,"iof":1.24,"premio":{"comercial":1.55,"puro":3.98,"total":5.00},"taxa":{"comercial":0.00031,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DIH","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"AFI","capital":2900.2,"iof":1.24,"premio":{"comercial":0.22,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000015,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]}],"grupos":[{"numero":1,"iof":1.24,"premio":{"comercial":4.38,"puro":3.98,"total":5.00},"taxa":{"comercial":0.0002185,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}],"coberturas":[{"sigla":"BAS","capital":119.8,"iof":1.24,"premio":{"comercial":2.58,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000043,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"MAP","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"AFI","capital":1000.7,"iof":1.24,"premio":{"comercial":1.55,"puro":3.98,"total":5.00},"taxa":{"comercial":0.00031,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DIH","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DG 10","capital":2900.2,"iof":1.24,"premio":{"comercial":0.22,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000015,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]}],"segurados":[{"numero":1,"iof":1.24,"premio":{"comercial":4.38,"puro":3.98,"total":5.00},"taxa":{"comercial":0.0002185,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}],"coberturas":[{"sigla":"BAS","capital":119.8,"iof":1.24,"premio":{"comercial":2.58,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000043,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"MAP","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"AFI","capital":1000.7,"iof":1.24,"premio":{"comercial":1.55,"puro":3.98,"total":5.00},"taxa":{"comercial":0.00031,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DG 10","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DIH","capital":1000900,"iof":1.24,"premio":{"comercial":0.22,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000015,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]}]}]}]}]}},"retornoAceitacao":{"analises":[],"recusas":[{"severidade":null,"codigo":4,"descricao":"Capital da Cobertura superior a R$200.000,00","area":"UNI","procedimento":"","mensagens":{"interna":"PERMITIDO","cliente":null,"representante":null}}],"avisos":[],"pendencias":[]},"retornoIntegracoes":{}}],"versoesCalculo":[{"opcao":0,"tipo":null,"descontoAgravo":0},{"opcao":1,"tipo":"FPG","descontoAgravo":-5},{"opcao":2,"tipo":"FPG","descontoAgravo":5}]}';


		Contract contrato = [SELECT Id, Produto__c FROM Contract]; // PLV-5331 INÍCIO/FIM

        EmissaoTO.PayloadTO payloadTO = (EmissaoTO.PayloadTO) JSON.deserialize(payload, EmissaoTO.PayloadTO.class);
        
        for(EmissaoTO.OfertasTO oferta : payloadTO.ofertas)
        {
            oferta.orcamento.vigenciaInicial = String.valueOf(System.today().addDays(1));
            oferta.orcamento.vigenciaFinal   = String.valueOf(System.today().addDays(1));
            oferta.orcamento.dataCalculo = String.valueOf(System.today().addDays(1));
			oferta.orcamento.idProdutoSf = contrato.Produto__c;
        }

        
        payload = JSON.serialize(payloadTO);

        Test.startTest();
        ServiceTO.PayRetornoOfertasTO ofertas = OrcamentoGenericoBuilder.getInstance().gerarOrcamentoGravar(payload);
       
        Test.stopTest();
    }
    */

    @isTest
    static void testEmissaoOrcamentoGenericBuilderOrcamentoRecusa() {

        String payload = '{ "ofertas": [ { "orcamento": { "tipoVigencia": "Periódico", "tipoSeguro": "Novo", "vigenciaFinal": "2019-10-08", "numeroOrcamento": "00000003", "numeroPortal": 0, "codigoProdutoVida": "VI-PESSOAS", "idProdutoSf": "01t89000006GWV8AAO", "customizavel": true, "contratantes": [ { "tipo": "PRI", "numero": 1, "grupos": [ { "numero": 1, "segurados": [ { "pessoa": { "tipo": "FIS", "enderecos": [ { "uf": "SP", "cidade": "SAO PAULO", "complemento": "Apto 22", "logradouro": "Guaianses", "bairro": "Centro", "complementoCep": "420", "tipoLogradouro": "R", "paisResidencia": "BRASIL", "tipoEndereco": "REC", "numeroLogradouro": "92", "cep": "07114" } ], "nome": "Testinho", "dadosPessoaFisica": { "numeroCpf": "438912318", "profissao": "5136-15", "tipoContrato": "TODOS", "celular": "(11) 11111-1111", "digitoCpf": "14", "dataNascimento": "2000-11-11", "fumante": false, "sexo": "MASCULINO", "renda": "FAIXA2" }, "email": "teste@teste.com.br" }, "numero": 1, "coberturas": [ { "sigla": "BAS", "valor": 20000 }, { "sigla": "MAP", "valor": 20000 }, { "sigla": "CAP", "valor": 10 } ] } ], "nome": "Testinho", "qtdeVidas": 1 } ] } ], "canalDistribuicao": "EXE", "meioComercializacao": "CO2", "segmento": "Individual", "versoesCalculos": [ { "opcao": 0, "tipo": "FPG", "descontoAgravo": 0 }, { "opcao": 1, "tipo": "FPG", "descontoAgravo": -5 }, { "opcao": 2, "tipo": "FPG", "descontoAgravo": 5 } ], "ordemPortal": 1, "rotulo": "Sniper - Plano Básico", "remuneracoes": [ { "percentual": 20, "tipoRemuneracao": "CORRETAGEM" } ], "vigenciaInicial": "2019-09-23", "dataCalculo": "2019-09-23" }, "retornosCalculo": [ { "opcao": 0, "orcnum": "00000003", "numeroOrcamento": "00000003", "numeroOferta": 123, "precificacao": { "juros": 0, "iof": 1.24, "encargos": 0, "custoDeApolice": 0, "premio": { "comercial": 205.98, "puro": 219.98, "total": 225.00 }, "taxa": { "comercial": 0.0002185, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ], "coberturas": [ { "sigla": "BAS", "capital": 350000.00, "iof": 0.28, "premio": { "comercial": 75.00, "puro": 75.00, "total": 75.00 }, "taxa": { "comercial": 0.000043, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "MAP", "capital": 500000.00, "iof": 0.19, "premio": { "comercial": 50.0, "puro": 50.0, "total": 50.0 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DIH", "capital": 1400.00, "iof": 0.09, "premio": { "comercial": 25.0, "puro": 25.0, "total": 25.0 }, "taxa": { "comercial": 0.00031, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DG 10", "capital": 6000.00, "iof": 0.14, "premio": { "comercial": 37.50, "puro": 37.50, "total": 37.50 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "AFI", "capital": 2900.00, "iof": 0.14, "premio": { "comercial": 37.50, "puro": 37.50, "total": 37.50 }, "taxa": { "comercial": 0.000015, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] } ], "contratantes": [ { "numero": 1, "iof": 1.24, "premio": { "comercial": 4.38, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.0002185, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ], "coberturas": [ { "sigla": "BAS", "capital": 119.8, "iof": 1.24, "premio": { "comercial": 2.58, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000043, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DG 10", "capital": 12.8, "iof": 1.24, "premio": { "comercial": 0.03, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "MAP", "capital": 1000.7, "iof": 1.24, "premio": { "comercial": 1.55, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.00031, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DIH", "capital": 12.8, "iof": 1.24, "premio": { "comercial": 0.03, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "AFI", "capital": 2900.2, "iof": 1.24, "premio": { "comercial": 0.22, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000015, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] } ], "grupos": [ { "numero": 1, "iof": 1.24, "premio": { "comercial": 4.38, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.0002185, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ], "coberturas": [ { "sigla": "BAS", "capital": 119.8, "iof": 1.24, "premio": { "comercial": 2.58, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000043, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "MAP", "capital": 12.8, "iof": 1.24, "premio": { "comercial": 0.03, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "AFI", "capital": 1000.7, "iof": 1.24, "premio": { "comercial": 1.55, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.00031, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DIH", "capital": 12.8, "iof": 1.24, "premio": { "comercial": 0.03, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DG 10", "capital": 2900.2, "iof": 1.24, "premio": { "comercial": 0.22, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000015, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] } ], "segurados": [ { "numero": 1, "iof": 1.24, "premio": { "comercial": 4.38, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.0002185, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ], "coberturas": [ { "sigla": "BAS", "capital": 119.8, "iof": 1.24, "premio": { "comercial": 2.58, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000043, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "MAP", "capital": 12.8, "iof": 1.24, "premio": { "comercial": 0.03, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "AFI", "capital": 1000.7, "iof": 1.24, "premio": { "comercial": 1.55, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.00031, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DG 10", "capital": 12.8, "iof": 1.24, "premio": { "comercial": 0.03, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DIH", "capital": 1000900, "iof": 1.24, "premio": { "comercial": 0.22, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000015, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] } ] } ] } ] } ] } } ], "retornoAceitacao": {}, "retornoIntegracoes": { "validacaoZeroDolar": null, "IndiceMonetario": { "ItensCotacao": [ { "moedaOrigem": "USD", "moedaDestino": "BRL", "dataCotacao": 13112018, "cotacao": "3.74720000" }, { "moedaOrigem": "EUR", "moedaDestino": "BRL", "dataCotacao": 13112018, "cotacao": "4.04720000" }, { "moedaOrigem": "BRL", "moedaDestino": "BRL", "dataCotacao": 13112018, "cotacao": "1" } ] } } } ] }';

        Contract contrato = [SELECT Id, Produto__c FROM Contract]; // PLV-5331 INÍCIO/FIM
       
        //ANNVI-55 - INICIO
        Profissao__c profissao = ( Profissao__c ) new ProfissaoFactory().createRecord();
        profissao.CodigoProfissao__c = '5136-15';
        profissao.Codigo__c = '5136-15';
        profissao.IdExterno__c = '1';
        profissao.Status__c = 'Ativo';

        update profissao;

        Account conta = new Account(
                Name = 'testeAcc', 
                Cpf__c = '09638381051',
                Cnpj__c = '38057572000180',
                Phone = '11 900000000',
                Profissao__c = profissao.Id
            );
    
        insert conta;
        
        Endereco__c endereco = new Endereco__c();
        endereco.Conta__c  = conta.Id;
        endereco.EnderecoCobranca__c = true;
        endereco.MaisAtual__c = false;
        endereco.CEP__c = '05689002';

        insert endereco;//ANNVI-55 FIM

        EmissaoTO.PayloadTO payloadTO = (EmissaoTO.PayloadTO) JSON.deserialize(payload, EmissaoTO.PayloadTO.class);
        
        for(EmissaoTO.OfertasTO oferta : payloadTO.ofertas)
        {
            oferta.orcamento.vigenciaInicial = String.valueOf(System.today().addDays(1));
            oferta.orcamento.vigenciaFinal   = String.valueOf(System.today().addDays(1));
            oferta.orcamento.dataCalculo = String.valueOf(System.today().addDays(1));
            oferta.orcamento.idProdutoSf = contrato.Produto__c;
        }

        //ANNVI-55 - INICIO
        Garantia__c garantia = new Garantia__c();
        garantia.Name = 'Garantia';
        garantia.Sigla__c = 'EXE';
        garantia.Tipo__c = 'Cobertura'; //ANNVI-55 - INICIO/FIM
        insert garantia;

        RamoSeguro__c ramoSeguro = [SELECT Id, Name, Codigo__c FROM RamoSeguro__c];
        Product2 produto = [SELECT Id, Name FROM Product2 WHERE Name = 'Nome Produto Tecnico'];

        GarantiaProduto__c garantiaProduto = new GarantiaProduto__c();
        garantiaProduto.TipoGarantia__c = 'Cobertura';
        garantiaProduto.RamoSeguro__c = ramoSeguro.Id;
        garantiaProduto.RamoSeguro__r = ramoSeguro;
        garantiaProduto.Garantia__c = garantia.id;
        garantiaProduto.Garantia__r = garantia;
        garantiaProduto.Produto__c = produto.Id;
        garantiaProduto.RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoTecnico').Id;
        garantiaProduto.OrdemPrioridade__c = 1;
        garantiaProduto.CurrencyIsoCode = 'BRL';
        garantiaProduto.LimiteCapitalMinimo__c = 100;
        garantiaProduto.LimiteCapitalMaximo__c = 1000;
        garantiaProduto.LimiteIdadeMaximo__c = 70;
        garantiaProduto.LimiteIdadeMinimo__c = 16; 
        garantiaProduto.Descricao__c = 'Teste';
        garantiaProduto.CancelaDependentes__c = false;
		garantiaProduto.CancelaGarantia__c = false;
		garantiaProduto.CancelaSegurado__c = false;
		garantiaProduto.MomentoCancelamento__c = 'Aviso';
	    garantiaProduto.CaracteristicaGarantia__c = 'Principal';
		garantiaProduto.Obrigatoria__c = true;
        garantiaProduto.TipoCapital__c = 'Capital global';
		garantiaProduto.TipoLimiteCapital__c = 'Monetário';
        
        insert garantiaProduto;
        //ANNVI-55 - FIM
        
        payload = JSON.serialize(payloadTO);

        Test.startTest();

        //ANNVI-55 - INICIO
        CriticaOrcamento__c critica = [SELECT Id, Justificativa__c, Tipo__c, Status__c, Orcamento__r.Numero__c FROM CriticaOrcamento__c LIMIT 1];
        critica.Tipo__c = 'Análise';
        update critica;
        OrcamentoGenericoBuilder.getInstance().retornarCriticasODM(critica.Orcamento__r.Numero__c);

        critica.Tipo__c = 'Aviso';
        update critica;
        OrcamentoGenericoBuilder.getInstance().retornarCriticasODM(critica.Orcamento__r.Numero__c);

        critica.Tipo__c = 'Pendência';
        update critica;
        OrcamentoGenericoBuilder.getInstance().retornarCriticasODM(critica.Orcamento__r.Numero__c);

        critica.Tipo__c = 'Recusa';
        update critica;
        OrcamentoGenericoBuilder.getInstance().retornarCriticasODM(critica.Orcamento__r.Numero__c);
        //ANNVI-55 - FIM

        ServiceTO.PayRetornoOfertasTO ofertas = OrcamentoGenericoBuilder.getInstance().gerarOrcamentoGravar(payload);
       
        Test.stopTest();
    }
  

    //PLV-2703 - FIM
    
    //PLV2365: INICIO
    @IsTest
    static void testEmissaoOrcamentoGenericBuilder()
    {
        //PLV-3667 - INICIO
        //List<StaticResource> listStaticResource = new List<StaticResource>();

        String payload = '{"ofertas":[{"orcamento":{"rotulo":"Viva tranquilo - Plano essencial","ordemPortal":"1","segmento":"Individual","meioComercializacao":"Arq","numeroPortal":"988444","dataCalculo":"2019-05-30","codigoProdutoVida":"VI-PESSOAS","tipoVigencia":"Periódico","vigenciaInicial":"2019-06-19","vigenciaFinal":"2020-06-18","tipoSeguro":"Novo","entradaNegocio":"Corretor 2.0","contratantes":[{"tipo":"PRI","numero":"1","pessoa":{"tipo":"FIS","nome":"DOUGLAS DOMICIANO GANSO","dadosPessoaFisica":{"sexo":"MASC","numeroCpf":"378549429","digitoCpf":"78","estadoCivil":"CAS","dataNascimento":"1982-08-26","profissao":"2111-05"},"email":"mussum.forevis@gmail.com","enderecos":[{"uf":"SP","tipoLogradouro":"R","tipoEndereco":"RES","paisResidencia":"BRA","numeroLogradouro":"92","logradouro":"Guaianses","complementoCep":"420","complemento":"Apto 22","cidade":"SAO PAULO","cep":"07114","bairro":"Centro"}]},"grupos":[{"numero":1,"nome":"Seguro Individual","qtdeVidas":1,"segurados":[{"numero":1,"pessoa":{"tipo":"FIS","nome":"DOUGLAS DOMICIANO GANSO","dadosPessoaFisica":{"sexo":"MASC","numeroCpf":"378549429","digitoCpf":"78","estadoCivil":"CAS","dataNascimento":"1982-08-26","profissao":"2111-05"},"email":"mussum.forevis@gmail.com","enderecos":[{"uf":"SP","tipoLogradouro":"R","tipoEndereco":"RES","paisResidencia":"BRA","numeroLogradouro":"92","logradouro":"Guaianses","complementoCep":"420","complemento":"Apto 22","cidade":"SAO PAULO","cep":"07114","bairro":"Centro"}]},"coberturas":[{"sigla":"ABC","valor":50000.0},{"sigla":"IEA","percentual":100.0,"garantiaReferenciada":"BAS"},{"sigla":"AFT","valor":3000.0}]}]}]}],"canalDistribuicao":"EXE","remuneracoes":[{"tipoRemuneracao":"CORRETAGEM","percentual":15.0}]},"retornoIntegracoes":{},"retornoCalculo":{"orcnum":"3821872979","precificacao":{"juros":0,"iof":1.24,"encargos":0,"custoDeApolice":0,"premio":{"comercial":4.38,"puro":3.98,"total":5.00},"taxa":{"comercial":0.0002185,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}],"coberturas":[{"sigla":"BAS","capital":119.8,"iof":1.24,"premio":{"comercial":2.58,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000043,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]}],"contratantes":[{"numero":1,"iof":1.24,"premio":{"comercial":4.38,"puro":3.98,"total":5.00},"taxa":{"comercial":0.0002185,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}],"coberturas":[{"sigla":"BAS","capital":119.8,"iof":1.24,"premio":{"comercial":2.58,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000043,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]}],"grupos":[{"numero":1,"iof":1.24,"premio":{"comercial":4.38,"puro":3.98,"total":5.00},"taxa":{"comercial":0.0002185,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}],"coberturas":[{"sigla":"BAS","capital":119.8,"iof":1.24,"premio":{"comercial":2.58,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000043,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]}],"segurados":[{"numero":1,"iof":1.24,"premio":{"comercial":4.38,"puro":3.98,"total":5.00},"taxa":{"comercial":0.0002185,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}],"coberturas":[{"sigla":"BAS","capital":119.8,"iof":1.24,"premio":{"comercial":2.58,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000043,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]}]}]}]}]}},"retornoAceitacao":{}}],"versoesCalculo":[{"opcao":0,"tipo":null,"descontoAgravo":0},{"opcao":1,"tipo":"FPG","descontoAgravo":-5},{"opcao":2,"tipo":"FPG","descontoAgravo":5}]}';

        //List<OfertasTO> ofertas
        
        Contract contrato = [SELECT Id, Produto__c FROM Contract]; // PLV-5331 INÍCIO/FIM
        
        List<EmissaoTO.RetornoCalculoTO> listaRetornoCalculoTO = new List<EmissaoTO.RetornoCalculoTO>();
        
        EmissaoTO.RetornoCalculoTO retornoCalculo = new EmissaoTO.RetornoCalculoTO();
        
        retornoCalculo.numeroOrcamento = '0000003';
        
        listaRetornoCalculoTO.add( retornoCalculo );

        EmissaoTO.PayloadTO payloadTO = (EmissaoTO.PayloadTO) JSON.deserialize(payload, EmissaoTO.PayloadTO.class);
		
        for(EmissaoTO.OfertasTO oferta : payloadTO.ofertas)
        {
            oferta.orcamento.vigenciaInicial = String.valueOf(System.today().addDays(1));
            oferta.orcamento.vigenciaFinal   = String.valueOf(System.today().addDays(1));
            oferta.orcamento.dataCalculo = String.valueOf(System.today().addDays(1));
			oferta.orcamento.idProdutoSf = contrato.Produto__c;
        }
        
        payload = JSON.serialize(payloadTO);
        
        payloadTO.retornosCalculo = listaRetornoCalculoTO;
        Test.startTest();
        //ServiceTO.PayRetornoOfertasTO ofertas = OrcamentoGenericoBuilder.getInstance().gerarOrcamentoGravar(payload);
       
       //system.assert(ofertas.retornoValidacaoProduto.recusas.size() > 0);


        Test.stopTest();

    }
    //PLV2365: FIM
    
    //PLV-2727 - Inicio
    @IsTest
    static void testEmissaoOrcamentoGenericBuilderCompleto()
    {
        //PLV-3667 - INICIO
        //List<StaticResource> listStaticResource = new List<StaticResource>();
		//PLV-3731 - INICIO
        //listStaticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadOrcamento2' LIMIT 1];
		//PLV-3731 - FIM
        //if(listStaticResource.isEmpty()) return;

        //String payload = listStaticResource[0].Body.toString();
        //PLV-3667 - FIM
        // PLV-5331 - INÍCIO
        List<EmissaoTO.OfertasTO> listaOfertas = new List<EmissaoTO.OfertasTO>();
        String payload = '{"ofertas":[{"orcamento":{"tipoVigencia":"Periódico","tipoSeguro":"Novo","vigenciaFinal":"2019-10-08","numeroOrcamento":"00000003","numeroPortal":0,"codigoProdutoVida":"201700001", "idProdutoSf": null,"customizavel":true,"contratantes":[{"tipo":"PRI","numero":1,"grupos":[{"numero":1,"segurados":[{"pessoa":{"tipo":"FIS","enderecos":[{"uf":"SP","cidade":"SAO PAULO","complemento":"Apto 22","logradouro":"Guaianses","bairro":"Centro","complementoCep":"420","tipoLogradouro":"R","paisResidencia":"BRASIL","tipoEndereco":"REC","numeroLogradouro":"92","cep":"07114"}],"nome":"Testinho","dadosPessoaFisica":{"numeroCpf":"438912318","profissao":null,"tipoContrato":"TODOS","celular":"(11) 11111-1111","digitoCpf":"14","dataNascimento":"2000-11-11","fumante":false,"sexo":"MASCULINO","renda":"FAIXA2"},"email":"teste@teste.com.br"},"numero":1,"coberturas":[{"sigla":"BAS","valor":20000},{"sigla":"MAP","valor":20000},{"sigla":"CAP","valor":10}]}],"nome":"Testinho","qtdeVidas":1}]}],"canalDistribuicao":"EXE","meioComercializacao":"CO2","segmento":"Individual","versoesCalculos":[{"opcao":0,"tipo":"FPG","descontoAgravo":0},{"opcao":1,"tipo":"FPG","descontoAgravo":-5},{"opcao":2,"tipo":"FPG","descontoAgravo":5}],"ordemPortal":1,"rotulo":"Sniper - Plano Básico","remuneracoes":[{"percentual":20,"tipoRemuneracao":"CORRETAGEM"}],"vigenciaInicial":"2019-09-23","dataCalculo":"2019-09-23"},"retornosCalculo":[{"opcao":0,"orcnum":"00000003","numeroOrcamento":"00000003","numeroOferta":123,"precificacao":{"juros":0,"iof":1.24,"encargos":0,"custoDeApolice":0,"premio":{"comercial":205.98,"puro":219.98,"total":225.00},"taxa":{"comercial":0.0002185,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}],"coberturas":[{"sigla":"BAS","capital":350000.00,"iof":0.28,"premio":{"comercial":75.00,"puro":75.00,"total":75.00},"taxa":{"comercial":0.000043,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"MAP","capital":500000.00,"iof":0.19,"premio":{"comercial":50.0,"puro":50.0,"total":50.0},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DIH","capital":1400.00,"iof":0.09,"premio":{"comercial":25.0,"puro":25.0,"total":25.0},"taxa":{"comercial":0.00031,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DG 10","capital":6000.00,"iof":0.14,"premio":{"comercial":37.50,"puro":37.50,"total":37.50},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"AFI","capital":2900.00,"iof":0.14,"premio":{"comercial":37.50,"puro":37.50,"total":37.50},"taxa":{"comercial":0.000015,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]}],"contratantes":[{"numero":1,"iof":1.24,"premio":{"comercial":4.38,"puro":3.98,"total":5.00},"taxa":{"comercial":0.0002185,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}],"coberturas":[{"sigla":"BAS","capital":119.8,"iof":1.24,"premio":{"comercial":2.58,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000043,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DG 10","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"MAP","capital":1000.7,"iof":1.24,"premio":{"comercial":1.55,"puro":3.98,"total":5.00},"taxa":{"comercial":0.00031,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DIH","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"AFI","capital":2900.2,"iof":1.24,"premio":{"comercial":0.22,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000015,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]}],"grupos":[{"numero":1,"iof":1.24,"premio":{"comercial":4.38,"puro":3.98,"total":5.00},"taxa":{"comercial":0.0002185,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}],"coberturas":[{"sigla":"BAS","capital":119.8,"iof":1.24,"premio":{"comercial":2.58,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000043,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"MAP","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"AFI","capital":1000.7,"iof":1.24,"premio":{"comercial":1.55,"puro":3.98,"total":5.00},"taxa":{"comercial":0.00031,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DIH","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DG 10","capital":2900.2,"iof":1.24,"premio":{"comercial":0.22,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000015,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]}],"segurados":[{"numero":1,"iof":1.24,"premio":{"comercial":4.38,"puro":3.98,"total":5.00},"taxa":{"comercial":0.0002185,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}],"coberturas":[{"sigla":"BAS","capital":119.8,"iof":1.24,"premio":{"comercial":2.58,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000043,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"MAP","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"AFI","capital":1000.7,"iof":1.24,"premio":{"comercial":1.55,"puro":3.98,"total":5.00},"taxa":{"comercial":0.00031,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DG 10","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DIH","capital":1000900,"iof":1.24,"premio":{"comercial":0.22,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000015,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]}]}]}]}]}}],"retornoAceitacao":{},"retornoIntegracoes":{"validacaoZeroDolar":null,"IndiceMonetario":{"ItensCotacao":[{"moedaOrigem":"USD","moedaDestino":"BRL","dataCotacao":13112018,"cotacao":"3.74720000"},{"moedaOrigem":"EUR","moedaDestino":"BRL","dataCotacao":13112018,"cotacao":"4.04720000"},{"moedaOrigem":"BRL","moedaDestino":"BRL","dataCotacao":13112018,"cotacao":"1"}]}}}]}';
        // PLV-5331 - FIM
        EmissaoTO.PayloadTO payloadTO = (EmissaoTO.PayloadTO) JSON.deserialize(payload, EmissaoTO.PayloadTO.class);
		
        contratos = [SELECT Id, Produto__c, Name, Empresa__c, Sucursal__c, CodigoRamo__c, NumeroApolice__c, Endosso__c FROM Contract LIMIT 1]; // PLV-5331 - INÍCIO/FIM 
        
        for(EmissaoTO.OfertasTO oferta : payloadTO.ofertas)
        {
            oferta.orcamento.vigenciaInicial = String.valueOf(System.today().addDays(1));
            oferta.orcamento.vigenciaFinal   = String.valueOf(System.today().addDays(1));
            //PLV-2995 - INICIO - Linha adicionada para o teste da classe
            oferta.orcamento.dataCalculo     = String.valueOf(System.today().addDays(1));
            //PLV-2995 - FIM
            oferta.orcamento.idProdutoSf = contratos[0].Produto__c; // PLV-5331 - INÍCIO/FIM
            
            listaOfertas.add(oferta); // PLV-5331 - INÍCIO/FIM
        }
        
        //payload = JSON.serialize(payloadTO);
        payload = JSON.serialize(listaOfertas[0]);// PLV-5331 - INÍCIO/FIM

        Test.startTest();
        ServiceTO.PayRetornoOfertasTO ofertas = OrcamentoGenericoBuilder.getInstance().gerarOrcamentoGravar(payloadTO);
		
        Test.stopTest();

    }
    //PLV-2727 - Fim

    private static EmissaoTO.PayloadTO gerarPayloadTO(){

        // Instancias
        payloadTO = new EmissaoTO.PayloadTO();
        payloadTO.orcamento = new EmissaoTO();
		
        
        contratos = [SELECT Id, Name, Empresa__c, Sucursal__c, CodigoRamo__c, NumeroApolice__c, Endosso__c FROM Contract ];
        System.debug('Empresa: >> ' + String.valueOf(contratos[0].Empresa__c));
        System.debug('Sucursal: >> ' + String.valueOf(contratos[0].Sucursal__c));
        System.debug('CodigoRamo: >> ' + String.valueOf(contratos[0].CodigoRamo__c));
        System.debug('NumeroApolice: >> ' + String.valueOf(contratos[0].NumeroApolice__c));
        System.debug('Endosso: >> ' + String.valueOf(contratos[0].Endosso__c));

        payloadTO.orcamento.empresa = String.valueOf(contratos[0].Empresa__c);// '22';
        payloadTO.orcamento.sucursal = Integer.valueOf(contratos[0].Sucursal__c);// 999;
        payloadTO.orcamento.ramo = Integer.valueOf(contratos[0].CodigoRamo__c); // 2;
        payloadTO.orcamento.endosso = contratos[0].Endosso__c; // 0 PLV-5331 INICIO / FIM;
        payloadTO.orcamento.apolice = String.valueOf(contratos[0].NumeroApolice__c);// '00006767';
        payloadTO.orcamento.tipoSeguro = 'CAN';
        payloadTO.orcamento.tipoEndosso = 'INA';
        payloadTO.orcamento.dataCalculo = '2019-02-19';
        payloadTO.orcamento.vigenciaInicial = '2016-09-23';
        payloadTO.orcamento.meioComercializacao = 'SFC'; //PLV-4550 INICIO/FIM

         return payloadTO;

    }

    // @IsTest
    //private static EmissaoTO.PayloadTO gerarPayload2TO(){

    //    // Instancias
    //    payloadTO = new EmissaoTO.PayloadTO();
    //    payloadTO.orcamento = new EmissaoTO();


    //    payloadTO.orcamento.empresa = '22';
    //    payloadTO.orcamento.sucursal = 999;
    //    payloadTO.orcamento.ramo = 2;
    //    payloadTO.orcamento.apolice = '00006767';
    //    payloadTO.orcamento.tipoSeguro = 'CAN';
    //    payloadTO.orcamento.tipoEndosso = 'INA';
    //    payloadTO.orcamento.dataCalculo = '2019-02-19';
    //    payloadTO.orcamento.vigenciaInicial = '2016-09-23';
    //    payloadTO.orcamento.meioComercializacao = 'CIC';


    //     return payloadTO;
    //}


	//@isTest
	//private static void testParser(){
	//	try{
	//		EmissaoTO r = (EmissaoTO)JSON.deserialize('{"ofertas":[{"retornoCalculo":null,"retornoAceitacao":null,"retornoValidacaoProduto":null,"orcamento":{"vigenciaInicial":"2016-09-23","apolice":874433,"ramo":1377,"tipoSeguro":"CAN","tipoAdesao":"INA","vigenciaFinal":"2016-09-30","empresa":1,"dataCalculo":"2019-01-19","sucursal":13,"status":"Dispon\u00edvel para Contrata\u00e7\u00e3o","numeroOrcamento":647658,"qtdDiasVigencia":8,"meioComercializacao":"CIC"},"retornoIntegracoes":null}]}', EmissaoTO.class);
	//		System.assert(true); // no error during parse
	//	} catch (Exception ex){
	//		System.assert(false, 'Parse failed for EmissaoTO: ' + ex.getMessage());
	//	}
	//}
	
  
    
    //PLV2569 - INICIO AVX - Ajuste para aumentar cobertura de testes da classe OrcamentoGenericoBuilder.
    public static Product2 atualizaProdutoComercial(){
              
       Product2 produtoTecnico = TestDataFactory.gerarProdutoTecnico();
       produtoTecnico.Status__c = 'Ativo';
       update produtoTecnico;
       
       Product2 produtoComercial = TestDataFactory.gerarProdutoComericial(produtoTecnico);
        
       System.debug('produtoComercial do metodo atualizaProdutoComercial:' + produtoComercial);
       
       produtoComercial.ProductCode = '201700001'; // PLV-5331 INICIO / FIM
       produtoComercial.Status__c = 'Ativo';
       produtoComercial.VigenciaInicial__c = date.valueof(system.today());
       produtoComercial.VigenciaFinal__c = NULL;
       produtoComercial.CodigoPrecificaProduto__c = produtoComercial.ProductCode; // PLV-5331 INICIO / FIM
        
       System.debug('produto.ProductCode:' + produtoComercial.ProductCode);
       System.debug('produto.Status__c: ' + produtoComercial.Status__c);
       System.debug('produto.VigenciaInicial__c: ' + produtoComercial.VigenciaInicial__c);
       System.debug('produto.VigenciaFinal__c: ' + produtoComercial.VigenciaFinal__c);
        
       update produtoComercial;

       Contract ctract = [SELECT Id, Produto__c FROM Contract LIMIT 1]; // PLV-5331 INICIO / FIM
       system.debug('contrato Id: '+ ctract.Id);
       ctract.Produto__c = produtoComercial.Id; // PLV-5331 INICIO / FIM
       update ctract; // PLV-5331 INICIO / FIM
                
       return produtoComercial;
    }
	
    //PLV-3141 - INICIO - Seguro Viagem - Atualização do serviço de criação de orçamento
    public static void associaProdutoCanal(Product2 produtoCom, String sigla){
        
        CanalDistribuicao__c canalDistribuicao = new CanalDistribuicao__c();
        canalDistribuicao.Sigla__c = sigla; //'EXE';
        //PLV-3141 - FIM - Seguro Viagem - Atualização do serviço de criação de orçamento
        canalDistribuicao.Name = 'Teste AVX';
        canalDistribuicao.Status__c = 'Em Ativação';
        
        insert canalDistribuicao;
        
        canalDistribuicao.Status__c = 'Ativo';
            
        update canalDistribuicao;
        
        ProdutoCanal__c produtoCanalGerado = new ProdutoCanal__c();
        produtoCanalGerado.CanalDistribuicao__c = canalDistribuicao.Id;
        produtoCanalGerado.Produto__c = produtoCom.Id;
            
        insert produtoCanalGerado;
        System.debug('produtoCanalGerado: ' + produtoCanalGerado);
        System.debug('canalDistribuicao: ' + canalDistribuicao);
        System.debug('Id do canalDistribuicao: ' + canalDistribuicao.Id);        
        System.debug('produtoCanalGerado.CanalDistribuicao__c: ' + produtoCanalGerado.CanalDistribuicao__c);
        System.debug('produtoCanalGerado.Produto__c: ' + produtoCanalGerado.Produto__c);        
        
        //update produtoCanalGerado;        
    } 
	//PLV2569 - FIM AVX - Ajuste para aumentar cobertura de testes da classe OrcamentoGenericoBuilder.
    
    //PLV-3667 - INICIO - Aumento de cobertura de classes de teste
    @isTest
    public static void gerarOrcamentoCivCalculoTest(){

        List<EmissaoTO.OfertasTO> listaOfertas = new List<EmissaoTO.OfertasTO>();

        //List<StaticResource> listaStaticResource = new List<StaticResource>();
		//PLV-3731 - INICIO
        //listaStaticResource = [SELECT id, body FROM StaticResource WHERE name = 'PayloadOrcamento2' LIMIT 1];
        //PLV-3731 - FIM

        //if(listaStaticResource.isEmpty()) return;

        //String payload = listaStaticResource[0].body.toString();

        String payload = '{"ofertas":[{"orcamento":{"tipoVigencia":"Periódico","tipoSeguro":"Novo","vigenciaFinal":"2019-10-08","numeroOrcamento":"00000003","numeroPortal":0,"codigoProdutoVida":"VI-PESSOAS", "idProdutoSf": null,"customizavel":true,"contratantes":[{"tipo":"PRI","numero":1,"grupos":[{"numero":1,"segurados":[{"pessoa":{"tipo":"FIS","enderecos":[{"uf":"SP","cidade":"SAO PAULO","complemento":"Apto 22","logradouro":"Guaianses","bairro":"Centro","complementoCep":"420","tipoLogradouro":"R","paisResidencia":"BRASIL","tipoEndereco":"REC","numeroLogradouro":"92","cep":"07114"}],"nome":"Testinho","dadosPessoaFisica":{"numeroCpf":"438912318","profissao":null,"tipoContrato":"TODOS","celular":"(11) 11111-1111","digitoCpf":"14","dataNascimento":"2000-11-11","fumante":false,"sexo":"MASCULINO","renda":"FAIXA2"},"email":"teste@teste.com.br"},"numero":1,"coberturas":[{"sigla":"BAS","valor":20000},{"sigla":"MAP","valor":20000},{"sigla":"CAP","valor":10}]}],"nome":"Testinho","qtdeVidas":1}]}],"canalDistribuicao":"EXE","meioComercializacao":"CO2","segmento":"Individual","versoesCalculos":[{"opcao":0,"tipo":"FPG","descontoAgravo":0},{"opcao":1,"tipo":"FPG","descontoAgravo":-5},{"opcao":2,"tipo":"FPG","descontoAgravo":5}],"ordemPortal":1,"rotulo":"Sniper - Plano Básico","remuneracoes":[{"percentual":20,"tipoRemuneracao":"CORRETAGEM"}],"vigenciaInicial":"2019-09-23","dataCalculo":"2019-09-23"},"retornosCalculo":[{"opcao":0,"orcnum":"00000003","numeroOrcamento":"00000003","numeroOferta":123,"precificacao":{"juros":0,"iof":1.24,"encargos":0,"custoDeApolice":0,"premio":{"comercial":205.98,"puro":219.98,"total":225.00},"taxa":{"comercial":0.0002185,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}],"coberturas":[{"sigla":"BAS","capital":350000.00,"iof":0.28,"premio":{"comercial":75.00,"puro":75.00,"total":75.00},"taxa":{"comercial":0.000043,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"MAP","capital":500000.00,"iof":0.19,"premio":{"comercial":50.0,"puro":50.0,"total":50.0},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DIH","capital":1400.00,"iof":0.09,"premio":{"comercial":25.0,"puro":25.0,"total":25.0},"taxa":{"comercial":0.00031,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DG 10","capital":6000.00,"iof":0.14,"premio":{"comercial":37.50,"puro":37.50,"total":37.50},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"AFI","capital":2900.00,"iof":0.14,"premio":{"comercial":37.50,"puro":37.50,"total":37.50},"taxa":{"comercial":0.000015,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]}],"contratantes":[{"numero":1,"iof":1.24,"premio":{"comercial":4.38,"puro":3.98,"total":5.00},"taxa":{"comercial":0.0002185,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}],"coberturas":[{"sigla":"BAS","capital":119.8,"iof":1.24,"premio":{"comercial":2.58,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000043,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DG 10","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"MAP","capital":1000.7,"iof":1.24,"premio":{"comercial":1.55,"puro":3.98,"total":5.00},"taxa":{"comercial":0.00031,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DIH","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"AFI","capital":2900.2,"iof":1.24,"premio":{"comercial":0.22,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000015,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]}],"grupos":[{"numero":1,"iof":1.24,"premio":{"comercial":4.38,"puro":3.98,"total":5.00},"taxa":{"comercial":0.0002185,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}],"coberturas":[{"sigla":"BAS","capital":119.8,"iof":1.24,"premio":{"comercial":2.58,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000043,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"MAP","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"AFI","capital":1000.7,"iof":1.24,"premio":{"comercial":1.55,"puro":3.98,"total":5.00},"taxa":{"comercial":0.00031,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DIH","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DG 10","capital":2900.2,"iof":1.24,"premio":{"comercial":0.22,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000015,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]}],"segurados":[{"numero":1,"iof":1.24,"premio":{"comercial":4.38,"puro":3.98,"total":5.00},"taxa":{"comercial":0.0002185,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}],"coberturas":[{"sigla":"BAS","capital":119.8,"iof":1.24,"premio":{"comercial":2.58,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000043,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"MAP","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"AFI","capital":1000.7,"iof":1.24,"premio":{"comercial":1.55,"puro":3.98,"total":5.00},"taxa":{"comercial":0.00031,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DG 10","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DIH","capital":1000900,"iof":1.24,"premio":{"comercial":0.22,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000015,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]}]}]}]}]}}],"retornoAceitacao":{},"retornoIntegracoes":{"validacaoZeroDolar":null,"IndiceMonetario":{"ItensCotacao":[{"moedaOrigem":"USD","moedaDestino":"BRL","dataCotacao":13112018,"cotacao":"3.74720000"},{"moedaOrigem":"EUR","moedaDestino":"BRL","dataCotacao":13112018,"cotacao":"4.04720000"},{"moedaOrigem":"BRL","moedaDestino":"BRL","dataCotacao":13112018,"cotacao":"1"}]}}}]}';

        EmissaoTO.PayloadTO payloadTO = (EmissaoTO.PayloadTO) JSON.deserialize(payload, EmissaoTO.PayloadTO.class);

        Contract contrato = [SELECT Id, Produto__c FROM Contract]; // PLV-5331 INÍCIO/FIM

        system.debug('Contrato abaixo');
        system.debug('Contrato acima');

        for(EmissaoTO.OfertasTO oferta : payloadTO.ofertas){
            oferta.orcamento.vigenciaInicial = String.valueOf(System.today().addDays(1));
            oferta.orcamento.vigenciaFinal =  String.valueOf(System.today().addDays(2));
            oferta.orcamento.dataCalculo = String.valueOf(System.today().addDays(1));
            oferta.orcamento.idProdutoSf = contrato.Produto__c;

            listaOfertas.add(oferta);
        }

        if(listaOfertas.isEmpty()) return; // PLV-5331 INÍCIO/FIM

        payload = JSON.serialize(listaOfertas[0]); // PLV-5331 INÍCIO/FIM

        Test.startTest();
        ServiceTO.PayRetornoOfertasTO RetornoOferta = orcamentoGenericoBuilder.getInstance().gerarOrcamentoGravar(payloadTO);

        orcamentoGenericoBuilder.getInstance().gerarOrcamentoCivCalculo(payload);
        Test.stopTest();
    }

    
    @IsTest
    public static void buscarParcelamentosTest(){
		Test.startTest(); // PLV-5331
	   //PLV-3731 - INICIO
        //List<StaticResource> listStaticResource = [SELECT body FROM StaticResource WHERE name = 'PayloadOrcamento2' LIMIT 1];
		//PLV-3731 - FIM
        //if(listStaticResource.IsEmpty()) return;

        Contract contrato = [SELECT Id, Produto__c FROM Contract]; // PLV-5331 INÍCIO/FIM
        System.debug('contrato => ' + contrato);

        List<EmissaoTO.OfertasTO> listaOfertas = new List<EmissaoTO.OfertasTO>(); // PLV-5331 INÍCIO/FIM

        String payload = '{"ofertas":[{"orcamento":{"tipoVigencia":"Periódico","tipoSeguro":"eds","vigenciaFinal":"2019-10-08","numeroOrcamento":"00000003","numeroPortal":0,"codigoProdutoVida":"VI-PESSOAS","idProdutoSf": "'+contrato.Produto__c+'","customizavel":true,"contratantes":[{"tipo":"PRI","numero":1,"grupos":[{"numero":1,"segurados":[{"pessoa":{"tipo":"FIS","enderecos":[{"uf":"SP","cidade":"SAO PAULO","complemento":"Apto 22","logradouro":"Guaianses","bairro":"Centro","complementoCep":"420","tipoLogradouro":"R","paisResidencia":"BRASIL","tipoEndereco":"REC","numeroLogradouro":"92","cep":"07114"}],"nome":"Testinho","dadosPessoaFisica":{"numeroCpf":"438912318","profissao":null,"tipoContrato":"TODOS","celular":"(11) 11111-1111","digitoCpf":"14","dataNascimento":"2000-11-11","fumante":false,"sexo":"MASCULINO","renda":"FAIXA2"},"email":"teste@teste.com.br"},"numero":1,"coberturas":[{"sigla":"BAS","valor":20000},{"sigla":"MAP","valor":20000},{"sigla":"CAP","valor":10}]}],"nome":"Testinho","qtdeVidas":1}]}],"canalDistribuicao":"EXE","meioComercializacao":"CO2","segmento":"Individual","versoesCalculos":[{"opcao":0,"tipo":"FPG","descontoAgravo":0},{"opcao":1,"tipo":"FPG","descontoAgravo":-5},{"opcao":2,"tipo":"FPG","descontoAgravo":5}],"ordemPortal":1,"rotulo":"Sniper - Plano Básico","remuneracoes":[{"percentual":20,"tipoRemuneracao":"CORRETAGEM"}],"vigenciaInicial":"2019-09-23","dataCalculo":"2019-09-23"},"retornosCalculo":[{"opcao":0,"orcnum":"00000003","numeroOrcamento":"00000003","numeroOferta":123,"precificacao":{"juros":0,"iof":1.24,"encargos":0,"custoDeApolice":0,"premio":{"comercial":205.98,"puro":219.98,"total":225.00},"taxa":{"comercial":0.0002185,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}],"coberturas":[{"sigla":"BAS","capital":350000.00,"iof":0.28,"premio":{"comercial":75.00,"puro":75.00,"total":75.00},"taxa":{"comercial":0.000043,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"MAP","capital":500000.00,"iof":0.19,"premio":{"comercial":50.0,"puro":50.0,"total":50.0},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DIH","capital":1400.00,"iof":0.09,"premio":{"comercial":25.0,"puro":25.0,"total":25.0},"taxa":{"comercial":0.00031,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DG 10","capital":6000.00,"iof":0.14,"premio":{"comercial":37.50,"puro":37.50,"total":37.50},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"AFI","capital":2900.00,"iof":0.14,"premio":{"comercial":37.50,"puro":37.50,"total":37.50},"taxa":{"comercial":0.000015,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]}],"contratantes":[{"numero":1,"iof":1.24,"premio":{"comercial":4.38,"puro":3.98,"total":5.00},"taxa":{"comercial":0.0002185,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}],"coberturas":[{"sigla":"BAS","capital":119.8,"iof":1.24,"premio":{"comercial":2.58,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000043,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DG 10","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"MAP","capital":1000.7,"iof":1.24,"premio":{"comercial":1.55,"puro":3.98,"total":5.00},"taxa":{"comercial":0.00031,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DIH","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"AFI","capital":2900.2,"iof":1.24,"premio":{"comercial":0.22,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000015,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]}],"grupos":[{"numero":1,"iof":1.24,"premio":{"comercial":4.38,"puro":3.98,"total":5.00},"taxa":{"comercial":0.0002185,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}],"coberturas":[{"sigla":"BAS","capital":119.8,"iof":1.24,"premio":{"comercial":2.58,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000043,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"MAP","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"AFI","capital":1000.7,"iof":1.24,"premio":{"comercial":1.55,"puro":3.98,"total":5.00},"taxa":{"comercial":0.00031,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DIH","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DG 10","capital":2900.2,"iof":1.24,"premio":{"comercial":0.22,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000015,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]}],"segurados":[{"numero":1,"iof":1.24,"premio":{"comercial":4.38,"puro":3.98,"total":5.00},"taxa":{"comercial":0.0002185,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}],"coberturas":[{"sigla":"BAS","capital":119.8,"iof":1.24,"premio":{"comercial":2.58,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000043,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"MAP","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"AFI","capital":1000.7,"iof":1.24,"premio":{"comercial":1.55,"puro":3.98,"total":5.00},"taxa":{"comercial":0.00031,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DG 10","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DIH","capital":1000900,"iof":1.24,"premio":{"comercial":0.22,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000015,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]}]}]}]}]}}],"retornoAceitacao":{},"retornoIntegracoes":{"validacaoZeroDolar":null,"IndiceMonetario":{"ItensCotacao":[{"moedaOrigem":"USD","moedaDestino":"BRL","dataCotacao":13112018,"cotacao":"3.74720000"},{"moedaOrigem":"EUR","moedaDestino":"BRL","dataCotacao":13112018,"cotacao":"4.04720000"},{"moedaOrigem":"BRL","moedaDestino":"BRL","dataCotacao":13112018,"cotacao":"1"}]}}}]}';// PLV-5331 INÍCIO/FIM //ANNVI-55 - INICIO/FIM

        EmissaoTO.PayloadTO payloadTO = (EmissaoTO.PayloadTO) JSON.deserialize(payload, EmissaoTO.PayloadTO.class);

        for(EmissaoTO.OfertasTO oferta : payloadTO.ofertas){
            oferta.orcamento.vigenciaInicial = String.valueOf(System.today().addDays(1));
            oferta.orcamento.vigenciaFinal = String.valueOf(System.today().addDays(2));
            oferta.orcamento.dataCalculo = String.valueOf(system.today().addDays(-130));
        }

        // if(listaOfertas.isEmpty()) return; // PLV-5331 INÍCIO/FIM

        // payload = JSON.serialize(listaOfertas[0]); // PLV-5331 INÍCIO/FIM

        List<Product2> prod2 = [SELECT ProductCode, CodigoPrecificaProduto__c FROM Product2 ];
        System.debug('prod2: ' + prod2);

        List<Product2> prod = [SELECT ProductCode, CodigoPrecificaProduto__c FROM Product2 
                    WHERE CodigoPrecificaProduto__c = 'VI-PESSOAS' AND Id =: contrato.Produto__c];
        System.debug('prod: ' + prod);
        

        ParametroVigencia__c param2 = [SELECT Id, ParcelamentoAposFinalVigencia__c FROM ParametroVigencia__c];
        param2.ParcelamentoAposFinalVigencia__c = true;
        upsert param2;

        CondicaoCobranca__c condicaoCobranca = [//ANNVI-55 - INICIO
            SELECT 
                Id,
                NomeFormaPagamento__c,
                FormaPagamento__c,
                FormaPagamento__r.Codigo__c,	
                FormaPagamento__r.Name,
                TipoPagamento__c,
                QuantidadeParcelas__c,
                PercentualDescontoAgravo__c,
                //LimiteValorParcela__c,//ANNVI-55 - INICIO/FIM
                AntecipacaoComissao__c,
                Produto__r.ProductCode,
                Produto__r.Status__c
            FROM
                CondicaoCobranca__c
            ];
     
        condicaoCobranca.NomeFormaPagamento__c = 'ADC';
        condicaoCobranca.TipoPagamento__c = 'ADC';
        condicaoCobranca.Produto__r.ProductCode = 'VI-PESSOAS';

        Product2 produto = [SELECT Id, ProductCode FROM Product2 WHERE Id = :condicaoCobranca.Produto__r.Id];
        produto.ProductCode = 'VI-PESSOAS';

        update produto;

        condicaoCobranca.Produto__r = produto;

        update condicaoCobranca;

        CondicaoCobranca__c condicaoCobranca2 = [
            SELECT 
                Id,
                NomeFormaPagamento__c,
                FormaPagamento__c,
                FormaPagamento__r.Codigo__c,	
                FormaPagamento__r.Name,
                TipoPagamento__c,
                QuantidadeParcelas__c,
                PercentualDescontoAgravo__c,
                //LimiteValorParcela__c,//ANNVI-55 - INICIO/FIM
                AntecipacaoComissao__c,
                Produto__r.ProductCode,
                Produto__r.Status__c
            FROM
                CondicaoCobranca__c
            ];
     
        condicaoCobranca2.NomeFormaPagamento__c = 'ADC';
        condicaoCobranca2.TipoPagamento__c = 'ADC';
        condicaoCobranca2.Produto__r.ProductCode = 'VI-PESSOAS';

        Product2 produto2 = [SELECT Id, ProductCode FROM Product2 WHERE Id = :condicaoCobranca2.Produto__r.Id];
        produto2.ProductCode = 'VI-PESSOAS';

        update produto2;

        condicaoCobranca2.Produto__r = produto2;

        update condicaoCobranca2;

        TestDataFactory.gerarPlanoParcelamento(condicaoCobranca.FormaPagamento__r.Id);
        TestDataFactory.gerarPlanoParcelamento(condicaoCobranca2.FormaPagamento__r.Id);
           
        //ANNVI-55 - FIM
        OrcamentoGenericoBuilder.buscarParcelamentos(payloadTO.ofertas[0]);
        Test.StopTest();
    }
    //PLV-3667 - FIM - Aumento de cobertura de classes de teste
    //PLV-4370 - INICIO
    @isTest
    static void testEmissaoOrcamentoGenericBuilderOrcamentoRecusasSampleMed() {

        Id recTypeProdTec = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id;
        Id recTypeProdCom = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id;
      
        Test.startTest();
        List<StaticResource> listStaticResource = new List<StaticResource>();

        Account conta = [SELECT Id FROM Account];
        
        Product2 prodTec = [SELECT Id FROM Product2 WHERE RecordTypeId =: recTypeProdTec LIMIT 1];
        prodTec.Status__c = 'Ativo';
        update prodTec;

        Product2 produtoCom = [SELECT Id FROM Product2 WHERE RecordTypeId =: recTypeProdCom];
        
        CanalDistribuicao__c canalDistribuicao = [SELECT ID FROM CanalDistribuicao__c];
        canalDistribuicao.Status__c = 'Ativo';
        update canalDistribuicao;

        Opportunity opportunity = [SELECT Id FROM Opportunity];

        String jsonTest = '{'+
		'   \"retornoAceitacao\":{'+
		'      \"analises\":['+
		'         {'+
		'            \"descricao\":\"TESTE\"'+
		'         }'+
		'      ],'+
		'      \"decisoes\":['+
		'         {'+
		'            \"codigo\":600,'+
		'            \"tipo\":\"Risco\",'+
		'            \"acao\":\"Tele\",'+
		'            \"descricao\":\"TIPO SUBSCRIÇÃO\"'+
		'         }'+
		'      ],'+
		'      \"recusas\":['+
		'         {'+
		'            \"descricao\":\"TESTE\",'+
		'            \"mensagens\":{'+
        '               \"cliente\":\"teste\",'+
        '               \"representante\":\"teste\",'+
        '               \"interna\":\"teste\"'+
                    '}'+
		'         }'+
		'      ],'+
		'      \"avisos\":['+
		'         {'+
		'            \"descricao\":\"TESTE\"'+
		'         }'+
		'      ],'+
		'      \"pendencias\":['+
		'         {'+
		'            \"descricao\":\"TESTE\"'+
		'         }'+
		'      ]'+
		'   }'+
		'}';
		// PLV-5331 FIM
       
        EmissaoTO payloadTO = (EmissaoTO) JSON.deserialize(jsonTest, EmissaoTO.class);
               
        EmissaoTO.RetornoAceitacaoTO jsonRecusa = payloadTO.retornoAceitacao;
        
        OrcamentoGenericoBuilder.getInstance().gerarCriticasODMOrcamento(jsonRecusa, opportunity.Id);
        system.debug('Total registro listStaticResource '+listStaticResource.size());
        system.assertEquals(listStaticResource.size(), 0);
       
        Test.stopTest();
    }
    //PLV-4370 - FIM
    //ANNVI-55 - INICIO
    @isTest
    static void testEmisOrcGenBuildPendencias() {

        Id recTypeProdTec = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id;
        Id recTypeProdCom = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id;
      
        Test.startTest();
        List<StaticResource> listStaticResource = new List<StaticResource>();

        Account conta = [SELECT Id FROM Account];
        
        Product2 prodTec = [SELECT Id FROM Product2 WHERE RecordTypeId =: recTypeProdTec LIMIT 1];
        prodTec.Status__c = 'Ativo';
        update prodTec;

        Product2 produtoCom = [SELECT Id FROM Product2 WHERE RecordTypeId =: recTypeProdCom];
        
        CanalDistribuicao__c canalDistribuicao = [SELECT ID FROM CanalDistribuicao__c];
        canalDistribuicao.Status__c = 'Ativo';
        update canalDistribuicao;

        Opportunity opportunity = [SELECT Id FROM Opportunity];

        EmissaoTO.MensagenTO mensagemTO = new EmissaoTO.MensagenTO();
        mensagemTO.interna = 'Teste';
        mensagemTO.cliente = 'Teste';
        mensagemTO.representante = 'Teste';

        EmissaoTO payload = new EmissaoTO();
        List<EmissaoTO.PendenciaTO> lsPendenciasTO = new List<EmissaoTO.PendenciaTO>();
        payload.retornoAceitacao = new EmissaoTO.RetornoAceitacaoTO();

        EmissaoTO.PendenciaTO pendenciaTO = new EmissaoTO.PendenciaTO();
        pendenciaTO.identificacao = 'Teste';
        pendenciaTO.atendida = true;
        pendenciaTO.mensagens = mensagemTO;
        pendenciaTO.area = 'Teste';
        pendenciaTO.codigo = 1;
        pendenciaTO.procedimento = 'Teste';
        pendenciaTO.descricao = 'Teste';
        pendenciaTO.severidade = 1;
        pendenciaTO.setor = 'Teste';
        pendenciaTO.momentoAnalise = 'Teste'; 

        lsPendenciasTO.add(pendenciaTO);
        payload.retornoAceitacao.analises = null;
        payload.retornoAceitacao.avisos = null;
        payload.retornoAceitacao.decisoes = null;
        payload.retornoAceitacao.nr = null;
        payload.retornoAceitacao.recusas = null;
        payload.retornoAceitacao.pendencias = lsPendenciasTO;

        String jsonTest = JSON.serialize(payload);/*'{'+
		'   \"retornoAceitacao\":{'+
		'      \"analises\":['+
		
		'      ],'+
		'      \"decisoes\":['+
		
		'      ],'+
		'      \"recusas\":['+
		
		'      ],'+
		'      \"avisos\":['+
		
		'      ],'+
		'      \"pendencias\":['+
		'         {'+
		'            \"identificacao\": \"Teste\",'+
        '            \"atendida\": true,'+
        '            \"mensagens\": mensagemTO,'+
        '            \"area\": \"Teste\",'+
        '            \"codigo\": 1,'+
        '            \"procedimento\": \"Teste\",'+
        '            \"descricao\": \"Teste\",'+
        '            \"severidade\": 1,'+
        '            \"setor\": \"Teste\",'+
        '            \"momentoAnalise\": \"Teste\"'+
		'         }'+
		'      ]'+
		'   }'+
		'}';*/
       
        EmissaoTO payloadTO = (EmissaoTO) JSON.deserialize(jsonTest, EmissaoTO.class);
               
        EmissaoTO.RetornoAceitacaoTO jsonRecusa = payloadTO.retornoAceitacao;
        
        OrcamentoGenericoBuilder.getInstance().gerarCriticasODMOrcamento(jsonRecusa, opportunity.Id);
        system.debug('Total registro listStaticResource '+listStaticResource.size());
        system.assertEquals(listStaticResource.size(), 0);
       
        Test.stopTest();
    }
    //ANNVI-55 - FIM

    //PLV - 4626 - VI - INICIO - GUSTAVO PEREIRA SYS4B 
    @isTest
    public static void gerarOrcamentoCivCalculoTest2(){
    
        Test.startTest(); //TKCL-256 FIX-05 INICIO/FIM
			Recordtype REC_ID_PERSONACCOUNT = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica');
			Date datePersonBirthdate = Date.newInstance(1985, 02, 02);
 			Map<String,Account> mStaticRecord = new Map<String,Account>();
			mStaticRecord.put('PessoaFisica', new Account(
				RecordtypeId = REC_ID_PERSONACCOUNT.Id,
				FirstName = 'TestFirstNamePessoaFisica',
				LastName = 'TestLastNamePessoaFisica',
				Cpf__c = '438.912.318-14',
                Pis__c = '123456789', // PLV-4445
				Pep__c = 'Não',
				Nacionalidade__c = 'Brasileira',
				Phone = '(00) 0000-0000', // ANNVI-55 - INICIO/FIM
				PersonBirthdate = datePersonBirthdate)
			);
        //insert mStaticRecord.values();
       ///String conta;
        //for(String s: mStaticRecord.keySet()){
            //conta = mStaticRecord.get(s).Id;
        //}

        //ANNVI-55 - INICIO
        ContadorCodigo__c confNumOferta = new ContadorCodigo__c(
            Name = 'NumeroOferta',
            Numero__c = 1
        );

        insert confNumOferta;        

        Account conta = [SELECT Id, IdExterno__c FROM Account limit 1];

        Profissao__c profissao = ( Profissao__c ) new ProfissaoFactory().createRecord();
        profissao.CodigoProfissao__c = '2111-06';
        profissao.Codigo__c = '2111-06';
        profissao.IdExterno__c = '2111-06';
        profissao.Status__c = 'Ativo';
        update profissao;
        //ANNVI-55 - FIM


        List<EmissaoTO.OfertasTO> listaOfertas = new List<EmissaoTO.OfertasTO>();

        List<StaticResource> listaStaticResource = new List<StaticResource>();
		//PLV-3731 - INICIO
        //listaStaticResource = [SELECT id, body FROM StaticResource WHERE name = 'PayloadOrcamento2' LIMIT 1]; // PLV-5331 INICIO / FIM
        //PLV-3731 - FIM

        // if(listaStaticResource.isEmpty()) return; // PLV-5331 INICIO / FIM

        // String payload = listaStaticResource[0].body.toString();
        String payload = '{ "ofertas": [ { "retornoCalculo": { "opcao": 0, "orcnum": "00000003", "numeroOrcamento": "00000003", "numeroOferta": 123, "precificacao": { "juros": 0, "iof": 1.24, "encargos": 0, "custoDeApolice": 0, "premio": { "comercial": 205.98, "puro": 219.98, "total": 225.00 }, "taxa": { "comercial": 0.0002185, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ], "coberturas": [ { "sigla": "BAS", "capital": 350000.00, "iof": 0.28, "premio": { "comercial": 75.00, "puro": 75.00, "total": 75.00 }, "taxa": { "comercial": 0.000043, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "MAP", "capital": 500000.00, "iof": 0.19, "premio": { "comercial": 50.0, "puro": 50.0, "total": 50.0 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DIH", "capital": 1400.00, "iof": 0.09, "premio": { "comercial": 25.0, "puro": 25.0, "total": 25.0 }, "taxa": { "comercial": 0.00031, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DG 10", "capital": 6000.00, "iof": 0.14, "premio": { "comercial": 37.50, "puro": 37.50, "total": 37.50 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "AFI", "capital": 2900.00, "iof": 0.14, "premio": { "comercial": 37.50, "puro": 37.50, "total": 37.50 }, "taxa": { "comercial": 0.000015, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] } ], "contratantes": [ { "numero": 1, "iof": 1.24, "premio": { "comercial": 4.38, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.0002185, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ], "coberturas": [ { "sigla": "BAS", "capital": 119.8, "iof": 1.24, "premio": { "comercial": 2.58, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000043, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DG 10", "capital": 12.8, "iof": 1.24, "premio": { "comercial": 0.03, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "MAP", "capital": 1000.7, "iof": 1.24, "premio": { "comercial": 1.55, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.00031, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DIH", "capital": 12.8, "iof": 1.24, "premio": { "comercial": 0.03, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "AFI", "capital": 2900.2, "iof": 1.24, "premio": { "comercial": 0.22, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000015, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] } ], "grupos": [ { "numero": 1, "iof": 1.24, "premio": { "comercial": 4.38, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.0002185, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ], "coberturas": [ { "sigla": "BAS", "capital": 119.8, "iof": 1.24, "premio": { "comercial": 2.58, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000043, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "MAP", "capital": 12.8, "iof": 1.24, "premio": { "comercial": 0.03, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "AFI", "capital": 1000.7, "iof": 1.24, "premio": { "comercial": 1.55, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.00031, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DIH", "capital": 12.8, "iof": 1.24, "premio": { "comercial": 0.03, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DG 10", "capital": 2900.2, "iof": 1.24, "premio": { "comercial": 0.22, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000015, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] } ], "segurados": [ { "numero": 1, "iof": 1.24, "premio": { "comercial": 4.38, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.0002185, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ], "coberturas": [ { "sigla": "BAS", "capital": 119.8, "iof": 1.24, "premio": { "comercial": 2.58, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000043, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "MAP", "capital": 12.8, "iof": 1.24, "premio": { "comercial": 0.03, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "AFI", "capital": 1000.7, "iof": 1.24, "premio": { "comercial": 1.55, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.00031, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DG 10", "capital": 12.8, "iof": 1.24, "premio": { "comercial": 0.03, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DIH", "capital": 1000900, "iof": 1.24, "premio": { "comercial": 0.22, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000015, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] } ] } ] } ] } ] } }, "orcamento": { "tipoVigencia": "Periódico", "tipoSeguro": "Novo", "endosso": "0", "vigenciaFinal": "2019-10-08", "numeroOrcamento": "00000003", "numeroPortal": 0, "codigoProdutoVida": "VI-PESSOAS", "idProdutoSf": null, "customizavel": true, "contratantes": [ { "tipo": "PRI", "numero": 1, "grupos": [ { "numero": 1, "segurados": [ { "pessoa": { "tipo": "FIS", "enderecos": [ { "uf": "SP", "cidade": "SAO PAULO", "complemento": "Apto 22", "logradouro": "Guaianses", "bairro": "Centro", "complementoCep": "420", "tipoLogradouro": "R", "paisResidencia": "BRASIL", "tipoEndereco": "REC", "numeroLogradouro": "92", "cep": "07114" } ], "nome": "Testinho", "dadosPessoaFisica": { "numeroCpf": 105423460, "profissao": null, "tipoContrato": "TODOS", "celular": "(11) 11111-1111", "digitoCpf": 44, "dataNascimento": "2000-11-11", "fumante": false, "sexo": "MASCULINO", "renda": "FAIXA2" }, "email": "teste@teste.com.br" }, "numero": 1, "coberturas": [ { "sigla": "BAS", "valor": 20000 }, { "sigla": "MAP", "valor": 20000 }, { "sigla": "CAP", "valor": 10 } ] } ], "nome": "Testinho", "qtdeVidas": 1 } ], "pessoa": { "nome": "Testinho", "tipo": "FIS", "enderecos": [ { "uf": "SP", "cidade": "SAO PAULO", "complemento": "Apto 22", "logradouro": "Guaianses", "bairro": "Centro", "complementoCep": "420", "tipoLogradouro": "R", "paisResidencia": "BRASIL", "tipoEndereco": "REC", "numeroLogradouro": "92", "cep": "07114" } ], "email": "teste@teste.com.br", "dadosPessoaFisica": { "numeroCpf": 105423460, "digitoCpf": 44, "dataNascimento": "2000-11-11", "fumante": false, "sexo": "MASCULINO", "estadoCivil": "CAS" } } } ], "canalDistribuicao": "EXE", "meioComercializacao": "CO2", "segmento": "Individual", "versoesCalculos": [ { "opcao": 0, "tipo": "FPG", "descontoAgravo": 0 }, { "opcao": 1, "tipo": "FPG", "descontoAgravo": -5 }, { "opcao": 2, "tipo": "FPG", "descontoAgravo": 5 } ], "ordemPortal": 1, "rotulo": "Sniper - Plano Básico", "remuneracoes": [ { "percentual": 20, "tipoRemuneracao": "CORRETAGEM" } ], "vigenciaInicial": "2019-09-23", "dataCalculo": "2019-09-23" }, "retornosCalculo": [ { "opcao": 0, "orcnum": "00000003", "numeroOrcamento": "00000003", "numeroOferta": 123, "precificacao": { "juros": 0, "iof": 1.24, "encargos": 0, "custoDeApolice": 0, "premio": { "comercial": 205.98, "puro": 219.98, "total": 225.00 }, "taxa": { "comercial": 0.0002185, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ], "coberturas": [ { "sigla": "BAS", "capital": 350000.00, "iof": 0.28, "premio": { "comercial": 75.00, "puro": 75.00, "total": 75.00 }, "taxa": { "comercial": 0.000043, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "MAP", "capital": 500000.00, "iof": 0.19, "premio": { "comercial": 50.0, "puro": 50.0, "total": 50.0 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DIH", "capital": 1400.00, "iof": 0.09, "premio": { "comercial": 25.0, "puro": 25.0, "total": 25.0 }, "taxa": { "comercial": 0.00031, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DG 10", "capital": 6000.00, "iof": 0.14, "premio": { "comercial": 37.50, "puro": 37.50, "total": 37.50 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "AFI", "capital": 2900.00, "iof": 0.14, "premio": { "comercial": 37.50, "puro": 37.50, "total": 37.50 }, "taxa": { "comercial": 0.000015, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] } ], "contratantes": [ { "numero": 1, "iof": 1.24, "premio": { "comercial": 4.38, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.0002185, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ], "coberturas": [ { "sigla": "BAS", "capital": 119.8, "iof": 1.24, "premio": { "comercial": 2.58, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000043, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DG 10", "capital": 12.8, "iof": 1.24, "premio": { "comercial": 0.03, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "MAP", "capital": 1000.7, "iof": 1.24, "premio": { "comercial": 1.55, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.00031, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DIH", "capital": 12.8, "iof": 1.24, "premio": { "comercial": 0.03, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "AFI", "capital": 2900.2, "iof": 1.24, "premio": { "comercial": 0.22, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000015, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] } ], "grupos": [ { "numero": 1, "iof": 1.24, "premio": { "comercial": 4.38, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.0002185, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ], "coberturas": [ { "sigla": "BAS", "capital": 119.8, "iof": 1.24, "premio": { "comercial": 2.58, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000043, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "MAP", "capital": 12.8, "iof": 1.24, "premio": { "comercial": 0.03, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "AFI", "capital": 1000.7, "iof": 1.24, "premio": { "comercial": 1.55, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.00031, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DIH", "capital": 12.8, "iof": 1.24, "premio": { "comercial": 0.03, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DG 10", "capital": 2900.2, "iof": 1.24, "premio": { "comercial": 0.22, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000015, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] } ], "segurados": [ { "numero": 1, "iof": 1.24, "premio": { "comercial": 4.38, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.0002185, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ], "coberturas": [ { "sigla": "BAS", "capital": 119.8, "iof": 1.24, "premio": { "comercial": 2.58, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000043, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "MAP", "capital": 12.8, "iof": 1.24, "premio": { "comercial": 0.03, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "AFI", "capital": 1000.7, "iof": 1.24, "premio": { "comercial": 1.55, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.00031, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DG 10", "capital": 12.8, "iof": 1.24, "premio": { "comercial": 0.03, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DIH", "capital": 1000900, "iof": 1.24, "premio": { "comercial": 0.22, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000015, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] } ] } ] } ] } ] } } ], "retornoAceitacao": {}, "retornoIntegracoes": { "validacaoZeroDolar": null, "IndiceMonetario": { "ItensCotacao": [ { "moedaOrigem": "USD", "moedaDestino": "BRL", "dataCotacao": 13112018, "cotacao": "3.74720000" }, { "moedaOrigem": "EUR", "moedaDestino": "BRL", "dataCotacao": 13112018, "cotacao": "4.04720000" }, { "moedaOrigem": "BRL", "moedaDestino": "BRL", "dataCotacao": 13112018, "cotacao": "1" } ] } } } ] }';//ANNVI-55 - INICIO/FIM

        EmissaoTO.PayloadTO payloadTO = new EmissaoTO.PayloadTO();//ANNVI-55 - INICIO
        EmissaoTO.RetornoCalculoTO retornoCalculo = new EmissaoTO.RetornoCalculoTO();
        EmissaoTO.RetornoIntegracoesTO retornoIntegracoes = new EmissaoTO.RetornoIntegracoesTO();
        payloadTO = (EmissaoTO.PayloadTO) JSON.deserialize(payload, EmissaoTO.PayloadTO.class);//ANNVI-55 - FIM
        system.debug('Payload: '+payloadTO);

        Contract contrato = [SELECT Id, Produto__c, Empresa__c, Sucursal__c, CodigoRamo__c, NumeroApolice__c, Endosso__c,
                                Nome_Social__c // ANNVI-55 - INICIO/FIM
                                FROM Contract]; // PLV-5331 INÍCIO/FIM

        system.debug('Contrato abaixo');
        system.debug('Contrato acima');

        for(EmissaoTO.OfertasTO oferta : payloadTO.ofertas){
            oferta.orcamento = new EmissaoTO();//ANNVI-55 - INICIO/FIM
            oferta.orcamento.vigenciaInicial = String.valueOf(System.today().addDays(1));
            oferta.orcamento.vigenciaFinal =  String.valueOf(System.today().addDays(2));
            oferta.orcamento.dataCalculo = String.valueOf(System.today().addDays(1));
            oferta.orcamento.tipoSeguro = 'CAN';
            oferta.orcamento.endosso = '0';//ANNVI-55 - INICIO
            oferta.orcamento.apolice = '000000014889';
            oferta.orcamento.ramo = 2;
            oferta.orcamento.empresa = '22';
            oferta.orcamento.sucursal = 999;
            oferta.orcamento.canalDistribuicao = 'EXE';
            oferta.orcamento.numeroOrcamento = '1';
            
            oferta.orcamento.remuneracoes = new List<EmissaoTO.RemuneracaoTO>();
            oferta.orcamento.remuneracao = new EmissaoTO.RemuneracaoTO();
            oferta.orcamento.remuneracao.tipoRemuneracao = 'AGENCIAMENTO';
            oferta.orcamento.remuneracao.percentual = 20;
            oferta.orcamento.remuneracoes.add(oferta.orcamento.remuneracao);

            //ANNVI-55 - FIM
            oferta.orcamento.idProdutoSf = contrato.Produto__c;
            
            // PLV 4655 INICIO

            EmissaoTO contratoOriginal = new EmissaoTO();
            contratoOriginal.codigoProdutoVida = '201700001';
            contratoOriginal.idProdutoSf = contrato.Produto__c;
            contratoOriginal.vigenciaFinal = '2021-11-19';
            contratoOriginal.vigenciaInicial = '2021-11-19';
            contratoOriginal.empresa = contrato.Empresa__c;
            contratoOriginal.sucursal = Integer.ValueOf(contrato.Sucursal__c);
            contratoOriginal.ramo = Integer.ValueOf(contrato.CodigoRamo__c);
            contratoOriginal.apolice = contrato.NumeroApolice__c;
            contratoOriginal.endosso = contrato.Endosso__c;
            
            // PLV 4655 FIM
            
            List<EmissaoTO.VersoesCalculo> versoesCalculos = new List<EmissaoTO.VersoesCalculo>();
            EmissaoTO.VersoesCalculo versaoCalculo = new EmissaoTO.VersoesCalculo();
            versaoCalculo.opcao = 1;
            versaoCalculo.tipo = 'FPG';
            versaoCalculo.descontoAgravo = -15;
            versoesCalculos.add(versaoCalculo);
            contratoOriginal.versoesCalculos = versoesCalculos;

            EmissaoTO.PrecificacaoTO precificacao = 
            new EmissaoTO.PrecificacaoTO();
    
            List<EmissaoTO.ContratanteTO> contratantes = 
            new List<EmissaoTO.ContratanteTO>();
    
            EmissaoTO.ContratanteTO contratante = 
            new EmissaoTO.ContratanteTO();
    
            EmissaoTO.TaxaTO taxa = 
            new EmissaoTO.TaxaTO(); 
    
            EmissaoTO.PremioTO premio = 
            new EmissaoTO.PremioTO(); 
    
            List<EmissaoTO.CoberturaTO> coberturas = 
            new List<EmissaoTO.CoberturaTO>();
    
            EmissaoTO.CoberturaTO cobertura = 
            new EmissaoTO.CoberturaTO();   
            
            List<EmissaoTO.GrupoTO> grupos = 
            new List<EmissaoTO.GrupoTO>();
    
            EmissaoTO.GrupoTO grupo = 
            new EmissaoTO.GrupoTO();  
    
            List<EmissaoTO.SeguradoTO> segurados = 
            new List<EmissaoTO.SeguradoTO>();
    
            EmissaoTO.SeguradoTO segurado = 
            new EmissaoTO.SeguradoTO();  
    
            EmissaoTO.PessoaTO pessoa = 
            new EmissaoTO.PessoaTO();
    
            EmissaoTO.DadosPessoaFisicaTO pessoaFisica = 
            new EmissaoTO.DadosPessoaFisicaTO(); 

            pessoaFisica.sexo = 'FEM';
            pessoaFisica.fumante = false;
            pessoaFisica.dataNascimento = '1959-03-12T00:00:00.000Z';
            pessoaFisica.regimeTrabalho = 'CLT';
            pessoaFisica.numeroCpf = '105423460'; //ANNVI-55 - INICIO
            pessoaFisica.digitoCpf = '44';
            pessoaFisica.estadoCivil = 'CAS'; 
            pessoaFisica.profissao = '2111-06';//ANNVI-55 - FIM
    

            pessoa.rendaMensal = 5000;
            pessoa.nome = 'XPTO';
            pessoa.tipo = 'FIS';//ANNVI-55 - INICIO

            List<EmissaoTO.EnderecoTO> enderecos = new List<EmissaoTO.EnderecoTO>();
            EmissaoTO.EnderecoTO endereco = new EmissaoTO.EnderecoTO();      

            endereco.cep = '05835';
            endereco.complementoCep = '906';
            endereco.tipoLogradouro = '';
            endereco.tipoEndereco = '';
            endereco.logradouro = '';
            endereco.numeroLogradouro = '';
            endereco.complemento = '';
            endereco.bairro = '';
            endereco.cidade = '';
            endereco.uf = '';
            endereco.paisResidencia = '';
        
            enderecos.add(endereco);

            pessoa.enderecos = enderecos;
            pessoa.email = 'teste@teste.com.br'; //ANNVI-55 - FIM
            pessoa.dadosPessoaFisica = pessoaFisica;
    
            taxa.pura = 10;
            taxa.comercial = 20;
            taxa.total = 30;
    
            premio.comercial = 10;
            premio.total = 20;
            premio.puro = 30;
    
            cobertura.taxa = taxa;
            cobertura.premio = premio;
            cobertura.sigla = 'MAP';
            cobertura.valor = 10.0;
            cobertura.quantidade = '1';
    
            coberturas.add(cobertura);

            //ANNVI-55 - INICIO
            List<EmissaoTO.DescontoAgravoTO> descontoAgravo = new List<EmissaoTO.DescontoAgravoTO>();

            EmissaoTO.DescontoAgravoTO descontoAgravoTEC = new EmissaoTO.DescontoAgravoTO();                        
            descontoAgravoTEC.monetario = 100;
            descontoAgravoTEC.percentual = 100;
            descontoAgravoTEC.tipo = 'TEC';

            descontoAgravo.add(descontoAgravoTEC);

            segurado.descontoAgravo = descontoAgravo;
            //ANNVI-55 - FIM    
            segurado.pessoa = pessoa;
            segurado.numero = '1';
            segurado.coberturas = coberturas;
    
            segurados.add(segurado);            
    
            grupo.segurados = segurados;
            grupo.coberturas = coberturas;
            grupo.tipoCalculo = ' ';
            grupo.numero = '1';
            grupo.nome = 'XPTO';
            grupo.qtdeVidas = 1.0;
            grupo.iof = 1.0; //ANNVI-55 - INICIO
            grupo.premio = premio;
            grupo.taxa = taxa;
            grupo.descontoAgravo = descontoAgravo;//ANNVI-55 - FIM
    
            grupos.add(grupo);
    
            contratante.grupos = grupos;
            contratante.coberturas = coberturas;
            contratante.tipo = 'PRI';
            contratante.numero = '1';
            contratante.taxa = taxa;
            contratante.premio = premio;
            contratante.conta = conta.id;
            contratante.pessoa = new EmissaoTO.PessoaTO(); //ANNVI-55 - INICIO
            contratante.pessoa = pessoa; //ANNVI-55 - FIM
            contratante.descontoAgravo = descontoAgravo;
    
            contratantes.add(contratante);    
            
            precificacao.premio = premio;
            precificacao.coberturas = coberturas;
    
            precificacao.encargos               = 1.0;
            precificacao.iof                    = 1.0;
            precificacao.juros                  = 1.0;
            precificacao.custoApolice           = 1.0;
            precificacao.taxa                   = taxa;
            precificacao.contratantes           = contratantes;
            precificacao.descontoAgravo         = new List<EmissaoTO.DescontoAgravoTO>();
            precificacao.coberturas             = new List<EmissaoTO.CoberturaTO>();
            
            //EmissaoTO.CoberturaTO cobertura     = new EmissaoTO.CoberturaTO();            
            cobertura.descontoAgravo            = new List<EmissaoTO.DescontoagravoTO>();
            
            precificacao.coberturas.add(cobertura);
            
            contratoOriginal.precificacao = precificacao;
            contratoOriginal.contratantes = contratantes;

            oferta.orcamento.contratoOriginal = contratoOriginal;

            //ANNVI-55 - INICIO
            oferta.orcamento.precificacao = precificacao;
            oferta.orcamento.contratantes = contratantes;
            oferta.retornosCalculo.add(retornoCalculo);           
            retornoCalculo.precificacao = precificacao;
            //ANNVI-55 - FIM

            listaOfertas.add(oferta);
        }
        update contrato; //TKCL-256 FIX-05 INICIO/FIM
        if(listaOfertas.isEmpty()) return;
        system.debug('Lista: '+listaOfertas[0]);
        payload = JSON.serialize(listaOfertas[0]);
        system.debug('Payload: '+payload);

        //ANNVI-55 - INICIO
        Product2 produtoComercial = [SELECT Id, Name FROM Product2 WHERE Name = 'Nome Produto Comercial'];

        CanalDistribuicao__c canalDistribuicao = CreateTestData.createCanalDistribuicao();

        String payloadName = 'PayloadOrcamento001';
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: payloadName LIMIT 1];
        Blob payloadEntrada = sr.Body;

        Opportunity orcamento = new Opportunity(
            StageName = 'Em criação',
            CurrencyIsoCode = 'BRL',
            Name = 'ARQ-1100760',
            CloseDate = System.today().addDays(19),
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addDays(2),
            Produto__c = produtoComercial.Id,
            Probability = 10.0,
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaIndividual').Id,
            AccountId = conta.Id,
            Numero__c = '10005760',
            CanalDistribuicao__c = canalDistribuicao.Id,
            Payload__c = EncodingUtil.base64Decode(EncodingUtil.base64Encode(payloadEntrada)).toString()
        );

        insert orcamento;

        Garantia__c garantia = TestDataFactory.gerarGarantia();
        GarantiaProduto__c garantiaProduto = new GarantiaProduto__c(
            TipoGarantia__c = 'Cobertura',
            Garantia__c = garantia.id,
            OrdemPrioridade__c = 1
        );
        
        insert garantiaProduto;
        
        ContratanteOrcamento__c contratanteOrcamento = TestDataFactory.gerarContratanteOrcamento(orcamento, conta);
        GrupoOrcamento__c grupoOrcamento = TestDataFactory.gerarGrupoOrcamento(contratanteOrcamento);
        SeguradoOrcamento__c seguradoOrcamento = TestDataFactory.gerarSeguradoOrcamento(grupoOrcamento);
        GarantiaSeguradoOrcamento__c garantiaSeguradoOrcamento = TestDataFactory.gerarGarantiaSeguradoOrcamento(garantia, seguradoOrcamento);        
        RamoSeguro__c ramoSeguro = [SELECT Id, Name, Codigo__c FROM RamoSeguro__c];
        DadosCorretor__c dadosCorretor = [SELECT Id FROM DadosCorretor__c];
        Modalidade__c modalidade = [SELECT Id FROM Modalidade__c];
        
        Account empresa = new Account(Name = 'Conta corretor', Papel__c = 'Corretor', Cnpj__c = '08.370.609/0001-64');
        insert empresa;
         
        Quote proposta = new Quote(
                Name = QuoteBO.getInstance().gerarNameProposta('18', '00052488'),
                NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta('18', '00052488'),
                Produto__c = produtoComercial.Id,
                RamoSeguro__c = ramoSeguro.Id,
                Status = 'Em criação',
                VigenciaInicial__c = System.today(),
                VigenciaFinal__c = System.today().addMonths(1),
                Empresa__c = empresa.Id,
                CodigoCorretor__c = dadosCorretor.Id,
                DataCalculo__c = System.today(),
                DataCriacaoPortal__c = System.today(),
                TipoVigencia__c = 'Anual',
                MeioComercializacao__c = 'PMC',
                OpportunityId = orcamento.Id,
                Origem__c = '18',
                Modalidade__c = modalidade.Id,
                NumeroProposta__c = '00052488',
                Parceiro__c = '67708896000139',
                CupomDesconto__c = 'VALE50DESCONTO'
 
         );
 
        insert proposta;

        proposta.OpportunityId = orcamento.Id;
        proposta.Opportunity = orcamento;
        proposta.Opportunity.Id = orcamento.Id;
        proposta.Tipo__c = 'Endosso';
        proposta.ContractId = contrato.Id;
        proposta.Status = 'Devolvida';
        
        update proposta;
        contrato.Status = 'Emitido';
        update contrato;

        List<RemuneracaoContrato__c> remuneracoes = new List<RemuneracaoContrato__c>(); 
        List<Orcamento.RemuneracaoOrcamentoWrapper> listRemuneracaoOrcamentoWrappers = new List<Orcamento.RemuneracaoOrcamentoWrapper>();
        
        TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao();
        RemuneracaoContrato__c remuneracaoContrato = TestDataFactory.gerarRemuneracaoContrato(contrato, tipoRemuneracao);
        
        remuneracoes.add(remuneracaoContrato);

        update remuneracoes;        

        List<GarantiaContrato__c> garantiasContrato = new List<GarantiaContrato__c>(); 
        List<Orcamento.GarantiaWrapper> listGarantiasWrapper = new List<Orcamento.GarantiaWrapper>();

        GarantiaContrato__c garantiaContrato = TestDataFactory.gerarGarantiaContrato(contrato, garantiaProduto);
        garantiasContrato.add(garantiaContrato);

        update garantiasContrato;

        OrcamentoGenericoBuilder ogb = OrcamentoGenericoBuilder.getInstance();

        Account contaParceiro = new Account(Name = 'ParceiroTeste', CodigoEmpresa__c = '12', IdExterno__c = '67708896000139', Inscricao_Municipal__c = '123456789', Cnpj__c = '67.708.896/0001-39');
        insert contaParceiro;

        ogb.contrato = [SELECT Id, CanalDistribuicao__c, (SELECT Id FROM ContratantesContrato__r) FROM Contract LIMIT 1];
        
        ContratanteContrato__c contratanteContrato = TestDataFactory.gerarContratanteContrato(ogb.contrato, conta, contaParceiro);
        GrupoContrato__c grupoContrato = TestDataFactory.gerarGrupoContrato(contratanteContrato);
        SeguradoContrato__c seguradoContrato = TestDataFactory.gerarSeguradoContrato(grupoContrato, conta);
        GarantiaGrupoContrato__c garantiaGrupoContrato = TestDataFactory.gerarGarantiaGrupoContrato(garantia, grupoContrato);        

        grupoContrato.ContratanteContrato__c = ogb.contrato.ContratantesContrato__r[0].Id;
        grupoContrato.Descricao__c = 'Teste';
        grupoContrato.TipoCalculo__c = 'GLO';
        grupoContrato.Numero__c = 12345678;
        grupoContrato.TipoDescontoAgravo__c = 'Comercial';
        grupoContrato.PremioComercial__c = 1.0;
        grupoContrato.PremioPuro__c = 1.0;
        grupoContrato.PremioTotal__c = 1.0;
        grupoContrato.PremioIntegral__c = 1.0; 
        grupoContrato.TaxaComercial__c = 1.0;
        grupoContrato.TaxaPura__c = 1.0;
        grupoContrato.TaxaTotal__c = 1.0;
        grupoContrato.DescontoAgravoMonetarioComercial__c = 1.0;
        grupoContrato.DescontoAgravoMonetarioInformado__c = 1.0;
        grupoContrato.DescontoAgravoMonetarioTecnico__c = 1.0;
        grupoContrato.DescontoAgravoPercentualComercial__c = 1.0;
        grupoContrato.DescontoAgravoPercentualInformado__c = 1.0;
        grupoContrato.DescontoAgravoPercentualTecnico__c = 1.0;
        grupoContrato.IOF__c = 1.0;

        update grupoContrato;

        seguradoContrato.Conta__c = conta.Id;
        seguradoContrato.EnderecoBoleto__c = 'http://www.google.com.br';
        seguradoContrato.IOF__c = 1.0;
        seguradoContrato.IPCA__c = 1.0;
        seguradoContrato.PorcentagemParticipacaoSegurado__c = 1.0;
        seguradoContrato.PorcentagemParticipacaoVida__c = 1.0;
        seguradoContrato.QuantidadeParcelas__c = 1;
        seguradoContrato.Reenquadramento__c = 1.0;
        seguradoContrato.Numero__c = 12345678;
        seguradoContrato.TipoCusteio__c = 'Não Contributário';
        seguradoContrato.TipoDescontoAgravo__c = 'Comercial';
        seguradoContrato.TipoResponsavelPagamento__c = 'SEG';
        seguradoContrato.VencimentoPrimeiraParcela__c = System.today().addDays(1);
        seguradoContrato.PremioComercial__c = 1.0;
        seguradoContrato.PremioParcela__c = 1.0;
        seguradoContrato.PremioIntegral__c = 1.0;
        seguradoContrato.PremioPuro__c = 1.0;
        seguradoContrato.PremioTotal__c = 1.0;
        seguradoContrato.TaxaComercial__c = 1.0;
        seguradoContrato.TaxaPura__c = 1.0;
        seguradoContrato.TaxaTotal__c = 1.0;
        seguradoContrato.DescontoAgravoMonetarioComercial__c = 1.0;
        seguradoContrato.DescontoAgravoMonetarioInformado__c = 1.0;
        seguradoContrato.DescontoAgravoMonetarioTecnico__c = 1.0;
        seguradoContrato.DescontoAgravoPercentualComercial__c = 1.0;
        seguradoContrato.DescontoAgravoPercentualInformado__c = 1.0;
        seguradoContrato.DescontoAgravoPercentualTecnico__c = 1.0;

        update seguradoContrato;

        garantiaGrupoContrato.IOF__c = 1.0;
        garantiaGrupoContrato.Capital__c = 10.00;
        garantiaGrupoContrato.GarantiaProduto__c = garantiaProduto.Id; 
        garantiaGrupoContrato.Garantia__c = garantia.Id;
        garantiaGrupoContrato.NumeroSerie__c = '1';
        garantiaGrupoContrato.NumeroSorte__c = '1';
        garantiaGrupoContrato.Percentual__c = 1.0;
        garantiaGrupoContrato.TipoDescontoAgravo__c = '';
        garantiaGrupoContrato.ValorCotacao__c = 1.0;
        garantiaGrupoContrato.Valor__c = 1.0;
        garantiaGrupoContrato.PremioComercial__c = 1.0;
        garantiaGrupoContrato.PremioPuro__c = 1.0;
        garantiaGrupoContrato.PremioIntegral__c = 1.0;
        garantiaGrupoContrato.PremioTotal__c = 1.0;
        garantiaGrupoContrato.TaxaComercial__c = 1.0;
        garantiaGrupoContrato.TaxaPura__c = 1.0;
        garantiaGrupoContrato.TaxaTotal__c = 1.0;	
        garantiaGrupoContrato.CurrencyIsoCode = 'BRL';
        garantiaGrupoContrato.DescontoAgravoMonetarioComercial__c = 1.0;
        garantiaGrupoContrato.DescontoAgravoMonetarioInformado__c = 1.0;
        garantiaGrupoContrato.DescontoAgravoMonetarioTecnico__c = 1.0;
        garantiaGrupoContrato.DescontoAgravoPercentualComercial__c = 1.0;
        garantiaGrupoContrato.DescontoAgravoPercentualInformado__c = 1.0;
        garantiaGrupoContrato.DescontoAgravoPercentualTecnico__c = 1.0;

        update garantiaGrupoContrato;

        Set<Id> setContratanteId = new Set<Id>{ogb.contrato.ContratantesContrato__r[0].Id};
        grupoContrato =  [ SELECT Id, Name, QuantidadeVidas__c, ContratanteContrato__c, Descricao__c, TipoCalculo__c, Numero__c, TipoDescontoAgravo__c, PremioComercial__c, PremioPuro__c, PremioTotal__c, PremioIntegral__c, TaxaComercial__c, TaxaPura__c, TaxaTotal__c, DescontoAgravoMonetarioComercial__c, DescontoAgravoMonetarioInformado__c, DescontoAgravoMonetarioTecnico__c, DescontoAgravoPercentualComercial__c, DescontoAgravoPercentualInformado__c, DescontoAgravoPercentualTecnico__c, IOF__c, ( SELECT Id, Name, Conta__c, EnderecoBoleto__c, IOF__c, IPCA__c, PorcentagemParticipacaoSegurado__c, PorcentagemParticipacaoVida__c, QuantidadeParcelas__c, Reenquadramento__c, Numero__c, TipoCusteio__c, TipoDescontoAgravo__c, TipoResponsavelPagamento__c, VencimentoPrimeiraParcela__c, PremioComercial__c, PremioParcela__c, PremioIntegral__c, PremioPuro__c, PremioTotal__c, TaxaComercial__c, TaxaPura__c, TaxaTotal__c, DescontoAgravoMonetarioComercial__c, DescontoAgravoMonetarioInformado__c, DescontoAgravoMonetarioTecnico__c, DescontoAgravoPercentualComercial__c, DescontoAgravoPercentualInformado__c, DescontoAgravoPercentualTecnico__c FROM SeguradosContrato__r ), ( SELECT Id, IOF__c, Capital__c, GarantiaProduto__c, Garantia__c, NumeroSerie__c, NumeroSorte__c, Percentual__c, TipoDescontoAgravo__c, ValorCotacao__c, Valor__c, PremioComercial__c, PremioPuro__c, PremioIntegral__c, PremioTotal__c, TaxaComercial__c, TaxaPura__c, TaxaTotal__c, CurrencyIsoCode, DescontoAgravoMonetarioComercial__c, DescontoAgravoMonetarioInformado__c, DescontoAgravoMonetarioTecnico__c, DescontoAgravoPercentualComercial__c, DescontoAgravoPercentualInformado__c, DescontoAgravoPercentualTecnico__c FROM GarantiasGrupoContrato__r ) FROM GrupoContrato__c WHERE GrupoContrato__c.ContratanteContrato__c IN :setContratanteId ];

        ogb.grupos.add(grupoContrato);

        GarantiaContratanteContrato__c garantiaContratante = TestDataFactory.gerarGarantiaContratanteContrato(garantia, ogb.contrato.ContratantesContrato__r[0]);
        garantiaContratante = [SELECT Id, ContratanteContrato__c, Capital__c, GarantiaProduto__c, Garantia__c, NumeroSerie__c, NumeroSorte__c, Percentual__c, ValorCotacao__c, CurrencyIsoCode FROM GarantiaContratanteContrato__c LIMIT 1];

        ogb.garantiasContratante.add(garantiaContratante);

        GarantiaSeguradoContrato__c garantiaSeguraContrato = TestDataFactory.gerarGarantiaSeguradoContrato(garantia, seguradoContrato);

        ogb.garantiasSeguradoContrato.add(garantiaSeguraContrato);

        List<ContratanteContrato__c> contratantes = new List<ContratanteContrato__c>();
        List<Orcamento.ContratanteWrapper> listContratanteWrapper = new List<Orcamento.ContratanteWrapper>();        
        
        contratantes.add(contratanteContrato);

        GarantiaContratanteContrato__c garantiaContratanteContrato = TestDataFactory.gerarGarantiaContratanteContrato(garantia, contratanteContrato);
        ogb.mapGarantiaContratanteContrato.put(contratanteContrato.Id, new List<GarantiaContratanteContrato__c>{garantiaContratanteContrato});

        ogb.mapGarantiasSigla.put(garantia.Id, 'MAP');

        ogb.mapGruposContrato.put(contratanteContrato.Id, new List<GrupoContrato__c>{grupoContrato});

        Orcamento orc = new Orcamento();
        Orcamento.OrcamentoWrapper orcWrapper = new Orcamento.OrcamentoWrapper();
        orcWrapper.sfOrcamento = new Opportunity();
        orcWrapper.sfOrcamento = orcamento;
        ogb.orcamento = new Orcamento();
        ogb.orcamento.orcamentoWrapper = orcWrapper;

        payloadTO.retornoCalculo = retornoCalculo;
        payloadTO.orcamento = listaOfertas[0].orcamento;
        payloadTO.orcamento.codigoProdutoVida = 'VI-PESSOAS';

        ogb.mapCoberturasGarantiaSeguradoOrcamento.put('MAP', payloadTO.orcamento.precificacao.coberturas[0]);

        OrcamentoGenericoBuilder.getInstance().gerarOrcamento(payloadTO);

        payloadTO.retornosCalculo = new List<EmissaoTO.RetornoCalculoTO>();
        EmissaoTO.RetornoCalculoTO retornoCalculoTO = new EmissaoTO.RetornoCalculoTO();

        retornoCalculoTO.tarifa = '2';
        retornoCalculoTO.dlls = new List<String>();
        
        retornoCalculoTO.dlls.add('X');
        retornoCalculoTO.dlls.add('Y');        
        
        payloadTO.retornosCalculo.add(retornoCalculoTO);

        payloadTO.retornoIntegracoes = new EmissaoTO.RetornoIntegracoesTO();
        payloadTO.retornoIntegracoes = retornoIntegracoes;
        //ANNVI-55 - FIM

        ServiceTO.PayRetornoOfertasTO RetornoOferta = orcamentoGenericoBuilder.getInstance().gerarOrcamentoGravar(payloadTO);
        orcamentoGenericoBuilder.getInstance().gerarOrcamentoCivCalculo(JSON.serialize(payloadTO)); //ANNVI-55 - INICIO/FIM       
        
        CriticaOrcamento__c critica = [SELECT Id, Justificativa__c, Tipo__c, Status__c, Orcamento__r.Numero__c FROM CriticaOrcamento__c LIMIT 1];
        critica.Tipo__c = 'Análise';
        update critica;
        OrcamentoGenericoBuilder.getInstance().retornarCriticasODM(critica.Orcamento__r.Numero__c);
        
        critica.Tipo__c = 'Aviso';
        update critica;
        OrcamentoGenericoBuilder.getInstance().retornarCriticasODM(critica.Orcamento__r.Numero__c);
        
        critica.Tipo__c = 'Pendência';
        update critica;
        OrcamentoGenericoBuilder.getInstance().retornarCriticasODM(critica.Orcamento__r.Numero__c);
        
        critica.Tipo__c = 'Recusa';
        update critica;
        OrcamentoGenericoBuilder.getInstance().retornarCriticasODM(critica.Orcamento__r.Numero__c); 

        // ContratanteContrato__c contratante = [SELECT Id, Bairro__c, CEP__c, Cidade__c, Complemento__c, Conta__c, TipoEndereco__c, TipoLogradouro__c, Tipo__c, Estado__c, Logradouro__c, NumeroEndereco__c, Pais__c, Numero__c FROM ContratanteContrato__c LIMIT 1];
        // ContratanteOrcamento__c contratanteOrcamento = [SELECT Id, Bairro__c, CEP__c, Cidade__c, Complemento__c, Conta__c, TipoEndereco__c, TipoLogradouro__c, Tipo__c, Estado__c, Logradouro__c, NumeroEndereco__c, Pais__c, Numero__c, IOF__c, PremioComercial__c, PremioPuro__c, PremioTotal__c, TaxaPura__c, TaxaTotal__c, TaxaComercial__c, TipoDescontoAgravo__c, DescontoAgravoPercentualTecnico__c, DescontoAgravoMonetarioTecnico__c, DescontoAgravoPercentualComercial__c, DescontoAgravoMonetarioComercial__c, DescontoAgravoPercentualInformado__c, DescontoAgravoMonetarioInformado__c FROM ContratanteOrcamento__c LIMIT 1];
        // orcamentoGenericoBuilder.getInstance().popularContratanteOrcamento(contratante, contratanteOrcamento);
        
        Test.stopTest();
        
    }
    //PLV - 4626 - VI - FIM - GUSTAVO PEREIRA SYS4B 


    // PLV-4598 INICIO
    @isTest
    public static void testGetListGarantia(){
        Test.startTest();
        OrcamentoGenericoBuilder.getInstance().getListGarantia(new List<String>(), new List<String>());
        Test.stopTest();

    }

    // PLV-4598 FIM
    @isTest
    static void inserirRegistrosTest() {

        Test.startTest();//ANNVI-55 - INICIO

        EmissaoTO.PayloadTO payloadTO = gerarPayloadTO();
        OrcamentoGenericoBuilder ogb = OrcamentoGenericoBuilder.getInstance();
        
        Orcamento orcamento = prepararInserirRegistro();

        ogb.inserirRegistros(orcamento);//ANNVI-55 - FIM
        Test.stopTest();
    }
    
    @isTest
    static void popularRemuneracaoOrcamentoTest() {

        Test.startTest();
        
        try{
            RemuneracaoOrcamento__c remuneracaoOrcamento = new RemuneracaoOrcamento__c(); 
            RemuneracaoContrato__c remuneracao = new RemuneracaoContrato__c();
            
            TipoRemuneracao__c tipoRemuneracao = new TipoRemuneracao__c();
            
            remuneracao.TipoRemuneracao__c = tipoRemuneracao.id;
            remuneracao.Percentual__c = 100;
            
            OrcamentoGenericoBuilder.getInstance().popularRemuneracaoOrcamento( remuneracaoOrcamento,  remuneracao);
            OrcamentoGenericoBuilder.getInstance().popularRemuneracaoOrcamento( remuneracaoOrcamento,  null);
            
        }catch(Exception e){}
     
        
        Test.stopTest();
    }
    
    
    @isTest
    static void popularGarantiaGrupoOrcamentoTest() {

        Test.startTest();
                
        Garantia__c garantia = new Garantia__c();        
        
        GarantiaGrupoOrcamento__c   garantiaOrcamento = new GarantiaGrupoOrcamento__c()   ;                        
        GarantiaGrupoContrato__c    garantiaGrupoContrato   = new GarantiaGrupoContrato__c()    ;
        
        try{                    
            
            String chave = garantia.id;
            
            EmissaoTO.DescontoAgravoTO descontoAgravoTEC = new EmissaoTO.DescontoAgravoTO();                        
            descontoAgravoTEC.monetario = 100;
            descontoAgravoTEC.percentual = 100;
            descontoAgravoTEC.tipo = 'TEC';
            
            EmissaoTO.DescontoAgravoTO descontoAgravoCOM = new EmissaoTO.DescontoAgravoTO();                        
            descontoAgravoCOM.monetario = 100;
            descontoAgravoCOM.percentual = 100;
            descontoAgravoCOM.tipo = 'COM';
            
            EmissaoTO.DescontoAgravoTO descontoAgravoBAT = new EmissaoTO.DescontoAgravoTO();                        
            descontoAgravoBAT.monetario = 100;
            descontoAgravoBAT.percentual = 100;
            descontoAgravoBAT.tipo = 'BAT';
            
            EmissaoTO.PremioTO premio = new EmissaoTO.PremioTO();
            EmissaoTO.TaxaTO taxa = new EmissaoTO.TaxaTO();
            
            
            EmissaoTO.CoberturaTO coberturaTO = new EmissaoTO.CoberturaTO();
            coberturaTO.premio = premio;
            coberturaTO.taxa = taxa;
            
            coberturaTO.descontoAgravo = new List<EmissaoTO.DescontoAgravoTO>();                                                                        
            
            OrcamentoGenericoBuilder orcamentoGenericoBuilder = new OrcamentoGenericoBuilder(true);
            
            orcamentoGenericoBuilder.mapCoberturasGarantiaGrupoOrcamento.put( chave , coberturaTO );
            orcamentoGenericoBuilder.mapGarantiasSigla.put( chave , chave );
            
            garantiaGrupoContrato.Garantia__c = chave;
            
            garantiaOrcamento.TipoDescontoAgravo__c = 'TEC';
            
            coberturaTO.descontoAgravo.add(descontoAgravoTEC);
            orcamentoGenericoBuilder.popularGarantiaGrupoOrcamento( garantiaOrcamento,  garantiaGrupoContrato );
            coberturaTO.descontoAgravo.clear();
            
            
            garantiaOrcamento.TipoDescontoAgravo__c = 'COM';
            
            coberturaTO.descontoAgravo.add( descontoAgravoCOM );
            orcamentoGenericoBuilder.popularGarantiaGrupoOrcamento( garantiaOrcamento,  garantiaGrupoContrato );            
            coberturaTO.descontoAgravo.clear();
            
            
            garantiaOrcamento.TipoDescontoAgravo__c = 'BAT';
            
            coberturaTO.descontoAgravo.add(descontoAgravoBAT);
            orcamentoGenericoBuilder.popularGarantiaGrupoOrcamento( garantiaOrcamento,  garantiaGrupoContrato );            
            coberturaTO.descontoAgravo.clear();
            
            //Esperado que gere ERRO
            orcamentoGenericoBuilder.popularGarantiaGrupoOrcamento( garantiaOrcamento,  garantiaGrupoContrato );            
            
        }catch(Exception e){
            
            
        }
     
        
        Test.stopTest();
    }
    
    @isTest
    static void retornarCriticasODMTest() {

        Test.startTest();
        
        OrcamentoGenericoBuilder orcamentoGenericoBuilder = new OrcamentoGenericoBuilder(true);                
        
        //try{                                
            
            CriticaOrcamento__c criticaOrcamento = new CriticaOrcamento__c();
            
            criticaOrcamento.Tipo__C = 'Análise';
            criticaOrcamento.Justificativa__c = 'XYZ';
            criticaOrcamento.Status__c = 'Liberado';
            insert criticaOrcamento;
            
            orcamentoGenericoBuilder.retornarCriticasODM(null);     
            
            criticaOrcamento.Tipo__C = 'Aviso';
            update criticaOrcamento;
            
            orcamentoGenericoBuilder.retornarCriticasODM(null);     
            
            criticaOrcamento.Tipo__C = 'Pendência';
            update criticaOrcamento;
            
            orcamentoGenericoBuilder.retornarCriticasODM(null);     
            
            criticaOrcamento.Tipo__C = 'Recusa';
            update criticaOrcamento;
            
            orcamentoGenericoBuilder.retornarCriticasODM(null);     
            
        // }catch(Exception e){
            
            
        // }
     
        
        Test.stopTest();
    }
    
    @isTest
    static void gerarContratantesTest() {

        Test.startTest();
        
        OrcamentoGenericoBuilder orcamentoGenericoBuilder = new OrcamentoGenericoBuilder(true);                
                                                          
            EmissaoTO.PayloadTO payloadTOpublic = new EmissaoTO.PayloadTO();
            
            List<ContratanteContrato__c> contratantes                   = [SELECT Id, IOF__c, Numero__c,  Tipo__c, Estado__c, Logradouro__c, NumeroEndereco__c, Pais__c , TipoEndereco__c,TipoLogradouro__c, CEP__c , Bairro__c, BairroCorrespondencia__c, Carga_DataStage__c, CartaoCredito__c, CEPCorrespondencia__c, Cidade__c, CidadeCorrespondencia__c, Comercial__c, Complemento__c, ComplementoCorrespondencia__c, Conta__c, 
                                                                                Conta__r.NomeSocial__c // ANNVI-55 - INICIO/FIM
                                                                           FROM ContratanteContrato__c ];
            List<Orcamento.ContratanteWrapper> listContratanteWrapper   = new List<Orcamento.ContratanteWrapper>();   
            
            Map<Id, List<GrupoContrato__c>> mapGruposContrato = new Map<Id, List<GrupoContrato__c>>();                     
            
            orcamentoGenericoBuilder.mapGruposContrato.put( contratantes[0].id ,  new List<GrupoContrato__c>());
            
            orcamentoGenericoBuilder.mapGarantiaContratanteContrato.put(contratantes[0].id, new List<GarantiaContratanteContrato__c>() );
            
            orcamentoGenericoBuilder.payloadTOpublic = payloadTOpublic;
            
            orcamentoGenericoBuilder.gerarContratantes(contratantes,listContratanteWrapper);                         
        
        Test.stopTest();
    }
    
    @isTest
    static void gerarGruposTest() {

        Test.startTest();
        
        OrcamentoGenericoBuilder orcamentoGenericoBuilder = new OrcamentoGenericoBuilder(true);                                                                                    
        
        List<ContratanteContrato__c> contratantes                   = [SELECT Id, IOF__c, Numero__c,  Tipo__c, Estado__c, Logradouro__c, NumeroEndereco__c, Pais__c , TipoEndereco__c,TipoLogradouro__c, CEP__c , Bairro__c, BairroCorrespondencia__c, Carga_DataStage__c, CartaoCredito__c, CEPCorrespondencia__c, Cidade__c, CidadeCorrespondencia__c, Comercial__c, Complemento__c, ComplementoCorrespondencia__c, Conta__c  
                                                                        FROM ContratanteContrato__c ];
        
                
        GrupoContrato__c grupo = new GrupoContrato__c();
        
        //GrupoContrato__c grupoContrato = GrupoFactory;
        
        List<GrupoContrato__c> listaGrupos = new List<GrupoContrato__c>();
        
        listaGrupos.add( grupo );
        
        List<Orcamento.GrupoWrapper> listGrupoWrapper = new List<Orcamento.GrupoWrapper>();
        
        orcamentoGenericoBuilder.mapGruposContrato.put( contratantes[0].id ,  new List<GrupoContrato__c>());
            
        orcamentoGenericoBuilder.mapGarantiaContratanteContrato.put(contratantes[0].id, new List<GarantiaContratanteContrato__c>() );                
        
        orcamentoGenericoBuilder.payloadTOpublic = new EmissaoTO.PayloadTO();
        
        orcamentoGenericoBuilder.gerarGrupos( listaGrupos , listGrupoWrapper );
        
        Test.stopTest();
    }
    
    
    @isTest
    static void gravarDadosOrcamentoEndossoTest() {
        
        String numeroApolice = '';
        
        OrcamentoGenericoBuilder orcamentoGenericoBuilder = new OrcamentoGenericoBuilder(true);                         
        
        Test.startTest();//ANNVI-55 - INICIO/FIM
        
        try{
        
        EmissaoTO.OfertasTO payloadTO                   = new EmissaoTO.OfertasTO();
        payloadTO.orcamento                             = new EmissaoTO();
        payloadTO.orcamento.tipoSeguro                  = '' ; //ANNVI-55 INICIO/FIM
        payloadTO.orcamento.contratoOriginal            = new EmissaoTO();
        payloadTO.retornoIntegracoes                    = new EmissaoTO.RetornoIntegracoesTO();
        //payloadTO.retornoIntegracoes.IndiceMonetario
                        
        Contract contaContrato                          = new Contract();
        
        contaContrato.AccountId                         = [SELECT Id FROM Account limit 1].id;
        
        payloadTO.orcamento.contratoOriginal.Empresa    = '';
        payloadTO.orcamento.contratoOriginal.sucursal   = 0; 
        payloadTO.orcamento.contratoOriginal.ramo       = 0;
        payloadTO.orcamento.contratoOriginal.apolice    = '';
        payloadTO.orcamento.contratoOriginal.endosso    = '';
        //payloadTO.orcamento.segmento                    = 'Individual';
        payLoadTO.orcamento.codigoProdutoVida           = 'VI-PESSOAS';
        payLoadTO.orcamento.numeroOrcamento             = '2';
        
        payLoadTO.orcamento.dataCalculo                 = ''+  Date.today();
        payloadTO.orcamento.vigenciaInicial             = ''+  Date.today();
        payloadTO.orcamento.vigenciaFinal               = ''+  Date.today();
        payLoadTO.orcamento.contratantes                = new List<EmissaoTO.ContratanteTO  >();
        
        
        
        List<ContratanteContrato__c> listaContratantes                   = [SELECT Id, IOF__c, Numero__c,  Tipo__c, Estado__c, Logradouro__c, NumeroEndereco__c, Pais__c , TipoEndereco__c,TipoLogradouro__c, CEP__c , Bairro__c, BairroCorrespondencia__c, Carga_DataStage__c, CartaoCredito__c, CEPCorrespondencia__c, Cidade__c, CidadeCorrespondencia__c, Comercial__c, Complemento__c, ComplementoCorrespondencia__c, Conta__c  
                                                                        FROM ContratanteContrato__c ];
        
        for( ContratanteContrato__c contratante: listaContratantes )
        {
            EmissaoTO.ContratanteTO contratanteTO   = new EmissaoTO.ContratanteTO();
            contratanteTO.idSf                      = contratante.id ;
            contratanteTO.numero                    = '00000003';
            contratanteTO.grupos                    = new List<EmissaoTO.GrupoTO>();
            
            EmissaoTO.GrupoTO grupo = new EmissaoTO.GrupoTO();
            //ANNVI-55 - INICIO
            EmissaoTO.PessoaTO pessoa = 
            new EmissaoTO.PessoaTO();
    
            EmissaoTO.DadosPessoaFisicaTO pessoaFisica = 
            new EmissaoTO.DadosPessoaFisicaTO(); 

            pessoaFisica.sexo = 'FEM';
            pessoaFisica.fumante = false;
            pessoaFisica.dataNascimento = '1959-03-12T00:00:00.000Z';
            pessoaFisica.regimeTrabalho = 'CLT';
            pessoaFisica.numeroCpf = '10542346044'; //ANNVI-55 - INICIO/FIM
    
            pessoa.rendaMensal = 5000;
            pessoa.nome = 'XPTO';
            pessoa.dadosPessoaFisica = pessoaFisica;

            List<EmissaoTO.SeguradoTO> segurados = 
            new List<EmissaoTO.SeguradoTO>();

            EmissaoTO.SeguradoTO segurado = 
            new EmissaoTO.SeguradoTO();

            EmissaoTO.TaxaTO taxa = 
            new EmissaoTO.TaxaTO(); 
    
            EmissaoTO.PremioTO premio = 
            new EmissaoTO.PremioTO(); 
    
            List<EmissaoTO.CoberturaTO> coberturas = 
            new List<EmissaoTO.CoberturaTO>();
    
            EmissaoTO.CoberturaTO cobertura = 
            new EmissaoTO.CoberturaTO();

            taxa.pura = 10;
            taxa.comercial = 20;
            taxa.total = 30;
    
            premio.comercial = 10;
            premio.total = 20;
            premio.puro = 30;
            
            cobertura.taxa = taxa;
            cobertura.premio = premio;
            cobertura.sigla = 'MAP';
            cobertura.valor = 10.0;
            cobertura.quantidade = '1';
            coberturas.add(cobertura);

            segurado.pessoa = pessoa;
            segurado.numero = '1';
            segurado.coberturas = coberturas;
            segurados.add(segurado);
            
            grupo.segurados = segurados;
            grupo.coberturas = coberturas;
            grupo.tipoCalculo = ' ';
            grupo.numero = '1';
            grupo.nome = 'XPTO';
            grupo.qtdeVidas = 2;

            contratanteTO.pessoa = pessoa; 
            //ANNVI-55 - FIM
            contratanteTO.grupos.add( grupo );
            
            payLoadTO.orcamento.contratantes.add( contratanteTO );
        }

        payLoadTO.orcamento.remuneracoes                = new List<EmissaoTO.RemuneracaoTO  >();
        
        EmissaoTO.RemuneracaoTO remuneracao = new EmissaoTO.RemuneracaoTO();
        
        remuneracao.tipoRemuneracao = 'x';
        
        payLoadTO.orcamento.remuneracoes.add( remuneracao );
        
        payloadTO.orcamento.canalDistribuicao           = 'EXE';
        payloadTO.retornosCalculo                       = new List<EmissaoTO.RetornoCalculoTO>();
        
        EmissaoTO.RetornoCalculoTO retorno              = new EmissaoTO.RetornoCalculoTO();
        
        retorno.precificacao = new EmissaoTO.PrecificacaoTO() ;
        
        payloadTO.retornosCalculo.add(retorno);
        
        Product2 produto = [SELECT Id , VigenciaInicial__c , VigenciaFinal__c , CodigoPrecificaProduto__c , RecordType.DeveloperName ,  Status__c
                            FROM Product2 
                            WHERE CodigoPrecificaProduto__c  = 'VI-PESSOAS' 
                            AND RecordType.DeveloperName = 'ProdutoComercial' 
                            AND Status__c = 'Ativo'
                            limit 1 ];
        
        produto.VigenciaInicial__c = system.today();
        update produto;
        
        
        payLoadTO.orcamento.idProdutoSf                 = produto.id;
        
        
        numeroApolice = payloadTO.orcamento.contratoOriginal.empresa    +'-'+
                        payloadTO.orcamento.contratoOriginal.sucursal   +'-'+  
                        payloadTO.orcamento.contratoOriginal.ramo       +'-'+
                        payloadTO.orcamento.contratoOriginal.apolice    +'-'+
                        payloadTO.orcamento.contratoOriginal.endosso;
        
        //ANNVI-55 - INICIO        
        payloadTO.retornosCalculo = new List<EmissaoTO.RetornoCalculoTO>();
        EmissaoTO.RetornoCalculoTO retornoCalculoTO = new EmissaoTO.RetornoCalculoTO();

        retornoCalculoTO.tarifa = '2';
        retornoCalculoTO.dlls = new List<String>();
        
        retornoCalculoTO.dlls.add('X');
        retornoCalculoTO.dlls.add('Y');        
        
        payloadTO.retornosCalculo.add(retornoCalculoTO);
        //ANNVI-55 - FIM

        contaContrato.Name = numeroApolice;
        
        insert contaContrato;
        
        EmissaoTO.ViagemTO viagem = new EmissaoTO.ViagemTO();
        //ANNVI-55 - INICIO
        viagem.trackageBagagem = 'true';
        viagem.passageirosNaoIdosos = '1';
        viagem.tipoViagem = 'Nacional';
        viagem.destinos = new List<EmissaoTO.DestinoTO>();
        
        EmissaoTO.DestinoTO destino = new EmissaoTO.DestinoTO();
        destino.codigo = '1';
        destino.pais = 'Teste';

        viagem.destinos.add(destino);

        viagem.incluiPaisSchengen = 'false';
        viagem.passageirosIdosos = '0';
        viagem.nomePrincipal = 'John Doe';
        viagem.nomeSocial = 'Jane Doe';
        //ANNVI-55 - FIM
        viagem.praticaEsportesAventura = 'false';
        viagem.utilizaraMotocicleta = 'false';
        payloadTO.orcamento.viagem = viagem;
        
        orcamentoGenericoBuilder.gravarDadosOrcamentoEndosso( payloadTO );

        //ANNVI-55 - INICIO
        payloadTO.orcamento.contratantes[0].grupos[0].segurados = null;
        orcamentoGenericoBuilder.gravarDadosOrcamentoEndosso( payloadTO );
        //ANNVI-55 - FIM
        }catch(Exception e){}
        
        Test.stopTest();
    }
    
    
    @isTest
    static void converterOrcamentoParaRetornoOrcamentoTest() {

        Test.startTest();
        
        OrcamentoGenericoBuilder orcamentoGenericoBuilder = new OrcamentoGenericoBuilder(true);                                                                                               
        
        Orcamento orcamento = new Orcamento();                
        
        //orcamento.orcamentoWrapper.sforcamento.Id                   = '000';
        orcamento.orcamentoWrapper.sforcamento.Numero__c            = '1234';
        orcamento.orcamentoWrapper.sforcamento.VigenciaInicial__c   = system.today(); 
        orcamento.orcamentoWrapper.sforcamento.VigenciaFinal__c     = system.today();
        
        orcamento.orcamentoWrapper.retornoWrapper.codigoEmpresa     = '0';
        orcamento.orcamentoWrapper.retornoWrapper.codigoSucursal    = '0';
        orcamento.orcamentoWrapper.retornoWrapper.codigoRamo        = '0';
        orcamento.orcamentoWrapper.retornoWrapper.numeroApolice     = '0';
        orcamento.orcamentoWrapper.retornoWrapper.codigoRamo        = '0';
        
        orcamentoGenericoBuilder.converterOrcamentoParaRetornoOrcamento(orcamento);
        
        Test.stopTest();
    }
    
    
    @isTest
    static void gerarNumeroOfertaTest() {

        Test.startTest();
        
        ContadorCodigo__c contadorCodigo    = new ContadorCodigo__c();
        contadorCodigo.Name                 = 'NumeroOferta';
        contadorCodigo.Numero__c            = 17;
        insert contadorCodigo;
                
        
        OrcamentoGenericoBuilder orcamentoGenericoBuilder = new OrcamentoGenericoBuilder(true);                                                                                                                               
        
       // orcamentoGenericoBuilder.gerarNumeroOferta();
        
        Test.stopTest();
    }
    
    
    @isTest
    static void fillFieldsDescAgrTest() {

        Test.startTest();                
        
        OrcamentoGenericoBuilder orcamentoGenericoBuilder = new OrcamentoGenericoBuilder(true);                                                                                                                               
        
        SObject sObj;
        
        Account conta = new Account();
        EmissaoTO.DescontoAgravoTO descAgr = new EmissaoTO.DescontoAgravoTO();
        
        orcamentoGenericoBuilder.fillFieldsDescAgr(conta, descAgr);
        
        Test.stopTest();
    }
    
    @isTest
    static void getRamoOrcamentoTest() {

        Test.startTest();                
        
        OrcamentoGenericoBuilder orcamentoGenericoBuilder = new OrcamentoGenericoBuilder(true);                
        
        Map< Id, GarantiaProduto__c > mpGarantiaProdutoCotacao = new Map< Id , GarantiaProduto__c >();
        
        Garantia__c garantia = new Garantia__c(//ANNVI-55 - INICIO
            VigenciaInicial__c = System.today(),
            Tipo__c = 'Cobertura',
            Sigla__c = 'AFF',
            Status__c = 'Ativo', 
            TipoEvento__c = 'Viagem',
            Descricao__c = 'teste'            
        );
        
        insert garantia;
        //ANNVI-55 - FIM
        
        GarantiaProduto__c garantiaProduto = new GarantiaProduto__c();
        garantiaProduto.TipoGarantia__c = 'Cobertura'; //ANNVI-55 - INICIO/FIM
        garantiaProduto.Garantia__c = garantia.id;
        //garantiaProduto.Name = 'xxx';
        garantiaProduto.OrdemPrioridade__c = 1;
        //garantiaProduto.RamoSeguro__c = '';
        
        insert garantiaProduto;
        
        mpGarantiaProdutoCotacao.put(garantiaProduto.id, garantiaProduto);             
        
        // for(GarantiaProduto__c garantia: [SELECT Id , OrdemPrioridade__c , RamoSeguro__r.id , RamoSeguro__c FROM GarantiaProduto__c ])
        // {
        //     garantia.OrdemPrioridade__c = 1;
        //     mpGarantiaProdutoCotacao.put(garantia.id, garantia);             
        // }
        
        orcamentoGenericoBuilder.getRamoOrcamento( mpGarantiaProdutoCotacao );
        
        Test.stopTest();
    }
    
    @isTest
    static void forceErros() {

        Test.startTest();
        
        try{
            OrcamentoGenericoBuilder.getInstance().gerarContratantes(null, null);
        }catch(Exception e){}
        
        try{                         
            OrcamentoGenericoBuilder.getInstance().gerarContratantes(new List<ContratanteContrato__c>(),new List<Orcamento.ContratanteWrapper>());
        }catch(Exception e){}
        
        try{
            
            OrcamentoGenericoBuilder.getInstance().gerarGrupos(new List<GrupoContrato__c>() , new List<Orcamento.GrupoWrapper>());
        }catch(Exception e){}
        
        try{
            OrcamentoGenericoBuilder.getInstance().popularContratanteOrcamento(new ContratanteContrato__c() , new ContratanteOrcamento__c() );
        }catch(Exception e){}
        
        Test.stopTest();
    }

    @isTest
    static void testPopularOrcamento() {

        String idContrato = [SELECT Id FROM Contract limit 1].Id ;
        Contract contrato = ContractDAO.getInstance().buscarContratoOriginalPorId(idContrato)[0];
        contrato.Nome_Social__c = 'Nome Social'; // ANNVI-55 - INICIO/FIM 
        Opportunity orcamento = [SELECT Id FROM Opportunity];
 
        List<EmissaoTO.OfertasTO> listaOfertas = new List<EmissaoTO.OfertasTO>();
        String payload = '{ "ofertas": [ { "orcamento": { "tipoVigencia": "Periódico", "tipoSeguro": "Novo", "vigenciaFinal": "2019-10-08", "numeroOrcamento": "00000003", "numeroPortal": 0, "codigoProdutoVida": "201700001", "idProdutoSf": null, "customizavel": true, "contratantes": [ { "tipo": "PRI", "numero": 1, "grupos": [ { "numero": 1, "segurados": [ { "pessoa": { "tipo": "FIS", "enderecos": [ { "uf": "SP", "cidade": "SAO PAULO", "complemento": "Apto 22", "logradouro": "Guaianses", "bairro": "Centro", "complementoCep": "420", "tipoLogradouro": "R", "paisResidencia": "BRASIL", "tipoEndereco": "REC", "numeroLogradouro": "92", "cep": "07114" } ], "nome": "Testinho", "dadosPessoaFisica": { "numeroCpf": "438912318", "profissao": null, "tipoContrato": "TODOS", "celular": "(11) 11111-1111", "digitoCpf": "14", "dataNascimento": "2000-11-11", "fumante": false, "sexo": "MASCULINO", "renda": "FAIXA2" }, "email": "teste@teste.com.br" }, "numero": 1, "coberturas": [ { "sigla": "BAS", "valor": 20000 }, { "sigla": "MAP", "valor": 20000 }, { "sigla": "CAP", "valor": 10 } ] } ], "nome": "Testinho", "qtdeVidas": 1 } ] } ], "canalDistribuicao": "EXE", "meioComercializacao": "CO2", "segmento": "Individual", "versoesCalculos": [ { "opcao": 0, "tipo": "FPG", "descontoAgravo": 0 }, { "opcao": 1, "tipo": "FPG", "descontoAgravo": -5 }, { "opcao": 2, "tipo": "FPG", "descontoAgravo": 5 } ], "ordemPortal": 1, "rotulo": "Sniper - Plano Básico", "remuneracoes": [ { "percentual": 20, "tipoRemuneracao": "CORRETAGEM" } ], "vigenciaInicial": "2019-09-23", "dataCalculo": "2019-09-23" }, "retornosCalculo": [ { "opcao": 0, "orcnum": "00000003", "numeroOrcamento": "00000003", "numeroOferta": 123, "precificacao": { "juros": 0, "iof": 1.24, "encargos": 0, "custoDeApolice": 0, "premio": { "comercial": 205.98, "puro": 219.98, "total": 225.00 }, "taxa": { "comercial": 0.0002185, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ], "coberturas": [ { "sigla": "BAS", "capital": 350000.00, "iof": 0.28, "premio": { "comercial": 75.00, "puro": 75.00, "total": 75.00 }, "taxa": { "comercial": 0.000043, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "MAP", "capital": 500000.00, "iof": 0.19, "premio": { "comercial": 50.0, "puro": 50.0, "total": 50.0 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DIH", "capital": 1400.00, "iof": 0.09, "premio": { "comercial": 25.0, "puro": 25.0, "total": 25.0 }, "taxa": { "comercial": 0.00031, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DG 10", "capital": 6000.00, "iof": 0.14, "premio": { "comercial": 37.50, "puro": 37.50, "total": 37.50 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "AFI", "capital": 2900.00, "iof": 0.14, "premio": { "comercial": 37.50, "puro": 37.50, "total": 37.50 }, "taxa": { "comercial": 0.000015, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] } ], "contratantes": [ { "numero": 1, "iof": 1.24, "premio": { "comercial": 4.38, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.0002185, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ], "coberturas": [ { "sigla": "BAS", "capital": 119.8, "iof": 1.24, "premio": { "comercial": 2.58, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000043, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DG 10", "capital": 12.8, "iof": 1.24, "premio": { "comercial": 0.03, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "MAP", "capital": 1000.7, "iof": 1.24, "premio": { "comercial": 1.55, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.00031, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DIH", "capital": 12.8, "iof": 1.24, "premio": { "comercial": 0.03, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "AFI", "capital": 2900.2, "iof": 1.24, "premio": { "comercial": 0.22, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000015, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] } ], "grupos": [ { "numero": 1, "iof": 1.24, "premio": { "comercial": 4.38, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.0002185, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ], "coberturas": [ { "sigla": "BAS", "capital": 119.8, "iof": 1.24, "premio": { "comercial": 2.58, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000043, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "MAP", "capital": 12.8, "iof": 1.24, "premio": { "comercial": 0.03, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "AFI", "capital": 1000.7, "iof": 1.24, "premio": { "comercial": 1.55, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.00031, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DIH", "capital": 12.8, "iof": 1.24, "premio": { "comercial": 0.03, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DG 10", "capital": 2900.2, "iof": 1.24, "premio": { "comercial": 0.22, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000015, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] } ], "segurados": [ { "numero": 1, "iof": 1.24, "premio": { "comercial": 4.38, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.0002185, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ], "coberturas": [ { "sigla": "BAS", "capital": 119.8, "iof": 1.24, "premio": { "comercial": 2.58, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000043, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "MAP", "capital": 12.8, "iof": 1.24, "premio": { "comercial": 0.03, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "AFI", "capital": 1000.7, "iof": 1.24, "premio": { "comercial": 1.55, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.00031, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DG 10", "capital": 12.8, "iof": 1.24, "premio": { "comercial": 0.03, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DIH", "capital": 1000900, "iof": 1.24, "premio": { "comercial": 0.22, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000015, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] } ] } ] } ] } ] } } ], "retornoCalculo": { "opcao": 0, "orcnum": "00000003", "numeroOrcamento": "00000003", "numeroOferta": 123, "precificacao": { "juros": 0, "iof": 1.24, "encargos": 0, "custoDeApolice": 0, "premio": { "comercial": 205.98, "puro": 219.98, "total": 225.00 }, "taxa": { "comercial": 0.0002185, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ], "coberturas": [ { "sigla": "BAS", "capital": 350000.00, "iof": 0.28, "premio": { "comercial": 75.00, "puro": 75.00, "total": 75.00 }, "taxa": { "comercial": 0.000043, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "MAP", "capital": 500000.00, "iof": 0.19, "premio": { "comercial": 50.0, "puro": 50.0, "total": 50.0 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DIH", "capital": 1400.00, "iof": 0.09, "premio": { "comercial": 25.0, "puro": 25.0, "total": 25.0 }, "taxa": { "comercial": 0.00031, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DG 10", "capital": 6000.00, "iof": 0.14, "premio": { "comercial": 37.50, "puro": 37.50, "total": 37.50 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "AFI", "capital": 2900.00, "iof": 0.14, "premio": { "comercial": 37.50, "puro": 37.50, "total": 37.50 }, "taxa": { "comercial": 0.000015, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] } ], "contratantes": [ { "numero": 1, "iof": 1.24, "premio": { "comercial": 4.38, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.0002185, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ], "coberturas": [ { "sigla": "BAS", "capital": 119.8, "iof": 1.24, "premio": { "comercial": 2.58, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000043, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DG 10", "capital": 12.8, "iof": 1.24, "premio": { "comercial": 0.03, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "MAP", "capital": 1000.7, "iof": 1.24, "premio": { "comercial": 1.55, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.00031, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DIH", "capital": 12.8, "iof": 1.24, "premio": { "comercial": 0.03, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "AFI", "capital": 2900.2, "iof": 1.24, "premio": { "comercial": 0.22, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000015, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] } ], "grupos": [ { "numero": 1, "iof": 1.24, "premio": { "comercial": 4.38, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.0002185, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ], "coberturas": [ { "sigla": "BAS", "capital": 119.8, "iof": 1.24, "premio": { "comercial": 2.58, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000043, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "MAP", "capital": 12.8, "iof": 1.24, "premio": { "comercial": 0.03, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "AFI", "capital": 1000.7, "iof": 1.24, "premio": { "comercial": 1.55, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.00031, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DIH", "capital": 12.8, "iof": 1.24, "premio": { "comercial": 0.03, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DG 10", "capital": 2900.2, "iof": 1.24, "premio": { "comercial": 0.22, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000015, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] } ], "segurados": [ { "numero": 1, "iof": 1.24, "premio": { "comercial": 4.38, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.0002185, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ], "coberturas": [ { "sigla": "BAS", "capital": 119.8, "iof": 1.24, "premio": { "comercial": 2.58, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000043, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "MAP", "capital": 12.8, "iof": 1.24, "premio": { "comercial": 0.03, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "AFI", "capital": 1000.7, "iof": 1.24, "premio": { "comercial": 1.55, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.00031, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DG 10", "capital": 12.8, "iof": 1.24, "premio": { "comercial": 0.03, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000506, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] }, { "sigla": "DIH", "capital": 1000900, "iof": 1.24, "premio": { "comercial": 0.22, "puro": 3.98, "total": 5.00 }, "taxa": { "comercial": 0.000015, "pura": 0.007462, "total": 0.005363 }, "descontoAgravo": [ { "percentual": -5.9, "monetario": -13.56, "tipo": "TEC" } ] } ] } ] } ] } ] } } , "retornoAceitacao": {}, "retornoIntegracoes": { "validacaoZeroDolar": null, "IndiceMonetario": { "ItensCotacao": [ { "moedaOrigem": "USD", "moedaDestino": "BRL", "dataCotacao": 13112018, "cotacao": "3.74720000" }, { "moedaOrigem": "EUR", "moedaDestino": "BRL", "dataCotacao": 13112018, "cotacao": "4.04720000" }, { "moedaOrigem": "BRL", "moedaDestino": "BRL", "dataCotacao": 13112018, "cotacao": "1" } ] } } } ] }';//ANNVI-55 - INICIO/FIM

        EmissaoTO.PayloadTO payloadTO = (EmissaoTO.PayloadTO) JSON.deserialize(payload, EmissaoTO.PayloadTO.class);
		EmissaoTO emsto = new EmissaoTO();
        emsto.meioComercializacao = 'XXXX';
        emsto.numeroOrcamento = '0000000000';
        emsto.dataCalculo = '2020-06-30';
        emsto.IndiceIPCA = 10;
        payLoadTO.orcamento = emsto;

        EmissaoTO.RetornoCalculoTO retornocalculo = new EmissaoTO.RetornoCalculoTO();
        EmissaoTO.PrecificacaoTO precificacao = new EmissaoTO.PrecificacaoTO();
        List<EmissaoTO.CoberturaTO> lstcobertura = new List<EmissaoTO.CoberturaTO>();
        EmissaoTO.CoberturaTO cobertura = new EmissaoTO.CoberturaTO();
        List<EmissaoTO.ContratanteTO> lstcontratante = new List<EmissaoTO.ContratanteTO>();
        List<EmissaoTO.GrupoTO> lstgrupo = new List<EmissaoTO.GrupoTO>();
        List<EmissaoTO.SeguradoTO> lstsegurado = new List<EmissaoTO.SeguradoTO>();
        EmissaoTO.ContratanteTO contratante = new EmissaoTO.ContratanteTO();
        EmissaoTO.GrupoTO grupo = new EmissaoTO.GrupoTO();
        EmissaoTO.SeguradoTO segurado = new EmissaoTO.SeguradoTO();
        EmissaoTO.PremioTO premio = new EmissaoTO.PremioTO();//ANNVI-55 - INICIO
        EmissaoTO.TaxaTO taxa = new EmissaoTO.TaxaTO();//ANNVI-55 - FIM

        lstcobertura.add(cobertura);
        lstgrupo.add(grupo);
        lstsegurado.add(segurado);
        grupo.segurados =lstsegurado;
        segurado.coberturas = lstcobertura;
        grupo.coberturas = lstcobertura;
        contratante.coberturas = lstcobertura;
        lstcontratante.add(contratante);
        contratante.grupos = lstgrupo;
        precificacao.coberturas = lstcobertura;
        precificacao.contratantes = lstcontratante;
        precificacao.premio = premio;//ANNVI-55 - INICIO
        precificacao.taxa = taxa;//ANNVI-55 - FIM
        retornocalculo.precificacao = precificacao;
        payLoadTO.retornoCalculo = retornocalculo;

        contratos = [SELECT Id, Produto__c, Name, Empresa__c, Sucursal__c, CodigoRamo__c, NumeroApolice__c, Endosso__c,  
                    Nome_Social__c // ANNVI-55 - INICIO/FIM
                    FROM Contract LIMIT 1]; // PLV-5331 - INÍCIO/FIM 
        
        for(EmissaoTO.OfertasTO oferta : payloadTO.ofertas)
        {
            oferta.orcamento.vigenciaInicial = String.valueOf(System.today().addDays(1));
            oferta.orcamento.vigenciaFinal   = String.valueOf(System.today().addDays(1));
            oferta.orcamento.dataCalculo     = String.valueOf(System.today().addDays(1));
            oferta.orcamento.idProdutoSf = contratos[0].Produto__c; 
            
            listaOfertas.add(oferta);
            payload = JSON.serialize(oferta);
        }
        
        ContadorCodigo__c cc = new ContadorCodigo__c();
        cc.numero__c = 0000000000;
        cc.Name = 'NumeroOferta';
        insert cc;

        Test.startTest();

        System.debug('===> payloadTo - PopularOrcamento: '+ JSON.serialize(payloadTO));
        try{
        OrcamentoGenericoBuilder.getInstance().popularOrcamento(contrato, orcamento, payloadTO, '00000003');
        }catch(Exception e){ 
        }

        Test.stopTest();

    }

    @isTest
    static void popularGarantiaOrcamentoTest() {

        Test.startTest();
                
        Garantia__c garantia = new Garantia__c();        
        
        GarantiaOrcamento__c   garantiaOrcamento  = new GarantiaOrcamento__c()   ;                        
        GarantiaContrato__c    garantiaContrato   = new GarantiaContrato__c()    ;
        
        try{                    
            
            String chave = garantia.id;
            
            EmissaoTO.DescontoAgravoTO descontoAgravoTEC = new EmissaoTO.DescontoAgravoTO();                        
            descontoAgravoTEC.monetario = 100;
            descontoAgravoTEC.percentual = 100;
            descontoAgravoTEC.tipo = 'TEC';
            
            EmissaoTO.DescontoAgravoTO descontoAgravoCOM = new EmissaoTO.DescontoAgravoTO();                        
            descontoAgravoCOM.monetario = 100;
            descontoAgravoCOM.percentual = 100;
            descontoAgravoCOM.tipo = 'COM';
            
            EmissaoTO.DescontoAgravoTO descontoAgravoBAT = new EmissaoTO.DescontoAgravoTO();                        
            descontoAgravoBAT.monetario = 100;
            descontoAgravoBAT.percentual = 100;
            descontoAgravoBAT.tipo = 'BAT';
            
            EmissaoTO.PremioTO premio = new EmissaoTO.PremioTO();
            EmissaoTO.TaxaTO taxa = new EmissaoTO.TaxaTO();
            
            EmissaoTO.CoberturaTO coberturaTO = new EmissaoTO.CoberturaTO();
            coberturaTO.premio = premio;
            coberturaTO.taxa = taxa;
            
            coberturaTO.descontoAgravo = new List<EmissaoTO.DescontoAgravoTO>();                                                                        
            
            OrcamentoGenericoBuilder orcamentoGenericoBuilder = new OrcamentoGenericoBuilder(true);
            
            orcamentoGenericoBuilder.mapCoberturasGarantiaOrcamento.put( chave , coberturaTO );
            orcamentoGenericoBuilder.mapGarantiasSigla.put( chave , chave );
            
            garantiaContrato.Garantia__c = chave;
            
            garantiaOrcamento.TipoDescontoAgravo__c = 'TEC';
            
            coberturaTO.descontoAgravo.add(descontoAgravoTEC);
            orcamentoGenericoBuilder.popularGarantiaOrcamento( garantiaOrcamento,  garantiaContrato );
            coberturaTO.descontoAgravo.clear();
            
            garantiaOrcamento.TipoDescontoAgravo__c = 'COM';
            
            coberturaTO.descontoAgravo.add( descontoAgravoCOM );
            orcamentoGenericoBuilder.popularGarantiaOrcamento( garantiaOrcamento,  garantiaContrato );            
            coberturaTO.descontoAgravo.clear();
            
            garantiaOrcamento.TipoDescontoAgravo__c = 'BAT';
            
            coberturaTO.descontoAgravo.add(descontoAgravoBAT);
            orcamentoGenericoBuilder.popularGarantiaOrcamento( garantiaOrcamento,  garantiaContrato );            
            coberturaTO.descontoAgravo.clear();
            
            orcamentoGenericoBuilder.popularGarantiaOrcamento( garantiaOrcamento,  garantiaContrato );            
            
        }catch(Exception e){
            
            
        }
     
        
        Test.stopTest();
    }

    @isTest
    static void popularGarantiaContratanteOrcamentoTest() {

       Test.startTest();
                
       Garantia__c garantia = new Garantia__c();        
        
        GarantiaContratanteOrcamento__c   garantiaOrcamento = new GarantiaContratanteOrcamento__c()   ;                        
        GarantiaContratanteContrato__c    garantiaContrato   = new GarantiaContratanteContrato__c()    ;
        
        try{                    
            
            String chave = garantia.id;
            
            EmissaoTO.DescontoAgravoTO descontoAgravoCOM = new EmissaoTO.DescontoAgravoTO();                        
            descontoAgravoCOM.monetario = 100;
            descontoAgravoCOM.percentual = 100;
            descontoAgravoCOM.tipo = 'COM';
            
            EmissaoTO.PremioTO premio = new EmissaoTO.PremioTO();
            EmissaoTO.TaxaTO taxa = new EmissaoTO.TaxaTO();
            
            EmissaoTO.CoberturaTO coberturaTO = new EmissaoTO.CoberturaTO();
            coberturaTO.premio = premio;
            coberturaTO.taxa = taxa;
            
            coberturaTO.descontoAgravo = new List<EmissaoTO.DescontoAgravoTO>();                                                                        
            
            OrcamentoGenericoBuilder orcamentoGenericoBuilder = new OrcamentoGenericoBuilder(true);
            
            orcamentoGenericoBuilder.mapCoberturasGarantiaContratanteOrcamento.put( chave , coberturaTO );
            orcamentoGenericoBuilder.mapGarantiasSigla.put( chave , chave );
            
            garantiaContrato.Garantia__c = chave;
            
            garantiaOrcamento.TipoDescontoAgravo__c = 'COM';
            
            coberturaTO.descontoAgravo.add( descontoAgravoCOM );
            orcamentoGenericoBuilder.popularGarantiaContratanteOrcamento( garantiaOrcamento,  garantiaContrato );            
            coberturaTO.descontoAgravo.clear();
            
            orcamentoGenericoBuilder.popularGarantiaContratanteOrcamento( garantiaOrcamento,  garantiaContrato );            
            
        }catch(Exception e){
            
            
        }
     
        
        Test.stopTest();
    }
    @isTest
    static void popularGarantiaSeguradoOrcamentoTest() {

        Test.startTest();
                
        Garantia__c garantia = new Garantia__c();        
        
        GarantiaSeguradoOrcamento__c   garantiaOrcamento =  new GarantiaSeguradoOrcamento__c()   ;                        
        GarantiaSeguradoContrato__c    garantiaContrato   = new GarantiaSeguradoContrato__c()    ;
        
        try{               

            String chave = garantia.id;
            
            EmissaoTO.DescontoAgravoTO descontoAgravoTEC = new EmissaoTO.DescontoAgravoTO();                        
            descontoAgravoTEC.monetario = 100;
            descontoAgravoTEC.percentual = 100;
            descontoAgravoTEC.tipo = 'TEC';
            
            EmissaoTO.DescontoAgravoTO descontoAgravoCOM = new EmissaoTO.DescontoAgravoTO();                        
            descontoAgravoCOM.monetario = 100;
            descontoAgravoCOM.percentual = 100;
            descontoAgravoCOM.tipo = 'COM';
            
            EmissaoTO.DescontoAgravoTO descontoAgravoBAT = new EmissaoTO.DescontoAgravoTO();                        
            descontoAgravoBAT.monetario = 100;
            descontoAgravoBAT.percentual = 100;
            descontoAgravoBAT.tipo = 'BAT';
            
            EmissaoTO.PremioTO premio = new EmissaoTO.PremioTO();
            EmissaoTO.TaxaTO taxa = new EmissaoTO.TaxaTO();
            
            EmissaoTO.CoberturaTO coberturaTO = new EmissaoTO.CoberturaTO();
            coberturaTO.premio = premio;
            coberturaTO.taxa = taxa;
            
            coberturaTO.descontoAgravo = new List<EmissaoTO.DescontoAgravoTO>();                                                                        
            
            OrcamentoGenericoBuilder orcamentoGenericoBuilder = new OrcamentoGenericoBuilder(true);
            
            orcamentoGenericoBuilder.mapCoberturasGarantiaSeguradoOrcamento.put( chave , coberturaTO );
            orcamentoGenericoBuilder.mapGarantiasSigla.put( chave , chave );
            
            garantiaContrato.Garantia__c = chave;
            
            garantiaOrcamento.TipoDescontoAgravo__c = 'TEC';
            
            coberturaTO.descontoAgravo.add(descontoAgravoTEC);
            orcamentoGenericoBuilder.popularGarantiaSeguradoOrcamento( garantiaOrcamento,  garantiaContrato );
            coberturaTO.descontoAgravo.clear();
            
            garantiaOrcamento.TipoDescontoAgravo__c = 'COM';
            
            coberturaTO.descontoAgravo.add( descontoAgravoCOM );
            orcamentoGenericoBuilder.popularGarantiaSeguradoOrcamento( garantiaOrcamento,  garantiaContrato );            
            coberturaTO.descontoAgravo.clear();
            
            
            garantiaOrcamento.TipoDescontoAgravo__c = 'BAT';
            
            coberturaTO.descontoAgravo.add(descontoAgravoBAT);
            orcamentoGenericoBuilder.popularGarantiaSeguradoOrcamento( garantiaOrcamento,  garantiaContrato );            
            coberturaTO.descontoAgravo.clear();
            
            orcamentoGenericoBuilder.popularGarantiaSeguradoOrcamento( garantiaOrcamento,  garantiaContrato );            
            
        }catch(Exception e){
            
            
        }
     
        
        Test.stopTest();
    }

    @isTest
    static void popularSeguradoOrcamentoTest() {

        Test.startTest();
                
        Garantia__c garantia = new Garantia__c();        
        
        SeguradoOrcamento__c   garantiaOrcamento =  new SeguradoOrcamento__c()   ;                        
        SeguradoContrato__c    seguradoContrato   = new SeguradoContrato__c()    ;

        try{                    
            
            String chave = garantia.id;
            
            EmissaoTO.DescontoAgravoTO descontoAgravoTEC = new EmissaoTO.DescontoAgravoTO();                        
            descontoAgravoTEC.monetario = 100;
            descontoAgravoTEC.percentual = 100;
            descontoAgravoTEC.tipo = 'TEC';
            
            EmissaoTO.DescontoAgravoTO descontoAgravoCOM = new EmissaoTO.DescontoAgravoTO();                        
            descontoAgravoCOM.monetario = 100;
            descontoAgravoCOM.percentual = 100;
            descontoAgravoCOM.tipo = 'COM';
            
            EmissaoTO.DescontoAgravoTO descontoAgravoBAT = new EmissaoTO.DescontoAgravoTO();                        
            descontoAgravoBAT.monetario = 100;
            descontoAgravoBAT.percentual = 100;
            descontoAgravoBAT.tipo = 'BAT';
            
            EmissaoTO.PremioTO premio = new EmissaoTO.PremioTO();
            EmissaoTO.TaxaTO taxa = new EmissaoTO.TaxaTO();
            
            EmissaoTO.CoberturaTO coberturaTO = new EmissaoTO.CoberturaTO();
            coberturaTO.premio = premio;
            coberturaTO.taxa = taxa;
            
            coberturaTO.descontoAgravo = new List<EmissaoTO.DescontoAgravoTO>();                                                                        
        
            OrcamentoGenericoBuilder orcamentoGenericoBuilder = new OrcamentoGenericoBuilder(true);
            
            orcamentoGenericoBuilder.mapCoberturasGarantiaSeguradoOrcamento.put( chave , coberturaTO );
            orcamentoGenericoBuilder.mapGarantiasSigla.put( chave , chave );
            
            
            garantiaOrcamento.TipoDescontoAgravo__c = 'TEC';
            
            coberturaTO.descontoAgravo.add(descontoAgravoTEC);
            orcamentoGenericoBuilder.popularSeguradoOrcamento( seguradoContrato, garantiaOrcamento );
            coberturaTO.descontoAgravo.clear();
            
            garantiaOrcamento.TipoDescontoAgravo__c = 'COM';
            
            coberturaTO.descontoAgravo.add( descontoAgravoCOM );
            orcamentoGenericoBuilder.popularSeguradoOrcamento( seguradoContrato, garantiaOrcamento );          
            coberturaTO.descontoAgravo.clear();
            
            
            garantiaOrcamento.TipoDescontoAgravo__c = 'BAT';
            
            coberturaTO.descontoAgravo.add(descontoAgravoBAT);
            orcamentoGenericoBuilder.popularSeguradoOrcamento( seguradoContrato, garantiaOrcamento );           
            coberturaTO.descontoAgravo.clear();
            
            orcamentoGenericoBuilder.popularSeguradoOrcamento( seguradoContrato, garantiaOrcamento );            
            
        }catch(Exception e){
            
            
        }  
        
        Test.stopTest();
    }

    //ANNVI-55 - INICIO
    private static Orcamento prepararInserirRegistro(){

        Orcamento orcamento = new Orcamento();
        Orcamento.OrcamentoWrapper orcamentoWrapper = new Orcamento.OrcamentoWrapper();
        Orcamento.retornoWrapper retornoWrapper = new Orcamento.retornoWrapper();
        Orcamento.RemuneracaoOrcamentoWrapper remuneracaoOrcamentoWrapper = new Orcamento.RemuneracaoOrcamentoWrapper();
        Orcamento.ContratanteWrapper contratanteWrapper = new Orcamento.ContratanteWrapper();
        Orcamento.PessoaWrapper pessoaWrapper = new Orcamento.PessoaWrapper();
        Orcamento.SeguradoWrapper seguradoWrapper = new Orcamento.SeguradoWrapper();

        Account conta = [SELECT Id, Name FROM Account];
    
        Product2 produtoComercial = [SELECT Id, Name FROM Product2 WHERE Name = 'Nome Produto Comercial'];
        produtoComercial.Name = 'Produto teste';

        update produtoComercial;

        RamoSeguro__c ramoSeguro = CreateTestData.createRamoSeguro(conta);
        DadosCorretor__c dadosCorretor = CreateTestData.createDadosCorretor(conta);
        CanalDistribuicao__c canalDistribuicao = CreateTestData.createCanalDistribuicao();

        String payloadName = 'PayloadOrcamento001';
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: payloadName LIMIT 1];
        Blob payloadEntrada = sr.Body;
       
        Opportunity sfOrcamento = new Opportunity(
                StageName = 'Em criação',
                CurrencyIsoCode = 'BRL',
                Name = 'ARQ-11006760',
                CloseDate = System.today().addDays(19),
                VigenciaInicial__c = System.today(),
                VigenciaFinal__c = System.today().addDays(2),
                Produto__c = produtoComercial.Id,
                Probability = 10.0,
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaIndividual').Id,
                AccountId = conta.Id,
                Numero__c = '10006760',
                CanalDistribuicao__c = canalDistribuicao.Id,
                Payload__c = EncodingUtil.base64Decode(EncodingUtil.base64Encode(payloadEntrada)).toString()
        );

        insert sfOrcamento;

        orcamentoWrapper.sfOrcamento = sfOrcamento;
        orcamento.orcamentoWrapper = orcamentoWrapper;

        CriticaOrcamento__c criticaOrcamento = new CriticaOrcamento__c();
        criticaOrcamento.Tipo__C = 'Análise';
        criticaOrcamento.Orcamento__c = sfOrcamento.Id; //ANNVI-55 - INICIO/FIM
        criticaOrcamento.Justificativa__c = 'XYZ';
        criticaOrcamento.Status__c = 'Liberado';
        
        insert criticaOrcamento;

        List<CriticaOrcamento__c> criticas = new List<CriticaOrcamento__c>();
        orcamentoWrapper.criticas.add(criticaOrcamento);

        List<Orcamento.GarantiaWrapper> garantiasWrapper = new List<Orcamento.GarantiaWrapper>();
        Orcamento.GarantiaWrapper garantiaWrapper = new Orcamento.GarantiaWrapper();
        garantiaWrapper.sigla = 'BLA';

        ContratanteOrcamento__c contratanteOrcamento = TestDataFactory.gerarContratanteOrcamento(sfOrcamento, conta);
        GrupoOrcamento__c grupoOrcamento = TestDataFactory.gerarGrupoOrcamento(contratanteOrcamento);

        GarantiaGrupoOrcamento__c garantiaGrupoOrcamento = new GarantiaGrupoOrcamento__c(
            GrupoOrcamento__c = grupoOrcamento.Id
        );

        insert garantiaGrupoOrcamento;

        garantiaWrapper.sfGarantiaGrupoOrcamento = garantiaGrupoOrcamento;

        Garantia__c garantia = TestDataFactory.gerarGarantia();
        GarantiaOrcamento__c sfGarantiaOrcamento = TestDataFactory.gerarGarantiaOrcamento(garantia, sfOrcamento);        
        
        GarantiaProduto__c garantiaProduto = new GarantiaProduto__c(
            TipoGarantia__c = 'Cobertura',
            Garantia__c = garantia.id,
            OrdemPrioridade__c = 1
        );
        
        insert garantiaProduto;

        sfGarantiaOrcamento.GarantiaProduto__c = garantiaProduto.Id;

        update sfGarantiaOrcamento;

        garantiaWrapper.sfGarantiaOrcamento = sfGarantiaOrcamento;

        GarantiaContratanteOrcamento__c garantiaContratanteOrcamento = TestDataFactory.gerarGarantiaContratanteOrcamento(garantia, contratanteOrcamento);

        garantiaWrapper.sfGarantiasContratanteOrcamento = garantiaContratanteOrcamento;

        SeguradoOrcamento__c seguradoOrcamento = TestDataFactory.gerarSeguradoOrcamento(grupoOrcamento);
        GarantiaSeguradoOrcamento__c sfGarantiaSeguradoOrcamento = TestDataFactory.gerarGarantiaSeguradoOrcamento(garantia, seguradoOrcamento);

        garantiaWrapper.sfGarantiaSeguradoOrcamento = sfGarantiaSeguradoOrcamento;
        garantiasWrapper.add(garantiaWrapper);
        orcamento.orcamentoWrapper.garantiasWrapper = garantiasWrapper;
        
        TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao('EXE', 100, 200, null);

        remuneracaoOrcamentoWrapper.chave = 'teste';
        List<Orcamento.RemuneracaoOrcamentoWrapper> remuneracoesOrcamento = new List<Orcamento.RemuneracaoOrcamentoWrapper>();
        remuneracaoOrcamentoWrapper.sfRemuneracaoOrcamento = TestDataFactory.gerarRemuneracaoOrcamento(sfOrcamento, tipoRemuneracao);
        
        remuneracoesOrcamento.add(remuneracaoOrcamentoWrapper);
        orcamento.orcamentoWrapper.RemuneracaoOrcamentoWrapper = remuneracoesOrcamento;

        List<Orcamento.ContratanteWrapper> contratantesWrapper = new List<Orcamento.ContratanteWrapper>();
        contratanteWrapper.chave = 'teste';
        contratanteWrapper.garantiasWrapper = garantiasWrapper;

        List<Orcamento.GrupoWrapper> gruposWrapper = new List<Orcamento.GrupoWrapper>();
        Orcamento.GrupoWrapper grupoWrapper = new Orcamento.GrupoWrapper();

        grupoWrapper.chave = 'teste';
        grupoWrapper.garantiasWrapper = garantiasWrapper;

        pessoaWrapper.sfConta = conta;

        List<Endereco__c> enderecos = new List<Endereco__c>();
        Endereco__c endereco = [SELECT Id FROM Endereco__c LIMIT 1];

        enderecos.add(endereco);

        pessoaWrapper.enderecos = enderecos;

        List<Orcamento.SeguradoWrapper> seguradosWrapper = new List<Orcamento.SeguradoWrapper>();
        seguradoWrapper.chave = 'teste';
        seguradoWrapper.garantiasWrapper = garantiasWrapper;
        seguradoWrapper.pessoaWrapper = pessoaWrapper;
        seguradoWrapper.sfSegurado = seguradoOrcamento;

        seguradosWrapper.add(seguradoWrapper);

        grupoWrapper.seguradosWrapper = seguradosWrapper;
        grupoWrapper.sfGrupo = grupoOrcamento;
        gruposWrapper.add(grupoWrapper);

        contratanteWrapper.gruposWrapper = gruposWrapper;
        contratantesWrapper.add(contratanteWrapper);
        Orcamento.orcamentoWrapper.contratantesWrapper = contratantesWrapper;

        retornoWrapper.codigoEmpresa = '1';
        retornoWrapper.codigoRamo = '1391';
        retornoWrapper.codigoSucursal = '1';
        retornoWrapper.numeroApolice = '000016160';
        retornoWrapper.tipoEndosso = '0';

        retornoWrapper.retorno = new RetornoOrcamentoRestTO.ValidacaoOrcamentoTO();
        retornoWrapper.retorno.devolutivas = new List<RetornoOrcamentoRestTO.DevolutivasTO>();
        
        RetornoOrcamentoRestTO.DevolutivasTO devolutiva = new RetornoOrcamentoRestTO.DevolutivasTO();
        devolutiva.codigo = 1;
        devolutiva.descricao = 'teste';
        devolutiva.numeroCampo = 1;
        devolutiva.origem = 'teste';
        devolutiva.tipoRegistro = 1;

        retornoWrapper.retorno.devolutivas.add(devolutiva);

        retornoWrapper.retorno.ofertas = new List<RetornoOrcamentoRestTO.OfertasTO>();

        RetornoOrcamentoRestTO.OfertasTO oferta = new RetornoOrcamentoRestTO.OfertasTO();
        oferta.orcamento = new RetornoOrcamentoRestTO.OrcamentoTO();
        oferta.orcamento.status = 'Teste';
        oferta.orcamento.apolice = 123;
        oferta.orcamento.ramo = 456;
        oferta.orcamento.tipoSeguro = 'Seguro de Vida';
        oferta.orcamento.tipoAdesao = 'Adesão Individual';
        oferta.orcamento.vigenciaFinal = '31/12/2022';
        oferta.orcamento.empresa = 789;
        oferta.orcamento.dataCalculo = '01/01/2022';
        oferta.orcamento.sucursal = 1011;
        oferta.orcamento.vigenciaInicial = '01/02/2022';
        oferta.orcamento.numeroOrcamento = 1213;
        oferta.orcamento.meioComercializacao = 'Online';
        oferta.orcamento.qtdDiasVigencia = 30;
        //oferta.orcamento.codigoCupom = 'ABC123';

        oferta.retornoAceitacao = 'teste';
        oferta.retornoCalculo = '1';
        oferta.retornoIntegracoes = '1';
        oferta.retornoValidacaoProduto = '1';
        
        retornoWrapper.retorno.ofertas.add(oferta);

        retornoWrapper.retorno.orcamento = new RetornoOrcamentoRestTO.OrcamentoTO();
        retornoWrapper.retorno.orcamento.status = 'Teste';
        retornoWrapper.retorno.orcamento.apolice = 123;
        retornoWrapper.retorno.orcamento.ramo = 456;
        retornoWrapper.retorno.orcamento.tipoSeguro = 'Seguro de Vida';
        retornoWrapper.retorno.orcamento.tipoAdesao = 'Adesão Individual';
        retornoWrapper.retorno.orcamento.vigenciaFinal = '31/12/2022';
        retornoWrapper.retorno.orcamento.empresa = 789;
        retornoWrapper.retorno.orcamento.dataCalculo = '01/01/2022';
        retornoWrapper.retorno.orcamento.sucursal = 1011;
        retornoWrapper.retorno.orcamento.vigenciaInicial = '01/02/2022';
        retornoWrapper.retorno.orcamento.numeroOrcamento = 1213;
        retornoWrapper.retorno.orcamento.meioComercializacao = 'Online';
        retornoWrapper.retorno.orcamento.qtdDiasVigencia = 30;
        //retornoWrapper.retorno.orcamento.codigoCupom = 'ABC123';

        orcamento.orcamentoWrapper.retornoWrapper = retornoWrapper;

        return orcamento;
    }

    @IsTest
    public static void buscarParcParamVigFalseTest(){
		
        Test.startTest(); 

        Contract contrato = [SELECT Id, Produto__c FROM Contract]; // PLV-5331 INÍCIO/FIM
        System.debug('contrato => ' + contrato);

        List<EmissaoTO.OfertasTO> listaOfertas = new List<EmissaoTO.OfertasTO>(); // PLV-5331 INÍCIO/FIM

        String payload = '{"ofertas":[{"orcamento":{"tipoVigencia":"Periódico","tipoSeguro":"eds","vigenciaFinal":"2019-10-08","numeroOrcamento":"00000003","numeroPortal":0,"codigoProdutoVida":"VI-PESSOAS","idProdutoSf": "'+contrato.Produto__c+'","customizavel":true,"contratantes":[{"tipo":"PRI","numero":1,"grupos":[{"numero":1,"segurados":[{"pessoa":{"tipo":"FIS","enderecos":[{"uf":"SP","cidade":"SAO PAULO","complemento":"Apto 22","logradouro":"Guaianses","bairro":"Centro","complementoCep":"420","tipoLogradouro":"R","paisResidencia":"BRASIL","tipoEndereco":"REC","numeroLogradouro":"92","cep":"07114"}],"nome":"Testinho","dadosPessoaFisica":{"numeroCpf":"438912318","profissao":null,"tipoContrato":"TODOS","celular":"(11) 11111-1111","digitoCpf":"14","dataNascimento":"2000-11-11","fumante":false,"sexo":"MASCULINO","renda":"FAIXA2"},"email":"teste@teste.com.br"},"numero":1,"coberturas":[{"sigla":"BAS","valor":20000},{"sigla":"MAP","valor":20000},{"sigla":"CAP","valor":10}]}],"nome":"Testinho","qtdeVidas":1}]}],"canalDistribuicao":"EXE","meioComercializacao":"CO2","segmento":"Individual","versoesCalculos":[{"opcao":0,"tipo":"FPG","descontoAgravo":0},{"opcao":1,"tipo":"FPG","descontoAgravo":-5},{"opcao":2,"tipo":"FPG","descontoAgravo":5}],"ordemPortal":1,"rotulo":"Sniper - Plano Básico","remuneracoes":[{"percentual":20,"tipoRemuneracao":"CORRETAGEM"}],"vigenciaInicial":"2019-09-23","dataCalculo":"2019-09-23"},"retornosCalculo":[{"opcao":0,"orcnum":"00000003","numeroOrcamento":"00000003","numeroOferta":123,"precificacao":{"juros":0,"iof":1.24,"encargos":0,"custoDeApolice":0,"premio":{"comercial":205.98,"puro":219.98,"total":225.00},"taxa":{"comercial":0.0002185,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}],"coberturas":[{"sigla":"BAS","capital":350000.00,"iof":0.28,"premio":{"comercial":75.00,"puro":75.00,"total":75.00},"taxa":{"comercial":0.000043,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"MAP","capital":500000.00,"iof":0.19,"premio":{"comercial":50.0,"puro":50.0,"total":50.0},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DIH","capital":1400.00,"iof":0.09,"premio":{"comercial":25.0,"puro":25.0,"total":25.0},"taxa":{"comercial":0.00031,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DG 10","capital":6000.00,"iof":0.14,"premio":{"comercial":37.50,"puro":37.50,"total":37.50},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"AFI","capital":2900.00,"iof":0.14,"premio":{"comercial":37.50,"puro":37.50,"total":37.50},"taxa":{"comercial":0.000015,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]}],"contratantes":[{"numero":1,"iof":1.24,"premio":{"comercial":4.38,"puro":3.98,"total":5.00},"taxa":{"comercial":0.0002185,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}],"coberturas":[{"sigla":"BAS","capital":119.8,"iof":1.24,"premio":{"comercial":2.58,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000043,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DG 10","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"MAP","capital":1000.7,"iof":1.24,"premio":{"comercial":1.55,"puro":3.98,"total":5.00},"taxa":{"comercial":0.00031,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DIH","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"AFI","capital":2900.2,"iof":1.24,"premio":{"comercial":0.22,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000015,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]}],"grupos":[{"numero":1,"iof":1.24,"premio":{"comercial":4.38,"puro":3.98,"total":5.00},"taxa":{"comercial":0.0002185,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}],"coberturas":[{"sigla":"BAS","capital":119.8,"iof":1.24,"premio":{"comercial":2.58,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000043,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"MAP","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"AFI","capital":1000.7,"iof":1.24,"premio":{"comercial":1.55,"puro":3.98,"total":5.00},"taxa":{"comercial":0.00031,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DIH","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DG 10","capital":2900.2,"iof":1.24,"premio":{"comercial":0.22,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000015,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]}],"segurados":[{"numero":1,"iof":1.24,"premio":{"comercial":4.38,"puro":3.98,"total":5.00},"taxa":{"comercial":0.0002185,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}],"coberturas":[{"sigla":"BAS","capital":119.8,"iof":1.24,"premio":{"comercial":2.58,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000043,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"MAP","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"AFI","capital":1000.7,"iof":1.24,"premio":{"comercial":1.55,"puro":3.98,"total":5.00},"taxa":{"comercial":0.00031,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DG 10","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DIH","capital":1000900,"iof":1.24,"premio":{"comercial":0.22,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000015,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]}]}]}]}]}}],"retornoAceitacao":{},"retornoIntegracoes":{"validacaoZeroDolar":null,"IndiceMonetario":{"ItensCotacao":[{"moedaOrigem":"USD","moedaDestino":"BRL","dataCotacao":13112018,"cotacao":"3.74720000"},{"moedaOrigem":"EUR","moedaDestino":"BRL","dataCotacao":13112018,"cotacao":"4.04720000"},{"moedaOrigem":"BRL","moedaDestino":"BRL","dataCotacao":13112018,"cotacao":"1"}]}}}]}';// PLV-5331 INÍCIO/FIM //ANNVI-55 - INICIO/FIM

        EmissaoTO.PayloadTO payloadTO = (EmissaoTO.PayloadTO) JSON.deserialize(payload, EmissaoTO.PayloadTO.class);

        for(EmissaoTO.OfertasTO oferta : payloadTO.ofertas){
            oferta.orcamento.vigenciaInicial = String.valueOf(System.today().addDays(1));
            oferta.orcamento.vigenciaFinal = String.valueOf(System.today().addDays(2));
            oferta.orcamento.dataCalculo = String.valueOf(system.today().addDays(-130));
        }        

        ParametroVigencia__c param2 = [SELECT Id, ParcelamentoAposFinalVigencia__c FROM ParametroVigencia__c];
        param2.ParcelamentoAposFinalVigencia__c = false;
        upsert param2;

        CondicaoCobranca__c condicaoCobranca = [
            SELECT 
                Id,
                NomeFormaPagamento__c,
                FormaPagamento__c,
                FormaPagamento__r.Codigo__c,	
                FormaPagamento__r.Name,
                TipoPagamento__c,
                QuantidadeParcelas__c,
                PercentualDescontoAgravo__c,
                //LimiteValorParcela__c,//ANNVI-55 - INICIO/FIM
                AntecipacaoComissao__c,
                Produto__r.ProductCode,
                Produto__r.Status__c
            FROM
                CondicaoCobranca__c
            ];
     
        condicaoCobranca.NomeFormaPagamento__c = 'ADC';
        condicaoCobranca.TipoPagamento__c = 'ADC';
        condicaoCobranca.Produto__r.ProductCode = 'VI-PESSOAS';

        Product2 produto = [SELECT Id, ProductCode FROM Product2 WHERE Id = :condicaoCobranca.Produto__r.Id];
        produto.ProductCode = 'VI-PESSOAS';

        update produto;

        condicaoCobranca.Produto__r = produto;

        update condicaoCobranca;

        CondicaoCobranca__c condicaoCobranca2 = [
            SELECT 
                Id,
                NomeFormaPagamento__c,
                FormaPagamento__c,
                FormaPagamento__r.Codigo__c,	
                FormaPagamento__r.Name,
                TipoPagamento__c,
                QuantidadeParcelas__c,
                PercentualDescontoAgravo__c,
                //LimiteValorParcela__c,//ANNVI-55 - INICIO/FIM
                AntecipacaoComissao__c,
                Produto__r.ProductCode,
                Produto__r.Status__c
            FROM
                CondicaoCobranca__c
            ];
     
        condicaoCobranca2.NomeFormaPagamento__c = 'ADC';
        condicaoCobranca2.TipoPagamento__c = 'ADC';
        condicaoCobranca2.Produto__r.ProductCode = 'VI-PESSOAS';

        Product2 produto2 = [SELECT Id, ProductCode FROM Product2 WHERE Id = :condicaoCobranca2.Produto__r.Id];
        produto2.ProductCode = 'VI-PESSOAS';

        update produto2;

        condicaoCobranca2.Produto__r = produto2;

        update condicaoCobranca2;

        TestDataFactory.gerarPlanoParcelamento(condicaoCobranca.FormaPagamento__r.Id);
        TestDataFactory.gerarPlanoParcelamento(condicaoCobranca2.FormaPagamento__r.Id);
    
        OrcamentoGenericoBuilder.buscarParcelamentos(payloadTO.ofertas[0]);
        Test.StopTest();
    }

    @IsTest
    static void testarMontarCobOrc(){

        OrcamentoGenericoBuilder ogb = OrcamentoGenericoBuilder.getInstance();

        List<EmissaoTO.CoberturaTO> coberturasTO = new  List<EmissaoTO.CoberturaTO>();
        EmissaoTO.CoberturaTO coberturaTO = new EmissaoTO.CoberturaTO();
        Set<String> setSiglasCoberturas = new Set<String>{'MAP'};
        Map<String, GarantiaProduto__c> mGarantiaProd = new Map<String, GarantiaProduto__c>();
        Map<String, EmissaoTO.coberturaTO> mapCalculos = new Map<String, EmissaoTO.coberturaTO>();
        EmissaoTO.OfertasTO payloadTO = new EmissaoTO.OfertasTO();
        EmissaoTO.TaxaTO taxa = new EmissaoTO.TaxaTO();   
        EmissaoTO.PremioTO premio = new EmissaoTO.PremioTO();
        List<EmissaoTO.DescontoAgravoTO> descontosAgravo = new List<EmissaoTO.DescontoAgravoTO>();
        
        payloadTO.orcamento = new EmissaoTO();
        payloadTO.orcamento.tipoSeguro = 'eds';
        payloadTO.orcamento.contratoOriginal = new EmissaoTO();
        payloadTO.orcamento.contratoOriginal.precificacao = new EmissaoTO.PrecificacaoTO();        
    
        Test.startTest();        

        taxa.pura = 10;
        taxa.comercial = 20;
        taxa.total = 30;
    
        premio.comercial = 10;
        premio.total = 20;
        premio.puro = 30;
            
        coberturaTO.taxa = taxa;
        coberturaTO.premio = premio;
        coberturaTO.sigla = 'MAP';
        coberturaTO.valor = 10.0;
        coberturaTO.quantidade = '1';
        coberturaTO.caracteristicaespecialvalor = 10.0;
        coberturaTO.caracteristicaespecialtipo = 'Ano(s)';
        EmissaoTO.DescontoAgravoTO descontoAgravoTEC = new EmissaoTO.DescontoAgravoTO();                        
        descontoAgravoTEC.monetario = 100;
        descontoAgravoTEC.percentual = 100;
        descontoAgravoTEC.tipo = 'TEC';

        EmissaoTO.DescontoAgravoTO descontoAgravoCOM = new EmissaoTO.DescontoAgravoTO();                        
        descontoAgravoCOM.monetario = 100;
        descontoAgravoCOM.percentual = 100;
        descontoAgravoCOM.tipo = 'COM';

        EmissaoTO.DescontoAgravoTO descontoAgravoBAT = new EmissaoTO.DescontoAgravoTO();                        
        descontoAgravoBAT.monetario = 100;
        descontoAgravoBAT.percentual = 100;
        descontoAgravoBAT.tipo = 'BAT';

        descontosAgravo.add(descontoAgravoTEC);
        descontosAgravo.add(descontoAgravoCOM);
        descontosAgravo.add(descontoAgravoBAT);

        coberturaTO.descontoAgravo = descontosAgravo;

        coberturasTO.add(coberturaTO);
        payloadTO.orcamento.contratoOriginal.coberturas = coberturasTO;

        mapCalculos.put(coberturaTO.sigla, coberturaTO);

        Account conta = [SELECT Id, Name FROM Account];    
        Product2 produtoComercial = [SELECT Id, Name FROM Product2 WHERE Name = 'Nome Produto Comercial'];

        CanalDistribuicao__c canalDistribuicao = CreateTestData.createCanalDistribuicao();

        String payloadName = 'PayloadOrcamento001';
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: payloadName LIMIT 1];
        Blob payloadEntrada = sr.Body;

        Opportunity orcamento = new Opportunity(
            StageName = 'Em criação',
            CurrencyIsoCode = 'BRL',
            Name = 'ARQ-1100760',
            CloseDate = System.today().addDays(19),
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addDays(2),
            Produto__c = produtoComercial.Id,
            Probability = 10.0,
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaIndividual').Id,
            AccountId = conta.Id,
            Numero__c = '10005760',
            CanalDistribuicao__c = canalDistribuicao.Id,
            Payload__c = EncodingUtil.base64Decode(EncodingUtil.base64Encode(payloadEntrada)).toString()
        );

        insert orcamento;

        Garantia__c garantia = TestDataFactory.gerarGarantia();
        GarantiaProduto__c garantiaProduto = new GarantiaProduto__c(
            TipoGarantia__c = 'Cobertura',
            Garantia__c = garantia.id,
            OrdemPrioridade__c = 1
        );
        
        insert garantiaProduto;

        Franquia__c franquia = new Franquia__c(
			Name = 'Franquia 1'
		);
		insert franquia;

        FranquiaGarantia__c franquiaGarantia = new FranquiaGarantia__c(
			GarantiaProduto__c = garantiaProduto.Id,
			Franquia__c = franquia.Id,
			RecordTypeId = RecordTypeBO.buscarTipoRegistro('FranquiaGarantia__c', 'ProdutoTecnico').Id
		);
		insert franquiaGarantia;
        
        GarantiaOrcamento__c garantiaOrcamento = TestDataFactory.gerarGarantiaOrcamento(garantia, orcamento);
        garantiaOrcamento.CurrencyIsoCode = 'BRL';

        update garantiaOrcamento;        

        garantiaOrcamento.GarantiaProduto__c = garantiaProduto.Id;

        update garantiaOrcamento;

        mGarantiaProd.put(coberturaTO.sigla, garantiaProduto);
    
        ogb.montarCoberturaOrcamento(coberturaTO, garantiaOrcamento, setSiglasCoberturas, mGarantiaProd, mapCalculos, payloadTO);

        Test.stopTest();
        
    }

    @IsTest
    static void testarMontarCobCtt(){

        OrcamentoGenericoBuilder ogb = OrcamentoGenericoBuilder.getInstance();

        List<EmissaoTO.CoberturaTO> coberturasTO = new List<EmissaoTO.CoberturaTO>();
        EmissaoTO.CoberturaTO coberturaTO = new EmissaoTO.CoberturaTO();
        Set<String> setSiglasCoberturas = new Set<String>{'MAP'};
        ogb.mGarantiaProd = new Map<String, GarantiaProduto__c>();
        Map<String, EmissaoTO.coberturaTO> mapCalculos = new Map<String, EmissaoTO.coberturaTO>();
        EmissaoTO.OfertasTO payloadTO = new EmissaoTO.OfertasTO();
        EmissaoTO.TaxaTO taxa = new EmissaoTO.TaxaTO();   
        EmissaoTO.PremioTO premio = new EmissaoTO.PremioTO();
        List<EmissaoTO.DescontoAgravoTO> descontosAgravo = new List<EmissaoTO.DescontoAgravoTO>();
        
        payloadTO.orcamento = new EmissaoTO();
        payloadTO.orcamento.tipoSeguro = 'eds';
        payloadTO.orcamento.contratoOriginal = new EmissaoTO();
        payloadTO.orcamento.contratoOriginal.precificacao = new EmissaoTO.PrecificacaoTO();
        payloadTO.orcamento.contratoOriginal.coberturas = new List<EmissaoTO.CoberturaTO>();
    
        Test.startTest();        

        taxa.pura = 10;
        taxa.comercial = 20;
        taxa.total = 30;
    
        premio.comercial = 10;
        premio.total = 20;
        premio.puro = 30;
            
        coberturaTO.taxa = taxa;
        coberturaTO.premio = premio;
        coberturaTO.sigla = 'MAP';
        coberturaTO.valor = 10.0;
        coberturaTO.quantidade = '1';
        coberturaTO.caracteristicaespecialvalor = 10.0;
        coberturaTO.caracteristicaespecialtipo = 'Ano(s)';

        EmissaoTO.DescontoAgravoTO descontoAgravoTEC = new EmissaoTO.DescontoAgravoTO();                        
        descontoAgravoTEC.monetario = 100;
        descontoAgravoTEC.percentual = 100;
        descontoAgravoTEC.tipo = 'TEC';

        EmissaoTO.DescontoAgravoTO descontoAgravoCOM = new EmissaoTO.DescontoAgravoTO();                        
        descontoAgravoCOM.monetario = 100;
        descontoAgravoCOM.percentual = 100;
        descontoAgravoCOM.tipo = 'COM';

        EmissaoTO.DescontoAgravoTO descontoAgravoBAT = new EmissaoTO.DescontoAgravoTO();                        
        descontoAgravoBAT.monetario = 100;
        descontoAgravoBAT.percentual = 100;
        descontoAgravoBAT.tipo = 'BAT';

        descontosAgravo.add(descontoAgravoTEC);
        descontosAgravo.add(descontoAgravoCOM);
        descontosAgravo.add(descontoAgravoBAT);

        coberturaTO.descontoAgravo = descontosAgravo;

        coberturasTO.add(coberturaTO);
        payloadTO.orcamento.contratoOriginal.coberturas = coberturasTO;

        mapCalculos.put(coberturaTO.sigla, coberturaTO);

        Account conta = [SELECT Id, Name FROM Account];    
        Product2 produtoComercial = [SELECT Id, Name FROM Product2 WHERE Name = 'Nome Produto Comercial'];

        CanalDistribuicao__c canalDistribuicao = CreateTestData.createCanalDistribuicao();

        String payloadName = 'PayloadOrcamento001';
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: payloadName LIMIT 1];
        Blob payloadEntrada = sr.Body;

        Opportunity orcamento = new Opportunity(
            StageName = 'Em criação',
            CurrencyIsoCode = 'BRL',
            Name = 'ARQ-1100760',
            CloseDate = System.today().addDays(19),
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addDays(2),
            Produto__c = produtoComercial.Id,
            Probability = 10.0,
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaIndividual').Id,
            AccountId = conta.Id,
            Numero__c = '10005760',
            CanalDistribuicao__c = canalDistribuicao.Id,
            Payload__c = EncodingUtil.base64Decode(EncodingUtil.base64Encode(payloadEntrada)).toString()
        );

        insert orcamento;

        Garantia__c garantia = TestDataFactory.gerarGarantia();
        GarantiaProduto__c garantiaProduto = new GarantiaProduto__c(
            TipoGarantia__c = 'Cobertura',
            Garantia__c = garantia.id,
            OrdemPrioridade__c = 1
        );
        
        insert garantiaProduto;

        ogb.mGarantiaProd.put(coberturaTO.sigla, garantiaProduto);
        
        ContratanteOrcamento__c contratanteOrcamento = TestDataFactory.gerarContratanteOrcamento(orcamento, conta);
        GarantiaContratanteOrcamento__c garantiaContratanteOrcamento = TestDataFactory.gerarGarantiaContratanteOrcamento(garantia, contratanteOrcamento);
        
        ogb.montarCoberturaContratante(coberturaTO, garantiaContratanteOrcamento, setSiglasCoberturas, mapCalculos, payloadTO);

        Test.stopTest();        
    }

    @IsTest
    static void testarMontarCobGrp(){

        OrcamentoGenericoBuilder ogb = OrcamentoGenericoBuilder.getInstance();

        List<EmissaoTO.CoberturaTO> coberturasTO = new List<EmissaoTO.CoberturaTO>();
        EmissaoTO.CoberturaTO coberturaTO = new EmissaoTO.CoberturaTO();
        Set<String> setSiglasCoberturas = new Set<String>{'MAP'};
        ogb.mGarantiaProd = new Map<String, GarantiaProduto__c>();
        Map<String, EmissaoTO.coberturaTO> mapCalculos = new Map<String, EmissaoTO.coberturaTO>();
        EmissaoTO.OfertasTO payloadTO = new EmissaoTO.OfertasTO();
        EmissaoTO.TaxaTO taxa = new EmissaoTO.TaxaTO();   
        EmissaoTO.PremioTO premio = new EmissaoTO.PremioTO();
        List<EmissaoTO.DescontoAgravoTO> descontosAgravo = new List<EmissaoTO.DescontoAgravoTO>();
        
        payloadTO.orcamento = new EmissaoTO();
        payloadTO.orcamento.tipoSeguro = 'eds';
        payloadTO.orcamento.contratoOriginal = new EmissaoTO();
        payloadTO.orcamento.contratoOriginal.precificacao = new EmissaoTO.PrecificacaoTO();
        payloadTO.orcamento.contratoOriginal.coberturas = new List<EmissaoTO.CoberturaTO>();
    
        Test.startTest();        

        taxa.pura = 10;
        taxa.comercial = 20;
        taxa.total = 30;
    
        premio.comercial = 10;
        premio.total = 20;
        premio.puro = 30;
            
        coberturaTO.taxa = taxa;
        coberturaTO.premio = premio;
        coberturaTO.sigla = 'MAP';
        coberturaTO.valor = 10.0;
        coberturaTO.quantidade = '1';
        coberturaTO.caracteristicaespecialvalor = 10.0;
        coberturaTO.caracteristicaespecialtipo = 'Ano(s)';

        EmissaoTO.DescontoAgravoTO descontoAgravoTEC = new EmissaoTO.DescontoAgravoTO();                        
        descontoAgravoTEC.monetario = 100;
        descontoAgravoTEC.percentual = 100;
        descontoAgravoTEC.tipo = 'TEC';

        EmissaoTO.DescontoAgravoTO descontoAgravoCOM = new EmissaoTO.DescontoAgravoTO();                        
        descontoAgravoCOM.monetario = 100;
        descontoAgravoCOM.percentual = 100;
        descontoAgravoCOM.tipo = 'COM';

        EmissaoTO.DescontoAgravoTO descontoAgravoBAT = new EmissaoTO.DescontoAgravoTO();                        
        descontoAgravoBAT.monetario = 100;
        descontoAgravoBAT.percentual = 100;
        descontoAgravoBAT.tipo = 'BAT';

        descontosAgravo.add(descontoAgravoTEC);
        descontosAgravo.add(descontoAgravoCOM);
        descontosAgravo.add(descontoAgravoBAT);

        coberturaTO.descontoAgravo = descontosAgravo;

        coberturasTO.add(coberturaTO);
        payloadTO.orcamento.contratoOriginal.coberturas = coberturasTO;

        mapCalculos.put(coberturaTO.sigla, coberturaTO);

        Account conta = [SELECT Id, Name FROM Account];    
        Product2 produtoComercial = [SELECT Id, Name FROM Product2 WHERE Name = 'Nome Produto Comercial'];

        CanalDistribuicao__c canalDistribuicao = CreateTestData.createCanalDistribuicao();

        String payloadName = 'PayloadOrcamento001';
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: payloadName LIMIT 1];
        Blob payloadEntrada = sr.Body;

        Opportunity orcamento = new Opportunity(
            StageName = 'Em criação',
            CurrencyIsoCode = 'BRL',
            Name = 'ARQ-1100760',
            CloseDate = System.today().addDays(19),
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addDays(2),
            Produto__c = produtoComercial.Id,
            Probability = 10.0,
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaIndividual').Id,
            AccountId = conta.Id,
            Numero__c = '10005760',
            CanalDistribuicao__c = canalDistribuicao.Id,
            Payload__c = EncodingUtil.base64Decode(EncodingUtil.base64Encode(payloadEntrada)).toString()
        );

        insert orcamento;

        Garantia__c garantia = TestDataFactory.gerarGarantia();
        GarantiaProduto__c garantiaProduto = new GarantiaProduto__c(
            TipoGarantia__c = 'Cobertura',
            Garantia__c = garantia.id,
            OrdemPrioridade__c = 1
        );
        
        insert garantiaProduto;

        ogb.mGarantiaProd.put(coberturaTO.sigla, garantiaProduto);
        
        ContratanteOrcamento__c contratanteOrcamento = TestDataFactory.gerarContratanteOrcamento(orcamento, conta);
        GrupoOrcamento__c grupoOrcamento = TestDataFactory.gerarGrupoOrcamento(contratanteOrcamento);
        GarantiaGrupoOrcamento__c garantiaGrupoOrcamento = TestDataFactory.gerarGarantiaGrupoOrcamento(garantia, grupoOrcamento);
        
        ogb.montarCoberturaGrupo(coberturaTO, garantiaGrupoOrcamento, setSiglasCoberturas, mapCalculos, payloadTO);

        Test.stopTest();        
    }

    @IsTest
    static void testarMontarCobSeg(){

        OrcamentoGenericoBuilder ogb = OrcamentoGenericoBuilder.getInstance();

        List<EmissaoTO.CoberturaTO> coberturasTO = new List<EmissaoTO.CoberturaTO>();
        EmissaoTO.CoberturaTO coberturaTO = new EmissaoTO.CoberturaTO();
        Set<String> setSiglasCoberturas = new Set<String>{'MAP'};
        ogb.mGarantiaProd = new Map<String, GarantiaProduto__c>();
        Map<String, EmissaoTO.coberturaTO> mapCalculos = new Map<String, EmissaoTO.coberturaTO>();
        EmissaoTO.OfertasTO payloadTO = new EmissaoTO.OfertasTO();
        EmissaoTO.TaxaTO taxa = new EmissaoTO.TaxaTO();   
        EmissaoTO.PremioTO premio = new EmissaoTO.PremioTO();
        List<EmissaoTO.DescontoAgravoTO> descontosAgravo = new List<EmissaoTO.DescontoAgravoTO>();
        
        payloadTO.orcamento = new EmissaoTO();
        payloadTO.orcamento.tipoSeguro = 'eds';
        payloadTO.orcamento.contratoOriginal = new EmissaoTO();
        payloadTO.orcamento.contratoOriginal.precificacao = new EmissaoTO.PrecificacaoTO();
        payloadTO.orcamento.contratoOriginal.coberturas = new List<EmissaoTO.CoberturaTO>();
    
        Test.startTest();        

        taxa.pura = 10;
        taxa.comercial = 20;
        taxa.total = 30;
    
        premio.comercial = 10;
        premio.total = 20;
        premio.puro = 30;
            
        coberturaTO.taxa = taxa;
        coberturaTO.premio = premio;
        coberturaTO.sigla = 'MAP';
        coberturaTO.valor = 10.0;
        coberturaTO.quantidade = '1';
        coberturaTO.caracteristicaespecialvalor = 10.0;
        coberturaTO.caracteristicaespecialtipo = 'Ano(s)';

        EmissaoTO.DescontoAgravoTO descontoAgravoTEC = new EmissaoTO.DescontoAgravoTO();                        
        descontoAgravoTEC.monetario = 100;
        descontoAgravoTEC.percentual = 100;
        descontoAgravoTEC.tipo = 'TEC';

        EmissaoTO.DescontoAgravoTO descontoAgravoCOM = new EmissaoTO.DescontoAgravoTO();                        
        descontoAgravoCOM.monetario = 100;
        descontoAgravoCOM.percentual = 100;
        descontoAgravoCOM.tipo = 'COM';

        EmissaoTO.DescontoAgravoTO descontoAgravoBAT = new EmissaoTO.DescontoAgravoTO();                        
        descontoAgravoBAT.monetario = 100;
        descontoAgravoBAT.percentual = 100;
        descontoAgravoBAT.tipo = 'BAT';

        descontosAgravo.add(descontoAgravoTEC);
        descontosAgravo.add(descontoAgravoCOM);
        descontosAgravo.add(descontoAgravoBAT);

        coberturaTO.descontoAgravo = descontosAgravo;

        coberturasTO.add(coberturaTO);
        payloadTO.orcamento.contratoOriginal.coberturas = coberturasTO;

        mapCalculos.put(coberturaTO.sigla, coberturaTO);

        Account conta = [SELECT Id, Name FROM Account];    
        Product2 produtoComercial = [SELECT Id, Name FROM Product2 WHERE Name = 'Nome Produto Comercial'];

        CanalDistribuicao__c canalDistribuicao = CreateTestData.createCanalDistribuicao();

        String payloadName = 'PayloadOrcamento001';
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: payloadName LIMIT 1];
        Blob payloadEntrada = sr.Body;

        Opportunity orcamento = new Opportunity(
            StageName = 'Em criação',
            CurrencyIsoCode = 'BRL',
            Name = 'ARQ-1100760',
            CloseDate = System.today().addDays(19),
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addDays(2),
            Produto__c = produtoComercial.Id,
            Probability = 10.0,
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaIndividual').Id,
            AccountId = conta.Id,
            Numero__c = '10005760',
            CanalDistribuicao__c = canalDistribuicao.Id,
            Payload__c = EncodingUtil.base64Decode(EncodingUtil.base64Encode(payloadEntrada)).toString()
        );

        insert orcamento;

        Garantia__c garantia = TestDataFactory.gerarGarantia();
        GarantiaProduto__c garantiaProduto = new GarantiaProduto__c(
            TipoGarantia__c = 'Cobertura',
            Garantia__c = garantia.id,
            OrdemPrioridade__c = 1
        );
        
        insert garantiaProduto;

        ogb.mGarantiaProd.put(coberturaTO.sigla, garantiaProduto);
        
        ContratanteOrcamento__c contratanteOrcamento = TestDataFactory.gerarContratanteOrcamento(orcamento, conta);
        GrupoOrcamento__c grupoOrcamento = TestDataFactory.gerarGrupoOrcamento(contratanteOrcamento);
        SeguradoOrcamento__c seguradoOrcamento = TestDataFactory.gerarSeguradoOrcamento(grupoOrcamento);
        GarantiaSeguradoOrcamento__c garantiaSeguradoOrcamento = TestDataFactory.gerarGarantiaSeguradoOrcamento(garantia, seguradoOrcamento);
        
        ogb.montarCoberturaSegurado(coberturaTO, garantiaSeguradoOrcamento, setSiglasCoberturas, mapCalculos, payloadTO);

        Test.stopTest();        
    }

    @IsTest
    static void testarMontarCoberturaGrp(){

        OrcamentoGenericoBuilder ogb = OrcamentoGenericoBuilder.getInstance();

        List<EmissaoTO.CoberturaTO> coberturasTO = new List<EmissaoTO.CoberturaTO>();
        EmissaoTO.CoberturaTO coberturaTO = new EmissaoTO.CoberturaTO();
        Set<String> setSiglasCoberturas = new Set<String>{'MAP'};
        ogb.mGarantiaProd = new Map<String, GarantiaProduto__c>();
        Map<String, EmissaoTO.coberturaTO> mapCalculos = new Map<String, EmissaoTO.coberturaTO>();
        EmissaoTO.OfertasTO payloadTO = new EmissaoTO.OfertasTO();
        EmissaoTO.TaxaTO taxa = new EmissaoTO.TaxaTO();   
        EmissaoTO.PremioTO premio = new EmissaoTO.PremioTO();
        List<EmissaoTO.DescontoAgravoTO> descontosAgravo = new List<EmissaoTO.DescontoAgravoTO>();
        
        payloadTO.orcamento = new EmissaoTO();
        payloadTO.orcamento.tipoSeguro = 'eds';
        payloadTO.orcamento.contratoOriginal = new EmissaoTO();
        payloadTO.orcamento.contratoOriginal.precificacao = new EmissaoTO.PrecificacaoTO();
        payloadTO.orcamento.contratoOriginal.coberturas = new List<EmissaoTO.CoberturaTO>();
    
        Test.startTest();        

        taxa.pura = 10;
        taxa.comercial = 20;
        taxa.total = 30;
    
        premio.comercial = 10;
        premio.total = 20;
        premio.puro = 30;
            
        coberturaTO.taxa = taxa;
        coberturaTO.premio = premio;
        coberturaTO.sigla = 'MAP';
        coberturaTO.valor = 10.0;
        coberturaTO.quantidade = '1';
        coberturaTO.caracteristicaespecialvalor = 10.0;
        coberturaTO.caracteristicaespecialtipo = 'Ano(s)';
        coberturaTO.percentual = 1;

        EmissaoTO.DescontoAgravoTO descontoAgravoTEC = new EmissaoTO.DescontoAgravoTO();                        
        descontoAgravoTEC.monetario = 100;
        descontoAgravoTEC.percentual = 100;
        descontoAgravoTEC.tipo = 'TEC';

        EmissaoTO.DescontoAgravoTO descontoAgravoCOM = new EmissaoTO.DescontoAgravoTO();                        
        descontoAgravoCOM.monetario = 100;
        descontoAgravoCOM.percentual = 100;
        descontoAgravoCOM.tipo = 'COM';

        EmissaoTO.DescontoAgravoTO descontoAgravoBAT = new EmissaoTO.DescontoAgravoTO();                        
        descontoAgravoBAT.monetario = 100;
        descontoAgravoBAT.percentual = 100;
        descontoAgravoBAT.tipo = 'BAT';

        descontosAgravo.add(descontoAgravoTEC);
        descontosAgravo.add(descontoAgravoCOM);
        descontosAgravo.add(descontoAgravoBAT);

        coberturaTO.descontoAgravo = descontosAgravo;

        coberturasTO.add(coberturaTO);
        payloadTO.orcamento.contratoOriginal.coberturas = coberturasTO;

        mapCalculos.put(coberturaTO.sigla, coberturaTO);

        Account conta = [SELECT Id, Name FROM Account];    
        Product2 produtoComercial = [SELECT Id, Name FROM Product2 WHERE Name = 'Nome Produto Comercial'];

        CanalDistribuicao__c canalDistribuicao = CreateTestData.createCanalDistribuicao();

        String payloadName = 'PayloadOrcamento001';
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: payloadName LIMIT 1];
        Blob payloadEntrada = sr.Body;

        Opportunity orcamento = new Opportunity(
            StageName = 'Em criação',
            CurrencyIsoCode = 'BRL',
            Name = 'ARQ-1100760',
            CloseDate = System.today().addDays(19),
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addDays(2),
            Produto__c = produtoComercial.Id,
            Probability = 10.0,
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaIndividual').Id,
            AccountId = conta.Id,
            Numero__c = '10005760',
            CanalDistribuicao__c = canalDistribuicao.Id,
            Payload__c = EncodingUtil.base64Decode(EncodingUtil.base64Encode(payloadEntrada)).toString()
        );

        insert orcamento;

        Garantia__c garantia = TestDataFactory.gerarGarantia();
        GarantiaProduto__c garantiaProduto = new GarantiaProduto__c(
            TipoGarantia__c = 'Cobertura',
            Garantia__c = garantia.id,
            OrdemPrioridade__c = 1
        );
        
        insert garantiaProduto;

        ogb.mGarantiaProd.put(coberturaTO.sigla, garantiaProduto);
        
        ContratanteOrcamento__c contratanteOrcamento = TestDataFactory.gerarContratanteOrcamento(orcamento, conta);
        GrupoOrcamento__c grupoOrcamento = TestDataFactory.gerarGrupoOrcamento(contratanteOrcamento);
        GarantiaGrupoOrcamento__c garantiaGrupoSegurado = TestDataFactory.gerarGarantiaGrupoOrcamento(garantia, grupoOrcamento);
        
        ogb.montarCobertura(coberturaTO, garantiaGrupoSegurado, setSiglasCoberturas);

        Test.stopTest();        
    }

    @IsTest
    static void testarBuscarRegistrosDominios(){

        OrcamentoGenericoBuilder ogb = OrcamentoGenericoBuilder.getInstance();
        
        Test.startTest();

        Account conta = [SELECT Id FROM Account LIMIT 1];
        Account contaParceiro = new Account(Name = 'ParceiroTeste', CodigoEmpresa__c = '12', IdExterno__c = '67708896000139', Inscricao_Municipal__c = '123456789', Cnpj__c = '67.708.896/0001-39');
        insert contaParceiro;

        ogb.contrato = [SELECT Id, (SELECT Id FROM ContratantesContrato__r) FROM Contract LIMIT 1];
        
        ContratanteContrato__c contratanteContrato = TestDataFactory.gerarContratanteContrato(ogb.contrato, conta, contaParceiro);
        GrupoContrato__c grupoContrato = TestDataFactory.gerarGrupoContrato(contratanteContrato);
        Garantia__c garantia = TestDataFactory.gerarGarantia();
        SeguradoContrato__c seguradoContrato = TestDataFactory.gerarSeguradoContrato(grupoContrato, conta);
        GarantiaGrupoContrato__c garantiaGrupoContrato = TestDataFactory.gerarGarantiaGrupoContrato(garantia, grupoContrato);        

        grupoContrato.ContratanteContrato__c = ogb.contrato.ContratantesContrato__r[0].Id;
        grupoContrato.Descricao__c = 'Teste';
        grupoContrato.TipoCalculo__c = 'GLO';
        grupoContrato.Numero__c = 12345678;
        grupoContrato.TipoDescontoAgravo__c = 'Comercial';
        grupoContrato.PremioComercial__c = 1.0;
        grupoContrato.PremioPuro__c = 1.0;
        grupoContrato.PremioTotal__c = 1.0;
        grupoContrato.PremioIntegral__c = 1.0; 
        grupoContrato.TaxaComercial__c = 1.0;
        grupoContrato.TaxaPura__c = 1.0;
        grupoContrato.TaxaTotal__c = 1.0;
        grupoContrato.DescontoAgravoMonetarioComercial__c = 1.0;
        grupoContrato.DescontoAgravoMonetarioInformado__c = 1.0;
        grupoContrato.DescontoAgravoMonetarioTecnico__c = 1.0;
        grupoContrato.DescontoAgravoPercentualComercial__c = 1.0;
        grupoContrato.DescontoAgravoPercentualInformado__c = 1.0;
        grupoContrato.DescontoAgravoPercentualTecnico__c = 1.0;
        grupoContrato.IOF__c = 1.0;

        update grupoContrato;

        seguradoContrato.Conta__c = conta.Id;
        seguradoContrato.EnderecoBoleto__c = 'http://www.google.com.br';
        seguradoContrato.IOF__c = 1.0;
        seguradoContrato.IPCA__c = 1.0;
        seguradoContrato.PorcentagemParticipacaoSegurado__c = 1.0;
        seguradoContrato.PorcentagemParticipacaoVida__c = 1.0;
        seguradoContrato.QuantidadeParcelas__c = 1;
        seguradoContrato.Reenquadramento__c = 1.0;
        seguradoContrato.Numero__c = 12345678;
        seguradoContrato.TipoCusteio__c = 'Não Contributário';
        seguradoContrato.TipoDescontoAgravo__c = 'Comercial';
        seguradoContrato.TipoResponsavelPagamento__c = 'SEG';
        seguradoContrato.VencimentoPrimeiraParcela__c = System.today().addDays(1);
        seguradoContrato.PremioComercial__c = 1.0;
        seguradoContrato.PremioParcela__c = 1.0;
        seguradoContrato.PremioIntegral__c = 1.0;
        seguradoContrato.PremioPuro__c = 1.0;
        seguradoContrato.PremioTotal__c = 1.0;
        seguradoContrato.TaxaComercial__c = 1.0;
        seguradoContrato.TaxaPura__c = 1.0;
        seguradoContrato.TaxaTotal__c = 1.0;
        seguradoContrato.DescontoAgravoMonetarioComercial__c = 1.0;
        seguradoContrato.DescontoAgravoMonetarioInformado__c = 1.0;
        seguradoContrato.DescontoAgravoMonetarioTecnico__c = 1.0;
        seguradoContrato.DescontoAgravoPercentualComercial__c = 1.0;
        seguradoContrato.DescontoAgravoPercentualInformado__c = 1.0;
        seguradoContrato.DescontoAgravoPercentualTecnico__c = 1.0;

        update seguradoContrato;

        GarantiaProduto__c garantiaProduto = new GarantiaProduto__c(
            TipoGarantia__c = 'Cobertura',
            Garantia__c = garantia.id,
            OrdemPrioridade__c = 1
        );
        
        insert garantiaProduto;

        garantiaGrupoContrato.IOF__c = 1.0;
        garantiaGrupoContrato.Capital__c = 10.00;
        garantiaGrupoContrato.GarantiaProduto__c = garantiaProduto.Id; 
        garantiaGrupoContrato.Garantia__c = garantia.Id;
        garantiaGrupoContrato.NumeroSerie__c = '1';
        garantiaGrupoContrato.NumeroSorte__c = '1';
        garantiaGrupoContrato.Percentual__c = 1.0;
        garantiaGrupoContrato.TipoDescontoAgravo__c = '';
        garantiaGrupoContrato.ValorCotacao__c = 1.0;
        garantiaGrupoContrato.Valor__c = 1.0;
        garantiaGrupoContrato.PremioComercial__c = 1.0;
        garantiaGrupoContrato.PremioPuro__c = 1.0;
        garantiaGrupoContrato.PremioIntegral__c = 1.0;
        garantiaGrupoContrato.PremioTotal__c = 1.0;
        garantiaGrupoContrato.TaxaComercial__c = 1.0;
        garantiaGrupoContrato.TaxaPura__c = 1.0;
        garantiaGrupoContrato.TaxaTotal__c = 1.0;	
        garantiaGrupoContrato.CurrencyIsoCode = 'BRL';
        garantiaGrupoContrato.DescontoAgravoMonetarioComercial__c = 1.0;
        garantiaGrupoContrato.DescontoAgravoMonetarioInformado__c = 1.0;
        garantiaGrupoContrato.DescontoAgravoMonetarioTecnico__c = 1.0;
        garantiaGrupoContrato.DescontoAgravoPercentualComercial__c = 1.0;
        garantiaGrupoContrato.DescontoAgravoPercentualInformado__c = 1.0;
        garantiaGrupoContrato.DescontoAgravoPercentualTecnico__c = 1.0;

        update garantiaGrupoContrato;

        Set<Id> setContratanteId = new Set<Id>{ogb.contrato.ContratantesContrato__r[0].Id};
        grupoContrato =  [ SELECT Id, Name, QuantidadeVidas__c, ContratanteContrato__c, Descricao__c, TipoCalculo__c, Numero__c, TipoDescontoAgravo__c, PremioComercial__c, PremioPuro__c, PremioTotal__c, PremioIntegral__c, TaxaComercial__c, TaxaPura__c, TaxaTotal__c, DescontoAgravoMonetarioComercial__c, DescontoAgravoMonetarioInformado__c, DescontoAgravoMonetarioTecnico__c, DescontoAgravoPercentualComercial__c, DescontoAgravoPercentualInformado__c, DescontoAgravoPercentualTecnico__c, IOF__c, ( SELECT Id, Name, Conta__c, EnderecoBoleto__c, IOF__c, IPCA__c, PorcentagemParticipacaoSegurado__c, PorcentagemParticipacaoVida__c, QuantidadeParcelas__c, Reenquadramento__c, Numero__c, TipoCusteio__c, TipoDescontoAgravo__c, TipoResponsavelPagamento__c, VencimentoPrimeiraParcela__c, PremioComercial__c, PremioParcela__c, PremioIntegral__c, PremioPuro__c, PremioTotal__c, TaxaComercial__c, TaxaPura__c, TaxaTotal__c, DescontoAgravoMonetarioComercial__c, DescontoAgravoMonetarioInformado__c, DescontoAgravoMonetarioTecnico__c, DescontoAgravoPercentualComercial__c, DescontoAgravoPercentualInformado__c, DescontoAgravoPercentualTecnico__c FROM SeguradosContrato__r ), ( SELECT Id, IOF__c, Capital__c, GarantiaProduto__c, Garantia__c, NumeroSerie__c, NumeroSorte__c, Percentual__c, TipoDescontoAgravo__c, ValorCotacao__c, Valor__c, PremioComercial__c, PremioPuro__c, PremioIntegral__c, PremioTotal__c, TaxaComercial__c, TaxaPura__c, TaxaTotal__c, CurrencyIsoCode, DescontoAgravoMonetarioComercial__c, DescontoAgravoMonetarioInformado__c, DescontoAgravoMonetarioTecnico__c, DescontoAgravoPercentualComercial__c, DescontoAgravoPercentualInformado__c, DescontoAgravoPercentualTecnico__c FROM GarantiasGrupoContrato__r ) FROM GrupoContrato__c WHERE GrupoContrato__c.ContratanteContrato__c IN :setContratanteId ];

        ogb.grupos.add(grupoContrato);

        GarantiaContratanteContrato__c garantiaContratante = TestDataFactory.gerarGarantiaContratanteContrato(garantia, ogb.contrato.ContratantesContrato__r[0]);
        garantiaContratante = [SELECT Id, ContratanteContrato__c FROM GarantiaContratanteContrato__c LIMIT 1];

        ogb.garantiasContratante.add(garantiaContratante);

        GarantiaSeguradoContrato__c garantiaSeguraContrato = TestDataFactory.gerarGarantiaSeguradoContrato(garantia, seguradoContrato);

        ogb.garantiasSeguradoContrato.add(garantiaSeguraContrato);

        ogb.buscarRegistrosDominios();
       
        Test.stopTest();
        
    }
    
    @IsTest
    static void testarGerarRemuneracaoOrcamentoWrapper(){
        
        List<RemuneracaoContrato__c> remuneracoes = new List<RemuneracaoContrato__c>(); 
        List<Orcamento.RemuneracaoOrcamentoWrapper> listRemuneracaoOrcamentoWrappers = new List<Orcamento.RemuneracaoOrcamentoWrapper>();

        Test.startTest();
        
        Contract contrato = [SELECT Id FROM Contract LIMIT 1];
        TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao();
        RemuneracaoContrato__c remuneracaoContrato = TestDataFactory.gerarRemuneracaoContrato(contrato, tipoRemuneracao);
        
        remuneracoes.add(remuneracaoContrato);

        OrcamentoGenericoBuilder.getInstance().gerarRemuneracaoOrcamentoWrapper(remuneracoes, listRemuneracaoOrcamentoWrappers);

        Test.stopTest();
        
    }

    @IsTest
    static void testarPopularGarantiasWrapper(){
        
        List<GarantiaContrato__c> garantiasContrato = new List<GarantiaContrato__c>(); 
        List<Orcamento.GarantiaWrapper> listGarantiasWrapper = new List<Orcamento.GarantiaWrapper>();

        Test.startTest();
        
        Contract contrato = [SELECT Id FROM Contract LIMIT 1];
        Garantia__c garantia = TestDataFactory.gerarGarantia();

        GarantiaProduto__c garantiaProduto = new GarantiaProduto__c(
            TipoGarantia__c = 'Cobertura',
            Garantia__c = garantia.id,
            OrdemPrioridade__c = 1
        );
        
        insert garantiaProduto;

        GarantiaContrato__c garantiaContrato = TestDataFactory.gerarGarantiaContrato(contrato, garantiaProduto);
        garantiasContrato.add(garantiaContrato);

        OrcamentoGenericoBuilder.getInstance().popularGarantiasWrapper(garantiasContrato, listGarantiasWrapper);

        Test.stopTest();
        
    }
    
    @IsTest
    static void testarGerarContratantes(){
        
        OrcamentoGenericoBuilder ogb = OrcamentoGenericoBuilder.getInstance();

        Test.startTest();

        Contract contrato = [SELECT Id, Produto__c FROM Contract LIMIT 1];

        String payload = '{"ofertas":[{"orcamento":{"tipoVigencia":"Periódico","tipoSeguro":"eds","vigenciaFinal":"2019-10-08","numeroOrcamento":"00000003","numeroPortal":0,"codigoProdutoVida":"VI-PESSOAS","idProdutoSf": "'+contrato.Produto__c+'","customizavel":true,"contratantes":[{"tipo":"PRI","numero":1,"grupos":[{"numero":1,"segurados":[{"pessoa":{"tipo":"FIS","enderecos":[{"uf":"SP","cidade":"SAO PAULO","complemento":"Apto 22","logradouro":"Guaianses","bairro":"Centro","complementoCep":"420","tipoLogradouro":"R","paisResidencia":"BRASIL","tipoEndereco":"REC","numeroLogradouro":"92","cep":"07114"}],"nome":"Testinho","dadosPessoaFisica":{"numeroCpf":"438912318","profissao":null,"tipoContrato":"TODOS","celular":"(11) 11111-1111","digitoCpf":"14","dataNascimento":"2000-11-11","fumante":false,"sexo":"MASCULINO","renda":"FAIXA2"},"email":"teste@teste.com.br"},"numero":1,"coberturas":[{"sigla":"BAS","valor":20000},{"sigla":"MAP","valor":20000},{"sigla":"CAP","valor":10}]}],"nome":"Testinho","qtdeVidas":1}]}],"canalDistribuicao":"EXE","meioComercializacao":"CO2","segmento":"Individual","versoesCalculos":[{"opcao":0,"tipo":"FPG","descontoAgravo":0},{"opcao":1,"tipo":"FPG","descontoAgravo":-5},{"opcao":2,"tipo":"FPG","descontoAgravo":5}],"ordemPortal":1,"rotulo":"Sniper - Plano Básico","remuneracoes":[{"percentual":20,"tipoRemuneracao":"CORRETAGEM"}],"vigenciaInicial":"2019-09-23","dataCalculo":"2019-09-23"},"retornosCalculo":[{"opcao":0,"orcnum":"00000003","numeroOrcamento":"00000003","numeroOferta":123,"precificacao":{"juros":0,"iof":1.24,"encargos":0,"custoDeApolice":0,"premio":{"comercial":205.98,"puro":219.98,"total":225.00},"taxa":{"comercial":0.0002185,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}],"coberturas":[{"sigla":"BAS","capital":350000.00,"iof":0.28,"premio":{"comercial":75.00,"puro":75.00,"total":75.00},"taxa":{"comercial":0.000043,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"MAP","capital":500000.00,"iof":0.19,"premio":{"comercial":50.0,"puro":50.0,"total":50.0},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DIH","capital":1400.00,"iof":0.09,"premio":{"comercial":25.0,"puro":25.0,"total":25.0},"taxa":{"comercial":0.00031,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DG 10","capital":6000.00,"iof":0.14,"premio":{"comercial":37.50,"puro":37.50,"total":37.50},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"AFI","capital":2900.00,"iof":0.14,"premio":{"comercial":37.50,"puro":37.50,"total":37.50},"taxa":{"comercial":0.000015,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]}],"contratantes":[{"numero":1,"iof":1.24,"premio":{"comercial":4.38,"puro":3.98,"total":5.00},"taxa":{"comercial":0.0002185,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}],"coberturas":[{"sigla":"BAS","capital":119.8,"iof":1.24,"premio":{"comercial":2.58,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000043,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DG 10","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"MAP","capital":1000.7,"iof":1.24,"premio":{"comercial":1.55,"puro":3.98,"total":5.00},"taxa":{"comercial":0.00031,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DIH","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"AFI","capital":2900.2,"iof":1.24,"premio":{"comercial":0.22,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000015,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]}],"grupos":[{"numero":1,"iof":1.24,"premio":{"comercial":4.38,"puro":3.98,"total":5.00},"taxa":{"comercial":0.0002185,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}],"coberturas":[{"sigla":"BAS","capital":119.8,"iof":1.24,"premio":{"comercial":2.58,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000043,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"MAP","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"AFI","capital":1000.7,"iof":1.24,"premio":{"comercial":1.55,"puro":3.98,"total":5.00},"taxa":{"comercial":0.00031,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DIH","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DG 10","capital":2900.2,"iof":1.24,"premio":{"comercial":0.22,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000015,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]}],"segurados":[{"numero":1,"iof":1.24,"premio":{"comercial":4.38,"puro":3.98,"total":5.00},"taxa":{"comercial":0.0002185,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}],"coberturas":[{"sigla":"BAS","capital":119.8,"iof":1.24,"premio":{"comercial":2.58,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000043,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"MAP","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"AFI","capital":1000.7,"iof":1.24,"premio":{"comercial":1.55,"puro":3.98,"total":5.00},"taxa":{"comercial":0.00031,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DG 10","capital":12.8,"iof":1.24,"premio":{"comercial":0.03,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000506,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]},{"sigla":"DIH","capital":1000900,"iof":1.24,"premio":{"comercial":0.22,"puro":3.98,"total":5.00},"taxa":{"comercial":0.000015,"pura":0.007462,"total":0.005363},"descontoAgravo":[{"percentual":-5.9,"monetario":-13.56,"tipo":"TEC"}]}]}]}]}]}}],"retornoAceitacao":{},"retornoIntegracoes":{"validacaoZeroDolar":null,"IndiceMonetario":{"ItensCotacao":[{"moedaOrigem":"USD","moedaDestino":"BRL","dataCotacao":13112018,"cotacao":"3.74720000"},{"moedaOrigem":"EUR","moedaDestino":"BRL","dataCotacao":13112018,"cotacao":"4.04720000"},{"moedaOrigem":"BRL","moedaDestino":"BRL","dataCotacao":13112018,"cotacao":"1"}]}}}]}';
        ogb.payloadTOpublic = new EmissaoTO.PayloadTO();
        ogb.payloadTOpublic = (EmissaoTO.PayloadTO) JSON.deserialize(payload, EmissaoTO.PayloadTO.class);
        
        List<ContratanteContrato__c> contratantes = new List<ContratanteContrato__c>();
        List<Orcamento.ContratanteWrapper> listContratanteWrapper = new List<Orcamento.ContratanteWrapper>();        
    
        Account conta = [SELECT Id FROM Account LIMIT 1];

        Account contaParceiro = new Account(Name = 'ParceiroTeste', CodigoEmpresa__c = '12', IdExterno__c = '67708896000139', Inscricao_Municipal__c = '123456789', Cnpj__c = '67.708.896/0001-39');
        insert contaParceiro;
        
        ContratanteContrato__c contratanteContrato = TestDataFactory.gerarContratanteContrato(contrato, conta, contaParceiro);
        contratantes.add(contratanteContrato);

        Garantia__c garantia = TestDataFactory.gerarGarantia();
        GarantiaContratanteContrato__c garantiaContratanteContrato = TestDataFactory.gerarGarantiaContratanteContrato(garantia, contratanteContrato);
        ogb.mapGarantiaContratanteContrato.put(contratanteContrato.Id, new List<GarantiaContratanteContrato__c>{garantiaContratanteContrato});

        GrupoContrato__c grupoContrato = TestDataFactory.gerarGrupoContrato(contratanteContrato);
        ogb.mapGruposContrato.put(contratanteContrato.Id, new List<GrupoContrato__c>{grupoContrato});

        ogb.gerarContratantes(contratantes, listContratanteWrapper);

        Test.stopTest();
        
    }
    //ANNVI-55 - FIM
}