({
  inicializar : function(component, event, helper) {
    helper.inicializar(component, event);
  },

  calcular : function(component, event, helper) {
    helper.calcular(component, event, true);
  },

  salvar : function(component, event, helper) {
    helper.salvar(component, event);
  },

  calcularPasso2 : function(component,event,helper){
    var estaSalvo = event.getParam("salvouPrimeiraAba");
    if(estaSalvo)
    helper.calcularPasso2(component,event);
  },

  cancelar : function(component, event, helper) {
    helper.cancelar(component, event);
  },

  alternaTab : function (component, event, helper) {
    let idTab = event.target.id;
    let targetTab = idTab.replace('__item','');

    let listTabItens = component.find('tabItem');
    let listTabContents = component.find('tabContent');

    listTabItens.forEach((element) =>{

      if(targetTab == element.getElement().dataset.target){
        $A.util.addClass(element, 'slds-is-active');
      }else {
        $A.util.addClass(element, 'slds-is-active');
        $A.util.removeClass(element, 'slds-is-active');
      }
    });

    let link = event.currentTarget;
    let section = link.parentElement;
    section.classList.add('slds-is-active');

    listTabContents.forEach((element) =>{
      if(targetTab == element.getElement().id){
        $A.util.addClass(element, 'slds-hide');
        $A.util.removeClass(element, 'slds-hide');
        $A.util.addClass(element, 'slds-show');
      }else {
        $A.util.addClass(element, 'slds-show');
        $A.util.removeClass(element, 'slds-show');
        $A.util.addClass(element, 'slds-hide');
      }

    });

  }
})