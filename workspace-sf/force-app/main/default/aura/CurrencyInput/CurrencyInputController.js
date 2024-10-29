({
    initCurrencyInput : function(component, event, helper) {
        //console.log('initCurrencyInput - Controller Name >> ',component.get('v.nome'));
        helper.formatValue(component,helper);
    },
    strip: function (component, event, helper) {
        helper.stripValue(component, helper);
    },
    formatV: function (component, event, helper) {
        //console.log('formatV - Controller Name >> ', component.get('v.nome'));
        //console.log('formatV - valor gravado', event.currentTarget.value.toString())
        
        let valor = event.currentTarget.value.toString()
        let validarlimite = component.get('v.validarLimite')
        if (validarlimite== true){
            let minimo = component.get('v.limiteMinimo') || null
            let maximo = component.get('v.limiteMaximo') || null

            if (minimo != null && valor && parseFloat(valor) < parseFloat(minimo)) {
                let mensagem = 'Valor ajustado ao Limite Mínimo'
                helper.showToastMessage(mensagem, "neutral", "dismissable");
                valor = minimo.toString()
            } else if (maximo != null && valor && parseFloat(valor) > parseFloat(maximo)) {
                let mensagem = 'Valor ajustado ao Limite Máximo'
                helper.showToastMessage(mensagem, "neutral", "dismissable");
                valor = maximo.toString()
            }
        }
        component.set('v.value', valor.toString())
        
        
        if (valor.toString() == component.get('v.value')){
            helper.formatValue(component, helper);
        }
    },
    formatSimbolo: function (component, event, helper) {
        //console.log('formatSimbolo', event.getParam("value"));
        helper.formatValue(component, helper, event.getParam("value"));
    },
    changeValueTipo: function(component, event,helper){
        //console.log('changeValueTipo')
        let campo = component.get('v.campo')
        let propostaOriginal = component.get('v.propostaOriginal');
        let propostaModificada = component.get('v.propostaModificada');[]

        let oldValue = event.getParam("oldValue")
        let newValue = event.getParam("value")
        let propostaTipo = component.get('v.propostaTipo')
        let valor = component.get('v.value');
        
        if (propostaTipo.changed == campo && propostaTipo[campo] == newValue) {
            //campo atual é o que foi modificado
            let simbolotosave = newValue == 'Porcentagem' ? '%' : propostaOriginal.isoCode
            //console.log('simbolotosave', simbolotosave)
            component.set('v.simbolo', simbolotosave)
            component.set('v.fim', simbolotosave == '%' ? true : false)
            helper.formatValue(component, helper, simbolotosave)
        }

    },
    changeValue: function (component, event, helper){
        let cobertura = component.get('v.cobertura')
        let garantiaDescontoOld = event.getParam("oldValue")
        let garantiaDesconto = event.getParam("value")
        let garantiaDescontoObj = component.get('v.garantiaDesconto')
        
        let propostaOriginal = component.get('v.propostaOriginal');
        let propostaModificada = component.get('v.propostaModificada');
        let valor = component.get('v.value');

        //console.log('garantiaDescontoObj', JSON.stringify(garantiaDescontoObj));
        if (garantiaDescontoObj.changed == cobertura && garantiaDescontoObj[cobertura] == garantiaDesconto){
            //console.log('alterada', garantiaDescontoObj.changed)
            //console.log('cobertura: '+cobertura,'garantiaDescontoOld: '+garantiaDescontoOld,'garantiaDesconto: '+garantiaDesconto)
            
            
            
            let garantiaO;
            let garantiaM;

            
            for (let i in propostaOriginal.garantias) {
                if (propostaOriginal.garantias[i].cobertura == cobertura) garantiaO = propostaOriginal.garantias[i]
            }
            if (!garantiaO) {
                mensagem = 'Garantia nao encontrada (' + garantiaO + ') (' + garantiaM + ')'
                helper.showToastMessage(mensagem, "warning", "dismissable");
                return;
            }

            for (let i in propostaModificada.garantias) {
                if (propostaModificada.garantias[i].cobertura == cobertura){
                    component.set('v.propostaModificada.garantias[' + i + '].tipoDescontoAgravo', garantiaDesconto);
                }
            }

            let validarlimite = component.get('v.validarLimite')
            if (validarlimite == true) {
                let minimo = component.get('v.limiteMinimo') || null
                let maximo = component.get('v.limiteMaximo') || null

                if (minimo != null && valor != null && parseFloat(valor) < parseFloat(minimo)) {
                    let mensagem = 'Valor ajustado ao Limite Mínimo'
                    helper.showToastMessage(mensagem, "neutral", "dismissable");
                    valor = minimo.toString()
                } else if (maximo != null && valor != null && parseFloat(valor) > parseFloat(maximo)) {
                    let mensagem = 'Valor ajustado ao Limite Máximo'
                    helper.showToastMessage(mensagem, "neutral", "dismissable");
                    valor = maximo.toString()
                }
            }


            //validar posteriormente o limite
            //valor = helper.stripNum(component)
            let simbolotosave = garantiaDesconto == 'Porcentagem' ? '%' : garantiaO.isoCode
            //console.log('simbolotosave', simbolotosave)
            component.set('v.simbolo', simbolotosave)
            component.set('v.fim', simbolotosave=='%'?true:false)
            helper.formatValue(component, helper, simbolotosave)
        }



    }
})