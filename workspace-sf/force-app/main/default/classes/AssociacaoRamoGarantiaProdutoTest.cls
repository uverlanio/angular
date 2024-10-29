@isTest
private class AssociacaoRamoGarantiaProdutoTest {
	@isTest
	static void testePagina() {
		Account contaTeste = new Account(Name = 'Conta 14', CodigoEmpresa__c = '14', cnpj__c = '31.641.896/0001-11');
		insert contaTeste;

		//Insere ramos
		RamoSeguro__c ramoVida = new RamoSeguro__c(
			Name = 'VIDA',
			CodigoEmpresa__c = '14',
			Codigo__c = '2',
			IdExterno__c = '14_2',
			Empresa__c = contaTeste.Id,
			Status__c = 'Ativo',
			CodigoOrigemDoMovimentoBCP__c = '32' //PLV-3773 INICIO/FIM - incluso campo para rega de validação
		);
		insert ramoVida;

		//Insere garantia
		Garantia__c garantia = new Garantia__c();
		garantia.VigenciaInicial__c = System.today();
		garantia.Tipo__c = 'Cobertura';
		insert garantia;

		//Insere ramos garantia
		RamoGarantia__c ramoGarantia = new RamoGarantia__c(
			CodigoRamo__c = '12',
			Garantia__c = garantia.Id,
			NomeRamo__c = 'XPTO',
			RamoSeguro__c = ramoVida.Id
		);
		insert ramoGarantia;

		//Realiza teste
		String ramosStr = AssociacaoRamoGarantiaProdutoController.buscarRamosSeguro(ramoGarantia.Garantia__c);
		List<CustomPickListOptionTO> listaOpcoesRamos = (List<CustomPickListOptionTO>)JSON.deserialize(ramosStr, List<CustomPickListOptionTO>.class);
		System.assertEquals(listaOpcoesRamos.get(0).value, ramoVida.Id);
	}
}