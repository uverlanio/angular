/*********************************************************************************************************************************************************************

@description  Classe que contem a Controller para o Trasmissão(Proposta).
@author Renan Martins - Avanxo
@date 26/06/2019
@Hackathon Sniper Atualização 26/06/2019
@Classe criada por conta da história PLV-2389
        
**********************************************************************************************************************************************************************/

@isTest
public class PropostaSniperTest {
       //RVI-39 - INICIO
      @TestSetup
      static void setUp(){
         Account contaTeste = new Account(
                Name = 'Conta 41',
                CodigoEmpresa__c = '214',
                IdExterno__c = '13143510000160',
                Papel__c = 'Parceiro',
                Sexo__c = 'Masc',
                Cpf__c = '76466318095',
                Pis__c = '123456789', // PLV-4445
                Cnpj__c = '13.143.510/0001-60',
                Inscricao_Municipal__c = '123456789', // PLV-4445
                Nacionalidade__c = 'Brasileira',
                EstadoCivil__c = 'Casado (a)',
                Email__c = 'teste@teste.com.br'
        );
        insert contaTeste;
        
        RamoSeguro__c ramoSegurado = new RamoSeguro__c(
                Name = 'SEGURO VIAGEM',  //AV-85 FIX 05 INICIO-FIM
                CodigoEmpresa__c = '214',
                Codigo__c = '2',
                Empresa__c = contaTeste.Id,
                Status__c = 'Ativo',
                CodigoOrigemDoMovimentoBCP__c = '32'
        );
        insert ramoSegurado;
        
        //cria modalidade
        Modalidade__c modalidade = new Modalidade__c(
                RamoSeguro__c = ramoSegurado.Id,
                Name = 'SEGURO VIAGEM', //AV-85 FIX 05 INICIO-FIM
                Codigo__c = '0'
        );
        insert modalidade;

        //cria forma de pagamento
        FormaPagamento__c formaPagamento = new FormaPagamento__c(
                Codigo__c = '41',
                Name = 'FRAC.1.A PARCELA CARNE',
                RamoSeguro__c = ramoSegurado.id,
                Modalidade__c = modalidade.id
        );

        insert formaPagamento;
        //RVI-39 - INICIO
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);
        Garantia__c garantia1 = TestDataFactory.gerarGarantia();
        
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
	    ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        produtoTec.Status__c = 'Ativo';
        produtoTec.Empresa__c = contaTeste.Id;
        update produtoTec;
        
        Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        produtoCom.Status__c ='ativo';
        produtoCom.Empresa__c = contaTeste.Id;
        update produtoCom;
        
        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        canalDistribuicao.Status__c = 'Ativo';
        update canalDistribuicao;
        
        //TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao('COR', 100, 200, null);
        
