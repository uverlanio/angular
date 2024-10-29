({
	//Inicializa componente. Realiza todas as buscas iniciais necessárias como dados de combos e registros de territorios
	inicializar : function(component, event) {
		let chamadasIniciais = [
			this.buscarPrefixoSObjects(component), 
			this.buscarTipos(component), 
			this.buscarContinentes(component), 
			this.buscarEstados(component),
			this.buscarPaises(component)
		];

		//Chama uma segunda vez, caso não seja uma quick action
		if(component.get("v.execucaoViaApp")){
			chamadasIniciais.push(this.buscarTerritoriosCadastrados(component, event, this));
		}

		Promise.all(chamadasIniciais).then(values => { 
		  	this.buscarTerritoriosCadastrados(component, event, this).then(value => {
		  		this.buscarMunicipios(component, this)
		  	});
		});
	},

	//Busca map contendo prefixos dos objetos pais (possíveis) de territorio
	buscarPrefixoSObjects: function(component) {
		return new Promise(function(resolve, reject) {
			var action = component.get("c.buscarPrefixosSObjects");

	        action.setCallback(this, (response) => {
	            var state = response.getState();
	            
	            if(state == "SUCCESS"){
	            	//Atualiza atributo para armazenar os valores
	            	component.set("v.mapPrefixoSObject", JSON.parse(response.getReturnValue()) );
	            	resolve();
	            } else if(state == "ERROR"){
	            	console.log(response.getError());
	                alert('Error in calling server side action: ' + response.getError());
	            }
	        });
	               
	        $A.enqueueAction(action);
        });
	},

	//Busca os territórios cadastrados para que possam ser editados
	buscarTerritoriosCadastrados : function(component, event, helper) {
	    return new Promise(function(resolve, reject) {
		    var action = component.get("c.buscarTerritorios"); 
		    let mapPrefixoSObject = component.get('v.mapPrefixoSObject');
		    let sObjectPaiId = component.get("v.recordId");

		    action.setParams({
             	sObjectPaiId: sObjectPaiId,
             	nomeSObjectPai: mapPrefixoSObject[sObjectPaiId.substring(0, 3)]
        	});

	        action.setCallback(this, (response) => {
	            var state = response.getState();
	            
	            if(state == "SUCCESS"){
	            	component.set("v.territorios", helper.gerarTerritorios(component, response.getReturnValue()));

	            	if(component.get("v.territorios").length == 0){
	            		helper.adicionarNovo(component, event);
	            	}
	            	resolve();

	            	if(component.get("v.execucaoViaApp")){
	            		this.adicionarNovo();
	            	}	
	            } else if(state == "ERROR"){
	            	console.log(response.getError());
	                alert('Error in calling server side action: ' + response.getError());
	            }
	        });
	        
	        $A.enqueueAction(action);
	    });
	},

	//Busca valores usados na combo de tipos
	buscarTipos: function(component) {
	    return new Promise(function(resolve, reject) {
		    var action = component.get("c.buscarTipos");

	        action.setCallback(this, (response) => {
	            var state = response.getState();

	            if(state == "SUCCESS"){
	            	//Atualiza atributo para armazenar os valores que serão usados como template pela combo correspodente
	            	component.set("v.optsTipo", response.getReturnValue());
	            	resolve();
	            } else if(state == "ERROR"){
	            	console.log(response.getError());
	                alert('Error in calling server side action: ' + response.getError());
	            }
	        });
	               
	        $A.enqueueAction(action);
	    });
	},

	//Busca valores usados na combo de continentes
	buscarContinentes: function(component) {
		return new Promise(function(resolve, reject) {
			var action = component.get("c.buscarContinentes");

	        action.setCallback(this, (response) => {
	            var state = response.getState();
	            
	            if(state == "SUCCESS"){
	            	//Atualiza atributo para armazenar os valores que serão usados como template pela combo correspodente
	            	component.set("v.optsContinente", response.getReturnValue());
	            	resolve();
	            } else if(state == "ERROR"){
	            	console.log(response.getError());
	                alert('Error in calling server side action: ' + response.getError());
	            }
	        });
	               
	        $A.enqueueAction(action);
        });
	},

	//Busca valores usados na combo de continentes
	buscarPaises: function(component) {
		return new Promise(function(resolve, reject) {
			var action = component.get("c.buscarTodosPaises");

	        action.setCallback(this, (response) => {
	            var state = response.getState();
	            
	            if(state == "SUCCESS"){
	            	//Atualiza atributo para armazenar os valores que serão usados como template pela combo correspodente
	            	component.set("v.mapPais", JSON.parse(response.getReturnValue()) );
	            	resolve();
	            } else if(state == "ERROR"){
	            	console.log(response.getError());
	                alert('Error in calling server side action: ' + response.getError());
	            }
	        });
	               
	        $A.enqueueAction(action);
        });
	},

	//Busca valores usados na combo de estados
	buscarEstados: function(component) {
		return new Promise(function(resolve, reject) {
			var action = component.get("c.buscarEstados");

	        action.setCallback(this, (response) => {
	            var state = response.getState();
	            
	            if(state == "SUCCESS"){
	            	//Atualiza atributo para armazenar os valores que serão usados como template pela combo correspodente
	            	component.set("v.optsEstado", response.getReturnValue());
	            	resolve();
	            } else if(state == "ERROR"){
	            	console.log(response.getError());
	                alert('Error in calling server side action: ' + response.getError());
	            }
	        });
	               
	        $A.enqueueAction(action);
        });
	},


	//Busca valores usados na combo de município
	buscarMunicipios: function(component, helper) {
		let territorios = component.get("v.territorios");
		let territorioMunicipio = null;
		let estados = null;

		for(let territorio of territorios){
			if(territorio.tipo == 'Município'){
				territorioMunicipio = territorio;
				estados = territorio.estado;
			}
		}

		//Verifica se há municipios para serem carregados
		if(estados){
			return new Promise(function(resolve, reject) {
				var action = component.get("c.buscarMunicipios");

				action.setParams({
					estados
				});

		        action.setCallback(this, (response) => {
		            var state = response.getState();
		            
		            if(state == "SUCCESS"){
		            	territorioMunicipio.optionsMunicipio = JSON.parse(response.getReturnValue());
		            	component.set("v.territorios", territorios);
		            	helper.selecionarValoresCombo(territorioMunicipio.municipio, territorioMunicipio.optionsMunicipio);
		            	resolve();
		            } else if(state == "ERROR"){
		            	console.log(response.getError());
		                alert('Error in calling server side action: ' + response.getError());
		            }
		        });
		               
		        $A.enqueueAction(action);
	        });
		}
	},

	//Adiciona novo item para que se possa cadastrar um novo territorio
	adicionarNovo : function(component, event) {
		let territorios = component.get("v.territorios");
		territorios.push(this.gerarNovoObjetoTerritorio(component, territorios.length));
		component.set("v.territorios", territorios);
	},

	//Gera um novo objeto para ser inserido na lista que permite inserir um novo item
	gerarNovoObjetoTerritorio: function(component, contadorTerritorios){
		let contador = contadorTerritorios + 1;
		let timestamp = (Date.now()) + contador;

		return {
			id: null,
			tipo: "",
			continente: "",
			pais: "",
			estado: "",
			municipio: "",
			habilitarContinente: false,
			habilitarPais: false,
			habilitarEstado: false,
			habilitarMunicipio: false,
			optionsTipo: JSON.parse(component.get("v.optsTipo")),
			optionsContinente: JSON.parse(component.get("v.optsContinente")),
			optionsPais: [],
			optionsEstado: JSON.parse(component.get("v.optsEstado")),
			optionsMunicipio: [],
			idx: timestamp,
			contador: contador
		};
	},

	//Salva registros criados/editados
	salvar : function(component, event) {
		let territorios = component.get("v.territorios");

		if(territorios.length == 0){
			alert('Não há territórios para serem salvos');
			return;
		}

		//Verifica se todos os valores estão validos
		if(this.validarTerritorios(territorios)){
			var action = component.get("c.salvarTerritorios");

			action.setParams({
	            territorios: this.gerarTerritoriosSObject(territorios, component)
	        });

	        action.setCallback(this, (response) => {
	            var state = response.getState();
	            
	            if(state == "SUCCESS"){
	            	//Atualiza página principal
	            	$A.get('e.force:refreshView').fire();
	            } else if(state == "ERROR"){
	            	console.log(response.getError());
	                alert('Error in calling server side action: ' + response.getError());
	            }
	        });
	               
	        $A.enqueueAction(action);
		}
	},

	//Realiza validação dos territorio criados
	validarTerritorios: function(territorios){
		let mensagem = "";
		let validacaoOK = true;

		//Valida se algum tipo foi escolhido
		mensagem = this.validarTiposTerritoriosSelecionados(territorios);

		if(!mensagem){
			//Valida se há mais de um tipo preenchido de forma repetida
			mensagem = this.validarTipoRepetido(territorios);
		}

		if(!mensagem){
			//Valida utilização de Globo terrestre
			mensagem = this.validarTipoGloboTerrestre(territorios);	
		}

		if(!mensagem){
			//Valida se o campos foram preenchidos corretamente
			mensagem = this.validarValoresPreenchidos(territorios);
		}

		if(!mensagem){
			//Validacao de países por continente
			mensagem = this.validarTipoPais(territorios);
		}

		if(!mensagem){
			//Validacao de estados
			mensagem = this.validarTipoEstado(territorios);
		}

		if(!mensagem){
			//Validacao de municipios
			mensagem = this.validarTipoMunicipio(territorios);
		}

		if(mensagem){
			validacaoOK = false;
			alert(mensagem);
		}

		return validacaoOK;
	},

	validarTiposTerritoriosSelecionados: function(territorios){	
		let mensagem = "";

		territorios.forEach((territorio) => {
			if(!territorio.tipo){
				mensagem += 'Erro linha ' + territorio.contador + ': Nenhum Tipo foi preenchido\r\n';
			}
		});

		return mensagem;
	},

	validarTipoRepetido: function(territorios){
		let mensagem = "";
		let tiposSelecionados = [];

		territorios.forEach((territorio) => {
			if(tiposSelecionados.includes(territorio.tipo)){
				mensagem = "Não é permitido utilizar mais de uma vez o mesmo âmbito territorial. O âmbito '" + territorio.tipo + "' está sendo utilizado mais de uma vez.";
			}

			tiposSelecionados.push(territorio.tipo);
		});	

		return mensagem;
	},

	validarTipoGloboTerrestre: function(territorios){
		let mensagem = "";
		let globoTerrestre = false;

		territorios.forEach((territorio) => {
			if(territorio.tipo == "Globo terrestre"){
				globoTerrestre = true;					
			}
		});

		if(territorios.length > 1 && globoTerrestre){
			mensagem = "Ao utilizar o âmbito 'Globo terrestre', não é permitido utilizar em conjunto com outros âmbito territoriais.";
		}

		return mensagem;
	},

	validarValoresPreenchidos: function(territorios){	
		let mensagem = "";

		territorios.forEach((territorio) => {
			if(territorio.tipo == "Continente"){
				if(!territorio.continente){
					mensagem += 'Erro linha ' + territorio.contador + ': Continente não preenchido\r\n';
				}
			}else if(territorio.tipo == "País"){
				if(!territorio.continente || !territorio.pais){
					mensagem += 'Erro linha ' + territorio.contador + ': País não preenchido\r\n';
				}
			}else if(territorio.tipo == "Estado"){
				if(!territorio.estado){
					mensagem += 'Erro linha ' + territorio.contador + ': Estado não preenchido\r\n';
				}
			}
			else if(territorio.tipo == "Município"){
				if(!territorio.municipio){
					mensagem += 'Erro linha ' + territorio.contador + ': Município não preenchido\r\n';
				}
			}
		});

		return mensagem;
	},

	validarTipoPais: function(territorios){	
		let mensagem = "";
		let tipoContinenteContinentes = [];
		let tipoPaisContinentes = [];

		territorios.forEach((territorio) => {
			if(territorio.tipo == "Continente"){
				tipoContinenteContinentes = territorio.continente.split(';');
			}

			if(territorio.tipo == "País"){
				tipoPaisContinentes = territorio.continente.split(';');
			}
		});

		//Verifica necessidade de validar
		if(tipoContinenteContinentes.length > 0 && tipoPaisContinentes.length > 0){
			let continentesRepetidos = [];

			for(let continente of tipoPaisContinentes){
				if(tipoContinenteContinentes.includes(continente) && continente != ""){
					continentesRepetidos.push(continente);
				}
			}

			if(continentesRepetidos.length > 0){
				mensagem = "O(s) continente(s) " + continentesRepetidos.join(", ") + " já estão sendo ultilizado(s) no âmbito de 'Continente'. \r\nNão é possível utiliza-lo(s) novamente no âmbito de 'País'.";
			}
		}

		return mensagem;
	},

	validarTipoEstado: function(territorios){	
		let mensagem = "";
		let tipoContinenteContinentes = [];
		let tipoPaisPaises = [];
		let valorContinente = null;
		let valorPais = null;

		territorios.forEach((territorio) => {
			if(territorio.tipo == "Continente"){
				tipoContinenteContinentes = territorio.continente.split(';');
			}

			if(territorio.tipo == "País"){
				tipoPaisPaises = territorio.pais.split(';');
			}

			if(territorio.tipo == "Estado"){
				valorContinente = 'América do Sul';
				valorPais = 'Brasil';
			}
		});

		//Valida se não está sendo utilizado o continente 'América do Sul'
		if(tipoContinenteContinentes.includes(valorContinente)){
			mensagem = "Não é possível utilizar o âmbito de 'Estado', pois o continente 'América do Sul' já está sendo utilizado no âmbito de 'Continente'.";
		}

		//Verifica necessidade de validar
		if(tipoPaisPaises.includes(valorPais)){
			mensagem = "Não é possível utilizar o âmbito de 'Estado', pois o país 'Brasil' já está sendo utilizado no âmbito de 'País'.";
		}

		return mensagem;
	},

	validarTipoMunicipio: function(territorios){
		let mensagem = "";
		let tipoContinenteContinentes = [];
		let tipoPaisPaises = [];
		let tipoEstadoEstados = [];
		let tipoMunicipioEstados = [];
		let valorContinente = null;
		let valorPais = null;
		let estadosUtilizados = [];

		territorios.forEach((territorio) => {
			if(territorio.tipo == "Continente"){
				tipoContinenteContinentes = territorio.continente.split(';');
			}

			if(territorio.tipo == "País"){
				tipoPaisPaises = territorio.pais.split(';');
			}

			if(territorio.tipo == "Estado"){
				valorContinente = 'América do Sul';
				valorPais = 'Brasil';
				tipoEstadoEstados = territorio.estado.split(';');
			}

			if(territorio.tipo == "Município"){
				tipoMunicipioEstados = territorio.estado.split(';');
			}
		});

		//Valida se não está sendo utilizado o continente 'América do Sul'
		if(tipoContinenteContinentes.includes(valorContinente)){
			mensagem = "Não é possível utilizar o âmbito de 'Município', pois o continente 'América do Sul' já está sendo utilizado no âmbito de 'Continente'.";
		}

		if(tipoPaisPaises.includes(valorPais)){
			mensagem = "Não é possível utilizar o âmbito de 'Município', pois o país 'Brasil' já está sendo utilizado no âmbito de 'País'.";
		}

		for(let estado of tipoEstadoEstados){
			if(tipoMunicipioEstados.includes(estado) && estado != ""){
				estadosUtilizados.push(estado);
			}
		}

		if(estadosUtilizados.length > 0){
			mensagem = "Não é possível utilizar o âmbito de 'Município', pois o(s) Estado(s) " + estadosUtilizados.join(', ') + " já estão sendo utilizado(s) no âmbito de 'Estado'.";
		}

		return mensagem;
	},

	//Gera objeto do tipo Territorio__c de acordo com objet territorio js usado pelo componente
	gerarTerritoriosSObject: function(territorios, component){
		let sObjectPaiId = component.get('v.recordId');
		let prefixoSObjectPai = sObjectPaiId.substring(0, 3);
		let mapPrefixoSObject = component.get('v.mapPrefixoSObject');
		let territoriosSobject = [];
		let garantiaProdutoId = null;
		let produtoId = null;

		if(mapPrefixoSObject[prefixoSObjectPai] == 'GarantiaProduto__c'){
			garantiaProdutoId = sObjectPaiId;
		}
		else if(mapPrefixoSObject[prefixoSObjectPai] == 'Product2'){
			produtoId = sObjectPaiId;
		}

		territorios.forEach((item) => {
			territoriosSobject.push({
				sobjectType : 'Territorio__c',
				Id: item.id, 
				Tipo__c: item.tipo,
				Continente__c: item.continente,
				Pais__c: item.pais,
				Estado__c: item.estado,
				Municipio__c: item.municipio,
				GarantiaProduto__c: garantiaProdutoId,
				Produto__c: produtoId
			});
		});

		return territoriosSobject;
	},

	//Gera territórios em formato que o componente entende (parse de SObject para object js)
	gerarTerritorios: function(component, territoriosSobject){
		let territorios = [];
		let contador = 0;

		territoriosSobject.forEach((item) => {
			//Cria objeto no formato que o componente entenda
			let territorio = this.gerarNovoObjetoTerritorio(component, contador);
			contador++;

			//Atribui valores do SObject
			territorio.id = item.Id;
			territorio.tipo = item.Tipo__c;
			territorio.continente = item.Continente__c;
			territorio.pais = item.Pais__c;
			territorio.estado = item.Estado__c;
			territorio.municipio = item.Municipio__c;

			//Se tipo for pais, gera options de paises de acordo com os continentes escolhidos
			if(territorio.tipo == 'País'){
				let mapPais = component.get("v.mapPais");

				if(territorio.continente){
					for(let continente of territorio.continente.split(";")){;
						territorio.optionsPais.push.apply(territorio.optionsPais, mapPais[continente]);
					}
				}
			}

			//Seleciona os valores escolhidos
			this.selecionarValoresCombo(territorio.tipo, territorio.optionsTipo);
			this.selecionarValoresCombo(territorio.continente, territorio.optionsContinente);
			this.selecionarValoresCombo(territorio.pais, territorio.optionsPais);
			this.selecionarValoresCombo(territorio.estado, territorio.optionsEstado);

			territorios.push(territorio);
		});

		return territorios;
	},

	//Seleciona os valores existente das combos
	selecionarValoresCombo: function(valores, listaCombo){
		if(valores){
			valores = valores.split(";");

			for(let valor of valores){
				for(let itemCombo of listaCombo){
					if(itemCombo.value == valor)
						itemCombo.selected = true;
				}
			}
		}
	},

	//Fecha popup
	cancelar: function(component, event) {
		if(!component.get("v.execucaoViaApp")){
			$A.get("e.force:closeQuickAction").fire();	
		}
		else{
			sforce.one.back(true);	
		}
	}
})