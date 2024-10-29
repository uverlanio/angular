/**
 * EnderecoTest
 * @author Fernando Barcellos @ 19/12/2017
 *
 **/
@isTest
private class EnderecoTest {

    @testSetup
    private static void setup() {
        TestDataFactory.gerarDadosSetup();
    }

	@isTest
	static void validarEnderecoMaisAtual() {
		// PLV-4472 INICIO
    Account conta = new Account(Name = 'Conta Teste', Cnpj__c = '38.579.897/0001-22');
    // PLV-4472 FIM
		insert conta;

		Endereco__c endereco1 = new Endereco__c(Conta__c = conta.Id, MaisAtual__c = true);
		insert endereco1;

		EnderecoDAO.getInstance().buscarEnderecoConta(conta.Id);
		AccountBO.getInstance().buscarContaInfomacoesBancarias(conta.Id);

		// TRICKY
		TriggerHandler.clearAllBypasses(); 
		
		Endereco__c endereco2 = new Endereco__c(Conta__c = conta.Id, MaisAtual__c = true);
		insert endereco2;

		Endereco__c endereco1Atualizado = [SELECT Id, Conta__c, MaisAtual__c FROM Endereco__c WHERE Id =: endereco1.Id];
		System.assertEquals(false, endereco1Atualizado.MaisAtual__c);

		Endereco__c endereco2Atualizado = [SELECT Id, Conta__c, MaisAtual__c FROM Endereco__c WHERE Id =: endereco2.Id];
		System.assertEquals(true, endereco2Atualizado.MaisAtual__c);
	}

	@isTest
	static void validarBuscarEnderecoLogradouro()
	{
		EnderecoBO bo = EnderecoBO.getInstance();

    String responseJsonString = '{\"obterLogradourosPorLogradouroResponse\":{\"enderecosGuiaPostalLocal\":{\"enderecoGuiaPostalLocal\":[{\"codigoLogradouro\":\"464330\",\"nomeLogradouro\":\"PEREIRA BARRETO \",\"complementoLogradouro\":\"\",\"tipoLogradouro\":\"AV \",\"numeroCepLogradouro\":\"09751\",\"complementoCepLogradouro\":\"0\",\"codigoFonetico\":\"OK \",\"primeiroCodigoFonetico\":\"cACF!!!{/?c!!!! \",\"segundoCodigoFonetico\":\"cACF!!!{/?c!!!! \",\"terceiroCodigoFonetico\":\"cACF!!!{/?c!!!! \",\"bairro\":{\"codigoBairro\":\"24247\",\"nomeBairro\":\"BAETA NEVES \"},\"cidade\":{\"codigoCidadeLocalidade\":\"9640\",\"complementoCepCidade\":\"1\",\"nomeCidadeNoGuiaPostal\":\"SAO BERNARDO DO CAMPO \",\"numeroCepLogradouro\":\"09600\",\"observacaoCidade\":\"\",\"primeiroCodigoFonetico\":\"&#124;-!!!{AY/7J{dE! \",\"segundoCodigoFonetico\":\"&#124;-!!!!!{AY/7E!! \",\"terceiroCodigoFonetico\":\"&#124;-!!!!!J{dE!!!! \"},\"unidadeFederacao\":{\"codigoUnidadeFederacao\":\"SP\",\"nomeUnidadeFedearacao\":\"SAO PAULO \",\"ultimaAtualizacaoLinha\":\"06/03/2018 \"},\"geolocalizacao\":{\"latitude\":\"-23.685710346999926\",\"longitude\":\"-46.547429283999634\"}}]}}}';

    Test.setMock(HttpCalloutMock.class, new MockHttpResponse(responseJsonString, 200, 'OK'));
    Test.startTest();
    List<ServiceTO.ListResultadoRetornoBuscaEndereco> lstRetornoBuscaEnderecos = bo.buscarEndereco('','','','PEREIRA BARRETO','SAO BERNARDO DO CAMPO','SP','1201');
    Test.stopTest();
    System.assert(lstRetornoBuscaEnderecos.size() > 0);
	}

