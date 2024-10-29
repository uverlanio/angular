/**************************************************************************************************************************************************************************
 *
 *  Classe responsável por gerar dados de teste para serem ulizados pelas classe de testes
 *
 **************************************************************************************************************************************************************************/

public class TestDataFactory
{

    //Gera registros que devem ser gerados pelo setup das classes de test
    public static void gerarDadosSetup()
    {
        List<ContadorCodigo__c> contadoresProduto = new List<ContadorCodigo__c>
        {
            new ContadorCodigo__c(Name='ProdutoTecnico', Numero__c = 0),
            new ContadorCodigo__c(Name='ProdutoComercial', Numero__c = 0)
        };

        insert contadoresProduto;
        
        //PLV-3460 Fix 5 - INICIO
	    QueueableQTD__c qtdRecordDetails = (QueueableQTD__c) new QueueableQTDFactory().createRecord();
        QueueableQTD__c qtdRecordSend = qtdRecordDetails.clone();
        qtdRecordSend.Name = 'QueueableContractDetails';
        qtdRecordSend.Quantidade__c = 20;
        insert qtdRecordSend;
        //PLV-3460 Fix 5 - FIM
    }
    
    //PLV-3744 - INICIO
    public static SenhaCriptografia__c Token(){
         SenhaCriptografia__c sCripto = new SenhaCriptografia__c();
         sCripto.Name = 'Senha';
         sCripto.Senha__c = 'TesteCrypto';
         insert sCripto;
         return sCripto;
    }
    //PLV-3744 - FIM

    // Gera conta
    public static Account gerarConta()
    {
        Account contaTeste = new Account(
                Name = 'Conta 14',
                CodigoEmpresa__c = '214',
                IdExterno__c = '86234154000',
                Papel__c = 'Parceiro',
                Sexo__c = 'Masc',
                Cpf__c = '86234154000',
                Pis__c = '123456789', // PLV-4445
                Cnpj__c = '88.327.868/0001-41',
                Inscricao_Municipal__c = '123456789', // PLV-4445
                Nacionalidade__c = 'Brasileira',
                EstadoCivil__c = 'Casado (a)',
                Email__c = 'teste2@teste.com.br'
                // PLV-2335 - Inicio - RollBack
                // PLV-2335 - Fim
        );
        upsert contaTeste IdExterno__c;

        return contaTeste;
    }

    // Gera conta
    public static Account gerarConta(String codigoEmpresa)
    {
        Account contaTeste = new Account(
                Name = 'Conta 41',
                CodigoEmpresa__c = codigoEmpresa,
                IdExterno__c = '13143510000160',
                Papel__c = 'Parceiro',
                Sexo__c = 'Masc',
                // Cpf__c = '76466318095', // original
                Cpf__c = '79255953885', // expurgo
                Pis__c = '123456789', // PLV-4445
                // Cnpj__c = '13.143.510/0001-60', // original
                Cnpj__c = '62.934.217/0001-26', // expurgo
                Inscricao_Municipal__c = '123456789', // PLV-4445
                Nacionalidade__c = 'Brasileira',
                EstadoCivil__c = 'Casado (a)',
                Email__c = 'teste@teste.com.br'
        );
        insert contaTeste;

        return contaTeste;
    }

    public static Endereco__c gerarEndereco(Account conta){
        Endereco__c endereco = new Endereco__c(
                CEP__c = '09876123',
                Cidade__c = 'São Paulo',
                Conta__c = conta.Id,
                Estado__c = 'SP',
                Logradouro__c = 'Rua Luar do Sertão',
                MaisAtual__c = true,
                Numero__c = '12',
                Pais__c = 'Brasil',
                TipoEndereco__c = 'Comercial',
                TipoLogradouro__c = 'Rua',
                Bairro__c = 'Jd. Nordeste'
                //IdExterno__c = conta.Id + '09876123' + 'Rua Luar do Sertão' + '12' + 'Comercial'
        );

        insert endereco;
        return endereco;
    }

    // Gera conta do corretor
    public static Account gerarCorretor(){
        // PLV-4472 INICIO
        Account contaCorretor = new Account(Name = 'Conta corretor', Papel__c = 'Corretor', Cnpj__c = '08.370.609/0001-64');
        // PLV-4472 FIM
        insert contaCorretor;
        return contaCorretor;
    }

    // Gera Parceiro Ativo
    public static Map<String,List<SObject>> gerarParceiroCompletoAtivo(Boolean deveGerarProduto){

        // Instancia do Map
        Map<String,List<SObject>> mapsObject = new Map<String, List<SObject>>();

        if(deveGerarProduto){
            mapsObject = TestDataFactory.gerarProdutoComercialAtivo(false);
        }

        Account contaParceiro = new Account(Name = 'ParceiroTeste', CodigoEmpresa__c = '12', IdExterno__c = '67708896000139', Inscricao_Municipal__c = '123456789', Cnpj__c = '67.708.896/0001-39'); // PLV-4445
        insert contaParceiro;

        // PLV-4472 INICIO
        Account contaCorretor = new Account(Name = 'ContaCorretor', Papel__c = 'Corretor', IdExterno__c = '38012786532', Cnpj__c = '38.579.897/0001-22');
        // PLV-4472 FIM
        insert contaCorretor;


        Product2 produtoComercial                   = [ SELECT Id, ProductCode, (SELECT Id, TipoRemuneracao__c, TipoRemuneracao__r.Id, TipoRemuneracao__r.Name, TipoRemuneracao__r.LimiteMinimo__c FROM RemuneracoesProduto__r) FROM Product2 WHERE RecordType.DeveloperName = 'ProdutoComercial' LIMIT 1 ];

        FormaPagamento__c formaPagamento            = TestDataFactory.gerarFormaPagamento();
        PlanoParcelamento__c gerarPlanoParcelamento = TestDataFactory.gerarPlanoParcelamento(formaPagamento.Id);
        Parceiro__c parceiro                        = TestDataFactory.gerarParceiro(contaParceiro,formaPagamento);
        List<CriticaParceiro__c> criticaParceiro    = TestDataFactory.gerarCriticasParceiro(parceiro.Id);
        ProdutoParceiro__c produtoParceiro          = TestDataFactory.gerarProdutoParceiro(parceiro, produtoComercial);
        RemuneracaoProdutoParceiro__c remuneracaoProdutoParceiro =
                TestDataFactory.gerarRemuneracaoProdutoParceiro(produtoComercial.RemuneracoesProduto__r[0].TipoRemuneracao__r, produtoParceiro, 10.0);

        remuneracaoProdutoParceiro          = [SELECT Id,TipoRemuneracao__c,TipoRemuneracao__r.Name FROM RemuneracaoProdutoParceiro__c WHERE Id =: remuneracaoProdutoParceiro.Id];
        Account conta                       = [SELECT Id,Name FROM Account  WHERE Papel__c = 'Corretor' LIMIT 1];

        DadosCorretor__c dadosCorretor = gerarDadosCorretor(conta);
        InformacaoBancaria__c informacaoBancaria = TestDataFactory.gerarInformacaoBancaria(conta);
        InformacaoBancaria__c informacaoBancariaParceiro = TestDataFactory.gerarInformacaoBancaria(contaParceiro);
        informacaoBancariaParceiro.Principal__c = true;
        update informacaoBancariaParceiro;

        FavorecidoRemuneracao__c favorecidoRemuneracao  = TestDataFactory.gerarFavorecidoRemuneracao(conta, 80.00, 'Corretor', true, remuneracaoProdutoParceiro,dadosCorretor, informacaoBancaria);
        FavorecidoRemuneracao__c favorecidoRemuneracao2 = TestDataFactory.gerarFavorecidoRemuneracao(conta, 20.00, 'Corretor', false, remuneracaoProdutoParceiro,dadosCorretor, informacaoBancaria);

        ParceiroBO.getInstance().ativarParceiro(parceiro.Id);

        // popula Map
        inserirSObject(mapsObject, 'Parceiro__c', parceiro);

        return mapsObject;
    }

    public static List<CriticaParceiro__c> gerarCriticasParceiro(Id parceiro)
    {
        List<CriticaParceiro__c> criticasParceiro = new List<CriticaParceiro__c>();

        CriticaParceiro__c c1               = new CriticaParceiro__c();
        c1.Parceiro__c                      = parceiro;
        c1.Rotulo__c                        = 'ConteudoInvalidoCampo';
        c1.IdentificacaoCampo__c            = '54';
        c1.Mensagem__c                      = 'Verifique as informações enSegurados no arquivo ( referente ao campo com problema ), corrija se for o caso e retransmita as informações no próximo arquivo';
        c1.Name                             = '54';

        criticasParceiro.add(c1);

        CriticaParceiro__c c2               = new CriticaParceiro__c();
        c2.Parceiro__c                      = parceiro;
        c2.Rotulo__c                        = 'ConteudoInvalidoCampo';
        c2.IdentificacaoCampo__c            = '45';
        c2.Mensagem__c                      = 'Verifique as informações enSegurados no arquivo ( referente ao campo com problema ), corrija se for o caso e retransmita as informações no próximo arquivo';
        c2.Name                             = '45';

        criticasParceiro.add(c2);

        CriticaParceiro__c c3               = new CriticaParceiro__c();
        c3.Parceiro__c                      = parceiro;
        c3.Rotulo__c                        = 'Emissão';
        c3.IdentificacaoCampo__c            = '0';
        c3.Mensagem__c                      = 'Contratação realizada com sucesso.';
        c3.Name                             = '0';

        criticasParceiro.add(c3);

        insert criticasParceiro;
        return criticasParceiro;
    }


    public static Fatura__c gerarFatura()
    {
        Fatura__c newFatura = new Fatura__c();

        newFatura.Apolice__c = '123456';
        newFatura.Empresa__c = '123456';
        newFatura.Conta__c = [SELECT Id FROM Account LIMIT 1][0].Id;
        newFatura.Sucursal__c = '123456';
        newFatura.Ramo__c = '123456';
        newFatura.CodigoProdutoComercial__c = '123456';
        newFatura.DataEmissao__c = System.today();
        newFatura.DataVencimento__c = System.today().addDays(30);
        newFatura.Endosso__c = '123456';
        newFatura.FinalCompetencia__c = System.today().addDays(30);
        newFatura.InicioCompetencia__c = System.today();
        newFatura.Origem__c = '123456';
        newFatura.Proposta__c = '123456';
        newFatura.TipoFatura__c = 'BatimentoContabil';
        newFatura.ValorIOF__c = 10;
        newFatura.ValorLiquido__c = 100;
        newFatura.ValorTotal__c = 110;
        newFatura.Status__c = 'Pendente';

        insert newFatura;
        return newFatura;

    }

    // Gera Parceiro
    public static Parceiro__c gerarParceiro(Account contaParceiro, FormaPagamento__c formaPagamento){
        Date hoje = System.today();
        Parceiro__c parceiro = new Parceiro__c(
                // EndossoFaturamento__c = String.valueOf(hoje.year()) + String.valueOf(hoje.month()) + String.valueOf(hoje.day()),
                ApoliceFaturamento__c = '1',
                DiaFaturamento__c = '15',
                DiaPreFaturamento__c = '20',
                PrazoVencimento__c = '10',
                Conta__c = contaParceiro.Id,
                FaturaProdutosSeparados__c = 'Sim',
                PossuiAnexoFatura__c = 'Nao',
                FormaPagamento__c = formaPagamento.Id,
                SiglaParceiro__c = 'PAR',
                Empresa__c = '12',
                Sucursal__c = '12',
                Ramo__c = '12'
        );
        insert parceiro;
        return parceiro;
    }

    // Gera Produto do Parceiro
    public static ProdutoParceiro__c gerarProdutoParceiro(Parceiro__c parceiro, Product2 produtoComercial){
        ProdutoParceiro__c produtoParceiro = new ProdutoParceiro__c(
                Produto__c = produtoComercial.Id,
                Parceiro__c = parceiro.Id,
                CodigoProdutoParceiro__c = produtoComercial.Id 
        );
        insert produtoParceiro;
        return produtoParceiro;
    }

