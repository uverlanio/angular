/**
 * Created by Isabela Fin on 30/10/2020.
 */
({
	init : function(component, event, helper) {
		//FNPVVEP-126 INICIO
		component.set("v.showSpinner", true);
		let isRecalculoOut = component.get("v.isRecalculoOut");
		console.log('isRecalculoOut', isRecalculoOut);
    	if (isRecalculoOut) {
        	helper.decryptIdProposta(component);
    	}
		else{
			helper.popularTabelaCriticas(component);
			helper.carregaDadosProposta(component);
			helper.dadosFormaPagamento(component);
			helper.verificaAgenciamento(component);
			helper.consultaBancos(component);
			helper.verificaResponsavelFinanceiro(component);
		}
		//FNPVVEP-126 FIM
	},
	recalcular : function(component, event, helper) {
		//console.log("controller recalcular")
		component.set("v.showSpinner", true);
		component.set("v.alteracaoFormPag", false); //II-206 FIX02 - INICIO/FIM
		helper.recalcular(component);
	},
	voltar : function(component) {
		component.set("v.showSpinner", true);
		var etapa = component.get('v.etapa');
		component.set('v.etapa',etapa-1);
		component.set("v.showSpinner", false);
	},
	changeTipo : function(component,event,helper) {
		let cobertura = event.currentTarget.dataset.cobertura
		let valor = event.currentTarget.value
		component.set('v.garantiaDesconto[changed]', cobertura)
		component.set('v.garantiaDesconto[' + cobertura + ']', valor)
	},
	changeTipoProposta : function(component,event,helper) {
		let campo = event.currentTarget.dataset.campo
		let valor = event.currentTarget.value
		if (!campo || !valor) return;
		component.set('v.propostaTipo[changed]', campo)
		component.set('v.propostaTipo[' + campo + ']', valor)
        if('proposta_descontoAgravo' == campo) component.set('v.propostaModificada.tipoDescontoAgravo',valor); //PLV-4694 - INICIO/FIM
	},
	
	verifyObrigatorias : function(component, event,helper){
		let newValue = event.currentTarget.checked
		let propostaModificada = component.get('v.propostaModificada')
		let garantiasPrincipais = component.get('v.garantiasPrincipais')
		let current = event.currentTarget
		let valorToapply = newValue
		if (newValue == false && current.dataset.obrigatorio=='true'){
			valorToapply = true
			helper.showToastMessage("Garantia obrigatória", "error", "pester")
		}else if (newValue == false && garantiasPrincipais.length == 1 && garantiasPrincipais[0]==current.dataset.cobertura){
			valorToapply = true
			helper.showToastMessage("Precisa de ao menos uma garantia principal.", "error", "pester")
		} else if (newValue == false && garantiasPrincipais.includes(current.dataset.cobertura)){
			let arrfilter = garantiasPrincipais.filter(function (item) {
				return item !== current.dataset.cobertura
			})
			component.set('v.garantiasPrincipais', arrfilter)
		} else if (newValue == true && current.dataset.caracteristica == 'Principal'){
			garantiasPrincipais.push(current.dataset.cobertura)
			component.set('v.garantiasPrincipais', garantiasPrincipais)
		}
		
		let mod = Object.assign(propostaModificada,{})
		for (let i in mod.garantias) {
			if (mod.garantias[i].cobertura == current.dataset.cobertura) {
				mod.garantias[i].contratado = valorToapply
			}
		}
		component.set('v.propostaModificada', mod)
		component.set('v.' + event.currentTarget.name, valorToapply);
		
	},
	
	resetProposta: function (component, event, helper) {
		let propostaModificada = component.get('v.propostaModificada')
		component.set('v.tipoConfirm', 'reset');
		component.set('v.showConfirmDialog', true);
		component.set('v.confirmDialogMessage', 'Deseja <u>descartar</u> todas as modificações realizadas?');
	},

	salvar : function(component, event, helper) {
		component.set('v.showConfirmDialog', true);
		component.set('v.tipoConfirm', 'salvar');
		//II-176 - INICIO
		let atualizarCtr = component.get("v.alteracaoFormPag");
		//FNPVVEP-168 INICIO
		let cliente = component.get("v.cliente");
		if(atualizarCtr){
			component.set('v.confirmDialogMessage', 'Você gostaria de aplicar todas as modificações realizadas? Ao confirmar, sua proposta será atualizada com os novos cálculos.'); //FNPVVEP-147 INICIO/FIM
			component.set('v.confirmDialogMessageAlt', 'Olá, '+cliente+'!<br/> A alteração da forma de pagamento do seu Seguro de Vida da Porto foi realizada com sucesso!<br/> Todo cuidado é Porto.'); //FNPVVEP-168 INICIO/FIM
		}else{
			component.set('v.confirmDialogMessage', 'Deseja aplicar todas as modificações realizadas? Ao aceitar o cálculo:<br/>• A Crítica de Recalculo será Liberada;<br/>• Será criada Critica da DOCUSIGN;<br/>• Será enviado e-mail para o contratante;<br/>• Itens vinculados ao registro podem ser apagados;');
			component.set('v.confirmDialogMessageAlt', 'Proposta racalculada com sucesso!'); //FNPVVEP-168 INICIO/FIM
		}
		//FNPVVEP-168 FIM
		//II-176 - FIM
	},

	resetForm: function (component, event, helper) {
		component.set("v.showSpinner", true);
		component.set('v.showConfirmDialog', false);
		component.set('v.tipoConfirm', '');
		component.set('v.propostaModificada', component.get('v.propostaOriginal'))
		$A.enqueueAction(component.get('c.init'))
	},
	salvarForm: function (component, event, helper) {
		component.set("v.showSpinner", true);
		component.set('v.showConfirmDialog', false);
		component.set('v.tipoConfirm', '');
		//II-206 - INICIO
		var isCartao = component.get("v.showFormPgtoCartao");
		var isADC = component.get("v.showFormPgtoADC");
		var isBoleto = component.get("v.showFormPgtoBoleto");
		
		helper.salvar(component);
		//helper.atualizarFavorecido(component); //FNPVVEP-147 INICIO/FIM
		helper.atualizaRespFinanceiro(component);
		if(isCartao){
			helper.atualizaCartoes(component);
		}else if(isADC){
			helper.atualizaADC(component);
		}else if(isBoleto){
			helper.atualizaBoleto(component);
		}
		//II-206 - FIM
	},
	
	handleConfirmDialogNo: function (component, event, helper) {
		component.set('v.showConfirmDialog', false);
		component.set('v.tipoConfirm', '');
	},
	//FNPVVEP-147 INICIO
	//FNPVVEP-168 INICIO
	handleConfirmRecalculo: function (component, event, helper) {
		component.set("v.etapaTela2", false);
		component.set('v.showConfirmRecalculo', false);
		component.set('v.tipoConfirm', '');
		helper.popularTabelaCriticas(component);
		helper.carregaDadosProposta(component);
		helper.dadosFormaPagamento(component);
		helper.verificaAgenciamento(component);
		helper.consultaBancos(component);
		helper.verificaResponsavelFinanceiro(component);
	},
	//FNPVVEP-168 FIM
	//FNPVVEP-147 FIM

	voltar : function(component) {
		component.set("v.showSpinner", true);
		var etapa = component.get('v.etapa');
		component.set('v.etapa',etapa-1);
		component.set("v.showSpinner", false);
	},
	//II-166 - INICIO
	removerOpEmp: function(component, event, helper){
		helper.removerOpEmp14(component);
	},
	gerarParcelas: function(component, event, helper){
        helper.qtdeParcelas(component);
		helper.ocultarFrase(component, event);
    },
    verificarValCartCred: function(component, event, helper){
        helper.verificarValCartCred();
    },
    verificarCartaoCredito: function(component, event, helper){
        helper.verificarCartaoCredito(component);
    },
	//II-166 - FIM
	//II-172 - INICIO
	formatarNumCartCred: function(component, event, helper){
		helper.formatarNumCartCred(component);
	},
	formatarValCartCred: function(component, event, helper){
		helper.formatarValCartCred(component);
	},
	showRespFinan: function(component, event, helper){
		component.set("v.showOutroRespFin", false);
	},
	showOutroRespFinan: function(component, event, helper){
		component.set("v.showOutroRespFin", true);
	},
	formatarCPF: function(component, event, helper){
		helper.formatarCPF(component);
	},
	verificarCPF: function(component, event, helper){
		helper.verificarCPF();
	},
	verificarVinculo: function(component, event, helper){
		helper.verificarVinculo();
	},
	formatarNascimento : function(component, event, helper){
		helper.formatarNascimento(component);
	},
	verificarNascimento: function(component, event, helper){
		helper.verificarNascimento(component);
	},
	verificarEmails: function(component, event, helper){
		helper.verificarEmails();
	},
	verificarTelefone1: function(component, event, helper){
		helper.verificarTelefone1();
	},
	verificarTelefone2: function(component, event, helper){
		helper.verificarTelefone2();
	},
	formatarTelefone1: function(component, event, helper){
		helper.formatarTelefone1(component);
	},
	formatarTelefone2: function(component, event, helper){
		helper.formatarTelefone2(component);
	},
	consultarCEP: function(component, event, helper){
		helper.consultarCEP(component);
	},
	formatarCEP: function(component, event, helper){
		helper.formatarCEP(component);
	},
	carregarComplementos: function(component, event, helper){
		helper.carregarComplementos(component, event);
	},
	//II-172 - FIM
	//II-176 - INICIO
	antComissao: function(component, event, helper){
		component.set("v.antecipar", true);
		component.set("v.naoAntecipar", false);
		component.set("v.antecipacaoSelecionada", true);
	},
	notAntComissao: function(component, event, helper){
		component.set("v.naoAntecipar", true);
		component.set("v.antecipar", false);
		component.set("v.antecipacaoSelecionada", true);
	},
	//II-206 - INICIO
	//Debugs Rogerio e Henrique FIX01 - INCIO
	recalculoFormPag: function(component, event, helper){
		var formularioResp = component.get("v.showOutroRespFin");
		var isCartao = component.get("v.showFormPgtoCartao");
		var isADC = component.get("v.showFormPgtoADC");
		var isBoleto = component.get("v.showFormPgtoBoleto");
		console.log("formularioResp <> ", formularioResp);
		console.log("isCartao <> ", isCartao);
		console.log("isADC <> ", isADC);
		console.log("isBoleto <> ", isBoleto);
		if(formularioResp){
			console.log("entrou if formularioResp == True <> ");
			helper.verificarFormulario(component);
			helper.getRespFinanceiro(component);
			console.log("entrou if formularioResp == True e executou as funções <>");
		}
		var calcular = component.get("v.liberarCalculo");
		console.log("calcular <> ", calcular); 
		helper.validarCampoPagamento(component); //II-206 FIX01 - INICIO/FIM
		if(!formularioResp || calcular){
			console.log("entrou if formularioResp == false OU calcular == True <> ");
			if(isCartao){
				console.log("entrou if isCartao == True <> ");
				helper.validarCamposCartao(component);
				var liberarCartao = component.get("v.liberarCartao");
				console.log("liberarCartao <> ", liberarCartao);
				if(liberarCartao){
					console.log("entrou if liberarCartao == True <> ");
					//FNPVVEP-146 INICIO
					let newFormPag = document.getElementById("novaFormaPagamento").value;
					let precificarCodes = ['70', '98'];
					if(precificarCodes.includes(newFormPag)){
						helper.newRecalculoFormaPagamento(component, event);
					} else{
						helper.recalculoFormaPagamento(component, event);
					}
					//FNPVVEP-146 FIM
				}
			}else if(isADC){
				console.log("entrou if isADC == True <> ");
				helper.validarCamposADC(component);
				var liberarADC = component.get("v.liberarADC");
				console.log("liberarADC <> ", liberarADC);
				if(liberarADC){
					console.log("entrou if liberarADC == True <> ");
					helper.recalculoFormaPagamento(component, event);
				}
			}else if(isBoleto){
				console.log("entrou if isBoleto == True <> ");
				helper.validarCamposBoleto(component);
				var liberarBoleto = component.get("v.liberarBoleto");
				console.log("liberarBoleto <> ", liberarBoleto);
				if(liberarBoleto){
					console.log("entrou if liberarBoleto == True <> ");
					helper.recalculoFormaPagamento(component, event);
					console.log("passou pela recalculoFormaPagamento <> ");
				}
			}
		}
		//II-206 - FIM
	},//Debugs Rogerio e Henrique FIX01 - FIM
	ocultarFrase: function(component, event, helper){
		helper.ocultarFrase(component, event);
	},//II-206 FIX02 - INICIO
	//II-176 - FIM
	voltarFormPag : function(component) {
		component.set("v.showSpinner", true);
		component.set('v.etapaTela2',1);
		component.set("v.showSpinner", false);
	}
	//II-206 FIX02 - FIM
})