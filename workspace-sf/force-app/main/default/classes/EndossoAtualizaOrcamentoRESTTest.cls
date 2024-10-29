/****
@description Classe de teste para EndossoAtualizaOrcamentoREST
@author Isabela Fin - Globant
@date 22/07/2020
-Classe criada por conta da historia PLV-3926    
*****/
@isTest
public class EndossoAtualizaOrcamentoRESTTest {
    
	@TestSetup
    static void createData(){
        Account contaPF = (Account) new AccountFactory.PessoaFisica().createRecord();
        Account contaPJ = (Account) new AccountFactory.PessoaJuridica().createRecord();
        
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
        
        Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();
        garantia.Sigla__c = 'MAP';
        update garantia;
        
        Opportunity orcamentoTipoNovo = (Opportunity) new OrcamentoFactory.VidaIndividual(produtoComercial, contaPF).createRecord();
        orcamentoTipoNovo.StageName = 'Disponível para contratação';
        orcamentoTipoNovo.Numero__c = '00054321';
        orcamentoTipoNovo.Origem__c = '18';
        update orcamentoTipoNovo;
        insert new GarantiaOrcamento__c (Orcamento__c = orcamentoTipoNovo.Id, Garantia__c = garantia.Id);
        
        ContratanteOrcamento__c contratanteOrcNovo = (ContratanteOrcamento__c) new contratanteOrcamentoFactory(orcamentoTipoNovo).createRecord();
        insert new GarantiaContratanteOrcamento__c (ContratanteOrcamento__c = contratanteOrcNovo.Id, Garantia__c = garantia.Id);
        
        GrupoOrcamento__c grupoOrcNovo = (GrupoOrcamento__c) new grupoOrcamentoFactory(contratanteOrcNovo).createRecord();
        insert new GarantiaGrupoOrcamento__c (GrupoOrcamento__c = grupoOrcNovo.Id, Garantia__c = garantia.Id);

        SeguradoOrcamento__c seguradoOrcNovo = (SeguradoOrcamento__c) new seguradoOrcamentoFactory(contaPF,grupoOrcNovo).createRecord();
        seguradoOrcNovo.Numero__c = 1;
        update seguradoOrcNovo;
        insert new GarantiaSeguradoOrcamento__c (SeguradoOrcamento__c = seguradoOrcNovo.Id, Garantia__c = garantia.Id);

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
        insert new GarantiaContrato__c(Contrato__c = contratoTipoNovo.Id);
        
        ProdutoParceiro__c produtoParceiro = (ProdutoParceiro__c) new ProdutoParceiroFactory(parceiro, produtoComercial).createRecord();
        
        ContratanteContrato__c contratanteContrato = (ContratanteContrato__c) new ContratanteFactory(contratoTipoNovo).createRecord();
        contratanteContrato.Numero__c = 123;
        contratanteContrato.IOF__c = 10;
        contratanteContrato.Contrato__c = contratoTipoNovo.Id;
        update contratanteContrato;        
        insert new GarantiaContratanteContrato__c(ContratanteContrato__c = contratanteContrato.Id);
        
	    GrupoContrato__c grupoContrato = (GrupoContrato__c) new GrupoFactory(contratanteContrato).createRecord();
        grupoContrato.Numero__c = 123;
        update grupoContrato;
        insert new GarantiaGrupoContrato__c(GrupoContrato__c = grupoContrato.Id);
        
	    SeguradoContrato__c seguradoContrato = (SeguradoContrato__c) new SeguradoContratoFactory(contaPF, grupoContrato).createRecord();
        seguradoContrato.Numero__c = 123;
        update seguradoContrato;
        insert new GarantiaSeguradoContrato__c(SeguradoContrato__c = seguradoContrato.Id);
     	
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
        
        Contract contratoOriginal = contratoTipoNovo.clone(false, false, false, false);
        contratoOriginal.NumeroApolice__c = '000054321';
        contratoOriginal.Name = '1-1-2-000054321-0';
		insert contratoOriginal;
		
        orcamentoTipoNovo.ContractId = contratoOriginal.Id;
        update orcamentoTipoNovo;
    }
    
    @isTest
    static void testSuccess() {
        StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadEndossoAtualizaOrcamento' LIMIT 1];
    	String payload = staticResource.Body.toString();
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(payload);
        RestContext.request = req;
        Test.startTest();
        EndossoAtualizaOrcamentoREST.Response result = EndossoAtualizaOrcamentoREST.gravarOrcamentoEndosso();
        System.debug('result ' + result);
        Test.stopTest();
    }
}