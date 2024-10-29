public class FilialParceiroDAO {
    private static final FilialParceiroDAO instance = new FilialParceiroDAO();
    public static FilialParceiroDAO getInstance() { return instance; }
    private FilialParceiroDAO() {}

    public List<FilialParceiro__c> buscarFiliaisPorParceiro(Set<String> setParceiros) {
        return [
            SELECT               
                Id,
                CodigoFilialParceiro__c,
                Parceiro__c
            FROM
                FilialParceiro__c
            WHERE
                Parceiro__c  IN :setParceiros
            ];
    }
}