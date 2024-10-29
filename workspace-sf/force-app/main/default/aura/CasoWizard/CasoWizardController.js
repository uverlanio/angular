({
    doInit : function(component, event, helper) {
      component.set('v.mMessage', {error: [], success: [], warning: [], info: []});
      helper.validapreenchimentos(component,event,helper);            
    },

    selecionaCheckbox : function (component, event, helper) {
  		console.log('component',component);
      let current = event.currentTarget
      let valor = current.dataset.value
      let checked = event.currentTarget.checked
      let selecionados = component.get('v.garantiaSelected');
      
      let listadados = component.get("v.listadados");
      let siglagarantia = valor.split('--')[0];
      let selecionadosPrices = component.get('v.garantiaSelectedPrices');

      let items = [];
      items = items.concat(component.find("garantiasprices"));
      
      if(checked){
          if(!selecionados.includes(valor)){
              selecionados.push(valor);               
          }
      }
      else{
          let index = selecionados.indexOf(valor);
          if (index > -1) {
              //selecionados.splice(index, 1);
          }
          //PLV-4176 - inicio
          let index2 = selecionadosPrices.map(function(e) { return e.valor; }).indexOf(valor);
          if (index2 > -1) {
              //selecionadosPrices.splice(index2, 1);
          }            
          //PLV-4176 - fim  
          console.log('selecionadosPrices',selecionadosPrices);  
      }
      for(let i in listadados){
          if(listadados[i].sigla==siglagarantia)
              listadados[i].selecionado= checked==true || false;
      }
      console.log('listadados2',[].concat(listadados));  
      component.set("v.listadados",[].concat(listadados));

    
    },
    //PLV-4938 - FIM

    //PLV-4176 - inicio
    selecionaPrice : function (component, event, helper) {
      helper.selecionaPrice(component, event, helper);      
    },
    //PLV-4176 - inicio
    
    voltarTela: function(component) {
      //PLV-4789 INICIO
      component.set('v.garantiaSelected', [])
      //PLV-4789 FIM
      console.log(component.get('v.tela'));
      var tela = component.get('v.tela');
      if(tela > 1){
        component.set('v.tela', String(tela-1));
      }
      else{
        $A.get("e.force:closeQuickAction").fire();
      }
    },

    voltarBox: function (component) {
       $A.get("e.force:closeQuickAction").fire(); 
    },

    avancar: function (component, event, helper) {
      helper.avancarTela(component,event,helper);
    },
    
    mostrarMais : function(component, event, helper){
      helper.mostrarMaiss(component,event,helper);
    },

    mostrarMaisCasos : function(component, event, helper){
      helper.mostrarMaissCasos(component,event,helper);
    }   
  })