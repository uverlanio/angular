public class OfertaGarantiaProdutoHandler extends TriggerHandler  {

    private List<OfertaGarantiaProduto__c> listOGPNew {get;set;}
    private List<OfertaGarantiaProduto__c> listOGPOld {get;set;}
    private Map<Id,OfertaGarantiaProduto__c> mapOGPNew {get;set;}
    private Map<Id,OfertaGarantiaProduto__c> mapOGPOld {get;set;}

    public OfertaGarantiaProdutoHandler() {

        this.listOGPNew = (List<OfertaGarantiaProduto__c>) Trigger.new;
        this.listOGPOld = (List<OfertaGarantiaProduto__c>) Trigger.old;
        this.mapOGPNew = (Map<Id,OfertaGarantiaProduto__c>) Trigger.newMap;
        this.mapOGPOld = (Map<Id,OfertaGarantiaProduto__c>) Trigger.oldMap;
    }
    
	//PLV-3434 - INICIO
    public override void beforeInsert(){
        this.preencheCampoChave();
        //PLV-4071 - INICIO - PEDRO AUGUSTO - SYS4B
        this.validaFormula();
        //PLV-4071 - FIM - PEDRO AUGUSTO - SYS4B
    }
    
    public override void beforeUpdate(){
        this.preencheCampoChave();
        //PLV-4071 - INICIO - PEDRO AUGUSTO - SYS4B
        this.validaFormula();
        //PLV-4071 - FIM - PEDRO AUGUSTO - SYS4B
    }
    
    public class NewException extends Exception {}

    // OfertaGarantiaProdutoHandler.checkDuplicate();
    public static void checkDuplicate(){
        List<AggregateResult> listDuplicate = [ SELECT Oferta__c, GarantiaProduto__c, COUNT(Id) FROM OfertaGarantiaProduto__c GROUP BY Oferta__c, GarantiaProduto__c HAVING COUNT(Id) > 1 ];
        if( listDuplicate.size() > 0 ){
            for(AggregateResult ar : listDuplicate){
                System.debug( 'Duplicate:' + ar.get( 'Oferta__c' ) + '|' + ar.get( 'GarantiaProduto__c' ) );
            } 
            throw new NewException('There are duplicates. Check log file (\"Debug only\").');
        }
    }
    
    // OfertaGarantiaProdutoHandler.updateAll();
    public static void updateAll(){
        List<OfertaGarantiaProduto__c> listAll = [ SELECT Id FROM OfertaGarantiaProduto__c ];
        update listAll;
    }
    
    private void preencheCampoChave(){
        for( OfertaGarantiaProduto__c ogp : listOGPNew ){
            if( String.isBlank( ogp.Chave__c ) || ogp.Chave__c.length() == 19 || ogp.Chave__c.length() == 37 ){
                ogp.Chave__c = ogp.Oferta__c + '|' + ( ogp.GarantiaProduto__c == null ? '' : ogp.GarantiaProduto__c );
            }
        }   
    }
	//PLV-3434 - FIM
    

    //PLV-4071 - INICIO - PEDRO AUGUSTO - SYS4B

    public void validaFormula(){
        Map<String,InformacaoOferta__c> mapInfo = new Map<String,InformacaoOferta__c>();
        Map<String,List<OpcaoInformacao__c>> mapIDxOpcao = new Map<String,List<OpcaoInformacao__c>>();

        Set<Id> setOpcoes = new Set<Id>();

        for(InformacaoOferta__c InfOferta : [SELECT Id
                                                , Id__c
                                                , Name
                                                , Descricao__c
                                                , Obrigatorio__c
                                                , Ordem__c
                                                , Servico__c
                                                , tipo__c
                                                FROM InformacaoOferta__c
                                                WHERE tipo__c='Opções fixas' OR tipo__c='Número inteiro']){
            mapInfo.put(InfOferta.Id__c,InfOferta);
            if(infOferta.tipo__c=='Opções fixas'){
                setOpcoes.add(infOferta.Id);
            }
            if(infOferta.tipo__c=='Número inteiro'){
                mapIDxOpcao.put(infOferta.Id__c,new List<OpcaoInformacao__c>());
            }
        }

        if(!setOpcoes.isEmpty()){
            List<OpcaoInformacao__c> opcoes = [SELECT Id, Codigo__c,InformacaoOferta__r.Id__c FROM OpcaoInformacao__c WHERE InformacaoOferta__c IN:setOpcoes];
            for(OpcaoInformacao__c opcao : opcoes){
                if(opcao.Codigo__c.isNumeric()){
                    if(!mapIDxOpcao.keyset().contains(opcao.InformacaoOferta__r.Id__c)) mapIDxOpcao.put(opcao.InformacaoOferta__r.Id__c,new List<OpcaoInformacao__c>());
                    mapIDxOpcao.get(opcao.InformacaoOferta__r.Id__c).add(opcao);
                }
            }
        }


        for( OfertaGarantiaProduto__c ogp : listOGPNew ){
            if(ogp.TipoCalculo__c!='Fórmula') continue;
            Decimal resultado = null;
            List<String> listIDsErro = new List<String>();
            if(String.isBlank(ogp.formula__c)){
                ogp.addError('A Fórmula (Cálculo do Valor do Capital) não pode estar em branco');
                continue;
            }

            String formula = ogp.formula__c;
            String regex = '(?<=op)|(?=op)'.replace('op', '[-+*\\/()]');
            
            List<String> formulaSplit = formula.split(regex);
            for(String item : formulaSplit){
                //System.debug(LoggingLevel.Error,'>>> item'+item);
                item = item.trim();

                if(item.isAlpha() || ((!item.isAlpha() && (item.contains('_')||item.contains('-')) && item!='_' && item!='-'))){
                    if(!mapIDxOpcao.keyset().contains(item)){
                        listIDsErro.add(item);
                    }
                }else if(!item.isNumeric() && item.isAlphanumeric() &&(item!='+' && item!='-' && item!='*' && item!='/' && item!='(' && item!=')' && item!='%')){
                    if(!mapIDxOpcao.keyset().contains(item)){
                        listIDsErro.add(item);
                    }
                }
            }

            System.debug(LoggingLevel.Error,'>>> listIDsErro'+listIDsErro);


            if(!listIDsErro.isEmpty()){
                ogp.addError('Não foi identificado referência para: '+String.join(listIDsErro, ', ')+'.  Opções Possíveis: '+String.join(new List<String>(mapIDxOpcao.keyset()), ', '));
            }

        }
    }
    //PLV-4071 - FIM - PEDRO AUGUSTO - SYS4B




    public override void beforeDelete(){
        //this.impedeDelGarantiaObrigatoria();
    }
    
    /*private void impedeDelGarantiaObrigatoria(){
		//PLV-3434 - INICIO
        String desabilitarImpedimentoDelecaoGarantiaObrigatoria = Label.Desabilitar_Impedimento_de_Delecao_de_Garantia_Obrigatoria;
        if( desabilitarImpedimentoDelecaoGarantiaObrigatoria == 'true' ) return;
		//PLV-3434 - FIM
        
        List<String> gpIdList = new List<String>();
        for(OfertaGarantiaProduto__c ogp : listOGPOld) gpIdList.add(ogp.GarantiaProduto__c);
            
        Map<Id,GarantiaProduto__c> mapGP = new Map<Id,GarantiaProduto__c>([
            SELECT Id, Obrigatoria__c FROM GarantiaProduto__c WHERE Id IN :gpIdList
        ]);
        
        for(OfertaGarantiaProduto__c ogp : listOGPOld){
            if(mapGP.get(ogp.GarantiaProduto__c).Obrigatoria__c) ogp.addError('Oferta de garantia obrigatória não pode ser excluida.');
        }    
    }*/
    //PLV-4283 - INICIO
    public override void afterUpdate(){
        this.validarCampos();
    }
    public void validarCampos(){
        
        Set<Id> idGarantiaProduto = new Set<Id>();
        
        for(OfertaGarantiaProduto__c ogp: listOGPNew){
            idGarantiaProduto.add(ogp.GarantiaProduto__c);
        }
        //PLV - 4283 INICIO - FIX 
        List<GarantiaProduto__c> lGarantiaProduto = [SELECT Id,LimiteMaximoCaracteristicaEspecial__c, LimiteMinimoCaracteristicaEspecial__c 
                                                     From GarantiaProduto__c
                                                     WHERE Id IN: idGarantiaProduto];
        
        for(GarantiaProduto__c g: lGarantiaProduto){
            for(OfertaGarantiaProduto__c ogp: listOGPNew){
                if(ogp.GarantiaProduto__c == g.Id){
                    if(g.LimiteMaximoCaracteristicaEspecial__c != null && g.LimiteMinimoCaracteristicaEspecial__c != null){
                        if(ogp.ValorCaracteristicaEspecial__c == null){
                            ogp.addError('Valor Caracteristica Especial não pode ser vazio');
                        }else{
                            if(ogp.ValorCaracteristicaEspecial__c >= g.LimiteMinimoCaracteristicaEspecial__c && 
                               ogp.ValorCaracteristicaEspecial__c <= g.LimiteMaximoCaracteristicaEspecial__c){
                               //PLV - 4283 INICIO - FIX 
                               }else{
                                   ogp.addError('O Valor da característica especial  deve estar dentro dos limites mínimo e máximo cadastrados');
                               }
                        }
                    }
                }
            }
        }       
    }
    //PLV-4283 - FIM
}