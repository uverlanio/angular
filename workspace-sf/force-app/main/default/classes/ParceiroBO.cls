/**
 * Created by Alessandro Ponte on 19/09/2018.
 */

public class ParceiroBO {

    private static final ParceiroBO instancia = new ParceiroBO();
    private static ParceiroDAO dao = ParceiroDAO.getInstance();
    private static final String PRODUTO_COMERCIAL = 'ProdutoComercial';
    private static HerokuService herokuServ = HerokuService.getInstance();

    private ParceiroBO(){}

    public static ParceiroBO getInstance(){
        return instancia;
    }

    public RetornoAcaoBotaoTO ativarParceiro(Id parceiroId) {

        // variaveis
        RetornoAcaoBotaoTO retorno = new RetornoAcaoBotaoTO();
        List<Parceiro__c> listParceiro = dao.buscarParceirosPorIds(new List<Id>{parceiroId});

        // Recupera dados do parceiro
        Parceiro__c parceiro = listParceiro[0];

        if(parceiro.Status__c == 'Ativo'){
            retorno.tipo = RetornoAcaoBotaoTO.WARNING;
            retorno.mensagens.add('Parceiro já esta Ativo!');
        }else{
            if(this.validarRegrasAtivacaoParceiro(parceiro, retorno)){

                parceiro.Status__c = 'Ativo';
                try {
                    update parceiro;
                    retorno.tipo = RetornoAcaoBotaoTO.SUCCESS;
                    retorno.mensagens.add('Parceiro ativado com sucesso!');
                }catch (Exception e){
                    retorno.tipo = RetornoAcaoBotaoTO.ERROR;
                    retorno.mensagens.add('Erro ao tentar ativar o parceiro!');
                    retorno.mensagens.add(e.getMessage());
                }

            }else{
                retorno.tipo = RetornoAcaoBotaoTO.ERROR;
            }
        }

        return retorno;
    }

