/**
 *
 * Classe responsável por todos TOs de serviços externos
 *
 **/
//PLV-3649 - INICIO - Ajuste no modificador de acesso da classe para atender novo servico
public class ServiceTO {
//PLV-3649 - FIM
	public static final String bodySericeUF = '{"obterCidadeRequest":{"obterCidade": "{{UF}}"}}'; 
	public static final String bodySericeCep = '{"obterEnderecoPorCep":{"cep": "{{CEP}}" , "cepSufixo": "{{SUFIXO}}"}}'; 
	public static final String bodySericeLogradouro = '{"obterLogradourosPorLogradouroRequest": {"logradouro" : "{{END}}" , "cidade": "{{CIDADE}}" , "estado": "{{UF}}", "numeroLogradouro" : "{{NUMERO}}"}}'; 

	/**
	 * Municipio__c
	 * @author Alex Gomes
	 **/
	public class MunicipioTO {
		public String codigoCidade { get; set; }
		//public String cepCidade { get; set; }
		//public String cepComplementoCidade { get; set; }
		//public String primeiroCodigoFoneticoCidade { get; set; }
		//public String segundoCodigoFoneticoCidade { get; set; }
		//public String terceiroCodigoFoneticoCidade { get; set; }
		public String unidadeFederativaCodigo { get; set; }
		public String nomeCidade { get; set; }
	}

	/**
	 * RamoSeguro__c
	 * @author Fernando Barcellos
	 **/
	public class RamoSeguroTO {
		public String codigoRamo { get; set; }
		public String nomeRamo { get; set; }
		//public String nomeAmigavel { get; set; }
		public String siglaRamo { get; set; }
		public String codigoEmpresa { get; set; }
		public String codigoGrupoRamo { get; set; }
		public String grupoRamosSinistro { get; set; }
		public String grupoRamosProducao  { get; set; }
	}

	public class RamosSeguroListagemTO {
		public List<RamoSeguroTO> LotusRamosSeguroDBOutput { get; set; }
	}

	/**
	 * FormaPagamento__c
	 * @author Alex Gomes
	 **/
	public class FormaPagamentoTO {
		//public String codigoEmpresa { get; set; }
		//public String codigoRamo { get; set; }
		public String codigoModalidade { get; set; }
		//public String codigoCategoriaContaContrato { get; set; }
		//public String codigoCategoriaObjetoSeguro { get; set; }
		//public String codigoOperacaoPrincipal { get; set; }
		//public String codigoSubOperacao { get; set; }
		public String codigoPlanoParcelamento { get; set; }
		public String descricaoPlanoParcelamento { get; set; }
		//public String numeroParcela { get; set; }
		//public String codigoMeioRecebimento { get; set; }
		//public String percentualAdicionalFracionamento { get; set; }
		//public String taxaJuros { get; set; }
		//public String quantidadeLimiteDiasAnteriorVencimento { get; set; }
		//public String quantidadeLimiteDiaVigencia { get; set; }
		//public String dataInicialVigencia { get; set; }
		//public String dataFinalVigencia { get; set; }
	}

	/**
	 * Profissao__c
	 * @author Fernando Barcellos
	 **/
/*
	public class ProfissaoTO {
		public List<ProfissaoGrandeGrupoTO> grandes_grupos { get; set; }
	}

	public class ProfissaoGrandeGrupoTO {
		public String codigo { get; set; }
		public String grande_grupo { get; set; }
		public List<ProfissaoGrupoPrincipalTO> grupos_principais { get; set; }
	}

	public class ProfissaoGrupoPrincipalTO {
		public String codigo { get; set; }
		public String grupo_principal { get; set; }
		public List<ProfissaoSubGrupoTO> sub_grupos { get; set; }
	}

	public class ProfissaoSubGrupoTO {
		public String codigo { get; set; }
		public String sub_grupo { get; set; }
		public List<ProfissaoFamiliaTO> familias { get; set; }
	}

	public class ProfissaoFamiliaTO {
		public String codigo { get; set; }
		public String familia { get; set; }
		public List<ProfissaoOcupacaoTO> ocupacoes { get; set; }
	}

	public class ProfissaoOcupacaoTO {
		public String codigo { get; set; }
		public String ocupacao { get; set; }
	}
*/
//PLV 4518 Inicio Fix3

	public class ProfissaoTO {
		public ProfissaoDetalheTO ResponseObterDominiosOcupacao { get; set; }
	}

	public class ProfissaoDetalheTO {
		public String codigoRetorno { get; set; }
		public List<ListProfissoesTO> ocupacao { get; set; }
	}

	/*public class ProfissaoTO {
		//public List<NewListProfissoesTO> ocupacoes { get; set; }
		public List<ListProfissoesTO> ocupacoes { get; set; }		
	}*/
//PLV 4518 Fim Fix3

	//PLV-2414 - Inicio
	//PLV-3137 - Inicio
	public class ParcelamentoTO
	{
		public Integer qtdParcelas { get; set; }
		public Integer juros { get; set; }
		public Double iof { get; set; }
		public Integer encargos { get; set; }
		public String descricao { get; set; }
		//PLV-3571 INÍCIO
		public String nomeFormaPagamento { get; set; }
		//PLV-3571 FIM
		public Integer custoapolice { get; set; }
		public Integer codigo { get; set; }
		public String meioRecebimentoPrimeiraParcela { get; set; }
		public String meioRecebimentoDemaisParcelas { get; set; }	///PLV-3137 -FIX-
		public String valorPrimeiraParcela { get; set; }
		public String valorDemaisParcelas { get; set; }		///PLV-3137 -FIX-
		public String idFormaPagamento { get; set; }
		//PLV-2678 - INICIO - Retornar agrupamento da Forma de pagamento para o portal
		public String agrupamento { get; set; }
		//PLV-2678 - FIM - Retornar agrupamento da Forma de pagamento para o portal
		
