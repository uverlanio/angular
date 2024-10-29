({
	inicializar: function(component, event){
		let chamadasIniciais = [
			this.buscarConta(component), 
			this.buscarServicos(component)
		];

		Promise.all(chamadasIniciais).then(values => { 
		  	this.montarPagina(component);
		});
	},
	
	//Realiza montagem da página permitindo edição dos dados já cadastrados
	montarPagina: function(component) {
		let conta = component.get("v.conta");
		let papeis = conta.Papel__c != undefined ? conta.Papel__c.split(';') : "";
		let dadosBancariosParceiro;
		let dadosBancariosPrestador;
		let dadosBancariosAgenciador;
		//Atribui dados bancarios se houver
		if(conta.InformacoesBancarias__r != undefined)
			for(let dados of conta.InformacoesBancarias__r){
				if(dados.Papel__c == "Parceiro"){
					dadosBancariosParceiro = dados;
				}
				else if(dados.Papel__c == "Prestador"){
					dadosBancariosPrestador = dados;
				}
				else if(dados.Papel__c == "Agenciador"){
					dadosBancariosAgenciador = dados;
				}
			}
			console.log('papeis');
			console.log(papeis);
			console.log('conta.InformacoesBancarias__r');
			console.log(conta.InformacoesBancarias__r);
		//Verifica se já existe algum papel associado a conta
		if(papeis.length > 0){
			let papeisConta = [];

			//Gera linhas com as informações respectivas de cada tipo de papel
			for(let papel of papeis){
				if(papel == "")
					continue;
				
				let novoItem = this.gerarNovoItem(component);
				novoItem.papel = papel;
				novoItem.conta = conta;
				console.log('conta: ', conta);

				//Atribui valores de dados bancarios
				if(novoItem.papel == 'Parceiro'){
					novoItem.bancariosParceiro = dadosBancariosParceiro;
					novoItem.bancoEscolhido = dadosBancariosParceiro != null ? dadosBancariosParceiro.BancoNew__r : null;
					if (novoItem.conta.ServicosParceiro__c){
						this.selecionarItensPickMultiplo(novoItem.opcoesServicosParceiro, novoItem.conta.ServicosParceiro__c.split(';'));
					}
				}
				else if(novoItem.papel == 'Prestador'){
					novoItem.bancariosPrestador = dadosBancariosPrestador;
					novoItem.bancoEscolhido = dadosBancariosPrestador != null ? dadosBancariosPrestador.BancoNew__r : null;
					if (novoItem.conta.ServicosPrestador__c) {
						this.selecionarItensPickMultiplo(novoItem.opcoesServicosPrestador, novoItem.conta.ServicosPrestador__c.split(';'));
					}
				}	
				else if(novoItem.papel == 'Agenciador'){
					novoItem.bancariosAgenciador = dadosBancariosAgenciador;
					novoItem.bancoEscolhido = dadosBancariosAgenciador != null ? dadosBancariosAgenciador.BancoNew__r : null;
				}

				papeisConta.push(novoItem);
			}

			component.set("v.papeisConta", papeisConta);
		}
		else{
			this.adicionarNovo(component);
		}
	},

	selecionarItensPickMultiplo: function(listaValorePick, valores){
		for(let valor of valores){
			for(let objPick of listaValorePick){
				if(objPick.label == valor){
					objPick.selected = true;
				}
			}	
		}
	},

	//Busca a conta referenciada na página
	buscarConta: function(component) {
		return new Promise(function(resolve, reject) {
			var action = component.get("c.buscarContaPapel");

			action.setParams({
				contaId: component.get('v.recordId')
			});

	        action.setCallback(this, (response) => {
	            var state = response.getState();
	            
	            if(state == "SUCCESS"){
	            	//Atualiza atributo para armazenar os valores
	            	component.set("v.conta", response.getReturnValue());
	            	resolve();
	            } else if(state == "ERROR"){
	            	console.log(response.getError());
	                alert('Error in calling server side action: ' + response.getError());
	            }
	        });
	               
	        $A.enqueueAction(action);
        });
	},

	//Busca os serviços dos papéis
	buscarServicos: function(component) {
		return new Promise(function(resolve, reject) {
			var action = component.get("c.buscarServicosPapel");

	        action.setCallback(this, (response) => {
	            var state = response.getState();
	            
	            if(state == "SUCCESS"){
	            	let servicosPapeis = JSON.parse(response.getReturnValue());
	            	let servicosParceiros = [];
	            	let servicosPrestadores = [];

	            	//Gera options de acordo com os papéis
	            	for(let servico of servicosPapeis){
	            		if(servico.Papel__r != undefined && servico.Papel__r.MasterLabel == 'Parceiro'){
	            			servicosParceiros.push({ value: servico.MasterLabel, label: servico.MasterLabel });
	            		}
	            		else{
	            			servicosPrestadores.push({ value: servico.MasterLabel, label: servico.MasterLabel });
	            		}
	            	}

		            component.set('v.servicosPapeisPrestador', servicosPrestadores);
		            component.set('v.servicosPapeisParceiro', servicosParceiros);
		            resolve();
	            } 
	            else if(state == "ERROR"){
	            	console.log(response.getError());
	                alert('Error in calling server side action: ' + response.getError());
	            }
	        });
	               
	        $A.enqueueAction(action);
        });
	},

	adicionarNovo: function(component){
		let papeisConta = component.get('v.papeisConta');
		papeisConta.push(this.gerarNovoItem(component));
		component.set('v.papeisConta', papeisConta);
	},

	gerarNovoItem: function(component){
		let papeisConta = component.get('v.papeisConta');
		let timestamp = (Date.now()) + papeisConta.length;
		let contaId = component.get('v.recordId');
		let servicosPapeisPrestador = component.get('v.servicosPapeisPrestador');
		let servicosPapeisParceiro = component.get('v.servicosPapeisParceiro');

		//let conta = component.get('conta');
		console.log('papeisConta: ', papeisConta);
		console.log('servicosPapeisParceiro: ', servicosPapeisParceiro);

		let conta = {'sobjectType': 'Account', 'Id' : contaId};
		let bancariosPrestador = {'sobjectType': 'InformacaoBancaria__c', 'Papel__c' : 'Prestador', 'Conta__c' : contaId};
		let bancariosParceiro = {'sobjectType': 'InformacaoBancaria__c', 'Papel__c' : 'Parceiro','Conta__c' : contaId};
		let bancariosAgenciador = {'sobjectType': 'InformacaoBancaria__c', 'Papel__c' : 'Agenciador','Conta__c' : contaId};
		let bancoEscolhido = null;
		

		let novoItem = {
			idx: timestamp,
			papel: "",
			conta: conta,
			bancoEscolhido: bancoEscolhido,
			opcoesServicosPrestador: servicosPapeisPrestador,
			opcoesServicosParceiro: servicosPapeisParceiro,
			bancariosPrestador: bancariosPrestador,
			bancariosParceiro: bancariosParceiro,
			bancariosAgenciador: bancariosAgenciador
		}

		return novoItem;
	},

	//Fecha popup
	cancelar: function(component, event) {
		$A.get("e.force:closeQuickAction").fire();	
	},

	salvar: function(component, event) {
		let papeisConta = component.get("v.papeisConta");
		let contaId = component.get('v.recordId');

		if(papeisConta.length == 0){
			alert('Não há papéis para serem salvos');
			return;
		}

		//Verifica se todos os valores estão validos
		if(this.validarPapeis(papeisConta)){
			var action = component.get("c.salvarPapeis");
            //PLV-4445 INICIO
            component.set('v.isLoading', true);
            //PLV-4445 FIM
			console.log('papeisContaAntes: ', papeisConta);
			action.setParams(this.parsearDadosParaSalvar(contaId, papeisConta));

	        action.setCallback(this, (response) => {
	            var state = response.getState();
	            
	            if(state == "SUCCESS"){
	            	//Atualiza página principal
	            	$A.get('e.force:refreshView').fire();
	            } else if(state == "ERROR"){
                    //PLV-4445 INICIO
                    console.log(response.getError());
                    this.handleErrors(response.getError());
                    //alert('Error in calling server side action: ' + );
                }
                
                component.set('v.isLoading', false);
                //PLV-4445 FIM
	        });
	               
	  		$A.enqueueAction(action);
		}
    },
    //PLV-4445 INICIO
    handleErrors : function(errors) {
        // let toastParams = {
        //     title: "Erro",
        //     message: "Erro fatal", 
        //     type: "error"
        // };
        if (errors) {
            if (errors[0] && errors[0].message) {
                console.log(errors[0].message);
                // toastParams.message = errors[0].message;
                alert(errors[0].message);
            }
        }
        // let toastEvent = $A.get("e.force:showToast");
        // toastEvent.setParams(toastParams);
        // toastEvent.fire();
    },
    //PLV-4445 FIM
	parsearDadosParaSalvar: function(contaId, papeisConta){
		console.log("papeisConta");
		console.log(papeisConta);
		let obj = {
			conta: {
				'sobjectType': 'Account',
				'Id': contaId,
				'Papel__c': ""
			},
	        infoBancariosPapeis: []
		};
		
		papeisConta.forEach((papelConta) => {
			if(papelConta.papel == "Agenciador"){
				obj.conta.Papel__c += papelConta.papel + ';';
				papelConta.bancariosAgenciador.Banco__c = papelConta.bancoEscolhido.CodigoBanco__c;
				obj.infoBancariosPapeis.push(papelConta.bancariosAgenciador);
			}
			else if (papelConta.papel == "Corretor"){
				obj.conta.Papel__c += papelConta.papel + ';';
				obj.conta.CodigoSusepCorretor__c = papelConta.conta.CodigoSusepCorretor__c;
				obj.conta.Sucursal__c = papelConta.conta.Sucursal__c;
				obj.conta.CodigoSusepCia__c = papelConta.conta.CodigoSusepCia__c;
			}
			else if (papelConta.papel == "Parceiro"){
				obj.conta.Papel__c += papelConta.papel + ';';
				papelConta.bancariosParceiro.Banco__c = papelConta.bancoEscolhido.CodigoBanco__c;
				obj.infoBancariosPapeis.push(papelConta.bancariosParceiro);
				obj.conta.ServicosParceiro__c = papelConta.conta.ServicosParceiro__c;
				obj.conta.NumeroContratoParceiro__c = papelConta.conta.NumeroContratoParceiro__c;
			}
			else if (papelConta.papel == "Prestador"){
				obj.conta.Papel__c += papelConta.papel + ';';
				papelConta.bancariosPrestador.Banco__c = papelConta.bancoEscolhido.CodigoBanco__c;
				obj.infoBancariosPapeis.push(papelConta.bancariosPrestador);
				obj.conta.ServicosPrestador__c = papelConta.conta.ServicosPrestador__c;
				obj.conta.NumeroContratoPrestador__c = papelConta.conta.NumeroContratoPrestador__c;
			}
			else if (papelConta.papel == "Representante de Seguros"){
				obj.conta.Papel__c += papelConta.papel + ';';
				obj.conta.NumeroContratoRespresentante__c = papelConta.conta.NumeroContratoRespresentante__c;
			} 
			else if (papelConta.papel == "Segurado"){
				obj.conta.Papel__c += papelConta.papel + ';';
			} 
		});	

		console.log('papeisContaDepois: ', obj);

		return obj;
	},

	validarPapeis: function(papeisConta){
		let mensagem = "";
		let validacaoOK = true;

		//Valida se algum papel foi escolhido
		mensagem = this.validarPapeisSelecionados(papeisConta);

		//Valida se há mais de um papel preenchido de forma repetida
		if(!mensagem){
			mensagem = this.validarPapeisRepetidos(papeisConta);
		}

		//Valida por tipo de papel escolhido
		if(!mensagem){
			mensagem = this.validarAgenciador(papeisConta);	
		}

		if(!mensagem){
			mensagem = this.validarCorretor(papeisConta);
		}

		if(!mensagem){
			mensagem = this.validarParceiro(papeisConta);
		}

		if(!mensagem){
			mensagem = this.validarPrestador(papeisConta);
		}

		if(!mensagem){
			mensagem = this.validarRepresentante(papeisConta);
		}

		if(mensagem){
			validacaoOK = false;
			alert(mensagem);
		}

		return validacaoOK;
	},

	validarPapeisSelecionados: function(papeisConta){
		let mensagem = "";

		papeisConta.forEach((papelConta) => {
			if(papelConta.papel == ""){
				mensagem = "Existem linhas com papéis sem preenchimento";
			}
		});	

		return mensagem;
	},

	validarPapeisRepetidos: function(papeisConta){
		let mensagem = "";
		let papeisSelecionados = [];

		papeisConta.forEach((papelConta) => {
			if(papeisSelecionados.includes(papelConta.papel)){
				mensagem = "Não é permitido utilizar mais de uma vez o mesmo papel. O papel '" + papelConta.papel + "' está sendo utilizado mais de uma vez.";
			}

			papeisSelecionados.push(papelConta.papel);
		});	

		return mensagem;
	},

	validarAgenciador: function(papeisConta){
		let mensagem = "";

		papeisConta.forEach((papelConta) => {
			if(papelConta.papel == 'Agenciador'){
				let dadosBancarios = papelConta.bancariosAgenciador;

                //PLV-4445 INICIO
                if(!papelConta.bancoEscolhido || !dadosBancarios.Agencia__c || !dadosBancarios.NumeroConta__c || !dadosBancarios.Digito__c){
                //PLV-4445 FIM
                    mensagem = "Existem campos do papel Agenciador sem preenchimento. Todos os campos são obrigatórios";
				}	
			}
		});	

		return mensagem;
	},

	validarCorretor: function(papeisConta){
		let mensagem = "";

		papeisConta.forEach((papelConta) => {
			if(papelConta.papel == 'Corretor'){
				let conta = papelConta.conta;

				if(conta.CodigoSusepCorretor__c == "" || conta.Sucursal__c == "" || conta.CodigoSusepCia__c == "" || conta.CodigoSusepCorretor__c == null || conta.Sucursal__c == null || conta.CodigoSusepCia__c == null){
					mensagem = "Existem campos do papel Corretor sem preenchimento. Todos os campos são obrigatórios";
				}
			}
		});	

		return mensagem;
	},

	validarParceiro: function(papeisConta){
		let mensagem = "";

		papeisConta.forEach((papelConta) => {
			if(papelConta.papel == 'Parceiro'){
				let dadosBancarios = papelConta.bancariosParceiro;
				let conta = papelConta.conta;

				if(dadosBancarios.Banco__c == "" || dadosBancarios.Agencia__c == "" || dadosBancarios.NumeroConta__c == "" || conta.NumeroContratoParceiro__c == ""|| conta.ServicosParceiro__c == ""){
					mensagem = "Existem campos do papel Parceiro sem preenchimento. Todos os campos são obrigatórios";
				}
			}
		});	

		return mensagem;
	},

	validarPrestador: function(papeisConta){
		let mensagem = "";

		papeisConta.forEach((papelConta) => {
			if(papelConta.papel == 'Prestador'){
				let dadosBancarios = papelConta.bancariosPrestador;
				let conta = papelConta.conta;

				if(dadosBancarios.Banco__c == "" || dadosBancarios.Agencia__c == "" || dadosBancarios.NumeroConta__c == "" || conta.NumeroContratoPrestador__c == ""|| conta.ServicosPrestador__c == ""){
					mensagem = "Existem campos do papel Prestador sem preenchimento. Todos os campos são obrigatórios";
				}
			}
		});	

		return mensagem;
	},

	validarRepresentante: function(papeisConta){
		let mensagem = "";

		papeisConta.forEach((papelConta) => {
			if(papelConta.papel == 'Representante de Seguros'){
				let conta = papelConta.conta;

				if(conta.NumeroContratoRespresentante__c == "" || conta.NumeroContratoRespresentante__c == null){
					mensagem = "Existem campos do papel Representante de Seguros sem preenchimento. Todos os campos são obrigatórios";
				}
			}
		});	

		return mensagem;
	}
})