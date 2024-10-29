/*********************************************************************************************************************************************************************
@description Classe teste responsavel por testar metodos que auxiliam na montagem do payload
@author Uverlanio Silva - Globant
@date 23/02/2023
**********************************************************************************************************************************************************************/
//LECVP-72 - INICIO
@isTest
public class ContractFacadeReenvioTest {

    @TestSetup
    static void makeData(){

        initReenvioContratoTO();

        Account conta = gerarConta();
        Contract contrato = gerarContrato(conta);
        CanalDistribuicao__c canalDistribuicao = gerarCanalDistribuicao();
        Opportunity orcamento = gerarOrcamento(canalDistribuicao);
        Product2 produto = gerarProduto();
        RamoSeguro__c ramoSeguro = gerarRamoSeguro();
        Quote proposta = gerarProposta(conta, orcamento, contrato, produto, ramoSeguro);
    }
    
    @isTest static void testarMapeiaReenvioPayload(){       

        Test.startTest();
        
        Quote proposta = getPropostaQuery();
        Contract contrato = getContratoQuery();       

        Map<String, String> mapPropostaApolice = new Map<String, String>();
        mapPropostaApolice.put(proposta.NumeroProposta__c, contrato.NumeroApolice__c);

        ReenvioContratoTO.PayloadTO retorno = ContractFacadeReenvio.getInstance().mapeiaReenvioPayload(proposta, mapPropostaApolice);

        System.assert(retorno.contrato != null);

        Test.stopTest();        
    }

    @isTest static void testarMapeiaReenvioPayloadEndosso() {       

        Test.startTest();

        Quote proposta = getPropostaQuery();
        
        Contract contrato = getContratoQuery();

        proposta.Tipo__c = 'Endosso';
        proposta.Contract = contrato;

        update proposta;

        Map<String, String> mapPropostaApolice = new Map<String, String>();
        mapPropostaApolice.put(proposta.NumeroProposta__c, contrato.NumeroApolice__c);

        ReenvioContratoTO.PayloadTO retorno = ContractFacadeReenvio.getInstance().mapeiaReenvioPayload(proposta, mapPropostaApolice);

        System.assert(retorno.contrato != null);

        Test.stopTest();        
    }

    @isTest static void testarMapeiaReenvioPayloadCancelamento() {       

        Test.startTest();

        Quote proposta = getPropostaQuery();
        
        Contract contrato = getContratoQuery();

        proposta.Tipo__c = 'Cancelamento';
        proposta.Contract = contrato;

        update proposta;

        Map<String, String> mapPropostaApolice = new Map<String, String>();
        mapPropostaApolice.put(proposta.NumeroProposta__c, contrato.NumeroApolice__c);

        Test.stopTest();       

        ReenvioContratoTO.PayloadTO retorno = ContractFacadeReenvio.getInstance().mapeiaReenvioPayload(proposta, mapPropostaApolice);

        System.assert(retorno.contrato != null);
    }

    @isTest static void testarParseDadosTelefonesReenvio(){

        Test.startTest();

        List<ReenvioContratoTO.TelefonesTO> telefones = new List<ReenvioContratoTO.TelefonesTO>();
        
        Account conta = getContaQuery();

        telefones = ContractFacadeReenvio.getInstance().parseDadosTelefoneReenvio(conta);

        System.assert(!telefones.isEmpty());

        Test.stopTest();
    }

    @isTest static void testarParseDadosEnderecosReenvio(){

        Test.startTest();

        List<ReenvioContratoTO.EnderecosTO> enderecos = new List<ReenvioContratoTO.EnderecosTO>();
        List<Endereco__c> lstEnderecos = new List<Endereco__c>();
    
        Account conta = getContaQuery();
        Endereco__c endereco = gerarEndereco(conta);

        lstEnderecos.add(endereco);        

        enderecos = ContractFacadeReenvio.getInstance().parseDadosEnderecosReenvio(lstEnderecos, conta.Id);

        System.assert(!enderecos.isEmpty());

        Test.stopTest();
    }

