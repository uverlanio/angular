/**************************************************************************************************************************************************************************
 * 
 *	Classe responsável pelo negócio do objeto de RemuneracaoCanal__c
 *
 **************************************************************************************************************************************************************************/
public class RemuneracaoCanalBO {
  private static final RemuneracaoCanalBO instancia = new RemuneracaoCanalBO();

  private RemuneracaoCanalBO() {
  }

  public static RemuneracaoCanalBO getInstance(){
    return instancia;
  }

  /**
   * Valida se um tipo de remuneração pode ou não ser utilizado
   *
   */
  public void validarTipoRemuneracao(List<RemuneracaoCanal__c> remuneracoesCanal){
    RegrasFabricaProdutos.validarTipoRemuneracaoFilhosProdutoCanal(remuneracoesCanal, 'RemuneracaoCanal__c');
  }

  /**
   * Valida se as parcelas de agenciamento escolhidas estão OK
   *
   */
  public void validarParcelasAgenciamento(List<RemuneracaoCanal__c> remuneracoesCanal){
    List<String> produtoCanalIds = new List<String>();
    Map<Id, List<RemuneracaoCanal__c>> mapRegistrosValidar = new Map<Id, List<RemuneracaoCanal__c>>();

    //Recupera ids de todos os produtos do canal
    for(RemuneracaoCanal__c remuneracaoCanal : remuneracoesCanal){
      Id idProdutoCanal = remuneracaoCanal.ProdutoCanal__c;
      produtoCanalIds.add('\'' + idProdutoCanal + '\'');

      if(!mapRegistrosValidar.containsKey(idProdutoCanal)){
        mapRegistrosValidar.put(idProdutoCanal, new List<RemuneracaoCanal__c>());
      }

      mapRegistrosValidar.get(idProdutoCanal).add(remuneracaoCanal);
    }

    if(!produtoCanalIds.isEmpty()){
      Set<Id> produtosIds = new Set<Id>();
      Map<Id, Id> mapProdutoCanalProduto = new Map<Id, Id>();
      Map<Id, List<RemuneracaoProduto__c>> mapProdutoRemuneracoesProduto = new Map<Id, List<RemuneracaoProduto__c>>();

      String criterio = 'Id IN ('+ String.join(produtoCanalIds, ', ') + ')';

      //Recupera as ids do produto relacionado com o produto do canal. Cria map com a relaçao do produto o canal e o produto
      for(ProdutoCanal__c produtoCanal : Database.query(Util.gerarQuery('ProdutoCanal__c', SObjectSchema.listarCamposEditaveis('ProdutoCanal__c'), new List<String>{criterio}))){
        produtosIds.add(produtoCanal.Produto__c);
        mapProdutoCanalProduto.put(produtoCanal.Id, produtoCanal.Produto__c);
      }

      //Busca as remunerações do produto. Gera a relação do produto com os tipos de remuneração
      for(RemuneracaoProduto__c remuneracaoProduto : RemuneracaoProdutoDAO.getInstance().buscarRemuneracaoProdutoPorProdutos(produtosIds)){
        if(!mapProdutoRemuneracoesProduto.containsKey(remuneracaoProduto.Produto__c)){
          mapProdutoRemuneracoesProduto.put(remuneracaoProduto.Produto__c, new List<RemuneracaoProduto__c>());
        }

        mapProdutoRemuneracoesProduto.get(remuneracaoProduto.Produto__c).add(remuneracaoProduto);
      }

      //Realiza a validacao das parcelas. Compara todos os regustros de remuneração do canal com os registros de remuneração do produto
      for(Id idProdutoCanal : mapRegistrosValidar.keySet()){
        Id produtoId = mapProdutoCanalProduto.get(idProdutoCanal);

        for(RemuneracaoCanal__c remuneracaoCanal : mapRegistrosValidar.get(idProdutoCanal)){
          for(RemuneracaoProduto__c remuneracaoProduto : mapProdutoRemuneracoesProduto.get(produtoId)){
            Set<String> parcelasAgenciamentoProduto = new Set<String>();

            if(String.isNotBlank(remuneracaoProduto.ParcelasAgenciamento__c)){
              parcelasAgenciamentoProduto.addAll(remuneracaoProduto.ParcelasAgenciamento__c.split(';'));
            }

            if(remuneracaoProduto.TipoRemuneracao__r.Name <> null &&
               remuneracaoProduto.TipoRemuneracao__r.Name.toUpperCase() == 'AGENCIAMENTO' &&
               remuneracaoCanal.TipoRemuneracao__c == remuneracaoProduto.TipoRemuneracao__c &&
               (parcelasAgenciamentoProduto == null || parcelasAgenciamentoProduto.contains(remuneracaoCanal.ParcelasAgenciamento__c) == false)){
              remuneracaoCanal.addError('As Parcelas de agenciamento devem ser iguais as Parcelas de agenciamento da Remuneração do produto.');
            }
          }
        }
      }
    }
  }

