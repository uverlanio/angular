/**
 * Created by Alessandro Ponte on 30/05/2018.
 */
({
    buscarGarantiasOrcamento : function(component,event,helper){
        let oportunidadeId = component.get('v.oportunidade').Id;

        let spinner = component.find('spinner');
        $A.util.removeClass(spinner, 'slds-hide');

        var action = component.get("c.buscarGarantiasOrcamento");

        action.setParams({ oportunidadeId : oportunidadeId });

        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            $A.util.addClass(spinner, 'slds-hide');
            if (state === "SUCCESS") {
                let orcamentoTO = JSON.parse((response.getReturnValue()) ? response.getReturnValue() : '');
                component.set('v.precificacao', orcamentoTO.oferta.calculo.precificacao);
                this.buscarAnaliseAtuarial(component,event,helper);
            }
            else if (state === "ERROR") {
                this.showToastWarning(component,event,helper);
                // this.showToast(component,event,helper,'error',component.get('v.erroTenteNovamente'));
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);

    },

    getGarantiasParaAtualizar : function(escolhaDescontoAgravo,valorDescontoAgravo, element,sObjectType){

        if(escolhaDescontoAgravo == '' || escolhaDescontoAgravo == undefined
            && valorDescontoAgravo == '' || valorDescontoAgravo == undefined)return;

        return {'sObjectType':sObjectType,'Id':element.idSf, 'DescontoAgravo__c': escolhaDescontoAgravo, 'Percentual__c': valorDescontoAgravo};
    },

    atualizarGarantiasDoGrupoDoOrcamento : function(component,event){

        return new Promise(function(resolve, reject) {

            let listGarantiasGrupoOrcamento = component.get('v.listGarantiasParaAtualizar');

            let oportunidade = component.get('v.oportunidade');

            if(listGarantiasGrupoOrcamento.length == 0) resolve();

            var action = component.get("c.atualizarGarantiasDoGrupoDoOrcamento");

            action.setParams({ listGarantiasGrupoOrcamento : listGarantiasGrupoOrcamento, oportunidadeId : oportunidade.Id });

            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log(state);
                if (state === "SUCCESS") {
                    let listErros = response.getReturnValue();
                    if(listErros.length > 0){
                        listErros.forEach((erro)=>console.log(erro));
                        reject();
                        // this.showToastWarning(component,event,helper);
                    }else{
                        resolve();
                    }
                }else if (state === "ERROR") {
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
        });
    },

    buscarAnaliseAtuarial : function(component,event,helper){

        let oportunidade = component.get('v.oportunidade');
        if(oportunidade.Payload__c == undefined) return;
        let opp = JSON.parse(oportunidade.Payload__c);
        console.log('opp',opp);
        console.log('oportunidade.Payload__c',oportunidade.Payload__c);
        this.manipulaCalculoTO(component,event,helper,opp);
        if(opp == undefined) return;
        component.set('v.analiseAtuarial',opp.orcamentos[0].oferta.calculo.analiseAtuarial);
    },

    insereNomesNosSeguradosENosGrupos:function(contratantes,mapNomeContratantes,mapGruposDosContratantes){

        console.log('contratantes',contratantes);

        for(let contratante of contratantes){

            let nomeSegurado = mapNomeContratantes.get(contratante.numero);
            contratante.nome = nomeSegurado;

            for(let grupo of contratante.grupos){
                let mapGrupos = mapGruposDosContratantes.get(contratante.numero);
                if(mapGrupos == undefined) return;
                let nomeGrupo = mapGrupos.get(grupo.numero);
                grupo.nome = nomeGrupo;
            }

        }

    },

    atualizaOportunidade : function(component,event,helper,oportunidade){
        let spinner = component.find('spinner');
        $A.util.toggleClass(spinner, 'slds-hide');

        var action = component.get("c.atualizaOportunidade");

        action.setParams({ oportunidade : oportunidade });

        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            $A.util.toggleClass(spinner, 'slds-hide');
            if (state === "SUCCESS") {
                if(response.getReturnValue() == null){
                    this.showToastWarning(component,event,helper);
                }else{
                    this.showToastSuccess(component,event,helper);
                    $A.get('e.force:refreshView').fire();
                }
            }
            else if (state === "ERROR") {
                this.showToastWarning(component,event,helper);
                // this.showToast(component,event,helper,'error',component.get('v.erroTenteNovamente'));
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);

    },

    justificativaEstaPreenchida : function(component,event,helper,oportunidade){
        let MensagemJustificativa = component.find('MensagemJustificativa').getElement();
        MensagemJustificativa.textContent = '';
        if(oportunidade.JustificativasPareceres__c == null || oportunidade.JustificativasPareceres__c.length == 0){
            MensagemJustificativa.textContent = $A.get("$Label.c.JustificativaObrigatoria");
            return false;
        }
        return true;
    },

    showToastSuccess:function(component,event,helper){
        let toast = component.find('toastSuccess');
        $A.util.removeClass(toast, 'slds-hide');
    },

    showToastWarning:function(component,event,helper){
        let toast = component.find('toastWarning');
        $A.util.removeClass(toast, 'slds-hide');
    },

    manipulaCalculoTO : function(component,event,helper,opportunity){
        // Declaracao de mapas
        let mapNomeSegurados = new Map();
        let mapGruposDosSegurados = new Map();

        // Verifica se os objetos existem
        if(opportunity.orcamentos[0].oferta == 'undefined') return;
        if(opportunity.orcamentos[0].solicitacaoOferta == 'undefined') return;

        // itera os segurados na solicitacao de oferta para pegar o seus nomes e os nomes dos seus grupos
        opportunity.orcamentos[0].solicitacaoOferta.contratantes.forEach(contratante => {
            mapNomeSegurados.set(contratante.numero,contratante.pessoa.nome);

            contratante.grupos.forEach((grupo,index,array) =>{
                let mapNomeGrupos = mapGruposDosSegurados.get(contratante.numero);
                if(mapNomeGrupos == undefined) mapNomeGrupos = new Map();
                mapNomeGrupos.set(grupo.numero,grupo.nome);
                mapGruposDosSegurados.set(contratante.numero,mapNomeGrupos);
            });
        });

        // itera os segurados na precificacao da oferta para inserir seus nomes e os nomes dos seus grupos
        this.insereNomesNosSeguradosENosGrupos(opportunity.orcamentos[0].oferta.calculo.precificacao.contratantes,mapNomeSegurados,mapGruposDosSegurados);

        // itera os segurados na analise da oferta para inserir seus nomes e os nomes dos seus grupos
        this.insereNomesNosSeguradosENosGrupos(opportunity.orcamentos[0].oferta.calculo.analiseAtuarial.contratantes,mapNomeSegurados,mapGruposDosSegurados);
        component.set('v.calculoTO',opportunity.orcamentos[0].oferta.calculo);

    },
})