		//PLV-3318 - INICIO
        public integer opcao {get; set;}
		//PLV-3318 - FIM
		//PLV-3318 FIX - INICIO DA INCLUSAO DO DESCONTO NO PARCELAMENTO
        public Decimal descontoAgravo { get; set; }
		//PLV-3318 FIX - FIM DA INCLUSAO DO DESCONTO NO PARCELAMENTO
		//PLV-4344 - Inicio
		public Boolean antecipacaoComissao { get; set; }
		//PLV-4344 - Fim
		// public String limiteValorParcela {get; set; } // ANNVI-48 - INICIO/FIM
	}
	//PLV-3137 - FIM
	//PLV-2414 - Fim

	//PLV-2414 - Inicio
	public class PlanoParcelamentoTO{
		public String idPlanoParcelamento { get; set; }
		public Decimal valorParcela { get; set; }
		public Integer qtdParcelas  { get; set; }
		public String codigoMeioRecebimento { get; set; }
		public String descricaoMeioRecebimento { get;set; }
	}
	//PLV-2414 - Fim
	//PLV 4518 Inicio Fix3
	public class ListProfissoesTO {
		public String codigoFamilia { get; set; }
		public String codigoGrandeGrupo { get; set; }
		public String codigoOcupacao { get; set; }
		public String codigoSubGrupo { get; set; }
		public String codigoSubGrupoPrincipal { get; set; }
		public String nomeFamilia { get; set; }
		public String nomeGrandeGrupo { get; set; }
		public String nomeOcupacao { get; set; }
		public String nomeSubGrupo { get; set; }
		public String nomeSubGrupoPrincipal { get; set; }
	}

	 
	public class NewListProfissoesTO {
		public String codigoGrupo { get; set; }
		//public String codigoGrandeGrupo { get; set; }
		public String codigoOcupacao { get; set; }
		public String codigoSubGrupo { get; set; }
		public String codigoSubGrupoPrincipal { get; set; }
		public String nomeFamilia { get; set; }
		public String nomeGrandeGrupo { get; set; }
		public String nomeOcupacao { get; set; }
		public String nomeSubGrupo { get; set; }
		public String nomeSubGrupoPrincipal { get; set; }
		public String Teste { get; set; }
		public String codigoFamilia { get; set; }								
	}
	//PLV 4518 Fim Fix3

	//PLV 4878 INICIO
	public class OcupacoesTO {
		public List<TestListProfissoesTO> ocupacoes;
	}
	
	public class TestListProfissoesTO{
		public Integer numeroOcupacao { get; set; }
		public Integer codigoGrupo { get; set; }
		public String nomeOcupacao { get; set; }
		public String dataAtualizacao { get; set; }
		public String codigoSituacao { get; set; }
		public Integer codigoSubgrupoPrincipal { get; set; }
		public Integer codigoSubgrupo { get; set; }
		public Integer codigoFamilia { get; set; }
		public Integer codigoOcupacao { get; set; }
	}	
	//PLV 4878 FIM	


	/**
	 * RamoAtividade__c
	 * @author Fernando Barcellos
	 **/
/*  substituido pela nova classe
	public class RamoAtividadeTO {
		public List<RamoAtividadeSecaoTO> secoes { get; set; }
	}

	public class RamoAtividadeSecaoTO {
		public String secao { get; set; }
		public String denominacao { get; set; }
		public List<RamoAtividadeDivisaoTO> divisoes  { get; set; }
	}

	public class RamoAtividadeDivisaoTO {
		public String divisao { get; set; }
		public String denominacao { get; set; }
		public List<RamoAtividadeGrupoTO> grupos  { get; set; }
	}

	public class RamoAtividadeGrupoTO {
		public String grupo { get; set; }
		public String denominacao { get; set; }
		public List<RamoAtividadeClasseTO> classes  { get; set; }
	}

	public class RamoAtividadeClasseTO {
		public String classe { get; set; }
		public String denominacao { get; set; }
		public List<RamoAtividadeSubclasseTO> subclasses  { get; set; }
	}

	public class RamoAtividadeSubclasseTO {
		public String subclasse { get; set; }
		public String denominacao { get; set; }
	}
*/

	public class EmpresasSeguroListagemTO {
		public List<EmpresaSeguroTO> LotusEmpresaSeguroDBOutput { get; set; }
	}

	public class EmpresaSeguroTO {
		public String codigoEmpresa { get; set; }
		public String nomeEmpresa { get; set; }
		public String numeroCpfCnpj { get; set; }
		public String ordem {get; set; }
		public String digitoCpfCnpj {get; set; }
		public String siglaEmpresa { get; set; }
		public String codigoPlanoContaContabil { get; set; }
		public String tipoLivroDiario { get; set; }
		public String numeroInscricaoEstadual { get; set; }
	}

	/**
	 * @author João Losada
	 **/
	public class RamoAtividadeTO {
		public RamoAtividadeCnaeTO ResponseObterDominiosCnae { get; set; }
	}

	public class RamoAtividadeCnaeTO {
		public String codigoRetorno { get; set; }
		public List<ListRamoAtividadeTO> cnae { get; set; }
	}

	public class ListRamoAtividadeTO {
		public String classe { get; set; }
		public String divisao { get; set; }
		public String grupo { get; set; }
		public String nomeAtividadeCnae { get; set; }
		public Decimal numeroCnae { get; set; }
		public String secao { get; set; }
		public String subClasse { get; set; }
	}

	/**
	 * @author João Losada
	 * Retorno da busca feita por UF
	 **/
	public class ObterCidadeUFTO {
		public obterCidadeEBOTO obterCidadeResponse { get; set; }
	}

