/**
 * Created by Alessandro Ponte on 19/06/2018.
 */
({
  doInit:function (component, event, helper) {
    Promise.all([
      helper.buscarVidas(component,event),
      helper.buscarPerguntasQuestionario(component,event)
    ]).then(values => {
          helper.montaHierarquiaDados(component,event,...values);
        }
    );
  },

  openModal : function(component,event,helper){
    component.set('v.isOpenModal', true);
  },

  handleApplicationEvent : function (component, event, helper) {
    var isToOpenSpinner = event.getParam("isToOpenSpinner");
    var isToRefreshView = event.getParam('isToRefreshView');
    var isToOpenToast = event.getParam('isToOpenToast');
    var textToast = event.getParam('textToast');
    var typeToast = event.getParam('typeToast');

    let toastModal = component.find('toastModal');

    // Spinner
    let spinner = component.find('spinner');
    if(isToOpenSpinner && spinner != undefined) $A.util.removeClass(spinner, 'slds-hide');
    else if(!isToOpenSpinner && spinner != undefined) $A.util.addClass(spinner, 'slds-hide');

    // RefreshView
    if(isToRefreshView) component.inicializar();


    // Toast
    if(toastModal != undefined && isToOpenToast) {
      component.set('v.textToast',textToast);
      component.set('v.typeToast',typeToast);
      toastModal.showToast();
    }
    else if(toastModal != undefined && !isToOpenToast) {
      toastModal.hiddenToast();
    }

  },

  closeQuickAction : function (component,event,helper){
    var dismissActionPanel = $A.get("e.force:closeQuickAction");
    dismissActionPanel.fire();
  },

  expand : function (component, event, helper) {
    let parentElement = event.currentTarget.parentElement;
    let isExpanded =(parentElement.getAttribute("aria-expanded") == 'true');
    parentElement.setAttribute("aria-expanded", !isExpanded);
  },
  selectVida: function (component, event, helper) {
    let element = event.currentTarget.dataset.hierarquia;
    let indices = element.split(':');

    let listSegurado = component.get('v.listSeguradoProposta');
    let vida = listSegurado[indices[0]].grupos[indices[1]].VidasProposta__r[indices[2]];

    component.set('v.wrapperAtivo',vida.perguntas);
    component.set('v.vidaAtiva',vida);
  }
})