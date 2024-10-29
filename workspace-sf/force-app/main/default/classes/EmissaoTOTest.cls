/**
 * Created by Alessandro Ponte on 11/01/2019.
 */

@IsTest
private class EmissaoTOTest {

    @IsTest
    static void testBehavior() {

        // EventoTO
        EmissaoTO.EventoTO eventoTO = new EmissaoTO.EventoTO();
        eventoTO.tipoEvento = 'Teste'; 
        eventoTO.qstControlePublico = 'Teste';
        eventoTO.qstLocalEvento = 'Teste';
        eventoTO.informacoesEvento = 'Teste';

        // CartaocreditoTO
        EmissaoTO.CartaocreditoTO cartaocreditoTO = new EmissaoTO.CartaocreditoTO();
        cartaocreditoTO.nomeTitularCartao = 'Teste';
        CartaocreditoTO.nomeTitular = 'Teste'; // PLV-5331 INICIO / FIM
        CartaocreditoTO.codigoBandeiraCartao = 'Teste';
        CartaocreditoTO.ticketCartao = 'Teste';
        CartaocreditoTO.ticket = 'Teste'; // PLV-5331 INICIO / FIM
        CartaocreditoTO.numero = 'Teste'; // PLV-5331 INICIO / FIM
        CartaocreditoTO.codigoSeguranca = 'Teste'; // PLV-5331 INICIO / FIM
        CartaocreditoTO.validade = 'Teste'; // PLV-5331 INICIO / FIM
        CartaocreditoTO.validadeCriptografada = 'Teste'; // PLV-5331 INICIO / FIM
        CartaocreditoTO.cartaoPorto = TRUE; // PLV-5331 INICIO / FIM
            

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
        telefoneTO.tipoTelefone = '1';
        telefoneTO.dddTelefone = '1';
        telefoneTO.numeroTelefone = '1';

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
        dadosPessoaFisicaTO.dataNascimento = 'Teste';
        dadosPessoaFisicaTO.documentos = new List<EmissaoTO.DocumentoTO>{documentoTO};
        dadosPessoaFisicaTO.estadoCivil = 'Teste';
        dadosPessoaFisicaTO.digitoCpf = 'Teste';
        dadosPessoaFisicaTO.nacionalidade = 'Teste';
        // PLV-5331 INICIO
        dadosPessoaFisicaTO.cpfPep = 'Teste';
        dadosPessoaFisicaTO.nomePessoaPep = 'Teste';
        dadosPessoaFisicaTO.paisDeOrigem = 'Teste';
        dadosPessoaFisicaTO.grupoProfissao = 'Teste';
        dadosPessoaFisicaTO.idade= 1;
        dadosPessoaFisicaTO.cicloVacinal='teste';
        //dadosPessoaFisicaTO.serasa = serasaViagemTO;
        dadosPessoaFisicaTO.ocupacaoProfissionalPrincipal='teste';
        dadosPessoaFisicaTO.formaTrabalho='teste';
        dadosPessoaFisicaTO.faixaRenda='teste';
        dadosPessoaFisicaTO.resideBrasil=true;
        dadosPessoaFisicaTO.paisResidente='teste';
        dadosPessoaFisicaTO.tipoDocIdentificacao='teste';
        dadosPessoaFisicaTO.docIdentificacao='teste';
        dadosPessoaFisicaTO.orgaoExpedidor='teste';
        //dadosPessoaFisicaTO.dataExpedicao= new date();
        dadosPessoaFisicaTO.grauParentesco='teste';
        dadosPessoaFisicaTO.tipoEmpresa='teste';
        dadosPessoaFisicaTO.numeroCnpj='teste';
        dadosPessoaFisicaTO.qtdFuncionarios=1;
        // PLV-5331 FIM

        // DadosPessoaJuridicaTO
        EmissaoTO.DadosPessoaJuridicaTO dadosPessoaJuridicaTO = new EmissaoTO.DadosPessoaJuridicaTO();
        dadosPessoaJuridicaTO.numeroCnpj = 'Teste';
        dadosPessoaJuridicaTO.ordemCnpj = 'Teste';
        dadosPessoaJuridicaTO.digitoCnpj = 'Teste';
        dadosPessoaJuridicaTO.cnpj = 'Teste';
        dadosPessoaJuridicaTO.codigoCNAE = 'Teste';
        dadosPessoaJuridicaTO.descricaoCNAE = 'Teste';

        // PessoaTO
        EmissaoTO.PessoaTO pessoaTO = new EmissaoTO.PessoaTO();
        pessoaTO.tipo = 'Teste';
        pessoaTO.nome = 'Teste';
        pessoaTO.email = 'Teste';
        pessoaTO.enderecos = new List<EmissaoTO.EnderecoTO>{enderecoTO};
        pessoaTO.telefones = new List<EmissaoTO.TelefoneTO>{telefoneTO};
        pessoaTO.dadosPessoaFisica = dadosPessoaFisicaTO;
        pessoaTO.dadosPessoaJuridica = dadosPessoaJuridicaTO;
        pessoaTO.nivelRelacionamento = '5'; 
        pessoaTO.rendaMensal = 1; // PLV-5331 INICIO / FIM 
        pessoaTO.melhorPeriodo = 'teste'; // PLV-5331 INICIO / FIM 
        pessoaTO.pep = 'teste'; // PLV-5331 INICIO / FIM 
        //pessoaTO.pessoaRelacionamentoPep = pessoaRelacionamentoPepTO; // PLV-5331 INICIO / FIM 
        pessoaTO.pessoaExpostaPoliticamente = 'teste'; // PLV-5331 INICIO / FIM 
        //pessoaTO.pessoaPEP = pessoaRelacionamentoPepTO; // PLV-5331 INICIO / FIM 
        //pessoaTO.retornoIntegracaoPEP = retornoIntegracaoPep; //PLV-5331 INICIO / FIM 
        pessoaTO.dadosPessoaFisica = dadosPessoaFisicaTO;//PLV-5331 INICIO / FIM 
        pessoaTO.dadosPessoaJuridica = dadosPessoaJuridicaTO;//PLV-5331 INICIO / FIM 
        pessoaTO.vinculoComSegurado = 'teste';//PLV-5331 INICIO / FIM 

        //DadosPessoaFisicaTO
        dadosPessoaFisicaTO.pessoaRelacionamentoPep = pessoaTO;
	//PLV - 4440 - INICIO 
        dadosPessoaFisicaTO.renda ='1200';
        dadosPessoaFisicaTO.regimeTrabalho ='CLT';
        dadosPessoaFisicaTO.tempoGarantiaRenda ='2';
	//PLV - 4440 - FIM 

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
        //agenteTO.susepBloqueios = susepBloqueioTO; //PLV-5331 INICIO / FIM 

        // TaxaTO
        EmissaoTO.TaxaTO taxaTO = new EmissaoTO.TaxaTO();
        taxaTO.pura = 1;
        taxaTO.mensal = 1;
        taxaTO.anual = 1;
        taxaTO.puroInterno = 1;
        taxaTO.puroResseguro = 1;
        taxaTO.comercial = 1;
        taxaTO.total = 1;

        // PremioTO
        EmissaoTO.PremioTO premioTO = new EmissaoTO.PremioTO();
        premioTO.puro = 1;
        premioTO.puroDesconto = 1;
        premioTO.puroInterno = 1;
        premioTO.puroResseguro = 1;
        premioTO.comercial = 1;
        premioTO.comercialDesconto = 1;
        premioTO.total = 1;
        premioTO.informado = 1; // PLV-5331 INICIO / FIM
        premioTO.premioPago = 1; // PLV-5331 INICIO / FIM
        premioTO.integral = 1; // PLV-5331 INICIO / FIM

        // ContatoTO
        EmissaoTO.ContatoTO contatoTO = new EmissaoTO.ContatoTO();
        contatoTO.ddd = 'Teste';
        contatoTO.nome = 'Teste';
        contatoTO.telefone = 'Teste';

        // TransferenciaCongenereTO
        EmissaoTO.TransferenciaCongenereTO transferenciaCongenereTO = new EmissaoTO.TransferenciaCongenereTO();
        transferenciaCongenereTO.tempoPermanencia = 1;
        transferenciaCongenereTO.congenere = 'Teste';
        transferenciaCongenereTO.taxaVigencia = 1;
        transferenciaCongenereTO.sinistralidade = 1;

        // DestinoTO
        EmissaoTO.DestinoTO destinoTO = new EmissaoTO.DestinoTO();
        destinoTO.pais = 'Teste';
        destinoTO.codigo = 'teste'; // PLV-5331 INICIO / FIM

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
        viagemTO.nomePrincipal = 'teste'; // PLV-5331 INICIO / FIM

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
        // PLV-5331 INICIO
        coberturaTO.iof = 0.5;
        coberturaTO.capitalContratacao = 0.5;
        coberturaTO.caracteristicaespecialvalor = 0.5;
        coberturaTO.caracteristicaespecialtipo = 'teste';
        coberturaTO.franquia = 'teste';
        //coberturaTO.descontoAgravo = new List<EmissaoTO.DescontoagravoTO>{descontoagravoTO};
        // PLV-5331 FIM

        // DadosBancarioTO
        EmissaoTO.DadosBancarioTO dadosBancarioTO = new EmissaoTO.DadosBancarioTO();
        dadosBancarioTO.digitoConta = 'Teste';
        dadosBancarioTO.agencia = 'Teste';
        dadosBancarioTO.conta = 'Teste';
        dadosBancarioTO.digitoAgencia = 'Teste';
        dadosBancarioTO.banco = 'Teste';
        dadosBancarioTO.cpf = 'teste';  // PLV-5331 INICIO /FIM
        
        // DadosBoletoTO   
        dadosBancarioTO.tipoPessoa ='FISICA'; //PLV-4440 - INCLUIDO - Odemir/SYS4B 071020

        // ArquivoTO
        EmissaoTO.ArquivoTO arquivoTO = new EmissaoTO.ArquivoTO();
        arquivoTO.descricao = 'Teste';
        arquivoTO.idArquivo = 'Teste';
        arquivoTO.nome = 'Teste';
        arquivoTO.bytes = 'Teste';

        // RespostaTO
        EmissaoTO.RespostaTO respostaTO = new EmissaoTO.RespostaTO();
        respostaTO.questao  = 'Teste';
        respostaTO.resposta  = 'Teste';

        // MensagenTO
        EmissaoTO.MensagenTO mensagemTO = new EmissaoTO.MensagenTO();
        mensagemTO.interna = 'Teste';
        mensagemTO.cliente = 'Teste';
        mensagemTO.representante = 'Teste';

        // AnaliseTO
        EmissaoTO.AnaliseTO analiseTO = new EmissaoTO.AnaliseTO();
        analiseTO.codigo = 1;
        analiseTO.area = 'Teste';
        analiseTO.procedimento = 'Teste';
        // INICIO | PLV=2402-30
        analiseTO.descricao = 'Teste';
        // FIM | PLV=2402-30
        analiseTO.severidade = 1;
        analiseTO.mensagens = mensagemTO;
        // PLV-5331 INICIO
        analiseTO.integracao = 'teste';
        analiseTO.momentoAnalise = 'teste';
        analiseTO.acao = 'teste';
        analiseTO.setor = 'teste';
        // PLV-5331 FIM

        // RecusaTO
        EmissaoTO.RecusaTO recusaTO = new EmissaoTO.RecusaTO();
        recusaTO.codigo = 1;
        recusaTO.mensagens = mensagemTO;
        recusaTO.descricao = 'Teste';
        recusaTO.area = 'Teste';
        recusaTO.procedimento = 'Teste';
        recusaTO.severidade = 1;

        // AvisoTO
        EmissaoTO.AvisoTO avisoTO = new EmissaoTO.AvisoTO();
        avisoTO.codigo = 1;
        avisoTO.area = 'Teste';
        avisoTO.mensagens = mensagemTO;
        avisoTO.procedimento = 'Teste';
        // INICIO | PLV=2402-30
        analiseTO.descricao = 'Teste';
        // FIM | PLV=2402-30
        avisoTO.severidade = 1;
        avisoTO.descricao = 'teste'; // PLV-5331 INICIO / FIM

        // ResponsavelpagamentoTO
        /*EmissaoTO.ResponsavelpagamentoTO responsavelpagamentoTO = new EmissaoTO.ResponsavelpagamentoTO();
        responsavelpagamentoTO.dadosPessoaFisica = dadosPessoaFisicaTO;
        responsavelpagamentoTO.dadosPessoaJuridica = dadosPessoaJuridicaTO;
        responsavelpagamentoTO.nome = 'Teste';
        responsavelpagamentoTO.tipo = 'Teste';*/

        // ANNVI-48 INICIO
        //FormaPagamentoTO
        EmissaoTO.FormaPagamentoTO formaPagamentoTO =  new EmissaoTO.FormaPagamentoTO(); // PLV-5331 INICIO / FIM 
        formaPagamentoTO.codigo = '70'; // PLV-5331 INICIO / FIM  
        formaPagamentoTO.descricao = 'teste'; // PLV-5331 INICIO / FIM 
        formaPagamentoTO.idFormaPagamento = 'teste'; // PLV-5331 INICIO / FIM 
        //formaPagamentoTO.planoParcelamento = planoParcelamentoTO; // PLV-5331 INICIO / FIM 
        // ANNVI-48 FIM

        // DadosPagamentoTO
        EmissaoTO.DadosPagamentoTO dadosPagamentoTO = new EmissaoTO.DadosPagamentoTO();
        dadosPagamentoTO.tipoResponsavelPagamento = 'Teste';
        dadosPagamentoTO.dadosBancarios = dadosBancarioTO;
        //dadosPagamentoTO.responsavelPagamento = responsavelPagamentoTO;
        dadosPagamentoTO.cartaoCredito = cartaocreditoTO;
        dadosPagamentoTO.quantidadeParcelas = 1;
        dadosPagamentoTO.vencimentoPrimeiraParcela = 'Teste';
        dadosPagamentoTO.boleto = 'Teste';
        dadosPagamentoTO.opcao = 1; // PLV-5331 INICIO / FIM
        dadosPagamentoTO.formaPagamento = formaPagamentoTO; // PLV-5331 INICIO / FIM // ANNVI-48 INICIO/FIM
        dadosPagamentoTO.codigoFormaPagamento =1; // PLV-5331 INICIO / FIM
        dadosPagamentoTO.descricaoFormaPagamento = 'teste'; // PLV-5331 INICIO / FIM
        dadosPagamentoTO.codigoMeioRecebimento = 'teste'; // PLV-5331 INICIO / FIM
        //dadosPagamentoTO.dadosCartaoCredito = dadosCartaoCreditoTO; // PLV-5331 INICIO / FIM
        dadosPagamentoTO.responsavelPagamento = pessoaTO; // PLV-5331 INICIO / FIM
        dadosPagamentoTO.idPlanoParcelamento = 'teste'; // PLV-5331 INICIO / FIM
        //dadosPagamentoTO.parcelas = new List<ParcelaTO>{parcelaTO};  // PLV-5331 INICIO / FIM
        dadosPagamentoTO.vencimentoDemaisParcelas = 'teste'; // PLV-5331 INICIO / FIM
        dadosPagamentoTO.vigenciaInicial = 'teste'; // PLV-5331 INICIO / FIM
        dadosPagamentoTO.diasPagamento = 'teste'; // PLV-5331 INICIO / FIM
        dadosPagamentoTO.responsavelFinanceiroSeguro = pessoaTO; // PLV-5331 INICIO / FIM
        dadosPagamentoTO.responsavelFinanceiro = true; // PLV-5331 INICIO / FIM
        dadosPagamentoTO.premioTotal =1; // PLV-5331 INICIO / FIM
        dadosPagamentoTO.codigo = 1; // PLV-5331 INICIO / FIM
        dadosPagamentoTO.descricao = 'teste'; // PLV-5331 INICIO / FIM
        

        // QuestionarioTO
        EmissaoTO.QuestionarioTO questionarioTO = new EmissaoTO.QuestionarioTO();
        questionarioTO.codigo = 'teste';
        questionarioTO.respostas = new List<EmissaoTO.RespostaTO>{respostaTO};
        //questionarioTO.idQuestionario = 'Teste'; // PLV-5331 INICIO / FIM
        questionarioTO.idquestionario = 'Teste'; //RVI-138 INICIO-FIM FIX01

        // DadosDevolucaoTO
        EmissaoTO.DadosDevolucaoTO dadosDevolucaoTO = new EmissaoTO.DadosDevolucaoTO();
        dadosDevolucaoTO.susepCorretor = 'Teste';
        dadosDevolucaoTO.codigo = 'Teste';
        dadosDevolucaoTO.motivo = 'Teste';
        dadosDevolucaoTO.matricula = 'Teste';

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
        remuneracaoTO.tipoRemuneracao = 'Teste'; // PLV-5331 INICIO / FIM
        remuneracaoTO.DICIO_RETENCAO = 1; // PLV-5331 INICIO / FIM
        remuneracaoTO.percentual = 1; // PLV-5331 INICIO / FIM
        remuneracaoTO.bonusCampanha = 5; //II-167 INICIO-FIM
        remuneracaoTO.ojSFOrcamento = new RemuneracaoOrcamento__c(); // PLV-5331 INICIO / FIM
        remuneracaoTO.ojSFProposta = new RemuneracaoProposta__c(); // PLV-5331 INICIO / FIM

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
        pendenciaTO.setor = 'Teste'; // PLV-5331 INICIO / FIM
        pendenciaTO.momentoAnalise = 'Teste'; // PLV-5331 INICIO / FIM

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
        
         // PLV-4440 - INCIO - ODEMIR - SYS4B 071020
         seguradoTO.formaTrabalho = 'CLT';
         seguradoTO.faixaRenda ='teste';
         seguradoTO.empresaQueTrabalha ='teste';
         //seguradoTO.ramoAtividade ='teste';//PLV-4595
         // PLV-4440 - FIM - ODEMIR - SYS4B 071020

         // PLV-5331 INICIO 
         //seguradoTO.beneficiarios = new List<EmissaoTO.BeneficiarioTO>{beneficiarioTO};
         seguradoTO.vigenciaInicial = 'teste';
         seguradoTO.vigenciaFinal = 'teste';
         seguradoTO.questionario = questionarioTO;
         //seguradoTO.contatoEmergencia = contatoEmergenciaTO;
         //seguradoTO.profissao = 'teste'; // PLV-5331
         seguradoTO.responsavelFinanceiro = true;
         seguradoTO.responsavelFinanceiroSeguro = pessoaTO;
         seguradoTO.ramoAtividade = 'teste';
         seguradoTO.ocupacaoProfissionalPrincipal = 'teste';
         seguradoTO.limiteProfissao = 0.5;
         // PLV-5331 Fim

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
        grupoTO.tarifa =1; // PLV-5331 INICIO / FIM

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
        contratanteTO.formaReceberApolice = 'Teste'; // PLV-5331 INICIO / FIM
        contratanteTO.conta = 'Teste'; // PLV-5331 INICIO / FIM
        contratanteTO.manterPlanoParcelamento = true; // PLV-5331 INICIO / FIM
        //contratanteTO.descontoAgravo = new List<EmissaoTO.DescontoagravoTO>{descontoagravoTO}; // PLV-5331 INICIO / FIM

        // RetornoAceitacaoTO
        EmissaoTO.RetornoAceitacaoTO retornoAceitacaoTO = new EmissaoTO.RetornoAceitacaoTO();
        retornoAceitacaoTO.analises = new List<EmissaoTO.AnaliseTO>{analiseTO};
        retornoAceitacaoTO.avisos = new List<EmissaoTO.AvisoTO>{avisoTO};
        retornoAceitacaoTO.recusas = new List<EmissaoTO.RecusaTO>{recusaTO};
        retornoAceitacaoTO.pendencias = new List<EmissaoTO.PendenciaTO>{pendenciaTO};
        // PLV-5331 INICIO
        retornoAceitacaoTO.nr = 'teste';
        //retornoAceitacaoTO.decisoes = new List<EmissaoTO.DecisaoTO>{decisaoTO};
        // PLV-5331 FIM

        // Desconto e agravo
        EmissaoTO.DescontoagravoTO descontoagravoTO = new EmissaoTO.DescontoagravoTO();
        descontoagravoTO.percentual = 1;
        descontoagravoTO.tipo = 'Teste';
        descontoagravoTO.monetario = 1;

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
        precificacaoTO.custoDeApolice = 1; // PLV-5331 INICIO / FIM

        // CalculoTO
        EmissaoTO.CalculoTO calculoTO = new EmissaoTO.CalculoTO();
        calculoTO.precificacao = precificacaoTO;
 
        //BeneficiarioTO - PLV-4440 - INCLUSAO - Odemir/SYS4B 071020 - INICIO
        EmissaoTO.BeneficiarioTO beneficiarioTO = new EmissaoTO.BeneficiarioTO();
        beneficiarioTO.grauParentesco='Filho';
        beneficiarioTO.motivoSemCpfCnpj='teste';
        beneficiarioTO.nascimento=System.today();
        beneficiarioTO.participacao=10;
        beneficiarioTO.percentualIndenizacao=10;
        beneficiarioTO.tipoBeneficiario='teste';
        beneficiarioTO.grauParentesco = 'Teste';// PLV-5331 INICIO / FIM
        beneficiarioTO.grauParentescoOutros = 'Teste';// PLV-5331 INICIO / FIM
        beneficiarioTO.pessoa = pessoaTO; // PLV-5331 INICIO / FIM
        beneficiarioTO.nome = 'teste'; // PLV-5331 INICIO / FIM
        beneficiarioTO.cpf = 'teste'; // PLV-5331 INICIO / FIM
        beneficiarioTO.sexoBeneficiario = 'teste'; // PLV-5331 INICIO / FIM
        beneficiarioTO.imprimirCertificado = true; // PLV-5331 INICIO / FIM
        
        EmissaoTO.FavorecidoTO favorecidoTO = new EmissaoTO.FavorecidoTO();
        favorecidoTO.papel='teste';
        favorecidoTO.corretagem=10;
        favorecidoTO.participacao=1;
        favorecidoTO.susep='1';
        favorecidoTO.tipoPessoaCorsus='1';
        favorecidoTO.susepEmissao='1';
        favorecidoTO.susepOficialCorretor='1';
        favorecidoTO.susepOrcamento='1';
        favorecidoTO.agenciamento=1;
        favorecidoTO.proLabore=1;
        favorecidoTO.assessoria=1;
        favorecidoTO.pessoa=null;
        favorecidoTO.corretorLider=true;
        favorecidoTO.antecipaComissao=true;
        favorecidoTO.antecipacaoComissao=true; // PLV-5331 INICIO / FIM
        
        
        
        EmissaoTO.DecisaoTO decisaoTO = new EmissaoTO.DecisaoTO();
        decisaoTO.codigo =1;
        decisaoTO.descricao ='teste';
        decisaoTO.tipo='teste';
        decisaoTO.acao ='tetse';
	
        // EmissaoTO
        EmissaoTO emissaoTO = new EmissaoTO();
        remuneracaoTO.favorecidos = new List<EmissaoTO.FavorecidoTO> {favorecidoTO};
        // emissaoTO.FavorecidoTO=favorecidoTO;
        // emissaoTO.DecisaoTO = decisaoTO;
 	    //PLV-4440 - INCLUSAO - Odemir/SYS4B 071020 - FIM
        emissaoTO.origemOriginal = 1;
        emissaoTO.numeroOriginal = 'teste';
        emissaoTO.canalDistribuicao = 'teste';
        emissaoTO.parceiro = 'teste';
        emissaoTO.tipoResponsavelPagamento = 'teste';
        emissaoTO.tipoBeneficiario = 'teste';
        emissaoTO.idContratoParceiro = 'teste';
        emissaoTO.idContratanteParceiro = 'teste';
        emissaoTO.origem = 1;
        emissaoTO.numero = 'teste';
        emissaoTO.segmento = 'teste';
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
        emissaoTO.contratoOriginal = emissaoTO;
         // PLV-4440 - INICIO - Odemir/SYS4B 071020
        emissaoTO.tempoRendaProtegida='24';
        emissaoTO.dependentesFinanceiros=false;
        //emissaoTO.tipoContrato ='VIDA'; PLV4725
        emissaoTO.formaReceberApolice ='DIGITAL';
        emissaoTO.termoGuarda =false;
        emissaoTO.termoResponsabilidade =false;
        emissaoTO.assinaturaEletronica =false;
        // PLV-4440 - FIM - Odemir/SYS4B 071020
    
        emissaoTO.scoreFraude=0.5; // PLV-4416 - INICIO/FIM
        
        emissaoTO.melhorPeriodo = 'I'; // PLV-4386 - INÍCIO/FIM

        emissaoTO.customizavel = true;// PLV-5331 INICIO / FIM
        emissaoTO.dataEndosso = 'Teste';// PLV-5331 INICIO / FIM
        emissaoTO.chaveContrato = 'Teste';// PLV-5331 INICIO / FIM
        emissaoTO.empresa = 'Teste';// PLV-5331 INICIO / FIM
        emissaoTO.sucursal = 1;// PLV-5331 INICIO / FIM
        emissaoTO.ramo = 1;// PLV-5331 INICIO / FIM
        emissaoTO.apolice = 'Teste';// PLV-5331 INICIO / FIM
        //emissaoTO.tiposEndosso = tipoEndossoTo;// PLV-5331 INICIO / FIM
        emissaoTO.varConsultivo = true; // PLV-5331 INICIO / FIM
        emissaoTO.premioPago = 1; // PLV-5331 INICIO / FIM 
        emissaoTO.susepOrcamento = 'Teste'; // PLV-5331 INICIO / FIM
        emissaoTO.entradaNegocio = 'Teste'; // PLV-5331 INICIO / FIM
        emissaoTO.idlote = 'Teste'; // PLV-5331 INICIO / FIM
        emissaoTO.nomeArquivo = 'Teste'; // PLV-5331 INICIO / FIM
        emissaoTO.endosso = 'Teste'; // PLV-5331 INICIO / FIM
        emissaoTO.ordemPortal = 'Teste'; // PLV-5331 INICIO / FIM
        emissaoTO.ProductCode = 'Teste'; // PLV-5331 INICIO / FIM
        emissaoTO.dataProtocolo = 'Teste'; // PLV-5331 INICIO / FIM
        emissaoTO.idProdutoSf = 'Teste'; // PLV-5331 INICIO / FIM
        emissaoTO.dataCancelamento = 'Teste';  // PLV-5331 INICIO / FIM
        emissaoTO.imprimirCertificadoSeguro = true; // PLV-5331 INICIO / FIM
        emissaoTO.precificacao = precificacaoTO; // PLV-5331 INICIO / FIM
        //emissaoTO.remuneracoes = new List<remuneracaoTO>{remuneracaoTO}; // PLV-5331 INICIO / FIM
        //emissaoTO.coberturas = new List<coberturaTO>{coberturaTO}; // PLV-5331 INICIO / FIM
        emissaoTO.indice = 1; // PLV-5331 INICIO / FIM
        //emissaoTO.versoesCalculos = new List<versoesCalculo>{versoesCalculo}; // PLV-5331 INICIO / FIM
        emissaoTO.proposta = emissaoTO; // PLV-5331 INICIO / FIM
        //emissaoTO.retornoAceitacao = retornoAceitacaoTO; // PLV-5331 INICIO / FIM
        emissaoTO.scoreSerasa = 0.5; // PLV-5331 INICIO / FIM
        emissaoTO.melhorPeriodo = 'Teste'; // PLV-5331 INICIO / FIM
        emissaoTO.tarifa = 'Teste'; // PLV-5331 INICIO / FIM
        //emissaoTO.resultadoIntegracoes = retornoIntegracoesTO; // PLV-5331 INICIO / FIM

        




        
        // PayloadTO
        EmissaoTO.PayloadTO payloadTO = new EmissaoTO.PayloadTO();
        payloadTO.proposta = emissaoTO; // PLV-5331 INICIO / FIM
        payloadTO.proposta2 = pessoaTO; // PLV-5331 INICIO / FIM
        payloadTO.orcamento = emissaoTO; // PLV-5331 INICIO / FIM
        payloadTO.orcamentos = new List<EmissaoTO>{emissaoTO};
        
        
        //payloadTO.propostas = new List<payloadTO>{payloadTO}; // PLV-5331 INICIO / FIM
        //payloadTO.ofertas = new List<OfertasTO>{ofertasTO}; // PLV-5331 INICIO / FIM
        //payloadTO.contratantes = new List<ContratanteTO>{contratanteTO}; // PLV-5331 INICIO / FIM
        //payloadTO.devolutivas = new List<EmissaoTO>{emissaoTO}; // PLV-5331 INICIO / FIM
        //payloadTO.retornoFinanceiro = RetornoFinanceiroTO; // PLV-5331 INICIO / FIM
        //payloadTO.retornoIntegracoes = RetornoIntegracoesTO; // PLV-5331 INICIO / FIM
        //payloadTO.resultadosIntegracoes = ResultadoIntegracoesTO; // PLV-5331 INICIO / FIM
        //payloadTO.retornoValidacaoProduto = RetornoValidacaoProdutoTO; // PLV-5331 INICIO / FIM
        //payloadTO.retornoCalculo = RetornoCalculoTO; // PLV-5331 INICIO / FIM
        //payloadTO.retornosCalculo = new List <RetornosCalculoTo>{retornosCalculoTo}; // PLV-5331 INICIO / FIM
        payloadTO.atualizarOrcamento = true; // PLV-5331 INICIO / FIM
        payloadTO.recusada = true; // PLV-5331 INICIO / FIM
        payloadTO.origemRecusa = 'Teste'; // PLV-5331 INICIO / FIM
        payloadTO.calculo = calculoTO;
        payloadTO.retornoAceitacao = retornoAceitacaoTO;


        //OfertasTO // PLV-5331 INICIO / FIM
        EmissaoTO.OfertasTO ofertasTO = new EmissaoTO.OfertasTO(); // PLV-5331 INICIO / FIM
        ofertasTO.orcamento = emissaoTO; // PLV-5331 INICIO / FIM
        ofertasTO.propostas = new List<emissaoTO>{emissaoTO}; // PLV-5331 INICIO / FIM
        //ofertasTO.retornosCalculo = new List <retornosCalculoTo>{retornosCalculoTo}; // PLV-5331 INICIO / FIM
        //ofertasTO.retornoIntegracoes = new List <retornoIntegracoesTO>{retornoIntegracoresTO};// PLV-5331 INICIO / FIM
        //ofertasTO.retornoAceitacao = new List <retornoAceitacaoTO>{retornoAceitacaoTO};// PLV-5331 INICIO / FIM
        
        //dadosCartaoCreditoTO 
        EmissaoTO.dadosCartaoCreditoTO dadosCartaoCreditoTO = new EmissaoTO.dadosCartaoCreditoTO();
        dadosCartaoCreditoTO.numero = 'teste'; // PLV-5331 INICIO / FIM
        dadosCartaoCreditoTO.validade = 'teste'; // PLV-5331 INICIO / FIM
        dadosCartaoCreditoTO.validadeCriptografada = 'teste'; // PLV-5331 INICIO / FIM
        dadosCartaoCreditoTO.nome = 'teste'; // PLV-5331 INICIO / FIM
        dadosCartaoCreditoTO.ticket = 'teste'; // PLV-5331 INICIO / FIM
        dadosCartaoCreditoTO.bandeira = 'teste'; // PLV-5331 INICIO / FIM
        dadosCartaoCreditoTO.cartaoPorto = true; // PLV-5331 INICIO / FIM
        dadosCartaoCreditoTO.nomeTitular = 'teste'; // PLV-5331 INICIO / FIM
        dadosCartaoCreditoTO.codigoBandeiraCartao = 'teste'; // PLV-5331 INICIO / FIM
        dadosCartaoCreditoTO.nomeTitularCartao = 'teste'; // PLV-5331 INICIO / FIM
        dadosCartaoCreditoTO.ticketCartao = 'teste'; // PLV-5331 INICIO / FIM
        dadosCartaoCreditoTO.codigoSeguranca = 'teste'; // PLV-5331 INICIO / FIM
        dadosCartaoCreditoTO.cvv = 'teste'; // PLV-5331 INICIO / FIM 

        //PlanoParcelamentoTO
        EmissaoTO.PlanoParcelamentoTO planoParcelamentoTO =  new EmissaoTO.PlanoParcelamentoTO(); // PLV-5331 INICIO / FIM 
        planoParcelamentoTO.quantidadeParcelas = 1; // PLV-5331 INICIO / FIM 
        planoParcelamentoTO.idPlanoParcelamento = 'teste'; // PLV-5331 INICIO / FIM 
        planoParcelamentoTO.codigoMeioRecebimento = 'teste'; // PLV-5331 INICIO / FIM 
        planoParcelamentoTO.valorParcela = 1; // PLV-5331 INICIO / FIM 


        //ResponsavelFinanceiroSeguroTO
        EmissaoTO.ResponsavelFinanceiroSeguroTO responsavelFinanceiroSeguroTO =  new EmissaoTO.ResponsavelFinanceiroSeguroTO(); // PLV-5331 INICIO / FIM 
        responsavelFinanceiroSeguroTO.nome ='teste'; // PLV-5331 INICIO / FIM
        responsavelFinanceiroSeguroTO.cpf ='teste'; // PLV-5331 INICIO / FIM
        responsavelFinanceiroSeguroTO.vinculoComSegurado ='teste'; // PLV-5331 INICIO / FIM

        // PLV-5331 INICIO
        //ContatoEmergenciaTO
        EmissaoTO.ContatoEmergenciaTO contatoEmergenciaTO =  new EmissaoTO.ContatoEmergenciaTO();
        contatoEmergenciaTO.ddd = '1'; // ANNVI-48 INICIO/FIM
        contatoEmergenciaTO.nome = 'teste';
        contatoEmergenciaTO.telefone = 'teste';
        // PLV-5331 FIM


        // PLV-5331 INICIO
        //SusepBloqueioTO
        EmissaoTO.SusepBloqueioTO susepBloqueioTO =  new EmissaoTO.SusepBloqueioTO();
        //susepBloqueioTO.bloqueios = new List<EmissaoTO.BloqueioTO>{bloqueioTO};
        // PLV-5331 FIM


        // PLV-5331 INICIO
        //BloqueioTO
        EmissaoTO.BloqueioTO bloqueioTO =  new EmissaoTO.BloqueioTO();
        bloqueioTO.bloqueioComissoes = 'teste';
        bloqueioTO.bloqueioFenacor = 'teste';
        bloqueioTO.bloqueioInativos = 'teste';
        bloqueioTO.bloqueioProducao = 'teste';
        bloqueioTO.status = 'teste';
        bloqueioTO.susepPorto = 'teste';
        // PLV-5331 FIM

        // PLV-5331 INICIO
        //ParcelaTO
        EmissaoTO.ParcelaTO parcelaTO =  new EmissaoTO.ParcelaTO();
        parcelaTO.boleto = 'teste';
        parcelaTO.dadosPagamento = dadosPagamentoTO;
        parcelaTO.dataVencimentoParcela = 'teste';
        parcelaTO.meioPagamento = 'teste';
        parcelaTO.numeroParcela = 'teste';
        parcelaTO.numeroTitulo = 'teste';
        parcelaTO.status = 'teste';
        parcelaTO.valorIOF = 0.5;
        parcelaTO.valorParcela = 0.5;
        // PLV-5331 FIM

        // PLV-5331 INICIO
        EmissaoTO.RetornoIntegracaoPepTO retornoIntegracaoPepTO = new EmissaoTO.RetornoIntegracaoPepTO();
        retornoIntegracaoPepTO.cargo = 'teste';
        retornoIntegracaoPepTO.dataAtualizacao = 'teste';
        retornoIntegracaoPepTO.pep = 'teste';
        // PLV-5331 FIM


        // PLV-5331 INICIO
        //PessoaRelacionamentoPepTO
        EmissaoTO.PessoaRelacionamentoPepTO pessoaRelacionamentoPepTO = new EmissaoTO.PessoaRelacionamentoPepTO();
        pessoaRelacionamentoPepTO.cpf = 'teste';
        pessoaRelacionamentoPepTO.grauParentesco = 'teste';
        pessoaRelacionamentoPepTO.tipo = 'teste';
        pessoaRelacionamentoPepTO.nome = 'teste';
        pessoaRelacionamentoPepTO.dadosPessoaFisica = dadosPessoaFisicaTO;
        pessoaRelacionamentoPepTO.dadosPessoaJuridica = dadosPessoaJuridicaTO;
        pessoaRelacionamentoPepTO.retornoIntegracaoPEP = retornoIntegracaoPepTO;
        // PLV-5331 FIM

        //TKCL-458 INICIO FIX01 
        EmissaoTO.ErrosTO errosTO = new EmissaoTO.ErrosTO();
        errosTO.campo = '';
        errosTO.erro = '';

        EmissaoTO.CartaoTO cartaoTO = new EmissaoTO.CartaoTO();
        cartaoTO.primeirosDigitos = '';
        cartaoTO.ultimosDigitos = '';
        cartaoTO.bandeira = '';

        EmissaoTO.CobrancaTO cobrancaTO = new EmissaoTO.CobrancaTO();
        cobrancaTO.id = '';
        cobrancaTO.valor = 0;
        cobrancaTO.estado = '';
        cobrancaTO.meioPagamento = '';
        cobrancaTO.detalhes = '';
        cobrancaTO.idProduto = '';
        cobrancaTO.cartao = cartaoTO;

        EmissaoTO.PortoPagTO portoPagTO = new EmissaoTO.PortoPagTO();
        portoPagTO.cobrancas = new List<EmissaoTO.CobrancaTO>{cobrancaTO};
        portoPagTO.codigo = '';
        portoPagTO.idExterno = '';
        portoPagTO.estado = '';
        portoPagTO.grupo = 1;
        portoPagTO.mensagem = '';
        portoPagTO.id = '';
        //TKCL-458 FIM FIX01

        /*
        // PLV-5331 INICIO
        //RetornoIntegracoesTO
        EmissaoTO.RetornoIntegracoesTO retornoIntegracoesTO = new EmissaoTO.RetornoIntegracoesTO();
        retornoIntegracoesTO.IndiceMonetario = IndiceMonetarioTO;
        retornoIntegracoesTO.validacaoZeroDolar = validacaoZERODolarTO;
        // PLV-5331 FIM
        */

        /*
        // PLV-5331 INICIO
        //ResultadosIntegracoesTO
        EmissaoTO.ResultadosIntegracoesTO resultadosIntegracoesTO = new EmissaoTO.ResultadosIntegracoesTO();
        resultadosIntegracoesTO.dossie = new DossieTO();
        resultadosIntegracoesTO.serasa = new SerasaTO();
        resultadosIntegracoesTO.coberturasAcumuladas = new List<EmissaoTO.CoberturasAcumuladasTO>();
        // PLV-5331 FIM
        */

        /*
        // PLV-5331 INICIO
        //SerasaTO
        EmissaoTO.SerasaTO serasaTO = new EmissaoTO.SerasaTO();
        serasaTO.buscarSocios = new BuscarSociosTO();
        EmissaoTO.SerasaTO();
        serasaTO.dadosCadastrais = new DadosCadastrais();
        EmissaoTO.SerasaTO();
        serasaTO.restritivos = new RestritivosTO();
        EmissaoTO.SerasaTO();
        serasaTO.score = new ScoreTO();
        // PLV-5331 FIM
        */

        /*
        // PLV-5331 INICIO
        //SerasaViagemTO
        EmissaoTO.SerasaViagemTO serasaViagemTO = new EmissaoTO.SerasaViagemTO();
        serasaViagemTO.buscarSocios = new BuscarSociosTO();
        serasaViagemTO.dadosCadastrais =  new DadosCadastraisTO();
        serasaViagemTO.restritivos =  new RestritivosTO();
        serasaViagemTO.score =  new ScoreViagemTO();
        // PLV-5331 FIM
        */



        
    }

}