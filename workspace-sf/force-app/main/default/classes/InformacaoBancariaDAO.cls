/**
 * InformacaoBancariaDAO
 * @author Fernando Barcellos @ 06/02/2018
 *
 **/
public class InformacaoBancariaDAO {
    private static final InformacaoBancariaDAO instancia = new InformacaoBancariaDAO();

    private InformacaoBancariaDAO() {   
    }

    public static InformacaoBancariaDAO getInstance(){
        return instancia;
    }

    public List<InformacaoBancaria__c> buscarInformacoesBancariasPorIdExterno(Set<String> idsExternos)
    {  
        return [
            SELECT
                Id,
                IdExterno__c,
                Conta__c,
                Banco__c,
                Agencia__c,
            	//PLV-3918-FIX6-INICIO
            	//PLV-3918-FIX7-INICIO
                NumeroConta__c,            	
                Digito__c
                //PLV-3918-FIX7 - FIM
            	//PLV-3918-FIX6 - FIM
            FROM
                InformacaoBancaria__c
            WHERE
                IdExterno__c IN : idsExternos
        ];
    }

    public List<InformacaoBancaria__c> buscarInformacoesBancariasPorId(Set<Id> idInformacoesBancarias) 
    {
        return [
            SELECT
                Id,
                IdExterno__c,
                Conta__c,
                Banco__c,
                Agencia__c,
                //PLV-3918-FIX6-INICIO
                //PLV-3918-FIX7-INICIO
                NumeroConta__c,        	
                Digito__c,
                //PLV-3918-FIX7 - FIM
            	//PLV-3918-FIX6 - FIM
                StatusIntegracao__c,
                ErroIntegracao__c
            FROM
                InformacaoBancaria__c
            WHERE
                id IN : idInformacoesBancarias
        ];
    }
    
    
    public List<BeneficiarioGarantia__c> buscarinfobancaria(String IdBeneficiario) 
    {
        return [
                SELECT Informacao_Bancaria__c 
                FROM BeneficiarioGarantia__c 
                WHERE Id =: IdBeneficiario
        ];
    }
    
    
    public List<InformacaoBancaria__c> buscarinfobancariasdosbeneficiarios(String Informacaobancaria) 
    {
        return [
            SELECT Id,
                    IdExterno__c,
                    Conta__c,
                    Conta__r.Cpf__c,
                    Conta__r.Cnpj__c,
                    Banco__c,
                    Agencia__c,
                    NumeroConta__c,
            		//PLV-3918-FIX6 - INICIO
                    //PLV-3918-FIX7-INICIO   	
                	Digito__c,
                	//PLV-3918-FIX7 - FIM
            		//PLV-3918-FIX6 - INICIO
                    StatusIntegracao__c,
                    ErroIntegracao__c 
            FROM InformacaoBancaria__c 
            WHERE
                Id  =:  Informacaobancaria
            //AND
                //StatusIntegracao__c = 'Não Validada' 
        ];
    }
}