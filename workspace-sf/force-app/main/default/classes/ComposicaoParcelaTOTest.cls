//II-154 INICIO
@isTest
public class ComposicaoParcelaTOTest {

    @isTest
    static void testComposicaoParcelaTO() {
        ComposicaoParcelaTO parcelaTO = new ComposicaoParcelaTO();
        parcelaTO.id = 1;
        parcelaTO.idexterno = 'ABC123';
        parcelaTO.codigoparceiro = 'Teste';
        parcelaTO.idfatura = 2;
        parcelaTO.origemproposta = 18;
        parcelaTO.idproposta = 'Teste123';
        parcelaTO.numeropropostaporto = '123123123';
        parcelaTO.produto = 'Vida';
        parcelaTO.apolice = 'contrato';
        parcelaTO.empresa = '14';
        parcelaTO.sucursal = 'teste';
        parcelaTO.ramo = 'Individual';
        parcelaTO.ramolider = 'Individual';
        parcelaTO.modalidade = 'Individual';
        parcelaTO.endosso = '1234567';
        parcelaTO.responsavelfinanceiro = 'Francis Liu';
        parcelaTO.tiporesponsavelpagamento = 'PF';
        parcelaTO.seguradosalesforce = 'Francis Liu';
        parcelaTO.vidasalesforce = 'Individual';
        parcelaTO.datapagamento = '23/01/2024';
        parcelaTO.datavencimento = '23/01/2025';
        parcelaTO.dataemissao = '10/01/2024';
        parcelaTO.datacancelamento = '15/01/2024';
        parcelaTO.numeroparcela = 6;
        parcelaTO.status = 'Paga';
        parcelaTO.titulo = 'Cliente';
        parcelaTO.valoriof = 10;
        parcelaTO.valorliquido = 10;
        parcelaTO.valorparcela = 10;
        parcelaTO.valorpago = 10;
        parcelaTO.antecipacaocomissao = 'Não';
        parcelaTO.statusIntegracao = 'Ok';
    }
}
//II-154 FIM