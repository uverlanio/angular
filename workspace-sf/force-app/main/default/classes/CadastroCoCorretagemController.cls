/* ------------------------------------------------------------
Author: Alison Sousa
UserStory: ANNI-16
Description: Controller para cadastro de co-corretagem
Historic<Date> <Author ́s name> <Shortly description of update> 
2024-03-05,Alison Sousa,Creation 
------------------------------------------------------------*/
public class CadastroCoCorretagemController {
    
    public CoCorretagem__c corretagem { get; set; }
    public Boolean susepDeCoCorretagemLider { get; set; }
    
    
    
    public CadastroCoCorretagemController(ApexPages.StandardController controller) {
        String id = ApexPages.CurrentPage().getParameters().get('ID');
        System.debug(id);
        if(id != null) this.corretagem = [SELECT SusepTransmissao__c, SusepDeCoCorretagem__c, SusepTransmissaoLider__c, SusepDeCoCorretagemLider__c, PercentualTransmissao__c, PercentualCoCorretagem__c FROM CoCorretagem__c WHERE Id =: id];
        if(this.corretagem != null) this.susepDeCoCorretagemLider = this.corretagem.SusepDeCoCorretagemLider__c;
        else this.susepDeCoCorretagemLider = false;
    }
    
    @RemoteAction
    public static String validarSusep(String susep) {
        List<DadosCorretor__c> dados = [SELECT Id, Name from DadosCorretor__c where Name like : susep];
        return validarSusep(susep, dados);
    }

    @RemoteAction
    public static String getSusep(String susep) {
        List<CoCorretagem__c> corretagem = [SELECT SusepTransmissao__c, SusepDeCoCorretagem__c, SusepTransmissaoLider__c, SusepDeCoCorretagemLider__c, PercentualTransmissao__c, PercentualCoCorretagem__c FROM CoCorretagem__c WHERE SusepTransmissao__c =: susep];
        return getSusep(susep, corretagem);
    }

    
    public static String getSusep(String susep, List<CoCorretagem__c> corretagem) {
        return corretagem.isEmpty() ? validarSusep(susep) : 'Update Warning' ;
    }

    @testVisible
    private static String validarSusep(String susep, List<DadosCorretor__c> dados) {
        return dados.isEmpty() ? 'Invalid Error' : 'Valid value';
        // if(dados.size() > 0){
        //     return dados[0].Name;
        // }
        // return 'Invalid Error';
    }
    
    @RemoteAction
    public static String salvar(String susepTransmissao, String coCorretagem, Boolean transmissaoLider, Boolean corretagemLider , Decimal percentualTransmissao, Decimal percentualCoCorretagem ) {
        try {
              CoCorretagem__c corretagem = new CoCorretagem__c();
              corretagem.Name = susepTransmissao + '-' + coCorretagem;
              corretagem.SusepTransmissao__c = susepTransmissao;
              corretagem.SusepDeCoCorretagem__c = coCorretagem;
              corretagem.SusepTransmissaoLider__c = transmissaoLider;
              corretagem.SusepDeCoCorretagemLider__c = corretagemLider;
              corretagem.PercentualTransmissao__c = percentualTransmissao;
              corretagem.PercentualCoCorretagem__c = percentualCoCorretagem;
            
               Database.upsert(corretagem, CoCorretagem__c.SusepTransmissao__c);
            
            return 'Ok';
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Erro ao salvar: ' + e.getMessage()));
            return null; 
        }
    }

}