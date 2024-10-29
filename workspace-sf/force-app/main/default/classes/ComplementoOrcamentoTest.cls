@isTest
private class ComplementoOrcamentoTest {

  @TestSetup
  static void testSetup(){
    TestDataFactory.gerarDadosSetup();
    // PLV-2312-28 INICIO
    TestDataFactory.gerarOrcamento(false);
    // PLV-2312-28 FIM
  }

  @isTest
  static void testarComponentePrincipal() {

    // Pega dados para os testes
    Opportunity orcamento = [SELECT Id FROM Opportunity];

    // Mock para callout
    String jsonSolicitacaoOferta =
            '{"solicitacaoOferta": null, "serasa": null, "retornoValidacaoProduto": null, "retornoAceitacao": null, "ofertas": [{"permiteTransmissao": "SIM", "parcelamentos": [{"valorDemaisParcelas": null, "valor1aParcela": null, "qtdParcelas": 1, "juros": 0, "iof": 0.38, "encargos": 0, "descricao": "1X - Cartao de Credito demais bandeiras", "custoapolice": 0, "codigo": 62 }, {"valorDemaisParcelas": null, "valor1aParcela": null, "qtdParcelas": 1, "juros": 0, "iof": 0.38, "encargos": 0, "descricao": "1X - Cartao Porto Seguro", "custoapolice": 0, "codigo": 97 } ], "origem": "PPW", "numeroPortal": 988444, "numero": 647658, "calculo": {"precificacao": {"taxa": {"puroResseguro": 0.97434, "puroInterno": 0.97435, "pura": 0.87443, "mensal": 0.74435, "comercial": 0.86434, "anual": 0.12344 }, "contratantes": [{"tipo": null, "taxa": {"puroResseguro": null, "puroInterno": null, "pura": 0.87443, "mensal": null, "comercial": 0.86434, "anual": null }, "premio": {"puroResseguro": null, "puroInterno": null, "puroDesconto": null, "puro": 8.0834, "comercialDesconto": null, "comercial": 3.09834 }, "pessoa": null, "objSf": null, "numero": 1, "idSf": null, "grupos": [{"segurados": [{"taxa": {"puroResseguro": null, "puroInterno": null, "pura": 0.87443, "mensal": null, "comercial": 0.86434, "anual": null }, "premio": {"puroResseguro": null, "puroInterno": null, "puroDesconto": null, "puro": 8.0834, "comercialDesconto": null, "comercial": 3.09834 }, "objSf": null, "numeroCpf": null, "numero": 1, "nome": null, "digitoCpf": null, "dataNascimento": null, "coberturas": [{"valorDescontoAgravo": null, "valor": null, "taxa": {"puroResseguro": null, "puroInterno": null, "pura": 0.87443, "mensal": null, "comercial": 0.86434, "anual": null }, "sigla": "MAP", "quantidade": null, "premio": {"puroResseguro": null, "puroInterno": null, "puroDesconto": null, "puro": 8.0834, "comercialDesconto": null, "comercial": 3.09834 }, "percentualIndenizacaoEspecial": null, "percentualFilhos": null, "percentual": null, "objSf": null, "moeda": null, "inclusaoIndenizacaoEspecial": null, "inclusaoFilhos": null, "idSf": null, "idGarantiaProdutoSf": null, "garantiaSf": null, "garantiaReferenciada": null, "garantiaProdutoSf": null, "garantiaOrcamentoSf": null, "escolhaDescontoAgravo": null, "desconto": null, "clausulaReducaoFranquiaAcidente": null, "capital": 737456.95, "agravo": null } ], "cid": null, "afastado": null }, {"taxa": {"puroResseguro": null, "puroInterno": null, "pura": 0.87443, "mensal": null, "comercial": 0.86434, "anual": null }, "premio": {"puroResseguro": null, "puroInterno": null, "puroDesconto": null, "puro": 8.0834, "comercialDesconto": null, "comercial": 3.09834 }, "objSf": null, "numeroCpf": null, "numero": 2, "nome": null, "digitoCpf": null, "dataNascimento": null, "coberturas": [{"valorDescontoAgravo": null, "valor": null, "taxa": {"puroResseguro": null, "puroInterno": null, "pura": 0.87443, "mensal": null, "comercial": 0.86434, "anual": null }, "sigla": "MAP", "quantidade": null, "premio": {"puroResseguro": null, "puroInterno": null, "puroDesconto": null, "puro": 8.0834, "comercialDesconto": null, "comercial": 3.09834 }, "percentualIndenizacaoEspecial": null, "percentualFilhos": null, "percentual": null, "objSf": null, "moeda": null, "inclusaoIndenizacaoEspecial": null, "inclusaoFilhos": null, "idSf": null, "idGarantiaProdutoSf": null, "garantiaSf": null, "garantiaReferenciada": null, "garantiaProdutoSf": null, "garantiaOrcamentoSf": null, "escolhaDescontoAgravo": null, "desconto": null, "clausulaReducaoFranquiaAcidente": null, "capital": 737456.95, "agravo": null } ], "cid": null, "afastado": null }, {"taxa": {"puroResseguro": null, "puroInterno": null, "pura": 0.87443, "mensal": null, "comercial": 0.86434, "anual": null }, "premio": {"puroResseguro": null, "puroInterno": null, "puroDesconto": null, "puro": 8.0834, "comercialDesconto": null, "comercial": 3.09834 }, "objSf": null, "numeroCpf": null, "numero": 3, "nome": null, "digitoCpf": null, "dataNascimento": null, "coberturas": [{"valorDescontoAgravo": null, "valor": null, "taxa": {"puroResseguro": null, "puroInterno": null, "pura": 0.87443, "mensal": null, "comercial": 0.86434, "anual": null }, "sigla": "MAP", "quantidade": null, "premio": {"puroResseguro": null, "puroInterno": null, "puroDesconto": null, "puro": 8.0834, "comercialDesconto": null, "comercial": 3.09834 }, "percentualIndenizacaoEspecial": null, "percentualFilhos": null, "percentual": null, "objSf": null, "moeda": null, "inclusaoIndenizacaoEspecial": null, "inclusaoFilhos": null, "idSf": null, "idGarantiaProdutoSf": null, "garantiaSf": null, "garantiaReferenciada": null, "garantiaProdutoSf": null, "garantiaOrcamentoSf": null, "escolhaDescontoAgravo": null, "desconto": null, "clausulaReducaoFranquiaAcidente": null, "capital": 737456.95, "agravo": null } ], "cid": null, "afastado": null } ], "valorDoBem": null, "valorDescontoAgravo": null, "tipoSegurado": null, "tipoCalculo": null, "taxa": {"puroResseguro": null, "puroInterno": null, "pura": 0.87443, "mensal": null, "comercial": 0.86434, "anual": null }, "saldoDevedor": null, "qtdeVidas": null, "premio": {"puroResseguro": null, "puroInterno": null, "puroDesconto": null, "puro": 8.0834, "comercialDesconto": null, "comercial": 3.09834 }, "prazoMaximoFinanciamentoPrestamista": null, "objSf": null, "numero": 1, "nome": null, "idSf": null, "idArquivoVidas": null, "escolhaDescontoAgravo": null, "desconto": null, "coberturas": [{"valorDescontoAgravo": null, "valor": null, "taxa": {"puroResseguro": null, "puroInterno": null, "pura": 0.87443, "mensal": null, "comercial": 0.86434, "anual": null }, "sigla": "MAP", "quantidade": null, "premio": {"puroResseguro": null, "puroInterno": null, "puroDesconto": null, "puro": 8.0834, "comercialDesconto": null, "comercial": 3.09834 }, "percentualIndenizacaoEspecial": null, "percentualFilhos": null, "percentual": null, "objSf": null, "moeda": null, "inclusaoIndenizacaoEspecial": null, "inclusaoFilhos": null, "idSf": null, "idGarantiaProdutoSf": null, "garantiaSf": null, "garantiaReferenciada": null, "garantiaProdutoSf": null, "garantiaOrcamentoSf": null, "escolhaDescontoAgravo": null, "desconto": null, "clausulaReducaoFranquiaAcidente": null, "capital": 737456.95, "agravo": null } ], "agravo": null } ], "contaSf": null, "coberturas": [{"valorDescontoAgravo": null, "valor": null, "taxa": {"puroResseguro": null, "puroInterno": null, "pura": 0.87443, "mensal": null, "comercial": 0.86434, "anual": null }, "sigla": "MAP", "quantidade": null, "premio": {"puroResseguro": null, "puroInterno": null, "puroDesconto": null, "puro": 8.0834, "comercialDesconto": null, "comercial": 3.09834 }, "percentualIndenizacaoEspecial": null, "percentualFilhos": null, "percentual": null, "objSf": null, "moeda": null, "inclusaoIndenizacaoEspecial": null, "inclusaoFilhos": null, "idSf": null, "idGarantiaProdutoSf": null, "garantiaSf": null, "garantiaReferenciada": null, "garantiaProdutoSf": null, "garantiaOrcamentoSf": null, "escolhaDescontoAgravo": null, "desconto": null, "clausulaReducaoFranquiaAcidente": null, "capital": 737456.95, "agravo": null } ] } ], "premio": {"puroResseguro": 1.97434, "puroInterno": 7.97435, "puroDesconto": 7.8643, "puro": 8.0834, "comercialDesconto": 2.75435, "comercial": 3.09834 }, "juros": 0.0, "iof": 0.0038, "encargos": 0.0, "custoApolice": 0.0, "coberturas": [{"valorDescontoAgravo": null, "valor": null, "taxa": {"puroResseguro": 0.97434, "puroInterno": 0.97435, "pura": 0.87443, "mensal": null, "comercial": 0.86434, "anual": null }, "sigla": "MAP", "quantidade": null, "premio": {"puroResseguro": 0.97434, "puroInterno": 0.97435, "puroDesconto": null, "puro": 8.0834, "comercialDesconto": null, "comercial": 3.09834 }, "percentualIndenizacaoEspecial": null, "percentualFilhos": null, "percentual": null, "objSf": null, "moeda": null, "inclusaoIndenizacaoEspecial": null, "inclusaoFilhos": null, "idSf": null, "idGarantiaProdutoSf": null, "garantiaSf": null, "garantiaReferenciada": null, "garantiaProdutoSf": null, "garantiaOrcamentoSf": null, "escolhaDescontoAgravo": null, "desconto": null, "clausulaReducaoFranquiaAcidente": null, "capital": 737456.95, "agravo": null } ] }, "analiseAtuarial": {"contratantes": [{"segurados": null, "estatistica": null, "analitica": null, "numero": 1, "grupos": [{"segurados": null, "estatistica": null, "analitica": null, "numero": 1, "grupos": null, "estatistica": {"status": [{"status": null, "severidade": null, "quantidade": 13, "procedimento": null, "mensagens": null, "descricao": null, "codigo": null, "area": null }, {"status": null, "severidade": null, "quantidade": 1, "procedimento": null, "mensagens": null, "descricao": null, "codigo": null, "area": null }, {"status": null, "severidade": null, "quantidade": 0, "procedimento": null, "mensagens": null, "descricao": null, "codigo": null, "area": null } ], "faixaEtaria": [{"tipo": "FXA", "quantidade": 7, "percentual": 100.0, "mediaCapital": 400000.0, "capital": 400000.0, "inicioFaixa": 18, "finalFaixa": 40 }, {"tipo": "FXA", "quantidade": 8, "percentual": 100.0, "mediaCapital": 400000.0, "capital": 400000.0, "inicioFaixa": 40, "finalFaixa": 60 }, {"tipo": "TOT", "quantidade": 15, "percentual": 100.0, "mediaCapital": 400000.0, "capital": 400000.0, "inicioFaixa": null, "finalFaixa": null } ], "faixaCapital": [{"tipo": "FXA", "quantidade": 13, "percentual": 100.0, "mediaCapital": 400000.0, "capital": 5200000000.0, "inicioFaixa": null, "finalFaixa": 400000.0 }, {"tipo": "FXA", "quantidade": 1, "percentual": 100.0, "mediaCapital": 2000000.0, "capital": 200000000.0, "inicioFaixa": 400000.0, "finalFaixa": null }, {"tipo": "TOT", "quantidade": 13, "percentual": 100.0, "mediaCapital": 400000.0, "capital": 5200000000.0, "inicioFaixa": null, "finalFaixa": null } ] }, "analitica": {"taxaModelagem": 0.89743, "quantidadeVidas": 23, "publicoMasculino": 53.09, "publicoFeminino": 43.05, "percentualDescontoModelagem": -95.9854, "idadeMediaPonderadaPorIS": 54.95, "idadeMediaPonderada": 24.054, "idadeMediaAtuarial": 35.94, "idadeMediaAritmetica": 43.54, "expectativaSinistrosAnual": 0.007543, "capitalPonderadoPorExpectativaSinistro": 10249.07, "capitalMedio": 43205444.99 } } ], "estatistica": {"status": [{"status": null, "severidade": null, "quantidade": 13, "procedimento": null, "mensagens": null, "descricao": null, "codigo": null, "area": null }, {"status": null, "severidade": null, "quantidade": 1, "procedimento": null, "mensagens": null, "descricao": null, "codigo": null, "area": null }, {"status": null, "severidade": null, "quantidade": 0, "procedimento": null, "mensagens": null, "descricao": null, "codigo": null, "area": null } ], "faixaEtaria": [{"tipo": "FXA", "quantidade": 7, "percentual": 100.0, "mediaCapital": 400000.0, "capital": 400000.0, "inicioFaixa": 18, "finalFaixa": 40 }, {"tipo": "FXA", "quantidade": 8, "percentual": 100.0, "mediaCapital": 400000.0, "capital": 400000.0, "inicioFaixa": 40, "finalFaixa": 60 }, {"tipo": "TOT", "quantidade": 15, "percentual": 100.0, "mediaCapital": 400000.0, "capital": 400000.0, "inicioFaixa": null, "finalFaixa": null } ], "faixaCapital": [{"tipo": "FXA", "quantidade": 13, "percentual": 100.0, "mediaCapital": 400000.0, "capital": 5200000000.0, "inicioFaixa": null, "finalFaixa": 400000.0 }, {"tipo": "FXA", "quantidade": 1, "percentual": 100.0, "mediaCapital": 2000000.0, "capital": 200000000.0, "inicioFaixa": 400000.0, "finalFaixa": null }, {"tipo": "TOT", "quantidade": 13, "percentual": 100.0, "mediaCapital": 400000.0, "capital": 5200000000.0, "inicioFaixa": null, "finalFaixa": null } ] }, "analitica": {"taxaModelagem": 0.89743, "quantidadeVidas": 23, "publicoMasculino": 53.09, "publicoFeminino": 43.05, "percentualDescontoModelagem": -95.9854, "idadeMediaPonderadaPorIS": 54.95, "idadeMediaPonderada": 24.054, "idadeMediaAtuarial": 35.94, "idadeMediaAritmetica": 43.54, "expectativaSinistrosAnual": 0.007543, "capitalPonderadoPorExpectativaSinistro": 10249.07, "capitalMedio": 43205444.99 } } ], "estatistica": {"status": [{"status": null, "severidade": null, "quantidade": 13, "procedimento": null, "mensagens": null, "descricao": null, "codigo": null, "area": null }, {"status": null, "severidade": null, "quantidade": 1, "procedimento": null, "mensagens": null, "descricao": null, "codigo": null, "area": null }, {"status": null, "severidade": null, "quantidade": 0, "procedimento": null, "mensagens": null, "descricao": null, "codigo": null, "area": null } ], "faixaEtaria": [{"tipo": "FXA", "quantidade": 7, "percentual": 100.0, "mediaCapital": 400000.0, "capital": 400000.0, "inicioFaixa": 18, "finalFaixa": 40 }, {"tipo": "FXA", "quantidade": 8, "percentual": 100.0, "mediaCapital": 400000.0, "capital": 400000.0, "inicioFaixa": 40, "finalFaixa": 60 }, {"tipo": "TOT", "quantidade": 15, "percentual": 100.0, "mediaCapital": 400000.0, "capital": 400000.0, "inicioFaixa": null, "finalFaixa": null } ], "faixaCapital": [{"tipo": "FXA", "quantidade": 13, "percentual": 100.0, "mediaCapital": 400000.0, "capital": 5200000000.0, "inicioFaixa": null, "finalFaixa": 400000.0 }, {"tipo": "FXA", "quantidade": 1, "percentual": 100.0, "mediaCapital": 2000000.0, "capital": 200000000.0, "inicioFaixa": 400000.0, "finalFaixa": null }, {"tipo": "TOT", "quantidade": 13, "percentual": 100.0, "mediaCapital": 400000.0, "capital": 5200000000.0, "inicioFaixa": null, "finalFaixa": null } ] }, "analitica": {"taxaModelagem": 0.89743, "quantidadeVidas": 23, "publicoMasculino": 53.09, "publicoFeminino": 43.05, "percentualDescontoModelagem": -95.9854, "idadeMediaPonderadaPorIS": 54.95, "idadeMediaPonderada": 24.054, "idadeMediaAtuarial": 35.94, "idadeMediaAritmetica": 43.54, "expectativaSinistrosAnual": 0.007543, "capitalPonderadoPorExpectativaSinistro": 10249.07, "capitalMedio": 43205444.99 } } } } ], "oferta": null, "mensagem": null, "licitacoes": null, "indiceMonetario": [{"valor": null, "moeda": null } ], "guiaPostal": null, "erro": null }';

    Test.setMock(HttpCalloutMock.class, new MockHttpResponse(jsonSolicitacaoOferta, 200, 'OK'));

    Test.startTest();

    // Roda os métodos
    String mensagemErro = ComplementoOrcamentoController.calcularOrcamento(orcamento.id);
    Opportunity orcamentoRetorno = ComplementoOrcamentoController.buscarOportunidade(orcamento.Id);

    // Testa buscarOportunidade
    System.assert(orcamentoRetorno.Id != null);

    // Testa calcularOrcamento
    System.assert(mensagemErro == null);     //MGRC-1657 - INICIO/FIM

    Test.stopTest();

  }

