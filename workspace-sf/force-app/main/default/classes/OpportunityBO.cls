/**************************************************************************************************************************************************************************
* 
*	Classe responsável pelo negócio do objeto de Opportunity
*
**************************************************************************************************************************************************************************/
public class OpportunityBO {
  private static final OpportunityBO instancia = new OpportunityBO();
  private static OpportunityDAO dao = OpportunityDAO.getInstance();

  private OpportunityBO() {}

  public static OpportunityBO getInstance() {
    return instancia;
  }

  /*********************************************************************************************************
  *
  * Busca uma oportunidade por ID
  *
  *********************************************************************************************************/
  public Opportunity buscarOportunidade(Id oportunidadeId){
    Opportunity oportunidade;

    try {
      oportunidade = dao.buscarOportunidadesPorId(new Set<Id>{oportunidadeId}).get(0);
    } catch(Exception e) {
      System.debug(e.getMessage());
    }

    return oportunidade;
  }

  /*********************************************************************************************************
  *
  * Salva uma oportunidade quando vinda do fluxo de oferta
  *
  *********************************************************************************************************/
  public Opportunity salvarOportunidadeOferta(Opportunity oportunidade, String segmento){
    try {
      segmento = segmento == 'VG' ? 'VidaGrupo' : 'VidaIndividual';
      oportunidade.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', segmento).Id;

      upsert oportunidade Opportunity.Name;
    }
    catch(Exception e) {
      throw new OpportunityException('Erro ao inserir/atualizar oportunidade. ' + e.getLineNumber() + ': ' + e.getMessage());
    }

    return oportunidade;
  }

  /*********************************************************************************************************
  *
  * Atualiza uma oportunidade
  * @param oportunidade - Oportunidade a ser atualizada
  *
  *********************************************************************************************************/
  public Opportunity atualizaOportunidade(Opportunity oportunidade){

    Database.SaveResult sr = Database.update(oportunidade, false);
    if (sr.isSuccess()) {
      System.debug('Successfully updated opportunity. Opportunity ID: ' + sr.getId());
      return oportunidade;
    }
    else {
      for(Database.Error err : sr.getErrors()) { 
        System.debug('The following error has occurred.');
        System.debug(err.getStatusCode() + ': ' + err.getMessage());
        System.debug('opportunity fields that affected this error: ' + err.getFields());
      }
    }

    return null;
  }

  /*********************************************************************************************************
  *
  * Atualiza GarantiaGrupoOrcamento
  * @param List<Sobject> - lista de objetos genericos a ser atualizada
  *
  * @return List<sObject>
  *********************************************************************************************************/

  public List<String> atualizarGarantiasDoGrupoDoOrcamento(List<SObject> listSObject, Id oportunidadeId){
    List<String> lStrings = new List<String>();

    Opportunity opp = new Opportunity(Id = oportunidadeId, DataCalculo__c = System.today());
    listSObject.add(opp);

    if(listSObject.isEmpty()){
      return lStrings;
    }

    Database.SaveResult[] urList = Database.update(listSObject);

    for(Database.SaveResult ur : urList){
      if (ur.isSuccess()) {
        System.debug('Successfully upsert GarantiaGrupoOrcamento. GarantiaGrupoOrcamento ID: ' + ur.getId());
      }
      else {
        for(Database.Error err : ur.getErrors()) {
          System.debug('The following error has occurred.');
          System.debug(err.getStatusCode() + ': ' + err.getMessage());
          lStrings.add(err.getMessage());
          System.debug('opportunity fields that affected this error: ' + err.getFields());
        }
      }
    }

    return lStrings;
  }

  /*********************************************************************************************************
	*
	* Validacoes para permitir o calculo do orcamento
	*
	*********************************************************************************************************/

  public void validarCalculoOrcamento(Id orcamentoId){

    // Busca dados no banco
    List<Opportunity> listOrcamento = dao.buscarOrcamentosPorId(new Set<Id>{orcamentoId});
    List<Product2> listProduto = dao.buscarRemuneracoesProduto(new Set<Id>{orcamentoId});

    // Define variaveis
    Set<Id> setTipoRemuneracaoObrigatorias = new Set<Id>();
    Set<Id> setTipoRemuneracaoNoOrcamento = new Set<Id>();

    // Valida se existe produto cadastrado no orçamento
    if(listProduto.isEmpty()){
      Throw new OpportunityException('Produto não informado!');
    }

    // Pega informacoes do orcamento
    List<RemuneracaoOrcamento__c> listRemuneracaoOrcamento = listOrcamento.get(0).RemuneracoesOrcamento__r;
    List<ContratanteOrcamento__c> listSeguradoOrcamento = listOrcamento.get(0).ContratantesOrcamento__r;
    // Pega as remuneracoes do produto no produto
    list<RemuneracaoProduto__c> listRemuneracaoProduto = listProduto.get(0).RemuneracoesProduto__r;
    // Valida se existe remuneração do produto
    if(listRemuneracaoProduto == null || listRemuneracaoProduto.isEmpty()){
      Throw new OpportunityException('Remuneração do produto não informada!');
    }

    // Valida se existe remuneração do orcamento
    if(listRemuneracaoOrcamento == null || listRemuneracaoOrcamento.isEmpty()){
      Throw new OpportunityException('Remuneração não informada!');
    }

    // Valida se existe segurado no orcamento
    if(listSeguradoOrcamento == null || listSeguradoOrcamento.isEmpty()){
      Throw new OpportunityException('Informar ao menos um segurado');
    }

    // popula o set com os tipos da Remuneracao do orcamento
    for (RemuneracaoOrcamento__c remuneracaoOrcamento : listRemuneracaoOrcamento){
      setTipoRemuneracaoNoOrcamento.add(remuneracaoOrcamento.TipoRemuneracao__c);
    }
    // popula o set com os tipos de remuneracao do produto obrigatorias
    for(RemuneracaoProduto__c remuneracaoProduto : listRemuneracaoProduto){
      // Verifica se eh uma remuneracao obrigatoria
      if(remuneracaoProduto.Obrigatoria__c == true) {
        setTipoRemuneracaoObrigatorias.add(remuneracaoProduto.TipoRemuneracao__c);
      }
    }


    Boolean existeSeguradoPrincipal = false;
    // itera os segurados
    for(ContratanteOrcamento__c seguradoOrcamento : listSeguradoOrcamento){
      // verifica se eh um segurado principal
      if(seguradoOrcamento.Tipo__c == 'Principal') {
        existeSeguradoPrincipal = true;
        break;
      }
    }

    // valida se existe um segurado principal
    if(!existeSeguradoPrincipal){
      Throw new OpportunityException('Segurado principal não informado!');
    }

    // valida se existe remuneração do produto obrigatoria
    if(setTipoRemuneracaoObrigatorias.isEmpty()){
      Throw new OpportunityException('Não há remuneração obrigatória no produto!');
    }

    // Valida se foi selecionado todos os tipos de remuneracoes obrigatorios no orcamento
    for(Id tipoRemuneracaoObrigatoria : setTipoRemuneracaoObrigatorias){
      if(!setTipoRemuneracaoNoOrcamento.contains(tipoRemuneracaoObrigatoria)){
        Throw new OpportunityException('Remuneração obrigatória não informada no orçamento!');
      }
    }

  }


  /*********************************************************************************************************
  *
  * Busca fielset de oportunidade que variam de acordo com o produto
  *
  *********************************************************************************************************/
  public List<FieldSetMember> buscarFieldSetProduto(String codigoProduto, String objeto){ 
    String nomeFieldSet = MetadataDAO.getInstance().buscarFieldSetOrcamento(codigoProduto, objeto).get(0).FieldSet__c;

    return SObjectSchema.recuperarCamposFieldSet(objeto, nomeFieldSet);
  }


