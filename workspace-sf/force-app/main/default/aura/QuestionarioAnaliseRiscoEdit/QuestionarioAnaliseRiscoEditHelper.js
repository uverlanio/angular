/**
 * Created by Alessndro Ponte on 26/06/2018.
 */
({
  salvarRespostas : function (component, event,respostas) {

    // let respostas = component.get('v.listRespostas');
    this.toggleSpinner(component,event,true);
    //
    // let respostasTemp = JSON.stringify(respostas);
    // respostas = JSON.parse(respostasTemp);


    if(respostas == undefined) return;

    respostas.forEach((resposta) => {
      delete resposta.attributes;
      resposta.sobjectType = 'RespostaQuestionario__c';
    });

    console.log('respostas');
    console.log(respostas);

    var action = component.get("c.salvarRespostaQuestionario");
    action.setParams({ listRespostas : respostas});

    action.setCallback(this, function(response) {
      var state = response.getState();
      console.log(state);
      this.toggleSpinner(component,event,false);
      if (state === "SUCCESS") {
        if(response.getReturnValue().length > 0){
          this.refreshView(component,event,true);
          this.toastModal(component,event,'Questionário salvo com sucesso', true,'success');
        }else {
          this.toastModal(component,event,'Erro! Por favor tente novamente', false,'error');
        }
      }
      else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " +
                errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
        this.toastModal(component,event,'Erro! Por favor tente novamente', false,'error');
      }
    });
    $A.enqueueAction(action);
  },

  toggleSpinner: function(component,event,boolean){
    var appEvent = $A.get("e.c:QuestionarioAnaliseRiscoEvent");
    appEvent.setParams({
      "isToOpenSpinner" : boolean });
    appEvent.fire();
  },

  refreshView: function(component,event,boolean){
    var appEvent = $A.get("e.c:QuestionarioAnaliseRiscoEvent");
    appEvent.setParams({
      "isToRefreshView" : boolean });
    appEvent.fire();
  },

  toastModal : function (component,event,message, isShow, type) {
    var appEvent = $A.get("e.c:QuestionarioAnaliseRiscoEvent");
    appEvent.setParams({
      "textToast" : message,
      "typeToast" : type,
      "isToOpenToast" : isShow
    });
    appEvent.fire();
  }
})