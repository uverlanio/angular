/*
*
* Classe responsável pelo processamento macro para sugestão de produtos
*
*/
public class SugestaoProdutoFacade {
	private static final SugestaoProdutoFacade instance = new SugestaoProdutoFacade();
	private ConfiguracaoBO configBo = ConfiguracaoBO.getInstance();
	private ProductBO produtoBo = ProductBO.getInstance();
	//private OrcamentoFacade orcamentoBO = OrcamentoFacade.getInstance();

	private SugestaoProdutoFacade() { }

	public static SugestaoProdutoFacade getInstance(){
		return instance;
	}

	//Realiza parse dos dados, e permite realiza processamento
	public SugestaoProdutoTO.SaidaTO sugerirProdutos(OrcamentoTO.PayloadTO payload){
		OrcamentoTO orcamento = payload.orcamentos.get(0);
		system.debug('SugestaoProdutoFacade >> sugerirProdutos >> orcamento: ' + orcamento); 
		SugestaoProdutoTO.SaidaTO resposta = new SugestaoProdutoTO.SaidaTO();

		//Verica se é um pedido de sugestão de produtos ou se trata de uma cancelamento
		if(orcamento.solicitacaoOferta.tipoSeguro != 'CAN'){
			SugestaoProdutoTO.EntradaTO dadosEntrada = this.parserDadosEntrada(orcamento);

			//Se não houver produto, sugerir
			if(dadosEntrada.dadosBusca.produto == null){
				Set<Id> produtosIds = new Set<Id>();
				Map<Id, Product2> mapProduto = new Map<Id, Product2>();

				//Gera map de DePara dos campos do json para os campos do Salesforce, e excuta busca dos produtos a partir das configurações
				Map<String, String> mapCamposValores = this.gerarMapDeparaCamposValores(dadosEntrada.dadosBusca);
				List<ProdutoConfiguracao__c> produtosConf = configBo.buscarProdutosConfigurados(mapCamposValores, dadosEntrada.dadosBusca.segmento);

				//Recupera ids dos produtos, para recuperar informações que não existem abaixo da estrutura de produto da configuração
				for(ProdutoConfiguracao__c produto : produtosConf){
					produtosIds.add(produto.Produto__c);
				}

				for(Product2 produto : produtoBo.buscarProdutos(produtosIds, true)){
					mapProduto.put(produto.Id, produto);
				}
				
				//Busca os produtos que deverão serem encontrados pelas regras de configuração
				for(ProdutoConfiguracao__c produto : produtosConf){
					resposta.produtos.add( this.parsearProduto(produto, mapProduto.get(produto.Produto__c)) );
				}
			}else{
				Date dataAtual = System.today();
				Product2 produto = produtoBo.buscarProdutoPorCodigoVigencia(dadosEntrada.dadosBusca.produto, dataAtual, dataAtual);
				resposta.produtos.add(this.parsearProduto(null, produtoBo.buscarProdutos(new Set<Id> {produto.Id}, true).get(0)));
			}
			system.debug('SugestaoProdutoFacade >> sugerirProdutos >> retorno: ' + resposta);
		}
		else
		{
			//Gera payload de orçamento de cancelemento
			//resposta.orcamentos = orcamentoBO.gerarOrcamentoCancelamento(orcamento);
		}

		return resposta;
	}

