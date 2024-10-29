// POR062-1 - INICIO
@isTest
private class CasoBOTest {

    @isTest static void testarRecuperarCasosAdministrativos(){

        Test.startTest();

        Case caso = criarCasoAdmTest(); // LECVPV-140-FIX02 INICIO

        List<Case> listaCasos = new List<Case>();
        listaCasos.add(caso);
    
        CasoBO.getInstance().recuperarCasosAdministrativos(listaCasos);
        
        Test.stopTest();

    }

    // LECVPV-140-FIX02 INICIO
    @isTest static void testarGerarMovimentoEncerramentoAdm(){
        Test.startTest();

        Case casoAdm = criarCasoAdmTest();

        insert new MovimentoSinistro__c(
            Caso__c = casoAdm.id,
            DataMovimento__c = System.now(),
            DescricaoMovimento__c = '1',
            TipoMovimento__c = 'Aviso',
            ValorMovimento__c = 500,
            SequenciaMovimento__c = '1'
        );

        List<Case> listaCasos = new List<Case>();
        listaCasos.add(casoAdm);

        CasoBO.getInstance().gerarMovimentosEncerramento(listaCasos);

        Test.stopTest();
    }

    @isTest static void testarGerarMovimentoEncerramentoJuridico(){ 

        Test.startTest();

        Case casoJur = criarCasoJuridicoTest();

        insert new MovimentoSinistro__c(
            Caso__c = casoJur.id,
            DataMovimento__c = System.now(),
            DescricaoMovimento__c = '1',
            TipoMovimento__c = 'Aviso',
            ValorMovimento__c = 500,
            SequenciaMovimento__c = '1'
        );

        List<Case> listaCasos = new List<Case>();
        listaCasos.add(casoJur);

        CasoBO.getInstance().gerarMovimentosEncerramento(listaCasos); 

        Test.stopTest();
    }
    // LECVPV-140-FIX02 FIM

    //LECVP-317 - INICIO
    // @isTest static void testarObrigarPreenchimentoAssistCard(){

    //     Test.startTest();

    //     Recordtype REC_ID_PERSONACCOUNT = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica');
    //     Recordtype REC_ID_ACCOUNT = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaJuridica');

    //     Account conta = new Account(
    //         RecordtypeId = REC_ID_PERSONACCOUNT.Id,
    //         FirstName = 'TestFirstNamePessoaFisica',
    //         LastName = 'TestLastNamePessoaFisica',
    //         Cpf__c = '438.912.318-14',
    //         Pis__c = '123456789', 
    //         Pep__c = 'Não',
    //         Nacionalidade__c = 'Brasileira',
    //         Phone = '(11)3131-4252',
    //         PersonBirthdate = Date.newInstance(1985, 02, 02)
    //     );
    //     insert conta;

    //     RamoAtividade__c ramoAtividade = (RamoAtividade__c) new RamoAtividadeFactory().createRecord();
    //     Account contaParceiro = new Account(
    //         RecordtypeId = REC_ID_ACCOUNT.Id,
    //         Name = 'TestNamePessoaJuridica',
    //         Cnpj__c = '31.838.851/0001-31',
    //         Inscricao_Municipal__c = '123456789',
    //         TipoAdministracao__c = 'Privada',
    //         RamoAtividade__c = ramoAtividade.id,
    //         Phone = '(11)3131-4252'
    //     );
    //     insert contaParceiro;

    //     FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();

    //     Product2 produto = createProduct();

    //     Parceiro__c parceiro = createParceiro(contaParceiro, formaPagamento);
    //     insert parceiro;

    //     Contract contrato = createContract(conta, produto, parceiro);
    //     contrato.TipoViagem__c = 'Internacional';
    //     insert contrato;

    //     ContratanteContrato__c contratanteContrato = createContratanteContrato(contrato, conta);
    //     insert contratanteContrato;

    //     GrupoContrato__c grupoContrato = createGrupoContrato(contratanteContrato);

    //     SeguradoContrato__c seguradoContrato = createSeguradoContrato(conta, grupoContrato);
    //     insert seguradoContrato;

