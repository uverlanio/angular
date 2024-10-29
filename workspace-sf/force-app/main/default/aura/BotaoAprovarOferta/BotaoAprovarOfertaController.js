/*
 * @author Sys4B - Denisson Santos
 * @date 2020-06-04
 * @description: Componente do botão de aprovar oferta
 * Criada para a história: PLV-3738 - MVP B - Criação de checklist para ativar configurador de oferta.
*/
({
    doInit: function(component, event, helper) {
        helper.validateOffer(component);
    },

	cancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

	submit: function(component, event, helper) {
        helper.submitForApproval(component);
    }
})