    @isTest static void testarParseDadosParcelasReenvio(){

        Test.startTest();

        List<ReenvioContratoTO.ParcelasTO> parcelas = new List<ReenvioContratoTO.ParcelasTO>();

        Integer quantidadeParcelas = 2;
        Decimal iof = 10.00;
        Decimal valor = 2.00;
        String codFormaPgto = 'Dinheiro';
        Date vencPrimeiraParc = Date.today() + 20;

        parcelas = ContractFacadeReenvio.getInstance().parseDadosParcelasReenvio(quantidadeParcelas, iof, valor, codFormaPgto, vencPrimeiraParc);

        System.assert(!parcelas.isEmpty());

        Test.stopTest();
    }

    @isTest static void testarRetornarNumeroEndosso(){

        Test.startTest();

        List<Contract> listaContratos = new List<Contract>();

        Account conta = getContaQuery();

        Contract contrato = getContratoQuery();

        listaContratos.add(contrato);

        Integer numeroEndosso = ContractFacadeReenvio.getInstance().retornarNumeroEndosso(listaContratos);

        System.assert(numeroEndosso > -1);

        Test.stopTest();
    }

    @isTest static void testarParseDadosGrupoReenvio(){

        Test.startTest();

        List<ReenvioContratoTO.GruposTO> listaGrupo = new List<ReenvioContratoTO.GruposTO>();

        List<GrupoProposta__c> gruposProp = new List<GrupoProposta__c>();

        Quote proposta = getPropostaQuery();

        Id idRamo = proposta.RamoSeguro__c;

        Map<String, RecordType> mapRecordType = new Map<String, RecordType>();
        for(RecordType tipo: RecordTypeDAO.getInstance().getListRecordTypeBySobject('Account')){
            mapRecordType.put(tipo.Id, tipo);
        }

        GrupoProposta__c grupoProposta = gerarGrupoProposta();

        gruposProp.add(grupoProposta);
        
        listaGrupo = ContractFacadeReenvio.getInstance().parseDadosGrupoReenvio(gruposProp, proposta.Id, idRamo, mapRecordType);

        System.assert(!listaGrupo.isEmpty());

        Test.stopTest();
    }

    @isTest static void testarParseDadosPagamentoReenvio(){

        Test.startTest();
        
        Account responsavelPagamento = getContaQuery();
        responsavelPagamento.Name = 'teste';
        FormaPagamento__c formaPagamento = gerarFormaPagamento();
        ContratanteProposta__c contratanteProposta = gerarContratanteProposta(responsavelPagamento, formaPagamento);        
        SeguradoProposta__c seguradoProposta = gerarSeguradoProposta(responsavelPagamento, formaPagamento);      

        Map<String, RecordType> mapRecordType = new Map<String, RecordType>();
        for(RecordType tipo: RecordTypeDAO.getInstance().getListRecordTypeBySobject('Account')){
            mapRecordType.put(tipo.Id, tipo);
        }

        ReenvioContratoTO.DadospagamentoTO retornoContratante = ContractFacadeReenvio.getInstance().parseDadosPagamentoReenvio('Contratante', contratanteProposta, seguradoProposta, mapRecordType);

        System.assert(retornoContratante != null);

        responsavelPagamento.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaJuridica').Id;
        contratanteProposta = gerarContratanteProposta(responsavelPagamento, formaPagamento);

        retornoContratante = ContractFacadeReenvio.getInstance().parseDadosPagamentoReenvio('Contratante', contratanteProposta, null, mapRecordType);

        System.assert(retornoContratante != null);

        ReenvioContratoTO.DadospagamentoTO retornoSegurado = ContractFacadeReenvio.getInstance().parseDadosPagamentoReenvio('Segurado', contratanteProposta, seguradoProposta, mapRecordType);

        System.assert(retornoSegurado != null);

        responsavelPagamento.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaJuridica').Id;
        seguradoProposta = gerarSeguradoProposta(responsavelPagamento, formaPagamento);

        retornoSegurado = ContractFacadeReenvio.getInstance().parseDadosPagamentoReenvio('Segurado', null, seguradoProposta, mapRecordType);

        System.assert(retornoSegurado != null);

        Test.stopTest();
    }