	public class obterCidadeEBOTO {
		public enderecoGuiaPostalEBOTO obterCidadeEBO { get; set; }
	}

	public class enderecoGuiaPostalEBOTO {
		public List<ListenderecoGuiaPostalEBOTO> enderecoGuiaPostalEBO { get; set; }
	}

	public class ListenderecoGuiaPostalEBOTO {
		public String codigoCidade { get; set; }
		public String cepCidade { get; set; }
		public String cepComplementoCidade { get; set; }
		public String cidadeObservacao { get; set; }
		public String primeiroCodigoFoneticoCidade { get; set; }
		public String segundoCodigoFoneticoCidade { get; set; }
		public String terceiroCodigoFoneticoCidade { get; set; }
		public String unidadeFederativaCodigo  { get; set; }
		public String nomeCidade { get; set; }
	}


	/**
	 * @author João Losada
	 * Retorno da busca feita por CEP
	 **/
	public class ObterCidadeCEPTO {
		public enderecosGuiaPostalEBOCEPTO obterEnderecoPorCEPResponse { get; set; }
	}

	public class enderecosGuiaPostalEBOCEPTO {
		public enderecoGuiaPostalEBOCEPTO enderecosGuiaPostalEBO { get; set; }
	}

	public class enderecoGuiaPostalEBOCEPTO {
		public DetenderecoGuiaPostalEBOTO enderecoGuiaPostalEBO { get; set; }
	}

	public class DetenderecoGuiaPostalEBOTO {
		public String codigoLogradouro { get; set; }
		public String codigoFoneticoLogradouro { get; set; }
		public String primeiroCodigoFoneticoLogradouro { get; set; }
		public String segundoCodigoFoneticoLogradouro { get; set; }
		public String terceiroCodigoFoneticoLogradouro { get; set; }
		public String codigoBairro { get; set; }
		public String codigoCidade { get; set; }
		public String cepCidade  { get; set; }
		public String cepComplementoCidade { get; set; }
		public CidadeObservacao cidadeObservacao { get; set; }
		public String primeiroCodigoFoneticoCidade { get; set; }
        public String segundoCodigoFoneticoCidade { get; set; }
        public String terceiroCodigoFoneticoCidade { get; set; }
        public String cepEspecial { get; set; }
		public enderecoCompleto enderecoCompleto { get; set; }
	}

	public class CidadeObservacao {
		public String nil { get; set; }
	}

	public class enderecoCompleto {
		public String tipoLogradouro { get; set; }
		public String logradouro { get; set; }
		public String complemento { get; set; }
 		public String bairro { get; set; }
		public String cidade { get; set; }
		public String uf { get; set; }
		public String cep { get; set; }
		public String complementoCep { get; set; }
	}

	// PLV-2312-28 INICIO
	public class ControleBatchTO{
		public String servico { get;set; }
		public String idjob { get;set; }
	}
	// PLV-2312-28 FIM

	/**
	 * @author João Losada
	 * Retorno da busca feita por Logradouro
	 **/
	public class ObterCidadeLogradouroTO {
		public enderecosGuiaPostalLocalTO obterLogradourosPorLogradouroResponse { get; set; }
	}

	public class enderecosGuiaPostalLocalTO {
		public enderecoGuiaPostalLocalTO enderecosGuiaPostalLocal { get; set; }
	}

	public class enderecoGuiaPostalLocalTO {
		public List<LstEnderecosDetalheTO> enderecoGuiaPostalLocal { get; set; }
	}

	public class LstEnderecosDetalheTO {
		public String codigoLogradouro { get; set; }
		public String nomeLogradouro { get; set; }
		public String complementoLogradouro { get; set; }
		public String tipoLogradouro { get; set; }
		public String numeroCepLogradouro { get; set; }
		public String complementoCepLogradouro { get; set; }
		public String codigoFonetico { get; set; }
		public String primeiroCodigoFonetico  { get; set; }
		public String segundoCodigoFonetico { get; set; }
		public String terceiroCodigoFonetico {get; set;}
		public Bairro bairro { get; set; }
		public Cidade cidade { get; set; }
		public unidadeFederacao unidadeFederacao {get; set;}
		public geolocalizacao geolocalizacao {get; set;}
	}

	public class Bairro {
		public String codigoBairro { get; set; }
		public String nomeBairro { get; set; }
	}

	public class Cidade {
        public String codigoCidadeLocalidade { get; set; }
        public String complementoCepCidade { get; set; }
        public String nomeCidadeNoGuiaPostal { get; set; }
        public String numeroCepLogradouro { get; set; }
        public String observacaoCidade { get; set; }
        public String primeiroCodigoFonetico { get; set; }
        public String segundoCodigoFonetico { get; set; }
        public String terceiroCodigoFonetico { get; set; }
	}

	public class unidadeFederacao {
        public String codigoUnidadeFederacao { get; set; }
        public String nomeUnidadeFedearacao { get; set; }
        public String ultimaAtualizacaoLinha { get; set; }
	}

    public class geolocalizacao {
        public String latitude { get; set; }
        public String longitude { get; set; }
	}


	/**
	 * @author João Losada
	 * Retorno da busca feita por endereço - Estrutura final 
	 **/
	public class ListResultadoRetornoBuscaEndereco {
		public String codigoLogradouro { get; set; }
		public String tipoLogradouro { get; set; }
		public String nomelogradouro { get; set; }
		public String codigoCidade { get; set; }
		public String nomeCidade { get; set; }
		public String unidadeFederativaCodigo  { get; set; }
		public String cepCidade { get; set; }
		public String cepCidadeComplemento { get; set; }
		public String codigoBairro { get; set; }
 		public String nomeBairro { get; set; }
		public String complementologradouro { get; set; }
		public String cep { get; set; }
 		public String cepComplemento { get; set; }
 	}

