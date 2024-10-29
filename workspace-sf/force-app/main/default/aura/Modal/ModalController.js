/**
 * Created by Alessndro Ponte on 20/06/2018.
 */
({
  openModal : function(component,event,helper){
    component.set('v.isOpenModal', true);
  },

  closeModal : function(component,event,helper){
    component.set('v.isOpenModal', false);
  },
})