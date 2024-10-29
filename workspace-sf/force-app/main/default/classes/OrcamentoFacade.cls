/**
 * Orçamento Façade
 * @author Fernando Barcellos @ 24/04/2018
 *
 **/
public class OrcamentoFacade{
    private final String SIM = 'SIM';
    private final String NAO = 'NAO';

    private final String PESSOA_FISICA = 'FIS';
    private final String PESSOA_JURIDICA = 'JUR';

    private final String TELEFONE_CELULAR = 'CEL';
    private final String TELEFONE_COMERCIAL = 'COM';
    private final String TELEFONE_RESIDENCIAL = 'RES';

    private final String ESTADO_CIVIL_CASADO = 'CAS';
    private final String ESTADO_CIVIL_SOLTEIRO = 'SOL';
    private final String ESTADO_CIVIL_DIVORCIADO = 'DIV';
    private final String ESTADO_CIVIL_UNIAO_ESTAVEL = 'UNI';
    private final String ESTADO_CIVIL_VIUVO = 'VIU';

    private final String NACIONALIDADE_BRASILEIRA = 'BRA';
    private final String CANAL_CORRETOR = 'COR';

    private final String PRINCIPAL = 'PRI';
    private final String DEPENDENTE = 'DEP';

    private final String PAPEL_CORRETOR = 'COR';
    private final String PAPEL_AGENCIADOR = 'AGE';
    private final String PAPEL_REPRESENTANTE = 'REP';
    private final String PAPEL_ASSESSORIA = 'ASS';
    private final String PAPEL_COMISSAO = 'COM';

    private Boolean cancelamento = false;

    private final Map<String, String> mapPapelRemuneracao = new Map<String, String> { PAPEL_CORRETOR => 'Corretor', PAPEL_AGENCIADOR => 'Agenciador', PAPEL_REPRESENTANTE => 'Representante', PAPEL_ASSESSORIA => 'Assessoria' };
    private final Map<String, String> mapPapelTipoRemuneracao = new Map<String, String> { PAPEL_CORRETOR => 'CORRETAGEM', PAPEL_AGENCIADOR => 'AGENCIAMENTO', PAPEL_REPRESENTANTE => 'PRÓ-LABORE', PAPEL_ASSESSORIA => 'ASSESSORIA', PAPEL_COMISSAO => 'COMISSÃO' };
    private final Map<String, String> mapTipoLogradouro = new Map<String, String> {'AL' => 'Alameda','AV' => 'Avenida', 'R'=> 'Rua'};

    private static AccountBO contaBo = AccountBO.getInstance();
    private static ProductBO produtoBo = ProductBO.getInstance();
    //private static ProfissaoBO profisBo = ProfissaoBO.getInstance();
    //private static RemuneracaoProdutoBO remunueracaoBo = RemuneracaoProdutoBO.getInstance();
    private static OpportunityBO oportunidadeBo = OpportunityBO.getInstance();
    private static QuoteBO OrcamentoBO = QuoteBO.getInstance();

    private static final OrcamentoFacade classInstance;

    static { classInstance = new OrcamentoFacade(); }
    private OrcamentoFacade() {}

    public static OrcamentoFacade getInstance() { return classInstance; }

