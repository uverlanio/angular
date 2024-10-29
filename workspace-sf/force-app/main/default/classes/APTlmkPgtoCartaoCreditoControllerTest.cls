/*
@description Gera link de pagamento é uma funcionalidade que permite o envio de um link para que o cliente
@author Uverlanio Pereira - Globant
@date 05/09/2022
@Classe criada por conta da história TKCL-263
*/
@isTest
public class APTlmkPgtoCartaoCreditoControllerTest{ 
    
    @isTest static void getLinkPagtoCartaoCreditoTest(){

        String json = '{\"idExterno\":\"080622001\",\"expiraEm\":120,\"nome\":\"Cliente Fulando de Tal\",\"tipoTransacao\":\"CAPTURA\",\"tipoLink\": \"REGISTRO_CARTAO\",\"documento\":{\"tipo\":\"CPF\",\"numero\":\"13481182657\"},\"produto\":{\"codigo\":\"01\",\"descricao\":\"Porto Auto\"},\"metadados\":{\"tipo_documento_comercial\":\"01\",\"endosso\":\"0\",\"codigo_empresa\":\"001\",\"composicao_valor_parcela\":\"01\",\"codigo_ramo\":\"531\",\"parcela\":\"5\",\"contrato_comercial\":\"\",\"evento_emissao\":\"1\",\"flag_sinalizador_processo\":\"O\",\"flag_produto_seguro\":\"S\",\"codigo_agregador\":\"\",\"codigo_modalidade\":\"1\",\"auth_type\":\"SINGLE\"},\"valorTotal\":\"1000\",\"planoPagamento\":[{\"parcelas\":1,\"descricao\":\"1x sem juros (R$ 1.000,00)\",\"valorTotal\":1000},{\"parcelas\":2,\"descricao\":\"2x sem juros (R$ 500,00)\",\"valorTotal\":1000},{\"parcelas\":3,\"descricao\":\"3x com juros (R$ 375,00)\",\"valorTotal\":1125},{\"parcelas\":4,\"descricao\":\"4x com juros (R$ 300,00)\",\"valorTotal\":1200},{\"parcelas\":5,\"descricao\":\"5x com juros (R$ 250,00)\",\"valorTotal\":1250}]}';       
        
        RestResponse restResponse = new RestResponse();
        RestRequest restRequest = new RestRequest();
        restRequest.requestUri ='/services/apexrest/aptlmk/api';
        restRequest.httpMethod = 'POST';
        restRequest.requestBody = Blob.valueOf(json);
        RestContext.response = restResponse;
        RestContext.request = restRequest;
    
        Test.startTest();
        String retorno = APTlmkPgtoCartaoCreditoController.getLinkPagtoCartaoCredito();
        Test.stopTest();
        
        System.assertNotEquals('', retorno);
    }

    @isTest static void getTokenTest(){ 
        
        API_Link_de_Pagamento__mdt metadados = MetadataDAO.getInstance().apiLinkDePgto('API_Link_de_Pagamento'); //RVI-294
        APTlmkGeraLinkPgtoCartaoCreditoService service = new APTlmkGeraLinkPgtoCartaoCreditoService();

        Test.startTest();
        HttpResponse response = service.getToken(metadados);
        Test.stopTest();
        System.assertEquals(200, response.getStatusCode(), 'Token OK.');
    }
}