  @isTest
  static void testarComponenteComplemento() {
    //Verifica se de acordo com um produto, encontrará o conjunto de campos relacionado
    //OBS: o código 5, é utilizado pelo FieldSet criado para ser utilizado nesta classe.
    String jsonFieldSet = ComplementoOrcamentoController.buscarFieldSetProduto('5','Opportunity');
    List<Object> campos = (List<Object>)JSON.deserializeUntyped(jsonFieldSet);

    System.assert(!campos.isEmpty());
  }

  @isTest
  static void testarComponenteGarantias() {

    // Busca o orcamento para o teste
    Opportunity orcamento = [SELECT Id FROM Opportunity];

    // Pega um produto comercial
    Product2 produtoComercial = [SELECT Id FROM Product2 WHERE RecordType.DeveloperName = 'ProdutoComercial'];

    // Pega um GrupoOrcamento
    GrupoOrcamento__c grupoOrcamento = [SELECT Id FROM GrupoOrcamento__c];

    // Pega uma garantia do Produto
    GarantiaProduto__c garantiaProdutoComercial = [SELECT Id FROM GarantiaProduto__c WHERE RecordType.DeveloperName = 'ProdutoComercial' LIMIT 1];

    List<SObject> listSObjectsParaApagar = new List<SObject>();
    // Pega GarantiaGrupoOrcamento para deletar
    GarantiaGrupoOrcamento__c garantiaGrupoOrcamentoParaApagar = new GarantiaGrupoOrcamento__c(
        Capital__c = 321.91,
        GrupoOrcamento__c = grupoOrcamento.Id,
        GarantiaProduto__c = garantiaProdutoComercial.Id
    );
    insert garantiaGrupoOrcamentoParaApagar;
    listSObjectsParaApagar.add(garantiaGrupoOrcamentoParaApagar);

    // Cria GarantiaGrupoOrcamento
    List<SObject> listSObjects = new List<SObject>();
    GarantiaGrupoOrcamento__c garantiaGrupoOrcamento = new GarantiaGrupoOrcamento__c(
        Capital__c = 673.98,
        GrupoOrcamento__c = grupoOrcamento.Id,
        GarantiaProduto__c = garantiaProdutoComercial.Id
    );
    listSObjects.add(garantiaGrupoOrcamento);

    Test.startTest();
    // Roda o buscarGarantiasProdutos
    List<GarantiaProduto__c> listGarantiaProduto = ComplementoOrcamentoController.buscarGarantiasProdutos(produtoComercial.Id);
    // Roda o buscarSeguradosOrcamento
    List<ContratanteOrcamento__c> listContratanteOrcamento = ComplementoOrcamentoController.buscarContratantesOrcamento(orcamento.Id);
    // Roda o buscarGarantiasGrupoVida
    List<GarantiaGrupoOrcamento__c> listGarantiaGrupoOrcamento2 = ComplementoOrcamentoController.buscarGarantiasGrupoOrcamento(grupoOrcamento.Id);
    // Roda o salvarDadosAbaGarantias
    ComplementoOrcamentoController.salvarDadosAbaGarantias(listSObjects, listSObjectsParaApagar);

    Test.stopTest();

    // Testa buscarGarantiasProdutos
    System.assert(listGarantiaProduto.size() > 0);
    // Testa buscarSeguradosOrcamento
    System.assert(listContratanteOrcamento.size() > 0);
    // Testa buscarGarantiasGrupoVida
    System.assert(listGarantiaGrupoOrcamento2.size() > 0);
    // Testa salvarDadosAbaGarantias
    GarantiaGrupoOrcamento__c garantiaGrupoOrcamentoClone = [SELECT Id FROM GarantiaGrupoOrcamento__c WHERE Capital__c = 673.98];
    System.assert(garantiaGrupoOrcamentoClone != null);
    // Testa salvarDadosAbaGarantias
    List<GarantiaGrupoOrcamento__c> listGarantiaGrupoOrcamentoCloneParaApagar = [SELECT Id FROM GarantiaGrupoOrcamento__c WHERE Id =: garantiaGrupoOrcamentoParaApagar.Id];
    System.assert(listGarantiaGrupoOrcamentoCloneParaApagar.isEmpty());
  }

