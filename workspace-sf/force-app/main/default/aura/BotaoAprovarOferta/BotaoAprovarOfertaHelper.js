/*
 * @author Sys4B - Denisson Santos
 * @date 2020-06-04
 * @description: Componente do botão de aprovar oferta
 * Criada para a história: PLV-3738 - MVP B - Criação de checklist para ativar configurador de oferta.
*/
({
    validateOffer: function (component) {
		component.set('v.showSpinner', true);

		var action = component.get('c.validateOffer');

		action.setParams({
            recordId: component.get('v.recordId')
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state == "SUCCESS") {
                var data = response.getReturnValue();

				var allValid = true;
				for (var i in data) {
					if (!data[i].isValid) {
						allValid = false;
						break;
					}
				}

				component.set('v.allValid', allValid);
				component.set('v.validateItems', data);
            } else {
                this.showToast();
            }

			component.set('v.showSpinner', false);
        });

        $A.enqueueAction(action); 
	},

	submitForApproval: function (component) {
		component.set('v.showSpinnerPage', true);

		var action = component.get('c.submitForApproval');

		action.setParams({
            recordId: component.get('v.recordId'),
			comments: component.get('v.comments')
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state == "SUCCESS") {
                var data = response.getReturnValue();

				if (data.status == 'success') {
					this.showToast(data.message, 'Sucesso!', 'success');
					$A.get('e.force:refreshView').fire();
					$A.get("e.force:closeQuickAction").fire();
				} else {
					this.showToast(data.message);
				}
            } else {
                this.showToast();
            }

			component.set('v.showSpinnerPage', false);
        });

        $A.enqueueAction(action); 
	},

	showToast: function (message, title, type) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			'title': (($A.util.isEmpty(title)) ? 'Ocorreu um erro!' : title),
			'type': (($A.util.isEmpty(type)) ? 'error' : type),
			'message': (($A.util.isEmpty(message)) ? 'Ocorreu um erro. Favor procurar o administrador do sistema.' : message)
		});
		toastEvent.fire();
	}
})