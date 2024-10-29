({
    formatValue : function(component, helper,simb) {
        //return;
        //TRATAMENTO DE VALORES
        let valor = component.get('v.value')
        if (valor == null || valor == '' || valor == undefined || valor==0) return;
        if (isNaN(valor)){
            let rg = new RegExp(/[^\d,-]/g)
            valor = valor.trim().replace(rg, '').replace(',', '.')
        }else{
            valor = valor.toString().trim().replace(',', '.')
        }
        let casasdecimais = parseFloat(component.get('v.casasdecimais'))
        let milhar = component.get('v.milhar')
        let fim = component.get('v.fim')
        let simbolo =''
        if (simb != null && simb !== undefined)
            simbolo = simb
        else
            simbolo = component.get('v.simbolo')

        //console.log('casasdecimais: '+casasdecimais, 'milhar: '+milhar,'fim: '+fim,'simbolo: '+simbolo)
        
        if(casasdecimais>0){
            valor = (parseFloat(valor)*100 / Math.pow(10, casasdecimais)).toFixed(casasdecimais)
        }
        
        if (milhar==true) valor = this.addCommas(valor)

        if (fim==true){
            valor+= ' '+simbolo
        }else{
            valor = simbolo+' '+valor
        }

        component.set('v.value', valor)
        //console.log('formatValue - valor gravado', valor)
    },

    addCommas : function(nStr) {
        var numero = nStr.split('.')
        numero[0] = numero[0].split(/(?=(?:...)*$)/).join('.').replace('-.', '-')
        return numero.join(',');
    },

    stripValue : function(component){
        let valor = component.get('v.value')
        if (valor == null || valor == '' || valor == undefined || valor == 0) return;
        let rg = new RegExp(/[^\d,-]/g)
        valor = valor.toString().replace(rg, '')
        component.set('v.value', valor)
        //console.log('stripValue - valor gravado', valor)
    },
    stripNum : function(valor){
        if (valor == null || valor == '' || valor == undefined || valor == 0) return;
        let rg = new RegExp(/[^\d,-]/g)
        valor = valor.toString().replace(rg, '')
        return valor;
    },

    showToastMessage: function (message, type, mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "message": message,
            "type": type,
            "mode": mode,
            "duration": $A.get('$Label.c.ToastDefaultDuration')
        });

        toastEvent.fire();

    },
})