  @isTest
  static void testarComponenteInfoComplementares() {
    // Busca o orcamento para o teste
    Opportunity orcamento = [SELECT Id FROM Opportunity];
    orcamento.Name = 'Novo Orcamento';

    // Trabalha uma garantia do Grupo do orcamento para atualizar
    List<SObject> listSObjects = new List<SObject>();
    List<GarantiaGrupoOrcamento__c> listGarantiaGrupoOrcamento = [SELECT Id,Capital__c FROM GarantiaGrupoOrcamento__c];
    GarantiaGrupoOrcamento__c garantiaGrupoOrcamento = (GarantiaGrupoOrcamento__c) listGarantiaGrupoOrcamento[0];
    garantiaGrupoOrcamento.Capital__c = 9876.98;
    listSObjects.addAll(listGarantiaGrupoOrcamento);

    Test.startTest();

    // roda o buscarGarantiasOrcamento
    String jsonString = ComplementoOrcamentoController.buscarGarantiasOrcamento(orcamento.Id);
    OrcamentoTO orcamentoTO = (OrcamentoTO) JSON.deserialize(jsonString, OrcamentoTO.class);

    // Roda o atualizarGarantiasDoGrupoDoOrcamento
    ComplementoOrcamentoController.atualizarGarantiasDoGrupoDoOrcamento(listSObjects, orcamento.Id);
    GarantiaGrupoOrcamento__c garantiaGrupoOrcamento2 = [SELECT Id, Capital__c FROM GarantiaGrupoOrcamento__c WHERE Id =: listGarantiaGrupoOrcamento[0].Id LIMIT 1];

    // Roda o atualizaOportunidade
    ComplementoOrcamentoController.atualizaOportunidade(orcamento);

    // Valida buscarGarantiasOrcamento
    System.assert(orcamentoTO.oferta.calculo.precificacao.coberturas.size() > 0);
    // Valida atualizarGarantiasDoGrupoDoOrcamento
    System.assert(garantiaGrupoOrcamento2.Capital__c == 9876.98);

    Opportunity orcamento2 = [SELECT Id, DataCalculo__c FROM Opportunity WHERE Id =: orcamento.Id];
    System.assert(orcamento2.DataCalculo__c == System.today());
    // Valida atualizaOportunidade
    Opportunity orcamentoAtualizado = [SELECT Id,Name FROM Opportunity];
    System.assert(orcamentoAtualizado.Name == 'Novo Orcamento');

    Test.stopTest();
  }

