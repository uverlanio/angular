/**************************************************************************************************************************************************************************
 * 
 *  Classe base de montagem de proposta
 *
 **************************************************************************************************************************************************************************/

public without sharing abstract class PropostaBuilder
{
	public Proposta proposta;
	private PropostaBuilder instancia {get;set;}

	// Constantes
	protected final String SEPARADOR_NOME_PROPOSTA = '-';
	protected final String SEPARADOR_NOME_ORCAMENTO = '-';

	//Atribui a instancia a ser utilizada na montagem
	public void setInstancia(PropostaBuilder instancia){ this.instancia = instancia; }

	//Método genérico reponsável pela orquestração da montagem da proposta
	public Proposta montarProposta(EmissaoTO.PayloadTO payload, PropostaBuilder propostaGenerica, Boolean inserir)
	{
        system.debug('MONTAR PROPOSTA!!' + JSON.serialize(payload));
		this.proposta = new Proposta();
		system.debug('PROPOSTA GENERICA ' + propostaGenerica);
        if(propostaGenerica != null)
            this.instancia.proposta = propostaGenerica.montarProposta(payload, null, false);
		
        system.debug('ANTES DE ACESSAR O VALIDAR');

		this.instancia.validarPayload(payload);
        system.debug('ANTES DE ACESSAR O GERAR'+ JSON.serialize(payload));
		this.instancia.gerarProposta(payload);
        system.debug('SAIU DO GERAR'+ JSON.serialize(payload));
        

		// Precificacao de uma emissao de uma nova proposta
		if(payload.calculo != null && payload.calculo.precificacao != null){
            system.debug('ANTES DE ACESSAR O GERARooo99999'+ JSON.serialize(payload));
			this.instancia.popularPrecificacao(payload.calculo.precificacao);
		}

		// Precificacao de outro tipo de emissao, como cancelamento, endosso e outros
		if(payload.calculo != null && payload.calculo.precificacao != null){
            system.debug('ANTES DE ACESSAR O GERARooo000000'+ JSON.serialize(payload));
			this.instancia.popularPrecificacao(payload.calculo.precificacao);
		}

		system.debug('propostaBuilder - this.proposta: ' + JSON.Serialize(this.proposta)); //PLV-3285
		system.debug('INSERIR: ' + inserir);
        system.debug('INSTANCIA: ' + instancia);
        if(inserir){
            system.debug('ANTES DE ACESSAR O GERARooo7878'+ JSON.serialize(payload));
			this.instancia.inserirRegistros(this.proposta);
			system.debug('propostaBuilder - AccountId da Proposta: ' + this.proposta.propostaWrapper.sfProposta.AccountId); // PLV-3285
        }
		system.debug('INSTANCIA: ' + instancia);
		return this.instancia.proposta;
	}

	//Métodos que devem ser sobreescritos e implementados
	// numero eh o numero identificador do contratante, grupo e segurado no payload
	public abstract void validarPayload(EmissaoTO.PayloadTO payloadTO);
	public abstract void gerarProposta(EmissaoTO.PayloadTO payloadTO);
	public abstract List<Proposta.ContratanteWrapper> gerarContratantes(EmissaoTO.PayloadTO payloadTO);
	public abstract List<Proposta.GrupoWrapper> gerarGrupos(List<EmissaoTO.GrupoTO> gruposTO, String numeroContratante);
	public abstract List<Proposta.SeguradoWrapper> gerarSegurados(List<EmissaoTO.SeguradoTO> seguradosTO, String numeroContratante, String numeroGrupo);
	// INICIO | PLV-2355-Hackathon
	public abstract List<Proposta.BeneficiariosWrapper> gerarBeneficiarios(List<EmissaoTO.BeneficiarioTO> beneficiariosTO, Proposta.SeguradoWrapper seguradoWrapper);
	public abstract void gerarContas(EmissaoTO.PayloadTO payloadTO, List<Proposta.PessoaWrapper> listPessoasWrapper);
	// FIN | PLV-2355-Hackathon
	public abstract void popularPrecificacao(EmissaoTO.PrecificacaoTO precificacaoTO);
	// INICIO | PLV-2402-30
	public abstract void gerarCriticas(EmissaoTO.PayloadTO payloadTO, List<Proposta.CriticaPropostaWrapper> listCriticasWrapper);
	// FIN | PLV-2302-30
	public abstract Proposta inserirRegistros(Proposta proposta);
	
	// Gera o campo Name da Proposta
	protected String gerarQuoteName(String origem, String numeroProposta){
		return QuoteBO.getInstance().gerarNameProposta(origem, numeroProposta);
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
	public RetornoPropostaRestTO.DevolutivasTO gerarDevolutiva(CriticaParceiro__c criticaParceiro, String origem, String criticaCustomizada, Integer codigo)
	{
		try{
			RetornoPropostaRestTO.DevolutivasTO devolutivaTO = new RetornoPropostaRestTO.DevolutivasTO();

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

			throw new PropostaBuilderException('Erro ao mapear a crítica - linha: ' +  e.getLineNumber() + ' - Mensagem: ' + e.getMessage() + ' - Causa: ' + e.getCause());
		}
	}

	// TODO: Para o Eric, a devolutiva eh do sistema, nao ha necessidade de ter uma TO de retorno para orcamento
	// TODO: e outro para proposta, unificar para uma unica TO e remover esse parse de um TO para outro
	// Parse de devolutivas de orcamento para proposta
	protected List<RetornoPropostaRestTO.DevolutivasTO> parseDevolutivasOrcamentoParaProposta(Orcamento orcamento){

		// Instancias
		List<RetornoPropostaRestTO.DevolutivasTO> listDevolutivaTO = new List<RetornoPropostaRestTO.DevolutivasTO>();

		// Itera as devolutivas de orcamento e converte para devolutivas de proposta
		for(RetornoOrcamentoRestTO.DevolutivasTO devolutivaOrcamentoTO : orcamento.orcamentoWrapper.retornoWrapper.retorno.devolutivas){
			RetornoPropostaRestTO.DevolutivasTO devolutivaPropostaTO = new RetornoPropostaRestTO.DevolutivasTO();
			devolutivaPropostaTO.codigo = devolutivaOrcamentoTO.codigo;
			devolutivaPropostaTO.origem = devolutivaOrcamentoTO.origem;
			devolutivaPropostaTO.tipoRegistro = devolutivaOrcamentoTO.tipoRegistro;
			devolutivaPropostaTO.numeroCampo = devolutivaOrcamentoTO.numeroCampo;
			devolutivaPropostaTO.descricao = devolutivaOrcamentoTO.descricao;
			listDevolutivaTO.add(devolutivaPropostaTO);
		}

		return listDevolutivaTO;

	}


	// exception
	public class PropostaBuilderException extends Exception {}
}