	/**
	 * @author João Losada
	 * Modalidade
	 **/
	public class ModalidadeTO {
		public List<ListModalidadesTO> Modalidades { get; set; }
	}

	public class ListModalidadesTO {

		public String codigoEmpresa  { get; set; }
		public String codigoRamo { get; set; }
		public String codigoModalidade { get; set; }
		public String nomeModalidade { get; set; }
		public String dataAlteracao { get; set; }
		public String grupoRamosProducao { get; set; }
	}

	/**
	 * @author João Losada
	 * Retorno CIV
	 **/
	public class ContratoTO {
		public ContratoDetalheTO contrato { get; set; }
	}

	public class ContratoDetalheTO {
       public Integer codigoEmpresa { get; set; }
       public Integer codigoSucursal { get; set; }
       public Integer ramoSeguro { get; set; }
       public String  numeroApolice { get; set; }
       public Integer numeroEndosso { get; set; }

	}

	/**
	 * @author João Losada
	 **/
	public class IntegrationFail {
		public String empresa { get; set; }
		public String sucursal { get; set; }
		public String ramo { get; set; }
		public String apolice { get; set; }
		public String endosso { get; set; }
		public String origem { get; set; }
		public String proposta { get; set; }
		public String payloadentrada { get; set; }
		public String endpoint { get; set; }
		public String metodo { get; set; }
		public String payloaderro { get; set; }
		public String datafalha { get; set; }
		public Integer reprocessamento { get; set; }
	}

	//--------------------------------------------------
	// Parametros de atualização de Id dos arquivos ECM
	// no documentos
	//--------------------------------------------------

	public class PayloadDadosEcmTO {
		public List<DetalheDadosEcmTO> dados { get; set; }
	}

	public class DetalheDadosEcmTO
	{
		public String tipoarquivo { get; set; }
		public String codfatura { get; set; } 
		public String codcontrato { get; set; }
		public String idarquivo { get; set; }
	}
	
	//---------------------------------------------------------------
	// Parametros data do processamento da contabilização de Valores
	//---------------------------------------------------------------

	public class ParametroContabilizacaoTO {
		public Date dataProcessamento { get; set; }
	}


	//---------------------------------------------------------------
	// Parametros para consulta de contrato
	//---------------------------------------------------------------

	public virtual class ParametroConsultaContratoPorPropostaTO { //ANNVI-55 - INICIO/FIM
		public String empresa { get; set; }
		public String ramo { get; set; }
		public String origem  { get; set; }
		public String proposta  { get; set; }
		public Integer parcela  { get; set; }
	}

	public class ParametroConsultarPropostaTO extends ParametroConsultaContratoPorPropostaTO{}

	public class ParametroConsultaContratoPorApoliceTO {
		public String empresa { get; set; }
		public String sucursal { get; set; }
		public String ramo { get; set; }
		public String apolice { get; set; }
		public String endosso { get; set; }
		public Integer numeroparcela { get; set; }
	}


	//---------------------------------------------------------------
	// Parametros para envio de sinostros para alteração de status
	//---------------------------------------------------------------

	public class ParamAtualizacaoStatusSinistroTO {
		public String idseguradoparceiro { get; set; }
		public String cpf { get; set; }
		public String nome  { get; set; }
		public String numerosinistro  { get; set; }
		public String codigoprodutoparceiro { get; set; }
		public String status { get; set; }
		public Date   dataocorrencia { get; set; }
		public Date   dataaviso { get; set; }
/*		
		public Integer origemproposta  { get; set; }
		public String  numeroproposta  { get; set; }
		public String  numerocontratoproposta  { get; set; }
		public Date    dataindenizacao { get; set; }
		public Date    datastatus { get; set; }
		public String  motivo { get; set; }
		public Decimal valorindenizado  { get; set; }
		public Integer numeroordempagamento  { get; set; }
		public String  agencia { get; set; }
		public String  banco  { get; set; }
		public String  conta  { get; set; }
		public String  observacao { get; set; }
*/
	}


	public class RetornoAtualizacaoSinistroTO 
	{
		public String dataExecucao { get; set; }
		public String servico { get; set; }
		public Integer statusHttp { get; set; }
		public String mensagem { get; set; }
	}

	public class ParamGerarErroHerokuTO 
	{
	  public String data { get; set; }
	  public String objeto { get; set; }
	  public String idregistro { get; set; }
	  public String codigointegracao { get; set; }
	  public String codigoerro { get; set; }
	  public String descricaoerro { get; set; }
	  public String status { get; set; }
	}

	public class RetornoCriarParcelaTO
	{
	    public List<ParcelaContratoTO> data;
	    public MetaTO meta;
	}

    public class MetaTO 
    {
        public String dataExecucao { get; set; }
        public String servico { get; set; }
        public Integer statusHttp { get; set; }
        public String mensagem { get; set; }
    }

    public class ParcelaCancelamentoTO 
    {
        public String apolice { get; set; }
        public String ramo { get; set; }
        public String endosso { get; set; }
        public String sucursal { get; set; }
        public Integer numeroparcela { get; set; }
    }


	public class RetornoPortoCapTO 
	{
		public Integer cd_retorno  { get; set; }
		public Integer id_lote     { get; set; }
		public String nm_retorno   { get; set; }
		public Integer cd_versao { get; set; }
		public List<TituloCapitalizacaoTO.CessionarioTO> listCessionarioTO  { get; set; }
	}