    @isTest static void testarParseDadosContratantesReenvio(){

        Test.startTest();

        List<ContratanteProposta__c> lstContratanteProposta = new List<ContratanteProposta__c>();
        Account responsavelPagamento = getContaQuery();
        responsavelPagamento.Name = 'teste';
        FormaPagamento__c formaPagamento = gerarFormaPagamento();
        ContratanteProposta__c contratanteProposta = gerarContratanteProposta(responsavelPagamento, formaPagamento);

        lstContratanteProposta.add(contratanteProposta);

        Quote proposta = getPropostaQuery();

        Id idRamo = proposta.RamoSeguro__c;

        Map<String, RecordType> mapRecordType = new Map<String, RecordType>();
        for(RecordType tipo: RecordTypeDAO.getInstance().getListRecordTypeBySobject('Account')){
            mapRecordType.put(tipo.Id, tipo);
        }

        List<ReenvioContratoTO.ContratantesTO> listaRetorno = ContractFacadeReenvio.getInstance().parseDadosContratantesReenvio(lstContratanteProposta, idRamo, mapRecordType);

        System.assert(!listaRetorno.isEmpty());

        responsavelPagamento.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaJuridica').Id;
        contratanteProposta = gerarContratanteProposta(responsavelPagamento, formaPagamento);
        lstContratanteProposta.add(contratanteProposta);

        listaRetorno = ContractFacadeReenvio.getInstance().parseDadosContratantesReenvio(lstContratanteProposta, idRamo, mapRecordType);

        System.assert(!listaRetorno.isEmpty());

        Test.stopTest();
    }

    @isTest static void testarAlteracoesEndossoReenvio(){

        Test.startTest();

        Quote cotacao = getPropostaQuery();

        List<ReenvioContratoTO.AlteracoesEndossoTO> listaRetorno = ContractFacadeReenvio.getInstance().parseDadosAlteracoesEndossoReenvio(cotacao);

        System.assert(!listaRetorno.isEmpty());

        cotacao.SiglaTipoEndosso__c = '';
        update cotacao;

        listaRetorno = ContractFacadeReenvio.getInstance().parseDadosAlteracoesEndossoReenvio(cotacao);

        System.assert(listaRetorno.isEmpty());

        Test.stopTest();
    }

    @isTest static void testarParseSeguradosGrupoReenvio(){

        Test.startTest();

        List<SeguradoProposta__c> seguradosGrupo = new List<SeguradoProposta__c>();
        Account responsavelPagamento = getContaQuery();
        responsavelPagamento.Name = 'teste';
        FormaPagamento__c formaPagamento = gerarFormaPagamento();
        SeguradoProposta__c seguradoProposta = new SeguradoProposta__c();

        seguradoProposta = gerarSeguradoProposta(responsavelPagamento, formaPagamento);
        seguradosGrupo.add(seguradoProposta);

        Quote proposta = getPropostaQuery();

        Id idRamo = proposta.RamoSeguro__c;

        Map<String, RecordType> mapRecordType = new Map<String, RecordType>();
        for(RecordType tipo: RecordTypeDAO.getInstance().getListRecordTypeBySobject('Account')){
            mapRecordType.put(tipo.Id, tipo);
        }

        List<ReenvioContratoTO.SeguradosTO> listaRetorno = new List<ReenvioContratoTO.SeguradosTO>();
        
        listaRetorno =  ContractFacadeReenvio.getInstance().parseSeguradosGrupoReenvio(seguradosGrupo, proposta.Id, idRamo, mapRecordType);

        System.assert(!listaRetorno.isEmpty());

        responsavelPagamento.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaJuridica').Id;
        seguradoProposta = gerarSeguradoProposta(responsavelPagamento, formaPagamento);
        seguradosGrupo.add(seguradoProposta);

        listaRetorno = ContractFacadeReenvio.getInstance().parseSeguradosGrupoReenvio(seguradosGrupo, proposta.Id, idRamo, mapRecordType);

        System.assert(!listaRetorno.isEmpty());

        Test.stopTest();
    }