  /*********************************************************************************************************
  *
  * Efetua cálculo do Orçamento
  *
  *********************************************************************************************************/
  public OrcamentoTO efetuarCalculo(Set<Id> codigoOrcamento){

    Boolean bErro = false;

    CalculoOrcamentoService servico = CalculoOrcamentoService.getInstance();

    OrcamentoTO parEntrada = new  OrcamentoTO();
    parEntrada.solicitacaoOferta = new OrcamentoTO.SolicitacaoOfertaTO();
    parEntrada.solicitacaoOferta.evento = new OrcamentoTO.EventoTO();
    parEntrada.solicitacaoOferta.viagem = new OrcamentoTO.ViagemTO();

    parEntrada.solicitacaoOferta.transferenciaCongenere= new OrcamentoTo.TransferenciaCongenereTO();
    parEntrada.solicitacaoOferta.contratantes = new List<OrcamentoTo.ContratanteTO>();
    parEntrada.solicitacaoOferta.remuneracao = new OrcamentoTo.remuneracaoTo();
    parEntrada.solicitacaoOferta.remuneracao.agentes = new List<OrcamentoTo.agenteTo>();

    OrcamentoTO parSaida = new  OrcamentoTO();

    List<Opportunity> objEntrada =  dao.buscarOrcamentosPorId(codigoOrcamento);

    for(Opportunity objOpportunity : objEntrada)
    {
      Id idOrcamento = objOpportunity.Id;

      // Lista com os grupos do Orçamento para geração das coberturas do Grupo
//      List<GrupoOrcamento__c> lstGrupoOrcamento = opportunityDAO.getInstance().buscarGruposOrcamento(idOrcamento);

      //*** Solicitação Oferta
      parEntrada.solicitacaoOferta.segmento 			= buscaSegmento(objOpportunity.RecordType.DeveloperName);
      parEntrada.solicitacaoOferta.meioComercializacao= objOpportunity.MeioComercializacao__c;
      parEntrada.solicitacaoOferta.numeroOrcamento	= objOpportunity.numero__c;
      parEntrada.solicitacaoOferta.numeroPortal		= objOpportunity.NumeroPortal__c;
      parEntrada.solicitacaoOferta.dataCalculo		= objOpportunity.CloseDate;
      parEntrada.solicitacaoOferta.dataCriacaoPortal	= objOpportunity.DataCriacaoPortal__c;
      parEntrada.solicitacaoOferta.codigoProdutoPortal= Integer.valueOf(objOpportunity.Produto__r.ProductCode);
      parEntrada.solicitacaoOferta.codigoProdutoVida	= objOpportunity.Produto__r.ProductCode;
      parEntrada.solicitacaoOferta.tipoVigencia		= objOpportunity.TipoVigencia__c;
      parEntrada.solicitacaoOferta.vigenciaInicial	= objOpportunity.VigenciaInicial__c;
      parEntrada.solicitacaoOferta.vigenciaFinal		= objOpportunity.VigenciaFinal__c;
      parEntrada.solicitacaoOferta.observacoesGerais	= objOpportunity.observacoesGerais__c;
      parEntrada.solicitacaoOferta.tipoSeguro			= objOpportunity.type;
      parEntrada.solicitacaoOferta.tipoAdesao			= objOpportunity.TipoAdesao__c;

      parEntrada.solicitacaoOferta.garantiasOrcamentoSf = dao.buscarGarantiasOrcamento(new Set<Id>{idOrcamento});

      if(objOpportunity.VigenciaFinal__c != null && objOpportunity.VigenciaInicial__c != null)
        parEntrada.solicitacaoOferta.qtdDiasVigencia = objOpportunity.VigenciaFinal__c.daysBetween(objOpportunity.VigenciaInicial__c);

      if(objOpportunity.DescontoAgravoComercial__c == 'Desconto')
        parEntrada.solicitacaoOferta.descontoComercial	= objOpportunity.Percentual__c;
      else
              parEntrada.solicitacaoOferta.agravoComercial	= objOpportunity.Percentual__c;

      //*** Evento
      parEntrada.solicitacaoOferta.evento.tipoEvento				= objOpportunity.TipoEvento__c;
      parEntrada.solicitacaoOferta.evento.qstControlePublico		= (objOpportunity.HaControlePublico__c ? 'SIM' : 'NAO');
      parEntrada.solicitacaoOferta.evento.qstLocalEvento			= (objOpportunity.EventoLocalFechadoDelimitado__c == true ? 'SIM' : 'NAO');
      parEntrada.solicitacaoOferta.evento.informacoesEvento		= objOpportunity.InformacoesEvento__c;
      //*** Viagem
      parEntrada.solicitacaoOferta.viagem.tipoViagem				= objOpportunity.TipoViagem__c;
      parEntrada.solicitacaoOferta.viagem.praticaEsportesAventura	= (objOpportunity.ViagemAventura__c ? 'SIM': 'NAO');
      parEntrada.solicitacaoOferta.viagem.utilizaraMotocicleta	= (objOpportunity.utilizamoto__c ? 'SIM' : 'NAO');
      parEntrada.solicitacaoOferta.viagem.incluiPaisSchengen		= (objOpportunity.IncluiPaisEuropeu__c ? 'SIM' : 'NAO');
      parEntrada.solicitacaoOferta.viagem.trackageBagagem			= (objOpportunity.PossuiTrackageBagagem__c ? 'SIM' : 'NAO');
      parEntrada.solicitacaoOferta.viagem.passageirosNaoIdosos	= (Integer)objOpportunity.QuantidadePassageirosNaoIdosos__c;
      parEntrada.solicitacaoOferta.viagem.passageirosIdosos		= (Integer)objOpportunity.QuantidadePassageirosIdosos__c;

      if(objOpportunity.PaisesDestino__c != null)
      {
        List<String> paises = objOpportunity.PaisesDestino__c.split(';');
        List<OrcamentoTO.DestinoTO> lstDestino = new List<OrcamentoTO.DestinoTO>();
        for(String pais : paises)
        {
          OrcamentoTO.DestinoTO objDestino = new OrcamentoTO.DestinoTO();
          objDestino.pais = pais;
          lstDestino.add(objDestino);
        }
        parEntrada.solicitacaoOferta.viagem.destinos = lstDestino;
      }

      //*** transferenciaCongenere
      parEntrada.solicitacaoOferta.transferenciaCongenere.congenere  			= objOpportunity.congenere__c;
      parEntrada.solicitacaoOferta.transferenciaCongenere.tempoPermanencia	= (Integer)objOpportunity.tempoPermanencia__c;
      parEntrada.solicitacaoOferta.transferenciaCongenere.sinistralidade		= objOpportunity.sinistralidade__c;
      parEntrada.solicitacaoOferta.transferenciaCongenere.taxaVigencia		= objOpportunity.taxavigencia__c;


      //*** segurados
      List<OrcamentoTO.ContratanteTO> lstContratante = new List<OrcamentoTO.ContratanteTO>();
      OrcamentoTO.ContratanteTO contratante;

      List<OrcamentoTO.CoberturaTO> lstcoberturas = new List<OrcamentoTO.CoberturaTO>();
      OrcamentoTO.CoberturaTO cobertura;

      for(ContratanteOrcamento__c contratanteOrcamento : OpportunityDAO.getInstance().buscarContratantesOrcamento(new Set<Id>{idOrcamento}))
      {
        List<OrcamentoTO.TelefoneTO> lsttelefone = new List<OrcamentoTO.TelefoneTO>();
        OrcamentoTO.TelefoneTO telefone;

        contratante = new OrcamentoTO.ContratanteTO();
        contratante.pessoa = new OrcamentoTO.pessoaTO();
        contratante.pessoa.telefones = new List<OrcamentoTO.telefoneTO>();
        contratante.pessoa.enderecos = new List<OrcamentoTO.enderecoTO>();
        contratante.pessoa.dadosPessoaJuridica = new OrcamentoTO.DadosPessoaJuridicaTO();
        contratante.pessoa.dadosPessoaFisica = new OrcamentoTO.DadosPessoaFisicaTO();
        contratante.pessoa.dadosPessoaFisica.pessoaRelacionamentoPep  = new OrcamentoTO.PessoaRelacionamentoPepTO();
        contratante.pessoa.dadosPessoaFisica.documentos  = new List<OrcamentoTO.documentoTO>();

        //*** Gerais
        contratante.tipo         = contratanteOrcamento.Tipo__c;
//				segurado.pessoa.nome  = SeguradoOrcamento.Conta__r.FirstName + ' ' + SeguradoOrcamento.Conta__r.LastName;
        contratante.pessoa.nome  = contratanteOrcamento.Conta__r.Name;
        contratante.numero       = (Integer)contratanteOrcamento.Numero__c;
        contratante.pessoa.email = contratanteOrcamento.Conta__r.PersonEmail;

        //** Telefone da Account

        telefone = new OrcamentoTO.telefoneTO();
        telefone.tipotelefone = 'Residencial';
        //segurado.dddTelefone
        telefone.numeroTelefone = contratanteOrcamento.Conta__r.PersonHomePhone;
        Lsttelefone.add(telefone);
        //** Telefone da Account
        telefone = new OrcamentoTO.telefoneTO();
        telefone.tipotelefone = 'Comercial';
        //segurado.dddTelefone
        telefone.numeroTelefone = contratanteOrcamento.Conta__r.PersonAssistantPhone;
        Lsttelefone.add(telefone);
        //** Telefone da Account
        telefone = new OrcamentoTO.telefoneTO();
        telefone.tipotelefone = 'Celular';
        //segurado.dddTelefone
        telefone.numeroTelefone = contratanteOrcamento.Conta__r.Phone;
        Lsttelefone.add(telefone);

        contratante.pessoa.telefones =  Lsttelefone;

        //*** endereços
        List<OrcamentoTO.EnderecoTO> lsttendereco = new List<OrcamentoTO.EnderecoTO>();
        OrcamentoTO.EnderecoTO endereco;

        for(Endereco__c objEndereco : enderecoDAO.getInstance().buscarEnderecosConta(contratanteOrcamento.conta__r.Id))
        {
          endereco = new OrcamentoTO.EnderecoTO();
          endereco.tipoLogradouro 	= objEndereco.TipoLogradouro__c;
          endereco.tipoEndereco 		= objEndereco.TipoEndereco__c;
          endereco.logradouro 		= objEndereco.Logradouro__c;
          endereco.numeroLogradouro 	= objEndereco.Numero__c;
          endereco.complemento 		= objEndereco.Complemento__c;
          endereco.bairro 			= objEndereco.Bairro__c;
          endereco.cidade 			= objEndereco.Cidade__c;
          endereco.uf 				= objEndereco.Estado__c;
          endereco.paisResidencia 	= objEndereco.Pais__c;
          endereco.cep 				= objEndereco.CEP__c;
          endereco.complementoCep 	= objEndereco.CEP__c;

          lsttendereco.add(endereco);
        }

        contratante.pessoa.enderecos = lsttendereco;

        //*** Dados Pessoa Juridica
        if(contratanteOrcamento.Conta__r.RecordType.DeveloperName == 'PessoaJuridica')
        {
          try {
            contratante.pessoa.dadosPessoaJuridica.numeroCnpj	= contratanteOrcamento.Conta__r.IdExterno__c.left(8);
            contratante.pessoa.dadosPessoaJuridica.ordemCnpj	= contratanteOrcamento.Conta__r.IdExterno__c.substring(8,11);
            contratante.pessoa.dadosPessoaJuridica.digitoCnpj	= contratanteOrcamento.Conta__r.IdExterno__c.right(2);
            contratante.pessoa.dadosPessoaJuridica.cnpj 		= contratanteOrcamento.Conta__r.Cnpj__c;
            contratante.pessoa.dadosPessoaJuridica.codigoCNAE 	= (Integer)contratanteOrcamento.conta__r.ramoatividade__r.NumeroCnae__c;
            contratante.pessoa.dadosPessoaJuridica.descricaoCNAE = contratanteOrcamento.conta__r.ramoatividade__r.NomeAtividadeCnae__c;
          }
          catch(Exception e) {
            throw new OpportunityException('Erro ao montar Orçamento. ' + e.getLineNumber() + ': ' + e.getMessage());
          }
        }
        //*** Dados Pessoa Fisica
        if(contratanteOrcamento.Conta__r.RecordType.DeveloperName == 'PessoaFisica')
        {
//						segurado.pessoa.dadosPessoaFisica.tipoRelacionamentoPep		=
//						segurado.pessoa.dadosPessoaFisica.pessoaRelacionamentoPep 	=
//						segurado.pessoa.dadosPessoaFisica.tipo 						=
//						segurado.pessoa.dadosPessoaFisica.nome 						=
//						segurado.pessoa.dadosPessoaFisica.dadosPessoaFisica 		=
//						segurado.pessoa.dadosPessoaFisica.numeroCpf 				=
//						segurado.pessoa.dadosPessoaFisica.digitoCpf 				=

          try {
            contratante.pessoa.dadosPessoaFisica.numeroCpf 		= contratanteOrcamento.Conta__r.IdExterno__c.left(9);
            contratante.pessoa.dadosPessoaFisica.digitoCpf			= contratanteOrcamento.Conta__r.IdExterno__c.right(2);
            contratante.pessoa.dadosPessoaFisica.sexo				= contratanteOrcamento.Conta__r.Sexo__c;
            contratante.pessoa.dadosPessoaFisica.profissao			= contratanteOrcamento.Conta__r.profissao__c;
            contratante.pessoa.dadosPessoaFisica.pep 				= (contratanteOrcamento.Conta__r.pep__c =='SIM' ? true : false);
            contratante.pessoa.dadosPessoaFisica.nacionalidade 	= contratanteOrcamento.Conta__r.Nacionalidade__c;
            contratante.pessoa.dadosPessoaFisica.estadoCivil 		= contratanteOrcamento.Conta__r.estadoCivil__c;
            contratante.pessoa.dadosPessoaFisica.dataNascimento	= contratanteOrcamento.Conta__r.PersonBirthdate;
          }
          catch(Exception e) {
            throw new OpportunityException('Erro ao montar Orçamento. ' + e.getLineNumber() + ': ' + e.getMessage());
          }

        }

        //*** Docuemntos
        List<OrcamentoTO.DocumentoTO> lstdoc = new List<OrcamentoTO.DocumentoTO>();
        OrcamentoTO.DocumentoTO doc;

        doc = new OrcamentoTO.DocumentoTO();
        doc.tipoDocumentoIdentidade 	= 'RG';
        doc.orgaoExpedidorDocumento		= contratanteOrcamento.Conta__r.OrgaoExpedidor__c;
        doc.numeroDocumentoIdentidade	= contratanteOrcamento.Conta__r.rg__c;
        doc.dataExpedicaoDocumento		= contratanteOrcamento.Conta__r.DataExpedicao__c;

        lstdoc.add(doc);

        contratante.pessoa.dadosPessoaFisica.documentos = lstdoc;

        List<OrcamentoTO.GrupoTO> lstgrupos = new List<OrcamentoTO.GrupoTO>();
        OrcamentoTO.GrupoTO objGrupo;

        contratante.grupos = new List<OrcamentoTO.grupoTO>();

        for(GrupoOrcamento__c grupoOrcamento : contratanteOrcamento.GruposOrcamento__r)
        {

          objGrupo = new OrcamentoTO.GrupoTO();

          objGrupo.numero 		= (Integer)grupoOrcamento.Numero__c;
          objGrupo.nome 			= grupoOrcamento.Name;
          objGrupo.qtdeSegurados 		= (Integer)grupoOrcamento.QuantidadeVidas__c;
          objGrupo.idArquivoSegurados = grupoOrcamento.CodigoArquivo__c;
          objGrupo.tipoCalculo 	= grupoOrcamento.TipoCalculo__c;
          // obs não sera criado	segirado.grupos.tipoSegurado = grupoOrcamento.TipoSegurado__c;
          // não criado			objGrupo.tipoCalculoprazoMaximoFinanciamentoPrestamista = grupoOrcamento.
          // não criado			objGrupo.saldoDevedor 	= grupoOrcamento.
          // não criado			objGrupo.valorDoBem		= grupoOrcamento.

          List<OrcamentoTO.SeguradoTO> lstSegurados = new List<OrcamentoTO.SeguradoTO>();
          OrcamentoTO.SeguradoTO objSegurado;
          List<OrcamentoTO.CoberturaTO> lstcoberturaSegurados = new List<OrcamentoTO.CoberturaTO>();
          OrcamentoTO.CoberturaTO objCoberturaSeg;


          for(SeguradoOrcamento__c seguradoOrcamento : opportunityDAO.getInstance().buscarSeguradosOrcamentoPorGrupo(grupoOrcamento.Id))
          {

            objSegurado = new OrcamentoTO.SeguradoTO();
            objSegurado.numeroCpf		= seguradoOrcamento.CPF__c;
            objSegurado.digitoCpf		= seguradoOrcamento.CPF__c;
            objSegurado.nome 			= seguradoOrcamento.Name;
            objSegurado.dataNascimento 	= seguradoOrcamento.DataNascimento__c;
            objSegurado.afastado	 	= (seguradoOrcamento.Afastado__c ? 'SIM' : 'NAO');
            objSegurado.cid 			= seguradoOrcamento.CID__c;
            objSegurado.numero 			= (Integer)seguradoOrcamento.Numero__c;

            // for(GarantiaGrupoOrcamento__c segCoberturaOrcamento : seguradoOrcamento.GarantiasGrupoOrcamento__r)
            // {
            //   objCoberturaSeg 		= new OrcamentoTO.CoberturaTO();

            //   objCoberturaSeg.sigla = segCoberturaOrcamento.GarantiaProduto__r.Garantia__r.Sigla__c;
            //   objCoberturaSeg.percentual =segCoberturaOrcamento.Percentual__c;
            //   objCoberturaSeg.valor =segCoberturaOrcamento.Valor__c;

            //   if(segCoberturaOrcamento.DescontoAgravo__c == 'Agravo')
            //     objCoberturaSeg.agravo =segCoberturaOrcamento.Percentual__c;
            //   else
            //     objCoberturaSeg.desconto =segCoberturaOrcamento.Percentual__c;

            //   //						objCoberturaSeg.moeda =
            //   objCoberturaSeg.escolhaDescontoAgravo =segCoberturaOrcamento.DescontoAgravo__c;
            //   //						objCoberturaSeg.valorDescontoAgravo =
            //   objCoberturaSeg.garantiaReferenciada = segCoberturaOrcamento.GarantiaReferenciada__c;
            //   objCoberturaSeg.inclusaoIndenizacaoEspecial = (segCoberturaOrcamento.IncluirIndenizacaoEspecial__c ? 'SIM' : 'NAO');
            //   objCoberturaSeg.percentualIndenizacaoEspecial =segCoberturaOrcamento.PercentualIndenizacaoEspecial__c;
            //   objCoberturaSeg.inclusaoFilhos = (segCoberturaOrcamento.IncluirFilhos__c ? 'SIM' : 'NAO');
            //   objCoberturaSeg.percentualFilhos =segCoberturaOrcamento.PercentualFilhos__c;
            //   objCoberturaSeg.quantidade =(Integer)segCoberturaOrcamento.Quantidade__c;
            //   objCoberturaSeg.clausulaReducaoFranquiaAcidente =(segCoberturaOrcamento.ClausulaReducaoFranquiaAcidente__c ? 'SIM' : 'NAO');
            //   objCoberturaSeg.capital = segCoberturaOrcamento.Capital__c;

            //   lstcoberturaSegurados.add(objCoberturaSeg);
            // }

            objSegurado.coberturas = lstcoberturaSegurados;
            lstSegurados.add(objSegurado);

          }


          objGrupo.segurados = lstSegurados;

          // cobertura do grupo
          List<OrcamentoTO.CoberturaTO> lstcoberturagrupo = new List<OrcamentoTO.CoberturaTO>();
          OrcamentoTO.CoberturaTO objcoberturagrupo;

          for(GrupoOrcamento__c grupoOrcamentoCobertura : opportunityDAO.getInstance().buscarGruposOrcamento(idOrcamento))
          {
            if(grupoOrcamentoCobertura.Id == grupoOrcamento.Id)
            {
              for(GarantiaGrupoOrcamento__c coberturaOrcamento : grupoOrcamentoCobertura.GruposGarantiaOrcamento__r)
              {
                objcoberturagrupo 	= new OrcamentoTO.CoberturaTO();

                objcoberturagrupo.sigla = coberturaOrcamento.GarantiaProduto__r.Garantia__r.Sigla__c;
                objcoberturagrupo.valor =coberturaOrcamento.Valor__c;
                objcoberturagrupo.quantidade = (Integer)coberturaOrcamento.Quantidade__c;
                objcoberturagrupo.clausulaReducaoFranquiaAcidente = (coberturaOrcamento.ClausulaReducaoFranquiaAcidente__c ? 'SIM' : 'NAO');
                objcoberturagrupo.capital = coberturaOrcamento.Capital__c;

                lstcoberturagrupo.add(objcoberturagrupo);
              }
            }
          }

          objGrupo.coberturas = lstcoberturagrupo;

          lstgrupos.add(objGrupo);

        }

        contratante.grupos = lstgrupos;


        lstContratante.add(contratante);
      }

      parEntrada.solicitacaoOferta.remuneracao.canal 			= objOpportunity.CanalDistribuicao__c;
/*
			parEntrada.solicitacaoOferta.remuneracao.papel			=
			parEntrada.solicitacaoOferta.remuneracao.corretagem		=
			parEntrada.solicitacaoOferta.remuneracao.susep 			=
			parEntrada.solicitacaoOferta.remuneracao.tipoPessoaCorsus =
			parEntrada.solicitacaoOferta.remuneracao.susepEmissao 	=
			parEntrada.solicitacaoOferta.remuneracao.susepOrcamento =
			parEntrada.solicitacaoOferta.remuneracao.pessoa 		=
			parEntrada.solicitacaoOferta.remuneracao.tipo 			=
			parEntrada.solicitacaoOferta.remuneracao.nome 			=
			parEntrada.solicitacaoOferta.remuneracao.dadosPessoaJuridica =
			parEntrada.solicitacaoOferta.remuneracao.numeroCnpj 	=
			parEntrada.solicitacaoOferta.remuneracao.ordemCnpj		=
			parEntrada.solicitacaoOferta.remuneracao.digitoCnpj		=
*/


      parEntrada.solicitacaoOferta.contratantes = (lstContratante);

    }

    System.debug(json.serialize(parEntrada));
    parSaida = servico.efetuarCalculo(parEntrada);
    System.debug(json.serialize(parSaida));

    return parSaida;
  }

