/*
@author Kevin Vogado - Globant
@date 27/06/2024
@Classe criada para cobrir a parametrosLinkPgtoCartaoCredito (FNPVVEP-59)
*/
@isTest
private class TestParametrosLinkPgtoCartaoCredito {

    @isTest
    static void testParseValidJson() {
        String json = '{' +
                      '  "expiraEm": 30,' +
                      '  "configuracaoPagamento": {' +
                      '    "produto": {' +
                      '      "codProduto": "12345",' +
                      '      "nomeVertical": "Vertical Teste",' +
                      '      "nomeProduto": "Produto Teste",' +
                      '      "icone": "icone-teste"' +
                      '    },' +
                      '    "cartaoCredito": {},' +
                      '    "contratos": [' +
                      '      {' +
                      '        "descricao": "Contrato 1",' +
                      '        "valorTotal": 100.0,' +
                      '        "idExterno": "id-1"' +
                      '      },' +
                      '      {' +
                      '        "descricao": "Contrato 2",' +
                      '        "valorTotal": 200.0,' +
                      '        "idExterno": "id-2"' +
                      '      }' +
                      '    ]' +
                      '  }' +
                      '}';
        
        Test.startTest();
        parametrosLinkPgtoCartaoCredito paramsParsed = parametrosLinkPgtoCartaoCredito.parse(json);
        Test.stopTest();
        
        System.assertEquals(30, paramsParsed.expiraEm);
        System.assertEquals('12345', paramsParsed.configuracaoPagamento.produto.codProduto);
        System.assertEquals('Contrato 2', paramsParsed.configuracaoPagamento.contratos[1].descricao);
    }
}