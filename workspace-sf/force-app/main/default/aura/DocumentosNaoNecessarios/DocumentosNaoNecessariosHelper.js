({
	//Busca dados do produto do canal a ser editado
	carregarProdutoCanal : function(component, event) {
		let action = component.get("c.buscarProdutoCanal");

		action.setParams({
			produtoCanalId: component.get('v.recordId')
		});

        action.setCallback(this, (response) => {
            let state = response.getState();
            
            if(state == "SUCCESS"){
            	component.set('v.produtoCanal', response.getReturnValue());
            	this.buscarDocumentos(component, event);            	
            } 
            else if(state == "ERROR"){
            	console.log(response.getError());
                alert('Error in calling server side action: ' + response.getError());
            }
        });
               
        $A.enqueueAction(action);
	},

	//Encontra os documentos do produto, e separa de acordo com o tipo
	buscarDocumentos : function(component, event) {
		let action = component.get("c.buscarDocumentosProduto");
		let produtoCanal = component.get("v.produtoCanal");

		//Sepera os documentos escolhidos no produto do canal
		let documentosEscolhidosEntrada = produtoCanal.DocumentosNaoNecessariosEntrada__c != undefined ? produtoCanal.DocumentosNaoNecessariosEntrada__c.split(";") : [];
		let documentosEscolhidosSaida = produtoCanal.DocumentosNaoNecessariosSaida__c != undefined ? produtoCanal.DocumentosNaoNecessariosSaida__c.split(";") : [];

		action.setParams({
			produtoId: produtoCanal.Produto__c
		});

		action.setCallback(this, (response) => {
            let state = response.getState();
            
            if(state == "SUCCESS"){
            	let documentos = response.getReturnValue();
            	let documentosEntrada = [];
            	let documentosSaida = [];

            	//Separa os documentos do produto de acordo com o tipo
            	for(let doc of documentos){
            		if(doc.Documento__c){
            			if(doc.Tipo__c == 'Entrada'){
            				documentosEntrada.push({
            					label: doc.Documento__c,
            					value: doc.Documento__c,
            					selected: documentosEscolhidosEntrada.includes(doc.Documento__c)
            				});
            			}
            			else{
            				documentosSaida.push({
            					label: doc.Documento__c,
            					value: doc.Documento__c,
            					selected: documentosEscolhidosSaida.includes(doc.Documento__c)
            				});
            			}
            		}
            	}

            	component.set('v.documentosEntrada', documentosEntrada);
            	component.set('v.documentosSaida', documentosSaida);
            } 
            else if(state == "ERROR"){
            	console.log(response.getError());
                alert('Error in calling server side action: ' + response.getError());
            }
        });
               
        $A.enqueueAction(action);
	},

	//Salva as informações alteradas
	salvar : function(component, event) {
		let action = component.get("c.salvarProdutoCanal");

		action.setParams({
			produtoCanal: component.get('v.produtoCanal')
		});

        action.setCallback(this, (response) => {
            let state = response.getState();
            
            if(state == "SUCCESS"){
            	$A.get('e.force:refreshView').fire();
            	this.cancelar();
            } 
            else if(state == "ERROR"){
            	console.log(response.getError());
                alert('Error in calling server side action: ' + response.getError());
            }
        });
               
        $A.enqueueAction(action);
	},

	//Retorna para a página de edição
	cancelar : function() {
		$A.get("e.force:closeQuickAction").fire();
	}
})