    @isTest static void testarParseDadosCoberturasReenvio(){

        Test.startTest();

        List<GarantiaProposta__c> lstGarantiaProposta = new List<GarantiaProposta__c>();
        RecordType recordType = new RecordType();
        Garantia__c garantia = gerarGarantia();
        Franquia__c franquia = gerarFranquia();
        GarantiaProduto__c garantiaProduto = gerarGarantiaProduto(garantia);
        GarantiaProposta__c garantiaProposta = gerarGarantiaProposta(garantia, garantiaProduto);
        Carencia__c carencia = gerarCarencia();
        recordType = RecordTypeDAO.getInstance().getListRecordTypeBySobject('CarenciaGarantia__c')[0];
        CarenciaGarantia__c carenciaGarantia = gerarCarenciaGarantia(carencia, garantiaProduto, recordType);
        recordType = RecordTypeDAO.getInstance().getListRecordTypeBySobject('FranquiaGarantia__c')[0];
        FranquiaGarantia__c franquiaGarantia = gerarFranquiaGarantia(franquia, garantiaProduto, recordType);
        Quote proposta = getPropostaQuery();

        Id idRamo = proposta.RamoSeguro__c;

        lstGarantiaProposta.add(garantiaProposta);

        List<ReenvioContratoTO.CoberturasTO> retornoLista = ContractFacadeReenvio.getInstance().parseDadosCoberturasReenvio(lstGarantiaProposta, idRamo);

        System.assert(!retornoLista.isEmpty());

        Test.stopTest();
    }

    @isTest static void testarParseDadosBeneficiarioSeguradoReenvio(){

        Test.startTest();

        List<BeneficiarioSeguradoProposta__c> beneficiariosVida = new List<BeneficiarioSeguradoProposta__c>();
        BeneficiarioSeguradoProposta__c beneficiarioSeguradoProposta = gerarBeneficiarioSeguradoProposta();

        beneficiariosVida.add(beneficiarioSeguradoProposta);

        List<ReenvioContratoTO.BeneficiariosTO> retornoLista = ContractFacadeReenvio.getInstance().parseDadosBeneficiarioSeguradoReenvio(beneficiariosVida);

        System.assert(!retornoLista.isEmpty());

        Test.stopTest();
    }

    @isTest static void testarCalculaPremioLiquido(){

        Test.startTest();

        Decimal premioTotal = 1000;
        Decimal valorIof = 2;

        Decimal retorno = ContractFacadeReenvio.getInstance().calculaPremioLiquido(premioTotal, valorIof);

        System.assert(retorno != null);

        premioTotal = 0;
        valorIof = 2;        
        
        retorno = ContractFacadeReenvio.getInstance().calculaPremioLiquido(premioTotal, valorIof);

        System.assert(retorno == 0);

        premioTotal = null;
        valorIof = null;

        retorno = ContractFacadeReenvio.getInstance().calculaPremioLiquido(premioTotal, valorIof);

        System.assert(retorno == 0);

        Test.stopTest();

    }

    @isTest static void parseDadosRemuneracaoReenvio(){

        Test.startTest();

        String canal = '1';
        String numeroSusep = 'P5005J';
        String sucursal = '1';

        List<RemuneracaoProposta__c> lstRemuneracao = new List<RemuneracaoProposta__c>();
        Quote proposta = getPropostaQuery();
        Account conta = getContaQuery();
        TipoRemuneracao__c tipoRemuneracao = gerarTipoRemuneracao();
        RemuneracaoProposta__c remuneracaoProposta = gerarRemuneracaoProposta(proposta, tipoRemuneracao);
        DadosCorretor__c dadosCorretor = gerarDadosCorretor();
        FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta = gerarFavorecidoRemuneracaoProposta(conta, remuneracaoProposta, dadosCorretor);

        lstRemuneracao.add(remuneracaoProposta);

        Map<String, RecordType> mapRecordType = new Map<String, RecordType>();
        for(RecordType tipo: RecordTypeDAO.getInstance().getListRecordTypeBySobject('Account')){
            mapRecordType.put(tipo.Id, tipo);
        }

        List<ReenvioContratoTO.RemuneracoesTO> retornoLista = ContractFacadeReenvio.getInstance().parseDadosRemuneracaoReenvio(canal, numeroSusep, sucursal, lstRemuneracao, mapRecordType);

        System.assert(!retornoLista.isEmpty());

        Test.stopTest();
    }

