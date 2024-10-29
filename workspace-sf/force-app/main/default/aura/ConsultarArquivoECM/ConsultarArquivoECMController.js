/**
 * Created by Fábio Rente on 09/04/2019.
 */
({
    doInit : function(component, event, helper) {


        // Inicializa o atributo consultarArquivoECMTO
        var rid = component.get("v.recordId");
        let consultarArquivoECMTO = component.get('v.ConsultarArquivoECMTO');
        component.set('v.ConsultarArquivoECMTO',JSON.parse(consultarArquivoECMTO));
        component.set("v.ConsultarArquivoECMTO.idsf", rid);

        //Monta a data como data inicial = dia 01 do mês corrente. data final = dia atual
        var today = new Date();
        var todayDD = String(today.getDate()).padStart(2, '0');
        var todayMM = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var todayYYYY = today.getFullYear();

        component.set('v.ConsultarArquivoECMTO.dataInicial', todayYYYY + '-' + todayMM + '-01');
        component.set('v.ConsultarArquivoECMTO.dataFinal', todayYYYY + '-' + todayMM + '-' + todayDD);

        helper.consultarArquivoECMHelper(component);

    },

    consultarArquivoECMController: function (component, event, helper) {

        if(helper.validar(component)){
            helper.consultarArquivoECMHelper(component);
        }

    },

    downloadArquivoECMController: function (component, event, helper) {
        helper.downloadArquivoECMHelper(component, event);
    },

    voltar : function (component, event, helper) {
      component.set('v.realizarDownload', false);
    }
})