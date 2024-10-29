/**
 * Classe abstrata para guiar a criação de classes para os objetos de expurgo
 */
public with sharing abstract class ExpurgoAbstract {
    /**
     * Buscar dados
     */
    public abstract List<Object> getDadosExpurgo(Integer qt);
    /**
     * Excluir dados
     */
    public abstract void deleteDadosExpurgo(List<Object> expList);
}