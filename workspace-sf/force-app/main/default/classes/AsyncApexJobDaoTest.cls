/*********************************************************************************************************************************************************************
@description  Classe de teste de dao responsável pela busca de registros AsyncApexJob.
@author Fernando Rodrigues Ribeiro Martins - Globant
@date 23/01/2023
**********************************************************************************************************************************************************************/
//LECVP-72 - Inicio
@isTest
public class AsyncApexJobDaoTest {
    @isTest
    static void buscarClassesTest()
    {
        Test.startTest();
        List<AsyncApexJob> trabalhos = AsyncApexJobDao.getInstancia().buscarClasses(new Set<String>());
        Test.stopTest();
        System.assert(trabalhos != null);
    }
}
//LECVP-72 - Fim