/**
 * @author AVX - Leonardo Camacho
 * @date 2019-02-27
 * @description: Segurado do Orçamento Factory Class
 * Criada para a história: PLV_2826 - Criar orçamento sem conta
 */

@isTest
public class seguradoOrcamentoFactory extends SObjectFactory{

	private static SeguradoOrcamento__c staticRecord;
    
    private static SeguradoOrcamento__c getRecordStatic(Account contaPessoal, GrupoOrcamento__c grupo){
        Date dataVigenciaInicial = Date.newInstance(2013, 03, 12);
        Date dataVigenciaFinal = Date.newInstance(2020, 03, 12);
        
		if(staticRecord == null){
			staticRecord = new SeguradoOrcamento__c(
                Conta__c = contaPessoal.Id,
                GrupoOrcamento__c = grupo.Id                
            );
		}
		return staticRecord;
	}
    
    public seguradoOrcamentoFactory() {

		this(
        	(Account) new AccountFactory.PessoaFisica().createRecord(),
            (GrupoOrcamento__c) new grupoOrcamentoFactory().createRecord()
        );
	}

	public seguradoOrcamentoFactory(Account contaPessoal, GrupoOrcamento__c grupo) {

		super(getRecordStatic(contaPessoal, grupo));
	}
}