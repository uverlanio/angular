//II-166 - INICIO
public without sharing class AltFormPgtoTO { //FNPVVEP-126 INICIO-FIM

    public AltFormPgtoTO() {
        FormaPagamentoTO formaPagamentoTO = new FormaPagamentoTO();
    }

    public class FormaPagamentoTO {

        public String proposta;
        public String formaPagamentoAtual;
        public String codFormPag; //II-174 FIX01 INICIO/FIM
        public Map<FormaPagamento__c, String> mapParcelamento = new Map<FormaPagamento__c, String>();
        public Decimal valorPremioAtual;
        public String novaFormaPagamento;
    }
    //II-172 - INICIO
    public class EnderecoTO {

        @AuraEnabled public String logradouro { get; set; }
        @AuraEnabled public String bairro { get; set; }
        @AuraEnabled public String cidade { get; set; }
        @AuraEnabled public String estado { get; set; }
        @AuraEnabled public String uf { get; set; }
        @AuraEnabled public String cepPrefixo { get;set; }
        @AuraEnabled public String cepSufixo { get;set; }
    }
    
    //II-172 - FIM    
}

//II-166 - FIM