  @IsTest
  static void testValidarCalcularOrcamento(){
    Opportunity orcamento = [SELECT Id,Produto__c FROM Opportunity LIMIT 1];

    // Declara Sets
    set<Id> setTipoRemuneracaoParaCriar = new Set<Id>();
    set<Id> setTipoRemuneracaoObrigatorias = new Set<Id>();
    set<Id> setTipoRemuneracaoOrcamento = new Set<Id>();

    // Recupera as remuneracoes do produto obrigatorias
    for(RemuneracaoProduto__c remuneracaoProduto :
    [SELECT Id,TipoRemuneracao__c,Obrigatoria__c FROM RemuneracaoProduto__c WHERE Produto__c =: orcamento.Produto__c]){
      if(remuneracaoProduto.Obrigatoria__c) setTipoRemuneracaoObrigatorias.add(remuneracaoProduto.TipoRemuneracao__c);
    }

    // recupera as remuneracoes do orcamento
    for(RemuneracaoOrcamento__c remuneracaoOrcamento : [SELECT Id,TipoRemuneracao__c FROM RemuneracaoOrcamento__c WHERE Oportunidade__c =: orcamento.Id]){
      setTipoRemuneracaoOrcamento.add(remuneracaoOrcamento.TipoRemuneracao__c);
    }

    // verifica se o orcamento tem as remuneracoes obrigatorias
    for(Id tipoRemuneracaoObrigatoriaId : setTipoRemuneracaoObrigatorias){
      if(!setTipoRemuneracaoOrcamento.contains(tipoRemuneracaoObrigatoriaId)) setTipoRemuneracaoParaCriar.add(tipoRemuneracaoObrigatoriaId);
    }

    // Cria as remuneracoes do orcamento que o produto solicita
    for(Id tipoRemuneracaoId : setTipoRemuneracaoParaCriar){
      TipoRemuneracao__c tipoRemuneracao = new TipoRemuneracao__c(Id = tipoRemuneracaoId);
      TestDataFactory.gerarRemuneracaoOrcamento(orcamento,tipoRemuneracao);
    }

    Test.startTest();
    String msgRetorno = ComplementoOrcamentoController.validarCalcularOrcamento(orcamento.Id);
    Test.stopTest();

    System.debug('msgRetorno ========= ' + msgRetorno);

    // Valida se nao retornou mensagem de erro
    System.assert(msgRetorno == null);
  }

