/**
 * Created by Alessndro Ponte on 21/06/2018.
 */
({
  ResponderPergunta : function (component, event, helper) {
    let wrapperPerguntas = component.get('v.wrapperPerguntas');
    let button = event.currentTarget;
    wrapperPerguntas.perguntaAtiva = wrapperPerguntas.perguntas[button.dataset.index];
    component.set('v.wrapperPerguntas',wrapperPerguntas);
  },

  handleApplicationEvent : function (component, event, helper) {
    var refreshView = event.getParam('isToRefreshView');

    if(refreshView){
      component.set('v.wrapperPerguntas', null);
      component.set('v.vida', null);
    }
  },
  // responderProxima : function (component, event, helper) {
  //   let componentEdit = component.find('questionarioEditComponent');
  //   if(componentEdit != undefined) componentEdit.responderProxima();
  // },

  responderProxima : function (component, event, helper) {
    let questionarioEditComponent = component.find('questionarioEditComponent');
    let wrapperPerguntas = component.get('v.wrapperPerguntas');
    let perguntas = wrapperPerguntas.perguntas;
    if(perguntas == undefined) return;

    // itera as perguntas
    perguntas.some((pergunta)=>{
      let respostas = pergunta.RespostasQuestionario__r;
      if(respostas == undefined) return;

      // procura um pergunta sem resposta
      let achou = false;
      respostas.some((resposta) => {
        if(resposta.Resposta__c == undefined) {
          wrapperPerguntas.perguntaAtiva = pergunta;
          questionarioEditComponent.set('v.wrapperPerguntas', wrapperPerguntas);
          achou = true;
          return true;
        }
      });
      if(achou){return true;}
    });
  }
})