@isTest
private class OrcamentoClassTest {

    @isTest
    public static void testOrcamentoClass() {
        /*//VIAG-253 INICIO
        OrcamentoClass.Cobertura cobertura1 = new OrcamentoClass.Cobertura();
        cobertura1.orcamento = 'orcamento1';
        cobertura1.rotulo = 'rotulo1';
        cobertura1.selecionado = true;
        cobertura1.sigla = 'sigla1';
        cobertura1.nomeCobertura = 'cobertura1';
        cobertura1.moeda = 'moeda1';
        cobertura1.valor = '100';
        cobertura1.valorFormatado = 'R$ 100,00';

        OrcamentoClass.Cobertura cobertura2 = new OrcamentoClass.Cobertura();
        cobertura2.orcamento = 'orcamento2';
        cobertura2.rotulo = 'rotulo2';
        cobertura2.selecionado = false;
        cobertura2.sigla = 'sigla2';
        cobertura2.nomeCobertura = 'cobertura2';
        cobertura2.moeda = 'moeda2';
        cobertura2.valor = '200';
        cobertura2.valorFormatado = 'R$ 200,00';

        List<OrcamentoClass.Cobertura> coberturaList = new List<OrcamentoClass.Cobertura>();
        coberturaList.add(cobertura1);
        coberturaList.add(cobertura2);

        OrcamentoClass orcamento = new OrcamentoClass();
        orcamento.CoberturaNome = 'Nome da Cobertura';
        orcamento.CoberturaList = coberturaList;
        */ //VIAG-253 FIM
        OrcamentoClass.CoberturaNomeClass coberturaNome = new OrcamentoClass.CoberturaNomeClass();
        coberturaNome.sigla = 'sigla1';
        coberturaNome.nome = 'nome1';
        
        System.assertEquals('sigla1', coberturaNome.sigla);
        System.assertEquals('nome1', coberturaNome.nome);
        /*//VIAG-253 INICIO 
        System.assertEquals('Nome da Cobertura', orcamento.CoberturaNome);
        System.assertEquals(2, orcamento.CoberturaList.size());

        System.assertEquals('orcamento1', cobertura1.orcamento);
        System.assertEquals('rotulo1', cobertura1.rotulo);
       
        System.assertEquals('sigla1', cobertura1.sigla);
        System.assertEquals('cobertura1', cobertura1.nomeCobertura);
        System.assertEquals('moeda1', cobertura1.moeda);
        System.assertEquals('100', cobertura1.valor);
        System.assertEquals('R$ 100,00', cobertura1.valorFormatado);

        System.assertEquals('orcamento2', cobertura2.orcamento);
        System.assertEquals('rotulo2', cobertura2.rotulo);
        System.assertEquals('sigla2', cobertura2.sigla);
        System.assertEquals('cobertura2', cobertura2.nomeCobertura);
        System.assertEquals('moeda2', cobertura2.moeda);
        System.assertEquals('200', cobertura2.valor);
        System.assertEquals('R$ 200,00', cobertura2.valorFormatado);
        */ //VIAG-253 FIM
    }
}