	//Recebe payload de orçamento e retorna estrutura de entrada que o serviço entende
	private SugestaoProdutoTO.EntradaTO parserDadosEntrada(OrcamentoTO orcamento){
		SugestaoProdutoTO.EntradaTO dadosEntrada = new SugestaoProdutoTO.EntradaTO();
		OrcamentoTO.ContratanteTO ContratantePrincipal = new OrcamentoTO.ContratanteTO();

		dadosEntrada.dadosBusca.segmento = orcamento.solicitacaoOferta.segmento == 'VG' ? 'Coletivo' : 'Individual';
		dadosEntrada.dadosBusca.produto = orcamento.solicitacaoOferta.codigoProdutoVida;

		if(orcamento.solicitacaoOferta.evento != null){
			dadosEntrada.dadosBusca.tipoEvento = orcamento.solicitacaoOferta.evento.tipoEvento;
		}

		if(orcamento.solicitacaoOferta.viagem != null && orcamento.solicitacaoOferta.viagem.destinos != null){
			dadosEntrada.dadosBusca.paisesDestino = '';

			for(OrcamentoTO.DestinoTO destino : orcamento.solicitacaoOferta.viagem.destinos){
				if(String.isBlank(dadosEntrada.dadosBusca.paisesDestino)){
					dadosEntrada.dadosBusca.paisesDestino = destino.pais;					
				}
				else{
					dadosEntrada.dadosBusca.paisesDestino +=  ';' + destino.pais;	
				}
			}

			dadosEntrada.dadosBusca.viagemAventura = String.valueOf(orcamento.solicitacaoOferta.viagem.praticaEsportesAventura == 'SIM');
			dadosEntrada.dadosBusca.utilizaMoto = String.valueOf(orcamento.solicitacaoOferta.viagem.utilizaraMotocicleta == 'SIM');
		}

		//Encontra o contratante principal
		for(OrcamentoTO.ContratanteTO contratante : orcamento.solicitacaoOferta.contratantes){
			if(contratante.tipo == 'PRI'){
				ContratantePrincipal = contratante;
				break;
			}	
		}

		if(ContratantePrincipal != null){
			dadosEntrada.dadosBusca.tipoContratante = ContratantePrincipal.tipo;

			if(orcamento.solicitacaoOferta.segmento == 'VG'){
				dadosEntrada.dadosBusca.cnae = String.valueOf(ContratantePrincipal.pessoa.dadosPessoaJuridica.codigoCNAE);
				//dadosEntrada.dadosBusca.quantidadeMotoboys
				//dadosEntrada.dadosBusca.quantidadeMotoristas
				//dadosEntrada.dadosBusca.quantidadeFuncionarios
				//dadosEntrada.dadosBusca.quantidadePassageiros
				//dadosEntrada.dadosBusca.transferenciaCongenere
				//dadosEntrada.dadosBusca.possuiAfastados
				//dadosEntrada.dadosBusca.tipoContratante
				//dadosEntrada.dadosBusca.vidasEntre70e74Anos
			}
			else{
				dadosEntrada.dadosBusca.profissao = ContratantePrincipal.pessoa.dadosPessoaFisica.profissao;
				dadosEntrada.dadosBusca.sexo = ContratantePrincipal.pessoa.dadosPessoaFisica.sexo == 'MAS' ? 'Masculino' : 'Feminino';
				dadosEntrada.dadosBusca.estadoCivil = ContratantePrincipal.pessoa.dadosPessoaFisica.estadoCivil;
				dadosEntrada.dadosBusca.dataNascimento = String.valueOf(ContratantePrincipal.pessoa.dadosPessoaFisica.dataNascimento);
				//dadosEntrada.dadosBusca.renda
				//dadosEntrada.dadosBusca.fumante
				//dadosEntrada.dadosBusca.faixaRenda
				//dadosEntrada.dadosBusca.faixaIdade
				//dadosEntrada.dadosBusca.protecaParaQuem
				//dadosEntrada.dadosBusca.formaTrabalho
			}	
		}
		
		return dadosEntrada;
	}