  private String buscaSegmento(String strDescricao)
  {
    String strRetorno;

    if(strDescricao == 'VidaGrupo')
      strRetorno = 'VG';
    else if (strDescricao == 'VidaIndividual')
      strRetorno = 'VI';

    return strRetorno;
  }


  /**
  *
  *
  * @param oportunidadeId Id da oportunidade
  *
  * @return String - JSON de OrcamentoTO
  */
  public String buscarGarantiasOrcamento (Id oportunidadeId){

    // Declaracao de mapas
    Map<Id, List<GrupoOrcamento__c>> mapGruposPorContratante = new Map<Id, List<GrupoOrcamento__c>>();
    Map<Id, ContratanteOrcamento__c> mapContratanteOrcamentoPorContratante = new Map<Id, ContratanteOrcamento__c>();
    Map<Id, List<GarantiaGrupoOrcamento__c>> mapGarantiasDoGrupoPorGrupo = new Map<Id, List<GarantiaGrupoOrcamento__c>>();
    Map<Id, List<GarantiaContratanteOrcamento__c>> mapGarantiasContratantePorContratante = new Map<Id, List<GarantiaContratanteOrcamento__c>>();

    // instancias
    CalculoOrcamentoService calculoOrcamentoService =  CalculoOrcamentoService.getInstance();

    // Buscas
    List<GarantiaOrcamento__c> listGarantiasOrcamento = dao.buscarGarantiasOrcamento(new Set<Id>{oportunidadeId});

    for(ContratanteOrcamento__c contratanteOrcamento : dao.buscarContratantesOrcamento(new Set<Id>{oportunidadeId})){

      mapGarantiasContratantePorContratante.put(contratanteOrcamento.Id,contratanteOrcamento.GarantiasContratanteOrcamento__r);
      mapContratanteOrcamentoPorContratante.put(contratanteOrcamento.Id,contratanteOrcamento);
      mapGruposPorContratante.put(contratanteOrcamento.Id,new List<GrupoOrcamento__c>());

      if(contratanteOrcamento.GruposOrcamento__r != null){

        for(GrupoOrcamento__c grupoOrcamento : contratanteOrcamento.GruposOrcamento__r){
          mapGruposPorContratante.get(contratanteOrcamento.Id).add(grupoOrcamento);
          mapGarantiasDoGrupoPorGrupo.put(grupoOrcamento.Id,new List<GarantiaGrupoOrcamento__c>());
        }
      }
    }

    // Busca os grupos do orcamento
    for(GrupoOrcamento__c  grupoOrcamento : dao.buscarGruposDoOrcamento(mapGarantiasDoGrupoPorGrupo.keySet())){
      mapGarantiasDoGrupoPorGrupo.put(grupoOrcamento.Id,grupoOrcamento.GruposGarantiaOrcamento__r);
    }

    OrcamentoTO orcamentoTO = calculoOrcamentoService.constroiPrecificacaoOrcamentoTO(
            listGarantiasOrcamento,
            mapGruposPorContratante,
            mapGarantiasDoGrupoPorGrupo,
            mapGarantiasContratantePorContratante,
            mapContratanteOrcamentoPorContratante
    );

    return JSON.serialize(orcamentoTO);
  }

