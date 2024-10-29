/**
 * Created by Alessandro Ponte on 28/12/2018.
 */

@IsTest
private class HerokuResponseTOTest {

  @IsTest
  static void testBehavior() {

    // Gera MetaTO
    HerokuResponseTO.MetaTO metaTO = new HerokuResponseTO.MetaTO();
    metaTO.mensagem = 'Teste';
    metaTO.dataExecucao = '2018-12-28';
    metaTO.statusHttp = 200;
    metaTO.servico = 'ServicoTeste';

    // Gera TituloDetalheTO
    HerokuResponseTO.TituloDetalheTO tituloDetalheTO = new HerokuResponseTO.TituloDetalheTO();
    tituloDetalheTO.lote = 12;
    tituloDetalheTO.nome = 'Teste';
    tituloDetalheTO.status = 'Pendente';

    // Gera o TituloTO
    HerokuResponseTO.TituloTO tituloTO = new HerokuResponseTO.TituloTO();
    tituloTO.meta = metaTO;
    tituloTO.data = tituloDetalheTO;

    // Gera o LoteTODetalhe
    HerokuResponseTO.LoteTODetalhe loteTODetalhe = new HerokuResponseTO.LoteTODetalhe();
    LoteTODetalhe.idlote = 12;
    LoteTODetalhe.produto = 'CCRTest';
    LoteTODetalhe.dataregistro = '2018-12-28';
    LoteTODetalhe.codigoparceiro = '000012';
    LoteTODetalhe.status = 'Pendente';
    LoteTODetalhe.quantidade = '12';

    // Gera o LoteTO
    HerokuResponseTO.LoteTO loteTO = new HerokuResponseTO.LoteTO();
    loteTO.meta = metaTO;
    loteTO.data = new List<HerokuResponseTO.LoteTODetalhe>{loteTODetalhe};

    // Gera o HerokuResponseErrorDetailTO
    HerokuResponseTO.HerokuResponseErrorDetailTO herokuResponseErrorDetailTO = new HerokuResponseTO.HerokuResponseErrorDetailTO();
    herokuResponseErrorDetailTO.statusCode = 500;
    herokuResponseErrorDetailTO.message = 'Teste';

    // Gera o HerokuResponseErrorTO
    HerokuResponseTO.HerokuResponseErrorTO herokuResponseErrorTO = new HerokuResponseTO.HerokuResponseErrorTO();
    herokuResponseErrorTO.error = herokuResponseErrorDetailTO;

    Test.startTest();

    // Testa o tituloTo
    System.assert(tituloTO.meta.statusHttp == 200);

    // Testa o LoteTO
    System.assert(loteTO.meta.statusHttp == 200);

    // Test o HerokuResponseErrorTO
    System.assert(herokuResponseErrorTO.error.statusCode == 500);

    Test.stopTest();


  }
}