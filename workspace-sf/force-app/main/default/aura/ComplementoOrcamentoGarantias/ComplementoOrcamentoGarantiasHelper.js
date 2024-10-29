({

    //Busca as garantias de um produto
    buscarGarantias: function(component, event){
        let oportunidade =  component.get('v.oportunidade');
        let produtoId = oportunidade.Produto__c;
        if(produtoId == undefined) return;
        let action = component.get("c.buscarGarantiasProdutos");

        action.setParams({
            produtoId
        });

        action.setCallback(this, (response) => {
            let state = response.getState();

            if(state == "SUCCESS"){
                component.set("v.garantias", response.getReturnValue());

                //Após bucar garantias, busca os contratantes
                this.buscarContratantes(component, event);

            } else if(state == "ERROR"){
                console.log(response.getError());
                alert('Error in calling server side action: ' + response.getError());
            }
        });

        $A.enqueueAction(action);
    },

    //Busca os segurados do orçamento
    buscarContratantes: function(component, event){
        let oportunidade =  component.get('v.oportunidade');
        let action = component.get("c.buscarContratantesOrcamento");
        let garantias = component.get("v.garantias");

        action.setParams({
            oportunidadeId : oportunidade.Id
        });

        action.setCallback(this, (response) => {
            let state = response.getState();

            if(state == "SUCCESS"){
                let contratantes = response.getReturnValue();
                let contratantesWrapper = [];
                let mapContratanteIdPorGrupoId = component.get("v.mapContratanteIdPorGrupoId");

                //Gera wrapper com os segurados e grupos
                for(let contratante of contratantes){
                    contratantesWrapper.push(
                        this.gerarWrapperContratante(contratante, garantias, mapContratanteIdPorGrupoId)
                    );
                }

                component.set("v.contratantes", contratantesWrapper);
            } else if(state == "ERROR"){
                console.log(response.getError());
                alert('Error in calling server side action: ' + response.getError());
            }
        });

        $A.enqueueAction(action);
    },

    //Gera wrapper com o conteúdo
    gerarWrapperContratante: function(contratante, garantias, mapContratanteIdPorGrupoId){
        let grupos = contratante.GruposOrcamento__r;

        //Gera as opções de grupos usadas pelas combos
        let gerarOptionsGrupos = (grupos) =>{
            let grupoOptions = [];

            if(!grupos) return grupoOptions;

            grupoOptions.push({
                label : "-- Selecionar --",
                value : ''
            });

            //Gera os grupos de um segurado, e também realiza mapeamento de grupo X segurado
            for(let grupo of grupos){
                mapContratanteIdPorGrupoId[grupo.Id] = contratante.Id;

                grupoOptions.push({
                    label : grupo.Name,
                    value : contratante.Id + "|" + grupo.Id
                });
            }

            return grupoOptions;
        };

        return  {
            id: contratante.Id,
            nome: contratante.Conta__r.Name,
            opcaoEdicao: "grupo",
            grupoOptions: [...gerarOptionsGrupos(grupos)],
            garantiasGrupos: [...this.gerarGarantiasGrupos(garantias, grupos)],
            grupoSelecionado: {},
            grupoSelecionadoId: "",
            grupoSelecionadoVidaId: null,
            tipoEdicao: "grupo"
        };

    },

    //Gera as garantias de um grupo a partir das garantias de um produto.
    gerarGarantiasGrupos: function(garantias, grupos) {
        let garantiasGrupos = [];

        if(!grupos) return garantiasGrupos;

        for(let grupo of grupos){
            let garantiasGrupoOrcamento = [];

            for(let garantia of garantias){
                garantiasGrupoOrcamento.push(this.gerarObjetoGarantiaGrupoOrcamento(grupo.Id, garantia, false));
            }

            garantiasGrupos.push({
                id: grupo.Id,
                premioTotal: grupo.PremioComercial__c,
                mergeOK: false,
                garantias: garantiasGrupoOrcamento
            });
        }

        return garantiasGrupos;
    },

    //Gera as garantias de um grupo a partir das garantias de um produto.
    gerarGarantiasSegurados: function(garantias, grupos) {
        let garantiasGrupos = [];

        if(!grupos) return garantiasGrupos;

        for(let grupo of grupos){
            let garantiasSeguradoOrcamento = [];

            for(let garantia of garantias){
                garantiasSeguradoOrcamento.push(this.gerarObjetoGarantiaSeguradoOrcamento(grupo.Id, garantia));
            }

            garantiasGrupos.push({
                id: grupo.Id,
                premioTotal: grupo.PremioComercial__c,
                mergeOK: false,
                garantias: garantiasSeguradoOrcamento
            });
        }

        return garantiasGrupos;
    },

    //Gera objeto de GarantiaGrupoOrcamento__c de acordo com as informações da garantia de produto e tambem das garantias do orçamento existentes. TODO: FAZER MERGE COM A GARANTIAS DO ORCAMENTO
    gerarObjetoGarantiaGrupoOrcamento : function(grupoId, garantiaProduto){
        let garantiaGrupoOrcamento = {
            Id: null,
            Capital__c: 0.00,
            PremioComercial__c: 0.00,
            GrupoOrcamento__c: grupoId,
            GarantiaProduto__c: garantiaProduto.Id,
            Garantia__c : garantiaProduto.Garantia__c,
            sobjectType : 'GarantiaGrupoOrcamento__c',
        };

        return {
            nome: garantiaProduto.Garantia__r.Name,
            chave: (grupoId + garantiaProduto.Id),
            selecionado : false,
            garantiaGrupo : garantiaGrupoOrcamento
        };
    },

    //Gera objeto de GarantiaContratanteOrcamento__c de acordo com as informações da garantia de produto e tambem das garantias do orçamento existentes. TODO: FAZER MERGE COM A GARANTIAS DO ORCAMENTO
    gerarObjetoGarantiaSeguradoOrcamento : function(seguradoId, garantiaProduto){
        let garantiaSeguradoOrcamento = {
            Id: null,
            Capital__c: 0.00,
            PremioComercial__c: 0.00,
            ContratanteOrcamento__c: seguradoId,
            GarantiaProduto__c: garantiaProduto.Id,
            Garantia__c : garantiaProduto.Garantia__c,
            sobjectType : 'GarantiaContratanteOrcamento__c',
        };

        return {
            nome: garantiaProduto.Garantia__r.Name,
            chave: (seguradoId + garantiaProduto.Id),
            selecionado : false,
            garantiaGrupo : garantiaSeguradoOrcamento
        };
    },

    //Seleciona uma garantia para ser utilizada em um grupo ou vida
    escolherGarantia : function(component, event) {
        let contratantes = component.get("v.contratantes");
        let chaveGarantiaEscolhida = event.currentTarget.dataset.chave;
        let contratanteId = event.currentTarget.dataset.contratanteid;

        for(let contratante of contratantes){
            if(contratante.id == contratanteId){
                for(let garantia of contratante.grupoSelecionado.garantias){
                    if(garantia.chave == chaveGarantiaEscolhida){
                        garantia.selecionado = !garantia.selecionado;
                    }
                }
            }
        }

        component.set("v.contratantes", contratantes);
    },

    //Seleciona grupo escolhido na combo de grupos
    selecionarGrupo : function(component, event) {
        let contratantes = component.get("v.contratantes");
        let valores = event.getParam("value").split("|");
        let contratanteId = valores[0];
        let grupoId = valores[1];

        for(let contratante of contratantes){
            if(contratante.id == contratanteId){

                //Se for tipo Vidas, não gera garantias de grupos
                if(contratante.tipoEdicao == "segurados"){
                    contratante.grupoSelecionadoVidaId = {};
                    contratante.grupoSelecionadoVidaId['GrupoOrcamento__c'] = grupoId;
                    contratante.grupoSelecionado = {
                        id: "",
                        garantias: []
                    }

                    component.set("v.contratantes", contratantes);
                    break;
                }

                for(let garantiaGrupo of contratante.garantiasGrupos){
                    if(garantiaGrupo.id == grupoId){
                        contratante.grupoSelecionado = garantiaGrupo;

                        //Busca as garantias do orçamento do grupo, e realiza merge com as garantias do produto
                        this.realizarMergeGarantiasGrupoOrcamento(component, contratantes, contratante.grupoSelecionado);
                        break;
                    }
                }
            }
        }
    },

    limparGrupoVidaSelecionado : function(event){
        console.log(event.getParam("value"));

        // segurado.grupoSelecionadoVidaId = {};
        // segurado.grupoSelecionadoVidaId['GrupoOrcamento__c'] = grupoId;
        // segurado.grupoSelecionado = {
        //   id: "",
        //   garantias: []
        // }

        // component.set("v.contratantes", segurados);
    },

    //Remove grupo selecionado quando se alterna entre os tipos Grupo e segurado através de radio button
    alterarTipoEdicao : function(component, event) {
        let contratanteId = event.getSource().get("v.name");
        let contratantes = component.get("v.contratantes");

        for(let contratante of contratantes){
            if(contratante.id == contratanteId){
                contratante.grupoSelecionadoVidaId = null;
                contratante.grupoSelecionadoId = "";
                contratante.grupoSelecionado = {garantias: []};
                contratante.tipoEdicao = event.getSource().get("v.value");
                break;
            }
        }

        component.set("v.contratantes", contratantes);
    },

    //Gera as garantias de um segurado
    gerarGarantiasSegurado : function(component, event, segurado) {
        let contratantes = component.get("v.contratantes");
        let garantias = component.get("v.garantias");
        let mapContratanteIdPorGrupoId = component.get("v.mapContratanteIdPorGrupoId");
        let contratanteId = mapContratanteIdPorGrupoId[segurado.GrupoOrcamento__c];

        //Encontra o contratante e verifica se há já existe segurado (grupoSelecionado) na estrutura
        for(let contratante of contratantes){
            if(contratante.id == contratanteId){
                let garantiaGrupoSegurado = null;

                for(let garantiaGrupo of contratante.garantiasGrupos){
                    if(garantiaGrupo.id == segurado.Id){
                        garantiaGrupoSegurado = garantiaGrupo;
                    }
                }

                //Se ainda não existe, então criar garantias
                if(garantiaGrupoSegurado == null){
                    let garantiasGrupoSegurado = this.gerarGarantiasSegurados(garantias, [segurado]);
                    contratante.garantiasGrupos.push(garantiasGrupoSegurado[0]);
                    garantiaGrupoSegurado = garantiasGrupoSegurado[0];
                }

                //Seleciona grupo da vida
                contratante.grupoSelecionado = garantiaGrupoSegurado;

                //Busca as garantias do segurado do orcamento, e realiza merge com as garantias do produto
                this.realizarMergeGarantiasSeguradoOrcamento(component, contratantes, contratante.grupoSelecionado);
                break;
            }
        }
    },

    //Realiza merge das garantias do grupo do orçamento gerado em tempo de execução com as que existem no Salesforce para um grupo
    realizarMergeGarantiasGrupoOrcamento: function(component, contratantes, grupoSelecionado){

        let action = component.get("c.buscarGarantiasGrupoOrcamento");

        //Realiza merge apenas se não foi feito ainda
        if(!grupoSelecionado.mergeOK){
            action.setParams({
                grupoId : grupoSelecionado.id
            });

            action.setCallback(this, (response) => {
                let state = response.getState();

                if(state == "SUCCESS"){
                    let garantiasOrcamento = response.getReturnValue();

                    //Varre todas as garantias do orçamento de um grupo/segurado e verifica se há relação com as garantias do produto exibidas no componente
                    for(let garantiaOrc of garantiasOrcamento){
                        for(let garantia of grupoSelecionado.garantias){
                            if(garantia.garantiaGrupo.GarantiaProduto__c == garantiaOrc.GarantiaProduto__c){
                                garantia.garantiaGrupo.Id = garantiaOrc.Id;
                                garantia.garantiaGrupo.Capital__c = garantiaOrc.Capital__c;
                                garantia.garantiaGrupo.PremioComercial__c = garantiaOrc.PremioComercial__c;
                                garantia.selecionado = true;
                                grupoSelecionado.mergeOK = true;
                            }
                        }
                    }

                    component.set("v.contratantes", contratantes);
                } else if(state == "ERROR"){
                    console.log(response.getError());
                    alert('Error in calling server side action: ' + response.getError());
                }
            });

            $A.enqueueAction(action);
        }else{
            component.set("v.contratantes", contratantes);
        }
    },

    //Realiza merge das garantias do grupo do orçamento gerado em tempo de execução com as que existem no Salesforce para um segurado
    realizarMergeGarantiasSeguradoOrcamento: function(component, contratantes, seguradoSelcionado){

        let action = component.get("c.buscarGarantiasSeguradoOrcamento");

        //Realiza merge apenas se não foi feito ainda
        if(!seguradoSelcionado.mergeOK){
            action.setParams({
                seguradoId : seguradoSelcionado.id
            });

            action.setCallback(this, (response) => {
                let state = response.getState();

                if(state == "SUCCESS"){
                    let garantiasOrcamento = response.getReturnValue();

                    //Varre todas as garantias do orçamento de um grupo/vida e verifica se há relação com as garantias do produto exibidas no componente
                    for(let garantiaOrc of garantiasOrcamento){
                        for(let garantia of seguradoSelcionado.garantias){
                            if(garantia.garantiaGrupo.GarantiaProduto__c == garantiaOrc.GarantiaProduto__c){
                                garantia.garantiaGrupo.Id = garantiaOrc.Id;
                                garantia.garantiaGrupo.Capital__c = garantiaOrc.Capital__c;
                                garantia.garantiaGrupo.PremioComercial__c = garantiaOrc.PremioComercial__c;
                                garantia.selecionado = true;
                                seguradoSelcionado.mergeOK = true;
                            }
                        }
                    }

                    component.set("v.contratantes", contratantes);
                } else if(state == "ERROR"){
                    console.log(response.getError());
                    alert('Error in calling server side action: ' + response.getError());
                }
            });

            $A.enqueueAction(action);
        }else{
            component.set("v.contratantes", segurados);
        }
    },

    //Gera estrutura de objeto que o accordeon entenda
    gerarGarantiaGrupoProposta: function(garantias){
        return {
            garantias: garantias
        };
    },

    //Prepara os objetos para serem salvos
    salvarGarantias: function(component, event){
        let contratantes = component.get("v.contratantes");
        let garantiasGrupoOrcamentoUpsert = [];
        let garantiasGrupoOrcamentoDelete = [];

        //Separa os registros que devem ser salvos e os que devem ser excluídos
        for(let contratante of contratantes){
            for(let grupo of contratante.garantiasGrupos){
                if(grupo.garantias){
                    for(let garantiaGrupo of grupo.garantias){
                        if(garantiaGrupo.selecionado){
                            garantiasGrupoOrcamentoUpsert.push(garantiaGrupo.garantiaGrupo);
                        }
                        else if(garantiaGrupo.garantiaGrupo.Id != null){
                            garantiasGrupoOrcamentoDelete.push(garantiaGrupo.garantiaGrupo);
                        }
                    }
                }
            }
        }

        // let prom = new Promise(function(resolve, reject) {
        //   resolve();
        // });

        // //Caso existam registros para serem
        // if(garantiasGrupoOrcamentoUpsert.length > 0 || garantiasGrupoOrcamentoDelete.length > 0){
        //   prom = this.salvarDados(component, garantiasGrupoOrcamentoUpsert, garantiasGrupoOrcamentoDelete);
        // }

        // return prom;

        console.log('garantiasGrupoOrcamentoUpsert ------------------- ',garantiasGrupoOrcamentoUpsert);
        console.log('garantiasGrupoOrcamentoDelete ------------------- ',garantiasGrupoOrcamentoDelete);

        return this.salvarDados(component, garantiasGrupoOrcamentoUpsert, garantiasGrupoOrcamentoDelete);
    },

    //Realiza DML dos dados
    salvarDados: function(component, garantiasGrupoOrcamentoUpsert, garantiasGrupoOrcamentoDelete) {
        console.log('Salvar aba garantias gerar promise');

        return new Promise(function(resolve, reject) {
            console.log('Salvar aba garantias...');
            let action = component.get("c.salvarDadosAbaGarantias");

            action.setParams({
                garantiasOrcamentoUpsert: garantiasGrupoOrcamentoUpsert,
                garantiasOrcamentoDelete: garantiasGrupoOrcamentoDelete
            });

            action.setCallback(this, (response) => {
                let state = response.getState();

                if(state == "SUCCESS"){
                    console.log('Aba garantias saved!');
                    resolve();
                } else if(state == "ERROR"){
                    console.log('Aba garantias erro!');
                    alert('Error in calling server side action: ' + response.getError());
                }
            });

            $A.enqueueAction(action);

        });
    },

    limparVidaLookup : function (component, event, idLookup) {
        let listCmpLookups = component.find(idLookup);

        if(listCmpLookups == undefined) return;

        if(listCmpLookups.length > 0) {

            listCmpLookups.forEach((lookup) => {
                lookup.limparResultadoEscolhido();
            });
        }else{
            listCmpLookups.limparResultadoEscolhido();
        }
    }

})