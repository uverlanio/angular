@isTest
private class SugestaoProdutoTest {

	@testSetup
	private static void setup() {
		TestDataFactory.gerarDadosSetup();
	}

	public class RetornoTeste {
		public RetornoRestTO.MetaTO meta {get; set;}
		public SugestaoProdutoTO.SaidaTO data {get; set;}
	}

	@isTest
	static void testarServicoSugestao() {
		//Payload para busca de produto de segmento individual para sexo masculino
		String payloadEntrada = '{"orcamentos":[{"solicitacaoOferta":{"segmento":"VI","meioComercializacao":"PPW","numeroOrcamento":"00000148","numeroPortal":988444,"dataCalculo":"2016-02-05","dataCriacaoPortal":"2016-09-09","codigoProdutoPortal":121,"codigoProdutoVida":null,"tipoVigencia":"PCU","vigenciaInicial":"2016-09-23","vigenciaFinal":"2016-09-30","qtdDiasVigencia":8,"tipoSeguro":"NOV","tipoAdesao":"TOT","evento":{"tipoEvento":"SHO","qstControlePublico":"SIM","qstLocalEvento":"SIM","informacoesEvento":"Ocorrerá durante os jogos do Brasil na Copa do Mundo"},"viagem":{"tipoViagem":"INT","praticaEsportesAventura":"NAO","utilizaraMotocicleta":"SIM","incluiPaisSchengen":"NAO","trackageBagagem":"SIM","destinos":[{"pais":"Alemanha"},{"pais":"Italia"},{"pais":"China"}],"passageirosNaoIdosos":3,"passageirosIdosos":1},"transferenciaCongenere":{"congenere":"SULAMERICA","tempoPermanencia":3,"sinistralidade":1.2,"taxaVigencia":2.1},"observacoesGerais":"Solicito atendimento especial.","contratantes":[{"tipo":"PRI","numero":1,"pessoa":{"tipo":"FIS","telefones":[{"tipoTelefone":"CEL","numeroTelefone":"971452694","dddTelefone":"11"}],"nome":"Mussum Forevis","enderecos":[{"uf":"SP","tipoLogradouro":"R","tipoEndereco":"RES","paisResidencia":"BRA","numeroLogradouro":"92","logradouro":"Guaianses","complementoCep":"420","complemento":"Apto 22","cidade":"SAO PAULO","cep":"07114","bairro":"Centro"}],"email":"mussum.forevis@gmail.com","dadosPessoaJuridica":{"cnpj":"00062999/0001-01","codigoCNAE":7490101,"descricaoCNAE":"SERVI&#199;OS DE TRADU&#199;&#195;OINTERPRETA&#199;&#195;O E SIMILARES"},"dadosPessoaFisica":{"tipoRelacionamentoPep":"Pai","sexo":"MAS","profissao":"5242-05/0413","pessoaRelacionamentoPep":{"tipo":"FIS","nome":"Marcelo Freixo","dadosPessoaFisica":{"numeroCpf":"123456789","digitoCpf":"56"}},"pep":true,"numeroCpf":"387308998","nacionalidade":"BRA","estadoCivil":"CAS","documentos":[{"tipoDocumentoIdentidade":"RG","orgaoExpedidorDocumento":"SSP","numeroDocumentoIdentidade":"4798840555","dataExpedicaoDocumento":"2000-06-29"}],"digitoCpf":"00","dataNascimento":"1980-06-29"}},"grupos":[{"numero":1,"nome":"Sócios","tipoSegurado":"COO","qtdeVidas":444,"idArquivoVidas":"Planilha_Upload_Vida_09_03_2018_15_53_40.xls","tipoCalculo":"GLO","prazoMaximoFinanciamentoPrestamista":56,"saldoDevedor":5000,"valorDoBem":40000,"segurados":[{"numero":"1","numeroCpf":null,"digitoCpf":null,"nome":null,"dataNascimento":"1975-12-10","afastado":"NAO","cid":null,"coberturas":[{"sigla":"IPA","percentual":75,"garantiaReferenciada":"MAP","agravo":10,"moeda":"USD"},{"sigla":"AFI","valor":4000,"desconto":6,"moeda":"USD"},{"sigla":"COJ","percentual":80,"inclusaoIndenizacaoEspecial":"SIM","percentualIndenizacaoEspecial":50,"moeda":"USD"},{"sigla":"CJP","percentual":80,"inclusaoFilhos":"SIM","percentualFilhos":50,"moeda":"USD"}]},{"numero":"2","numeroCpf":null,"digitoCpf":null,"nome":null,"dataNascimento":"1966-02-21","afastado":"NAO","cid":null,"coberturas":[{"sigla":"IPA","percentual":100,"garantiaReferenciada":"MAP","moeda":"USD"},{"sigla":"AFI","valor":3000,"moeda":"USD"},{"sigla":"COJ","percentual":80,"inclusaoIndenizacaoEspecial":"SIM","percentualIndenizacaoEspecial":50,"moeda":"USD"},{"sigla":"CJP","percentual":80,"inclusaoFilhos":"SIM","percentualFilhos":50,"moeda":"USD"}]},{"numero":"3","numeroCpf":null,"digitoCpf":null,"nome":null,"dataNascimento":"1981-06-30","afastado":"SIM","cid":345,"coberturas":[{"sigla":"IPA","moeda":"USD","percentual":100,"garantiaReferenciada":"MAP"},{"moeda":"EUR","sigla":"AFI","valor":5000},{"sigla":"COJ","percentual":80,"inclusaoIndenizacaoEspecial":"SIM","percentualIndenizacaoEspecial":50,"moeda":"EUR"},{"sigla":"CJP","percentual":80,"inclusaoFilhos":"SIM","percentualFilhos":50,"moeda":"USD"}]}],"coberturas":[{"sigla":"MAP","valor":56000,"moeda":"USD"},{"sigla":"DMHO","valor":250,"moeda":"USD"},{"sigla":"DIT","valor":400,"moeda":"USD","quantidade":30,"clausulaReducaoFranquiaAcidente":"SIM"}]}]}],"descontoComercial":1.1,"agravoComercial":1,"remuneracao":{"canal":"COR","agentes":[{"papel":"COR","corretagem":5,"susep":"C1192J","tipoPessoaCorsus":"J","susepEmissao":"C1192J","susepOrcamento":"C1192J","pessoa":{"tipo":"JUR","nome":"Potencia Corretora","dadosPessoaJuridica":{"numeroCnpj":"00062999","ordemCnpj":"0001","digitoCnpj":"01"}}},{"papel":"AGE","agenciamento":2,"pessoa":{"tipo":"FIS","nome":"Xuxa Meneghel","dadosPessoaFisica":{"numeroCpf":"745861388","digitoCpf":"23"}}},{"papel":"REP","proLabore":10,"pessoa":{"tipo":"FIS","nome":"Pelé","dadosPessoaFisica":{"numeroCpf":"111222333","digitoCpf":"42"}}},{"papel":"ASS","assessoria":4,"pessoa":{"tipo":"FIS","nome":"Ayrton Senna","dadosPessoaFisica":{"numeroCpf":"111222333","digitoCpf":"43"}}}],"codigoOperacaoImprimir":"SIM"}},"guiaPostal":[{"cep":"12345-123","cidade":"São Paulo","uf":"São Paulo"}],"licitacoes":[{"orgaoPublico":"S","cnpj":"60.856.443/0001-00"}],"serasa":[{"cnpj":"222.222.222-22","cnae":"22525-12","cep":"12345-123"}],"indiceMonetario":[{"moeda":"USD","valor":2.4},{"moeda":"EUR","valor":3.4}],"retornoValidacaoProduto":{"codigoProduto":1,"versaoProduto":1,"descontoComercial":40,"descontoTecnico":40,"agravoComercial":10,"agravoTecnico":10,"premiosMinimos":[{"quantidadeParcelas":1,"formaPagamento":"ADC","premioMinimo":50}],"moedasExtrangeiras":["USD","EUR"]},"retornoAceitacao":{"avisos":[{"codigo":10080,"descricao":"Verifique a natureza dos afastamentos","area":"ACE","procedimento":"Informar os afastados de alto risco à Atuária.","mensagens":{"interna":"Verifique a natureza dos afastamentos, alto risco deve ser mapeado"}}],"pendencias":[{"codigo":874343,"descricao":"Falta enviar declaracao de saude","area":"UNI","severidade":1,"procedimento":"Aguardar envio da DS e verificar sua autenticidade","mensagens":{"interna":"Pendente de envio de DS","cliente":"Prezado cliente, precisamos da sua declaração de saúde para prosseguir com a contratação.","representante":"Caro ?, favor solicitar ao cliente a Declaração de Saúde."}}],"analises":[{"codigo":10085,"descricao":"Quantidade de afastados necessita análise","area":"TEC","severidade":2,"procedimento":"Abaixo de 3%, aceitar. Entre 3% e 6%, aceitar somente se doenças forem abaixo do grau 3. Acima de 6%, recusar."}],"recusas":[{"codigo":10090,"descricao":"Idade máxima excedida","mensagens":{"interna":"Idade sem aceitação para o produto","cliente":"Prezado cliente, na sua fase de vida temos outros produtos para atendê-lo. Consulte o nosso site.","representante":"Caro ?, cliente com idade acima do permitido para o produto."}}]},"oferta":{"permiteTransmissao":"SIM","parcelamentos":[{"valorDemaisParcelas":0,"valor1aParcela":313.01,"qtdParcelas":1,"juros":0,"iof":0.38,"encargos":0,"descricao":"1X - Cartao de Credito demais bandeiras","custoapolice":0,"codigo":62},{"valorDemaisParcelas":0,"valor1aParcela":297.37,"qtdParcelas":1,"juros":0,"iof":0.38,"encargos":0,"descricao":"1X - Cartao Porto Seguro","custoapolice":0,"codigo":97}],"origem":"PPW","numeroPortal":988444,"numero":647658,"calculo":{"precificacao":{"juros":0,"iof":0.0038,"encargos":0,"custoApolice":0,"premio":{"puro":8.0834,"puroDesconto":7.8643,"puroInterno":7.97435,"puroResseguro":1.97434,"comercial":3.09834,"comercialDesconto":2.75435},"taxa":{"pura":0.87443,"mensal":0.74435,"anual":0.12344,"puroInterno":0.97435,"puroResseguro":0.97434,"comercial":0.86434},"coberturas":[{"sigla":"MAP","moeda":"USD","capital":737456.95,"premio":{"puro":8.0834,"puroInterno":0.97435,"puroResseguro":0.97434,"comercial":3.09834},"taxa":{"pura":0.87443,"puroInterno":0.97435,"puroResseguro":0.97434,"comercial":0.86434}}],"contratantes":[{"numero":1,"premio":{"puro":8.0834,"comercial":3.09834},"taxa":{"pura":0.87443,"comercial":0.86434},"coberturas":[{"sigla":"MAP","moeda":"USD","capital":737456.95,"premio":{"puro":8.0834,"comercial":3.09834},"taxa":{"pura":0.87443,"comercial":0.86434}}],"grupos":[{"numero":1,"premio":{"puro":8.0834,"comercial":3.09834},"taxa":{"pura":0.87443,"comercial":0.86434},"coberturas":[{"sigla":"IPA","moeda":"USD","capital":737456.95,"premio":{"puro":8.0834,"comercial":3.09834},"taxa":{"pura":0.87443,"comercial":0.86434}}],"segurados":[{"numero":"1","premio":{"puro":8.0834,"comercial":3.09834},"taxa":{"pura":0.87443,"comercial":0.86434},"coberturas":[{"sigla":"IPA","moeda":"USD","capital":737456.95,"premio":{"puro":8.0834,"comercial":3.09834},"taxa":{"pura":0.87443,"comercial":0.86434}}]},{"numero":"2","premio":{"puro":8.0834,"comercial":3.09834},"taxa":{"pura":0.87443,"comercial":0.86434},"coberturas":[{"sigla":"AFI","moeda":"USD","capital":737456.95,"premio":{"puro":8.0834,"comercial":3.09834},"taxa":{"pura":0.87443,"comercial":0.86434}}]},{"numero":"3","premio":{"puro":8.0834,"comercial":3.09834},"taxa":{"pura":0.87443,"comercial":0.86434},"coberturas":[{"sigla":"MAP","moeda":"USD","capital":737456.95,"premio":{"puro":8.0834,"comercial":3.09834},"taxa":{"pura":0.87443,"comercial":0.86434}}]}]}]}]},"analiseAtuarial":{"estatistica":{"faixaEtaria":[{"tipo":"FXA","inicioFaixa":18,"finalFaixa":40,"quantidade":7,"percentual":100,"capital":400000,"mediaCapital":400000},{"tipo":"FXA","inicioFaixa":40,"finalFaixa":60,"quantidade":8,"percentual":100,"capital":400000,"mediaCapital":400000},{"tipo":"TOT","quantidade":15,"percentual":100,"capital":400000,"mediaCapital":400000}],"faixaCapital":[{"tipo":"FXA","finalFaixa":400000,"quantidade":13,"percentual":100,"capital":5200000000,"mediaCapital":400000},{"tipo":"FXA","inicioFaixa":400000,"quantidade":1,"percentual":100,"capital":200000000,"mediaCapital":2000000},{"tipo":"TOT","quantidade":13,"percentual":100,"capital":5200000000,"mediaCapital":400000}],"status":[{"status":"Ativo(s)","quantidade":13},{"status":"Afastado(s)","quantidade":1},{"status":"Aposentado(s)","quantidade":0}]},"analitica":{"quantidadeVidas":23,"publicoMasculino":53.09,"publicoFeminino":43.05,"capitalMedio":43205444.99,"idadeMediaAtuarial":35.94,"idadeMediaPonderada":24.054,"idadeMediaPonderadaPorIS":54.95,"idadeMediaAritmetica":43.54,"taxaModelagem":0.89743,"percentualDescontoModelagem":-95.9854,"expectativaSinistrosAnual":0.007543,"capitalPonderadoPorExpectativaSinistro":10249.07},"contratantes":[{"numero":1,"estatistica":{"faixaEtaria":[{"tipo":"FXA","inicioFaixa":18,"finalFaixa":40,"quantidade":7,"percentual":100,"capital":400000,"mediaCapital":400000},{"tipo":"FXA","inicioFaixa":40,"finalFaixa":60,"quantidade":8,"percentual":100,"capital":400000,"mediaCapital":400000},{"tipo":"TOT","quantidade":15,"percentual":100,"capital":400000,"mediaCapital":400000}],"faixaCapital":[{"tipo":"FXA","finalFaixa":400000,"quantidade":13,"percentual":100,"capital":5200000000,"mediaCapital":400000},{"tipo":"FXA","inicioFaixa":400000,"quantidade":1,"percentual":100,"capital":200000000,"mediaCapital":2000000},{"tipo":"TOT","quantidade":13,"percentual":100,"capital":5200000000,"mediaCapital":400000}],"status":[{"status":"Ativo(s)","quantidade":13},{"status":"Afastado(s)","quantidade":1},{"status":"Aposentado(s)","quantidade":0}]},"analitica":{"quantidadeVidas":23,"publicoMasculino":53.09,"publicoFeminino":43.05,"capitalMedio":43205444.99,"idadeMediaAtuarial":35.94,"idadeMediaPonderada":24.054,"idadeMediaPonderadaPorIS":54.95,"idadeMediaAritmetica":43.54,"taxaModelagem":0.89743,"percentualDescontoModelagem":-95.9854,"expectativaSinistrosAnual":0.007543,"capitalPonderadoPorExpectativaSinistro":10249.07},"grupos":[{"numero":1,"estatistica":{"faixaEtaria":[{"tipo":"FXA","inicioFaixa":18,"finalFaixa":40,"quantidade":7,"percentual":100,"capital":400000,"mediaCapital":400000},{"tipo":"FXA","inicioFaixa":40,"finalFaixa":60,"quantidade":8,"percentual":100,"capital":400000,"mediaCapital":400000},{"tipo":"TOT","quantidade":15,"percentual":100,"capital":400000,"mediaCapital":400000}],"faixaCapital":[{"tipo":"FXA","finalFaixa":400000,"quantidade":13,"percentual":100,"capital":5200000000,"mediaCapital":400000},{"tipo":"FXA","inicioFaixa":400000,"quantidade":1,"percentual":100,"capital":200000000,"mediaCapital":2000000},{"tipo":"TOT","quantidade":13,"percentual":100,"capital":5200000000,"mediaCapital":400000}],"status":[{"status":"Ativo(s)","quantidade":13},{"status":"Afastado(s)","quantidade":1},{"status":"Aposentado(s)","quantidade":0}]},"analitica":{"quantidadeVidas":23,"publicoMasculino":53.09,"publicoFeminino":43.05,"capitalMedio":43205444.99,"idadeMediaAtuarial":35.94,"idadeMediaPonderada":24.054,"idadeMediaPonderadaPorIS":54.95,"idadeMediaAritmetica":43.54,"taxaModelagem":0.89743,"percentualDescontoModelagem":-95.9854,"expectativaSinistrosAnual":0.007543,"capitalPonderadoPorExpectativaSinistro":10249.07}}]}]}}},"mensagem":"Cálculo realizado com sucesso","erro":0}]}';
		Product2 produtoGerado = gerarDados();

		RestRequest postRequest = new RestRequest();
		postRequest.requestURI 	= '/services/apexrest/sugestaoProduto';
		postRequest.requestBody = Blob.valueOf(payloadEntrada);
		postRequest.httpMethod 	= 'POST';
		postRequest.addHeader('Content-Type', 'application/json');
		RestContext.request		= postRequest;
		RestContext.response 	=  new RestResponse();

		Test.startTest();

		SugestaoProdutoRest.processarPost();
		String jsonResposta = RestContext.response.responseBody.toString();

		Map<String, Schema.FieldSetMember> mapCamposObjetos = ConfiguracaoBO.getInstance().buscarMapInformacoesCamposCriterio(new List<String>{'Account', 'Opportunity'}, 'Individual', 'ConfiguradorOferta');
		Map<String, CriterioConfiguracao__c> mapCriterios = new Map<String, CriterioConfiguracao__c>();
		Map<String, String> mapCamposValores = new Map<String, String>();
		mapCamposValores.put('Opportunity.TipoSegurado__c', 'Alunos');
		mapCamposValores.put('Account.Renda__c', '50');
		mapCamposValores.put('Account.PersonBirthdate', '1993-03-13');

		for(CriterioConfiguracao__c criterio : [SELECT Id,Campo__c,Operador__c,Valor__c FROM CriterioConfiguracao__c]){
			mapCriterios.put(criterio.Campo__c, criterio);
		}

		ConfiguracaoBO.getInstance().validarValoresCriterios(mapCamposValores, mapCriterios, mapCamposObjetos);

		//RetornoTeste resposta = (RetornoTeste)JSON.deserialize(jsonResposta, RetornoTeste.class);

		//System.assertEquals(resposta.meta.statusHttp, 200);
		//System.assertEquals(resposta.data.produtos.size(), 1);
		//System.assertEquals(resposta.data.produtos.get(0).nome, produtoGerado.Name);
		//System.assertEquals(resposta.data.produtos.get(0).garantias.get(0).nome, produtoGerado.GarantiasProduto__r[0].Garantia__r.Name);

		Test.stopTest();
	}