    private static Account gerarConta(){
        
        Account conta =  new Account( 
            LastName = 'teste',
            Cnpj__c = '69979029000163',
            Sexo__c = 'MASCULINO',
            Cpf__c = '96577845069',
            Email__c = 'test@globant.com',
            PersonEmail = 'test@globant.com',
            Phone = '(11)3131-4252',
            PersonHomePhone = '(11)98563-9852',
            PersonOtherPhone = '(11)98563-9752',
            PersonMobilePhone = '(11)98563-9952',
            Fax = '(11)98563-9252',
            EstadoCivil__c = 'Casado (a)',
            PersonBirthdate = Date.today().addYears(-19),
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica').Id
        );

        insert conta;

        return conta;
    }

    private static Contract gerarContrato(Account conta){

        Contract contrato = new Contract(
            Name = 'teste2',
            StartDate = Date.today(),
            VigenciaFinal__c = Date.today().addYears(1),
            DataEmissao__c = Date.today(),
            NumeroApolice__c = '000001834',
            NumeroProposta__c = '00001234',
            AccountId = conta.Id
        );

        insert contrato;

        return contrato;
    }

    private static CanalDistribuicao__c gerarCanalDistribuicao(){
        
        CanalDistribuicao__c canalDistribuicao = new CanalDistribuicao__c(
            Name = 'teste',
            Sigla__c = 'COR'
        );

        return canalDistribuicao;
    }

    private static Opportunity gerarOrcamento(CanalDistribuicao__c canalDistribuicao){
        
        Opportunity orcamento = new Opportunity(
            Name = 'teste',
            StageName = 'Em criação',
            CloseDate = Date.today(),
            CanalDistribuicao__c = canalDistribuicao.Id
        );

        insert orcamento;

        return orcamento;
    }

    private static Product2 gerarProduto(){

        Product2 produto = new Product2(
            Name = 'teste'
        );

        return produto;
}

    private static Quote gerarProposta(Account conta, Opportunity orcamento, Contract contrato, Product2 produto, RamoSeguro__c ramoSeguro){

        Quote proposta = new Quote(
            Name = 'teste',
            Tipo__c = 'Novo',
            SiglaTipoEndosso__c = 'CAD',
            Contract = contrato,
            NumeroProposta__c = '00001234',
            OpportunityId = orcamento.Id,
            Produto__c = produto.Id,
            Empresa__c = conta.Id,
            VigenciaInicial__c = Date.today(),
            VigenciaFinal__c = Date.today().addYears(1),
            RamoSeguro__c = ramoSeguro.Id, 
            Origem__c = '18',
            Opportunity = orcamento       
        );

        insert proposta;

        return proposta;
    }

    private static RamoSeguro__c gerarRamoSeguro(){
        RamoSeguro__c ramoSeguro = new RamoSeguro__c(
            Name = 'teste',
            Codigo__c = '1',
            CodigoOrigemDoMovimentoBCP__c = '1'
        );

        return ramoSeguro;
    }

    private static TipoRemuneracao__c gerarTipoRemuneracao(){
        TipoRemuneracao__c tipoRemuneracao = new TipoRemuneracao__c(
            Name = 'teste',
            Codigo__c = 'COR'
        );
        
        insert tipoRemuneracao; 

        return tipoRemuneracao;
    }

    private static RemuneracaoProposta__c gerarRemuneracaoProposta(Quote proposta, TipoRemuneracao__c tipoRemuneracao){
        
        RemuneracaoProposta__c remuneracaoProposta = new RemuneracaoProposta__c(
            TipoRemuneracao__r = tipoRemuneracao,
            TipoRemuneracao__c = tipoRemuneracao.Id,                    
            Porcentagem_de_Retencao__c = 10.00,
            Percentual__c = 10.00,
            Proposta__c = proposta.Id
        );

        insert remuneracaoProposta;

        return remuneracaoProposta;
    }

    private static DadosCorretor__c gerarDadosCorretor(){

        DadosCorretor__c dadosCorretor = new DadosCorretor__c(
            Name = 'teste',
            SucursalVinculo__c = '1',
            CodigoSucursalVinculo__c = '1'
        );
        
        insert dadosCorretor;

        return dadosCorretor;
    }