    //Executa validações necessárias para ativar um parceiro
    private Boolean validarRegrasAtivacaoParceiro(Parceiro__c parceiro, RetornoAcaoBotaoTO retorno){
        Boolean parceiroEhValido = true;

        // Variveis
        Map< Id,Product2 > mapProdutoPorIdProduto = new Map< Id, Product2 >();
        Map< Id,List<RemuneracaoProdutoParceiro__c> > mapListRemuneracaoProdutoParceiroPorIdProduto = new Map< Id, List<RemuneracaoProdutoParceiro__c> >();
        Set< Id > setIdTipoRemuneracaoObrigatoria = new Set< Id >();
        Map< Id, RemuneracaoProduto__c > mapRemuneracaoProdutoPorIdTipoRemuneracao = new Map<Id, RemuneracaoProduto__c>();

        // Valida se parceiro possui produto
        if(parceiro.ProdutosParceiro__r == null || parceiro.ProdutosParceiro__r.isEmpty()){
            parceiroEhValido = false;
            retorno.mensagens.add('Relacionar pelo menos um produto comercial ao parceiro');
            return false;
        }

        // Valida se todos os produtos são comerciais
        List<ProdutoParceiro__c> listProduto = parceiro.ProdutosParceiro__r;
        for(ProdutoParceiro__c produtoParceiro : listProduto){
            if(produtoParceiro.Produto__r.RecordType.DeveloperName != PRODUTO_COMERCIAL){
                parceiroEhValido = false;
                retorno.mensagens.add('Produto ' + produtoParceiro.Produto__r.ProductCode + ' não é um produto comercial!');
                return false;
            }

            mapProdutoPorIdProduto.put(produtoParceiro.Produto__c, new Product2());
        }

        // Busca os produtos e suas remuneracoes
        for(Product2 produto : dao.buscarProdutos(mapProdutoPorIdProduto.keySet())){
            mapProdutoPorIdProduto.put(produto.Id, produto);
        }

        // Busca aos Favorecidos da remuneracao
        for(RemuneracaoProdutoParceiro__c remuneracaoProdutoParceiro: dao.buscarRemuneracaoProdutoParceiro(new Set<Id>{parceiro.Id})){

            if(!mapListRemuneracaoProdutoParceiroPorIdProduto.containsKey(remuneracaoProdutoParceiro.ProdutoParceiro__r.Produto__c)){
                mapListRemuneracaoProdutoParceiroPorIdProduto.put(remuneracaoProdutoParceiro.ProdutoParceiro__r.Produto__c, new List<RemuneracaoProdutoParceiro__c>());
            }

            mapListRemuneracaoProdutoParceiroPorIdProduto.get(remuneracaoProdutoParceiro.ProdutoParceiro__r.Produto__c).add(remuneracaoProdutoParceiro);
        }

        // Itera os produtos do parceiro
        for(Id idProduto : mapProdutoPorIdProduto.keySet()){
            Product2 produto2 = mapProdutoPorIdProduto.get(idProduto);

            List<RemuneracaoProdutoParceiro__c> listRemuneracaoProdutoParceiro =
                    mapListRemuneracaoProdutoParceiroPorIdProduto.get(idProduto);

            // Valida se o produto possui remuneracao do produto do parceiro
            if(listRemuneracaoProdutoParceiro == null || listRemuneracaoProdutoParceiro.isEmpty()){
                parceiroEhValido = false;
                retorno.mensagens.add('Remuneracao no parceiro não cadastrada para o Produto ' +  produto2.ProductCode);
                continue;
            }

            // Valida se o produto esta ativo e vigente
            if( produto2.VigenciaFinal__c < System.today()
                    || produto2.VigenciaInicial__c > System.today()
                    || produto2.Status__c != 'Ativo' ){

                parceiroEhValido = false;
                retorno.mensagens.add('Produto ' +  produto2.ProductCode + ' não está ativo e/ou vigente');
            }

            // Itera as remuneracoes do produto
            for(RemuneracaoProduto__c remuneracaoProduto : produto2.RemuneracoesProduto__r){

                // Verifica se eh uma remuneracao obrigatoria
                if(remuneracaoProduto.Obrigatoria__c){
                    setIdTipoRemuneracaoObrigatoria.add(remuneracaoProduto.TipoRemuneracao__c);
                }

                mapRemuneracaoProdutoPorIdTipoRemuneracao.put(remuneracaoProduto.TipoRemuneracao__c,remuneracaoProduto);

            }

            // Itera as remuneracoes por produto do parceiro
            for(RemuneracaoProdutoParceiro__c remuneracaoProdutoParceiro : listRemuneracaoProdutoParceiro){

                setIdTipoRemuneracaoObrigatoria.remove(remuneracaoProdutoParceiro.TipoRemuneracao__c);

                // Valida se os tipos de remuneracao do parceiro sao permitidos pelo produto
                RemuneracaoProduto__c remuneracaoProduto = mapRemuneracaoProdutoPorIdTipoRemuneracao.get(remuneracaoProdutoParceiro.TipoRemuneracao__c);
                if(remuneracaoProduto == null){
                    parceiroEhValido = false;
                    retorno.mensagens.add('Remuneração ' + remuneracaoProdutoParceiro.TipoRemuneracao__r.Name + ' não permitida pelo produto' );
                    continue;
                }

                //  Valida se para cada tipo de remuneracao exista pelo menos um favorecido
                List<FavorecidoRemuneracao__c> listFavorecidoRemuneracao = remuneracaoProdutoParceiro.FavorecidosRemuneracao__r;

                if(listFavorecidoRemuneracao.isEmpty()){
                    parceiroEhValido = false;
                    retorno.mensagens.add('Informar os favorecidos da Remuneração ' + remuneracaoProdutoParceiro.TipoRemuneracao__r.Name);
                }
                Boolean ehCorretagem = false;
                if(remuneracaoProdutoParceiro.TipoRemuneracao__r.Name == 'CORRETAGEM') ehCorretagem = true;

                List<FavorecidoRemuneracao__c> listFavorecidoRemuneracaoLider = new List<FavorecidoRemuneracao__c>();
                Decimal percentualTotal = 0.00;

                for(FavorecidoRemuneracao__c favorecidoRemuneracao : listFavorecidoRemuneracao){

                    // Verifica se existe somente um lider para o tipo de remuneracao corretagem
                    if(ehCorretagem && favorecidoRemuneracao.Lider__c) listFavorecidoRemuneracaoLider.add(favorecidoRemuneracao);

                    // Verifica se o papel do favorecido eh um papel da conta
                    if(!favorecidoRemuneracao.Conta__r.Papel__c.contains(favorecidoRemuneracao.Papel__c)){
                        parceiroEhValido = false;
                        retorno.mensagens.add('Papel do favorecido(a) ' + favorecidoRemuneracao.Conta__r.Name + ' não vínculado a conta!');
                    }

                    percentualTotal += favorecidoRemuneracao.Percentual__c;                }

                // Valida se existe e somente um lider para o tipo de remuneracao corretagem
                if (ehCorretagem && listFavorecidoRemuneracaoLider.size() == 0) {
                    parceiroEhValido = false;
                    retorno.mensagens.add('Informar um líder para a remuneração de corretagem');
                } else if (ehCorretagem && listFavorecidoRemuneracaoLider.size() > 1) {
                    parceiroEhValido = false;
                    retorno.mensagens.add('Informar somente um líder para a remuneração de corretagem');
                }

                percentualTotal = percentualTotal.setScale(2);

                // Valida se a somatória do percentual de todos os favorecidos da remuneracao eh exatamente igual a 100%
                if(percentualTotal != 100.00){
                    parceiroEhValido = false;
                    retorno.mensagens.add('A somatória do percentual dos favorecidos da remuneração ' + remuneracaoProdutoParceiro.TipoRemuneracao__r.Name + ' é diferente de 100%');
                }

                // Valida se o limite máximo e mínimo sao permitidos pelo produto
                if(remuneracaoProdutoParceiro.Percentual__c < remuneracaoProduto.LimiteMinimo__c
                        || remuneracaoProdutoParceiro.Percentual__c > remuneracaoProduto.LimiteMaximo__c){
                    parceiroEhValido = false;
                    retorno.mensagens.add('Percentual da remuneração ' + remuneracaoProdutoParceiro.TipoRemuneracao__r.Name + ' fora dos limites');
                }


            }

            // Valida se todas as remuneracoes obrigatoria pelo produto existem no parceiro
            if(!setIdTipoRemuneracaoObrigatoria.isEmpty()){
                parceiroEhValido = false;
                retorno.mensagens.add('Cadastrar todas as remunerações obrigatórias no Parceiro' );
            }

        }

        return parceiroEhValido;
    }

