({

    fireNotification: function(title, message, type, duration, mode){
        if(mode == undefined) mode = 'dismissible';
        var notification = $A.get("e.force:showToast");
        notification.setParams({
            type: type,
            title: title,
            mode: mode,
            duration: duration ? duration : 10,
            message: message
        });
        notification.fire();
    },

	cancelar: function(component) {
		$A.get("e.force:closeQuickAction").fire();	
	},
    
    //PLV-4270 - INÍCIO
	inicializar: function( component, event, helper ) {
		var action = component.get('c.obterPerfil');
		action.setCallback(this, (response) => {
			var state = response.getState();
			var retorno = response.getReturnValue();
            console.log( 'retorno: ', retorno );
			if( state == "SUCCESS" ) {
            	var tiposEndosso = [];
				var perfil = retorno;
            	console.log( 'perfil: ', perfil );
            	if( perfil == 'Atendimento' ){ //PLV-5794 INICIO/FIM
                    tiposEndosso = [
                        {'label': 'Cancelamento de apólice por desistência do segurado', 'value': 'DES'},// FCVEP-38 - INICIO
                        {'label': 'Cancelamento de apólice por arrependimento do segurado', 'value': 'ARR'},
						{'label': 'Cancelamento de apólice para reemissão', 'value': 'REE'}, //II-179 - INICIO/FIM
						{'label': 'Cancelamento por emissão indevida', 'value': 'EMI'} //II-179 - INICIO/FIM // FCVEP-38 - FIM 
                    ];
        		} else {
                    tiposEndosso = [
                        {'label': 'Cancelamento de apólice por inadimplência', 'value': 'INA'},// FCVEP-38 - INICIO
                        {'label': 'Cancelamento de apólice por sinistro', 'value': 'SIN'},
                        {'label': 'Cancelamento de apólice a pedido do Segurado', 'value': 'DES'},
                        {'label': 'Cancelamento de apólice por arrependimento do segurado', 'value': 'ARR'},
                        {'label': 'Cancelamento de apólice por iniciativa da seguradora', 'value': 'ISG'},
						{'label': 'Cancelamento de apólice para reemissão', 'value': 'REE'}, //II-179 - INICIO/FIM
						{'label': 'Cancelamento por emissão indevida', 'value': 'EMI'} //II-179 - INICIO/FIM // FCVEP-38 - FIM 
                    ];
        		}
            
				component.set( 'v.tiposEndosso', tiposEndosso );
            
            	var tiposEndosso2 = component.get( 'v.tiposEndosso' );
            	console.log( 'tiposEndosso: ', tiposEndosso2 );
			} else {
            	console.log( 'state: ', state );
			}
		});
		$A.enqueueAction(action);
	},
    //PLV-4270 - FIM

	//PLV-4678 - Inicio
	/*
	//PLV-3872 - INICIO - PEDRO AUGUSTO -SYS4B
	setOferta: function(component,event) {
		component.set('v.selectedOferta',event.currentTarget.dataset.oferta);
		this.toggleBtnSalvar(component);
	},
	*/ 
	//PLV-4678 - Fim

	limparValues: function(component,event) {
		if(event){
			component.set('v.selectedEndosso',event.getParam("value"))
		}
		component.set('v.selectedOferta','')
		component.set('v.retorno','');
		component.set('v.disableSalve',true);
		//component.set('v.dataToShow',[]); //PLV-4678 Inicio/Fim
	},



	calcular: function (component, event, helper) {
		//RESET PARA EVITAR BUGS
		this.limparValues(component);
		//this.toggleBtnSalvar(component); //PLV-4678 Inicio/Fim

		let tipoEndossoSel = component.find('cboTipoEndosso').get('v.value');
		
		if (tipoEndossoSel != ''){
			component.set("v.visivel", false);
			component.set('v.retorno','');
			helper.toggleSpinner(component);
			let dataCancelamento = component.get('v.dataCancelamento');

			console.log(dataCancelamento);
			debugger;
			var action = component.get("c.gerarOrcamentoEndosso");

			action.setParams({
				idContrato: component.get('v.recordId'),
				tipoEndosso: tipoEndossoSel,
				dataCancelar: dataCancelamento
			});

			console.log('dataCancelamento', dataCancelamento)
			action.setCallback(this, (response) => {
                debugger;
                console.log('retorno servico'+response.getReturnValue());
				var state = response.getState();
				var data = JSON.parse(response.getReturnValue()) || null;
				console.log('state: ', state);
				console.log('data: ', data);
				if (state == "SUCCESS") {
					if(data.message){
                		
						this.fireNotification('Cancelar Contrato', data.message, 'warning');
						$A.get("e.force:closeQuickAction").fire();
					}
					else if(data.data == null){
                		
						this.fireNotification('Cancelar Contrato','Nenhum calculo retornado, contate o administrador do sistema.', 'error');
					} else if(data.data.ofertas){
						component.set("v.visivel", true);
						component.set('v.retorno', data);
						//PLV-4678 - Inicio
						//for (let x = 0; x < data.data.ofertas.length; x++) {
							//component.set("v.dataToShow[" + x + "]", data.data.ofertas[x].orcamento); 
						//}	
						
						if(data.data.ofertas[0].orcamento != null){
							component.set('v.dataToShow', data.data.ofertas[0].orcamento);
							this.toggleBtnSalvar(component);
						}
						
						//PLV-4678 - Fim
					}

				} else if (state == "ERROR") {
					//component.set("v.visivel", true);
					debugger;
					this.fireNotification('Cancelar Contrato', 'Não foi possivel cancelar o contrato, contate o administrador do sistema.', 'error');
				}

				helper.toggleSpinner(component);

			});

			$A.enqueueAction(action);

		}else{
			this.fireNotification('Alerta','Selecione tipo de Endosso','warning');
		}
	},


	salvar: function(component, event, helper) {

		helper.toggleSpinner(component);

		var numeroOrcamentoComp = component.get('v.dataToShow').numeroOrcamento; //PLV-4678 - Inicio/Fim

		console.log(numeroOrcamentoComp);

		var action = component.get('c.gerarPropostaEndosso');

		action.setParams({
			numeroOrcamento: numeroOrcamentoComp,
			// PLV-4606-FIX INICIO
			idContrato: component.get('v.recordId'),
			dataCancel: component.get('v.dataCancelamento')
			// PLV-4606-FIX FIM
		});
		console.log('Rogerio aqui: ');
		action.setCallback(this, (response) => {
			var state = response.getState();
			console.log('Rogerio state: ', state);
			console.log('retorno henrique: ',JSON.parse(response.getReturnValue()) );
			var retorno = JSON.parse(response.getReturnValue());
			//console.log('retorno ', retorno);
            // deugger;
			if(state == "SUCCESS"){
				if(retorno.message){
					this.fireNotification('Cancelar Contrato', 'Um erro inesperado aconteceu. Por favor, contate o administrador do sistema.', 'error');
				}
				else{
					location.reload();
				}
			} else {
				this.fireNotification('Cancelar Contrato', 'Não foi possivel cancelar o contrato, contate o administrador do sistema.', 'error');
			}

			helper.toggleSpinner(component);
		});
		$A.enqueueAction(action);

	},
	//PLV-4678 - Inicio
	toggleBtnSalvar: function (component) {
		let disableSalve = false;
		component.set('v.disableSalve', disableSalve);
	},
	//PLV-4678 - Fim
	//PLV-3872 - FIM - PEDRO AUGUSTO -SYS4B
	toggleSpinner : function (component){
		let spinner = component.find("mySpinner");
		$A.util.toggleClass(spinner, "slds-hide");
	}


})