  /*********************************************************************************************************
  *
  * Retorna os segurados de uma orcamento
  *
  *********************************************************************************************************/
  public List<ContratanteOrcamento__c> buscarContratantesOrcamento(Id oportunidadeId){
    return dao.buscarContratantesOrcamento(new Set<Id>{oportunidadeId});
  }
  //PLV-4660 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
  public void validarProdutoCanal(List<Opportunity> lstOportunidades)
  {
    Map<Id, Opportunity> mapCanalDistribuicao = new Map<Id, Opportunity>();
    Map<Id, Opportunity> mapProduto = new Map<Id, Opportunity>();
    List<Opportunity> listToVerify = new List<Opportunity>();
    for (Opportunity opp : lstOportunidades) {
      if(opp.Type!=null && opp.Type.equalsIgnoreCase('Seguro novo')){
        mapCanalDistribuicao.put(opp.CanalDistribuicao__c, opp);
        mapProduto.put(opp.Produto__c, opp);
        listToVerify.add(opp);
      }
    }

    // TODO: single query: [SELECT Id, Name, Status__c, (SELECT Id, Name, Produto__c, Produto__r.Name FROM ProdutosCanal__r WHERE Produto__c IN :mapProduto.keySet()) FROM CanalDistribuicao__c WHERE Status__c = 'Ativo' AND Id IN :mapCanalDistribuicao.keySet()]
    if(listToVerify.size()>0){
      List<Product2> listProd = [SELECT Id, RecordType.DeveloperName FROM Product2 WHERE Id IN : mapProduto.keySet()];

      List<CanalDistribuicao__c> listCanaisDistribuicaoOpp = [SELECT Id, Name, Status__c FROM CanalDistribuicao__c WHERE Id =: mapCanalDistribuicao.keySet()];
      List<ProdutoCanal__c> listProdutoCanalOpp = [SELECT Id, Name, Produto__c, Produto__r.Name, CanalDistribuicao__c FROM ProdutoCanal__c WHERE Produto__c IN :mapProduto.keySet() AND CanalDistribuicao__c IN :mapCanalDistribuicao.keySet()];
    
      for (CanalDistribuicao__c cd1 : listCanaisDistribuicaoOpp)
      {
        if (cd1.Status__c != 'Ativo')
        {
          Opportunity oppError = mapCanalDistribuicao.get(cd1.Id);
          oppError.addError('Canal não está ativo para esta ação, favor verificar.');
        }
        else
        {
          if (listProdutoCanalOpp.size() > 0)
          {
            for (ProdutoCanal__c pc1 : listProdutoCanalOpp)
            {
              if (!mapProduto.containsKey(pc1.Produto__c) && !mapCanalDistribuicao.containsKey(pc1.CanalDistribuicao__c))
              {
                Opportunity oppError = mapProduto.get(pc1.Produto__c);
                oppError.addError('Produto não localizado para canal informado.');
              }
            }
          }
          else
          {
            Opportunity oppError = mapCanalDistribuicao.get(cd1.Id);
            oppError.addError('Produto não existente no canal informado.');
          }
        }
      }
    }
  }
  //PLV-4660 - FIM - PEDRO AUGUSTO BRAZ - SYS4B