    public class SeguroContratoTO 
    {
    	public Id idsalesforce { get; set; }
		public String empresa { get; set; }
		public String sucursal { get; set; }
		public String ramo { get; set; }
		public String apolice { get; set; }
		public String endosso { get; set; }
		public String situacaoapolice { get; set; }
		public String statuscontrato { get; set; }
        // PLV-2312-28 INICIO
		public String payload { get; set; }
        // PLV-2312-28 FIM
		public Date vigenciainicial { get; set; }
		public Date vigenciafinal { get; set; }
		public String produto { get; set; }
		public String canal { get; set; }
		public String suseplider { get; set; }
		public Integer quantidadeparcelas { get; set; }
		public String tipoendosso { get; set; }
		public String tiposeguro { get; set; }
		public Integer titulocapitalizacao { get; set; }
		public String numerocontratoparceiro { get; set; }
		// PLV-4488
		public String siglatipoendosso { get; set; }
		public String cpf { get; set; }
		public String nome { get; set; }
		public String numeropropostaporto { get; set; }
		public Date   dataemissao { get; set; }
		public String codigoparceiro { get; set; }
		//PLV-2225-28 INICIO
		public Integer quantidadevidas { get; set; }
		//PLV-2225-28 FIM
		//PLV-2605-29 INICIO
		public List<ParcelaContratoTO> parcelas {get; set;}
		//PLV-2605-29 FIM
		//PLV-2576 Adicionando o campo origemproposta
		public String origemproposta { get; set; }
		public Date datacancelamento { get; set; }
		//PLV-2576 Adicionando o campo origemproposta
		//PLV-4601-FIX3 INICIO
		public double valorrestituicao { get; set; }
		//PLV-4601-FIX3 FIM		
	}

    public class SeguroContratoCancelamentoTO 
    {
		public String apolice { get; set; }
		public String endosso { get; set; }
		public String sucursal { get; set; }
		public String ramo { get; set; }
		// PLV-2312-28 INICIO
		public String empresa { get; set; }
		// PLV-2312-28 FIM
	}

	//AVX - cria pagamento do beneficiario
    public class ParamPagamentoBeneficiarioTO {
        public String id { get; set; } 
        public String idobjeto { get; set; }
        public Date   dataprogramadapagamento { get; set; }
        public Double valorpagamento { get; set; }
        public String idconta { get; set; }
        public String cnpjcpf { get; set; }
        public String tipoconta { get; set; }
        public String status { get; set; }
        public Date datapagamento { get; set; }
        public String tipopagamento { get; set; }
        public String matricula { get; set; }
        public String codigoexcecao { get; set; }
        public String descricaoexcecao { get; set; }
        public Decimal valorbruto  { get; set; }
        public String tributacao { get; set; }
        public String tiporemuneracao { get; set; }
        public Date datacancelamento { get; set; }
        public String motivo { get; set; }
        public String descricao { get; set; }
        public String susepcorretor { get; set; }
        public Date dataatualizacao { get; set; }
    }
    
    //AVX - cria bloqueio bancário
    public class validarBloqueioBancarioTO {
        public String body { get; set; } 
    }


    //PLV-1197-27: Cancelamento Contrato
	//PLV-5300 - INICIO
	public class OrcamentoCalculoTO {
		public String empresa				{ get; set; }
		public String sucursal				{ get; set; }
		public String ramo					{ get; set; }
		public String apolice				{ get; set; }
		public String tipoSeguro			{ get; set; }
		public String tipoEndosso			{ get; set; }
		public Date dataCalculo				{ get; set; }
		public Date vigenciaInicial			{ get; set; }
		public String meioComercializacao	{ get; set; }
		public String segmento				{ get; set; } //PLV-4695-VI - INICIO/FIM
		public String endosso				{ get; set; } //PLV-4695-FIX6 - INICIO/FIM
		public String tarifa				{ get; set; }  
	}
	//PLV-5300 - FIM

	public class ParamOrcamentoCalculoTO {
		public OrcamentoCalculoTO orcamento { get; set; }
	}


	public class PropostaCalculoTO {
		public String numeroOrcamento { get; set; }
	}

	public class ParamPropostaCalculoTO {
		public PropostaCalculoTO proposta { get; set; }
	}

    //---- Inicio:PLV-1197-27: Cancelamento Contrato
	public class DetalheOrcamentoCancelamentoTO {
		public String numeroOrcamento { get; set; }
		//PLV-3872 - INICIO - Inclusao de parametro
		public String tipoSeguro { get; set; }
		public String status { get; set; }
		//PLV-3872 - FIM

		public String valorTotalPremio { get; set; } //PLV-4678 Inicio/Fim

	}

	public class OrcamentoCancelamentoTO {
		public DetalheOrcamentoCancelamentoTO orcamento { get; set; }
	}

	// PLV-2312 INICIO
	public class OfertasCancelamentoTO {
		public List<OrcamentoCancelamentoTO> ofertas { get; set; }
	}

	public class DataCancelamentoTO {
		public OfertasCancelamentoTO data { get; set; }
	}
	// PLV-2312 FIM
	//---- Fim:PLV1197-27

	//PLV2365: INICIO
	//---- retorno Serviço Grava Orçamento
	public class OrcamentoTO {
		public String ordemPortal { get; set; }
		public String numeroOrcamento { get; set; }
		public String numeroPortal { get; set; }
		//PLV 3079 INICIO
		public Boolean varConsultivo {get;set;}
		//PLV 3079 FIM
		public Integer ramoSeguro { get; set; } //PLV-4854 - INÍCIO/FIM
	}

    //PLV2365: INICIO
	public class PayRetornoOfertasTO {
		public List<OfertaTO> ofertas { get; set; }
        //PLV-2502 - Inicio
        public RetornoValidacaoProdutoTO retornoValidacaoProduto { get; set; } 
        //PLV-2502 - Fim
	}
    //PLV2365: FIM

    //PLV-2502 - Inicio
    
    public class RetornoValidacaoProdutoTO {
        
         public List<RecusaTO> recusas { get; set; }
        
    }
    
