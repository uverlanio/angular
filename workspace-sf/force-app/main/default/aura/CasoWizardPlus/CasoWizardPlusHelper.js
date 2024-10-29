({
    validapreenchimentos : function(component, event, helper) {
        let recId = component.get('v.recordId');
        let action = component.get('c.validarpreenchimento');
        action.setParams({recordId: recId});
        
        action.setCallback(this, function(response) {
            let state = response.getState();
            
            if (state === 'SUCCESS') {
                let ret = response.getReturnValue();                
                
                if(ret[0] != 'Todos os campos foram preenchidos'){
                    component.set("v.errorInit", response.getReturnValue());
                    component.set('v.etapa', '');                    
                }else if(ret[0] == 'Todos os campos foram preenchidos'){
                    this.reiniciarEtapas(component,event,this);
                }
                
            } else {
                let errors = response.getError();
                if (errors && errors[0] && errors[0].message)
                    component.set("v.errorInit", 'Error, response state: ' + state + errors[0].message);
            }
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
        
    },


    avancarEtapa : function(component, event, helper){
        let etapa = component.get('v.etapa');
        let CasosDuplicados = component.get('v.CasosDuplicados');
        let bypassduplicate = component.get('v.bypassduplicate');
        let recId = component.get('v.recordId');
        let tipoEvento = component.get("v.tipoEventoEscolhido");

        //SE TIVER CASOS DUPLICADOS SOLICITAR CONFIRMAÇÃO DE EXIBIÇÃO
        if(CasosDuplicados && CasosDuplicados!=null && CasosDuplicados.length > 0 && bypassduplicate==false){
            helper.showToastMessage('Assinale que verificou os casos já abertos antes de prosseguir.', "error", "warning")
            component.set("v.showSpinner", false);
            return null;
        }if(bypassduplicate==true) {
            component.set('v.CasosDuplicados',null);
            component.set('v.bypassduplicate',!bypassduplicate);
            etapa = (parseInt(etapa)+1).toString() || etapa;
        }
        //CARREGAR INFORMAÇÕES QUANDO TEVE CASOS DUPLICADOS
        if(etapa =='2' && bypassduplicate){
            helper.pesquisacontratos(component, event, helper);
            return;
        }

        

        if(etapa == '1') {//ETAPA DE SELECIONAR O TIPO DE EVENTO AQUI IRÁ VALIDAR SE FOI PREENCHIDO O CAMPO
            if(!tipoEvento || tipoEvento == ""){
                this.showToastMessage('Selecione um tipo de evento antes de avançar.', "error", "warning")
                component.set('v.showSpinner',false);
                return;
            }else{
                helper.validaDuplicados(component, event, helper)
                //helper.pesquisacontratos(component, event, helper, recId, tipoEvento);//no retorno dessa função deve jogar a etapa para 2 em caso de sucesso
            }
        }else if(etapa == '2') {//ETAPA DE SELEÇÃO DE GARANTIAS - AQUI IRÁ VALIDAR SE TEM AO MENOS UMA SELECIONADA, FAZER UMA VERIFICAÇÃO PREVIA PARA NAO FICAR ENVIANDO PROBLEMAS PARA O BACKEND
            let garantiasOriginais = component.get("v.garantiasOriginais");
            let garantiasModificadas = component.get("v.garantiasModificadas");
            let keysToStrip = ['capital', 'dias', 'franquia']
            garantiasModificadas = this.replaceObject(garantiasModificadas,keysToStrip)
            let garantiasSelecionadas = [];
            let garantiasSelecionadasErro = [];
            let contratos = {};
            let arrcontratos = component.get('v.contratos');
            for (let i in arrcontratos) {
                contratos[arrcontratos[i].id] = arrcontratos[i];      
            }


            //VERIFICAR SE NECESSITA DE CORREÇÕES ANTES DE FAZER A CHAMADA PARA O BACKEND
            for(let i in garantiasModificadas){
                let garantia = garantiasModificadas[i]
                if(garantia.selecionado==true){
                    garantia.franquia = garantia.franquia && typeof garantia.franquia === 'string' ? parseInt(garantia.franquia) : garantia.franquia;
                    garantia.dias = garantia.dias && typeof garantia.dias === 'string' ? parseInt(garantia.dias) : garantia.dias;
                    garantia.capital = garantia.capital && typeof garantia.capital === 'string' ? parseInt(garantia.capital) : garantia.capital;
                    if(garantia.liberardiasfranquia == true && ((!garantia.dias ||garantia.dias==0 || garantia.dia=='') || (!garantia.franquia || garantia.franquia==0||garantia.franquia=='')))
                        garantiasSelecionadasErro.push(garantia)
                    else if(garantia.liberardiasfranquia == true){
                        garantiasSelecionadas.push(garantia)
                    }else if(garantia.liberardiasfranquia == false && garantia.valorfixo==false && (!garantia.capital ||  garantia.capital<=0)){
                        garantiasSelecionadasErro.push(garantia)
                    }else if(garantia.liberardiasfranquia == false && garantia.capital>0){
                        garantiasSelecionadas.push(garantia)
                    }/*else{
                        garantiasSelecionadasErro.push(garantia)
                    }*/
                }
            }

            if(garantiasSelecionadas.length==0 && garantiasSelecionadasErro.length == 0){
                this.showToastMessage('Selecione ao menos uma garantia para poder prosseguir!', "info", "info")
                component.set("v.showSpinner", false);
                return;
            }if(garantiasSelecionadasErro.length>0){
                let contratoxGarantia = {}
                let contratoNum = []
                for(let i in garantiasSelecionadasErro){
                    let garantia = garantiasSelecionadasErro[i]
                    if( contratoxGarantia[garantia.contratoId] == null ) {contratoxGarantia[garantia.contratoId] = []; contratoNum.push(garantia.contratoId);}
                    contratoxGarantia[garantia.contratoId].push(garantia)
                    if(!contratoNum.includes(garantia.contratoId)) contratoNum.push(garantia.contratoId)
                }
                
                let texto = 'Verifique as coberturas abaixo:<br/>';

                for(let i in contratoNum){
                    let idcont = contratoNum[i];
                    texto += 'Contrato: '+contratos[idcont].numero+'<br/>';
                    for(let x in contratoxGarantia[idcont]){
                        let garantia = contratoxGarantia[idcont][x]
                        texto += garantia.sigla + ' - '+garantia.name+'<br/>';
                    }
                    texto +='--------------------<br/>';
                }
                
                component.set("v.showSpinner", false);
                component.set("v.errorInit", texto);
            }else{
                //this.showToastMessage('LIBERADO PARA CRIAR COBERTURAS', "info", "success");
                component.set("v.showSpinner", false);
                
                component.set('v.showConfirmDialog',true);
                component.set('v.confirmDialogMessage', 'Deseja prosseguir com a criação dos sinistros');
                component.set('v.tipoConfirm','salvar');
                return;
            }
              
            
        }
        

        if(bypassduplicate == true){
            component.set('v.bypassduplicate',true);
            component.get('v.CasosDuplicados',null);
        }
    },


    pesquisacontratos : function(component, event, helper) {
        let etapa = component.get('v.etapa');
        let CasosDuplicados = component.get('v.CasosDuplicados');
        let bypassduplicate = component.get('v.bypassduplicate');
        let recId = component.get('v.recordId');
        let tipoEvento = component.get("v.tipoEventoEscolhido");

        let action = component.get('c.pesquisacontratos');
        
        action.setParams({
            recordId: recId,
            tipoEvento: tipoEvento
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === 'SUCCESS') {
                let ret = JSON.parse(response.getReturnValue());
                
                if(ret.retorno && ret.retorno != '') {
                    component.set("v.errorInit", ret.retorno);
                    component.set("v.etapa", '1');
                }else {
                    
                    component.set("v.garantiasOriginais", JSON.stringify(ret.garantias));
                    component.set("v.garantiasModificadas", ret.garantias);
                    component.set("v.contratos", ret.contratos);
                    component.set("v.etapa", '2');
                    
                    if(ret.contratos.length==0){
                        component.set("v.errorInit", 'Não foram encontrados contratos para o tipo de evento');
                        component.set("v.etapa", '1');
                    }
                    if(ret.garantias.length==0){
                        component.set("v.errorInit", 'Não foram encontradas garantias disponíveis');
                        component.set("v.etapa", '1');
                    }
                }                                
            } else {
                let errors = response.getError();
                if (errors && errors[0] && errors[0].message)
                    component.set("v.errorInit", 'Error, response state: ' + state + errors[0].message);
                
            }            
            component.set('v.showSpinner',false);
        });
        $A.enqueueAction(action);
    },

    validaDuplicados : function (component, event, helper){
        let tipoEvento = component.get('v.tipoEventoEscolhido');
        let recId = component.get('v.recordId');
        let etapa = component.get('v.etapa');
        
        let action = component.get('c.validarSinistroDuplicado');
        action.setParams({
            recordId: recId,
            tipoEvento: tipoEvento
        });

        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === 'SUCCESS') {
                let ret = response.getReturnValue();
                
                if(ret == null){
                    component.set("v.errorInit", '');
                    //component.set('v.etapa', '3');
                    //this.showToastMessage('Não existem casos duplicados. Pode prosseguir!', "info", "info")
                    //CONTROLE DE AVANÇO
                    if(etapa==1){
                        helper.pesquisacontratos(component, event, helper);
                        component.set("v.etapa", '2');                    
                    }
                }else{
                    //var Json = JSON.parse(ret); 
                    //console.log('var Json: ', ret);                   
                    component.set("v.CasosDuplicados", ret);
                }
            } else {
                let errors = response.getError();
                if (errors && errors[0] && errors[0].message)
                    component.set("v.errorInit", 'Error, response state: ' + state + errors[0].message);
            }
            component.set('v.showSpinner',false);
        });
        $A.enqueueAction(action);
    },


    prossegueCriacaoSinistro : function (component, event, helper){
        let keysToStrip = ['capital', 'dias', 'franquia']
        let garantiasOriginais = component.get('v.garantiasOriginais');
        let garantiasModificadas = Object.assign(component.get('v.garantiasModificadas'),[]);
        garantiasModificadas = this.replaceObject(garantiasModificadas,keysToStrip)
        let tipoEvento = component.get('v.tipoEventoEscolhido');
        let contratos = component.get('v.contratos');
        let recId = component.get('v.recordId');
        let requestOBJ = {
                        recordId: recId,
                        contratos: contratos,
                        garantiasOriginais: JSON.parse(garantiasOriginais),
                        garantiasModificadas: garantiasModificadas,
                        tipoEvento:tipoEvento
                    }
        
        let action = component.get('c.criaCasoSinistroPlus');
        action.setParams({
            pJSON: JSON.stringify(requestOBJ)
        });

        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === 'SUCCESS'){
                
                let ret = response.getReturnValue();

                if(ret.sucesso==true){
                    this.showToastMessage('Caso(s) criado(s) com sucesso!', "success", "success");
                    
                    component.set('v.saveMessage','Caso(s) criado(s) com sucesso!<br/>Lista de Casos:');
                    component.set('v.casosCriados',ret.casos);
                    component.set('v.etapa','3');
                }else{
                    component.set("v.errorInit", 'Tivemos problemas para criar os casos: <br/>'+ ret.mensagem);
                    component.set('v.etapa','2');
                }
            }else {
                let errors = response.getError();
                if (errors && errors[0] && errors[0].message)
                    component.set("v.errorInit", 'Error, response state: ' + state + errors[0].message);
            }
            component.set('v.showSpinner',false);
        });
        $A.enqueueAction(action);
    },


    showToastMessage: function (message, type, mode) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "message": message,
            "type": type,
            "mode": mode,
            "duration": $A.get('$Label.c.ToastDefaultDuration')
        });

        toastEvent.fire();
    },

    reiniciarEtapas : function(component, event, helper) {
        component.set('v.contratos',[]);
        component.set('v.garantiasOriginais','');
        component.set('v.garantiasModificadas',[]);
        component.set('v.CasosDuplicados',null);
        component.set('v.tipoConfirm','');
        component.set('v.showConfirmDialog',false);
        component.set('v.confirmDialogMessage','');
        component.set('v.errorInit','');
        component.set('v.saveMessage','');
        component.set('v.etapa','1');
        component.set('v.showSpinner',false);
        component.set('v.bypassduplicate',false);
    },
    resetGarantias : function(component, event, helper) {
        let originais = component.get('v.garantiasOriginais');
        component.set('v.garantiasModificadas', JSON.parse(originais));
        component.set('v.showConfirmDialog', false);
    },

    toggleSpinner : function(component){
        var spinner = component.get("v.showSpinner");
        component.set('v.showSpinner',!spinner);
    },

    stripNum: function (valor) {
        //console.log('valor entrada',valor)
        valor = valor!=null && valor!==undefined ? valor.toString().replace('%','').replace('$','').replace(',', '.').replace(/[^\d.,-]/g, '').replace(/(.*)\./, x => x.replace(/\./g, '') + '.').trim(): null;
        //console.log('valor saida',valor)
        return valor
    },

    replaceObject: function (obj, keysToStrip) {
        let type = Array.isArray(obj) ? 'array' : 'object';
        let ObjToReturn = {}
        Object.entries(obj).forEach(([key, value]) => {
            if (typeof obj[key] === 'object' && value != null) {
                if (!Array.isArray(value)) {
                    ObjToReturn[key] = this.replaceObject(obj[key], keysToStrip)
                } else {
                    ObjToReturn[key] = []
                    for (let ent in obj[key]) {
                        let parsed = obj[key][ent]
                        if (!Array.isArray(parsed) && typeof parsed !== 'string')
                            ObjToReturn[key].push(this.replaceObject(parsed, keysToStrip))
                        else
                            ObjToReturn[key].push(keysToStrip.includes(key) ? stripNum(parsed) : parsed)
                    }
                }

            } else {
                if (keysToStrip.includes(key) && value != null) ObjToReturn[key] = this.stripNum(value)
                else ObjToReturn[key] = value
            }
        });
        return type == 'array' ? Object.values(ObjToReturn) : ObjToReturn;
    },
})