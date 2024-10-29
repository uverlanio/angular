/**
 * @group             : 
 * @last modified on  : 02-13-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class QuoteBO
{
    private static final String CLASS_NAME = 'QuoteBO';//PLV-5111 - INICIO/FIM
    private static final QuoteBO instancia = new QuoteBO();
    private static QuoteDAO dao = QuoteDAO.getInstance();
    private static ContractDAO contratoDAO = ContractDAO.getInstance();
    private static CIVServices services = CIVServices.getInstance();
    
    public static final String CODIGO_BOLETO = 'BOL';
    public static final String CODIGO_CARTAO_CREDITO = 'CAT';
    public static final String CODIGO_CARTAO_PORTO = 'CPO';
    public static final String ADC = 'ADC';
    
    //INICIO | PLV-1879-28
    public static Id modalidadePrioritaria = null;
    //FIM | PLV-1879-28
    
    //PLV-4398 - Viagem - INICIO - Correção Múltiplos passageiros
    public static Boolean atualizarOrcamento { get; set; }
    //PLV-4398 - Viagem - FIM - Correção Múltiplos passageiros
    
    public QuoteBO (){  }//PLV-4539 - liberado o construtor
    
    public static QuoteBO getInstance(){
        return instancia;
    }
    
    public void gerarPropostaCancelamento(List<Opportunity> listOrcamento,OrcamentoTO.PayloadTO orcamentoPayloadTO)
    {
        
        List<EmissaoTO> propostas = new List<EmissaoTO>();
        try {
            
            // variaveis
            Map<String, Contract> mapContratoPorApolice = new Map<String, Contract>();
            
            // Itera o orcamento para buscar dados no Salesforce
            for(OrcamentoTO orcamentoTO : orcamentoPayloadTO.orcamentos){
                mapContratoPorApolice.put(orcamentoTO.solicitacaoOferta.apolice, new Contract());
            }
            
            // Busca informacoes dos contratos
            for(Contract contrato : contratoDAO.buscarPorNumeroApolice(mapContratoPorApolice.keySet())){
                mapContratoPorApolice.put(contrato.Name,contrato);
            }
            
            for(OrcamentoTO orcamentoTO :orcamentoPayloadTO.orcamentos){
                
                // Verifica se eh um orcamento de cancelamento
                if(orcamentoTO.solicitacaoOferta.tipoSeguro != 'CAN') continue;
                
                EmissaoTO propostaTO = new EmissaoTO();
                converterOrcamentoTOParaPropostaTO(propostaTO,orcamentoTO,mapContratoPorApolice);
                propostas.add(propostaTO);
                
            }
            
            // Envia as propostas para o CIV de transmissao
            transmitirProposta(JSON.serialize(propostas));
        }catch(Exception e){
            throw new QuoteException(e.getLineNumber() + ' : Erro ao gerar payload de proposta: ' + e.getMessage() );
        }
        
    }
    
    @future(callout=true)
    public static void transmitirProposta(String body)
    {
        System.debug('--- Transmitir proposta ---');
        System.debug('corpo da requisição ------------ ' + body);
        RetornoPropostaRestTO retornoPropostaTO = services.transmitirProposta((List<EmissaoTO>)JSON.deserialize(body, List<EmissaoTO>.class));
        System.debug('--- Retorno CIV de transmissão --- '+ retornoPropostaTO);
    }
    
    public EmissaoTO converterOrcamentoTOParaPropostaTO(EmissaoTO emissaoTO, OrcamentoTO orcamentoTO,Map<String, Contract> mapContratoPorApolice)
    {
        try{
            
            OrcamentoTO.SolicitacaoOfertaTO solicitacaoOferta = orcamentoTO.solicitacaoOferta;
            Contract contrato = mapContratoPorApolice.get(solicitacaoOferta.apolice);
            ContratanteContrato__c seguradoContratoPrincipal;
            
            // recupera o contratante principal
            for(ContratanteContrato__c seguradoContrato : contrato.ContratantesContrato__r){
                if(seguradoContrato.Tipo__c == 'Principal'){
                    seguradoContratoPrincipal = seguradoContrato;
                }
            }
            
            
            
            // TODO: Incluir nos desenvolvimentos do Eric: numeroSucursal , tipoEndosso,
            
            /* Informacoes vinda do payload de orcamento */
            
            emissaoTO.codigoEmpresa = Integer.valueOf(solicitacaoOferta.empresa);
            emissaoTO.numeroSucursal = Integer.valueOf(solicitacaoOferta.sucursal);
            emissaoTO.ramoSeguro = Integer.valueOf(solicitacaoOferta.ramo);
            emissaoTO.numeroApolice = String.valueOf(solicitacaoOferta.apolice);
            emissaoTO.tipoSeguro = solicitacaoOferta.tipoSeguro;
            emissaoTO.tipoEndosso = solicitacaoOferta.tipoEndosso;
            emissaoTO.dataCalculo = String.valueOf(solicitacaoOferta.dataCalculo);
            emissaoTO.meioComercializacao = solicitacaoOferta.meioComercializacao;
            emissaoTO.parceiro = solicitacaoOferta.parceiro;
            emissaoTO.numeroOrcamento = String.valueOf(solicitacaoOferta.numeroOrcamento);
            emissaoTO.codigoProdutoVida = solicitacaoOferta.codigoProdutoVida;
            emissaoTO.tipoVigencia = solicitacaoOferta.tipoVigencia;
            emissaoTO.vigenciaInicial = String.valueOf(solicitacaoOferta.vigenciaInicial);
            emissaoTO.vigenciaFinal = String.valueOf(solicitacaoOferta.vigenciaFinal);
            emissaoTO.segmento = solicitacaoOferta.segmento;
            //propostaTO.calculo.precificacao.premio.informado = SolicitacaoOferta.precificacao.premio.informado;
            emissaoTO.dataCriacaoPortal = String.valueOf(solicitacaoOferta.dataCriacaoPortal);
            
            
            /* Informacoes vinda do Salesforce */
            
            emissaoTO.tipoResponsavelPagamento = (seguradoContratoPrincipal != null) ? seguradoContratoPrincipal.TipoResponsavelPagamento__c : null; //TODO Pegar o tipo do responsavel pelo pagamento do contratante principal
            emissaoTO.tipoBeneficiario = ''; // TODO: Esse é um campo que deveria estar no nó de beneficiarios da proposta. No caso d RENNER, esse campo vem no cabeçalho com o valor 'PAR'
            emissaoTO.idContratoParceiro = contrato.Proposta__r.IdContratoParceiro__c;
            emissaoTO.idContratanteParceiro = contrato.Proposta__r.IdContratanteParceiro__c;
            emissaoTO.origem = Integer.valueOf(contrato.Name.substring(0,2));
            emissaoTO.numero = contrato.Name.substring(2);
            emissaoTO.numeroEndosso = Integer.valueOf(contrato.Endosso__c);
            //            propostaTO.descricaoRamo = ''; // Verificar de onde vem esse valor
            emissaoTO.modalidade = Integer.valueOf(contrato.Proposta__r.Modalidade__r.Codigo__c);
            emissaoTO.dataEmissao = String.valueOf(System.today());
            
        }catch (Exception e){
            throw new QuoteException(e.getLineNumber() + ': Erro ao gerar a proposta: ' + e.getMessage());
        }
        
        converterSeguradosOrcamentoTOParaSeguradosPropostaTO(emissaoTO, orcamentoTO.solicitacaoOferta.contratantes);
        
        return emissaoTO;
    }
    
    public EmissaoTO converterSeguradosOrcamentoTOParaSeguradosPropostaTO(EmissaoTO propostaTO, List<OrcamentoTO.ContratanteTO> listSeguradoOrcamento){
        
        List<EmissaoTO.ContratanteTO> listSeguradoTO = new List<EmissaoTO.ContratanteTO>();
        
        try{
            
            for(OrcamentoTO.ContratanteTO orcamentoSeguradoTO : listSeguradoOrcamento){
                EmissaoTO.ContratanteTO contratanteTO = new EmissaoTO.ContratanteTO();
                contratanteTO.tipo = orcamentoSeguradoTO.tipo;
                contratanteTO.pessoa = converterOrcamentoPessoaTOParaPropostaPessoaTO(orcamentoSeguradoTO.pessoa); // PessoaTO
                contratanteTO.dadosPagamento = converterOrcamentoDadosPagamentoTOParaPropostaDadosPagamentoTO(orcamentoSeguradoTO.dadosPagamento); // DadosPagamentoTO
                contratanteTO.grupos = converterOrcamentoGruposSeguradoTOParaPropostaGrupoSeguradoTO(orcamentoSeguradoTO.grupos); // List<GrupoTO
                
                
                listSeguradoTO.add(contratanteTO);
            }
            
        }catch (Exception e){
            
            throw new QuoteException(e.getLineNumber() + ' : Erro ao gerar os contratantes da proposta : ' + e.getMessage());
            
        }
        
        propostaTO.contratantes = listSeguradoTO;
        
        return propostaTO;
        
    }
    
    public List<EmissaoTO.GrupoTO> converterOrcamentoGruposSeguradoTOParaPropostaGrupoSeguradoTO(List<OrcamentoTO.GrupoTO> orcamentoGruposSegurado){
        
        List<EmissaoTO.GrupoTO> grupos = new List<EmissaoTO.GrupoTO>();
        
        for(OrcamentoTO.GrupoTO orcamentoGrupoTO : orcamentoGruposSegurado){
            
            EmissaoTO.GrupoTO grupoTO = new EmissaoTO.GrupoTO();
            grupoTO.numero = String.valueOf(orcamentoGrupoTO.numero);
            grupoTO.nome = orcamentoGrupoTO.nome;
            // 2666 - INICIO
            grupoTO.qtdeVidas = orcamentoGrupoTO.qtdeSegurados;
            // 2666 - FIM
            grupoTO.segurados = converterOrcamentoVidasSeguradoTOParaPropostaVidaSeguradoTO(orcamentoGrupoTO.segurados);
            
            grupos.add(grupoTO);
            
        }
        return grupos;
    }
    
    public List<EmissaoTO.SeguradoTO> converterOrcamentoVidasSeguradoTOParaPropostaVidaSeguradoTO(List<OrcamentoTO.SeguradoTO> orcamentoVidasSegurado){
        
        List<EmissaoTO.SeguradoTO> segurados = new List<EmissaoTO.SeguradoTO>();
        
        for(OrcamentoTO.SeguradoTO orcamentoVidaTO : orcamentoVidasSegurado) {
            
            EmissaoTO.SeguradoTO seguradoTO = new EmissaoTO.SeguradoTO();
            seguradoTO.numero = String.valueOf(orcamentoVidaTO.numero);
            seguradoTO.pessoa = converterOrcamentoPessoaTOParaPropostaPessoaTO(orcamentoVidaTO.pessoa);
            
            segurados.add(seguradoTO);
        }
        
        return segurados;
    }
    
    public EmissaoTO.DadosPagamentoTO converterOrcamentoDadosPagamentoTOParaPropostaDadosPagamentoTO(OrcamentoTO.DadosPagamentoTO orcamentoDadosPagamento){
        EmissaoTO.DadosPagamentoTO dadospagamentoTO = new EmissaoTO.DadosPagamentoTO();
        dadospagamentoTO.quantidadeParcelas = Integer.valueOf(orcamentoDadosPagamento.quantidadeParcelas);
        dadospagamentoTO.vencimentoPrimeiraParcela = String.valueOf(orcamentoDadosPagamento.vencimentoPrimeiraParcela);
        dadospagamentoTO.tipoResponsavelPagamento = orcamentoDadosPagamento.tipoResponsavelPagamento;
        return dadospagamentoTO;
    }
    
    public EmissaoTO.PessoaTO converterOrcamentoPessoaTOParaPropostaPessoaTO(OrcamentoTO.PessoaTO orcamentoPessoaTO)
    {
        EmissaoTO.PessoaTO pessoaTO = new EmissaoTO.PessoaTO();
        
        pessoaTO.tipo = orcamentoPessoaTO.tipo;
        pessoaTO.nome = orcamentoPessoaTO.nome;
        pessoaTO.email = orcamentoPessoaTO.email;
        
        // Verifica se eh pessoa fisica ou juridica e converte
        if(pessoaTO.tipo == 'FIS'){
            EmissaoTO.DadosPessoaFisicaTO dadospessoafisicaTO = new EmissaoTO.DadosPessoaFisicaTO();
            dadospessoafisicaTO.sexo = orcamentoPessoaTO.dadosPessoaFisica.sexo;
            dadospessoafisicaTO.numeroCpf = orcamentoPessoaTO.dadosPessoaFisica.numeroCpf;
            dadospessoafisicaTO.digitoCpf = orcamentoPessoaTO.dadosPessoaFisica.digitoCpf;
            dadospessoafisicaTO.nacionalidade = orcamentoPessoaTO.dadosPessoaFisica.nacionalidade;
            dadospessoafisicaTO.paisDeOrigem = orcamentoPessoaTO.dadosPessoaFisica.paisDeOrigem; //PLV-5231 - INICIO/FIM
            dadospessoafisicaTO.estadoCivil = orcamentoPessoaTO.dadosPessoaFisica.estadoCivil;
            dadospessoafisicaTO.dataNascimento = String.valueOf(orcamentoPessoaTO.dadosPessoaFisica.dataNascimento);
            pessoaTO.dadosPessoaFisica = dadospessoafisicaTO;
        }else{
            EmissaoTO.DadosPessoaJuridicaTO dadosPessoaJuridicaTO = new EmissaoTO.DadosPessoaJuridicaTO();
            dadosPessoaJuridicaTO.cnpj = orcamentoPessoaTO.dadosPessoaJuridica.cnpj;
            dadosPessoaJuridicaTO.codigoCNAE = String.valueOf(orcamentoPessoaTO.dadosPessoaJuridica.codigoCNAE);
            pessoaTO.dadosPessoaJuridica = dadosPessoaJuridicaTO;
        }
        
        // converte os telefones
        if(!orcamentoPessoaTO.telefones.isEmpty()){
            List<EmissaoTO.TelefoneTO> telefones = new List<EmissaoTO.TelefoneTO>();
            for(OrcamentoTO.TelefoneTO orcamentoTelefoneTO : orcamentoPessoaTO.telefones){
                EmissaoTO.TelefoneTO telefonesTO = new EmissaoTO.TelefoneTO();
                telefonesTO.tipoTelefone = orcamentoTelefoneTO.tipoTelefone;
                telefonesTO.numeroTelefone = orcamentoTelefoneTO.numeroTelefone;
                telefonesTO.dddTelefone = orcamentoTelefoneTO.dddTelefone;
                telefones.add(telefonesTO);
            }
            pessoaTO.telefones = telefones;
        }
        
        // converte os enderecos
        if(!orcamentoPessoaTO.enderecos.isEmpty()){
            List<EmissaoTO.EnderecoTO> enderecos = new List<EmissaoTO.EnderecoTO>();
            for(OrcamentoTO.EnderecoTO orcamentoEnderecoTO : orcamentoPessoaTO.enderecos){
                EmissaoTO.EnderecoTO enderecoTO = new EmissaoTO.EnderecoTO();
                enderecoTO.tipoEndereco = orcamentoEnderecoTO.tipoEndereco;
                enderecoTO.tipoLogradouro = orcamentoEnderecoTO.tipoLogradouro;
                enderecoTO.logradouro = orcamentoEnderecoTO.logradouro;
                enderecoTO.numeroLogradouro = orcamentoEnderecoTO.numeroLogradouro;
                enderecoTO.bairro = orcamentoEnderecoTO.bairro;
                enderecoTO.cidade = orcamentoEnderecoTO.cidade;
                enderecoTO.uf = orcamentoEnderecoTO.uf;
                enderecoTO.cep = orcamentoEnderecoTO.cep;
                enderecoTO.complementoCep = orcamentoEnderecoTO.complementoCep;
                enderecoTO.paisResidencia = orcamentoEnderecoTO.paisResidencia;
                enderecos.add(enderecoTO);
            }
            pessoaTO.enderecos = enderecos;
        }
        
        return pessoaTO;
    }
    
    public Quote obterProposta(String numero)
    {
        List<Quote> propostas = QuoteDAO.getInstance().obterPropostaPorNumero(numero);
        
        if(propostas.size() == 0)
            return null;
        
        return propostas[0];
    }
    
    public List<SeguradoProposta__c> buscarListVidaProposta(Id quoteId){
        return dao.buscarListVidaProposta(new Set<Id>{quoteId});
    }
    
    public List<QuestionarioAnaliseRiscoController.WrapperQuestionario> buscarPerguntasQuestionario(Id quoteId){
        
        // Busca as Garantias da Proposta
        Set<Id> setGarantiaProdutoId = new Set<Id>();
        for(GarantiaProposta__c garantiaProposta : dao.buscarGarantiasProposta(quoteId)){
            setGarantiaProdutoId.add(garantiaProposta.GarantiaProduto__c);
        }
        
        // Busca o questionario com prioridade pela garantia contida na proposta
        Map<Integer, List<QuestionarioProduto__c>> mapListQuestionarioPorPrioridade =  new Map<Integer, List<QuestionarioProduto__c>>();
        Integer menorPrioridade;
        
        for (QuestionarioProduto__c questionarioProduto : dao.buscarQuestionarioPrioritario(setGarantiaProdutoId)){
            
            if(menorPrioridade == null || questionarioProduto.Prioridade__c <= menorPrioridade){
                menorPrioridade = Integer.valueOf(questionarioProduto.Prioridade__c);
            }
            
            List<QuestionarioProduto__c> listQuestionarioProduto = mapListQuestionarioPorPrioridade.get(Integer.valueOf(questionarioProduto.Prioridade__c));
            if(listQuestionarioProduto == null) listQuestionarioProduto = new List<QuestionarioProduto__c>();
            listQuestionarioProduto.add(questionarioProduto);
            mapListQuestionarioPorPrioridade .put(Integer.valueOf(questionarioProduto.Prioridade__c), listQuestionarioProduto);
        }
        
        Map<Id,QuestionarioProduto__c> mapQuestionarioProdutoPorQuestionario = new Map<Id,QuestionarioProduto__c>();
        List<QuestionarioProduto__c> listQuestionarioProdutos = mapListQuestionarioPorPrioridade.get(menorPrioridade);
        if(listQuestionarioProdutos == null) listQuestionarioProdutos = new List<QuestionarioProduto__c>();
        for(QuestionarioProduto__c questionarioProduto : listQuestionarioProdutos){
            mapQuestionarioProdutoPorQuestionario.put(questionarioProduto.Questionario__c, questionarioProduto);
        }
        
        Map<Id, List<PerguntaQuestionario__c>> mapPerguntasPorQuestionario = new Map<Id, List<PerguntaQuestionario__c>>();
        
        // Busca as Perguntas do Questionario e suas respostas
        for(PerguntaQuestionario__c perguntaQuestionario :  dao.buscarPerguntasQuestionario(mapQuestionarioProdutoPorQuestionario.keySet())){
            List<PerguntaQuestionario__c> listWrapperQuestionario = mapPerguntasPorQuestionario.get(perguntaQuestionario.Questionario__c);
            if(listWrapperQuestionario == null) listWrapperQuestionario = new List<PerguntaQuestionario__c>();
            listWrapperQuestionario.add(perguntaQuestionario);
            mapPerguntasPorQuestionario.put(perguntaQuestionario.Questionario__c, listWrapperQuestionario);
        }
        
        // monta Wrapper
        List<QuestionarioAnaliseRiscoController.WrapperQuestionario> listWrapper = new List<QuestionarioAnaliseRiscoController.WrapperQuestionario>();
        for(Id questionarioId : mapPerguntasPorQuestionario.keySet()){
            QuestionarioProduto__c questionarioProduto = mapQuestionarioProdutoPorQuestionario.get(questionarioId);
            
            QuestionarioAnaliseRiscoController.WrapperQuestionario wrapperQuestionario = new QuestionarioAnaliseRiscoController.WrapperQuestionario();
            wrapperQuestionario.questionarioId            = questionarioId;
            wrapperQuestionario.listPerguntaQuestionario  =  mapPerguntasPorQuestionario.get(questionarioId);
            wrapperQuestionario.limiteCapitalMaximo       = questionarioProduto.LimiteCapitalMaximo__c;
            wrapperQuestionario.limiteCapitalMinimo       = questionarioProduto.LimiteCapitalMinimo__c;
            wrapperQuestionario.siglaGarantia             = questionarioProduto.GarantiaProduto__r.Garantia__r.Sigla__c;
            
            listWrapper.add(wrapperQuestionario);
        }
        
        return listWrapper;
    }
    
    //Verifica se todos os beneficiários totalizam os 100%
    public void validarPercentualBeneficiarios(List<Quote> propostas){
        Set<Id> propostasIds = new Set<Id>();
        Map<Id, Quote> mapProposta = new Map<Id, Quote>();
        
        //Recupera ids das propostas e realiza busca para trazer a participaçao dos beneficiários
        for(Quote proposta : propostas){
            if(proposta.Status == 'Em aprovação')
            {
                propostasIds.add(proposta.Id);
                mapProposta.put(proposta.Id, proposta);
            }
        }
        
        for(SeguradoProposta__c vidaproposta : dao.buscarListVidaProposta(propostasIds)){
            Decimal percentualTotal = 0;
            
            for(BeneficiarioSeguradoProposta__c beneficiario : vidaproposta.BeneficiariosSeguradosProposta__r){
                if(beneficiario.TipoBeneficiario__c == 'Nome do beneficiário'){
                    percentualTotal += beneficiario.Participacao__c != null ? beneficiario.Participacao__c : 0;
                    
                    //          if(percentualTotal != 100 && vidaproposta.Status == 'Em aprovação'){
                    if(percentualTotal != 100){
                        mapProposta.get(vidaproposta.GrupoProposta__r.ContratanteProposta__r.Proposta__c).addError('A soma dos percentuais dos beneficiários, deve ser igual a 100%');
                    }
                }
            }
        }
        
    }
    
    public List<RespostaQuestionario__c> salvarRespostaQuestionario(List<RespostaQuestionario__c>  respostas){
        upsert respostas;
        return respostas;
    }
    
    public List<RemuneracaoProposta__c> buscarRemuneracaoProposta (Id quoteId){
        return dao.buscarRemuneracaoProposta(new Set<Id>{quoteId});
    }
    
    public List<Opportunity> buscarRemuneracaoOrcamentoNoOrcamento (Id quoteId){
        return dao.buscarRemuneracaoOrcamentoNoOrcamento(new Set<Id>{quoteId});
    }
    
    public String salvarRemuneracaoProposta (List<RemuneracaoProposta__c> listRemuneracaoProposta, List<RemuneracaoProposta__c> listaRemuneracaoPropostaParaApagar){
        String mensagem = '';
        
        try {
            if(listRemuneracaoProposta.size() > 0) upsert listRemuneracaoProposta;
            if(listaRemuneracaoPropostaParaApagar.size() > 0 ) delete listaRemuneracaoPropostaParaApagar;
        }catch(Exception e) {
            mensagem =e.getMessage();
            throw new QuoteException('Erro ao inserir/atualizar as remunerações da proposta. ' + e.getLineNumber() + ': ' + e.getMessage());
        }
        return mensagem;
    }
    
    public void validarDadosPagamentoSeguradoProposta(List<ContratanteProposta__c> listSeguradoProposta){
        
        // Declara variaveis
        Set<Id> setQuoteId = new Set<Id>();
        Map<Id,Account> mapContaResponsavelPagamento = new Map<Id,Account>();
        Map<Id, Map<Id,List<CondicaoCobranca__c>>> mapCondicoesCobrancaPorProduto = new Map<Id, Map<Id,List<CondicaoCobranca__c>>>();//PLV-4260
        Map<Id,Id> mapProdutoIdPorPropostaId = new Map<Id, Id>();
        
        // Itera os contratantes
        for(ContratanteProposta__c seguradoProposta : listSeguradoProposta){
            if(seguradoProposta.FormaPagamento__c == null) continue;
            setQuoteId.add(seguradoProposta.Proposta__c);
            mapContaResponsavelPagamento.put(seguradoProposta.ResponsavelPagamento__c,new Account());
        }
        
        if(setQuoteId.isEmpty()) return;
        
        // Busca a propostas dos contratantes
        for(Quote proposta : dao.buscarPropostasPorId(setQuoteId)){
            mapProdutoIdPorPropostaId.put(proposta.Id, proposta.Produto__c);
        }
        
        // Busca as contas dos contratantes
        if(!mapContaResponsavelPagamento.isEmpty()){
            for(Account conta : dao.buscarContas(mapContaResponsavelPagamento.keySet())){
                mapContaResponsavelPagamento.put(conta.Id,conta);
            }
        }
        
        // Busca as condicoes de cobranca do produto comercial e armazena em mapa
        for(Product2 produto : dao.buscarProduto(mapProdutoIdPorPropostaId.values())){
            
            List<CondicaoCobranca__c> listCondicaoCobrancas = produto.CondicoesCobranca__r;
            if(listCondicaoCobrancas == null ) listCondicaoCobrancas = new List<CondicaoCobranca__c>();
            //PLV-4260-INICIO
            Map<Id,List<CondicaoCobranca__c>> mapCondicaoCobrancasPorFormaPagamento = new Map<Id, List<CondicaoCobranca__c>>();
            for(CondicaoCobranca__c condicaoCobranca : listCondicaoCobrancas){
                if(!mapCondicaoCobrancasPorFormaPagamento.containsKey(condicaoCobranca.FormaPagamento__c)) mapCondicaoCobrancasPorFormaPagamento.put(condicaoCobranca.FormaPagamento__c,new List<CondicaoCobranca__c>());
                mapCondicaoCobrancasPorFormaPagamento.get(condicaoCobranca.FormaPagamento__c).add(condicaoCobranca);
            }
            //PLV-4260-FIM
            mapCondicoesCobrancaPorProduto.put(produto.Id,mapCondicaoCobrancasPorFormaPagamento);
        }
        
        // Inicia as validacoes por contratante da proposta
        for(ContratanteProposta__c contratanteProposta : listSeguradoProposta)
        {
            
            if(contratanteProposta.FormaPagamento__c == null) continue;
            //PLV-4260-INICIO
            // Pega as condicoes de cobranca do produto comercial
            Map<Id,List<CondicaoCobranca__c>> mapCondicaoCobrancasPorFormaPagamento =
                mapCondicoesCobrancaPorProduto.get(mapProdutoIdPorPropostaId.get(contratanteProposta.Proposta__c));
            
            // pega a condicao de cobranca
            //PLV-4790 FIX 12 - INÍCIO
            List<CondicaoCobranca__c> condicaoCobranca;
            if(mapCondicaoCobrancasPorFormaPagamento != null){
                condicaoCobranca = mapCondicaoCobrancasPorFormaPagamento.get(contratanteProposta.FormaPagamento__c);
            }
            //PLV-4790 FIX 12 - FIM
            // valida se a condicao de cobranca existe no produto comercial
            if(condicaoCobranca == null){continue;}
            

            //PLV-4260-FIM
            if(contratanteProposta.ResponsavelPagamento__c == null)
                contratanteProposta.addError('Responsável pelo pagamento não informado!');
            else
            {
                // Declara listas
                List<CartaoCredito__c> listCartaoCredito = new List<CartaoCredito__c>();
                List<CartaoCredito__c> listCartaoCreditoPorto = new List<CartaoCredito__c>();
                
                // Pega a conta do responsavel
                Account conta = mapContaResponsavelPagamento.get(contratanteProposta.ResponsavelPagamento__c);
                
                // Pega os cartoes do responsavel
                List<CartaoCredito__c> listCartaoCreditoTemp = conta.CartoesCredito__r;
                if(listCartaoCreditoTemp == null) listCartaoCreditoTemp = new List<CartaoCredito__c>();
                
                // Pega as informacoes bancarias do responsavel
                List<InformacaoBancaria__c> listInformacaoBancaria = conta.InformacoesBancarias__r;
                if(listInformacaoBancaria == null) listInformacaoBancaria = new List<InformacaoBancaria__c>();
                
                // itera os cartoes do responsavel
                for (CartaoCredito__c cartaoCredito : listCartaoCreditoTemp){
                    if(cartaoCredito.CartoPortoSeguro__c) {
                        listCartaoCreditoPorto.add(cartaoCredito);
                    }else{
                        listCartaoCredito.add(cartaoCredito);
                    }
                }
                //PLV-4260-INICIO
                // Valida se informou o endereco do boleto, para BOLETO
                if(condicaoCobranca[0].FormaPagamento__r.Codigo__c == CODIGO_BOLETO && contratanteProposta.EnderecoBoleto__c == null) {
                    contratanteProposta.addError('Para boleto é necessário informar o endereço do boleto');
                    
                    // Valida se existe cartao de credito cadastrado
                }else if(condicaoCobranca[0].FormaPagamento__r.Codigo__c == CODIGO_CARTAO_CREDITO && listCartaoCredito.size() == 0 ){
                    contratanteProposta.addError('Para cartão de crédito é necessário ter um cartão cadastrado!');
                    
                    // Valida se existe cartao de credito porto cadastrado
                }else if(condicaoCobranca[0].FormaPagamento__r.Codigo__c == CODIGO_CARTAO_PORTO && listCartaoCreditoPorto.size() == 0){
                    contratanteProposta.addError('Para pagamento no cartão de crédito Porto é necessário ter um cartão Porto cadastrado!');
                    
                    // Valida se existe uma conta bancaria cadastrada
                }else if(condicaoCobranca[0].FormaPagamento__r.Codigo__c == ADC && listInformacaoBancaria.size() == 0){
                    contratanteProposta.addError('Para débito em conta é necessário ter uma informação bancária cadastrada!');
                }
                //PLV-4260-FIM
            }
            
            // valida se a quantidade de parcelas eh informada
            if(contratanteProposta.QuantidadeParcelas__c == null) {
                
                //seguradoProposta.addError('Quantidade de parcelas não informada!');
                
                // valida se a quantidade de parcelas eh permitida pela condicao de cobranca do produto comercial
            }else{
                
                //            }else if(Integer.valueOf(condicaoCobranca.QuantidadeParcelas__c) < Integer.valueOf(seguradoProposta.QuantidadeParcelas__c)) {
                //PLV-4260-INICIO
                List<String> parcelasCobranca = new List<String>();
                for(CondicaoCobranca__c condicao : condicaoCobranca){
                    parcelasCobranca.addAll(condicao.QuantidadeParcelas__c.split(';')); 
                }
                //PLV-4260-FIM
                Boolean permitido = false;
                
                for(String parcela : parcelasCobranca)
                {
                    System.debug( '@@@@ Integer.valueOf(contratanteProposta.QuantidadeParcelas__c) :>' + Integer.valueOf(contratanteProposta.QuantidadeParcelas__c));
                    System.debug( '@@@@ Integer.valueOf(parcela) :>' + Integer.valueOf(parcela));
                    if(Integer.valueOf(parcela) == Integer.valueOf(contratanteProposta.QuantidadeParcelas__c))
                    {
                        permitido = true;
                        break;
                    }
                }
               
                if(!permitido)
                    contratanteProposta.addError('Quantidade de parcelas não permitida pelo produto comercial!');
            }
        }
    }
    
    public void validarDadosPagamentoVidaProposta(List<SeguradoProposta__c> listVidaProposta)
    {
        // Declara variaveis
        Set<Id>                                 setQuoteId                      = new Set<Id>();
        SET<Id>                                 setGrupoPropostaId              = new Set<Id>();
        Map<Id,Account>                         mapContaResponsavelPagamento    = new Map<Id,Account>();
        Map<Id, Map<Id,CondicaoCobranca__c>>    mapCondicoesCobrancaPorProduto  = new Map<Id, Map<Id,CondicaoCobranca__c>>();
        Map<Id,Id>                              mapProdutoIdPorPropostaId       = new Map<Id, Id>();
        Map<Id,Id>                              mapPropostaPorGrupo             = new Map<Id, Id>();
        
        // Itera as Vidas
        for(SeguradoProposta__c vidaProposta : listVidaProposta)
        {
            if(vidaProposta.FormaPagamento__c == null)
                continue;
            
            setGrupoPropostaId.add(vidaProposta.GrupoProposta__c);
            mapContaResponsavelPagamento.put(vidaProposta.ResponsavelPagamento__c,new Account());
        }
        
        
        //busca a proposta pelas segurados
        for(GrupoProposta__c grupoProposta : dao.buscarGrupoProposta(setGrupoPropostaId))
        {
            setQuoteId.add(grupoProposta.ContratanteProposta__r.Proposta__c);
            mapPropostaPorGrupo.put(grupoProposta.Id,grupoProposta.ContratanteProposta__r.Proposta__c);
        }
        
        if(setQuoteId.isEmpty())
            return;
        
        // Busca a propostas das segurados
        for(Quote proposta : dao.buscarPropostasPorId(setQuoteId))
            mapProdutoIdPorPropostaId.put(proposta.Id, proposta.Produto__c);
        
        // Busca as contas dos contratantes
        if(!mapContaResponsavelPagamento.isEmpty())
        {
            for(Account conta : dao.buscarContas(mapContaResponsavelPagamento.keySet()))
                mapContaResponsavelPagamento.put(conta.Id,conta);
        }
        
        // Busca as condicoes de pagamento do produto comercial e armazena em mapa
        for(Product2 produto : dao.buscarProduto(mapProdutoIdPorPropostaId.values()))
        {
            List<CondicaoCobranca__c> listCondicaoCobrancas = produto.CondicoesCobranca__r;
            if(listCondicaoCobrancas == null )
                listCondicaoCobrancas = new List<CondicaoCobranca__c>();
            
            Map<Id,CondicaoCobranca__c> mapCondicaoCobrancasPorFormaPagamento = new Map<Id, CondicaoCobranca__c>();
            
            for(CondicaoCobranca__c condicaoCobranca : listCondicaoCobrancas)
                mapCondicaoCobrancasPorFormaPagamento.put(condicaoCobranca.FormaPagamento__c, condicaoCobranca);
            
            mapCondicoesCobrancaPorProduto.put(produto.Id, mapCondicaoCobrancasPorFormaPagamento);
        }
        
        // Inicia as validacoes por contratante da proposta
        for(SeguradoProposta__c vidaProposta : listVidaProposta)
        {
            if(vidaProposta.FormaPagamento__c == null)
                continue;
            
            // Pega as condicoes de cobranca do produto comercial
            Map<Id,CondicaoCobranca__c> mapCondicaoCobrancasPorFormaPagamento =
                mapCondicoesCobrancaPorProduto.get(
                    mapProdutoIdPorPropostaId.get(
                        mapPropostaPorGrupo.get(
                            vidaProposta.GrupoProposta__c)));
            
            // pega a condicao de cobranca
            system.debug('colection: ' + mapCondicoesCobrancaPorProduto);
            system.debug('colection: ' + mapCondicaoCobrancasPorFormaPagamento);
            system.debug(': ' + vidaProposta.FormaPagamento__c);
            CondicaoCobranca__c condicaoCobranca = mapCondicaoCobrancasPorFormaPagamento.get(vidaProposta.FormaPagamento__c);
            
            // valida se a condicao de cobranca existe no produto comercial
            if(condicaoCobranca == null)
            {
                //TODO: ERIC, VER PQ ESTÁ CAINDO AQUI SENDO QUE NÃO DEVERIA
                //vidaProposta.addError('Condição de cobrança não cadastrada no produto comercial!');
                continue;
            }
            
            
            if(vidaProposta.ResponsavelPagamento__c == null){
                vidaProposta.addError('Responsável pelo pagamento não informado!');
            }else {
                // Declara listas
                List<CartaoCredito__c> listCartaoCredito = new List<CartaoCredito__c>();
                List<CartaoCredito__c> listCartaoCreditoPorto = new List<CartaoCredito__c>();
                
                // Pega a conta do responsavel
                Account conta = mapContaResponsavelPagamento.get(vidaProposta.ResponsavelPagamento__c);
                
                // Pega os cartoes do responsavel
                List<CartaoCredito__c> listCartaoCreditoTemp = conta.CartoesCredito__r;
                if(listCartaoCreditoTemp == null) listCartaoCreditoTemp = new List<CartaoCredito__c>();
                
                // Pega as informacoes bancarias do responsavel
                List<InformacaoBancaria__c> listInformacaoBancaria = conta.InformacoesBancarias__r;
                if(listInformacaoBancaria == null) listInformacaoBancaria = new List<InformacaoBancaria__c>();
                
                // itera os cartoes do responsavel
                for (CartaoCredito__c cartaoCredito : listCartaoCreditoTemp){
                    if(cartaoCredito.CartoPortoSeguro__c) {
                        listCartaoCreditoPorto.add(cartaoCredito);
                    }else{
                        listCartaoCredito.add(cartaoCredito);
                    }
                }
                
                // Valida se informou o endereco do boleto, para BOLETO
                if(condicaoCobranca.FormaPagamento__r.Codigo__c == CODIGO_BOLETO && vidaProposta.EnderecoBoleto__c == null) {
                    vidaProposta.addError('Para boleto é necessário informar o endereço do boleto');
                    
                    // Valida se existe cartao de credito cadastrado
                }else if(condicaoCobranca.FormaPagamento__r.Codigo__c == CODIGO_CARTAO_CREDITO && listCartaoCredito.size() == 0 ){
                    vidaProposta.addError('Para cartão de crédito é necessário ter um cartão cadastrado!');
                    
                    // Valida se existe cartao de credito porto cadastrado
                }else if(condicaoCobranca.FormaPagamento__r.Codigo__c == CODIGO_CARTAO_PORTO && listCartaoCreditoPorto.size() == 0){
                    vidaProposta.addError('Para pagamento no cartão de crédito Porto é necessário ter um cartão Porto cadastrado!');
                    
                    // Valida se existe uma conta bancaria cadastrada
                }else if(condicaoCobranca.FormaPagamento__r.Codigo__c == ADC && listInformacaoBancaria.size() == 0){
                    vidaProposta.addError('Para débito em conta é necessário ter uma informação bancária cadastrada!');
                }
            }
            
            //TODO: comentado porque nem sempre vai existir informação de pgto na segurado da proposta
            
            // valida se a quantidade de parcelas eh informada
            //             if(vidaProposta.QuantidadeParcelas__c == null) 
            //             {
            
            //                 vidaProposta.addError('Quantidade de parcelas não informada!');
            
            //                 // valida se a quantidade de parcelas eh permitida pela condicao de cobranca do produto comercial
            //             } 
            //             else 
            //             {
            // //            }else if(condicaoCobranca.QuantidadeParcelas__c < vidaProposta.QuantidadeParcelas__c) {
            
            //                 List<String> parcelasCobranca = condicaoCobranca.QuantidadeParcelas__c.split(';');
            //                 Boolean permitido = false;
            
            //                 for(String parcela : parcelasCobranca)
            //                 {
            //                     if(Integer.valueOf(parcela) == Integer.valueOf(vidaProposta.QuantidadeParcelas__c))
            //                     {
            //                         permitido = true;
            //                         break;
            //                     }
            //                 }
            
            //                 if(!permitido)
            //                     vidaProposta.addError('Quantidade de parcelas não permitida pelo produto comercial!');
            //             }
        }
    }
    
    // PLV-2312-28 INICIO
    //------ Trigger creating Contract
    public void processarCriacaoContrato(List<Quote> lstQuotes, Map<Id, Quote> mapOldQuotes)
    {
        System.debug('gera contrato >> INICIO');
        
        Set<Id> quotesIds = new Set<Id>();
        
        // Make sure of the map's instance
        if(mapOldQuotes == null)
            mapOldQuotes = new Map<Id, Quote>();
        
        // Verify if is a new record or if have changes in the date field
        for(Quote objQuote : lstQuotes){
            Quote quoteOld = mapOldQuotes.get(objQuote.Id);
            system.debug('gera contrato >> mapOldQuotes: ' + mapOldQuotes.get(objQuote.Id));
            System.debug('gera contrato >> quoteOld: '+ quoteOld);
            System.debug('gera contrato >> status: '+ objQuote.Status);
            // PLV-2378-29 - INICIO
            if(objQuote.Status == 'Disponível para contratação' && (quoteOld == null  || (quoteOld.Status != 'Contratada'  && quoteOld.Status != 'Disponível para contratação')))
            {
                quotesIds.add(objQuote.Id);
            }
            // PLV-2378-29 - FINAL
        }
        
        System.debug('gera contrato >> ids : '+ quotesIds);
        
        //INICIO - PLV-2287-28
        if(quotesIds.size() > 0) {
            System.debug('GERANDO CONTRATO PELA TRIGGER...');
            
            // Recupera todas as informacoes de propostas necessarias para a geracao de contratos
            List<Quote> listProposta = QuoteDAO.getInstance().buscarPropostasPorId(quotesIds);
            // Processar as propostas para contrato, gerando contrato com status em elaboracao
            List<Contract> listContratosEmElaboracao = new QuoteBO().processarPropostaParaContrato(listProposta);//PLV-4539
            
            // PLV-2372 INICIO
            // Envia dados para sistemas externos
            if(!listContratosEmElaboracao.isEmpty()){
                //PLV-3459 - INICIO - Alterar o processo de Emissão
                //PLV-4398 - Viagem - INICIO - Correção Múltiplos passageiros
                system.debug('Flag atualizarOrcamento - Antes de chamar a QueueableContract: ' + atualizarOrcamento);
                System.enqueueJob(new QueueableContractDetails(listContratosEmElaboracao, 0, atualizarOrcamento));
                //PLV-4398 - Viagem - FIM - Correção Múltiplos passageiros
                //PLV-3459 - FIM - Alterar o processo de Emissão
            }            
            // PLV-2372 FIM
        }
        //FIM -PLV-2287-28
    }
    // PLV-2312-28 FIM
    
    // PLV-2312-28 INICIO
    public List<Contract> processarPropostaParaContrato(List<Quote> listProposta){
        
        System.debug('INICIO DO PROCESSAMENTO DE PROPOSTA PARA CONTRATO');
        // Instancias
        //====> Listas
        List<Contract> listContrato = new List<Contract>();
        List<Contract> listContratoApagar = new List<Contract>();
        //RVI-79 - INICIO
        List<ParametroVigencia__c> listParametrosVigencia = [SELECT Id, Produto__c, ProdutoRenovavel__c, VigenciaMinimaRenovacao__c FROM ParametroVigencia__c];
        Map<String, ParametroVigencia__c> mapParametroVigenciaProduto = new  Map<String, ParametroVigencia__c>();

        for(ParametroVigencia__c parametroVigencia : listParametrosVigencia){
            mapParametroVigenciaProduto.put(parametroVigencia.Produto__c, parametroVigencia);
        }
        //RVI-79 - FIM
        //====> Mapas
        Map<String,ServiceTO.ContratoTO> mapContratoTOPorNumeroProposta = new Map<String, ServiceTO.ContratoTO>();
        
        // Verifica se existe um contrato anterior em elaboracao para apagar e recuperar as informacoes
        mapContratoTOPorNumeroProposta = verificarContratoAnteriorPendente(listProposta, mapContratoTOPorNumeroProposta, listContratoApagar);
        
        // Apaga os contratos processados anteriormente com erro
        System.debug('QUANTIDADE DE CONTRATOS PRCESSADOS ANTERIORMENTE COM ERRO PARA APAGAR ' + listContratoApagar.size());
        delete listContratoApagar;
        
        for(Quote proposta : listProposta){
            
            System.debug('NUMERO DE PROPOSTA' + proposta.NumeroProposta__c);
            
            // Recupera o numero de apolice se houver
            ServiceTO.ContratoTO contratoTO = mapContratoTOPorNumeroProposta.get(proposta.NumeroProposta__c);
            
            try {
                // Criação do contrato e sua hirarquia completa
                Contract contrato = gerarHierarquiaCompletaContrato(proposta, contratoTO, mapParametroVigenciaProduto);
             
                listContrato.add(contrato);
            } catch (Exception e) {
                // Loga no Heroku o erro via evento de plataforma
                String descricaoErro = 'Erro ao processar proposta para contrato. Mensagem do erro: ' + e.getMessage() + ' linha: ' + e.getLineNumber();
                System.debug(descricaoErro);
                
                ServiceTO.ParamGerarErroHerokuTO logHerokuTO = new ServiceTO.ParamGerarErroHerokuTO();
                logHerokuTO.objeto            = 'Proposta';
                logHerokuTO.idregistro        = String.valueOf(proposta.Id) + '|' + proposta.Name;
                logHerokuTO.codigointegracao  = 'ProcessarPropostaParaContrato';
                logHerokuTO.descricaoerro     = descricaoErro;
                logHerokuTO.status            = 'ERRO';
                enviarHerokuLog(logHerokuTO);
                
                // Nao lancar excecao para nao dar rollback na proposta
                //                throw new QuoteException(descricaoErro);
            }
        }
        
        System.debug('TERMINOU A GERACAO DO CONTRATO');
        return listContrato;
    }
    // PLV-2312-28 FIM
    
    
    // PLV-2804 INICIO
    @TestVisible //VE-45
    public void chamarCIVEmissao(Set<Id> setContratoId, Map<String, String> mapPropostaApolice) { //PLV-3460 - INICIO/FIM
        
        try {
            Debug.getInstance().start(); // LECVP-69 - Inicio/Fim
            ResultadoIntegracaoTO resultadoIntegracaoTO = new ResultadoIntegracaoTO();
            resultadoIntegracaoTO.tipoobjeto = 'SF:FluxoSeguro';
            resultadoIntegracaoTO.idintegracao = 88;
            resultadoIntegracaoTO.reprocessamento = 0;
            resultadoIntegracaoTO.dataintegracao = String.valueOf(System.today());
            resultadoIntegracaoTO.endpoint = '/api/seguro/fluxo-seguro';
            resultadoIntegracaoTO.metodo = 'POST';

            List<BCP_Log__c> logs = new List<BCP_Log__c>();//LECVP-72 - INICIO / FIM
            
            // Busca os contratos ate os orcamentos para integrar com o CIV
            for (Contract contrato : ContractDAO.getInstance().buscarContratos(setContratoId)) {
                
                // Instancias
                ServiceTO.ContratoTO contratoTO;
                Quote proposta = contrato.Proposta__r;
                BCP_Log__c log = new BCP_Log__c(); //LECVP-72 - INICIO / FIM
                // Criar json com dados da proposta para envio para o CIV
                ContratoTO.PayloadTO payloadContratoCIV = ContractFacade.getInstance().mapeiaPayloadContrato(proposta, mapPropostaApolice);
                // Complementa o resultado de integracao com informacoes desse envio
                resultadoIntegracaoTO.payloadentrada = JSON.serialize(payloadContratoCIV);
                Debug.getInstance().log(new Map<Object, Object> { // LECVP-69 - Inicio
                    'Contrato' => contrato,
                    'Proposta' => proposta,
                    'Payload contrato CIV' => payloadContratoCIV,
                    'ResultadoIntegracaoTO' => resultadoIntegracaoTO
                }); // LECVP-69 - Fim
                
                // Envio da proposta para CIV
                try{
                    //LECVP-72 - INICIO
                    log.BCP_Contrato__c = contrato.Id;
                    log.BCP_DataHoraEnvio__c = Util.montarDataHoraComGMT(Datetime.now());
                    //LECVP-72 - FIM
                    
                    //PLV-3393 - INICIO - Integração BCP
                    SensediaServices.getInstance().emitirContrato(payloadContratoCIV); //MGRC-1653 - INICIO/FIM
                    //[PLV-3393] O CIV não retorna mais o contrato com o número da Apólice, por isso o método emitirContrato
                    //teve sua assinatura alterada para VOID e a atribuição de retorno abaixo foi comentada.
                    //contratoTO = CIVServices.getInstance().emitirContrato(payloadContratoCIV);
                    //System.debug('RESPOSTA DO CIV' + json.serialize(contratoTO, true));
                    //PLV-3393 - FIM
                    
                    // gerar resultado integração de sucesso
                    resultadoIntegracaoTO.status = 'Sucesso';
                    resultadoIntegracaoTO.devolutiva = '200';

                    System.debug('resultadoIntegracaoTO: ' + resultadoIntegracaoTO);
                    
                    HerokuService.getInstance().gerarResultadoIntegracao(resultadoIntegracaoTO);
                    //LECVP-72 - INICIO
                    log.BCP_Descricao__c = 'Envio para BCP efetuado com sucesso';
                    log.BCP_Status__c = 'SF - Enviado para BCP';
                    //LECVP-72 - FIM
                }catch (Exception e){
                    // gerar resultado integração de erro
                    resultadoIntegracaoTO.status = 'Erro';
                    resultadoIntegracaoTO.devolutiva = e.getMessage();

                    System.debug('resultadoIntegracaoTO: ' + resultadoIntegracaoTO);
                    
                    HerokuService.getInstance().gerarResultadoIntegracao(resultadoIntegracaoTO);
                    //LECVP-72 - INICIO                  
                    log.BCP_DataHoraEnvio__c = Util.montarDataHoraComGMT(Datetime.now());
                    log.BCP_Descricao__c = 'Código BCP inválido nas alterações';
                    log.BCP_Status__c = 'SF - Erro interno BCP';                   
                    //LECVP-72 - FIM
                }
                logs.add(log); //LECVP-72 - INICIO / FIM
                //PLV-3393 - INICIO
                // Verifica se o CIV retornou o esperado e gera log em caso de erro
                //if (String.isBlank(contratoTO.contrato.numeroApolice) || Long.valueOf(contratoTO.contrato.numeroApolice) <= 0) {
                // System.debug('ERRO:  CIV não retornou os dados corretamente.');
                
                //throw new QuoteException('CIV não retornou o número de apólice');
                // }
                //PLV-3393 - FIM
            }
            insert logs; //LECVP-72 - INICIO / FIM
        }catch (Exception e){
            Debug.getInstance().log(e); // LECVP-69 - Inicio/Fim
            // Loga no Heroku o erro via evento de plataforma
            String descricaoErro = 'Erro ao chamar o CIV. Mensagem do erro: ' + e.getMessage() + ' linha: ' + e.getLineNumber();
            
            ServiceTO.ParamGerarErroHerokuTO logHerokuTO = new ServiceTO.ParamGerarErroHerokuTO();
            logHerokuTO.codigointegracao  = 'chamarCIVEmissao';
            logHerokuTO.descricaoerro     = descricaoErro;
            logHerokuTO.status            = 'ERRO';
            new QuoteBO().enviarHerokuLog(logHerokuTO);//PLV-4539
            
        }
        Debug.getInstance().end(); // LECVP-69 - Inicio/Fim
    }
    // PLV-2804 FIM
    // PLV-2312-28 FIM

    //LECVP-72 - INICIO
    public void chamarCIVReenvio(Set<Id> setContratoId, Map<String, String> mapPropostaApolice) {
        
        try {
            List<BCP_Log__c> logs = new List<BCP_Log__c>();
            // Busca os contratos ate os orcamentos para integrar com o CIV
            for (Contract contrato : ContractDAO.getInstance().buscarContratos(setContratoId)) {
                
                // Instancias
                ServiceTO.ContratoTO contratoTO;
                Quote proposta = contrato.Proposta__r;
                BCP_Log__c log = new BCP_Log__c();
                String mensagemErro = '';

                // Criar json com dados da proposta para envio para o CIV
                ReenvioContratoTO.PayloadTO reenvioContratoCIV = ContractFacadeReenvio.getInstance().mapeiaReenvioPayload(proposta, mapPropostaApolice);
                 
                try{
                    log.BCP_Contrato__c = contrato.Id;
                    log.BCP_DataHoraEnvio__c = Util.montarDataHoraComGMT(Datetime.now());
                    
                    //Reenvio de contrato para API exclusiva da BCP via CIV
                    BCPContratoTcktTO bCPContratoTcktTO = CIVServices.getInstance().reemitirContrato(reenvioContratoCIV);
                 
                    if(bCPContratoTcktTO.respostaBCP == null){
                        mensagemErro = bCPContratoTcktTO.mensagem;
                        throw new QuoteException('Sem retorno da BCP via CIV');
                    }
                        log.BCP_DataHoraRetorno__c = Util.montarDataHoraComGMT(Datetime.now());
                        log.BCP_Descricao__c = bCPContratoTcktTO.mensagem;
                        log.BCP_Status__c = 'SF - Enviado para BCP - Reemissão';

                }catch (Exception e){

                        log.BCP_DataHoraRetorno__c = Util.montarDataHoraComGMT(Datetime.now());
                        log.BCP_Descricao__c = mensagemErro;
                        log.BCP_Status__c = 'SF - Erro interno BCP - Reemissão';
                }
                logs.add(log);
            }
            insert logs;
        
        }catch(Exception e){
            System.debug('Erro ao chamar o CIV. \nMensagem do erro: ' + e.getMessage() + ' linha: ' + e.getLineNumber());
        }
    }
    //LECVP-72 - FIM

    // PLV-2312-28 INICIO
    private Map<String, ServiceTO.ContratoTO> verificarContratoAnteriorPendente(List<Quote> listProposta, Map<String, ServiceTO.ContratoTO> mapContratoTOPorNumeroProposta, List<Contract> listContratoApagar) {
        for (Quote proposta : listProposta) {
            
            // Verifica se já foi gerado um contrato anteriormente
            if(proposta.Contratos__r != null && !proposta.Contratos__r.isEmpty() && proposta.Contratos__r[0].Status != 'Emitido' && proposta.Contratos__r[0].Status != 'Cancelado'){
                Contract contrato = proposta.Contratos__r[0];
                
                // PLV-2605 INICIO
                // Verifica se ja gerou o numero de apolice para recuperar
                if(!String.isBlank(contrato.NumeroApolice__c)){
                    // PLV-2605 FIM
                    ServiceTO.ContratoTO contratoTO = new ServiceTO.ContratoTO();
                    contratoTO.contrato = new ServiceTO.ContratoDetalheTO();
                    contratoTO.contrato.codigoEmpresa = Integer.valueOf(contrato.Empresa__c);
                    contratoTO.contrato.codigoSucursal = Integer.valueOf(contrato.Sucursal__c);
                    contratoTO.contrato.numeroApolice = contrato.NumeroApolice__c;
                    contratoTO.contrato.numeroEndosso = Integer.valueOf(contrato.Endosso__c);
                    mapContratoTOPorNumeroProposta.put(proposta.NumeroProposta__c, contratoTO);
                }
                listContratoApagar.add(contrato);
            }
        }
        return mapContratoTOPorNumeroProposta;
    }
    // PLV-2312-28 FIM
    
    //PLV-2605-29 INICIO
    //PLV-4398 - Viagem - INICIO - Correção Múltiplos passageiros
    public void atualizarSistemaExterno(List<Contract> listContratoTemp){
        atualizarSistemaExterno(listContratoTemp, true);
    }
    public void atualizarSistemaExterno(List<Contract> listContratoTemp, Boolean atualizarOrcamento){
    //PLV-4398 - Viagem - FIM - Correção Múltiplos passageiros
        
        // Instancias
        Set<Id> setContratoId = new Set<Id>();
        List<Contract> listContrato = new List<Contract>();
        List<ServiceTO.SeguroContratoTO> seguros = new List<ServiceTO.SeguroContratoTO>();
        //PLV-4344-Fix - Inicio
        List<RemuneracaoContrato__c> lstRemuneracoesContrato = new List<RemuneracaoContrato__c>();
        Map<Id, Boolean> mapAntecipaComissaoContrato = new Map<Id, Boolean>();
        //PLV-4344-Fix - Fim

        try {
            
            if (listContratoTemp == null || listContratoTemp.isEmpty()) {
                System.debug('Não há contratos para atualizar os sistemas externos');
                return ;
            }
            
            for (Contract contrato : listContratoTemp) {
                setContratoId.add(contrato.Id);
            }
            
            // Busca os contratos ate os orcamentos
           
            //PLV-4344-Fix - Inicio
            listContrato = ContractDAO.getInstance().buscarContratos(setContratoId);
            lstRemuneracoesContrato = ContractDAO.getInstance().buscarRemuneracaoContratoPorId(setContratoId);
            for(RemuneracaoContrato__c rem : lstRemuneracoesContrato) {
                if(!mapAntecipaComissaoContrato.containsKey(rem.Contrato__c)){
                    if(rem.TipoRemuneracao__r.Codigo__c.toUpperCase() == 'AGE' && rem.Percentual__c > 0){
                        mapAntecipaComissaoContrato.put(rem.Contrato__c, false);
                        continue;
                    }
                    else if(rem.TipoRemuneracao__r.Codigo__c.toUpperCase() == 'COR'){
                        if(rem.FavorecidosContrato__r != null && !rem.FavorecidosContrato__r.isEmpty()){
                            mapAntecipaComissaoContrato.put(rem.Contrato__c, rem.FavorecidosContrato__r[0].AntecipacaoComissao__c);
                        }
                    }
                }
            }
            
            //PLV-4438 - Inicio - Calculo de vencimento da primeira parcela
            List<BusinessHours> lstHorariosComerciais = [SELECT Id, Name, IsActive, IsDefault, MondayStartTime, MondayEndTime FROM BusinessHours WHERE Name = 'Bancário'];
            
            //PLV-4438-Fix2 - Inicio
            Date vencPrimeiraParcela; //PLV-4438-Fix - Inicio/Fim
            Integer qtdDiasADC = 11; //INICIO/FIM - PLV-4696 - Guilherme Brito
            Integer qtdDiasBoleto = 11; //INICIO/FIM - PLV-4696 - Guilherme Brito

            Set<String> setCodADC = new Set<String>{'51','52','53'};
            Set<String> setCodBoleto = new Set<String>{'11','21','25','41','71','81','82'};
            List<ContratanteContrato__c> listContratantes = new  List<ContratanteContrato__c>();
            
            Map<String, ContratanteProposta__c> mapPropostaContaContratante = new Map<String, ContratanteProposta__c>();
            Set<String> setIdPropostas = new Set<String>();
            Integer diasEntre;

            for(Contract contrato  :listContrato) {
                setIdPropostas.add(contrato.Proposta__c);
            }
            List<ContratanteProposta__c> listContratanteProposta = new List<ContratanteProposta__c>([SELECT Id, Proposta__c, Conta__c, VencimentoPrimeiraParcela__c FROM ContratanteProposta__c WHERE Proposta__c IN :setIdPropostas]);
            for(ContratanteProposta__c cP :listContratanteProposta){
                if(cP.Proposta__c != null && cP.Conta__c != null) mapPropostaContaContratante.put(cP.Proposta__c + '|' + cP.Conta__c,cP);
            }
            listContratanteProposta.clear();

            for(Contract contrato  :listContrato) {
                for(ContratanteContrato__c contratante :contrato.ContratantesContrato__r) {
                    vencPrimeiraParcela = System.today(); //PLV-4438-Fix - Inicio/Fim 
                     
                    //INICIO - PLV-4696 - Guilherme Brito
                    if(contratante.FormaPagamento__r.Codigo__c != null) {
                        if(setCodADC.contains(contratante.FormaPagamento__r.Codigo__c)) { //ADC - D + 11 dias corridos
                            //vencPrimeiraParcela = !lstHorariosComerciais.isEmpty() && lstHorariosComerciais[0].isActive ? Util.calculaDataFinalPorDiasUteis(lstHorariosComerciais[0], vencPrimeiraParcela, qtdDiasADC) :
                            vencPrimeiraParcela = vencPrimeiraParcela.addDays(qtdDiasADC);

                        } else if(setCodBoleto.contains(contratante.FormaPagamento__r.Codigo__c)) {  //Boleto - D + 11 dias corridos
                            vencPrimeiraParcela = vencPrimeiraParcela.addDays(qtdDiasBoleto);
                            
                        } else { //Considerado que eh cartao
                            vencPrimeiraParcela = vencPrimeiraParcela.addMonths(1); //Antiga definicao do portal //PLV-5832 INICIO/FIM
                        }
                    }
                    //FIM - PLV-4696 - Guilherme Brito

                    contratante.VencimentoPrimeiraParcela__c = vencPrimeiraParcela;
                    listContratantes.add(contratante);

                    if(contrato.Proposta__c != null && contratante.Conta__c != null){
                        if(mapPropostaContaContratante.containsKey(contrato.Proposta__c + '|' + contratante.Conta__c)){
                            ContratanteProposta__c cP = mapPropostaContaContratante.get(contrato.Proposta__c + '|' + contratante.Conta__c);
                            cp.VencimentoPrimeiraParcela__c = vencPrimeiraParcela;
                            listContratanteProposta.add(cp);
                        }
                    }
                }
            }
            //PLV-4438-Fix2 - Fim

            // gera TO de seguro e parcela
            seguros = ContractBO.getInstance().gerarDadosSeguro(setContratoId, listContrato, mapAntecipaComissaoContrato, lstHorariosComerciais);
            //PLV-4438 - Fim - Calculo de vencimento da primeira parcela
            //PLV-4344-Fix - Fim
            
            System.debug('Danilo QuoteBO seguros: '+ seguros);

            //PLV-5710 INICIO
            List<String> listParcelasSeguros = new List<String>();
            for(ServiceTO.SeguroContratoTO seguro : seguros){
                // MGRC-505-FIX2 INICIO
                if (seguro.parcelas!=null && seguro.parcelas.size()>0) {  
                    listParcelasSeguros.add(JSON.serialize(seguro.parcelas));
                } 
                 // MGRC-505-FIX2 FIM
            }
            //PLV-5710 FIM

            System.debug('seguros TEST HEROKU');
            System.debug(JSON.serialize(seguros));
            
            // chama o heroku para gerar numero de apolice, seguro e parcela
            
            Map<String, String> mapPropostaApolice = HerokuService.getInstance().atualizarFluxoSeguro(seguros);
            
            // PLV-2804 INICIO
            // Codigo removido por conta da historia PLV-3460
            //PLV-4438 - Inicio
            //PLV-4398 - Viagem - INICIO - Correção Múltiplos passageiros
            
            listContrato = alterarStatusOrcamentoPropostaContrato(listContrato, listContratantes, listContratanteProposta, mapPropostaApolice, atualizarOrcamento); //PLV-4438-Fix2 - Inicio/Fim
            //PLV-4398 - Viagem - FIM - Correção Múltiplos passageiros
            //PLV-4438 - Fim
            // PLV-2804 FIM
            // PLV-4720 FIX 3 INICIO 
            // PLV-4921 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
            //PLV-5710 INICIO 
            //for(ServiceTO.SeguroContratoTO seguro : seguros){
                //system.debug('HENRIQUE RODRIGUES ENTROU NO FOR SEGURO');
                // PLV-4606-FIX-3 INICIO
            if(listParcelasSeguros != null && listParcelasSeguros.size() > 0 && listContrato[0].CodigoRamo__c != '1377' && listContrato[0].CodigoRamo__c != '1369'){
                system.debug('HENRIQUE RODRIGUES ENTROU NO IF');
                System.debug('gerarComposicaoParcela >>>> '+ listContrato);
                System.debug('gerarComposicaoParcela >>>> '+ listParcelasSeguros);
                System.debug('JSON.serialize(listContrato) >>>> '+ JSON.serialize(listContrato));
                //ContractBO.gerarComposicaoParcela(JSON.serialize(listContrato), JSON.serialize(seguro.parcelas));
                ContractBO.gerarComposicaoParcela(JSON.serialize(listContrato), listParcelasSeguros); //PLV-5710 INICIO/FIM
            }
                // PLV-4606-FIX-3 FIM
            //}
            //PLV-5710 FIM 
            // PLV-4921 - FIM - PEDRO AUGUSTO BRAZ - SYS4B
            // PLV-4720 FIX 3 FIM
            System.debug('mapPropostaApolice ' + mapPropostaApolice);
        }catch(Exception e){
            
            // Instancias
            List<Contract> listContratoComNumeroApolice = new List<Contract>();
            
            for(Contract contrato : listContrato){
                if (!String.isBlank(contrato.NumeroApolice__c) && (contrato.Tipo__c == 'Novo' || contrato.Tipo__c == 'Renovacao')){//RVI-138 - INICIO/FIM
                    listContratoComNumeroApolice.add(contrato);
                }
            }
            update listContratoComNumeroApolice;
            
            // Loga no Heroku o erro via evento de plataforma
            String descricaoErro = 'Erro ao atualizar os sistemas externos. Mensagem do erro: ' + e.getMessage() + ' linha: ' + e.getLineNumber();
            
            ServiceTO.ParamGerarErroHerokuTO logHerokuTO = new ServiceTO.ParamGerarErroHerokuTO();
            logHerokuTO.codigointegracao  = 'AtualizarSistemasExternos';
            logHerokuTO.descricaoerro     = descricaoErro;
            logHerokuTO.status            = 'ERRO';
            enviarHerokuLog(logHerokuTO);
            
            //throw new QuoteException(descricaoErro);
        }
        
    }
    //PLV-2605-29 FIM
    
    // PLV-2312 INICIO
    public void logarHeroku(List<HerokuLogs__e> listHerokuLogs){
        for(HerokuLogs__e herokuLogs : listHerokuLogs){
            System.debug('LOGANDO NO HEROKU...');
            QuoteBO.criarLogErroFuture(herokuLogs.Objeto__c, herokuLogs.IdRegistro__c, herokuLogs.CodigoIntegracao__c, herokuLogs.CodigoErro__c, herokuLogs.Descricao__c, herokuLogs.Status__c);
        }
    }
    // PLV-2312 FIM
    
    // PLV-2312-28 INICIO
    @future(callout=true)
    private static void criarLogErroFuture(String objeto, String idregistro, String codigointegracao, String codigoerro, String descricaoerro, String status)
    {
        ServiceTO.ParamGerarErroHerokuTO parametro = new ServiceTO.ParamGerarErroHerokuTO();
        
        parametro.data              = String.valueOf(datetime.now());
        parametro.objeto            = objeto;
        parametro.idregistro        = idregistro;
        parametro.codigointegracao  = codigointegracao;
        parametro.codigoerro        = codigoerro;
        parametro.descricaoerro     = descricaoerro;
        parametro.status            = status;
        
        if(!Test.isRunningTest()){
            HerokuService.getInstance().gerarLogErro(parametro);
        }
    }
    // PLV-2312-28 FIM
    
    // PLV-2312-28 INICIO
    public void enviarHerokuLog(ServiceTO.ParamGerarErroHerokuTO logHerokuTO){
        
        System.debug('Logando erro no Heroku');
        
        // Instancia
        HerokuLogs__e herokuLogs = new HerokuLogs__e(
            Descricao__c = logHerokuTO.descricaoerro,
            Data__c = Datetime.now(),
            Objeto__c = logHerokuTO.objeto,
            IdRegistro__c = logHerokuTO.idregistro,
            CodigoIntegracao__c = logHerokuTO.codigointegracao,
            CodigoErro__c = logHerokuTO.codigoerro,
            Status__c = logHerokuTO.status
        );
        
        Database.SaveResult sr = EventBus.publish(herokuLogs);
        
        if (sr.isSuccess()){
            System.debug('Evento de log publicado com sucesso!');
            
            // Id da operacao.
            System.debug('ID da operacao de evento de plataforma ' + EventBus.getOperationId(sr));
            
            // The getOperationID call above is equivalent to the err.getMessage() call
            for(Database.Error err : sr.getErrors()) {
                System.debug('Erro retornado: ' +
                             err.getStatusCode() +
                             ' - ' +
                             err.getMessage());
            }
        } else {
            for(Database.Error err : sr.getErrors()) {
                System.debug('Erro retornado: ' +
                             err.getStatusCode() +
                             ' - ' +
                             err.getMessage());
            }
        }
    }
    // PLV-2312-28 FIM
    
    // private static QuoteTO LoadQuote(Quote objQuote)
    // {
    //     //--- Define parts of json
    //     QuoteTO tempData = new QuoteTO();
    //     tempData.contrato = new QuoteTO.PropostaTO();
    //     tempData.contrato.arquivos = new List<QuoteTO.ArquivoTO>();
    //     tempData.contrato.remuneracao = new QuoteTO.RemuneracaoTO();
    //     tempData.contrato.remuneracao.agentes = new List<QuoteTO.AgenteTO>();
    //     tempData.contrato.evento = new QuoteTO.EventoTO();
    //     tempData.contrato.viagem = new QuoteTO.ViagemTO();
    //     tempData.contrato.transferenciaCongenere = new QuoteTO.TransferenciaCongenereTO();
    //     tempData.contrato.dadosDevolucao = new QuoteTO.DadosDevolucaoTO();
    //     tempData.contrato.contratantes = new List<QuoteTO.ContratanteTO>();
    
    //     //--- load quote datos
    //     if(objQuote.Produto__r.Empresa__r.CodigoEmpresa__c != null)
    //         tempData.contrato.codigoEmpresa = Integer.valueOf(objQuote.Produto__r.Empresa__r.CodigoEmpresa__c);
    //     else
    //         tempData.contrato.codigoEmpresa = 0;
    
    //     if(objQuote.CodigoCorretor__r.CodigoSusepCia__c != null)
    //         tempData.contrato.codigoSucursal = objQuote.CodigoCorretor__r.CodigoSusepCia__c;
    //     else
    //         tempData.contrato.codigoSucursal = '';
    
    //     /*
    //             if(objQuote.RamoSeguro__r.Codigo__c != null)
    //                 tempData.contrato.ramoSeguro = Integer.valueOf(objQuote.RamoSeguro__r.Codigo__c);
    //             else
    //                 tempData.contrato.ramoSeguro = 0;
    //     */
    
    //     String ramoSeguro = BuscarRamoSeguro(objQuote.Produto__c);
    
    //     if(ramoSeguro != null)
    //         tempData.contrato.ramoSeguro = Integer.valueOf(ramoSeguro);
    //     else
    //         tempData.contrato.ramoSeguro = 0;
    
    
    //     if(objQuote.Origem__c != null)
    //         tempData.contrato.origem = Integer.valueOf(objQuote.Origem__c);
    //     else
    //         tempData.contrato.origem = 0;
    
    //     if(objQuote.Name != null)
    //         tempData.contrato.numero = Decimal.valueOf(objQuote.Name);
    //     else
    //         tempData.contrato.numero = 0;
    
    //     tempData.contrato.segmento            = buscaSegmento(objQuote.RecordType.DeveloperName);
    //     tempData.contrato.meioComercializacao = (objQuote.MeioComercializacao__c == null ? '' : objQuote.MeioComercializacao__c);
    //     tempData.contrato.nomeEmpresa         = (objQuote.Empresa__r.Name == null ? '' : objQuote.Empresa__r.Name);
    //     // if(objQuote.Opportunity.Numero__c != null)
    //     //     tempData.contrato.numeroOrcamento     = Integer.valueOf(objQuote.Opportunity.Numero__c);
    //     // else
    //     //     tempData.contrato.numeroOrcamento = 0;
    
    //     // if(objQuote.Opportunity.NumeroPortal__c != null)
    //     //     tempData.contrato.numeroPortal = Integer.valueOf(objQuote.Opportunity.NumeroPortal__c);
    //     // else
    //     //     tempData.contrato.numeroPortal = 0;
    
    //     if(objQuote.Modalidade__r.Codigo__c != null)
    //         tempData.contrato.modalidade = Integer.valueOf(objQuote.Modalidade__r.Codigo__c);
    //     else
    //         tempData.contrato.modalidade = 0;
    
    
    //     tempData.contrato.descricaoModalidade = (objQuote.Modalidade__r.Descricao__c == null ? '' : objQuote.Modalidade__r.Descricao__c);
    //     tempData.contrato.dataCalculo         = objQuote.DataCalculo__c;
    //     tempData.contrato.dataCriacaoPortal   = objQuote.DataCriacaoPortal__c;
    
    //     if(objQuote.Produto__r.ProductCode != null)
    //         tempData.contrato.codigoProdutoVida = Integer.valueOf(objQuote.Produto__r.ProductCode);
    //     else
    //         tempData.contrato.codigoProdutoVida = 0;
    
    //     tempData.contrato.descricaoProduto  = (objQuote.Produto__r.Description == null ? '' : objQuote.Produto__r.Description);
    //     tempData.contrato.tipoVigencia      = (objQuote.TipoVigencia__c == null ? '' : objQuote.TipoVigencia__c);
    //     tempData.contrato.vigenciaInicial   = objQuote.VigenciaInicial__c;
    //     tempData.contrato.vigenciaFinal     = objQuote.VigenciaFinal__c;
    //     tempData.contrato.tipoSeguro        = (objQuote.Tipo__c == null ? '' : objQuote.Tipo__c);
    //     tempData.contrato.valorPremio       = (objQuote.ValorPremio__c == null ? 0 : objQuote.ValorPremio__c);
    //     tempData.contrato.status            = (objQuote.Status == null ? '' : objQuote.Status);
    
    //     tempData.contrato.numeroEndosso     = 0;
    
    
    //     //      tempData.contrato.numeroEndosso
    //     //      tempData.contrato.origemRequisicao
    //     //      tempData.contrato.descricaoRamo
    //     //      tempData.contrato.setorOrigem
    //     //      tempData.contrato.dataEmissao
    //     //      tempData.contrato.descricaoStatus   = objQuote.
    //     //      tempData.contrato.mensagemStatus    = objQuote.
    //     //      tempData.contrato.observacoesGerais
    //     //      tempData.contrato.flagReentrada
    //     //      tempData.contrato.idProtocolo
    
    //     //--- load remuneracao
    //     tempData.contrato.remuneracao.canal = objQuote.Opportunity.CanalDistribuicao__c;
    
    //     //--- load eventos
    //     tempData.contrato.evento.tipoEvento             = objQuote.TipoEvento__c;
    //     tempData.contrato.evento.informacoesEvento      = objQuote.InformacoesEvento__c;
    //     tempData.contrato.evento.qstControlePublico     = (objQuote.Opportunity.HaControlePublico__c ? 'SIM' : 'NAO');
    //     tempData.contrato.evento.qstLocalEvento         = (objQuote.Opportunity.EventoLocalFechadoDelimitado__c == true ? 'SIM' : 'NAO');
    
    
    //     //*** Viagem
    //     tempData.contrato.viagem.tipoViagem             = objQuote.TipoViagem__c;
    //     tempData.contrato.viagem.praticaEsportesAventura= (objQuote.Opportunity.ViagemAventura__c ? 'SIM': 'NAO');
    //     tempData.contrato.viagem.utilizaraMotocicleta   = (objQuote.Opportunity.UtilizaMoto__c ? 'SIM' : 'NAO');
    //     tempData.contrato.viagem.incluiPaisSchengen     = (objQuote.Opportunity.IncluiPaisEuropeu__c ? 'SIM' : 'NAO');
    //     tempData.contrato.viagem.trackageBagagem        = (objQuote.Opportunity.PossuiTrackageBagagem__c ? 'SIM' : 'NAO');
    //     tempData.contrato.viagem.passageirosNaoIdosos   = (Integer)objQuote.Opportunity.QuantidadePassageirosNaoIdosos__c;
    //     tempData.contrato.viagem.passageirosIdosos      = (Integer)objQuote.Opportunity.QuantidadePassageirosIdosos__c;
    
    //     if(Opportunity.PaisesDestino__c != null)
    //     {
    //         List<String> paises = objQuote.Opportunity.PaisesDestino__c.split(';');
    //         List<QuoteTO.DestinoTO> lstDestino = new List<QuoteTO.DestinoTO>();
    //         for(String pais : paises)
    //         {
    //             QuoteTO.DestinoTO objDestino = new QuoteTO.DestinoTO();
    //             objDestino.pais = pais;
    //             lstDestino.add(objDestino);
    //         }
    //         tempData.contrato.viagem.destinos = lstDestino;
    //     }
    
    
    //     /*--- PROVISORIO
    //     tempData.contrato.ramoSeguro = 1391;
    //     tempData.contrato.numeroEndosso  = 0;
    //     tempData.contrato.codigoSucursal = 1;
    //     tempData.contrato.codigoEmpresa = 1;
    //     */
    
    
    //     return tempData;
    // }
    
    public static String buscaSegmento(String strDescricao)
    {
        String strRetorno;
        
        if(strDescricao == 'VidaGrupo')
            strRetorno = 'VG';
        else if (strDescricao == 'VidaIndividual')
            strRetorno = 'VI';
        
        return strRetorno;
    }
    
    public class ParcelasException extends Exception {}
    
    // Gera o campo name da proposta
    public String gerarNameProposta(String origem, String numeroProposta){
        return origem + '-' + numeroProposta.leftPad(8,'0');
    }
    
    public class NewException extends Exception {} //PLV-5776 - INICIO/FIM
    
    // PLV-2804 INICIO
    // PLV-4438 - Inicio
    // PLV-4438-Fix2 - Inicio
    //PLV-4398 - Viagem - INICIO - Correção Múltiplos passageiros
    public static List<Contract> alterarStatusOrcamentoPropostaContrato(List<Contract> listContrato, List<ContratanteContrato__c> listContratantesContrato, List<ContratanteProposta__c> listContratantesProposta, Map<String,String> mapNumeroApolicePorProposta, Boolean atualizarOrcamento){
    System.debug('CONTRATO RENOVA--------- ENTROU alterarStatusOrcamentoPropostaContrato');
    //PLV-4398 - Viagem - FIM - Correção Múltiplos passageiros
    // PLV-4438-Fix2 - Fim
    // PLV-4438 - Fim
    // PLV-2804 FIM
    
        //PLV-4398 INICIO FIX 1
        if (atualizarOrcamento == null) {
            atualizarOrcamento = true;
        }
        //PLV-4398 FIM FIX 1
        
        // Instancias
        //PLV-4398 - Viagem - INICIO - Correção Emissão
        List<Quote> listProposta = new List<Quote>();
        List<Contract> listContratoOriginais = new List<Contract>();
        Set<Id> setOrcamento = new Set<Id>(); //PLV-3896 - INICIO/FIM - Criação da variavel para não repetir o orcamento e remoção de variavel

        for (Contract contrato : listContrato) {
            if (contrato.Proposta__r.Opportunity != null) {
                setOrcamento.add(contrato.Proposta__r.OpportunityId);
            }
        }
        
        Map<Id, Opportunity> orcamentosMap = new Map<Id, Opportunity>();
        Map<Id, Opportunity> orcamentosMapToUpdate = new Map<Id, Opportunity>();
        
        if (setOrcamento.size() > 0) {
            orcamentosMap = new Map<Id, Opportunity>([
                SELECT Id
                    ,StageName
                FROM Opportunity
                WHERE Id IN: setOrcamento
                FOR UPDATE
            ]); 
        }
        //PLV-4398 - Viagem - FIM - Correção Emissão

        // Inicia a transacao
        Savepoint sp = Database.setSavepoint();
        
        try{
            for(Contract contrato : listContrato) {
                
                String apolice = mapNumeroApolicePorProposta.get(contrato.NumeroProposta__c);
                
                system.debug('3459 - apolice: ' + apolice);
                
                if(contrato.NumeroApolice__c == null){                    
                    String numeroApolice = apolice.leftPad(9, '0');
                    system.debug('3459 - numeroApolice: ' + numeroApolice);
                    system.debug('3459 - contrato.Empresa__c: ' + contrato.Empresa__c);
                    system.debug('3459 - contrato.Sucursal__c: ' + contrato.Sucursal__c);
                    system.debug('3459 - contrato.RamoSeguro__r.Codigo__c: ' + contrato.RamoSeguro__r.Codigo__c);
                    system.debug('3459 - numeroApolice: ' + numeroApolice);
                    system.debug('3459 - contrato.Endosso__c: ' + contrato.Endosso__c);

                    //POR010-0 - INICIO
                    List<RemuneracaoProposta__c> listRemuneracaoProposta = QuoteDAO.getInstance().buscarRemuneracaoProposta(new Set<Id>{contrato.Proposta__r.Id});
                    String codigoSucursalVinculo = buscarSucursal(listRemuneracaoProposta);
                    //POR010-0 - FIM

                    String name = ContractBO.getInstance().gerarNameContrato(contrato.Empresa__c, codigoSucursalVinculo, contrato.RamoSeguro__r.Codigo__c, numeroApolice, contrato.Endosso__c); //POR010-0 - INICIO / FIM
                    system.debug('3459 - Name: ' + name);
                    contrato.NumeroApolice__c = numeroApolice;
                    system.debug('3459 - contrato.NumeroApolice__c: ' + contrato.NumeroApolice__c);
                    contrato.Name = name;
                    system.debug('3459 - contrato.Name: ' + contrato.Name);
                    contrato.IdExterno__c = name;
                }
                
                //--- Muda status do contrato para emitido
                contrato.Status = 'Emitido';
                //PLV-2591 Inicio Adicionando a data atual
                contrato.DataEmissao__c = System.today();
                
                //--- Muda status da proposta para contratada
                Quote proposta = contrato.Proposta__r;           
                proposta.Status = 'Contratada';
                proposta.DataEmissao__c = System.today();
                //PLV-2591 Fim Adicionando a data atual
                listProposta.add(proposta);
                
                //--- Muda status do orçamento
                //PLV-4398 - Viagem - INICIO - Correção Múltiplos passageiros
                system.debug('Flag atualizarOrcamento - Antes de alterar status do Orçamento: ' + atualizarOrcamento);
                //PLV-4398 - Viagem - INICIO - Correção Emissão
                if(atualizarOrcamento && orcamentosMap.containsKey(contrato.Proposta__r.OpportunityId)){
                    Opportunity orcamento = orcamentosMap.get(contrato.Proposta__r.OpportunityId);
                    //PLV-4467 - INICIO
                    if(orcamento.StageName != 'Contratado'){
                        orcamento.StageName = 'Contratado';
                        orcamentosMapToUpdate.put(orcamento.Id, orcamento);
                    }
                    //PLV-4467 - FIM
                }
                //PLV-4398 - Viagem - FIM - Correção Emissão
                //PLV-4398 - Viagem - FIM - Correção Múltiplos passageiros
                    
                //--- Cancela o contrato original
                if(contrato.Tipo__c == 'Cancelamento'){
                    Contract contratoOriginal = contrato.Proposta__r.Contract;
                    contratoOriginal.Status = 'Cancelado';
                    listContratoOriginais.add(contratoOriginal);
                }
            }
            
            //PLV-4398 - Viagem - INICIO - Correção Múltiplos passageiros
            //List<Opportunity> listOrcamento = new List<Opportunity>(setOrcamento); //PLV-3896 - INICIO/FIM - Incluindo set em uma lista para realizar a DML 
            //PLV-4398 - Viagem - FIM - Correção Múltiplos passageiros

            //PLV-3460 Complemento - INICIO
            update listContrato;

            //PLV-5776-INICIO
            List<TotalVidasService.ContratoTO> contratos = new  List<TotalVidasService.ContratoTO>();

            Set<Id> contractsId = new Set<Id>();
            List<String> listSiglaTipoEndosso = new List<String>();
            //PLV-5776-INICIO-FIX02
            for(Contract ctr : listContrato){
                System.debug('ctr.siglaTipoEndosso: ' + ctr.SiglaTipoEndosso__c);
                if(ctr.SiglaTipoEndosso__c == null){
                    contractsId.add(ctr.Id);
                }
                else{
                    listSiglaTipoEndosso  = ctr.SiglaTipoEndosso__c.split(';');
                    System.debug('ctr: ' + ctr);
                    System.debug('listSiglaTipoEndosso: ' + listSiglaTipoEndosso);
                    System.debug('ctr tipo: ' + ctr.Tipo__c);
                    System.debug('ctr premio: ' + ctr.Proposta__r.PremioTotal__c);
                for(String sigla : listSiglaTipoEndosso){
                    if (sigla != 'BEN' && sigla !='CAD') { //PLV-5776-INICIO/FIM
                        System.debug('HENRIQUE + RAFA ENTROU NO IF DA AMIZADE');
                        contractsId.add(ctr.Id);
                    }  
                 }
                }          
            }
            //PLV-5776-FIM-FIX02

            System.debug('contractsId HENRIQUE: ' +contractsId );
            
            if(!contractsId.isEmpty()){

                Map<Id, SeguradoContrato__c> insuredMap = TotalVidasService.getInsuredMap(contractsId);
                
                Map<Id, Contract> contractMappedByInsured = new Map<Id, Contract>();
                System.debug('insuredMap: ' + insuredMap);
                for(SeguradoContrato__c sc : insuredMap.values())
                {
                    contractMappedByInsured.put(sc.Id, sc.GrupoContrato__r.ContratanteContrato__r.Contrato__r);
                }
                
                Map<Id, GarantiaContrato__c> assuranceMap = TotalVidasService.getAssuranceMap(contractMappedByInsured);  
                System.debug('assuranceMap Danilo: ' + assuranceMap);
                Map<Id, List<GarantiaContrato__c>> assuranceMappedByContract = new Map<Id, List<GarantiaContrato__c>>();
    
                for(GarantiaContrato__c gc : assuranceMap.Values())
                {
    
                    if(!assuranceMappedByContract.containsKey(gc.Contrato__c))
                    {
                        assuranceMappedByContract.put(gc.Contrato__c, new List<GarantiaContrato__c>());
                    }
    
                    assuranceMappedByContract.get(gc.Contrato__c).add(gc);
                }
                System.debug('assuranceMappedByContract Danilo: ' + assuranceMappedByContract);
                Map<Id, Map<String, List<GarantiaContrato__c>>> contractIndexedByAssurance = TotalVidasService.getGrtAndCtrByInsuredMap(
                    contractMappedByInsured, assuranceMappedByContract
                );    
                
                System.debug('contractIndexedByAssurance Danilo: ' + contractIndexedByAssurance);
                contratos = TotalVidasService.createRequest(insuredMap, contractIndexedByAssurance);

                System.debug('contratos : ' + JSON.serialize(contratos));

                if(!Test.isRunningTest()){
                    System.debug('ENTROU NO MÉTODO QUE CHAMA O HEROKU');
                    integrarTotalVidas(JSON.serialize(contratos));
                }


            }
            //PLV-5776-FIM

            //PLV-4438-Fix2 - Inicio
            if(listContratantesProposta.size() > 0) update listContratantesProposta;
            if(listContratantesContrato.size() > 0) update listContratantesContrato; //PLV-4438 - Inicio/Fim
            //PLV-4438-Fix2 - Fim
            update listProposta;
            
            //PLV-4398 - Viagem - INICIO - Correção Múltiplos passageiros
            //PLV-4398 - Viagem - INICIO - Correção Emissão
            system.debug('Flag atualizarOrcamento - Antes update Orçamento: ' + atualizarOrcamento);
            if(atualizarOrcamento && orcamentosMapToUpdate.values().size() > 0){
                update orcamentosMapToUpdate.values();
            }
            //PLV-4398 - Viagem - FIM - Correção Emissão
            //PLV-4398 - Viagem - FIM - Correção Múltiplos passageiros
           
            if(!listContratoOriginais.isEmpty()){
                update listContratoOriginais;
            }
            //PLV-3460 Complemento - FIM
            
            // PLV-3404 - INICIO 
            // caso dê erro em algum batch descomentar a segunda parte e comentar a primeira
            /*Set<Id> sContratoId = new Set<Id>();
            for (Contract con : listContrato)
            sContratoId.add(con.Id);
            if(!Test.isRunningTest()){
            ContractBO.criarApoliceAsync(sContratoId);
            }else{
            ContractBO.criarApoliceSync(sContratoId);
            }
            Set<Id> sContratoId = new Set<Id>();
            for (Contract con : listContrato)
            sContratoId.add(con.Id);
            ContractBO.criarApoliceSync(sContratoId);
            */    
            // PLV-3404 - FIM
            
            // PLV-2804 INICIO
            //copiarDeclaracaoSaude(listContrato);

            return listContrato;

            // PLV-2804 FIM
            
        }catch(Exception e){
            // Rollback na transacao
            Database.rollback(sp);
            throw new QuoteException('Erro ao atualizar o status de orcamento, proposta, contrato e/ou contrato original. Mensagem do erro: ' + e.getMessage() + ' linha: ' + e.getLineNumber());
        }
    }
    // PLV-2605-29 FIM

    //INICIO - PLV-4802 - Guilherme Brito  
    public void copiarDeclaracaoSaude(List<Contract> listContrato) {
        system.debug('Class: QuoteBO | Method: copiarDeclaracaoSaude');

        List<DeclaracaoSaude__c> dSaude = [SELECT ID, Name, Contrato__c FROM DeclaracaoSaude__c WHERE Proposta__c =: listContrato[0].Proposta__c LIMIT 1];

        if(dSaude.size() > 0) {
            dSaude[0].Contrato__c = listContrato[0].ID;
            update dSaude;
        } else {
            return;
        }
    }
    //FIM - PLV-4802 - Guilherme Brito 

    //PLV-5776 - INICIO
    @future(callout=true)
    public static void integrarTotalVidas(String body){
        System.debug('Body Total: ' + body);
        HerokuService.getInstance().gravarContratosLivesTotalPartner(body);
    }
    //PLV-5776 - FIM


    public void atualizarVigencias(List<Contract> listContrato) {
        system.debug('atualizarVigencias');

        

    }
    
    // PLV-2312-28 INICIO Refactory na emissao de contrato
    // Método de criação do contrato e toda a sua hierarquia de filhos
    private static Contract gerarHierarquiaCompletaContrato(Quote proposta, ServiceTO.ContratoTO contratoTO, Map<String, ParametroVigencia__c> mapParametroVigenciaProduto){ //RVI-79 - INICIO/FIM
        // Instancias
        //====> Mapas
        Map<Id, ContratanteContrato__c> mapContratanteContrato = new Map<Id, ContratanteContrato__c>();
        Map<Id, GrupoContrato__c> mapGrupoContrato = new Map<Id, GrupoContrato__c>();
        Map<Id, SeguradoContrato__c> mapSeguradoContrato = new Map<Id, SeguradoContrato__c>();
        //=== > Variaveis
        Contract contrato;
        
        // Inicia a transacao
        Savepoint sp = Database.setSavepoint();
        try
        {
            //====> Contrato
            contrato = gerarHierarquiaContrato(proposta, contratoTO, mapParametroVigenciaProduto);
            //====> Contratantes do contrato
            mapContratanteContrato = gerarHierarquiaContratantesContrato(proposta, contrato, mapContratanteContrato);
            //====> Grupo do contrato
            mapGrupoContrato = gerarHierarquiaGruposContrato(proposta, mapContratanteContrato, mapGrupoContrato);
            //====> Segurado do contrato
            mapSeguradoContrato = gerarHierarquiaSeguradosContrato(proposta, mapGrupoContrato, mapSeguradoContrato);
            
        }
        catch(Exception ex) {
            System.debug('Erro na geração do contrato. Iniciando rollback do contrato.');
            Database.rollback(sp);
            throw ex;
        }
        
        return contrato;
    }
    // PLV-2312-28 FIM Refactory na emissao de contrato
    
    // PLV-2312-28 INICIO Refactory na emissao de contrato
    private static List<CriticaContrato__c> gerarCriticasContrato(Quote proposta, Contract contrato,  List<CriticaContrato__c> listCriticaContrato) {
        for (CriticaProposta__c objCritica : proposta.CriticasProposta__r) {
            CriticaContrato__c criticaContrato = new CriticaContrato__c();
            
            criticaContrato.Contrato__c = contrato.Id;
            criticaContrato.Codigo__c = objCritica.Codigo__c;
            criticaContrato.DataConclusao__c = objCritica.DataConclusao__c;
            criticaContrato.Descricao__c = objCritica.Descricao__c;
            //PLV-4790 FIX 9 - INÍCIO
            //criticaContrato.MensagemCliente__c = objCritica.MensagemCliente__c; //INICIO/FIM | PLV-4647-VI-Guilherme Brito
            //criticaContrato.MensagemInterna__c = objCritica.MensagemInterna__c; //INICIO/FIM | PLV-4647-VI-Guilherme Brito
            //criticaContrato.MensagemRepresentante__c = objCritica.MensagemRepresentante__c; //INICIO/FIM | PLV-4647-VI-Guilherme Brito
            criticaContrato.Origem__c = objCritica.Origem__c;
            //criticaContrato.Procedimento__c = objCritica.Procedimento__c; //INICIO/FIM | PLV-4647-VI-Guilherme Brito 
            criticaContrato.Parecer__c = objCritica.Parecer__c;
            //PLV-4790 FIX 9 - FIM
            criticaContrato.Severidade__c = objCritica.Severidade__c;
            criticaContrato.Status__c = objCritica.Status__c;
            criticaContrato.Tipo__c = objCritica.Tipo__c;
            criticaContrato.Area__c = objCritica.Area__c;
            
            listCriticaContrato.add(criticaContrato);
            
        }
        
        return listCriticaContrato;
    }
    // PLV-2312-28 FIM Refactory na emissao de contrato
    // PLV-2312-28 INICIO Refactory na emissao de contrato
    @TestVisible //II-167 INICIO/FIM
    private static List<FavorecidoRemuneracaoContrato__c> gerarFavorecidosRemuneracaoContrato(List<RemuneracaoProposta__c> listRemuneracaoProposta, List<FavorecidoRemuneracaoContrato__c> listFavorecidosContrato, Map<Id, RemuneracaoContrato__c> mapRemsContrato) {
        for (RemuneracaoProposta__c remuneracaoProposta : listRemuneracaoProposta) {
            RemuneracaoContrato__c remuneracaoContrato = mapRemsContrato.get(remuneracaoProposta.Id);
            
            for (FavorecidoRemuneracaoProposta__c objFavorecido : remuneracaoProposta.FavorecidosRemuneracaodaProposta__r) {
                FavorecidoRemuneracaoContrato__c objFavorecidoRemuneracaoContrato = new FavorecidoRemuneracaoContrato__c();
                
                objFavorecidoRemuneracaoContrato.Conta__c = objFavorecido.Conta__c;
                objFavorecidoRemuneracaoContrato.DadosCorretor__c = objFavorecido.DadosCorretor__c;
                objFavorecidoRemuneracaoContrato.CorretorLider__c = objFavorecido.CorretorLider__c;
                objFavorecidoRemuneracaoContrato.Papel__c = objFavorecido.Papel__c;
                objFavorecidoRemuneracaoContrato.Participacao__c = objFavorecido.Participacao__c;
                objFavorecidoRemuneracaoContrato.RemuneracaoContrato__c = remuneracaoContrato.Id;
                objFavorecidoRemuneracaoContrato.Susep__c = objFavorecido.Susep__c;
                objFavorecidoRemuneracaoContrato.SusepEmissao__c = objFavorecido.SusepEmissao__c;
                objFavorecidoRemuneracaoContrato.SusepOficialCorretor__c = objFavorecido.SusepOficialCorretor__c;
                objFavorecidoRemuneracaoContrato.SusepOrcamento__c = objFavorecido.SusepOrcamento__c;
                objFavorecidoRemuneracaoContrato.AntecipacaoComissao__c = objFavorecido.AntecipacaoComissao__c; //PLV-4344
                
                listFavorecidosContrato.add(objFavorecidoRemuneracaoContrato);
            }
        }
        return listFavorecidosContrato;
    }
    // PLV-2312-28 FIM Refactory na emissao de contrato
    // PLV-2312-28 INICIO Refactory na emissao de contrato
    @TestVisible //II-167 INICIO/FIM
    private static List<RemuneracaoContrato__c> gerarRemuneracoesContrato(Contract contrato, List<RemuneracaoProposta__c> listRemuneracaoProposta, List<RemuneracaoContrato__c> listRemuneracaoContrato, Map<Id, RemuneracaoContrato__c> mapRemuneracaoContratoPorRemuneracaoPropostaId) {
        
        for (RemuneracaoProposta__c remuneracaoProposta : listRemuneracaoProposta) {
            RemuneracaoContrato__c remuneracaoContrato = new RemuneracaoContrato__c();
            
            remuneracaoContrato.Contrato__c = contrato.Id;
            remuneracaoContrato.Percentual__c = remuneracaoProposta.Percentual__c;
            remuneracaoContrato.RemuneracaoProduto__c = remuneracaoProposta.RemuneracaoProduto__c;
            remuneracaoContrato.TipoRemuneracao__c = remuneracaoProposta.TipoRemuneracao__c;
            // PLV-4234 - INICIO
            remuneracaoContrato.Porcentagem_de_Retencao__c = remuneracaoProposta.Porcentagem_de_Retencao__c;
            // PLV-4234 - FIM
            remuneracaoContrato.BonusCampanha__c = remuneracaoProposta.BonusCampanha__c; //II-167 INICIO/FIM

            listRemuneracaoContrato.add(remuneracaoContrato);
            mapRemuneracaoContratoPorRemuneracaoPropostaId.put(remuneracaoProposta.Id, remuneracaoContrato);
            
        }
        
        return listRemuneracaoContrato;
    }
    // PLV-2312-28 FIM Refactory na emissao de contrato
    // PLV-2312-28 INICIO Refactory na emissao de contrato
    private static List<GarantiaSeguradoContrato__c> gerarGarantiasSeguradoContrato(SeguradoProposta__c seguradoProposta, Map<Id, SeguradoContrato__c> mapSeguradoContrato, List<GarantiaSeguradoContrato__c> listGarantiaSeguradoContrato) {
        for(GarantiaSeguradoProposta__c garantiaSeguradoProposta : seguradoProposta.GarantiasSeguradoProposta__r){
            GarantiaSeguradoContrato__c garantiaSeguradoContrato = new GarantiaSeguradoContrato__c();
            
            garantiaSeguradoContrato.SeguradoContrato__c = mapSeguradoContrato.get(garantiaSeguradoProposta.SeguradoProposta__c).Id;
            
            garantiaSeguradoContrato.Capital__c = garantiaSeguradoProposta.Capital__c;
            // objGarantiaSegContrato.GarantiaReferenciada__c = objGarantiaSegProp.GarantiaReferenciada__c;
            garantiaSeguradoContrato.Garantia__c = garantiaSeguradoProposta.Garantia__c;
            garantiaSeguradoContrato.GarantiaProduto__c = garantiaSeguradoProposta.GarantiaProduto__c;
            garantiaSeguradoContrato.Percentual__c = garantiaSeguradoProposta.Percentual__c;
            garantiaSeguradoContrato.Valor__c = garantiaSeguradoProposta.Valor__c;
            garantiaSeguradoContrato.ValorCotacao__c = garantiaSeguradoProposta.ValorCotacao__c;
            garantiaSeguradoContrato.NumeroSerie__c = garantiaSeguradoProposta.NumeroSerie__c;
            garantiaSeguradoContrato.NumeroSorte__c = garantiaSeguradoProposta.NumeroSorte__c;
            garantiaSeguradoContrato.CurrencyIsoCode = garantiaSeguradoProposta.CurrencyIsoCode; //PLV-3884 - INICIO/FIM - Preenchimento da moeda seguindo garantia do segurado da proposta 
            
            //PLV-3731 - INICIO
            garantiaSeguradoContrato.ValorCotacao__c = garantiaSeguradoProposta.ValorCotacao__c;
            //PLV-3731 - FIM
            //PLV-5841 INICIO
            garantiaSeguradoContrato.PremioIntegral__c = garantiaSeguradoProposta.PremioIntegral__c != null ? garantiaSeguradoProposta.PremioIntegral__c : 0; //PLV-5351 INICIO/FIM
            garantiaSeguradoContrato.PremioPuro__c = garantiaSeguradoProposta.PremioPuro__c != null ? garantiaSeguradoProposta.PremioPuro__c : 0;
            garantiaSeguradoContrato.PremioComercial__c = garantiaSeguradoProposta.PremioComercial__c != null ? garantiaSeguradoProposta.PremioComercial__c : 0;
            garantiaSeguradoContrato.PremioTotal__c = garantiaSeguradoProposta.PremioTotal__c != null ? garantiaSeguradoProposta.PremioTotal__c : 0;
            //PLV-5841 FIM
            garantiaSeguradoContrato.TaxaPura__c = garantiaSeguradoProposta.TaxaPura__c;
            garantiaSeguradoContrato.TaxaComercial__c = garantiaSeguradoProposta.TaxaComercial__c;
            garantiaSeguradoContrato.TaxaTotal__c = garantiaSeguradoProposta.TaxaTotal__c;
            
            //PLV-5841 INICIO
            garantiaSeguradoContrato.DescontoAgravoPercentualTecnico__c = garantiaSeguradoProposta.DescontoAgravoPercentualTecnico__c != null? garantiaSeguradoProposta.DescontoAgravoPercentualTecnico__c : 0;
            garantiaSeguradoContrato.DescontoAgravoMonetarioTecnico__c = garantiaSeguradoProposta.DescontoAgravoMonetarioTecnico__c != null? garantiaSeguradoProposta.DescontoAgravoMonetarioTecnico__c : 0;
            garantiaSeguradoContrato.DescontoAgravoPercentualComercial__c = garantiaSeguradoProposta.DescontoAgravoPercentualComercial__c != null? garantiaSeguradoProposta.DescontoAgravoPercentualComercial__c : 0;
            garantiaSeguradoContrato.DescontoAgravoMonetarioComercial__c = garantiaSeguradoProposta.DescontoAgravoMonetarioComercial__c != null? garantiaSeguradoProposta.DescontoAgravoMonetarioComercial__c : 0;
            garantiaSeguradoContrato.DescontoAgravoPercentualInformado__c = garantiaSeguradoProposta.DescontoAgravoPercentualInformado__c != null? garantiaSeguradoProposta.DescontoAgravoPercentualInformado__c : 0;
            garantiaSeguradoContrato.DescontoAgravoMonetarioInformado__c = garantiaSeguradoProposta.DescontoAgravoMonetarioInformado__c != null? garantiaSeguradoProposta.DescontoAgravoMonetarioInformado__c : 0;
            garantiaSeguradoContrato.DescontoAgravoPercentualFormaPagto__c = garantiaSeguradoProposta.DescontoAgravoPercentualFormaPagto__c != null? garantiaSeguradoProposta.DescontoAgravoPercentualFormaPagto__c : 0;//PLV-4701 - INICIO/FIM
            garantiaSeguradoContrato.DescontoAgravoMonetarioFormaPagto__c = garantiaSeguradoProposta.DescontoAgravoMonetarioFormaPagto__c != null? garantiaSeguradoProposta.DescontoAgravoMonetarioFormaPagto__c : 0;//PLV-4701 - INICIO/FIM
            //PLV-5841 FIM
            garantiaSeguradoContrato.IOF__c = garantiaSeguradoProposta.IOF__c;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
            //PLV-4620 FIX 2 INICIO
            garantiaSeguradoContrato.Tipo_de_limite_de_utilizacao__c    = garantiaSeguradoProposta.Tipo_de_limite_de_utilizacao__c;
            garantiaSeguradoContrato.Limite_de_Uso__c         			= garantiaSeguradoProposta.Limite_de_Uso__c;
            //PLV-4830 INICIO
            garantiaSeguradoContrato.ValorDias__c         			= garantiaSeguradoProposta.ValorDias__c;
            System.debug('garantiaSeguradoContrato.ValorDias__c: ' + garantiaSeguradoContrato.ValorDias__c);
            //PLV-4830 FIM
            //PLV-4620 FIX 2 FIM
            
            listGarantiaSeguradoContrato.add(garantiaSeguradoContrato);
        }
        return listGarantiaSeguradoContrato;
    }
    // PLV-2312-28 FIM Refactory na emissao de contrato
    // PLV-2312-28 INICIO Refactory na emissao de contrato
    private static List<GarantiaGrupoContrato__c> gerarGarantiasGrupoContrato(GrupoProposta__c grupoProposta, List<GarantiaGrupoContrato__c> listGarantiaGrupoContrato, Map<Id, GrupoContrato__c> mapGrupoContrato) {
        for(GarantiasGrupoProposta__c garantiasGrupoProposta : grupoProposta.GarantiasGrupoProposta__r){
            GarantiaGrupoContrato__c garantiaGrupoContrato = new GarantiaGrupoContrato__c();
            
            garantiaGrupoContrato.GrupoContrato__c = mapGrupoContrato.get(garantiasGrupoProposta.GrupoProposta__c).Id;
            
            garantiaGrupoContrato.Capital__c = garantiasGrupoProposta.Capital__c;
            garantiaGrupoContrato.GarantiaReferenciada__c = garantiasGrupoProposta.GarantiaReferenciada__c;
            garantiaGrupoContrato.Garantia__c = garantiasGrupoProposta.Garantia__c;
            garantiaGrupoContrato.GarantiaProduto__c = garantiasGrupoProposta.GarantiaProduto__c;
            garantiaGrupoContrato.Percentual__c = garantiasGrupoProposta.Percentual__c;
            garantiaGrupoContrato.Valor__c = garantiasGrupoProposta.Valor__c;
            garantiaGrupoContrato.ValorCotacao__c = garantiasGrupoProposta.ValorCotacao__c;
            garantiaGrupoContrato.NumeroSerie__c = garantiasGrupoProposta.NumeroSerie__c;
            garantiaGrupoContrato.NumeroSorte__c = garantiasGrupoProposta.NumeroSorte__c;
            garantiaGrupoContrato.CurrencyIsoCode = garantiasGrupoProposta.CurrencyIsoCode; //PLV-3884 - INICIO/FIM - Preenchimento da moeda seguindo garantia do grupo da proposta 
            
            //PLV-3731 - INICIO
            garantiaGrupoContrato.ValorCotacao__c = garantiasGrupoProposta.ValorCotacao__c;
            // PLV-3884 - FIM
            //PLV-3731 - FIM
            garantiaGrupoContrato.PremioIntegral__c = garantiasGrupoProposta.PremioIntegral__c; //PLV-5351 INICIO/FIM FIX-01
            garantiaGrupoContrato.PremioPuro__c = garantiasGrupoProposta.PremioPuro__c;
            garantiaGrupoContrato.PremioComercial__c = garantiasGrupoProposta.PremioComercial__c;
            garantiaGrupoContrato.PremioTotal__c = garantiasGrupoProposta.PremioTotal__c;
            garantiaGrupoContrato.TaxaPura__c = garantiasGrupoProposta.TaxaPura__c;
            garantiaGrupoContrato.TaxaComercial__c = garantiasGrupoProposta.TaxaComercial__c;
            garantiaGrupoContrato.TaxaTotal__c = garantiasGrupoProposta.TaxaTotal__c;
            
            garantiaGrupoContrato.DescontoAgravoPercentualTecnico__c = garantiasGrupoProposta.DescontoAgravoPercentualTecnico__c;
            garantiaGrupoContrato.DescontoAgravoMonetarioTecnico__c = garantiasGrupoProposta.DescontoAgravoMonetarioTecnico__c;
            garantiaGrupoContrato.DescontoAgravoPercentualComercial__c = garantiasGrupoProposta.DescontoAgravoPercentualComercial__c;
            garantiaGrupoContrato.DescontoAgravoMonetarioComercial__c = garantiasGrupoProposta.DescontoAgravoMonetarioComercial__c;
            garantiaGrupoContrato.DescontoAgravoPercentualInformado__c = garantiasGrupoProposta.DescontoAgravoPercentualInformado__c;
            garantiaGrupoContrato.DescontoAgravoMonetarioInformado__c = garantiasGrupoProposta.DescontoAgravoMonetarioInformado__c;
            garantiaGrupoContrato.DescontoAgravoPercentualFormaPagto__c = garantiasGrupoProposta.DescontoAgravoPercentualFormaPagto__c;//PLV-4701 - INICIO/FIM
            garantiaGrupoContrato.DescontoAgravoMonetarioFormaPagto__c = garantiasGrupoProposta.DescontoAgravoMonetarioFormaPagto__c;//PLV-4701 - INICIO/FIM
            garantiaGrupoContrato.IOF__c = garantiasGrupoProposta.IOF__c;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
            
            
            listGarantiaGrupoContrato.add(garantiaGrupoContrato);
            
        }
        
        return listGarantiaGrupoContrato;
    }
    // PLV-2312-28 FIM Refactory na emissao de contrato
    // PLV-2312-28 INICIO Refactory na emissao de contrato
    private static List<GarantiaContratanteContrato__c> gerarGarantiasContratanteContrato(ContratanteProposta__c contratanteProposta, List<GarantiaContratanteContrato__c> listGarantiaContratanteContrato, Map<Id, ContratanteContrato__c> mapContratanteContrato) {
        
        // Busca as garantias do contratante da proposta
        for (GarantiaContratanteProposta__c garantiaContratanteProposta : contratanteProposta.GarantiasContratanteProposta__r){
            GarantiaContratanteContrato__c garantiaContratanteContrato = new GarantiaContratanteContrato__c();
            
            garantiaContratanteContrato.ContratanteContrato__c = mapContratanteContrato.get(garantiaContratanteProposta.ContratanteProposta__c).Id;
            garantiaContratanteContrato.Garantia__c = garantiaContratanteProposta.Garantia__c;
            // objGarantiaContratanteContrato.TipoCapital__c      = objGarantiaContratanteProp.TipoCapital__c;
            // objGarantiaContratanteContrato.LimiteCapital__c    = objGarantiaContratanteProp.LimiteCapital__c;
            garantiaContratanteContrato.GarantiaProduto__c = garantiaContratanteProposta.GarantiaProduto__c;
            garantiaContratanteContrato.Capital__c = garantiaContratanteProposta.Capital__c;
            garantiaContratanteContrato.NumeroSorte__c = garantiaContratanteProposta.NumeroSorte__c;
            garantiaContratanteContrato.NumeroSerie__c = garantiaContratanteProposta.NumeroSerie__c;
            garantiaContratanteContrato.CurrencyIsoCode = garantiaContratanteProposta.CurrencyIsoCode; //PLV-3884 - INICIO/FIM - Preenchimento da moeda seguindo garantia do contratante da proposta 
            
            //PLV-3731 - INICIO
            garantiaContratanteContrato.ValorCotacao__c = garantiaContratanteProposta.ValorCotacao__c;
            //PLV-3731 - FIM
            
            // objGarantiaContratanteContrato.DataSorteio__c      = objGarantiaContratanteProp.DataSorteio__c;
            // objGarantiaContratanteContrato.DataSolicitacaoCapitalizacao__c = objGarantiaContratanteProp.DataSolicitacaoCapitalizacao__c;
            // objGarantiaContratanteContrato.StatusCapitalizacao__c          = objGarantiaContratanteProp.StatusCapitalizacao__c;
            // objGarantiaContratanteContrato.VersaoTitulo__c                 = objGarantiaContratanteProp.VersaoTitulo__c;
            // objGarantiaContratanteContrato.NumeroTitulo__c                 = objGarantiaContratanteProp.NumeroTitulo__c;
            // objGarantiaContratanteContrato.DataSorteio__c                  = objGarantiaContratanteProp.DataSorteio__c;
            // objGarantiaContratanteContrato.LoteCapitalizacao__c            = objGarantiaContratanteProp.LoteCapitalizacao__c;
            
            garantiaContratanteContrato.PremioIntegral__c = garantiaContratanteProposta.PremioIntegral__c; //PLV-5351 INICIO/FIM
            garantiaContratanteContrato.PremioComercial__c = garantiaContratanteProposta.PremioComercial__c;
            garantiaContratanteContrato.PremioPuro__c = garantiaContratanteProposta.PremioPuro__c;
            garantiaContratanteContrato.PremioTotal__c = garantiaContratanteProposta.PremioTotal__c;
            garantiaContratanteContrato.TaxaComercial__c = garantiaContratanteProposta.TaxaComercial__c;
            garantiaContratanteContrato.TaxaPura__c = garantiaContratanteProposta.TaxaPura__c;
            garantiaContratanteContrato.TaxaTotal__c = garantiaContratanteProposta.TaxaTotal__c;
            
            garantiaContratanteContrato.DescontoAgravoPercentualTecnico__c = garantiaContratanteProposta.DescontoAgravoPercentualTecnico__c;
            garantiaContratanteContrato.DescontoAgravoMonetarioTecnico__c = garantiaContratanteProposta.DescontoAgravoMonetarioTecnico__c;
            garantiaContratanteContrato.DescontoAgravoPercentualComercial__c = garantiaContratanteProposta.DescontoAgravoPercentualComercial__c;
            garantiaContratanteContrato.DescontoAgravoMonetarioComercial__c = garantiaContratanteProposta.DescontoAgravoMonetarioComercial__c;
            garantiaContratanteContrato.DescontoAgravoPercentualInformado__c = garantiaContratanteProposta.DescontoAgravoPercentualInformado__c;
            garantiaContratanteContrato.DescontoAgravoMonetarioInformado__c = garantiaContratanteProposta.DescontoAgravoMonetarioInformado__c;
            garantiaContratanteContrato.DescontoAgravoPercentualFormaPagto__c = garantiaContratanteProposta.DescontoAgravoPercentualFormaPagto__c;//PLV-4701 - INICIO/FIM
            garantiaContratanteContrato.DescontoAgravoMonetarioFormaPagto__c = garantiaContratanteProposta.DescontoAgravoMonetarioFormaPagto__c;//PLV-4701 - INICIO/FIM
            garantiaContratanteContrato.IOF__c = garantiaContratanteProposta.IOF__c;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
            
            listGarantiaContratanteContrato.add(garantiaContratanteContrato);
            
        }
        
        return listGarantiaContratanteContrato;
    }
    // PLV-2312-28 FIM Refactory na emissao de contrato
    // PLV-2312-28 INICIO Refactory na emissao de contrato
    private static List<GarantiaContrato__c> gerarGarantiasContrato(Quote proposta, Contract contrato, List<GarantiaContrato__c> listGarantiaContrato) {
        
        // Busca as garantias da proposta
        for (GarantiaProposta__c garantiaProposta : proposta.GarantiasProposta__r) {
            
            GarantiaContrato__c objGarantiaContrato = new GarantiaContrato__c();
            
            objGarantiaContrato.Contrato__c = contrato.Id;
            objGarantiaContrato.Garantia__c = garantiaProposta.Garantia__c;
            
            objGarantiaContrato.TipoCapital__c = garantiaProposta.TipoCapital__c;
            objGarantiaContrato.LimiteCapital__c = garantiaProposta.LimiteCapital__c;
            objGarantiaContrato.GarantiaProduto__c = garantiaProposta.GarantiaProduto__c;
            objGarantiaContrato.Capital__c = garantiaProposta.Capital__c;
            objGarantiaContrato.NumeroSorte__c = garantiaProposta.NumeroSorte__c;
            objGarantiaContrato.NumeroSerie__c = garantiaProposta.NumeroSerie__c;
            objGarantiaContrato.DataSorteio__c = garantiaProposta.DataSorteio__c;
            objGarantiaContrato.DataSolicitacaoCapitalizacao__c = garantiaProposta.DataSolicitacaoCapitalizacao__c;
            objGarantiaContrato.StatusCapitalizacao__c = garantiaProposta.StatusCapitalizacao__c;
            objGarantiaContrato.VersaoTitulo__c = garantiaProposta.VersaoTitulo__c;
            objGarantiaContrato.NumeroTitulo__c = garantiaProposta.NumeroTitulo__c;
            objGarantiaContrato.DataSorteio__c = garantiaProposta.DataSorteio__c;
            objGarantiaContrato.LoteCapitalizacao__c = garantiaProposta.LoteCapitalizacao__c;
            objGarantiaContrato.GarantiaProduto__c = garantiaProposta.GarantiaProduto__c;
            objGarantiaContrato.CurrencyIsoCode = garantiaProposta.CurrencyIsoCode; //PLV-3884 - INICIO/FIM - Preenchimento da moeda seguindo garantia da proposta 
            //PLV-5841 INICIO
            objGarantiaContrato.PremioIntegral__c = garantiaProposta.PremioIntegral__c != null ? garantiaProposta.PremioIntegral__c : 0; //PLV-5351 INICIO/FIM
            objGarantiaContrato.PremioComercial__c = garantiaProposta.PremioComercial__c != null ? garantiaProposta.PremioComercial__c : 0;
            objGarantiaContrato.PremioPuro__c = garantiaProposta.PremioPuro__c != null ? garantiaProposta.PremioPuro__c : 0;
            objGarantiaContrato.PremioTotal__c = garantiaProposta.PremioTotal__c != null ? garantiaProposta.PremioTotal__c : 0;
            //PLV-5841 FIM
            objGarantiaContrato.TaxaComercial__c = garantiaProposta.TaxaComercial__c;
            objGarantiaContrato.TaxaPura__c = garantiaProposta.TaxaPura__c;
            objGarantiaContrato.TaxaTotal__c = garantiaProposta.TaxaTotal__c;
            
            //PLV-4620 FIX 2 INICIO
            objGarantiaContrato.Tipo_de_limite_de_utilizacao__c    = garantiaProposta.Tipo_de_limite_de_utilizacao__c;
            objGarantiaContrato.Limite_de_Uso__c         			= garantiaProposta.Limite_de_Uso__c;
            //PLV-4620 FIX 2 FIM
            
            //PLV-3731 - INICIO
            objGarantiaContrato.ValorCotacao__c = garantiaProposta.ValorCotacao__c;
            //PLV-3731 - FIM
            
            //PLV-5841 INICIO
            objGarantiaContrato.DescontoAgravoPercentualTecnico__c = garantiaProposta.DescontoAgravoPercentualTecnico__c != null ? garantiaProposta.DescontoAgravoPercentualTecnico__c : 0;
            objGarantiaContrato.DescontoAgravoMonetarioTecnico__c = garantiaProposta.DescontoAgravoMonetarioTecnico__c != null ? garantiaProposta.DescontoAgravoMonetarioTecnico__c : 0;
            objGarantiaContrato.DescontoAgravoPercentualComercial__c = garantiaProposta.DescontoAgravoPercentualComercial__c != null ? garantiaProposta.DescontoAgravoPercentualComercial__c : 0;
            objGarantiaContrato.DescontoAgravoMonetarioComercial__c = garantiaProposta.DescontoAgravoMonetarioComercial__c != null ? garantiaProposta.DescontoAgravoMonetarioComercial__c : 0;
            objGarantiaContrato.DescontoAgravoPercentualInformado__c = garantiaProposta.DescontoAgravoPercentualInformado__c != null ? garantiaProposta.DescontoAgravoPercentualInformado__c : 0;
            objGarantiaContrato.DescontoAgravoMonetarioInformado__c = garantiaProposta.DescontoAgravoMonetarioInformado__c != null ? garantiaProposta.DescontoAgravoMonetarioInformado__c : 0;
            objGarantiaContrato.DescontoAgravoPercentualFormaPagto__c = garantiaProposta.DescontoAgravoPercentualFormaPagto__c != null ? garantiaProposta.DescontoAgravoPercentualFormaPagto__c : 0;//PLV-4701 - INICIO/FIM
            objGarantiaContrato.DescontoAgravoMonetarioFormaPagto__c = garantiaProposta.DescontoAgravoMonetarioFormaPagto__c != null ? garantiaProposta.DescontoAgravoMonetarioFormaPagto__c : 0;//PLV-4701 - INICIO/FIM
            //PLV-5841 FIM
            objGarantiaContrato.IOF__c = garantiaProposta.IOF__c;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
            
            objGarantiaContrato.FranquiaGarantia__c = garantiaProposta.FranquiaGarantia__c; // PLV-4598 - INICIO/FIM
            
            
            listGarantiaContrato.add(objGarantiaContrato);
            
        }
        return listGarantiaContrato;
    }
    // PLV-2312-28 FIM Refactory na emissao de contrato
    // PLV-2312-28 INICIO Refactory na emissao de contrato
    private static List<BeneficiarioSeguradoContrato__c> gerarBeneficiariosSeguradoContrato(SeguradoProposta__c seguradoProposta, Map<Id, SeguradoContrato__c> mapSeguradoContrato, List<BeneficiarioSeguradoContrato__c> listBeneficiarioSeguradoContrato) {
        for (BeneficiarioSeguradoProposta__c beneficiarioSeguradoProposta : seguradoProposta.BeneficiariosSeguradosProposta__r) {
            listBeneficiarioSeguradoContrato.add(gerarBeneficiarioSeguradoProposta(mapSeguradoContrato, beneficiarioSeguradoProposta));
        }
        return listBeneficiarioSeguradoContrato;
    }
    // PLV-2312-28 FIM Refactory na emissao de contrato
    // PLV-2312-28 INICIO Refactory na emissao de contrato
    private static BeneficiarioSeguradoContrato__c gerarBeneficiarioSeguradoProposta(Map<Id, SeguradoContrato__c> mapSeguradoContrato, BeneficiarioSeguradoProposta__c beneficiarioSeguradoProposta) {
        // Instancias
        BeneficiarioSeguradoContrato__c beneficiarioSeguradoContrato = new BeneficiarioSeguradoContrato__c();
        
        beneficiarioSeguradoContrato.SeguradoContrato__c = mapSeguradoContrato.get(beneficiarioSeguradoProposta.SeguradoProposta__c).Id;
        beneficiarioSeguradoContrato.Conta__c = beneficiarioSeguradoProposta.Conta__c;
        beneficiarioSeguradoContrato.CpfCnpj__c = beneficiarioSeguradoProposta.CpfCnpj__c;
        beneficiarioSeguradoContrato.CpfPep__c = beneficiarioSeguradoProposta.CpfPep__c;
        //PLV-4441 beneficiarioSeguradoContrato.GrauParentesco__c = beneficiarioSeguradoProposta.GrauParentescoPep__c;
        beneficiarioSeguradoContrato.GrauParentescoPep__c = beneficiarioSeguradoProposta.GrauParentescoPep__c;
        beneficiarioSeguradoContrato.ImprimirCertificadoSeguro__c = beneficiarioSeguradoProposta.ImprimirCertificadoSeguro__c;
        beneficiarioSeguradoContrato.MotivoSemCpfCnpj__c = beneficiarioSeguradoProposta.MotivoSemCpfCnpj__c;
        beneficiarioSeguradoContrato.Nome__c = beneficiarioSeguradoProposta.Nome__c;
        beneficiarioSeguradoContrato.NomeSocial__c = beneficiarioSeguradoProposta.NomeSocial__c; // LECVPV-184 INICIO/FIM
        beneficiarioSeguradoContrato.NomePessoaPep__c = beneficiarioSeguradoProposta.NomePessoaPep__c;
        beneficiarioSeguradoContrato.Participacao__c = beneficiarioSeguradoProposta.Participacao__c;
        beneficiarioSeguradoContrato.Pep__c = beneficiarioSeguradoProposta.Pep__c;
        beneficiarioSeguradoContrato.TipoBeneficiario__c = beneficiarioSeguradoProposta.TipoBeneficiario__c;
        //PLV-4441 - INICIO - Pedro Augusto Braz - SYS4B
        beneficiarioSeguradoContrato.Data_de_Nascimento__c = beneficiarioSeguradoProposta.Data_de_Nascimento__c;
        beneficiarioSeguradoContrato.GrauParentesco__c = beneficiarioSeguradoProposta.GrauParentesco__c;
        beneficiarioSeguradoContrato.BeneficiarioGrauParentescoOutros__c = beneficiarioSeguradoProposta.BeneficiarioGrauParentescoOutros__c; //PLV-5231 - INICIO/FIM
        beneficiarioSeguradoContrato.PercentualIndenizacao__c = beneficiarioSeguradoProposta.PercentualIndenizacao__c;
        beneficiarioSeguradoContrato.Sexo__c = beneficiarioSeguradoProposta.Sexo__c;
        
        //PLV-4441 - FIM - Pedro Augusto Braz - SYS4B
        return beneficiarioSeguradoContrato;
    }
    // PLV-2312-28 FIM Refactory na emissao de contrato
    // PLV-2312-28 INICIO Refactory na emissao de contrato
    private static Map<Id, SeguradoContrato__c> gerarHierarquiaSeguradosContrato(Quote proposta, Map<Id, GrupoContrato__c> mapGrupoContrato, Map<Id, SeguradoContrato__c> mapSeguradoContrato) {
        // Instancias
        List<SeguradoContrato__c> listSeguradoContrato = new List<SeguradoContrato__c>();
        List<BeneficiarioSeguradoContrato__c> listBeneficiarioSeguradoContrato = new List<BeneficiarioSeguradoContrato__c>();
        List<GarantiaSeguradoContrato__c> lstGarantiaSeguradoContrato = new List<GarantiaSeguradoContrato__c>();
        
        // Busca os segurados da proposta
        List<SeguradoProposta__c> listSeguradoProposta = QuoteDAO.getInstance().buscarListSeguradosPropostaByQuote(new Set<Id>{proposta.Id});
        
        // Geracao dos segurados do contrato a partir do segurado da proposta
        for (SeguradoProposta__c seguradoProposta : listSeguradoProposta){
            SeguradoContrato__c seguradoContrato = gerarSeguradoContrato(mapGrupoContrato, seguradoProposta);
            
            //PLV-2334 - INICIO
            seguradoContrato.VigenciaInicial__c = proposta.VigenciaInicial__c;
            seguradoContrato.VigenciaFinal__c = proposta.VigenciaFinal__c;
            //PLV-2334 - FINAL
    //RVI-84 - INICIO
    if (seguradoProposta.GrupoRisco__c == null) {
        seguradoContrato.GrupoRisco__c = ' ';
    } else {
        seguradoContrato.GrupoRisco__c = seguradoProposta.GrupoRisco__c;
    }
    //RVI-84 - FIM

            mapSeguradoContrato.put(seguradoProposta.Id, seguradoContrato);
            listSeguradoContrato.add(seguradoContrato);
        }
        System.debug('Grava Grupo do Contrato');
        insert listSeguradoContrato;
        
        // Geracao de filhos do segurado do contrato
        for(SeguradoProposta__c seguradoProposta : listSeguradoProposta){
            //====> Beneficiarios do segurado do contrato
            listBeneficiarioSeguradoContrato = gerarBeneficiariosSeguradoContrato(seguradoProposta, mapSeguradoContrato, listBeneficiarioSeguradoContrato);
            //====> Garantia do segurado do contrato
            lstGarantiaSeguradoContrato = gerarGarantiasSeguradoContrato(seguradoProposta, mapSeguradoContrato, lstGarantiaSeguradoContrato);
        }
        
        //====> Gravacao dos filhos do segurado do contrato
        insert lstGarantiaSeguradoContrato;
        insert listBeneficiarioSeguradoContrato;
        
        return mapSeguradoContrato;
    }
    // PLV-2312-28 FIM Refactory na emissao de contrato
    // PLV-2312-28 INICIO Refactory na emissao de contrato
    @TestVisible //II-167 INICIO/FIM
    private static SeguradoContrato__c gerarSeguradoContrato(Map<Id, GrupoContrato__c> mapGrupoContrato, SeguradoProposta__c seguradoProposta) {
        // Instancia
        SeguradoContrato__c seguradoContrato = new SeguradoContrato__c();
        
        seguradoContrato.GrupoContrato__c = mapGrupoContrato.get(seguradoProposta.GrupoProposta__c).Id;
        
        //PLV-5098 - INICIO - BRUNO FILIPE/JOSE LUCIANO/GABRIEL LOCH
        seguradoContrato.tipoEmpresa__c = seguradoProposta.tipoEmpresa__c;
        seguradoContrato.numeroCnpj__c = seguradoProposta.numeroCnpj__c;
        seguradoContrato.qtdFuncionarios__c = seguradoProposta.qtdFuncionarios__c;
        //PLV-5098 - FIM - BRUNO FILIPE/JOSE LUCIANO/GABRIEL LOCH

        seguradoContrato.Conta__c = seguradoProposta.Conta__c;
        seguradoContrato.EnderecoBoleto__c = seguradoProposta.EnderecoBoleto__c;
        seguradoContrato.FormaPagamento__c = seguradoProposta.FormaPagamento__c;
        seguradoContrato.QuantidadeParcelas__c = seguradoProposta.QuantidadeParcelas__c;
        seguradoContrato.ResponsavelPagamento__c = seguradoProposta.ResponsavelPagamento__c;
        seguradoContrato.VencimentoPrimeiraParcela__c = seguradoProposta.VencimentoPrimeiraParcela__c;
        seguradoContrato.TipoResponsavelPagamento__c = seguradoProposta.TipoResponsavelPagamento__c;
        seguradoContrato.Numero__c = seguradoProposta.Numero__c;
        
        seguradoContrato.PremioParcela__c = seguradoProposta.PremioParcela__c;
        seguradoContrato.PorcentagemParticipacaoVida__c = seguradoProposta.PorcentagemParticipacaoVida__c;
        seguradoContrato.Reenquadramento__c = seguradoProposta.Reenquadramento__c;
        
        seguradoContrato.PorcentagemParticipacaoSegurado__c = seguradoProposta.PorcentagemParticipacaoSegurado__c;
        seguradoContrato.InformacaoBancaria__c = seguradoProposta.InformacaoBancaria__c;
        seguradoContrato.PlanoParcelamento__c = seguradoProposta.PlanoParcelamento__c;
        seguradoContrato.CartaoCredito__c = seguradoProposta.CartaoCredito__c;
        seguradoContrato.TipoCusteio__c = seguradoProposta.TipoCusteio__c;
        
        seguradoContrato.IOF__c = seguradoProposta.IOF__c;
        seguradoContrato.IPCA__c = seguradoProposta.IPCA__c;
        seguradoContrato.PremioIntegral__c = seguradoProposta.PremioIntegral__c; //PLV-5351 INICO/FIM
        seguradoContrato.PremioComercial__c = seguradoProposta.PremioComercial__c;
        seguradoContrato.PremioPuro__c = seguradoProposta.PremioPuro__c;
        seguradoContrato.PremioTotal__c = seguradoProposta.PremioTotal__c;
        seguradoContrato.TaxaComercial__c = seguradoProposta.TaxaComercial__c;
        seguradoContrato.TaxaPura__c = seguradoProposta.TaxaPura__c;
        seguradoContrato.TaxaTotal__c = seguradoProposta.TaxaTotal__c;
        
        seguradoContrato.DescontoAgravoPercentualTecnico__c = seguradoProposta.DescontoAgravoPercentualTecnico__c;
        seguradoContrato.DescontoAgravoMonetarioTecnico__c = seguradoProposta.DescontoAgravoMonetarioTecnico__c;
        seguradoContrato.DescontoAgravoPercentualComercial__c = seguradoProposta.DescontoAgravoPercentualComercial__c;
        seguradoContrato.DescontoAgravoMonetarioComercial__c = seguradoProposta.DescontoAgravoMonetarioComercial__c;
        seguradoContrato.DescontoAgravoPercentualInformado__c = seguradoProposta.DescontoAgravoPercentualInformado__c;
        seguradoContrato.DescontoAgravoMonetarioInformado__c = seguradoProposta.DescontoAgravoMonetarioInformado__c;
        seguradoContrato.DescontoAgravoPercentualFormaPagto__c = seguradoProposta.DescontoAgravoPercentualFormaPagto__c;//PLV-4701 - INICIO/FIM
        seguradoContrato.DescontoAgravoMonetarioFormaPagto__c = seguradoProposta.DescontoAgravoMonetarioFormaPagto__c;//PLV-4701 - INICIO/FIM
        seguradoContrato.DescontoAgravoPercentualParcelamento__c = seguradoProposta.DescontoAgravoPercentualParcelamento__c;//PLV-4810 - INICIO/FIM SYS4B odemir
        seguradoContrato.DescontoAgravoMonetarioParcelamento__c = seguradoProposta.DescontoAgravoMonetarioParcelamento__c;//PLV-4810 - INICIO/FIM SYS4B odemir
        seguradoContrato.IOF__c = seguradoProposta.IOF__c;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
        
        
        //PLV-4441 - INICIO - Pedro Augusto Braz - SYS4B
        seguradoContrato.profissao__c   =   seguradoProposta.profissao__c;
        seguradoContrato.RegimeTrabalho__c  =   seguradoProposta.RegimeTrabalho__c;
        seguradoContrato.FaixaRenda__c  =   seguradoProposta.FaixaRenda__c;
        seguradoContrato.ResponsavelFinanceiroSeguro__c  =   seguradoProposta.ResponsavelFinanceiroSeguro__c;
        seguradoContrato.NomeResponsavel__c  =   seguradoProposta.NomeResponsavel__c;
        seguradoContrato.CpfResponsavel__c  =   seguradoProposta.CpfResponsavel__c;
        seguradoContrato.EmailResponsavel__c  =   seguradoProposta.EmailResponsavel__c;//PLV-4911 - INICIO/FIM
        seguradoContrato.VinculoComSegurado__c  =   seguradoProposta.VinculoComSegurado__c;
        seguradoContrato.Pep__c = seguradoProposta.Pep__c;
        seguradoContrato.TipoPessoaRelacionamentoProximo__c = seguradoProposta.TipoPessoaRelacionamentoProximo__c;
        seguradoContrato.NomePessoaRelacionamentoProximo__c = seguradoProposta.NomePessoaRelacionamentoProximo__c;
        seguradoContrato.CpfPessoaRelacionamentoProximo__c  = seguradoProposta.CpfPessoaRelacionamentoProximo__c;
        seguradoContrato.GrauParentesco__c = seguradoProposta.GrauParentesco__c;
        seguradoContrato.Fumante__c = seguradoProposta.Fumante__c;
        seguradoContrato.TemDependentes__c = seguradoProposta.TemDependentes__c;
        //PLV-4441 - FIM - Pedro Augusto Braz - SYS4B
        //PLV-4600 INICIO
        seguradoContrato.NomeContatoEmergencia__c = seguradoProposta.NomeContatoEmergencia__c;
        seguradoContrato.TelefoneContatoEmergencia__c = seguradoProposta.TelefoneContatoEmergencia__c;
        //PLV-4600 FIM

        //PLV-2334 - INICIO
        //seguradoContrato.VigenciaInicial__c = seguradoProposta.VigenciaInicial__c;
        //seguradoContrato.VigenciaFinal__c = seguradoProposta.VigenciaFinal__c;
        //PLV-2334 - FINAL
        
        /*PLV - 4442 Inicio
        seguradoContrato.Profissao__c = seguradoProposta.Profissao__c ;
        seguradoContrato.Fumante__c = seguradoProposta.Fumante__c;
        seguradoContrato.RegimeTrabalho__c = seguradoProposta.RegimeTrabalho__c;
        seguradoContrato.TemDependentes__c = seguradoProposta.TemDependentes__c;
        seguradoContrato.FaixaRenda__c = seguradoProposta.FaixaRenda__c;       
        //PLV - 4442 fim */

        //PLV - 4690 - INICIO -  GUSTAVO DA SILVA PEREIRA SYS4B
        seguradoContrato.NomeSegurado__c = seguradoProposta.Nome_do_segurado__c;
        // LECVPV-184 INICIO
        seguradoContrato.NomeSocial__c = seguradoProposta.NomeSocial_do_Segurado__c;
        seguradoContrato.NomeSocial_do_Segurado__c =  seguradoProposta.NomeSocial_do_Segurado__c;
        // LECVPV-184 FIM
        seguradoContrato.EmpresaTrabalhaSocio__c = seguradoProposta.EmpresaTrabalhaSocio__c;
        seguradoContrato.RamoAtividade__c = seguradoProposta.RamoAtividade__c;  //  PLV-4810 INICIO/FIM SYS4B ODEMIR
        seguradoContrato.Renda__c = seguradoProposta.Renda__c;
        seguradoContrato.Email__c = seguradoProposta.Email__c;
        seguradoContrato.Celular__c = seguradoProposta.Celular__c;
        seguradoContrato.TelefoneResidencial__c = seguradoProposta.Telefone_residencial__c;
        seguradoContrato.TelefoneComercial__c = seguradoProposta.Telefone_comercial__c;
        seguradoContrato.EnderecoResidencial__c = seguradoProposta.Endereco_residencial__c;
        seguradoContrato.EnderecoComercial__c = seguradoProposta.Endereco_comercial__c;
        seguradoContrato.EnderecoRecado__c = seguradoProposta.Endereco_de_recado__c;
        seguradoContrato.EnderecoVeraneio__c = seguradoProposta.Endereco_veraneio__c;
        seguradoContrato.MelhorPeriodoContato__c = seguradoProposta.Melhor_periodo_para_contato__c;
        //PLV - 4690 - FIM -  GUSTAVO DA SILVA PEREIRA SYS4B

         // PLV-4594 INICIO SYS4B ODEMIR  
         seguradoContrato.IntegracaoPEP__c =  seguradoProposta.IntegracaoPEP__c;
         seguradoContrato.CargoPEP__c =  seguradoProposta.CargoPEP__c;
         seguradoContrato.UltimaConsultaPEP__c =  seguradoProposta.UltimaConsultaPEP__c;
         seguradoContrato.DataAtualizacaoPEP__c = seguradoProposta.DataAtualizacaoPEP__c;
         // PLV-4594 FIM SYS4B ODEMIR

        // PLV-4844 INICIO
         seguradoContrato.logradouroResidencial__c = seguradoProposta.logradouroResidencial__c;
         seguradoContrato.numeroResidencial__c = seguradoProposta.numeroResidencial__c;
         seguradoContrato.ComplementoResidencial__c = seguradoProposta.ComplementoResidencial__c;
         seguradoContrato.bairroResidencial__c = seguradoProposta.bairroResidencial__c;
         seguradoContrato.CidadeResidencial__c = seguradoProposta.CidadeResidencial__c;
         seguradoContrato.UFResidencial__c = seguradoProposta.UFResidencial__c;
         seguradoContrato.paisResidencial__c = seguradoProposta.paisResidencial__c;
         seguradoContrato.cepResidencial__c = seguradoProposta.cepResidencial__c;
        // PLV-4844 FIM
        
        seguradoContrato.CicloVacinal__c = seguradoProposta.CicloVacinal__c; //PLV-5127 INICIO/FIM

        //PLV-5066 INICIO
        seguradoContrato.Nome__c = seguradoProposta.Nome_do_segurado__c;
        seguradoContrato.RendaMensal__c = String.valueOf(seguradoProposta.Renda__c);
        //PLV-5066 FIM

        //PLV-4874 - Inicio
        seguradoContrato.Pais_Residente__c = seguradoProposta.Pais_Residente__c;
        //PLV-4874 - Fim
        
        seguradoContrato.PaisDeOrigem__c = seguradoProposta.PaisDeOrigem__c; //PLV-5231 - INICIO/FIM
        
        return seguradoContrato;
    }
    // PLV-2312-28 FIM Refactory na emissao de contrato
    // PLV-2312-28 INICIO Refactory na emissao de contrato
    @TestVisible //II-167 INICIO/FIM
    private static Map<Id, GrupoContrato__c> gerarHierarquiaGruposContrato(Quote proposta, Map<Id, ContratanteContrato__c> mapContratanteContrato, Map<Id, GrupoContrato__c> mapGrupoContrato) {
        
        // Instancias
        List<GrupoContrato__c> listGrupoContrato = new List<GrupoContrato__c>();
        List<GarantiaGrupoContrato__c> listGarantiaGrupoContrato = new List<GarantiaGrupoContrato__c>();
        
        // Busca os grupos da proposta e seus filhos
        List<GrupoProposta__c> listGrupoProposta = QuoteDAO.getInstance().buscarListGrupoPropostaByQuote(new Set<Id>{proposta.Id});
        System.debug('listGrupoProposta <>' + listGrupoProposta);
        System.debug('proposta.Id <> ' + proposta.Id);
        System.debug('proposta <> ' + proposta);


        for (GrupoProposta__c grupoProposta : listGrupoProposta){
            GrupoContrato__c grupoContrato = new GrupoContrato__c();
            grupoContrato.ContratanteContrato__c = mapContratanteContrato.get(grupoProposta.ContratanteProposta__c).Id;
            grupoContrato.Descricao__c = grupoProposta.Descricao__c;
            grupoContrato.Name = grupoProposta.Name;
            grupoContrato.Numero__c = grupoProposta.Numero__c;
            grupoContrato.QuantidadeVidas__c = grupoProposta.QuantidadeVidas__c;
            grupoContrato.TipoCalculo__c = grupoProposta.TipoCalculo__c;
            grupoContrato.PremioIntegral__c = grupoProposta.PremioIntegral__c; //PLV-5351 INICIO/FIM
            grupoContrato.PremioComercial__c = grupoProposta.PremioComercial__c;
            grupoContrato.PremioPuro__c = grupoProposta.PremioPuro__c;
            grupoContrato.PremioTotal__c = grupoProposta.PremioTotal__c;
            grupoContrato.TaxaComercial__c = grupoProposta.TaxaComercial__c;
            grupoContrato.TaxaPura__c = grupoProposta.TaxaPura__c;
            grupoContrato.TaxaTotal__c = grupoProposta.TaxaTotal__c;
            grupoContrato.DescontoAgravoPercentualTecnico__c = grupoProposta.DescontoAgravoPercentualTecnico__c;
            grupoContrato.DescontoAgravoMonetarioTecnico__c = grupoProposta.DescontoAgravoMonetarioTecnico__c;
            grupoContrato.DescontoAgravoPercentualComercial__c = grupoProposta.DescontoAgravoPercentualComercial__c;
            grupoContrato.DescontoAgravoMonetarioComercial__c = grupoProposta.DescontoAgravoMonetarioComercial__c;
            grupoContrato.DescontoAgravoPercentualInformado__c = grupoProposta.DescontoAgravoPercentualInformado__c;
            grupoContrato.DescontoAgravoMonetarioInformado__c = grupoProposta.DescontoAgravoMonetarioInformado__c;
            grupoContrato.DescontoAgravoPercentualFormaPagto__c = grupoProposta.DescontoAgravoPercentualFormaPagto__c;//PLV-4701 - INICIO/FIM
            grupoContrato.DescontoAgravoMonetarioFormaPagto__c = grupoProposta.DescontoAgravoMonetarioFormaPagto__c;//PLV-4701 - INICIO/FIM
            grupoContrato.IOF__c = grupoProposta.IOF__c;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
            
            mapGrupoContrato.put(grupoProposta.Id, grupoContrato);
            listGrupoContrato.add(grupoContrato);
        }
        
        insert listGrupoContrato;
        
        // Geracao dos filhos do grupo do contrato
        for(GrupoProposta__c grupoProposta : listGrupoProposta){
            //====> Garantia do Grupo do Contrato
            listGarantiaGrupoContrato = gerarGarantiasGrupoContrato(grupoProposta, listGarantiaGrupoContrato, mapGrupoContrato);
        }
        
        // Gravacao dos filhos do grupo do contrato
        insert listGarantiaGrupoContrato;
        
        return mapGrupoContrato;
    }
    // PLV-2312-28 FIM Refactory na emissao de contrato
    // PLV-2312-28 INICIO Refactory na emissao de contrato
    private static Map<Id, ContratanteContrato__c> gerarHierarquiaContratantesContrato(Quote proposta, Contract contrato, Map<Id, ContratanteContrato__c> mapContratanteContrato) {
        
        // Instancias
        List<ContratanteContrato__c> listContratanteContrato = new List<ContratanteContrato__c>();
        List<GarantiaContratanteContrato__c> listGarantiaContratanteContrato = new List<GarantiaContratanteContrato__c>();
        
        // Busca os contratantes da proposta
        List<ContratanteProposta__c> listContratanteProposta = QuoteDAO.getInstance().buscarContratantesPropostaByQuote(new Set<Id>{proposta.Id});
        
        // Gera o contratante a partir do contratante da proposta
        for (ContratanteProposta__c contratanteProposta : listContratanteProposta){
            ContratanteContrato__c contratanteContrato = gerarContratanteContrato(contrato, contratanteProposta);
            listContratanteContrato.add(contratanteContrato);
            mapContratanteContrato.put(contratanteProposta.Id, contratanteContrato);
        }
        System.debug('Grava Contratantes do Contrato');
        insert listContratanteContrato;
        
        // Geracao de filhos do contratante do contrato
        for(ContratanteProposta__c contratanteProposta : listContratanteProposta) {
            //====> Garantia do Contratante do Contrato
            listGarantiaContratanteContrato = gerarGarantiasContratanteContrato(contratanteProposta, listGarantiaContratanteContrato, mapContratanteContrato);
        }
        
        // Gravacao dos filhos do contratante do contrato
        System.debug('Grava Garantia Contratante do Contrato');
        insert listGarantiaContratanteContrato;
        
        return  mapContratanteContrato;
    }
    // PLV-2312-28 FIM Refactory na emissao de contrato
    // PLV-2312-28 INICIO Refactory na emissao de contrato
    private static ContratanteContrato__c gerarContratanteContrato(Contract contrato, ContratanteProposta__c contratanteProposta){
        
        ContratanteContrato__c contratanteContrato = new ContratanteContrato__c();
        
        contratanteContrato.Contrato__c = contrato.Id;
        contratanteContrato.Bairro__c = contratanteProposta.Bairro__c;
        contratanteContrato.BairroCorrespondencia__c = contratanteProposta.BairroCorrespondencia__c;
        contratanteContrato.Cep__c = contratanteProposta.Cep__c;
        contratanteContrato.CEPCorrespondencia__c = contratanteProposta.CEPCorrespondencia__c;
        contratanteContrato.Cidade__c = contratanteProposta.Cidade__c;
        contratanteContrato.CidadeCorrespondencia__c = contratanteProposta.CidadeCorrespondencia__c;
        contratanteContrato.Complemento__c = contratanteProposta.Complemento__c;
        contratanteContrato.ComplementoCorrespondencia__c = contratanteProposta.ComplementoCorrespondencia__c;
        contratanteContrato.Conta__c = contratanteProposta.Conta__c;
        contratanteContrato.CpfCnpj__c = contratanteProposta.Conta__r.Recordtype.DeveloperName == 'PessoaJuridica' ? contratanteProposta.Conta__r.Cnpj__c : contratanteProposta.Conta__r.Cpf__c; //PLV-4813 INICIO/FIM
        contratanteContrato.EnderecoBoleto__c = contratanteProposta.EnderecoBoleto__c;
        contratanteContrato.Estado__c = contratanteProposta.Estado__c;
        contratanteContrato.EstadoCorrespondencia__c = contratanteProposta.EstadoCorrespondencia__c;
        System.debug('4588>>5 ');
        contratanteContrato.FormaInfoCartao__c = contratanteProposta.FormaInfoCartao__c; // RVI-248 - INICIO/FIM
        System.debug('contratanteContrato.FormaPagamento__c' + contratanteContrato.FormaPagamento__c);
        contratanteContrato.FormaPagamento__c = contratanteProposta.FormaPagamento__c;
        contratanteContrato.Logradouro__c = contratanteProposta.Logradouro__c;
        contratanteContrato.LogradouroCorrespondencia__c = contratanteProposta.LogradouroCorrespondencia__c;
        contratanteContrato.NumeroCorrespondencia__c = contratanteProposta.NumeroCorrespondencia__c;
        contratanteContrato.NumeroEndereco__c = contratanteProposta.NumeroEndereco__c;
        contratanteContrato.Numero__c = contratanteProposta.Numero__c;
        contratanteContrato.Pais__c = contratanteProposta.Pais__c;
        contratanteContrato.PaisCorrespondencia__c = contratanteProposta.PaisCorrespondencia__c;
        contratanteContrato.QuantidadeParcelas__c = contratanteProposta.QuantidadeParcelas__c;
        //PLV-4441 - INICIO - PEDRO AUGUSTO BRAZ
        contratanteContrato.VigenciaInicial__c = contratanteProposta.VigenciaInicial__c;
        //PLV-4441 - FIM - PEDRO AUGUSTO BRAZ
        contratanteContrato.VencimentoDemaisParcelas__c = contratanteProposta.VencimentoDemaisParcelas__c; //PLV-4438 - Inicio/Fim
        // TKCL-473 INICIO
        System.debug('Giordano....dadosProposta-recorrencia'+contratanteProposta.Recorrencia__c);
        System.debug('Giordano....dadosProposta-valorprimeira'+contratanteProposta.Valor_PrimeiraParcela__c);
        System.debug('Giordano....dadosProposta-valordemais'+contratanteProposta.Valor_DemaisParcelas__c);
        contratanteContrato.Recorrencia__c = contratanteProposta.Recorrencia__c;
        contratanteContrato.Valor_PrimeiraParcela__c = contratanteProposta.Valor_PrimeiraParcela__c;
        contratanteContrato.Valor_DemaisParcelas__c = contratanteProposta.Valor_DemaisParcelas__c;
        // TKCL-473 FIM
        contratanteContrato.ResponsavelPagamento__c = contratanteProposta.ResponsavelPagamento__c;
        contratanteContrato.Tipo__c = contratanteProposta.Tipo__c;
        contratanteContrato.TipoEndereco__c = contratanteProposta.TipoEndereco__c;
        contratanteContrato.TipoEnderecoCorrespondencia__c = contratanteProposta.TipoEnderecoCorrespondencia__c;
        contratanteContrato.TipoLogradouro__c = contratanteProposta.TipoLogradouro__c;
        contratanteContrato.TipoLogradouroCorrespondencia__c = contratanteProposta.TipoLogradouroCorrespondencia__c;
        contratanteContrato.TipoResponsavelPagamento__c = contratanteProposta.TipoResponsavelPagamento__c;
        contratanteContrato.VencimentoPrimeiraParcela__c = contratanteProposta.VencimentoPrimeiraParcela__c;
        contratanteContrato.IOF__c = contratanteProposta.IOF__c;
        contratanteContrato.PremioComercial__c = contratanteProposta.PremioComercial__c;
        contratanteContrato.PremioParcela__c = contratanteProposta.PremioParcela__c;
        contratanteContrato.PorcentagemParticipacaoVida__c = contratanteProposta.PorcentagemParticipacaoVida__c;
        contratanteContrato.Reenquadramento__c = contratanteProposta.Reenquadramento__c;
        contratanteContrato.IPCA__c = contratanteProposta.IPCA__c;
        contratanteContrato.PorcentagemParticipacaoSegurado__c = contratanteProposta.PorcentagemParticipacaoSegurado__c;
        contratanteContrato.InformacaoBancaria__c = contratanteProposta.InformacaoBancaria__c;
        contratanteContrato.PlanoParcelamento__c = contratanteProposta.PlanoParcelamento__c;
        contratanteContrato.CartaoCredito__c = contratanteProposta.CartaoCredito__c;
        contratanteContrato.TipoCusteio__c = contratanteProposta.TipoCusteio__c;
        
        //objContratanteContrato.Juros__c                = contratanteProp.Juros__c;
        contratanteContrato.IOF__c = contratanteProposta.IOF__c;
        //objContratanteContrato.Encargos__c             = contratanteProp.Encargos__c;
        //objContratanteContrato.CustoApolice__c         = contratanteProp.CustoApolice__c;
        contratanteContrato.PremioIntegral__c = contratanteProposta.PremioIntegral__c; //PLV-5351 INICIO/FIM
        contratanteContrato.PremioComercial__c = contratanteProposta.PremioComercial__c;
        contratanteContrato.PremioPuro__c = contratanteProposta.PremioPuro__c;
        contratanteContrato.PremioTotal__c = contratanteProposta.PremioTotal__c;
        contratanteContrato.TaxaComercial__c = contratanteProposta.TaxaComercial__c;
        contratanteContrato.TaxaPura__c = contratanteProposta.TaxaPura__c;
        contratanteContrato.TaxaTotal__c = contratanteProposta.TaxaTotal__c;
        
        contratanteContrato.DescontoAgravoPercentualTecnico__c = contratanteProposta.DescontoAgravoPercentualTecnico__c;
        contratanteContrato.DescontoAgravoMonetarioTecnico__c = contratanteProposta.DescontoAgravoMonetarioTecnico__c;
        contratanteContrato.DescontoAgravoPercentualComercial__c = contratanteProposta.DescontoAgravoPercentualComercial__c;
        contratanteContrato.DescontoAgravoMonetarioComercial__c = contratanteProposta.DescontoAgravoMonetarioComercial__c;
        contratanteContrato.DescontoAgravoPercentualInformado__c = contratanteProposta.DescontoAgravoPercentualInformado__c;
        contratanteContrato.DescontoAgravoMonetarioInformado__c = contratanteProposta.DescontoAgravoMonetarioInformado__c;
        contratanteContrato.DescontoAgravoPercentualFormaPagto__c = contratanteProposta.DescontoAgravoPercentualFormaPagto__c;//PLV-4701 - INICIO/FIM
        contratanteContrato.DescontoAgravoMonetarioFormaPagto__c = contratanteProposta.DescontoAgravoMonetarioFormaPagto__c;//PLV-4701 - INICIO/FIM
        contratanteContrato.IOF__c = contratanteProposta.IOF__c;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B

        //PLV - 4690 - INICIO -  GUSTAVO DA SILVA PEREIRA SYS4B
        contratanteContrato.NomeContratante__c = contratanteProposta.Nome_do_segurado__c;
        contratanteContrato.Nome__c = contratanteProposta.Nome_do_segurado__c; //PLV-4813 INICIO/FIM
        contratanteContrato.NomeSocial_do_Contratante__c = contratanteProposta.NomeSocial_do_Segurado__c; // LECVPV-184 INICIO/FIM
        contratanteContrato.Email__c = contratanteProposta.Email__c;
        contratanteContrato.Celular__c = contratanteProposta.Celular__c;
        contratanteContrato.Telefone__c = contratanteProposta.Telefone__c;
        contratanteContrato.TelefoneOutro__c = contratanteProposta.Telefone_Outro__c;
        contratanteContrato.FormaReceberApolice__c = contratanteProposta.Forma_de_receber_apolice__c;
        //PLV - 4690 - FIM -  GUSTAVO DA SILVA PEREIRA SYS4B


        return contratanteContrato;
    }
    // PLV-2312-28 FIM Refactory na emissao de contrato
    // PLV-2312-28 INICIO Refactory na emissao de contrato
    private static Contract gerarHierarquiaContrato(Quote proposta, ServiceTO.ContratoTO contratoTO, Map<String, ParametroVigencia__c> mapParametroVigenciaProduto) { //RVI-79 - INICIO/FIM
        system.debug('Gerar hierarquia contrato'+contratoTO);
        //Instancias
        Contract contrato = new Contract();
        GarantiaProposta__c garantiaPropostaPrioritaria;
        //====> Listas
        List<GarantiaContrato__c> listGarantiaContrato = new List<GarantiaContrato__c>();
        List<RemuneracaoContrato__c> listRemuneracaoContrato = new List<RemuneracaoContrato__c>();
        List<CriticaContrato__c> listCriticaContrato = new List<CriticaContrato__c>();
        List<FavorecidoRemuneracaoContrato__c> listFavorecidosContrato = new List<FavorecidoRemuneracaoContrato__c>();
        //====> Maps
        Map<Id, RemuneracaoContrato__c> mapRemuneracaoContratoPorRemuneracaoPropostaId = new Map<Id, RemuneracaoContrato__c>();
        System.debug('carlos proposta: ' + proposta);
        // PLV-2605 INICIO
        // Verifica se existia um contrato sendo elaborado anteriormente para recuperar as informacoes
        // PLV-4488 INICIO
        List<Contract> listOldContract = new List<Contract>();
        List<String> listSiglaTipoEndosso = new List<String>();
        // PLV-4488 FIM
        if(contratoTO != null){
            // Complementa o numero de apolice com zeros a esquerda
           
            String numeroApolice = contratoTO.contrato.numeroApolice.leftPad(9, '0');
            contrato.NumeroApolice__c = numeroApolice;
           //PORUVER - INICIO
           //PORUVER - FIM
            contrato.Name = ContractBO.getInstance().gerarNameContrato(String.valueOf(contratoTO.contrato.codigoEmpresa), String.valueOf(contratoTO.contrato.codigoSucursal), proposta.RamoSeguro__r.Codigo__c, numeroApolice, String.valueOf(contratoTO.contrato.numeroEndosso));
            contrato.IdExterno__c = ContractBO.getInstance().gerarNameContrato(String.valueOf(contratoTO.contrato.codigoEmpresa), String.valueOf(contratoTO.contrato.codigoSucursal), proposta.RamoSeguro__r.Codigo__c, numeroApolice, String.valueOf(contratoTO.contrato.numeroEndosso));
        }else{
            // Gera um name temporário
            contrato.Name = 'Contrato em elaboração ' + proposta.Origem__c + '-' + proposta.NumeroProposta__c;
            contrato.IdExterno__c = 'Contrato em elaboração ' + proposta.Origem__c + '-' + proposta.NumeroProposta__c;
        }
        // PLV-4488 INICIO
        if(proposta.Tipo__c == 'Endosso'){
               
            listOldContract = [SELECT Id, Status, VigenciaFinal__c, DataEndosso__c, TipoContrato__c, SiglaTipoEndosso__c, NumeroApolice__c, RamoSeguro__r.Codigo__c, Endosso__c, Sucursal__c, Empresa__c FROM Contract WHERE Id =: proposta.ContractId]; //INICIO/FIM - PLV-4686 - Guilherme Brito
            System.debug('old contract ' + listOldContract);
            if(proposta != null && proposta.SiglaTipoEndosso__c != null)
                listSiglaTipoEndosso = proposta.SiglaTipoEndosso__c.split(';');

            // PLV-4488 INICIO FIX  //PLV-5066 - INICIO - YURI
            Boolean siglaCAD = false;
            if(listSiglaTipoEndosso != null && listSiglaTipoEndosso.size() > 0){
                siglaCAD = true;
                for(String sigla : listSiglaTipoEndosso){
                    if(sigla != 'BEN' && sigla != 'CAD') siglaCAD = false;
                }          
            }
            // PLV-4488 FIM FIX  //PLV-5066 - FIM - YURI 

            if(!siglaCad){
                // PLV-4488 INICIO FIX
                Integer numeroEndosso = Integer.valueOf(listOldContract[0].Endosso__c);
                List<String> listNameContract = new List<String>();
                while(numeroEndosso >= 0){
                    String nameContract = ContractBO.getInstance().gerarNameContrato(String.valueOf(listOldContract[0].Empresa__c), String.valueOf(listOldContract[0].Sucursal__c), listOldContract[0].RamoSeguro__r.Codigo__c, listOldContract[0].NumeroApolice__c, String.valueOf(numeroEndosso));
                    listNameContract.add(nameContract);
                    numeroEndosso--;
                }
                List<Contract> listContractOldUpdate = new List<Contract>();
                //INICIO - PLV-4686 - Guilherme Brito
                for(Contract con : [SELECT Id, Status, DataEndosso__c FROM Contract WHERE Name IN: listNameContract AND Status = 'Emitido']){
                    con.Status = 'Alterado';
                    // AJUSTAR QUANDO CRIAR O CAMPO DE DATA DE VIGENCIA EM TELA NO PROCESSO DE ENDOSSO
                    con.DataEndosso__c = listOldContract[0].DataEndosso__c;
                    listContractOldUpdate.add(con);
                }
                 //FIM - PLV-4686 - Guilherme Brito
                update listContractOldUpdate;
                // PLV-4488 FIM FIX
            }

            contrato.Name  = ContractBO.getInstance().gerarNameContrato(String.valueOf(listOldContract[0].Empresa__c), String.valueOf(listOldContract[0].Sucursal__c), listOldContract[0].RamoSeguro__r.Codigo__c, listOldContract[0].NumeroApolice__c, String.valueOf(Decimal.valueOf(listOldContract[0].Endosso__c) + 1));
            contrato.IdExterno__c = contrato.Name;
            contrato.NumeroApolice__c    = listOldContract[0].NumeroApolice__c;
            contrato.email__c = proposta.Account.PersonEmail; //PLV-4587 FIX 2
            contrato.Nome_Social__c = proposta.Account.NomeSocial__c;  // LECVPV-184 INICIO/FIM
            contrato.SiglaTipoEndosso__c = proposta.SiglaTipoEndosso__c;
            List<Id> listIdProposta = new List<Id>();
            listIdProposta.add(proposta.Id);
            gerarPDFProposta(listIdProposta);
            
        }
        // PLV-4488 FIM

        // PLV-2605 FIM
        // PLV-2508 FIM
        
        
        // Busca as remuneracoes do contrato e seus filhos
        List<RemuneracaoProposta__c> listRemuneracaoProposta = QuoteDAO.getInstance().buscarRemuneracaoProposta(new Set<Id>{proposta.Id});
        
        contrato.Seguradora__c = proposta.Produto__r.Empresa__c;
        if (String.isNotBlank(proposta.Parceiro__c)) contrato.Parceria__c = ParceiroDAO.getInstance().obtemParceiro(proposta.Parceiro__c).Id;
        // PLV-2486 INICIO
        contrato.NumeroPropostaUnico__c = proposta.NumeroPropostaUnico__c;
        // PLV-2486 FIM
        contrato.CodigoRamo__c = proposta.RamoSeguro__r.Codigo__c;
        contrato.Nome_Social__c = proposta.NomeSocial__c;  // LECVPV-184 INICIO/FIM
        contrato.CanalDistribuicao__c = proposta.CanalDistribuicao__c;
        contrato.AccountId = proposta.AccountId;
        contrato.RamoSeguro__c = proposta.RamoSeguro__c;
        contrato.RecordType = proposta.RecordType;
        contrato.CodigoCorretor__c = proposta.CodigoCorretor__c;
        contrato.Description = proposta.Description;
        contrato.FormaPagamento__c = proposta.FormaPagamento__c;
        contrato.Oportunidade__c = proposta.OpportunityId;
        contrato.Produto__c = proposta.Produto__c;
        contrato.Proposta__c = proposta.Id;
        contrato.Status = 'Em elaboração';    // Status será substituído no final do processo se tudo for executado ok
        contrato.Tipo__c = proposta.Tipo__c;
        contrato.DataEmissao__c = System.today();
        contrato.IdContratoParceiro__c = proposta.IdContratoParceiro__c;
        contrato.IdContratanteParceiro__c = proposta.IdContratanteParceiro__c;
        contrato.Parceiro__c = proposta.Parceiro__c;
        contrato.Payload__c = proposta.Payload__c;
        //INICIO - PLV-4686 - Guilherme Brito
        if(proposta.DataEndosso__c != null){
            contrato.DataEndosso__c = date.valueOf(proposta.DataEndosso__c);
        }
        // PLV-4666 - INICIO
        contrato.Tarifa__c = proposta.Tarifa__c;
        contrato.DLL__c = proposta.DLL__c;
        // PLV-4666 - FIM
        //FIM - PLV-4686 - Guilherme Brito
        // PLV-4488 INICIO
        if(listOldContract != null && listOldContract.size() > 0 && listSiglaTipoEndosso.size() > 0 && proposta.Produto__r.Segmento__c == 'Individual'){ //PLV-4684 INICIO/FIM
            Contract oldContract = listOldContract[0];
            contrato.VigenciaFinal__c = oldContract.VigenciaFinal__c;
            //INICIO - PLV-4686 - Guilherme Brito
            contrato.DataEndosso__c = oldContract.DataEndosso__c;
            contrato.StartDate = oldContract.DataEndosso__c;
            //FIM - PLV-4686 - Guilherme Brito
        }else{
            contrato.StartDate = proposta.VigenciaInicial__c;
            contrato.VigenciaFinal__c = proposta.VigenciaFinal__c;
        }
        contrato.VigenciaFinalAlterada__c = proposta.VigenciaFinalAlterada__c; //PLV-4684 INICIO/FIM
        // PLV-4488 FIM
        contrato.MeioComercializacao__c = proposta.MeioComercializacao__c;
        contrato.PremioIntegral__c = proposta.PremioIntegral__c; //PLV-5351 INICIO/FIM
        contrato.PremioComercial__c = proposta.PremioComercial__c;
        contrato.PremioPuro__c = proposta.PremioPuro__c;
        contrato.PremioTotal__c = proposta.PremioTotal__c;
        // PLV-2566 INICIO
        contrato.ContratoOriginal__c = proposta.ContractId;
        // PLV-2566 FIM
        contrato.TaxaComercial__c = proposta.TaxaComercial__c;
        contrato.TaxaPura__c = proposta.TaxaPura__c;
        contrato.TaxaTotal__c = proposta.TaxaTotal__c;
        //PLV-2932 - Inicio - Gravar modalidade no contrato
        //contrato.ModalidadeSeguro__c = proposta.Modalidade__c;
        //PLV-2932 - Fim - Gravar modalidade no contrato
        contrato.Origem__c = proposta.Origem__c;
        contrato.TipoEndosso__c = proposta.TipoEndosso__c;
        // Campo para controle do processo de entrada do contrato, se via massificados ou nao
        contrato.Massificados__c = proposta.Massificados__c;
        //PLV-3392-FIX2 - INICIO - Inclusao do campo Valor IOF

        //PLV-4441 - INICIO - Pedro Augusto Braz - SYS4B
        
        contrato.FormaReceberApolice__c = proposta.FormaReceberApolice__c;
        contrato.TermoGuarda__c = proposta.TermoGuarda__c;
        contrato.TermoResponsabilidade__c   = proposta.TermoResponsabilidade__c;
        contrato.AssinaturaEletronica__c    = proposta.AssinaturaEletronica__c;
        contrato.PorQuantoTempoQuerGarantirRenda__c = proposta.PorQuantoTempoQuerGarantirRenda__c;
        contrato.DependentesFinanceiros__c = proposta.DependentesFinanceiros__c;
        // PLV-4488 INICIO
        if(listOldContract != null && listOldContract.size() > 0){
            contrato.TipoContrato__c = listOldContract[0].TipoContrato__c;
        }else{
            contrato.TipoContrato__c = proposta.TipoContrato__c;
        }
        // PLV-4488 FIM
        
        //PLV-4441 - FIM - Pedro Augusto Braz - SYS4B

        contrato.ScoreFraude__c = proposta.ScoreFraude__c; // PLV-4416 INICIO - FIM 
        contrato.ScoreSerasa__c = proposta.ScoreSerasa__c;//PLV - 4388 - INICIO/FIM - Gustavo Pereira SYS4b
        if(!contrato.Massificados__c){
            List<ContratanteProposta__c> lstContProp = [SELECT IOF__c 
                                                        FROM ContratanteProposta__c 
                                                        WHERE Proposta__c = :contrato.Proposta__c LIMIT 1];
            if(!lstContProp.isEmpty()){
                contrato.ValorIOF__c = lstContProp[0].IOF__c;
            }
            //PLV-4101 - INICIO
            SeguradoProposta__c objContaSeguro = [SELECT Conta__r.Name, Conta__r.Id, GrupoProposta__r.Id, GrupoProposta__r.ContratanteProposta__r.Proposta__c
      									FROM SeguradoProposta__c
     								  WHERE GrupoProposta__r.ContratanteProposta__r.Proposta__c  =: contrato.Proposta__c  limit 1];

			system.debug('PLV-4101 - objContaSeguro.Conta__c'+objContaSeguro);
            contrato.AccountId = objContaSeguro.Conta__r.Id;
            //PLV-4101 - FIM
        }
        //PLV-3392-FIX2 - FIM
        //PLV-3888 - FIX1 - INICIO
        system.debug('Chave_de_Agrupamento__c'+proposta.Chave_de_Agrupamento__c);
		contrato.Chave_de_Agrupamento__c = proposta.Chave_de_Agrupamento__c;
		//PLV-3888 - FIX1 - FIM
        contrato.EntradaNegocio__c = proposta.EntradaNegocio__c;
        //-- PLV2168 - gravar numero proposta/origem no contrato
        contrato.NumeroProposta__c = proposta.NumeroProposta__c;
        contrato.DescontoAgravoPercentualTecnico__c = proposta.DescontoAgravoPercentualTecnico__c;
        contrato.DescontoAgravoMonetarioTecnico__c = proposta.DescontoAgravoMonetarioTecnico__c;
        contrato.DescontoAgravoPercentualComercial__c = proposta.DescontoAgravoPercentualComercial__c;
        contrato.DescontoAgravoMonetarioComercial__c = proposta.DescontoAgravoMonetarioComercial__c;
        contrato.DescontoAgravoPercentualInformado__c = proposta.DescontoAgravoPercentualInformado__c;
        contrato.DescontoAgravoMonetarioInformado__c = proposta.DescontoAgravoMonetarioInformado__c;
        // PLV-3362 INICIO
        contrato.TipoViagem__c = proposta.TipoViagem__c;
        contrato.QuantidadePassageiros070Anos__c = proposta.QuantidadePassageiros070Anos__c;
        contrato.ViagemAventura__c = proposta.ViagemAventura__c;
        contrato.UtilizaMoto__c = proposta.UtilizaMoto__c; 
        //PLV-3879 - INICIO
        contrato.PaisesDestino__c = proposta.PaisesDestino__c;
        //PLV-3879 - FIM
        contrato.VidasEntre7190Anos__c = proposta.VidasEntre7190Anos__c;
        contrato.IncluiPaisEuropeu__c = proposta.IncluiPaisEuropeu__c;
        // PLv-3362 FIM
        // PLV-2146 - INÍCIO
        contrato.DescontoAgravoPercentualFormaPagto__c = proposta.DescontoAgravoPercentualFormaPagto__c;
        contrato.DescontoAgravoMonetarioFormaPagto__c = proposta.DescontoAgravoMonetarioFormaPagto__c;
        contrato.DescontoAgravoPercentualParcelamento__c = proposta.DescontoAgravoPercentualParcelamento__c;
        contrato.DescontoAgravoMonetarioParcelamento__c = proposta.DescontoAgravoMonetarioParcelamento__c;
        // PLV-2146 - FIM
        
        // AV-664 INICIO 
        contrato.CupomDesconto__c = proposta.CupomDesconto__c; 
        // AV-664 FIM 
        
        // PLV-2509-30 INICIO
        // Preenchimento da modalidade prioritaria do seguro
        garantiaPropostaPrioritaria = verificarGarantiaPropostaPrioritaria(proposta.GarantiasProposta__r);
        if(garantiaPropostaPrioritaria != null){
            contrato.ModalidadeSeguro__c = garantiaPropostaPrioritaria.GarantiaProduto__r.Modalidade__c;
        }
        // PLV-2509-30 FIM
        
        // PLV-2605 INICIO
        contrato.Empresa__c = proposta.Produto__r.Empresa__r.CodigoEmpresa__c;
        contrato.Sucursal__c = buscarSucursal(listRemuneracaoProposta);

        // PLV-4488 - INICIO
        if(listOldContract != null && listOldContract.size() > 0){
            contrato.Endosso__c = String.valueOf(Decimal.valueOf(listOldContract[0].Endosso__c) + 1);
        }else{
            contrato.Endosso__c = definirEndosso(contrato);
        }
        // PLV-4488 - FIM
        //PLV-4488
        if(contrato.Tipo__c == 'Cancelamento'){
            //PLV-4695-FIX6-INICIO
            system.debug('contrato original:'+proposta.ContractId);
             // PLV-4660 - INICIO
             Contract contratoOrigi =  [SELECT Endosso__c, Empresa__c, Sucursal__c, NumeroApolice__c, CodigoRamo__c FROM Contract WHERE Id =: proposta.ContractId]; //PLV-5147 - FIX01 - INICIO/FIM

             //PLV-5147 - INICIO
             AggregateResult aggEndossosContrato = [
                SELECT 
                    MAX(Endosso__c) UltimoEndosso
                FROM Contract 
                WHERE 
                    NumeroApolice__c =: contratoOrigi.NumeroApolice__c
                    AND Empresa__c =: contratoOrigi.Empresa__c
                    AND Sucursal__c =: contratoOrigi.Sucursal__c
                    AND CodigoRamo__c =: contratoOrigi.CodigoRamo__c 
            ];

             Integer numeroEndosso = Integer.valueOf(aggEndossosContrato.get('UltimoEndosso'));
             if (numeroEndosso == null) {
                numeroEndosso = 1;
             } else {
                numeroEndosso = numeroEndosso + 1;
             }

             contrato.NumeroApolice__c = proposta.Contract.NumeroApolice__c;
             String name = ContractBO.getInstance().gerarNameContrato(contratoOrigi.Empresa__c, contratoOrigi.Sucursal__c, proposta.RamoSeguro__r.Codigo__c, contratoOrigi.NumeroApolice__c, String.valueOf(numeroEndosso));
             //PLV-5147 - FIM

             // PLV-4660 - FIM
            contrato.Name = name;
            contrato.IdExterno__c = name;
            system.debug('trata idExterno Cancelamento:'+name);
            //PLV-4695-FIX6 - FIM
        }
        // PLV-2605 FIM

        //RVI-79 - INICIO
        ParametroVigencia__c parametroVigenciaProduto = mapParametroVigenciaProduto.get(contrato.Produto__c);
        if(parametroVigenciaProduto.ProdutoRenovavel__c){
            contrato.DataRenovacao__c = contrato.VigenciaFinal__c - parametroVigenciaProduto.VigenciaMinimaRenovacao__c.intValue();
            contrato.StatusRenovacao__c = 'Não Renovado';            
        }
        //RVI-79 - FIM

        //POR010 - INICIO
        if(contrato.Tipo__c == 'Endosso' || contrato.Tipo__c == 'Cancelamento'){
            Contract contratoOriginal = [
                    select Id, Sucursal__c from Contract where Id = :contrato.ContratoOriginal__c order by ContractNumber
                ];

                if(contratoOriginal != null){
                    contrato.Sucursal__c = contratoOriginal.Sucursal__c;
                }
        }
        //POR010 - FIM
                
        insert contrato;
        
        // Geracao de filhos do contrato
        //====> Garantia do Contrato
        listGarantiaContrato = gerarGarantiasContrato(proposta, contrato, listGarantiaContrato);
        //====> Remuneração do Contrato
        listRemuneracaoContrato = gerarRemuneracoesContrato(contrato, listRemuneracaoProposta, listRemuneracaoContrato, mapRemuneracaoContratoPorRemuneracaoPropostaId);
        //====> Critica do Contrato
        listCriticaContrato = gerarCriticasContrato(proposta, contrato, listCriticaContrato);
        
        // Gravacao dos filhos do contrato
        insert listGarantiaContrato;
        insert listCriticaContrato;
        insert listRemuneracaoContrato;
        
        // Gravacao dos netos do contrato
        // Geracao dos filhos da remuneração do contrato
        //====> Favorecido da remuneração do contrato
        listFavorecidosContrato = gerarFavorecidosRemuneracaoContrato(listRemuneracaoProposta, listFavorecidosContrato, mapRemuneracaoContratoPorRemuneracaoPropostaId);
        
        // Gravacao dos filhos da remuneração do contrato
        insert listFavorecidosContrato;
        
        // INICIO | PLV-1879-28
        // Atualizacoes no contrato
        if(garantiaPropostaPrioritaria != null){
            contrato.ModalidadeSeguro__c = garantiaPropostaPrioritaria.GarantiaProduto__r.Modalidade__c;
            update contrato;
        }
        // FIM | PLV-1879-28
        
        return contrato;
    }
    // PLV-2312-28 FIM Refactory na emissao de contrato
    // PLV-2605 INICIO
    //II-155 INICIO
    public static String definirEndosso(Contract contrato){
        //RVI-227 INICIO
        System.debug('definirEndosso contrato>> ' + contrato);
        Integer endosso;
        //RVI-251 INICIO
        String numeroApolice;
        //II-155 FIX01 INICIO
        list<contract> numApolice = new List<contract>();
        if(contrato.ContratoOriginal__c != null){
            numApolice = [SELECT NumeroApolice__c FROM Contract WHERE ContratoOriginal__c = :contrato.ContratoOriginal__c];
        }
        //II-155 FIX01 FIM
        if(!numApolice.isEmpty()){
            numeroApolice = numApolice[0].NumeroApolice__c;
        } //RVI-251 FIM
                // Verifica o tipo do contrato para determinar o numero do endosso
        if((contrato.Tipo__c == 'Novo' || contrato.Tipo__c == 'Renovacao')){//RVI-138 - INICIO/FIM
            endosso = 0;
        }else {
            System.debug('numApolice ++++' + numApolice);
            System.debug('contrato.CodigoRamo__c ISA ' + contrato.CodigoRamo__c);
            ContractBO.RetornoDadosEndossoTO dadosEndossoTO = ContractBO.getInstance().buscarUltimoEndossoApolice(
                contrato.Empresa__c,
                contrato.Sucursal__c,
                contrato.CodigoRamo__c, //PLV-3460 Fix 5 - INICIO/FIM
                //contrato.NumeroApolice__c
                //numApolice.NumeroApolice__c
                numeroApolice//RVI-251 INICIO/FIM
            );

            endosso = dadosEndossoTO.numeroEndosso;
            System.debug('definirEndosso endosso 1 >> ' + endosso);
            if(dadosEndossoTO.objContrato.Tipo__c == 'Cancelamento'){
                endosso++;
            }
            System.debug('definirEndosso endosso 2>> ' + endosso);
        }
        
        return String.valueOf(endosso);
        //RVI-227 FIM
    }
    // PLV-2605 FIM
    //II-155 INICIO
    
    /*
public static String BuscarRamoSeguro(Id idProduto)
{
String codigo = '0';

Product2 prod = ProductDAO.getInstance().buscarProdutoGarantiasPorProduto(idProduto);

if(prod.garantiasproduto__r.size() > 0)
{
codigo = prod.garantiasproduto__r[0].RamoSeguro__r.Codigo__c;
}

return codigo;
}
*/
    
    // PLV-2605 INICIO
    public static String buscarSucursal(List<RemuneracaoProposta__c> listRemuneracaoProposta){
        
        String codigoSucursal;
        for(RemuneracaoProposta__c remuneracaoProposta : listRemuneracaoProposta) {
            for(FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta : remuneracaoProposta.FavorecidosRemuneracaodaProposta__r)
            {
                if(favorecidoRemuneracaoProposta.CorretorLider__c)
                    codigoSucursal = favorecidoRemuneracaoProposta.DadosCorretor__r.CodigoSucursalVinculo__c;
            }
        }
        
        return codigoSucursal;
    }
    // PLV-2605 FIM
    
    
    /*
public static String BuscarRamoSeguro(Id idProduto)
{
String codigo = '0';

Product2 prod = ProductDAO.getInstance().buscarProdutoGarantiasPorProduto(idProduto);

if(prod.garantiasproduto__r.size() > 0)
{
codigo = prod.garantiasproduto__r[0].RamoSeguro__r.Codigo__c;
}

return codigo;
}
*/
    
    // PLV-2312 INICIO
    public Boolean verificarPropostasMassificados(){
        List<Quote> listPropostas = dao.verificarPropostasMassificados();
        if(listPropostas.isEmpty()){
            return false;
        }
        return true;
    }
    // PLV-2312 FIM
    
    
    public Id BuscarRamoSeguro(Set<Id> idProduto)
    {
        List<GarantiaProduto__c> lstGarantiasProdutoProposta = GarantiaProdutoDAO.getInstance().buscarGarantiasProdutoPorProdutoId(idProduto);
        system.debug('QuoteBO >> BuscarRamoSeguro >> Lista: ' + lstGarantiasProdutoProposta);
        Id retorno = null;
        Decimal prioridade = 99999;
        
        for(GarantiaProduto__c garantiaProd : lstGarantiasProdutoProposta)
        {
            system.debug('QuoteBO >> BuscarRamoSeguro >> prioridade: ' + prioridade);
            system.debug('QuoteBO >> BuscarRamoSeguro >> OrdemPrioridade__c: ' + garantiaProd.OrdemPrioridade__c);
            if(prioridade > garantiaProd.OrdemPrioridade__c)
            {
                retorno    = garantiaProd.RamoSeguro__r.Id;
                prioridade = garantiaProd.OrdemPrioridade__c;
            }
        }
        
        return retorno;
    }
    
    //PLV-4871 - INICIO
    public void atualizarVigencia(List<Quote> listQuoteNew, Map<Id, Quote> mapQuoteOld){
        System.debug('Atualizando vigencia: Renovação');
        //PLV-4871 - FIX - INICIO 
        for(Quote proposta: listQuoteNew){
            if(proposta.Segmento__c == 'Individual' && proposta.Tipo__c == 'Novo'  && proposta.Status == 'Disponível para contratação' && mapQuoteOld.get(proposta.Id).Status != proposta.Status){ //PLV-4871 - FIX - FIM //RVI-138 //RVI-160 - INICIO/FIM
                System.debug('(PLV-4871) Objeto novo: ' + proposta);
                calcularVigencia(proposta);
            } 
            else if(proposta.Segmento__c == 'Individual' && proposta.Tipo__c == 'Renovacao' && proposta.Status == 'Disponível para contratação' && mapQuoteOld.get(proposta.Id).Status != proposta.Status){ //RVI-160 - FIX 01
                System.debug('(RVI-160) Objeto renovacao: ' + proposta);
                calcularVigenciaRenovacao(proposta, mapQuoteOld.get(proposta.Id));
            }
        }    
    }
    //PLV-4871 - FIM

    //PLV-4871 - INICIO
    @TestVisible //PLV-5231- INICIO/FIM
    private void calcularVigencia(Quote proposta){
        proposta.DataEmissao__c = System.today();
        Integer days = proposta.VigenciaInicial__c.daysBetween(proposta.VigenciaFinal__c);
        proposta.VigenciaInicial__c = proposta.DataEmissao__c;
        System.debug('(PLV-5231) Vigencia inicial: ' + proposta.VigenciaInicial__c);
        proposta.VigenciaFinal__c = proposta.VigenciaInicial__c.addDays(days);
        System.debug('(PLV-5231) Vigencia final: ' + proposta.vigenciaFinal__c);
    }
    //PLV-4871 - FIM

    //RVI-160 - INICIO
    @TestVisible //PLV-5231- INICIO/FIM
    private void calcularVigenciaRenovacao(Quote proposta, Quote QuoteOld){
        //proposta.DataEmissao__c = System.today();
        proposta.VigenciaInicial__c = QuoteOld.vigenciaFinal__c.addDays(1).addYears(-1);
        System.debug('(RVI-160) Vigencia inicial: ' + proposta.VigenciaInicial__c);
        proposta.VigenciaFinal__c = proposta.VigenciaInicial__c.addYears(1).addDays(-1);
        System.debug('(RVI-160) Vigencia final: ' + proposta.VigenciaFinal__c);
    }
    //RVI-160 - FIM

    //PLV-2932 - Inicio - Metodo que atualiza a data emissao quando a proposta é contratada
    public void atualizarDataEmissao(List<Quote> lProposta){
        //PLV-4871 - INICIO
        //PLV-4871 - FIX - INICIO 
        for(Quote proposta: lProposta){
            if(proposta.Status == 'Contratada' && TriggerHelper.isChanged(proposta, 'Status')){
                proposta.DataEmissao__c = System.today();
                if(proposta.Segmento__c == 'Individual' && proposta.Tipo__c == 'Novo'){ //PLV-4871 - FIX - FIM
                    calcularVigencia(proposta);
                    System.debug('Objeto formatado:' + proposta);
                }
            }
        }
        //PLV-4871 - FIM
    }
    //PLV-2932 - Fim - Metodo que atualiza a data emissao quando a proposta é contratada
    
    // PLV-2509 INICIO
    private static GarantiaProposta__c verificarGarantiaPropostaPrioritaria(List<GarantiaProposta__c> listGarantiaProposta) {
        // Instancia
        GarantiaProposta__c garantiaPropostaPrioritaria;
        
        // Verifica qual a garantia da proposta de maior prioridade
        for(GarantiaProposta__c garantiaProposta : listGarantiaProposta) {
            if (garantiaPropostaPrioritaria == null || garantiaProposta.GarantiaProduto__r.OrdemPrioridade__c < garantiaPropostaPrioritaria.GarantiaProduto__r.OrdemPrioridade__c) {
                garantiaPropostaPrioritaria = garantiaProposta;
            }
        }
        return garantiaPropostaPrioritaria; 
        
    }
    // PLV-2509 FIM
    
    
    /*//PLV-3755 INICIO
    
    public void enviaVoucherEmail(List<Quote> plProposta) {
        
        List<Quote> lProposta = new List<Quote>();
        List<String> lEmail = new List<String>();
        for (Quote proposta : plProposta) {
            if (TriggerHelper.isChanged(proposta, 'Status') && proposta.Status == 'Disponível para contratação') {
                lProposta.add(proposta);
            }
        }
        
        if (lProposta.isEmpty()) return;
        
        for(Quote p : lProposta){
            lEmail.add(p.email__c);
        }
        
		Messaging.SingleEmailMessage[] messages = new Messaging.SingleEmailMessage[0];
        for(Quote p: [SELECT Id FROM QUOTE Where Id in :lProposta]){
                Messaging.SingleEmailMessage m = new Messaging.SingleEmailMessage();
				m.setTargetObjectId(p.Id); 
        }
				

        /*if (results[0].success) {
            System.debug('Email enviado com Sucesso!');
        } else {
            System.debug('Erro no envio do Email' + results[0].errors[0].message);
        }
        
    }
    */
    //PLV-3755 FIM
    
    
    // PLV-2939 INICIO
    public void criarVoucher(List<Quote> plProposta) {
        
        List<Quote> lProposta = new List<Quote>();
        Set<Id> sProdutoId = new Set<Id>();
        
        for (Quote proposta : plProposta) {
            // PLV-3186 INICIO
            if (TriggerHelper.isChanged(proposta, 'Status') && proposta.Status == 'Disponível para contratação' && proposta.Tipo__c != 'Cancelamento') { //PLV-3872 - INICIO/FIM - Inibir geracao de documentos em caso de cancelamento unitario
                lProposta.add(proposta);
                sProdutoId.add(proposta.Produto__c);
            }
        }
        
        if (lProposta.isEmpty()) return;
        
        Map<Id,Product2> mProduto = new Map<Id,Product2>(
            [SELECT Id, GerarVoucher__c FROM Product2 WHERE Id = :sProdutoId]
        );
        
        Set<Id> sPropostaId = new Set<Id>();
        
        for (Quote proposta : lProposta) {
            
            System.debug('proposta.Produto__c =====' + proposta.Produto__c);
            System.debug('mProduto.get(proposta.Produto__c).GerarVoucher__c =====' + mProduto.get(proposta.Produto__c).GerarVoucher__c);
            if (mProduto.containsKey(proposta.Produto__c) && mProduto.get(proposta.Produto__c).GerarVoucher__c) {
                // PLV-3186 FIM
                //CH-5031619 - INICIO
                if(proposta.Segmento__c != 'VidaIndividual' && proposta.Segmento__c != 'Massificados'){
                    sPropostaId.add(proposta.Id);
                }
                //CH-5031619 - FIM
            }
        }
        
        if (sPropostaId.isEmpty()) return;
        
        if (System.isFuture() || System.isBatch() || System.isQueueable()) {
            criarVoucherSync(sPropostaId); 
        }
        else {
            criarVoucherAsync(sPropostaId); 
           
        }
        //criarVoucherSync(sPropostaId); 
        
    }
    
    @future(callout=true)
    public static void criarVoucherAsync(Set<Id> psPropostaId) {
        
        criarVoucherSync(psPropostaId);
       
    }
    
    public static void criarVoucherSync(Set<Id> psPropostaId) {
        
        Map<Id,ContentVersion> mContentVersion = new Map<Id,ContentVersion>();
        
        //PLV-3601 - INICIO
        Map<Id,Quote> mapQuote = new Map<Id,Quote>();
        List<Quote> listQuote = [SELECT Id, NumeroProposta__c, Origem__c, Produto__r.GerarVoucher__c FROM Quote WHERE id IN:(psPropostaId)]; //PLV - 4440  INICIO/FIM adcionado gerarvouchers na query
        //PLV - 4440  INICIO Ajuste gerarVoucher produto
        Boolean nGerarVoucher = true;
        for(Quote pQuote : listQuote){
            mapQuote.put(pQuote.Id,pQuote);
            if(!pQuote.Produto__r.GerarVoucher__c){
                nGerarVoucher = false;
            	break;
            }
        } 
        if(!nGerarVoucher)return;
		//PLV - 4440  FIM Ajuste gerarVoucher produto
        //PLV-3601 - FIM
        
        for (Id propostaId : psPropostaId) {
            
            PageReference pdf = Page.VoucherPage;
            Map<String,String> mPDFParam = pdf.getParameters();
            mPDFParam.put('propostaId', propostaId);
            mPDFParam.put('renderAs', 'pdf');
            //PLV-3601 - INICIO
            string nomeVoucher;
            nomeVoucher = mapQuote.get(propostaId).Origem__c+'_'+mapQuote.get(propostaId).NumeroProposta__c;
            ContentVersion file = new ContentVersion(
                Title = 'Voucher_'+nomeVoucher,
                VersionData = Test.IsRunningTest() ? Blob.valueOf('TEST') : pdf.getContentAsPDF(),
                PathOnClient ='/voucher.pdf',
                origin = 'H'
            );
            //PLV-3601 - FIM
            
            mContentVersion.put(propostaId, file);
        }
        
        if (mContentVersion.isEmpty()) return;
        
        insert mContentVersion.values();
        //PLV-3601 - INICIO
        Map<Id, ContentVersion> mContentVersionInserted = new Map<Id, ContentVersion>(
            [SELECT Id, ContentDocumentId, Title FROM ContentVersion WHERE Id IN :mContentVersion.values()]
        );
        //PLV-3601 - FIM
        List<ContentDocumentLink> lContentDocumentLink = new List<ContentDocumentLink>();
        //PLV3601 - INICIO
        List<ControleIntegracao__c>lControleIntegracao = new list<ControleIntegracao__c>();
        //PLV3601 - FIM
        for (Id propostaId : psPropostaId) {
            
            ContentDocumentLink fileLink = new ContentDocumentLink(
                LinkedEntityId = propostaId,
                ContentDocumentId = mContentVersionInserted.get(mContentVersion.get(propostaId).Id).ContentDocumentId,
                ShareType = 'V'
            );
            
            lContentDocumentLink.add(fileLink);
            //PLV-3601 - INICIO
            ControleIntegracao__c controleIntegracao = new ControleIntegracao__c(
                IdObjeto__c = propostaId+'_'+mContentVersionInserted.get(mContentVersion.get(propostaId).Id).Id,
                Status__c = 'Pendente',
                DataCriacaoRegistro__c = Date.today(),
                CodigoIntegracao__c = '85',
                // PLV - 4599 - INICIO - HENRIQUE R. META
                Objeto__c = 'Quote',
                // PLV - 4599 - FIM - HENRIQUE R. META]
                // PLV - 4599 FIX - INICIO - HENRIQUE R. META
                Pasta_ECM__c = 'Enterprise:Corporativo:Vida:Voucher Viagem'
                // PLV - 4599 FIX - FIM - HENRIQUE R. META
            );
            lControleIntegracao.add(controleIntegracao);
            //PLV-3601 - FIM
        }
        
        insert lContentDocumentLink; 
        
        //PLV-3601 - INICIO
        insert lControleIntegracao;
        //PLV-3601 - FIM
        
        //PLV-3395 - INICIO
        //PLV-3601 - INICIO (MELHORIA NESTE PROCESSO)
        //List<ContentVersion> lContentVersion = [SELECT Id,Title, ContentDocumentId FROM ContentVersion WHERE Id IN :mContentVersion.values()];
        List<ContentVersion> lContentVersion = mContentVersionInserted.values();
        //PLV-3601 - FIM
        List<Quote> q = [SELECT Id, VoucherPdfDownloadUrl__c, Account.PersonEmail, Senha__c,  DistributionPublicUrl__c from Quote where id IN: psPropostaId]; // MGRC-505 INICIO/FIM
        List<Quote> q2update = new List<Quote>();
        List<ContentDistribution> lContentDistribution2Insert = new List<ContentDistribution>();
        system.debug('contentversion: '+lcontentversion);
        system.Debug('contract: '+q);
        
        
        for(ContentVersion cvv: lContentVersion){	
            ContentDistribution cd = new ContentDistribution (
                Name = cvv.Title,
                ContentVersionId = cvv.id,
                PreferencesPasswordRequired = true  // MGRC-505 INICIO/FIM
            );
            lContentDistribution2Insert.add(cd);
            
            system.debug('cd: '+cd);
        }
        QuoteTriggerHandler.sendEmailVou = true; // MGRC-505-FIX INICIO/FIM
        insert lContentDistribution2Insert;
        
        
        List <ContentDocumentLink> mContentDocumentLink = new List <ContentDocumentLink>([select LinkedEntityId,ContentDocumentId 
                                                                                          from ContentDocumentLink 
                                                                                          where LinkedEntityId in: (psPropostaId)]); 
        Map <ID, ID> mContractContent = new Map<ID,ID>();
        List<string> lcontentDocument = new List<string>();
        for(ContentDocumentLink obj : mContentDocumentLink){
            
            mContractContent.put(obj.ContentDocumentId,obj.LinkedEntityId);
            lcontentDocument.add(obj.ContentDocumentId);
        }
        Map <ID,ContentDistribution> lContentDistribution = new map<ID,ContentDistribution>([select ContentDocumentId,ContentVersionId, PdfDownloadUrl, Password, DistributionPublicUrl from ContentDistribution where ContentDocumentId in : (lcontentDocument) ]); // MGRC-505 INICIO/FIM
        system.debug('map contrato + id documento'+mContractContent);
        system.debug('ID contentDoc'+lcontentDocument);
        system.debug('link para contrato' + lContentDistribution);
        map <ID,String> contractURL = new map <ID,String>();
        map <ID,String> contractSenha = new map <ID,String>(); // MGRC-505 INICIO/FIM
        map <ID,String> contractDistributionPublicUrl = new map <ID,String>(); // MGRC-505 INICIO/FIM
        //PLV-3744 - INICIO
        Map<String,String> versionxProposta = new Map<String,String>();
        String baseURL = [SELECT Endpoint FROM NamedCredential WHERE DeveloperName = 'SFECM' LIMIT 1].Endpoint;
        baseURL += [SELECT NomeCredencial__c,NomeToken__c,Endpoint__c,DeveloperName FROM Servico__mdt WHERE DeveloperName='Consultar_ArquivoSF' LIMIT 1].Endpoint__c;
        
        for(String key : mContentVersion.keyset()){
            versionxProposta.put((String)mContentVersion.get(key).Id,key);
        }
        //PLV-3744 - FIM
        system.debug('TESTE QUEBRA'+mContentVersionInserted);
        for(ID idkey : lContentDistribution.keyset()){
            if(mContractContent.containsKey(lContentDistribution.get(idkey).ContentDocumentId) && 
               mContentVersionInserted.containsKey(lContentDistribution.get(idkey).ContentVersionId)){ //PLV-4803 - FIX - INICIO/FIM
                //PLV-3744 - INICIO
                
                /*system.debug('encontrou contrato ID Contrato'+mContractContent.get(lContentDistribution.get(idkey).ContentDocumentId));  
                contractURL.put(mContractContent.get(lContentDistribution.get(idkey).ContentDocumentId),lContentDistribution.get(idkey).PdfDownloadUrl);*/
                system.debug('>>> '+idKey);
                system.debug('>>>2 '+versionxProposta.get(lContentDistribution.get(idkey).ContentVersionId));
                system.debug('>>>2 '+lContentDistribution.get(idkey).ContentVersionId);
                //system.debug('>>>3 '+mContentVersionInserted.get(lContentDistribution.get(idkey).ContentVersionId).Title);
                String token = Util.encryptDocPublicURL(versionxProposta.get(lContentDistribution.get(idkey).ContentVersionId),
                                                        mContentVersionInserted.get(lContentDistribution.get(idkey).ContentVersionId).Title+'.pdf');
                system.debug('>>>4 '+token);
                contractURL.put(mContractContent.get(lContentDistribution.get(idkey).ContentDocumentId),token);
                //PLV-3744 - FIM
                contractSenha.put(mContractContent.get(lContentDistribution.get(idkey).ContentDocumentId),lContentDistribution.get(idkey).Password); // MGRC-505 INICIO/FIM
                contractDistributionPublicUrl.put(mContractContent.get(lContentDistribution.get(idkey).ContentDocumentId),lContentDistribution.get(idkey).DistributionPublicUrl); // MGRC-505 INICIO/FIM
            }
            system.debug('DocumentoID' + lContentDistribution.get(idkey).ContentDocumentId);
        }
        system.debug('URL COM ID DO CONTRATO'+contractURL);
        
        for(Quote prop: q){
            if(contractURL.containsKey(prop.Id))
                system.debug('contrato:' + prop.Id);
            //PLV-3744 - INICIO
            prop.VoucherPdfDownloadUrl__c = baseURL + contractURL.get(prop.Id);
            //PLV-3744 - FIM
            prop.Senha__c = contractSenha.get(prop.Id); // MGRC-505 INICIO/FIM
            prop.DistributionPublicUrl__c = contractDistributionPublicUrl.get(prop.Id); // MGRC-505 INICIO/FIM
            if(prop.Account.PersonEmail != null)
                prop.email__c = prop.Account.PersonEmail;
            q2update.add(prop);
        }
        update(q2update);
        system.debug('c2update: '+q2update);
      
        
        //PLV -3305 - FIM
    }
    // PLV-2939 FIM
    
    // private static void CancelarEndosso(Id idContrato)
    // {
    //     Contract contratoEndossoAnterior = new Contract();
    //     Long EndossoAnterior = -1;
    
    //     //--- buscar contrato
    //     Contract objContratoCanc = contratoDAO.buscarContratosPorId(new Set<Id>{idContrato})[0];
    
    //     //--- buscar endosso anterior
    //     for(Contract obj : contratoDAO.buscarPorNumeroApolice(new Set<String>{objContratoCanc.Name}))
    //     {
    //         if(obj.Status == 'Emitido' && !String.isBlank(obj.Endosso__c) && EndossoAnterior < Long.valueOf(obj.Endosso__c))
    //         {
    //             EndossoAnterior = Long.valueOf(obj.Endosso__c);
    //             contratoEndossoAnterior = obj;
    //         }
    //     }
    
    //     if(contratoEndossoAnterior != null)
    //     {
    //         contratoEndossoAnterior.Status = 'Cancelado';
    
    //         update contratoEndossoAnterior;
    //     }
    // }
    
    /*

public void clonaProposta(Quote proposta, Id idOrcamento, String status)
{
Quote clone = new Quote();

try
{

clone.OpportunityId                 = idOrcamento;
clone.Status                        = status;
clone.DataCriacaoPortal__c          = date.today();

clone.Name                          = proposta.Name;
clone.CartaoCredito__c              = proposta.CartaoCredito__c;
clone.ContactId                     = proposta.ContactId;
clone.DataEmissao__c                = proposta.DataEmissao__c;
clone.DataProtocolo__c              = proposta.DataProtocolo__c;
clone.Email                         = proposta.Email;
clone.Empresa__c                    = proposta.Empresa__c;
clone.ImprimirCertificadoSeguro__c  = proposta.ImprimirCertificadoSeguro__c;
clone.InformacaoBancaria__c         = proposta.InformacaoBancaria__c;
clone.IOF__c                        = proposta.IOF__c;
clone.IPCA__c                       = proposta.IPCA__c;
clone.Modalidade__c                 = proposta.Modalidade__c;
clone.Phone                         = proposta.Phone;
clone.PremioParcela__c              = proposta.PremioParcela__c;
clone.PremioInformado__c            = proposta.PremioInformado__c;
clone.QuantidadeParcelas__c         = proposta.QuantidadeParcelas__c;
clone.RecordTypeId                  = proposta.RecordTypeId;
clone.Reenquadramento__c            = proposta.Reenquadramento__c;
clone.ResponsavelFinanceiro__c      = proposta.ResponsavelFinanceiro__c;
clone.TipoCusteio__c                = proposta.TipoCusteio__c;
clone.TipoCusteioEstipulante__c     = proposta.TipoCusteioEstipulante__c;
clone.TipoCusteioSegurado__c        = proposta.TipoCusteioSegurado__c;
clone.TecnicoResponsavel__c         = proposta.TecnicoResponsavel__c;
clone.MeioComercializacao__c        = proposta.MeioComercializacao__c;
clone.Produto__c                    = proposta.Produto__c;
clone.Origem__c                     = proposta.Origem__c;
clone.DataCalculo__c                = proposta.DataCalculo__c;
clone.TipoVigencia__c               = proposta.TipoVigencia__c;
clone.VigenciaInicial__c            = proposta.VigenciaInicial__c;
clone.VigenciaFinal__c              = proposta.VigenciaFinal__c;
clone.Tipo__c                       = proposta.Tipo__c;
clone.ValorPremio__c                = proposta.ValorPremio__c;
clone.TipoEvento__c                 = proposta.TipoEvento__c;
clone.InformacoesEvento__c          = proposta.InformacoesEvento__c;
clone.TipoViagem__c                 = proposta.TipoViagem__c;
clone.RamoSeguro__c                 = proposta.RamoSeguro__c;
clone.CodigoCorretor__c             = proposta.CodigoCorretor__c;
clone.Description                   = proposta.Description;
clone.FormaPagamento__c             = proposta.FormaPagamento__c;
clone.IdContratoParceiro__c         = proposta.IdContratoParceiro__c;
clone.IdContratanteParceiro__c         = proposta.IdContratanteParceiro__c;
clone.Parceiro__c                   = proposta.Parceiro__c;
}
catch(Exception e)
{
system.debug('Erro ao mapear clonar proposta :'+ e.getCause() + ' - ' +  e.getLineNumber() + ': ' + e.getMessage());
throw new QuoteException(e.getCause() + ' - ' +  e.getLineNumber() + ': ' + e.getMessage());
}

try{ insert clone; }
catch(Exception e)
{
system.debug('Erro ao inserir proposta:'+ e.getCause() + ' - ' +  e.getLineNumber() + ': ' + e.getMessage());
throw new QuoteException(e.getCause() + ' - ' +  e.getLineNumber() + ': ' + e.getMessage());
}

// remunerações

List<RemuneracaoProposta__c> lstRemProp = RemuneracaoFacade.getInstance().clonaRemuneracaoProposta(clone.Id, QuoteDAO.getInstance().buscarRemuneracaoProposta(new Set<Id>{proposta.Id}));


try{ insert lstRemProp; }
catch(Exception e)
{
system.debug('Erro remuneracao orcamento:'+ e.getCause() + ' - ' +  e.getLineNumber() + ': ' + e.getMessage());
throw new QuoteException(e.getCause() + ' - ' +  e.getLineNumber() + ': ' + e.getMessage());
}

// contratantes

// criticas

// garantias

// contrato
}

*/
    
    //#1563 - comentou essa validação
    // public void validarPropostaJaIncluida(List<Quote> propostas)
    // {
    //     Set<String> propostasCods = new Set<String>();
    //     Map<String, Quote> mapProposta = new Map<String, Quote>();
    
    //     //Recupera ids das propostas e realiza busca para trazer a participaçao dos beneficiários
    //     for(Quote proposta : propostas)
    //     {
    //         propostasCods.add(proposta.Name);
    //         mapProposta.put(proposta.Name, proposta);
    //     }
    
    //     for(Quote proposta : dao.obterPropostaPorNumero(propostasCods))
    //          mapProposta.get(proposta.Name).addError('Proposta já existente no cadastro.');
    // }
    
    //PLV-4337 - INÍCIO
    public void atualizarDataVencimento( List<Quote> listaProposta ) {
        if ( Test.isRunningTest() ) {
            List< Profissao__c > listaProfissao = [ SELECT Id FROM Profissao__c WHERE Name = 'Testador' ];
            System.debug('ListSize Rogerio' + listaProfissao.size());
            if ( listaProfissao.size() != 1 ) { return; }
        }

        Set< Id > setOrcamentoId = new Set< Id >();
        Set< Id > setProdutoId = new Set< Id >();
        for ( Quote proposta: listaProposta ) {
            if ( !proposta.Massificados__c ) {
                switch on proposta.Status {
                    when 'Em criação' {
                		setOrcamentoId.add( proposta.OpportunityId );
                    }
                    when 'TODO: <<Em análise>>' {
                		setProdutoId.add( proposta.Produto__c );
                    }
                    when else {
                        System.debug('default');
                    }
                } 
            }
        }
        
		Map< Id, Date > mapaOrcamentoDataVencimento = new Map< Id, Date >();
        if ( setOrcamentoId.size() > 0 ) {
            List< Opportunity > listaOrcamentos = [ SELECT Id, DataVencimento__c, Produto__c, CreatedDate FROM Opportunity WHERE Id IN: setOrcamentoId ];
            Map< Id, Id > mapaOrcamentoProduto = new Map< Id, Id >();
            Map< Id, Datetime > mapaOrcamentoDataCriacao = new Map< Id, Datetime >();
        	Set< Id > setProdutoId2 = new Set< Id >();
        	for ( Opportunity orcamento: listaOrcamentos ) {
                if ( orcamento.DataVencimento__c != null ) {
                    mapaOrcamentoDataVencimento.put( orcamento.Id, orcamento.DataVencimento__c );
                    System.debug( 'Data de vencimento setada: ' + orcamento.DataVencimento__c );
                } else {
                    mapaOrcamentoProduto.put( orcamento.Id, orcamento.Produto__c );
                    mapaOrcamentoDataCriacao.put( orcamento.Id, orcamento.CreatedDate );
                    setProdutoId2.add( orcamento.Produto__c );
                }
            }
            
        	if ( setProdutoId2.size() > 0 ) {
                Map< Id, Double > mapaProdutoValidadeOrcamento = new Map< Id, Double >();
                List< ParametroVigencia__c > lista = [ SELECT Produto__c, ValidadeOrcamento__c FROM ParametroVigencia__c WHERE Produto__c IN: setProdutoId2 ];
        		for ( ParametroVigencia__c pv: lista ) {
                    if ( pv.ValidadeOrcamento__c != null ) {
                        mapaProdutoValidadeOrcamento.put( pv.Produto__c, pv.ValidadeOrcamento__c );
                    }
                }
                for ( Id orcamentoId : mapaOrcamentoProduto.keySet() ) {
                    Id produtoId = mapaOrcamentoProduto.get( orcamentoId );
                    Double validadeOrcamento = mapaProdutoValidadeOrcamento.get( produtoId );
                    if ( validadeOrcamento == null ) continue;
                    Datetime dt = mapaOrcamentoDataCriacao.get( orcamentoId );
                    Date data = Date.newinstance( dt.year(), dt.month(), dt.day() );
                    Date dataVencimento = data.addDays( Integer.valueOf( validadeOrcamento ) );
                    mapaOrcamentoDataVencimento.put( orcamentoId, dataVencimento );
                    System.debug( 'Data de vencimento setada: ' + dataVencimento );
                } 
            }
        }
        
		Map< Id, Date > mapaProdutoDataVencimento = new Map< Id, Date >();
        if ( setProdutoId.size() > 0 ) {
            List< ParametroVigencia__c > lista = [ SELECT Produto__c, ValidadeProposta__c FROM ParametroVigencia__c WHERE Produto__c IN: setProdutoId ];
        	for ( ParametroVigencia__c pv: lista ) {
                if ( pv.ValidadeProposta__c != null ) {
                    Date dataVencimento = System.today().addDays( Integer.valueOf( pv.ValidadeProposta__c ) );
                    mapaProdutoDataVencimento.put( pv.Produto__c, dataVencimento );
                    System.debug( 'Data de vencimento setada: ' + dataVencimento );
                }
            }
        }
        
        for ( Quote proposta: listaProposta ) {
            if ( !proposta.Massificados__c ) {
                switch on proposta.Status {
                    when 'Em criação' {
                        Date dataVencimentoOrcamento  = mapaOrcamentoDataVencimento.get( proposta.OpportunityId );
                        if ( dataVencimentoOrcamento != null ) { proposta.DataVencimento__c = dataVencimentoOrcamento; }
                    }
                    when 'TODO: <<Em análise>>' {
                        Date dataVencimentoProposta  = mapaProdutoDataVencimento.get( proposta.Produto__c );
                        if ( dataVencimentoProposta != null ) { proposta.DataVencimento__c = dataVencimentoProposta; }
                		setProdutoId.add( proposta.Produto__c );
                    }
                    when else {
                        System.debug('default');
                    }
                } 
            }
        }
    }
    //PLV-4337 - FIM
    
   //PLV-4179 and PLV- 4239 - INICIO    
   public void salvarIntegracaoAS(List<Quote> listQuoteNew, Map<Id, Quote> mapQuoteOld)
   {
        String METHOD_NAME = 'salvarIntegracaoAS';
        //PLV-5111 - FIX01 - INICIO
        List<Quote> listQuoteNewHdl = new List<Quote>();
        Map<Id, Quote> mapQuoteOldHdl = new Map<Id, Quote>();
        //PLV-5111 - FIX01 - FIM
   
        Set<Id> setIdQuote = new Set<id>();        
        if(mapQuoteOld == null) mapQuoteOld = new map<id,Quote>();
        //PLV-4496 - INICIO
        List<CriticaProposta__c> lstCriticaProposta = new List<CriticaProposta__c>();
        //PLv-4496 - FIM

        //VIDA-186 - INICIO
        Map<Id, Quote> quoteByProduct = new Map<Id, Quote>();

        for(Quote quote : listQuoteNew){
            if(!quoteByProduct.containsKey(quote.Produto__c)) quoteByProduct.put(quote.Produto__c, quote);
        }

        Map<Id, String> quoteIdIndexByProductName = new Map<Id, String>();

        if(!Test.isRunningTest()){
            List<Product2> productsById = [SELECT Id, Name FROM Product2 WHERE Id IN: quoteByProduct.keySet() AND Name = 'Porto Vida ON'];

            for(Quote quote : quoteByProduct.values()){
                for(Product2 prod : productsById){
                    if(quote.Produto__c == prod.Id) quoteIdIndexByProductName.put(quote.Id, prod.Name);
                }
            }

        }
        //VIDA-186 - FIM

        for(Quote quoteAS : listQuoteNew)
        {
            String productName = !Test.IsRunningTest() ? quoteIdIndexByProductName.get(quoteAS.Id) : 'valid product';//VIDA-186 - INICIO/FIM

            //PLV-5859 INICIO
            //RVI-247 - FIX01 - INICIO
            //II-213 - INICIO (Descomentando a RVI-247)
        //     if(quoteAS.Tipo__c == 'Renovacao' || quoteAS.Tipo__c == 'Endosso'){ 
        //         System.debug('CAIU NO Break' + quote.Tipo__c);
        //         continue;
        //    }
           //II-213 - FIM

            //RVI-247 - FIX01 - FIM
            //PLV-5859 FIM

            //AV-824 - INICIO
            if(quoteAS.Hub__c == true || quoteAS.meioComercializacao__c == 'HUB'){
                continue;
            }
            //AV-824 - FIM
            
            Quote quoteOld = mapQuoteOld.get(quoteAS.id);
            
            if(quoteOld == null) quoteOld = new Quote(status = '');
            
            //validação alteração de Status
            if(quoteAS.Status != quoteOld.Status)
            {    
                //PLV-5111 - FIX01 - INICIO
                //Havendo mudança de status, adiciona item em lista para integração de Proposta
                // RVI-247 - FIX01 - INICIO
                if(quoteAS.Tipo__c != 'Renovacao') //II-213 - INICIO/FIM
                {
                    System.debug('ENTROU NO FI DA CONDIÇÃO: ' + quoteAS.Tipo__c);
                    System.debug('QUOTE AS DEBUG: ' + quoteAS);
                    listQuoteNewHdl.add(quoteAS);
                    mapQuoteOldHdl.put(quoteAS.Id, quoteOld);
                }                
                // RVI-247 - FIX01 - FIM
                //PLV-5111 - FIX01 - FIM
                System.debug(LoggingLevel.ERROR + 'CLASS_NAME: '+ CLASS_NAME + ' -> METHOD_NAME: '+ METHOD_NAME + ' -> quoteAS.Status: ' + quoteAS.Status); //PLV-5111 - FIM
                if (quoteAS.Status == 'Em criação')  setIdQuote.add(quoteAs.id); 
                if (quoteAS.Status == 'Contratada')  setIdQuote.add(quoteAs.id);
                if (quoteAS.Status == 'Recusada')    setIdQuote.add(quoteAs.id);   
                //PLV-4496 - INICIO
                if (quoteAS.Status == 'Em análise'){

                    String formaPagamento = getCodigoFormaPagamento(quoteAS.Id);

                    System.debug('--->STATUS EM ANALISE<---');

                    System.debug('--->formaPagamento<---'+ formaPagamento);
                    //FCVEP-33 INICIO
                    String status = (formaPagamento == '21' || formaPagamento == '52') && quoteAS.Tipo__c == 'Novo' ? 'Pendente' : 'Não iniciada';

                    System.debug('--->status<---'+ status);

                    if(productName != 'Porto Vida ON'){//VIDA-186 - INICIO
                        CriticaProposta__c ctp = new CriticaProposta__c(
                            //PLV-4790 FIX 3 INICIO
                            Tipo__c = 'Analise',
                            Setor__c = 'Emissão',
                            //PLV-4790 FIX 4 INICIO
                            Descricao__c = 'Parecer final da emissão',
                            Codigo__c = '0',
                            //PLV-4790 FIX 4 FIM
                            //PLV-4790 FIX 3 FIM
                            Proposta__c = quoteAs.id,
                            MomentoAnalise__c = 'Palavra final',
                            Status__c = status
                        );
                        lstCriticaProposta.add(ctp);                    
                    }//VIDA-186 - FIM
                    //FCVEP-33 FIM
                }
                //PLV-4496 - FIM
            }             
        }   
        //PLV-4496 - INICIO
        if(lstCriticaProposta.size()>0){
            insert lstCriticaProposta;
        }        
        //PLV-4496 - FIM
        
        // PLV-5111 - FIX01 - INICIO
        // Realiza a integração AS apenas havendo propostas com mudanças de status
        if (listQuoteNewHdl.size() > 0) {
            System.debug('LISTA QUOTE NEW: ' + listQuoteNewHdl );
            IntegracaoAS.execute(listQuoteNewHdl, mapQuoteOldHdl); 
        }
        // PLV-5111 - FIX01 - FIM
        
        //IntegracaoAS.execute(listQuoteNew, mapQuoteOld); // PLV-4875 INICIO/FIM // PLV-5111 - FIX01 - INICIO/FIM
          
    } 
    //PLV-4179 and PLV- 4239 - FIM

    //FCVEP-33 INICIO
    public String getCodigoFormaPagamento(Id quoteId) {
        Quote quote = [SELECT FormaPagamento__r.Codigo__c FROM Quote WHERE Id =: quoteId LIMIT 1];
        return quote.FormaPagamento__r.Codigo__c;
    }
    //FCVEP-33 FIM

    //VIAG-165 - INICIO
    //PLV-4589 - INICIO    
    public void atualizarSLAProposta(List<Quote> listQuoteNew, Map<Id, Quote> mapQuoteOld)
    {   
        
        System.debug('ENTROU AQUI HENRIQUE ATUALIZAR');
        System.debug('ENTROU AQUI HENRIQUE ATUALIZAR listQuoteNew: ' + listQuoteNew);
        System.debug('ENTROU AQUI HENRIQUE ATUALIZAR listQuoteNew: ' + listQuoteNew[0].Segmento__c);
        System.debug('ENTROU AQUI HENRIQUE ATUALIZAR mapQuoteOld: ' + mapQuoteOld);

        for(Quote lstQuot : listQuoteNew){
            System.debug('lstQuot HENRIQUE Segmento: ' + lstQuot.Segmento__c);
            if(lstQuot.Segmento__c == 'Individual'){
                System.debug('ENTROU NO IF NOVO');
                if(mapQuoteOld == null) mapQuoteOld = new map<id,Quote>();        
                
                List<Quote> lstQuoteSLA = new List<Quote>();
                Date dataAtual = System.Today();
                Integer diasAdicionais = 15;
                
                Map<Id,List<CriticaProposta__c>> criticasPropostaSLA = new Map<Id,List<CriticaProposta__c>>();
                
                for(Quote propostasTriggerSLA : [	SELECT	Id,
                                                    (SELECT Id, DataFimPendencia__c 
                                                    FROM CriticasProposta__r
                                                    ORDER BY DataFimPendencia__c DESC)
                                            FROM 	Quote
                                            WHERE 	Id IN: listQuoteNew]){                                        

                    if(!(propostasTriggerSLA.CriticasProposta__r).isEmpty()){				
                        criticasPropostaSLA.put(propostasTriggerSLA.id, propostasTriggerSLA.CriticasProposta__r);
                    }      
                }            
                        
                for(Quote quoteSLA : listQuoteNew){
                    System.debug('quoteSLA> ' + JSON.serialize(quoteSLA));
                    //PLV-4872 INICIO
                    if (quoteSLA.Status == 'Recusada') {
                        quoteSLA.Data_da_recusa__c = System.today();
                    }
                    //PLV-4872 FIM
                    Quote quoteOld = mapQuoteOld.get(quoteSLA.id);
                    
                    if(quoteOld == null) quoteOld = new Quote(DataProtocolo__c = null);         

                    Integer totalDiasPausados = quoteSLA.TotalDiasPausados__c != null ? Integer.valueOf(quoteSLA.TotalDiasPausados__c) : 0;
                    
                    if(quoteSLA.DataProtocolo__c != quoteOld.DataProtocolo__c){ 
                        if (quoteSLA.DataProtocolo__c == dataAtual){
                            quoteSLA.DataMaximaEmissao__c = quoteSLA.DataProtocolo__c.addDays(diasAdicionais);
                            lstQuoteSLA.add(quoteSLA); 
                        }
                    } 
                    
                    if(quoteSLA.DataInicioPendencia__c != quoteOld.DataInicioPendencia__c){ 
                        if (quoteSLA.DataInicioPendencia__c == dataAtual){
                            quoteSLA.DataMaximaEmissao__c = null;
                            lstQuoteSLA.add(quoteSLA); 
                        }
                    }

                    if(quoteSLA.DataFimPendencia__c != quoteOld.DataFimPendencia__c){ 

                        if(criticasPropostaSLA != null){
                            List<CriticaProposta__c> criticaDataSLA = criticasPropostaSLA.get(quoteSLA.id);  
                            for(CriticaProposta__c propostaDataFimPendenciaSLA : criticaDataSLA){
                                System.debug('propostaDataFimPendenciaSLA> ' + JSON.serialize(propostaDataFimPendenciaSLA));
                                if (quoteSLA.DataFimPendencia__c == propostaDataFimPendenciaSLA.DataFimPendencia__c && quoteSLA.DataInicioPendencia__c != null){

                                    //PLV-4995 - INÍCIO
                                    //PLV-4995 - FIX2 - INÍCIO
                                    quoteSLA.DataMaximaEmissao__c = (quoteSLA.DataProtocolo__c.addDays(diasAdicionais))+math.max(totalDiasPausados-1,0);
                                    lstQuoteSLA.add(quoteSLA); 
                                    //PLV-4995 - FIX2 - FIM
                                }
                                //PLV-4995 - FIM   
                            }
                        }                
                    }
                        
                    if(quoteSLA.DataInicioResseguro__c != quoteOld.DataInicioResseguro__c){ 
                        if (quoteSLA.DataInicioResseguro__c == dataAtual){
                            quoteSLA.DataMaximaEmissao__c = null;
                            lstQuoteSLA.add(quoteSLA); 
                        }
                    }
                        
                    if(quoteSLA.DataFimResseguro__c != quoteOld.DataFimResseguro__c){ 
                        if (quoteSLA.DataFimResseguro__c == dataAtual && quoteSLA.DataInicioResseguro__c != null){
                            quoteSLA.DataMaximaEmissao__c = (quoteSLA.DataProtocolo__c.addDays(diasAdicionais))+math.max(totalDiasPausados-1,0);  //PLV-4995 - FIX2 - INÍCIO/FIM
                            lstQuoteSLA.add(quoteSLA); 
                        }
                    }
                }
            }
        }  
    }  
    //VIAG-165 - FIM
    //PLV-4589 - FIM


    
    
    public class QuoteException extends Exception{}
    
   // PLV-4570 INICIO
   public static void callGerarPDFProposta(List<Quote> listPropostas, Map<Id, Quote> mapOldPropostas, Boolean bypass){// PLV-4544 INICIO/FIM

    List<Id> listIdPropostas = new List<Id>();
    List<Id> listIdPropostasSync = new List<Id>();// PLV-4544 INICIO/FIM
    System.debug('GiordanoPDF......... Lista Propostas.... ' + JSON.serialize(listPropostas));
    //TKCL-246 FIX06 INICIO
    if (listPropostas !=null && !listPropostas.isEmpty()) {
        String nomeP = listPropostas[0].produto__c;     
        Product2 produtoProposta;
        List<ContentDocumentLink> hasFiles = null;
        if(!Test.isRunningTest()){
            hasFiles = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :listPropostas[0].Id];
            produtoProposta = [SELECT CodigoPrecificaProduto__c, Segmento__c FROM product2 WHERE ID = :nomeP]; //II-104 INICIO-FIM
        }else{
            produtoProposta = new Product2();
            produtoProposta.CodigoPrecificaProduto__c = 'APTLMKT';
            produtoProposta.Segmento__c = 'Individual'; //II-104 INICIO-FIM
        } 
        //TKCL-246 FIX06 FIM
        //VIDA-90 - INICIO
        for (Quote proposta : listPropostas) {
            //System.debug('GiordanoPDF Produto.........' + proposta.Produto__r); //II-104 INICIO-FIM
            System.debug('GiordanoPDF mapOld.........' + mapOldPropostas.get(proposta.Id).Status);
            System.debug('XXX - PROPOSTA' + JSON.serialize(proposta));
        
            String currentStatus = proposta.Status;
            String oldStatus = mapOldPropostas.get(proposta.Id).Status;
            String productCode = produtoProposta.CodigoPrecificaProduto__c;
            String productSeg = produtoProposta.Segmento__c; //II-104 INICIO-FIM
            
            if (currentStatus == 'Em análise' && oldStatus != 'Em análise') {
                listIdPropostas.add(proposta.Id);
            }

            if (proposta.GerarPDF__c && !bypass) {
                listIdPropostasSync.add(proposta.Id);
            }
            
            if (currentStatus == 'Contratada' && oldStatus == 'Contratada' && (hasFiles == null || hasFiles.isEmpty())) {
                if (productSeg == 'Individual') { //II-104 INICIO-FFIM
                    listIdPropostas.add(proposta.Id);
                }
            }
        }
        //VIDA-90 - FIM

    }

    System.debug('Lista Propostas IF: ' + JSON.serialize(listIdPropostas));
    System.debug('Lista Propostas SYNC IF: ' + JSON.serialize(listIdPropostasSync));

    // PLV-4544 INICIO
    if(listIdPropostas.size() > 0) {
        System.debug('GiorPDF.........Vai gerar propostaPDF');
        gerarPDFProposta(listIdPropostas);
    }
    if(listIdPropostasSync.size() > 0) {
        gerarPDFPropostaSync(listIdPropostasSync);
    }
    // PLV-4544 FIM
}

    //PLV-4544 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
    @future(callout=true)
    public static void gerarPDFProposta(List<Id> listIdPropostas){
        gerarPDFPropostaSync(listIdPropostas);
    }
    @InvocableMethod //PLV-4544 INICIO/FIM
    public static void gerarPDFPropostaSync(List<Id> listIdPropostas){
    //PLV-4544 - FIM - PEDRO AUGUSTO BRAZ - SYS4B
    System.debug('GERAR PDF PROPOSTA');
    // PLV-4488
    List<Quote> listPropostas = [SELECT Id, Name, RealizarEnvioDocusign__c, Tipo__c, TipoSubscricao__c,Senha__c, DistributionPublicUrl__c, Segmento__c FROM Quote WHERE Id IN: listIdPropostas AND Segmento__c != 'Viagem']; //PLV-4588  MGRC-635 FIX INICIO-FIM EP- INÍCIO//FIM //PLV-4953 - INICIO/FIM 
    try{
        Map<Id, ContentVersion> mapContentVersion = new Map<Id, ContentVersion>();
        List<ContentDocumentLink> listContentDocumentLink = new List<ContentDocumentLink>();
        for(Quote proposta : listPropostas){
            PageReference pdf = Page.PropostaIndividual;
            pdf.getParameters().put('numProposta', proposta.Name);
            pdf.setRedirect(true);

            // PLV - 4599 INICIO - COMPLEMENTO - Henrique META
            ContentVersion file = new ContentVersion(
                Title = 'Proposta_' + (proposta.Name).replace('-','_'),
                VersionData = Test.IsRunningTest() ? Blob.valueOf('TEST') : pdf.getContentAsPDF(),
                PathOnClient = 'Proposta_' + (proposta.Name).replace('-','_') + '.pdf',
                origin = 'H'
            );
            // PLV - 4599 INICIO - COMPLEMENTO - Henrique META
            mapContentVersion.put(proposta.Id, file);
        }

        insert mapContentVersion.values();

        Map<Id, ContentVersion> mContentVersionInserted = new Map<Id, ContentVersion>(
            [SELECT Id, ContentDocumentId, Title FROM ContentVersion WHERE Id IN :mapContentVersion.values()]
        );
        List<ContentDocumentLink> lContentDocumentLink = new List<ContentDocumentLink>(); //PLV-4953 - INÍCIO/FIM
        
        List<ControleIntegracao__c> listCI = new List<ControleIntegracao__c>();
        for(Quote proposta : listPropostas){
            ContentDocumentLink fileLink = new ContentDocumentLink(
                    LinkedEntityId = proposta.Id,
                    ContentDocumentId = mContentVersionInserted.get(mapContentVersion.get(proposta.Id).Id).ContentDocumentId,
                    ShareType = 'V'
                );
            listContentDocumentLink.add(fileLink);

            ControleIntegracao__c controleIntegracao = new ControleIntegracao__c(
                IdObjeto__c = proposta.Id+'_'+mContentVersionInserted.get(mapContentVersion.get(proposta.Id).Id).Id,
                Status__c = 'Pendente',
                DataCriacaoRegistro__c = Date.today(),
                CodigoIntegracao__c = '85',
                // PLV - 4599 - INICIO - HENRIQUE R. META
                Objeto__c = 'Quote',
                // PLV - 4599 - FIM - HENRIQUE R. META
                // PLV - 4599 FIX - INICIO - HENRIQUE R. META
                Pasta_ECM__c = 'Enterprise:Corporativo:Vida:Proposta Seguro Novo'
                // PLV - 4599 FIX - FIM - HENRIQUE R. META
            );
            // PLV-4488
            //PLV-4953 - INICIO
            if(proposta.Tipo__c != 'Endosso' && proposta.TipoSubscricao__c != 'auto' && 
            proposta.TipoSubscricao__c != 'tele' && proposta.TipoSubscricao__c != 'video') {
                proposta.RealizarEnvioDocusign__c = true;
            }
            //PLV-4953 - FIM
            listCI.add(controleIntegracao);
        }

        insert listContentDocumentLink;
        insert listCI;

        //PLV-4953 - INÍCIO
        List<ContentVersion> lContentVersion = mContentVersionInserted.values();
        //List<Quote> propostas = [SELECT Id, PropostaPdfDownloadUrl__c FROM Quote WHERE Id IN :listIdPropostas];
        List<ContentDistribution> lContentDistribution2Insert = new List<ContentDistribution>();
          
        for(ContentVersion cvv: lContentVersion){	
            ContentDistribution cd = new ContentDistribution (
                Name = cvv.Title,
                ContentVersionId = cvv.id, 
                PreferencesPasswordRequired = true  // MGRC-505 INICIO/FIM
            );
            lContentDistribution2Insert.add(cd);
        }
        insert lContentDistribution2Insert;

        List <ContentDocumentLink> mContentDocumentLink = new List <ContentDocumentLink>([select LinkedEntityId,ContentDocumentId from ContentDocumentLink where LinkedEntityId in: (listIdPropostas)]); 
        
        Map <ID, ID> mQuoteContent = new Map<ID,ID>();
        List<string> lcontentDocument = new List<string>();
        for(ContentDocumentLink obj : mContentDocumentLink){
        
            mQuoteContent.put(obj.ContentDocumentId,obj.LinkedEntityId);
            lcontentDocument.add(obj.ContentDocumentId);
        }

        Map <ID,ContentDistribution> lContentDistribution = new map<ID,ContentDistribution>([select ContentDocumentId,ContentVersionId, PdfDownloadUrl, Password, DistributionPublicUrl from ContentDistribution where ContentDocumentId in : (lcontentDocument) ]); // MGRC-635 INICIO/FIM
        Map <ID,String> quoteURL = new map <ID,String>();
        Map<String,String> versionxContract = new Map<String,String>();
        map <ID,String> SenhaContent = new map <ID,String>(); // MGRC-505 INICIO/FIM
        map <ID,String> DistributionPublicUrlContent = new map <ID,String>(); // MGRC-505 INICIO/FIM
       
      
        String baseURL = [SELECT Endpoint FROM NamedCredential WHERE DeveloperName = 'SFECM' LIMIT 1].Endpoint;
        baseURL += [SELECT NomeCredencial__c,NomeToken__c,Endpoint__c,DeveloperName FROM Servico__mdt WHERE DeveloperName='Consultar_ArquivoSF' LIMIT 1].Endpoint__c;
        
        for(String key : mapContentVersion.keyset()){
            versionxContract.put((String)mapContentVersion.get(key).Id,key);
        }
       
        for(ID idkey : lContentDistribution.keyset()){

            if(mQuoteContent.containsKey(lContentDistribution.get(idkey).ContentDocumentId)){
                String token = Util.encryptDocPublicURL(versionxContract.get(lContentDistribution.get(idkey).ContentVersionId),mContentVersionInserted.get(lContentDistribution.get(idkey).ContentVersionId).Title+'.pdf');
                quoteURL.put(mQuoteContent.get(lContentDistribution.get(idkey).ContentDocumentId),token);
                 SenhaContent.put(mQuoteContent.get(lContentDistribution.get(idkey).ContentDocumentId),lContentDistribution.get(idkey).Password); // MGRC-635 INICIO/FIM 
                DistributionPublicUrlContent.put(mQuoteContent.get(lContentDistribution.get(idkey).ContentDocumentId),lContentDistribution.get(idkey).DistributionPublicUrl); // MGRC-635 INICIO/FIM 
             
            }
        }
        System.debug('>>1 quoteURL ' + JSON.serialize(quoteURL));
        System.debug('>>2 lContentDistribution ' + JSON.serialize(lContentDistribution));
        System.debug('>>3 mQuoteContent ' + JSON.serialize(mQuoteContent));
        System.debug('>>4 mapContentVersion ' + JSON.serialize(mapContentVersion));
        System.debug('>>4 lcontentDocument ' + JSON.serialize(lcontentDocument)); 
        for(Quote proposta : listPropostas){
            proposta.PropostaPdfDownloadUrl__c = baseURL + quoteURL.get(proposta.Id);  
            proposta.Senha__c = SenhaContent.get(proposta.Id);  // MGRC-505 INICIO/FIM
            proposta.DistributionPublicUrl__c = DistributionPublicUrlContent.get(proposta.Id);  // MGRC-505 INICIO/FIM
       
        }
        update listPropostas;

    //PLV-4953 - FIM
    }catch(Exception e){
        System.debug('gerarApoliceProposta ERROR ' + e.getMessage() + ' na linha: ' + e.getLineNumber());
    }
}
// PLV-4570 FIM

    //PLV-4612 INICIO
    public String checkTipoEndosso(EmissaoTO.PayloadTO objPayload){
        System.Debug('checkTipoEndosso***');
        System.debug('***jsonpayloadTO***' + JSON.serialize(objPayload));
        System.debug('HENRIQUE DEBUG: ' + objPayload.proposta);
        // II-25-FIX02  - INICIO
        if(objPayload.proposta.contratoOriginal == null) return '';
        // II-25 INICIO
        // considerado que na estrutura da nova integradora, contratoOriginal não tem o nó contratantes na raiz.
        Boolean isContratoOriginalNovaIntegradora = objPayload.proposta.contratoOriginal.contratantes == null;
        // II-25 FIM
        // II-25-FIX02  - FIM
        //Segurado
        EmissaoTO.SeguradoTO novoSegurado = objPayload.proposta.contratantes[0].grupos[0].segurados[0];
        // II-25 INICIO
        EmissaoTO.SeguradoTO seguradoOriginal = isContratoOriginalNovaIntegradora == true ? 
            objPayload.proposta.contratoOriginal.segurados[0] :  
            objPayload.proposta.contratoOriginal.contratantes[0].grupos[0].segurados[0];

        List<EmissaoTO.CoberturaTO> coberturasOriginal =  isContratoOriginalNovaIntegradora == true ? 
        objPayload.proposta.contratoOriginal.coberturas :  
        objPayload.proposta.contratoOriginal.contratantes[0].grupos[0].segurados[0].coberturas;

        EmissaoTO.DadosPagamentoTO dadosPagamentoOriginal =  isContratoOriginalNovaIntegradora == true ? 
        objPayload.proposta.contratoOriginal.dadosPagamento :  
        objPayload.proposta.contratoOriginal.contratantes[0].dadosPagamento;
        // II-25 FIM

        System.debug('Novo Segurado: '+ JSON.serialize(novoSegurado));
        System.debug('Segurado Original: '+ JSON.serialize(seguradoOriginal));


        String response = '';

        String hasCAD = '';
        // PLV-4621-FIX - INICIO
        if(objPayload.proposta.segmento == 'Viagem'){
            hasCAD = this.EndossoHasCADVIAGEM(novoSegurado, seguradoOriginal);
        }else if(isContratoOriginalNovaIntegradora == false && objPayload.proposta.contratantes[0].formaReceberApolice != objPayload.proposta.contratoOriginal.contratantes[0].formaReceberApolice){ //II-25 INICIO/FIM
            System.debug('hasCAD = CAD pela FormaReceberApolice.');
            hasCAD = 'CAD';
        }else {
            // II-25 INICIO
            hasCAD = isContratoOriginalNovaIntegradora == true ? 
                  this.EndossoHasCAD_NI(novoSegurado, seguradoOriginal) :
                  this.EndossoHasCAD(novoSegurado, seguradoOriginal);
            // II-25 FIM
        }
        // PLV-4621-FIX - FIM


        // PLV-4621-FIX2 - INICIO
        String hasFPG = '';
        String hasINC = '';
        String hasEXC = '';
        String hasAUC = '';
        String hasRDC = '';
        String hasPRM = '';
        String hasCOM = '';
        String hasBEN = '';
        if(objPayload.proposta.segmento != 'Viagem'){
            // II-25 INICIO
            hasINC = this.EndossoHasINC(novoSegurado, coberturasOriginal);
            hasEXC = this.EndossoHasEXC(novoSegurado, coberturasOriginal);
            hasAUC = this.EndossoHasAUC(novoSegurado, coberturasOriginal);
            hasFPG = this.EndossoHasFPG(objPayload.proposta.contratantes[0].dadosPagamento, dadosPagamentoOriginal);
            hasPRM = this.EndossoHasPRM(objPayload.proposta.contratantes[0].dadosPagamento, dadosPagamentoOriginal);
            // II-25 FIM
            hasCOM = this.EndossoHasCOM(objPayload.proposta.remuneracoes, objPayload.proposta.contratoOriginal.remuneracoes);

            if (novoSegurado.coberturas != null){
                hasRDC = this.EndossoHasRDC(novoSegurado, coberturasOriginal); // II-25 INICIO/FIM
            }
        
            if (novoSegurado.beneficiarios != null){
                hasBEN = this.EndossoHasBEN(novoSegurado, seguradoOriginal);
            }

        }else if(objPayload.proposta.segmento == 'Viagem'){
            hasFPG = this.EndossoHasFPGVIAGEM(objPayload.proposta.contratantes[0].dadosPagamento, objPayload.proposta.contratoOriginal.contratantes[0].dadosPagamento);
        }
        System.debug('hasCAD ' +hasCAD);
        System.debug('hasINC ' +hasINC);
        System.debug('hasEXC ' +hasEXC);
        System.debug('hasAUC ' +hasAUC);
        System.debug('hasRDC ' +hasRDC);
        System.debug('hasPRM ' +hasPRM);
        System.debug('hasCOM ' +hasCOM);
        System.debug('hasBEN ' +hasBEN);
        // PLV-4621-FIX2 - FIM
        response = hasCAD + ';' + hasINC + ';' + hasEXC + ';' + hasAUC + ';' + hasRDC + ';' + hasPRM + ';' + hasCOM + ';' + hasBEN + ';' + hasFPG;

        return response;
    }

    // PLV-4621-FIX - INICIO
    @TestVisible
    private String EndossoHasCADVIAGEM(EmissaoTO.SeguradoTO novoSegurado, EmissaoTO.SeguradoTO seguradoOriginal) {
        String novoCPF      = novoSegurado.pessoa.dadosPessoaFisica.numeroCpf + novoSegurado.pessoa.dadosPessoaFisica.digitoCpf;
        String origCPF      = seguradoOriginal.pessoa.dadosPessoaFisica.numeroCpf + seguradoOriginal.pessoa.dadosPessoaFisica.digitoCpf;
        String novoRES      = '';
        String novoCEL      = '';
        String novoPES      = '';
        String origRES      = '';
        String origCEL      = '';
        String origPES      = '';
        String novoResid    = '';
        String novoComer    = '';
        String origResid    = '';
        String origComer    = '';
        if(novoSegurado.contatoEmergencia != null && seguradoOriginal.contatoEmergencia != null){
            if(novoSegurado.contatoEmergencia.nome != seguradoOriginal.contatoEmergencia.nome ||
                novoSegurado.contatoEmergencia.telefone != seguradoOriginal.contatoEmergencia.telefone ||
                novoSegurado.contatoEmergencia.ddd != seguradoOriginal.contatoEmergencia.ddd
            ){
                return 'CAD';
            }
        }
           

        for(EmissaoTO.TelefoneTO novoTel : novoSegurado.pessoa.telefones) {

            if(novoTel.tipoTelefone == 'RES') novoRES = novoTel.tipoTelefone + novoTel.dddTelefone + ' ' + novoTel.numeroTelefone;

            if(novoTel.tipoTelefone == 'CEL') novoCEL = novoTel.tipoTelefone + novoTel.dddTelefone + ' ' + novoTel.numeroTelefone;

            if(novoTel.tipoTelefone == 'PES') novoPES = novoTel.tipoTelefone + novoTel.dddTelefone + ' ' + novoTel.numeroTelefone;
        }

        for(EmissaoTO.TelefoneTO origTel : seguradoOriginal.pessoa.telefones) {
            
            if(origTel.tipoTelefone == 'RES') origRES = origTel.tipoTelefone + origTel.numeroTelefone;

            if(origTel.tipoTelefone == 'CEL') origCEL = origTel.tipoTelefone + origTel.numeroTelefone;

            if(origTel.tipoTelefone == 'PES') origPES = origTel.tipoTelefone + origTel.numeroTelefone;
        }
        
        for(EmissaoTO.EnderecoTO novoAddress : novoSegurado.pessoa.enderecos) {

            if(novoAddress.tipoEndereco == 'RESIDENCIAL') novoResid = novoAddress.tipoEndereco + novoAddress.uf + novoAddress.cidade + novoAddress.complemento + 
                                                                      novoAddress.logradouro + novoAddress.bairro + novoAddress.cep + novoAddress.complementoCep + 
                                                                      novoAddress.numeroLogradouro;

            if(novoAddress.tipoEndereco == 'COMERCIAL')   novoComer = novoAddress.tipoEndereco + novoAddress.uf + novoAddress.cidade + novoAddress.complemento + 
                                                                      novoAddress.logradouro + novoAddress.bairro + novoAddress.cep + novoAddress.numeroLogradouro;
        }

        for(EmissaoTO.EnderecoTO origAddress : seguradoOriginal.pessoa.enderecos) {
            
            if(origAddress.tipoEndereco == 'RESIDENCIAL') origResid = origAddress.tipoEndereco + origAddress.uf + origAddress.cidade + origAddress.complemento + 
                                                                      origAddress.logradouro + origAddress.bairro + origAddress.cep + origAddress.complementoCep + 
                                                                      origAddress.numeroLogradouro;

            if(origAddress.tipoEndereco == 'COMERCIAL')   origComer = origAddress.tipoEndereco + origAddress.uf + origAddress.cidade + origAddress.complemento + 
                                                                      origAddress.logradouro + origAddress.bairro + origAddress.cep + origAddress.numeroLogradouro;
        }

        if( novoSegurado.pessoa.nome                                        != seguradoOriginal.pessoa.nome ||
            novoCPF                                                         != origCPF ||
            novoSegurado.pessoa.dadosPessoaFisica.sexo                      != seguradoOriginal.pessoa.dadosPessoaFisica.sexo ||
            novoSegurado.pessoa.dadosPessoaFisica.resideBrasil              != seguradoOriginal.pessoa.dadosPessoaFisica.resideBrasil ||
            novoSegurado.pessoa.email                                       != seguradoOriginal.pessoa.email ||
            novoRES                                                         != origRES ||
            novoCEL                                                         != origCEL ||
            novoPES                                                         != origPES ||
            novoResid                                                       != origResid ||
            novoComer                                                       != origComer
        ){
            return 'CAD';
        }
        
        return '';
    }
    // PLV-4621-FIX - FIM
    public String EndossoHasCAD(EmissaoTO.SeguradoTO novoSegurado, EmissaoTO.SeguradoTO seguradoOriginal) {

        String novoCPF      = novoSegurado.pessoa.dadosPessoaFisica.numeroCpf + novoSegurado.pessoa.dadosPessoaFisica.digitoCpf;
        String origCPF      = seguradoOriginal.pessoa.dadosPessoaFisica.numeroCpf + seguradoOriginal.pessoa.dadosPessoaFisica.digitoCpf;
        String novoRES      = '';
        String novoCEL      = '';
        String novoPES      = '';
        String origRES      = '';
        String origCEL      = '';
        String origPES      = '';
        String novoResid    = '';
        String novoComer    = '';
        String origResid    = '';
        String origComer    = '';


        
            for(EmissaoTO.TelefoneTO novoTel : novoSegurado.pessoa.telefones) {

                if(novoTel.tipoTelefone == 'RES') novoRES = novoTel.tipoTelefone + novoTel.dddTelefone + ' ' + novoTel.numeroTelefone;

                if(novoTel.tipoTelefone == 'CEL') novoCEL = novoTel.tipoTelefone + novoTel.dddTelefone + ' ' + novoTel.numeroTelefone;

                if(novoTel.tipoTelefone == 'PES') novoPES = novoTel.tipoTelefone + novoTel.dddTelefone + ' ' + novoTel.numeroTelefone;
            }

            for(EmissaoTO.TelefoneTO origTel : seguradoOriginal.pessoa.telefones) {
                
                if(origTel.tipoTelefone == 'RES') origRES = origTel.tipoTelefone + origTel.numeroTelefone;

                if(origTel.tipoTelefone == 'CEL') origCEL = origTel.tipoTelefone + origTel.numeroTelefone;

                if(origTel.tipoTelefone == 'PES') origPES = origTel.tipoTelefone + origTel.numeroTelefone;
            }
        
        
        

         
            for(EmissaoTO.EnderecoTO novoAddress : novoSegurado.pessoa.enderecos) {

                if(novoAddress.tipoEndereco == 'RESIDENCIAL') novoResid = novoAddress.tipoEndereco + novoAddress.uf + novoAddress.cidade + novoAddress.complemento + 
                                                                        novoAddress.logradouro + novoAddress.bairro + novoAddress.cep + novoAddress.complementoCep + 
                                                                        novoAddress.numeroLogradouro;

                if(novoAddress.tipoEndereco == 'COMERCIAL')   novoComer = novoAddress.tipoEndereco + novoAddress.uf + novoAddress.cidade + novoAddress.complemento + 
                                                                        novoAddress.logradouro + novoAddress.bairro + novoAddress.cep + novoAddress.numeroLogradouro;
            }

            for(EmissaoTO.EnderecoTO origAddress : seguradoOriginal.pessoa.enderecos) {
                
                if(origAddress.tipoEndereco == 'RESIDENCIAL') origResid = origAddress.tipoEndereco + origAddress.uf + origAddress.cidade + origAddress.complemento + 
                                                                        origAddress.logradouro + origAddress.bairro + origAddress.cep + origAddress.complementoCep + 
                                                                        origAddress.numeroLogradouro;

                if(origAddress.tipoEndereco == 'COMERCIAL')   origComer = origAddress.tipoEndereco + origAddress.uf + origAddress.cidade + origAddress.complemento + 
                                                                        origAddress.logradouro + origAddress.bairro + origAddress.cep + origAddress.numeroLogradouro;
            }

        if(
            //Segurado Principal
            novoSegurado.pessoa.nome                                        != seguradoOriginal.pessoa.nome ||
            novoSegurado.pessoa.dadosPessoaFisica.dataNascimento            != seguradoOriginal.pessoa.dadosPessoaFisica.dataNascimento ||
            novoSegurado.pessoa.dadosPessoaFisica.idade                     != seguradoOriginal.pessoa.dadosPessoaFisica.idade ||
            novoCPF                                                         != origCPF ||
            novoSegurado.pessoa.dadosPessoaFisica.tipoDocIdentificacao      != seguradoOriginal.pessoa.dadosPessoaFisica.tipoDocIdentificacao ||
            novoSegurado.pessoa.dadosPessoaFisica.docIdentificacao          != seguradoOriginal.pessoa.dadosPessoaFisica.docIdentificacao ||
            novoSegurado.pessoa.dadosPessoaFisica.orgaoExpedidor            != seguradoOriginal.pessoa.dadosPessoaFisica.orgaoExpedidor ||
            novoSegurado.pessoa.dadosPessoaFisica.dataExpedicao             != seguradoOriginal.pessoa.dadosPessoaFisica.dataExpedicao ||
            novoSegurado.pessoa.dadosPessoaFisica.sexo                      != seguradoOriginal.pessoa.dadosPessoaFisica.sexo ||
            novoSegurado.pessoa.dadosPessoaFisica.fumante                   != seguradoOriginal.pessoa.dadosPessoaFisica.fumante ||
            novoSegurado.pessoa.dadosPessoaFisica.profissao                 != seguradoOriginal.pessoa.dadosPessoaFisica.profissao ||
            novoSegurado.pessoa.dadosPessoaFisica.regimeTrabalho            != seguradoOriginal.pessoa.dadosPessoaFisica.regimeTrabalho ||
            novoSegurado.empresaQueTrabalha                                 != seguradoOriginal.empresaQueTrabalha ||
            novoSegurado.pessoa.rendaMensal                                 != seguradoOriginal.pessoa.rendaMensal ||
            novoSegurado.pessoa.dadosPessoaFisica.estadoCivil               != seguradoOriginal.pessoa.dadosPessoaFisica.estadoCivil ||
            novoSegurado.pessoa.dadosPessoaFisica.nacionalidade             != seguradoOriginal.pessoa.dadosPessoaFisica.nacionalidade ||
            novoSegurado.pessoa.dadosPessoaFisica.resideBrasil              != seguradoOriginal.pessoa.dadosPessoaFisica.resideBrasil ||
            novoSegurado.pessoa.dadosPessoaFisica.paisResidente             != seguradoOriginal.pessoa.dadosPessoaFisica.paisResidente ||
            novoSegurado.pessoa.pessoaExpostaPoliticamente                  != seguradoOriginal.pessoa.pessoaExpostaPoliticamente ||
            //Contato e Envio de Documentos
            novoRES                                                         != origRES ||
            novoCEL                                                         != origCEL ||
            novoPES                                                         != origPES ||
            novoSegurado.pessoa.melhorPeriodo                               != seguradoOriginal.pessoa.melhorPeriodo ||
            novoSegurado.pessoa.email                                       != seguradoOriginal.pessoa.email ||
            novoResid                                                       != origResid ||
            novoComer                                                       != origComer ||
            //Outros
            novoSegurado.ocupacaoProfissionalPrincipal                      != seguradoOriginal.ocupacaoProfissionalPrincipal ||
            novoSegurado.faixaRenda                                         != seguradoOriginal.faixaRenda
            
        ) return 'CAD';

        return '';
    }

    // II-25 INICIO  - METODO HASCAD PARA A NOVA INTEGRADORA.. POR ISSO A SIGLA 'NI'
    public String EndossoHasCAD_NI(EmissaoTO.SeguradoTO novoSegurado, EmissaoTO.SeguradoTO seguradoOriginal) {

        String novoCPF      = novoSegurado.pessoa.dadosPessoaFisica.numeroCpf + novoSegurado.pessoa.dadosPessoaFisica.digitoCpf;
        String origCPF      = seguradoOriginal.dadosPessoaFisica.numeroCpf + seguradoOriginal.dadosPessoaFisica.digitoCpf;
        String novoRES      = '';
        String novoCEL      = '';
        String novoPES      = '';
        String origRES      = '';
        String origCEL      = '';
        String origPES      = '';
        String novoResid    = '';
        String novoComer    = '';
        String origResid    = '';
        String origComer    = '';


        
            for(EmissaoTO.TelefoneTO novoTel : novoSegurado.pessoa.telefones) {

                if(novoTel.tipoTelefone == 'RES') novoRES = novoTel.tipoTelefone + novoTel.dddTelefone + ' ' + novoTel.numeroTelefone;

                if(novoTel.tipoTelefone == 'CEL') novoCEL = novoTel.tipoTelefone + novoTel.dddTelefone + ' ' + novoTel.numeroTelefone;

                if(novoTel.tipoTelefone == 'PES') novoPES = novoTel.tipoTelefone + novoTel.dddTelefone + ' ' + novoTel.numeroTelefone;
            }

            for(EmissaoTO.TelefoneTO origTel : seguradoOriginal.telefones) {
                
                if(origTel.tipoTelefone == 'RES') origRES = origTel.tipoTelefone + origTel.numeroTelefone;

                if(origTel.tipoTelefone == 'CEL') origCEL = origTel.tipoTelefone + origTel.numeroTelefone;

                if(origTel.tipoTelefone == 'PES') origPES = origTel.tipoTelefone + origTel.numeroTelefone;
            }
        
        
        

         
            for(EmissaoTO.EnderecoTO novoAddress : novoSegurado.pessoa.enderecos) {

                if(novoAddress.tipoEndereco == 'RESIDENCIAL') novoResid = novoAddress.tipoEndereco + novoAddress.uf + novoAddress.cidade + novoAddress.complemento + 
                                                                        novoAddress.logradouro + novoAddress.bairro + novoAddress.cep + novoAddress.complementoCep + 
                                                                        novoAddress.numeroLogradouro;

                if(novoAddress.tipoEndereco == 'COMERCIAL')   novoComer = novoAddress.tipoEndereco + novoAddress.uf + novoAddress.cidade + novoAddress.complemento + 
                                                                        novoAddress.logradouro + novoAddress.bairro + novoAddress.cep + novoAddress.numeroLogradouro;
            }

            for(EmissaoTO.EnderecoTO origAddress : seguradoOriginal.enderecos) {
                
                if(origAddress.tipoEndereco == 'RESIDENCIAL') origResid = origAddress.tipoEndereco + origAddress.uf + origAddress.cidade + origAddress.complemento + 
                                                                        origAddress.logradouro + origAddress.bairro + origAddress.cep + origAddress.complementoCep + 
                                                                        origAddress.numeroLogradouro;

                if(origAddress.tipoEndereco == 'COMERCIAL')   origComer = origAddress.tipoEndereco + origAddress.uf + origAddress.cidade + origAddress.complemento + 
                                                                        origAddress.logradouro + origAddress.bairro + origAddress.cep + origAddress.numeroLogradouro;
            }

        if(
            //Segurado Principal
            novoSegurado.pessoa.nome                                        != seguradoOriginal.nome ||
            novoSegurado.pessoa.dadosPessoaFisica.dataNascimento            != seguradoOriginal.dadosPessoaFisica.dataNascimento ||
            novoCPF                                                         != origCPF ||
            novoSegurado.pessoa.dadosPessoaFisica.sexo                      != seguradoOriginal.dadosPessoaFisica.sexo ||
            novoSegurado.pessoa.dadosPessoaFisica.profissao                 != seguradoOriginal.dadosPessoaFisica.profissao ||
            novoSegurado.pessoa.rendaMensal                                 != seguradoOriginal.rendaMensal ||
            novoSegurado.pessoa.dadosPessoaFisica.estadoCivil               != seguradoOriginal.dadosPessoaFisica.estadoCivil ||
            novoSegurado.pessoa.dadosPessoaFisica.nacionalidade             != seguradoOriginal.dadosPessoaFisica.nacionalidade ||
            novoSegurado.pessoa.dadosPessoaFisica.resideBrasil              != seguradoOriginal.dadosPessoaFisica.resideBrasil ||
            novoSegurado.pessoa.dadosPessoaFisica.paisResidente             != seguradoOriginal.dadosPessoaFisica.paisResidente ||
            novoSegurado.pessoa.pessoaExpostaPoliticamente                  != seguradoOriginal.pessoaExpostaPoliticamente ||
            //Contato e Envio de Documentos
            novoRES                                                         != origRES ||
            novoCEL                                                         != origCEL ||
            novoPES                                                         != origPES ||
            novoSegurado.pessoa.email                                       != seguradoOriginal.email ||
            novoResid                                                       != origResid ||
            novoComer                                                       != origComer

        ) return 'CAD';

        return '';
    }
    // II-25 FIM

    // II-25 INICIO
    public String EndossoHasINC(EmissaoTO.SeguradoTO novoSegurado, List<EmissaoTO.CoberturaTO> coberturasOriginal) {

        List<String> lsNovaCobertura = new List<String>();
        List<String> lsOrigCobertura = new List<String>();

        //INICIO - PLV-4588 - Fix
        if(novoSegurado.coberturas != null) {
            for(EmissaoTO.CoberturaTO newCobertura :novoSegurado.coberturas)  {
                if (newCobertura !=null) {
                    lsNovaCobertura.add(newCobertura.sigla);
                }
            }
    
            for(EmissaoTO.CoberturaTO origCobertura :coberturasOriginal) {
                if (origCobertura != null) {
                    lsOrigCobertura.add(origCobertura.sigla);
                }
            }
            for(String siglaCob :lsNovaCobertura) {
                if(!lsOrigCobertura.contains(siglaCob)) return 'INC';
            }     
        }
        //FIM - PLV-4588 - Fix

        return '';
    }
    // II-25 FIM
    
    // II-25 INICIO
    public String EndossoHasEXC(EmissaoTO.SeguradoTO novoSegurado, List<EmissaoTO.CoberturaTO> coberturasOriginal) {

        List<String> lsNovaCobertura = new List<String>();
        List<String> lsOrigCobertura = new List<String>();

        //INICIO - PLV-4588 - Fix
        if(novoSegurado.coberturas != null) {
            for(EmissaoTO.CoberturaTO newCobertura :novoSegurado.coberturas) lsNovaCobertura.add(newCobertura.sigla);
            
            for(EmissaoTO.CoberturaTO origCobertura :coberturasOriginal) lsOrigCobertura.add(origCobertura.sigla);
            
            for(String siglaCob :lsOrigCobertura) {
                if(!lsNovaCobertura.contains(siglaCob)) return 'EXC';
            }
        }
        //FIM - PLV-4588 - Fix
        
        return '';
    }
    // II-25 FIM
    
    // II-25 INICIO
    public String EndossoHasAUC(EmissaoTO.SeguradoTO novoSegurado, List<EmissaoTO.CoberturaTO> coberturasOriginal) {

        Map<String, EmissaoTO.CoberturaTO> mpNovaCobertura = new Map<String, EmissaoTO.CoberturaTO>();
        Map<String, EmissaoTO.CoberturaTO> mpOrigCobertura = new Map<String, EmissaoTO.CoberturaTO>();

        if(novoSegurado.coberturas != null) {
            for(EmissaoTO.CoberturaTO newCobertura :novoSegurado.coberturas) {
                mpNovaCobertura.put(newCobertura.sigla, newCobertura);
            }
            
            for(EmissaoTO.CoberturaTO origCobertura :coberturasOriginal) {
                mpOrigCobertura.put(origCobertura.sigla, origCobertura);
            }
            
            for(String sigla :mpNovaCobertura.keySet()) {
                EmissaoTO.CoberturaTO coberturaNova = mpNovaCobertura.get(sigla);
                EmissaoTO.CoberturaTO coberturaOrig = mpOrigCobertura.get(sigla);
                
                if(coberturaNova != null && coberturaOrig != null && coberturaNova.valor > coberturaOrig.valor) return 'AUC';
            }
            
        }
        
        return '';
    }
    // II-25 FIM

    @TestVisible
    // II-25 INICIO
    private String EndossoHasRDC(EmissaoTO.SeguradoTO novoSegurado, List<EmissaoTO.CoberturaTO> coberturasOriginal) {

        Map<String, EmissaoTO.CoberturaTO> mpNovaCobertura = new Map<String, EmissaoTO.CoberturaTO>();
        Map<String, EmissaoTO.CoberturaTO> mpOrigCobertura = new Map<String, EmissaoTO.CoberturaTO>();
        
        for(EmissaoTO.CoberturaTO newCobertura :novoSegurado.coberturas) {

            mpNovaCobertura.put(newCobertura.sigla, newCobertura);
        }

        for(EmissaoTO.CoberturaTO origCobertura :coberturasOriginal) {

            mpOrigCobertura.put(origCobertura.sigla, origCobertura);
        }

        for(String sigla :mpNovaCobertura.keySet()) {

            EmissaoTO.CoberturaTO coberturaNova = mpNovaCobertura.get(sigla);
            EmissaoTO.CoberturaTO coberturaOrig = mpOrigCobertura.get(sigla);

            if(
                coberturaNova != null &&
                coberturaOrig != null &&
                coberturaNova.valor < coberturaOrig.valor
            ) return 'RDC';
        }

        return '';
    }  
    // II-25 FIM  

    @TestVisible
    private String EndossoHasPRM(EmissaoTO.DadosPagamentoTO novoDadoPagamento, EmissaoTO.DadosPagamentoTO dadoPagamentoOriginal) {
        
        if(
            novoDadoPagamento.codigoFormaPagamento != dadoPagamentoOriginal.codigoFormaPagamento
        ) return 'PRM';
            
        return '';
    }
    
    // PLV-4621-FIX - INICIO
    @TestVisible
    public String EndossoHasPRMVIAGEM(EmissaoTO.PayloadTO payload, Quote proposta) {
        if(proposta.vigenciaInicial__c != Date.ValueOf(payload.proposta.contratoOriginal.vigenciaInicial) ||
            proposta.vigenciaFinal__c != Date.ValueOf(payload.proposta.contratoOriginal.vigenciaFinal)){
            return 'PRM';
        }
        return '';
    }
    // PLV-4621-FIX - FIM

    @TestVisible
    private String EndossoHasCOM(List<EmissaoTO.RemuneracaoTO> novaRemuneracao, List<EmissaoTO.RemuneracaoTO> remuneracaoOriginal) {

        Decimal percentualNew = 0;
        Decimal percentualOriginal = 0;

        for(EmissaoTO.RemuneracaoTO newRem :novaRemuneracao) {
            if(newRem.tipoRemuneracao == 'COR' || newRem.tipoRemuneracao == 'CORRETAGEM') {
                percentualNew = newRem.percentual;
                break;
            }
        }

        for(EmissaoTO.RemuneracaoTO origRem :remuneracaoOriginal) {
            if(origRem.tipoRemuneracao == 'COR' || origRem.tipoRemuneracao == 'CORRETAGEM') {
                percentualOriginal = origRem.percentual;
                break;
            }
        }

        return percentualNew == percentualOriginal ? '' : 'COM';
    }

    @TestVisible
    private String EndossoHasBEN(EmissaoTO.SeguradoTO novoSegurado, EmissaoTO.SeguradoTO seguradoOriginal) {
        // PLV-4524-FIX2 INICIO
        
        if(
            novoSegurado.beneficiarios[0].tipoBeneficiario     == 'Herdeiros legais, conforme artigo 792 do código civil.' &&
            seguradoOriginal.beneficiarios[0].tipoBeneficiario == 'Herdeiros legais, conforme artigo 792 do código civil.'
        ) return '';

        if(
            (
                novoSegurado.beneficiarios[0].tipoBeneficiario     != 'Herdeiros legais, conforme artigo 792 do código civil.' &&
                seguradoOriginal.beneficiarios[0].tipoBeneficiario == 'Herdeiros legais, conforme artigo 792 do código civil.'
            ) ||
            (
                novoSegurado.beneficiarios[0].tipoBeneficiario     == 'Herdeiros legais, conforme artigo 792 do código civil.' &&
                seguradoOriginal.beneficiarios[0].tipoBeneficiario != 'Herdeiros legais, conforme artigo 792 do código civil.'
            )
        ) return 'BEN';
        // PLV-4524-FIX2 FIM
        Map<String, EmissaoTO.BeneficiarioTO> mpNovoBenefic = new Map<String, EmissaoTO.BeneficiarioTO>();
        Map<String, EmissaoTO.BeneficiarioTO> mpOrigBenefic = new Map<String, EmissaoTO.BeneficiarioTO>();

        for(EmissaoTO.BeneficiarioTO newBen :novoSegurado.beneficiarios) {

            mpNovoBenefic.put(newBen.nome, newBen);
        }

        for(EmissaoTO.BeneficiarioTO origBen :seguradoOriginal.beneficiarios) {

            mpOrigBenefic.put(origBen.nome, origBen);
        }

        for(String nome :mpNovoBenefic.keySet()) {

            if(!mpOrigBenefic.containskey(nome)) return 'BEN';

            EmissaoTO.BeneficiarioTO beneficiarioNovo = mpNovoBenefic.get(nome);
            EmissaoTO.BeneficiarioTO beneficiarioOrig = mpOrigBenefic.get(nome);

            if(
                beneficiarioNovo.nome                   != beneficiarioOrig.nome ||
                beneficiarioNovo.cpf                    != beneficiarioOrig.cpf ||
                beneficiarioNovo.nascimento             != beneficiarioOrig.nascimento ||
                beneficiarioNovo.sexoBeneficiario       != beneficiarioOrig.sexoBeneficiario ||
                beneficiarioNovo.grauParentesco         != beneficiarioOrig.grauParentesco ||
                beneficiarioNovo.grauParentescoOutros   != beneficiarioOrig.grauParentescoOutros || //PLV-5231 INICIO/FIM
                beneficiarioNovo.percentualIndenizacao  != beneficiarioOrig.percentualIndenizacao
            ) return 'BEN';
        }

        return '';
    }

    @TestVisible
    private String EndossoHasFPG(EmissaoTO.DadosPagamentoTO novoDadoPagamento, EmissaoTO.DadosPagamentoTO dadoPagamentoOriginal) {

        if(
            novoDadoPagamento.quantidadeParcelas != dadoPagamentoOriginal.quantidadeParcelas
        ) return 'FPG';

        return '';
    }

    @TestVisible
    private String EndossoHasFPGVIAGEM(EmissaoTO.DadosPagamentoTO novoDadoPagamento, EmissaoTO.DadosPagamentoTO dadoPagamentoOriginal) {

        if(novoDadoPagamento.codigoFormaPagamento != dadoPagamentoOriginal.codigoFormaPagamento){
            return 'FPG';
        }

        return '';
    }

    //PLV-4612 FIM

     //PLV-4667 INICIO
     /* MGRC-504 - INICIO
     public void integrarNaoClienteBCP(List<Quote> listQuote){
        try{
            Set<Id> listIdClientes = new Set<Id>();
            Set<Id> listIdProdutos = new Set<Id>();
            Set<Id> listProposta = new Set<Id>();
            Map<String, Boolean> mapClientesContract = new Map<String, Boolean>();
            Map<String, Account> mapClientes = new Map<String, Account>();
            Map<String, InformacaoBancaria__c> mapInfoBancaria = new Map<String, InformacaoBancaria__c>();
            Map<String, Endereco__c> mapEndereco = new Map<String, Endereco__c>();
            Map<String, Product2> mapProduto = new Map<String, Product2>();
            Map<String, SeguradoProposta__c> mapSeguradoProposta = new Map<String, SeguradoProposta__c>();
            Map<String, BeneficiarioSeguradoProposta__c> mapBenficiario = new Map<String, BeneficiarioSeguradoProposta__c>();
            Map<String, ContratanteProposta__c> mapContratanteProposta = new Map<String, ContratanteProposta__c>();
            
            for(Quote proposta : listQuote){
                if((proposta.Status == 'Recusada' || proposta.Status == 'Devolvida') && !proposta.IntegrouNaoClienteBCP__c){
                    listIdClientes.add(proposta.AccountId);
                    listIdProdutos.add(proposta.Produto__c);
                    listProposta.add(proposta.Id);
                }
            }
            if(listProposta.size() == 0)
                return;
            for(ContratanteProposta__c contratanteProposta : [SELECT Estado__c, Proposta__c FROM ContratanteProposta__c WHERE Proposta__c IN: listProposta]){
                mapContratanteProposta.put(contratanteProposta.Proposta__c, contratanteProposta);
            }
            for(SeguradoProposta__c seguradoProposta : [SELECT Id, NomePessoaRelacionamentoProximo__c, GrauParentesco__c, GrupoProposta__r.ContratanteProposta__r.Proposta__c, PEP__c, CpfPessoaRelacionamentoProximo__c, CargoPEP__c
            FROM SeguradoProposta__c WHERE GrupoProposta__r.ContratanteProposta__r.Proposta__c IN: listProposta]){
                mapSeguradoProposta.put(seguradoProposta.GrupoProposta__r.ContratanteProposta__r.Proposta__c, seguradoProposta);
            }
            for(Product2 produto : [SELECT Id, ProductCode FROM Product2 WHERE Id IN: listIdProdutos]){
                mapProduto.put(produto.Id, produto);
            }
            for(Contract contrato : [SELECT Id, AccountId FROM Contract WHERE AccountId IN: listIdClientes]){
                mapClientesContract.put(contrato.AccountId, true);
            }
            for(InformacaoBancaria__c info : [SELECT Id, Digito__c, Agencia__c, Banco__c, NumeroConta__c, Conta__c 
                                                    FROM InformacaoBancaria__c WHERE Conta__c IN: listIdClientes ORDER BY CreatedDate ASC]){
                mapInfoBancaria.put(info.Conta__c, info);
            }
            for(Endereco__c endereco : [SELECT Id, TipoEndereco__c, Conta__c, Logradouro__c, Numero__c, Complemento__c FROM Endereco__c WHERE Conta__c IN: listIdClientes AND Maisatual__c = true ORDER BY CreatedDate ASC]){
                mapEndereco.put(endereco.Conta__c + endereco.TipoEndereco__c, endereco);
            }
            for(Account conta : [SELECT Id, Name, OrgaoExpedidor__c, 
                                        DataExpedicao__c, Rg__c, DocIndentificacao__c, 
                                        Pescod__c, Sexo__c, RecordType.Name, Cpf__c, 
                                        PersonEmail, EstadoCivil__c, CargoPEP__c,
                                        Phone, PersonHomePhone, PersonMobilePhone 
                                         FROM Account WHERE Id IN: listIdClientes]){

                mapClientes.put(conta.Id, conta);
            }

            List<Quote> listToUp = new List<Quote>();
            for(Quote proposta : listQuote){
                System.debug('mapClientesContract====' + mapClientesContract);
                System.debug('proposta.AccountId====' + proposta.AccountId);
                if(mapClientesContract.get(proposta.AccountId) == null){
                    // Enviar Nao Clientes
                    Account cliente = mapClientes.get(proposta.accountid);
                    System.debug('cliente =====' + cliente);
                    if(cliente == null)
                        continue;
                    InformacaoBancaria__c banco = mapInfoBancaria.get(proposta.accountid);
                    Endereco__c enderecoResidecial = mapEndereco.get(cliente.Id + 'Residencial');
                    Endereco__c enderecoComercial = mapEndereco.get(cliente.Id + 'Comercial');
                    Endereco__c enderecoVeraneio = mapEndereco.get(cliente.Id + 'Veraneio');
                    Endereco__c enderecoRecado = mapEndereco.get(cliente.Id + 'Recado');
                    // Montagem JSON
                    String nome1 = '';
                    String nome2 = '';
                    String nome3 = '';
                    for(String x : cliente.Name.split(' ')){
                        if(nome1 == ''){
                            nome1 = x;
                        }else if(nome2 == ''){
                            nome2 = x;
                        }else{
                            nome3 += ' ' + x;
                        }
                    }
                    BCPNaoClientes bcpTO = new BCPNaoClientes();
                    bcpTO.adicionaPessoaNaoClienteRequest                     = new BCPNaoClientes.AdicionaPessoaNaoClienteRequest();
                    // PLV-4667-FIX - INICIO
                    if(proposta.Segmento__c == 'Individual'){
                        bcptO.adicionaPessoaNaoClienteRequest.codigoOrigemMovimento = 32;
                    }else{
                        bcptO.adicionaPessoaNaoClienteRequest.codigoOrigemMovimento = 61;
                    }
                    // PLV-4667-FIX - FIM
                    bcptO.adicionaPessoaNaoClienteRequest.dataHoraMovimento = String.valueOf(System.today());
                    bcptO.adicionaPessoaNaoClienteRequest.grupoXml = 4;
                    bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO = new BCPNaoClientes.PessoaNaoClienteEBO();
                    bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.estadoCivil = new BCPNaoClientes.EstadoCivil();
                    //bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.carteiraNacionalHabilitacaoPessoa = new BCPNaoClientes.CarteiraNacionalHabilitacaoPessoa ();
                    bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.CarteiraIdentidadePessoa = new BCPNaoClientes.CarteiraIdentidadePessoa();
                    bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.contasBancaria = new List<BCPNaoClientes.ContasBancaria>();
                    bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.enderecosPessoa = new List<BCPNaoClientes.EnderecosPessoa>();
                    bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.telefonesPessoa = new List<BCPNaoClientes.TelefonesPessoa>();
                    bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.enderecosEletronicosPessoa = new List<BCPNaoClientes.EnderecosEletronicosPessoa>();
                    bcpTo.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.vinculoPessoaPoliticamenteExposta = new BCPNaoClientes.VinculoPessoaPoliticamenteExposta();
                    bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.cpfPessoa = new BCPNaoClientes.CpfPessoa();
                    if (cliente.Cpf__c != '' && cliente.Cpf__c != null) {
                        String newCpf = cliente.Cpf__c.replace('.', '').replace('-', '');
                        String digCpf = newCpf.right(2);
                        newCpf = newCpf.substring(0,9);
                        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.cpfPessoa.digitoCpf = digCpf;
                        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.cpfPessoa.numeroRaizCpf = newCpf;
                    }
                    bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.vinculoPessoaPoliticamenteExposta.codigoPessoaLocalFuncaoPessoaPoliticamenteExposta = cliente.CargoPEP__c;
                    bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.vinculoPessoaPoliticamenteExposta.codigoPessoaPoliticamenteExposta = cliente.Pescod__c;
                    if (mapSeguradoProposta.get(proposta.id) != null){
                        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.vinculoPessoaPoliticamenteExposta.nomePessoaPoliticamenteExposta = mapSeguradoProposta.get(proposta.id).NomePessoaRelacionamentoProximo__c;
                        // if(mapSeguradoProposta.get(proposta.id).TipoPessoaRelacionamentoProximo__c == 'PessoaFisica' || mapSeguradoProposta.get(proposta.id).TipoPessoaRelacionamentoProximo__c == 'Pessoa física'){
                        //     bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.vinculoPessoaPoliticamenteExposta.codigoTipoVinculoPessoaPoliticamenteExposta = 'Fisica';
                        // }else{
                        //     bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.vinculoPessoaPoliticamenteExposta.codigoTipoVinculoPessoaPoliticamenteExposta = 'Juridica';
                        // }
                        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.vinculoPessoaPoliticamenteExposta.codigoTipoVinculoPessoaPoliticamenteExposta = mapSeguradoProposta.get(proposta.id).GrauParentesco__c;
                        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.vinculoPessoaPoliticamenteExposta.codigoVinculoPessoaPoliticamenteExposta = mapSeguradoProposta.get(proposta.id).Pep__c;
                        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.vinculoPessoaPoliticamenteExposta.nomeOrgaoGovernamentalPessoaPoliticamenteExposta = mapSeguradoProposta.get(proposta.id).CargoPEP__c;
                        if(mapSeguradoProposta.get(proposta.id).CpfPessoaRelacionamentoProximo__c != null && mapSeguradoProposta.get(proposta.id).CpfPessoaRelacionamentoProximo__c != '') {
                            String cpfPep = mapSeguradoProposta.get(proposta.id).CpfPessoaRelacionamentoProximo__c.replace('.', '').replace('-','');
                            String digCpfPep = cpfPep.right(2);
                            cpfPep = cpfPep.substring(0,9);
                            bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.vinculoPessoaPoliticamenteExposta.digitoCpfPessoaPoliticamenteExposta = digCpfPep;
                            bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.vinculoPessoaPoliticamenteExposta.numeroRaizCpfPessoaPoliticamenteExposta = cpfPep; 
                        }
                    }
                    bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.codigoProduto = mapProduto.get(proposta.Produto__c).ProductCode;
                    BCPNaoClientes.enderecosEletronicosPessoa emailCliente = new BCPNaoClientes.EnderecosEletronicosPessoa();
                    emailCliente.textoEnderecoEletronicoPessoa = cliente.PersonEmail;
                    bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.enderecosEletronicosPessoa.add(emailCliente);
                    if(enderecoResidecial != null) {
                        BCPNaoClientes.EnderecosPessoa endResidencial = new BCPNaoClientes.EnderecosPessoa();
                        endResidencial.flagImovelSemNumero = '1';
                        endResidencial.numeroImovelLogradouroEndereco = enderecoResidecial.Logradouro__c + ' ' + enderecoResidecial.Numero__c;
                        endResidencial.descricaoComplementoEndereco = enderecoResidecial.Complemento__c;
                        endResidencial.codigoTipoFinalidadeEndereco = 1;
                        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.enderecosPessoa.add(endResidencial);
                    }
                    if(enderecoComercial != null) {
                        BCPNaoClientes.EnderecosPessoa endComercial = new BCPNaoClientes.EnderecosPessoa();
                        endComercial.flagImovelSemNumero = '1';
                        endComercial.numeroImovelLogradouroEndereco = enderecoComercial.Logradouro__c + ' ' + enderecoComercial.Numero__c;
                        endComercial.descricaoComplementoEndereco = enderecoComercial.Complemento__c;
                        endComercial.codigoTipoFinalidadeEndereco = 2;
                        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.enderecosPessoa.add(endComercial);
                    }
                    if(enderecoVeraneio != null) {
                        BCPNaoClientes.EnderecosPessoa endVeraneio = new BCPNaoClientes.EnderecosPessoa();
                        endVeraneio.flagImovelSemNumero = '1';
                        endVeraneio.numeroImovelLogradouroEndereco = enderecoVeraneio.Logradouro__c + ' ' + enderecoVeraneio.Numero__c;
                        endVeraneio.descricaoComplementoEndereco = enderecoVeraneio.Complemento__c;
                        endVeraneio.codigoTipoFinalidadeEndereco = 2;
                        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.enderecosPessoa.add(endVeraneio);
                    }
                    if(enderecoRecado != null) {
                        BCPNaoClientes.EnderecosPessoa endRecado = new BCPNaoClientes.EnderecosPessoa();
                        endRecado.flagImovelSemNumero = '1';
                        endRecado.numeroImovelLogradouroEndereco = enderecoRecado.Logradouro__c + ' ' + enderecoRecado.Numero__c;
                        endRecado.descricaoComplementoEndereco = enderecoRecado.Complemento__c;
                        endRecado.codigoTipoFinalidadeEndereco = 2;
                        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.enderecosPessoa.add(endRecado);
                    }
                    if(banco != null) {
                        BCPNaoClientes.ContasBancaria conta = new BCPNaoClientes.ContasBancaria();
                        conta.numeroBancoOficial = Integer.valueOf(banco.Banco__c);
                        conta.numeroAgenciaBancariaOficial = banco.Agencia__c;
                        conta.numeroContaBancariaPessoa = Integer.valueOf(banco.NumeroConta__c);
                        conta.digitoContaBancariaPessoa = banco.Digito__c;
                        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.contasBancaria.add(conta);
                    }
                    if(mapContratanteProposta.get(proposta.id) != null){
                        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.CarteiraIdentidadePessoa.codigoEstado = mapContratanteProposta.get(proposta.id).Estado__c;
                    }
                    bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.CarteiraIdentidadePessoa.codigoOrgaoExpedidorDocumento = cliente.OrgaoExpedidor__c;
                    bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.CarteiraIdentidadePessoa.dataExpedicaoCarteiraIdentidade = cliente.DataExpedicao__c;
                    if(cliente.Rg__c != '' && cliente.Rg__c != null){
                        String rg = cliente.Rg__c.replace('.','').replace('-', '');
                        String digito = rg.right(1);
                        rg = rg.subString(0, rg.length()-1);
                        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.CarteiraIdentidadePessoa.digitoCarteiraIdentidade = Integer.valueOf(digito);
                        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.CarteiraIdentidadePessoa.numeroRaizCarteiraIdentidade = Integer.valueOf(rg);
                    }
                    if(cliente.PersonHomePhone != null && cliente.PersonHomePhone != ''){
                        BCPNaoClientes.TelefonesPessoa telResidencial = new BCPNaoClientes.TelefonesPessoa();
                        telResidencial.codigoDdd = Integer.valueOf(cliente.PersonHomePhone.subString(1,3));
                        telResidencial.codigoTelefone = 'Residencial';
                        telResidencial.numeroTelefone = Integer.valueOf(cliente.PersonHomePhone.subString(5, cliente.PersonHomePhone.length()).replace('-', ''));
                        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.telefonesPessoa.add(telResidencial);
                    }
                    if(cliente.Phone != null && cliente.Phone != ''){
                        BCPNaoClientes.TelefonesPessoa telComercial = new BCPNaoClientes.TelefonesPessoa();
                        telComercial.codigoDdd = Integer.valueof(cliente.Phone.subString(1,3));
                        telComercial.codigoTelefone = 'Comercial';
                        telComercial.numeroTelefone = Integer.valueOf(cliente.Phone.subString(5, cliente.Phone.length()).replace('-', ''));
                        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.telefonesPessoa.add(telComercial);
                    }
                    if(cliente.PersonMobilePhone != null && cliente.PersonMobilePhone != ''){
                        BCPNaoClientes.TelefonesPessoa celular = new BCPNaoClientes.TelefonesPessoa();
                        celular.codigoDdd = Integer.valueOf(cliente.PersonMobilePhone.subString(1,3));
                        celular.codigoTelefone = 'Celular';
                        celular.numeroTelefone = Integer.valueOf(cliente.PersonMobilePhone.subString(5, cliente.PersonMobilePhone.length()).replace('-', ''));
                        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.telefonesPessoa.add(celular);
                    }
                    bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.codigoSexo = cliente.Sexo__c;
                    if(cliente.RecordType.Name == 'PessoaFisica' || cliente.RecordType.Name == 'Pessoa física'){
                        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.codigoTipoPessoa = 'Fisica';
                    }else{
                        bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.codigoTipoPessoa = 'Juridica';
                    }
                    bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.estadoCivil.codigoEstadoCivil = cliente.EstadoCivil__c;
                    bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.textoPrenomePessoa = nome1;
                    bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.textoNomeIntermediarioPessoa = nome2;
                    bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.textoUltimoNomePessoa = nome3.trim();
                    //bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.carteiraNacionalHabilitacaoPessoa.dataExpedicaoCnh = Date.valueOf(cliente.DataExpedicao__c);
                    //if(cliente.DocIndentificacao__c != '' && cliente.DocIndentificacao__c != null){
                    //    Integer identificacao = Integer.valueOf(cliente.DocIndentificacao__c.replace('-','').replace('.',''));
                    //    bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.carteiraNacionalHabilitacaoPessoa.numeroCnh = identificacao;
                    //    bcpTO.adicionaPessoaNaoClienteRequest.pessoaNaoClienteEBO.carteiraNacionalHabilitacaoPessoa.numeroRegistroCnhPessoa = identificacao;    
                    //}
                    
                    System.debug('karin');
                    System.debug(JSON.serialize(bcpTO, true));
                    //PLV-5022 - INICIO
                    listToUp.add(new Quote(Id=proposta.id,IntegrouNaoClienteBCP__c=true));
                    if(!Test.isRunningTest()){
                        if(proposta.isAPI__c!=true){
                            if(System.isFuture()){
                                CIVServices.getInstance().integrarNaoClientesBCP(JSON.serialize(bcpTO, true));
                            }else{
                                QuoteBO.integrarNaoClientesBCPFuture(JSON.serialize(bcpTO, true));
                            }
                        }
                    }
                    //PLV-5022 - FIM
                }
            }
            if(listToUp.size()>0) update listToUp;//PLV-5022 - INICIO/FIM
        }catch(Exception e){
            System.debug('ERROR - integrarNaoClienteBCP - ' + e.getMessage());
            System.debug('ERROR - integrarNaoClienteBCP - ' + e.getLineNumber());
        }
        
    }
    @future(callout=true)
    public static void integrarNaoClientesBCPFuture(String body){
        CIVServices.getInstance().integrarNaoClientesBCP(body);
    }
     MGRC-504 - FIM */
    //PLV-4667 FIM

    //PLV-4980 INICIO 
    public void sendEmailRecusaProposta(List<Quote> listQuote, Map<Id, Quote> mapQuoteOld){
        List<Quote> lstQuote = new List<Quote>();
        List<String> toAddresses = new List<String>();
        Set<Id> setIdCorretor = new Set<Id>();
        Map<Id,String> mapEmailCorretor = new Map<Id,String>();
 
        // filtro das propostas que estão entrando na trigger
        for(Quote proposta : listQuote ){
            system.debug('antiga proposta>> '+ mapQuoteOld.get(proposta.Id).isRecusadaSumariamente__c);
            if(proposta.isRecusadaSumariamente__c && mapQuoteOld.get(proposta.Id).isRecusadaSumariamente__c == false){
                lstQuote.add(proposta);
                setIdCorretor.add(proposta.CodigoCorretor__c);
            }
        }

        if(lstQuote.isEmpty()) return; 
        if(setIdCorretor.isEmpty()) return; 

        // pegar o email do corretor principal
        

        List<DadosCorretor__c> lstDadosCorretor = [SELECT Id, NomeCorretor__r.Email__c, Tipo__c FROM DadosCorretor__c WHERE Id IN:setIdCorretor AND NomeCorretor__r.Email__c <> NULL];

        for(DadosCorretor__c dadoCorretor : lstDadosCorretor ){
             mapEmailCorretor.put(dadoCorretor.Id, dadoCorretor.NomeCorretor__r.Email__c);
        }

        system.debug('map '+ JSON.serialize(mapEmailCorretor));

        // select modelo email 
        EmailTemplate template = [SELECT Id, Name, htmlValue, Subject FROM EmailTemplate WHERE Name = 'Email Recusa Proposta' LIMIT 1]; 
        String htmlBody; 
        List<Messaging.SingleEmailMessage> lstMail = new List<Messaging.SingleEmailMessage>();
            for(Quote proposta : lstQuote ){
                if(!mapEmailCorretor.containsKey(proposta.CodigoCorretor__c)) continue;
                toAddresses.add(mapEmailCorretor.get(proposta.CodigoCorretor__c));
                system.debug('endereços '+JSON.serialize(toAddresses));
                htmlBody = template.htmlValue.replace('XXXXXXXX',proposta.Name);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(toAddresses);
                mail.setSenderDisplayName('Porto Seguro Vida');
                mail.setSubject(template.Subject);
                mail.setWhatId(proposta.Id);
                mail.setHtmlBody(htmlBody);
                lstMail.add(mail);
            }
            Messaging.sendEmail(lstMail);
        
    }

    public void sendEmailPropostaRecusada(List<Quote> listQuote, Map<Id, Quote> mapQuoteOld){

        Set<Id> setIdProposta = new Set<Id>(); 
        Set<Id> setIdProduto = new Set<Id>(); 
        List<Quote> lstQuote = new List<Quote>();
        Set<String> setAtributos = new Set<String>{'NaoEnviaEmailRecusa'}; 
        Boolean isFailedOdm = false;
        List<CriticaProposta__c> lstPropRecusa = new List<CriticaProposta__c>();
        List<Product2> lstProduct = new List<Product2>();
        Boolean isRenovacao;
        String emailAddresses;
        String segmento;

        List<ImagemTemplate__mdt> urlTemplateRecusa = [SELECT UrlImagem__c FROM ImagemTemplate__mdt WHERE NomeTemplate__c = 'Recusa proposta'];

        for(Quote proposta : listQuote ){
            if(proposta.Status == 'Recusada'){
                lstQuote.add(proposta);
                setIdProposta.add(proposta.Id);
                setIdProduto.add(proposta.Produto__c);
            } 
        }
        if(lstQuote.isEmpty()){
            isFailedOdm = true;
        }else{
            lstProduct = [SELECT id, Segmento__c FROM Product2 WHERE id IN :setIdProduto];
            System.debug('lstProduct >>'+ lstProduct);
            segmento = lstProduct[0].Segmento__c;
            emailAddresses = lstQuote[0].email__c;
            System.debug('segmento >>'+ segmento);
            isRenovacao = (lstQuote[0].Tipo__c == 'Renovacao') ? true : false;
            if(isRenovacao){
                lstPropRecusa = [SELECT id, Codigo__c FROM CriticaProposta__c WHERE Proposta__r.Tipo__c = 'Renovacao' AND Proposta__r.Status = 'Recusada' AND Proposta__c IN :setIdProposta]; 
                if(lstPropRecusa.isEmpty()){
                isFailedOdm = true;
                }
            }
        }

        for (Constante__mdt constante: MetadataDAO.getInstance().buscarConstantes(setAtributos)){
            List<String> valoresSeparados = constante.Valor__c.split(',');
            for (CriticaProposta__c ctrProp : lstPropRecusa){
                if(valoresSeparados.contains(ctrProp.Codigo__c)){
                    isFailedOdm = true;
                }
            }
        }
    
        if(!isFailedOdm && emailAddresses != null && segmento == 'Individual'){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String bodyToSend = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"><html><head><META http-equiv="Content-Type" content="text/html; charset=utf-8"></head><body><div><div style="text-align:center"><div dir="ltr" style="color:rgb(34,34,34);font-family:Arial,Helvetica,sans-serif;font-size:small;background-color:rgb(255,255,255)"><div><div bgcolor="#FFFFFF"><table align="center" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0" width="600"><tbody><tr></tr><tr><td style="font-family:Roboto,RobotoDraft,Helvetica,Arial,sans-serif;margin:0px"><img src="#ImagemEmail#" style="outline:0px" width="100%></td></tr><tr><td style="margin:0px;padding:20px;font-size:14px;line-height:1.5;color:rgb(140,140,140)"><p style="text-align:left"><strong><span style="color:#000000">Olá,</span></strong></p><div style="text-align:left"><span style="color:#000000">Após a análise de risco da proposta <b>#proposta#</b>, informamos que não será possível prosseguir com a aceitação da proposta.</span></div><div style="text-align:left"> </div><br><div style="text-align:left"><span style="color:#000000">Porto Seguro Vida e Previdência</span></div></td></tr></tbody></table><table align="center" border="0" cellpadding="20" cellspacing="0" width="600"><tbody><tr><td align="center" bgcolor="#FFFFFF" style="font-family:Roboto,RobotoDraft,Helvetica,Arial,sans-serif;margin:0px;border-top-style:solid;border-top-color:rgb(176,176,176);border-bottom-style:solid;border-bottom-color:rgb(176,176,176)"><table align="left" border="0" cellpadding="0" cellspacing="0" width="113"><tbody><tr><td align="center" style="font-family:Arial,Helvetica,sans-serif;margin:0px;font-size:12px;color:rgb(94,94,94)"><a href="http://www.portoseguro.com.br/a-porto-seguro/fique-por-dentro/redes-sociais" style="color:rgb(94,94,94)" target="_blank">Redes Sociais</a></td></tr></tbody></table><table align="left" border="0" cellpadding="0" cellspacing="0" width="125"><tbody><tr><td align="center" style="font-family:Arial,Helvetica,sans-serif;margin:0px;font-size:12px;color:rgb(94,94,94)"><a href="https://cliente.portoseguro.com.br/portaldecliente?" style="color:rgb(94,94,94)" target="_blank">Portal do Cliente</a></td></tr></tbody></table><table align="left" border="0" cellpadding="0" cellspacing="0" width="84"><tbody><tr><td align="center" style="font-family:Arial,Helvetica,sans-serif;margin:0px;font-size:12px;color:rgb(94,94,94)"><a href="http://www.portoseguro.com.br/servicos/aplicativos-porto-seguro" style="color:rgb(94,94,94)" target="_blank">Aplicativos</a></td></tr></tbody></table><table align="left" border="0" cellpadding="0" cellspacing="0" width="103"><tbody><tr><td align="center" style="font-family:Arial,Helvetica,sans-serif;margin:0px;font-size:12px;color:rgb(94,94,94)"><a href="https://institucional.portoseguro.com.br/a-porto-seguro/fale-com-a-porto-seguro" style="color:rgb(94,94,94)" target="_blank">Atendimento</a></td></tr></tbody></table><table align="left" border="0" cellpadding="0" cellspacing="0" width="126"><tbody><tr><td align="center" style="font-family:Arial,Helvetica,sans-serif;margin:0px;font-size:12px;color:rgb(94,94,94)"><a href="http://www.portoseguro.com.br/reciclagem" style="color:rgb(94,94,94)" target="_blank">Sustentabilidade</a></td></tr></tbody></table></td></tr><tr><td align="left" bgcolor="#FFFFFF" style="margin:0px;font-size:11px;color:rgb(94,94,94);padding:10px 20px 20px">Porto Seguro Cia. de Seguros Gerais SA - CNPJ: 61.198.164/0001-60, Alameda Barão de Piracicaba n° 618 - Torre B - 8° Andar - Campos Elíseos - São Paulo - CEP 01216-012.<br>Informações reduzidas. Consulte as Condições Gerais do seguro contratado no site www.portoseguro.com.br/vida. Processos Susep: Seguro de Pessoas Individual: 15414.901355/2016-07, Porto Acidentes Pessoais Individual 15414.632387/2022-97. Antes de contratar consulte as condições gerais. O registro deste plano na SUSEP não implica, por parte da Autarquia, incentivo ou recomendação à sua comercialização. A aceitação do seguro está sujeita à análise de risco.<br> </td></tr></tbody></table></div></div></div></div></div><p> </p></div></body></html>'; //II-131 INICIO-FIM //II-148 - INICIO/FIM
            String proposta = lstQuote[0].Origem__c + '-' + lstQuote[0].NumeroProposta__c;
            bodyToSend = bodyToSend.replace('#proposta#', proposta);
            bodyToSend = bodyToSend.replace('#ImagemEmail#', urlTemplateRecusa[0].UrlImagem__c);
            String[] toAddresses = new String[] {emailAddresses};
            email.setToAddresses(toAddresses);
            email.setSubject('Sandbox: RECUSA DE PROPOSTA APÓS ANÁLISE DE RISCO');
            email.setHtmlBody(bodyToSend);
    
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            QuoteTriggerHandler.sendEmail = true;
        }
    }


    //PLV-4980 FIM

    //AV-824 - INICIO
    public void getGarantiasOportunity(List<Quote> propostas){
       List<GarantiaOrcamento__c> gOpp = new List<GarantiaOrcamento__c>();
        //AV-824-FIX1 - INICIO
        //if(gOpp.size() > 0){
            Quote opp = propostas[0];
            //Boolean hub = opp.Hub__c;
            if(!Test.isRunningTest()){
                //AV-824 - FIX2 - INICIO
                if(opp.Hub__c == true){
                    String idProposta = opp.Id;
                    Set<Id> sOpp = new Set<Id>{propostas[0].OpportunityId};
                    gOpp = OpportunityDAO.getInstance().buscarGarantiasOrcamento(sOpp);                    
                    GarantiaPropostaBO.setGarantiasProposta(gOpp, idProposta);
                }
                //AV-824 - FIX2 - FIM
               
            }
        //} 
        //AV-824-FIX1 - FIM    
    }
    
    // VIAG-166 INICIO 
    // LECVP-140 INICIO
    // public void getvalidarStatusProposta(List<Quote> propostas){
    //     List<quote> cotacao = new  List<quote>();
    //     List<quote> lcotacao = new  List<quote>();
    //     Boolean statusPropostas = false;
    //     Quote coProposta = propostas[0];
    //     cotacao = [SELECT ID, Status FROM Quote where OpportunityId =: coProposta.OpportunityId];
    //    if(cotacao.size() > 0) {
    //             for(integer i=0; i < cotacao.size(); i++ ) {
    //                 if (cotacao[i].status == 'Recusada') {
    //                   statusPropostas = true;
    //                 }
    //             }
    //             if(statusPropostas==true) {
    //               for(integer i=0; i < cotacao.size(); i++ ) {
    //                   Quote Proposta = new Quote();
    //                   Proposta.Id = cotacao[i].Id;
    //                   Proposta.CodigoMotivoDevolucao__c = '123';
    //                   Proposta.Status = 'Recusada';
    //                   lcotacao.add(Proposta);
    //               }
    //             // update lcotacao;
    //             System.debug('lcotacao>>>>>>>>>'+ lcotacao);
    //             }
    //     } 
    //}
    // LECVP-140 INICIO-FIM
    // VIAG-166 FIM
  



    public void getGarantiasOportunityContratante(List<ContratanteProposta__c> contraProposta){
        List<ContratanteOrcamento__c> contratanteOrc = new List<ContratanteOrcamento__c>();
        List<GarantiaContratanteOrcamento__c> garantiasContratante = new List<GarantiaContratanteOrcamento__c>();
        ContratanteProposta__c coProposta = contraProposta[0];
        List<Quote> opp = [SELECT Hub__c, Id, OpportunityId FROM Quote WHERE Id =: coProposta.Proposta__c];
        if(opp.size() > 0){
            Boolean hub = opp[0].Hub__c;
            if(Test.isRunningTest()){
                hub = true;
            }
            
            if(hub == true){
            
                Set<Id> sOpp = new Set<Id>{opp[0].OpportunityId};
                
                contratanteOrc = OpportunityDAO.getInstance().buscarContratantesOrcamento(sOpp);
            
                //pega as garantias contratante do orçamento e cria em proposta inicio
                for(ContratanteOrcamento__c c : contratanteOrc){
                    for(GarantiaContratanteOrcamento__c g : c.GarantiasContratanteOrcamento__r){
                        garantiasContratante.add(g);
                    }
                }
                if(garantiasContratante.size() > 0){
                
                    GarantiaPropostaBO.setGarantiaContratanteProposta(garantiasContratante,coProposta.Id);
                }
                //pega as garantias contratante do orçamento e cria em proposta fim  
            }
        }
        
        
    }

    public void getGarantiasGrupoProposta(List<GrupoProposta__c> gproposta){
        //AV-36 - INCIO
        Set<Id> sGrupoPropostaIds = new Set<Id>();
        for(GrupoProposta__c gr : gproposta){
            sGrupoPropostaIds.add(gr.Id);
        }
        List<GrupoProposta__c> lGrupoProposta = [select Name, ContratanteProposta__r.Proposta__r.OpportunityId, ContratanteProposta__r.Proposta__r.Hub__c from GrupoProposta__c where Id IN: sGrupoPropostaIds];
        if(lGrupoProposta.size() > 0){
            Boolean hub = lGrupoProposta[0].ContratanteProposta__r.Proposta__r.Hub__c;
            if(Test.isRunningTest()){
                hub = true;
            }
            if(hub == true){
                String idOpportunity = lGrupoProposta[0].ContratanteProposta__r.Proposta__r.OpportunityId;
            
                List<ContratanteOrcamento__c> lContratanteOrc = [select Id from ContratanteOrcamento__c where Orcamento__c =: idOpportunity];
                if(lContratanteOrc.size() > 0){
                     
                    Set<Id> idsContratentProp = new Set<Id>{lContratanteOrc[0].Id};
                    List<GrupoOrcamento__c> grupos = new List<GrupoOrcamento__c>();
                    grupos = GrupoOrcamentoDAO.getInstance().listarGrupoOrcamento(idsContratentProp);
                    
                    List<GarantiaGrupoOrcamento__c> lGarGruOrcamento = new List<GarantiaGrupoOrcamento__c>();        
                    Map<String,List<GarantiaGrupoOrcamento__c>> mgarantiasGrupoOrcamento = new Map<String,List<GarantiaGrupoOrcamento__c>>();
                    for(GrupoProposta__c gr : lGrupoProposta){
                        lGarGruOrcamento.clear();
                        for(GrupoOrcamento__c grupo : grupos){
                            for(GarantiaGrupoOrcamento__c g : grupo.GruposGarantiaOrcamento__r){
                                if(gr.Name == grupo.Name){
                                    lGarGruOrcamento.add(g);
                                }                            
                            }
                        }
                        if(lGarGruOrcamento.size() > 0){
                            mgarantiasGrupoOrcamento.put(gr.Id,lGarGruOrcamento);
                            //lGarGruOrcamento.clear();
                        }
                    }
                    System.debug('###garantias do grupo###'+mgarantiasGrupoOrcamento);
                    if(mgarantiasGrupoOrcamento.size() > 0){
                        GarantiaPropostaBO.setGarantiasGrupoPosposta(mgarantiasGrupoOrcamento);
                    }
                }  
            }
        }
    //AV-36 - FIM
    }

    public void getGarantiasGrupoPropostaSegurado(List<SeguradoProposta__c> segurado){
        Id idGrupoProposta = segurado[0].GrupoProposta__c;
        List<GarantiasGrupoProposta__c> lgarantiasGrupoProposta = new List<GarantiasGrupoProposta__c>();
        List<GrupoProposta__c> lGrupoProposta = [select ContratanteProposta__r.Proposta__r.Massificados__c, ContratanteProposta__r.Proposta__r.OpportunityId, ContratanteProposta__r.Proposta__r.Hub__c from GrupoProposta__c where Id =: idGrupoProposta]; //INICIO-FIM LECVPV-235-FIX1
       
        //INICIO LECVPV-235-FIX1
        if(lGrupoProposta[0].ContratanteProposta__r.Proposta__r.Massificados__c == false){
            PepBO.getInstance().getListObjectPep(segurado);
        }
        //FIM LECVPV-235-FIX1
        if(lGrupoProposta.size() > 0){
            Boolean hub = lGrupoProposta[0].ContratanteProposta__r.Proposta__r.Hub__c;
            if(Test.isRunningTest()){
                hub = true;
            }
            if(hub == true){
                lgarantiasGrupoProposta = GarantiasGrupoPropostaDAO.getInstance().listaGarantiasVida(new Set<Id>{idGrupoProposta});

                if(lgarantiasGrupoProposta.size() > 0){
                    GarantiaPropostaBO.setGarantiasSeguradoProposta(lgarantiasGrupoProposta,segurado[0].Id);
                }
            }
        }
        
    }

    //FCVEP-39 - INICIO
    public void limparCamposReemissao(List<Quote> propostas){

        Quote proposta = propostas[0];

        if(proposta != null && (proposta.Tipo__c != 'Novo' || !proposta.reemissao__c)){
            proposta.sucursalReemissao__c = '';
            proposta.ramoReemissao__c = '';
            proposta.apoliceReemissao__c = '';
            proposta.reemissao__c = false;
        }
           
    }
    //FCVEP-39 - FIM

    //AV-824 - FIM

    // VIAG-166 INICIO
    // LECVP-140 INICIO
    // public void validarStatusProposta(List<Quote> propostas){
    //     String OrcamentoId = propostas[0].OpportunityId;
    //     String PropostaId =  propostas[0].Id;
    //     System.debug('NUmero Orçamento>>>>>>>> '+OrcamentoId );      
    //     List<quote> cotacao = new  List<quote>();
    //     List<quote> lcotacao = new  List<quote>();
    //     List<CriticaProposta__c> lcritica = new List<CriticaProposta__c>();
    //     Boolean statusPropostas = false;
    //     cotacao = [SELECT ID, Status, OpportunityId FROM Quote where OpportunityId =: OrcamentoId  Order By CreatedDate DESC];
    //     if(cotacao.size() > 0) {
    //     for(integer i=0; i < cotacao.size(); i++ ) {
    //         if (cotacao[i].status == 'Recusada') {
    //             statusPropostas = true;
    //         }
    //     }
    //     if(statusPropostas==true) {
    //         List<CriticaProposta__c> CriticaProposta = new List<CriticaProposta__c>();
    //         List<CriticaProposta__c> tCriticaProposta = new List<CriticaProposta__c>();
    //         CriticaProposta = [SELECT Id,Proposta__c, Status__c  from CriticaProposta__c where Proposta__r.OpportunityId  =: OrcamentoId AND Status__c  != 'Recusado' ];
          
    //         for(integer i=0; i < cotacao.size(); i++ ) {
    //             if (cotacao[i].Id != PropostaId ) {
    //             Quote Proposta = new Quote();
    //             Proposta.Id = cotacao[i].Id;
    //             Proposta.CodigoMotivoDevolucao__c = '123';
    //             Proposta.Status = 'Recusada';
    //             lcotacao.add(Proposta);
    //             CriticaProposta__c critica = new CriticaProposta__c();
    //             critica.Descricao__c = 'SERASA - Múltiplos Passageiros';
    //             critica.Procedimento__c = 'Crítica recusada';
    //             critica.Proposta__c = cotacao[i].Id;
    //             critica.Status__c = 'Recusado';
    //             critica.Tipo__c ='Analise';
    //             critica.MensagemInterna__c = 'Outra proposta deste mesmo orçamento passou pela validação do SERASA, mas os dados encontrados foram incossistentes com a regra.';
    //             lcritica.add(critica);
    //              //verifica se possui mais criticas nas proposta e cancela todas
    //             }

    //             if (CriticaProposta.size() >0) {
    //                 for(integer a=0; a < CriticaProposta.size(); a++ ) { 
    //                 CriticaProposta__c aCriticaProposta = new CriticaProposta__c();
    //                 aCriticaProposta.Id = CriticaProposta[a].Id;
    //                 aCriticaProposta.Status__c = 'Cancelada';
    //                 tCriticaProposta.add(aCriticaProposta);
    //                 }
    //             }
    //         } 
    //         update tCriticaProposta;
    //         update lcotacao;
    //         insert lcritica;
           
    //       }
    //    }

    // }
    // VIAG-166 FIM
    // LECVP-140 FIM
}