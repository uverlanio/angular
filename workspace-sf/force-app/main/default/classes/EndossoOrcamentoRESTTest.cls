/****
@description Classe de teste para classe EndossoOrcamentoREST
@author Isabela Fin - Globant
@date 22/07/2020
-Classe criada por conta da historia PLV-3926    
*****/
@isTest
public class EndossoOrcamentoRESTTest {

    @TestSetup
    static void createData(){
        Account contaPF = (Account) new AccountFactory.PessoaFisica().createRecord();
        Account contaPJ = (Account) new AccountFactory.PessoaJuridica().createRecord();
        contaPF.Fumante__c = 'Sim'; //PLV-4695 - INICIO/FIM
        update contaPF;
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
	    ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        ContadorCodigo__c contCodigoNumOferta = (ContadorCodigo__c) new ContadorCodigoFactory.NumeroOferta().createRecord();
        
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        produtoComercial.Status__c = 'Ativo';
        update produtoComercial;
        
        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaPF, formaPagamento).createRecord();
        
        Opportunity orcamentoTipoNovo = (Opportunity) new OrcamentoFactory.VidaIndividual(produtoComercial, contaPF).createRecord();
        orcamentoTipoNovo.StageName = 'Disponível para contratação';
        orcamentoTipoNovo.Origem__c = '18';
        update orcamentoTipoNovo;
        
        ContratanteOrcamento__c contratanteOrcNovo = (ContratanteOrcamento__c) new contratanteOrcamentoFactory(orcamentoTipoNovo).createRecord();
        insert new GarantiaContratanteOrcamento__c (ContratanteOrcamento__c = contratanteOrcNovo.Id);
        
        GrupoOrcamento__c grupoOrcNovo = (GrupoOrcamento__c) new grupoOrcamentoFactory(contratanteOrcNovo).createRecord();
        insert new GarantiaGrupoOrcamento__c (GrupoOrcamento__c = grupoOrcNovo.Id);

        SeguradoOrcamento__c seguradoOrcNovo = (SeguradoOrcamento__c) new seguradoOrcamentoFactory(contaPF,grupoOrcNovo).createRecord();
        seguradoOrcNovo.Numero__c = 1;
        update seguradoOrcNovo;
        insert new GarantiaSeguradoOrcamento__c (SeguradoOrcamento__c = seguradoOrcNovo.Id);

        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(contaPJ).createRecord();
        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(contaPJ).createRecord();
        Modalidade__c modalidade = (Modalidade__c) new ModalidadeFactory(ramoSeguro).createRecord();
        
        Quote propostaTipoNovo = (Quote) new PropostaFactory(produtoComercial, ramoSeguro, contaPJ, dadosCorretor, orcamentoTipoNovo, modalidade).createRecord();
        propostaTipoNovo.Tipo__c = 'Novo';
        propostaTipoNovo.Status = 'Contratada';
        propostaTipoNovo.Parceiro__c = '';
        update propostaTipoNovo;

        ContratanteProposta__c contratantePropostaNova = (ContratanteProposta__c) new ContratantePropostaFactory(propostatipoNovo, formaPagamento).createRecord();
        contratantePropostaNova.Conta__c = contaPJ.Id;
        update contratantePropostaNova;
        insert new GarantiaContratanteProposta__c (ContratanteProposta__c = contratantePropostaNova.Id);

        GrupoProposta__c grupoPropostaNova = new GrupoProposta__c(ContratanteProposta__c = contratantePropostaNova.Id, Name = 'TesteGrupoProposta');
        insert grupoPropostaNova;

        SeguradoProposta__c seguradoPropostaNova = new SeguradoProposta__c(Conta__c = contaPF.Id, GrupoProposta__c = grupoPropostaNova.Id, Numero__c = 1);
        insert seguradoPropostaNova;