  public void validarRemuneracaoObrigatoria(Map<Id, RemuneracaoCanal__c> remuneracoesCanal) {
    Map<Id, Id> mapProdutoCanalTipoRemuneracao = new Map<Id, Id>();

    for (RemuneracaoCanal__c rc : remuneracoesCanal.values()) {
      if (rc.ProdutoCanal__c != null) {
        mapProdutoCanalTipoRemuneracao.put(rc.ProdutoCanal__c, rc.TipoRemuneracao__c);
      }
    }

    // buscar ids de produto no objeto produto do canal
    List<ProdutoCanal__c> lstProdutoCanal = ProdutoCanalDAO.getInstance().buscarProdutoCanalPorIds(mapProdutoCanalTipoRemuneracao.keySet());

    Map<Id, Id> mapProdutoComercialProdutoCanal = new Map<Id, Id>();

    for (ProdutoCanal__c pc : lstProdutoCanal) {
      mapProdutoComercialProdutoCanal.put(pc.Produto__c, pc.Id);
    }

    // buscar o tipo de remuneracao do objeto remuneracao do produto
    List<RemuneracaoProduto__c> lstRemuneracaoProdutoObrigatoria = RemuneracaoProdutoBO.getInstance().buscarRemuneracoesObrigatoriasPorProduto(mapProdutoComercialProdutoCanal.keySet());
    Map<Id, Id> mapProdutoCanalTipoRemuneracaoObrigatoria = new Map<Id, Id>();

    for(RemuneracaoProduto__c rp : lstRemuneracaoProdutoObrigatoria) {
      mapProdutoCanalTipoRemuneracaoObrigatoria.put(mapProdutoComercialProdutoCanal.get(rp.Produto__c), rp.TipoRemuneracao__c);
    }

    for (RemuneracaoCanal__c rc : remuneracoesCanal.values()) {
      if (mapProdutoCanalTipoRemuneracaoObrigatoria.get(rc.ProdutoCanal__c) == rc.TipoRemuneracao__c) {
        rc.addError('Esta Remuneração do canal é obrigatória no Produto comercial e não será excluída.');
      }
    }
  }

  //Valida Meio de Comercialização
  public void validarMeioComercializacao(List<RemuneracaoCanal__c> remuneracoesCanal)
  {
    Set<Id> produtoCanalIds = new Set<Id>();
    Map<String, Id> mapRemuneracaoCanal = new Map<String, Id>();

    //Busca os produtos do canal para encontrar o produto relacionado
    for(RemuneracaoCanal__c remuneracaoCanal : remuneracoesCanal){
      produtoCanalIds.add(remuneracaoCanal.ProdutoCanal__c);
    }

    //Busca os Remunerações do produto do canal 
    for(RemuneracaoCanal__c remuneracaoCanal : RemuneracaoCanalDao.getInstance().buscarRemuneracaoCanalPorProdutos(produtoCanalIds))
    {
      mapRemuneracaoCanal.put(remuneracaoCanal.TipoRemuneracao__c + remuneracaoCanal.MeioComercializacao__c, remuneracaoCanal.Id);
    }

    for(RemuneracaoCanal__c remuneracaoCanal : remuneracoesCanal)
    {
      if(mapRemuneracaoCanal.containsKey(remuneracaoCanal.TipoRemuneracao__c + remuneracaoCanal.MeioComercializacao__c))
      {
        if(mapRemuneracaoCanal.get(remuneracaoCanal.TipoRemuneracao__c + remuneracaoCanal.MeioComercializacao__c) != remuneracaoCanal.Id)
        {
            system.debug('TESTE 1 '+ mapRemuneracaoCanal.get(remuneracaoCanal.TipoRemuneracao__c + remuneracaoCanal.MeioComercializacao__c));
          	system.debug('TESTE 2 '+remuneracaoCanal.Id);
            remuneracaoCanal.addError('Tipo Remuneração/Meio de Comercialização já cadastrado.');

          break;
        }
      }
    }
  }

