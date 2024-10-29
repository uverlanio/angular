/**
 * Created by Alessndro Ponte on 18/01/2019.
 */
({
    fecharModal : function (component, event, helper) {
        component.set('v.ehVisivel' , false);
    },
    popularSelect : function (component, event, helper) {

        let inputStatus = component.find("InputSelectStatus");

        var opts = [
            { "class": "optionClass", label: "Pendente", value: "PENDENTE" },
            { "class": "optionClass", label: "Inadimplente", value: "INADIMPLENTE" },
            { "class": "optionClass", label: "A faturar", value: "A FATURAR" }
        ];
        inputStatus.set("v.options", opts);
    },

    atualizarParcelaContratoController : function (component, event, helper) {

        let parcela = component.get('v.parcela');
        let callback = function(response){
            $A.get('e.force:refreshView').fire();

            helper.showToast('Sucesso!', 'Parcela atualizada com sucesso.', 'success');

            // atualiza os dados do componente pai
            helper.atualizarComponentEvent(component);

            // fecha o modal
            component.set('v.ehVisivel' , false);
        }

        helper.requestFromServer(component, 'atualizarParcelaContrato', { id:parcela.id, status:parcela.status }, callback)

    }
})