    //     Garantia__c garantia = (Garantia__c) new GarantiaFactory().getRecord();
    //     garantia.Sigla__c = 'DMHO';

    //     insert garantia;

    //     List<Case> listaCaso = new List<Case>();
    //     Map<Id, Case> mapCaso = new Map<Id, Case>();
    //     Case caso = createCaso();
    //     Case casoOld = createCaso();

    //     casoOld.Status = 'Avisar';
    //     insert casoOld;
    //     mapCaso.put(casoOld.Id, casoOld);

    //     caso.PagtoAssistCardInternacional__c = 'Sim';
    //     caso.Invoice__c = '';
    //     caso.Data_pagamento__c = null;
    //     caso.Contrato__c = contrato.Id;
    //     caso.Status = 'Avisar';

    //     listaCaso.add(caso);
    //     insert listaCaso;       

    //     GarantiaSeguradoContrato__c garantiaSeguradoContrato = createGarantiaSeguradoContrato(seguradoContrato, garantia);
    //     insert garantiaSeguradoContrato;

    //     PagamentoGarantia__c pagamentoGarantia = criarPagamentoGarantia(listaCaso[0], garantiaSeguradoContrato);
    //     Boolean validouPreencObr = false;

    //     try{   
    //         insert pagamentoGarantia;         
    //         CasoBO.getInstance().obrigarPreenchimentoAssistCard(listaCaso, mapCaso);
    //     }catch(System.DmlException d){
    //         if(d.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
    //             validouPreencObr = true;
    //         }
    //     }

    //     Assert.areEqual(true, validouPreencObr);
        
    //     Test.stopTest();

    // }

    @isTest static void preencheCorretorCasoTest (){

        Test.startTest();
            Map<String, SObject> records = createIntegratedScenario();

            CasoBO.getInstance().PreencheCorretorCaso(new List<Case>{(Case) records.get('CasoSinistro')});
        Test.stopTest();
    }

    @isTest static void preencherDataLimiteTest(){

        Map<String, Sobject> records = createIntegratedScenario();
        records.put('CasoPadrao', createCaso());
        // records.put('CasoSinistro', createCasoSinistro((Case) records.get('CasoPadrao'), (Contract) records.get('Contrato'), (GarantiaSeguradoContrato__c) records.get('GarantiaSeguradoContrato'), false));

        // Case caso = (Case) records.get('CasoSinistro');
        // caso.Cidade_do_evento__c = 'Teste do Sul';



        Test.startTest();
            records.put('CasoSinistro', createCasoSinistro((Case) records.get('CasoPadrao'), (Contract) records.get('Contrato'), (GarantiaSeguradoContrato__c) records.get('GarantiaSeguradoContrato'), false));
            // CasoBO.getInstance().preencherDataLimite(
            //     new List<Case>{caso}, 
            //     new Map<Id, Case>()
            // );
        Test.stopTest();


    }


    @isTest static void preencheContratonoCasoTest(){

        Map<String, Sobject> records = createIntegratedScenario();

        // LECVPV-216 INICIO
        records.put('CasoPadrao', createCaso());
        records.put('CasoSinistro', createCasoSinistro((Case) records.get('CasoPadrao'), (Contract) records.get('Contrato'), (GarantiaSeguradoContrato__c) records.get('GarantiaSeguradoContrato'), false));
        // LECVPV-216 FIM

        List<Case> cases = new List<Case>{(Case) records.get('CasoSinistro')};

        // GarantiaSeguradoContrato__c garantia = createGarantiaSeguradoContrato((SeguradoContrato__c) records.get('SeguradoContrato'), (Garantia__c) records.get('Garantia'));

        Case casoOld = new Case(
            Sinistro_Judicial__c = false,
            Origin = 'Atendimento',
            RamoSplit__c = 1369,
            Type = 'Sinistro',
            Internacional__c = false,
            Invoice__c = '',
            Data_pagamento__c = Date.today(),
            Status = 'Avisar',
            Garantia_do_segurado_do_contrato__c = null
        );

        Map<Id, Case> casosOld = new Map<Id, Case>{
            casoOld.Id => casoOld
        };

        Test.startTest();
            CasoBO.getInstance().preencheContratonoCaso(cases, casosOld);
        Test.stopTest();

    }

