@isTest
public class TestBCPNaoClientes {
    public TestBCPNaoClientes() {

    }

    @TestSetup
    static void setup(){
        
        TestDataFactory.gerarDadosSetup();
        //PLV-3746 - INICIO
        SenhaCriptografia__c sCripto = new SenhaCriptografia__c();
        sCripto.Name = 'Senha';
        sCripto.Senha__c = 'TesteCrypto';
        insert sCripto;
        //PLV-3746 - FIM
        
    }

    @isTest
    static void teste1() {


        Account contaTeste = TestDataFactory.gerarConta();
        contaTeste.Rg__c = '12321312';
        contaTeste.Phone = '12321312';
        update contaTeste;
        Endereco__c endereco = TestDataFactory.gerarEndereco(contaTeste);
        endereco.TipoEndereco__c = 'Residencial';
        endereco.Maisatual__c = true;
        update endereco;
        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);
        Garantia__c garantia = TestDataFactory.gerarGarantia();
        //PLV - 4250 inicio
        Garantia__c garantiaCobertura = TestDataFactory.gerarGarantia();
        garantiaCobertura.name = 'Produto Porto';
        update garantiaCobertura;
        //PLV - 4250 fim
        RamoGarantia__c ramoGarantia = TestDataFactory.gerarRamoGarantia(garantia, ramoSegurado);
        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        produtoTec.Status__c = 'Ativo';
        update produtoTec;
        Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        Map<String,List<SObject>> mapListSObject = TestDataFactory.gerarProdutoComercialAtivo(false);
        produtoCom.Status__c ='ativo';
        update produtoCom;
        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        canalDistribuicao.Status__c = 'Ativo';
        update canalDistribuicao;
        ProdutoCanal__c produtoCanal = TestDataFactory.gerarProdutoCanal(canalDistribuicao, produtoCom);
        FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento();
        Parceiro__C parceiro = TestDataFactory.gerarParceiro(contaTeste, formaPagamento);
        ProdutoParceiro__c produtoParceiro = TestDataFactory.gerarProdutoParceiro(parceiro, produtoCom);
        Opportunity opp = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);
        TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao('COR', 100, 200, null);
        InformacaoBancaria__c InformacaoBancaria = TestDataFactory.gerarInformacaoBancaria(contaTeste);
        RemuneracaoProdutoParceiro__c RemuneracaoProdutoParceiro = TestDataFactory.gerarRemuneracaoProdutoParceiro(tipoRemuneracao, produtoParceiro, 20);
        FavorecidoRemuneracao__c favorecidoRemuneracao = TestDataFactory.gerarFavorecidoRemuneracao(contaTeste, 20.00, 'Corretor', true, remuneracaoProdutoParceiro,dadosCorretor, informacaoBancaria);        
        system.debug('favorecidoRemuneracao: '+favorecidoRemuneracao.RemuneracaoProdutoParceiro__c); 
        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);
        Quote cot = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, opp, modalidade);

        cot.status = 'Devolvida';
        cot.isAPI__c = true;//PLV-5022 - INICIO/FIM
        update cot;

        List<Quote> propostas = new List<Quote>();
        propostas.add(cot);
        /* MGRC-504 - INICIO
        QuoteBO.getInstance().integrarNaoClienteBCP(propostas);
        BCPNaoClientes bcpTO = new BCPNaoClientes();
        bcpTO.adicionaPessoaNaoClienteRequest                     = new BCPNaoClientes.AdicionaPessoaNaoClienteRequest();
        bcptO.adicionaPessoaNaoClienteRequest.codigoOrigemMovimento = 32;
        bcptO.adicionaPessoaNaoClienteRequest.dataHoraMovimento = String.valueOf(System.today());
        bcptO.adicionaPessoaNaoClienteRequest.grupoXml = 4;
        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO = new BCPNaoClientes.PessoaNaoClienteEBO();
        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.estadoCivil = new BCPNaoClientes.EstadoCivil();
        //bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.carteiraNacionalHabilitacaoPessoa = new BCPNaoClientes.CarteiraNacionalHabilitacaoPessoa ();
        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.CarteiraIdentidadePessoa = new BCPNaoClientes.CarteiraIdentidadePessoa();
        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.contasBancaria = new List<BCPNaoClientes.ContasBancaria>();
        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.enderecosPessoa = new List<BCPNaoClientes.EnderecosPessoa>();
        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.telefonesPessoa = new List<BCPNaoClientes.TelefonesPessoa>();
        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.enderecosEletronicosPessoa = new List<BCPNaoClientes.EnderecosEletronicosPessoa>();
        bcpTo.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.vinculoPessoaPoliticamenteExposta = new BCPNaoClientes.VinculoPessoaPoliticamenteExposta();
        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.cpfPessoa = new BCPNaoClientes.CpfPessoa();
        
        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.cpfPessoa.digitoCpf = '123456789';
        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.cpfPessoa.numeroRaizCpf = '10';
        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.vinculoPessoaPoliticamenteExposta.codigoPessoaLocalFuncaoPessoaPoliticamenteExposta = 'CargoPEP';
        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.vinculoPessoaPoliticamenteExposta.codigoPessoaPoliticamenteExposta = 'PESCOD';
        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.vinculoPessoaPoliticamenteExposta.nomePessoaPoliticamenteExposta = 'Nome PEP';
        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.vinculoPessoaPoliticamenteExposta.codigoTipoVinculoPessoaPoliticamenteExposta = 'Fisica';
        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.vinculoPessoaPoliticamenteExposta.codigoVinculoPessoaPoliticamenteExposta = '1';
        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.vinculoPessoaPoliticamenteExposta.nomeOrgaoGovernamentalPessoaPoliticamenteExposta = 'CargoPEP';
        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.vinculoPessoaPoliticamenteExposta.digitoCpfPessoaPoliticamenteExposta = '123456789';
        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.vinculoPessoaPoliticamenteExposta.numeroRaizCpfPessoaPoliticamenteExposta = '10'; 
        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.codigoProduto = 'VIDA';
        BCPNaoClientes.enderecosEletronicosPessoa emailCliente = new BCPNaoClientes.EnderecosEletronicosPessoa();
        emailCliente.textoEnderecoEletronicoPessoa = 'teste@email.com';
        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.enderecosEletronicosPessoa.add(emailCliente);
        BCPNaoClientes.EnderecosPessoa endResidencial = new BCPNaoClientes.EnderecosPessoa();
        endResidencial.flagImovelSemNumero = '1';
        endResidencial.numeroImovelLogradouroEndereco = 'rua teste 123';
        endResidencial.descricaoComplementoEndereco = '123';
        endResidencial.codigoTipoFinalidadeEndereco = 1;
        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.enderecosPessoa.add(endResidencial);

            BCPNaoClientes.ContasBancaria conta = new BCPNaoClientes.ContasBancaria();
            conta.numeroBancoOficial = 1;
            conta.numeroAgenciaBancariaOficial = '123';
            conta.numeroContaBancariaPessoa = 1;
            conta.digitoContaBancariaPessoa = '2';
            bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.contasBancaria.add(conta);
        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.CarteiraIdentidadePessoa.codigoEstado = '123';
        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.CarteiraIdentidadePessoa.codigoOrgaoExpedidorDocumento = '123';
        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.CarteiraIdentidadePessoa.dataExpedicaoCarteiraIdentidade = System.today();
        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.CarteiraIdentidadePessoa.digitoCarteiraIdentidade = 123;
        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.CarteiraIdentidadePessoa.numeroRaizCarteiraIdentidade = 1;
            BCPNaoClientes.TelefonesPessoa telResidencial = new BCPNaoClientes.TelefonesPessoa();
            telResidencial.codigoDdd = 33;
            telResidencial.codigoTelefone = 'Residencial';
            telResidencial.numeroTelefone = 12312323;
            bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.telefonesPessoa.add(telResidencial);
        
        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.codigoSexo = 'Masc';
        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.codigoTipoPessoa = 'Fisica';
        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.estadoCivil.codigoEstadoCivil = 'estado';
        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.textoPrenomePessoa = 'Nome';
        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.textoNomeIntermediarioPessoa = 'nome2';
        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.textoUltimoNomePessoa = 'nome3';
        //bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.carteiraNacionalHabilitacaoPessoa.dataExpedicaoCnh = Date.valueOf(cliente.DataExpedicao__c);
        //if(cliente.DocIndentificacao__c != '' && cliente.DocIndentificacao__c != null){
        //    Integer identificacao = Integer.valueOf(cliente.DocIndentificacao__c.replace('-','').replace('.',''));
        //    bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.carteiraNacionalHabilitacaoPessoa.numeroCnh = identificacao;
        //    bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.carteiraNacionalHabilitacaoPessoa.numeroRegistroCnhPessoa = identificacao;    
        //}
        
        // System.debug('karin');
        // System.debug(JSON.serialize(bcpTO, true));
        // // proposta.IntegrouNaoClienteBCP__c = true;
        // QuoteBO.integrarNaoClientesBCPFuture(JSON.serialize(bcpTO, true));
    }
    
    // PLV-4921 INICIO
	@isTest
    static void teste2(){
        BCPNaoClientes.parse('{}');
    }
    // PLV-4921 FIM
    
    MGRC-504 - FIM   */
   }
}