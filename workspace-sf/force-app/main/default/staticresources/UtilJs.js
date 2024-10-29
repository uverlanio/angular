const util = {
    processarRetornoAcaoBotao(result) {
        if (result.sucesso) {
            let redirectPadrao = !result.linkRedirecionar;

            if (redirectPadrao)
                sforce.one.back(true);
            else
                sforce.one.navigateToSObject(result.linkRedirecionar); 
        }
        else {
            let mensagemErro = result.erro;
            let arrMensagem = mensagemErro.split('FIELD_CUSTOM_VALIDATION_EXCEPTION,');

            if (arrMensagem.length > 1) {
                mensagemErro = arrMensagem[1].replace(': []', '');
            }
            else {
                mensagemErro = arrMensagem[0];
            }

            alert(mensagemErro);
            sforce.one.back(true);
        }
    }
};

window._util = (function() {

    function planificarObjetos(arr) {
        function step(currentKey, into, target) {
            for (var i in into) {
                if (into.hasOwnProperty(i)) {
                    var newKey = i;
                    var newVal = into[i];
                    
                    if (currentKey.length > 0) {
                        newKey = currentKey + '.' + i;
                    }
                    
                    if (typeof newVal === 'object') {
                        step(newKey, newVal, target);
                    }
                    else {
                        target[newKey] = newVal;
                    }
                }
            }
        }

        var newObj = {};
        step('', arr, newObj);
        return newObj;
    }

    return {
        fecharQuickAction: function() {
            $A.get('e.force:closeQuickAction').fire();
        },
        flatten: function(arr) {
            return planificarObjetos(arr);
        }
    };
}());