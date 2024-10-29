({
	//Busca a oportunidade
	buscarOportunidade : function(component, event) {
        
        let action = component.get("c.burcarOportunidadePorRoteamentoId");
        action.setParams({
            routerId : event.getParam("workItemId")
        });
        
        action.setCallback(this, (response) => {
           
            let state = response.getState();
            
            if(state == "SUCCESS"){
                let oportunidade = response.getReturnValue();
                console.log( oportunidade );

                component.set("v.Oportunidade", oportunidade);    
                component.set("v.isOpeningAnRoute",true);   
                
                this.closeFocusedTab(component, event);
                this.openTab(component, event);
            	
            } else if(state == "ERROR"){
            	console.log(response.getError());
                alert('Error in calling server side action: ' + response.getError());
            }
            
        });

        $A.enqueueAction(action);  
       
    },

    openTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            recordId: component.get("v.Oportunidade").AccountId,
            focus: true
        }).then(function(tabId) {
            //Altera a fase e abre sub tab de oportunidade
            //this.alterarFaseAguardandoAnalise(component.get("v.Oportunidade").Id, response, workspaceAPI, component);

            let action = component.get("c.atualizarOportunidade");

            action.setParams({
                    oportunidade: {
                        Id : component.get("v.Oportunidade").Id,
                        StageName: 'Em análise',
                        sobjectType: 'Opportunity'
                    }
                }
            );

            action.setCallback(this, (response) => {
                let state = response.getState();
                
                if(state == "SUCCESS"){
                    workspaceAPI.openSubtab({
                        parentTabId: tabId,
                        recordId: component.get("v.Oportunidade").Id
                    });
                } else if(state == "ERROR"){
                    alert('Error in calling server side action: ' + response.getError());
                }
            });

            $A.enqueueAction(action);  

        })
        .catch(function(error) {
               console.log(error);
        });
    },

    // //Altera fase da oportunidade para aguardando analise
    // alterarFaseAguardandoAnalise : function(idOportunidade, responseOpenTab, workspaceAPI, component) {
    //     let action = component.get("c.atualizarOportunidade");
    //     action.setParams({
    //             oportunidade: {
    //                 Id : idOportunidade,
    //                 StageName: 'Aguardando análise',
    //                 sobjectType: 'Opportunity'
    //             }
    //         }
    //     );

    //     action.setCallback(this, (response) => {
    //         let state = response.getState();
            
    //         if(state == "SUCCESS"){
    //             workspaceAPI.openSubtab({
    //                 parentTabId: responseOpenTab,
    //                 recordId: idOportunidade
    //             });
    //         } else if(state == "ERROR"){
    //             console.log(response.getError());
    //             alert('Error in calling server side action: ' + response.getError());
    //         }
    //     });

    //     $A.enqueueAction(action);  
    // },

    closeFocusedTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    }
    
	
})