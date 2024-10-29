/**
 * Created by Alessndro Ponte on 28/12/2018.
 */

@IsTest
private class QuestionarioProdutoTest {

  @testSetup
  private static void setup() {
    TestDataFactory.gerarDadosSetup();
    Map<String,List<SObject>> mapListSObject = TestDataFactory.gerarProdutoComercialAtivo(false);
  }


  @IsTest
  private static void validarQuestionario(){

    RetornoAcaoBotaoTO resposta;

    TEst.startTest();

    //Criação dos dados
    Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
    TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao();
    RemuneracaoProduto__c remuneracao = TestDataFactory.gerarRemuneracaoProduto(produtoTec, tipoRemuneracao);
    ParametroVigencia__c paramVigencia = TestDataFactory.gerarParametroVigenciaProdutoTecnico(produtoTec);
    FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento();
    PremioMinimoProduto__c premioMinimo = TestDataFactory.gerarPremioMinimoProdutoTecnico(produtoTec, formaPagamento);
    Account contaTeste = TestDataFactory.gerarConta('412');
    RamoSeguro__c ramoVida = TestDataFactory.gerarRamoSeguro(contaTeste,'412');
    Modalidade__c modalidade1 = TestDataFactory.gerarModalidade(ramoVida);
    Garantia__c garantia = TestDataFactory.gerarGarantia('Morte Acidental','MAP');
    RamoGarantia__c ramoGarantia = TestDataFactory.gerarRamoGarantia(garantia, ramoVida);
    GarantiaProduto__c garantiaProduto = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTec, garantia, ramoVida);
    limiteGarantiaProduto__c limGarantiaProdTec = (limiteGarantiaProduto__c) new LimiteGarantiaProdutoFactory(garantiaProduto).createRecord(); //PLV - 3046
    Territorio__c territorioProduto = TestDataFactory.gerarTerritorioProdutoTecnico(produtoTec);
    Territorio__c territorioGarantia = TestDataFactory.gerarTerritorioGarantiaTecnica(garantiaProduto);
    DependenteGarantia__c dependenteGarantia = TestDataFactory.gerarDependenteGarantiaTecnica(garantiaProduto);

    //Ativa produto
    //ContentDocumentLink arquivo = TestDataFactory.gerarDocumentoProduto(produtoTec); //correcao ambientes

    produtoTec.Status__c = 'Em ativação';
    produtoTec.NumeroSusep__c = '1234';
    update produtoTec;

    //Ativa produto
    resposta = (RetornoAcaoBotaoTO)JSON.deserialize(ProductAcaoBotaoController.ativarProduto(produtoTec.Id), RetornoAcaoBotaoTO.class);

    //Teste clonagem registros
    resposta = (RetornoAcaoBotaoTO)JSON.deserialize(ProductAcaoBotaoController.gerarNovoProdutoComercial(produtoTec.Id), RetornoAcaoBotaoTO.class);
//		System.assertEquals(resposta.tipo, RetornoAcaoBotaoTO.SUCCESS);

    //Ativa produto clonado. Necessário passar uma vigencia valida
    //PLV-3493 - INICIO - Inclusao do campo para teste
    List<Product2> listProduct = [Select Id, VigenciaInicial__c, VigenciaFinal__c, Versao__c, ProductCode, Status__c From Product2 Where Id =: resposta.linkRedirecionar];
    //PLV-3493 - FIM
    Product2 produtoClone = listProduct[0];
    //ContentDocumentLink arquivo2 = TestDataFactory.gerarDocumentoProduto(produtoClone); //correcao ambientes

    produtoClone.VigenciaInicial__c = System.today().addDays(2);
    produtoClone.Status__c = 'Em ativação';
    produtoClone.ProductCode = '209685948304'; //PLV-3493 - INICIO/FIM - Atribuicao do valor
    produtoClone.NumeroSusep__c = '43434';
    update produtoClone;

    GarantiaProduto__c garantiaProdutoCom = TestDataFactory.gerarGarantiaProdutoComercial(produtoClone, garantia, garantiaProduto, ramoVida);
    ParametroVigencia__c paramVigenciaCom = TestDataFactory.gerarParametroVigenciaProdutoComercial(produtoClone);
    Questionario__c questionario = TestDataFactory.gerarQuestionario();
    QuestionarioProduto__c questionarioProduto = TestDataFactory.gerarQuestionarioProduto(questionario, produtoClone, garantiaProdutoCom);

    resposta = (RetornoAcaoBotaoTO)JSON.deserialize(ProductAcaoBotaoController.ativarProduto(produtoClone.Id), RetornoAcaoBotaoTO.class);

    Test.stopTest();



  }
}