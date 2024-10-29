/**
 * Created by Alessndro Ponte on 17/12/2018.
 */
({
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

    consultarEstoqueHelper : function(component){

        let consultarEstoqueTO = component.get('v.consultarEstoqueTO');

        let callback = (loteTOString) => {

            let loteTO = JSON.parse(loteTOString);
            if(loteTO != null){
                this.fireNotification('Sucesso', 'Consulta realizada com sucesso!', 'success');
            }else{
                this.fireNotification('Sucesso', 'Consulta realizada com sucesso mas sem resultado para esse filtro!', 'success');
            }

            component.set('v.lotes',loteTO.data);
        };

        this.chamarController(component, 'consultarEstoque', {'consultarEstoqueTOString' : JSON.stringify(consultarEstoqueTO)}, callback);

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

        opts.push({"class": "optionClass", label: '-- SELECIONE --', value: ''});

        if(mapValores){
            for(let key in mapValores){

                if(campo == 'parceiro'){
                    opts.push({"class": "optionClass", label: mapValores[key].Conta__r.Name, value: key});
                }else if(campo == 'produtosParceiro'){
                    opts.push({"class": "optionClass", label: mapValores[key].Produto__r.Name, value: mapValores[key].CodigoProdutoParceiro__c});
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
    chamarController : function(component, method, params, callback) {

        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");

        if(component){
            let apexCall = component.get('c.' + method);
            apexCall.setParams(params);
            apexCall.setCallback(this, (response) => {
                var state = response.getState();
                if (state === "SUCCESS") {
                    $A.util.toggleClass(spinner, "slds-hide");
                    callback(response.getReturnValue());
                }else{
                    $A.util.toggleClass(spinner, "slds-hide");
                    this.fireNotification('Erro', 'Ocorreu um problema. Contate o adminstrador.', 'error');
                };
            });

            $A.enqueueAction(apexCall);
        } else {
            console.log('this Exception: Component access not granted. Please initialize it.');
        }
    },

    validar : function (component) {
        let corpo = component.get('v.consultarEstoqueTO');

        let listMensagens = [];

        if(!corpo.dataInicial){
            listMensagens.push('Por favor, informar a data inicial da consulta.');
        }

        if(!corpo.dataFinal){
            listMensagens.push('Por favor, informar a data final da consulta.');
        }

        if(corpo.dataInicial > corpo.dataFinal){
            listMensagens.push('A data inicial não pode ser maior que a data final.');
        }

        component.set( 'v.erros', listMensagens );

        if( listMensagens.length > 0 ){
            return false;
        }

        return true;


        // if(consultarEstoqueTO)

    }

})