    //Gera registro de forma de pagamento
    public static FormaPagamento__c gerarFormaPagamento(){
        FormaPagamento__c formaPagamento = new FormaPagamento__c(
                Codigo__c = 'BOL',
                Name = '3X'
        ); 

        insert formaPagamento;
        return formaPagamento;
    }

    //Gera registro de plano de parcelamento
    public static PlanoParcelamento__c gerarPlanoParcelamento(Id idFormaPagamento){
        PlanoParcelamento__c planoParcelamento = new PlanoParcelamento__c(
                CodigoMeioRecebimento__c = '1234',
                DescricaoMeioRecebimento__c = 'RECEBIMENTO-BOLETO REGISTRADO',
                FormaPagamento__c = idFormaPagamento,
                NumeroParcela__c = 1               
        );

        insert planoParcelamento;
        return planoParcelamento;
    }


    // Gera registro de caso
    // PLV-3460 Fix 5 - INICIO - Trecho comentado
    /*public static Case gerarCaso(Account conta, Contact contato){
        Case caso = new Case(
                Status = 'Aberto',
                Subject = 'Batida',
                ContactId = contato.Id,
                AccountId = conta.Id,
                Vitima__c = 'Segurado',
                TipoEvento__c = 'Viagem',
                Dataocorrencia__c = System.today(),
                Type = 'Sinistro'
        );
        insert caso;
        return caso;
    }*/
	//PLV-3460 Fix 5 - FIM


    //Gera registro de forma de pagamento
    public static FormaPagamento__c gerarFormaPagamento(RamoSeguro__c ramoSeguro, Modalidade__c modalidade, String name, String codigo){
        FormaPagamento__c formaPagamento = new FormaPagamento__c(
                Codigo__c = codigo,
                Name = name,
                RamoSeguro__c = ramoSeguro.Id,
                Modalidade__c = modalidade.Id
        );

        insert formaPagamento;
        return formaPagamento;
    }

    //Gera um produto técnico
    public static Product2 gerarProdutoTecnico(){
        Product2 produtoTec = new Product2(
                Name = 'Nome Produto Tecnico',
                Status__c = 'Em criação',
                ProductCode = '201700001',
                VigenciaInicial__c = System.today().addDays(3),
                TipoCapital__c = 'Capital uniforme',
                Segmento__c = 'Coletivo',
                TipoResponsavelPagamento__c = 'PAR',
                NumeroSusep__c = '12345',
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id,
                Versao__c                       = 1,
                VersaoMaxima__c                 = true,
                VersaoRenovacao__c              = 'Versão atual'
        );

        insert produtoTec;

        return produtoTec;
    }
    //VIAG-253 INICIO - KAYMON
    //Gera um produto técnico - viagem
    public static Product2 gerarProdutoTecnicoViagem(){
        Product2 produtoTec = new Product2(
            Name = 'Nome Produto Tecnico',
            Status__c = 'Em criação',
            ProductCode = '2017000012',
            VigenciaInicial__c = System.today().addDays(3),
            TipoCapital__c = 'Capital uniforme',
            Segmento__c = 'Viagem',
            TipoResponsavelPagamento__c = 'PAR',
            NumeroSusep__c = '12345',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id,
            Versao__c                       = 1,
            VersaoMaxima__c                 = true,
            VersaoRenovacao__c              = 'Versão atual'
        );
        insert produtoTec;
        produtoTec.Status__c = 'Ativo';
        update produtoTec;
        return produtoTec;
    }
    //Gera  garantia do produto tecnico
    public static GarantiaProduto__c gerarGarantiaProdutoTecnicoViagem(){
        Product2 produtoTec = gerarProdutoTecnicoViagem();
        Garantia__c garantia = gerarGarantias();
        Garantia__c garantiaType_2 = [SELECT Id FROM Garantia__c WHERE Sigla__c = 'DMHO' LIMIT 1];
        List<GarantiaProduto__c> GarantiaProdutoList = new List<GarantiaProduto__c>();
        GarantiaProduto__c garantiaProdutoTec = new GarantiaProduto__c(
            TipoGarantia__c = 'Cobertura',
            Garantia__c = garantia.Id,
            Produto__c = produtoTec.Id,
            OrdemPrioridade__c = 1,
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoTecnico').Id,
            TipoCapital__c = 'Capital uniforme',
            CodigoPromocao__c = 'VITST',
            VersaoTitulo__c = '1'
        );
        GarantiaProduto__c garantiaProdutoTec2 = new GarantiaProduto__c(
            TipoGarantia__c = 'Cobertura',
            Garantia__c = garantiaType_2.Id,
            Produto__c = produtoTec.Id,
            OrdemPrioridade__c = 1,
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoTecnico').Id,
            TipoCapital__c = 'Capital uniforme',
            CodigoPromocao__c = 'VITST',
            VersaoTitulo__c = '1'
        );
        GarantiaProdutoList.add(garantiaProdutoTec);
        GarantiaProdutoList.add(garantiaProdutoTec2);
        insert GarantiaProdutoList;
        return garantiaProdutoTec;
        }
    //VIAG-253 FIM - KAYMON

    //Gera um produto comercial
    public static Product2 gerarProdutoComericial(Product2 produtoTec){
        Product2 produtoCom = new Product2(
                ProdutoTecnico__c               = produtoTec.Id,
                Name                            = 'Nome Produto Comercial',
                Status__c                       = 'Em criação',
             
            //PLV2569 - INICIO AVX - Ajuste para aumentar cobertura de testes da classe OrcamentoGenericoBuilder.
            	ProductCode                    = '201700001',
                //ProductCode                      = 'SNIPER',
            //PLV2569 - FIM AVX - Ajuste para aumentar cobertura de testes da classe OrcamentoGenericoBuilder.    
            	
            VigenciaInicial__c              = System.today(),
                VigenciaFinal__c                = System.today().addDays(1),
                TipoCapital__c                  = 'Capital uniforme',
                Segmento__c                     = 'Coletivo',
                TipoResponsavelPagamento__c     = 'PAR',
                LimiteTotalCarregamento__c      = 200,
                NumeroSusep__c                  = '12345',
                RecordTypeId                    = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id,
                Versao__c                       = 1,
                VersaoMaxima__c                 = true,
                VersaoRenovacao__c              = 'Versão atual'
        );
        insert produtoCom;

        return produtoCom;
    }

    //AV-85 INICIO
    //Gera um produto comercial
    public static Product2 gerarProdutoComericialVidaON(Product2 produtoTec){
        Product2 produtoCom = new Product2(
            ProdutoTecnico__c               = produtoTec.Id,
            Name                            = 'VIAGEM_VIDA_ON',
            Status__c                       = 'Em criação',
            ProductCode                     = 'VIAGEM-PRATA',   
            VigenciaInicial__c              = System.today(),
            VigenciaFinal__c                = System.today().addDays(1),
            TipoCapital__c                  = 'Capital uniforme',
            Segmento__c                     = 'Viagem',
            TipoResponsavelPagamento__c     = 'SEG',
            LimiteTotalCarregamento__c      = 200,
            NumeroSusep__c                  = '15414.900476/2015-42',
            RecordTypeId                    = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id,
            Versao__c                       = 1,
            VersaoMaxima__c                 = true,
            VersaoRenovacao__c              = 'Versão atual'
        );
        insert produtoCom;

        return produtoCom;
    }
    //AV-85 FIM

    // Gera Canal de Distribuição
    public static CanalDistribuicao__c gerarCanalDistribuicao(){
        CanalDistribuicao__c canalDistribuicao = new CanalDistribuicao__c();
        canalDistribuicao.Name = 'Canal Distribuição Teste 001';
        canalDistribuicao.Status__c = 'Em ativação';
        canalDistribuicao.Sigla__c = 'EXE';
        insert canalDistribuicao;
        return canalDistribuicao;
    }

    // Gera Produto Canal
    public static ProdutoCanal__c gerarProdutoCanal(CanalDistribuicao__c canalDistribuicao, Product2 produtoCom){
        ProdutoCanal__c produtoCanal = new ProdutoCanal__c(
                CanalDistribuicao__c = canalDistribuicao.Id,
                Produto__c = produtoCom.Id
        );

        insert produtoCanal;
        return produtoCanal;
    }

    // Gera Remuneracao Canal
    public static RemuneracaoCanal__c gerarRemuneracaoCanal(ProdutoCanal__c produtoCanal, TipoRemuneracao__c tipoRemuneracao){
        RemuneracaoCanal__c remuneracaoCanal = new RemuneracaoCanal__c(
                ProdutoCanal__c = produtoCanal.Id,
                TipoRemuneracao__c = tipoRemuneracao.Id,
                LimiteMinimo__c = 10,
                LimiteMaximo__c = 49
        );

        insert remuneracaoCanal;
        return remuneracaoCanal;

    }

    // Gera Remuneração do produto
    public static RemuneracaoProduto__c gerarRemuneracaoProduto(Product2 produtoCom, TipoRemuneracao__c tipoRemuneracao){
        RemuneracaoProduto__c remuneracaoProdutoCom = new RemuneracaoProduto__c();
        remuneracaoProdutoCom.Produto__c = produtoCom.Id;
        remuneracaoProdutoCom.TipoRemuneracao__c = tipoRemuneracao.Id;
        remuneracaoProdutoCom.Obrigatoria__c = true;
        remuneracaoProdutoCom.LimiteMinimo__c = 10;
        remuneracaoProdutoCom.LimiteMaximo__c = 49;
        insert remuneracaoProdutoCom;
        return remuneracaoProdutoCom;
    }

    // Gera Condicao de Cobranca
    // PLV-3316 - INICIO
    public static CondicaoCobranca__c gerarCondicaoCobranca(Product2 produto, FormaPagamento__c formaPagamento){
        List <CondicaoCobranca__c> condicaoCobranca = new List <CondicaoCobranca__c>();
        // CondicaoCobranca__c a = new CondicaoCobranca__c(
        //         Produto__c = produto.Id,
        //         FormaPagamento__c = formaPagamento.Id,
        //         QuantidadeParcelas__c = '1;2'
        // );
        // CondicaoCobranca__c b = new CondicaoCobranca__c(
        //         Produto__c = produto.Id,
        //         FormaPagamento__c = formaPagamento.Id,
        //         QuantidadeParcelas__c = '3;4'
        // );
        CondicaoCobranca__c c = new CondicaoCobranca__c(
                Produto__c = produto.Id,
                FormaPagamento__c = formaPagamento.Id,
                QuantidadeParcelas__c = '1;2;3;4;5;6;7;8;9;10',
            	//PLV-3318 - INICIO
            	PercentualDescontoAgravo__c = 0
            	//PLV-3318 - FIM
        );
        
        // condicaoCobranca.add(a);
        // condicaoCobranca.add(b);
        condicaoCobranca.add(c);
        insert condicaoCobranca;
        return condicaoCobranca[0];
    }
    // PLV-3316 - FIM
    

    //Gera ramo de seguro
    public static RamoSeguro__c gerarRamoSeguro(Account contaTeste){

        //Insere ramos
        RamoSeguro__c ramoSegurado = new RamoSeguro__c(
                Name = 'Segurado',
                CodigoEmpresa__c = '214',
                Codigo__c = '2',
                Empresa__c = contaTeste.Id,
                Status__c = 'Ativo',
                CodigoOrigemDoMovimentoBCP__c = '32' //PLV-3773 INICIO/FIM - incluso campo para rega de validação
        );
        insert ramoSegurado;

        return ramoSegurado;
    }

