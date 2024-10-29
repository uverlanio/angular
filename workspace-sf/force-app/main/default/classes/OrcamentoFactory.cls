/**
 * @author AVX - Leonardo Camacho
 * @date 2019-08-26
 * @description: Orçamento Factory Class
 */

@isTest
public class OrcamentoFactory{
	    
    private static Map<String,Opportunity> mStaticRecord = new Map<String,Opportunity>();
       
    public static Opportunity criarRegOrcamentoVidaGrupo(Product2 produtoComercial, Account contaPF){
        
        if(!mStaticRecord.containsKey('VidaGrupo')){
         Recordtype REC_ID_TipoOrcGrupo = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaGrupo');
        	 // OPORTUNIDADE DO TIPO Vida em GRUPO
       		 mStaticRecord.put('VidaGrupo', new Opportunity(
                StageName = 'Em criação',
                CurrencyIsoCode = 'BRL',
                Name = 'ARQ-00006666',
                CloseDate = System.today().addDays(20),
                VigenciaInicial__c = System.today(),
                VigenciaFinal__c = System.today().addDays(1),
                Produto__c = produtoComercial.Id,
                Probability = 10.0,
                RecordTypeId = REC_ID_TipoOrcGrupo.Id,
                AccountId = contaPF.Id,
                Numero__c = '00005555')             
        	 );

            insert mStaticRecord.get('VidaGrupo');
        }
            
        return mStaticRecord.get('VidaGrupo');
    }     
    
    //PLV_2673 - INICIO - Ação em caso de ultrapassar validade de orçamento
    public class VidaGrupo extends SObjectFactory{

		public VidaGrupo(){

            this(
                 (Product2) new ProdutoFactory.ProdutoComercial().createRecord(),
                 (Account) new AccountFactory.PessoaFisica().createRecord()
                );
        }
    
      	public VidaGrupo(Product2 produtoComercial, Account contaPF){
        	super(criarRegOrcamentoVidaGrupo(produtoComercial, contaPF));
		}
    //PLV_2673 - FIM - Ação em caso de ultrapassar validade de orçamento     
    }
    
    public static Opportunity criarRegOrcamentoVidaIndividual(Product2 produtoComercial, Account contaPF){
        
        if(!mStaticRecord.containsKey('VidaIndividual')){
        	Recordtype REC_ID_TipoOrcGrupo = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaIndividual');
                          
        	 // OPORTUNIDADE DO TIPO Vida Individual
        	 mStaticRecord.put('VidaIndividual', new Opportunity(
                StageName = 'Em criação',
                CurrencyIsoCode = 'BRL',
                Name = 'ARQ-00006666',
                CloseDate = System.today().addDays(20),
                VigenciaInicial__c = System.today(),
                VigenciaFinal__c = System.today().addDays(1),
                Produto__c = produtoComercial.Id,
                Probability = 10.0,
                RecordTypeId = REC_ID_TipoOrcGrupo.Id,
                AccountId = contaPF.Id,
                Numero__c = '00005555')              
        	 ); 
            
            insert mStaticRecord.get('VidaIndividual');
        }
            
        return mStaticRecord.get('VidaIndividual');
       
    }
        
       //PLV_2673 - INICIO - Ação em caso de ultrapassar validade de orçamento
       public class VidaIndividual extends SObjectFactory {

        public VidaIndividual(){
         
            this(
                	(Product2) new ProdutoFactory.ProdutoComercial().createRecord(),
                	(Account) new AccountFactory.PessoaFisica().createRecord()
            	);
            
        }    
           
		public VidaIndividual(Product2 produtoComercial, Account contaPF){

			super(criarRegOrcamentoVidaIndividual(produtoComercial, contaPF));
		}           
	}
    //PLV_2673 - INICIO - Ação em caso de ultrapassar validade de orçamento
}