    private static FavorecidoRemuneracaoProposta__c gerarFavorecidoRemuneracaoProposta(Account conta, RemuneracaoProposta__c remuneracaoProposta, DadosCorretor__c dadosCorretor){
        
        FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta = new FavorecidoRemuneracaoProposta__c(
            Conta__c = conta.Id,
            Conta__r = conta,
            CorretorLider__c = true,
            Papel__c = 'Corretor',
            Participacao__c = 10.00,
            RemuneracaoProposta__c = remuneracaoProposta.Id,
            Susep__c = 'p5005j',
            SusepEmissao__c = 'p5005j',
            SusepOficialCorretor__c = '123',
            SusepOrcamento__c = 'p5005j',
            AntecipacaoComissao__c = true,
            DadosCorretor__c = dadosCorretor.Id
        );

        insert favorecidoRemuneracaoProposta;

        return favorecidoRemuneracaoProposta;
    }

    private static Endereco__c gerarEndereco(Account conta){

        Endereco__c endereco = new Endereco__c(
            Conta__c = conta.Id,
            TipoLogradouro__c = 'Rua',
            Cidade__c = 'Sao Paulo',
            TipoEndereco__c = 'Comercial',
            Logradouro__c = 'teste',
            Bairro__c = 'teste',
            CEP__c = '12345-123',
            Estado__c = 'SP',
            Numero__c = '10',
            Pais__c = 'BRA',
            Complemento__c = 'N/A'             
        );
    
        insert endereco;

        return endereco;
    }

    private static GrupoProposta__c gerarGrupoProposta(){
        GrupoProposta__c grupoProposta = new GrupoProposta__c(
            Name = 'teste',
            Descricao__c = '10',
            QuantidadeVidas__c = 10.00
        );

        insert grupoProposta;

        return grupoProposta;
    }

    private static FormaPagamento__c gerarFormaPagamento(){

        FormaPagamento__c formaPagamento = new FormaPagamento__c(
            Name = 'teste',
            Codigo__c = '41'
        );

        return formaPagamento;
    }

    private static ContratanteProposta__c gerarContratanteProposta(Account responsavelPagamento, FormaPagamento__c formaPagamento){

        ContratanteProposta__c contratanteProposta = new ContratanteProposta__c(
            Tipo__c = 'Principal',
            Numero__c = 0.0,
            Conta__c = responsavelPagamento.Id,
            Conta__r = responsavelPagamento,
            TipoResponsavelPagamento__c = 'CON',
            ResponsavelPagamento__r = responsavelPagamento,
            QuantidadeParcelas__c = 1,
            FormaPagamento__c = formaPagamento.Id,
            IOF__c = 1.0,
            PremioComercial__c = 1000.0,
            VencimentoPrimeiraParcela__c = Date.today().addDays(1)
        );

        insert contratanteProposta;

        return contratanteProposta;
    }

    private static SeguradoProposta__c gerarSeguradoProposta(Account responsavelPagamento, FormaPagamento__c formaPagamento){

        SeguradoProposta__c seguradoProposta = new SeguradoProposta__c(
            Conta__c = responsavelPagamento.Id,
            Conta__r = responsavelPagamento,
            TipoResponsavelPagamento__c = '',
            ResponsavelPagamento__r = responsavelPagamento,
            QuantidadeParcelas__c = 1,
            FormaPagamento__c = formaPagamento.Id,
            IOF__c = 1.0,
            PremioComercial__c = 1000.0,
            VencimentoPrimeiraParcela__c = Date.today().addDays(1),
            FaixaRenda__c = '2500'
        );

        return seguradoProposta;
    }

    private static Garantia__c gerarGarantia(){

        Garantia__c garantia = new Garantia__c(
            Name = 'Morte Acidental',
            Sigla__c = 'DHMO'
        );

        insert garantia;

        return garantia;
    }

    private static Franquia__c gerarFranquia(){
        Franquia__c franquia = new Franquia__c(
            Name = 'teste franquia',
            Descricao__c = 'teste franquia'
        );
        
        insert franquia;

        return franquia;
    }

