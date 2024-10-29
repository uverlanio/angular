({
  //Busca os field sets de acordo com o produto relacionado a oportunidade
  buscarCamposProduto : function(component, event) {
    let spinner = component.find('spinner');
    $A.util.toggleClass(spinner, 'slds-hide');

    let action = component.get("c.buscarFieldSetProduto");
    let oportunidade = component.get("v.oportunidade");
    let campos = component.get("v.campos");

    if(oportunidade.Produto__r){

      action.setParams({
        codigoProduto : oportunidade.Produto__r.ProductCode,
        objeto: 'Opportunity'
      });

      action.setCallback(this, (response) => {
        let state = response.getState();

        if(state == "SUCCESS"){
          let campos = JSON.parse(response.getReturnValue());
          let camposColuna1 = component.get("v.camposColuna1");
          let camposColuna2 = component.get("v.camposColuna2");
          let camposColuna3 = component.get("v.camposColuna3");
          let contador = 0;

          while(true){
            contador++;
            if(campos[contador - 1] != undefined){
              campos[contador - 1].dbRequired = true;
              camposColuna1.push(campos[contador - 1]);
            }
            else
              break;

            contador++;
            if(campos[contador - 1] != undefined){
              campos[contador - 1].dbRequired = true;
              camposColuna2.push(campos[contador - 1]);
            }
            else
              break;

            contador++;
            if(campos[contador - 1] != undefined){
              campos[contador - 1].dbRequired = true;
              camposColuna3.push(campos[contador - 1]);
            }
            else
              break;
          }
        
          //component.set("v.campos", campos);
          component.set("v.camposColuna1", camposColuna1);
          component.set("v.camposColuna2", camposColuna2);
          component.set("v.camposColuna3", camposColuna3);
          $A.util.toggleClass(spinner, 'slds-hide');
        } else if(state == "ERROR"){
          console.log(response.getError());
        }
      });

      $A.enqueueAction(action);
    }
    else{
      alert('Produto não encontrado');
      $A.get("e.force:closeQuickAction").fire();
    }
  },

  validarCamposObrigatorios: function(component, event){
    let campos = event.getParam("fields");

    let mapCampos = new Map(Object.entries(campos));

    //Verifca se os campos foram preenchidos
    for(let key in campos){

      if(key == 'MultiploSalarial__c' && campos[key] == undefined || campos[key] == ''){

        let tipoCalculo = mapCampos.get('TipoCalculo__c');

        if(tipoCalculo == 'Múltiplo'){

          component.find("ToastParaModal").showToast();
          this.disparaEventoDeConfirmacao(component,event,false);
          return false;
        }

      }else if(!campos[key]){
        component.find("ToastParaModal").showToast();
        this.disparaEventoDeConfirmacao(component,event,false);
        return false;
      }
    }

    component.find("formComplemento").submit();
    this.disparaEventoDeConfirmacao(component,event,true);
  },

  disparaEventoDeConfirmacao:function(component,event, estaSalvo){
    var appEvent = $A.get("e.c:ComplementoOrcamentoEvent");
    appEvent.setParams({
      "salvouPrimeiraAba" : estaSalvo });
    appEvent.fire();

  },

  //Busca os field sets de acordo com o produto relacionado a oportunidade
  // buscarCamposProdutoConta : function(component, event) {
  //       let action = component.get("c.buscarFieldSetProduto");
  //       let oportunidade = component.get("v.oportunidade");

  //       action.setParams({
  //             codigoProduto : oportunidade.Produto__r.ProductCode,
  //             objeto: 'Account'
  //       });

  //       action.setCallback(this, (response) => {
  //             let state = response.getState();

  //             if(state == "SUCCESS"){
  //                   let camposConta = JSON.parse(response.getReturnValue());
  //                   let camposContaColuna1 = component.get("v.camposContaColuna1");
  //                   let camposContaColuna2 = component.get("v.camposContaColuna2");
  //                   let camposContaColuna3 = component.get("v.camposContaColuna3");
  //                   let contador = 0;

  //                   while(true){
  //                         contador++;
  //                         if(camposConta[contador - 1] != undefined){
  //                               camposContaColuna1.push(camposConta[contador - 1]);
  //                         }
  //                         else
  //                               break;

  //                         contador++;
  //                         if(camposConta[contador - 1] != undefined){
  //                               camposContaColuna2.push(camposConta[contador - 1]);
  //                         }
  //                         else
  //                               break;

  //                         contador++;
  //                         if(camposConta[contador - 1] != undefined){
  //                               camposContaColuna3.push(camposConta[contador - 1]);
  //                         }
  //                         else
  //                               break;
  //                   }

  //                   component.set("v.camposConta", camposConta);
  //                   component.set("v.camposContaColuna1", camposContaColuna1);
  //                   component.set("v.camposContaColuna2", camposContaColuna2);
  //                   component.set("v.camposContaColuna3", camposContaColuna3);
  //             } else if(state == "ERROR"){
  //                   console.log(response.getError());
  //                 alert('Conjunto de campos não cadastrados para o produto deste orçamento. Não será possível realizar o Complemento.');
  //             }
  //       });

  //       $A.enqueueAction(action);
  // }
})