  @IsTest
  static void testValidarCalcularOrcamentoSemProduto(){
    Opportunity orcamento = [SELECT Id,Produto__c FROM Opportunity LIMIT 1];
    String mensagemEsperada = 'Produto não informado!';

    Product2 produto = new Product2(Id = orcamento.Produto__c);
    delete produto;

    Test.startTest();
    String msgRetorno = ComplementoOrcamentoController.validarCalcularOrcamento(orcamento.Id);
    Test.stopTest();

    // Valida se nao retornou mensagem de erro
    System.assertEquals(mensagemEsperada,msgRetorno);
  }

  @IsTest
  static void testValidarCalcularOrcamentoSemRemuneracaoProduto(){
    Opportunity orcamento = [SELECT Id,Produto__c FROM Opportunity LIMIT 1];
    String mensagemEsperada = 'Remuneração do produto não informada!';

    List<RemuneracaoProduto__c> listRemuneracaoProduto = [
        SELECT Id FROM RemuneracaoProduto__c WHERE Produto__c =: orcamento.Produto__c
    ];
    delete listRemuneracaoProduto;

    Test.startTest();
    String msgRetorno = ComplementoOrcamentoController.validarCalcularOrcamento(orcamento.Id);
    Test.stopTest();

    // Valida se nao retornou mensagem de erro
    System.assertEquals(mensagemEsperada,msgRetorno);
  }

