@isTest
public class MilestoneHelperTest {
//PLV-4122 - INICIO - PEDRO AUGUSTO - SYS4B
/*
    @isTest 
    static void validarCalculateMilestoneTriggerTime(){
        
 	//PLV_3046 - INICIO - Cadastro de Limite de garantia do produto - Viagem

       //Criando Conta Pessoal
        /*	Date dataContaPessoal = Date.newInstance(1985, 02, 02);
        
        	Recordtype REC_ID_PERSONACCOUNT = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica');
        	Account contaPessoal = new Account();
        	contaPessoal.RecordTypeId = REC_ID_PERSONACCOUNT.Id;
        	contaPessoal.FirstName = 'Teste';
        	contaPessoal.LastName = 'Teste_Avanxo';
        	contaPessoal.Cpf__c = '42770982826';
        	contaPessoal.Pep__c = 'Não';
        	contaPessoal.Nacionalidade__c = 'Brasileira';
        	contaPessoal.PersonBirthdate = dataContaPessoal;
        	insert contaPessoal;
        
       //Criando Garantia
        	Garantia__c garantia = TestDataFactory.gerarGarantia();
        
       //Craindo Caso Pai
			Date dataOcorrencia = Date.newInstance(2018, 01, 30);
        	Date dataAvisoCliente = Date.newInstance(2018, 05, 30);
        
        	Recordtype REC_ID_CASEPAI = RecordTypeBO.buscarTipoRegistro('Case', 'Atendimento');
        	Case casoPai = new Case();
        	casoPai.RecordTypeId = REC_ID_CASEPAI.Id;
        	casoPai.Status = 'Avisar';
        	casoPai.Status_Dependente__c = 'Em Análise';
        	casoPai.Origin = 'Email';
        	casoPai.AccountId = contaPessoal.Id;
        	casoPai.Subject = 'TestePai';
        	casoPai.Vitima__c = 'Filhos';
        	casoPai.Description = 'Teste AvanxoPai';
        	casoPai.Dataocorrencia__c = dataOcorrencia;
        	casoPai.Type = 'Sinistro';
        	casoPai.TipoEvento__c = 'Morte';
        	casoPai.Garantia__c = garantia.Id;
        	//casoPai.Data_Aviso_Cliente__c = dataAvisoCliente;	
    		insert casoPai;
        
       //Criando Ramo de Seguro
       		RamoSeguro__c ramoSeguro = TestDataFactory.gerarRamoSeguro(contaPessoal);
       
       //Criando Ramo da Garantia
       		RamoGarantia__c ramoGarantia = TestDataFactory.gerarRamoGarantia(garantia, ramoSeguro);
        
       //Criando Contador Codigo - Produto Comercial
       		ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
       //Criando Contador Codigo - Produto Tecnico
       		ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        
       //Criando Produto Técnico
       		Recordtype REC_ID_ProdutoTecnico = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico');
       			Date dataVigenciaInicialProduto = Date.newInstance(2018, 01, 30);
        		Product2 produto = new Product2();
        		produto.RecordTypeId = REC_ID_ProdutoTecnico.Id;
        		produto.Name = 'Teste AVX_Milestone';
        		produto.Status__c = 'Em criação';
        		produto.ProductCode = '00001';
        		produto.VigenciaInicial__c = dataVigenciaInicialProduto;
        		produto.TipoCapital__c = 'Capital global';
        		produto.Segmento__c = 'Individual';
        		produto.TipoResponsavelPagamento__c = 'SEG';
        		produto.NumeroSusep__c = '010101';
	   		insert produto;
        		produto.Status__c = 'Ativo';
        		update produto;
       
       //Criando Produto Comercial
       		Product2 produtoComercial = TestDataFactory.gerarProdutoComericial(produto);
        
       //Criando Garantia do Produto Técnico
       		GarantiaProduto__c garantiaProdTec = TestDataFactory.gerarGarantiaProdutoTecnico(produto, garantia, ramoSeguro);
        limiteGarantiaProduto__c limGarantiaProdTec = (limiteGarantiaProduto__c) new LimiteGarantiaProdutoFactory(garantiaProdTec).createRecord(); //PLV - 3046
        
       //Criando Garantia do Produto Comercial
       		GarantiaProduto__c garantiaProdCom = TestDataFactory.gerarGarantiaProdutoComercial(produtoComercial, garantia, garantiaProdTec, ramoSeguro);
      
       //Atualizando registro da garantia
       		garantiaProdCom.PrazoMaximoLiquidacao__c = 10;
		  	garantiaProdCom.TipoPrazoMaximoLiquidacao__c = 'Dia';
			garantiaProdCom.PrazoAvisoSinistro__c = 20;
			garantiaProdCom.TipoPrazoAvisoSinistro__c = 'Ano';
			update garantiaProdCom;
        
        //Criando Ramo de Atividade
        	RamoAtividade__c ramo = new RamoAtividade__c();
        	ramo.Name = 'Teste_Avanxo';
        
        //Criando Conta        
        	Recordtype REC_ID_ACCOUNT = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaJuridica');
        	Account conta = new Account();
        	conta.RecordTypeId = REC_ID_ACCOUNT.Id;
        	conta.Name = 'Teste_Avanxo';
        	conta.Cnpj__c = '58.924.754/0001-18';
        	conta.TipoAdministracao__c = 'Privada';
        	conta.RamoAtividade__c = ramo.Id;
        	
        	insert conta;
        
        //Criando Contato
        	Date dataContato = Date.newInstance(1999, 11, 28);
        
        	Contact contato = new Contact();
        	contato.FirstName = 'Teste';
        	contato.LastName = 'Teste_Avanxo_Milestone';
        	contato.AccountId = conta.Id;
        	contato.PEP__c = 'Não';
        	contato.CPF__c = '427.709.828-26';
        	contato.Birthdate = dataContato;
        	insert contato;
        
        //Criando Contrato
        	Date dataContrato = Date.newInstance(2012, 03, 18);
        	
        	Contract contrato = new Contract();
        	contrato.Name = '100';
        	contrato.Status = 'Em elaboração';
    		contrato.StartDate = dataContrato;
        	contrato.AccountId = contaPessoal.Id;
        	insert contrato;
        
        //Criando Contratante
        	ContratanteContrato__c contratante = new ContratanteContrato__c();
        	contratante.Contrato__c = contrato.Id;
        	contratante.TipoResponsavelPagamento__c = 'SEG';
        	insert contratante;
        
        //Criando Grupo
        	GrupoContrato__c grupo = new GrupoContrato__c();
        	grupo.Name = 'Teste_Avanxo';
        	grupo.ContratanteContrato__c = contratante.Id;
        	insert grupo;
        
        //Criando Segurado do Contrato
			Date dataVigenciaInicial = Date.newInstance(2013, 03, 12);
        	Date dataVigenciaFinal = Date.newInstance(2020, 03, 12);
        
        	SeguradoContrato__c segurado = new SeguradoContrato__c();
        	segurado.Conta__c = contaPessoal.Id;
        	segurado.GrupoContrato__c = grupo.Id;
        	segurado.VigenciaInicial__c = dataVigenciaInicial;
        	segurado.VIgenciaFinal__c = dataVigenciaFinal;
        	insert segurado;
        
        GarantiaSeguradoContrato__c garantiaSegurado = new GarantiaSeguradoContrato__c();
        	garantiaSegurado.SeguradoContrato__c = segurado.Id;
        	garantiaSegurado.Garantia__c = garantia.Id;
        	insert garantiaSegurado;
        
        	Entitlement entitle = new Entitlement();
        	entitle.AccountId = contaPessoal.Id;
        	entitle.Name = 'TesteAvx_Milestone';
        	insert entitle;
        
        //Criando Forma de Pagamento
        	FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento();
        //Criando Parceiro e atualizando contrato
        	//Gerar Parceiro Manualmente
        		Parceiro__c parceiro = new Parceiro__c();
        		parceiro.ApoliceFaturamento__c = '1';
                parceiro.DiaFaturamento__c = '15';
                parceiro.DiaPreFaturamento__c = '20';
                parceiro.PrazoVencimento__c = '10';
                parceiro.Conta__c = contaPessoal.Id;
                parceiro.FaturaProdutosSeparados__c = 'Sim';
                parceiro.PossuiAnexoFatura__c = 'Nao';
                parceiro.FormaPagamento__c = formaPagamento.Id;
                parceiro.SiglaParceiro__c = 'PAR';
                parceiro.Empresa__c = '12';
                parceiro.Sucursal__c = '12';
                parceiro.Ramo__c = '12';
        		insert parceiro;
        
        //Atualizando contrato com a parceria
        	contrato.Parceria__c = parceiro.id;
        	contrato.Produto__c = produtoComercial.id;
        	update contrato;

            Profile p = [SELECT id, Name FROM Profile WHERE Name = 'Administrador do sistema'];
        
        	User usuario = new User();
        	usuario.Username = 'TesteMilestone@Avanxo.com';
        	usuario.LastName = 'Teste';
        	usuario.Email = 'TesteMilestone@Avanxo.com';
        	usuario.Alias = 'TesteAvx';
        	usuario.CommunityNickname = 'TesteAvx';
        	usuario.TimeZoneSidKey = 'America/Sao_Paulo';
        	usuario.LocaleSidKey = 'pt_BR';
        	usuario.EmailEncodingKey = 'ISO-8859-1';
        	usuario.ProfileId = p.Id;
        	usuario.LanguageLocaleKey = 'pt_BR';
        	insert usuario;

            Group gpSinistroAvisado = [SELECT Id FROM Group WHERE DeveloperName = 'Sinistros_Avisados'];       
        
        //Criando Caso Filho (para ativação da classe MilestoneHelper)
        	Date dataOcorrenciaSinistro = Date.newInstance(2018, 01, 30);
        	Id RecordTypeIdsinistro = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sinistro').getRecordTypeId();
        	
        	Case casoFilho = new Case();
        	casoFilho.RecordTypeId = RecordTypeIdsinistro;
        	casoFilho.Status = 'Avisar';
        	casoFilho.Status_Dependente__c = 'Em Análise';
        	casoFilho.Origin = 'Pai';
        	casoFilho.ParentId = casoPai.Id;
        	casoFilho.AccountId = contaPessoal.Id;
        	casoFilho.Subject = 'Teste Caso Filho AVX';
        	casoFilho.Vitima__c = 'Filhos';
        	casoFilho.Description = 'Teste Do Filho AVX';
        	casoFilho.Dataocorrencia__c = dataOcorrenciaSinistro;
        	casoFilho.Type = 'Sinistro';
        	casoFilho.TipoEvento__c = 'Morte';
        	insert casoFilho;

        	Date dataLimiteAvisoSinistro = Date.newInstance(2019, 03, 25);
        	casoFilho.Garantia__c = garantia.Id;
        	casoFilho.ContactId = contato.Id;
        	casoFilho.Contrato__c = contrato.Id;
        	casoFilho.Garantia_do_segurado_do_contrato__c = garantiaSegurado.id;
        	casoFilho.Status = 'Avisado';
            casoFilho.Status_Dependente__c = 'Em Análise';
        	casoFilho.NumeroSinistro__c = '123';
            casoFilho.OwnerId = gpSinistroAvisado.Id;
            casoFilho.Segurado_do_Contrato__c = segurado.id;
            //PLV-2433 - Inicio - Campo criado para reparar a classe de teste
            casoFilho.ProcessaNumeroSinistro__c = true;
            //PLV-2433 - Inicio - Campo criado para reparar a classe de teste
        	//casoFilho.Data_limite_aviso_sinistro__c = dataLimiteAvisoSinistro;
        	//casoFilho.Data_sinistro_avisado__c = System.today();
        	update casoFilho;

            garantiaProdCom.TipoPrazoMaximoLiquidacao__c = 'Mês';
            update garantiaProdCom;
        	update casoFilho;
        
        	garantiaProdCom.PrazoMaximoLiquidacao__c = 1;
		  	garantiaProdCom.TipoPrazoMaximoLiquidacao__c = 'Ano';
        	update garantiaProdCom;
        	update casoFilho;
			
			
			ContadorCodigo__c contadorCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
			ContadorCodigo__c contadorCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();		
			Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
			ProdutoFactory.ProdutoTecnico produtoTecAtivar = new ProdutoFactory.ProdutoTecnico();
			produtoTecAtivar.ativar();
			Product2 produtoComercial  = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
			ProdutoFactory.ProdutoComercial produtoComAtivar = new ProdutoFactory.ProdutoComercial();
			produtoComAtivar.ativar();
			RamoSeguro__c ramoSegurado = (RamoSeguro__c) new RamoSeguroFactory().createRecord();
        	Garantia__c garantia = (garantia__c) new GarantiaFactory().createRecord();
        	RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSegurado).createRecord();
			GarantiaProduto__c garantiaProdutoTEC = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSegurado).createRecord();
			GarantiaProduto__c garantiaProduto = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garantiaProdutoTEC, ramoSegurado).createRecord();
			Account contaPessoaFisica = (Account) new AccountFactory.PessoaFisica().createRecord();
			FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
			Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaPessoaFisica, formaPagamento).createRecord();
			Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaPessoaFisica, produtoComercial, parceiro).createRecord();
			Case casoPai = (Case) new CasoFactory.AtendimentoSinistro(contaPessoaFisica).createRecord();
			Case casoFilho = (Case) new CasoFactory.Sinistro(casoPai, contaPessoaFisica).createRecord();
			ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
			GrupoContrato__c grupoContrato = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
			SeguradoContrato__c seguradoContrato = (SeguradoContrato__c) new SeguradoContratoFactory(contaPessoaFisica, grupoContrato).createRecord();
			GarantiaSeguradoContrato__c garantiaSegurado = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(seguradoContrato, garantia).createRecord();
			casoFilho.Garantia_do_segurado_do_contrato__c = garantiaSegurado.Id;
			casoFilho.contrato__c = contrato.Id;
			casofilho.Data_sinistro_avisado__c = System.now().date();
			upsert casoFilho;	

			Test.startTest();
				MilestoneType milestoneType = [SELECT id, name 
											  FROM MilestoneType 
											  WHERE name = 'Aviso de sinistro' LIMIT 1]; //PLV-4009 - Inicio/Fim
		
				MilestoneHelper MilestoneHelper = new MilestoneHelper();
				Integer tempo = MilestoneHelper.calculateMilestoneTriggerTime(casoFilho.Id, milestoneType.Id);
				System.assert(tempo != 0, 'Tipo do Milestone "Aviso de sinistro" não encontrado!'); //PLV-4009 - Inicio/Fim
        
        	Test.stopTest();
		
		//PLV_3046 - FIM - Cadastro de Limite de garantia do produto - Viagem	
		
	}
	*/
	//PLV-4122 - FIM - PEDRO AUGUSTO - SYS4B
	//PLV-4122 - INICIO - PEDRO AUGUSTO - SYS4B
	@isTest
    static void validarPrazoReaberturaSinistroCalculateMilestoneTriggerTime(){
			BotaoReabrirSinistroControllerTest.setup();

			Test.startTest();
			
				Recordtype REC_ID_CASESINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');
				Case caso = [SELECT Id, Status FROM Case WHERE RecordTypeId=:REC_ID_CASESINISTRO.Id LIMIT 1];

				List<ReaberturaSinistro__mdt> metaSLA= [SELECT Marco__c, Tempo_minutos__c, TipoRegistro__c FROM ReaberturaSinistro__mdt WHERE TipoRegistro__c='Tempo Marco Sinistro'];
        
				Map<String,Decimal> mapProcessoMarco = new Map<String,Decimal>();
				for(ReaberturaSinistro__mdt sla :metaSLA){
					mapProcessoMarco.put(sla.Marco__c,sla.Tempo_minutos__c);
				}
				
				List<MilestoneType> milestoneTypes = [SELECT id, name 
											  FROM MilestoneType 
											  WHERE name IN: mapProcessoMarco.keyset()];
				
				MilestoneHelper MilestoneHelper = new MilestoneHelper();
				for(MilestoneType milestoneType : milestoneTypes){
					Integer tempo = MilestoneHelper.calculateMilestoneTriggerTime(caso.Id, milestoneType.Id);
					System.assert(tempo!=0);
					
				}
        
			Test.stopTest();
	}

