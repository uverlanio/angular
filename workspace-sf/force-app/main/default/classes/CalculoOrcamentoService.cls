/**
 * Serviços do Objeto Orcamento
 * @author João Losada @02/06/2018
 *
 **/
public class CalculoOrcamentoService extends ServiceBase 
{

  private static final CalculoOrcamentoService instance = new CalculoOrcamentoService();

  private String nomeEndpoint = 'EfetuarCalculo';
  private String mensagemErro = 'Erro ao efetuar Cálculo.';

  private CalculoOrcamentoService() { }

  public static CalculoOrcamentoService getInstance() {
    return instance;
  }
  

  /**
   * Retorna uma lista do serviço externo
   */
  public OrcamentoTO efetuarCalculo(OrcamentoTO parEntrada) {
    OrcamentoTO tempList = new OrcamentoTO();

    String body;

    body = JSON.serialize(parEntrada);

    try {
      HttpResponse resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'PUT', new Map<String, String>(), body, 60000, nomeEndpoint);

      if (resposta.getStatusCode() < 400) {
        tempList = (OrcamentoTO)JSON.deserialize(resposta.getBody(), OrcamentoTO.class);
      }
      else {
        throw new CalculoOrcamentoServiceException('ERROR HTTP ' + resposta.getStatusCode());
      }
    }
    catch (Exception e) {
      System.debug(e.getMessage());
      throw new CalculoOrcamentoServiceException(mensagemErro + e.getMessage());
    }

