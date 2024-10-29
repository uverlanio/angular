//II-166 - INICIO
@isTest
private class AltFormPgtoTOTest {

    @isTest
    static void altFormPgtoTOTest() {
        
        AltFormPgtoTO to = new AltFormPgtoTO();
        AltFormPgtoTO.FormaPagamentoTO fpTO = new AltFormPgtoTO.FormaPagamentoTO();
        fpTO.proposta = '18-12345';
        fpTO.formaPagamentoAtual = 'B';
        fpTO.mapParcelamento = new Map<FormaPagamento__c, String>();
        fpTO.valorPremioAtual = 1;
        fpTO.novaFormaPagamento = 'N';
        fpTO.codFormPag = '41'; //II-174 FIX01 INICIO/FIM

        //II-172 - INICIO
        AltFormPgtoTO.EnderecoTO endTO = new AltFormPgtoTO.EnderecoTO();
        endTO.bairro = 'b';
        endTO.cepPrefixo = 'p';
        endTO.cepSufixo = 's';
        endTO.cidade = 'c';
        endTO.estado = 'e';
        endTO.logradouro = 'l';
        endTO.uf = 'u';
        //II-172 - FIM

    }
}
//II-166 - FIM