    private static PagamentoGarantia__c criarPagamentoGarantia(Case caso, GarantiaSeguradoContrato__c garantiaSeguradoContrato){

        PagamentoGarantia__c pagamentoGarantia = new PagamentoGarantia__c(
            Name = 'Assistência Funeral Individual',
            Caso__c = caso.Id,
            Garantia_do_segurado_do_contrato__c = garantiaSeguradoContrato.Id            
        );

        insert pagamentoGarantia;
        return pagamentoGarantia;
    }

    private static Parceiro__c createParceiro(Account conta, FormaPagamento__c formaPagamento){

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


    private static Product2 createTechnicalProduct(){
        
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
            VersaoRenovacao__c              = 'Versão atual'
        );
        insert produtoTec;

        produtoTec.Status__c = 'Ativo';
        update produtoTec;

       return produtoTec;
    }

    private static Product2 createComercialProduct(Product2 produtoTec){

        Product2 produtoCom = new Product2 (
            ProdutoTecnico__c               = produtoTec.Id,
            Name                            = 'VIAGEM_VIDA_ON',
            Status__c                       = 'Em criação',
            ProductCode                     = 'VI-PESSOAS',   
            VigenciaInicial__c              = System.today(),
            VigenciaFinal__c                = System.today().addDays(1),
            TipoCapital__c                  = 'Capital uniforme',
            Segmento__c                     = 'Individual',
            TipoResponsavelPagamento__c     = 'SEG',
            LimiteTotalCarregamento__c      = 200,
            NumeroSusep__c                  = '15414.900476/2015-42',
            RecordTypeId                    = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id,
            Versao__c                       = 1,
            VersaoMaxima__c                 = true,
            VersaoRenovacao__c              = 'Versão atual'
        );
        insert produtoCom;

        produtoCom.Status__c = 'Ativo';
        update produtoCom;

        return produtoCom;
    }






    private static Contract createContract(Account conta, Product2 produto, Parceiro__c parceiro){

        Contract contrato =  new Contract(
            Name = 'teste',
            AccountId = conta.Id,
            Produto__c = produto.Id,
            Parceria__c = parceiro.Id,
            CodigoRamo__c = '1369',
            TipoViagem__c = 'Internacional'
        );

        insert contrato;
        return contrato;
    }

    private static ContratanteContrato__c createContratanteContrato(Contract contrato, Account conta){

        ContratanteContrato__c contratanteContrato = new ContratanteContrato__c(
            Contrato__c = contrato.Id,
            Conta__c = conta.Id,
            Tipo__c = 'Principal'
        );

        insert contratanteContrato;
        return contratanteContrato;
    }

    private static GrupoContrato__c createGrupoContrato(ContratanteContrato__c contratanteContrato){

        GrupoContrato__c grupoContrato = new GrupoContrato__c(
            ContratanteContrato__c = contratanteContrato.Id
        );

        insert grupoContrato;
        return grupoContrato;
    }

    private static SeguradoContrato__c createSeguradoContrato(Account conta, GrupoContrato__c grupoContrato){

        SeguradoContrato__c seguradoContrato = new SeguradoContrato__c(
            Conta__c = conta.Id,
            GrupoContrato__c = grupoContrato.Id,
            VigenciaInicial__c = system.today(),
            VigenciaFinal__c = system.today().addMonths(1)
        );

        insert seguradoContrato;
        return seguradoContrato;
    }

    private static GarantiaSeguradoContrato__c createGarantiaSeguradoContrato(SeguradoContrato__c seguradoContrato, Garantia__c garantia){

        GarantiaSeguradoContrato__c garantiaSeguradoContrato = new GarantiaSeguradoContrato__c(
            SeguradoContrato__c = seguradoContrato.Id,
            Garantia__c = garantia.Id
        );

        insert garantiaSeguradoContrato;
        return garantiaSeguradoContrato;
    }