    //Gera ramo de seguro
    public static RamoSeguro__c gerarRamoSeguro(Account contaTeste, String codigoEmpresa){

        //Insere ramos
        RamoSeguro__c ramoSegurado = new RamoSeguro__c(
                Name = 'Segurado',
                CodigoEmpresa__c = codigoEmpresa,
                Codigo__c = '2',
                IdExterno__c = codigoEmpresa + '_3',
                Empresa__c = contaTeste.Id,
                Status__c = 'Ativo',
                CodigoOrigemDoMovimentoBCP__c = '32' //PLV-3773 INICIO/FIM - incluso campo para rega de validação
        );
        insert ramoSegurado;

        return ramoSegurado;
    }

    //Gera modalidade
    public static Modalidade__c gerarModalidade(RamoSeguro__c ramoSegurado){
        Modalidade__c modalidade = new Modalidade__c(
                RamoSeguro__c = ramoSegurado.Id,
                Name = 'Mod teste',
                Codigo__c = '0'
        );
        insert modalidade;

        return modalidade;
    }

    //Gera garantia
    public static Garantia__c gerarGarantia(){
        Garantia__c garantia = new Garantia__c(
                VigenciaInicial__c = System.today(),
                Tipo__c = 'Cobertura',
                Sigla__c = 'CAP'
        );

        insert garantia;

        return garantia;
    }

    //Gera garantia
    public static Garantia__c gerarGarantia(String nome, String sigla){
        Garantia__c garantia = new Garantia__c(
                VigenciaInicial__c = System.today(),
                Tipo__c = 'Cobertura',
                Sigla__c = sigla,
                Name = nome
        );

        insert garantia;
        return garantia;
    }
    //VIAG-241 INICIO KAYMON
    //Gera garantias
    public static Garantia__c gerarGarantias(){
        List<Garantia__c> garantiaList = new List<Garantia__c>();
        Garantia__c g1 = new Garantia__c (
                VigenciaInicial__c = System.today(),
                Tipo__c = 'Cobertura',
                Sigla__c = 'PVB',
            	Status__c = 'Ativo',
                Name = 'Porto Viaje Bem'
        );
        Garantia__c g2 = new Garantia__c (
            VigenciaInicial__c = System.today(),
            Tipo__c = 'Cobertura',
            Sigla__c = 'DMHO',
            Status__c = 'Ativo',
            Name = 'Despesas Médicas, Hospitalares e Odontológicas'
        );
        Garantia__c g3 = new Garantia__c (
            VigenciaInicial__c = System.today(),
            Tipo__c = 'Cobertura',
            Sigla__c = 'MAP',
            Status__c = 'Ativo',
            Name = 'Morte...'
        );
        Garantia__c g4 = new Garantia__c (
            VigenciaInicial__c = System.today(),
            Tipo__c = 'Cobertura',
            Sigla__c = 'RS',
            Status__c = 'Ativo',
            Name = '--'
        );

        garantiaList.add(g1);
        garantiaList.add(g2);
        garantiaList.add(g3);
        garantiaList.add(g4);
        insert garantiaList;
        return g1;
    }
    //VIAG-241 FIM KAYMON
    //Gera ramo da garantia
    public static RamoGarantia__c gerarRamoGarantia(Garantia__c garantia, RamoSeguro__c ramoSegurado){
        RamoGarantia__c ramoGarantia = new RamoGarantia__c(
                Garantia__c = garantia.Id,
                RamoSeguro__c = ramoSegurado.Id
        );
        insert ramoGarantia;

        return ramoGarantia;
    }

    //Gera  garantia do produto tecnico
    public static GarantiaProduto__c gerarGarantiaProdutoTecnico(Product2 produtoTec, Garantia__c garantia, RamoSeguro__c ramoSegurado){
        GarantiaProduto__c garantiaProdutoTec = new GarantiaProduto__c(
                TipoGarantia__c = 'Cobertura',
            	Garantia__c = garantia.Id,
                Produto__c = produtoTec.Id,
                RamoSeguro__c = ramoSegurado.Id,
                OrdemPrioridade__c = 1,
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoTecnico').Id,
                TipoCapital__c = 'Capital uniforme',
                CodigoPromocao__c = 'VITST',
                VersaoTitulo__c = '1'
        );
        insert garantiaProdutoTec;

        return garantiaProdutoTec;
    }

    public static GarantiaProduto__c gerarGarantiaProdutoComercial(Product2 produtoCom, Garantia__c garantia, GarantiaProduto__c garantiaProdutoTec, RamoSeguro__c ramoSegurado){
        GarantiaProduto__c garantiaProdutoCom = new GarantiaProduto__c(
                Garantia__c = garantia.Id,
                GarantiaProduto__c = garantiaProdutoTec.Id,
                Produto__c = produtoCom.Id,
                OrdemPrioridade__c = 1,
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id,
                TipoGarantia__c = 'Cobertura',
                TipoCapital__c = 'Capital uniforme',
                RamoSeguro__c = ramoSegurado.Id,
                TipoCaracteristicaEspecial__c = 'Cestas',
                LimiteMaximoCaracteristicaEspecial__c = 100,
                LimiteMinimoCaracteristicaEspecial__c = 10,
                CodigoPromocao__c = 'VITST',
                VersaoTitulo__c = '1',
            //PLV - 3046 - INICIO
                CurrencyIsoCode = 'BRL',
                LimiteCapitalMinimo__c = 100,
                LimiteCapitalMaximo__c = 1000, 
            //PLV - 3046 - FIM
                Obrigatoria__c = true
        );

        insert garantiaProdutoCom;

        return garantiaProdutoCom;
    }

    //Gera premio minimo produto técnico
    public static PremioMinimoProduto__c gerarPremioMinimoProdutoTecnico(Product2 produtoTec, FormaPagamento__c formaPagamento){
        PremioMinimoProduto__c premioMinimo = new PremioMinimoProduto__c(
                Produto__c = produtoTec.Id,
                FormaPagamento__c = formaPagamento.Id,
                PeriodicidadePagamento__c = 'Anual',
                TipoContratacao__c = 'Novo',
                PremioMinimoParcela__c = 100,
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('PremioMinimoProduto__c', 'ProdutoTecnico').Id
        );
        insert premioMinimo;

        return premioMinimo;
    }

    //Gera premio minimo produto comercoal
    public static PremioMinimoProduto__c gerarPremioMinimoProdutoComercial(Product2 produtoCom, FormaPagamento__c formaPagamento){
        PremioMinimoProduto__c premioMinimo = new PremioMinimoProduto__c(
                Produto__c = produtoCom.Id,
                FormaPagamento__c = formaPagamento.Id,
                PeriodicidadePagamento__c = 'Anual',
                TipoContratacao__c = 'Novo',
                PremioMinimoParcela__c = 100,
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('PremioMinimoProduto__c', 'ProdutoComercial').Id
        );
        insert premioMinimo;

        return premioMinimo;
    }
    //correcao ambientes inicio
    //Gera documentos do produto
    /* public static ContentDocumentLink gerarDocumentoProduto(Product2 produto){
        ContentVersion versaoArquivo = new ContentVersion(
                Title = 'Test 001 - ' + System.now(),
                PathOnClient = 'test_001.txt',
                VersionData = Blob.valueOf('Arquivo #001 de amostra ' + System.now()),
                IsMajorVersion = true
        );
        insert versaoArquivo;

        ContentDocumentLink arquivo = new ContentDocumentLink();
        arquivo.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: versaoArquivo.Id].ContentDocumentId;
        arquivo.LinkedEntityId = produto.Id;
        arquivo.ShareType = 'V';
        insert arquivo;

        return arquivo;
    } */ 
    //correcao ambientes fim

    // Gera Remuneracao do produto do parceiro
    public static RemuneracaoProdutoParceiro__c gerarRemuneracaoProdutoParceiro(TipoRemuneracao__c tipoRemuneracao, ProdutoParceiro__c produtoParceiro, Decimal percentual){
        RemuneracaoProdutoParceiro__c remuneracaoProdutoParceiro = new RemuneracaoProdutoParceiro__c(
                Percentual__c = percentual,
                TipoRemuneracao__c = tipoRemuneracao.Id,
                ProdutoParceiro__c = produtoParceiro.Id
        );
        insert remuneracaoProdutoParceiro;
        return remuneracaoProdutoParceiro;
    }

    // Gera o favorecido da remuneracao do produto do parceiro
    public static FavorecidoRemuneracao__c gerarFavorecidoRemuneracao(Account conta, Decimal percentual, String papel, Boolean ehLider, RemuneracaoProdutoParceiro__c remuneracaoProdutoParceiro, DadosCorretor__c dadosCorretor, InformacaoBancaria__c informacaoBancaria){
        FavorecidoRemuneracao__c favorecidoRemuneracao = new FavorecidoRemuneracao__c(
                Conta__c = conta.Id,
                Percentual__c = percentual,
                Papel__c = papel,
                Lider__c = ehLider,
                RemuneracaoProdutoParceiro__c = remuneracaoProdutoParceiro.Id,
                DadosCorretor__c = (dadosCorretor != null) ? dadosCorretor.Id : null,
                InformacaoBancaria__c = informacaoBancaria.Id
        );
        insert favorecidoRemuneracao;
        return favorecidoRemuneracao;
    }

    //Gera tipo remuneração
    public static TipoRemuneracao__c gerarTipoRemuneracao(){
        TipoRemuneracao__c tipoRemuneracao = new TipoRemuneracao__c(
                Name = 'COMISSÃO',
                Descricao__c = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit.',
                ModeloRecuperacao__c = 'Integral',
                Codigo__c = 'COM',
                LimiteMinimo__c = 10,
                LimiteMaximo__c = 50
        );
        insert tipoRemuneracao;

        return tipoRemuneracao;
    }

    public static TipoRemuneracao__c gerarTipoRemuneracao(String nome, Decimal min, Decimal max, String modeloRecuperacao) {
        TipoRemuneracao__c tipoRemuneracao = new TipoRemuneracao__c(
                Name = nome,
                Codigo__c = nome.substring(0, 3).toUpperCase(),
                LimiteMinimo__c = min,
                LimiteMaximo__c = max,
                ModeloRecuperacao__c = modeloRecuperacao
        );

        insert tipoRemuneracao;
        return tipoRemuneracao;
    }

    //Gera paramentro de vigencia para um produto técnico
    public static ParametroVigencia__c gerarParametroVigenciaProdutoTecnico(Product2 produtoTec){
        ParametroVigencia__c paramVigenciaTec = new ParametroVigencia__c(
                Produto__c = produtoTec.Id,
                Tipo__c = 'Vitalício',
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoTecnico').Id,
                PeriodoCoberturaMinimo__c = 0,
                PeriodoCoberturaMaximo__c = 1000,
                Periodicidade__c = 'Anos',
                PeriodoMaximoInadimplencia__c = 30
        );
        insert paramVigenciaTec;

        return paramVigenciaTec;
    }

    //Gera paramentro de vigencia para um produto comercial
    public static ParametroVigencia__c gerarParametroVigenciaProdutoComercial(Product2 produtoCom){
        ParametroVigencia__c paramVigenciaCom = new ParametroVigencia__c(
                Produto__c = produtoCom.Id,
                Tipo__c = 'Vitalício',
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoComercial').Id,
                PeriodoCoberturaMinimo__c = 0,
                PeriodoCoberturaMaximo__c = 1000,
                Periodicidade__c = 'Anos',
                PeriodoMaximoInadimplencia__c = 30
        );
        insert paramVigenciaCom;

        return paramVigenciaCom;
    }

    public static FaixaDevolucao__c gerarFaixaDevolucaoProdutoComercial(ParametroVigencia__c paramVigencia){
        FaixaDevolucao__c faixa = new FaixaDevolucao__c(
                ParametroVigencia__c = paramVigencia.Id,
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('FaixaDevolucao__c', 'ProdutoComercial').Id
        );
        insert faixa;

        return faixa;
    }

    // Gera remuneracao do orcamento
    public static RemuneracaoOrcamento__c gerarRemuneracaoOrcamento(Opportunity orcamento, TipoRemuneracao__c tipoRemuneracao){
        RemuneracaoOrcamento__c remuneracaoOportunidade = new RemuneracaoOrcamento__c(
                TipoRemuneracao__c = tipoRemuneracao.id,
                Oportunidade__c = orcamento.Id,
                Percentual__c = 40
        );

        insert remuneracaoOportunidade;
        return remuneracaoOportunidade;
    }

