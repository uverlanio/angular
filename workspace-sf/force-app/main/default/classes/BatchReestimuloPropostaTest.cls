/****************************************************************************************************************************
 * Classe de testes para a classe de negocio implementada para o processo automático de alteração de Status de Propostas    *
 * que já foram liberadas                                                                                                   *
 * @author : Globant                                                                                                        *
 * @date 09/11/2023                                                                                                         *
 * Classe implementada tendo como origem a história PLV-5856                                                                *
 * **************************************************************************************************************************/
@isTest
public class BatchReestimuloPropostaTest {
    @testSetup
    public static void gerarDadosTeste(){
        
        Account contaTeste = TestDataFactory.gerarConta();
        gerarEndereco(contaTeste.Id);
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);
        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);
        Garantia__c garantia1 = TestDataFactory.gerarGarantia();        
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
	      ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        produtoTec.Status__c = 'Ativo';
        produtoTec.Segmento__c = 'Individual';
        update produtoTec;
        
        Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        produtoCom.Status__c ='ativo';
        produtoCom.Segmento__c = 'Individual';
        update produtoCom;

        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        
        Opportunity orcamentoContratado = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        orcamentoContratado.Type = 'Novo';        
        update orcamentoContratado;

        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);

      	Quote propostaTeste= TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, orcamentoContratado, modalidade);
        propostaTeste.Status = 'Em análise';
        propostaTeste.Tipo__c = 'Novo';
        propostaTeste.VigenciaInicial__c = System.today().addDays(10);
        propostaTeste.PaisesDestino__c = 'Brasil';
        propostaTeste.FaseStatus__c = 'Palavra final';
        update propostaTeste;

        FormaPagamento__c pagamento = TestDataFactory.gerarFormaPagamento();
        ContratanteProposta__c contratantePropLiberada = TestDataFactory.gerarContratanteProposta(contaTeste, propostaTeste, pagamento);

        CriticaProposta__c criticaProposta = new CriticaProposta__c(
            Proposta__c = propostaTeste.Id,        
            Status__c = 'Liberado',
            Tipo__c = 'Analise',
            MomentoAnalise__c = 'Palavra Final'    
        );
        insert criticaProposta;
    }

    @istest
    public static void testBatch() {
        Test.startTest();
        BatchReestimuloProposta batchPropostas = new BatchReestimuloProposta();
        Database.executeBatch(batchPropostas);
        Test.stopTest();
    }

  /*  @istest
    public static void testSchedule() {
        Test.startTest();
        for(AsyncApexJob aJob : [SELECT id ,Status FROM AsyncApexJob]){
            System.AbortJob(aJob.Id);
        }
        
        BatchReestimuloProposta batchPropostas = new BatchReestimuloProposta();
        batchPropostas.scheduleBatch();
        Test.stopTest();
    }*/

    public static void gerarEndereco(Id accountId){
        Endereco__c endereco = new Endereco__c(
          Bairro__c = 'Bairro XYZ',
          CEP__c = '05572070',
          Cidade__c = 'São Paulo',
          Complemento__c = null,
          CurrencyIsoCode = 'BRL',
          EnderecoCobranca__c = false,
          Estado__c = 'AP',
          IdExterno__c = null,
          Logradouro__c = 'Rua XYZ',
          MaisAtual__c = false,
          Numero__c = '13',
          Pais__c = 'Brasil',
          TipoEndereco__c = 'Residencial',
          TipoLogradouro__c = null,
          Conta__c = accountId
        );
  
        insert endereco;
    }
}