  @IsTest
  static void testValidarCalcularOrcamentoSemRemuneracaoOrcamento(){
    Opportunity orcamento = [SELECT Id,Produto__c,(SELECT Id FROM RemuneracoesOrcamento__r) FROM Opportunity LIMIT 1];
    String mensagemEsperada = 'Remuneração não informada!';

    List<RemuneracaoOrcamento__c> listRemuneracaoOrcamento = orcamento.RemuneracoesOrcamento__r;
    delete listRemuneracaoOrcamento;

    Test.startTest();
    String msgRetorno = ComplementoOrcamentoController.validarCalcularOrcamento(orcamento.Id);
    Test.stopTest();

    // Valida se nao retornou mensagem de erro
    System.assertEquals(mensagemEsperada,msgRetorno);
  }

  @IsTest
  static void testValidarCalcularOrcamentoSemSeguradoOrcamento(){
    Opportunity orcamento = [SELECT Id,Produto__c,(SELECT Id FROM ContratantesOrcamento__r) FROM Opportunity LIMIT 1];
    String mensagemEsperada = 'Informar ao menos um segurado';

    List<ContratanteOrcamento__c> listContratanteOrcamento = orcamento.ContratantesOrcamento__r;
    delete listContratanteOrcamento;

    Test.startTest();
    String msgRetorno = ComplementoOrcamentoController.validarCalcularOrcamento(orcamento.Id);
    Test.stopTest();

    // Valida se nao retornou mensagem de erro
    System.assertEquals(mensagemEsperada,msgRetorno);
  }