  @isTest
  static void buscarEnderecoUF()
  {
    EnderecoBO bo = EnderecoBO.getInstance();

    String responseJsonString = '{"obterCidadeResponse":{"obterCidadeEBO":{"enderecoGuiaPostalEBO":[{"codigoCidade":"8853","cepCidade":"17800","cepComplementoCidade":"0","cidadeObservacao":null,"primeiroCodigoFoneticoCidade":"*yT{m>&!!!!!!!!","segundoCodigoFoneticoCidade":"*yT{m>&!!!!!!!!","terceiroCodigoFoneticoCidade":"*yT{m>&!!!!!!!!","unidadeFederativaCodigo":"SP","nomeCidade":"ADAMANTINA"}]}}}';

    Test.setMock(HttpCalloutMock.class, new MockHttpResponse(responseJsonString, 200, 'OK'));
    Test.startTest();
    List<ServiceTO.ListResultadoRetornoBuscaEndereco> lstRetornoBuscaEnderecos = bo.buscarEndereco('SP','','','','','','');
    Test.stopTest();

    System.assert(lstRetornoBuscaEnderecos.size() > 0);

  }

  @isTest
  static void atualizarEnderecoSegurados() {
    // PLV-2312-28 INICIO
    Map<String,List<SObject>> dados = TestDataFactory.gerarOrcamento(false);
    // PLV-2312-28 FIM
    Opportunity orcamento = (Opportunity)dados.get('Opportunity').get(0);
    Account conta = (Account)dados.get('Account').get(0);

    //Verifica endereço atual do segurado
    ContratanteOrcamento__c segurado = [Select Id, Logradouro__c From ContratanteOrcamento__c Where Orcamento__c = :orcamento.Id];
    System.assertEquals('Rua Teste', segurado.Logradouro__c);

    //Gera endereço para a conta vinculada ao segurado
    TriggerHandler.clearAllBypasses();
    Endereco__c endereco = gerarEndereco(conta, 'Rua do Azar', true);

    segurado = [Select Id, Logradouro__c, Conta__c From ContratanteOrcamento__c Where Conta__c = :conta.Id];
    System.assertEquals(endereco.Logradouro__c, segurado.Logradouro__c);

    //Atualiza endereço e consequentemente, endereço do segurado também
    TriggerHandler.clearAllBypasses();
    endereco.Logradouro__c = 'Rua da Sorte';
    update endereco;

    segurado = [Select Id, Logradouro__c From ContratanteOrcamento__c Where Orcamento__c = :orcamento.Id];
    System.assertEquals(endereco.Logradouro__c, segurado.Logradouro__c);
  }

  //TODO: COLOCAR NA FACTORY
  public static Endereco__c gerarEndereco(Account conta, String rua, Boolean maisAtual){
    Endereco__c endereco = new Endereco__c(
        Conta__c = conta.Id,
        Bairro__c = 'Jd. Abismo',
        CEP__c = '05689001',
        Cidade__c = 'São Paulo',
        Complemento__c = '',
        Estado__c = 'SP',
        Logradouro__c = rua,
        Numero__c = '20',
        TipoLogradouro__c = 'Rua',
        TipoEndereco__c = 'Comercial',
        MaisAtual__c = maisAtual
    );

    insert endereco;
    return endereco;
  }

  @isTest
  static void buscarEnderecoCEP()
  {
    EnderecoBO bo = EnderecoBO.getInstance();
    List<ServiceTO.ListResultadoRetornoBuscaEndereco> lstRetornoBuscaEnderecos = new List<ServiceTO.ListResultadoRetornoBuscaEndereco>();

    String responseJsonString = '';

    Test.setMock(HttpCalloutMock.class, new MockHttpResponse(responseJsonString, 200, 'OK'));
    Test.startTest();
    lstRetornoBuscaEnderecos = bo.buscarEndereco('','17800','001','','','','');
    Test.stopTest();

    System.assert(lstRetornoBuscaEnderecos.size() == 0);
  }

  //PLV-2727 - Inicio
  @isTest
  public static void montarIdExternoTest(){
    Endereco__c endereco = (Endereco__c) new EnderecoFactory().createRecord();
    String idExterno = EnderecoBO.getInstance().montarIdExterno(endereco);
  }
  //PLV-2727 - Fim
  
  // PLV-3995 - Inicio
  @isTest
  static void enderecoCobrancaTest(){
    Account acc = (Account) new AccountFactory.PessoaFisica().createRecord();
    Endereco__c endereco = new Endereco__c();
    endereco.Conta__c  = acc.Id;
    endereco.EnderecoCobranca__c = true;
    endereco.MaisAtual__c = false;
    endereco.CEP__c = '05689001';
    
    Test.startTest();
    insert endereco;
    endereco.Logradouro__c = 'TESTE';
    update endereco;
    Test.stopTest();
  }
  // PLV-3995 - FIM

}