    // Gera remuneracao da proposta
    public static RemuneracaoProposta__c gerarRemuneracaoProposta(Quote proposta, TipoRemuneracao__c tipoRemuneracao){
        RemuneracaoProposta__c remuneracaoProposta = new RemuneracaoProposta__c(
                TipoRemuneracao__c = tipoRemuneracao.Id,
                Proposta__c = proposta.Id,
                Percentual__c = 100
        );

        insert remuneracaoProposta;
        return remuneracaoProposta;
    }

    // Gera favorecido da remuneracao da proposta
    public static FavorecidoRemuneracaoProposta__c gerarFavorecidoRemuneracaoProposta(RemuneracaoProposta__c remuneracaoProposta,Account conta){
        FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta = new FavorecidoRemuneracaoProposta__c(
                Conta__c = conta.Id,
                Papel__c = 'Parceiro',
                Participacao__c = 100,
                RemuneracaoProposta__c = remuneracaoProposta.Id,
                Susep__c = '123',
                SusepEmissao__c = '123',
                SusepOficialCorretor__c = '123',
                SusepOrcamento__c = '123'
        );
        insert favorecidoRemuneracaoProposta;
        return favorecidoRemuneracaoProposta;

    }

    //Gera territorio do produto tecnico
    public static Territorio__c gerarTerritorioProdutoTecnico(Product2 produtoTec){
        Territorio__c territorioProduto = new Territorio__c(
                Tipo__c = 'Estado',
                Continente__c = 'América do Sul',
                Pais__c = 'Brasil',
                Estado__c = 'SP',
                Produto__c = produtoTec.Id,
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('Territorio__c', 'ProdutoTecnico').Id
        );
        insert territorioProduto;

        return territorioProduto;
    }

    //Gera territorio da garantia do produto tecnico
    public static Territorio__c gerarTerritorioGarantiaTecnica(GarantiaProduto__c garantiaProdutoTec){
        Territorio__c territorioGarantia = new Territorio__c(
                Tipo__c = 'Estado',
                Continente__c = 'América do Sul',
                Pais__c = 'Brasil',
                Estado__c = 'SP',
                GarantiaProduto__c = garantiaProdutoTec.Id,
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('Territorio__c', 'GarantiaProdutoTecnico').Id
        );
        insert territorioGarantia;

        return territorioGarantia;
    }

    //Gera territorio da garantia do produto comercial
    public static Territorio__c gerarTerritorioGarantiaComercial(GarantiaProduto__c garantiaProdutoCom){
        Territorio__c territorioGarantia = new Territorio__c(
                Tipo__c = 'Estado',
                Continente__c = 'América do Sul',
                Pais__c = 'Brasil',
                Estado__c = 'SP',
                GarantiaProduto__c = garantiaProdutoCom.Id,
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('Territorio__c', 'GarantiaProdutoComercial').Id
        );
        insert territorioGarantia;

        return territorioGarantia;
    }

    // Gera Pergunta
    // PLV-2542 INICIO
    public static Pergunta__c gerarPergunta(){
        Pergunta__c pergunta = new Pergunta__c(
                Pergunta__c = 'Qual a data de hoje',
                TipoResposta__c = 'Data'
        );
        insert pergunta;
        return pergunta;

    }
    // PLV-2542 FIM

    //Gera quetionario
    public static Questionario__c gerarQuestionario(){
        Questionario__c questionario = new Questionario__c(
                Name = 'Q1'
                //PLV-2771 - Codigo removido devido a exclusão do campo
        );
        insert questionario;

        return questionario;
    }

    // Gera Pergunta do questionário
    public static PerguntaQuestionario__c gerarPerguntaQuestionario(Questionario__c questionario, Pergunta__c pergunta){
        PerguntaQuestionario__c perguntaQuestionario = new PerguntaQuestionario__c(
                Pergunta__c = pergunta.Id,
                Questionario__c = questionario.Id,
                Numero__c = 1
        );

        insert perguntaQuestionario;
        return perguntaQuestionario;
    }

    //Gera quetionario
    public static QuestionarioProduto__c gerarQuestionarioProduto(Questionario__c questionario, Product2 produto,
            GarantiaProduto__c garantiaProduto){
        QuestionarioProduto__c questionarioProduto = new QuestionarioProduto__c(
                Produto__c = produto.Id,
                Questionario__c = questionario.Id,
                GarantiaProduto__c = garantiaProduto.Id,
                LimiteCapitalMinimo__c = 10,
                LimiteCapitalMaximo__c = 100,
                Prioridade__c = 1
        );
        insert questionarioProduto;
        return questionarioProduto;
    }

    //Gera Orcamento
    public static Opportunity gerarOrcamentoObjeto(Account conta, Product2 produtoCom, CanalDistribuicao__c canalDistribuicao){

        // Recupera o JSON que está no recurso estático;
        String payloadName = 'PayloadOrcamento001';
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: payloadName LIMIT 1];
        Blob payloadEntrada = sr.Body;

        // OPORTUNIDADE DO TIPO Segurado DE GRUPO
        Opportunity opportunity = new Opportunity(
                StageName = 'Em criação',
                CurrencyIsoCode = 'BRL',
                Name = 'ARQ-10006769',
                CloseDate = System.today().addDays(20),
                VigenciaInicial__c = System.today(),
                VigenciaFinal__c = System.today().addDays(1),
                Produto__c = produtoCom.Id,
                Probability = 10.0,
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaGrupo').Id,
                AccountId = conta.Id,
                Numero__c = '10006769',
                CanalDistribuicao__c = canalDistribuicao.Id,
                Payload__c = EncodingUtil.base64Decode(EncodingUtil.base64Encode(payloadEntrada)).toString()
        );
        System.debug('opportunity'+ opportunity);
        insert opportunity;

        CriticaOrcamento__c critica = new CriticaOrcamento__c(
                Orcamento__c = opportunity.Id,
                Status__c = 'Em aprovação',
                Justificativa__c = 'Justificativa'
        );

        insert critica;

        CriticaOrcamento__c critica_2 = new CriticaOrcamento__c();
        critica_2 = critica.clone();

        insert critica_2;

        return opportunity;
    }
    
    //PLV-2439 - INICIO
    //PLV-3460 Fix 5 - INICIO - Trecho comentado
    /*public static Opportunity gerarCriticasODM(Account conta, Product2 produtoCom, CanalDistribuicao__c canalDistribuicao){

        // Recupera o JSON que está no recurso estático;
        String payloadName = 'PayloadOrcamentoRetornoAceitacao';
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: payloadName LIMIT 1];
        Blob payloadEntrada = sr.Body;

        // OPORTUNIDADE DO TIPO Segurado DE GRUPO
        Opportunity opportunity = new Opportunity(
                StageName = 'Em criação',
                CurrencyIsoCode = 'BRL',
                Name = 'ARQ-00006767',
                CloseDate = System.today().addDays(20),
                VigenciaInicial__c = System.today(),
                VigenciaFinal__c = System.today().addDays(1),
                Produto__c = produtoCom.Id,
                Probability = 10.0,
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaGrupo').Id,
                AccountId = conta.Id,
                Numero__c = '00006767',
                CanalDistribuicao__c = canalDistribuicao.Id,
                Payload__c = EncodingUtil.base64Decode(EncodingUtil.base64Encode(payloadEntrada)).toString()
        );
        insert opportunity;

        CriticaOrcamento__c critica = new CriticaOrcamento__c(
                Orcamento__c = opportunity.Id,
            	Descricao__c = 'Capital da Cobertura superior a R$400.000,00',
                Area__c = 'UNI',
                Procedimento__c = '',
                Origem__c = 'ODM',
                Tipo__c = 'Análise',
        		Status__c = 'Pendente'

        );

        insert critica;

        CriticaOrcamento__c critica_2 = new CriticaOrcamento__c();
        critica_2.Orcamento__c = opportunity.Id;
            	critica_2.Descricao__c = 'Capital da Cobertura superior a R$1.000.000,00';
                critica_2.Area__c = 'UNI';
                critica_2.Procedimento__c = '';
                critica_2.Origem__c = 'ODM';
                critica_2.Tipo__c = 'Recusa';
        		critica_2.Status__c = 'Pendente';

        insert critica_2;

        return opportunity;
    }*/
    //PLV-3460 Fix 5 - FIM