    public class RecusaTO
    {
        public Integer codigo { get; set; }
        public MensagenTO mensagens { get; set; }
        public String descricao { get; set; }
        public String area { get; set; }
        public String procedimento { get; set; }
        public Integer severidade { get; set; }
    }
    
    public class MensagenTO
    {
        public String interna { get; set; }
        public String cliente { get; set; }
        public String representante { get; set; }
    }
	//PLV-2502 - Fim
	
	public class OfertaTO {
		public OrcamentoTO orcamento { get; set; }
	    //--> PLV2427 INICIO
		public RegrasRetornoOfertaTO regras  { get; set; }
	    //--> PLV2427 FIM
		//PLV-2414 - Inicio
		public List<ParcelamentoTO> parcelamentos { get; set; }
		//PLV-2414 - Fim

		//PLV-2962 - inicio
		public RetornoAceitacaoTO retornoAceitacao { get; set; }
		//PLV-2962 - fim

		//PLV-5066 - INICIO
		public List<EmissaoTO.RetornoCalculoTO> retornosCalculo { get; set; }
		//PLV-5066 - FIM
	}
	//PLV2365: FIM
	   
    //--> PLV2427 INICIO
    public class RegrasRetornoOfertaTO {
        public List<String> coberturasLideres { get; set; }
        public List<CoberturaRetornoOfertaTO> coberturas { get; set; }
        public List<RemuneracaoRetornoOfertaTO> remuneracoes { get; set; }
        public List<CocorretagemOfertaTO> cocorretagem { get; set; } // ANNI-16 - INICIO/FIM

    //PLV-2421 - Inicio
		public List<QuestionarioTO> questionarios { get; set; }
		
		//PLV-4260 - INICIO - PEDRO AUGUSTO - SYS4B
		public String idquestionario {get;set;}
		//PLV-4260 - FIM - PEDRO AUGUSTO - SYS4B

    }

	//PLV-2962 - inicio
	public class RetornoAceitacaoTO
    {
        public List<AnaliseTO> analises { get; set; }
        public List<AvisoTO> avisos { get; set; }
        public List<RecusaTO> recusas { get; set; }
        public List<PendenciaTO> pendencias { get; set; }
		//PLV-4260 - INICIO - PEDRO AUGUSTO - SYS4B
		public List<DecisaoTO> decisoes { get; set; }
		//PLV-4260 - FIM - PEDRO AUGUSTO - SYS4B
		
    }

	public class AnaliseTO
    {
        public Integer codigo { get; set; }
        public String area { get; set; }
        public String procedimento { get; set; }
        // INICIO | PLV=2402-30
        public String descricao { get; set; }
        // FIM | PLV=2402-30
        public Integer severidade { get; set; }
        public MensagenTO mensagens { get; set; }
	}
    public class AvisoTO
    {
        public Integer codigo { get; set; }
        public String area { get; set; }
        public MensagenTO mensagens { get; set; }
        public String procedimento { get; set; }
         // INICIO | PLV=2402-30
        public String descricao { get; set; }
        // FIM | PLV=2402-30
        public Integer severidade { get; set; }
    }
	public class PendenciaTO
    {
        public String identificacao { get; set; }
        public Boolean atendida { get; set; }
        public MensagenTO mensagens { get; set; }
        public String area { get; set; }
        public Integer codigo { get; set; }
        public String procedimento { get; set; }
        public String descricao { get; set; }
        public Integer severidade { get; set; }
    }
	//PLV-2962 - fim

	//PLV-4260 - INICIO - PEDRO AUGUSTO - SYS4B
	public class DecisaoTO{
        public Integer codigo { get; set; }
        public String descricao { get; set; }
        public String tipo { get; set; }
        public String acao { get; set; }//PARA O QUESTIONARIO AQUI VAI ESTAR O CODIGO DO QUESTIONARIO
	}
	//PLV-4260 - FIM - PEDRO AUGUSTO - SYS4B

    public class QuestionarioTO {
    	public String idPergunta { get; set; }
    	public String pergunta { get; set; }
    	public String tipoResposta { get; set; }
    	public String opcoesRespostas { get; set; }
    	public String justificarPergunta { get; set; } //ANNVI-17 INICIO/FIM 
    	//PLV-4771 - INÍCIO
		//public String proximaPergunta { get; set; }
		public Decimal ordenacao { get;set; }
		//PLV-4771 - FIM
		public Boolean obrigatorio { get; set; }  // PLV-4797 INICIO/FIM  SYS4B ODEMIR 
    }
	//PLV-2421 - Fim
    public class RemuneracaoRetornoOfertaTO {
        public String tipoRemuneracao { get; set; }
        public Boolean obrigatorio { get; set; }
        public Double limiteMinimo { get; set; }
		public Double limiteMaximo { get; set; }
		public List<AntecipacaoComissaoTO> antecipacaoComissoes { get; set; } //PLV-4344 - Inicio/Fim
	}

	// ANNI-16 - INICIO
	public class CocorretagemOfertaTO{
		public String susepTransmissao { get; set; }
		public String coCorretagem { get; set; }
		public Boolean transmissaoLider { get; set; }
		public Boolean corretagemLider  { get; set; }
		public Decimal percentualTransmissao { get; set; }
		public Decimal percentualCoCorretagem { get; set; } 
	}
	// ANNI-16 - FIM
	
	//PLV-4344 - Inicio
	public class AntecipacaoComissaoTO{
		public String tipoEvento { get; set; }
        public Double limiteMinimo { get; set; }
        public Double limiteMaximo { get; set; }
	}
	//PLV-4344 - Fim

