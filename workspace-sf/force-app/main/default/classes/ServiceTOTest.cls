/**
 * @description       : 
 * @author            : giordano.menezes@globant.com
 * @group             : 
 * @last modified on  : 12-08-2022
 * @last modified by  : giordano.menezes@globant.com
**/
@isTest
private class ServiceTOTest 
{
	@isTest
	static void testEstruturasSerivceTO()
	{
		CarregarEstruturasServiceTO.getInstance().ExecutarCargaEstruturasServiceTo();
	}


	//INICIO - PLV-4614-VI-Guilherme Brito
	@isTest
	public static void Testvalidar() {
		ServiceTO.CobrancaCartaoOfflineTO cobrancaCartaoOfflineTOTeste = new ServiceTO.CobrancaCartaoOfflineTO();
	//	ServiceTO.CobrancaCartaoOfflineTO chamarValidar = new ServiceTO.CobrancaCartaoOfflineTO();

		cobrancaCartaoOfflineTOTeste.numeroReferencia = '1234';
		cobrancaCartaoOfflineTOTeste.quantidadeParcelas = 0;
		cobrancaCartaoOfflineTOTeste.valor = 20.0;
		cobrancaCartaoOfflineTOTeste.idFiscal = '';
		cobrancaCartaoOfflineTOTeste.ticket = '';
		cobrancaCartaoOfflineTOTeste.tipoIdFiscal = '';
		cobrancaCartaoOfflineTOTeste.validadeCriptografada = '';

		Test.startTest();
	      cobrancaCartaoOfflineTOTeste.validar();
			//chamarValidar.dtoCobranca(critDoc2);
		Test.stopTest();
	}

	@isTest
	public static void testNovoCartaoTO() {
		ServiceTO.NovoCartaoTO novoCartao = new ServiceTO.NovoCartaoTO();
		ServiceTO.NovoCartaoTO chamarValidar = new ServiceTO.NovoCartaoTO();
		CartaoCredito__c pCartao = (CartaoCredito__c) new CartaoCreditoFactory.PessoaFisica().createRecord();

		novoCartao.cartao = 'tESTE';
		novoCartao.cvv = '1234';
		novoCartao.numeroReferencia = '123';
		novoCartao.validadeCartao = '123';

		Test.startTest();
			chamarValidar.dtoCartao(pCartao);
		Test.stopTest();
	}

	//FIM - PLV-4614-VI-Guilherme Brito
}