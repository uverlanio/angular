/**
 * Created by Alessandro Ponte on 29/05/2018.
 */
({
  doInit : function (component, event, helper) {
    // helper.buildListsTableGroup(component,event,helper);
    helper.parseJSON(component,event,helper);
  },
  splitCalculo : function (component, event, helper) {
    let calculo = component.get('v.calculo');

    if(calculo.preficicacao.coberturas != null)
      helper.buildLstCoberturas(component,event,helper,calculo.preficicacao.coberturas);

  }
})