	@isTest
    static void ReabrindoOcasoMilestoneTriggerTime(){
			BotaoReabrirSinistroControllerTest.setup();

			Test.startTest();
			
				Recordtype REC_ID_CASESINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');
				Case caso = [SELECT Id, Status FROM Case WHERE RecordTypeId=:REC_ID_CASESINISTRO.Id LIMIT 1];



				GarantiaSeguradoContrato__c garanSegCont= [SELECT Id FROM GarantiaSeguradoContrato__c LIMIT 1];
				PagamentoGarantia__c pgto = new PagamentoGarantia__c(
						Caso__c = caso.Id,
						Garantia_do_segurado_do_contrato__c = garanSegCont.Id,
						Name = 'TestPagamentoGarantia',
						Capital__c = 100.00, 
						Fase__c = 'Aberto',
						Valor_indenizado__c = 50000
					);
				insert pgto;
				pgto.Fase__c = 'Em análise';
				pgto.Status_do_pagamento__c='Cancelado';
				update pgto;

				caso.Status = 'Fechado';
				caso.Status_Dependente__c = 'Cancelado';
				caso.Motivos_de_recusa__c ='4';
				update caso;


				Map<String,Object> retornoReabrir = BotaoReabrirSinistroController.reabrirSinistro(caso.Id, 'Fechamento indevido','Calcular Tempo', 'teste');


				

				List<ReaberturaSinistro__mdt> metaSLA= [SELECT Marco__c, Tempo_minutos__c, TipoRegistro__c FROM ReaberturaSinistro__mdt WHERE TipoRegistro__c='Tempo Marco Sinistro'];
        
				Map<String,Decimal> mapProcessoMarco = new Map<String,Decimal>();
				for(ReaberturaSinistro__mdt sla :metaSLA){
					mapProcessoMarco.put(sla.Marco__c,sla.Tempo_minutos__c);
				}
				
				List<MilestoneType> milestoneTypes = [SELECT id, name 
											  FROM MilestoneType 
											  WHERE name IN: mapProcessoMarco.keyset()];
				
				MilestoneHelper MilestoneHelper = new MilestoneHelper();
				for(MilestoneType milestoneType : milestoneTypes){
					Integer tempo = MilestoneHelper.calculateMilestoneTriggerTime(caso.Id, milestoneType.Id);
					System.assert(tempo!=0);
					
				}
        
			Test.stopTest();
	}
	//PLV-4122 - FIM - PEDRO AUGUSTO - SYS4B
	
	
}