        Opportunity orcamento = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        orcamento.Numero__c = '00529857';
        update orcamento;
        //RVI-39 - FIM
      }


        @isTest
     static void testPropostaSnipper() {
         
         test.startTest();
         
         //Referente a Pagina PropostaSniper
         //Chamada do Método do transmissaoContratacao
         
         String	XmlProposta = +'{'+
                                +'"proposta":{'+
                                  +'  "origem":18,'+
                                  +'  "numero":243855,'+
                                  +'  "status":"Disponível para Contratação",'+
                                  +'  "numeroOrcamento":647658,'+
                                  +'  "empresa":1,'+
                                  +'  "sucursal":13,'+
                                  +'  "ramo":1377,'+
                                  +'  "apolice":874433,'+
                                  +'  "tipoSeguro":"Novo",'+
                                  +'  "vigenciaInicial":"2016-09-23",'+
                                  +'  "vigenciaFinal":"2016-09-30",'+
                                  +'  "dataCalculo":"2019-01-19",'+
                                  +'  "dataTransmissao":"2019-01-19",'+
                                  +'  "dataEmissao":"2019-01-19",'+
                                  +'  "meioComercializacao":"Portal",'+
                                  +'  "qtdDiasVigencia":365'+
                               +' }'+
                            +'}';
         Test.setMock(HttpCalloutMock.class, new MockHttpResponse(XmlProposta, 200, 'OK'));  
         
         CtrPropostaSniper testeSnipper = new CtrPropostaSniper();  
        testeSnipper.opServico = '';
        testeSnipper.servicosEntrada = '';
        testeSnipper.entradaTransmissao = '{"propostas":[{"indice":1,"codigoEmpresa":1,"numeroOrcamento":"00529857","numeroPortal":0,"origem":18,"ramoSeguro":1391,"tipoSeguro":"Novo","entradaNegocio":"COR","dataProtocolo":"2022-04-19","meioComercializacao":"SFC","codigoProdutoVida":"VI-PESSOAS","contratantes":[{"tipo":"PRI","numero":1,"grupos":[{"numero":1,"segurados":[{"pessoa":{"tipo":"FIS","enderecos":[{"tipoEndereco":"RESIDENCIAL","logradouro":"Luís Gama","numeroLogradouro":52,"bairro":"Jardim Monções","cidade":"Santo André","uf":"SP","cep":"09180","complemento":"","complementoCep":"320"},{"tipoEndereco":"COMERCIAL","logradouro":"","numeroLogradouro":null,"bairro":"","cidade":"","uf":"","cep":"","complemento":""}],"nome":"CLIENTE TESTE AAEFCF","dadosPessoaFisica":{"grupoProfissao":"DIT-A","cicloVacinal":"1","profissao":"2111-05","temDependentes":true,"tipoContrato":"VOCE","tempoGarantiaRenda":"48","dataNascimento":"1988-01-01T00:00:00.000Z","sexo":"MASCULINO","fumante":false,"regimeTrabalho":"CLT","numeroCpf":"000004526","digitoCpf":"88","estadoCivil":"CASADO","nacionalidade":"BRASILEIRA","tipoDocIdentificacao":"rg","docIdentificacao":"38.269.469-2","orgaoExpedidor":"SSP","dataExpedicao":"2020-07-01","idade":34,"paisResidente":"Brasil","DataUltimaVacina":null,"paisDeOrigem":"","resideBrasil":true},"email":"teste@teste.com.br","rendaMensal":"2222.00","telefones":[{"tipoTelefone":"CEL","numeroTelefone":"111111111","dddTelefone":"11"},{"tipoTelefone":"RES","numeroTelefone":"222222222","dddTelefone":"22"}],"melhorPeriodo":"I","pessoaExpostaPoliticamente":"Nao"},"numero":1,"coberturas":[{"franquia":"FR_DIH","sigla":"DIH","moeda":"BRL","limitemaximo":1000,"caracteristica":"Adicional","valor":100,"tipoprotecao":"Renda","caracteristicaespecialvalor":30,"limiteminimo":50,"caracteristicaespecialtipo":"Dia(s)"},{"franquia":null,"sigla":"AFF","moeda":"BRL","limitemaximo":20000,"caracteristica":"Adicional","valor":10000,"tipoprotecao":"Família","caracteristicaespecialvalor":null,"limiteminimo":5000,"caracteristicaespecialtipo":null},{"franquia":null,"sigla":"DG10","moeda":"BRL","limitemaximo":500000,"caracteristica":"Adicional","valor":500000,"tipoprotecao":"Doenças","caracteristicaespecialvalor":null,"limiteminimo":30000,"caracteristicaespecialtipo":null},{"franquia":null,"sigla":"BAS","moeda":"BRL","limitemaximo":10000000,"caracteristica":"Principal","valor":576000,"tipoprotecao":"Família","caracteristicaespecialvalor":null,"limiteminimo":30000,"caracteristicaespecialtipo":null},{"franquia":null,"sigla":"MAP","moeda":"BRL","limitemaximo":10000000,"caracteristica":"Principal","valor":576000,"tipoprotecao":"Família","caracteristicaespecialvalor":null,"limiteminimo":30000,"caracteristicaespecialtipo":null},{"franquia":null,"sigla":"TELEMED","moeda":"BRL","limitemaximo":0,"caracteristica":"Serviço complementar","valor":0,"tipoprotecao":"Assistências e benefícios","caracteristicaespecialvalor":null,"limiteminimo":0,"caracteristicaespecialtipo":null},{"franquia":null,"sigla":"IPA","moeda":"BRL","limitemaximo":10000000,"caracteristica":"Principal","valor":576000,"tipoprotecao":"Imprevistos","caracteristicaespecialvalor":null,"limiteminimo":30000,"caracteristicaespecialtipo":null},{"franquia":null,"sigla":"AED","moeda":"BRL","limitemaximo":10000000,"caracteristica":"Adicional","valor":576000,"tipoprotecao":"Doenças","caracteristicaespecialvalor":null,"limiteminimo":30000,"caracteristicaespecialtipo":null}],"empresaQueTrabalha":"PORTO SEGURO","ramoAtividade":"","ocupacaoProfissionalPrincipal":"2111-05","faixaRenda":"12000","formaTrabalho":"CLT","beneficiarios":[{"nome":null,"cpf":null,"nascimento":null,"grauParentesco":null,"percentualIndenizacao":100,"sexoBeneficiario":null,"tipoBeneficiario":"Herdeiros legais, conforme artigo 792 do código civil."}],"responsavelFinanceiro":false,"responsavelFinanceiroSeguro":{"nome":"TESTE","cpf":"460.359.598-06","vinculoComSegurado":"PAI","email":"teste@teste.com.br","dadosPessoaFisica":{"digitoCpf":"06","numeroCpf":"460359598","sexo":"MASCULINO","dataNascimento":"1998-11-08","estadoCivil":"CASADO"},"telefones":[{"tipoTelefone":"CEL","numeroTelefone":"555555555","dddTelefone":"55"},{"tipoTelefone":"RES","numeroTelefone":"666666666","dddTelefone":"66"}],"enderecos":[{"tipoEndereco":"Comercial","logradouro":"Luís Gama","numeroLogradouro":null,"bairro":"Jardim Monções","cidade":"Santo André","uf":"SP","cep":"09180","complemento":"","complementoCep":"320"}]},"questionario":{"idquestionario":null,"respostas":[]}}],"nome":"CLIENTE TESTE AAEFCF","qtdeVidas":1}],"pessoa":{"tipo":"FIS","enderecos":[{"tipoEndereco":"RESIDENCIAL","logradouro":"Luís Gama","numeroLogradouro":52,"bairro":"Jardim Monções","cidade":"Santo André","uf":"SP","cep":"09180","complemento":"","complementoCep":"320"},{"tipoEndereco":"COMERCIAL","logradouro":"","numeroLogradouro":null,"bairro":"","cidade":"","uf":"","cep":"","complemento":""}],"nome":"CLIENTE TESTE AAEFCF","dadosPessoaFisica":{"grupoProfissao":"DIT-A","cicloVacinal":"1","profissao":"2111-05","temDependentes":true,"tipoContrato":"VOCE","tempoGarantiaRenda":"48","dataNascimento":"1988-01-01T00:00:00.000Z","sexo":"MASCULINO","fumante":false,"regimeTrabalho":"CLT","numeroCpf":"000004526","digitoCpf":"88","estadoCivil":"CASADO","nacionalidade":"BRASILEIRA","tipoDocIdentificacao":"rg","docIdentificacao":"38.269.469-2","orgaoExpedidor":"SSP","dataExpedicao":"2020-07-01","idade":34,"paisResidente":"Brasil","DataUltimaVacina":null,"paisDeOrigem":"","resideBrasil":true},"email":"teste@teste.com.br","rendaMensal":"2222.00","telefones":[{"tipoTelefone":"CEL","numeroTelefone":"111111111","dddTelefone":"11"},{"tipoTelefone":"RES","numeroTelefone":"222222222","dddTelefone":"22"}],"melhorPeriodo":"I","pessoaExpostaPoliticamente":"Nao"},"dadosPagamento":{"opcao":0,"codigoFormaPagamento":41,"quantidadeParcelas":12,"cartaoCredito":null,"dadosBancarios":null,"formaPagamento":{"codigo":41,"descricao":"Boleto bancário","idFormaPagamento":"a0a0t000002krBhAAI","planoParcelamento":{"idPlanoParcelamento":"12","quantidadeParcelas":12}},"responsavelPagamento":null,"tipoResponsavelPagamento":"CON","vencimentoDemaisParcelas":"A cada 30 dias","vigenciaInicial":null,"responsavelFinanceiro":false,"responsavelFinanceiroSeguro":{"nome":"TESTE","cpf":"460.359.598-06","vinculoComSegurado":"PAI","email":"teste@teste.com.br","dadosPessoaFisica":{"digitoCpf":"06","numeroCpf":"460359598","sexo":"MASCULINO","dataNascimento":"1998-11-08","estadoCivil":"CASADO"},"telefones":[{"tipoTelefone":"CEL","numeroTelefone":"555555555","dddTelefone":"55"},{"tipoTelefone":"RES","numeroTelefone":"666666666","dddTelefone":"66"}],"enderecos":[{"tipoEndereco":"Comercial","logradouro":"Luís Gama","numeroLogradouro":null,"bairro":"Jardim Monções","cidade":"Santo André","uf":"SP","cep":"09180","complemento":"","complementoCep":"320"}]}}}],"canalDistribuicao":"COR","remuneracoes":[{"percentual":35,"tipoRemuneracao":"COR","favorecidos":[{"papel":"COR","participacao":100,"corretorLider":true,"susep":"COL10J","pessoa":null,"antecipaComissao":false}]}],"segmento":"Individual","tempoRendaProtegida":"48","dependentesFinanceiros":true,"formaReceberApolice":"DIGITAL","termoGuarda":false,"termoResponsabilidade":true,"assinaturaEletronica":true}]}';  //RVI-39 - INICIO/FIM
        testeSnipper.DadosVoucher = '{"cpf" : "180.917.248-96", "voucher" : "17961495", "produto" : "VIDA_INDIVIDUAL"}';		 
         testeSnipper.pagTransmissao();
         
     }

  //PLV-2411-Sniper - Início - Lógica para tratamento de exceção.
  @isTest
  static void testPropostaSnipperRetornoErro(){

		test.startTest();

		String erroServico = 'Erro na requisição';

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(erroServico, 404, 'NOK'));
		 
		CtrPropostaSniper testeSnipper = new CtrPropostaSniper();  
		testeSnipper.opServico = '';
		testeSnipper.servicosEntrada = '';
		testeSnipper.entradaTransmissao = '{"propostas":[{"indice":1,"codigoEmpresa":1,"numeroOrcamento":"00529857","numeroPortal":0,"origem":18,"ramoSeguro":1391,"tipoSeguro":"Novo","entradaNegocio":"COR","dataProtocolo":"2022-04-19","meioComercializacao":"SFC","codigoProdutoVida":"VI-PESSOAS","contratantes":[{"tipo":"PRI","numero":1,"grupos":[{"numero":1,"segurados":[{"pessoa":{"tipo":"FIS","enderecos":[{"tipoEndereco":"RESIDENCIAL","logradouro":"Luís Gama","numeroLogradouro":52,"bairro":"Jardim Monções","cidade":"Santo André","uf":"SP","cep":"09180","complemento":"","complementoCep":"320"},{"tipoEndereco":"COMERCIAL","logradouro":"","numeroLogradouro":null,"bairro":"","cidade":"","uf":"","cep":"","complemento":""}],"nome":"CLIENTE TESTE AAEFCF","dadosPessoaFisica":{"grupoProfissao":"DIT-A","cicloVacinal":"1","profissao":"2111-05","temDependentes":true,"tipoContrato":"VOCE","tempoGarantiaRenda":"48","dataNascimento":"1988-01-01T00:00:00.000Z","sexo":"MASCULINO","fumante":false,"regimeTrabalho":"CLT","numeroCpf":"000004526","digitoCpf":"88","estadoCivil":"CASADO","nacionalidade":"BRASILEIRA","tipoDocIdentificacao":"rg","docIdentificacao":"38.269.469-2","orgaoExpedidor":"SSP","dataExpedicao":"2020-07-01","idade":34,"paisResidente":"Brasil","DataUltimaVacina":null,"paisDeOrigem":"","resideBrasil":true},"email":"teste@teste.com.br","rendaMensal":"2222.00","telefones":[{"tipoTelefone":"CEL","numeroTelefone":"111111111","dddTelefone":"11"},{"tipoTelefone":"RES","numeroTelefone":"222222222","dddTelefone":"22"}],"melhorPeriodo":"I","pessoaExpostaPoliticamente":"Nao"},"numero":1,"coberturas":[{"franquia":"FR_DIH","sigla":"DIH","moeda":"BRL","limitemaximo":1000,"caracteristica":"Adicional","valor":100,"tipoprotecao":"Renda","caracteristicaespecialvalor":30,"limiteminimo":50,"caracteristicaespecialtipo":"Dia(s)"},{"franquia":null,"sigla":"AFF","moeda":"BRL","limitemaximo":20000,"caracteristica":"Adicional","valor":10000,"tipoprotecao":"Família","caracteristicaespecialvalor":null,"limiteminimo":5000,"caracteristicaespecialtipo":null},{"franquia":null,"sigla":"DG10","moeda":"BRL","limitemaximo":500000,"caracteristica":"Adicional","valor":500000,"tipoprotecao":"Doenças","caracteristicaespecialvalor":null,"limiteminimo":30000,"caracteristicaespecialtipo":null},{"franquia":null,"sigla":"BAS","moeda":"BRL","limitemaximo":10000000,"caracteristica":"Principal","valor":576000,"tipoprotecao":"Família","caracteristicaespecialvalor":null,"limiteminimo":30000,"caracteristicaespecialtipo":null},{"franquia":null,"sigla":"MAP","moeda":"BRL","limitemaximo":10000000,"caracteristica":"Principal","valor":576000,"tipoprotecao":"Família","caracteristicaespecialvalor":null,"limiteminimo":30000,"caracteristicaespecialtipo":null},{"franquia":null,"sigla":"TELEMED","moeda":"BRL","limitemaximo":0,"caracteristica":"Serviço complementar","valor":0,"tipoprotecao":"Assistências e benefícios","caracteristicaespecialvalor":null,"limiteminimo":0,"caracteristicaespecialtipo":null},{"franquia":null,"sigla":"IPA","moeda":"BRL","limitemaximo":10000000,"caracteristica":"Principal","valor":576000,"tipoprotecao":"Imprevistos","caracteristicaespecialvalor":null,"limiteminimo":30000,"caracteristicaespecialtipo":null},{"franquia":null,"sigla":"AED","moeda":"BRL","limitemaximo":10000000,"caracteristica":"Adicional","valor":576000,"tipoprotecao":"Doenças","caracteristicaespecialvalor":null,"limiteminimo":30000,"caracteristicaespecialtipo":null}],"empresaQueTrabalha":"PORTO SEGURO","ramoAtividade":"","ocupacaoProfissionalPrincipal":"2111-05","faixaRenda":"12000","formaTrabalho":"CLT","beneficiarios":[{"nome":null,"cpf":null,"nascimento":null,"grauParentesco":null,"percentualIndenizacao":100,"sexoBeneficiario":null,"tipoBeneficiario":"Herdeiros legais, conforme artigo 792 do código civil."}],"responsavelFinanceiro":false,"responsavelFinanceiroSeguro":{"nome":"TESTE","cpf":"460.359.598-06","vinculoComSegurado":"PAI","email":"teste@teste.com.br","dadosPessoaFisica":{"digitoCpf":"06","numeroCpf":"460359598","sexo":"MASCULINO","dataNascimento":"1998-11-08","estadoCivil":"CASADO"},"telefones":[{"tipoTelefone":"CEL","numeroTelefone":"555555555","dddTelefone":"55"},{"tipoTelefone":"RES","numeroTelefone":"666666666","dddTelefone":"66"}],"enderecos":[{"tipoEndereco":"Comercial","logradouro":"Luís Gama","numeroLogradouro":null,"bairro":"Jardim Monções","cidade":"Santo André","uf":"SP","cep":"09180","complemento":"","complementoCep":"320"}]},"questionario":{"idquestionario":null,"respostas":[]}}],"nome":"CLIENTE TESTE AAEFCF","qtdeVidas":1}],"pessoa":{"tipo":"FIS","enderecos":[{"tipoEndereco":"RESIDENCIAL","logradouro":"Luís Gama","numeroLogradouro":52,"bairro":"Jardim Monções","cidade":"Santo André","uf":"SP","cep":"09180","complemento":"","complementoCep":"320"},{"tipoEndereco":"COMERCIAL","logradouro":"","numeroLogradouro":null,"bairro":"","cidade":"","uf":"","cep":"","complemento":""}],"nome":"CLIENTE TESTE AAEFCF","dadosPessoaFisica":{"grupoProfissao":"DIT-A","cicloVacinal":"1","profissao":"2111-05","temDependentes":true,"tipoContrato":"VOCE","tempoGarantiaRenda":"48","dataNascimento":"1988-01-01T00:00:00.000Z","sexo":"MASCULINO","fumante":false,"regimeTrabalho":"CLT","numeroCpf":"000004526","digitoCpf":"88","estadoCivil":"CASADO","nacionalidade":"BRASILEIRA","tipoDocIdentificacao":"rg","docIdentificacao":"38.269.469-2","orgaoExpedidor":"SSP","dataExpedicao":"2020-07-01","idade":34,"paisResidente":"Brasil","DataUltimaVacina":null,"paisDeOrigem":"","resideBrasil":true},"email":"teste@teste.com.br","rendaMensal":"2222.00","telefones":[{"tipoTelefone":"CEL","numeroTelefone":"111111111","dddTelefone":"11"},{"tipoTelefone":"RES","numeroTelefone":"222222222","dddTelefone":"22"}],"melhorPeriodo":"I","pessoaExpostaPoliticamente":"Nao"},"dadosPagamento":{"opcao":0,"codigoFormaPagamento":41,"quantidadeParcelas":12,"cartaoCredito":null,"dadosBancarios":null,"formaPagamento":{"codigo":41,"descricao":"Boleto bancário","idFormaPagamento":"a0a0t000002krBhAAI","planoParcelamento":{"idPlanoParcelamento":"12","quantidadeParcelas":12}},"responsavelPagamento":null,"tipoResponsavelPagamento":"CON","vencimentoDemaisParcelas":"A cada 30 dias","vigenciaInicial":null,"responsavelFinanceiro":false,"responsavelFinanceiroSeguro":{"nome":"TESTE","cpf":"460.359.598-06","vinculoComSegurado":"PAI","email":"teste@teste.com.br","dadosPessoaFisica":{"digitoCpf":"06","numeroCpf":"460359598","sexo":"MASCULINO","dataNascimento":"1998-11-08","estadoCivil":"CASADO"},"telefones":[{"tipoTelefone":"CEL","numeroTelefone":"555555555","dddTelefone":"55"},{"tipoTelefone":"RES","numeroTelefone":"666666666","dddTelefone":"66"}],"enderecos":[{"tipoEndereco":"Comercial","logradouro":"Luís Gama","numeroLogradouro":null,"bairro":"Jardim Monções","cidade":"Santo André","uf":"SP","cep":"09180","complemento":"","complementoCep":"320"}]}}}],"canalDistribuicao":"COR","remuneracoes":[{"percentual":35,"tipoRemuneracao":"COR","favorecidos":[{"papel":"COR","participacao":100,"corretorLider":true,"susep":"COL10J","pessoa":null,"antecipaComissao":false}]}],"segmento":"Individual","tempoRendaProtegida":"48","dependentesFinanceiros":true,"formaReceberApolice":"DIGITAL","termoGuarda":false,"termoResponsabilidade":true,"assinaturaEletronica":true}]}';  //RVI-39 - INICIO/FIM
		testeSnipper.DadosVoucher = '{"cpf" : "180.917.248-96", "voucher" : "17961495", "produto" : "VIDA_INDIVIDUAL"}';
		testeSnipper.pagTransmissao();  

		test.stopTest();

  }
  //PLV-2411-Sniper - Fim - Lógica para tratamento de exceção.
}