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

                component.set("v.visivel", true);

                let data = response.getReturnValue();

                let listTipoContagem = data.listTipoContagem        || [];
                let listMotivos =   data.motivosReabertura          || [];
               

                component.set("v.listTipoContagem", listTipoContagem);
                component.set("v.motivoReabertura", listMotivos);
                component.set("v.permitido", data.canReopen);
                component.set("v.showSpinner", false);
                component.set("v.visivel", data.visible);


            } else if (state == "ERROR") {
                this.fireNotification('Reabrir Sinistro', 'Erro ao buscar informações', 'error');
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
            let cboMotivovalue = component.find("cboMotivo").get("v.value");
            let cboTipoContagemvalue = component.find("cboTipoContagem").get("v.value");
            let obsvalue = component.find("txtObs").get("v.value");

            var action = component.get("c.reabrirSinistro");

            action.setParams({
                recordId: component.get('v.recordId'),
                motivo: cboMotivovalue,
                TipoContagem: cboTipoContagemvalue,
                observacao: obsvalue
            });

            action.setCallback(this, (response) => {
                var state = response.getState();

                this.toggleSpinner(component);

                console.log(state);

                if (state == "SUCCESS") {

                    let data = response.getReturnValue();

                    if(data.sucesso){
                        this.fireNotification('Reabrir Sinistro', 'Sinistro reaberto com sucesso', 'success');
                        $A.get("e.force:closeQuickAction").fire();
                        $A.get('e.force:refreshView').fire();
                    }else{
                        this.fireNotification('Reabrir Sinistro', data.mensagem, 'error');
                    }

                } else if (state == "ERROR") {
                    
                    this.fireNotification('Reabrir Sinistro', 'Erro ao reabrir o sinistro', 'error');

                }
                component.set("v.showSpinner", false);
            });

            $A.enqueueAction(action);


        }else{
            component.set("v.showSpinner", false);
            this.fireNotification('Reabrir Sinistro', 'Campos obrigatórios não preenchidos', 'error');
        }

    },

    handleConfirmDialog: function (component, event, helper) {
        let allOK = this.validateForm(component);

        if (allOK) {
            component.set('v.showConfirmDialog', true);
        }else{
            component.set("v.showSpinner", false);
            this.fireNotification('Reabrir Sinistro', 'Campos obrigatórios não preenchidos', 'error');
        }
    },

    toggleSpinner: function (component) {
        let spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },

    validateForm: function (component) {
        //Validar Motivo
        var allOK = true;
        let cboMotivo = component.find("cboMotivo");
        let cboMotivovalue = cboMotivo.get("v.value");
        if (!cboMotivovalue && cboMotivovalue == "") {
            allOK =false;
        }
        let cboTipoContagem = component.find("cboTipoContagem");
        let cboTipoContagemvalue = cboTipoContagem.get("v.value");
        if (!cboTipoContagemvalue && cboTipoContagemvalue == "") {
            allOK =false;
        }
        
        return allOK;
        
    }
})