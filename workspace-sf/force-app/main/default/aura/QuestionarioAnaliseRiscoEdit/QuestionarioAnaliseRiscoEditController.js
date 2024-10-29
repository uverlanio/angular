/**
 * Created by Alessndro Ponte on 20/06/2018.
 */
({
  perguntaAnterior : function (component, event, helper) {
    let wrapperPergunta = component.get('v.wrapperPerguntas');
    wrapperPergunta.perguntaAnterior();
    component.set('v.wrapperPerguntas',wrapperPergunta);

  },
  proximaPergunta : function (component, event, helper) {
    let wrapperPergunta = component.get('v.wrapperPerguntas');
    wrapperPergunta.proximaPergunta();
    component.set('v.wrapperPerguntas',wrapperPergunta);
  },

  salvarRespostas:function (component, event, helper) {
    let perguntas = component.get('v.wrapperPerguntas').perguntas;

    if(perguntas == undefined) return;

    let respostas = [];

    perguntas.forEach((element) =>{
      let respostaTemp = element.RespostasQuestionario__r;
      if(respostaTemp[0].Resposta__c == undefined) return;
      respostas.push(respostaTemp[0]);
    });

    if(respostas.length > 0)
      component.set('v.listRespostas',respostas);
      helper.salvarRespostas(component,event,respostas);
  },

  limparAlteracoes : function (component, event, helper) {
    helper.refreshView(component,event,true);
  },
})