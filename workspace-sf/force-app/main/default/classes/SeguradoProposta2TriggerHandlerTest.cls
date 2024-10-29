@isTest
private class SeguradoProposta2TriggerHandlerTest {
	
        
// 	@testSetup 
// 	static void setup(){
//         TestDataFactory.gerarDadosSetup();

//         //testInsertGarantiaProposta();
// 	}

//     @isTest
//     public static void testInsertSeguradoProposta2(){
    	
//     	Account conta = new Account(
//             RecordTypeId = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica').Id,
//             LastName = 'Teste2',
//             Nacionalidade__c = 'Brasileira',
//             CPF__c = '99922211176',
//             Rg__c = '232323231',
//             DataExpedicao__c = Date.today(),
//             OrgaoExpedidor__c = '123132',
//             PersonBirthDate = Date.valueOf('1980-12-24'),
//             EstadoCivil__c = 'Solteiro (a)'
//         );
//         insert conta;

//         Opportunity oportunidade = new Opportunity(
//             Name = 'Teste Contrato',
//             StageName = 'Em criação',
//             RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaIndividual').Id,
//             AccountId = conta.Id,
//             CloseDate = Date.today()
//         );
//         insert oportunidade;

//         Product2 produtoTec = new Product2(
//                 Name = 'Nome Produto Teste Versao',
//                 Status__c = 'Em criação',
//                 ProductCode = '201700001',
//                 VigenciaInicial__c = System.today().addDays(3),
//                 TipoCapital__c = 'Capital uniforme',
//                 Segmento__c = 'Coletivo',
//                 TipoResponsavelPagamento__c = 'PAR',
//                 NumeroSusep__c = '12345',
//                 RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id,
//                 Versao__c                       = 1,
//                 VersaoMaxima__c                 = true,
//                 VersaoRenovacao__c              = 'Versão atual'
//         );

//         insert produtoTec;

//         produtoTec.Status__c = 'Em ativação';
// 		produtoTec.NumeroSusep__c = '1234x';
// 		update produtoTec;

// 		produtoTec.Status__c = 'Ativo';
// 		update produtoTec;

//         Product2 produtoComercial = new Product2(
//                 ProdutoTecnico__c               = produtoTec.Id,
//                 Name                            = 'Nome Produto Teste Versao',
//                 Status__c                       = 'Em criação',
//                 ProductCode                     = '201700001',
//                 VigenciaInicial__c              = System.today(),
//                 VigenciaFinal__c                = System.today().addDays(1),
//                 TipoCapital__c                  = 'Capital uniforme',
//                 Segmento__c                     = 'Coletivo',
//                 TipoResponsavelPagamento__c     = 'PAR',
//                 LimiteTotalCarregamento__c      = 200,
//                 NumeroSusep__c                  = '12345',
//                 RecordTypeId                    = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id,
//                 Versao__c                       = 1,
//                 VersaoMaxima__c                 = true,
//                 VersaoRenovacao__c              = 'Versão atual'
//         );
//         insert produtoComercial;

//         RamoSeguro__c ramoSeguro = new RamoSeguro__c(
//                 Name = 'VIDA',
//                 CodigoEmpresa__c = '214',
//                 Codigo__c = '2',
//                 IdExterno__c = '214_2',
//                 Empresa__c = conta.Id,
//                 Status__c = 'Ativo'
//         );
//         insert ramoSeguro;

//         Garantia__c garantia = new Garantia__c(
//                 VigenciaInicial__c = System.today(),
//                 Tipo__c = 'Cobertura',
//                 Sigla__c = 'CAP'
//         );
//         insert garantia;

//         RamoGarantia__c ramoGarantia = new RamoGarantia__c(
//                 Garantia__c = garantia.Id,
//                 RamoSeguro__c = ramoSeguro.Id
//         );
//         insert ramoGarantia;

//         GarantiaProduto__c garantiaProduto = new GarantiaProduto__c(
//                 Garantia__c = garantia.Id,
//                 Produto__c = produtoTec.Id,
//                 RamoSeguro__c = ramoSeguro.Id,
//                 OrdemPrioridade__c = 1,
//                 RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoTecnico').Id,
//                 TipoGarantia__c = 'Cobertura',
//                 TipoCapital__c = 'Capital uniforme',
//                 CodigoPromocao__c = 'VI005',
//                 VersaoTitulo__c = '1'
//         );
//         insert garantiaProduto;

//         Modalidade__c modalidade = new Modalidade__c(
//                 RamoSeguro__c = ramoSeguro.Id,
//                 Name = 'Mod teste',
//                 Codigo__c = '0'
//         );
//         insert modalidade;

//         FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento(ramoSeguro,modalidade,'Boleto','BOL');
//         DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(conta);
//         Quote proposta = TestDataFactory.gerarPropostaObjeto(produtoComercial, ramoSeguro, conta, dadosCorretor, oportunidade, modalidade);

//         ContratanteProposta__c seguradoProposta = TestDataFactory.gerarSeguradoProposta(conta, proposta, formaPagamento);
//     	GrupoProposta__c grupoProposta = TestDataFactory.gerarGrupoProposta(seguradoProposta);
//     	SeguradoProposta2__c SeguradoProposta2 = TestDataFactory.gerarSeguradoProposta2(conta, grupoProposta, formaPagamento);

// 		SeguradoProposta2.Numero__c = 1;
// 		update SeguradoProposta2;

//     	System.assertEquals(true, (SeguradoProposta2 != null));


//     }
	
}