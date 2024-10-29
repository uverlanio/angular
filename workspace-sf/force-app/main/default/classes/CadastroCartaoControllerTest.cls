/****************************
@description  Classe de teste para a classe CadastroCartaoController
@author Rogerio Menezes - Globant
@date 06/10/2023
@Classe criada por conta da história II-86        
****************************/

@isTest
public class CadastroCartaoControllerTest {

    @testSetup 
	static void setup(){

        Account contaTeste = TestDataFactory.gerarConta();
        contaTeste.CodigoEmpresa__c = '14';
        update contaTeste;

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
        produtoCom.Empresa__c = contaTeste.Id;
        update produtoCom;

        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        
        Opportunity orcamento = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        orcamento.Numero__c = '00006767';
        update orcamento;

        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);

      	Quote proposta = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, orcamento, modalidade);

        FormaPagamento__c pagamento = TestDataFactory.gerarFormaPagamento();
        ContratanteProposta__c contratantePropLiberada = TestDataFactory.gerarContratanteProposta(contaTeste, proposta, pagamento);     

        CriticaProposta__c criticaProposta = new CriticaProposta__c(
            Proposta__c = proposta.Id,        
            Status__c = 'Pendente',
            Tipo__c = 'Analise',
            MomentoAnalise__c = 'Palavra Final'    
        );
        insert criticaProposta;

    }

    @istest static void getLinkPortoPagTest(){
        String codRamo = '531';
        String descricao = 'Porto auto';
        String ofertaSelecionada = '00006767';
        String parcelas = '5';
        List<Quote> proposta = [SELECT Id FROM Quote LIMIT 1];
        String idProposta = proposta[0].Id;
        List<Opportunity> codEmpresa = [SELECT Id, Produto__r.Empresa__r.CodigoEmpresa__c FROM Opportunity WHERE Numero__c =: ofertaSelecionada];
		String codEmp = codEmpresa[0].Produto__r.Empresa__r.CodigoEmpresa__c;

        String payloadReturn = '{"idExterno":"080622001","expiraEm":"120","nome":"Cliente Fulando de Tal","tipoTransacao":"CAPTURA","tipoLink":"REGISTRO_CARTAO","documento":{"tipo":"CPF","numero":"13481182657"},"produto":{"codigo":"32","descricao":"Porto Auto"},"metadados":{"tipo_documento_comercial":"01","endosso":"","codigo_empresa":"1","composicao_valor_parcela":"01","codigo_ramo":"'+ codRamo +'","parcela":"5","contrato_comercial":"","evento_emissao":"1","flag_sinalizador_processo":"O","flag_produto_seguro":"S","codigo_agregador":"","codigo_modalidade":"24","auth_type":"SINGLE"},"valorTotal":"1000","planoPagamento":[{"parcelas":1,"descricao":"1xsemjuros(R$1.000,00)","valorTotal":1000},{"parcelas":2,"descricao":"2xsemjuros(R$500,00)","valorTotal":1000},{"parcelas":3,"descricao":"3xcomjuros(R$375,00)","valorTotal":1125},{"parcelas":4,"descricao":"4xcomjuros(R$300,00)","valorTotal":1200},{"parcelas":5,"descricao":"5xcomjuros(R$250,00)","valorTotal":1250}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payloadReturn, 200, 'OK'));
        Test.startTest();
            CadastroCartaoController.getLinkPortoPag(codRamo, descricao, ofertaSelecionada, parcelas, idProposta);
        Test.stopTest();
    }

    @istest static void rgstNewCardTest(){
        List<Quote> proposta = [SELECT Id FROM Quote LIMIT 1];
        String idProposta = proposta[0].Id;

        String ticket = 'adb4df68-f1af-4036-b724-7dd3bd8be6b9'; 
        String bandeira = 'Mastercard';
        Test.startTest();
            CadastroCartaoController.rgstNewCard(ticket, bandeira, idProposta);
        Test.stopTest();

    }

    @istest static void getDadosPropostaTest(){
        List<Quote> proposta = [SELECT Id FROM Quote LIMIT 1];
        String idProposta = proposta[0].Id;
        Test.startTest();
            CadastroCartaoController.getDadosProposta(idProposta);
        Test.stopTest();
    }
}