    private static FranquiaGarantia__c gerarFranquiaGarantia(Franquia__c franquia, GarantiaProduto__c garantiaProduto, RecordType recordType){
        
        FranquiaGarantia__c franquiaGarantia = new FranquiaGarantia__c(
            Franquia__c = franquia.Id,
            FranquiaGarantia__c = 'a0bL0000009vadiIAA',
            GarantiaProduto__c = garantiaProduto.Id,
            PermiteAlterarProdutoComercial__c = true,
            RecordTypeId = recordType.Id,
            Franquia__r = franquia
        );

        return franquiaGarantia;
    }

    private static GarantiaProduto__c gerarGarantiaProduto(Garantia__c garantia){

        GarantiaProduto__c garantiaProduto = new GarantiaProduto__c(
            Garantia__c = garantia.Id,
            TipoGarantia__c = 'Cobertura',
            AmbitoTerritorial__c = 'TerritorioNacional',
            CaracteristicaGarantia__c = 'Principal'
        );

        return garantiaProduto;
    }

    private static GarantiaProposta__c gerarGarantiaProposta(Garantia__c garantia, GarantiaProduto__c garantiaProduto){

        GarantiaProposta__c garantiaProposta = new GarantiaProposta__c(
            GarantiaProduto__c = garantiaProduto.Id,
            Garantia__r = garantia,
            Capital__c = 5000,
            NumeroSorte__c = '1.0',
            NumeroSerie__c = '1.0'
        );

        return garantiaProposta;
    }

    private static Carencia__c gerarCarencia(){

        Carencia__c carencia = new Carencia__c(
            Name = 'teste',
            Descricao__c = 'TESTE12345 - Carencia 2.0'
        );

        return carencia;
    }

    private static CarenciaGarantia__c gerarCarenciaGarantia(Carencia__c carencia, GarantiaProduto__c garantiaProduto, RecordType recordType){

        CarenciaGarantia__c carenciaGarantia = new CarenciaGarantia__c(
            Carencia__c = carencia.Id,
            CarenciaGarantia__c = 'a0BL0000007PjyRMAS',
            GarantiaProduto__c = garantiaProduto.Id,
            PermiteAlterarProdutoComercial__c = true,
            RecordTypeId = recordType.Id,
            Carencia__r = carencia
        );

        return carenciaGarantia;
    }

    private static BeneficiarioSeguradoProposta__c gerarBeneficiarioSeguradoProposta(){

        BeneficiarioSeguradoProposta__c beneficiarioSeguradoProposta = new BeneficiarioSeguradoProposta__c(
            Nome__c = 'teste',
            CpfCnpj__c = '56909582000188',
            Participacao__c = 100,
            Pep__c = 'teste',
            GrauParentesco__c = 'Pai',
            TipoBeneficiario__c	= 'Herdeiros legais, conforme artigo 792 do código civil.'
        );

        return beneficiarioSeguradoProposta;
    }

    private static Quote getPropostaQuery(){
        Quote proposta = [
            SELECT 
                Id,
                NumeroProposta__c,
                Tipo__c,
                Produto__r.Empresa__r.CodigoEmpresa__c,
                VigenciaInicial__c,
                VigenciaFinal__c,
                RamoSeguro__r.Codigo__c,
                RamoSeguro__r.CodigoOrigemDoMovimentoBCP__c,
                Origem__c,
                Opportunity.CanalDistribuicao__r.Sigla__c,
                Empresa__r.Sucursal__c,
                Contract.Sucursal__c,
                Contract.NumeroApolice__c
            FROM 
                Quote
            LIMIT 1
        ];

        return proposta;
    }

    private static Contract getContratoQuery(){
        Contract contrato = [
            SELECT 
                Id, 
                NumeroApolice__c, 
                Sucursal__c, 
                DataEmissao__c,
                Endosso__c
            FROM 
                Contract 
            LIMIT 1
        ];

        return contrato;
    }