  //Valida limite minimo e máximo com relação  as as Remunerações do produto
  public void validarLimites(List<RemuneracaoCanal__c> remuneracoesCanal){
    Set<Id> produtoCanalIds = new Set<Id>();
    Set<Id> produtoIds = new Set<Id>();
    Map<Id, Id> produtoCanal = new Map<Id, Id>();
    Map<Id, List<RemuneracaoProduto__c>> mapListRemuneracaoProdutoPorProduto = new Map<Id, List<RemuneracaoProduto__c>>();

    //Busca os produtos do canal para encontrar o produto relacionado
    for(RemuneracaoCanal__c remuneracaoCanal : remuneracoesCanal){
      produtoCanalIds.add(remuneracaoCanal.ProdutoCanal__c);
    }

    for(ProdutoCanal__c produtoCan : ProdutoCanalBO.getInstance().buscarProdutoCanal(produtoCanalIds)){
      produtoCanal.put(produtoCan.Id, produtoCan.Produto__c);
      produtoIds.add(produtoCan.Produto__c);
    }

    //Busca as remunerações dos produtos e gera map com a relação produto X RemuneracaoProduto__c
    for(RemuneracaoProduto__c remProduto : RemuneracaoProdutoBO.getInstance().buscarRemuneracaoProdutoPorProdutos(produtoIds)){
      List<RemuneracaoProduto__c> lstRemuneracaoProduto = mapListRemuneracaoProdutoPorProduto.get(remProduto.Produto__c);
      if(lstRemuneracaoProduto == null) lstRemuneracaoProduto = new List<RemuneracaoProduto__c>();
      lstRemuneracaoProduto.add(remProduto);
      mapListRemuneracaoProdutoPorProduto.put(remProduto.Produto__c, lstRemuneracaoProduto);
    }

    //Executa as validações
    for(RemuneracaoCanal__c remuneracaoCanal : remuneracoesCanal){
      RemuneracaoProduto__c remuneracaoProd;

      // Pega a remuneração do produto existente no canal
      for(RemuneracaoProduto__c remuneracaoProd2 : mapListRemuneracaoProdutoPorProduto.get(produtoCanal.get(remuneracaoCanal.ProdutoCanal__c))){
        if(remuneracaoProd2 == null || remuneracaoCanal.TipoRemuneracao__c != remuneracaoProd2.TipoRemuneracao__c)continue;
        remuneracaoProd = remuneracaoProd2;
      }

      // Verifica se encontrou a mesma remuneração do canal no produto
      if(remuneracaoProd == null) remuneracaoCanal.addError('O tipo da remuneração do canal não informado no produto!');

      //Valida a remuneração e o os limites
      if(remuneracaoProd != null && remuneracaoCanal.TipoRemuneracao__c == remuneracaoProd.TipoRemuneracao__c){

        if(remuneracaoCanal.LimiteMinimo__c < remuneracaoProd.LimiteMinimo__c || remuneracaoCanal.LimiteMinimo__c > remuneracaoProd.LimiteMaximo__c){
          remuneracaoCanal.addError('Limite mínimo inválido. O limite informado menor que o limite permitido no produto.');
        }

        if(remuneracaoCanal.LimiteMaximo__c < remuneracaoProd.LimiteMinimo__c || remuneracaoCanal.LimiteMaximo__c > remuneracaoProd.LimiteMaximo__c){
          remuneracaoCanal.addError('Limite máximo inválido. O limite informado maior que o limite permitido no produto.');
        }
      }
    }
  }
}