  /*********************************************************************************************************
  *
  * Retornas as garantias de um segurado
  *
  *********************************************************************************************************/

  public List<GarantiaContratanteOrcamento__c> buscarGarantiasContratanteOrcamento(Id seguradoId){

    return dao.buscarGarantiasContratanteOrcamentoPorSegurados(new Set<Id>{seguradoId});

  }

  /*********************************************************************************************************
  *
  * Retornas as garantias de um contratante
  *
  *********************************************************************************************************/

  public List<GarantiaGrupoOrcamento__c> buscarGarantiasGrupoOrcamento(Id contratanteId){

    return dao.buscarGarantiasGrupoOrcamentoPorGrupo(new Set<Id>{contratanteId});


  }

  /*********************************************************************************************************
  *
  * Realiza calculo em um orçamento, e em seguida, atualiza orçamento com os dados retornados do calculo
  *
  *********************************************************************************************************/
  public void calcularOrcamento(Id oportunidadeId){
    try {
      OrcamentoTO orcamento = this.efetuarCalculo(new Set<Id> {oportunidadeId});
      OrcamentoTO.OfertaTO oferta = orcamento.ofertas.get(0);

      if(oferta.calculo.precificacao == null)
        return;

      Map<String, OrcamentoTO.ContratanteTO> contranteResumo = new Map<String, OrcamentoTO.ContratanteTO>();
      Map<String, OrcamentoTO.GrupoTO> grupoResumo = new Map<String, OrcamentoTO.GrupoTO>();
      Map<String, OrcamentoTO.CoberturaTO> coberturaResumo = new Map<String, OrcamentoTO.CoberturaTO>();
      Map<String, OrcamentoTO.CoberturaTO> coberturaGrupo = new Map<String, OrcamentoTO.CoberturaTO>();
      Map<String, OrcamentoTO.CoberturaTO> coberturaVida = new Map<String, OrcamentoTO.CoberturaTO>();

      //Busca registros que devem ser atualizados
      Opportunity oportunidade = dao.buscarOportunidadesPorId(new Set<Id> {oportunidadeId}).get(0);
      List<ContratanteOrcamento__c> contratantesOrcamento = dao.buscarContratantesOrcamento(new Set<Id>{oportunidadeId});
      List<GrupoOrcamento__c> gruposOrcamento = dao.buscarGruposOrcamentoPorOrcamento(new Set<Id> {oportunidadeId});
      List<GarantiaOrcamento__c> garantiasOrcamento = dao.buscarGarantiasOrcamento(new Set<Id>{oportunidadeId});
      List<GarantiaGrupoOrcamento__c> garantiasGrupoOrcamento = dao.buscarTodasGarantiasGrupoOrcamento(oportunidadeId);
      //List<GarantiaGrupoOrcamento__c> garantiasVidaGrupoOrcamento = dao.buscarTodasGarantiasVidaOrcamento(oportunidadeId);

      //Mapeia os dados de garantia de resumo
      for(OrcamentoTO.CoberturaTO cobertura : oferta.calculo.precificacao.coberturas){
        coberturaResumo.put(cobertura.sigla, cobertura);
      }

      //Mapeia todos os dados necessários que devem ser atualizafos após o calculp
      for(OrcamentoTO.ContratanteTO contratanteTO : oferta.calculo.precificacao.contratantes){
        //Mapeia os dados de segurados
        contranteResumo.put(contratanteTO.numero.format(), contratanteTO);

        for(OrcamentoTO.GrupoTO grupo : contratanteTO.grupos){
          //Mapeia os dados de grupos
          grupoResumo.put(contratanteTO.numero.format() + grupo.numero.format(), grupo);

          //Mapeia os dados de garantia dos grupos
          for(OrcamentoTO.CoberturaTO cobertura : grupo.coberturas){
            coberturaGrupo.put(contratanteTO.numero.format() + grupo.numero.format() + cobertura.sigla, cobertura);
          }

          //Mapeia os dados de garantia das segurados
          for(OrcamentoTO.SeguradoTO segurado : grupo.segurados){
            for(OrcamentoTO.CoberturaTO cobertura : segurado.coberturas){
              coberturaVida.put(contratanteTO.numero.format() + grupo.numero.format() + segurado.numero.format() + cobertura.sigla, cobertura);
            }
          }
        }
      }

      //Reatribui valores
      this.atualizarCamposOrcamento(oportunidade, oferta);
      this.atualizarCamposSegurado(contratantesOrcamento, contranteResumo);
      this.atualizarCamposGrupo(gruposOrcamento,  grupoResumo);
      this.atualizarCamposGarantiaOrcamento(garantiasOrcamento, coberturaResumo);
      this.atualizarCamposGrupoGarantiaOrcamento(garantiasGrupoOrcamento, coberturaGrupo, false);
      //this.atualizarCamposGrupoGarantiaOrcamento(garantiasVidaGrupoOrcamento, coberturaVida, true);

      //Atualiza registros com as atualizações de calculo
      if(!contratantesOrcamento.isEmpty()){
        update contratantesOrcamento;
      }

      if(!gruposOrcamento.isEmpty()){
        update gruposOrcamento;
      }

      if(!garantiasOrcamento.isEmpty()){
        update garantiasOrcamento;
      }

      if(!garantiasGrupoOrcamento.isEmpty()){
        update garantiasGrupoOrcamento;
      }

      // if(!garantiasVidaGrupoOrcamento.isEmpty()){
      //   update garantiasVidaGrupoOrcamento;
      // }

      //Atualiza payload com as informações de calculo
      OrcamentoTO.PayloadTO payload = (OrcamentoTO.PayloadTO) JSON.deserialize(oportunidade.Payload__c, OrcamentoTO.PayloadTO.class);
      payload.orcamentos.get(0).oferta = oferta;
      oportunidade.Payload__c = JSON.serialize(payload);

      update oportunidade;

    } catch(Exception e) {
      throw new OpportunityException('Erro no retorno do cálculo.|' + e.getMessage());
    }
  }

