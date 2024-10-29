@isTest
private class CondicaoCobrancaTriggerHandlerTest {
	
	@testSetup 
	static void setup(){
        TestDataFactory.gerarDadosSetup();

        //testInsertGarantiaProposta();
	}

    @isTest
    public static void testInsertCondicaoCobranca(){
    	
    	Account conta = new Account(
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica').Id,
            LastName = 'Teste2',
            Nacionalidade__c = 'Brasileira',
            CPF__c = '00478394659',
            Rg__c = '232323231',
            DataExpedicao__c = Date.today(),
            OrgaoExpedidor__c = '123132',
            PersonBirthDate = Date.valueOf('1980-12-24'),
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

        Product2 produtoTec = new Product2(
                Name = 'Nome Produto Teste Versao',
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

        produtoTec.Status__c = 'Em ativação';
		produtoTec.NumeroSusep__c = '1234x';
		update produtoTec;

		produtoTec.Status__c = 'Ativo';
		update produtoTec;

    	RamoSeguro__c ramoVida = TestDataFactory.gerarRamoSeguro(conta);
        Modalidade__c modalidade1 = TestDataFactory.gerarModalidade(ramoVida);
        FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento(ramoVida,modalidade1,'Boleto','BOL');
        // PLV-3316 - INICIO
    	CondicaoCobranca__c condicaoCobranca = TestDataFactory.gerarCondicaoCobranca(produtoTec,formaPagamento);
    	condicaoCobranca.QuantidadeParcelas__c = '1,2'; 
        try{
			 update condicaoCobranca;            
        }catch(Exception error){
            System.assert(error.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }
        System.debug('atualização condicao cobranca' + condicaoCobranca);
        System.assertEquals(true, (condicaoCobranca != null));
        // PLV-3316 - FIM
    }
	
}