    return tempList;
  }

  /**
   *
   *
   * @param listGarantiasOrcamentos List<GarantiaOrcamento__c>
   * @param mapGruposPorSegurado Map<Id, List<GrupoOrcamento__c>>
   * @param mapGarantiasDoGrupoPorGrupo Map<Id, List<GarantiaGrupoOrcamento__c>>
   * @param mapGarantiasDoGrupoPorSegurado Map<Id, List<GarantiaGrupoOrcamento__c>>
   * @param mapSeguradoDoOrcamentoPorSegurado Map<Id, ContratanteOrcamento__c>
   *
   * @return OrcamentoTO - Objeto de integracao
   */
  public OrcamentoTO constroiPrecificacaoOrcamentoTO(
          List<GarantiaOrcamento__c> listGarantiasOrcamentos,
          Map<Id, List<GrupoOrcamento__c>> mapGruposPorContratante,
          Map<Id, List<GarantiaGrupoOrcamento__c>> mapGarantiasDoGrupoPorGrupo,
          Map<Id, List<GarantiaContratanteOrcamento__c>> mapGarantiasContratantePorContratante,
          Map<Id, ContratanteOrcamento__c> mapContratanteOrcamentoPorContratante){

    OrcamentoTO orcamentoTO = new OrcamentoTO();
    orcamentoTO.oferta = new OrcamentoTO.OfertaTO();
    orcamentoTO.oferta.calculo = new OrcamentoTO.CalculoTO();
    orcamentoTO.oferta.calculo.precificacao = new OrcamentoTO.PrecificacaoTO();

    // 1a hierarquia
    if(!listGarantiasOrcamentos.isEmpty())
      orcamentoTO.oferta.calculo.precificacao = converteParaPrecificacaoTO(listGarantiasOrcamentos);

    //2a hierarquia
    orcamentoTO.oferta.calculo.precificacao.contratantes =
            gerarListaContratanteTOs(
                    mapGarantiasContratantePorContratante,
                    mapGruposPorContratante,
                    mapGarantiasDoGrupoPorGrupo,
                    mapContratanteOrcamentoPorContratante
            );
            

    System.debug('OrcamentoTO para o componente de resumo do orcamento ------------ ' + orcamentoTO);

    return orcamentoTO;
    
  }

  public OrcamentoTO.PrecificacaoTO converteParaPrecificacaoTO(List<GarantiaOrcamento__c> listGarantiasOrcamentos){

    OrcamentoTO.PrecificacaoTO precificacaoTO = new OrcamentoTO.PrecificacaoTO();

    precificacaoTO.taxa = converteParaTaxaTODoOrcamento(listGarantiasOrcamentos[0].Orcamento__r);
    precificacaoTO.premio = converteParaPremioTODoOrcamento(listGarantiasOrcamentos[0].Orcamento__r);
    precificacaoTO.coberturas = geraListaDeCoberturaDeUmaListaDeGarantiaOrcamento(listGarantiasOrcamentos);

    return  precificacaoTO;
  }

  /**
*
*
* @param contratanteOrcamento -  Objeto do Salesforce que relaciona a Conta com o Orcamento
*
* @return PessoaTO - Objeto Interno do OrcamentoTO
*/
  public OrcamentoTO.PessoaTO converteParaPessoaTO (ContratanteOrcamento__c contratanteOrcamento){

    OrcamentoTO.PessoaTO pessoaTO = new OrcamentoTO.PessoaTO();

    pessoaTO.tipo = contratanteOrcamento.Tipo__c;
    pessoaTO.nome = contratanteOrcamento.Conta__r.Name;

    return pessoaTO;
  }


  /**
 *
 *
 * @param garantiaOrcamento Objeto GarantiaOrcamento__c do Salesforce que contem a taxa
 *
 * @return TaxaTO - Objeto interno do OrcamentoTO
 */
  public OrcamentoTO.TaxaTO converteParaTaxaTODeGarantiaOrcamento (GarantiaOrcamento__c garantiaOrcamento){
    OrcamentoTO.TaxaTO taxaTO = new OrcamentoTO.TaxaTO();
    taxaTO.pura = garantiaOrcamento.TaxaPura__c;
    taxaTO.mensal = garantiaOrcamento.TaxaMensal__c;
    taxaTO.anual = garantiaOrcamento.TaxaAnual__c;
    taxaTO.puroInterno = garantiaOrcamento.TaxaPuroInterno__c;
    taxaTO.puroResseguro = garantiaOrcamento.TaxaPuroResseguro__c;
    taxaTO.comercial = garantiaOrcamento.TaxaComercial__c;
    taxaTO.total = garantiaOrcamento.TaxaTotal__c;

    return taxaTO;
  }

  /**
   *
   *
   * @param garantiaOrcamento Objeto do Salesforce que contém as coberturas do Orcamento
   *
   * @return CoberturaTO - Objeto interno do OrcamentoTO
   */
  public OrcamentoTO.CoberturaTO converteParaCoberturaTODeGarantiaOrcamento (GarantiaOrcamento__c garantiaOrcamento){
    OrcamentoTO.CoberturaTO coberturaTO = new OrcamentoTO.CoberturaTO();

    coberturaTO.idSf = garantiaOrcamento.Id;
    coberturaTO.sigla = garantiaOrcamento.GarantiaProduto__r.Garantia__r.Sigla__c;
    coberturaTO.capital = garantiaOrcamento.Capital__c;
    coberturaTO.premio = converteParaPremioTODeGarantiaOrcamento(garantiaOrcamento);
    coberturaTO.taxa = converteParaTaxaTODeGarantiaOrcamento(garantiaOrcamento);
    coberturaTO.valorDescontoAgravo = garantiaOrcamento.Percentual__c;
    coberturaTO.escolhaDescontoAgravo = garantiaOrcamento.DescontoAgravo__c;
    coberturaTO.idGarantiaProdutoSf = garantiaOrcamento.GarantiaProduto__c;

    return coberturaTO;

  }

  /**
   *
   *
   * @param opportunity Objeto Opportunity do Salesforce que contem o premio
   *
   * @return PremioTO - Objeto interno do OrcamentoTO
   */
  public OrcamentoTO.PremioTO converteParaPremioTODoOrcamento (Opportunity opportunity){
    OrcamentoTO.PremioTO premioTO = new OrcamentoTO.PremioTO();

    premioTO.puro = opportunity.PremioPuro__c;
    premioTO.puroInterno = opportunity.PremioPuroInterno__c;
    premioTO.puroResseguro = opportunity.PremioPuroResseguro__c;
    premioTO.comercial = opportunity.PremioComercial__c;
    premioTO.total = opportunity.PremioTotal__c;

    return  premioTO;
  }

  /**
 *
 *
 * @param garantiaOrcamento Objeto GarantiaOrcamento do Salesforce que contem o premio
 *
 * @return PremioTO - Objeto interno do OrcamentoTO
 */
  public OrcamentoTO.PremioTO converteParaPremioTODeGarantiaOrcamento (GarantiaOrcamento__c garantiaOrcamento){
    OrcamentoTO.PremioTO premioTO = new OrcamentoTO.PremioTO();
    premioTO.puro = garantiaOrcamento.PremioPuro__c;    
    premioTO.comercial = garantiaOrcamento.PremioComercial__c;
    premioTO.total = garantiaOrcamento.PremioTotal__c;
    premioTO.puroDesconto = garantiaOrcamento.PremioPuroDesconto__c;
    premioTO.puroInterno = garantiaOrcamento.PremioPuroInterno__c;
    premioTO.puroResseguro = garantiaOrcamento.PremioPuroResseguro__c;
    premioTO.comercialDesconto = garantiaOrcamento.PremioComercialDesconto__c;
    return  premioTO;
  }

  /**
   *
   *
   * @param listGarantiasOrcamentos Lista de objeto GarantiaOrcamento do Salesforce que contém as coberturas do orcamento
   *
   * @return List<CoberturaTO> - Lista de CoberturaTO que eh objeto interno do OrcamentoTO
   */
  public List<OrcamentoTO.CoberturaTO> geraListaDeCoberturaDeUmaListaDeGarantiaOrcamento(
          List<GarantiaOrcamento__c> listGarantiasOrcamentos){
    List<OrcamentoTO.CoberturaTO> listCoberturaTOs = new List<OrcamentoTO.CoberturaTO>();

    for(GarantiaOrcamento__c garantiaOrcamento : listGarantiasOrcamentos){
      OrcamentoTO.CoberturaTO coberturaTO = converteParaCoberturaTODeGarantiaOrcamento(garantiaOrcamento);
      listCoberturaTOs.add(coberturaTO);
    }

    return listCoberturaTOs;
  }

  /**
   *
   *
   * @param listGarantiasGrupoOrcamento Lista de objeto GarantiasGrupoOrcamento do Salesforce que contém as coberturas do orcamento
   *
   * @return List<CoberturaTO> - Lista de objeto interno do OrcamentoTO
   */
  public List<OrcamentoTO.CoberturaTO> geraListaDeCoberturaDeUmaListaDeGarantiaGrupoOrcamento(List<GarantiaGrupoOrcamento__c> listGarantiasGrupoOrcamento){
    List<OrcamentoTO.CoberturaTO> listCoberturaTOs = new List<OrcamentoTO.CoberturaTO>();
    if(listGarantiasGrupoOrcamento == null || listGarantiasGrupoOrcamento.isEmpty()) return listCoberturaTOs;

    for(GarantiaGrupoOrcamento__c garantiaGrupoOrcamento : listGarantiasGrupoOrcamento){
      OrcamentoTO.CoberturaTO coberturaTO = converteParaCoberturaTODeGarantiaGrupoOrcamento(garantiaGrupoOrcamento);
      listCoberturaTOs.add(coberturaTO);
    }

    return listCoberturaTOs;
  }

  /**
   *
   *
   * @param listGarantiasContratanteOrcamento Lista de objeto Garantia Contratante Orcamento do Salesforce que contém as coberturas do contratante
   *
   * @return List<CoberturaTO> - Lista de objeto interno do OrcamentoTO
   */
  public List<OrcamentoTO.CoberturaTO> geraListaDeCoberturaDeUmaListaDeGarantiaContratanteOrcamento(List<GarantiaContratanteOrcamento__c> listGarantiasContratanteOrcamento){
    List<OrcamentoTO.CoberturaTO> listCoberturaTOs = new List<OrcamentoTO.CoberturaTO>();
    if(listGarantiasContratanteOrcamento == null || listGarantiasContratanteOrcamento.isEmpty()) return listCoberturaTOs;

    for(GarantiaContratanteOrcamento__c garantiaContratanteOrcamento : listGarantiasContratanteOrcamento){
      OrcamentoTO.CoberturaTO coberturaTO = converteParaCoberturaTODeGarantiaContratanteOrcamento(garantiaContratanteOrcamento);
      listCoberturaTOs.add(coberturaTO);
    }

    return listCoberturaTOs;
  }


  /**
   *
   *
   * @param garantiaDoGrupoOrcamento
   *
   * @return CoberturaTO - Objeto interno do OrcamentoTO
   */
  public OrcamentoTO.CoberturaTO converteParaCoberturaTODeGarantiaGrupoOrcamento (GarantiaGrupoOrcamento__c garantiaDoGrupoOrcamento){
    OrcamentoTO.CoberturaTO coberturaTO = new OrcamentoTO.CoberturaTO();

    coberturaTO.sigla = garantiaDoGrupoOrcamento.GarantiaProduto__r.Garantia__r.Sigla__c;
    coberturaTO.capital = garantiaDoGrupoOrcamento.Capital__c;
    coberturaTO.premio = converteParaPremioTODeGarantiaGrupoOrcamento(garantiaDoGrupoOrcamento);
    coberturaTO.taxa = converteParaTaxaTODeGarantiaGrupoOrcamento(garantiaDoGrupoOrcamento);
    coberturaTO.idSf = garantiaDoGrupoOrcamento.Id;
    coberturaTO.valorDescontoAgravo = garantiaDoGrupoOrcamento.Percentual__c;
    coberturaTO.escolhaDescontoAgravo = garantiaDoGrupoOrcamento.DescontoAgravo__c;
    coberturaTO.idGarantiaProdutoSf = garantiaDoGrupoOrcamento.GarantiaProduto__c;

    if(garantiaDoGrupoOrcamento.DescontoAgravo__c != null && garantiaDoGrupoOrcamento.DescontoAgravo__c == 'Agravo'){
      coberturaTO.agravo = GarantiaDoGrupoOrcamento.Percentual__c;
    }else if(garantiaDoGrupoOrcamento.DescontoAgravo__c != null && garantiaDoGrupoOrcamento.DescontoAgravo__c == 'Desconto'){
      coberturaTO.desconto = garantiaDoGrupoOrcamento.Percentual__c;
    }

    return coberturaTO;
  }

  /**
   *
   *
   * @param garantiaDoGrupoOrcamento
   *
   * @return CoberturaTO - Objeto interno do OrcamentoTO
   */
  public OrcamentoTO.CoberturaTO converteParaCoberturaTODeGarantiaSeguradoOrcamento (GarantiaContratanteOrcamento__c garantiaSeguradoOrcamento){
    OrcamentoTO.CoberturaTO coberturaTO = new OrcamentoTO.CoberturaTO();

    coberturaTO.sigla = garantiaSeguradoOrcamento.GarantiaProduto__r.Garantia__r.Sigla__c;
    coberturaTO.capital = garantiaSeguradoOrcamento.Capital__c;
    coberturaTO.premio = converteParaPremioTODeGarantiaSeguradoOrcamento(garantiaSeguradoOrcamento);
    coberturaTO.taxa = converteParaTaxaTODeGarantiaSeguradoOrcamento(garantiaSeguradoOrcamento);
    coberturaTO.idSf = garantiaSeguradoOrcamento.Id;
    coberturaTO.valorDescontoAgravo = garantiaSeguradoOrcamento.Percentual__c;
    coberturaTO.escolhaDescontoAgravo = garantiaSeguradoOrcamento.DescontoAgravo__c;
    coberturaTO.idGarantiaProdutoSf = garantiaSeguradoOrcamento.GarantiaProduto__c;

    if(garantiaSeguradoOrcamento.DescontoAgravo__c != null && garantiaSeguradoOrcamento.DescontoAgravo__c == 'Agravo'){
      coberturaTO.agravo = garantiaSeguradoOrcamento.Percentual__c;
    }else if(garantiaSeguradoOrcamento.DescontoAgravo__c != null && garantiaSeguradoOrcamento.DescontoAgravo__c == 'Desconto'){
      coberturaTO.desconto = garantiaSeguradoOrcamento.Percentual__c;
    }

    return coberturaTO;
  }

  /**
   *
   *
   * @param garantiaContratanteOrcamento
   *
   * @return CoberturaTO - Objeto interno do OrcamentoTO
   */
  public OrcamentoTO.CoberturaTO converteParaCoberturaTODeGarantiaContratanteOrcamento (GarantiaContratanteOrcamento__c garantiaContratanteOrcamento){
    OrcamentoTO.CoberturaTO coberturaTO = new OrcamentoTO.CoberturaTO();

    coberturaTO.sigla = garantiaContratanteOrcamento.GarantiaProduto__r.Garantia__r.Sigla__c;
    coberturaTO.capital = garantiaContratanteOrcamento.Capital__c;
    coberturaTO.premio = converteParaPremioTODeGarantiaContratanteOrcamento(garantiaContratanteOrcamento);
    coberturaTO.taxa = converteParaTaxaTODeGarantiaContratanteOrcamento(garantiaContratanteOrcamento);
    coberturaTO.idSf = garantiaContratanteOrcamento.Id;
    coberturaTO.valorDescontoAgravo = garantiaContratanteOrcamento.Percentual__c;
    coberturaTO.escolhaDescontoAgravo = garantiaContratanteOrcamento.DescontoAgravo__c;
    coberturaTO.idGarantiaProdutoSf = garantiaContratanteOrcamento.GarantiaProduto__c;

    if(garantiaContratanteOrcamento.DescontoAgravo__c != null && garantiaContratanteOrcamento.DescontoAgravo__c == 'Agravo'){
      coberturaTO.agravo = garantiaContratanteOrcamento.Percentual__c;
    }else if(garantiaContratanteOrcamento.DescontoAgravo__c != null && garantiaContratanteOrcamento.DescontoAgravo__c == 'Desconto'){
      coberturaTO.desconto = garantiaContratanteOrcamento.Percentual__c;
    }

    return coberturaTO;
  }

  /**
 *
 *
 * @param garantiaGrupoOrcamento Objeto GarantiaGrupoOrcamento do Salesforce que contem o premio
 *
 * @return PremioTO - Objeto interno do OrcamentoTO
 */
  public OrcamentoTO.PremioTO converteParaPremioTODeGarantiaGrupoOrcamento (GarantiaGrupoOrcamento__c garantiaGrupoOrcamento){
    OrcamentoTO.PremioTO premioTO = new OrcamentoTO.PremioTO();
    premioTO.puro = garantiaGrupoOrcamento.PremioPuro__c;
    premioTO.comercial = garantiaGrupoOrcamento.PremioComercial__c;
    premioTO.total = garantiaGrupoOrcamento.PremioTotal__c;
    premioTO.puroDesconto = garantiaGrupoOrcamento.PremioPuroDesconto__c;
    premioTO.puroInterno = garantiaGrupoOrcamento.PremioPuroInterno__c;
    premioTO.puroResseguro = garantiaGrupoOrcamento.PremioPuroResseguro__c;
    premioTO.comercialDesconto = garantiaGrupoOrcamento.PremioComercialDesconto__c;
    return  premioTO;
  }

  /**
*
*
* @param garantiaGrupoOrcamento Objeto GarantiaGrupoOrcamento do Salesforce que contem o premio
*
* @return PremioTO - Objeto interno do OrcamentoTO
*/
  public OrcamentoTO.PremioTO converteParaPremioTODeGarantiaSeguradoOrcamento (GarantiaContratanteOrcamento__c garantiaSeguradoOrcamento){
    OrcamentoTO.PremioTO premioTO = new OrcamentoTO.PremioTO();
    premioTO.puro = garantiaSeguradoOrcamento.PremioPuro__c;
    premioTO.comercial = garantiaSeguradoOrcamento.PremioComercial__c;
    premioTO.total = garantiaSeguradoOrcamento.PremioTotal__c;
    premioTO.puroDesconto = garantiaSeguradoOrcamento.PremioPuroDesconto__c;
    premioTO.puroInterno = garantiaSeguradoOrcamento.PremioPuroInterno__c;
    premioTO.puroResseguro = garantiaSeguradoOrcamento.PremioPuroResseguro__c;
    premioTO.comercialDesconto = garantiaSeguradoOrcamento.PremioComercialDesconto__c;
    return  premioTO;
  }

  /**
*
*
* @param garantiaGrupoOrcamento Objeto GarantiaGrupoOrcamento do Salesforce que contem o premio
*
* @return PremioTO - Objeto interno do OrcamentoTO
*/
  public OrcamentoTO.PremioTO converteParaPremioTODeGarantiaContratanteOrcamento (GarantiaContratanteOrcamento__c garantiaContratanteOrcamento){
    OrcamentoTO.PremioTO premioTO = new OrcamentoTO.PremioTO();
    premioTO.puro = garantiaContratanteOrcamento.PremioPuro__c;
    premioTO.comercial = garantiaContratanteOrcamento.PremioComercial__c;
    premioTO.total = garantiaContratanteOrcamento.PremioTotal__c;
    premioTO.puroDesconto = garantiaContratanteOrcamento.PremioPuroDesconto__c;
    premioTO.puroInterno = garantiaContratanteOrcamento.PremioPuroInterno__c;
    premioTO.puroResseguro = garantiaContratanteOrcamento.PremioPuroResseguro__c;
    premioTO.comercialDesconto = garantiaContratanteOrcamento.PremioComercialDesconto__c;
    return  premioTO;
  }

  /**
 *
 *
 * @param garantiaGrupoOrcamento Objeto GarantiaGrupoOrcamento__c do Salesforce que contem o premio
 *
 * @return TaxaTO - Objeto interno do OrcamentoTO
 */
  public OrcamentoTO.TaxaTO converteParaTaxaTODeGarantiaGrupoOrcamento (GarantiaGrupoOrcamento__c garantiaGrupoOrcamento){
    OrcamentoTO.TaxaTO taxaTO = new OrcamentoTO.TaxaTO();
    taxaTO.pura = garantiaGrupoOrcamento.TaxaPura__c;
    taxaTO.mensal = garantiaGrupoOrcamento.TaxaMensal__c;
    taxaTO.anual = garantiaGrupoOrcamento.TaxaAnual__c;
    taxaTO.puroInterno = garantiaGrupoOrcamento.TaxaPuroInterno__c;
    taxaTO.puroResseguro = garantiaGrupoOrcamento.TaxaPuroResseguro__c;
    taxaTO.comercial = garantiaGrupoOrcamento.TaxaComercial__c;
    taxaTO.total = garantiaGrupoOrcamento.TaxaTotal__c;

    return taxaTO;
  }

  /**
*
*
* @param garantiaSeguradoOrcamento Objeto GarantiaContratanteOrcamento__c do Salesforce que contem o premio
*
* @return TaxaTO - Objeto interno do OrcamentoTO
*/
  public OrcamentoTO.TaxaTO converteParaTaxaTODeGarantiaSeguradoOrcamento (GarantiaContratanteOrcamento__c garantiaSeguradoOrcamento){
    OrcamentoTO.TaxaTO taxaTO = new OrcamentoTO.TaxaTO();
    taxaTO.pura = garantiaSeguradoOrcamento.TaxaPura__c;
    taxaTO.mensal = garantiaSeguradoOrcamento.TaxaMensal__c;
    taxaTO.anual = garantiaSeguradoOrcamento.TaxaAnual__c;
    taxaTO.puroInterno = garantiaSeguradoOrcamento.TaxaPuroInterno__c;
    taxaTO.puroResseguro = garantiaSeguradoOrcamento.TaxaPuroResseguro__c;
    taxaTO.comercial = garantiaSeguradoOrcamento.TaxaComercial__c;
    taxaTO.total = garantiaSeguradoOrcamento.TaxaTotal__c;

    return taxaTO;
  }

  /**
*
*
* @param garantiaContratanteOrcamento Objeto GarantiaContratanteOrcamento__c do Salesforce que contem o premio
*
* @return TaxaTO - Objeto interno do OrcamentoTO
*/
  public OrcamentoTO.TaxaTO converteParaTaxaTODeGarantiaContratanteOrcamento (GarantiaContratanteOrcamento__c garantiaContratanteOrcamento){
    OrcamentoTO.TaxaTO taxaTO = new OrcamentoTO.TaxaTO();
    taxaTO.pura = garantiaContratanteOrcamento.TaxaPura__c;
    taxaTO.mensal = garantiaContratanteOrcamento.TaxaMensal__c;
    taxaTO.anual = garantiaContratanteOrcamento.TaxaAnual__c;
    taxaTO.puroInterno = garantiaContratanteOrcamento.TaxaPuroInterno__c;
    taxaTO.puroResseguro = garantiaContratanteOrcamento.TaxaPuroResseguro__c;
    taxaTO.comercial = garantiaContratanteOrcamento.TaxaComercial__c;
    taxaTO.total = garantiaContratanteOrcamento.TaxaTotal__c;

    return taxaTO;
  }

  /**
  *
  *
  * @param opportunity Objeto opportunity__c do Salesforce que contem a taxa
  *
  * @return TaxaTO - Objeto interno do OrcamentoTO
  */
  public OrcamentoTO.TaxaTO converteParaTaxaTODoOrcamento (Opportunity opportunity){
    OrcamentoTO.TaxaTO taxaTO = new OrcamentoTO.TaxaTO();
    taxaTO.pura = opportunity.TaxaPura__c;
    taxaTO.mensal = opportunity.TaxaMensal__c;
    taxaTO.total = opportunity.TaxaTotal__c;
    taxaTO.anual = opportunity.TaxaAnual__c;
    taxaTO.comercial = opportunity.TaxaComercial__c;

    return taxaTO;
  }

  /**
   *
   *
   * @param mapGarantiasContratantePorContratante Map<Id, List<GarantiaContratanteOrcamento__c>>
   * @param mapGruposPorSegurado Map<Id,List<GrupoOrcamento__c>>
   * @param mapGarantiasDoGrupoPorGrupo Map<Id, List<GarantiaGrupoOrcamento__c>>
   * @param mapSeguradoDoOrcamentoPorSegurado Map<Id, ContratanteOrcamento__c>
   *
   * @return List<OrcamentoTO.ContratanteTO> - Objeto interno do OrcamentoTO
   */
  public List<OrcamentoTO.ContratanteTO> gerarListaContratanteTOs (
          Map<Id, List<GarantiaContratanteOrcamento__c>> mapGarantiasContratantePorContratante,
          Map<Id,List<GrupoOrcamento__c>> mapGruposPorContratante,
          Map<Id, List<GarantiaGrupoOrcamento__c>> mapGarantiasDoGrupoPorGrupo,
          Map<Id, ContratanteOrcamento__c> mapContratanteOrcamentoPorContratante){

    List<OrcamentoTO.ContratanteTO> listContratanteTOs = new List<OrcamentoTO.ContratanteTO>();

    for(String contratanteId : mapGarantiasContratantePorContratante.keySet()){

      OrcamentoTO.ContratanteTO contratanteTO = new OrcamentoTO.ContratanteTO();
      contratanteTO.idSf = contratanteId;
      ContratanteOrcamento__c contratanteOrcamento = mapContratanteOrcamentoPorContratante.get(contratanteId);
      contratanteTO.pessoa = converteParaPessoaTO(contratanteOrcamento);

      // Cria a lista de coberturaTo
      List<GarantiaContratanteOrcamento__c>  listGarantiaContratanteOrcamento = mapGarantiasContratantePorContratante.get(contratanteId);
      if(listGarantiaContratanteOrcamento != null && !listGarantiaContratanteOrcamento.isEmpty()){
        contratanteTO.coberturas = geraListaDeCoberturaDeUmaListaDeGarantiaContratanteOrcamento(listGarantiaContratanteOrcamento);
      }

      // Cria a lista de grupoTos
      contratanteTO.grupos = geraListaDeGrupoTOs(contratanteId, mapGruposPorContratante, mapGarantiasDoGrupoPorGrupo);

      listContratanteTOs.add(contratanteTO);
    }

    return listContratanteTOs;
  }

  /**
   *
   *
   * @param seguradoId String - Id do segurado
   * @param mapGruposPorSegurado Map<Id,List<GrupoOrcamento__c>>
   * @param mapGarantiasDoGrupoPorGrupo Map<Id, List<GarantiaGrupoOrcamento__c>>
   *
   * @return List<OrcamentoTO.GrupoTO> - Lista de objeto interno do OrcamentoTO
   */
  public List<OrcamentoTO.GrupoTO> geraListaDeGrupoTOs(Id seguradoId, Map<Id,List<GrupoOrcamento__c>> mapGruposPorSegurado,
          Map<Id, List<GarantiaGrupoOrcamento__c>> mapGarantiasDoGrupoPorGrupo){

    List<OrcamentoTO.GrupoTO> listGrupoTOs = new List<OrcamentoTO.GrupoTO>();

    List<GrupoOrcamento__c> listGrupoOrcamentos = mapGruposPorSegurado.get(seguradoId);

    if(listGrupoOrcamentos == null || listGrupoOrcamentos.isEmpty()) return new List<OrcamentoTO.GrupoTO>();

    for(GrupoOrcamento__c grupoOrcamento : listGrupoOrcamentos){

      OrcamentoTO.GrupoTO grupoTO = new OrcamentoTO.GrupoTO();
      grupoTO.idSf = grupoOrcamento.Id;
      grupoTO.nome = grupoOrcamento.Name;
      grupoTO.valorDescontoAgravo = grupoOrcamento.Percentual__c;
      grupoTO.escolhaDescontoAgravo = grupoOrcamento.DescontoAgravo__c;

      // cria lista de coberturas
      List<GarantiaGrupoOrcamento__c> listGarantiaGrupoOrcamentos =  mapGarantiasDoGrupoPorGrupo.get(grupoOrcamento.Id);
      if(listGarantiaGrupoOrcamentos != null && !listGarantiaGrupoOrcamentos.isEmpty())
        grupoTO.coberturas = geraListaDeCoberturaDeUmaListaDeGarantiaGrupoOrcamento(listGarantiaGrupoOrcamentos);

      listGrupoTOs.add(grupoTO);
    }

    return listGrupoTOs;

  }

  public class CalculoOrcamentoServiceException extends Exception { }
}