	//Realiza depara com o nome do campo passado no json para o nome do campo no salesforce
	private Map<String, String> gerarMapDeparaCamposValores(SugestaoProdutoTO.DadosBuscaTO dadosBusca){
		Map<String, String> mapCamposValores = new Map<String, String>();
		
		if(dadosBusca.cnpj != null){
			mapCamposValores.put('Account.Cnpj__c', dadosBusca.cnpj);
		}

		if(dadosBusca.cpf != null){
			mapCamposValores.put('Account.CPF__pc', dadosBusca.cpf);	
		}

		//É UMA LOOKUP, NÃO PODE SER FEITO DESTA FORMA
		//if(dadosBusca.profissao != null){
		//	mapCamposValores.put('Account.Profissao__pc', dadosBusca.profissao);
		//}

		if(dadosBusca.renda != null){
			mapCamposValores.put('Account.Renda__c', dadosBusca.renda);
		}

		if(dadosBusca.estadoCivil != null){
			mapCamposValores.put('Account.EstadoCivil__c', dadosBusca.estadoCivil);
		}

		if(dadosBusca.cnae != null){
			mapCamposValores.put('Account.CNAE__c', dadosBusca.cnae);
		}

		if(dadosBusca.sexo != null){
			mapCamposValores.put('Account.Sexo__pc', dadosBusca.sexo);	
		}		

		if(dadosBusca.fumante != null){
			mapCamposValores.put('Account.Fumante__c', dadosBusca.fumante);	
		}	

		if(dadosBusca.dataNascimento != null){
			mapCamposValores.put('Account.PersonBirthdate', dadosBusca.dataNascimento);
		}		

		if(dadosBusca.faixaRenda != null){
			mapCamposValores.put('Opportunity.FaixaRenda__c', dadosBusca.faixaRenda);	
		}	

		if(dadosBusca.faixaIdade != null){
			mapCamposValores.put('Opportunity.FaixaIdade__c', dadosBusca.faixaIdade);	
		}			

		if(dadosBusca.protecaParaQuem != null){
			mapCamposValores.put('Opportunity.ProtecaoParaQuem__c', dadosBusca.protecaParaQuem);	
		}	

		if(dadosBusca.formaTrabalho != null){
			mapCamposValores.put('Opportunity.FormaTrabalho__c', dadosBusca.formaTrabalho);	
		}	

		if(dadosBusca.quantidadeMotoboys != null){
			mapCamposValores.put('Opportunity.QuantidadeMotoboys__c', dadosBusca.quantidadeMotoboys);	
		}	

		if(dadosBusca.quantidadeMotoristas != null){
			mapCamposValores.put('Opportunity.QuantidadeMotoristas__c', dadosBusca.quantidadeMotoristas);	
		}	

		if(dadosBusca.quantidadeFuncionarios != null){
			mapCamposValores.put('Opportunity.QuantidadeFuncionarios__c', dadosBusca.quantidadeFuncionarios);	
		}	

		if(dadosBusca.transferenciaCongenere != null){
			mapCamposValores.put('Opportunity.TransferenciaCongenere__c', dadosBusca.transferenciaCongenere);	
		}	

		if(dadosBusca.possuiAfastados != null){
			mapCamposValores.put('Opportunity.PossuiAfastados__c', dadosBusca.possuiAfastados);	
		}	

		if(dadosBusca.tipoContratante != null){
			mapCamposValores.put('Opportunity.TipoContratante__c', dadosBusca.tipoContratante);	
		}	

		if(dadosBusca.tipoCalculo != null){
			mapCamposValores.put('Opportunity.TipoCalculo__c', dadosBusca.tipoCalculo);
		}

		if(dadosBusca.SeguradosEntre70e74Anos != null){
			mapCamposValores.put('Opportunity.SeguradosEntre70e74Anos__c', dadosBusca.SeguradosEntre70e74Anos);	
		}	

		if(dadosBusca.tipoEvento != null){
			mapCamposValores.put('Opportunity.TipoEvento__c', dadosBusca.tipoEvento);	
		}	

		if(dadosBusca.paisesDestino != null){
			mapCamposValores.put('Opportunity.PaisesDestino__c', dadosBusca.paisesDestino);	
		}	

		if(dadosBusca.viagemAventura != null){
			mapCamposValores.put('Opportunity.ViagemAventura__c', dadosBusca.viagemAventura);	
		}	

		if(dadosBusca.quantidadePassageiros != null){
			mapCamposValores.put('Opportunity.QuantidadePassageiros__c', dadosBusca.quantidadePassageiros);	
		}	

		if(dadosBusca.destino != null){
			mapCamposValores.put('Opportunity.Destino__c', dadosBusca.destino);	
		}	

		if(dadosBusca.utilizaMoto != null){
			mapCamposValores.put('Opportunity.UtilizaMoto__c', dadosBusca.utilizaMoto);	
		}			

		//if(dadosBusca.viagemAventura != null){
		//	mapCamposValores.put('GarantiaOportunidade__c.ViagemAventura__c', dadosBusca.viagemAventura);	
		//}			

		return mapCamposValores;
	}

