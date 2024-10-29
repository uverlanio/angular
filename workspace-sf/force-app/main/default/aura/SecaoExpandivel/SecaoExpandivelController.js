/**
 * Created by Alessndro Ponte on 20/06/2018.
 */
({

  expand : function(compponent,event,helper){
    component.set('v.isOpen', true);
  },

  collapse : function(compponent,event,helper){
    component.set('v.isOpen', false);
  },

  switchAttributeSection : function (component, event, helper) {
    let isOpen = component.get('v.isOpen');
    component.set('v.isOpen', !isOpen);
  }
})