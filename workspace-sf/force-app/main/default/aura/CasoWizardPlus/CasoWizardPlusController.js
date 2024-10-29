({
    doInit : function(component, event, helper) {
      component.set("v.showSpinner", true);
      helper.validapreenchimentos(component,event,helper);            
    },

    fechar : function (component){
        component.set("v.showSpinner", true);
        $A.get("e.force:closeQuickAction").fire();
    },

    avancarEtapa : function(component, event, helper) {
         component.set("v.showSpinner", true);
         helper.avancarEtapa(component, event, helper);
    },
    reiniciarEtapas : function(component, event, helper) {
        helper.reiniciarEtapas(component, event, helper);
    },
    resetGarantias : function(component, event, helper) {
        helper.resetGarantias(component, event, helper);
    },
    bypassconfirm : function(component, event, helper) {
         let byconfirm = component.get("v.bypassduplicate", 'true');
         component.set("v.bypassduplicate", !byconfirm);
    },
    confirmaresetGarantias : function(component, event, helper) {
        component.set('v.tipoConfirm', 'reset');
		component.set('v.showConfirmDialog', true);
		component.set('v.confirmDialogMessage', 'Deseja <u>descartar</u> todas as modificações realizadas?')
    },


    oncheckGarantia : function(component, event, helper) {
        let dataset = event.currentTarget.dataset
        let siglaGarantia = dataset.sigla;//'DMHO';
        let checkall = dataset.checkall=="true" ? true : false;//COBERTURAS COM VALOR FIXO ASSINALAM EM TODAS OS CONTRATOS
        let toValue = event.currentTarget.checked;//true //deve vir do currentTarget.checked
        let contratoid = dataset.contratoid;//'xpto'; //deve vir do dataset.contratoId
        let garantias = component.get('v.garantiasModificadas');
		for(let i in garantias){
            let gr = garantias[i]
            if(checkall && gr.sigla==siglaGarantia){
                gr.selecionado = toValue
            }else if(!checkall && gr.sigla==siglaGarantia && gr.contratoId==contratoid){
                gr.selecionado = toValue;
            }
        }
        component.set('v.garantiasModificadas',garantias);
    },

    handleConfirmDialogNo: function (component, event, helper) {
		component.set('v.showConfirmDialog', false);
		component.set('v.tipoConfirm', '');
	},
    corrigir: function (component, event, helper) {
		component.set("v.errorInit", '');
	},
    voltar: function (component, event, helper) {
        component.set("v.errorInit", '');
        component.set("v.CasosDuplicados", null);
        let etapa = component.get("v.etapa");
        etapa = (parseInt(etapa)-1) < 1? '1' : (parseInt(etapa)-1).toString() ;
        component.set("v.etapa", etapa);
	},
    criarSinistros: function (component, event, helper) {
        component.set("v.showSpinner", true);
        component.set('v.showConfirmDialog', false);
		component.set('v.tipoConfirm', '');
		component.set("v.errorInit", '');
        helper.prossegueCriacaoSinistro(component, event, helper);
	},


})