        BeneficiarioSeguradoProposta__c beneficiarioSeguradoProposta = new BeneficiarioSeguradoProposta__c();
        beneficiarioSeguradoProposta.Nome__c ='BPTeste';
        beneficiarioSeguradoProposta.CpfCnpj__c= '016.094.860-64';
        beneficiarioSeguradoProposta.Conta__c = contaPF.Id;
        beneficiarioSeguradoProposta.Pep__c = 'Nao';
        beneficiarioSeguradoProposta.GrauParentesco__c ='Avó';
        beneficiarioSeguradoProposta.SeguradoProposta__c = seguradoPropostaNova.Id;
        beneficiarioSeguradoProposta.Participacao__c = 10;
        beneficiarioSeguradoProposta.TipoBeneficiario__c ='Nome do beneficiário';
        insert beneficiarioSeguradoProposta;

        RemuneracaoProposta__c remuneracao = new RemuneracaoProposta__c (Proposta__c = propostaTipoNovo.Id);
        insert remuneracao;
        insert new FavorecidoRemuneracaoProposta__c (RemuneracaoProposta__c = remuneracao.Id, Conta__c = contaPJ.Id);

        Contract contratoTipoNovo = (Contract) new ContratoFactory.ContratoFactoryComParam(contaPF, produtoComercial, parceiro).createRecord();
        contratoTipoNovo.CodigoRamo__c = '2';
        update contratoTipoNovo;
        //PLV-4695-INICIO
        GarantiaContrato__c garantiaContrato = new GarantiaContrato__c();
        garantiaContrato.Contrato__c = contratoTipoNovo.Id;
        garantiaContrato.PremioTotal__c = 1;
        garantiaContrato.PremioPuro__c=1;
        garantiaContrato.PremioComercial__c=1;
        garantiaContrato.Capital__c=1;//FNPVVEP-51 INICIO/FIM
        insert garantiaContrato;
        //insert new GarantiaContrato__c(Contrato__c = contratoTipoNovo.Id);
        //PLV-4596-FIM
        ProdutoParceiro__c produtoParceiro = (ProdutoParceiro__c) new ProdutoParceiroFactory(parceiro, produtoComercial).createRecord();
        
        ContratanteContrato__c contratanteContrato = (ContratanteContrato__c) new ContratanteFactory(contratoTipoNovo).createRecord();
        contratanteContrato.Numero__c = 123;
        contratanteContrato.IOF__c = 10;
        contratanteContrato.Contrato__c = contratoTipoNovo.Id;
        update contratanteContrato;   
        
        //PLV-4695 - INICIO
        GarantiaContratanteContrato__c garantiaContratanteContrato =  new GarantiaContratanteContrato__c();
        garantiaContratanteContrato.ContratanteContrato__c = contratanteContrato.Id;
        garantiaContratanteContrato.PremioTotal__c = 1;
        garantiaContratanteContrato.PremioPuro__c=1;
        garantiaContratanteContrato.PremioComercial__c=1;
        insert garantiaContratanteContrato;
        //insert new GarantiaContratanteContrato__c(ContratanteContrato__c = contratanteContrato.Id);
        //PLV-4695 - FIM
       
        
	    GrupoContrato__c grupoContrato = (GrupoContrato__c) new GrupoFactory(contratanteContrato).createRecord();
        grupoContrato.Numero__c = 123;
        update grupoContrato;
        
        //PLV-4695 - INICIO
        GarantiaGrupoContrato__c garantiaContratoGrupo =  new GarantiaGrupoContrato__c();
        garantiaContratoGrupo.GrupoContrato__c = grupoContrato.Id;
        garantiaContratoGrupo.PremioTotal__c = 1;
        garantiaContratoGrupo.PremioPuro__c=1;
        garantiaContratoGrupo.PremioComercial__c=1;
        garantiaContratoGrupo.Capital__c=1;//FNPVVEP-51 INICIO|FIM
        insert garantiaContratoGrupo;
        //insert new GarantiaGrupoContrato__c(GrupoContrato__c = grupoContrato.Id);
        //PLV-4695 - FIM

        //PLV-5842 INICIO
        Profissao__c profissao = ( Profissao__c ) new ProfissaoFactory().createRecord();
        profissao.CodigoProfissao__c = '2111-05';
        profissao.IdExterno__c = '2111-05';
        profissao.Status__c = 'Ativo';
        update profissao;
        //PLV-5842 FIM