    public class CoberturaRetornoOfertaTO {
        public String sigla { get; set; }
		//PLV-3357 - INICIO - Add prioridade para apresentação no portal
		public Decimal prioridade { get; set; }
		//PLV-3357 - FIM
		// PLV-4116 - INICIO
		public String caracteristica { get; set; }
		// PLV-4116 - FIM
		//PLV-4325 - INICIO - Inclusao de campos
		public String tipoGarantia {get;set;}
		//PLV-4325 - FIM
		//PLV-2422 Inteligencia de oferta - Inicio - Incluido o campo nome
		public String nome { get; set; }
        public String tipo { get; set; }
		public String formaExibicaoCapital  { get; set; } //II-139 INICIO-FIM
        public List<String> includentes { get; set; } //PLV-4869 - FIX 1  - INÍCIO/FIM
        public List<String> excludentes { get; set; } //PLV-4869 - FIX 1  - INÍCIO/FIM
        public Boolean obrigatorio { get; set; }
        public Double limiteMinimo { get; set; }
        public Double limiteMaximo { get; set; }
        public List<String> inclui { get; set; }
        public String descricao {get;set; }
		public String agrupamento{get;set;} //VIAG-265 - INICIO/FIM
		//PLV-2422 - Fim
		//PLV-4319-VI - INICIO - PEDRO AUGUSTO - SYS4B
		public List<FranquiaTO> franquias { get; set; }
		public Boolean filtrada { get; set; }
		public List<CarenciaTO> carencias { get; set; }
		public CaracteristicaEspecialTO caracteristicaespecial { get; set; }
		//PLV-4319-VI - FIM - PEDRO AUGUSTO - SYS4B
		//PLV-4416-VI - INICIO - ODEMIR - SYS4B 
		public String ramo {get;set;}
		//PLV-4416-VI - FIM - ODEMIR - SYS4B 
	}
	//PLV-4319-VI - INICIO - PEDRO AUGUSTO - SYS4B
	public class FranquiaTO {
		public Boolean padrao { get; set; }
        public String descricao { get; set; }
        public String valor { get; set; }
		public Boolean selecionado { get; set; } //PLV-4887 - INICIO/FIM
		public String name { get; set; } //II-73
	}
	public class CarenciaTO {
		public Boolean padrao { get; set; }
        public String descricao { get; set; }
		public String valor { get; set; }
		
	}
	public class CaracteristicaEspecialTO {
		public String tipo { get; set; }
        public Double limiteMinimo { get; set; }
        public Double limiteMaximo { get; set; }
	}
	//PLV-4319-VI - FIM - PEDRO AUGUSTO - SYS4B

	// public interface AutorizacaoCartaoTO {
	// 	String validar();
	// 	void dtoCobranca(CriticaProposta__c pCritica);
	// }

	//PLV-4449-VI - INICIO - PEDRO AUGUSTO - SYS4B
	// TKCL-473 - INÍCIO
	public class CobrancaCartaoOfflineTO {
		public String numeroReferencia { get; set; }
		public Integer quantidadeParcelas { get; set; }
		public Integer codigoFormaPagamento { get; set; } //ANNVI-48 - INICIO/FIM
		public Double valor { get; set; }
		public String idFiscal { get; set; }
		public String ticket { get; set; }
		public String tipoIdFiscal { get; set; }
		public String validadeCriptografada { get; set; }
		public String nomeCartao { get; set; } //PLV-4992 FIX 1 - INÍCIO/FIM
		public String ramo { get; set; } //PLV-4992 FIX 1 - INÍCIO/FIM
		public String modalidade { get; set; } //PLV-4992 FIX 1 - INÍCIO/FIM
		public String codigoPrecificaProduto { get; set; } //TKCL-358 INICIO/FIM
		public String codigoEmpresa {get; set; } //TKCL-473 INICIO/FIM
		public Double valorPrimeiraParcela {get; set; } //TKCL-473 INICIO/FIM

		public String validar(){
			List<String> erros = new List<String>();
			
			if(this.quantidadeParcelas < 1) erros.add('Quantidade de Parcelas inferiror a 1');
			if(this.valor < 1) erros.add('Valor inferiror a 1');			
			if(String.isBlank(this.idFiscal)) erros.add('CPF/CNPJ do Contratante não informado');			
			if(String.isBlank(this.tipoIdFiscal)) erros.add('Tipo de Cliente não identificado');
			if(String.isBlank(this.ticket) && String.isBlank(this.validadeCriptografada)) erros.add('Verificar dados do Cartão de Crédito');

			return String.join(erros,', ');
		}