    public RetornoOrcamentoRestTO.ValidacaoOrcamentoTO gerarOrcamento(String payload){
        Savepoint sp = Database.setSavepoint();
        Boolean success = false;
        OrcamentoTO.PayloadTO objPayload;
        RetornoOrcamentoRestTO.ValidacaoOrcamentoTO retorno;


        try{
            // Parser do Payload
            objPayload = (OrcamentoTO.PayloadTO) JSON.deserialize(payload, OrcamentoTO.PayloadTO.class);

            // Verifica se eh um orcamento de cancelamento
            if(objPayload.orcamentos[0].solicitacaoOferta.tipoSeguro == 'CAN') cancelamento = true;

            // Maps
            Map<String, List<GarantiaProduto__c>>       mapGarantiasPorOrcamentos           = this.agruparGarantiasOrcamento(objPayload.orcamentos);
           
            Map<String, Account>                        mapOrcamentoContratantesPrincipais  = new Map<String, Account>();
            Map<String, Opportunity>                    mapOrcamentoOportunidade            = new Map<String, Opportunity>();
            Map<Id, String>                             mapIdOportunidadeChaveOrcamento     = new Map<Id, String>();
            Map<Integer, Account>                       mapContratantesContas               = new Map<Integer, Account>();
            Map<String, List<ContratanteOrcamento__c>>  mapOrcamentoContratantesOrcamento   = new Map<String, List<ContratanteOrcamento__c>>();
            Map<String, Decimal>                        mapMoedaCotacao                     = new Map<String, Decimal>();

            List<Opportunity>               listOppUpdate                                   = new List<Opportunity>();
            List<CriticaOrcamento__c>       listCriticas                                    = new List<CriticaOrcamento__c>();
            
            List<ContratanteOrcamento__c>   listaContratantesOrcamentosParaAtualizar        = new List<ContratanteOrcamento__c>();
            List<GrupoOrcamento__c>         listaGruposOrcamentosParaAtualizar              = new List<GrupoOrcamento__c>();
            List<SeguradoOrcamento__c>      listaSeguradosOrcamentosParaAtualizar           = new List<SeguradoOrcamento__c>();

            List<GarantiaOrcamento__c>                          listaGarantiasOrcamento             = new List<GarantiaOrcamento__c>();
            List<GarantiaContratanteOrcamento__c>               listaGarantiasContratantesOrcamento = new List<GarantiaContratanteOrcamento__c>();
            List<GarantiaGrupoOrcamento__c>                     listaGarantiasGrupoOrcamento        = new List<GarantiaGrupoOrcamento__c>();
            List<GarantiaSeguradoOrcamento__c>                  listaGarantiasSeguradosOrcamento     = new List<GarantiaSeguradoOrcamento__c>();
            

            // GERAR Contas dos Contratantes do Orçamneto -------------------------
            try{
                for (OrcamentoTO payloadOrcamento : objPayload.orcamentos){
                    String chaveOrcamento = payloadOrcamento.solicitacaoOferta.numeroOrcamento;

                    Map<Integer, String> mapContratantes = new Map<Integer, String>();
                    Map<String, List<OrcamentoTO.EnderecoTO>> mapEnderecosSegurado = new Map<String, List<OrcamentoTO.EnderecoTO>>();
                    Account contaResponsavelOferta;

                    System.debug(':=========================== contratantes.size(): ' + JSON.serialize(payloadOrcamento.solicitacaoOferta.contratantes.size()));

                    for (OrcamentoTO.ContratanteTO contratante : payloadOrcamento.solicitacaoOferta.contratantes){
                        String cpfCnpj = '';

                        //Identifica qual é a pessoa principal da Oferta, na qual a oportunidade ficará vinculada
                        if (contratante.tipo == PRINCIPAL){
                            contaResponsavelOferta = this.gerarParseConta(contratante, null, true);
                            contratante.contaSf = contaResponsavelOferta;
                            mapOrcamentoContratantesPrincipais.put(chaveOrcamento, contaResponsavelOferta);
                            mapContratantesContas.put(contratante.numero, contaResponsavelOferta);
                            System.debug('::: contaResponsavelOferta: ' + JSON.serialize(contaResponsavelOferta));
                        }

                        //Separa os contratantes PF e suas profissões
                        if (contratante.pessoa.tipo == PESSOA_FISICA){
                            mapContratantes.put(contratante.numero, contratante.pessoa.dadosPessoaFisica.profissao);
                            cpfCnpj = contratante.pessoa.dadosPessoaFisica.numeroCpf + contratante.pessoa.dadosPessoaFisica.digitoCpf;
                        }
                        else{
                            cpfCnpj = contratante.pessoa.dadosPessoaJuridica.cnpj;
                        }

                        //Separa os endereços de cada contratante
                        mapEnderecosSegurado.put(cpfCnpj, contratante.pessoa.enderecos);

                        //Processa e salva as contas e o seus endereços

                        //Verifica se eh um orcamento de cancelamento
                        if(!cancelamento) 
                            mapContratantesContas = this.gerarContasOferta(payloadOrcamento, contaResponsavelOferta, mapEnderecosSegurado);
                    }
                }
            }
            catch(Exception e){
                System.debug('::: e: ' + e);
                throw new OrcamentoException('Erro ao gerar os contratantes do orçamento. ' + e.getLineNumber() + ' - ' + e.getMessage());
            }
            // END -------------------------------------------------------------

            // GERAR Orçamentos (Opp) ------------------------------------------
            try{
                for (OrcamentoTO payloadOrcamento : objPayload.orcamentos){
                    String chaveOrcamento = payloadOrcamento.solicitacaoOferta.numeroOrcamento;

                    // GERAR Mapa de cotação para usar nos Valores de cotação das garantias
                    for (OrcamentoTO.IndiceMonetarioTO indice : payloadOrcamento.indiceMonetario) 
                        mapMoedaCotacao.put(indice.moeda, indice.valor);

                    System.debug('========================================================================');
                    System.debug(':::   Orçamento: ' + payloadOrcamento.solicitacaoOferta.meioComercializacao + '' + payloadOrcamento.solicitacaoOferta.numeroPortal);
                    System.debug('::: # Orçamento: ' + payloadOrcamento.solicitacaoOferta.numeroOrcamento);
                    System.debug(':::    # Portal: ' + payloadOrcamento.solicitacaoOferta.numeroPortal);
                    System.debug('========================================================================');
                    System.debug('');

                    Opportunity oportunidade = this.gerarOportunidadeOferta(payloadOrcamento, mapOrcamentoContratantesPrincipais.get(chaveOrcamento).Id);
                    payloadOrcamento.solicitacaoOferta.objSf = oportunidade;
                    mapOrcamentoOportunidade.put(chaveOrcamento, oportunidade);
                    mapIdOportunidadeChaveOrcamento.put(oportunidade.Id, chaveOrcamento);
                }
            }
            catch(Exception e) 
            {
                //throw new OrcamentoException('Erro ao gerar os orçamentos. ERRO: ' + e);
                throw new OrcamentoException(e.getCause() + ' - ' +  e.getLineNumber() + ': ' + e.getMessage());
            }

            // GERAR SEGURADO DO ORÇAMENTO ------------------------------------
            try 
            {
                for (OrcamentoTO payloadOrcamento : objPayload.orcamentos) 
                {
                    String chaveOrcamento = payloadOrcamento.solicitacaoOferta.numeroOrcamento;

                    for (OrcamentoTO.ContratanteTO contratante : payloadOrcamento.solicitacaoOferta.contratantes) 
                    {
                        if(!mapOrcamentoContratantesOrcamento.containsKey(chaveOrcamento)) 
                            mapOrcamentoContratantesOrcamento.put(chaveOrcamento, new List<ContratanteOrcamento__c>());

                        System.debug('::: contratante.contaSf: ' + JSON.serialize(contratante.contaSf));

                        ContratanteOrcamento__c seguradoOrcamento = new ContratanteOrcamento__c();
                        seguradoOrcamento.Orcamento__c = mapOrcamentoOportunidade.get(chaveOrcamento).Id;
                        seguradoOrcamento.Numero__c = contratante.numero;

                        String tipoEndereco = contratante.pessoa.enderecos[0].tipoEndereco == 'RES' ? 'Residencial' : 'Comercial';

                        seguradoOrcamento.TipoEndereco__c = tipoEndereco;
                        seguradoOrcamento.Bairro__c = contratante.pessoa.enderecos[0].bairro;
                        seguradoOrcamento.CEP__c = contratante.pessoa.enderecos[0].cep + '' + contratante.pessoa.enderecos[0].complementoCep;
                        seguradoOrcamento.Cidade__c = contratante.pessoa.enderecos[0].cidade;
                        seguradoOrcamento.Complemento__c = contratante.pessoa.enderecos[0].complemento;
                        seguradoOrcamento.Estado__c = contratante.pessoa.enderecos[0].uf;
                        seguradoOrcamento.Logradouro__c = contratante.pessoa.enderecos[0].logradouro;
                        seguradoOrcamento.NumeroEndereco__c = contratante.pessoa.enderecos[0].numeroLogradouro;
                        seguradoOrcamento.TipoLogradouro__c  = mapTipoLogradouro.get(contratante.pessoa.enderecos[0].tipoLogradouro);

                        if (contratante.contaSf != null){
                            seguradoOrcamento.Conta__c = contratante.contaSf.Id;
                            if (contratante.tipo == PRINCIPAL) 
                                seguradoOrcamento.Tipo__c = 'Principal';
                        }

                        // retorna ao payload o objeto salesforce para ser usado como referência
                        contratante.objSf = seguradoOrcamento;
                        mapOrcamentoContratantesOrcamento.get(chaveOrcamento).add(seguradoOrcamento);
                    }
                }

                try 
                {
                    List<ContratanteOrcamento__c> contratantes = new List<ContratanteOrcamento__c>();
                    for (String chave : mapOrcamentoContratantesOrcamento.keySet()) 
                        contratantes.addAll(mapOrcamentoContratantesOrcamento.get(chave));

                    System.debug('##################################################');
                    System.debug('::: contratantes: ' + JSON.serialize(contratantes));

                    insert contratantes;
                }
                catch(Exception e) 
                {
                    System.debug(e.getLineNumber() + ': ' + e.getMessage());
                    throw new OrcamentoException(e.getLineNumber() + ': ' + e.getMessage());
                }
            }
            catch(Exception e){
                throw new OrcamentoException('Erro ao gerar os contratantes do orçamento. ERRO 2: ' + e);
            }
            // END -------------------------------------------------------------

            // GERAR GRUPO DO ORÇAMENTO ------------------------------------
            try{
                List<GrupoOrcamento__c> gruposOrcamentoParaInserir = new List<GrupoOrcamento__c>();
                for (OrcamentoTO payloadOrcamento : objPayload.orcamentos){
                    for (OrcamentoTO.ContratanteTO contratante : payloadOrcamento.solicitacaoOferta.contratantes){
                        for (OrcamentoTO.GrupoTO grupo : contratante.grupos){
                            GrupoOrcamento__c grupoOrcamento1 = new GrupoOrcamento__c();
                            grupoOrcamento1.Name = grupo.nome;
                            grupoOrcamento1.QuantidadeVidas__c = grupo.qtdeSegurados;
                            grupoOrcamento1.TipoCalculo__c = grupo.tipoCalculo;
                            grupoOrcamento1.CodigoArquivo__c = grupo.idArquivoSegurados;
                            grupoOrcamento1.ContratanteOrcamento__c = contratante.objSf.Id;
                            grupoOrcamento1.Numero__c = grupo.numero;

                            // retorna ao payload o objeto salesforce para ser usado como referência
                            grupo.objSf = grupoOrcamento1;

                            // acumular para inserir
                            gruposOrcamentoParaInserir.add(grupoOrcamento1);
                        }
                    }
                }

                // INSERT
                try{
                    insert gruposOrcamentoParaInserir;
                }
                catch(Exception e){
                    System.debug(e.getLineNumber() + ': ' + e.getMessage());
                    throw new OrcamentoException(e.getLineNumber() + ': ' + e.getMessage());
                }
            }
            catch(Exception e) 
            {
                throw new OrcamentoException('Erro ao gerar os grupos do orçamento. ERRO: ' + e);
            }
            // END -------------------------------------------------------------

            // GERAR VIDA DO ORÇAMENTO ------------------------------------


            try{
                List<SeguradoOrcamento__c> vidasOrcamentoParaInserir = new List<SeguradoOrcamento__c>();
                for (OrcamentoTO payloadOrcamento : objPayload.orcamentos) 
                {
                    for (OrcamentoTO.ContratanteTO contratante : payloadOrcamento.solicitacaoOferta.contratantes) 
                    {
                        for (OrcamentoTO.GrupoTO grupo : contratante.grupos) 
                        {
                            for (OrcamentoTO.SeguradoTO segurado : grupo.segurados) 
                            {
                                SeguradoOrcamento__c seguradoOrcamento1 = new SeguradoOrcamento__c();
                                //seguradoOrcamento1.Name = segurado.nome;
                                seguradoOrcamento1.CID__c = segurado.cid;
                              
                                if (segurado.numeroCpf != null && segurado.digitoCpf != null) 
                                    seguradoOrcamento1.CPF__c = segurado.numeroCpf + segurado.digitoCpf;
                                
                                seguradoOrcamento1.Afastado__c = segurado.afastado == SIM ? true : false;
                                seguradoOrcamento1.DataNascimento__c = segurado.dataNascimento;

                                // recupera o Id do objeto inserido anteriormente
                                seguradoOrcamento1.GrupoOrcamento__c = grupo.objSf.Id;
                                seguradoOrcamento1.Numero__c = segurado.numero;
                                System.debug('ISABELA FIN OrcamentoFacade');
                                
                                // retorna ao payload o objeto salesforce para ser usado como referência
                                segurado.objSf = seguradoOrcamento1;

                                // acumular para inserir
                                vidasOrcamentoParaInserir.add(seguradoOrcamento1);
                            }
                        }
                    }
                }

                // INSERT
                try 
                {
                    insert vidasOrcamentoParaInserir;
                }
                catch(Exception e) 
                {
                    System.debug(e.getLineNumber() + ': ' + e.getMessage());
                    throw new OrcamentoException(e.getLineNumber() + ': ' + e.getMessage());
                }
            }
            catch(Exception e) 
            {
                throw new OrcamentoException('Erro ao gerar a(s) segurado(s) do orçamento. ERRO: ' + e);
            }
            // END -------------------------------------------------------------

            // GERAR DADOS DO CÁLCULO DO ORÇAMENTO -----------------------------
            try 
            {
                // Orçamento
                for (OrcamentoTO payloadOrcamento : objPayload.orcamentos) 
                {
                    String chaveOrcamento = payloadOrcamento.solicitacaoOferta.numeroOrcamento;
                    Opportunity opp1 = payloadOrcamento.solicitacaoOferta.objSf;
                    opp1.Juros__c = payloadOrcamento.oferta.calculo.precificacao.juros;
                    opp1.IOF__c = payloadOrcamento.oferta.calculo.precificacao.iof;
                    opp1.Encargos__c = payloadOrcamento.oferta.calculo.precificacao.encargos;
                    opp1.CustoApolice__c = payloadOrcamento.oferta.calculo.precificacao.custoApolice;
                    opp1.PremioPuro__c = payloadOrcamento.oferta.calculo.precificacao.premio.puro;
                    opp1.PremioPuroInterno__c = payloadOrcamento.oferta.calculo.precificacao.premio.puroInterno;
                    opp1.DescontoPremioPuro__c = payloadOrcamento.oferta.calculo.precificacao.premio.puroDesconto;
                    opp1.PremioPuroResseguro__c = payloadOrcamento.oferta.calculo.precificacao.premio.puroResseguro;
                    opp1.PremioComercial__c = payloadOrcamento.oferta.calculo.precificacao.premio.comercial;
                    opp1.DescontoPremioComercial__c = payloadOrcamento.oferta.calculo.precificacao.premio.comercialDesconto;
                    opp1.TaxaPura__c = payloadOrcamento.oferta.calculo.precificacao.taxa.pura;
                    opp1.TaxaMensal__c = payloadOrcamento.oferta.calculo.precificacao.taxa.mensal;
                    opp1.TaxaAnual__c = payloadOrcamento.oferta.calculo.precificacao.taxa.anual;
                    opp1.TaxaPuraResseguro__c = payloadOrcamento.oferta.calculo.precificacao.taxa.puroResseguro;
                    opp1.TaxaPuraInterna__c = payloadOrcamento.oferta.calculo.precificacao.taxa.puroInterno;
                    opp1.TaxaComercial__c = payloadOrcamento.oferta.calculo.precificacao.taxa.comercial;
                    //opp1.Payload__c = payload;

                    if(payloadOrcamento.retornoAceitacao != null){
                        if(payloadOrcamento.retornoAceitacao.avisos != null){
                            if (payloadOrcamento.retornoAceitacao.avisos.size() > 0){
                                for (OrcamentoTO.StatusTO status : payloadOrcamento.retornoAceitacao.avisos){
                                    CriticaOrcamento__c aviso1 = new CriticaOrcamento__c();
                                    aviso1.Status__c ='Pendente';
                                    aviso1.Tipo__c = 'Aviso';
                                    aviso1.Codigo__c = String.valueOf(status.codigo);
                                    aviso1.Origem__c = status.origem;
                                    aviso1.Descricao__c = status.descricao;
                                    aviso1.Severidade__c = status.severidade;
                                    aviso1.Area__c = status.area;
                                    aviso1.Orcamento__c = opp1.Id;
                                    //aviso1.Justificativa__c = '-';

                                    // INICIO | PLV-4647-VI-Guilherme Brito
                                    aviso1.Procedimento__c = status.procedimento; 
                                    if (status.mensagens.interna != null) aviso1.MensagemInterna__c = status.mensagens.interna;
                                    if (status.mensagens.representante != null) aviso1.MensagemRepresentante__c = status.mensagens.representante;
                                    if (status.mensagens.cliente != null) aviso1.MensagemCliente__c = status.mensagens.cliente;
                                    // FIM| PLV-4647-VI-Guilherme Brito

                                    listCriticas.add(aviso1);
                                }
                            }
                        }

                        if(payloadOrcamento.retornoAceitacao.analises != null){
                            if (payloadOrcamento.retornoAceitacao.analises.size() > 0){
                                for (OrcamentoTO.StatusTO status : payloadOrcamento.retornoAceitacao.analises){
                                    CriticaOrcamento__c analise1 = new CriticaOrcamento__c();
                                    analise1.Status__c ='Pendente';
                                    analise1.Tipo__c = 'Análise';
                                    analise1.Codigo__c = String.valueOf(status.codigo);
                                    analise1.Origem__c = status.origem;
                                    analise1.Descricao__c = status.descricao;
                                    analise1.Severidade__c = status.severidade;
                                    analise1.Area__c = status.area;
                                    analise1.Orcamento__c = opp1.Id;
                                    //analise1.Justificativa__c = '-';
                                    // INICIO | PLV-4647-VI-Guilherme Brito
                                    analise1.Procedimento__c = status.procedimento;
                                    if (status.mensagens != null){
                                        analise1.MensagemInterna__c = status.mensagens.interna;
                                        analise1.MensagemRepresentante__c = status.mensagens.representante;
                                        analise1.MensagemCliente__c = status.mensagens.cliente;
                                    }
                                    // FIM| PLV-4647-VI-Guilherme Brito

                                    listCriticas.add(analise1);
                                }
                            }
                        }

                        if(payloadOrcamento.retornoAceitacao.recusas != null){
                            if (payloadOrcamento.retornoAceitacao.recusas.size() > 0){
                                for (OrcamentoTO.StatusTO status : payloadOrcamento.retornoAceitacao.recusas){
                                    CriticaOrcamento__c recusa1 = new CriticaOrcamento__c();
                                    recusa1.Status__c ='Pendente';
                                    recusa1.Tipo__c = 'Recusa';
                                    recusa1.Codigo__c = String.valueOf(status.codigo);
                                    recusa1.Origem__c = status.origem;
                                    recusa1.Descricao__c = status.descricao;
                                    recusa1.Severidade__c = status.severidade;
                                    recusa1.Area__c = status.area;
                                    recusa1.Orcamento__c = opp1.Id;
                                    //recusa1.Justificativa__c = '-';

                                    // INICIO | PLV-4647-VI-Guilherme Brito
                                    recusa1.Procedimento__c = status.procedimento;
                                    if (status.mensagens != null){
                                        recusa1.MensagemInterna__c = status.mensagens.interna;
                                        recusa1.MensagemRepresentante__c = status.mensagens.representante;
                                        recusa1.MensagemCliente__c = status.mensagens.cliente;
                                    }
                                    // FIM| PLV-4647-VI-Guilherme Brito
                                    listCriticas.add(recusa1);
                                }
                            }
                        }

                        if(payloadOrcamento.retornoAceitacao.pendencias != null){
                            if (payloadOrcamento.retornoAceitacao.pendencias.size() > 0){
                                for (OrcamentoTO.StatusTO status : payloadOrcamento.retornoAceitacao.pendencias){
                                    CriticaOrcamento__c pendencia1 = new CriticaOrcamento__c();
                                    pendencia1.Status__c ='Pendente';
                                    pendencia1.Tipo__c = 'Pendência';
                                    pendencia1.Codigo__c = String.valueOf(status.codigo);
                                    pendencia1.Origem__c = status.origem;
                                    pendencia1.Descricao__c = status.descricao;
                                    pendencia1.Severidade__c = status.severidade;
                                    pendencia1.Area__c = status.area;
                                    pendencia1.Orcamento__c = opp1.Id;
                                    //pendencia1.Justificativa__c = '-';

                                    // INICIO | PLV-4647-VI-Guilherme Brito
                                    pendencia1.Procedimento__c = status.procedimento;
                                    if (status.mensagens != null){
                                        pendencia1.MensagemInterna__c = status.mensagens.interna;
                                        pendencia1.MensagemRepresentante__c = status.mensagens.representante;
                                        pendencia1.MensagemCliente__c = status.mensagens.cliente;
                                    }
                                    // FIM| PLV-4647-VI-Guilherme Brito

                                    listCriticas.add(pendencia1);
                                }
                            }
                        }
                    }

                    listOppUpdate.add(opp1);

                    // Orçamento
                    // Contratantes do Orçamento
                    for (OrcamentoTO.ContratanteTO contratante : payloadOrcamento.oferta.calculo.precificacao.contratantes){
                        for (OrcamentoTO.ContratanteTO seguradoSf : payloadOrcamento.solicitacaoOferta.contratantes){
                            if (contratante.numero == seguradoSf.numero){
                                ContratanteOrcamento__c sg1 = seguradoSf.objSf;
                                sg1.PremioPuro__c = contratante.premio.puro;
                                sg1.PremioComercial__c = contratante.premio.comercial;
                                sg1.TaxaComercial__c = contratante.taxa.comercial;
                                sg1.TaxaPura__c = contratante.taxa.pura;

                                listaContratantesOrcamentosParaAtualizar.add(sg1);
                                break;
                            }
                        }
                        // Orçamento
                        // Contratantes do Orçamento
                        // Grupos do Contratante
                        for (OrcamentoTO.GrupoTO grupo : contratante.grupos){
                            for (OrcamentoTO.ContratanteTO seguradoSf : payloadOrcamento.solicitacaoOferta.contratantes){
                                for (OrcamentoTO.GrupoTO grupoSf : seguradoSf.grupos){
                                    if (grupo.numero == grupoSf.numero){
                                        GrupoOrcamento__c go1 = grupoSf.objSf;
                                        go1.PremioPuro__c = grupo.premio.puro;
                                        go1.PremioComercial__c = grupo.premio.comercial;
                                        go1.TaxaPura__c = grupo.taxa.pura;
                                        go1.TaxaComercial__c = grupo.taxa.comercial;

                                        listaGruposOrcamentosParaAtualizar.add(go1);

                                        System.debug('================================ grupo.coberturas.size(): ' + grupo.coberturas.size());
                                       
                                        break;
                                    }
                                }
                            }

                            for (OrcamentoTO.SeguradoTO segurado : grupo.segurados){
                                for (OrcamentoTO.ContratanteTO contratanteSf : payloadOrcamento.solicitacaoOferta.contratantes){
                                    for (OrcamentoTO.GrupoTO grupoSf : contratanteSf.grupos){
                                        for (OrcamentoTO.SeguradoTO seguradoSf : grupoSf.segurados){
                                            if (segurado.numero == seguradoSf.numero){
                                                SeguradoOrcamento__c vo1 = seguradoSf.objSf;
                                                vo1.PremioPuro__c = segurado.premio.puro;
                                                vo1.PremioComercial__c = segurado.premio.comercial;
                                                vo1.TaxaPura__c = segurado.taxa.pura;
                                                vo1.TaxaComercial__c = segurado.taxa.comercial;
                                                listaSeguradosOrcamentosParaAtualizar.add(vo1);
                                                break;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // UPDATE
                try{
                    update listOppUpdate;
                    insert listCriticas;
                    //TODO: eric
                    //update listGarantiasOrcamentoParaAtualizar;
                    update listaContratantesOrcamentosParaAtualizar;
                    update listaGruposOrcamentosParaAtualizar;
                    update listaSeguradosOrcamentosParaAtualizar;

                }
                catch(Exception e){
                    System.debug(e.getLineNumber() + ': ' + e.getMessage());
                    throw new OrcamentoException(e.getLineNumber() + ': ' + e.getMessage());
                }
            }
            catch(Exception e){
                throw new OrcamentoException('Erro ao gerar os contratantes do orçamento. ERRO 3: ' + e.getLineNumber() +' |' + e.getMessage());
            }
            // END -------------------------------------------------------------


            // GARANTIAS DO ORÇAMENTO (1616)
            //Varre o Payload p/ criar as garantias de Orcamento, Contratante, Grupo e Segurado
            for(OrcamentoTO payloadOrcamento : objPayload.orcamentos){
                Map<String, List<GarantiaContratanteOrcamento__c>> mapGarantiasOrcamentos = new Map<String, List<GarantiaContratanteOrcamento__c>>();
                String chaveOrcamento = payloadOrcamento.solicitacaoOferta.numeroOrcamento;

                for(OrcamentoTO.ContratanteTO contratante : payloadOrcamento.solicitacaoOferta.contratantes){
                    Map<String, List<GarantiaGrupoOrcamento__c>> mapGarantiasGruposContratante = new Map<String, List<GarantiaGrupoOrcamento__c>>();
           
                    for(OrcamentoTO.GrupoTO grupo : contratante.grupos){
                        Map<String, List<GarantiaSeguradoOrcamento__c>> mapGarantiasSegGrupo = new Map<String, List<GarantiaSeguradoOrcamento__c>>();
                        // inclui segurados dos segurados
                        for(OrcamentoTO.SeguradoTO segurado : grupo.segurados){
                            for(OrcamentoTO.CoberturaTO cobertura : segurado.coberturas){
                                for(GarantiaProduto__c garantia : mapGarantiasPorOrcamentos.get(chaveOrcamento)){
                                    if(cobertura.sigla == garantia.Garantia__r.Sigla__c){



                                        GarantiaSeguradoOrcamento__c garantiaSeguradoOrc = new GarantiaSeguradoOrcamento__c();
                                        
                                        garantiaSeguradoOrc.SeguradoOrcamento__c = segurado.objSf.Id;
                                        garantiaSeguradoOrc.Garantia__c          = garantia.Garantia__c;
                                        garantiaSeguradoOrc.GarantiaProduto__c   = garantia.Id;

                                        garantiaSeguradoOrc.Capital__c           = cobertura.capital;
                                        garantiaSeguradoOrc.TaxaComercial__c     = cobertura.taxa.comercial;
                                        garantiaSeguradoOrc.TaxaPura__c          = cobertura.taxa.pura;
                                        garantiaSeguradoOrc.PremioComercial__c   = cobertura.premio.comercial;
                                        garantiaSeguradoOrc.PremioPuro__c        = cobertura.premio.puro;
                                        
                                        garantiaSeguradoOrc.IncluirIndenizacaoEspecial__c       = cobertura.inclusaoIndenizacaoEspecial == SIM ? true : false;
                                        garantiaSeguradoOrc.PercentualIndenizacaoEspecial__c    = cobertura.percentualIndenizacaoEspecial;
                                        garantiaSeguradoOrc.IncluirFilhos__c                    = cobertura.inclusaoFilhos == SIM ? true : false;
                                        garantiaSeguradoOrc.PercentualFilhos__c                 = cobertura.percentualFilhos;
                                        garantiaSeguradoOrc.CurrencyIsoCode                     = garantia.CurrencyIsoCode; //PLV-3884 - INICIO/FIM
                                        
                                        if(cobertura.percentual != null) garantiaSeguradoOrc.PercentualReferenciado__c = cobertura.percentual;

                                        if(cobertura.valor != null) garantiaSeguradoOrc.Valor__c = cobertura.valor;

                                        if(cobertura.agravo != null){
                                            garantiaSeguradoOrc.Percentual__c = cobertura.agravo;
                                            garantiaSeguradoOrc.DescontoAgravo__c = 'Agravo';
                                        }

                                        if(cobertura.desconto != null){
                                            garantiaSeguradoOrc.Percentual__c = cobertura.desconto;
                                            garantiaSeguradoOrc.DescontoAgravo__c = 'Desconto';
                                        }

                                        try{
                                            if (cobertura.moeda != null){
                                                Decimal valorCotacao = mapMoedaCotacao.get(cobertura.moeda);
                                                garantiaSeguradoOrc.CurrencyIsoCode = cobertura.moeda;
                                                garantiaSeguradoOrc.ValorCotacao__c = valorCotacao;
                                            }
                                        }
                                        catch(Exception e){
                                            throw new OrcamentoException('Moeda informada não existe no Salesforce: ' + cobertura.moeda);
                                        }


                                        cobertura.objSf = garantiaSeguradoOrc;
                                        listaGarantiasSeguradosOrcamento.add(garantiaSeguradoOrc);
                                    }
                                }
                            }
                        }
                        mapGarantiasSegGrupo.put(grupo.objSf.Id, listaGarantiasSeguradosOrcamento);

                        // Inclui garantias dos grupos
                        // varre os segurados do grupo p/ incluir as garantias do grupo, somando de acordo com a garantia do produto
                        Set<Id> setGarantiasSeguradoOrc = new Set<Id>();
                        for(GarantiaSeguradoOrcamento__c garantiaSeguradoOrc : mapGarantiasSegGrupo.get(grupo.objSf.Id))
                        {
                            // verifica se ja existe uma garantia com a mesma ligla
                            if(!setGarantiasSeguradoOrc.contains(garantiaSeguradoOrc.Garantia__c))
                            {
                                GarantiaGrupoOrcamento__c garantiaGrupoOrc          = new GarantiaGrupoOrcamento__c();

                                garantiaGrupoOrc.GrupoOrcamento__c                  = grupo.objSf.Id;
                                garantiaGrupoOrc.Garantia__c                        = garantiaSeguradoOrc.Garantia__c;
                                garantiaGrupoOrc.GarantiaProduto__c                 = garantiaSeguradoOrc.GarantiaProduto__c;
                                garantiaGrupoOrc.Capital__c                         = garantiaSeguradoOrc.Capital__c;
                                garantiaGrupoOrc.TaxaComercial__c                   = garantiaSeguradoOrc.TaxaComercial__c;
                                garantiaGrupoOrc.TaxaPura__c                        = garantiaSeguradoOrc.TaxaPura__c;
                                garantiaGrupoOrc.PremioComercial__c                 = garantiaSeguradoOrc.PremioComercial__c;
                                garantiaGrupoOrc.PremioPuro__c                      = garantiaSeguradoOrc.PremioPuro__c;
                                garantiaGrupoOrc.IncluirIndenizacaoEspecial__c      = garantiaSeguradoOrc.IncluirIndenizacaoEspecial__c;
                                garantiaGrupoOrc.PercentualIndenizacaoEspecial__c   = garantiaSeguradoOrc.PercentualIndenizacaoEspecial__c;
                                garantiaGrupoOrc.IncluirFilhos__c                   = garantiaSeguradoOrc.IncluirFilhos__c;
                                garantiaGrupoOrc.PercentualFilhos__c                = garantiaSeguradoOrc.PercentualFilhos__c;
                                garantiaGrupoOrc.CurrencyIsoCode                    = garantiaSeguradoOrc.CurrencyIsoCode;
                                garantiaGrupoOrc.PercentualReferenciado__c          = garantiaSeguradoOrc.PercentualReferenciado__c;
                                garantiaGrupoOrc.Valor__c                           = garantiaSeguradoOrc.Valor__c;
                                garantiaGrupoOrc.Percentual__c                      = garantiaSeguradoOrc.Percentual__c;
                                garantiaGrupoOrc.DescontoAgravo__c                  = garantiaSeguradoOrc.DescontoAgravo__c;
                                garantiaGrupoOrc.Percentual__c                      = garantiaSeguradoOrc.Percentual__c;
                                garantiaGrupoOrc.DescontoAgravo__c                  = garantiaSeguradoOrc.DescontoAgravo__c;
                                garantiaGrupoOrc.CurrencyIsoCode                    = garantiaSeguradoOrc.CurrencyIsoCode; //PLV-3884 - INICIO/FIM
                                garantiaGrupoOrc.ValorCotacao__c                    = garantiaSeguradoOrc.ValorCotacao__c;
                                
                                listaGarantiasGrupoOrcamento.add(garantiaGrupoOrc);
                                setGarantiasSeguradoOrc.add(garantiaSeguradoOrc.Garantia__c);
                            }
                        }
                    }
                    mapGarantiasGruposContratante.put(contratante.objSf.Id, listaGarantiasGrupoOrcamento);

                    // Inclui garantias dos contratantes
                    // Varre a lista de grupos do contratante p/ inserir as garantias
                    Set<Id> setGarantiasGrupoOrc = new Set<Id>();
                    for(GarantiaGrupoOrcamento__c garantiaGrupoOrc : mapGarantiasGruposContratante.get(contratante.objSf.Id)){
                        if(!setGarantiasGrupoOrc.contains(garantiaGrupoOrc.Garantia__c)){
                            GarantiaContratanteOrcamento__c garantiaContratanteOrc = new GarantiaContratanteOrcamento__c();

                            garantiaContratanteOrc.ContratanteOrcamento__c            = contratante.objSf.Id;
                            garantiaContratanteOrc.Garantia__c                        = garantiaGrupoOrc.Garantia__c;
                            garantiaContratanteOrc.GarantiaProduto__c                 = garantiaGrupoOrc.GarantiaProduto__c;
                            garantiaContratanteOrc.Capital__c                         = garantiaGrupoOrc.Capital__c;
                            garantiaContratanteOrc.TaxaComercial__c                   = garantiaGrupoOrc.TaxaComercial__c;
                            garantiaContratanteOrc.TaxaPura__c                        = garantiaGrupoOrc.TaxaPura__c;
                            garantiaContratanteOrc.PremioComercial__c                 = garantiaGrupoOrc.PremioComercial__c;
                            garantiaContratanteOrc.PremioPuro__c                      = garantiaGrupoOrc.PremioPuro__c;
                            garantiaContratanteOrc.IncluirIndenizacaoEspecial__c      = garantiaGrupoOrc.IncluirIndenizacaoEspecial__c;
                            garantiaContratanteOrc.PercentualIndenizacaoEspecial__c   = garantiaGrupoOrc.PercentualIndenizacaoEspecial__c;
                            garantiaContratanteOrc.IncluirFilhos__c                   = garantiaGrupoOrc.IncluirFilhos__c;
                            garantiaContratanteOrc.PercentualFilhos__c                = garantiaGrupoOrc.PercentualFilhos__c;
                            garantiaContratanteOrc.CurrencyIsoCode                    = garantiaGrupoOrc.CurrencyIsoCode;
                            garantiaContratanteOrc.PercentualReferenciado__c          = garantiaGrupoOrc.PercentualReferenciado__c;
                            garantiaContratanteOrc.Valor__c                           = garantiaGrupoOrc.Valor__c;
                            garantiaContratanteOrc.Percentual__c                      = garantiaGrupoOrc.Percentual__c;
                            garantiaContratanteOrc.DescontoAgravo__c                  = garantiaGrupoOrc.DescontoAgravo__c;
                            garantiaContratanteOrc.Percentual__c                      = garantiaGrupoOrc.Percentual__c;
                            garantiaContratanteOrc.DescontoAgravo__c                  = garantiaGrupoOrc.DescontoAgravo__c;
                            garantiaContratanteOrc.CurrencyIsoCode                    = garantiaGrupoOrc.CurrencyIsoCode;
                            garantiaContratanteOrc.ValorCotacao__c                    = garantiaGrupoOrc.ValorCotacao__c;
                            
                            listaGarantiasContratantesOrcamento.add(garantiaContratanteOrc);
                            setGarantiasGrupoOrc.add(garantiaGrupoOrc.Garantia__c);
                        }
                    }
                }
                mapGarantiasOrcamentos.put(chaveOrcamento, listaGarantiasContratantesOrcamento);
                
                // Inclui garantias do Orcwmento
                // Varre a lista de contratantes p/ inserir as garantias
                Set<Id> setGarantiasGrupoOrc = new Set<Id>();
                for(GarantiaContratanteOrcamento__c garantiaContratanteOrc : mapGarantiasOrcamentos.get(chaveOrcamento)){
                    if(!setGarantiasGrupoOrc.contains(garantiaContratanteOrc.Garantia__c)){
                        GarantiaOrcamento__c garantiaOrc = new GarantiaOrcamento__c();

                        garantiaOrc.Orcamento__c                       = mapOrcamentoOportunidade.get(chaveOrcamento).Id;
                        garantiaOrc.Garantia__c                        = garantiaContratanteOrc.Garantia__c;
                        garantiaOrc.GarantiaProduto__c                 = garantiaContratanteOrc.GarantiaProduto__c;
                        garantiaOrc.Capital__c                         = garantiaContratanteOrc.Capital__c;
                        garantiaOrc.TaxaComercial__c                   = garantiaContratanteOrc.TaxaComercial__c;
                        garantiaOrc.TaxaPura__c                        = garantiaContratanteOrc.TaxaPura__c;
                        garantiaOrc.PremioComercial__c                 = garantiaContratanteOrc.PremioComercial__c;
                        garantiaOrc.PremioPuro__c                      = garantiaContratanteOrc.PremioPuro__c;
                        garantiaOrc.CurrencyIsoCode                    = garantiaContratanteOrc.CurrencyIsoCode;
                        garantiaOrc.Percentual__c                      = garantiaContratanteOrc.Percentual__c;
                        garantiaOrc.DescontoAgravo__c                  = garantiaContratanteOrc.DescontoAgravo__c;
                        garantiaOrc.Percentual__c                      = garantiaContratanteOrc.Percentual__c;
                        garantiaOrc.DescontoAgravo__c                  = garantiaContratanteOrc.DescontoAgravo__c;
                        garantiaOrc.CurrencyIsoCode                    = garantiaContratanteOrc.CurrencyIsoCode;
                
                        listaGarantiasOrcamento.add(garantiaOrc);
                        setGarantiasGrupoOrc.add(garantiaContratanteOrc.Garantia__c);
                    }
                }
            }

            try{
                insert listaGarantiasOrcamento;
                insert listaGarantiasContratantesOrcamento;
                insert listaGarantiasGrupoOrcamento;
                insert listaGarantiasSeguradosOrcamento;
            }
            catch(Exception e){
                success = false;
                Database.rollback(sp);
                System.debug(e.getLineNumber() + ': ' + e.getMessage());
                throw new OrcamentoException(e.getLineNumber() + ': ' + e);

            }


            ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Q

            // GERAR Remunerações do Orçamento (RemuneracaoOrcamento__c)
            Map<String, List<RemuneracaoOrcamento__c>> mapOrcamentosRemuneracoes = this.gerarRemuneracaoOportunidade(objPayload.orcamentos, mapOrcamentoOportunidade);
            // END -------------------------------------------------------------

            // GERAR Retorno REST
            Map<String, String> mapRetorno = new Map<String, String>();
            for (String chaveOrcamento : mapOrcamentoOportunidade.keySet()) 
                mapRetorno.put(chaveOrcamento, String.valueOf(mapOrcamentoOportunidade.get(chaveOrcamento).Id));
          

                // TODO ERIC
            //retorno = new RetornoRestTO(mapRetorno.values().get(0), mapRetorno);
            success = true;
            // END -------------------------------------------------------------

            System.debug('Orcamento Payload ----------------------- ' + objPayload);
            System.debug('Orcamento ----------------------- ' + listOppUpdate);

            // Itera os orcamentos
            List<Opportunity> listOrcamentoParaCancelar = new List<Opportunity>();
            // Verifica se eh orcamento de Cancelamento
            for(Opportunity orcamento : listOppUpdate)
            {
                if(orcamento.Type == 'Cancelamento')
                    listOrcamentoParaCancelar.add(orcamento);
            }

            // Gera a proposta cancelamento
            if(!listOrcamentoParaCancelar.isEmpty())
                OrcamentoBO.gerarPropostaCancelamento(listOrcamentoParaCancelar,objPayload);

        }
        catch(Exception e) 
        {
            success = false;
            Database.rollback(sp);
            System.debug(e.getLineNumber() + ': ' + e.getMessage());
            throw new OrcamentoException(e.getLineNumber() + ': ' + e);
        }
        finally 
        {
            //if (success && Test.isRunningTest()) 
            //{
            System.debug('');
            System.debug('========================================================================');
            System.debug('::: JSON Payload');
            System.debug(JSON.serialize(objPayload));
            System.debug('========================================================================');
            //}
        }

        if (!Test.isRunningTest()) 
        {
            System.debug('');
            System.debug('//////////////////////////////////////////');
            System.debug('/// LIMITS Orçamento');
            System.debug('//////////////////////////////////////////');
            System.debug('///               Cpu Time: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime());
            System.debug('///              Heap Size: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());
            System.debug('///               DML Rows: ' + Limits.getDMLRows() + '/' + Limits.getLimitDMLRows());
            System.debug('///         DML Statements: ' + Limits.getDMLStatements() + '/' + Limits.getLimitDMLStatements());
            System.debug('///                Queries: ' + Limits.getQueries() + '/' + Limits.getLimitQueries());
            System.debug('///             Query Rows: ' + Limits.getQueryRows() + '/' + Limits.getLimitQueryRows());
            System.debug('///      Query LocatorRows: ' + Limits.getQueryLocatorRows() + '/' + Limits.getLimitQueryLocatorRows());
            System.debug('///           SOSL Queries: ' + Limits.getSoslQueries() + '/' + Limits.getLimitSoslQueries());
            System.debug('///      Aggregate Queries: ' + Limits.getAggregateQueries() + '/' + Limits.getLimitAggregateQueries());
            System.debug('///           Future Calls: ' + Limits.getFutureCalls() + '/' + Limits.getLimitFutureCalls());
            System.debug('///         Queueable Jobs: ' + Limits.getQueueableJobs() + '/' + Limits.getLimitQueueableJobs());
            System.debug('/// Mobile Push Apex Calls: ' + Limits.getMobilePushApexCalls() + '/' + Limits.getLimitMobilePushApexCalls());
            System.debug('///      Email Invocations: ' + Limits.getEmailInvocations() + '/' + Limits.getLimitEmailInvocations());
            System.debug('//////////////////////////////////////////');
            System.debug('');
        }

        System.debug('');
        System.debug('========================================================================');
        System.debug('::: JSON Retorno');
        //System.debug('::: ' + JSON.serialize(retorno.ids, true));
        System.debug('========================================================================');

        return retorno;
    }
   
    private Map<String, List<GarantiaProduto__c>> agruparGarantiasOrcamento(List<OrcamentoTO> listOrcamentos) 
    {
        Map<String, List<GarantiaProduto__c>> mapRetorno = new Map<String, List<GarantiaProduto__c>>();
        Map<String, Set<String>> mapOrcamentosSiglasGarantias = new Map<String, Set<String>>();
        Map<String, Set<String>> mapSiglasGarantiasOrcamento = new Map<String, Set<String>>();
        Set<Id> idsProdutos = new Set<Id>();

        // primeiro loop para extrair as siglas e montando 2 mapas para associação no segundo loop
        for (OrcamentoTO payloadOrcamento : listOrcamentos) 
        {
            Product2 produto = produtoBo.buscarProdutoPorCodigoVigencia(payloadOrcamento.solicitacaoOferta.codigoProdutoVida, payloadOrcamento.solicitacaoOferta.vigenciaInicial, payloadOrcamento.solicitacaoOferta.vigenciaFinal);
            System.debug('buscarProdutoPorCodigoVigencia');
            System.debug(produto);
            idsProdutos.add(produto.Id);

            String chaveOrcamento = payloadOrcamento.solicitacaoOferta.numeroOrcamento;

            for (OrcamentoTO.ContratanteTO contratante : payloadOrcamento.solicitacaoOferta.contratantes) 
            {
                for (OrcamentoTO.GrupoTO grupo : contratante.grupos) 
                {
                    if(grupo.coberturas != null) 
                    {
                        for (OrcamentoTO.CoberturaTO cobertura : grupo.coberturas) 
                        {
                            String siglaCobertura = cobertura.sigla;

                            if (!mapOrcamentosSiglasGarantias.containsKey(chaveOrcamento)) 
                                mapOrcamentosSiglasGarantias.put(chaveOrcamento, new Set<String>());

                            if (!mapSiglasGarantiasOrcamento.containsKey(siglaCobertura)) 
                                mapSiglasGarantiasOrcamento.put(siglaCobertura, new Set<String>());

                            mapOrcamentosSiglasGarantias.get(chaveOrcamento).add(siglaCobertura);
                            mapSiglasGarantiasOrcamento.get(siglaCobertura).add(chaveOrcamento);
                        }
                    }

                    for (OrcamentoTO.SeguradoTO segurado : grupo.segurados) 
                    {
                        for (OrcamentoTO.CoberturaTO cobertura : segurado.coberturas) 
                        {
                            String siglaCobertura = cobertura.sigla;

                            if(!mapOrcamentosSiglasGarantias.containsKey(chaveOrcamento)) 
                                mapOrcamentosSiglasGarantias.put(chaveOrcamento, new Set<String>());

                            if(!mapSiglasGarantiasOrcamento.containsKey(siglaCobertura)) 
                                mapSiglasGarantiasOrcamento.put(siglaCobertura, new Set<String>());

                            mapOrcamentosSiglasGarantias.get(chaveOrcamento).add(siglaCobertura);
                            mapSiglasGarantiasOrcamento.get(siglaCobertura).add(chaveOrcamento);
                        }
                    }
                }
            }
        }

        List<GarantiaProduto__c> garantiasProduto = GarantiaProdutoDAO.getInstance().buscarGarantiasProdutoObrigatoriasPorProdutoId(idsProdutos);
        System.debug('garantiasProduto');
        System.debug(garantiasProduto);

        for (OrcamentoTO payloadOrcamento : listOrcamentos) 
        {
            String chaveOrcamento = payloadOrcamento.solicitacaoOferta.numeroOrcamento;

            for (GarantiaProduto__c garantiaProduto : garantiasProduto) 
            {
                if (!mapSiglasGarantiasOrcamento.containsKey(garantiaProduto.Garantia__r.Sigla__c)) 
                    throw new OrcamentoException('Garantia do produto não encontrada no orçamento. Sigla: ' + garantiaProduto.Garantia__r.Sigla__c);
                if (mapSiglasGarantiasOrcamento.get(garantiaProduto.Garantia__r.Sigla__c).contains(chaveOrcamento)) 
                {
                    if(!mapRetorno.containsKey(chaveOrcamento)) 
                        mapRetorno.put(chaveOrcamento, new List<GarantiaProduto__c>());
                    mapRetorno.get(chaveOrcamento).add(garantiaProduto);
                }
            }
        }

        return mapRetorno;
    }

    private Map<String, List<RemuneracaoOrcamento__c>> gerarRemuneracaoOportunidade(List<OrcamentoTO> listOrcamentos, Map<String, Opportunity> orcamentosOportunidades) 
    {
        Map<String, List<RemuneracaoOrcamento__c>> mapRetorno = new Map<String, List<RemuneracaoOrcamento__c>>();
        Map<String, Set<String>> mapOrcamentoDocumentosAgentes = new Map<String, Set<String>>();
        Map<String, List<OrcamentoTO.AgenteTO>> mapOrcamentosAgentes = new Map<String, List<OrcamentoTO.AgenteTO>>();

        Map<String, TipoRemuneracao__c> mapTiposRemuneracoes = new Map<String, TipoRemuneracao__c>();

        Set<String> tiposRemuneracoes = new Set<String>();
        for (OrcamentoTO payloadOrcamento : listOrcamentos) 
        {
            for (OrcamentoTO.AgenteTO agente : payloadOrcamento.solicitacaoOferta.remuneracao.agentes) 
                tiposRemuneracoes.add(mapPapelTipoRemuneracao.get(agente.papel));
        }

        List<TipoRemuneracao__c> listTiposRemuneracoes = [SELECT Id, Name, Descricao__c, LimiteMinimo__c, LimiteMaximo__c, ModeloRecuperacao__c FROM TipoRemuneracao__c WHERE Name IN :tiposRemuneracoes];
        for (TipoRemuneracao__c tipoRemuneracao : listTiposRemuneracoes) 
            mapTiposRemuneracoes.put(tipoRemuneracao.Name, tipoRemuneracao);

        // ORCAMENTOS
        for (OrcamentoTO payloadOrcamento : listOrcamentos) 
        {
            String chaveOrcamento = payloadOrcamento.solicitacaoOferta.numeroOrcamento;
            Set<String> documentosAgentes = new Set<String>();

            // REMUNERACAO
            if(!mapOrcamentosAgentes.containsKey(chaveOrcamento)) 
                mapOrcamentosAgentes.put(chaveOrcamento, new List<OrcamentoTO.AgenteTO>());

            mapOrcamentosAgentes.get(chaveOrcamento).addAll(payloadOrcamento.solicitacaoOferta.remuneracao.agentes);

            // AGENTES
            for (OrcamentoTO.AgenteTO agente : payloadOrcamento.solicitacaoOferta.remuneracao.agentes) 
            {
                String documento;
                if (agente.pessoa.tipo == PESSOA_JURIDICA) 
                    documento = agente.pessoa.dadosPessoaJuridica.numeroCnpj + agente.pessoa.dadosPessoaJuridica.ordemCnpj + agente.pessoa.dadosPessoaJuridica.digitoCnpj;
                else if (agente.pessoa.tipo == PESSOA_FISICA) 
                    documento = agente.pessoa.dadosPessoaFisica.numeroCpf + agente.pessoa.dadosPessoaFisica.digitoCpf;
                documentosAgentes.add(documento);
            }

            if (documentosAgentes.size() > 0) 
                mapOrcamentoDocumentosAgentes.put(chaveOrcamento, documentosAgentes);
            else 
                throw new OrcamentoException('AGENTE_SEM_DOCUMENTO - Todos os agentes precisam de documentação.');
        }

        // Agrupar todos os documentos de todos Orçamentos
        Set<String> documentosTodosAgentes = new Set<String>();
        for (String chaveOrcamento : mapOrcamentoDocumentosAgentes.keySet()) 
        {
            for (String documento : mapOrcamentoDocumentosAgentes.get(chaveOrcamento)) 
                documentosTodosAgentes.add(documento);
        }

        // Acumular TODAS as contas de TODOS os orçamentos 
        List<Account> contasAgentesOrcamento = AccountDAO.getInstance().buscarContasPorIdExterno(documentosTodosAgentes);
        //System.debug('::: contasAgentesOrcamento: ' + JSON.serialize(contasAgentesOrcamento));

        Map<String, Id> mapDocumentoContaAgente = new Map<String, Id>();
        for (Account contaAgente : contasAgentesOrcamento) 
            mapDocumentoContaAgente.put(contaAgente.IdExterno__c, contaAgente.Id);

        Map<String, Set<Id>> mapOrcamentosIdContasAgentes = new Map<String, Set<Id>>();

        for (String chaveOrcamento : mapOrcamentoDocumentosAgentes.keySet()) 
        {
            Set<Id> idsContasAgentes = new Set<Id>();
            for (Account conta : contasAgentesOrcamento) 
            {
                Set<String> documentos = mapOrcamentoDocumentosAgentes.get(chaveOrcamento);
                if (documentos.contains(conta.IdExterno__c)) 
                    idsContasAgentes.add(conta.Id);
            }
            mapOrcamentosIdContasAgentes.put(chaveOrcamento, idsContasAgentes);
        }

        //System.debug('::: mapOrcamentosIdContasAgentes: ' + JSON.serialize(mapOrcamentosIdContasAgentes));
        List<RemuneracaoOrcamento__c> remuneracoesParaInserir = new List<RemuneracaoOrcamento__c>();

        for (String chaveOrcamento : mapOrcamentoDocumentosAgentes.keySet()) 
        {
            for (OrcamentoTO.AgenteTO agente : mapOrcamentosAgentes.get(chaveOrcamento)) 
            {
                String documento;
                if (agente.pessoa.tipo == PESSOA_JURIDICA) 
                    documento = agente.pessoa.dadosPessoaJuridica.numeroCnpj + agente.pessoa.dadosPessoaJuridica.ordemCnpj + agente.pessoa.dadosPessoaJuridica.digitoCnpj;
                else if (agente.pessoa.tipo == PESSOA_FISICA) 
                    documento = agente.pessoa.dadosPessoaFisica.numeroCpf + agente.pessoa.dadosPessoaFisica.digitoCpf;

                Decimal valorRemuneracao;
                if (agente.papel == PAPEL_CORRETOR) 
                    valorRemuneracao = agente.corretagem;
                else if (agente.papel == PAPEL_AGENCIADOR) 
                    valorRemuneracao = agente.agenciamento;
                else if (agente.papel == PAPEL_REPRESENTANTE) 
                    valorRemuneracao = agente.proLabore;
                else if (agente.papel == PAPEL_ASSESSORIA) 
                    valorRemuneracao = agente.assessoria;
                else if (agente.papel == PAPEL_COMISSAO) 
                    valorRemuneracao = agente.comissao;

                System.debug('mapTiposRemuneracoes');
                System.debug(mapTiposRemuneracoes);

                System.debug('agente.papel');
                System.debug(agente.papel);

                System.debug('mapPapelTipoRemuneracao');
                System.debug(mapPapelTipoRemuneracao);

                if (mapTiposRemuneracoes.containsKey(mapPapelTipoRemuneracao.get(agente.papel))) 
                {
                    RemuneracaoOrcamento__c remuneracao = new RemuneracaoOrcamento__c();
                    remuneracao.Oportunidade__c = orcamentosOportunidades.get(chaveOrcamento).Id;
                    remuneracao.Percentual__c = valorRemuneracao;
                    remuneracao.TipoRemuneracao__c = mapTiposRemuneracoes.get(mapPapelTipoRemuneracao.get(agente.papel)).Id;
                    remuneracoesParaInserir.add(remuneracao);

                    if(!mapRetorno.containsKey(chaveOrcamento)) 
                        mapRetorno.put(chaveOrcamento, new List<RemuneracaoOrcamento__c>());

                    mapRetorno.get(chaveOrcamento).add(remuneracao);
                }
                else 
                {
                    throw new OrcamentoException('TIPO_REMUNERACAO_AUSENTE - Tipo de remuneração não cadastrada no Salesforce.');
                }
            }
        }

        try 
        {
            insert remuneracoesParaInserir;
        }
        catch(Exception e) 
        {
            System.debug(e.getLineNumber() + ': ' + e.getMessage());
            throw new OrcamentoException(e.getLineNumber() + ': ' + e.getMessage());
        }

        return mapRetorno;
    }

    private Map<Integer, Account> gerarContasOferta(OrcamentoTO orcamento, Account contaResponsavelOferta, Map<String, List<OrcamentoTO.EnderecoTO>> mapEnderecos)
    {
        Map<Integer, Account> mapRetorno = new Map<Integer, Account>();
        //Salva conta principal para que seja possível gerar as contas filhas
        contaBo.salvarContasOferta(new List<Account>
        {contaResponsavelOferta});

        // processa os restantes dos contratantes contratante(s)
        List<Account> contas = new List<Account>();
        for(OrcamentoTO.ContratanteTO contratante : orcamento.solicitacaoOferta.contratantes) 
        {
            Account conta = this.gerarParseConta(contratante, contaResponsavelOferta.Id, false);
            mapRetorno.put(contratante.numero, conta);
            if(conta != null)
                contas.add(conta);
        }

        //Salva as outras contas
        contaBo.salvarContasOferta(contas);

        //Realiza criação dos endereços das contas
        contas.add(contaResponsavelOferta);
        this.gerarEnderecosContas(contas, mapEnderecos);

        return mapRetorno;
        //return contaResponsavelOferta.Id;
    }

    //Gera os endereços das contas criadas
    private void gerarEnderecosContas(List<Account> contas, Map<String, List<OrcamentoTO.EnderecoTO>> mapEnderecos)
    {
        Id tipoRegistroPessoaFisica = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica').Id;
        List<Endereco__c> enderecosConta = new List<Endereco__c>();
        Set<String> setContas = new Set<String>();
        Map<String, Endereco__c> mapEnderecosConta = new Map<String, Endereco__c>();

        for(Account conta : contas)
            setContas.add(conta.IdExterno__c);

        for(Account conta : AccountDAO.getInstance().buscarContasPorIdExterno(setContas))
        {
            for(Endereco__c endereco : conta.Enderecos__r)
                mapEnderecosConta.put(conta.Id + endereco.Logradouro__c + endereco.numero__c + endereco.Cidade__c + endereco.Estado__c, endereco);
        }

        for(Account conta : contas)
        {
            String cpfCnpj = '';

            if(conta.RecordTypeId == tipoRegistroPessoaFisica)
                cpfCnpj = conta.Cpf__c;
            else
                cpfCnpj = conta.CNPJ__c;

            enderecosConta.addAll(this.gerarParseEndereco(conta.Id, mapEnderecos.get(cpfCnpj), mapEnderecosConta));
        }

        //Salva os endereços das contas
        contaBo.salvarEnderecosContas(enderecosConta);
    }

    //Gera a oportunidade referente a oferta
    private Opportunity gerarOportunidadeOferta(OrcamentoTO orcamento, Id contaResponsavelId)
    {
        Map<String, String> mapTipoSeguro = new Map<String, String>
        {'NOV' => 'Seguro novo', 'REN' => 'Renovação', 'END' => 'Endosso', 'CAN' => 'Cancelamento'};
        Product2 produto = produtoBo.buscarProdutoPorCodigoVigencia(orcamento.solicitacaoOferta.codigoProdutoVida, orcamento.solicitacaoOferta.vigenciaInicial, orcamento.solicitacaoOferta.vigenciaFinal);
        Endereco__c enderecoPrincipal = EnderecoDAO.getInstance().buscarEnderecoConta(contaResponsavelId);

        CanalDistribuicao__c canalDistribuicaoOrcamento;

        System.debug('CANAL ' + orcamento.solicitacaoOferta.remuneracao.canal);

        try 
        {
            canalDistribuicaoOrcamento = CanalDistribuicaoDAO.getInstance().buscarCanalDistribuicaoOrcamentoPorSigla(orcamento.solicitacaoOferta.remuneracao.canal);
        }
        catch(Exception e) 
        {
            System.debug(e.getLineNumber() + ': ' + e.getMessage());
            throw new OrcamentoException('Canal de distribuição não encontrado.');
        }

        Opportunity oportunidade = new Opportunity(
            AccountId = contaResponsavelId,
            Produto__c = produto.Id,
            /*
            Endereco__c = enderecoPrincipal.Id,
            *
            Campo comentado para deletar Lookup Endereco__c de Opportunity
            Sprint 13, PLV-952
            Histórias relacionadas - PLV-953/959/999
            */
            FormaPagamento__c = produto.CondicoesCobranca__r.get(0).FormaPagamento__c,
            Name = orcamento.solicitacaoOferta.meioComercializacao + '-' + orcamento.solicitacaoOferta.numeroPortal,
            VigenciaInicial__c = orcamento.solicitacaoOferta.vigenciaInicial,
            VigenciaFinal__c = orcamento.solicitacaoOferta.vigenciaFinal,
            Type = mapTipoSeguro.get(orcamento.solicitacaoOferta.tipoSeguro),
            Description = orcamento.solicitacaoOferta.observacoesGerais,
            MeioComercializacao__c = orcamento.solicitacaoOferta.meioComercializacao,
            StageName = 'Em criação',
            CanalDistribuicao__c = canalDistribuicaoOrcamento.Id,
            CloseDate = System.today()
        );

        if (orcamento.solicitacaoOferta.dataCalculo != null) 
            oportunidade.DataCalculo__c = orcamento.solicitacaoOferta.dataCalculo;

        return oportunidadeBo.salvarOportunidadeOferta(oportunidade, orcamento.solicitacaoOferta.segmento);
    }

    //Gera parse de endereços
    private List<Endereco__c> gerarParseEndereco(Id contaId, List<OrcamentoTO.EnderecoTO> enderecos, Map<String, Endereco__c> mapEnderecosConta)
    {
        List<Endereco__c> enderecosConta = new List<Endereco__c>();
        Map<String, String> mapTipoEndereco = new Map<String, String>
        {'COM' => 'Comercial', 'REC' => 'Recado', 'RES' => 'Residencial', 'VER' => 'Veraneio'};
        Map<String, String> mapTipoLogradouro = new Map<String, String>
        {'A' => 'Alameda', 'AV' => 'Avenida', 'R' => 'Rua'};

        for(OrcamentoTO.EnderecoTO endereco : enderecos)
        {
            Id enderecoId = null;
            Endereco__c enderecoExistente = mapEnderecosConta.get(contaId + endereco.logradouro + endereco.numeroLogradouro + endereco.cidade + endereco.uf);

            if(enderecoExistente != null)
                enderecoId = enderecoExistente.Id;

            enderecosConta.add(
                new Endereco__c(
                    Id = enderecoId,
                    Conta__c = contaId,
                    TipoEndereco__c = mapTipoEndereco.get(endereco.tipoEndereco),
                    TipoLogradouro__c = mapTipoLogradouro.get(endereco.tipoLogradouro),
                    Logradouro__c = endereco.logradouro,
                    Numero__c = endereco.numeroLogradouro,
                    Complemento__c = endereco.complemento,
                    CEP__c = endereco.cep + endereco.complementoCep,
                    Cidade__c = endereco.cidade,
                    Estado__c = endereco.uf,
                    Pais__c = endereco.paisResidencia,
                    Bairro__c = endereco.bairro,
                    MaisAtual__c = true
                )
            );
        }

        return enderecosConta;
    }

    //Gera conta através de PessoaTO
    private Account gerarParseConta(OrcamentoTO.ContratanteTO contratante, Id contaPaiId, Boolean contaPrincipal)
    {
        System.debug('::: gerarParseConta, nome: ' + contratante.pessoa.nome);
        if(!contaPrincipal && contratante.tipo == PRINCIPAL)
            return null;

        Account conta;
        OrcamentoTO.DadosPessoaJuridicaTO dadosPessoaJuridica;
        OrcamentoTO.DadosPessoaFisicaTO dadosPessoaFisica;
        Map<String, String> mapEstadoCivil = new Map<String, String>
        {
            ESTADO_CIVIL_CASADO => 'Casado (a)',
            ESTADO_CIVIL_DIVORCIADO => 'Divorciado(a)',
            ESTADO_CIVIL_SOLTEIRO => 'Solteiro (a)',
            ESTADO_CIVIL_UNIAO_ESTAVEL => 'União estável',
            ESTADO_CIVIL_VIUVO => 'Viúvo(a)'
        };

        if (contratante.pessoa.tipo == PESSOA_FISICA) 
        {
            dadosPessoaFisica = contratante.pessoa.dadosPessoaFisica;
            String sexoConta = dadosPessoaFisica.sexo;
            dadosPessoaFisica.nacionalidade = String.isBlank(dadosPessoaFisica.nacionalidade) ? NACIONALIDADE_BRASILEIRA : dadosPessoaFisica.nacionalidade;
            dadosPessoaFisica.paisDeOrigem  = String.isBlank(dadosPessoaFisica.paisDeOrigem) ? '' : dadosPessoaFisica.paisDeOrigem; //PLV-5231 INICIO/FIM
            String nacionalidadeConta = dadosPessoaFisica.nacionalidade == NACIONALIDADE_BRASILEIRA ? 'Brasileira' : 'Estrangeira';

            if(cancelamento == false) 
            {
                if (dadosPessoaFisica.documentos == null || dadosPessoaFisica.documentos.isEmpty()) 
                    throw new OrcamentoException('CONTA_SEM_DOCUMENTO - Conta não possui documentos');
            }

            if(cancelamento == true)
            {
                conta = contaBo.preencherDadosContaPessoaFisica(
                    contaPaiId,
                    contratante.pessoa.nome,
                    contratante.pessoa.email,
                    dadosPessoaFisica.numeroCpf + dadosPessoaFisica.digitoCpf,
                    null,
                    null,
                    null,
                    dadosPessoaFisica.dataNascimento,
                    mapEstadoCivil.get(dadosPessoaFisica.estadoCivil),
                    nacionalidadeConta,                    
                    dadosPessoaFisica.profissao,
                    sexoConta,
                    //PLV-2720 - Inicio - Adição de parâmetro                    
                    //PLV-5231 INICIO
                    false,
                    null
                    //PLV-5231 FIM
                    //PLV-2720 - Fim - Adição de parâmetro
                );
            }
            else 
            {
                conta = contaBo.preencherDadosContaPessoaFisica(
                    contaPaiId,
                    contratante.pessoa.nome,
                    contratante.pessoa.email,
                    dadosPessoaFisica.numeroCpf + dadosPessoaFisica.digitoCpf,
                    dadosPessoaFisica.documentos[0].numeroDocumentoIdentidade,
                    dadosPessoaFisica.documentos[0].dataExpedicaoDocumento,
                    dadosPessoaFisica.documentos[0].orgaoExpedidorDocumento,
                    dadosPessoaFisica.dataNascimento,
                    mapEstadoCivil.get(dadosPessoaFisica.estadoCivil),
                    nacionalidadeConta,                    
                    dadosPessoaFisica.profissao,
                    sexoConta,
                    //PLV-2720 - Inicio - Adição de parâmetro
                    //PLV-5231 INICIO
                    false,
                    dadosPessoaFisica.paisDeOrigem 
                    //PLV-5231 FIM
                    //PLV-2720 - Fim - Adição de parâmetro
                );
            }
        }
        else if (contratante.pessoa.tipo == PESSOA_JURIDICA) 
        {
            dadosPessoaJuridica = contratante.pessoa.dadosPessoaJuridica;
            conta = contaBo.preencherDadosContaPessoaJuridica(contaPaiId, contratante.pessoa.nome, dadosPessoaJuridica.cnpj);
        }

        return conta;
    }

    //Gera payload de orçamento de cancelamento
    public List<OrcamentoTO> gerarOrcamentoCancelamento(OrcamentoTO orcamento)
    {
        OrcamentoTO.SolicitacaoOfertaTO solicitacaoOferta = orcamento.solicitacaoOferta;
        solicitacaoOferta.precificacao = new OrcamentoTO.PrecificacaoTO();
        solicitacaoOferta.precificacao.premio = new OrcamentoTO.PremioTO();

        ContractBO contratoBo = ContractBO.getInstance();
        Map<String, String> mapTipoVigencia = new Map<String, String> 
        { 'Anual' => 'ANU', 'Plurianual'  => 'PLU', 'Prazo curto' => 'CUR'};
        Set<Id> contaIds = new Set<Id>();
        Map<Id, List<Endereco__c>> enderecosConta = new Map<Id, List<Endereco__c>>();
        Map<Id, List<GrupoContrato__c>> gruposSegurado = new Map<Id, List<GrupoContrato__c>>();
        Map<Id, List<GarantiaGrupoContrato__c>> garantiasVida = new Map<Id, List<GarantiaGrupoContrato__c>>();

        //Realiza busca de todos os dados necessários da estrutura de contratato
        Contract contrato = contratoBo.buscarPorNumeroApolice(solicitacaoOferta.apolice);
        System.debug('Contrato ISA TEST ' + contrato.Name);
        List<ContratanteContrato__c> contratantes = contratoBo.buscarContratantesPorNumeroApolice(solicitacaoOferta.apolice);

        //Recupera todas as contas dos contratantes para
        for(ContratanteContrato__c contratante : contratantes)
            contaIds.add(contratante.Conta__c);

        //Monta map com os enderecos das contas
        for(Endereco__c endereco : EnderecoBO.getInstance().buscarEnderecosContas(contaIds))
        {
            if(!enderecosConta.containsKey(endereco.Conta__c))
                enderecosConta.put(endereco.Conta__c, new List<Endereco__c>());

            enderecosConta.get(endereco.Conta__c).add(endereco);
        }

        //Monta map com os grupos dos contratantes
        for(GrupoContrato__c grupo : contratoBo.buscarGruposPorNumeroApolice(solicitacaoOferta.apolice))
        {
            if(!gruposSegurado.containsKey(grupo.ContratanteContrato__c))
                gruposSegurado.put(grupo.ContratanteContrato__c, new List<GrupoContrato__c>());

            gruposSegurado.get(grupo.ContratanteContrato__c).add(grupo);
        }

        //Monta map com as garantias das segurados
        // for(GarantiaGrupoContrato__c garantia : contratoBo.buscarGarantiasContratantesPorNumeroApolice(solicitacaoOferta.apolice))
        //{
        //     if(!garantiasVida.containsKey(garantia.SeguradoContrato__c))
        //         garantiasVida.put(garantia.SeguradoContrato__c, new List<GarantiaGrupoContrato__c>());

        //     garantiasVida.get(garantia.SeguradoContrato__c).add(garantia);
        // }

        //Dados de cabeçalho
        solicitacaoOferta.numeroOrcamento = contrato.Proposta__r.Opportunity.Name;
        solicitacaoOferta.codigoProdutoVida = contrato.Proposta__r.Produto__r.ProductCode;
        solicitacaoOferta.tipoVigencia = mapTipoVigencia.get(contrato.Proposta__r.TipoVigencia__c);
        solicitacaoOferta.vigenciaInicial = contrato.Proposta__r.VigenciaInicial__c;
        solicitacaoOferta.vigenciaFinal = contrato.Proposta__r.VigenciaFinal__c;
        solicitacaoOferta.segmento = contrato.Proposta__r.RecordType.DeveloperName == 'VidaIndividual' ? 'VI' : 'VG';
        solicitacaoOferta.precificacao.premio.informado = contrato.Proposta__r.ValorPremio__c;

        //Dados de contratantes
        solicitacaoOferta.contratantes = this.gerarContratantesCancelamento(contratantes, gruposSegurado, enderecosConta, garantiasVida);

        return new List<OrcamentoTO>
        {orcamento};
    }

    //Gera toda a hierarquia de contratantes para gerar cancelamento
    private List<OrcamentoTO.ContratanteTO> gerarContratantesCancelamento(List<ContratanteContrato__c> contratantes, Map<Id, List<GrupoContrato__c>> gruposSegurado, Map<Id, List<Endereco__c>> enderecosConta, Map<Id, List<GarantiaGrupoContrato__c>> garantiasVida)
    {
        List<OrcamentoTO.ContratanteTO> contratantesTo = new List<OrcamentoTO.ContratanteTO>();
        Map<String, String> mapEstadoCivil = new Map<String, String>
        {'Casado (a)' => 'CAS', 'Divorciado(a)' => 'DIV','Solteiro (a)' => 'SOL','Viúvo(a)' => 'VIU', 'Separado(a)' => 'SEP', 'União estável' => 'UNI'};

        //Realiza processamento dos contratantes e da hieraquia abaixo dele
        for(ContratanteContrato__c contratante : contratantes)
        {
            OrcamentoTO.ContratanteTO seguradoTo = new OrcamentoTO.ContratanteTO();
            contratantesTo.add(seguradoTo);
            seguradoTo.tipo = contratante.Tipo__c == 'Principal' ? 'PRI' : 'DEP';

            //Monta hierarquia de grupos
            seguradoTo.grupos = this.gerarGruposSeguradoCancelamento(contratante, gruposSegurado, garantiasVida, mapEstadoCivil);

            //Gera nó de dados de pagamento
            seguradoTo.dadosPagamento = new OrcamentoTO.DadosPagamentoTO();
            seguradoTo.dadosPagamento.quantidadeParcelas = contratante.QuantidadeParcelas__c;
            seguradoTo.dadosPagamento.vencimentoPrimeiraParcela = contratante.VencimentoPrimeiraParcela__c;
            seguradoTo.dadosPagamento.tipoResponsavelPagamento = contratante.TipoResponsavelPagamento__c;

            //Gera nó de pessoa
            seguradoTo.pessoa = new OrcamentoTO.PessoaTO();
            seguradoTo.pessoa.enderecos = new List<OrcamentoTO.EnderecoTO>();
            seguradoTo.pessoa.telefones = new List<OrcamentoTO.TelefoneTO>();
            seguradoTo.pessoa.nome = contratante.Conta__r.Name;
            seguradoTo.pessoa.email = contratante.Conta__r.PersonEmail;

            if(String.isBlank(contratante.Conta__r.Cnpj__c))
            {
                seguradoTo.pessoa.tipo = 'FIS';
                seguradoTo.pessoa.dadosPessoaFisica = new OrcamentoTO.DadosPessoaFisicaTO();
                seguradoTo.pessoa.dadosPessoaFisica.sexo =  contratante.Conta__r.Sexo__c;
                seguradoTo.pessoa.dadosPessoaFisica.numeroCpf = contratante.Conta__r.Cpf__c.substring(0, contratante.Conta__r.Cpf__c.length() - 2);
                seguradoTo.pessoa.dadosPessoaFisica.digitoCpf =  contratante.Conta__r.Cpf__c.right(2);
                seguradoTo.pessoa.dadosPessoaFisica.nacionalidade =  contratante.Conta__r.Nacionalidade__c == 'Brasileira' ? 'BRA' : 'EST';
                seguradoTo.pessoa.dadosPessoaFisica.dataNascimento =  contratante.Conta__r.PersonBirthdate;

                if(mapEstadoCivil.containsKey(contratante.Conta__r.EstadoCivil__c))
                    seguradoTo.pessoa.dadosPessoaFisica.estadoCivil =  mapEstadoCivil.get(contratante.Conta__r.EstadoCivil__c);

            }
            else
            {
                seguradoTo.pessoa.tipo = 'JUR';
                seguradoTo.pessoa.dadosPessoaJuridica = new OrcamentoTO.DadosPessoaJuridicaTO();
                seguradoTo.pessoa.dadosPessoaJuridica.cnpj = contratante.Conta__r.Cnpj__c;
                seguradoTo.pessoa.dadosPessoaJuridica.codigoCNAE = Integer.valueOf(contratante.Conta__r.CNAE__c);
            }

            //Gera lista de telefones da pessoa
            if(String.isNotBlank(contratante.Conta__r.PersonHomePhone))
            {
                OrcamentoTO.TelefoneTO telefoneRes = new OrcamentoTO.TelefoneTO();
                telefoneRes.tipoTelefone = 'RES';
                telefoneRes.numeroTelefone = contratante.Conta__r.PersonHomePhone;
                seguradoTo.pessoa.telefones.add(telefoneRes);
            }

            if(String.isNotBlank(contratante.Conta__r.Phone))
            {
                OrcamentoTO.TelefoneTO telefoneCel = new OrcamentoTO.TelefoneTO();
                telefoneCel.tipoTelefone = 'CEL';
                telefoneCel.numeroTelefone = contratante.Conta__r.Phone;
                seguradoTo.pessoa.telefones.add(telefoneCel);
            }

            if(String.isNotBlank(contratante.Conta__r.PersonAssistantPhone))
            {
                OrcamentoTO.TelefoneTO telefoneCom = new OrcamentoTO.TelefoneTO();
                telefoneCom.tipoTelefone = 'COM';
                telefoneCom.numeroTelefone = contratante.Conta__r.PersonAssistantPhone;
                seguradoTo.pessoa.telefones.add(telefoneCom);
            }

            //Gera lista endereços da pessoa
            if(enderecosConta.containsKey(contratante.Conta__c))
            {
                for(Endereco__c endereco : enderecosConta.get(contratante.Conta__c))
                {
                    OrcamentoTO.EnderecoTO enderecoTo = new OrcamentoTO.EnderecoTO();
                    enderecoTo.tipoEndereco = String.isNotBlank(endereco.TipoEndereco__c) ? endereco.TipoEndereco__c.substring(0, 3).toUpperCase() : '';
                    enderecoTo.tipoLogradouro = String.isNotBlank(endereco.TipoLogradouro__c) ? endereco.TipoLogradouro__c.substring(0, 3).toUpperCase() : '';
                    enderecoTo.logradouro = endereco.Logradouro__c;
                    enderecoTo.numeroLogradouro =  endereco.Numero__c;
                    enderecoTo.bairro = endereco.Bairro__c;
                    enderecoTo.cidade = endereco.Cidade__c;
                    enderecoTo.uf = endereco.Estado__c;
                    enderecoTo.cep = endereco.CEP__c.substring(0, endereco.CEP__c.length() - 3);
                    enderecoTo.complementoCep = endereco.CEP__c.right(3);
                    enderecoTo.paisResidencia = endereco.Pais__c.substring(0, 3).toUpperCase();
                    seguradoTo.pessoa.enderecos.add(enderecoTo);
                }
            }
        }

        return contratantesTo;
    }

    //Gera toda a hierarquia de grupos do contratante para gerar cancelamento
    private List<OrcamentoTO.GrupoTO> gerarGruposSeguradoCancelamento(ContratanteContrato__c contratante, Map<Id, List<GrupoContrato__c>> gruposSegurado, Map<Id, List<GarantiaGrupoContrato__c>> garantiasVida, Map<String, String> mapEstadoCivil)
    {
        List<OrcamentoTO.GrupoTO> gruposTo = new List<OrcamentoTO.GrupoTO>();
        Integer contadorGrupo = 0;

        //Processa os grupos do contratante
        for(GrupoContrato__c grupo : gruposSegurado.get(contratante.Id))
        {
            contadorGrupo++;
            Integer contadorSegurados = 0;

            OrcamentoTO.GrupoTO grupoTo = new OrcamentoTO.GrupoTO();
            grupoTo.numero = contadorGrupo;
            grupoTo.nome = grupo.Name;
            grupoTo.qtdeSegurados = Integer.valueOf(grupo.QuantidadeVidas__c);
            grupoTo.segurados = new List<OrcamentoTO.SeguradoTO>();

            //TODO: GERAR AS GARANTIAS DOS GRUPOS
            //public List<CoberturaTO> coberturas { get; set; }

            //Gera nó de segurados
            for(SeguradoContrato__c segurado : grupo.SeguradosContrato__r)
            {
                contadorSegurados++;

                OrcamentoTO.SeguradoTO seguradoTo = new OrcamentoTO.SeguradoTO();
                seguradoTo.pessoa = new OrcamentoTO.PessoaTO();
                seguradoTo.coberturas = new List<OrcamentoTO.CoberturaTO>();
                seguradoTo.numero = contadorSegurados;

                if(String.isBlank(segurado.Conta__r.Cnpj__c))
                {
                    seguradoTo.pessoa.tipo = 'FIS';
                    seguradoTo.pessoa.dadosPessoaFisica = new OrcamentoTO.DadosPessoaFisicaTO();
                    seguradoTo.pessoa.dadosPessoaFisica.sexo =  segurado.Conta__r.Sexo__c;
                    seguradoTo.pessoa.dadosPessoaFisica.numeroCpf = segurado.Conta__r.Cpf__c.substring(0, segurado.Conta__r.Cpf__c.length() - 2);
                    seguradoTo.pessoa.dadosPessoaFisica.digitoCpf =  segurado.Conta__r.Cpf__c.right(2);
                    seguradoTo.pessoa.dadosPessoaFisica.nacionalidade =  segurado.Conta__r.Nacionalidade__c == 'Brasileira' ? 'BRA' : 'EST';
                    //seguradoTo.pessoa.dadosPessoaFisica.estadoCivil =  mapEstadoCivil.get(segurado.Conta__r.EstadoCivil__c);
                    seguradoTo.pessoa.dadosPessoaFisica.dataNascimento =  segurado.Conta__r.PersonBirthdate;

                }
                else
                {
                    seguradoTo.pessoa.tipo = 'JUR';
                    seguradoTo.pessoa.dadosPessoaJuridica = new OrcamentoTO.DadosPessoaJuridicaTO();
                    seguradoTo.pessoa.dadosPessoaJuridica.cnpj = segurado.Conta__r.Cnpj__c;
                    seguradoTo.pessoa.dadosPessoaJuridica.codigoCNAE = Integer.valueOf(segurado.Conta__r.CNAE__c);
                }

                //Gera nó de garantias
                if(garantiasVida.containsKey(segurado.Id))
                {
                    for(GarantiaGrupoContrato__c garantia : garantiasVida.get(segurado.Id))
                    {
                        OrcamentoTO.CoberturaTO cobertura = new OrcamentoTO.CoberturaTO();
                        cobertura.sigla = garantia.GarantiaReferenciada__r.Sigla__c;
                        cobertura.importancia = garantia.Capital__c;
                        cobertura.numeroSerie = garantia.NumeroSerie__c;
                        cobertura.numeroSorte = garantia.NumeroSorte__c;

                        seguradoTo.coberturas.add(cobertura);
                    }
                }

                grupoTo.segurados.add(seguradoTo);
            }

            //Adiciona grupo para lista
            gruposTo.add(grupoTo);
        }

        return gruposTo;
    }

    public class RetornoRestTO 
    {
        //public String status;
        //public String erro;
        public String id { get; set; }
        public Map<String, String> ids { get; set; }

        // Depreciado: apenas para manter funcionando chamadas anteriores à sprint 11
        public RetornoRestTO(String id) { this.id = id; }

        // Lista de orçamentos x oportunidade (1:1)
        public RetornoRestTO(String id, Map<String, String> ids) { this.id = id; this.ids = ids; }
    }

    public class OrcamentoException extends Exception {}
}