	@isTest
	static void testarServicoProduto() {
		//Payload para busca de produto de segmento individual para sexo masculino
		String payloadEntrada = '{"orcamentos":[{"solicitacaoOferta":{"segmento":"VI","meioComercializacao":"PPW","numeroOrcamento":"00000148","numeroPortal":988444,"dataCalculo":"2016-02-05","dataCriacaoPortal":"2016-09-09","codigoProdutoPortal":121,"codigoProdutoVida":260,"tipoVigencia":"PCU","vigenciaInicial":"2016-09-23","vigenciaFinal":"2016-09-30","qtdDiasVigencia":8,"tipoSeguro":"NOV","tipoAdesao":"TOT","evento":{"tipoEvento":"SHO","qstControlePublico":"SIM","qstLocalEvento":"SIM","informacoesEvento":"Ocorrerá durante os jogos do Brasil na Copa do Mundo"},"viagem":{"tipoViagem":"INT","praticaEsportesAventura":"NAO","utilizaraMotocicleta":"SIM","incluiPaisSchengen":"NAO","trackageBagagem":"SIM","destinos":[{"pais":"Alemanha"},{"pais":"Italia"},{"pais":"China"}],"passageirosNaoIdosos":3,"passageirosIdosos":1},"transferenciaCongenere":{"congenere":"SULAMERICA","tempoPermanencia":3,"sinistralidade":1.2,"taxaVigencia":2.1},"observacoesGerais":"Solicito atendimento especial.","contratantes":[{"tipo":"PRI","numero":1,"pessoa":{"tipo":"FIS","telefones":[{"tipoTelefone":"CEL","numeroTelefone":"971452694","dddTelefone":"11"}],"nome":"Mussum Forevis","enderecos":[{"uf":"SP","tipoLogradouro":"R","tipoEndereco":"RES","paisResidencia":"BRA","numeroLogradouro":"92","logradouro":"Guaianses","complementoCep":"420","complemento":"Apto 22","cidade":"SAO PAULO","cep":"07114","bairro":"Centro"}],"email":"mussum.forevis@gmail.com","dadosPessoaJuridica":{"cnpj":"00062999/0001-01","codigoCNAE":7490101,"descricaoCNAE":"SERVI&#199;OS DE TRADU&#199;&#195;OINTERPRETA&#199;&#195;O E SIMILARES"},"dadosPessoaFisica":{"tipoRelacionamentoPep":"Pai","sexo":"MAS","profissao":"5242-05/0413","pessoaRelacionamentoPep":{"tipo":"FIS","nome":"Marcelo Freixo","dadosPessoaFisica":{"numeroCpf":"123456789","digitoCpf":"56"}},"pep":true,"numeroCpf":"387308998","nacionalidade":"BRA","estadoCivil":"CAS","documentos":[{"tipoDocumentoIdentidade":"RG","orgaoExpedidorDocumento":"SSP","numeroDocumentoIdentidade":"4798840555","dataExpedicaoDocumento":"2000-06-29"}],"digitoCpf":"00","dataNascimento":"1980-06-29"}},"grupos":[{"numero":1,"nome":"Sócios","tipoSegurado":"COO","qtdeVidas":444,"idArquivoVidas":"Planilha_Upload_Vida_09_03_2018_15_53_40.xls","tipoCalculo":"GLO","prazoMaximoFinanciamentoPrestamista":56,"saldoDevedor":5000,"valorDoBem":40000,"segurados":[{"numero":"1","numeroCpf":null,"digitoCpf":null,"nome":null,"dataNascimento":"1975-12-10","afastado":"NAO","cid":null,"coberturas":[{"sigla":"IPA","percentual":75,"garantiaReferenciada":"MAP","agravo":10,"moeda":"USD"},{"sigla":"AFI","valor":4000,"desconto":6,"moeda":"USD"},{"sigla":"COJ","percentual":80,"inclusaoIndenizacaoEspecial":"SIM","percentualIndenizacaoEspecial":50,"moeda":"USD"},{"sigla":"CJP","percentual":80,"inclusaoFilhos":"SIM","percentualFilhos":50,"moeda":"USD"}]},{"numero":"2","numeroCpf":null,"digitoCpf":null,"nome":null,"dataNascimento":"1966-02-21","afastado":"NAO","cid":null,"coberturas":[{"sigla":"IPA","percentual":100,"garantiaReferenciada":"MAP","moeda":"USD"},{"sigla":"AFI","valor":3000,"moeda":"USD"},{"sigla":"COJ","percentual":80,"inclusaoIndenizacaoEspecial":"SIM","percentualIndenizacaoEspecial":50,"moeda":"USD"},{"sigla":"CJP","percentual":80,"inclusaoFilhos":"SIM","percentualFilhos":50,"moeda":"USD"}]},{"numero":"3","numeroCpf":null,"digitoCpf":null,"nome":null,"dataNascimento":"1981-06-30","afastado":"SIM","cid":345,"coberturas":[{"sigla":"IPA","moeda":"USD","percentual":100,"garantiaReferenciada":"MAP"},{"moeda":"EUR","sigla":"AFI","valor":5000},{"sigla":"COJ","percentual":80,"inclusaoIndenizacaoEspecial":"SIM","percentualIndenizacaoEspecial":50,"moeda":"EUR"},{"sigla":"CJP","percentual":80,"inclusaoFilhos":"SIM","percentualFilhos":50,"moeda":"USD"}]}],"coberturas":[{"sigla":"MAP","valor":56000,"moeda":"USD"},{"sigla":"DMHO","valor":250,"moeda":"USD"},{"sigla":"DIT","valor":400,"moeda":"USD","quantidade":30,"clausulaReducaoFranquiaAcidente":"SIM"}]}]}],"descontoComercial":1.1,"agravoComercial":1,"remuneracao":{"canal":"COR","agentes":[{"papel":"COR","corretagem":5,"susep":"C1192J","tipoPessoaCorsus":"J","susepEmissao":"C1192J","susepOrcamento":"C1192J","pessoa":{"tipo":"JUR","nome":"Potencia Corretora","dadosPessoaJuridica":{"numeroCnpj":"00062999","ordemCnpj":"0001","digitoCnpj":"01"}}},{"papel":"AGE","agenciamento":2,"pessoa":{"tipo":"FIS","nome":"Xuxa Meneghel","dadosPessoaFisica":{"numeroCpf":"745861388","digitoCpf":"23"}}},{"papel":"REP","proLabore":10,"pessoa":{"tipo":"FIS","nome":"Pelé","dadosPessoaFisica":{"numeroCpf":"111222333","digitoCpf":"42"}}},{"papel":"ASS","assessoria":4,"pessoa":{"tipo":"FIS","nome":"Ayrton Senna","dadosPessoaFisica":{"numeroCpf":"111222333","digitoCpf":"43"}}}],"codigoOperacaoImprimir":"SIM"}},"guiaPostal":[{"cep":"12345-123","cidade":"São Paulo","uf":"São Paulo"}],"licitacoes":[{"orgaoPublico":"S","cnpj":"60.856.443/0001-00"}],"serasa":[{"cnpj":"222.222.222-22","cnae":"22525-12","cep":"12345-123"}],"indiceMonetario":[{"moeda":"USD","valor":2.4},{"moeda":"EUR","valor":3.4}],"retornoValidacaoProduto":{"codigoProduto":1,"versaoProduto":1,"descontoComercial":40,"descontoTecnico":40,"agravoComercial":10,"agravoTecnico":10,"premiosMinimos":[{"quantidadeParcelas":1,"formaPagamento":"ADC","premioMinimo":50}],"moedasExtrangeiras":["USD","EUR"]},"retornoAceitacao":{"avisos":[{"codigo":10080,"descricao":"Verifique a natureza dos afastamentos","area":"ACE","procedimento":"Informar os afastados de alto risco à Atuária.","mensagens":{"interna":"Verifique a natureza dos afastamentos, alto risco deve ser mapeado"}}],"pendencias":[{"codigo":874343,"descricao":"Falta enviar declaracao de saude","area":"UNI","severidade":1,"procedimento":"Aguardar envio da DS e verificar sua autenticidade","mensagens":{"interna":"Pendente de envio de DS","cliente":"Prezado cliente, precisamos da sua declaração de saúde para prosseguir com a contratação.","representante":"Caro ?, favor solicitar ao cliente a Declaração de Saúde."}}],"analises":[{"codigo":10085,"descricao":"Quantidade de afastados necessita análise","area":"TEC","severidade":2,"procedimento":"Abaixo de 3%, aceitar. Entre 3% e 6%, aceitar somente se doenças forem abaixo do grau 3. Acima de 6%, recusar."}],"recusas":[{"codigo":10090,"descricao":"Idade máxima excedida","mensagens":{"interna":"Idade sem aceitação para o produto","cliente":"Prezado cliente, na sua fase de vida temos outros produtos para atendê-lo. Consulte o nosso site.","representante":"Caro ?, cliente com idade acima do permitido para o produto."}}]},"oferta":{"permiteTransmissao":"SIM","parcelamentos":[{"valorDemaisParcelas":0,"valor1aParcela":313.01,"qtdParcelas":1,"juros":0,"iof":0.38,"encargos":0,"descricao":"1X - Cartao de Credito demais bandeiras","custoapolice":0,"codigo":62},{"valorDemaisParcelas":0,"valor1aParcela":297.37,"qtdParcelas":1,"juros":0,"iof":0.38,"encargos":0,"descricao":"1X - Cartao Porto Seguro","custoapolice":0,"codigo":97}],"origem":"PPW","numeroPortal":988444,"numero":647658,"calculo":{"precificacao":{"juros":0,"iof":0.0038,"encargos":0,"custoApolice":0,"premio":{"puro":8.0834,"puroDesconto":7.8643,"puroInterno":7.97435,"puroResseguro":1.97434,"comercial":3.09834,"comercialDesconto":2.75435},"taxa":{"pura":0.87443,"mensal":0.74435,"anual":0.12344,"puroInterno":0.97435,"puroResseguro":0.97434,"comercial":0.86434},"coberturas":[{"sigla":"MAP","moeda":"USD","capital":737456.95,"premio":{"puro":8.0834,"puroInterno":0.97435,"puroResseguro":0.97434,"comercial":3.09834},"taxa":{"pura":0.87443,"puroInterno":0.97435,"puroResseguro":0.97434,"comercial":0.86434}}],"contratantes":[{"numero":1,"premio":{"puro":8.0834,"comercial":3.09834},"taxa":{"pura":0.87443,"comercial":0.86434},"coberturas":[{"sigla":"MAP","moeda":"USD","capital":737456.95,"premio":{"puro":8.0834,"comercial":3.09834},"taxa":{"pura":0.87443,"comercial":0.86434}}],"grupos":[{"numero":1,"premio":{"puro":8.0834,"comercial":3.09834},"taxa":{"pura":0.87443,"comercial":0.86434},"coberturas":[{"sigla":"IPA","moeda":"USD","capital":737456.95,"premio":{"puro":8.0834,"comercial":3.09834},"taxa":{"pura":0.87443,"comercial":0.86434}}],"segurados":[{"numero":"1","premio":{"puro":8.0834,"comercial":3.09834},"taxa":{"pura":0.87443,"comercial":0.86434},"coberturas":[{"sigla":"IPA","moeda":"USD","capital":737456.95,"premio":{"puro":8.0834,"comercial":3.09834},"taxa":{"pura":0.87443,"comercial":0.86434}}]},{"numero":"2","premio":{"puro":8.0834,"comercial":3.09834},"taxa":{"pura":0.87443,"comercial":0.86434},"coberturas":[{"sigla":"AFI","moeda":"USD","capital":737456.95,"premio":{"puro":8.0834,"comercial":3.09834},"taxa":{"pura":0.87443,"comercial":0.86434}}]},{"numero":"3","premio":{"puro":8.0834,"comercial":3.09834},"taxa":{"pura":0.87443,"comercial":0.86434},"coberturas":[{"sigla":"MAP","moeda":"USD","capital":737456.95,"premio":{"puro":8.0834,"comercial":3.09834},"taxa":{"pura":0.87443,"comercial":0.86434}}]}]}]}]},"analiseAtuarial":{"estatistica":{"faixaEtaria":[{"tipo":"FXA","inicioFaixa":18,"finalFaixa":40,"quantidade":7,"percentual":100,"capital":400000,"mediaCapital":400000},{"tipo":"FXA","inicioFaixa":40,"finalFaixa":60,"quantidade":8,"percentual":100,"capital":400000,"mediaCapital":400000},{"tipo":"TOT","quantidade":15,"percentual":100,"capital":400000,"mediaCapital":400000}],"faixaCapital":[{"tipo":"FXA","finalFaixa":400000,"quantidade":13,"percentual":100,"capital":5200000000,"mediaCapital":400000},{"tipo":"FXA","inicioFaixa":400000,"quantidade":1,"percentual":100,"capital":200000000,"mediaCapital":2000000},{"tipo":"TOT","quantidade":13,"percentual":100,"capital":5200000000,"mediaCapital":400000}],"status":[{"status":"Ativo(s)","quantidade":13},{"status":"Afastado(s)","quantidade":1},{"status":"Aposentado(s)","quantidade":0}]},"analitica":{"quantidadeVidas":23,"publicoMasculino":53.09,"publicoFeminino":43.05,"capitalMedio":43205444.99,"idadeMediaAtuarial":35.94,"idadeMediaPonderada":24.054,"idadeMediaPonderadaPorIS":54.95,"idadeMediaAritmetica":43.54,"taxaModelagem":0.89743,"percentualDescontoModelagem":-95.9854,"expectativaSinistrosAnual":0.007543,"capitalPonderadoPorExpectativaSinistro":10249.07},"contratantes":[{"numero":1,"estatistica":{"faixaEtaria":[{"tipo":"FXA","inicioFaixa":18,"finalFaixa":40,"quantidade":7,"percentual":100,"capital":400000,"mediaCapital":400000},{"tipo":"FXA","inicioFaixa":40,"finalFaixa":60,"quantidade":8,"percentual":100,"capital":400000,"mediaCapital":400000},{"tipo":"TOT","quantidade":15,"percentual":100,"capital":400000,"mediaCapital":400000}],"faixaCapital":[{"tipo":"FXA","finalFaixa":400000,"quantidade":13,"percentual":100,"capital":5200000000,"mediaCapital":400000},{"tipo":"FXA","inicioFaixa":400000,"quantidade":1,"percentual":100,"capital":200000000,"mediaCapital":2000000},{"tipo":"TOT","quantidade":13,"percentual":100,"capital":5200000000,"mediaCapital":400000}],"status":[{"status":"Ativo(s)","quantidade":13},{"status":"Afastado(s)","quantidade":1},{"status":"Aposentado(s)","quantidade":0}]},"analitica":{"quantidadeVidas":23,"publicoMasculino":53.09,"publicoFeminino":43.05,"capitalMedio":43205444.99,"idadeMediaAtuarial":35.94,"idadeMediaPonderada":24.054,"idadeMediaPonderadaPorIS":54.95,"idadeMediaAritmetica":43.54,"taxaModelagem":0.89743,"percentualDescontoModelagem":-95.9854,"expectativaSinistrosAnual":0.007543,"capitalPonderadoPorExpectativaSinistro":10249.07},"grupos":[{"numero":1,"estatistica":{"faixaEtaria":[{"tipo":"FXA","inicioFaixa":18,"finalFaixa":40,"quantidade":7,"percentual":100,"capital":400000,"mediaCapital":400000},{"tipo":"FXA","inicioFaixa":40,"finalFaixa":60,"quantidade":8,"percentual":100,"capital":400000,"mediaCapital":400000},{"tipo":"TOT","quantidade":15,"percentual":100,"capital":400000,"mediaCapital":400000}],"faixaCapital":[{"tipo":"FXA","finalFaixa":400000,"quantidade":13,"percentual":100,"capital":5200000000,"mediaCapital":400000},{"tipo":"FXA","inicioFaixa":400000,"quantidade":1,"percentual":100,"capital":200000000,"mediaCapital":2000000},{"tipo":"TOT","quantidade":13,"percentual":100,"capital":5200000000,"mediaCapital":400000}],"status":[{"status":"Ativo(s)","quantidade":13},{"status":"Afastado(s)","quantidade":1},{"status":"Aposentado(s)","quantidade":0}]},"analitica":{"quantidadeVidas":23,"publicoMasculino":53.09,"publicoFeminino":43.05,"capitalMedio":43205444.99,"idadeMediaAtuarial":35.94,"idadeMediaPonderada":24.054,"idadeMediaPonderadaPorIS":54.95,"idadeMediaAritmetica":43.54,"taxaModelagem":0.89743,"percentualDescontoModelagem":-95.9854,"expectativaSinistrosAnual":0.007543,"capitalPonderadoPorExpectativaSinistro":10249.07}}]}]}}},"mensagem":"Cálculo realizado com sucesso","erro":0}]}';
		Product2 produtoGerado = gerarDados();

		RestRequest postRequest = new RestRequest();
		postRequest.requestURI 	= '/services/apexrest/sugestaoProduto';
		postRequest.requestBody = Blob.valueOf(payloadEntrada);
		postRequest.httpMethod 	= 'POST';
		postRequest.addHeader('Content-Type', 'application/json');
		RestContext.request		= postRequest;
		RestContext.response 	=  new RestResponse();

		Test.startTest();

		SugestaoProdutoRest.processarPost();
		String jsonResposta = RestContext.response.responseBody.toString();
		//RetornoTeste resposta = (RetornoTeste)JSON.deserialize(jsonResposta, RetornoTeste.class);

		//System.assertEquals(resposta.meta.statusHttp, 200);
		//System.assertEquals(resposta.data.produtos.size(), 1);
		//System.assertEquals(resposta.data.produtos.get(0).nome, produtoGerado.Name);
		//System.assertEquals(resposta.data.produtos.get(0).garantias.get(0).nome, produtoGerado.GarantiasProduto__r[0].Garantia__r.Name);

		Test.stopTest();
	}

