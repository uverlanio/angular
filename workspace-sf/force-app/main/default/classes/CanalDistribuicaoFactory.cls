/**
 * @author AVX - Renato Matheus Simião
 * @date 2019-09-12
 * @description Canal Distribuicao Factory Class
 */
@isTest
public class CanalDistribuicaoFactory extends SObjectFactory{

	private static CanalDistribuicao__c staticRecord;

    private static CanalDistribuicao__c getStaticRecord(){
       
        if(staticRecord == null){
			staticRecord = new CanalDistribuicao__c(
                Name = 'Canal Distribuição Teste 001',
                Status__c = 'Em ativação',
                Sigla__c = 'EXE'
            );
		}
		return staticRecord;
	}

    public CanalDistribuicaoFactory() {

		super(getStaticRecord());
	}
}