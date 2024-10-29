/**
 * Created by Alessndro Ponte on 14/06/2018.
 */
({
  hiddenToast : function (component, event, helper) {
    let toast = component.find('toastParaModal');
    $A.util.addClass(toast, 'slds-hide');
  },

  showToast:function(component,event,helper){
    let toast = component.find('toastParaModal');
    $A.util.removeClass(toast, 'slds-hide');
  },
})