	@isTest
	static void testarBuscaOrcamentoCancelamento() {
		//Payload para busca de produto de segmento individual para sexo masculino
		Contract contratoGerado = gerarDadosContrato();
		String payloadEntrada = '{"orcamentos": [{"solicitacaoOferta":{"empresa":1,"sucursal":13,"ramo":1377,"apolice": ' + contratoGerado.Name + ' ,"tipoSeguro":"CAN","tipoEndosso":"INA","dataCalculo":"2018-08-19","vigenciaInicial":"2018-09-19","meioComercializacao":"SFC"}}]}';
		
		RestRequest postRequest = new RestRequest();
		postRequest.requestURI 	= '/services/apexrest/sugestaoProduto';
		postRequest.requestBody = Blob.valueOf(payloadEntrada);
		postRequest.httpMethod 	= 'POST';
		postRequest.addHeader('Content-Type', 'application/json');
		RestContext.request		= postRequest;
		RestContext.response 	=  new RestResponse();


		SugestaoProdutoRest.processarPost();
		String jsonResposta = RestContext.response.responseBody.toString();
		RetornoTeste resposta = (RetornoTeste)JSON.deserialize(jsonResposta, RetornoTeste.class);

		//System.assertEquals(resposta.meta.statusHttp, 200);
		//System.assertEquals(resposta.data.produtos.size(), 1);
		//System.assertEquals(resposta.data.produtos.get(0).nome, produtoGerado.Name);
		//System.assertEquals(resposta.data.produtos.get(0).garantias.get(0).nome, produtoGerado.GarantiasProduto__r[0].Garantia__r.Name);
	}

