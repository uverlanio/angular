/**
 * Created by Fábio Rente on 09/04/2019.
 */
({
    consultarArquivoECMHelper : function(component){

    	// Mock
    	//let ArquivoECMTO = JSON.parse('{"data":[{"idecm":"027351731000138_18/02/2019_00005989_ADS","nomearquivo":"RENNER_PORTO_CCR_ADS_00005989_VG01.PRO","datainclusao":"2019-02-18","tipoarquivo":"ADS"},{"idecm":"027351731000138_28/03/2019_00000022_ADS","nomearquivo":"RENNER_PORTO_EP_ADS_00000022_VG01.PRO","datainclusao":"2019-03-28","tipoarquivo":"ADS"},{"idecm":"027351731000138_28/03/2019_00511427_CAN","nomearquivo":"RENNER_PORTO_EP_CAN_00511427_VG07.PRO","datainclusao":"2019-03-28","tipoarquivo":"CAN"}]}');
    	/*let ArquivoECMTO = JSON.parse('{"data":[{"idecm":"027351731000138_18/02/2019_00005989_ADS","nomearquivo":"RENNER_PORTO_CCR_ADS_00005989_VG01.PRO","datainclusao":"2019-02-18","tipoarquivo":"ADS"},{"idecm":"027351731000138_28/03/2019_00000022_ADS","nomearquivo":"RENNER_PORTO_EP_ADS_00000022_VG01.PRO","datainclusao":"2019-03-28","tipoarquivo":"ADS"},{"idecm":"027351731000138_28/03/2019_00511427_CAN","nomearquivo":"RENNER_PORTO_EP_CAN_00511427_VG07.PRO","datainclusao":"2019-03-28","tipoarquivo":"CAN"},{"idecm":"027351731000138_28/03/2019_00000022_ADS","nomearquivo":"RENNER_PORTO_EP_ADS_00000022_VG01.PRO","datainclusao":"2019-03-28","tipoarquivo":"ADS"},{"idecm":"027351731000138_28/03/2019_00511427_CAN","nomearquivo":"RENNER_PORTO_EP_CAN_00511427_VG07.PRO","datainclusao":"2019-03-28","tipoarquivo":"CAN"},{"idecm":"027351731000138_28/03/2019_00000022_ADS","nomearquivo":"RENNER_PORTO_EP_ADS_00000022_VG01.PRO","datainclusao":"2019-03-28","tipoarquivo":"ADS"},{"idecm":"027351731000138_28/03/2019_00511427_CAN","nomearquivo":"RENNER_PORTO_EP_CAN_00511427_VG07.PRO","datainclusao":"2019-03-28","tipoarquivo":"CAN"},{"idecm":"027351731000138_28/03/2019_00000022_ADS","nomearquivo":"RENNER_PORTO_EP_ADS_00000022_VG01.PRO","datainclusao":"2019-03-28","tipoarquivo":"ADS"},{"idecm":"027351731000138_28/03/2019_00511427_CAN","nomearquivo":"RENNER_PORTO_EP_CAN_00511427_VG07.PRO","datainclusao":"2019-03-28","tipoarquivo":"CAN"},{"idecm":"027351731000138_28/03/2019_00000022_ADS","nomearquivo":"RENNER_PORTO_EP_ADS_00000022_VG01.PRO","datainclusao":"2019-03-28","tipoarquivo":"ADS"},{"idecm":"027351731000138_28/03/2019_00511427_CAN","nomearquivo":"RENNER_PORTO_EP_CAN_00511427_VG07.PRO","datainclusao":"2019-03-28","tipoarquivo":"CAN"},{"idecm":"027351731000138_28/03/2019_00000022_ADS","nomearquivo":"RENNER_PORTO_EP_ADS_00000022_VG01.PRO","datainclusao":"2019-03-28","tipoarquivo":"ADS"},{"idecm":"027351731000138_28/03/2019_00511427_CAN","nomearquivo":"RENNER_PORTO_EP_CAN_00511427_VG07.PRO","datainclusao":"2019-03-28","tipoarquivo":"CAN"},{"idecm":"027351731000138_28/03/2019_00000022_ADS","nomearquivo":"RENNER_PORTO_EP_ADS_00000022_VG01.PRO","datainclusao":"2019-03-28","tipoarquivo":"ADS"},{"idecm":"027351731000138_28/03/2019_00511427_CAN","nomearquivo":"RENNER_PORTO_EP_CAN_00511427_VG07.PRO","datainclusao":"2019-03-28","tipoarquivo":"CAN"},{"idecm":"027351731000138_28/03/2019_00000022_ADS","nomearquivo":"RENNER_PORTO_EP_ADS_00000022_VG01.PRO","datainclusao":"2019-03-28","tipoarquivo":"ADS"},{"idecm":"027351731000138_28/03/2019_00511427_CAN","nomearquivo":"RENNER_PORTO_EP_CAN_00511427_VG07.PRO","datainclusao":"2019-03-28","tipoarquivo":"CAN"},{"idecm":"027351731000138_28/03/2019_00000022_ADS","nomearquivo":"RENNER_PORTO_EP_ADS_00000022_VG01.PRO","datainclusao":"2019-03-28","tipoarquivo":"ADS"},{"idecm":"027351731000138_28/03/2019_00511427_CAN","nomearquivo":"RENNER_PORTO_EP_CAN_00511427_VG07.PRO","datainclusao":"2019-03-28","tipoarquivo":"CAN"},{"idecm":"027351731000138_28/03/2019_00000022_ADS","nomearquivo":"RENNER_PORTO_EP_ADS_00000022_VG01.PRO","datainclusao":"2019-03-28","tipoarquivo":"ADS"},{"idecm":"027351731000138_28/03/2019_00511427_CAN","nomearquivo":"RENNER_PORTO_EP_CAN_00511427_VG07.PRO","datainclusao":"2019-03-28","tipoarquivo":"CAN"},{"idecm":"027351731000138_28/03/2019_00000022_ADS","nomearquivo":"RENNER_PORTO_EP_ADS_00000022_VG01.PRO","datainclusao":"2019-03-28","tipoarquivo":"ADS"},{"idecm":"027351731000138_28/03/2019_00511427_CAN","nomearquivo":"RENNER_PORTO_EP_CAN_00511427_VG07.PRO","datainclusao":"2019-03-28","tipoarquivo":"CAN"},{"idecm":"027351731000138_28/03/2019_00000022_ADS","nomearquivo":"RENNER_PORTO_EP_ADS_00000022_VG01.PRO","datainclusao":"2019-03-28","tipoarquivo":"ADS"},{"idecm":"027351731000138_28/03/2019_00511427_CAN","nomearquivo":"RENNER_PORTO_EP_CAN_00511427_VG07.PRO","datainclusao":"2019-03-28","tipoarquivo":"CAN"},{"idecm":"027351731000138_28/03/2019_00000022_ADS","nomearquivo":"RENNER_PORTO_EP_ADS_00000022_VG01.PRO","datainclusao":"2019-03-28","tipoarquivo":"ADS"},{"idecm":"027351731000138_28/03/2019_00511427_CAN","nomearquivo":"RENNER_PORTO_EP_CAN_00511427_VG07.PRO","datainclusao":"2019-03-28","tipoarquivo":"CAN"},{"idecm":"027351731000138_28/03/2019_00000022_ADS","nomearquivo":"RENNER_PORTO_EP_ADS_00000022_VG01.PRO","datainclusao":"2019-03-28","tipoarquivo":"ADS"},{"idecm":"027351731000138_28/03/2019_00511427_CAN","nomearquivo":"RENNER_PORTO_EP_CAN_00511427_VG07.PRO","datainclusao":"2019-03-28","tipoarquivo":"CAN"},{"idecm":"027351731000138_28/03/2019_00000022_ADS","nomearquivo":"RENNER_PORTO_EP_ADS_00000022_VG01.PRO","datainclusao":"2019-03-28","tipoarquivo":"ADS"},{"idecm":"027351731000138_28/03/2019_00511427_CAN","nomearquivo":"RENNER_PORTO_EP_CAN_00511427_VG07.PRO","datainclusao":"2019-03-28","tipoarquivo":"CAN"},{"idecm":"027351731000138_28/03/2019_00000022_ADS","nomearquivo":"RENNER_PORTO_EP_ADS_00000022_VG01.PRO","datainclusao":"2019-03-28","tipoarquivo":"ADS"},{"idecm":"027351731000138_28/03/2019_00511427_CAN","nomearquivo":"RENNER_PORTO_EP_CAN_00511427_VG07.PRO","datainclusao":"2019-03-28","tipoarquivo":"CAN"},{"idecm":"027351731000138_28/03/2019_00000022_ADS","nomearquivo":"RENNER_PORTO_EP_ADS_00000022_VG01.PRO","datainclusao":"2019-03-28","tipoarquivo":"ADS"},{"idecm":"027351731000138_28/03/2019_00511427_CAN","nomearquivo":"RENNER_PORTO_EP_CAN_00511427_VG07.PRO","datainclusao":"2019-03-28","tipoarquivo":"CAN"},{"idecm":"027351731000138_28/03/2019_00000022_ADS","nomearquivo":"RENNER_PORTO_EP_ADS_00000022_VG01.PRO","datainclusao":"2019-03-28","tipoarquivo":"ADS"},{"idecm":"027351731000138_28/03/2019_00511427_CAN","nomearquivo":"RENNER_PORTO_EP_CAN_00511427_VG07.PRO","datainclusao":"2019-03-28","tipoarquivo":"CAN"},{"idecm":"027351731000138_28/03/2019_00000022_ADS","nomearquivo":"RENNER_PORTO_EP_ADS_00000022_VG01.PRO","datainclusao":"2019-03-28","tipoarquivo":"ADS"},{"idecm":"027351731000138_28/03/2019_00511427_CAN","nomearquivo":"RENNER_PORTO_EP_CAN_00511427_VG07.PRO","datainclusao":"2019-03-28","tipoarquivo":"CAN"},{"idecm":"027351731000138_28/03/2019_00000022_ADS","nomearquivo":"RENNER_PORTO_EP_ADS_00000022_VG01.PRO","datainclusao":"2019-03-28","tipoarquivo":"ADS"},{"idecm":"027351731000138_28/03/2019_00511427_CAN","nomearquivo":"RENNER_PORTO_EP_CAN_00511427_VG07.PRO","datainclusao":"2019-03-28","tipoarquivo":"CAN"},{"idecm":"027351731000138_28/03/2019_00000022_ADS","nomearquivo":"RENNER_PORTO_EP_ADS_00000022_VG01.PRO","datainclusao":"2019-03-28","tipoarquivo":"ADS"},{"idecm":"027351731000138_28/03/2019_00511427_CAN","nomearquivo":"RENNER_PORTO_EP_CAN_00511427_VG07.PRO","datainclusao":"2019-03-28","tipoarquivo":"CAN"},{"idecm":"027351731000138_28/03/2019_00000022_ADS","nomearquivo":"RENNER_PORTO_EP_ADS_00000022_VG01.PRO","datainclusao":"2019-03-28","tipoarquivo":"ADS"},{"idecm":"027351731000138_28/03/2019_00511427_CAN","nomearquivo":"RENNER_PORTO_EP_CAN_00511427_VG07.PRO","datainclusao":"2019-03-28","tipoarquivo":"CAN"},{"idecm":"027351731000138_28/03/2019_00000022_ADS","nomearquivo":"RENNER_PORTO_EP_ADS_00000022_VG01.PRO","datainclusao":"2019-03-28","tipoarquivo":"ADS"},{"idecm":"027351731000138_28/03/2019_00511427_CAN","nomearquivo":"RENNER_PORTO_EP_CAN_00511427_VG07.PRO","datainclusao":"2019-03-28","tipoarquivo":"CAN"},{"idecm":"027351731000138_28/03/2019_00000022_ADS","nomearquivo":"RENNER_PORTO_EP_ADS_00000022_VG01.PRO","datainclusao":"2019-03-28","tipoarquivo":"ADS"},{"idecm":"027351731000138_28/03/2019_00511427_CAN","nomearquivo":"RENNER_PORTO_EP_CAN_00511427_VG07.PRO","datainclusao":"2019-03-28","tipoarquivo":"CAN"},{"idecm":"027351731000138_28/03/2019_00000022_ADS","nomearquivo":"RENNER_PORTO_EP_ADS_00000022_VG01.PRO","datainclusao":"2019-03-28","tipoarquivo":"ADS"},{"idecm":"027351731000138_28/03/2019_00511427_CAN","nomearquivo":"RENNER_PORTO_EP_CAN_00511427_VG07.PRO","datainclusao":"2019-03-28","tipoarquivo":"CAN"}]}');

        if(ArquivoECMTO != null){
            this.fireNotification('Sucesso', 'Consulta realizada com sucesso!', 'success');
        }else{
            this.fireNotification('Sucesso', 'Consulta realizada com sucesso mas sem resultado para esse filtro!', 'success');
        }

        console.log(ArquivoECMTO.data);

        component.set('v.arquivos',ArquivoECMTO.data);
        */

        // let action = component.get("c.buscarDominioSf");
        //
        // action.setCallback(this, (response) => {
        //   let state = response.getState();
        //   console.log('Estado da busca de dominio',state);
        //
        //   if(state == "SUCCESS"){
        //     component.set('v.dominio', response.getReturnValue());
        //     console.log(response.getReturnValue());
        //     //this.buscarCodigoDocumento(component, event);
        //
        //   } else if(state == "ERROR"){
        //     console.log(response.getError());
        //     alert('Error in calling server side action buscarDominioSf: ' + response.getError());
        //   }
        // });

        let consultarArquivoECMTO = component.get('v.ConsultarArquivoECMTO');
        console.log('Envio dos dados para o Serviço = ' + JSON.stringify(consultarArquivoECMTO))


        let callback = (ArquivoECMTOString) => {
            console.log(ArquivoECMTOString);
            let ArquivoECMTO = JSON.parse(ArquivoECMTOString);
            if(ArquivoECMTO != null){
                this.fireNotification('Sucesso', 'Consulta realizada com sucesso!', 'success');
            }else{
                this.fireNotification('Sucesso', 'Consulta realizada com sucesso mas sem resultado para esse filtro!', 'success');
            }

            component.set('v.arquivos',ArquivoECMTO.data);
        };

        this.chamarController(component, 'consultarArquivoECM', {'consultarArquivoECMTOString' : JSON.stringify(consultarArquivoECMTO)}, callback);



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

        //var spinner = component.find("mySpinner");
        //$A.util.toggleClass(spinner, "slds-hide");
        console.log('params = ' + JSON.stringify(params));

        if(component){
            let apexCall = component.get('c.' + method);
            apexCall.setParams(params);
            apexCall.setCallback(this, (response) => {
                var state = response.getState();
                console.log('estado da chamada', state);
                if (state === "SUCCESS") {
                    //$A.util.toggleClass(spinner, "slds-hide");
                    callback(response.getReturnValue());
                    console.log('response.getReturnValue() = ' + JSON.stringify(response.getReturnValue()));
                }else{
                    //$A.util.toggleClass(spinner, "slds-hide");
                    this.fireNotification('Erro', 'Ocorreu um problema. Contate o adminstrador.', 'error');
                };
            });

            $A.enqueueAction(apexCall);
        } else {
            console.log('this Exception: Component access not granted. Please initialize it.');
        }
    },

    validar : function (component) {
        let corpo = component.get('v.ConsultarArquivoECMTO');

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

        var numeroDiasPeriodo = this.datediff(this.parseDate(corpo.dataInicial), this.parseDate(corpo.dataFinal));
        if (numeroDiasPeriodo > 60){
            listMensagens.push('O número de dias do período não pode ser maior que 60 dias. Você está selecionando ' + numeroDiasPeriodo + ' dias, por favor, diminua o período.');
        }

        component.set( 'v.erros', listMensagens );

        if( listMensagens.length > 0 ){
            return false;
        }

        return true;

    },

    downloadArquivoECMHelper : function(component, event) {
        var ctarget = event.currentTarget; 
        var id_str = ctarget.dataset.value;

        console.log('id_str' + id_str);

        // Verifica se o idecm eh um id de arquivo ou uma chave de busca
        if (id_str.includes('_')){
            // Realiza a busca do id do arquivo pela chave de busca
            let codigoECM = id_str;
            console.log('idEcm = ' + id_str)

            let callback = (retornoBuscaIdECM) => {
                console.log('retornoBuscaIdECM = ' + retornoBuscaIdECM);
                let BuscaIdECM = retornoBuscaIdECM;
                if(BuscaIdECM != null){
                    this.fireNotification('Sucesso', 'ID ECM Gerado com sucesso!', 'success');
                    // Realiza o download do arquivo
                    console.log('dominio = ' , component.get('v.dominio'));

                    component.set('v.idecm', BuscaIdECM);
                    component.set('v.realizarDownload',true);
                    console.log('idecm = ' , component.get('v.idecm'));
                    console.log('realizarDownload = ' , component.get('v.realizarDownload'));
                }else{
                    this.fireNotification('Sucesso', 'ID ECM não foi encontrado !', 'success');
                }

                //component.set('v.arquivos',BuscaIdECM.data);
            };

            this.chamarController(component, 'buscaIdECM', {'codigoECMString' : JSON.stringify(codigoECM)}, callback);

        }else{
            // Realiza o download do arquivo
            console.log('dominio = ' , component.get('v.dominio'));

            component.set('v.idecm', id_str);
            component.set('v.realizarDownload',true);
            console.log('idecm = ' , component.get('v.idecm'));
            console.log('realizarDownload = ' , component.get('v.realizarDownload'));
        }
    },

    datediff : function(dataInicial, dataFinal) {
        // Take the difference between the dates and divide by milliseconds per day.
        // Round to nearest whole number to deal with DST.
        var umDia = 24 * 60 * 60 * 1000;
        return Math.round(Math.abs(dataFinal.getTime() - dataInicial.getTime())/(umDia));
    },

    parseDate : function(str) {
        // 00 01 02
        // 25/02/2019

        // 00   01 02
        // 2019-02-25
        var mdy = str.split('-');
        return new Date(mdy[0], mdy[1]-1, mdy[2]);
    }

})