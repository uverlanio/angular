trigger BeneficiarioSeguradoPropostaTrigger on BeneficiarioSeguradoProposta__c (before insert, before update, after insert, after update) {

    new BeneficiarioSeguradoPropostaHandler().run();
}