  //Atualiza campos de Opportunity com base nos dados retornados pelo calculo
  private void atualizarCamposOrcamento(Opportunity oportunidade, OrcamentoTO.OfertaTO oferta){
    oportunidade.Juros__c = oferta.calculo.precificacao.juros;
    oportunidade.IOF__c = oferta.calculo.precificacao.iof;
    oportunidade.Encargos__c = oferta.calculo.precificacao.encargos;
    oportunidade.CustoApolice__c = oferta.calculo.precificacao.custoApolice;
    oportunidade.PremioPuro__c = oferta.calculo.precificacao.premio.puro;
    oportunidade.PremioPuroInterno__c = oferta.calculo.precificacao.premio.puroInterno;
    oportunidade.DescontoPremioPuro__c = oferta.calculo.precificacao.premio.puroDesconto;
    oportunidade.PremioPuroResseguro__c = oferta.calculo.precificacao.premio.puroResseguro;
    oportunidade.PremioComercial__c = oferta.calculo.precificacao.premio.comercial;
    oportunidade.DescontoPremioComercial__c = oferta.calculo.precificacao.premio.comercialDesconto;
    oportunidade.TaxaPura__c = oferta.calculo.precificacao.taxa.pura;
    oportunidade.TaxaMensal__c = oferta.calculo.precificacao.taxa.mensal;
    oportunidade.TaxaAnual__c = oferta.calculo.precificacao.taxa.anual;
    oportunidade.TaxaPuraResseguro__c = oferta.calculo.precificacao.taxa.puroResseguro;
    oportunidade.TaxaPuraInterna__c = oferta.calculo.precificacao.taxa.puroInterno;
    oportunidade.TaxaComercial__c = oferta.calculo.precificacao.taxa.comercial;
  }

  //Atualiza campos de ContratanteOrcamento__c com base nos dados retornados pelo calcul
  private void atualizarCamposSegurado(List<ContratanteOrcamento__c> contratantesOrcamento, Map<String, OrcamentoTO.ContratanteTO> contratanteResumo){
    //Altera os valores dos campos com resultado do calculo
    for(ContratanteOrcamento__c contratanteOrcamento : contratantesOrcamento){
      OrcamentoTO.ContratanteTO contratante = contratanteResumo.get(contratanteOrcamento.Numero__c.format());

      if(contratante != null){
        contratanteOrcamento.PremioPuro__c = contratante.premio.puro;
        contratanteOrcamento.PremioComercial__c = contratante.premio.comercial;
        contratanteOrcamento.TaxaComercial__c = contratante.taxa.comercial;
        contratanteOrcamento.TaxaPura__c = contratante.taxa.pura;
      }
    }
  }

  //Atualiza campos de GrupoOrcamento__c com base nos dados retornados pelo calcul
  private void atualizarCamposGrupo(List<GrupoOrcamento__c> gruposOrcamento, Map<String, OrcamentoTO.GrupoTO> grupoResumo){
    //Altera os valores dos campos com resultado do calculo
    for(GrupoOrcamento__c grupoOrcamento : gruposOrcamento){
      OrcamentoTO.GrupoTO grupo = grupoResumo.get(grupoOrcamento.ContratanteOrcamento__r.Numero__c.format() + grupoOrcamento.Numero__c);

      if(grupo != null){
        grupoOrcamento.PremioPuro__c = grupo.premio.puro;
        grupoOrcamento.PremioComercial__c = grupo.premio.comercial;
        grupoOrcamento.TaxaPura__c = grupo.taxa.pura;
        grupoOrcamento.TaxaComercial__c = grupo.taxa.comercial;
        grupoOrcamento.QuantidadeVidas__c = grupo.qtdeSegurados;

        if (grupo.agravo != null) {
          grupoOrcamento.Percentual__c = grupo.agravo;
          grupoOrcamento.DescontoAgravo__c = 'Agravo';
        }

        if (grupo.desconto != null) {
          grupoOrcamento.Percentual__c = grupo.desconto;
          grupoOrcamento.DescontoAgravo__c = 'Desconto';
        }
      }
    }
  }

