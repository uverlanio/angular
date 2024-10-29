//ZSVEP-76-INICIO
@isTest
public class CoberturaWrapperTest {
    @isTest
    static void testParse() {
        // JSON de exemplo
        String jsonString = '[{"orcamento":"123","rotulo":"Cobertura 1","selecionado":true,"premioTotal":"1000","coberturas":[{"sigla":"COB1","moeda":"BRL","selecionado":true,"valor":"500","valorFormatado":"R$ 500"},{"sigla":"COB2","moeda":"BRL","selecionado":false,"valor":"300","valorFormatado":"R$ 300"}]},{"orcamento":"124","rotulo":"Cobertura 2","selecionado":false,"premioTotal":"2000","coberturas":[{"sigla":"COB3","moeda":"USD","selecionado":true,"valor":"700","valorFormatado":"$ 700"},{"sigla":"COB4","moeda":"USD","selecionado":false,"valor":"400","valorFormatado":"$ 400"}]}]';
        
        // Chamar o método parse
        List<CoberturaWrapper> result = CoberturaWrapper.parse(jsonString);
        
        // Verificações (Assertions)
        System.assertNotEquals(null, result, 'O resultado da deserialização não deve ser nulo.');
        System.assertEquals(2, result.size(), 'O resultado deve conter 2 elementos.');
        
        CoberturaWrapper primeiro = result[0];
        System.assertEquals('123', primeiro.orcamento, 'O orcamento do primeiro elemento deve ser 123.');
        System.assertEquals('Cobertura 1', primeiro.rotulo, 'O rotulo do primeiro elemento deve ser Cobertura 1.');
        System.assertEquals(true, primeiro.selecionado, 'O selecionado do primeiro elemento deve ser true.');
        System.assertEquals('1000', primeiro.premioTotal, 'O premioTotal do primeiro elemento deve ser 1000.');
        System.assertEquals(2, primeiro.coberturas.size(), 'O primeiro elemento deve ter 2 coberturas.');
        
        CoberturaWrapper.Coberturas primeiraCobertura = primeiro.coberturas[0];
        System.assertEquals('COB1', primeiraCobertura.sigla, 'A sigla da primeira cobertura do primeiro elemento deve ser COB1.');
        System.assertEquals('BRL', primeiraCobertura.moeda, 'A moeda da primeira cobertura do primeiro elemento deve ser BRL.');
        System.assertEquals(true, primeiraCobertura.selecionado, 'O selecionado da primeira cobertura do primeiro elemento deve ser true.');
        System.assertEquals('500', primeiraCobertura.valor, 'O valor da primeira cobertura do primeiro elemento deve ser 500.');
        System.assertEquals('R$ 500', primeiraCobertura.valorFormatado, 'O valorFormatado da primeira cobertura do primeiro elemento deve ser R$ 500.');
        
        // Verificações do segundo elemento
        CoberturaWrapper segundo = result[1];
        System.assertEquals('124', segundo.orcamento, 'O orcamento do segundo elemento deve ser 124.');
        System.assertEquals('Cobertura 2', segundo.rotulo, 'O rotulo do segundo elemento deve ser Cobertura 2.');
        System.assertEquals(false, segundo.selecionado, 'O selecionado do segundo elemento deve ser false.');
        System.assertEquals('2000', segundo.premioTotal, 'O premioTotal do segundo elemento deve ser 2000.');
        System.assertEquals(2, segundo.coberturas.size(), 'O segundo elemento deve ter 2 coberturas.');
        
        CoberturaWrapper.Coberturas segundaCobertura = segundo.coberturas[0];
        System.assertEquals('COB3', segundaCobertura.sigla, 'A sigla da primeira cobertura do segundo elemento deve ser COB3.');
        System.assertEquals('USD', segundaCobertura.moeda, 'A moeda da primeira cobertura do segundo elemento deve ser USD.');
        System.assertEquals(true, segundaCobertura.selecionado, 'O selecionado da primeira cobertura do segundo elemento deve ser true.');
        System.assertEquals('700', segundaCobertura.valor, 'O valor da primeira cobertura do segundo elemento deve ser 700.');
        System.assertEquals('$ 700', segundaCobertura.valorFormatado, 'O valorFormatado da primeira cobertura do segundo elemento deve ser $ 700.');
    }
}
//ZSVEP-76-FIM