	@isTest
	static void dadosTO() {
		SugestaoProdutoTO.DadosBuscaTO dadoTo = new SugestaoProdutoTO.DadosBuscaTO();
		dadoTo.cobertura = 'COB';
		dadoTo.capitalCobertura = '56';
		dadoTo.assistencia = 'MOR';
		dadoTo.vigencia = '2018-09-09';
		dadoTo.dataNascimento = '1958-09-09';
		dadoTo.remuneracao = '45';
		dadoTo.nomeProponente = 'MARIA';
		dadoTo.periodoVigencia = '34';
		dadoTo.cep = '06709-890';
		dadoTo.cooperados = '';
		dadoTo.funcionarios = '100';
		dadoTo.sociosEstagiarios = 'false';
		dadoTo.prestadoresOuEstagiarios = 'false';
		dadoTo.cursosPeriodoDeterminado = '';
		dadoTo.excursoesPasseiosTuristicos = '';
		dadoTo.exposicoesDeiras = '';
		dadoTo.formaturasFestas = '';
		dadoTo.shows = '';
		dadoTo.cinema = '';
		dadoTo.pecasTeatroFilmagens = '';
		dadoTo.eventosEsportivos = '';
		dadoTo.eventosRodeio = '';
		dadoTo.eventoLocalFechado = '';
		dadoTo.tiposContratante = '';
		dadoTo.quantidadesegurados = '';
		dadoTo.capital = '';
		dadoTo.eventosEsportesRadicais = 'false';
		dadoTo.lutas = 'true';
		dadoTo.artesMarciais = 'true';
		dadoTo.periodoViagem = '';
		dadoTo.faixaEtaria = '';

		SugestaoProdutoTO.ValidacaoTO validacaoTO = new SugestaoProdutoTO.ValidacaoTO();
		validacaoTO.tipo = 'garantia';
		validacaoTO.descricao = 'Garantia';
	}
	 