//PLV-2439 - FIM

    public static ContratanteOrcamento__c gerarContratanteOrcamento(Opportunity opp, Account conta)
    {
        ContratanteOrcamento__c contratanteOrcamento = new ContratanteOrcamento__c(
                CurrencyIsoCode = 'BRL',
                Orcamento__c = opp.Id,
                Conta__c = conta.Id,
                Numero__c = 1,
                Tipo__c = 'Principal',
                IOF__c = 0.14 ,
                Logradouro__c = 'Rua Teste',
                NumeroEndereco__c = '55',
                Pais__c = 'Brasil',
                PremioComercial__c = 100,
                PremioPuro__c = 100,
                PremioTotal__c = 200,
                TaxaComercial__c = 0.05,
                TaxaPura__c = 0.05,
                TaxaTotal__c = 0.05
                //TipoDescontoAgravo__c = 'TEC',
                //TipoEndereco__c = 'COM'


        );
        insert contratanteOrcamento;
        return contratanteOrcamento;
    }

    public static GrupoOrcamento__c gerarGrupoOrcamento(ContratanteOrcamento__c contratanteOrcamento)
    {
        GrupoOrcamento__c grupoOrcamento = new GrupoOrcamento__c(
                Name = 'Sócio',
                ContratanteOrcamento__c = contratanteOrcamento.Id,
                Numero__c = 1
        );
        insert grupoOrcamento;
        return grupoOrcamento;
    }

    public static SeguradoOrcamento__c gerarSeguradoOrcamento(GrupoOrcamento__c grupoOrcamento)
    {
        SeguradoOrcamento__c SeguradoOrcamento = new SeguradoOrcamento__c(
                GrupoOrcamento__c = grupoOrcamento.Id,
               //Name = 'Marieta',
                CPF__c = '727.235.580-88',
                Numero__c = 1
        );

        insert SeguradoOrcamento;
        return SeguradoOrcamento;
    }

  
    public static RemuneracaoContrato__c gerarRemuneracaoContrato(Contract contrato, TipoRemuneracao__c tipoRemuneracao){
        RemuneracaoContrato__c remuneracaoContrato = new RemuneracaoContrato__c(
                Contrato__c = contrato.Id,
                TipoRemuneracao__c = tipoRemuneracao.Id
        );
        insert remuneracaoContrato;
        return remuneracaoContrato;
    }

    public static CriticaProposta__c gerarCriticaProposta(Quote proposta)
    {
        CriticaProposta__c criticaproposta = new CriticaProposta__c(
                Proposta__c = proposta.Id,
                //INICIO | PLV-4647-VI-Guilherme Brito
                MensagemCliente__c = 'Teste',
                MensagemInterna__c = 'Teste',
                MensagemRepresentante__c = 'Teste', 
                //FIM| PLV-4647-VI-Guilherme Brito
                Origem__c = 'ODM'
        );
        insert criticaproposta;
        return criticaproposta;
    }
    
    //RVI-104 -Inicio
    public static CriticaProposta__c gerarCriticasPropostaRenovacao(Quote proposta, String codigoCritica, String statusCritica){
        CriticaProposta__c criticaProposta = new CriticaProposta__c();
        // CriticaProposta__c -> Objeto -> Inicio
        criticaProposta.Proposta__c = proposta.Id;
        criticaProposta.MensagemCliente__c = 'Mensagem cliente';
        criticaProposta.MensagemInterna__c = 'Mensagem interna';        
        criticaProposta.MensagemRepresentante__c = 'Mensagem Representante'; 
        criticaproposta.Codigo__c = codigoCritica;
        criticaProposta.Origem__c = 'ODM';
        criticaProposta.Status__c = statusCritica;
        criticaProposta.Tipo__c = 'Analise';
        // CriticaProposta__c -> Objeto -> Fim
        
        Insert criticaProposta;
        return criticaProposta;
    }
    //RVI-104 -Fim

     public static BeneficiarioSeguradoProposta__c gerarBeneficiarioSeguradoProposta(Account conta, SeguradoProposta__c segurado)
     {
         BeneficiarioSeguradoProposta__c beneficiarioSeguradoproposta = new BeneficiarioSeguradoProposta__c(
                 Conta__c = conta.Id,
                 Nome__c = 'Teste',
                 NomePessoaPep__c = 'Teste',
                 SeguradoProposta__c = segurado.Id,
                 TipoBeneficiario__c = 'Nome do beneficiário',
                 Participacao__c = 100,
                 MotivoSemCpfCnpj__c = 'Não desejo informar',
                 GrauParentesco__c = 'Cônjuge',
                 Pep__c = 'Sim'
         );
         insert beneficiarioSeguradoproposta;
         return beneficiarioSeguradoproposta;
     }


    // ---------------------------------------GARANTIAS DO ORÇAMENTO  ---------------------------------------

    public static GarantiaOrcamento__c gerarGarantiaOrcamento (Garantia__c garantia, Opportunity opp)
    {
        GarantiaOrcamento__c garantiaOrcamento = new GarantiaOrcamento__c(
                Garantia__c = garantia.Id,
                Orcamento__c = opp.Id,
                Capital__c = 15000.00,
                TaxaPura__c = 0.1,
                TaxaAnual__c = 0.1,
                TaxaComercial__c = 0.2,
                TaxaMensal__c = 0.5,
                TaxaPuroInterno__c = 0.2,
                TaxaPuroResseguro__c = 0.2,
                PremioComercial__c = 4000.00,
                PremioPuro__c = 4000.00,
                PremioComercialDesconto__c = 4000.00,
                PremioPuroDesconto__c = 4000.00,
                PremioPuroInterno__c = 4000.00,
                PremioPuroResseguro__c = 4000.00
        );

        insert garantiaOrcamento;
        return garantiaOrcamento;
    }

    public static GarantiaContratanteOrcamento__c gerarGarantiaContratanteOrcamento(Garantia__c garantia, ContratanteOrcamento__c contratanteOrcamento)
    {
        // Garantia do Grupo do Orçamento
        GarantiaContratanteOrcamento__c garantiaGrupoOrcamento = new GarantiaContratanteOrcamento__c(
                Garantia__c = garantia.Id,
                ContratanteOrcamento__c = contratanteOrcamento.Id,
                Capital__c = 15000.00,
                TaxaPura__c = 0.1,
                TaxaAnual__c = 0.1,
                TaxaComercial__c = 0.2,
                TaxaMensal__c = 0.5,
                TaxaPuroInterno__c = 0.2,
                TaxaPuroResseguro__c = 0.2,
                PremioComercial__c = 4000.00,
                PremioComercialDesconto__c = 4000.00,
                PremioPuro__c = 4000.00,
                PremioPuroDesconto__c = 4000.00,
                PremioPuroInterno__c = 4000.00,
                PremioPuroResseguro__c = 4000.00
        );
        insert garantiaGrupoOrcamento;
        return garantiaGrupoOrcamento;
    }

    public static GarantiaGrupoOrcamento__c gerarGarantiaGrupoOrcamento(Garantia__c garantia, GrupoOrcamento__c grupoOrcamento)
    {
        // Garantia do Grupo do Orçamento
        GarantiaGrupoOrcamento__c garantiaGrupoOrcamento = new GarantiaGrupoOrcamento__c(
                GrupoOrcamento__c = grupoOrcamento.Id,
                Garantia__c = garantia.Id,
                Capital__c = 15000.00,
                TaxaPura__c = 0.1,
                TaxaAnual__c = 0.1,
                TaxaComercial__c = 0.2,
                TaxaMensal__c = 0.5,
                TaxaPuroInterno__c = 0.2,
                TaxaPuroResseguro__c = 0.2,
                PremioComercial__c = 4000.00,
                PremioPuro__c = 4000.00,
                PremioComercialDesconto__c = 4000.00,
                PremioPuroDesconto__c = 4000.00,
                PremioPuroInterno__c = 4000.00,
                PremioPuroResseguro__c = 4000.00
        );
        insert garantiaGrupoOrcamento;
        return garantiaGrupoOrcamento;
    }

    public static GarantiaSeguradoOrcamento__c gerarGarantiaSeguradoOrcamento(Garantia__c garantia1, SeguradoOrcamento__c seguradoOrcamento)
    {
        // Garantia do Grupo do Orçamento
        GarantiaSeguradoOrcamento__c garantia = new GarantiaSeguradoOrcamento__c(
                SeguradoOrcamento__c = seguradoOrcamento.Id,
                Garantia__c = garantia1.Id,
                Capital__c = 15000.00,
                TaxaPura__c = 0.1,
                TaxaAnual__c = 0.1,
                TaxaComercial__c = 0.2,
                TaxaMensal__c = 0.5,
                TaxaPuroInterno__c = 0.2,
                TaxaPuroResseguro__c = 0.2,
                PremioComercial__c = 4000.00,
                PremioPuro__c = 4000.00,
                PremioComercialDesconto__c = 4000.00,
                PremioPuroDesconto__c = 4000.00,
                PremioPuroInterno__c = 4000.00,
                PremioPuroResseguro__c = 4000.00
        );
        insert garantia;
        return garantia;
    }

   



   

    // Gera proposta
    public static Quote gerarPropostaObjeto(Product2 produto, RamoSeguro__c ramoSeguro, Account empresa, DadosCorretor__c dadosCorretor, Opportunity orcamento, Modalidade__c modalidade ){

        String origem = '18';
        String numeroProposta = '00006767';
        // AV-664 INICIO
        Cupom__c cupom = new Cupom__c(
            Codigo__c = 'VALE50DESCONTO',
            Limite_de_Utilizacao__c	= 400,
            Meio_de_Comercializacao__c=	'SFC',
            Percentual__c	 = 5,
            Vigencia_Inicial__c = System.today(),
            Vigencia_Final__c = System.today().addMonths(8)
        );
        insert cupom;
       // AV-664 FIM
        Quote quote = new Quote(
                Name = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta),
                // PLV-2312-28 INICIO
                NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta),
                // PLV-2312-28 FIM
                Produto__c = produto.Id,
                RamoSeguro__c = ramoSeguro.Id,
                Status = 'Em criação',
                VigenciaInicial__c = System.today(),
                VigenciaFinal__c = System.today().addMonths(1),
                Empresa__c = empresa.Id,
                CodigoCorretor__c = dadosCorretor.Id,
                DataCalculo__c = System.today(),
                DataCriacaoPortal__c = System.today(),
                TipoVigencia__c = 'Anual',
                MeioComercializacao__c = 'PMC', //PLV-4550 INICIO/FIM
                OpportunityId = orcamento.Id,
                Origem__c = origem,
                Modalidade__c = modalidade.Id,
                NumeroProposta__c = numeroProposta,
                Parceiro__c = '67708896000139',
                CupomDesconto__c = 'VALE50DESCONTO' // AV-664 FIM

        );

        insert quote;
        return quote;
    }

  

    // Gera contratante da proposta
    public static ContratanteProposta__c gerarContratanteProposta(Account conta, Quote proposta, FormaPagamento__c formaPagamento)
    {
        // PLV-2312 INICIO

        // Busca o parceiro
        List<Parceiro__c> listParceiro = [SELECT Id, Conta__c FROM Parceiro__c];

        Account contaParceiro;
        if(!listParceiro.isEmpty() && listParceiro[0].Conta__c != null){
            contaParceiro = new Account(Id = listParceiro[0].Conta__c);
        }

        ContratanteProposta__c contratanteProposta = new ContratanteProposta__c(
                Conta__c = conta.Id,
                Proposta__c = proposta.Id,
                Tipo__c = 'Principal',
                TipoEndereco__c = 'Residencial',
                Cep__c = '03020-000',
                TipoLogradouro__c = 'Rua',
                Logradouro__c = '15',
                NumeroEndereco__c = '15',
                Bairro__c = 'Osasco',
                Cidade__c = 'São Paulo',
                Estado__c = 'SP',
                Pais__c = 'Brasil',
                ResponsavelPagamento__c = (contaParceiro != null) ? contaParceiro.Id : null,
                FormaPagamento__c = formaPagamento.Id,
                PremioTotal__c = 10,
                PremioComercial__c = 10,
                IOF__c = 1,
                QuantidadeParcelas__c = 1,
                EnderecoBoleto__c = 'http://www.google.com.br',
                TipoResponsavelPagamento__c = 'PAR',
                VencimentoPrimeiraParcela__c = System.today(),
                PremioPuro__c = 100,
                TaxaPura__c = 10,
                TaxaComercial__c = 10,
                Numero__c = 1
        );
        // PLV-2312 FIM

        insert contratanteProposta;
        return contratanteProposta;
    }

   // Gera grupo da proposta
    public static GrupoProposta__c gerarGrupoProposta(ContratanteProposta__c contratanteProposta)
    {
        GrupoProposta__c grupoProposta = new GrupoProposta__c(
                ContratanteProposta__c =contratanteProposta.Id,
                Name = 'Grupo de Teste',
                Numero__c = 1
        );

        insert grupoProposta;
        return grupoProposta;
    }

    // Gera Segurado do grupo da proposta
    public static SeguradoProposta__c gerarSeguradoProposta(Account conta, GrupoProposta__c grupoProposta, FormaPagamento__c formaPagamento)
    {
        SeguradoProposta__c SeguradoProposta = new SeguradoProposta__c(
                Conta__c = conta.Id,
                ResponsavelPagamento__c = conta.Id,
                FormaPagamento__c = formaPagamento.Id,
                PremioTotal__c = 10,
                GrupoProposta__c = grupoProposta.Id,
                EnderecoBoleto__c = 'http://www.google.com.br',
                PremioComercial__c = 10,
                IOF__c = 1,
                Numero__c = 1
        );

        insert SeguradoProposta;
        return SeguradoProposta;
    }

      // Gera garantia da proposta
    public static GarantiaProposta__c gerarGarantiaProposta(Quote proposta, GarantiaProduto__c garantiaProduto)
    {
        GarantiaProposta__c garantiaProposta = new GarantiaProposta__c(
                Proposta__c = proposta.Id,
                GarantiaProduto__c = garantiaProduto.Id,
                Garantia__c = garantiaProduto.Garantia__c,
                TipoCapital__c = 'Capital uniforme'
        );

        insert garantiaProposta;
        return garantiaProposta;
    }

     public static GarantiaContratanteProposta__c gerarGarantiaContratanteProposta(Garantia__c garantia, ContratanteProposta__c contratanteProposta)
     {
         GarantiaContratanteProposta__c garantiasContratanteProposta = new GarantiaContratanteProposta__c(
                 ContratanteProposta__c = contratanteProposta.Id,
                 Garantia__c =  garantia.Id,
                 Capital__c = 90.00
         );


         insert garantiasContratanteProposta;
         return garantiasContratanteProposta;
     }


     public static GarantiasGrupoProposta__c gerarGarantiaGrupoProposta(Garantia__c garantia, GrupoProposta__c grupoProposta)
     {
         GarantiasGrupoProposta__c garantiasGrupoProposta = new GarantiasGrupoProposta__c(
                 GrupoProposta__c = grupoProposta.Id,
                 Garantia__c =  garantia.Id,
                 Capital__c = 90.00
         );


         insert garantiasGrupoProposta;
         return garantiasGrupoProposta;
     }

   public static GarantiaSeguradoProposta__c gerarGarantiaSeguradoProposta(Garantia__c garantia, SeguradoProposta__c seguradoProposta)
     {
         GarantiaSeguradoProposta__c garantiasSeguradoProposta = new GarantiaSeguradoProposta__c(
                 SeguradoProposta__c = seguradoProposta.Id,
                 Garantia__c =  garantia.Id,
                 Capital__c = 90.00
         );


         insert garantiasSeguradoProposta;
         return garantiasSeguradoProposta;
     }


 

    // Gera informacao Bancaria
    public static InformacaoBancaria__c gerarInformacaoBancaria(Account conta){
        
        // PLV-4337 - INÍCIO
        Banco__c banconew = new Banco__c();
        List< Banco__c > listaBanco = [ SELECT CodigoBanco__c, ConveniadoADC__c, Name, Ativo__c FROM Banco__c WHERE CodigoBanco__c = '341' LIMIT 1 ];
        if( listaBanco.size() == 1 ) {
            banconew = listaBanco[0];
        } else {
            //PLV-4363 - INICIO
            //Banco__c banconew = new Banco__c();
            banconew.CodigoBanco__c = '341';
            banconew.ConveniadoADC__c  = false;
            banconew.Name = 'BANCO ITAU S/A';
            banconew.Ativo__c = true;
            insert banconew; 
            //PLV-4363 - FIM            
        }
        // PLV-4337 - FIM

        InformacaoBancaria__c informacaoBancaria = new InformacaoBancaria__c(
                Conta__c = conta.Id,
                Agencia__c = '8765',
                Banco__c = '341',
                NumeroConta__c = '012345',
            	//PLV-3918-FIX6 - INICIO
            	//PLV-3918-FIX7 - INICIO
                Digito__c = '3',
            	//PLV-3918-FIX7 - FIM
                //PLV-3918-FIX6 - FIM
             
                BancoNew__c = banconew.Id, //PLV-4363 - INICIO/FIM
               
                StatusIntegracao__c = 'Validada'
        );
        insert informacaoBancaria;
        return informacaoBancaria;
    }


    

    
     


    

    //Gera dependentes garantia
    public static DependenteGarantia__c gerarDependenteGarantiaTecnica(GarantiaProduto__c garantiaProduto){
        DependenteGarantia__c dependenteGarantia = new DependenteGarantia__c(
                GarantiaProduto__c = garantiaProduto.Id,
                Dependente__c = 'Filhos',
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('DependenteGarantia__c', 'ProdutoTecnico').Id
        );
        insert dependenteGarantia;

        return dependenteGarantia;
    }

    // Gera dados do corretor
    public static DadosCorretor__c gerarDadosCorretor(Account conta){
        DadosCorretor__c dadosCorretor = new DadosCorretor__c(
                Name            = conta.Name,
                NomeCorretor__c = conta.Id
        );

        insert dadosCorretor;
        return dadosCorretor;
    }

    private static DocumentoProduto__c gerarDocumento(Product2 produto){
        DocumentoProduto__c documento = new DocumentoProduto__c(
                Produto__c = produto.Id,
                //Documento__c = 'Apólice de Seguro',
                MeioEnvio__c = 'Protocolo manual'
        );

        insert documento;
        return documento;
    }

    //Gera um produto comercial ativo juntamente com os seus filhos
    public static Map<String,List<SObject>> gerarProdutoComercialAtivo(Boolean gerarParceiro){

        Test.startTest();

        //Geração dos dados de dominio
        Account contaTeste = TestDataFactory.gerarConta();
        Endereco__c endereco = gerarEndereco(contaTeste);
        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);
        Modalidade__c modalidade1 = TestDataFactory.gerarModalidade(ramoSegurado);
        FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento(ramoSegurado,modalidade1,'Boleto','1234'); // PLV-5331 FIX
        PlanoParcelamento__c gerarPlanoParcelamento = TestDataFactory.gerarPlanoParcelamento(formaPagamento.Id);
        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao('CORRETAGEM', 5, 100, 'Integral');
        Garantia__c garantia = TestDataFactory.gerarGarantia();
        RamoGarantia__c ramoGarantia = TestDataFactory.gerarRamoGarantia(garantia, ramoSegurado);
        GarantiaProduto__c garantiaProdutoTec = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTec, garantia, ramoSegurado);
        limiteGarantiaProduto__c limGarantiaProdTec = (limiteGarantiaProduto__c) new LimiteGarantiaProdutoFactory(garantiaProdutoTec).createRecord(); //3046
        PremioMinimoProduto__c premioMinimo = TestDataFactory.gerarPremioMinimoProdutoTecnico(produtoTec, formaPagamento);
        //ContentDocumentLink arquivoTec = TestDataFactory.gerarDocumentoProduto(produtoTec); //correcao ambientes
        ParametroVigencia__c paramVigenciaTec = TestDataFactory.gerarParametroVigenciaProdutoTecnico(produtoTec);
        RemuneracaoProduto__c remuneracaoProduto = TestDataFactory.gerarRemuneracaoProduto(produtoTec, tipoRemuneracao);

        //AND(
        //NOT(ISNEW()), true
        //ISPICKVAL(Status__c, &apos;Em ativação&apos;), true
        //NOT(ISCHANGED(NumeroSusep__c)),  false
        //NOT(ISCHANGED(VersaoRenovacao__c)) true
        //)

        produtoTec.Status__c = 'Em ativação';
        //produtoTec.VersaoRenovacao__c = 'Versão cont';
        produtoTec.NumeroSusep__c = '54321';

        update produtoTec;

        //Ativa o produto técnico
        ProductAcaoBotaoController.ativarProduto(produtoTec.Id);

        //Criação dos dados do produto comercial
        Product2 produto = TestDataFactory.gerarProdutoComericial(produtoTec);
        ParametroVigencia__c paramVigencia = TestDataFactory.gerarParametroVigenciaProdutoComercial(produto);
        FaixaDevolucao__c faixa = TestDataFactory.gerarFaixaDevolucaoProdutoComercial(paramVigencia);
        GarantiaProduto__c garantiaProdutoCom = TestDataFactory.gerarGarantiaProdutoComercial(produto, garantia, garantiaProdutoTec, ramoSegurado);
        Territorio__c territorioGarantia = TestDataFactory.gerarTerritorioGarantiaComercial(garantiaProdutoCom);

        //Ativa produto comercial
        //ContentDocumentLink arquivo = TestDataFactory.gerarDocumentoProduto(produto); //correcao ambientes
        RemuneracaoProduto__c remuneracaoProdutoCom = TestDataFactory.gerarRemuneracaoProduto(produto, tipoRemuneracao);
        PremioMinimoProduto__c premioMinimoCom = TestDataFactory.gerarPremioMinimoProdutoComercial(produto, formaPagamento);
        Pergunta__c pergunta = gerarPergunta();
        Questionario__c questionario = TestDataFactory.gerarQuestionario();
        PerguntaQuestionario__c perguntaQuestionario = gerarPerguntaQuestionario(questionario, pergunta);
        QuestionarioProduto__c questionarioProduto = TestDataFactory.gerarQuestionarioProduto(questionario, produto, garantiaProdutoCom);
        //DocumentoProduto__c documentoProd = TestDataFactory.gerarDocumento(produto);
        CondicaoCobranca__c condicaoCobranca = TestDataFactory.gerarCondicaoCobranca(produto,formaPagamento);

        produto.Status__c = 'Em ativação';
        produto.NumeroSusep__c = '1234';
        update produto;

        //Ativa produto
        ProductAcaoBotaoController.ativarProduto(produto.Id);

        // Instancia do Map
        Map<String,List<SObject>> mapsObject = new Map<String, List<SObject>>();

        // popula Map
        inserirSObject(mapsObject, 'FormaPagamento__c',      formaPagamento);
        inserirSObject(mapsObject, 'Account',                contaTeste);
        inserirSObject(mapsObject, 'RamoSeguro__c',          ramoSegurado);
        inserirSObject(mapsObject, 'TipoRemuneracao__c',     tipoRemuneracao);
        inserirSObject(mapsObject, 'Modalidade__c',          modalidade1);
        inserirSObject(mapsObject, 'Garantia__c',            garantia);
        inserirSObject(mapsObject, 'RamoGarantia__c',        ramoGarantia);
        //inserirSObject(mapsObject, 'PremioMinimoProduto__c', premioMinimo);
        //inserirSObject(mapsObject, 'ContentDocumentLink',    arquivoTec);
        //inserirSObject(mapsObject, 'ParametroVigencia__c',   paramVigenciaTec);
        //inserirSObject(mapsObject, 'RemuneracaoProduto__c',  remuneracaoProduto);
        inserirSObject(mapsObject, 'Product2',               produto);
        inserirSObject(mapsObject, 'ParametroVigencia__c',   paramVigencia);
        inserirSObject(mapsObject, 'FaixaDevolucao__c',      faixa);
        inserirSObject(mapsObject, 'GarantiaProduto__c',     garantiaProdutoCom);
        inserirSObject(mapsObject, 'Territorio__c',          territorioGarantia);
        //inserirSObject(mapsObject, 'ContentDocumentLink',    arquivo); //correcao ambientes
        inserirSObject(mapsObject, 'RemuneracaoProduto__c',  remuneracaoProdutoCom);
        inserirSObject(mapsObject, 'PremioMinimoProduto__c', premioMinimoCom);
        inserirSObject(mapsObject, 'Pergunta__c',            pergunta);
        inserirSObject(mapsObject, 'PerguntaQuestionario__c',perguntaQuestionario);
        inserirSObject(mapsObject, 'Questionario__c',        questionario);
        inserirSObject(mapsObject, 'QuestionarioProduto__c', questionarioProduto);

        if(gerarParceiro){
            gerarParceiroCompletoAtivo(false);
        }

        Test.stopTest();

        return mapsObject;
    }

    // Gera proposta
    // PLV-2312-28 INICIO
    public static Contract gerarContratoObjeto(Product2 produto, RamoSeguro__c ramoSeguro, Account conta, DadosCorretor__c dadosCorretor, Quote proposta){

        String empresa = '22';
        String sucursal = '999';
        String ramo = '2';
        String numeroApolice = '000000014889'; //PLV - 4626 - VI - INICIO/FIM - GUSTAVO PEREIRA SYS4B 
        String endosso = '0';
       
          // AV-664 INICIO
          Cupom__c cupom = new Cupom__c(
            Codigo__c = 'VALE50DESCONTO',
            Limite_de_Utilizacao__c	= 400,
            Meio_de_Comercializacao__c=	'SFC',
            Percentual__c	 = 5,
            Vigencia_Inicial__c = System.today(),
            Vigencia_Final__c = System.today().addMonths(8)
        );
        insert cupom;
       // AV-664 FIM


        Contract contrato = new Contract(
                Name = ContractBO.getInstance().gerarNameContrato(empresa, sucursal, ramo, numeroApolice, endosso),
                Produto__c = produto.Id,
                NumeroApolice__c = numeroApolice,
                RamoSeguro__c = ramoSeguro.Id,
                Status = 'Em elaboração',
                Empresa__c = empresa,
                CodigoCorretor__c = dadosCorretor.Id,
                MeioComercializacao__c = 'PMC', //PLV-4550 INICIO/FIM
                Proposta__c = proposta.Id,
                AccountId = conta.Id,
                StartDate = System.today(),
                VigenciaFinal__c = System.today().addDays(30),
                DataEmissao__c = System.today(),
                Endosso__c = endosso,
                Sucursal__c = sucursal,
                CodigoRamo__c = ramo,
                PremioComercial__c = 15000.00,
                Parceiro__c = '67708896000139',
                CupomDesconto__c = cupom.codigo__c // AV-664
        );

        insert contrato;
        return contrato;
    }
    // PLV-2312-28 FIM

    public static ContratanteContrato__c gerarContratanteContrato(Contract contrato, Account conta, Account contaParceiro){
        
        ContratanteContrato__c contratanteContrato = new ContratanteContrato__c(
                CurrencyIsoCode = 'BRL',
                Contrato__c = contrato.Id,
                Conta__c = conta.Id,
                Tipo__c = 'Principal',
                QuantidadeParcelas__c = 2,
                VencimentoPrimeiraParcela__c = System.today().addDays(20),
                TipoResponsavelPagamento__c = 'PAR',
                IOF__c = 10,
                Logradouro__c = 'Rua xpto',
                NumeroEndereco__c = '55',
                //Numero__c = 44,
                Pais__c = 'Brasil',
                PremioComercial__c = 150,
                PremioPuro__c = 150,
                PremioTotal__c = 300,
                TaxaComercial__c = 0.10,
                TaxaPura__c =  0.10,
                TaxaTotal__c =  0.10,
               // TipoDescontoAgravo__c = 'Informado',
                TipoEndereco__c = 'Comercial',
                TipoLogradouro__c = 'Rua'
        );

        if(contaParceiro != null){
            contratanteContrato.ResponsavelPagamento__c = contaParceiro.Id;
        }

        insert contratanteContrato;
        return contratanteContrato;
    }

    public static GrupoContrato__c gerarGrupoContrato(ContratanteContrato__c contratanteContrato){
        GrupoContrato__c grupoContrato = new GrupoContrato__c(
                Name = 'Sócio',
                ContratanteContrato__c = contratanteContrato.Id,
                QuantidadeVidas__c = 1
        );
        insert grupoContrato;
        return grupoContrato;
    }

    public static SeguradoContrato__c gerarSeguradoContrato(GrupoContrato__c grupoContrato, Account conta){
        SeguradoContrato__c SeguradoContrato = new SeguradoContrato__c(
                GrupoContrato__c = grupoContrato.Id,
                Conta__c = conta.Id,
                TipoResponsavelPagamento__c = 'PAR'
        );

        insert SeguradoContrato;
        return SeguradoContrato;
    }

    public static GarantiaContrato__c gerarGarantiaContrato(Contract contrato, GarantiaProduto__c garantiaProduto)
    {
        GarantiaContrato__c garantiaContrato = new GarantiaContrato__c(
                Contrato__c = contrato.Id,
                GarantiaProduto__c = garantiaProduto.Id,
                Garantia__c = garantiaProduto.Garantia__c,
                TipoCapital__c = 'Capital uniforme',
                VersaoTitulo__c = '1'
        );

        insert garantiaContrato;
        return garantiaContrato;
    }

    public static GarantiaContratanteContrato__c gerarGarantiaContratanteContrato(Garantia__c garantia, ContratanteContrato__c contratanteContrato)
    {
        // Garantia do Grupo do Orçamento
        GarantiaContratanteContrato__c garantiaGrupoContrato = new GarantiaContratanteContrato__c(
                Garantia__c = garantia.Id,
                ContratanteContrato__c = contratanteContrato.Id,
                Capital__c = 15000.00,
                PremioTotal__c = 15000.00
                
        );
        insert garantiaGrupoContrato;
        return garantiaGrupoContrato;
    }


    public static GarantiaGrupoContrato__c gerarGarantiaGrupoContrato(Garantia__c garantia, GrupoContrato__c grupo)
    {
         GarantiaGrupoContrato__c garantiaContrato = new GarantiaGrupoContrato__c(
            GrupoContrato__c =  grupo.Id,
                 Garantia__c = garantia.Id,
                 Capital__c = 200,
                 NumeroSorte__c = '444',
                 NumeroSerie__c = '666'
         );

         insert garantiaContrato;
         return garantiaContrato;
    }

    public static GarantiaSeguradoContrato__c gerarGarantiaSeguradoContrato(Garantia__c garantia, SeguradoContrato__c segurado)
    {
         GarantiaSeguradoContrato__c garantiaContrato = new GarantiaSeguradoContrato__c(
                 Garantia__c = garantia.Id,
                 SeguradoContrato__c = segurado.Id,
                 Capital__c = 200,
                 NumeroSorte__c = '444',
                 NumeroSerie__c = '666'
         );

         insert garantiaContrato;
         return garantiaContrato;
    }

    public static Roteamento__c gerarRoteamento(Opportunity oportunidade){
        Roteamento__c roteamento = new Roteamento__c(
                IdExterno__c = '12312455',
                Orcamento__c = oportunidade.Id
        );
        insert roteamento;
        return roteamento;
    }

    // PLV-2312-28 INICIO
    // Gera um orcamento e todos os seus filhos
    public static Map<String,List<SObject>> gerarOrcamento(Boolean gerarParceiro)
    {

        Map<String,List<SObject>> mapListObject = new Map<String, List<SObject>>();

        // gera um produto comercial ativo e seus filhos
        mapListObject = gerarProdutoComercialAtivo(gerarParceiro);



        // Pega dados do produto comercial
        Product2 produtoComercial = (Product2) pegarRegistro(mapListObject, 'Product2');

        Account             conta                       = (Account)             pegarRegistro(mapListObject, 'Account');
        Garantia__c         garantia                    = (Garantia__c)         pegarRegistro(mapListObject, 'Garantia__c');
        GarantiaProduto__c  garantiaProduto             = (GarantiaProduto__c)  pegarRegistro(mapListObject, 'GarantiaProduto__c');
        TipoRemuneracao__c  tipoRemuneracao             = (TipoRemuneracao__c)  pegarRegistro(mapListObject, 'TipoRemuneracao__c');

        TipoRemuneracao__c  tipoRemuneracaoParaCanal    = TestDataFactory.gerarTipoRemuneracao();

        // geracao do orcamento
        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();

        ProdutoCanal__c produtoCanal = TestDataFactory.gerarProdutoCanal(canalDistribuicao, produtoComercial);

        RemuneracaoProduto__c remuneracaoProduto = TestDataFactory.gerarRemuneracaoProduto(produtoComercial, tipoRemuneracaoParaCanal);
        RemuneracaoCanal__c remuneracaoCanal = TestDataFactory.gerarRemuneracaoCanal(produtoCanal, tipoRemuneracaoParaCanal);

        // Ativa o Canal de Distribuicao
        canalDistribuicao.Status__c = 'Ativo';
        update  canalDistribuicao;
        Account                         corretor                     = gerarCorretor();

        Opportunity                     orcamento                    = gerarOrcamentoObjeto(conta, produtoComercial, canalDistribuicao);
        ContratanteOrcamento__c         contratanteOrcamento         = gerarContratanteOrcamento(orcamento, conta);
        GrupoOrcamento__c               grupoOrcamento               = gerarGrupoOrcamento(contratanteOrcamento);
        SeguradoOrcamento__c            seguradoOrcamento            = gerarSeguradoOrcamento(grupoOrcamento);
        GarantiaOrcamento__c            garantiaOrcamento            = gerarGarantiaOrcamento(garantia, orcamento);
        GarantiaContratanteOrcamento__c garantiaContratanteOrcamento = gerarGarantiaContratanteOrcamento(garantia, contratanteOrcamento);
        GarantiaGrupoOrcamento__c       garantiaGrupoOrcamento       = gerarGarantiaGrupoOrcamento(garantia, grupoOrcamento);
        GarantiaSeguradoOrcamento__c     garantiaSeguradoOrcamento    = gerarGarantiaSeguradoOrcamento(garantia, seguradoOrcamento);
        RemuneracaoOrcamento__c         remuneracaoOportunidade      = gerarRemuneracaoOrcamento(orcamento,tipoRemuneracaoParaCanal);

        Roteamento__c                   roteamento                   = gerarRoteamento(orcamento);


        // popula Map
        inserirSObject(mapListObject, 'Account',                       corretor);
        inserirSObject(mapListObject, 'Roteamento__c',                   roteamento);
        inserirSObject(mapListObject, 'Opportunity',                     orcamento);
        inserirSObject(mapListObject, 'ContratanteOrcamento__c',         contratanteOrcamento);
        inserirSObject(mapListObject, 'GrupoOrcamento__c',               grupoOrcamento);
        inserirSObject(mapListObject, 'SeguradoOrcamento__c',            seguradoOrcamento);
        inserirSObject(mapListObject, 'GarantiaOrcamento__c',            garantiaOrcamento);
        inserirSObject(mapListObject, 'GarantiaContratanteOrcamento__c', garantiaContratanteOrcamento);
        inserirSObject(mapListObject, 'GarantiaGrupoOrcamento__c',       garantiaGrupoOrcamento);
        inserirSObject(mapListObject, 'GarantiaSeguradoOrcamento__c',     garantiaSeguradoOrcamento);
        inserirSObject(mapListObject, 'RemuneracaoOrcamento__c',         remuneracaoOportunidade);

        return mapListObject;
    }
    // PLV-2312-28 FIM

    // PLV-2312-28 INICIO
    public static Map<String,List<SObject>> gerarProposta(Boolean gerarParceiro)
    {
        // Gerar orcamento e seus filhos
        Map<String,List<SObject>> mapListObject = gerarOrcamento(gerarParceiro);

        // Pega os dados filhos
        Product2            produtoComercial = (Product2)           pegarRegistro(mapListObject, 'Product2');
        RamoSeguro__c       ramoSeguro       = (RamoSeguro__c)      pegarRegistro(mapListObject, 'RamoSeguro__c');
        Account             conta            = (Account)            pegarRegistro(mapListObject, 'Account');
        GarantiaProduto__c  garantiaProduto  = (GarantiaProduto__c) pegarRegistro(mapListObject, 'GarantiaProduto__c');
        FormaPagamento__c   formaPagamento   = (FormaPagamento__c)  pegarRegistro(mapListObject, 'FormaPagamento__c');
        Opportunity         orcamento        = (Opportunity)        pegarRegistro(mapListObject, 'Opportunity');
        TipoRemuneracao__c  tipoRemuneracao  = (TipoRemuneracao__c) pegarRegistro(mapListObject, 'TipoRemuneracao__c');
        Modalidade__c       modalidade       = (Modalidade__c)      pegarRegistro(mapListObject, 'Modalidade__c');
        Garantia__c         garantia         = (Garantia__c)        pegarRegistro(mapListObject, 'Garantia__c');

        // Geracao da proposta
        DadosCorretor__c                dadosCorretor                = gerarDadosCorretor(conta);

        Quote                           proposta                     = gerarPropostaObjeto(produtoComercial, ramoSeguro, conta, dadosCorretor,orcamento, modalidade);
        ContratanteProposta__c          contratanteProposta          = gerarContratanteProposta(conta, proposta, formaPagamento);
        GrupoProposta__c                grupoProposta                = gerarGrupoProposta(contratanteProposta);
        SeguradoProposta__c             seguradoProposta             = gerarSeguradoProposta(conta, grupoProposta, formaPagamento);
        BeneficiarioSeguradoProposta__c beneficiarioSeguradoproposta = gerarBeneficiarioSeguradoProposta(conta, seguradoProposta);

        GarantiaProposta__c             garantiaProposta             = gerarGarantiaProposta(proposta, garantiaProduto);
        GarantiaContratanteProposta__c  garantiaContratanteProposta  = gerarGarantiaContratanteProposta(garantia, contratanteProposta);
        GarantiasGrupoProposta__c       garantiaGrupoProposta        = gerarGarantiaGrupoProposta(garantia, grupoProposta);
        GarantiaSeguradoProposta__c     garantiaSeguradoProposta     = gerarGarantiaSeguradoProposta(garantia, seguradoProposta);

        RemuneracaoProposta__c          remuneracaoProposta          = gerarRemuneracaoProposta(proposta,tipoRemuneracao);
        FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta = gerarFavorecidoRemuneracaoProposta(remuneracaoProposta, conta);
        CriticaProposta__c              criticaproposta              = gerarCriticaProposta(proposta);


        inserirSObject(mapListObject, 'DadosCorretor__c',                   dadosCorretor);
        inserirSObject(mapListObject, 'Quote',                              proposta);
        inserirSObject(mapListObject, 'ContratanteProposta__c',             contratanteProposta);
        inserirSObject(mapListObject, 'GrupoProposta__c',                   grupoProposta);
        inserirSObject(mapListObject, 'SeguradoProposta__c',                seguradoProposta);
        inserirSObject(mapListObject, 'BeneficiarioSeguradoProposta__c',    beneficiarioSeguradoproposta);
        inserirSObject(mapListObject, 'GarantiaProposta__c',                garantiaProposta);
        inserirSObject(mapListObject, 'GarantiaContratanteProposta__c',     garantiaContratanteProposta);
        inserirSObject(mapListObject, 'GarantiasGrupoProposta__c',          garantiaGrupoProposta);
        inserirSObject(mapListObject, 'GarantiaSeguradoProposta__c',        garantiaSeguradoProposta);
        inserirSObject(mapListObject, 'RemuneracaoProposta__c',             remuneracaoProposta);
        inserirSObject(mapListObject, 'CriticaProposta__c',                 criticaproposta);

        return mapListObject;
    }
    // PLV-2312-28 FIM

    // PLV-2312-28 INICIO
    public static Map<String,List<SObject>> gerarContrato(Boolean gerarParceiro)
    {
        Map<String,List<SObject>> mapListObject = gerarProposta(gerarParceiro);

        // Pega os dados filhos
        Product2            produtoComercial = (Product2)           pegarRegistro(mapListObject, 'Product2');
        Garantia__c         garantia         = (Garantia__c)        pegarRegistro(mapListObject, 'Garantia__c');
        RamoSeguro__c       ramoSeguro       = (RamoSeguro__c)      pegarRegistro(mapListObject, 'RamoSeguro__c');
        Account             conta            = (Account)            pegarRegistro(mapListObject, 'Account');
        
        //PLV-2421 - Inicio - Lógica para atender cobertura de classe de teste
        GarantiaProduto__c garanProd = new GarantiaProduto__c(
            	Garantia__c = garantia.Id,
                Produto__c = produtoComercial.Id,
                OrdemPrioridade__c = 3,
            	//PLV-2703 - Inicio - Adição de campos para classe de teste
            	LimiteCapitalMinimo__c = 100,
            	LimiteCapitalMaximo__c = 5000,
            	//PLV-2703 - Fim - Adição de campos para classe de teste
            	TipoGarantia__c = 'Cobertura',
                TipoCapital__c = 'Capital uniforme',
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id,
                CaracteristicaGarantia__c = 'Adicional',
                Obrigatoria__c = true);
        insert garanProd;
        
        GarantiaProduto__c garanProd2 = new GarantiaProduto__c(
            	Garantia__c = garantia.Id,
                Produto__c = produtoComercial.Id,
                OrdemPrioridade__c = 2,
            	//PLV-2703 - Inicio - Adição de campos para classe de teste
            	LimiteCapitalMinimo__c = 100,
            	LimiteCapitalMaximo__c = 5000,
            	//PLV-2703 - Fim - Adição de campos para classe de teste
            	TipoGarantia__c = 'Cobertura',
                TipoCapital__c = 'Capital uniforme',
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id,
                CaracteristicaGarantia__c = 'Principal',
                Obrigatoria__c = true);
        insert garanProd2;
        //PLV-2421 - Fim - Lógica para atender cobertura de classe de teste
        
        //PLV-2703 - Inicio - Criação de objetos para aumento de cobertura
        TipoRemuneracao__c tipoRemuneracaoAgenciamento = new TipoRemuneracao__c();
		tipoRemuneracaoAgenciamento.Name = 'Agenciamento';
		tipoRemuneracaoAgenciamento.Descricao__c = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit.';
		tipoRemuneracaoAgenciamento.ModeloRecuperacao__c = 'Integral';
		insert tipoRemuneracaoAgenciamento;
        
        RemuneracaoProduto__c remProd = new RemuneracaoProduto__c();
        remProd.Produto__c = produtoComercial.Id;
        remProd.TipoRemuneracao__c = tipoRemuneracaoAgenciamento.Id;
        remProd.ParcelasAgenciamento__c = '1ª parcela';
        insert remProd;
        //PLV-2703 - Fim - Criação de objetos para aumento de cobertura
        
        GarantiaProduto__c  garantiaProduto  = (GarantiaProduto__c) pegarRegistro(mapListObject, 'GarantiaProduto__c');
        FormaPagamento__c   formaPagamento   = (FormaPagamento__c)  pegarRegistro(mapListObject, 'FormaPagamento__c');
        Opportunity         orcamento        = (Opportunity)        pegarRegistro(mapListObject, 'Opportunity');
        TipoRemuneracao__c  tipoRemuneracao  = (TipoRemuneracao__c) pegarRegistro(mapListObject, 'TipoRemuneracao__c');
        DadosCorretor__c    dadosCorretor    = (DadosCorretor__c)   pegarRegistro(mapListObject, 'DadosCorretor__c');
        Quote               proposta         = (Quote)              pegarRegistro(mapListObject, 'Quote');

        // Busca o parceiro
        List<Parceiro__c> listParceiro = [SELECT Id, Conta__c FROM Parceiro__c];

        Account contaParceiro;
        if(!listParceiro.isEmpty() && listParceiro[0].Conta__c != null){
            contaParceiro = new Account(Id = listParceiro[0].Conta__c);
        }

        // Geracao do contrato
        Contract                        contrato                    = gerarContratoObjeto(produtoComercial, ramoSeguro, conta, dadosCorretor, proposta);
        ContratanteContrato__c          contratanteContrato         = gerarContratanteContrato(contrato, conta, contaParceiro);
        GrupoContrato__c                grupoContrato               = gerarGrupoContrato(contratanteContrato);
        SeguradoContrato__c             seguradoContrato            = gerarSeguradoContrato(grupoContrato, conta);
        GarantiaContrato__c             garantiaContrato            = gerarGarantiaContrato(contrato, garantiaProduto);
        GarantiaContratanteContrato__c  garantiaContratanteContrato = gerarGarantiaContratanteContrato(garantia, contratanteContrato);
        GarantiaGrupoContrato__c        garantiaGrupoContrato       = gerarGarantiaGrupoContrato(garantia, grupoContrato);
        GarantiaSeguradoContrato__c     garantiaSeguradoContrato    = gerarGarantiaSeguradoContrato(garantia, seguradoContrato);
        RemuneracaoContrato__c          remuneracaoContrato         = gerarRemuneracaoContrato(contrato, tipoRemuneracao);
        
        //PLV2569 - INICIO AVX - Ajuste para aumentar cobertura de testes da classe OrcamentoGenericoBuilder.               
        CanalDistribuicao__c canalDistribuicao = new CanalDistribuicao__c();
        canalDistribuicao.Sigla__c = 'EXE';
        canalDistribuicao.Name = 'Teste AVX';
        canalDistribuicao.Status__c = 'Em Ativação';
        
        insert canalDistribuicao;
        
        canalDistribuicao.Status__c = 'Ativo';
            
        update canalDistribuicao;
        
        ProdutoCanal__c produtoCanalGerado = new ProdutoCanal__c();
        produtoCanalGerado.CanalDistribuicao__c = canalDistribuicao.Id;
        produtoCanalGerado.Produto__c = produtoComercial.Id;
        
        insert produtoCanalGerado;
        //PLV2569 - FIM AVX - Ajuste para aumentar cobertura de testes da classe OrcamentoGenericoBuilder.
        
        //PLV-2703 - Inicio - Criação de objetos para aumento de cobertura
        RemuneracaoCanal__c remCanal = new RemuneracaoCanal__c();
        remCanal.ProdutoCanal__c = produtoCanalGerado.Id;
        remCanal.TipoRemuneracao__c = tipoRemuneracaoAgenciamento.Id;
        remCanal.ParcelasAgenciamento__c = '1ª parcela';
        insert remCanal;
        //PLV-2703 - Fim - Criação de objetos para aumento de cobertura
        
        //PLV-2421- Inicio - Lógica para atender cobertura de classe de teste
        	//Criar Pegunta
        	Pergunta__c pergunta = gerarPergunta();
        	//Criar questionario
        	Questionario__c questionario = new Questionario__c(
            	Name = 'Q2',
                Status__c = 'Ativo' //PLV-4165
                //PLV-2771 - Codigo removido devido a exclusão do campo
            );
        	insert questionario;
        	//Criar Pergunta do questionario
        	PerguntaQuestionario__c pergQuest = gerarPerguntaQuestionario(questionario, pergunta);
        	//Criar Questionario do Produto
        	QuestionarioProduto__c questProd = new QuestionarioProduto__c(
                Produto__c = produtoComercial.Id,
                Questionario__c = questionario.Id,
                GarantiaProduto__c = garanProd.Id,
                LimiteCapitalMinimo__c = 100,
                LimiteCapitalMaximo__c = 1000,
                Prioridade__c = 2);
        insert questProd;
        //PLV-2421 - Fim - Lógica para atender cobertura de classe de teste

        inserirSObject(mapListObject, 'Contract',                       contrato);
        inserirSObject(mapListObject, 'ContratanteContrato__c',         contratanteContrato);
        inserirSObject(mapListObject, 'GrupoContrato__c',               grupoContrato);
        inserirSObject(mapListObject, 'SeguradoContrato__c',            seguradoContrato);
        inserirSObject(mapListObject, 'GarantiaContrato__c',            garantiaContrato);
        inserirSObject(mapListObject, 'GarantiaContratanteContrato__c', garantiaContratanteContrato);
        inserirSObject(mapListObject, 'GarantiaGrupoContrato__c',       garantiaGrupoContrato);
        inserirSObject(mapListObject, 'GarantiaSeguradoContrato__c',    garantiaSeguradoContrato);
        inserirSObject(mapListObject, 'RemuneracaoContrato__c',         remuneracaoContrato);
		
        // Codigo removido por conta da historia PLV-3460 Fix 5
        return mapListObject;
    }
    // PLV-2312-28 FIM

    //INICIO | PLV-2266-28

    public static Pagamento__x mapeiaPagamento( Account conta, string status)
    {
        Pagamento__x pgto = new Pagamento__x(
			Id__c = 133,
			IdConta__c = conta.Id,
			CnpjCpf__c = '305.699.878-65',
			Matricula__c = 'P0610277',
			Status__c = status,
			SusepCorretor__c = 'REN01J',
			TipoConta__c = 'Beneficiário',
			TipoPagamento__c = 'REMUNERACAO',
			tributacao__c = false,
			ValorBruto__c = 300.00,
			ValorPagamento__c = 300.00000,
			Descricao__c = 'Pagamento Sinistro 1.1377.2019.500481'
		);

        return pgto;
    }

    //INICIO | PLV-2233-27-v2
    public static NotaFiscal__c mapeiaNotaFiscal(Integer idPagamento, String status)
    {
        NotaFiscal__c nf = new NotaFiscal__c();
        nf.Pagamento__c = String.valueOf(idPagamento);
        nf.StatusAprovacao__c = status;
        nf.DataEmissaoNotaFiscal__c = System.today(); 
        nf.FormaPagamento__c  ='Crédito em Conta Corrente';
        nf.NumeroNotaFiscal__c =  '125125';
        nf.TipoNotaFiscal__c = 'Fiscal de Serviços';

        return nf;
    }
    //FIM | PLV-2233-27-v2

    //FIM | PLV-2266-28

    // Pega a lista do mapa
    public static List<SObject> pegarListaSObjects(Map<String,List<SObject>> mapa, String chave)
    {
        List<SObject> listSObject = mapa.get(chave);
        if(listSObject == null) listSObject = new List<SObject>();
        return listSObject;
    }

    public static void inserirSObject(Map<String,List<SObject>> mapa, String chave, SObject sObj)
    {
        List<sObject> listSObjects = pegarListaSObjects(mapa,chave);
        listSObjects.add(sObj);
        mapa.put(chave,listSObjects);
    }

    public static SObject pegarRegistro(Map<String,List<SObject>> mapa, String chave)
    {
        List<SObject> listAux = pegarListaSObjects(mapa, chave);
        return listAux[0];
    }    
}