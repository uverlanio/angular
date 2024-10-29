//PLV-4305 Complemento - INICIO - Criação de classe para as regras de negocio
public class AntecipacaoComissaoBO {
    public static void validaAntecipacoes(List<AntecipacaoComissao__c> lstAnt){
        Set<Id> setRemuneracoes = new Set<Id>();

        for(AntecipacaoComissao__c antCom : lstAnt){
            if(antCom.RemuneracaoProduto__c != null) setRemuneracoes.add(antCom.RemuneracaoProduto__c);
        }

        if(setRemuneracoes.isEmpty()) return;

        Map<Id, AntecipacaoComissao__c> mapAntCom = new Map<Id, AntecipacaoComissao__c>([SELECT Id, RemuneracaoProduto__c, TipoEvento__c FROM AntecipacaoComissao__c WHERE RemuneracaoProduto__c IN :setRemuneracoes]);

        if(mapAntCom.isEmpty()) return;

        for(AntecipacaoComissao__c vAnt : lstAnt){
            if(mapAntCom.containsKey(vAnt.Id)) mapAntCom.remove(vAnt.Id);
        }

        if(mapAntCom.isEmpty()) return;
        //PLV-4305 FIX - INICIO - Ajuste na logica
        Map<Id,Map<String,AntecipacaoComissao__c>> mapIdRemAntCom = new Map<Id,Map<String,AntecipacaoComissao__c>>();
        for(AntecipacaoComissao__c antecipMap : mapAntCom.values()){

            Map<String,AntecipacaoComissao__c> mapTipoEvento;

            if(mapIdRemAntCom.containsKey(antecipMap.RemuneracaoProduto__c)) mapTipoEvento = mapIdRemAntCom.get(antecipMap.RemuneracaoProduto__c);
            else mapTipoEvento = new Map<String,AntecipacaoComissao__c>();

            mapTipoEvento.put(antecipMap.TipoEvento__c, antecipMap);
            mapIdRemAntCom.put(antecipMap.RemuneracaoProduto__c, mapTipoEvento);
        }

        for(AntecipacaoComissao__c antecipCom : lstAnt){
            
            if(!mapIdRemAntCom.containsKey(antecipCom.RemuneracaoProduto__c)) continue;
            
            Map<String,AntecipacaoComissao__c> mapTipo = mapIdRemAntCom.get(antecipCom.RemuneracaoProduto__c);
            
            if(!mapTipo.containsKey(antecipCom.TipoEvento__c)) continue;

            AntecipacaoComissao__c vAnt = mapTipo.get(antecipCom.TipoEvento__c);

            //if(antecipCom.RemuneracaoProduto__c == vAnt.RemuneracaoProduto__c && antecipCom.TipoEvento__c == vAnt.TipoEvento__c) antecipCom.addError('Antecipação já cadastrada para a Remunaração do Produto com o mesmo tipo de evento'); //ANNVI-41 FIX-01 INICIO/FIM
        }
        //PLV-4305 FIX - FIM
    }
}
//PLV-4305 Complemento - FIM