	static Contract gerarDadosContrato(){
		// PLV-2312-28 INICIO
		Map<String,List<SObject>> mapDados = TestDataFactory.gerarContrato(true);
		// PLV-2312-28 FIM
		return (Contract)TestDataFactory.pegarRegistro(mapDados, 'Contract');
	}

	//Gera dados e retorna informação que deverá ser encontrada no processamento de uma configuração
	static Product2 gerarDados(){
		//Cria produto
		// PLV-4472 INICIO
		Account contaTeste = new Account(Name = 'Conta 14', 
											CodigoEmpresa__c = '14', 
											Cnpj__c = '84.762.465/0001-70' 
										);
		// PLV-4472 FIM
		insert contaTeste;

		FormaPagamento__c formaPagamento = new FormaPagamento__c(
                Codigo__c = '1234',
                Name = '3X'
        );
        insert formaPagamento;

		RamoSeguro__c ramoVida = new RamoSeguro__c(
			Name = 'VIDA',
			CodigoEmpresa__c = '14',
			Codigo__c = '2',
			IdExterno__c = '14_2',
			Empresa__c = contaTeste.Id,
			Status__c = 'Ativo',
			CodigoOrigemDoMovimentoBCP__c = '32' //PLV-3773 INICIO/FIM - incluso campo para rega de validação
		);
		insert ramoVida;

		Garantia__c garantia = new Garantia__c();
		garantia.Name = 'XPTO';
		garantia.VigenciaInicial__c = System.today();
		garantia.Tipo__c = 'Cobertura';
		insert garantia;

		RamoGarantia__c ramoGarantia = new RamoGarantia__c(
			Garantia__c = garantia.Id,
			RamoSeguro__c = ramoVida.Id
		);
		insert ramoGarantia;

		Product2 produtoTec = new Product2();
		produtoTec.Name = 'Nome produtoTec 001';
		produtoTec.Status__c = 'Em criação';
		produtoTec.ProductCode = '260';
		produtoTec.Status__c = 'Em criação';
		produtoTec.TipoResponsavelPagamento__c = 'PAR';
		produtoTec.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id;
		insert produtoTec;
		//correcao ambientes inicio
		/* ContentVersion versaoArquivoTec = new ContentVersion(
			Title = 'Test 001 - ' + System.now(),
			PathOnClient = 'test_001.txt',
			VersionData = Blob.valueOf('Arquivo #001 de amostra ' + System.now()),
			IsMajorVersion = true
		);
		insert versaoArquivoTec;

		ContentDocumentLink arquivoTec = new ContentDocumentLink();
		arquivoTec.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: versaoArquivoTec.Id].ContentDocumentId;
		arquivoTec.LinkedEntityId = produtoTec.Id;
		arquivoTec.ShareType = 'V';
		insert arquivoTec; */
		//correcao ambientes fim

		produtoTec.Status__c = 'Em ativação';
		produtoTec.NumeroSusep__c = '1234x';
		update produtoTec;

		produtoTec.Status__c = 'Ativo';
		update produtoTec;

		GarantiaProduto__c coberturaTec = new GarantiaProduto__c();
		coberturaTec.Garantia__c = garantia.Id;
		coberturaTec.Produto__c = produtoTec.Id; //
		coberturaTec.OrdemPrioridade__c = 1;
		coberturaTec.RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoTecnico').Id;
		coberturaTec.TipoCapital__c = 'Capital uniforme';
		coberturaTec.RamoSeguro__c = ramoVida.Id;
		coberturaTec.TipoGarantia__c = 'Cobertura';

		insert coberturaTec;
		
        //PLV-3046 - INICIO - Cadastro de Produto - Viagem
		LimiteGarantiaProduto__c limiteGarantiaProdutoTec = (LimiteGarantiaProduto__c) new LimiteGarantiaProdutoFactory(coberturaTec).createRecord();
		//PLV-3046 - FIM - Cadastro de Produto - Viagem
        
		PremioMinimoProduto__c premioMinimoTec = new PremioMinimoProduto__c(
            Produto__c = produtoTec.Id,
            FormaPagamento__c = formaPagamento.Id,
            PeriodicidadePagamento__c = 'Anual',
            TipoContratacao__c = 'Novo',
            PremioMinimoParcela__c = 100,
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('PremioMinimoProduto__c', 'ProdutoTecnico').Id
        );
        insert premioMinimoTec;

        CondicaoCobranca__c condicaoCobrancaTec = new CondicaoCobranca__c(
                Produto__c = produtoTec.Id,
                FormaPagamento__c = formaPagamento.Id,
                QuantidadeParcelas__c = '1;2'
        );
        insert condicaoCobrancaTec;

		Product2 produtoCom = new Product2();
		produtoCom.ProdutoTecnico__c = produtoTec.Id;
		produtoCom.Name = 'Nome ProdutoCom 001';
		produtoCom.Status__c = 'Em criação';
		produtoCom.ProductCode = '260';
		produtoCom.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id;
		produtoCom.VigenciaInicial__c = System.today();
		produtoCom.TipoResponsavelPagamento__c = 'PAR';
		insert produtoCom;

		produtoCom.Status__c = 'Em ativação';
		produtoCom.NumeroSusep__c = '1234x';
		update produtoCom;

		produtoCom.Status__c = 'Ativo';
		update produtoCom;

		GarantiaProduto__c coberturaCom1 = new GarantiaProduto__c();
		coberturaCom1.GarantiaProduto__c = coberturaTec.Id;
		coberturaCom1.Garantia__c = garantia.Id;
		coberturaCom1.Produto__c = produtoCom.Id; //
		coberturaCom1.OrdemPrioridade__c = 1;
		coberturaCom1.RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id;
		coberturaCom1.TipoCapital__c = 'Capital uniforme';
		coberturaCom1.RamoSeguro__c = ramoVida.Id;
		coberturaCom1.TipoGarantia__c = 'Cobertura';
		//PLV-3046 - INICIO
		coberturaCom1.LimiteCapitalMinimo__c = 20;
		coberturaCom1.LimiteCapitalMaximo__c = 900;
		coberturaCom1.currencyIsoCode = 'BRL';
		//PLV-3046 - FIM
		insert coberturaCom1;

		PremioMinimoProduto__c premioMinimoCom = new PremioMinimoProduto__c(
            Produto__c = produtoCom.Id,
            FormaPagamento__c = formaPagamento.Id,
            PeriodicidadePagamento__c = 'Anual',
            TipoContratacao__c = 'Novo',
            PremioMinimoParcela__c = 100,
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('PremioMinimoProduto__c', 'ProdutoComercial').Id
        );
        insert premioMinimoCom;

        CondicaoCobranca__c condicaoCobrancaCom = new CondicaoCobranca__c(
                Produto__c = produtoCom.Id,
                FormaPagamento__c = formaPagamento.Id,
                QuantidadeParcelas__c = '1;2'
        );
        insert condicaoCobrancaCom;

		//Cria configuracao
		Configuracao__c configuracao = new Configuracao__c(
			Name = 'Produto para macho',
			Segmento__c = 'Individual',
			Status__c = 'Em criação',
			VigenciaInicial__c = System.today().addDays(-2),
			VigenciaFinal__c = System.today().addDays(2)
		);
		insert configuracao;

		configuracao.Status__c = 'Em aprovação';
		update configuracao;

		configuracao.Status__c = 'Em ativação';
		update configuracao;

		configuracao.Status__c = 'Ativo';
		update configuracao;

		ProdutoConfiguracao__c produtoConf = new ProdutoConfiguracao__c(
			Configuracao__c = configuracao.Id,
			Produto__c = produtoCom.Id
		);
		insert produtoConf;

		GarantiaProdutoConfiguracao__c garantiaConf = new GarantiaProdutoConfiguracao__c(
			ProdutoConfiguracao__c = produtoConf.Id,
			GarantiaProduto__c = coberturaCom1.Id
		);
		insert garantiaConf;

		List<CriterioConfiguracao__c> criterios = new List<CriterioConfiguracao__c>{
			new CriterioConfiguracao__c(
				Configuracao__c = configuracao.Id,
				Campo__c = 'Account.Sexo__pc',
				Operador__c = 'Igual',
				Valor__c = 'Masculino'
			),
			new CriterioConfiguracao__c(
				Configuracao__c = configuracao.Id,
				Campo__c = 'Account.Profissao__pc',
				Operador__c = 'Igual',
				Valor__c = 'Programador'
			),
			new CriterioConfiguracao__c(
				Configuracao__c = configuracao.Id,
				Campo__c = 'Account.Renda__c',
				Operador__c = 'Maior',
				Valor__c = '1000.50'
			),
			new CriterioConfiguracao__c(
				Configuracao__c = configuracao.Id,
				Campo__c = 'Account.PersonBirthdate',
				Operador__c = 'Igual',
				Valor__c = '1990-03-13'
			),
			new CriterioConfiguracao__c(
				Configuracao__c = configuracao.Id,
				Campo__c = 'Opportunity.TipoSegurado__c',
				Operador__c = 'Contém',
				Valor__c = 'Alunos;Cooperados;PRI'
			)
		};
		insert criterios;

		return ProductBO.getInstance().buscarProdutos(new Set<Id>{produtoCom.Id}, true).get(0);
	}
}