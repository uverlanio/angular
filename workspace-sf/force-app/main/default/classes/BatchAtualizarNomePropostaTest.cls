/****************************************************************************************************************************
 * Classe de teste para a classe de negocio implementada para o processo automático correção de número de apólice e nome    *
 * de contratos que já tiveram parcelas geradas                                                                             *
 *                                                                                                                          *
 * @author : Globant                                                                                                        *
 * @date 26/01/2024                                                                                                         *
 * Classe implementada tendo como origem a história PLV-5855                                                                *
 * **************************************************************************************************************************/

@isTest
public with sharing class BatchAtualizarNomePropostaTest {
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
        propostaTeste.Status = 'Contratada';
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

        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaTeste, pagamento).createRecord();
        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaTeste, produtoCom, parceiro).createRecord();
        contrato.Oportunidade__c = orcamentoContratado.Id;
        contrato.NumeroApolice__c = '';
        contrato.Empresa__c = '22';
        contrato.Sucursal__c = '999';
        contrato.CodigoRamo__c = '2';
        contrato.Endosso__c = '0';
        contrato.Proposta__c = propostaTeste.Id;
        contrato.Status = 'Em elaboração';
        contrato.Name = 'Contrato em elaboração Test';
        contrato.NumeroApolice__c = '';
        contrato.Tipo__c = 'Novo';
        contrato.NumeroProposta__c = '00006767';
        contrato.Origem__c = '18';
        update contrato;
    }

    @istest
    public static void testBatchSuccess() {
        Test.startTest();
        System.debug('entrou aqui');
        list<Contract> contratosDeTeste = [SELECT id, Status, Tipo__c FROM contract];
        System.debug('contratosDeTeste '+ contratosDeTeste);
        BatchAtualizarNomeProposta batchPropostas = new BatchAtualizarNomeProposta();

        public_parcelacontrato__x mockedRequest = new public_parcelacontrato__x(
                Id__c = 0000, 
                Empresa__c = '22',
                Ramo__c = '2', 
                Sucursal__c= '999', 
                Apolice__c= '000000014889', 
                Endosso__c= '0', 
                idProposta__c= '18-00006767'
        );

        batchPropostas.mockedRequests.add(mockedRequest);

        Database.executeBatch(batchPropostas);
        Test.stopTest();
    }

    @istest
    public static void testBatchFailure() {
        Test.startTest();
        System.debug('entrou aqui');
        list<Contract> contratosDeTeste = [SELECT id, Status, Tipo__c FROM contract];
        System.debug('contratosDeTeste '+ contratosDeTeste);
        BatchAtualizarNomeProposta batchPropostas = new BatchAtualizarNomeProposta();

        public_parcelacontrato__x mockedRequest = new public_parcelacontrato__x();

        batchPropostas.mockedRequests.add(mockedRequest);

        Database.executeBatch(batchPropostas);
        Test.stopTest();
    }

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