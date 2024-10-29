/*******************************************************************************************************************************
* Classe de teste para PropostaGenericaCancelamentoBuilder
* @author Isabela Fin - Globant
* @date 03/07/2020
* Classe criada por conta da historia PLV-3989
******************************************************************************************************************************/
@IsTest
public class PropostaGenericaCancelamentoBuilderTest {

    @TestSetup
    static void setup(){
        Account contaPF = (Account) new AccountFactory.PessoaFisica().createRecord();
        Account contaPJ = (Account) new AccountFactory.PessoaJuridica().createRecord();
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
	    ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
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
        contratoTipoNovo.CodigoRamo__c = '7';
        update contratoTipoNovo;
        
        ProdutoParceiro__c produtoParceiro = TestDataFactory.gerarProdutoParceiro(parceiro, produtoComercial);
        
        ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contratoTipoNovo).createRecord();
        contratante.Numero__c = 123;
        contratante.IOF__c = 10;
        contratante.Contrato__c = contratoTipoNovo.Id;
        update contratante;
        
	    GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
        grupo.Numero__c = 123;
        update grupo;
        
	    SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(contaPF, grupo).createRecord();
        segurado.Numero__c = 123;
        update segurado;
     	
       	contratoTipoNovo.Empresa__c = '1';
        contratoTipoNovo.Sucursal__c = '1';
        contratoTipoNovo.NumeroApolice__c = '12345';
        contratoTipoNovo.Endosso__c = '0';
        contratoTipoNovo.VigenciaFinal__c = contratoTipoNovo.StartDate.addMonths(3);  
        contratoTipoNovo.MeioComercializacao__c = 'CO2';
        contratoTipoNovo.Proposta__c = propostaTipoNovo.Id;
        contratoTipoNovo.RamoSeguro__c = ramoSeguro.Id;
        contratoTipoNovo.Status = 'Emitido';
        update contratoTipoNovo;

        Opportunity orcamentoTipoCancelamento = orcamentoTipoNovo.clone(false, false, false, false);
        orcamentoTipoCancelamento.Name = 'ARQ-00005556';
        orcamentoTipoCancelamento.Numero__c = '00005556';
        orcamentoTipoCancelamento.Type = 'CAN';
        orcamentoTipoCancelamento.StageName = 'Em criação';
        insert orcamentoTipoCancelamento;
        orcamentoTipoCancelamento.ContractId = contratoTipoNovo.Id;
        orcamentoTipoCancelamento.StageName = 'Disponível para contratação';
        orcamentoTipoCancelamento.Origem__c = '18';
        update orcamentoTipoCancelamento;

        Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();

        GarantiaOrcamento__c garantiaOrcamentoCan = (GarantiaOrcamento__c) new GarantiaOrcamentoFactory(garantia, orcamentoTipoCancelamento).createRecord();

        ContratanteOrcamento__c contratanteOrcCan = contratanteOrcNovo.clone(false,false,false,false);
        contratanteOrcCan.Orcamento__c = orcamentoTipoCancelamento.Id;
        insert contratanteOrcCan;
        insert new GarantiaContratanteOrcamento__c (ContratanteOrcamento__c = contratanteOrcCan.Id);

        GrupoOrcamento__c grupoOrcCan = grupoOrcNovo.clone(false, false, false, false);
        grupoOrcCan.ContratanteOrcamento__c = contratanteOrcCan.Id;
        insert grupoOrcCan;
        insert new GarantiaGrupoOrcamento__c (GrupoOrcamento__c = grupoOrcCan.Id);

        SeguradoOrcamento__c seguradoOrcCan = seguradoOrcNovo.clone(false, false, false, false);
        seguradoOrcCan.Conta__c = contaPF.Id;
        seguradoOrcCan.GrupoOrcamento__c = grupoOrcCan.Id;
        insert seguradoOrcCan;
        insert new GarantiaSeguradoOrcamento__c (SeguradoOrcamento__c = seguradoOrcCan.Id);
    }

    @IsTest
    static void gerarPropostaCancelamentoTest() {
        PropostaEndossoTO proposta = new PropostaEndossoTO();
		PropostaTO p = new PropostaTO();

        p.numeroOrcamento = 5556;
        p.tipoSeguro = 'CAN';
        proposta.proposta = new PropostaTO();
        proposta.proposta = p;

        RestRequest requestCancelamento = new RestRequest();
        requestCancelamento.requestUri ='/services/apexrest/proposta/cancelamento';
        requestCancelamento.httpMethod = 'POST';
        requestCancelamento.requestBody = Blob.valueOf(JSON.serialize(proposta));
        
        Test.startTest();
            RestContext.request = requestCancelamento;
            PropostaREST.processarPost();
        Test.stopTest();    
    }

    public class PropostaEndossoTO {
        public PropostaTO proposta {get; set;}
	}

	public class PropostaTO {
		public Integer numeroOrcamento {get; set;}
		public String tipoSeguro { get; set; }
	}  
}