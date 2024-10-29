/**
 * Created by Alessandro Ponte on 30/05/2018.
 */
({
  doInit: function (component, event, helper) {
    helper.buscarGarantiasOrcamento(component,event,helper);
  },

  expandirTudo : function(component,event,helper){
    let sections = component.find('section-action');
    if(sections != undefined){
      sections.forEach((element)=>{
        $A.util.addClass(element, 'section-is-open');
      });
    }
  },

  encolherTudo : function(component,event,helper){
    let sections = component.find('section-action');
    if(sections != undefined) {
      sections.forEach((element) => {
        $A.util.addClass(element, 'section-is-open');
        $A.util.removeClass(element, 'section-is-open');
      });
    }
  },

  switchSection : function (component,event,helper) {
    let button = event.currentTarget;
    let section = button.parentElement.parentElement;
    section.classList.toggle('section-is-open');

  },
  liberar:function(component,event,helper){
    let oportunidade = component.get('v.oportunidade');

    if(!helper.justificativaEstaPreenchida(component,event,helper,oportunidade)){
      return;
    }
    oportunidade.StageName = 'Em aprovação';
    helper.atualizaOportunidade(component,event,helper,oportunidade);
  },

  salvarDescontoAgravo : function(component,event,helper){
    let precificacao = component.get('v.precificacao');

    let listGarantiasParaAtualizar = [];

    if(precificacao.coberturas != undefined) {
      precificacao.coberturas.forEach((cobertura) => {

        let garantiaOrcamento = helper.getGarantiasParaAtualizar(cobertura.escolhaDescontoAgravo, cobertura.valorDescontoAgravo, cobertura, 'GarantiaOrcamento__c');
        if (garantiaOrcamento == undefined) return;
        listGarantiasParaAtualizar.push(garantiaOrcamento);
      });
    }

    if(precificacao.contratantes != undefined) {
      precificacao.contratantes.forEach((contratante) => {

        if(contratante.grupos != undefined) {
          // Itera os grupos para pegar os descontos e agravos do grupo todo
            contratante.grupos.forEach((grupo) => {
            let garantiaGrupoOrcamento = helper.getGarantiasParaAtualizar(grupo.escolhaDescontoAgravo, grupo.valorDescontoAgravo, grupo,'GrupoOrcamento');
            if (garantiaGrupoOrcamento != undefined) listGarantiasParaAtualizar.push(garantiaGrupoOrcamento);

            if (grupo.coberturas != undefined) {

              // itera as coberturas do grupo para pegar os descontos e agravos nas coberturas dos grupos
              grupo.coberturas.forEach((cobertura) => {

                garantiaGrupoOrcamento = helper.getGarantiasParaAtualizar(cobertura.escolhaDescontoAgravo, cobertura.valorDescontoAgravo, cobertura,'GarantiaGrupoOrcamento__c');
                if (garantiaGrupoOrcamento != undefined) listGarantiasParaAtualizar.push(garantiaGrupoOrcamento);

              });
            }
          });
        }
      });
    }

    component.set('v.listGarantiasParaAtualizar',listGarantiasParaAtualizar);
    return helper.atualizarGarantiasDoGrupoDoOrcamento(component,event);
  },

  recusar:function(component,event,helper){
    let oportunidade = component.get('v.oportunidade');

    if(!helper.justificativaEstaPreenchida(component,event,helper,oportunidade)){
      return;
    }

    oportunidade.StageName = 'Recusado';
    helper.atualizaOportunidade(component,event,helper,oportunidade);
  },
  closeToastWarning : function (component, event, helper) {
    let toast = component.find('toastWarning');
    $A.util.addClass(toast, 'slds-hide');
  },
  closeToastSuccess : function (component, event, helper) {
    let toast = component.find('toastSuccess');
    $A.util.addClass(toast, 'slds-hide');
  }
})