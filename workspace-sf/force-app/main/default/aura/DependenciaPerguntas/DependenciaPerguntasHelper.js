({
	inicializar: function(component, event) {
		console.log('inicializar helper...');

		let chamadasIniciais = [
			this.buscarPerguntasQuestionario(component)
		];
		
		Promise.all(chamadasIniciais).then(values => {
			console.log('Carregou todas as chamadas...');
		});
	},
	buscarPerguntasQuestionario: function(component) {
		return new Promise(function(resolve, reject) {
			console.log('buscar perguntas questionario...');
			let idPerguntaQuestionario = component.get('v.recordId');
			var action = component.get('c.buscarPerguntasQuestionario2');

			action.setParams({
				'idPerguntaQuestionario': idPerguntaQuestionario
			});

			console.log('params: ' + JSON.stringify(action.getParams()));

			action.setCallback(this, (response) => {
				console.log(':: response: ' + response);
				var state = response.getState();
				console.log(':: state: ' + state);
				if (state == 'SUCCESS' && response.getReturnValue() != '') {
					var objResponse = JSON.parse(response.getReturnValue());

					var lista = [];
					var mapOpcaoResposta = objResponse.opcoesSelecionadas;
					var contador = 1;
					try {
						for (var i = 0; i < objResponse.opcoes.length; i++) {
							var obj = {};
							obj.etiquetaOpcao = objResponse.opcoes[i].trim().replace(';', '');
							obj.valorOpcao = objResponse.opcoes[i].trim().replace(';', '');
							obj.perguntaSelecionada = '';
							obj.idx = (new Date()).valueOf() + contador++;

							try {
								obj.perguntaSelecionada = mapOpcaoResposta[obj.valorOpcao].trim().replace(';', '');
							}
							catch(e){}

							lista.push(obj);
						}
					}
					catch(e) {}

					component.set('v.opcoesResposta', lista);
					
					var objPerguntas = [];
					for (let i = 0; i < objResponse.perguntas.length; i++) {
						var item = objResponse.perguntas[i];
						objPerguntas.push({'value': item, 'label': item});
					}
					component.set('v.perguntasQuestionario', objPerguntas);
					console.dir(objPerguntas);

					resolve();
				}
				else {
					$A.get('e.force:closeQuickAction').fire();
					var resultsToast = $A.get('e.force:showToast');
					resultsToast.setParams({
						'message': 'Esta pergunta não é do tipo opções.',
						'mode': 'pester',
						'type': 'error'
					});
					resultsToast.fire();
					reject();
				}
			});

			$A.enqueueAction(action);
		});
	},
	salvarOpcoes: function(component, event) {
		var opcoesResposta = component.get('v.opcoesResposta');
		this.atualizarDadosSF(component, event, opcoesResposta);
		$A.get('e.force:closeQuickAction').fire();
	},
	excluirOpcao: function(component, event) {
		var opcoesResposta = component.get('v.opcoesResposta');
		var opcaoSelecionada = event.getSource().get('v.value');
		console.log('opcaoSelecionada: ' + opcaoSelecionada);

		//Identifica o item a ser excluido
		for(let i = 0; i < opcoesResposta.length; i++) {
			console.log( opcoesResposta.idx );
			if(opcoesResposta[i].idx == opcaoSelecionada) {
				opcoesResposta.splice(i, 1);
			}
		}
		// salva os dados no salesforce
		component.set('v.opcoesResposta', opcoesResposta);
		this.atualizarDadosSF(component, event, opcoesResposta);
	},
	atualizarDadosSF: function(component, event, dados) {
		var idPerguntaQuestionario = component.get('v.recordId');
		var action = component.get('c.atualizarDados');
		dados = JSON.stringify(dados);
		
		action.setParams({
			'dados': dados,
			'idPerguntaQuestionario': idPerguntaQuestionario
		});

		action.setCallback(this, (response) => {
			var state = response.getState();

			if (state == 'SUCCESS') {
				var resultsToast = $A.get('e.force:showToast');
				resultsToast.setParams({
					'message': 'As dependências foram salvas com sucesso.',
					'mode': 'pester',
					'type': 'success'
				});
				resultsToast.fire();
				$A.get('e.force:refreshView').fire();
			}
			else {
				alert('Error in calling server side action: ' + JSON.stringify(response.getError()));
			}
		});
		$A.enqueueAction(action);
	}
})