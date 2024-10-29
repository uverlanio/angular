/*
@author Kevin Vogado - Globant
@date 27/06/2024
@Classe criada para cobrir a  (FNPVVEP-46)
*/
public with sharing class CreateTestData {

    public static Map<String, Sobject> createIntegratedScenario(){

        Map<String, Sobject> records = new Map<String, Sobject>();
        records.put('ContadorCodigoTec', createContadorCodigoProdutoTecnico());
        records.put('AccountPessoaFisica', (Account) new AccountFactory.PessoaFisica().createRecord());
        records.put('DadosCorretor', createDadosCorretor((Account) records.get('AccountPessoaFisica')));
        records.put('RamoSeguro', createRamoSeguro((Account) records.get('AccountPessoaFisica')));
        records.put('RamoAtividade', createRamoAtividade('Teste'));
        records.put('AccountPessoaJuridica', createAccountWithRecordTypeAndRamoAtividade('PessoaJuridica', (RamoAtividade__c) records.get('RamoAtividade')));
        records.put('ProdutoTec', createTechnicalProduct());
        records.put('ProdutoComercial', createComercialProduct((Product2) records.get('ProdutoTec')));
        records.put('FormaPagamento', createFormaPagamento());
        records.put('Parceiro', createParceiro((Account) records.get('AccountPessoaJuridica'), (FormaPagamento__c) records.get('FormaPagamento')));
        records.put('Contrato', createContract((Account) records.get('AccountPessoaFisica'), (Product2) records.get('ProdutoComercial'), (Parceiro__c) records.get('Parceiro'), (RamoSeguro__c) records.get('RamoSeguro'), (FormaPagamento__c) records.get('FormaPagamento'), (DadosCorretor__c) records.get('DadosCorretor')));//ANNVI-55 - INICIO/FIM
        records.put('TipoRemuneracao', createTipoRemuneracaoByName('Corretagem'));
        records.put('RemuneracaoContrato', createRemuneracaoContrato((Contract) records.get('Contrato'), (TipoRemuneracao__c) records.get('TipoRemuneracao')));
        records.put('FavorecidoRemuneracaoContrato', createFavorecidoRemuneracaoContrato((Account) records.get('AccountPessoaFisica'), (RemuneracaoContrato__c) records.get('RemuneracaoContrato'), (DadosCorretor__c) records.get('DadosCorretor')));
        records.put('ContratanteContrato', createContratanteContrato((Contract) records.get('Contrato'), (Account) records.get('AccountPessoaFisica'), (FormaPagamento__c) records.get('FormaPagamento')));
        records.put('GrupoContrato', createGrupoContrato((ContratanteContrato__c) records.get('ContratanteContrato')));
        records.put('SeguradoContrato', createSeguradoContrato((Account) records.get('AccountPessoaFisica'), (GrupoContrato__c) records.get('GrupoContrato')));
        records.put('Garantia', createGarantia());
        records.put('GarantiaProdutoTec', createGarantiaProdutoWithProdutoTecnico((Garantia__c) records.get('Garantia'), (Product2) records.get('ProdutoTec'), (RamoSeguro__c) records.get('RamoSeguro')));
        records.put('GarantiaProdutoComercial', createGarantiaProdutoWithProdutoComercial((Garantia__c) records.get('Garantia'), (GarantiaProduto__c) records.get('GarantiaProdutoTec'), (Product2) records.get('ProdutoTec'), (RamoSeguro__c) records.get('RamoSeguro')));
        records.put('GarantiaSeguradoContrato', createGarantiaSeguradoContrato((garantiaProduto__c) records.get('GarantiaProdutoComercial'),(SeguradoContrato__c) records.get('SeguradoContrato'), (Garantia__c) records.get('Garantia')));
        records.put('Carencia', createCarencia());
        records.put('CarenciaContrato', createCarenciaGarantia((GarantiaProduto__c) records.get('GarantiaProdutoTec'), (Carencia__c) records.get('Carencia')));
        records.put('CasoPadrao', createCaso());
        records.put('CasoSinistro', createCasoSinistro((Case) records.get('CasoPadrao'), (Contract) records.get('Contrato'), (GarantiaSeguradoContrato__c) records.get('GarantiaSeguradoContrato'), false));
        records.put('PagamentoGarantia', createPagamentoGarantia((Case) records.get('CasoSinistro'), (GarantiaSeguradoContrato__c) records.get('GarantiaSeguradoContrato')));
        records.put('BeneficiarioGarantia', createBeneficiarioGarantia((PagamentoGarantia__c) records.get('PagamentoGarantia'), (Account) records.get('AccountPessoaFisica')));
        records.put('Banco', createBanco());
        records.put('InformacaoBancaria', createInformacaoBancaria((Banco__c) records.get('Banco'), (Account) records.get('AccountPessoaFisica')));
        records.put('PagamentoDeSinistro', createPagamentoDeSinistro((Case) records.get('CasoSinistro'), (InformacaoBancaria__c) records.get('InformacaoBancaria'), (Account) records.get('AccountPessoaFisica'), (PagamentoGarantia__c) records.get('PagamentoGarantia')));
        records.put('Modalidade', createModalidade((RamoSeguro__c) records.get('RamoSeguro')));//ANNVI-55 - INICIO
        records.put('CanalDistribuicao', createCanalDistribuicao());
        records.put('Orcamento', createOrcamento((Product2) records.get('ProdutoComercial'), (Account) records.get('AccountPessoaFisica'), (CanalDistribuicao__c) records.get('CanalDistribuicao')));
        records.put('Proposta', createProposta((RamoSeguro__c) records.get('RamoSeguro'), (Product2) records.get('ProdutoComercial'), (Account) records.get('AccountPessoaFisica'), (DadosCorretor__c) records.get('DadosCorretor'), (Opportunity) records.get('Orcamento'), (Modalidade__c) records.get('Modalidade')));
        records.put('GarantiaProposta', createGarantiaProposta((Garantia__c) records.get('Garantia'), (Quote) records.get('Proposta'),(GarantiaProduto__c) records.get('GarantiaProdutoComercial')));//ANNVI-55 - FIM
        return records;
    }


    public static BeneficiarioGarantia__c createBeneficiarioGarantia(PagamentoGarantia__c pagamentoGarantia, Account contaPessoal){

        BeneficiarioGarantia__c beneficiarioGarantia = new BeneficiarioGarantia__c(
            Pagamento_de_garantia__c = pagamentoGarantia.Id,
            Conta__c = contaPessoal.id,
            Status__c = 'Pendente',
            Tipo_de_Pagamento__c = 'Cheque',
            InformarIndenizacao__c = 'Valor de Indenização', 
            ValorIndenizacao__c = 20.00, 
            Sucursal_Destino_de_Cheque__c = 10,
        	Data_programada_do_pagamento__c = System.today() + 2,
        	StatusSerasa__c = 'Atualizado'
        );

        insert beneficiarioGarantia;
        return beneficiarioGarantia;
    }

    public static PagamentoGarantia__c createPagamentoGarantia(Case caso, GarantiaSeguradoContrato__c garantiaSeguradoContrato){

        PagamentoGarantia__c pagamentoGarantia = new PagamentoGarantia__c(
            Name = 'Despesas Médicas, Hospitalares e Odontológicas',
            Caso__c = caso.Id,
            Caso__r = caso,
            Garantia_do_segurado_do_contrato__c = garantiaSeguradoContrato.Id,
            Garantia_do_segurado_do_contrato__r = garantiaSeguradoContrato,
            QuantidadeDias__c = 1  //FNPVVEP-46 - INICIO/FIM (Adjustment)
        );

        insert pagamentoGarantia;
        return pagamentoGarantia;
    }


    public static ContadorCodigo__c createContadorCodigoProdutoTecnico(){
        
        ContadorCodigo__c contadorProdutoTecnico = new ContadorCodigo__c(
            Numero__c = 1.0,
            Name = 'ProdutoTecnico'
        );

        insert contadorProdutoTecnico;
        return contadorProdutoTecnico;
    }
    
    public static Parceiro__c createParceiro(Account conta, FormaPagamento__c formaPagamento){

        Parceiro__c parceiro = new Parceiro__c(
            Status__c = 'Ativo',
            Sucursal__c = '1',
            Ramo__c = '1391',
            Empresa__c = '1',
            Conta__c = conta.Id,
            FormaPagamento__c = formaPagamento.Id,
            DiaFaturamento__c = '15',
            DiaPreFaturamento__c = '20',
            PrazoVencimento__c = '10',
            FaturaProdutosSeparados__c = 'Sim',
            PossuiAnexoFatura__c = 'Nao',
            SiglaParceiro__c = 'PAR'
        );

        insert parceiro;
        return parceiro;
    }

    public static TipoRemuneracao__c createTipoRemuneracaoByName(String name){
        
        TipoRemuneracao__c tipo = new TipoRemuneracao__c(
            Name = name,
            Descricao__c = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit.',
            ModeloRecuperacao__c = 'Integral',
            Codigo__c = 'COR',
            LimiteMinimo__c = 10,
            LimiteMaximo__c = 50
        );

        insert tipo;
        return tipo;
    }

    public static RemuneracaoContrato__c createRemuneracaoContrato(Contract contrato, TipoRemuneracao__c tipoRemuneracao){
        
        RemuneracaoContrato__c remunercao = new RemuneracaoContrato__c(
            Contrato__c = contrato.Id,
            TipoRemuneracao__c = tipoRemuneracao.Id,
            CurrencyIsoCode = 'BRL',
            Percentual__c = 10,
            Porcentagem_de_Retencao__c = 0
        );

        insert remunercao;
        return remunercao;
    }

    public static FavorecidoRemuneracaoContrato__c createFavorecidoRemuneracaoContrato(Account conta, RemuneracaoContrato__c remuneracao, DadosCorretor__c dados ){
        
        FavorecidoRemuneracaoContrato__c favorecido = new FavorecidoRemuneracaoContrato__c(
            Conta__c = conta.Id,
            CorretorLider__c = true,
            AntecipacaoComissao__c = true,
            RemuneracaoContrato__c = remuneracao.Id,
            DadosCorretor__c = dados.Id,
            Papel__c = 'Corretor',
            Susep__c = 'REN01J'
        );

        insert favorecido;
        return favorecido;
    }

    public static Product2 createTechnicalProduct(){
        
        Product2 produtoTec = new Product2(
            Name = 'Nome Produto Tecnico',
            Status__c = 'Em criação',
            ProductCode = '201700001',
            VigenciaInicial__c = System.today().addDays(3),
            TipoCapital__c = 'Capital uniforme',
            Segmento__c = 'Individual',
            TipoResponsavelPagamento__c = 'PAR',
            NumeroSusep__c = '12345',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id,
            Versao__c                       = 1,
            VersaoMaxima__c                 = true,
            VersaoRenovacao__c              = 'Versão atual',
            GerarVoucher__c = true
        );
        insert produtoTec;

        produtoTec.Status__c = 'Ativo';
        update produtoTec;

       return produtoTec;
    }

    public static Product2 createComercialProduct(Product2 produtoTec){

        Product2 produtoCom = new Product2 (
            ProdutoTecnico__c = produtoTec.Id,
            Name = 'VIAGEM_VIDA_ON',
            Status__c = 'Em criação',
            ProductCode = 'VI-PESSOAS',   
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addDays(1),
            TipoCapital__c = 'Capital uniforme',
            Segmento__c = 'Individual',
            TipoResponsavelPagamento__c = 'SEG',
            LimiteTotalCarregamento__c = 200,
            NumeroSusep__c = '15414.900476/2015-42',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id,
            Versao__c = 1,
            VersaoMaxima__c = true,
            VersaoRenovacao__c = 'Versão atual',
            GerarVoucher__c = true
        );
        insert produtoCom;

        produtoCom.Status__c = 'Ativo';
        update produtoCom;

        return produtoCom;
    }

    public static Contract createContract(Account conta, Product2 produto, Parceiro__c parceiro, RamoSeguro__c ramo, FormaPagamento__c formaPagamento, DadosCorretor__c dadosCorretor){//ANNVI-55 - INICIO/FIM

        Contract contrato = new Contract(
            Name = 'teste',
            AccountId = conta.Id,
            Produto__c = produto.Id,
            Parceria__c = parceiro.Id,
            CodigoRamo__c = '1369',
            TipoViagem__c = 'Internacional',
            Empresa__c = '14',//ANNVI-55 - INICIO
            DataEmissao__c = System.today(),
            RamoSeguro__r = ramo,
            Sucursal__c = '1',
            Endosso__c = '0',
            StartDate = System.today(),
            VigenciaFinal__c = System.today().addYears(1),
            FormaPagamento__r = formaPagamento,
            ValorPremio__c = 10,
            Tipo__c = 'Novo',
            CodigoCorretor__r = dadosCorretor,
            CodigoCorretor__c = dadosCorretor.Id//ANNVI-55 - FIM

        );

        insert contrato;
        return contrato;
    }

    public static ContratanteContrato__c createContratanteContrato(Contract contrato, Account conta, FormaPagamento__c formaPagamento){ //ANNVI-55 - INICIO/FIM

        ContratanteContrato__c contratanteContrato = new ContratanteContrato__c(
            Contrato__c = contrato.Id,
            Conta__c = conta.Id,
            Tipo__c = 'Principal',
            FormaPagamento__r = formaPagamento,//ANNVI-55 - INICIO
            QuantidadeParcelas__c = 1 //ANNVI-55 - FIM
        );

        insert contratanteContrato;
        return contratanteContrato;
    }

    public static GrupoContrato__c createGrupoContrato(ContratanteContrato__c contratanteContrato){

        GrupoContrato__c grupoContrato = new GrupoContrato__c(
            ContratanteContrato__c = contratanteContrato.Id
        );

        insert grupoContrato;
        return grupoContrato;
    }

    public static SeguradoContrato__c createSeguradoContrato(Account conta, GrupoContrato__c grupoContrato){

        SeguradoContrato__c seguradoContrato = new SeguradoContrato__c(
            Conta__c = conta.Id,
            GrupoContrato__c = grupoContrato.Id,
            VigenciaInicial__c = system.today(),
            VigenciaFinal__c = system.today().addMonths(1)
        );

        insert seguradoContrato;
        return seguradoContrato;
    }

    public static GarantiaSeguradoContrato__c createGarantiaSeguradoContrato(GarantiaProduto__c garantiaProd, SeguradoContrato__c seguradoContrato, Garantia__c garantia){

        GarantiaSeguradoContrato__c garantiaSeguradoContrato = new GarantiaSeguradoContrato__c(
            SeguradoContrato__c = seguradoContrato.Id,
            Garantia__c = garantia.Id,
            GarantiaProduto__c = garantiaProd.Id
        );

        insert garantiaSeguradoContrato;
        return garantiaSeguradoContrato;
    }

    public static Garantia__c createGarantia(){
        
        Garantia__c garantia = new Garantia__c(
            VigenciaInicial__c = System.today(),
            Tipo__c = 'Cobertura',
            Sigla__c = 'AFF',
            Status__c = 'Ativo', //ANNVI-55 - INICIO
            TipoEvento__c = 'Viagem',
            Descricao__c = 'teste'
            //ANNVI-55 - FIM
        );

        insert garantia;
        return garantia;
    }

    public static GarantiaProduto__c createGarantiaProdutoWithProdutoTecnico(Garantia__c garantia, Product2 produtoTec, RamoSeguro__c ramoSegurado){

        GarantiaProduto__c garantiaProduto = new GarantiaProduto__c(
            TipoGarantia__c = 'Cobertura',
            Garantia__c = garantia.Id,
            Produto__c = produtoTec.Id,
            RamoSeguro__c = ramoSegurado.Id,
            OrdemPrioridade__c = 1,
            TipoPagamento__c = 'Reembolso',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoTecnico').Id,
            TipoCapital__c = 'Capital uniforme',
            CodigoPromocao__c = 'VITST',
            VersaoTitulo__c = '1'
        );

        insert garantiaProduto;
        return garantiaProduto;
    }

    public static GarantiaProduto__c createGarantiaProdutoWithProdutoComercial(Garantia__c garantia, GarantiaProduto__c garantiaProdutoTec, Product2 produtoCom, RamoSeguro__c ramoSegurado){

        GarantiaProduto__c garantiaProduto = new GarantiaProduto__c(
            Garantia__c = garantia.Id,
            GarantiaProduto__c = garantiaProdutoTec.Id,
            Produto__c = produtoCom.Id,
            OrdemPrioridade__c = 1,
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id,
            TipoGarantia__c = 'Cobertura',
            TipoCapital__c = 'Capital uniforme',
            RamoSeguro__c = ramoSegurado.Id,
            TipoPagamento__c = 'Reembolso',
            TipoCaracteristicaEspecial__c = 'Cestas',
            LimiteMaximoCaracteristicaEspecial__c = 100,
            LimiteMinimoCaracteristicaEspecial__c = 10,
            CodigoPromocao__c = 'VITST',
            VersaoTitulo__c = '1',
            CurrencyIsoCode = 'BRL',
            LimiteCapitalMinimo__c = 100,
            LimiteCapitalMaximo__c = 1000, 
            Obrigatoria__c = true
        );

        insert garantiaProduto;
        return garantiaProduto;
    }

    public static Case createCasoSinistro(Case casoPadrao, Contract contrato, GarantiaSeguradoContrato__c garantia, Boolean filhoCriadoAuto){

        Recordtype REC_ID_SINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');

        Case caso = new Case(
            ParentId = casoPadrao.Id,
            RecordTypeId = REC_ID_SINISTRO.Id,
            Sinistro_Judicial__c = false,
            Origin = 'Atendimento',
            RamoSplit__c = 1369,
            Type = 'Sinistro',
            Internacional__c = false,
            Invoice__c = '',
            Data_pagamento__c = Date.today(),
            Contrato__c = contrato.Id,
            Caso_Filho_Criado_Automaticamente__c = filhoCriadoAuto
        );

        insert caso;
        return caso;
    }

    public static Case createCaso(){

        Recordtype REC_ID_ATENDIMENTO = RecordTypeBO.buscarTipoRegistro('Case', 'Atendimento');

        Case caso = new Case(
            RecordTypeId = REC_ID_ATENDIMENTO.Id,
            Sinistro_Judicial__c = false,
            Origin = 'Atendimento',
            RamoSplit__c = 1369,
            Type = 'Padrão',
            Internacional__c = false,
            Invoice__c = '',
            Data_pagamento__c = Date.today()
        );

        insert caso;
        return caso;
    }

    public static Account createAccountWithRecordTypeAndRamoAtividade(String recordTypeName, RamoAtividade__c ramo){

        RecordType TYPE = RecordTypeBO.buscarTipoRegistro('Account', recordTypeName);

        Account conta = new Account(
            RecordtypeId = TYPE.Id,
            Name = 'Conta 42',
            CodigoEmpresa__c = '14',
            IdExterno__c = '13143510000160',
            Papel__c = 'Parceiro',
            Sexo__c = 'Masc',
            Cpf__c = '76466318095',
            Pis__c = '123456789',
            Cnpj__c = '13.143.510/0001-60',
            Inscricao_Municipal__c = '123456789',
            Nacionalidade__c = 'Brasileira',
            EstadoCivil__c = 'Casado (a)',
            Email__c = 'teste@teste.com.br'        
        );

        insert conta;
        return conta;
    }

    public static DadosCorretor__c createDadosCorretor(Account conta){
        DadosCorretor__c dados = new DadosCorretor__c(
            Name = conta.Name,
            NomeCorretor__c = conta.Id
        );

        insert dados;
        return dados;
    }

    public static RamoSeguro__c createRamoSeguro(Account conta){
        RamoSeguro__c ramo = new RamoSeguro__c(
			Name = 'VIDA',
			CodigoEmpresa__c = '14',
			Codigo__c = '2',
			IdExterno__c = '14_2',
			Empresa__c = conta.Id,
			Status__c = 'Ativo',
			CodigoOrigemDoMovimentoBCP__c = '32'
		);

        insert ramo;
        return ramo;
    }

    public static RamoAtividade__c createRamoAtividade(String name){
        RamoAtividade__c ramoAtividade = new RamoAtividade__c(
            Name = name
        );

        insert ramoAtividade;
        return ramoAtividade;
    }

    public static FormaPagamento__c createFormaPagamento(){
        FormaPagamento__c forma = new FormaPagamento__c(
            Codigo__c = '41',
            Name = 'X'
        );

        insert forma;
        return forma;
    }

    public static Carencia__c createCarencia(){
        Carencia__c carencia = new Carencia__c(
			Name = 'Carencia 1'
		);
        
		insert carencia;
        return carencia;
    }

    public static CarenciaGarantia__c createCarenciaGarantia(GarantiaProduto__c garantiaProdutoTec, Carencia__c carencia){
        CarenciaGarantia__c carenciaGarantiaTec = new CarenciaGarantia__c(
			GarantiaProduto__c = garantiaProdutoTec.Id,
			Carencia__c = carencia.Id,
			RecordTypeId = RecordTypeBO.buscarTipoRegistro('CarenciaGarantia__c', 'ProdutoTecnico').Id
		);
		insert carenciaGarantiaTec;
        return carenciaGarantiaTec;
    }
    //MGRC-1252 - INICIO - FIX1
    public static Banco__c createBanco(){
        Banco__c banco = new Banco__c(
            Name = 'Banco 1',
            CodigoBanco__c = '1',
            Ativo__c = true
        );

        insert banco;
        return banco;
    }

    public static InformacaoBancaria__c createInformacaoBancaria(Banco__c banco, Account conta){
        InformacaoBancaria__c informacaoBancaria = new InformacaoBancaria__c(
            Papel__c = 'Agenciador',
            Banco__c = '341',
            Agencia__c = '2332',
            NumeroConta__c = '1234548',
            Digito__c = '5',
            Conta__c = conta.Id,
            BancoNew__c = banco.Id
        );

        insert informacaoBancaria;
        return informacaoBancaria;
    }

    public static Pagamento_de_Sinistro__c createPagamentoDeSinistro(Case casoSinistro, InformacaoBancaria__c InformacaoBancaria, Account contaPessoaFisica, PagamentoGarantia__c pagamentoGarantia){
        Pagamento_de_Sinistro__c pagamentoDeSinistro = new Pagamento_de_Sinistro__c(
            Beneficiario_da_Garantia__c = contaPessoaFisica.Id,
			Caso_de_Sinistro__c = casoSinistro.Id,
			Dados_Bancarios__c = InformacaoBancaria.Id,
			Garantia_do_Sinistro__c = pagamentoGarantia.Id,
			Data_Programada_de_Pagamento__c = Date.today()
        );

        insert pagamentoDeSinistro;
        return pagamentoDeSinistro;
    }
    //MGRC-1252 - FIM - FIX1
    //ANNVI-55 - INICIO
    public static CanalDistribuicao__c createCanalDistribuicao(){

        CanalDistribuicao__c canalDistribuicao = new CanalDistribuicao__c();
        canalDistribuicao.Name = 'Canal Distribuição Teste 001';
        canalDistribuicao.Status__c = 'Em ativação';
        canalDistribuicao.Sigla__c = 'EXE';

        insert canalDistribuicao;
        return canalDistribuicao;
    }

    public static Modalidade__c createModalidade(RamoSeguro__c ramo){

        Modalidade__c modalidade = new Modalidade__c(
                RamoSeguro__c = ramo.Id,
                Name = 'Mod teste',
                Codigo__c = '14'
        );
        insert modalidade;
        return modalidade;
    }

    public static Opportunity createOrcamento(Product2 produto, Account conta, CanalDistribuicao__c canalDistribuicao){

        String payloadName = 'PayloadOrcamento001';
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: payloadName LIMIT 1];
        Blob payloadEntrada = sr.Body;
        
        Opportunity orcamento = new Opportunity(
                StageName = 'Em criação',
                CurrencyIsoCode = 'BRL',
                Name = 'ARQ-10006729',
                CloseDate = System.today().addDays(20),
                VigenciaInicial__c = System.today(),
                VigenciaFinal__c = System.today().addDays(1),
                Produto__c = produto.Id,
                Probability = 10.0,
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaGrupo').Id,
                AccountId = conta.Id,
                Numero__c = '10006769',
                CanalDistribuicao__c = canalDistribuicao.Id,
                Payload__c = EncodingUtil.base64Decode(EncodingUtil.base64Encode(payloadEntrada)).toString()
        );

        insert orcamento;
        return orcamento;
    }

    public static Quote createProposta(RamoSeguro__c ramo, Product2 produto, Account conta, DadosCorretor__c dadosCorretor, Opportunity orcamento, Modalidade__c modalidade){

        Quote proposta = new Quote(
                Name = '18-00052493',
                NumeroPropostaUnico__c = '18-00052493',
                Produto__c = produto.Id,
                RamoSeguro__c = ramo.Id,
                Status = 'Em criação',
                VigenciaInicial__c = System.today(),
                VigenciaFinal__c = System.today().addMonths(1),
                Empresa__c = conta.Id,
                CodigoCorretor__c = dadosCorretor.Id,
                DataCalculo__c = System.today(),
                DataCriacaoPortal__c = System.today(),
                TipoVigencia__c = 'Anual',
                MeioComercializacao__c = 'PMC',
                OpportunityId = orcamento.Id,
                Origem__c = '18',
                Modalidade__c = modalidade.Id,
                NumeroProposta__c = '00052493',
                Parceiro__c = '67708896000139',
                QuantidadeParcelas__c = 1,
                Link_Questionario_Samplemed__c = 'www.globant.com', //FNPVVEP-99 - INICIO/FIM
                Email__c = 'usuario@test.com' //FNPVVEP-99 - INICIO/FIM

        );

        insert proposta;
        return proposta;
    }
    
    public static GarantiaProposta__c createGarantiaProposta(Garantia__c garantia, Quote proposta, GarantiaProduto__c garantiaProduto){

        GarantiaProposta__c garantiaProposta = new GarantiaProposta__c(
            NumeroSorte__c = '01',
            NumeroSerie__c = '1',
            TipoCapital__c = 'Capital global',
            Capital__c = 1000,
            LimiteCapital__c = 1000,
            GarantiaProduto__c = garantiaProduto.Id,
            Garantia__c = garantia.Id,
            Garantia__r = garantia,
            PremioPuro__c = 106,
            PremioComercial__c = 266,
            PremioIntegral__c = 270,
            PremioTotal__c = 267,
            CurrencyIsoCode = 'BRL',
            TaxaPura__c = 0.01064,
            TaxaComercial__c = 0.0266,
            TaxaTotal__c = 0.02670108,
            Proposta__c = proposta.Id
        );

        insert garantiaProposta;
        return garantiaProposta;
    }
    //ANNVI-55 - FIM
}