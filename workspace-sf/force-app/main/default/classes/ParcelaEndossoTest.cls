//plv 4014 inicio

@IsTest
public class ParcelaEndossoTest {
    
    static testMethod void testParse() {
        String json = '{\"meta\":{\"statusHttp\":200,\"servico\":\"Buscarparcelasdocontratoporseguradoouvida\",\"mensagem\":\"OK\",\"dataExecucao\":\"2020-07-20T17:03:08.773Z\"},\"data\":[{\"vidasalesforce\":null,\"valorparcela\":\"-3.98\",\"valorliquido\":\"-3.99\",\"valoriof\":\"0.01\",\"titulo\":\"\",\"sucursal\":\"1\",\"status\":\"ARESTITUIR\",\"seguradosalesforce\":\"a0fL0000007WpViIAK\",\"responsavelfinanceiro\":\"001L000001TgdMuIAJ\",\"ramo\":\"1369\",\"origemproposta\":18,\"numeroproposta\":null,\"numeroparcela\":1,\"idparceiro\":null,\"idfatura\":null,\"idexterno\":\"800L0000002Oo1AIAS_a0fL0000007WpViIAK\",\"id\":110296,\"endosso\":\"1\",\"empresa\":\"1\",\"datavencimento\":\"2020-07-23T00:00:00.000Z\",\"dataPagamentoParceiro\":null,\"contrato\":null,\"apolice\":\"000005936\"}]}';
        ParcelaEndosso obj = ParcelaEndosso.parse(json);
        System.assert(obj != null);
    }

}
//plv 4014 fim