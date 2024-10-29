/**
* @author Renato Matheus Simião
* @version 1.0
* @date 2019-08-26
* @description Trigger handler for the SObject BeneficiarioSeguradoProposta__c
*/
// INICIO - PLV-2610
public with sharing class BeneficiarioSeguradoPropostaHandler extends TriggerHandler {

    private List<BeneficiarioSeguradoProposta__c> tNew;
    private List<BeneficiarioSeguradoProposta__c> tOld;
    private Map<Id, BeneficiarioSeguradoProposta__c> tNewMap;
    private Map<Id, BeneficiarioSeguradoProposta__c> tOldMap;
    private static PepBO pep = PepBO.getInstance();

    public BeneficiarioSeguradoPropostaHandler() {

        this.tNew = (List<BeneficiarioSeguradoProposta__c>) Trigger.new;
        this.tOld = (List<BeneficiarioSeguradoProposta__c>) Trigger.old;
        this.tNewMap = (Map<Id, BeneficiarioSeguradoProposta__c>) Trigger.newMap;
        this.tOldMap = (Map<Id, BeneficiarioSeguradoProposta__c>) Trigger.oldMap;
    }

    public override void beforeInsert() {

        setDefaultValues();
    }

    public override void beforeUpdate() {

        setDefaultValues();
    }
    //INICIO - LECVPV-218
    public override void afterInsert(){
        //INICIO LECVPV-235-FIX1
        list<BeneficiarioSeguradoProposta__c> listBeneSegProposta  = Trigger.new;
        if(listBeneSegProposta[0].PropostaMassificado__c == false){
            pep.getListObjectPep(Trigger.new);
        }
        //FIM LECVPV-235-FIX1
    }
    //FIM - LECVPV-218

       
    

    // seta os campos padrões de acordo com as regras de negócio (CpfPep__c, CpfCnpj__c, Conta__c...)
    private void setDefaultValues() {

        // Seta a conta de acordo com o CPF/CNPJ inserido, o problema é que o mesmo campo que vem o CPF vem tbm o CNPJ mas na conta os campos são diferentes...
        Set<String> sCPFCNPJ = new Set<String>();
        List<BeneficiarioSeguradoProposta__c> lBeneficiario = new List<BeneficiarioSeguradoProposta__c>();
        String segmentoProposta; //PLV-5099 INICIO / FIM

        for (BeneficiarioSeguradoProposta__c beneficiario : this.tNew) {            
            if (TriggerHelper.isChanged(beneficiario, 'CpfCnpj__c')) {
                // MEL-5 - INICIO
                System.debug('beneficiario cnpj: '+beneficiario.CpfCnpj__c);
                // removendo a máscara se existente para validar por tamanho CPF e CNPJ 
                beneficiario.CpfCnpj__c = beneficiario.CpfCnpj__c.replaceAll('\\.', '').replaceAll('/', '').replaceAll('-', '');
                if (beneficiario.CpfCnpj__c.length() > 11) {
                    // cnpj sempre terá comprimento maior que 11 
                    // if (!beneficiario.CpfCnpj__c.contains('.') && !beneficiario.CpfCnpj__c.contains('/') && !beneficiario.CpfCnpj__c.contains('-')) {
                        beneficiario.CpfCnpj__c = Util.imprimeCNPJ(beneficiario.CpfCnpj__c);
                    // }

                } else {
                    //PLV 5159  - INICIO
                    // if(!beneficiario.CpfCnpj__c.contains('.') && !beneficiario.CpfCnpj__c.contains('-')){
                        beneficiario.CpfCnpj__c = Util.imprimeCPF(beneficiario.CpfCnpj__c.leftPad(11,'0'));
                    // }
                }
                // MEL-5 - FIM
                //beneficiario.CpfCnpj__c = Util.imprimeCPF(beneficiario.CpfCnpj__c.leftPad(11,'0'));
                //PLV 5159  - FIM
                sCPFCNPJ.add(beneficiario.CpfCnpj__c);
                lBeneficiario.add(beneficiario);
            }

            segmentoProposta = beneficiario.SegmentoProposta__c; //PLV-5099 INICIO/FIM
            
            if (TriggerHelper.isChanged(beneficiario, 'CpfPep__c')) {
                //PLV 5159  - INICIO
                if(!beneficiario.CpfCnpj__c.contains('.') && !beneficiario.CpfCnpj__c.contains('-')){
                    beneficiario.CpfPep__c = Util.imprimeCPF(beneficiario.CpfPep__c.leftPad(11,'0'));
                }
                //beneficiario.CpfPep__c = Util.imprimeCPF(beneficiario.CpfPep__c.leftPad(11,'0'));
                //PLV 5159  - FIM
            }
        }

        if (lBeneficiario.isEmpty()) return;

        Map<String, Account> mAccount = new Map<String,Account>();
        
        //PLV-5099 INICIO
        for (Account acc : [SELECT Id, Cpf__c, Cnpj__c FROM Account WHERE Cpf__c IN :sCPFCNPJ])
            mAccount.put(acc.Cpf__c, acc);

        if(segmentoProposta != 'Individual'){
            for (BeneficiarioSeguradoProposta__c beneficiario : lBeneficiario) {
            
                if (!mAccount.containsKey(beneficiario.CpfCnpj__c)) continue;
    
                beneficiario.Conta__c = mAccount.get(beneficiario.CpfCnpj__c).Id;
            }
        }
        //PLV-5099 FIM
    }
}
// FIM - PLV-2610