    private static Account getContaQuery(){
        Account conta = [
            SELECT
                Id,
                LastName,
                Email__c,
                PersonEmail,
                Cnpj__c,
                Sexo__c,
                Cpf__c,
                Phone,
                PersonHomePhone,
                PersonOtherPhone,
                PersonMobilePhone,
                Fax,
                EstadoCivil__c,
                PersonBirthdate, 
                RecordTypeId
            FROM
                Account
            LIMIT 1
        ];

        return conta;
    }

    private static void initReenvioContratoTO(){
        
        ReenvioContratoTO reenvioContrato = new ReenvioContratoTO();
        ReenvioContratoTO.PayloadTO payload = new ReenvioContratoTO.PayloadTO();
        payload.contrato = new ReenvioContratoTO();
        payload.contrato.codigoSucursal = '';
        
        ReenvioContratoTO.ContratantesTO contratantes = new ReenvioContratoTO.ContratantesTO();
        contratantes.dadosPagamento = new ReenvioContratoTO.DadospagamentoTO();
        contratantes.iof = 0;
        contratantes.premio = new ReenvioContratoTO.PremioTO();
        contratantes.taxa = new ReenvioContratoTO.TaxaTO();
        contratantes.coberturas = new List<ReenvioContratoTO.CoberturasTO>();

        ReenvioContratoTO.GruposTO grupos = new ReenvioContratoTO.GruposTO();
        grupos.iof = 0;
        grupos.premio = new ReenvioContratoTO.PremioTO();
        grupos.taxa = new ReenvioContratoTO.TaxaTO();

        ReenvioContratoTO.CoberturasTO coberturas = new ReenvioContratoTO.CoberturasTO();
        coberturas.iof = 0;
        coberturas.capital = 0;
        coberturas.premio = new ReenvioContratoTO.PremioTO();
        coberturas.taxa = new ReenvioContratoTO.TaxaTO();
        coberturas.franquias = new List<ReenvioContratoTO.FranquiasTO>();
        coberturas.carencias = new List<ReenvioContratoTO.CarenciasTO>();

        ReenvioContratoTO.FavorecidosTO favorecidos = new ReenvioContratoTO.FavorecidosTO();
        favorecidos.papel = '';
        favorecidos.participacao = 0;
        favorecidos.pessoa = new ReenvioContratoTO.PessoaTO();
        favorecidos.corretorLider = true;
        favorecidos.susepOficialCorretor = '';
        favorecidos.susepEmissao = '';
        favorecidos.susepOrcamento = '';
        favorecidos.susep = '';

        ReenvioContratoTO.SeguradosTO segurados = new ReenvioContratoTO.SeguradosTO();
        segurados.iof = 0;
        segurados.premio = new ReenvioContratoTO.PremioTO();
        segurados.taxa = new ReenvioContratoTO.TaxaTO();
        segurados.dadosPagamento = new ReenvioContratoTO.DadospagamentoTO();

        ReenvioContratoTO.ResponsavelPagamentoTO responsavelPagamento = new ReenvioContratoTO.ResponsavelPagamentoTO();
        responsavelPagamento.dadosPessoaFisica = new ReenvioContratoTO.DadosPessoaFisicaTO();

        ReenvioContratoTO.FranquiasTO franquias = new ReenvioContratoTO.FranquiasTO();
        franquias.descricao = '';

        ReenvioContratoTO.CarenciasTO carencias = new ReenvioContratoTO.CarenciasTO();
        carencias.descricao = '';

        ReenvioContratoTO.PessoaTO pessoa = new ReenvioContratoTO.PessoaTO();
        pessoa.pessoaExpostaPoliticamente = 0;

        ReenvioContratoTO.TaxaTO taxa = new ReenvioContratoTO.TaxaTO();
        taxa.pura = 0;
        taxa.comercial = 0;
        taxa.total = 0;

        ReenvioContratoTO.PremioTO premio = new ReenvioContratoTO.PremioTO();
        premio.comercial = 0;
        premio.integral = 0;
        premio.puro = 0;
        premio.total = 0;

        ReenvioContratoTO.DadosPessoaFisicaTO dadosPessoaFisica = new ReenvioContratoTO.DadosPessoaFisicaTO();
        dadosPessoaFisica.nacionalidade = '';
    }
//LECVP-72 - FIM
}