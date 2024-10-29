/**
 * Created by Alessandro Ponte on 14/12/2018.
 */
({
    validar : function (component) {

        let corpo = component.get('v.solicitarTituloTO');

        let listMensagens = [];

        if(!corpo.parceiro){
            listMensagens.push('Por favor, informar o parceiro.');
        }

        if(!corpo.produto){
            listMensagens.push('Por favor, informar o produto.');
        }

        if(!corpo.origemproposta){
            listMensagens.push('Por favor, informar a origem da proposta.');
        }

        if(!corpo.quantidade){
            listMensagens.push('Por favor, informar a quantidade.');
        }

        component.set( 'v.erros', listMensagens );

        if( listMensagens.length > 0 ){
            return false;
        }

        return true;

    },

    buscarParceiros : function (component, inputParceiro) {

        let self = this;

        let callback = (listParceiros) => {

            // cria o mapa de parceiros
            let mapParceiros = self.gerarMapa(listParceiros, 'parceiro');
            component.set('v.mapParceiros',mapParceiros);

            // Popula o select de parceiro
            self.popularSelectAPartirMap(component, inputParceiro, mapParceiros,'parceiro');

        }

        self.chamarController(component, 'buscarTodosParceiros', {}, callback);
    },

    scrollToElement : function(component,elementId){

        var errorMessage = component.find(elementId).getElement();
        if(errorMessage){
            errorMessage.scrollIntoView();
        }
    },

    gerarMapa: function(listValores, campo){

        let map = {};

        for(let valor  of listValores){

            if(campo == 'parceiro'){
                map[valor.Codigo__c] = valor;
            }else{
                map[valor.Id] = valor;
            }

        }

        return map;
    },

    popularSelectAPartirMap: function(component, inputsel, mapValores, campo)
    {
        var opts = [];

        opts.push({"class": "optionClass", label: '-- SELECIONE --', value: '', disabled: 'true'});

        if(mapValores){
            for(let key in mapValores){

                if(campo == 'parceiro'){
                    opts.push({"class": "optionClass", label: mapValores[key].Conta__r.Name, value: key});
                }else if(campo == 'produtosParceiro'){
                    opts.push({"class": "optionClass", label: mapValores[key].Produto__r.Name, value: mapValores[key].Sigla__c});
                }else{
                    opts.push({"class": "optionClass", label: mapValores[key], value: key});
                }

            }

            // habilita o campo
            inputsel.set('v.disabled',false);

        }else{
            // desabilita o campo
            inputsel.set('v.disabled',true);
        }

        inputsel.set("v.options", opts);


    },

    solicitarTitulosHelper : function(component){

        let solicitarTituloTO = component.get('v.solicitarTituloTO');

        let callback = (retornoString) => {
            let retorno = JSON.parse(retornoString);
            let mensagem = retorno.meta.mensagem;

            this.fireNotification('Sucesso', mensagem, 'success');
        };

        this.chamarController(component, 'gerarNumeroProposta', { solicitarTituloTOString : JSON.stringify(solicitarTituloTO) }, callback);

    },

    fireNotification: function(title, message, type, duration, mode){
        if(mode == undefined) mode = 'dismissible';
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

    chamarController : function(component, method, params, callback, callbackError) {

        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");

        if(component){
            let apexCall = component.get('c.' + method);
            apexCall.setParams(params);
            apexCall.setCallback(this, (response) => {

                var state = response.getState();
                console.log('state',state);
                console.log('method',method);

                if (state === "SUCCESS") {
                    $A.util.toggleClass(spinner, "slds-hide");
                    callback(response.getReturnValue());
                }else{

                    $A.util.toggleClass(spinner, "slds-hide");

                    if(callbackError){
                        callbackError(response.getError());
                    }else{

                        let listException = response.getError();

                        if(listException && listException.length > 0){

                            for(let exception of listException){
                                let customException = JSON.parse(exception.message);
                                this.fireNotification(customException.nome, customException.mensagem, 'error');
                            }

                        }else{
                            this.fireNotification('Erro', 'Ocorreu um problema. Por favor contate o adminstrador do sistema.', 'error');
                        }

                    }
                };
            });

            $A.enqueueAction(apexCall);
        } else {
            console.log('this Exception: Component access not granted. Please initialize it.');
        }
    },


})