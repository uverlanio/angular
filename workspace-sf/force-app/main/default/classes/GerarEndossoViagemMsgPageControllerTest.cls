/********************************************************************************************************************
* Gerar Endosso Viagem Mensagem Controler Test
* @author Squad_Globant
* @date 29/06/2021
* Classe criada por conta da história PLV-5063
*********************************************************************************************************************/
@IsTest
public class GerarEndossoViagemMsgPageControllerTest {
   
    @IsTest
    public static void GerarEndossoViagemMsgPageControllerTest(){
        
        Account conta = new Account(
			RecordTypeId = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica').Id,
			LastName = 'Teste',
			Nacionalidade__c = 'Brasileira',
			CPF__c = '00478394659',
			Rg__c = '232323231',
			DataExpedicao__c = Date.today(),
			OrgaoExpedidor__c = '123132',
			PersonBirthDate = (Date.today()-7300),
			EstadoCivil__c = 'Solteiro (a)'
		);
		insert conta;

		Opportunity oportunidade = new Opportunity(
			Name = 'Teste Contrato',
			StageName = 'Em criação',
			RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaIndividual').Id,
			AccountId = conta.Id,
			CloseDate = Date.today()
		);
		insert oportunidade;

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
			Name= 'Teste Contrato',
			OpportunityId=oportunidade.Id,
			DataProtocolo__c = Date.today(),
			DataCalculo__c =  Date.today(),
			Empresa__c = conta.Id,
			ExpirationDate = Date.today(),
			Produto__c = produtoComercial.id //TKCL-246 FIX05 INICIO/FIM
		);
		insert proposta;

		ContratanteProposta__c segurado = new ContratanteProposta__c(
			conta__c = conta.Id,
			Proposta__c = proposta.Id,
			Tipo__c = 'Principal'
		);
		insert segurado;

		GrupoProposta__c grupo = new GrupoProposta__c(
			Name = 'Teste',
			QuantidadeVidas__c = 1,
			ContratanteProposta__c = segurado.Id
		);
		insert grupo;

		SeguradoProposta__c vida = new SeguradoProposta__c(
			Conta__c = conta.Id,
			GrupoProposta__c = grupo.Id
		);
		insert vida;

		// PLV-5098 FIX01 INICIO
		/*BeneficiarioSeguradoProposta__c beneficiario = new BeneficiarioSeguradoProposta__c(
			SeguradoProposta__c = vida.Id,
			CpfCnpj__c = '00478394659',
			Nome__c = 'Teste Contrato',
			TipoBeneficiario__c = 'Nome do beneficiário',
			GrauParentesco__c = 'Pai',
			Participacao__c = 100,
			Pep__c = 'Não'
		);
		insert beneficiario;

		BeneficiarioSeguradoProposta__c beneficiario2 = new BeneficiarioSeguradoProposta__c(
			SeguradoProposta__c = vida.Id,
			CpfCnpj__c = '99235310075',
			Nome__c = 'Teste Contrato',
			TipoBeneficiario__c = 'Nome do beneficiário',
			GrauParentesco__c = 'Pai',
			Participacao__c = 100,
			Pep__c = 'Não'
		);
        insert beneficiario2;*/
		// PLV-5098 FIX01 FIM
        
        Quote proposta1 = [SELECT Id FROM Quote WHERE Name = 'Teste Contrato'];
		Opportunity oportunidade1 = [SELECT Id FROM Opportunity WHERE Name = 'Teste Contrato'];
		List<Account> conta1 = [SELECT id FROM Account WHERE LastName = 'Teste'];
		
		Contract contrato = new Contract(
			Name = '111',
			Oportunidade__c = oportunidade1.Id,
			Proposta__c = proposta1.Id,
            Tipo__c = 'Novo',
            Status = 'Emitido',
			AccountId = conta1[0].Id,
            VigenciaFinal__c=System.today().addDays(360)              
		);        
        insert contrato;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(contrato);
        GerarEndossoViagemMsgPageController gera = new GerarEndossoViagemMsgPageController(sc);        
        PageReference pageRef = Page.GerarEndossoViagemMensagem;
        String mensagem = 'A quantidade de dias do endosso de extensão de viagem é superior à permitida pelo produto contratado.';         
        pageRef.getParameters().put('idContrato',contrato.Id);
        pageRef.getParameters().put('mensagem',mensagem);  
        
        Test.setCurrentPage(pageRef); 
        Test.startTest();        
        gera.redirectEndossoViagem(); 
        Test.stopTest();
        contrato = [SELECT Id, Name, Status FROM Contract WHERE Id =: contrato.Id];        
        System.assert(contract.Status != null);
    }
}