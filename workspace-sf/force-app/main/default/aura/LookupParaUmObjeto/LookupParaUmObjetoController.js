/**
 * Created by Alessndro Ponte on 11/06/2018.
 */
({
  realizarPesquisa : function (component, event, helper) {
    let textoPesquisa = component.get('v.textoPesquisa');

    if(textoPesquisa == undefined) return;
    if(textoPesquisa.length == 0) helper.limpaLista(component,event);

    if(textoPesquisa.length > 2) {
      component.set('v.issearching',true);
      helper.buscarRegistros(component, event, textoPesquisa);
    }
  },

  escolheuItem : function (component,event,helper) {
    let item = event.currentTarget;
    let index = item.dataset.index;
    let listResults = component.get('v.listResults');
    component.set('v.value',listResults[index]);

    // Dispara o evento de aplicacao passando o resultado escolhido
    var appEvent = $A.get("e.c:LookupParaUmObjetoEvent");
    appEvent.setParams({
      "recordFound" : listResults[index],
      "identifier" : component.get('v.identifier')
    });
    appEvent.fire();

    helper.limpaLista(component,event);
  },

  limparResultadoEscolhido : function (component, event, helper) {
    helper.limparResultadoEscolhido(component,event);
  }
})