    public void geracaoNumeroApolice(List<Parceiro__c> listParceiro){

        Map<Id,ConsultarDadosContratoTO.NumeroPropostaTO> mapNumeroPropostaTOPorParceiro = new Map<Id,ConsultarDadosContratoTO.NumeroPropostaTO>();
        Map<Id,Parceiro__c> mapParceiroPorId = new Map<Id, Parceiro__c>();

        for(Parceiro__c parceiro : listParceiro){
            ConsultarDadosContratoTO.NumeroPropostaTO numeroPropostaTO = mapNumeroPropostaTOPorParceiro.get(parceiro.Id);
            //gerarNumeroProposta(parceiro.Empresa__c,parceiro.Sucursal__c, parceiro.Ramo__c, parceiro.Id); //RVI-298 Comentar só a empresa
            gerarNumeroProposta(parceiro.Sucursal__c, parceiro.Ramo__c, parceiro.Id); //RVI-298 sem a empresa
        }

    }

    @future(callout=true)
    //public static void gerarNumeroProposta(String empresa, String sucursal, String ramo, Id parceiroId){ //RVI-298 Comentar só a empresa
    public static void gerarNumeroProposta(String sucursal, String ramo, Id parceiroId){ //RVI-298 sem a empresa
        System.debug('--- Gerar numero proposta ---');
        System.debug('dados da requisição ------------ ');
        //System.debug('Empresa: ' + empresa + ' sucursal: ' + sucursal + ' ramo: ' + ramo);//RVI-298 Comentar
        System.debug('Id do parceiro: ' + parceiroId);

        // Declara variaveis
        Parceiro__c parceiro;
        ConsultarDadosContratoTO.NumeroPropostaTO numeroPropostaTO;
        List<String> listNumeroProposta;

        // Busca o parceiro
        List<Parceiro__c> listParceiro = dao.buscarParceirosPorIds(new List<Id>{parceiroId});

        if(!listParceiro.isEmpty()){
            parceiro = listParceiro[0];
        }

        // Converte os dados
        try {
            numeroPropostaTO = new ConsultarDadosContratoTO.NumeroPropostaTO();

            //numeroPropostaTO.empresa = Integer.valueOf(empresa); //RVI-298 Comentar
            numeroPropostaTO.sucursal = Integer.valueOf(sucursal);
            numeroPropostaTO.ramo = Integer.valueOf(ramo);
        }catch (Exception e){
            throw new ParceiroException('Erro ao converter empresa, sucursal e ramo em numero inteiro ' + e.getLineNumber() + e.getMessage());
        }

        try {
            if(Test.isRunningTest()){
                listNumeroProposta = new List<String>{'1'};
            }else{
                listNumeroProposta = herokuServ.gerarNumeroApolice(numeroPropostaTO, 1);
            }
        }catch (Exception e){
            throw new ParceiroException('Erro ao gerar o numero de proposta ' + e.getLineNumber() + e.getMessage());
        }

        System.debug('--- Retorno da geração do numero de Apolice --- '+ listNumeroProposta);

        if(!listNumeroProposta.isEmpty()){
            parceiro.ApoliceFaturamento__c = listNumeroProposta[0];
        }

        try{
            update parceiro;
        }catch (Exception e){
            throw new ParceiroException('Erro ao atualizar o parceiro ' + e.getLineNumber() + ' ' + e.getMessage());
        }
    }

