/**
 * Created by Alessndro Ponte on 11/07/2018.
 */
({
  doInit : function (component, event, helper) {
    helper.doInitHelper(component,event);
  },
  adicionar:function (component, event, helper) {
    let list = component.get('v.listWrapper');
    let element = event.currentTarget;
    let index = element.parentElement.dataset.indexwrapper;
    list[index].listRemuneracaoProposta.push(helper.criarRemuneracaoProposta(component,event, list[index]));
    component.set('v.listWrapper',list);
  },

  excluir : function (component, event, helper) {
    let list = component.get('v.listWrapper');
    let element = event.currentTarget;
    let index = element.parentElement.dataset.index;
    let indexWrapper = element.parentElement.dataset.indexwrapper;
    if(index == undefined || indexWrapper == undefined) return;

    let listaParaApagar = component.get('v.listRemuneracoesParaApagar');
    listaParaApagar = JSON.parse(JSON.stringify(listaParaApagar));

    let remuneracaoProposta = list[indexWrapper].listRemuneracaoProposta[index];
    delete remuneracaoProposta.controle;

    if(remuneracaoProposta.Id != undefined) listaParaApagar.push(remuneracaoProposta);
    list[indexWrapper].listRemuneracaoProposta.splice(index,1);

    if(list[indexWrapper].listRemuneracaoProposta.length == 0)
      list[indexWrapper].listRemuneracaoProposta.push(helper.criarRemuneracaoProposta(component,event,list[indexWrapper]));

    component.set('v.listWrapper',list);
    component.set('v.listRemuneracoesParaApagar',listaParaApagar);
  },
  handleApplicationEvent : function(component, event,helper) {
    let identifier = event.getParam("identifier");

    let hierarquiaIndice = identifier.split(':');

    let list = component.get('v.listWrapper');
    let remuneracaoProposta = list[hierarquiaIndice[0]].listRemuneracaoProposta[hierarquiaIndice[1]];

    // Verifica se limpou o lookup de conta
    if(remuneracaoProposta.Conta__r == undefined) {

      delete remuneracaoProposta.Conta__c;
      delete remuneracaoProposta.Papel__c;
      delete remuneracaoProposta.controle.opcoesPapel;

    }else{
      helper.criarOpcoesPapel(component,event,remuneracaoProposta);
    }

    component.set('v.listWrapper',list);

  },

  salvarRemuneracoes : function (component, event,helper) {
    helper.salvarRemuneracoes(component,event);

  }
})