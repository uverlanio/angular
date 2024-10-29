/**
 * @description       : 
 * @author            : giordano.menezes@globant.com
 * @group             : 
 * @last modified on  : 12-08-2022
 * @last modified by  : giordano.menezes@globant.com
**/
public class CarregarEstruturasServiceTO {
	private static final CarregarEstruturasServiceTO instance = new CarregarEstruturasServiceTO();

	private CarregarEstruturasServiceTO() { }

	public static CarregarEstruturasServiceTO getInstance() {
		return instance;
	}

	public void ExecutarCargaEstruturasPropostaTo()
	{
		StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadProposta001' LIMIT 1];
	    String payload = staticResource.Body.toString();

		try
		{
			EmissaoTO.PayloadTO tempList;
		    tempList = (EmissaoTO.PayloadTO) JSON.deserialize(payload, EmissaoTO.PayloadTO.class);

		    System.debug('PropostaTO: ' + tempList);
		    //System.debug('payload: ' + payload);
		
		}catch(Exception e){
			System.debug('Erro deserialize');
        }

	}

	public void ExecutarCargaEstruturasServiceTo()
	{
        
        ServiceTO.ParcelamentoTO parcelamento = new ServiceTO.ParcelamentoTO();
        parcelamento.qtdParcelas = 1;
        parcelamento.juros = 1;
        parcelamento.iof = 1.1;
        parcelamento.encargos = 1;
        parcelamento.descricao = 'Teste';
        parcelamento.nomeFormaPagamento = 'Teste';
        parcelamento.custoapolice = 1;
        parcelamento.codigo = 1;
        parcelamento.meioRecebimentoPrimeiraParcela = 'Teste';
        parcelamento.meioRecebimentoDemaisParcelas = 'Teste';
        parcelamento.valorPrimeiraParcela = 'Teste';
        parcelamento.valorDemaisParcelas = 'Teste';
        parcelamento.idFormaPagamento = 'Teste';
        parcelamento.agrupamento = 'Teste';
        parcelamento.opcao = 1;
        parcelamento.descontoAgravo = 1.1;
        parcelamento.antecipacaoComissao = true;
        
		//----------

		// INICIO - PLV-4614-VI-Guilherme Brito
		ServiceTO.ParamPagamentoBeneficiarioTO paramPagamento = new ServiceTO.ParamPagamentoBeneficiarioTO();
		paramPagamento.id  = 'Teste';
        paramPagamento.idobjeto  = 'Teste';
        paramPagamento.dataprogramadapagamento = System.today();
        paramPagamento.valorpagamento = 1.1;
        paramPagamento.idconta  = 'Teste';
        paramPagamento.cnpjcpf  = 'Teste';
        paramPagamento.tipoconta  = 'Teste';
        paramPagamento.status  = 'Teste';
        paramPagamento.datapagamento = System.today();
        paramPagamento.tipopagamento  = 'Teste';
        paramPagamento.matricula  = 'Teste';
        paramPagamento.codigoexcecao  = 'Teste';
        paramPagamento.descricaoexcecao  = 'Teste';
        paramPagamento.valorbruto = 1.1;
        paramPagamento.tributacao  = 'Teste';
        paramPagamento.tiporemuneracao  = 'Teste';
        paramPagamento.datacancelamento = System.today();
        paramPagamento.motivo  = 'Teste';
        paramPagamento.descricao  = 'Teste';
        paramPagamento.susepcorretor  = 'Teste';
        paramPagamento.dataatualizacao = System.today();
		
		//----------

		ServiceTO.validarBloqueioBancarioTO validarBloqueio = new ServiceTO.validarBloqueioBancarioTO();
		validarBloqueio.body = 'Teste';

		//----------

		ServiceTO.OrcamentoCalculoTO orcamentoCalculo = new ServiceTO.OrcamentoCalculoTO();
		orcamentoCalculo.empresa = 'Teste';
		orcamentoCalculo.sucursal = 'Teste';
		orcamentoCalculo.ramo = 'Teste';
		orcamentoCalculo.apolice = 'Teste';
		orcamentoCalculo.tipoSeguro = 'Teste';
		orcamentoCalculo.tipoEndosso = 'Teste';
		orcamentoCalculo.dataCalculo = System.today();
		orcamentoCalculo.vigenciaInicial = System.today();
		orcamentoCalculo.meioComercializacao = 'Teste';

		//----------

		ServiceTO.ParamOrcamentoCalculoTO paramOrcamentoCalculo = new ServiceTO.ParamOrcamentoCalculoTO();
		paramOrcamentoCalculo.orcamento = orcamentoCalculo;

		//----------

		ServiceTO.PropostaCalculoTO propostaCalculo = new ServiceTO.PropostaCalculoTO();
		propostaCalculo.numeroOrcamento = '1';
		
		//----------

		ServiceTO.ParamPropostaCalculoTO paramPropostaCalculo = new ServiceTO.ParamPropostaCalculoTO();
		paramPropostaCalculo.proposta = propostaCalculo;
		
		//----------

		ServiceTO.DetalheOrcamentoCancelamentoTO DetalheOrcamentoCancelamentoTO = new ServiceTO.DetalheOrcamentoCancelamentoTO();
		DetalheOrcamentoCancelamentoTO.numeroOrcamento = 'Teste';
		DetalheOrcamentoCancelamentoTO.status = 'Teste';
		DetalheOrcamentoCancelamentoTO.tipoSeguro = 'Teste';
				
		//----------
		
		ServiceTO.OrcamentoCancelamentoTO OrcamentoCancelamentoTO = new ServiceTO.OrcamentoCancelamentoTO();
		OrcamentoCancelamentoTO.orcamento = DetalheOrcamentoCancelamentoTO;
				
		//----------

		List<ServiceTO.OrcamentoCancelamentoTO> listaOrcamentoCancelamentoTO = new List<ServiceTO.OrcamentoCancelamentoTO>();
		ServiceTO.OfertasCancelamentoTO ofertasCancelamento = new ServiceTO.OfertasCancelamentoTO();
		ofertasCancelamento.ofertas = listaOrcamentoCancelamentoTO;

		//----------

		ServiceTO.OfertasCancelamentoTO OfertasCancelamentoTO = new ServiceTO.OfertasCancelamentoTO();
		ServiceTO.DataCancelamentoTO DataCancelamentoTO = new ServiceTO.DataCancelamentoTO();
		DataCancelamentoTO.data = OfertasCancelamentoTO;
		
		//----------

		ServiceTO.OrcamentoTO OrcamentoTO = new ServiceTO.OrcamentoTO();
		OrcamentoTO.numeroOrcamento = 'Teste';
		OrcamentoTO.numeroPortal = 'Teste';
		OrcamentoTO.ramoSeguro = 1;
		OrcamentoTO.varConsultivo = true;
		OrcamentoTO.ordemPortal = 'Teste';

		//----------

		List<ServiceTO.OfertaTO> listaOfertaTO = new List<ServiceTO.OfertaTO>();
		ServiceTO.RetornoValidacaoProdutoTO retorno = new ServiceTO.RetornoValidacaoProdutoTO();
		ServiceTO.PayRetornoOfertasTO PayRetornoOfertasTO = new ServiceTO.PayRetornoOfertasTO();
		PayRetornoOfertasTO.ofertas = listaOfertaTO;
		PayRetornoOfertasTO.retornoValidacaoProduto = retorno;

		//----------

		List<ServiceTO.RecusaTO> listaRecusaTO = new List<ServiceTO.RecusaTO>();
		ServiceTO.RetornoValidacaoProdutoTO RetornoValidacaoProdutoTO = new ServiceTO.RetornoValidacaoProdutoTO();	
		RetornoValidacaoProdutoTO.recusas = listaRecusaTO;

		//----------

		List<String> lista = new List<String>();
		List<ServiceTO.FranquiaTO> listaFranquiaTO = new List<ServiceTO.FranquiaTO>();
		List<ServiceTO.CarenciaTO> listaCarenciaTO = new List<ServiceTO.CarenciaTO>();
		ServiceTO.CaracteristicaEspecialTO CaracteristicaEspecialTO = new ServiceTO.CaracteristicaEspecialTO();
		ServiceTO.CoberturaRetornoOfertaTO CoberturaRetornoOfertaTO = new ServiceTO.CoberturaRetornoOfertaTO();
		CoberturaRetornoOfertaTO.sigla = 'Teste';
		CoberturaRetornoOfertaTO.prioridade = 1.1;
		CoberturaRetornoOfertaTO.caracteristica = 'Teste';
		CoberturaRetornoOfertaTO.tipoGarantia = 'Teste';
		CoberturaRetornoOfertaTO.nome = 'Teste';
        CoberturaRetornoOfertaTO.tipo = 'Teste';
        CoberturaRetornoOfertaTO.obrigatorio = true;
        CoberturaRetornoOfertaTO.limiteMinimo = 1.1;
        CoberturaRetornoOfertaTO.limiteMaximo = 1.1;
		CoberturaRetornoOfertaTO.inclui = lista;
        CoberturaRetornoOfertaTO.descricao = 'Teste';
		CoberturaRetornoOfertaTO.franquias = listaFranquiaTO;
		CoberturaRetornoOfertaTO.filtrada = true;
		CoberturaRetornoOfertaTO.carencias = listaCarenciaTO;
		CoberturaRetornoOfertaTO.caracteristicaespecial = CaracteristicaEspecialTO;
		CoberturaRetornoOfertaTO.ramo = 'Teste';

		//----------

		ServiceTO.SeguroContratoTO SeguroContratoTO = new ServiceTO.SeguroContratoTO();
		SeguroContratoTO.idsalesforce = UserInfo.getUserId();
		SeguroContratoTO.empresa = 'Teste';
		SeguroContratoTO.sucursal = 'Teste';
		SeguroContratoTO.ramo = 'Teste';
		SeguroContratoTO.apolice = 'Teste';
		SeguroContratoTO.endosso = 'Teste';
		SeguroContratoTO.situacaoapolice = 'Teste';
		SeguroContratoTO.statuscontrato = 'Teste';
		SeguroContratoTO.payload = 'Teste';
		SeguroContratoTO.vigenciainicial = system.today();
		SeguroContratoTO.vigenciafinal = system.today();
		SeguroContratoTO.produto = 'Teste';
		SeguroContratoTO.canal = 'Teste';
		SeguroContratoTO.suseplider = 'Teste';
		SeguroContratoTO.quantidadeparcelas = 1;
		SeguroContratoTO.tipoendosso = 'Teste';
		SeguroContratoTO.tiposeguro = 'Teste';
		SeguroContratoTO.titulocapitalizacao = 1;
		SeguroContratoTO.numerocontratoparceiro = 'Teste';
		SeguroContratoTO.siglatipoendosso = 'Teste';
		SeguroContratoTO.cpf = 'Teste';
		SeguroContratoTO.nome = 'Teste';
		SeguroContratoTO.numeropropostaporto = 'Teste';
		SeguroContratoTO.dataemissao = system.today();
		SeguroContratoTO.codigoparceiro = 'Teste';
		SeguroContratoTO.quantidadevidas = 1;
		SeguroContratoTO.parcelas = new List<ParcelaContratoTO>();
		SeguroContratoTO.origemproposta = 'Teste';
		SeguroContratoTO.datacancelamento = system.today();

		//----------

		ServiceTO.SeguroContratoCancelamentoTO SeguroContratoCancelamentoTO = new ServiceTO.SeguroContratoCancelamentoTO();
		SeguroContratoCancelamentoTO.apolice = 'Teste';
		SeguroContratoCancelamentoTO.endosso = 'Teste';
		SeguroContratoCancelamentoTO.sucursal = 'Teste';
		SeguroContratoCancelamentoTO.ramo = 'Teste';
		SeguroContratoCancelamentoTO.empresa = 'Teste';

		//----------
		
		ServiceTO.OfertaTO OfertaTO = new ServiceTO.OfertaTO();
		OfertaTO.orcamento = OrcamentoTO;
		OfertaTO.regras = new ServiceTO.RegrasRetornoOfertaTO();
		OfertaTO.parcelamentos = new List<ServiceTO.ParcelamentoTO>();
		OfertaTO.retornoAceitacao = new ServiceTO.RetornoAceitacaoTO();

		//----------	

		ServiceTO.RetornoAceitacaoTO RetornoAceitacaoTO = new ServiceTO.RetornoAceitacaoTO();
		RetornoAceitacaoTO.analises = new List<ServiceTO.AnaliseTO>();
        RetornoAceitacaoTO.avisos = new List<ServiceTO.AvisoTO>();
        RetornoAceitacaoTO.recusas = listaRecusaTO;
        RetornoAceitacaoTO.pendencias = new List<ServiceTO.PendenciaTO>();
		RetornoAceitacaoTO.decisoes = new List<ServiceTO.DecisaoTO>();

		//----------

		ServiceTO.MensagenTO MensagenTO = new ServiceTO.MensagenTO();	
		MensagenTO.cliente = 'Teste';
		MensagenTO.interna = 'Teste';
		MensagenTO.representante = 'Teste';

		//----------

		ServiceTO.AnaliseTO AnaliseTO = new ServiceTO.AnaliseTO();
		AnaliseTO.codigo = 1;
        AnaliseTO.area = 'Teste';
        AnaliseTO.procedimento = 'Teste';
        AnaliseTO.descricao = 'Teste';
        AnaliseTO.severidade = 1;
        AnaliseTO.mensagens = MensagenTO;

		//----------

		ServiceTO.AvisoTO AvisoTO = new ServiceTO.AvisoTO();
		AvisoTO.codigo = 1;
        AvisoTO.area = 'Teste';
        AvisoTO.procedimento = 'Teste';
        AvisoTO.descricao = 'Teste';
        AvisoTO.severidade = 1;
        AvisoTO.mensagens = MensagenTO;

		//----------
		
		ServiceTO.PendenciaTO PendenciaTO = new ServiceTO.PendenciaTO();
		PendenciaTO.codigo = 1;
		PendenciaTO.identificacao = 'Teste';
		PendenciaTO.atendida = true;
        PendenciaTO.area = 'Teste';
        PendenciaTO.procedimento = 'Teste';
        PendenciaTO.descricao = 'Teste';
        PendenciaTO.severidade = 1;
        PendenciaTO.mensagens = MensagenTO;

		//----------

		ServiceTO.DecisaoTO DecisaoTO = new ServiceTO.DecisaoTO();
		DecisaoTO.acao = 'Teste';
		DecisaoTO.codigo = 1;
		DecisaoTO.descricao = 'Teste';
		DecisaoTO.tipo = 'Teste';

		//----------

		ServiceTO.QuestionarioTO QuestionarioTO = new ServiceTO.QuestionarioTO();
		QuestionarioTO.idPergunta = 'Teste';
    	QuestionarioTO.pergunta = 'Teste';
    	QuestionarioTO.tipoResposta = 'Teste';
		QuestionarioTO.opcoesRespostas = 'Teste';
		
		//----------

		ServiceTO.RemuneracaoRetornoOfertaTO RemuneracaoRetornoOfertaTO = new ServiceTO.RemuneracaoRetornoOfertaTO();
		RemuneracaoRetornoOfertaTO.tipoRemuneracao = 'Teste';
        RemuneracaoRetornoOfertaTO.obrigatorio = true;
        RemuneracaoRetornoOfertaTO.limiteMinimo = 1.1;
		RemuneracaoRetornoOfertaTO.limiteMaximo = 2.1;
		RemuneracaoRetornoOfertaTO.antecipacaoComissoes = new List<ServiceTO.AntecipacaoComissaoTO>();

		//----------

		ServiceTO.AntecipacaoComissaoTO AntecipacaoComissaoTO = new ServiceTO.AntecipacaoComissaoTO();
		AntecipacaoComissaoTO.limiteMaximo = 2.1;
		AntecipacaoComissaoTO.limiteMinimo = 1.1;
		AntecipacaoComissaoTO.tipoEvento = 'Teste';

		//----------
		
		//ServiceTO.CaracteristicaEspecialTO CaracteristicaEspecialTO = new ServiceTO.CaracteristicaEspecialTO();
		CaracteristicaEspecialTO.limiteMaximo = 2.1;
		CaracteristicaEspecialTO.limiteMinimo = 1.1;
		CaracteristicaEspecialTO.tipo = 'Teste';
		
		//----------
		
		ServiceTO.FranquiaTO FranquiaTO = new ServiceTO.FranquiaTO();
		FranquiaTO.padrao = true;
		FranquiaTO.descricao = 'Teste';
		FranquiaTO.valor = 'Teste';
		
		//----------
		
		ServiceTO.CarenciaTO CarenciaTO = new ServiceTO.CarenciaTO();
		CarenciaTO.padrao = true;
		CarenciaTO.descricao = 'Teste';
		CarenciaTO.valor = 'Teste';
		
		//----------
		// FIM - PLV-4614-VI-Guilherme Brito 

		ServiceTO.RecusaTO RecusaTO = new ServiceTO.RecusaTO();	
		RecusaTO.codigo = 1;
        RecusaTO.mensagens = MensagenTO;
        RecusaTO.descricao = 'Teste';
        RecusaTO.area = 'Teste';
        RecusaTO.procedimento = 'Teste';
		RecusaTO.severidade = 1;
		
		//----------

        ServiceTO.PlanoParcelamentoTO planoParcelamento = new ServiceTO.PlanoParcelamentoTO();
        planoParcelamento.idPlanoParcelamento = 'Teste';
		planoParcelamento.valorParcela = 1.1;
		planoParcelamento.qtdParcelas = 1;
		planoParcelamento.codigoMeioRecebimento = 'Teste';
		planoParcelamento.descricaoMeioRecebimento = 'Teste';
		
        //----------
	
		ServiceTO.MunicipioTO  municipio = new ServiceTO.MunicipioTO();
		municipio.codigoCidade = '1';
		municipio.unidadeFederativaCodigo = '1';
		municipio.nomeCidade = '1';

		//----------
		
        ServiceTO.ControleBatchTO controleBatch = new ServiceTO.ControleBatchTO();
        controlebatch.idjob = 'Teste';
        controlebatch.servico = 'Teste';
        
        //----------
        
        ServiceTO.ParcelaCancelamentoTO parcelaCancelamento = new ServiceTO.ParcelaCancelamentoTO();
        parcelaCancelamento.apolice = 'Teste';
        parcelaCancelamento.ramo  = 'Teste';
        parcelaCancelamento.endosso  = 'Teste';
        parcelaCancelamento.sucursal  = 'Teste';
        parcelaCancelamento.numeroparcela  = 1;

		//----------		
        
		ServiceTO.RamoSeguroTO ramoSeguro = new ServiceTO.RamoSeguroTO();
		ramoSeguro.codigoRamo = '1';
		ramoSeguro.nomeRamo = '1';
		ramoSeguro.siglaRamo = '1';
		ramoSeguro.codigoEmpresa = '1';
		ramoSeguro.codigoGrupoRamo = '1';
		ramoSeguro.grupoRamosSinistro = '1';
		ramoSeguro.grupoRamosProducao = '1';

		//-----------
		ServiceTO.RamosSeguroListagemTO ramoSeguroList = new ServiceTO.RamosSeguroListagemTO();
		ramoSeguroList.LotusRamosSeguroDBOutput = new List<ServiceTO.RamoSeguroTO>();
		ramoSeguroList.LotusRamosSeguroDBOutput.add(ramoSeguro);

		//-----------
		ServiceTO.FormaPagamentoTO formaPagamento = new ServiceTO.FormaPagamentoTO();
		formaPagamento.codigoModalidade = '1';
		formaPagamento.codigoPlanoParcelamento = '1';
		formaPagamento.descricaoPlanoParcelamento = '1';


		//------------
		//PLV 4518 Inicio Fix 3
		ServiceTO.ProfissaoTO profissao = new ServiceTO.ProfissaoTO();

		ServiceTO.ListProfissoesTO lstProfissao = new ServiceTO.ListProfissoesTO();
		lstProfissao.codigoFamilia = '1';
		lstProfissao.codigoGrandeGrupo = '1';
		lstProfissao.codigoOcupacao = '1';
		lstProfissao.codigoSubGrupo = '1';
		lstProfissao.codigoSubGrupoPrincipal = '1';
		lstProfissao.nomeFamilia = '1';
		lstProfissao.nomeGrandeGrupo = '1';
		lstProfissao.nomeOcupacao = '1';
		lstProfissao.nomeSubGrupo = '1';
		lstProfissao.nomeSubGrupoPrincipal = '1';

		/*ServiceTO.NewListProfissoesTO lstProfissao = new ServiceTO.NewListProfissoesTO();
		
		lstProfissao.codigoGrupo = '1';		
		lstProfissao.codigoOcupacao = '1';
		lstProfissao.codigoSubGrupo = '1';
		lstProfissao.codigoSubGrupoPrincipal = '1';
		lstProfissao.nomeFamilia = '1';
		lstProfissao.nomeGrandeGrupo = '1';
		lstProfissao.nomeOcupacao = '1';
		lstProfissao.nomeSubGrupo = '1';
		lstProfissao.nomeSubGrupoPrincipal = '1';
		lstProfissao.Teste = '1';
		lstProfissao.codigoFamilia = '1';*/			

		profissao.ResponseObterDominiosOcupacao = new ServiceTO.ProfissaoDetalheTO();
		profissao.ResponseObterDominiosOcupacao.codigoRetorno = '1';
		profissao.ResponseObterDominiosOcupacao.ocupacao = new List<ServiceTO.ListProfissoesTO>();
		profissao.ResponseObterDominiosOcupacao.ocupacao.add(lstProfissao);

		//PLV 4518 Fim Fix 3
		//------------
		ServiceTO.EmpresasSeguroListagemTO empresasSeguro = new ServiceTO.EmpresasSeguroListagemTO();

		ServiceTO.EmpresaSeguroTO empresasegurodet = new ServiceTO.EmpresaSeguroTO();
		empresasegurodet.codigoEmpresa = '1';
		empresasegurodet.nomeEmpresa = '1';
		empresasegurodet.numeroCpfCnpj = '1';
		empresasegurodet.ordem = '1';
		empresasegurodet.digitoCpfCnpj = '1';
		empresasegurodet.siglaEmpresa = '1';
		empresasegurodet.codigoPlanoContaContabil = '1';
		empresasegurodet.tipoLivroDiario = '1';
		empresasegurodet.numeroInscricaoEstadual = '1';

		empresasSeguro.LotusEmpresaSeguroDBOutput = new List<ServiceTO.EmpresaSeguroTO>();
		empresasSeguro.LotusEmpresaSeguroDBOutput.add(empresasegurodet);

		//------------
		ServiceTO.RamoAtividadeTO ramoAtividade = new ServiceTO.RamoAtividadeTO();

		ServiceTO.ListRamoAtividadeTO ramoatividadedet = new ServiceTO.ListRamoAtividadeTO();
		ramoatividadedet.classe = '1';
		ramoatividadedet.divisao = '1';
		ramoatividadedet.grupo = '1';
		ramoatividadedet.nomeAtividadeCnae = '1';
		ramoatividadedet.numeroCnae = 1;
		ramoatividadedet.secao = '1';
		ramoatividadedet.subClasse = '1';

		ramoAtividade.ResponseObterDominiosCnae = new ServiceTO.RamoAtividadeCnaeTO();
		ramoAtividade.ResponseObterDominiosCnae.cnae = new List<ServiceTO.ListRamoAtividadeTO>();
		ramoAtividade.ResponseObterDominiosCnae.codigoRetorno = '1';
		ramoAtividade.ResponseObterDominiosCnae.cnae.add(ramoatividadedet);

		//------------
		ServiceTO.ObterCidadeUFTO cidadeUf = new ServiceTO.ObterCidadeUFTO();

		ServiceTO.ListenderecoGuiaPostalEBOTO quiapostal = new ServiceTO.ListenderecoGuiaPostalEBOTO();
		quiapostal.codigoCidade = '1';
		quiapostal.cepCidade = '1';
		quiapostal.cepComplementoCidade = '1';
		quiapostal.cidadeObservacao = '1';
		quiapostal.primeiroCodigoFoneticoCidade = '1';
		quiapostal.segundoCodigoFoneticoCidade = '1';
		quiapostal.terceiroCodigoFoneticoCidade = '1';
		quiapostal.unidadeFederativaCodigo = '1';
		quiapostal.nomeCidade = '1';


		cidadeUf.obterCidadeResponse = new ServiceTO.obterCidadeEBOTO();
		cidadeUf.obterCidadeResponse.obterCidadeEBO = new ServiceTO.enderecoGuiaPostalEBOTO();
		cidadeUf.obterCidadeResponse.obterCidadeEBO.enderecoGuiaPostalEBO = new List<ServiceTO.ListenderecoGuiaPostalEBOTO>();

		cidadeUf.obterCidadeResponse.obterCidadeEBO.enderecoGuiaPostalEBO.add(quiapostal);


		//-------------
		ServiceTO.ObterCidadeCEPTO cidadeCep = new ServiceTO.ObterCidadeCEPTO();

		cidadeCep.obterEnderecoPorCEPResponse = new ServiceTO.enderecosGuiaPostalEBOCEPTO();
		cidadeCep.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO = new ServiceTO.enderecoGuiaPostalEBOCEPTO();
		cidadeCep.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO = new ServiceTO.DetenderecoGuiaPostalEBOTO();

		ServiceTO.CidadeObservacao cidadeobs = new ServiceTO.CidadeObservacao();
		cidadeobs.nil = '1';

		ServiceTO.enderecoCompleto endcompleto = new ServiceTO.enderecoCompleto();
		endcompleto.tipoLogradouro = '1';
		endcompleto.logradouro = '1';
		endcompleto.complemento = '1';
		endcompleto.bairro = '1';
		endcompleto.cidade = '1';
		endcompleto.uf = '1';
		endcompleto.cep = '1';
		endcompleto.complementoCep = '1';

		ServiceTO.DetenderecoGuiaPostalEBOTO guipostalCep = new ServiceTO.DetenderecoGuiaPostalEBOTO();
		guipostalCep.codigoLogradouro = '1';
		guipostalCep.codigoFoneticoLogradouro = '1';
		guipostalCep.primeiroCodigoFoneticoLogradouro = '1';
		guipostalCep.segundoCodigoFoneticoLogradouro = '1';
		guipostalCep.terceiroCodigoFoneticoLogradouro = '1';
		guipostalCep.codigoBairro = '1';
		guipostalCep.codigoCidade = '1';
		guipostalCep.cepCidade = '1';
		guipostalCep.cepComplementoCidade = '1';
		guipostalCep.primeiroCodigoFoneticoCidade = '1';
		guipostalCep.segundoCodigoFoneticoCidade = '1';
		guipostalCep.terceiroCodigoFoneticoCidade = '1';
		guipostalCep.cepEspecial = '1';
		guipostalCep.cidadeObservacao = cidadeobs;
		guipostalCep.enderecoCompleto = endcompleto;

		cidadeCep.obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO = guipostalCep;

		//----------------
		ServiceTO.ObterCidadeLogradouroTO cidadeLogradouro = new ServiceTO.ObterCidadeLogradouroTO();
		cidadeLogradouro.obterLogradourosPorLogradouroResponse = new ServiceTO.enderecosGuiaPostalLocalTO();
		cidadeLogradouro.obterLogradourosPorLogradouroResponse.enderecosGuiaPostalLocal = new ServiceTO.enderecoGuiaPostalLocalTO();
		cidadeLogradouro.obterLogradourosPorLogradouroResponse.enderecosGuiaPostalLocal.enderecoGuiaPostalLocal = new List<ServiceTO.LstEnderecosDetalheTO>();

		ServiceTO.geolocalizacao geolocalizacao = new ServiceTO.geolocalizacao();
		geolocalizacao.longitude = '1';
		geolocalizacao.latitude = '1';

		ServiceTO.unidadeFederacao uf = new ServiceTO.unidadeFederacao();
		uf.codigoUnidadeFederacao = '1';
		uf.nomeUnidadeFedearacao = '1';
		uf.ultimaAtualizacaoLinha = '1';

		ServiceTO.Cidade cidade = new ServiceTO.Cidade();
		cidade.codigoCidadeLocalidade = '1';
		cidade.complementoCepCidade = '1';
		cidade.nomeCidadeNoGuiaPostal = '1';
		cidade.numeroCepLogradouro = '1';
		cidade.observacaoCidade = '1';
		cidade.primeiroCodigoFonetico = '1';
		cidade.segundoCodigoFonetico = '1';
		cidade.terceiroCodigoFonetico = '1';

		ServiceTO.Bairro bairro = new ServiceTO.Bairro();
		bairro.codigoBairro = '1';
		bairro.nomeBairro = '1';

		ServiceTO.LstEnderecosDetalheTO detalhe = new ServiceTO.LstEnderecosDetalheTO();
		detalhe.codigoLogradouro = '1';
		detalhe.nomeLogradouro = '1';
		detalhe.complementoLogradouro = '1';
		detalhe.tipoLogradouro = '1';
		detalhe.numeroCepLogradouro = '1';
		detalhe.complementoCepLogradouro = '1';
		detalhe.codigoFonetico = '1';
		detalhe.primeiroCodigoFonetico = '1';
		detalhe.segundoCodigoFonetico = '1';
		detalhe.terceiroCodigoFonetico = '1';
		detalhe.bairro = bairro;
		detalhe.cidade = cidade;
		detalhe.unidadeFederacao = uf;
		detalhe.geolocalizacao = geolocalizacao;

		cidadeLogradouro.obterLogradourosPorLogradouroResponse.enderecosGuiaPostalLocal.enderecoGuiaPostalLocal.add(detalhe);

		// INICIO - Cobertura de classe - Guilherme Brito
		//-------------------

		ServiceTO.RegrasRetornoOfertaTO RegrasRetornoOfertaTO = new ServiceTO.RegrasRetornoOfertaTO();
		RegrasRetornoOfertaTO.coberturasLideres = new List<string>();
        RegrasRetornoOfertaTO.coberturas = new List<ServiceTO.CoberturaRetornoOfertaTO>();
        RegrasRetornoOfertaTO.remuneracoes = new List<ServiceTO.RemuneracaoRetornoOfertaTO>();
		RegrasRetornoOfertaTO.questionarios = new List<ServiceTO.QuestionarioTO>();
		RegrasRetornoOfertaTO.idquestionario = 'Teste';

		// FIM - Cobertura de classe - Guilherme Brito
		//-------------------

		ServiceTO.ListResultadoRetornoBuscaEndereco retornoBuscaEndereco = new ServiceTO.ListResultadoRetornoBuscaEndereco();
		retornoBuscaEndereco.codigoLogradouro = '1';
		retornoBuscaEndereco.tipoLogradouro = '1';
		retornoBuscaEndereco.nomelogradouro = '1';
		retornoBuscaEndereco.codigoCidade = '1';
		retornoBuscaEndereco.nomeCidade = '1';
		retornoBuscaEndereco.unidadeFederativaCodigo = '1';
		retornoBuscaEndereco.cepCidade = '1';
		retornoBuscaEndereco.cepCidadeComplemento = '1';
		retornoBuscaEndereco.codigoBairro = '1';
		retornoBuscaEndereco.nomeBairro = '1';
		retornoBuscaEndereco.complementologradouro = '1';
		retornoBuscaEndereco.cep = '1';
		retornoBuscaEndereco.cepComplemento = '1';


		//-----------------------
		ServiceTO.ModalidadeTO modalidade = new ServiceTO.ModalidadeTO();
		modalidade.Modalidades = new List<ServiceTO.ListModalidadesTO>();

		ServiceTO.ListModalidadesTO modalidadedet = new ServiceTO.ListModalidadesTO();
		modalidadedet.codigoEmpresa = '1';
		modalidadedet.codigoRamo = '1';
		modalidadedet.codigoModalidade = '1';
		modalidadedet.nomeModalidade = '1';
		modalidadedet.dataAlteracao = '1';
		modalidadedet.grupoRamosProducao = '1';

		modalidade.Modalidades.add(modalidadedet);

		//-------------------------
		ServiceTO.ContratoTO contrato = new ServiceTO.ContratoTO();

		ServiceTO.ContratoDetalheTO contratodet = new ServiceTO.ContratoDetalheTO();
		contratodet.codigoEmpresa = 1;
		contratodet.codigoSucursal = 1;
		contratodet.ramoSeguro = 1;
		contratodet.numeroApolice = '1';
		contratodet.numeroEndosso = 1;

		contrato.contrato = contratodet;

		//---------------------------
		ServiceTO.IntegrationFail integration = new ServiceTO.IntegrationFail();
		integration.empresa = '1';
		integration.sucursal = '1';
		integration.ramo = '1';
		integration.apolice = '1';
		integration.endosso = '1';
		integration.origem = '1';
		integration.proposta = '1';
		integration.payloadentrada = '1';
		integration.endpoint = '1';
		integration.metodo = '1';
		integration.payloaderro = '1';
		integration.datafalha = '1';
		integration.reprocessamento = 1;

		//-------------------
		ServiceTO.PayloadDadosEcmTO payloadDadosEcm = new ServiceTO.PayloadDadosEcmTO();
		payloadDadosEcm.dados = new List<ServiceTO.DetalheDadosEcmTO>();

		ServiceTO.DetalheDadosEcmTO ecmdet = new ServiceTO.DetalheDadosEcmTO();
		ecmdet.tipoarquivo = '1';
		ecmdet.codfatura = '1';
		ecmdet.codcontrato = '1';
		ecmdet.idarquivo = '1';


		payloadDadosEcm.dados.add(ecmdet);

		// ALTERACAO A PEDIDO DE FRANCISCO PARA CORRIGIR CLASSE SERVICETOTEST - 08/12/22 INICIO 
		//--------------------
		// ServiceTO.RetornoConsultaPortoCapTO retornoportocap = new ServiceTO.RetornoConsultaPortoCapTO();
		// retornoportocap.codigoproduto = '1';
		// retornoportocap.codigopromocao = '1';
		// retornoportocap.valortitulo = 1;
		// retornoportocap.versaotitulo = '1';
		// retornoportocap.mensagem = '1';
		// ALTERACAO A PEDIDO DE FRANCISCO PARA CORRIGIR CLASSE SERVICETOTEST - 08/12/22 FIM

		//---------------------
		ServiceTO.ParametroContabilizacaoTO parametroContab = new ServiceTO.ParametroContabilizacaoTO();

		parametroContab.dataProcessamento = System.today();

		//-------------------------
		ServiceTO.ParametroConsultarPropostaTO parametroConsultaContrato = new ServiceTO.ParametroConsultarPropostaTO();
		parametroConsultaContrato.empresa = '1';
		parametroConsultaContrato.ramo = '1';
		parametroConsultaContrato.origem = '1';
		parametroConsultaContrato.proposta = '1';
		parametroConsultaContrato.parcela = 1; // INICIO/FIM - Cobertura de classe - Guilherme Brito

		ServiceTO.ParametroConsultaContratoPorApoliceTO  parametroConsultaContratoApolice = new ServiceTO.ParametroConsultaContratoPorApoliceTO();

		parametroConsultaContratoApolice.empresa = '1';
		parametroConsultaContratoApolice.sucursal = '1';
		parametroConsultaContratoApolice.ramo = '1';
		parametroConsultaContratoApolice.apolice = '1';
		parametroConsultaContratoApolice.endosso = '1';
		parametroConsultaContratoApolice.numeroparcela = 1;

		//---------------------------
// INICIO - Cobertura de classe - Guilherme Brito
		ServiceTO.RetornoPortoCapTO RetornoPortoCapTO = new ServiceTO.RetornoPortoCapTO();
		RetornoPortoCapTO.cd_retorno = 1;
		RetornoPortoCapTO.id_lote = 1;
		RetornoPortoCapTO.nm_retorno = 'Teste';
		RetornoPortoCapTO.cd_versao = 1;
		RetornoPortoCapTO.listCessionarioTO = new List<TituloCapitalizacaoTO.CessionarioTO>();
// FIM - Cobertura de classe - Guilherme Brito
		//---------------------------

		ServiceTO.ParamAtualizacaoStatusSinistroTO parametroAtualizacaoStatusSinistro = new ServiceTO.ParamAtualizacaoStatusSinistroTO();

		parametroAtualizacaoStatusSinistro.idseguradoparceiro ='1';
		parametroAtualizacaoStatusSinistro.cpf ='1';
		parametroAtualizacaoStatusSinistro.nome ='1';
		parametroAtualizacaoStatusSinistro.numerosinistro ='1';
		parametroAtualizacaoStatusSinistro.codigoprodutoparceiro ='1';
		parametroAtualizacaoStatusSinistro.status ='1';
		parametroAtualizacaoStatusSinistro.dataocorrencia = System.today();
		parametroAtualizacaoStatusSinistro.dataaviso = System.today();

		//---------------------------
		ServiceTO.RetornoAtualizacaoSinistroTO retornoAtualizacaoSinistro = new ServiceTO.RetornoAtualizacaoSinistroTO();
		retornoAtualizacaoSinistro.dataExecucao = '1';
		retornoAtualizacaoSinistro.servico = '1';
		retornoAtualizacaoSinistro.statusHttp = 1;
		retornoAtualizacaoSinistro.mensagem = '1';


		//---------------------------
		ServiceTO.ParamGerarErroHerokuTO parametroGerarErroHeroku = new ServiceTO.ParamGerarErroHerokuTO();
		parametroGerarErroHeroku.data = '1';
		parametroGerarErroHeroku.objeto = '1';
		parametroGerarErroHeroku.idregistro = '1';
		parametroGerarErroHeroku.codigointegracao = '1';
		parametroGerarErroHeroku.codigoerro = '1';
		parametroGerarErroHeroku.descricaoerro = '1';
		parametroGerarErroHeroku.status = '1';

		//-----------------------------

		ServiceTO.RetornoCriarParcelaTO retornoCriarParcela = new ServiceTO.RetornoCriarParcelaTO();
		retornoCriarParcela.data = new List<ParcelaContratoTO>();

		ServiceTO.MetaTO meta = new ServiceTO.MetaTO();
		meta.dataExecucao = '1';
		meta.servico = '1';
		meta.statusHttp = 1;
		meta.mensagem = '1';

		ParcelaContratoTO parcela = new ParcelaContratoTO();
		parcela.idexterno = '1';
		parcela.codigoparceiro = '1';
		parcela.idfatura = 1;
		parcela.origemproposta = 1;
		parcela.idproposta = '1';
		parcela.numeropropostaporto = '1';
		parcela.produto = '1';
		parcela.apolice = '1';
		parcela.empresa = '1';
		parcela.sucursal = '1';
		parcela.ramo = '1';
		parcela.endosso = '1';
		parcela.responsavelfinanceiro = '1';
		parcela.tiporesponsavelpagamento = '1';
		parcela.seguradosalesforce = '1';
		parcela.vidasalesforce = '1';
		parcela.datapagamento = '1';
		parcela.datavencimento = '1';
		parcela.dataemissao = '1';
		parcela.datacancelamento = '1';
		parcela.numeroparcela = 1;
		parcela.status = '1';
		parcela.titulo = '1';
		parcela.valoriof = 1;
		parcela.valorliquido = 1;
		parcela.valorparcela = 1;
		parcela.valorpago = 1;

		retornoCriarParcela.data.add(parcela);
		retornoCriarParcela.meta = meta;

	}

}