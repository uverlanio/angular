/**
* @author Renato Matheus Simião
* @version 1.0
* @date 2019-09-11
* @description Trigger handler for the SObject CartaoCredito__c
*/
// INICIO - PLV-2666
public without sharing class CartaoCreditoTriggerHandler extends TriggerHandler { //FNPVVEP-126 INICIO-FIM

    private List<CartaoCredito__c> tNew;
    private List<CartaoCredito__c> tOld;
    private Map<Id, CartaoCredito__c> tNewMap;
    private Map<Id, CartaoCredito__c> tOldMap;

    public CartaoCreditoTriggerHandler() {

        this.tNew = (List<CartaoCredito__c>) Trigger.new;
        this.tOld = (List<CartaoCredito__c>) Trigger.old;
        this.tNewMap = (Map<Id, CartaoCredito__c>) Trigger.newMap;
        this.tOldMap = (Map<Id, CartaoCredito__c>) Trigger.oldMap;
    }

    public override void beforeInsert() {

        setDefaultValues();
    }

    public override void beforeUpdate() {

        setDefaultValues();
    }

    //PLV-4449-VI - INICIO
    public override void afterInsert() {
        preencherTicket(JSON.serialize(this.tNew));
        limparInformacoes();//PLV-4926 - INICIO/FIM - PEDRO AUGUSTO BRAZ
    }
    
    public override void afterUpdate(){
        preencherTicket(JSON.serialize(this.tNew));
        //limparInformacoes();//PLV-4926 - INICIO/FIM - PEDRO AUGUSTO BRAZ //PLV-5064 INICIO/FIM
    }
    //PLV-4449-VI - FIM

    public static String getIdExterno(CartaoCredito__c pCartaoCredito) {
        //TKCL-263 INICIO
        System.debug('Rogerio pCartao antes do if'+ pCartaoCredito.Ticket__c);
        System.debug('Rogerio NumeroCartao__c antes do if'+ pCartaoCredito.NumeroCartao__c);
        if(pCartaoCredito.NumeroCartao__c != null && pCartaoCredito.NumeroCartao__c != ''){
            System.debug('entrou no if Rogerio');
            System.debug('Rogerio NumeroCartao__c dentro do if'+ pCartaoCredito.NumeroCartao__c);
            return pCartaoCredito.Conta__c + pCartaoCredito.NumeroCartao__c;
        }else{
            system.debug('Entrou no else Rogerio');
            System.debug('Rogerio pCartao'+ pCartaoCredito.Ticket__c);
            String ticketAPTLMK = pCartaoCredito.Ticket__c.replace('-', '');
            system.debug('pCartaoCredito Rogerio: ' + ticketAPTLMK);
            return pCartaoCredito.Conta__c + ticketAPTLMK;
        }
        //TKCL-263 FIM
        /*
        //PLV_2822 - INICIO - Informações do cartão de crédito não podem ser armazenadas no SF
        return pCartaoCredito.Conta__c + pCartaoCredito.NumeroCartao__c;
        //PLV_2822 - FIM - Informações do cartão de crédito não podem ser armazenadas no SF
        */
    }

    // seta os campos padrões de acordo com as regras de negócio (IdExterno__c)
    private void setDefaultValues() {
        //PLV-4926 - INICIO - PEDRO AUGUSTO BRAZ
        for (CartaoCredito__c cartaoCredito : this.tNew) {
            if(String.isBlank(cartaoCredito.CodigoSeguranca__c)) cartaoCredito.CodigoSeguranca__c = 'naoInformado'; //PLV-5064 INICIO/FIM
            //PLV_2822 - INICIO - Informações do cartão de crédito não podem ser armazenadas no SF
            if (TriggerHelper.isChanged(cartaoCredito, new Set<String>{'Conta__c', 'NumeroCartao__c'})){
            //PLV_2822 - FIM - Informações do cartão de crédito não podem ser armazenadas no SF
                cartaoCredito.IdExterno__c = getIdExterno(cartaoCredito);
                cartaoCredito.Bandeira__c = verificarBandeira(cartaoCredito.Bandeira__c, cartaoCredito.NumeroCartao__c); // VIAG-152 INICIO/FIM
             }
        }
        //PLV-4926 - FIM - PEDRO AUGUSTO BRAZ
    }
    
    //PLV-4449-VI - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
    //PLV-4926 - INICIO - PEDRO AUGUSTO BRAZ
    @Future(Callout=true)
    public static void preencherTicket(String cartao){
        List<CartaoCredito__c> listCartao = (List<CartaoCredito__c>) JSON.deserialize(cartao, List<CartaoCredito__c>.class);
        System.debug('cartao'+cartao);
        List<CartaoCredito__c> listCartaoToIntegrate = new List<CartaoCredito__c>();

        /*for(CartaoCredito__c c : listCartao){
            if(String.isBlank(c.Ticket__c) && String.isNotBlank(c.Status__c) &&'Não integrado'.equalsIgnoreCase(c.Status__c))
                listCartaoToIntegrate.add(c);
        }*/


        if(listCartaoToIntegrate.size()>50){
            throw new TriggerHandlerException('Lista possui mais que 50 registros para integração');
        }else{    
            for(CartaoCredito__c c : listCartaoToIntegrate){
                ServiceTO.NovoCartaoTO novoCartao = new ServiceTO.NovoCartaoTO().dtoCartao(c);
                SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.POST, SensediaServices.DOMAIN.AWS_EXTERNO, SensediaServices.NOVO_CARTAO, JSON.serialize(novoCartao, true));//MGRC-1277 - INICIO/FIM
            }
        }
        
    }
    //PLV-4449-VI - FIM - PEDRO AUGUSTO BRAZ - SYS4B
    
    public static String verificarBandeira(String pBandeira, String pNumeroCartao){
       // VIAG-152 INICIO
        if(String.isBlank(pNumeroCartao)) {
            if(String.isBlank(pBandeira)) {
                return null;
            } else {
                String  bandeira = (pBandeira).capitalize();
                 if (bandeira =='Elo' ||bandeira =='Jcb' || bandeira =='Aura'||bandeira =='Hipercard'||bandeira =='Maestro'||bandeira =='Visa'|| bandeira =='Amex' ||bandeira =='Discover'||bandeira =='Dinersclub'||bandeira =='Mastercard' ) {
                    return bandeira;
                 } else {
                    return 'Não identificado'; 
                 }
            }
        // VIAG-152  FIM
        } else {
       
        pNumeroCartao = pNumeroCartao.replaceAll('\\D', '');
        System.debug('pNumeroCartao'+pNumeroCartao);
        Map<String,String> mapBandeiraPattern = new Map<String,String>();

        mapBandeiraPattern.put('Elo',         '^((((636368)|(438935)|(504175)|(451416)|(636297))\\d{0,10})|((5067)|(4576)|(4011))\\d{0,12})$');
        mapBandeiraPattern.put('Jcb',         '^(?:2131|1800|35\\d{3})\\d{11}$');
        mapBandeiraPattern.put('Aura',        '^(5078\\d{2})(\\d{2})(\\d{11})$');
        mapBandeiraPattern.put('Hipercard',   '^(606282\\d{10}(\\d{3})?)|(3841\\d{15})$');
        mapBandeiraPattern.put('Maestro',     '^(?:5[0678]\\d\\d|6304|6390|67\\d\\d)\\d{8,15}$');
        mapBandeiraPattern.put('Visa',        '^4\\d{12}(\\d{3})?$');
        mapBandeiraPattern.put('Amex',        '^3[47]\\d{13}$');
        mapBandeiraPattern.put('Discover',    '^6(?:011|5[0-9]{2})[0-9]{12}$');
        mapBandeiraPattern.put('Dinersclub',  '^3(0[0-5]|[68]\\d)\\d{11}$');
        mapBandeiraPattern.put('Mastercard',  '^(5[1-5]\\d{4}|677189)\\d{10}$');

        String bandeiraToReturn;
        for(String bandeira : mapBandeiraPattern.keySet()){
            if(bandeiraToReturn!=null) continue;
            Pattern MyPattern = Pattern.compile(mapBandeiraPattern.get(bandeira));
            Matcher MyMatcher = MyPattern.matcher(pNumeroCartao);
            if(MyMatcher.matches()) bandeiraToReturn= bandeira;
        }
        return bandeiraToReturn!=null ? bandeiraToReturn.toLowerCase() : 'Não identificado';

        //CANO NECESSITEM DE OUTRAS BANDEIRAS ENCONTREI ESSES REGEX
        //NÃO ESQUEÇA DE ADICIONARO O VALOR NO PICKLIST BANDEIRA__C
        /*
        mapBandeiraPattern.put('banese card', '^636117');
        mapBandeiraPattern.put('cabal', '(60420[1-9]|6042[1-9][0-9]|6043[0-9]{2}|604400)');
        mapBandeiraPattern.put('valecard', '^606444|^606458|^606482');
        mapBandeiraPattern.put('personal card', '^636085');
        mapBandeiraPattern.put('grandCard', '^605032');
        mapBandeiraPattern.put('fort brasil', '^628167');
        */
      }
    }

    private void limparInformacoes() {
        List<CartaoCredito__c> listToClear = new List<CartaoCredito__c>();
        for (CartaoCredito__c cartaoCredito : this.tNew) {
            if(cartaoCredito.CodigoSeguranca__c!=null){
                CartaoCredito__c ca = new CartaoCredito__c();
                ca.Id = cartaoCredito.Id;
                ca.CodigoSeguranca__c = null;
                listToClear.add(ca);
            }
        }
        if(listToClear.size()>0) update listToClear;
    }
    //PLV-4926 - FIM - PEDRO AUGUSTO BRAZ
}