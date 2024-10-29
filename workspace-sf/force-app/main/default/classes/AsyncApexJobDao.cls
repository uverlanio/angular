/*********************************************************************************************************************************************************************
@description  Classe da responsável por busca de registros AsyncApexJob.
@author Fernando Rodrigues Ribeiro Martins - Globant
@date 23/01/2023
**********************************************************************************************************************************************************************/
// LECVP-72 - Inicio
public class AsyncApexJobDao {
    private static final AsyncApexJobDao instancia = new AsyncApexJobDao();
    @TestVisible
    private static final String[] statusFila = new String[] {
        'Processing','Preparing','Queued','Holding'
    };
    private AsyncApexJobDao(){}
    public static AsyncApexJobDao getInstancia()
    {
        return instancia;
    }
    public List<AsyncApexJob> buscarClasses(Set<String> classesApex)
    {
        List<AsyncApexJob> trabalhos = [
            SELECT Id
            FROM AsyncApexJob
            WHERE
                JobType='BatchApex' AND Status IN :statusFila AND
                ApexClass.NamespacePrefix = '' AND ApexClass.Name IN :classesApex
        ];
        return trabalhos;
    }
}
// LECVP-72 - Fim