		public void dtoCobranca(CriticaProposta__c pCritica){
			Recordtype pessoaFisica = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica');
			Recordtype pessoaJuridica = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaJuridica');
			ContratanteProposta__c contratante = pCritica.Proposta__r.ContratantesProposta__r[0];
			//PLV-4992 FIX 1 - INÍCIO
			String ramo = pCritica.Proposta__r.RamoSeguro__r.Codigo__c;
			String modalidade = pCritica.Proposta__r.Modalidade__r.Codigo__c;
			//PLV-4992 FIX 1 - FIM
			String codigoPrecificaProduto = pCritica.Proposta__r.Produto__r.CodigoPrecificaProduto__c; //TKCL-358 INICIO/FIM
			//CobrancaCartaoOfflineTO cobrancaToReturn = new CobrancaCartaoOfflineTO();
            
            System.debug( 'pCritica' + pCritica);
			System.debug( 'produtoR' + pCritica.Proposta__r.Produto__r);
			System.debug( 'empresaR' + pCritica.Proposta__r.Produto__r.Empresa__r);
			System.debug( 'codigoEmpresa' + pCritica.Proposta__r.Produto__r.Empresa__r.CodigoEmpresa__c);
			System.debug( 'Contratante' + JSON.serialize(contratante));
			System.debug( 'valorPrimeira' + contratante.Valor_PrimeiraParcela__c);
			this.numeroReferencia 	= pCritica.Proposta__r.NumeroPropostaUnico__c.replace('-','')+'|'+pCritica.Proposta__c+'|'+pCritica.Id+'|'+Util.gerarStringRandomicaAlpha(10);//PLV - 4901 - FIX - HENRIQUE R. - INICIO/FM
			this.quantidadeParcelas = Integer.valueOf(contratante.QuantidadeParcelas__c);
			this.valor				= contratante.Recorrencia__c == true ? contratante.Valor_DemaisParcelas__c : contratante.PremioTotal__c!=null ? (Double) contratante.PremioTotal__c : 0; // TKCL 473 - INICIO/FIM
			this.ticket 			= contratante.CartaoCredito__r.Ticket__c;
			this.validadeCriptografada = contratante.CartaoCredito__r.VencimentoCriptografado__c;
			this.codigoPrecificaProduto = codigoPrecificaProduto != null ? codigoPrecificaProduto : ''; //TKCL-358 INICIO/FIM
			//PLV-4992 FIX 1 - INÍCIO
			this.nomeCartao = contratante.CartaoCredito__r.NomeTitular__c; 
			this.ramo = ramo != null ? ramo : '';
			this.modalidade =  modalidade != null ? modalidade : '';
			//PLV-4992 FIX 1 - FIM
			this.idFiscal  			= contratante.Conta__r.RecordTypeId==pessoaFisica.id && String.isNotBlank(contratante.Conta__r.CPF__c) ? contratante.Conta__r.CPF__c.replaceAll('\\D',''): contratante.Conta__r.RecordTypeId== pessoaJuridica.id && String.isNotBlank(contratante.Conta__r.Cnpj__c) ? contratante.Conta__r.Cnpj__c.replaceAll('\\D','') : '';
			this.tipoIdFiscal  		= contratante.Conta__r.RecordTypeId==pessoaFisica.id ? '1' : contratante.Conta__r.RecordTypeId== pessoaJuridica.id ? '2' : '';
			this.valorPrimeiraParcela = contratante.Valor_PrimeiraParcela__c; // TKCL 473 - INICIO/FIM
			this.codigoEmpresa = pCritica.Proposta__r.Produto__r.Empresa__r.CodigoEmpresa__c; // TKCL 473 - INICIO/FIM
			this.codigoFormaPagamento = Integer.valueOf(contratante.FormaPagamento__r.Codigo__c); //ANNVI-48 - INICIO/FIM
			System.debug('nova cobrança populada>> ' + JSON.serialize(this));
		//	return cobrancaToReturn;
		}
	}
	// TKCL-473 - FIM

	//TKCL-473 INÍCIO
	// public class CartaoCreditoPortoPagTO {
	// 	public String id { get; set; }
	// 	public Integer parcelas { get; set; }
	// 	public String tipoTransacao{ get; set; } 
	// }

	// public class CobrancaPortoPagTO {
	// 	public CartaoCreditoPortoPagTO cartaoCredito { get; set; }
	// 	public String meioPagamento { get; set; }
	// 	public Double valorPrimeiraParcela { get; set; }
	// 	public Double valor { get; set; }
	// }

	// public class MetadadoPortoPagTo {
	// 	public String tipo_documento_comercial { get; set; }
	// 	public String endosso { get; set; }
	// 	public String codigo_empresa { get; set; }
	// 	public String composicao_valor_parcela { get; set; }
	// 	public String codigo_ramo { get; set; }
	// 	public String parcela { get; set; }
	// 	public String contrato_comercial { get; set; }
	// 	public String evento_emissao { get; set; }
	// 	public String flag_sinalizador_processo { get; set; }
	// 	public String flag_produto_seguro { get; set; }
	// 	public String codigo_agregador { get; set; }
	// 	public String codigo_modalidade { get; set; }
	// 	public String auth_type { get; set; }
	// }

	// public class AutorizacaoPortoPagTO implements AutorizacaoCartaoTO {
	// 	public List<CobrancaPortoPagTO> cobrancas { get; set; }
	// 	public String codProduto { get; set; }
	// 	public String idExterno { get; set; }
	// 	public MetadadoPortoPagTo metadados { get; set; }

	// 	public String validar(){
	// 		return '';
	// 	}

	// 	public void dtoCobranca(CriticaProposta__c pCritica){

	// 		String codigoProduto = pCritica.Proposta__r.Produto__r.CodigoProdutoTecnico__c;
	// 		System.debug( 'pCritica' + pCritica);
	// 		this.codProduto = codigoProduto;
	// 		this.idExterno = contratante.CartaoCredito__r.Ticket__c;

	// 	}
	// }
	//TKCL-473 FIM


	public class NovoCartaoTO {
		public String numeroReferencia { get; set; }
		public String cartao { get; set; }
		public String validadeCartao { get; set; }
		public String cvv { get; set; }
		public String bandeira { get; set; } //PLV-4926

		public NovoCartaoTO dtoCartao(CartaoCredito__c pCartao){
			NovoCartaoTO cartaoToReturn = new NovoCartaoTO();
			cartaoToReturn.numeroReferencia = pCartao.Id+'|'+Util.gerarStringRandomicaAlpha(10);
			cartaoToReturn.cartao = pCartao.NumeroCartao__c.replaceAll('\\D','');
			cartaoToReturn.validadeCartao = pCartao.Vencimento__c.replaceAll('\\D','');
			cartaoToReturn.cvv = pCartao.CodigoSeguranca__c; // PLV-5064 INICIO/FIM 
			cartaoToReturn.bandeira = pCartao.Bandeira__c==null? 'não identificado' : pCartao.Bandeira__c.toLowerCase(); //PLV-4926
			return cartaoToReturn;
		}
	}
	//PLV-4449-VI - INICIO - PEDRO AUGUSTO - SYS4B


    //--> PLV2427 FIM


}