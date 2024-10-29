// POR062-1 - INICIO
@isTest
private class MovimentoSinistroTOTest {
    @isTest
    static void recuperarConjuntoMovimentoValorTest() {
        Set<Integer> conjuntoMov = MovimentoSinistroTO.getInstance().recuperarConjuntoMovimentoValor(
            MovimentoSinistroTO.CONJ_MOV_COMPLEMENTO
        );
        for(MovimentoSinistroTO.Movimento movimentoTO : MovimentoSinistroTO.CONJ_MOV_COMPLEMENTO)
        {
            System.assert(
                conjuntoMov.contains(movimentoTO.valor),
                String.format(
                    'recuperarConjuntoMovimentoValorTest: Movimento(Nome: {0} | Valor: {1}) não encontrado no conjunto recuperado.',
                    new String[] { movimentoTO.nome, movimentoTO.descricaoValor }
                )
            );
        }
    }
}
// POR062-1 - FIM