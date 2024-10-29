({
    //PLV-4535 - INICIO

    possuiComplemento: function (component) {

        var action = component.get('c.possuiComplementoIndenizacao');
        action.setParams({
            idBeneficiarioGarantia: component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            let retornoController = JSON.parse(response.getReturnValue());
            let state = retornoController.tipo;
            if (state === 'success') {
                let toast = $A.get('e.force:showToast');
                toast.setParams({
                    'title': 'Sucesso!',
                    'mode': 'sticky',
                    'message': 'Atualização monetária realizada com sucesso!',
                    'type': 'success'
                });
                toast.fire();
                $A.get("e.force:closeQuickAction").fire();

            } else if (retornoController.mensagens.includes("Possui complemento.")) {
                let spinner = component.find("mySpinner");
                $A.util.toggleClass(spinner, "slds-hide");
                component.set("v.criarOuSubstituir", true);
            } else {
                let toast = $A.get('e.force:showToast');
                toast.setParams({
                    'title': 'Erro!',
                    'mode': 'sticky',
                    'message': retornoController.mensagens[0],
                    'type': 'error'
                });
                toast.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    },

    criarOutro: function (component) {
        let spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
        component.set("v.criarOuSubstituir", false);
        var action = component.get('c.criaComplementoIndenizacao');
        action.setParams({
            idBeneficiarioGarantia: component.get('v.recordId'),
            substituir: false
        });
        action.setCallback(this, function (response) {
            let retornoController = JSON.parse(response.getReturnValue());
            let state = retornoController.tipo;
            if (state === 'success') {
                let toast = $A.get('e.force:showToast');
                toast.setParams({
                    'title': 'Sucesso!',
                    'mode': 'sticky',
                    'message': 'Atualização monetária realizada com sucesso!',
                    'type': 'success'
                });
                toast.fire();
                helper.notifyRecordPage();
                $A.get("e.force:closeQuickAction").fire();

            } else if (retornoController.mensagens.includes("Possui complemento.")) {
                let spinner = component.find("mySpinner");
                $A.util.toggleClass(spinner, "slds-hide");
                component.set("v.criarOuSubstituir", true);
            } else {
                let toast = $A.get('e.force:showToast');
                toast.setParams({
                    'title': 'Erro!',
                    'mode': 'sticky',
                    'message': retornoController.mensagens[0],
                    'type': 'error'
                });
                toast.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    },

    substituir: function (component) {
        let spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
        component.set("v.criarOuSubstituir", false);
        var action = component.get('c.criaComplementoIndenizacao');
        action.setParams({
            idBeneficiarioGarantia: component.get('v.recordId'),
            substituir: true
        });
        action.setCallback(this, function (response) {
            let retornoController = JSON.parse(response.getReturnValue());
            let state = retornoController.tipo;
            if (state === 'success') {
                let toast = $A.get('e.force:showToast');
                toast.setParams({
                    'title': 'Sucesso!',
                    'mode': 'sticky',
                    'message': 'Atualização monetária realizada com sucesso!',
                    'type': 'success'
                });
                toast.fire();
                helper.notifyRecordPage();
                $A.get("e.force:closeQuickAction").fire();

            } else if (retornoController.mensagens.includes("Possui complemento.")) {
                let spinner = component.find("mySpinner");
                $A.util.toggleClass(spinner, "slds-hide");
                component.set("v.criarOuSubstituir", true);
            } else {
                let toast = $A.get('e.force:showToast');
                toast.setParams({
                    'title': 'Erro!',
                    'mode': 'sticky',
                    'message': retornoController.mensagens[0],
                    'type': 'error'
                });
                toast.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    },
    //PLV-4535 - FIM
})