	//Realiza parser do produto/garantia Salesforce para estrutura de retorno do serviço
	private SugestaoProdutoTO.ProdutoTO parsearProduto(ProdutoConfiguracao__c produtoConf, Product2 produto){
		SugestaoProdutoTO.ProdutoTO produtoTo = new SugestaoProdutoTO.ProdutoTO();

		produtoTo.nome = produto.Name;
		produtoTo.codigo = produto.ProductCode;
		produtoTo.versao = produto.Versao__c;

		//Se for produto vindo de uma sugestão, utilziar as garantias da configuração
		if(produtoConf != null){
			for(GarantiaProdutoConfiguracao__c garantia : produtoConf.GarantiasProdutoConfiguracao__r){
				produtoTo.garantias.add(
					new SugestaoProdutoTO.GarantiaTO(
						garantia.GarantiaProduto__r.Garantia__r.Name,
						garantia.GarantiaProduto__r.Name,
						garantia.GarantiaProduto__r.TipoCapital__c,
						garantia.GarantiaProduto__r.CapitalRiscos__c, 
						garantia.GarantiaProduto__r.ValorInicial__c,
						garantia.GarantiaProduto__r.ValorFinal__c,
						garantia.GarantiaProduto__r.PercentualAgravoMinimo__c,
						garantia.GarantiaProduto__r.PercentualAgravoMaximo__c,
						garantia.GarantiaProduto__r.PercentualDescontoMinimo__c,
						garantia.GarantiaProduto__r.PercentualDescontoMaximo__c,
						garantia.GarantiaProduto__r.Garantia__r.Sigla__c,
						garantia.GarantiaProduto__r.CurrencyIsoCode
					)
				);
			}
		}
		else{
			for(GarantiaProduto__c garantia : produto.GarantiasProduto__r){
				produtoTo.garantias.add(
					new SugestaoProdutoTO.GarantiaTO(
						garantia.Garantia__r.Name,
						garantia.Name,
						garantia.TipoCapital__c,
						garantia.CapitalRiscos__c, 
						garantia.ValorInicial__c,
						garantia.ValorFinal__c,
						garantia.PercentualAgravoMinimo__c,
						garantia.PercentualAgravoMaximo__c,
						garantia.PercentualDescontoMinimo__c,
						garantia.PercentualDescontoMaximo__c,
						garantia.Garantia__r.Sigla__c,
						garantia.CurrencyIsoCode
					)
				);
			}
		}

		for(PremioMinimoProduto__c premioMinimo : produto.PremiosMinimoProduto__r){
			produtoTo.premiosMinimo.add(
				new SugestaoProdutoTO.PremioMinimoTO(
					premioMinimo.FormaPagamento__r.Name,
					premioMinimo.TipoContratacao__c,
					premioMinimo.PeriodicidadePagamento__c,
					premioMinimo.PremioMinimoParcela__c
				)
			);
		}

		for(CondicaoCobranca__c condicao : produto.CondicoesCobranca__r){
			produtoTo.condicoesCobranca.add(
				new SugestaoProdutoTO.CondicaoCobrancaTO(
					condicao.FormaPagamento__r.Name,
					condicao.QuantidadeParcelas__c,
					condicao.PercentualMinimo__c,
					condicao.PercentualMaximo__c
				)
			);
		}

		return produtoTo;
	}
}