/**
 * Created by Alessndro Ponte on 19/06/2018.
 */
({
  buscarVidas : function(component,event){
    return new Promise($A.getCallback(function(resolve, reject) {

      let quoteId = component.get('v.recordId');

      var action = component.get("c.buscarListVidaProposta");
      action.setParams({ quoteId : quoteId });

      action.setCallback(this, function(response) {
        var state = response.getState();
        console.log(state);
        if (state === "SUCCESS") {
          resolve(response.getReturnValue());
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
          reject();
        }
      });
      $A.enqueueAction(action);
    }));
  },

  buscarPerguntasQuestionario : function(component,event,helper){
    return new Promise($A.getCallback(function(resolve, reject) {

      let quoteId = component.get('v.recordId');

      var action = component.get("c.buscarPerguntas");
      action.setParams({ quoteId : quoteId});

      action.setCallback(this, function(response) {
        var state = response.getState();
        console.log(state);
        if (state === "SUCCESS") {
          if(response.getReturnValue() != undefined){
            resolve(JSON.parse(response.getReturnValue()));
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
          reject();
        }
      });
      $A.enqueueAction(action);
    }));

  },

  montaHierarquiaDados : function(component,event,listVidaProposta,listWrapperPerguntas){

    if(listVidaProposta == undefined) return;

    // Declaracao de mapas
    let mapListGruposPropostaPorSegurado = new Map();
    let mapSeguradosPropostaPorSegurado = new Map();
    let mapListVidaPropostaPorGrupo = new Map();

    // populaMapas
    listVidaProposta.forEach((vida) => {
      vida.perguntas = this.buildWrapperQuestion(component, event, listWrapperPerguntas, vida);

      // Popula o mapa da vida
      let listVidaProposta = mapListVidaPropostaPorGrupo.get(vida.GrupoProposta__c);
      if (listVidaProposta == undefined) listVidaProposta = [];
      listVidaProposta.push(vida);
      mapListVidaPropostaPorGrupo.set(vida.GrupoProposta__c, listVidaProposta);

      // Popula o mapa dos grupos
      let listGrupoProposta2 = mapListGruposPropostaPorSegurado.get(vida.GrupoProposta__r.ContratanteProposta__c);
      if (listGrupoProposta2 == undefined) listGrupoProposta2 = [];
      listGrupoProposta2.push(vida.GrupoProposta__r);
      mapListGruposPropostaPorSegurado.set(vida.GrupoProposta__r.ContratanteProposta__c, listGrupoProposta2);

      // Popula o mapa dos segurados
      mapSeguradosPropostaPorSegurado.set(vida.GrupoProposta__r.ContratanteProposta__c, vida.GrupoProposta__r.ContratanteProposta__r);
    });

    let listSegurados = [];

    // monta estrutura
    for (let [key, segurado] of mapSeguradosPropostaPorSegurado) {
      segurado.grupos = mapListGruposPropostaPorSegurado.get(key);

      if(segurado.grupos != undefined){
        segurado.grupos.forEach((grupo) => {
          grupo.VidasProposta__r = mapListVidaPropostaPorGrupo.get(grupo.Id);
        });
      }

      listSegurados.push(segurado);
    }

    component.set('v.listSeguradoProposta', listSegurados);
  },

  buildWrapperQuestion : function(component,event,listWrapperPerguntas,vida){
    class WrapperQuestion{
      constructor(){
        this._perguntaAtiva;
        this.respondidas = 0;
        this.total;
        this.haAnterior;
        this.haProxima;
        this._perguntas = this.filtraPerguntas(listWrapperPerguntas,vida);
        this._mapPerguntas;
        this.opcoes;
        this._respostas = new Map();
        this.controlaPerguntas();
      }

      filtraPerguntas(listWrapperPerguntas,vida){

        if(listWrapperPerguntas == undefined) return;

        // Declara variaveis
        let listPerguntas = [];
        let listPerguntas2 = [];
        let map = this._mapPerguntas;
        if(map == undefined) map = new Map();

        // itera as perguntas do questionario
        listWrapperPerguntas.some((wrapper) => {

          // Verifica se tem mais de um questionario
          if (listWrapperPerguntas.length > 1) {
            let garantiasDaVida = vida.GarantiasGrupoProposta__r;
            if (garantiasDaVida == undefined) return;

            garantiasDaVida.some((garantia) => {

              if (wrapper.siglaGarantia != garantia.GarantiaProduto__r.GarantiaProduto__r.Garantia__r.Sigla__c) return false;

              if (garantia.Capital__c >= wrapper.limiteCapitalMinimo && garantia.Capital__c <= wrapper.limiteCapitalMaximo) {
                listPerguntas = wrapper.listPerguntaQuestionario;
                return true;
              }
            });
          }else{
            listPerguntas = wrapper.listPerguntaQuestionario;
          }

          if(listPerguntas.length > 0) return true;
        });

        this.total = listPerguntas.length;

        listPerguntas.forEach((perguntaTemp) => {

          let pergunta = Object.assign({}, perguntaTemp);

          // Cria resposta caso nao haja
          if(pergunta.RespostasQuestionario__r == undefined)
            pergunta.RespostasQuestionario__r = this.criaResposta(pergunta,vida);

          // pega a resposta que for dessa vida
          let respostaDaVida = pergunta.RespostasQuestionario__r;
          if(respostaDaVida.length == undefined) respostaDaVida = pergunta.RespostasQuestionario__r.records;
          if(respostaDaVida == undefined) return;
          
          respostaDaVida = respostaDaVida.filter((resposta) =>{
            if(resposta.SeguradoProposta__c == vida.Id) return resposta;
          });
          

          if(respostaDaVida.length == 0) respostaDaVida = this.criaResposta(pergunta,vida);
          pergunta.RespostasQuestionario__r = respostaDaVida;

          if(respostaDaVida[0].Resposta__c != undefined) this.respondidas++;

          map.set(pergunta.Id,pergunta);
          listPerguntas2.push(pergunta);
        });
        this._mapPerguntas = map;
        return listPerguntas2;
      }

      get perguntaAtiva(){
        return this._perguntaAtiva;
      }
      set perguntaAtiva(pergunta){
        this._perguntaAtiva = pergunta;
        this.controlaPerguntas();
      }

      get perguntas(){
        return this._perguntas;
      }

      proximaPergunta(){
        if(this._perguntaAtiva.ProximaPergunta__c != undefined){
          this._perguntaAtiva = this._mapPerguntas.get(this._perguntaAtiva.ProximaPergunta__c);
        }
        this.controlaPerguntas();
      }
      perguntaAnterior(){
        if( (this._perguntaAtiva - 1) >=  0)
          this._perguntaAtiva--;
        this.controlaPerguntas();
      }

      criaResposta(pergunta,vida){
        return [].concat({
          "sobjectType" : 'RespostaQuestionario__c',
          "PerguntaQuestionario__c" : pergunta.Id,          
          "SeguradoProposta__c" : vida.Id          
        });
      }

      controlaPerguntas(){
        // Verifica se ha pergunta anterior
        this.haAnterior = false;

        // Verifica se ha proxima pergunta
        this.haProxima = false;
        if(this._perguntaAtiva != undefined
            && this._perguntaAtiva.ProximaPergunta__c != undefined){
          this.haProxima = true;
        }

        // Verifica se a pergunta ativa eh uma pergunta de opcoes e montas array de opcoes
        if(this._perguntaAtiva != undefined
            && this._perguntaAtiva.Pergunta__r.TipoResposta__c  == 'Opção' ) {
          this.opcoes = this._perguntaAtiva.Pergunta__r.OpcoesResposta__c.split(';').map((element) => {
            return {'label': element, 'value': element};
          });

        }else{
          this.opcoes = undefined;
        }
      }
    }
    return new WrapperQuestion();
  }
});