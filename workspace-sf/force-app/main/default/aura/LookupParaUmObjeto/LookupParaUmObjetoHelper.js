/**
 * Created by Alessndro Ponte on 11/06/2018.
 */
({
  buscarRegistros:function (component, event, searchText) {
    let sObjectName = component.get('v.sObject');
    if(sObjectName == undefined) return;

    let listFields = [];
    let listFieldsTemp = component.get('v.listFields');
    if(listFieldsTemp == undefined) listFieldsTemp = [];

    listFieldsTemp.forEach((field) =>{
      if(field != 'Id' && field != 'Name' && typeof field === 'string') listFields.push(field);
    });

    let mapFieldsController = component.get('v.mapFieldsController');
    if(mapFieldsController == undefined) mapFieldsController = new Map();

    var action = component.get("c.searchText");
    action.setParams({searchText  : searchText, sObjectName : sObjectName, listFields : listFields, mapFieldsController : mapFieldsController });
    action.setCallback(this, function(response) {
      var state = response.getState();
      console.log(state);
      component.set('v.issearching',false);
      if (state === "SUCCESS") {
        let listResults = response.getReturnValue();
        component.set('v.listResults',listResults);
        if(listResults != undefined && listResults.length > 0) component.set('v.isOpen',true);
      }
      else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " +
                errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  },

  limpaLista : function (component, event) {
    component.set('v.listResults',[]);
    component.set('v.isOpen',false);
    component.set('v.textoPesquisa','');
  },

  limparResultadoEscolhido : function (component, event) {
    component.set('v.value',null);
    this.limpaLista(component,event);

    // Dispara o evento de aplicacao passando um objeto vazio
    var appEvent = $A.get("e.c:LookupParaUmObjetoEvent");
    appEvent.setParams({
      "recordFound" : null,
      "identifier" : component.get('v.identifier')
    });
    appEvent.fire();
  }
})