  //Atualiza campos de GarantiaOrcamento__c com base nos dados retornados pelo calculo
  private void atualizarCamposGarantiaOrcamento(List<GarantiaOrcamento__c> garantiasOrcamento, Map<String, OrcamentoTO.CoberturaTO> coberturaResumo){
    //Altera os valores dos campos com resultado do calculo
    for(GarantiaOrcamento__c garantiaOrcamento : garantiasOrcamento){
      OrcamentoTO.CoberturaTO cobertura = coberturaResumo.get(garantiaOrcamento.GarantiaProduto__r.Garantia__r.Sigla__c);

      if(cobertura != null){
        garantiaOrcamento.Capital__c = cobertura.capital;
        garantiaOrcamento.PremioComercial__c = cobertura.premio.comercial;
        garantiaOrcamento.PremioPuro__c = cobertura.premio.puro;
        garantiaOrcamento.PremioComercialDesconto__c = cobertura.premio.comercialDesconto;
        garantiaOrcamento.PremioPuroDesconto__c = cobertura.premio.puroDesconto;
        garantiaOrcamento.PremioPuroInterno__c = cobertura.premio.puroInterno;
        garantiaOrcamento.PremioPuroResseguro__c = cobertura.premio.puroResseguro;
        garantiaOrcamento.TaxaAnual__c = cobertura.taxa.anual;
        garantiaOrcamento.TaxaComercial__c = cobertura.taxa.comercial;
        garantiaOrcamento.TaxaMensal__c = cobertura.taxa.mensal;
        garantiaOrcamento.TaxaPuroInterno__c = cobertura.taxa.puroInterno;
        garantiaOrcamento.TaxaPura__c = cobertura.taxa.pura;
        garantiaOrcamento.TaxaPuroResseguro__c = cobertura.taxa.puroResseguro;
      }
    }
  }

  //Atualiza campos de GarantiaGrupoOrcamento__c com base nos dados retornados pelo calculo
  private void atualizarCamposGrupoGarantiaOrcamento(List<GarantiaGrupoOrcamento__c> garantiasGrupoOrcamento, Map<String, OrcamentoTO.CoberturaTO> coberturaGrupo, Boolean segurado){
    String chave = '';

    //Altera os valores dos campos com resultado do calculo
    for(GarantiaGrupoOrcamento__c garantiaGrupo : garantiasGrupoOrcamento){
      if(!segurado)
        chave = garantiaGrupo.GrupoOrcamento__r.ContratanteOrcamento__r.Numero__c.format() + garantiaGrupo.GrupoOrcamento__r.Numero__c.format() + garantiaGrupo.GarantiaProduto__r.Garantia__r.Sigla__c;
      // }else{
      //   chave = garantiaGrupo.SeguradoOrcamento__r.GrupoOrcamento__r.ContratanteOrcamento__r.Numero__c.format() + garantiaGrupo.SeguradoOrcamento__r.GrupoOrcamento__r.Numero__c.format() + garantiaGrupo.SeguradoOrcamento__r.Numero__c.format() + garantiaGrupo.GarantiaProduto__r.Garantia__r.Sigla__c;
      // }

      OrcamentoTO.CoberturaTO cobertura = coberturaGrupo.get(chave);

      if(cobertura != null){
        garantiaGrupo.Capital__c = cobertura.capital;
        garantiaGrupo.IncluirIndenizacaoEspecial__c = cobertura.inclusaoIndenizacaoEspecial == 'SIM' ? true : false;
        garantiaGrupo.PercentualIndenizacaoEspecial__c = cobertura.percentualIndenizacaoEspecial;
        garantiaGrupo.IncluirFilhos__c = cobertura.inclusaoFilhos == 'SIM' ? true : false;
        garantiaGrupo.PercentualFilhos__c = cobertura.percentualFilhos;
        garantiaGrupo.TaxaComercial__c = cobertura.taxa.comercial;
        garantiaGrupo.TaxaPura__c = cobertura.taxa.pura;
        garantiaGrupo.PremioComercial__c = cobertura.premio.comercial;
        garantiaGrupo.PremioPuro__c = cobertura.premio.puro;
        garantiaGrupo.PremioComercialDesconto__c = cobertura.premio.comercialDesconto;
        garantiaGrupo.PremioPuroInterno__c = cobertura.premio.puroInterno;
        garantiaGrupo.PremioPuroResseguro__c = cobertura.premio.puroResseguro;
        garantiaGrupo.Quantidade__c = cobertura.quantidade;
        
        if (cobertura.agravo != null) {
          garantiaGrupo.Percentual__c = cobertura.agravo;
          garantiaGrupo.DescontoAgravo__c = 'Agravo';
        }

        if (cobertura.desconto != null) {
          garantiaGrupo.Percentual__c = cobertura.desconto;
          garantiaGrupo.DescontoAgravo__c = 'Desconto';
        }
      }
    }
  }


  // public void clonaOrcamento(Opportunity orcamento)
  // {
  //   Opportunity orcamentoClone = new Opportunity();

  //   try
  //   {
  //     orcamentoClone.RecordTypeId              = orcamento.RecordTypeId;
  //     orcamentoClone.tipoVigencia__c           = orcamento.tipoVigencia__c;
  //     orcamentoClone.Name                      = orcamento.Name;
  //     orcamentoClone.numero__c                 = orcamento.numero__c;
  //     orcamentoClone.origem__c                 = orcamento.origem__c;
  //     orcamentoClone.meioComercializacao__c    = orcamento.meioComercializacao__c;
  //     orcamentoClone.vigenciaInicial__c        = orcamento.vigenciaInicial__c;
  //     orcamentoClone.VigenciaFinal__c          = orcamento.VigenciaFinal__c;
  //     orcamentoClone.dataCalculo__c            = orcamento.dataCalculo__c;
  //     orcamentoClone.dataCriacaoPortal__c      = orcamento.dataCriacaoPortal__c;
  //     orcamentoClone.PremioInformado__c        = orcamento.PremioInformado__c;
  //     orcamentoClone.Produto__c                = orcamento.Produto__c;
  //     orcamentoClone.Description               = orcamento.Description;
  //     orcamentoClone.InformacoesEvento__c      = orcamento.InformacoesEvento__c;
  //     orcamentoClone.TipoViagem__c             = orcamento.TipoViagem__c;
  //     orcamentoClone.Amount                    = orcamento.Amount;
  //     orcamentoClone.FormaPagamento__c         = orcamento.FormaPagamento__c;
  //     orcamentoClone.Name                      = orcamento.Name;
  //     orcamentoClone.Type                      = orcamento.Type;
  //     orcamentoClone.MeioComercializacao__c    = orcamento.MeioComercializacao__c;
  //     //orcamentoClone.StageName                 = orcamento.StageName;
  //     orcamentoClone.CloseDate                 = orcamento.CloseDate;
  //     orcamentoClone.CanalDistribuicao__c      = orcamento.CanalDistribuicao__c;
  //     orcamentoClone.StageName = '';// TODO:
  //     orcamentoClone.AccountId                 = orcamento.AccountId;

