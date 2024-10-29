@isTest
public class APITokenizacaoServiceTest {//RVI-262  e RVI-223- INCIO
    
    @isTest
    static void getLinkPgtoCartaoCredito() {
        API_Link_de_Pagamento__mdt mtd = API_Link_de_Pagamento__mdt.getInstance('API_Link_de_Pagamento_Email');
        APITokenizacaoService service = new APITokenizacaoService();
        String jsonRequest = '{\"expiraEm\":3600,\"configuracaoPagamento\":{\"produto\":{\"codProduto\":\"148\",\"nomeVertical\":\"VidaePrevidência\",\"nomeProduto\":\"VidaIndividual\",\"icone\":\"vida_previdencia\"},\"cartaoCredito\":{\"planoPagamento\":{\"parcelas\":3,\"descricao\":\"3xdeR$15,00semjuros\",\"valorTotal\":45.01}},\"contratos\":[{\"descricao\":\"PlanoEssencialVD\",\"valorTotal\":20.01,\"idExterno\":\"1001CM000206\"},{\"descricao\":\"PlanoEssencialVP\",\"valorTotal\":25,\"idExterno\":\"1001CM000207\"}]}}';
        Test.startTest();
        HttpResponse responseToken = service.getToken(mtd);
        TokenApiLinkPgtoCartaoCredito tokenApiLinkPgtoCartaoCredito = new TokenApiLinkPgtoCartaoCredito(responseToken.getBody());
        HttpResponse responseEmail = service.getLinkPgtoCartaoCredito(jsonRequest, mtd, tokenApiLinkPgtoCartaoCredito);
        Test.stopTest();
    }
    
}//RVI-262  e RVI-223- FIM