    public static Garantia__c createGarantia(){
        Garantia__c garantia = new Garantia__c(
            VigenciaInicial__c = System.today(),
            Tipo__c = 'Cobertura',
            Sigla__c = 'AFF'
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

    private static Case createCasoSinistro(Case casoPadrao, Contract contrato, GarantiaSeguradoContrato__c garantia, Boolean filhoCriadoAuto){

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

    private static Case createCaso(){

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
    //LECVP-317 - FIM

    // LECVPV-140-FIX02 INICIO
    public static Case criarCasoAdmTest(){
        
        Case caso = new Case(
            Id = '500L000000GSvG0IAL',
            Sinistro_Judicial__c = false
        );

        insert caso;
        return caso;
    }

    public static Case criarCasoJuridicoTest(){
        
        Case caso = new Case(
            Id = '5008900000AYcxzAAD',
            Sinistro_Judicial__c = true
        );

        insert caso;
        return caso;
    }

    // public static Account createAccountWithRecordType(String recordTypeName){

    //     Account contaFisica = (Account) new AccountFactory.PessoaFisica().createRecord();

    //     insert conta;
    //     return conta;
    // }

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

    public static Map<String, Sobject> createIntegratedScenario(){

        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();

        Map<String, Sobject> records = new Map<String, Sobject>();
        records.put('AccountPessoaFisica', (Account) new AccountFactory.PessoaFisica().createRecord());
        records.put('DadosCorretor', createDadosCorretor((Account) records.get('AccountPessoaFisica')));
        records.put('RamoSeguro', createRamoSeguro((Account) records.get('AccountPessoaFisica')));
        records.put('RamoAtividade', createRamoAtividade('Teste'));
        records.put('AccountPessoaJuridica', createAccountWithRecordTypeAndRamoAtividade('PessoaJuridica', (RamoAtividade__c) records.get('RamoAtividade')));
        records.put('ProdutoTec', createTechnicalProduct());
        records.put('ProdutoComercial', createComercialProduct((Product2) records.get('ProdutoTec')));
        records.put('FormaPagamento', createFormaPagamento());
        records.put('Parceiro', createParceiro((Account) records.get('AccountPessoaJuridica'), (FormaPagamento__c) records.get('FormaPagamento')));
        records.put('Contrato', createContract((Account) records.get('AccountPessoaFisica'), (Product2) records.get('ProdutoComercial'), (Parceiro__c) records.get('Parceiro')));
        records.put('TipoRemuneracao', createTipoRemuneracaoByName('Corretagem'));
        records.put('RemuneracaoContrato', createRemuneracaoContrato((Contract) records.get('Contrato'), (TipoRemuneracao__c) records.get('TipoRemuneracao')));
        records.put('FavorecidoRemuneracaoContrato', createFavorecidoRemuneracaoContrato((Account) records.get('AccountPessoaFisica'), (RemuneracaoContrato__c) records.get('RemuneracaoContrato'), (DadosCorretor__c) records.get('DadosCorretor')));
        records.put('ContratanteContrato', createContratanteContrato((Contract) records.get('Contrato'), (Account) records.get('AccountPessoaFisica')));
        records.put('GrupoContrato', createGrupoContrato((ContratanteContrato__c) records.get('ContratanteContrato')));
        records.put('SeguradoContrato', createSeguradoContrato((Account) records.get('AccountPessoaFisica'), (GrupoContrato__c) records.get('GrupoContrato')));
        records.put('Garantia', createGarantia());
        records.put('GarantiaProdutoTec', createGarantiaProdutoWithProdutoTecnico((Garantia__c) records.get('Garantia'), (Product2) records.get('ProdutoTec'), (RamoSeguro__c) records.get('RamoSeguro')));
        records.put('GarantiaProdutoComercial', createGarantiaProdutoWithProdutoComercial((Garantia__c) records.get('Garantia'), (GarantiaProduto__c) records.get('GarantiaProdutoTec'), (Product2) records.get('ProdutoTec'), (RamoSeguro__c) records.get('RamoSeguro')));
        records.put('GarantiaSeguradoContrato', createGarantiaSeguradoContrato((SeguradoContrato__c) records.get('SeguradoContrato'), (Garantia__c) records.get('Garantia')));

        return records;
    }
     // LECVPV-140-FIX02 FIM
}
// POR062-1 - FIM