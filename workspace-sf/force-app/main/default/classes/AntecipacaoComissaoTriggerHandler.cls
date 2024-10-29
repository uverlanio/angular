//PLV-4305 Complemento - INICIO - Criacao de classe Handler para auxilio da Trigger
public class AntecipacaoComissaoTriggerHandler extends TriggerHandler {
   
    public override void afterInsert(){
        AntecipacaoComissaoBO.validaAntecipacoes(Trigger.new);
    }

    public override void afterUpdate(){
        AntecipacaoComissaoBO.validaAntecipacoes(Trigger.new);
    }
}
//PLV-4305 Complemento - FIM