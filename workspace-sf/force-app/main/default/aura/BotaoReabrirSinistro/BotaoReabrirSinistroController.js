({

    doInit: function (component, event, helper) {
        helper.doInit(component, event, helper);
    },


    salvar: function (component, event, helper) {
        helper.handleConfirmDialog(component, event, helper);
    },

    //Fecha popup
    cancelar: function (component, event, helper) {
        helper.cancelar(component, event);
    },

    //confirmação
    handleConfirmDialogSim: function (component, event, helper) {
        component.set('v.showConfirmDialog', false);
        helper.salvar(component, event, helper);
    },

    handleConfirmDialogNao: function (component, event, helper) {
        component.set('v.showConfirmDialog', false);
    },
    change: function (component, event, helper) {
    },

})