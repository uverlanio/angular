/**************************************************************************************************************************************************************************
 * 
 *  Classe base de montagem de orçamento
 *
 **************************************************************************************************************************************************************************/
public without sharing abstract class OrcamentoBuilder {
	public Orcamento orcamento;
	private OrcamentoBuilder instancia {get;set;}

	// Constantes
	protected final String SEPARADOR_NOME_PROPOSTA = '-';
	private static final String SEPARADOR_NOME_ORCAMENTO = '-';

	//Atribui a instancia a ser utilizada na montagem
	public void setInstancia(OrcamentoBuilder instancia){
		this.instancia = instancia;
	}

	//Método genérico reponsável pela orquestração da montagem da proposta
	public Orcamento montarOrcamento(EmissaoTO.PayloadTO payloadTO, OrcamentoBuilder orcamentoGenerico, Boolean inserir){

		this.orcamento = new Orcamento();

		if(orcamentoGenerico != null){
			this.instancia.orcamento = orcamentoGenerico.montarOrcamento(payloadTO, null, false);
		}

		// geracao do orcamento
		this.instancia.gerarOrcamento(payloadTO);

		if(payloadTO.proposta != null)
		{
			// Popular a precificacao a partir de payload de proposta
			if(payloadTO.proposta.precificacao != null){
				this.instancia.popularPrecificacao(payloadTO.proposta.precificacao);
			}

			// Popular a precificacao de cancelamento a partir de payload de proposta
			if(payloadTO.proposta.contratoOriginal != null && payloadTO.proposta.contratoOriginal.precificacao != null){
				this.instancia.popularPrecificacao(payloadTO.proposta.contratoOriginal.precificacao);
			}
		}

		system.debug('orcamento Buider>> '+ inserir);
		if(inserir){
			system.debug('orcamento Buider>> inserirRegistros');
			this.instancia.inserirRegistros(this.orcamento);
		}
		system.debug('instancia.orcamento ' + JSON.serialize(this.instancia.orcamento));
		return this.instancia.orcamento;
	}

	//Métodos que devem ser sobreescritos e implementados
	public virtual void gerarOrcamento(EmissaoTO.PayloadTO payloadTO){}
	public virtual List<Orcamento.ContratanteWrapper> gerarContratantes(EmissaoTO.PayloadTO payloadTO){ return  null; }
	public virtual List<Orcamento.GrupoWrapper> gerarGrupos(EmissaoTO.PayloadTO payloadTO){ return  null; }
	public virtual List<Orcamento.SeguradoWrapper> gerarSegurados(EmissaoTO.PayloadTO payloadTO){ return  null; }
	public virtual void popularPrecificacao(EmissaoTO.PrecificacaoTO precificacaoTO){}

	public abstract Orcamento inserirRegistros(Orcamento orcamento);

	protected String gerarOpportunityName(String MeioComercializacao, String numeroProposta){
		return MeioComercializacao + SEPARADOR_NOME_ORCAMENTO + numeroProposta.leftPad(8,'0');
	}

	protected String gerarQuoteName(String origem, String numeroProposta){
		return OpportunityBO.getInstance().gerarNameOrcamento(origem,numeroProposta);
	}

	/**
     * Realiza extração dos metadados para recuperar nomes de campos, monta query e retornar resultado baseados nos criterios
     *
     * @param objeto  - Nome do objeto a ser processado
     * @param criteriosQuery  - Criterio a ser usado na query
     */
	protected  List<SObject> buscarDadosObjeto(String objeto, String criteriosQuery){
		List<SObject> registrosObjeto = Database.query(Util.gerarQuery(objeto, SObjectSchema.listarCamposEditaveis(objeto), new List<String>{criteriosQuery}));

		return registrosObjeto;
	}

	// Gera devolutiva do parceiro
	public RetornoOrcamentoRestTO.DevolutivasTO gerarDevolutiva(CriticaParceiro__c criticaParceiro, String origem, String criticaCustomizada, Integer codigo)
	{
		try{
			RetornoOrcamentoRestTO.DevolutivasTO devolutivaTO = new RetornoOrcamentoRestTO.DevolutivasTO();

			// Verifica se a critica foi mapeada no parceiro
			if(criticaParceiro == null){

				// Verifica se existe um codigo customizado
				if(codigo == null){
					codigo = -3;
				}

				// Verifica se existe uma critica customizada
				if(String.isBlank(criticaCustomizada)){
					criticaCustomizada = 'Erro não mapeado, Critica ' + codigo + ' não encontrada no cadastro do parceiro';
				}

				devolutivaTO.codigo		= -3;
				devolutivaTO.origem		= origem;
				devolutivaTO.tipoRegistro	= null;
				devolutivaTO.numeroCampo	= null;
				devolutivaTO.descricao		= criticaCustomizada;
			}else{
				devolutivaTO.codigo		= Integer.valueOf(criticaParceiro.Name);
				devolutivaTO.origem		= origem;
				devolutivaTO.numeroCampo	=  String.isNotBlank(criticaParceiro.IdentificacaoCampo__c) ? Integer.valueOf(criticaParceiro.IdentificacaoCampo__c) : null;
				devolutivaTO.descricao		= criticaParceiro.Rotulo__c.touppercase() + ' - ' + criticaParceiro.Mensagem__c;
				devolutivaTO.tipoRegistro	= criticaParceiro.TipoRegistro__c != null ? Integer.valueOf(criticaParceiro.TipoRegistro__c) : null;
			}

			return devolutivaTO;
		}catch (Exception e){

			throw new OrcamentoBuilderException('Erro ao mapear a crítica - linha: ' +  e.getLineNumber() + ' - Mensagem: ' + e.getMessage() + ' - Causa: ' + e.getCause());
		}
	}

	// exception
	public class OrcamentoBuilderException extends Exception {}
}