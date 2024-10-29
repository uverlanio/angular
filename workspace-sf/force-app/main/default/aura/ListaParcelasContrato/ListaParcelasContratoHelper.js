({
    toggleSpinner : function (component)
    {
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },

    showToast: function(titulo, msg, tipo)
    {
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent == null)
            return;

        toastEvent.setParams({
            'title': titulo,
            'message': msg,
            'type': tipo
        });
        toastEvent.fire();
    },

    requestFromServer: function(component, controller, setter, params)
    {
        var action = component.get(controller);
        if(params)
            action.setParams(params);

        action.setCallback(this, function(response)
        {
            var state = response.getState();
            var retorno = response.getReturnValue();

            if(component.isValid() && state === 'SUCCESS')
            {
                // if(retorno.length == 0)
                // 	this.showToast('Aviso!', 'nenhuma parcela encontrada.', 'warning');
				retorno = this.removerSemRestituicao(retorno); //PLV-5094 - INICIO/FIM
                component.set(setter, retorno.sort(this.compare));

            }
            else// Se ocorrer algum erro, exibe mensagem
            {
                this.showToast('Erro!', 'Ocorreu um erro inesperado!', 'error');
            }

            $A.util.addClass(component.find("mySpinner"), "slds-hide");
        });

        // Faz a chamada
        $A.enqueueAction(action);
    },

    compare : function(a,b)
    {
        if(parseInt(a.numeroParcela) < parseInt(b.numeroParcela)) return -1;
        if(parseInt(a.numeroParcela) > parseInt(b.numeroParcela)) return 1;
        return 0;
    },
    
    //PLV-5094 - INICIO
    removerSemRestituicao : function(parcelas){ 
  		var i = 0;
        while (i < parcelas.length) {
            if (parcelas[i].status == 'A RESTITUIR' && parcelas[i].valorTotal == 0) {
              parcelas.splice(i, 1);
            } else ++i;
        }
        return parcelas;
    },
    //PLV-5094 - FIM

    obterParcelas : function(component)
    {
        this.toggleSpinner(component);
        var recordId = component.get('v.recordId');
        this.requestFromServer(	component, 'c.obterParcelas', 'v.lstParcelas', {'id': recordId});
    },

    //PLV-3869 - INICIO - PEDRO AUGUSTO -SYS4B
    getCanEditHelper: function (component) {
        var action = component.get('c.getCanEdit');

        action.setCallback(this, function (response) {
            var state = response.getState();
            var retorno = response.getReturnValue();

            if (component.isValid() && state === 'SUCCESS') {
               component.set('v.canEdit',retorno);
            }else{
                this.showToast('Erro!', 'Erro ao obter permissão de edição', 'error');
            }
            this.obterParcelas(component);

            $A.util.addClass(component.find("mySpinner"), "slds-hide");
        });

        $A.enqueueAction(action);
    }
    //PLV-3869 - FIM - PEDRO AUGUSTO -SYS4B

})