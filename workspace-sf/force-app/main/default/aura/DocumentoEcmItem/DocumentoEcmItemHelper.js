({
   solicitacaoDownload : function(component) {
		var idEcm = component.get("v.arquivoECM.idecm__c");
        var self = this;
        var action = component.get("c.getBase64Info");
        action.setParams({
            idEcm : idEcm
        });
       
        var spinner = component.find("spinner");
        $A.util.toggleClass(spinner, "slds-show");
       
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var opwrap = response.getReturnValue();
                if(opwrap.Error != null){
                    self.showToast(opwrap.Error,"Erro","error");
                }
                else{
                	self.basetoBlobDownload(opwrap);
                }
                this.toggleSpinner(component);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						 console.error("Error message: " + errors[0].message);
                    }
                }
                console.error('Error getting attachment.');
            }
        });
        $A.enqueueAction(action);
        this.toggleSpinner(component);
    },
    basetoBlobDownload : function(wrap){
		var byteCharacters = atob(wrap.Body);
        const buf = new Array(byteCharacters.length);
        for (var i = 0; i != byteCharacters.length; ++i) buf[i] = byteCharacters.charCodeAt(i);// & 0xFF;
        const view = new Uint8Array(buf);
        var contentDisposition = wrap.Disposition;
      	var contentType = wrap.Type;
      	var filename = contentDisposition.match(/filename="(.+)"/)[1];
      	var file = new Blob([view], { type: contentType });
        var a = window.document.createElement('a');
        a.href = URL.createObjectURL(file);
        a.download = filename;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
    },
    showToast : function(message, title, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "title": title,
            "message": message
        });
        toastEvent.fire();
    },
     toggleSpinner: function(component){
        var spinner = component.find("spinner");
        $A.util.toggleClass(spinner, "slds-hide");
    }
})