  //   }
  //   catch(Exception e)
  //   {
  //       system.debug('Erro orcamento:'+ e.getCause() + ' - ' +  e.getLineNumber() + ': ' + e.getMessage());
  //       throw new OpportunityException(e.getCause() + ' - ' +  e.getLineNumber() + ': ' + e.getMessage());
  //   }

  //   try{ insert orcamentoClone; }
  //   catch(Exception e)
  //   {
  //       system.debug('Erro orcamento:'+ e.getCause() + ' - ' +  e.getLineNumber() + ': ' + e.getMessage());
  //       throw new OpportunityException(e.getCause() + ' - ' +  e.getLineNumber() + ': ' + e.getMessage());
  //   }

  //   List<RemuneracaoOrcamento__c> lstRemOrc = RemuneracaoFacade.getInstance().clonaRemuneracaoOrcamento(orcamentoClone.Id, orcamentoClone.RemuneracoesOrcamento__r);

  //   try{ insert lstRemOrc; }
  //   catch(Exception e)
  //   {
  //       system.debug('Erro remuneracao orcamento:'+ e.getCause() + ' - ' +  e.getLineNumber() + ': ' + e.getMessage());
  //       throw new OpportunityException(e.getCause() + ' - ' +  e.getLineNumber() + ': ' + e.getMessage());
  //   }

  //   SeguradoOrcamentoBO.getInstance().clonarSeguradosOrcamento(orcamentoClone.Id, orcamento.ContratantesOrcamento__r);

  //   List<GarantiaOrcamento__c> garantiasClone = GarantiaFacade.getInstance().clonaGarantiaOrcamento(orcamentoClone.Id, orcamento.CoberturasOrcamento__r);
  //   try{ insert garantiasClone; }
  //   catch(Exception e)
  //   {
  //       system.debug('Erro garantia orcamento:'+ e.getCause() + ' - ' +  e.getLineNumber() + ': ' + e.getMessage());
  //       throw new OpportunityException(e.getCause() + ' - ' +  e.getLineNumber() + ': ' + e.getMessage());
  //   }
  // }
  // 

   /*********************************************************************************************************
	*
	* Validacoes para Atualizar Geração de Número de Orçamento 
	* @author Renan Martins - Avanxo
	*********************************************************************************************************/
  //PLV-2589- INICIO
  //Inserir campos de Opportunity com base nos dados retornados pelo calculo
    public void atualizarGerarNumeroOrcamento(List < Opportunity > ltOportunidadeNew) {
        
        List < Opportunity > ltOportunidadeUpdate = new List < Opportunity > ();
        
        for (Opportunity opttNew: ltOportunidadeNew) {
            
            if (opttNew.Name != 'GERAR') continue;
            //PLV-2715 Fix 2 - Inicio - Ajuste na geração de número orçamento
            //Add através do ID da Oportunidade o Meio de Comercialização - contador Orcamento
            ltOportunidadeUpdate.add(new Opportunity(
                Id = opttNew.id,
                name = opttNew.MeioComercializacao__c + '-' + opttNew.ContadorOrcamento__c,
                Numero__c = opttNew.ContadorOrcamento__c 
            ));
            
            //ltOportunidadeUpdate.add(new Opportunity(Id = opttNew.id, name = opttNew.ContadorOrcamento__c));
            
            system.debug('Campos oportunidade Trigger>>>>' + opttNew);
            //PLV-2715 Fix 2 - Fim - Ajuste na geração de número orçamento           
            
        }
        update ltOportunidadeUpdate;
    }
    //PLV-2589- FIM
    
    // Gera o campo name da orcamento
    public String gerarNameOrcamento(String origem, String numeroProposta){
        return origem + '-' + numeroProposta.leftPad(8,'0');
    }
    
    //PLV-2673 - INICIO - AVX
    public void vencimentoOrcamento (List<Opportunity> lOportunidades) {
        List<Opportunity> lstOportunidades = new  List<Opportunity>();
        Set<Id> setIdProduto = new Set<Id>();

        for (Opportunity op : lOportunidades) {
          if (op.StageName == 'Em criação' && TriggerHelper.isChanged(op, new Set<String>{'StageName', 'Produto__c'})) {
            setIdProduto.add(op.Produto__c);
            lstOportunidades.add(op);
          }
        }
        
        if (lstOportunidades.isEmpty()) return;
        if (setIdProduto.isEmpty()) return; 

        List<ParametroVigencia__c> lstParamVigencia = [SELECT Id, ValidadeOrcamento__c, Produto__c 
                                                      FROM ParametroVigencia__c 
                                                      WHERE Produto__c IN :setIdProduto];
        
        if (lstParamVigencia.isEmpty()) return;
        
        Map<Id, ParametroVigencia__c> mParamVigencia = new Map<Id, ParametroVigencia__c>();

        for (ParametroVigencia__c pv : lstParamVigencia) {
          if(pv.ValidadeOrcamento__c != null)
            mParamVigencia.put(pv.Produto__c, pv);
        }

        if(mParamVigencia.isEmpty()) return;

        for (Opportunity oCalculo : lstOportunidades) {
            Date data = System.today();
            system.debug('Data today ====> ' + data);

            ParametroVigencia__c vParam = mParamVigencia.get(oCalculo.Produto__c);

            oCalculo.DataVencimento__c = data.addDays(Integer.valueOf(vParam.ValidadeOrcamento__c));

            system.debug('Orçamento validade: ' + oCalculo.DataVencimento__c);
        }
    }
	  //PLV-2673 - FIM - AVX
    
    //PLV-4393 - INICIO
    /*
    public void deleteLocalStorageDocument( List<Opportunity> lstNewOpp, Map<Id, Opportunity> mapOldOpp ){
        
        List<Id> lstIdOppContratado = new List<Id>();

        for( Opportunity oppNew : lstNewOpp ){

            Opportunity oppOld = mapOldOpp.get( oppNew.Id );

            Boolean isStageNameChanged = ( oppNew.StageName != oppOld.StageName );
            Boolean isStageNameContratado = ( oppNew.StageName == 'Contratado' );

            if( isStageNameChanged && isStageNameContratado ){
                lstIdOppContratado.add( oppNew.Id );
            }
            
        }

        if( !lstIdOppContratado.isEmpty() ){
            FileController.deleteFile( '%_localStorage', lstIdOppContratado );
        }

    }
	*/
    //PLV-4393 - FIM
     
  	public class OpportunityException extends Exception {}
    
    //PLV-4498 - Inicio
    public void preencherRamoOrcamento(List<Opportunity> ltNewOpp){
        system.debug('#### - Entrou - OpportunityBO - preencherRamoOrcamento');
        
        Set<Id> stIdProduto = new Set<Id>();
        for(Opportunity opp : ltNewOpp){
            system.debug('#### - opp.Produto__c = ' + opp.Produto__c);
            if(opp.Produto__c != null){
                stIdProduto.add(opp.Produto__c);
                opp.RamoOrcamento__c = buscarRamoSeguro(stIdProduto);
            }
        }
    }

    public static String buscarRamoSeguro(Set<Id> idProduto){
        List<GarantiaProduto__c> lstGarantiasProdutoProposta = GarantiaProdutoDAO.getInstance().buscarGarantiasProdutoPorProdutoId(idProduto);
        String retorno = null;
        Decimal prioridade = 99999;
        
        for(GarantiaProduto__c garantiaProd : lstGarantiasProdutoProposta){
          if(prioridade > garantiaProd.OrdemPrioridade__c){
            if(garantiaProd.RamoSeguro__c != null){
                retorno    = garantiaProd.RamoSeguro__r.Codigo__c;
                prioridade = garantiaProd.OrdemPrioridade__c;
            }
          }
        }
        
        return retorno;
    }
    //PLV-4498 - FIM
}