  @IsTest
  static void testValidarCalcularOrcamentoSemSeguradoPrincipalNoOrcamento(){
    Opportunity orcamento = [SELECT Id,Produto__c,(SELECT Id, Tipo__c FROM ContratantesOrcamento__r) FROM Opportunity LIMIT 1];
    String mensagemEsperada = 'Segurado principal não informado!';

    List<ContratanteOrcamento__c> listContratanteOrcamento = new List<ContratanteOrcamento__c>();
    for(ContratanteOrcamento__c seguradoOrcamento : orcamento.ContratantesOrcamento__r){
      seguradoOrcamento.Tipo__c = 'Dependente';
      listContratanteOrcamento.add(seguradoOrcamento);
    }
    update listContratanteOrcamento;

    Test.startTest();
    String msgRetorno = ComplementoOrcamentoController.validarCalcularOrcamento(orcamento.Id);
    Test.stopTest();

    // Valida se nao retornou mensagem de erro
    System.assertEquals(mensagemEsperada,msgRetorno);
  }

  @IsTest
  static void testValidarCalcularOrcamentoSemRemuneracaoProdutoObrigatoria(){
    Opportunity orcamento = [SELECT Id,Produto__c FROM Opportunity LIMIT 1];
    String mensagemEsperada = 'Não há remuneração obrigatória no produto!';

    List<RemuneracaoProduto__c> listRemuneracaoProduto = new List<RemuneracaoProduto__c>();
    for(RemuneracaoProduto__c remuneracaoProduto : [
        SELECT Id FROM RemuneracaoProduto__c WHERE Produto__c =: orcamento.Produto__c
    ]){
      remuneracaoProduto.Obrigatoria__c = false;
      listRemuneracaoProduto.add(remuneracaoProduto);
    }
    update listRemuneracaoProduto;

    Test.startTest();
    String msgRetorno = ComplementoOrcamentoController.validarCalcularOrcamento(orcamento.Id);
    Test.stopTest();

    // Valida se nao retornou mensagem de erro
    System.assertEquals(mensagemEsperada,msgRetorno);
  }

  @IsTest
  static void testValidarCalcularOrcamentoSemRemuneracaoOrcamentoObrigatoria(){
    Opportunity orcamento = [SELECT Id,Produto__c,(SELECT Id FROM RemuneracoesOrcamento__r) FROM Opportunity LIMIT 1];
    String mensagemEsperada = 'Remuneração obrigatória não informada no orçamento!';

    List<RemuneracaoOrcamento__c> listRemuneracaoOrcamento = orcamento.RemuneracoesOrcamento__r;
    delete listRemuneracaoOrcamento;

    TipoRemuneracao__c tipoRemuneracao = [SELECT Id FROM TipoRemuneracao__c WHERE Name ='COMISSÃO' LIMIT 1];
    RemuneracaoOrcamento__c remuneracaoOrcamento  = TestDataFactory.gerarRemuneracaoOrcamento(orcamento,tipoRemuneracao);

    Test.startTest();
    String msgRetorno = ComplementoOrcamentoController.validarCalcularOrcamento(orcamento.Id);
    Test.stopTest();

    // Valida se nao retornou mensagem de erro
    System.assertEquals(mensagemEsperada,msgRetorno);
  }
}