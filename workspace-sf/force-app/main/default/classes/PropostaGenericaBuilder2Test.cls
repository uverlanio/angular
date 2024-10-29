/*******************************************************************************************************************************
* Classe de teste para PropostaGenericaBuilder
*
* @date 02/02/2023
*
******************************************************************************************************************************/

@isTest
public with sharing class PropostaGenericaBuilder2Test{
    
    public static EmissaoTO.PayloadTO payloadTO;
    public static EmissaoTO.GrupoTO grupoTO;
    public static ServiceTO.OfertaTO payloadParcelamentos;
    public static List<Contract> contratos;
    
    @TestSetup
    static void setup(){
        insert new ContadorCodigo__c(Name='ProdutoTecnico', Numero__c = 0);
        insert new ContadorCodigo__c(Name='ProdutoComercial', Numero__c = 0);

        Map<String, String> paramConsMap = new Map<String,String> ();
        paramConsMap.put('GRUPO_JOVENS_NOME','Passageiros até 70 anos');
        paramConsMap.put('GRUPO_IDOSOS_IDADE_MIN',' 71');
        paramConsMap.put('GRUPO_IDOSOS_IDADE_MAX','90');
        paramConsMap.put('GRUPO_IDOSOS_NOME','Passageiros de 71 a 90 anos');
        paramConsMap.put('GRUPO_JOVENS_IDADE_MAX','70');
        paramConsMap.put('GRUPO_JOVENS_IDADE_MIN','0');

        list<ParametrosConstante__c> lstParamCons = new List<ParametrosConstante__c>();
        for(String pc : paramConsMap.keySet()){
            lstParamCons.add( new ParametrosConstante__c (name = pc, Valor__c = paramConsMap.get(pc) ));
        }
        insert lstParamCons;

        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c='C1192J';
        produtoTecnico.VersaoRenovacao__c='Versão atual';
        update produtoTecnico;
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        Product2 produtoComercial  = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        Account acc =   (Account) new AccountFactory.PessoaFisica().createRecord();
        acc.IdExterno__c = '34648600606';
        update acc;

        //TKCL-246 FIX05 INICIO
        Product2 produtoTecnicoAp = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnicoAp.Status__c = 'Em ativação';
        produtoTecnicoAp.NumeroSusep__c = '123';
        produtoTecnicoAp.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnicoAp;
        produtoTecnicoAp.Status__c = 'Ativo';
        produtoTecnicoAp.ProductCode = '49';
        produtoTecnicoAp.Segmento__c = 'Individual';
        update produtoTecnicoAp;
        Product2 produtoComercialAp = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnicoAp).createRecord();
        produtoComercialAp.Status__c = 'Ativo';
        produtoComercialAp.ProductCode = 'APTLMKT';
        produtoComercialAp.Segmento__c = 'Individual';
        produtoComercialAp.CodigoPrecificaProduto__c = 'APTLMKT';
        update produtoComercialAp;
        //TKCL-246 FIX05 FIM

        CanalDistribuicao__c cd = new CanalDistribuicao__c();
        insert cd; // PLV - 4440 INICIO/FIM
        Opportunity orcamento = (Opportunity) new OrcamentoFactory.VidaIndividual().createRecord();
        orcamento.Numero__c = '00006395';
        orcamento.StageName = 'Disponível para contratação';
        orcamento.CanalDistribuicao__c = cd.Id;
        orcamento.Produto__c = produtoComercial.Id;
        update orcamento;
        FormaPagamento__c formaPagamento =  new FormaPagamento__c( Codigo__c = '62', Name = '3X');
        insert formaPagamento;
        CondicaoCobranca__c conCobranca = new CondicaoCobranca__c ( Produto__c = produtoComercial.Id, 
                                                                    QuantidadeParcelas__c = '6',
                                                                    FormaPagamento__c = formaPagamento.Id);
        insert conCobranca;
        insert new PlanoParcelamento__c(FormaPagamento__c = formaPagamento.Id, NumeroParcela__c = 6 );
        // PLV - 4440 INICIO
        List<Quote> listaPropostas = new List<Quote>();
        
        Quote   proposta = new Quote(   Name = '18-00001348', 
                                     OpportunityId = orcamento.Id, 
                                     FormaPagamento__c = formaPagamento.Id, 
                                     VigenciaInicial__c = Date.today(),
                                     CanalDistribuicao__c = cd.Id,
                                     Produto__c = produtoComercial.Id, //TKCL-246 FIX05 INICIO/FIM
                                     ReaproveitarAssinatura__c = false,  //PLV-5643 - INÍCIO/FIM
                                     Status = 'Em análise',
                                     VigenciaFinal__c = Date.today().addDays(60));
        
        listaPropostas.add(proposta);
        
        Quote   proposta2 = new Quote(   Name = '18-00001349', 
                                      OpportunityId = orcamento.Id, 
                                      FormaPagamento__c = formaPagamento.Id, 
                                      VigenciaInicial__c = Date.today(),
                                      CanalDistribuicao__c = cd.Id,
                                      ReaproveitarAssinatura__c = true,  //PLV-5643 - INÍCIO/FIM
                                      VigenciaFinal__c = Date.today().addDays(60));
        
        listaPropostas.add(proposta2);
        
        Quote   proposta3 = new Quote(   Name = '18-00001350', 
                                      OpportunityId = orcamento.Id, 
                                      FormaPagamento__c = formaPagamento.Id, 
                                      VigenciaInicial__c = Date.today(),
                                      CanalDistribuicao__c = cd.Id,
                                      ReaproveitarAssinatura__c = true,  //PLV-5643 - INÍCIO/FIM
                                      VigenciaFinal__c = Date.today().addDays(60));
        
        listaPropostas.add(proposta3);
        
        //insert proposta;
        insert listaPropostas;
	    // PLV - 4440 FIM
        insert new GarantiaOrcamento__c (Orcamento__c = orcamento.Id );
        // PLV-3667 - FIM

        RemuneracaoProposta__c rp = new RemuneracaoProposta__c (Proposta__c = proposta.Id);
        insert rp;
        insert new FavorecidoRemuneracaoProposta__c (RemuneracaoProposta__c = rp.Id ,Conta__c = acc.Id);
        
        ContratanteOrcamento__c contratante = (ContratanteOrcamento__c) new contratanteOrcamentoFactory(orcamento).createRecord();
        contratante.Orcamento__c = orcamento.Id;
        update contratante;
        GrupoOrcamento__c grupoOrcamento = new GrupoOrcamento__c(
            Name = 'Sócio',
            ContratanteOrcamento__c = contratante.Id,
            Numero__c = 1
        );
        insert grupoOrcamento;
        insert new GarantiaContratanteOrcamento__c (ContratanteOrcamento__c = contratante.Id);
        insert new GarantiaGrupoOrcamento__c ( GrupoOrcamento__c = grupoOrcamento.Id);

        List<StaticResource> srList = [ SELECT Id, Body, Name FROM StaticResource 
                                        WHERE Name = 'gravarProposta' 
                                        OR Name = 'gravarDevolutiva' 
                                        OR Name = 'gravarPropostaViagem' 
                                        OR Name = 'payloadOrcamentoPrecificacaoTest'
                                        ORDER BY Name];

        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/proposta/gravar';
        request.httpMethod = 'POST';
        request.requestBody = srList[1].Body;

        RestRequest requestDevolutiva = new RestRequest();
        requestDevolutiva.requestUri ='/services/apexrest/proposta/devolutiva';
        requestDevolutiva.httpMethod = 'POST';
        requestDevolutiva.requestBody = srList[0].Body;
        
        RestRequest requestViagem = new RestRequest();
        requestViagem.requestUri ='/services/apexrest/proposta/gravar';
        requestViagem.httpMethod = 'POST';
        requestViagem.requestBody = srList[2].Body;

        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'payloadOrcamentoPrecificacaoTest',
            PathOnClient = 'payloadOrcamentoPrecificacaoTest.json',
            VersionData = srList[3].Body,
            IsMajorVersion = true
        );
        
        insert contentVersion; 

        List<ContentDocument> documents = [SELECT Id, Title FROM ContentDocument];
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = orcamento.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

    }
    
    @isTest
    private static EmissaoTO.PayloadTO gerarPayloadTO(){

        // DestinoTO
        EmissaoTO.DestinoTO destinoTO = new EmissaoTO.DestinoTO();
        destinoTO.pais = 'Teste';
        

         // ViagemTO
         EmissaoTO.ViagemTO viagemTO = new EmissaoTO.ViagemTO();
         viagemTO.trackageBagagem = 'Teste';
         viagemTO.utilizaraMotocicleta = 'Teste';
         viagemTO.passageirosNaoIdosos = 'Teste';
         viagemTO.tipoViagem = 'Teste';
         viagemTO.praticaEsportesAventura = 'Teste';
         viagemTO.destinos = new List<EmissaoTO.DestinoTO>{destinoTO};
         viagemTO.incluiPaisSchengen = 'Teste';
         viagemTO.passageirosIdosos = 'Teste';
         

         // PremioTO
         EmissaoTO.PremioTO premioTO = new EmissaoTO.PremioTO();
         premioTO.puro = 1;
         premioTO.puroDesconto = 1;
         premioTO.puroInterno = 1;
         premioTO.puroResseguro = 1;
         premioTO.comercial = 1;
         premioTO.comercialDesconto = 1;
         premioTO.total = 1;

       

        
        //Cupom desconto AV-664 inicio
        Cupom__c Cupom = new Cupom__c();
        Cupom.Name = 'CUPOMNOVO';
        Cupom.Codigo__c = 'CUPOMNOVO';
        Cupom.Limite_de_Utilizacao__c = 200;
        Cupom.Meio_de_Comercializacao__c = 'SFC';
        Cupom.Vigencia_Final__c	= Date.valueOf('2024-11-24');
        Cupom.Vigencia_Inicial__c = Date.valueOf('2022-08-15');
        //Cupom desconto AV-664 FIM


        EmissaoTO.StargateTO stargateTO = new EmissaoTO.StargateTO();
        stargateTO.codigo = 2;
        stargateTO.codigoAgrupamento= '1';
        stargateTO.codigoGateway= 1;
        stargateTO.mensagem= 'a';
        stargateTO.mensagemGateway= '1';
        
        //TKCL-458 FIX01 Inicio
        Boolean existeCriticaFinanceiro = false;

        EmissaoTO.CobrancaTO cobrancaTO = new EmissaoTO.CobrancaTO();
        cobrancaTO.estado = 'PAGA'; // TKCL 458-FIX02

        EmissaoTO.PortoPagTO portoPagTO = new EmissaoTO.PortoPagTO();
        portoPagTo.cobrancas = new List<EmissaoTO.CobrancaTO>{CobrancaTO};



          
        EmissaoTO.AutorizacaoCartaoTO autorizacaoCartaoTO = new EmissaoTO.AutorizacaoCartaoTO();
        autorizacaoCartaoTO.stargate = stargateTO;
        autorizacaoCartaoTO.portoPag = portoPagTO; //TKCL-458 FIX01 Inicio/FIM



        EmissaoTO.RetornoFinanceiroTO retornoFinanceiroTO = new EmissaoTO.RetornoFinanceiroTO();
        retornoFinanceiroTO.autorizacaoCartao = autorizacaoCartaoTO;

         // ContatoTO
         EmissaoTO.ContatoTO contatoTO = new EmissaoTO.ContatoTO();
         contatoTO.ddd = 'Teste';
         contatoTO.nome = 'Teste';
         contatoTO.telefone = 'Teste';

         // TaxaTO
        EmissaoTO.TaxaTO taxaTO = new EmissaoTO.TaxaTO();
        taxaTO.pura = 1;
        taxaTO.mensal = 1;
        taxaTO.anual = 1;
        taxaTO.puroInterno = 1;
        taxaTO.puroResseguro = 1;
        taxaTO.comercial = 1;
        taxaTO.total = 1;

         // EnderecoTO
         EmissaoTO.EnderecoTO enderecoTO = new EmissaoTO.EnderecoTO();
         enderecoTO.tipoLogradouro = 'Teste';
         enderecoTO.tipoEndereco = 'Teste';
         enderecoTO.logradouro = 'Teste';
         enderecoTO.numeroLogradouro = 'Teste';
         enderecoTO.complemento = 'Teste';
         enderecoTO.bairro = 'Teste';
         enderecoTO.cidade = 'Teste';
         enderecoTO.uf = 'Teste';
         enderecoTO.paisResidencia = 'Teste';
         enderecoTO.cep = 'Teste';
         enderecoTO.complementoCep = 'Teste';

        // TelefoneTO
        EmissaoTO.TelefoneTO telefoneTO = new EmissaoTO.TelefoneTO();
        // ANNVI-18 - INICIO
        telefoneTO.tipoTelefone = 'CEL';
        telefoneTO.dddTelefone = '11';
        telefoneTO.numeroTelefone = '900000000';
         // ANNVI-18 - FIM
        
        // DadosPessoaJuridicaTO
        EmissaoTO.DadosPessoaJuridicaTO dadosPessoaJuridicaTO = new EmissaoTO.DadosPessoaJuridicaTO();
        // ANNVI-18 - INICIO
         dadosPessoaJuridicaTO.numeroCnpj = '88109244';
         dadosPessoaJuridicaTO.ordemCnpj = '0001';
         dadosPessoaJuridicaTO.digitoCnpj = '58';
         dadosPessoaJuridicaTO.cnpj = '88.109.244/0001-58';
         dadosPessoaJuridicaTO.codigoCNAE = '1.02';
         dadosPessoaJuridicaTO.descricaoCNAE = 'Analise e desenvolvimento de sistemas';
         // ANNVI-18 - FIM

         // DocumentoTO
         EmissaoTO.DocumentoTO documentoTO = new EmissaoTO.DocumentoTO();
         documentoTO.orgaoExpedidorDocumento = 'Teste';
         documentoTO.numeroDocumentoIdentidade = 'Teste';
         documentoTO.dataExpedicaoDocumento = 'Teste';
         documentoTO.tipoDocumentoIdentidade = 'Teste';
         
         // DadosPessoaFisicaTO
         EmissaoTO.DadosPessoaFisicaTO dadosPessoaFisicaTO = new EmissaoTO.DadosPessoaFisicaTO();
         dadosPessoaFisicaTO.tipoRelacionamentoPep = '';
         dadosPessoaFisicaTO.pep = 'Não';
         dadosPessoaFisicaTO.profissao = 'Teste';
         dadosPessoaFisicaTO.numeroCpf = 'Teste';
         dadosPessoaFisicaTO.sexo = 'Teste';
         dadosPessoaFisicaTO.dataNascimento = null; // PLV - 4440 INICIO/FIM
         dadosPessoaFisicaTO.documentos = new List<EmissaoTO.DocumentoTO>{documentoTO};
         dadosPessoaFisicaTO.estadoCivil = 'Teste';
         dadosPessoaFisicaTO.digitoCpf = 'Teste';
         dadosPessoaFisicaTO.nacionalidade = 'Teste';
         


          // CoberturaTO
          EmissaoTO.CoberturaTO coberturaTO = new EmissaoTO.CoberturaTO();
          coberturaTO.idSf = 'Teste';
          coberturaTO.sigla = 'Teste';
          coberturaTO.capital = 1;
          coberturaTO.premio = premioTO;
          coberturaTO.taxa = taxaTO;
          coberturaTO.valor = 1;
          coberturaTO.agravo = 1;
          coberturaTO.desconto = 1;
          coberturaTO.escolhaDescontoAgravo = 'Teste';
          coberturaTO.valorDescontoAgravo = 1;
          coberturaTO.garantiaReferenciada = 'Teste';
          coberturaTO.percentual = 1;
          coberturaTO.inclusaoIndenizacaoEspecial = 'Teste';
          coberturaTO.percentualIndenizacaoEspecial = 1;
          coberturaTO.inclusaoFilhos = 'Teste';
          coberturaTO.percentualFilhos = 1;
          coberturaTO.quantidade = 'Teste';
          coberturaTO.importancia = 1;
          coberturaTO.clausulaReducaoFranquiaAcidente = 'Teste';
          coberturaTO.numeroSerie = 'Teste';
          coberturaTO.numeroSorte = 'Teste';
          coberturaTO.dataSorteio = 'Teste';
          coberturaTO.tituloCapitalizacao = 'Teste';
          coberturaTO.statusCapitalizacao = 'Teste';
          coberturaTO.versaoCapitalizacao = 'Teste';
          coberturaTO.dataSolicitacao = 'Teste';
          coberturaTO.loteCapitalizacao = 'Teste';

        // PessoaTO
        EmissaoTO.PessoaTO pessoaTO = new EmissaoTO.PessoaTO();
        pessoaTO.tipo = 'Teste';
        pessoaTO.nome = 'Teste';
        pessoaTO.email = 'Teste';
        pessoaTO.enderecos = new List<EmissaoTO.EnderecoTO>{enderecoTO};
        pessoaTO.telefones = new List<EmissaoTO.TelefoneTO>{telefoneTO};
        pessoaTO.dadosPessoaFisica = dadosPessoaFisicaTO.clone(); // PLV - 4440 INICIO/FIM
        pessoaTO.dadosPessoaJuridica = dadosPessoaJuridicaTO;

        
        // Desconto e agravo
        EmissaoTO.DescontoagravoTO descontoagravoTO = new EmissaoTO.DescontoagravoTO();
        descontoagravoTO.percentual = 1;
        descontoagravoTO.tipo = 'Teste';
        descontoagravoTO.monetario = 1;

        // DadosBancarioTO
        EmissaoTO.DadosBancarioTO dadosBancarioTO = new EmissaoTO.DadosBancarioTO();
        dadosBancarioTO.digitoConta = 'Teste';
        dadosBancarioTO.agencia = 'Teste';
        dadosBancarioTO.conta = 'Teste';
        dadosBancarioTO.digitoAgencia = 'Teste';
        dadosBancarioTO.banco = 'Teste';

        // RespostaTO
        EmissaoTO.RespostaTO respostaTO = new EmissaoTO.RespostaTO();
	    // PLV - 4440 INICIO
        respostaTO.questao  =  null; 
        respostaTO.resposta  = null;
	    // PLV - 4440 FIM

        // CartaocreditoTO
        EmissaoTO.CartaocreditoTO cartaocreditoTO = new EmissaoTO.CartaocreditoTO();
        cartaocreditoTO.nomeTitularCartao = 'Teste';
        CartaocreditoTO.nomeTitularCartao = 'Teste';
        CartaocreditoTO.codigoBandeiraCartao = 'Teste';
        CartaocreditoTO.ticketCartao = 'Teste';
        

        // DadosPagamentoTO
        EmissaoTO.DadosPagamentoTO dadosPagamentoTO = new EmissaoTO.DadosPagamentoTO();
        dadosPagamentoTO.tipoResponsavelPagamento = 'Teste';
        dadosPagamentoTO.dadosBancarios = dadosBancarioTO;
        //dadosPagamentoTO.responsavelPagamento = responsavelPagamentoTO;
        dadosPagamentoTO.cartaoCredito = cartaocreditoTO;
        dadosPagamentoTO.quantidadeParcelas = 1;
        dadosPagamentoTO.vencimentoPrimeiraParcela = 'Teste';
        dadosPagamentoTO.boleto = 'Teste';
        dadosPagamentoTo.codigoFormaPagamento = 97;

        
        // SeguradoTO
        EmissaoTO.SeguradoTO seguradoTO = new EmissaoTO.SeguradoTO();
        seguradoTO.objSF = new SeguradoProposta__c();
        seguradoTO.objSfO = new SeguradoOrcamento__c();
        seguradoTO.numero = 'Teste';
        seguradoTO.nome = 'Teste';
        seguradoTO.dataNascimento = Date.newInstance(2015,10,10);
        seguradoTO.numeroCpf = 'Teste';
        seguradoTO.digitoCpf = 'Teste';
        seguradoTO.afastado = 'Teste';
        seguradoTO.cid = new List<String>{'teste','teste2'};
        seguradoTO.iof = 1;
        seguradoTO.premio = premioTO;
        seguradoTO.taxa = taxaTO;
        seguradoTO.coberturas = new List<EmissaoTO.CoberturaTO>{coberturaTO};
        seguradoTO.pessoa = pessoaTO;
        seguradoTO.dadosPagamento = dadosPagamentoTO;
	    // PLV - 4440 INICIO
        seguradoTO.questionario = new EmissaoTO.QuestionarioTO();
        seguradoTO.questionario.respostas =  new List<EmissaoTO.RespostaTO> {respostaTO};
        // PLV - 4440 FIM   

        // GrupoTO
        EmissaoTO.GrupoTO grupoTO = new EmissaoTO.GrupoTO();
        grupoTO.objSF = new GrupoProposta__c();
        grupoTO.objSFO = new GrupoOrcamento__c();
        grupoTO.idSf = 'Teste';
        grupoTO.nome = 'Teste';
        grupoTO.numero = 'Teste';
        grupoTO.tipoSegurado = 'Teste';
        grupoTO.idArquivoVidas = 'Teste';
        grupoTO.tipoCalculo = 'Teste';
        grupoTO.prazoMaximoFinanciamentoPrestamista = 'Teste';
        grupoTO.saldoDevedor = 1;
        grupoTO.valorDoBem = 1;
        grupoTO.premio = premioTO;
        grupoTO.agravo = 1;
        grupoTO.desconto = 1;
        grupoTO.escolhaDescontoAgravo = 'Teste';
        grupoTO.valorDescontoAgravo = 1;
        grupoTO.taxa = taxaTO;
        grupoTO.iof = 1;
        grupoTO.segurados = new List<EmissaoTO.SeguradoTO>{seguradoTO};
        grupoTO.coberturas = new List<EmissaoTO.CoberturaTO>{coberturaTO};

         
          

        
          

        // ContratanteTO
        EmissaoTO.ContratanteTO contratanteTO = new EmissaoTO.ContratanteTO();
        contratanteTO.contaSf = new Account();
        contratanteTO.objSf = new ContratanteProposta__c();
        contratanteTO.objSfO = new ContratanteOrcamento__c();
        contratanteTO.idSf = 'Teste';
        contratanteTO.numero = 'Teste';
        contratanteTO.tipo = 'Teste';
        contratanteTO.pessoa = pessoaTO;
        contratanteTO.iof = 1;
        contratanteTO.premio = premioTO;
        contratanteTO.taxa = taxaTO;
        contratanteTO.coberturas = new List<EmissaoTO.CoberturaTO>{coberturaTO};
        contratanteTO.grupos = new List<EmissaoTO.GrupoTO>{grupoTO};
        contratanteTO.contato = contatoTO;
        contratanteTO.dadosPagamento = dadosPagamentoTO;

        // DadosDevolucaoTO
        EmissaoTO.DadosDevolucaoTO dadosDevolucaoTO = new EmissaoTO.DadosDevolucaoTO();
        dadosDevolucaoTO.susepCorretor = 'Teste';
        dadosDevolucaoTO.codigo = 'Teste';
        dadosDevolucaoTO.motivo = 'Teste';
        dadosDevolucaoTO.matricula = 'Teste';

         // PrecificacaoTO
         EmissaoTO.PrecificacaoTO precificacaoTO = new EmissaoTO.PrecificacaoTO();
         precificacaoTO.iof = 1;
         precificacaoTO.juros = 1;
         precificacaoTO.premio = premioTO;
         precificacaoTO.contratantes = new List<EmissaoTO.ContratanteTO>{contratanteTO};
         precificacaoTO.custoApolice = 1;
         precificacaoTO.taxa = taxaTO;
         precificacaoTO.encargos  = 1;
         precificacaoTO.coberturas = new List<EmissaoTO.CoberturaTO>{coberturaTO};
         precificacaoTO.descontoAgravo = new List<EmissaoTO.DescontoagravoTO>{descontoagravoTO};
        
         
        // CalculoTO
        EmissaoTO.CalculoTO calculoTO = new EmissaoTO.CalculoTO();
        calculoTO.precificacao = precificacaoTO;

         // TransferenciaCongenereTO
         EmissaoTO.TransferenciaCongenereTO transferenciaCongenereTO = new EmissaoTO.TransferenciaCongenereTO();
         transferenciaCongenereTO.tempoPermanencia = 1;
         transferenciaCongenereTO.congenere = 'Teste';
         transferenciaCongenereTO.taxaVigencia = 1;
         transferenciaCongenereTO.sinistralidade = 1;

         
        // ArquivoTO
        EmissaoTO.ArquivoTO arquivoTO = new EmissaoTO.ArquivoTO();
        arquivoTO.descricao = 'Teste';
        arquivoTO.idArquivo = 'Teste';
        arquivoTO.nome = 'Teste';
        arquivoTO.bytes = 'Teste';
        
       
         // MensagenTO
         EmissaoTO.MensagenTO mensagemTO = new EmissaoTO.MensagenTO();
         mensagemTO.interna = 'Teste';
         mensagemTO.cliente = 'Teste';
         mensagemTO.representante = 'Teste';
         

        // PendenciaTO
        EmissaoTO.PendenciaTO pendenciaTO = new EmissaoTO.PendenciaTO();
        pendenciaTO.identificacao = 'Teste';
        pendenciaTO.atendida = true;
        pendenciaTO.mensagens = mensagemTO;
        pendenciaTO.area = 'Teste';
        pendenciaTO.codigo = 1;
        pendenciaTO.procedimento = 'Teste';
        pendenciaTO.descricao = 'Teste';
        pendenciaTO.severidade = 1;

         // EventoTO
         EmissaoTO.EventoTO eventoTO = new EmissaoTO.EventoTO();
         eventoTO.tipoEvento = 'Teste'; 
         eventoTO.qstControlePublico = 'Teste';
         eventoTO.qstLocalEvento = 'Teste';
         eventoTO.informacoesEvento = 'Teste';
         
         
         // AgenteTO
         EmissaoTO.AgenteTO agenteTO = new EmissaoTO.AgenteTO();
         agenteTO.papel = 'Teste';
         agenteTO.corretagem = 1;
         agenteTO.susep = 'Teste';
         agenteTO.tipoPessoaCorsus = 'Teste';
         agenteTO.susepEmissao = 'Teste';
         agenteTO.susepOrcamento = 'Teste';
         agenteTO.agenciamento = 1;
         agenteTO.proLabore = 1;
         agenteTO.assessoria = 1;
         agenteTO.pessoa = pessoaTO;
         

        // RemuneracaoTO
        EmissaoTO.RemuneracaoTO remuneracaoTO = new EmissaoTO.RemuneracaoTO();
        remuneracaoTO.canal = 'Teste';
        remuneracaoTO.susep = 'Teste';
        remuneracaoTO.susepEmissao = 'Teste';
        remuneracaoTO.susepOrcamento = 'Teste';
        remuneracaoTO.tipoPessoaCorsus = 'Teste';
        remuneracaoTO.codigoOperacao = 'Teste';
        remuneracaoTO.codigoOperacaoPercentual = 1;
        remuneracaoTO.codigoOperacaoImprimir = 'Teste';
        remuneracaoTO.proLabore = 1;
        remuneracaoTO.agenciamento = 1;
        remuneracaoTO.assessoria = 1;
        remuneracaoTO.retencao = 51.7; // PLV-4470 INICIO/FIM
        remuneracaoTO.agentes = new  List<EmissaoTO.AgenteTO>{agenteTO};   

        // Instancias
      payloadTO = new EmissaoTO.PayloadTO();
      // EmissaoTO
      EmissaoTO emissaoTO = new EmissaoTO();
      emissaoTO.origemOriginal = 1;
      emissaoTO.numeroOriginal = 'teste';
      emissaoTO.canalDistribuicao = 'teste';
      emissaoTO.parceiro = 'teste';
      emissaoTO.tipoResponsavelPagamento = 'teste';
      emissaoTO.tipoBeneficiario = 'teste';
      emissaoTO.idContratoParceiro = 'teste';
      emissaoTO.idContratanteParceiro = 'teste';
      emissaoTO.origem = 18;//PLV-5643 - INÍCIO/FIM
      emissaoTO.numero = '1348';//PLV-5643 - INÍCIO/FIM
      emissaoTO.segmento = 'Viagem';
      emissaoTO.meioComercializacao = 'teste';
      emissaoTO.origemRequisicao = 'teste';
      emissaoTO.codigoEmpresa = 1;
      emissaoTO.nomeEmpresa = 'teste';
      emissaoTO.numeroOrcamento = 'teste';
      emissaoTO.numeroPortal = 'teste';
      emissaoTO.numeroApolice = 'teste';
      emissaoTO.numeroEndosso = 1;
      emissaoTO.numeroSucursal = 1;
      emissaoTO.tipoEndosso = 'Teste';
      emissaoTO.ramoSeguro = 1;
      emissaoTO.descricaoRamo = 'teste';
      emissaoTO.modalidade = 1;
      emissaoTO.descricaoModalidade = 'teste';
      emissaoTO.dataCalculo = 'teste';
      emissaoTO.dataCriacaoPortal = 'teste';
      emissaoTO.codigoProdutoVida = '1';
      emissaoTO.descricaoProduto = 'teste';
      emissaoTO.tipoVigencia = 'teste';
      emissaoTO.vigenciaInicial = 'teste';
      emissaoTO.vigenciaFinal = 'teste';
      emissaoTO.tipoSeguro = 'teste';
      emissaoTO.descontoEmissaoEspecial = 1;
      emissaoTO.setorOrigem = 1;
      emissaoTO.dataEmissao = 'teste';
      emissaoTO.status = 'teste';
      emissaoTO.descricaoStatus = 'teste';
      emissaoTO.mensagemStatus = 'teste';
      emissaoTO.observacoesGerais = 'teste';
      emissaoTO.flagReentrada = true;
      emissaoTO.idProtocolo = 1;
      emissaoTO.pendencias = new List<EmissaoTO.PendenciaTO>{pendenciaTO};
      emissaoTO.arquivos = new List<EmissaoTO.ArquivoTO>{arquivoTO};
      emissaoTO.remuneracao = remuneracaoTO;
      emissaoTO.evento = eventoTO;
      emissaoTO.viagem = viagemTO;
      emissaoTO.transferenciaCongenere = transferenciaCongenereTO;
      emissaoTO.dadosDevolucao = dadosDevolucaoTO;
      emissaoTO.contratantes = new List<EmissaoTO.ContratanteTO>{contratanteTO};
      emissaoTO.melhorPeriodo = 'I'; // PLV-4386 - INÍCIO/FIM
      emissaoTO.cupomDesconto = 'CUPOMNOVO'; // AV-644 - INICIO/FIM
      // PLV - 4440 INICIO
      emissaoTO.contratoOriginal = emissaoTO.clone();
      emissaoTO.proposta = emissaoTO.clone();
     // PLV - 4440 FIM
     emissaoTO.reaproveitarAssinatura = true;//PLV-5643 - INÍCIO/FIM
     
      List<EmissaoTO> lEmissaoTO = new List<EmissaoTO>();
      
      // PayloadTO
      EmissaoTO.PayloadTO payloadTO = new EmissaoTO.PayloadTO();
      payloadTO.proposta = emissaoTO;
      payloadTO.retornoFinanceiro = retornoFinanceiroTO;
      lEmissaoTO.add(emissaoTO);
      system.debug('lEmissaoTO: '+lEmissaoTO);
      
      payloadTO.orcamentos = new List<EmissaoTO>{emissaoTO};
      payloadTO.calculo = calculoTO;
      payloadTO.devolutivas = lEmissaoTO;
      //PLV-5643 - INÍCIO/FIM
      payloadTO.recusada = true;
      payloadTO.origemRecusa = 'origemRecusa';
      String mockRetornoAceitacao = '{"recusas":[{"area":"Teste","codigo":1,"descricao":"Teste","mensagens":{"representante":null,"interna":"ANALISAR","cliente":null},"procedimento":"Teste","severidade":1}],"pendencias":[],"nr":null,"decisoes":null,"avisos":[{"severidade":5,"procedimento":"Necessário envio de pendência ao corretor para regularização do CPF: 518179180 Informações identificadas no retorno do serviço Restritivos Origem da informação : externa Status na Receita: REGULAR Data de atualização: 2022-08-22 17:44:50 Status do registro:atualizado Score PF -CSBA Faixa: J Taixa : 26.9","mensagens":{"representante":null,"interna":"ANALISAR","cliente":null},"descricao":"Código 0012 - Score >100 e Restrições <200mil com apólice vigente","codigo":12,"area":"ACE"},{"severidade":5,"procedimento":"","mensagens":{"representante":null,"interna":"ANALISAR","cliente":null},"descricao":"Código 0005 - Status CPF - Regular","codigo":5,"area":"ACE"}],"analises":[{"severidade":0,"setor":"Aceitação","procedimento":"","momentoAnalise":"Subscrição","mensagens":{"representante":null,"interna":"Envio para SAMPLEMED","cliente":null},"integracao":"SAMPLE","descricao":"Código 0071 - Samplemed com DIT, DG ou CAN - subscrição automática 1","codigo":71,"area":"SAMPLE","acao":"auto"},{"severidade":5,"setor":"Emissão","procedimento":"","momentoAnalise":"Análise interna","mensagens":{"representante":null,"interna":"PARA ANALISAR","cliente":null},"integracao":"DOCUSIGN","descricao":"Código 0109 -Envio para assinatura eletrônica","codigo":109,"area":"ACE","acao":""}]}';
      EmissaoTO.RetornoAceitacaoTO testAceitacao = (EmissaoTO.RetornoAceitacaoTO)System.JSON.deserialize(mockRetornoAceitacao, EmissaoTO.RetornoAceitacaoTO.class);
      payloadTO.retornoAceitacao = testAceitacao;
      //PLV-5643 - FIM
		

        
      

         return payloadTO;

    }

    @isTest
    private static ServiceTO.OfertaTO gerarParcelamentos(){

        payloadTO = gerarPayloadTO();


        List<EmissaoTO.RetornoCalculoTO> listaRetornosCalculo = new List<EmissaoTO.RetornoCalculoTO>();
        EmissaoTO.RetornoCalculoTO retornosCalculo = new EmissaoTO.RetornoCalculoTO();
        EmissaoTO.DadosPagamentoTO dadosPagamentoTO = new EmissaoTO.DadosPagamentoTO();
        EmissaoTO.ContratanteTO contratanteTO = new EmissaoTO.ContratanteTO();
        listaRetornosCalculo.add(retornosCalculo);

           // RetornoAceitacao
           ServiceTO.RetornoAceitacaoTO retornoAceitacao = new ServiceTO.RetornoAceitacaoTO();

           // Regras
           ServiceTO.RegrasRetornoOfertaTO regras = new ServiceTO.RegrasRetornoOfertaTO();

         // Parcelamentos
        ServiceTO.OfertaTO payloadParcelamentos = new ServiceTO.OfertaTO();
        List<ServiceTO.ParcelamentoTO> listaParcelamentoTO = new List<ServiceTO.ParcelamentoTO>();
        ServiceTO.ParcelamentoTO parcelamento = new ServiceTO.ParcelamentoTO();
         parcelamento.opcao = 0;
         parcelamento.encargos = 0;
         parcelamento.iof = 00.00;
         parcelamento.codigo = 97;
         parcelamento.valorPrimeiraParcela = '100.00';
         parcelamento.descontoAgravo = -15;
         parcelamento.custoApolice = 0;
         parcelamento.qtdParcelas = 2;
         parcelamento.juros = 0;
         parcelamento.valorDemaisParcelas = '101.00';
         parcelamento.meioRecebimentoPrimeiraParcela = 'P';
         parcelamento.descricao = 'CARTAO PORTO SEGURO';
         parcelamento.nomeFormaPagamento = '';
         parcelamento.agrupamento = 'CartaoCredito';
         parcelamento.meioRecebimentoDemaisParcelas = null;
         parcelamento.antecipacaoComissao = true;
         parcelamento.idFormaPagamento = '1';
 
         listaParcelamentoTO.add(parcelamento);
 
         // Orcamento
         ServiceTO.OrcamentoTO orcamentoTO = new ServiceTO.OrcamentoTO();
 
         ServiceTO.OfertaTO ofertaTO = new ServiceTO.OfertaTO();
         ofertaTO.retornosCalculo = listaRetornosCalculo;
         ofertaTO.retornoAceitacao = retornoAceitacao;
         ofertaTO.regras = regras;
         ofertaTO.parcelamentos = listaParcelamentoTO;
   
         payloadParcelamentos.parcelamentos = ofertaTO.parcelamentos;
 
         payloadTO.proposta.codigoProdutoVida = 'APTLMKT';
         payloadTO.proposta.segmento = 'Individual';
         payloadTO.proposta.contratantes = new List<EmissaoTO.ContratanteTO>{contratanteTO};
         dadosPagamentoTO.quantidadeParcelas = 2;
         payloadTO.proposta.contratantes[0].dadosPagamento = dadosPagamentoTO;

         return payloadParcelamentos;

    }

    @isTest
    private static EmissaoTO.GrupoTO gerarGrupos(){

        payloadTO = gerarPayloadTO();
        EmissaoTO.SeguradoTO seguradoTO = new EmissaoTO.SeguradoTO();
        EmissaoTO.CoberturaTO coberturaTO = new EmissaoTO.CoberturaTO();
        EmissaoTO.PremioTO premioTO = new EmissaoTO.PremioTO();
        EmissaoTO.TaxaTO taxaTO = new EmissaoTO.TaxaTO();

        // GrupoTO
        EmissaoTO.GrupoTO grupoTO = new EmissaoTO.GrupoTO();
        grupoTO.objSF = new GrupoProposta__c();
        grupoTO.objSFO = new GrupoOrcamento__c();
        grupoTO.idSf = 'Teste';
        grupoTO.nome = 'Teste';
        grupoTO.numero = 'Teste';
        grupoTO.tipoSegurado = 'Teste';
        grupoTO.idArquivoVidas = 'Teste';
        grupoTO.tipoCalculo = 'Teste';
        grupoTO.prazoMaximoFinanciamentoPrestamista = 'Teste';
        grupoTO.saldoDevedor = 1;
        grupoTO.valorDoBem = 1;
        grupoTO.premio = premioTO;
        grupoTO.agravo = 1;
        grupoTO.desconto = 1;
        grupoTO.escolhaDescontoAgravo = 'Teste';
        grupoTO.valorDescontoAgravo = 1;
        grupoTO.taxa = taxaTO;
        grupoTO.iof = 1;
        grupoTO.segurados = new List<EmissaoTO.SeguradoTO>{seguradoTO};
        grupoTO.coberturas = new List<EmissaoTO.CoberturaTO>{coberturaTO};


        return grupoTO;

    }
   
    @isTest
    public static void gerarContratantes(){
        Test.startTest(); 
	    PropostaGenericaBuilder pgb = new PropostaGenericaBuilder();
        payloadTO = gerarPayloadTO();

        System.debug('payloadTO>>>>>>>>>>'+ payloadTO);
        
        pgb.gerarContratantes(payloadTO);

        Test.stopTest();
    }
    
    @isTest
    public static void ValidarPayload(){
        Test.startTest(); 
	    PropostaGenericaBuilder pgb = new PropostaGenericaBuilder();
        payloadTO = gerarPayloadTO();

        System.debug('payloadTO>>>>>>>>>>'+ payloadTO);
        
        pgb.validarPayload(payloadTO);
            
        Test.stopTest();
    }

    @isTest
    public static void gerarpayloadParcelamentos(){
        Test.startTest(); 
	    PropostaGenericaBuilder pgb = new PropostaGenericaBuilder();
        payloadTO = gerarPayloadTO();
        payloadParcelamentos = gerarParcelamentos();

        pgb.atribuirParcelasRecorrencia(payloadParcelamentos, payloadTO);      

        Test.stopTest();
    }
    @isTest
    public static void geraratualizarStatusListaPropostas(){
        PropostaGenericaBuilder pgb = new PropostaGenericaBuilder();
        payloadTO = gerarPayloadTO();
        grupoTO = gerarGrupos();
        Test.startTest(); 
        pgb.atualizarStatusListaPropostas(payloadTO);
        Test.stopTest();
    }
    
    @isTest
    public static void gerarAtualizarOrcamento(){
        PropostaGenericaBuilder pgb = new PropostaGenericaBuilder();
        payloadTO = gerarPayloadTO();
        Test.startTest(); 
        System.debug('PayloadTO Henrique: ' + json.serialize(payloadTO));
        pgb.atualizarStatusListaPropostas(payloadTO);
        
        Test.stopTest();
    }
    
    @isTest
    public static void gerarCriticasRetornoFinanceiro(){
        PropostaGenericaBuilder pgb = new PropostaGenericaBuilder();
        Test.startTest(); 
        
        Quote proposta = [SELECT ID, Name, ContactId, VigenciaFinal__c, VigenciaInicial__c, Origem__c, PaisesDestino__c,
        OpportunityId, DiasAnalise__c, FormaPagamento__r.Name, Account.Name, Account.BillingStreet, CanalDistribuicao__c,
        NumeroProposta__c, status,	MeioComercializacao__c,DataCalculo__c,Tipo__c, VoucherPdfDownloadUrl__c, Segmento__c     
        FROM Quote  limit 1];
        payloadTO = gerarPayloadTO();
        List<Proposta> lProposta = new List<Proposta>();
        Proposta p = new Proposta();
        p.propostaWrapper.sfProposta= proposta;
        lProposta.add(p);
        pgb.converterListaPropostasParaRetorno(lProposta);
        EmissaoTO.RetornoFinanceiroTO retornoFinanceiro= new EmissaoTO.RetornoFinanceiroTO();
        retornoFinanceiro.autorizacaoCartao = new EmissaoTO.AutorizacaoCartaoTO();
        retornoFinanceiro.autorizacaoCartao.stargate = new EmissaoTO.StargateTO();
        retornoFinanceiro.autorizacaoCartao.portoPag = new EmissaoTO.PortoPagTO();
        retornoFinanceiro.autorizacaoCartao.stargate.codigo = 123;
        retornoFinanceiro.autorizacaoCartao.stargate.mensagem = 'Autorizado';

        Proposta.CriticaPropostaWrapper cp = new Proposta.CriticaPropostaWrapper();
        List<Proposta.CriticaPropostaWrapper> listCriticasWrapper = new List<Proposta.CriticaPropostaWrapper>();
        listCriticasWrapper.add(cp);

        pgb.gerarCriticasRetornoFinanceiro(payloadTO.retornoFinanceiro, listCriticasWrapper);
        payLoadTO.proposta.segmento = 'Individual';
        System.debug('individual='+payLoadTO.proposta.segmento);
        //EmissaoTO emissaoTO = gerarPayloadTO();
        
        EmissaoTO.RetornoAceitacaoTO retornoAceitacao = new EmissaoTO.RetornoAceitacaoTO();
        
        
        pgb.gerarCriticasRetornoAceitacao(payloadTO.retornoAceitacao, listCriticasWrapper, payloadTO.proposta);
        Test.stopTest();
    }
   
    @isTest
    public static void gerarCritica666(){
        PropostaGenericaBuilder pgb = new PropostaGenericaBuilder();
        Test.startTest(); 
        pgb.gerarCritica666('Teste');
        Test.stopTest();
    }

    // @isTest 
    // public static void gerarCriticaAnaliseTest(){
    //     list<Quote> proposta = [SELECT Id, Account.Cpf__c FROM Quote WHERE Status = 'Em análise' LIMIT 1];
    //     Test.startTest();
    //     PropostaGenericaBuilder.gerarCriticaAnalise(proposta);
    //     Test.stopTest();
    // } // ANNVI-18 INICIO/FIM -> método comentado na classe, provavelmente pela história II-165

    @isTest 
    public static void propDescAgravTest(){
        Opportunity orcamento = [SELECT Id, Numero__c FROM Opportunity LIMIT 1];
        Test.startTest();
        PropostaGenericaBuilder pgb = new PropostaGenericaBuilder();
        pgb.propostaDescontoAgravo(orcamento.Numero__c);
        Test.stopTest();
    }
       
    

}