	    SeguradoContrato__c seguradoContrato = (SeguradoContrato__c) new SeguradoContratoFactory(contaPF, grupoContrato).createRecord();
        seguradoContrato.Numero__c = 123;
        seguradoContrato.Profissao__c = profissao.id; //PLV-5842 INICIO/FIM
        update seguradoContrato;
        insert new GarantiaSeguradoContrato__c(SeguradoContrato__c = seguradoContrato.Id, PremioTotal__c = 100, Capital__c = 100);//FNPVVEP-51 INICIO|FIM
     	
       	contratoTipoNovo.Empresa__c = '1';
        contratoTipoNovo.Sucursal__c = '1';
        contratoTipoNovo.NumeroApolice__c = '000012345';
        contratoTipoNovo.Name = '1-1-2-000012345-0';
        contratoTipoNovo.Endosso__c = '0';
        contratoTipoNovo.VigenciaFinal__c = contratoTipoNovo.StartDate.addMonths(3);  
        contratoTipoNovo.MeioComercializacao__c = 'CO2';
        contratoTipoNovo.Proposta__c = propostaTipoNovo.Id;
        contratoTipoNovo.RamoSeguro__c = ramoSeguro.Id;
        contratoTipoNovo.Status = 'Emitido';
        update contratoTipoNovo;
    }
    //PLV-4695 - INICIO
    @isTest
    static void testSuccess() {
        String payload = '{"orcamento":{"vigenciaInicial":"2020-08-01","segmento":"Viagem","tipoSeguro":"CAN","tipoEndosso":"INA","sucursal":"1","ramo":"2","meioComercializacao":"CO2","empresa":"1","dataCalculo":"2020-07-22","apolice":"12345","premioPago":200.55,"endosso":"0"}}'; //PLV-4695-FIX6-INICIO/FIM
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(payload);
        RestContext.request = req;
        Test.startTest();
        EndossoOrcamentoREST.gravarOrcamentoEndosso();
        Test.stopTest();
    }
    @isTest
    static void testSuccessVI() {
        String payload = '{"orcamento":{"vigenciaInicial":"2020-08-01","segmento":"Individual","tipoSeguro":"CAN","tipoEndosso":"INA","sucursal":"1","ramo":"2","meioComercializacao":"CO2","empresa":"1","dataCalculo":"2020-07-22","apolice":"000012345","premioPago":200.55,"endosso":"0"}}'; //PLV-4695-FIX6-INICIO/FIM || FNPVVEP-51 INICIO/FIM
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(payload);
        RestContext.request = req;
        Test.startTest();
        
        EndossoOrcamentoREST.gravarOrcamentoEndosso();
        Test.stopTest();
    }
    //PLV-4695 - FIM
    //FNPVVEP-51 - INICIO
    @isTest
    static void testSuccessAPTLMK() {
        Contract contrato = [SELECT Id, Produto__c, Name, NumeroApolice__c, Oportunidade__c FROM Contract LIMIT 1];
        String idProduto = contrato.Produto__c;
        System.debug('contrato >< ' + contrato);
        Product2 produto = [SELECT Id, CodigoPrecificaProduto__c FROM Product2 WHERE Id =: idProduto LIMIT 1];
        produto.CodigoPrecificaProduto__c = 'APTLMKT';
        update produto;
        String payload = '{"orcamento":{"vigenciaInicial":"2020-08-01","segmento":"Individual","tipoSeguro":"CAN","tipoEndosso":"INA","sucursal":"1","ramo":"2","meioComercializacao":"CO2","empresa":"1","dataCalculo":"2020-07-22","apolice":"000012345","premioPago":200.55,"endosso":"0"}}'; //PLV-4695-FIX6-INICIO/FIM || FNPVVEP-51 INICIO/FIM
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(payload);
        RestContext.request = req;
        Test.startTest();
        
        EndossoOrcamentoREST.gravarOrcamentoEndosso();
        Test.stopTest();
    }

    @IsTest
    static void testGerarNumeroOferta() {
        EndossoOrcamentoREST.Request request = new EndossoOrcamentoREST.Request();
        EmissaoTO emissao = new EmissaoTO();
        request.orcamento = emissao;
        Test.startTest();
        EndossoOrcamentoVIService service = new EndossoOrcamentoVIService(request);
        String numeroOferta = service.gerarNumeroOferta();
        Test.stopTest();
    }
    //FNPVVEP-51 - FIM
}