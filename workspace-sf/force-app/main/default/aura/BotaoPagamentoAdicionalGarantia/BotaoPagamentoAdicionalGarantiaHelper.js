({
    fireNotification: function (title, message, type, duration, mode) {
        if (mode == undefined) mode = 'dismissible';
        var notification = $A.get("e.force:showToast");
        notification.setParams({
            type: type,
            title: title,
            mode: mode,
            duration: duration ? duration : 10,
            message: message
        });
        notification.fire();
    },

    doInit: function (component, event, helper) {

        var action = component.get("c.buscarInformacoes");

        action.setParams({
            recordId: component.get('v.recordId')
        });

        action.setCallback(this, (response) => {
            var state = response.getState();

            component.set("v.showSpinner",true);
           

            console.log(state);

            if (state == "SUCCESS") {

                component.set("v.visivel", 'visivel');

                let data = response.getReturnValue();

                let listJustificativas =   data.justificativasPagamento  || [];

                component.set("v.justificativaPagamento", listJustificativas);
                component.set("v.showSpinner", false);
                component.set("v.visivel", data.visible);
            } else if (state == "ERROR") {
                this.fireNotification('Novo Pagamento', 'Erro ao buscar informações', 'error');
            }
            component.set("v.showSpinner", false);
            
        });

        $A.enqueueAction(action);

    },

    cancelar: function (component) {
        $A.get("e.force:closeQuickAction").fire();
    },
    salvar: function (component, event, helper) {
        component.set("v.showSpinner", true);

        let allOK = this.validateForm(component);
        
        if(allOK){
            let cboJustificativaValue = component.find("cboJustificativa").get("v.value");
            let valorInden = component.find("valueNum").get("v.value");

            var action = component.get("c.criarGarantia");

            action.setParams({
                recordId: component.get('v.recordId'),
                justPag: cboJustificativaValue,
                valor: valorInden
            });

            action.setCallback(this, (response) => {
                var state = response.getState();

                this.toggleSpinner(component);

                console.log(state);

                if (state == "SUCCESS") {

                    let data = response.getReturnValue();

                    if(data.sucesso){
                        this.fireNotification('Novo Pagamento', 'Pagamento adicional criado com sucesso', 'success');
                        $A.get("e.force:closeQuickAction").fire();
                        $A.get('e.force:refreshView').fire();
                    }else{
                        this.fireNotification('Nova Garantia', data.mensagem, 'error');
                    }

                } else if (state == "ERROR") {
                    
                    this.fireNotification('Novo Pagamento', 'Erro ao criar Pagamento', 'error');

                }
                component.set("v.showSpinner", false);
            });

            $A.enqueueAction(action);

        }else{
            component.set("v.showSpinner", false);
            this.fireNotification('Novo Pagamento', 'Campos obrigatórios não preenchidos', 'error');
        }

    },

    handleConfirmDialog: function (component, event, helper) {
        component.set('v.showConfirmDialog', true);
    },

    toggleSpinner: function (component) {
        let spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },

    validateForm: function (component) {
        var allOK = true;

        // valida campo valor
        let valueNum = component.find("valueNum");
        let valueNumValue = valueNum.get("v.value");
        if (!valueNumValue && valueNumValue != "") {
            allOK =false;
        }

        // valida campo justificativas
        let cboJustificativa = component.find("cboJustificativa");
        let cboJustificativaValue = cboJustificativa.get("v.value");
        if (!cboJustificativaValue && cboJustificativaValue!=""){
            allOK = false;
        }
        
        return allOK;

    }
})