    public void atualizarVersaoProdutoParceiro(Map<String, Product2> mapProdutoMaximaVersao, List<ProdutoParceiro__c> produtosParceiro){

        List<ProdutoParceiro__c> produtoParceiroAtualizar = new List<ProdutoParceiro__c>();

        for(ProdutoParceiro__c produtoParceiro : produtosParceiro){

            // Verifica se existe um produto com a versão maxima e ativo
            if(!mapProdutoMaximaVersao.containsKey(produtoParceiro.Produto__r.ProductCode)) continue;

            Product2 produtoAtualizado = mapProdutoMaximaVersao.get(produtoParceiro.Produto__r.ProductCode);

            if(produtoParceiro.Produto__r.Versao__c != produtoAtualizado.Versao__c){

                produtoParceiro.Produto__c = produtoAtualizado.Id;
                produtoParceiroAtualizar.add(produtoParceiro);
            }

        }

        if (!produtoParceiroAtualizar.isEmpty()) {
            update produtoParceiroAtualizar;
        }

    }

    public List<Parceiro__c> buscarTodosParceiros(){
        return dao.buscarTodosParceiros();
    }

    public List<ProdutoParceiro__c> buscarProdutosParceiro(Set<String> setCodigoParceiro, Set<String> setCodigoProduto){
        return dao.buscarProdutosParceiro(setCodigoParceiro,setCodigoProduto);
    }

    public class ParceiroException extends Exception{}

}