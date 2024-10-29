/**************************************************************************************************************************************************************************
 *
 *	Classe responsável pelo negócio do objeto de RemuneracaoOrcamento__c
 *
 **************************************************************************************************************************************************************************/
public  class RemuneracaoOrcamentoBO {
    private static final RemuneracaoOrcamentoBO instancia = new RemuneracaoOrcamentoBO();
    private RemuneracaoOrcamentoDAO dao = RemuneracaoOrcamentoDAO.getInstance();

    private RemuneracaoOrcamentoBO() {
    }

    public static RemuneracaoOrcamentoBO getInstance(){
        return instancia;
    }

    //Verifica se mais de um tipo de remuneração já não está sendo utilizado no mesmo orçamento
    public void validarTipoRemuneracaoExistente(List<RemuneracaoOrcamento__c> remuneracoesOrcamento){
        Set<Id> orcamentoIds = new Set<Id>();
        Map<Id, List<RemuneracaoOrcamento__c>> mapOrcamenteRemuneracoes = new Map<Id, List<RemuneracaoOrcamento__c>>();

        //Recupera id de todos os orçamentos para realizar busca
        for(RemuneracaoOrcamento__c remOrcamento : remuneracoesOrcamento){
            orcamentoIds.add(remOrcamento.Oportunidade__c);
        }

        System.debug('Ids de orcamentos ------------- ' + orcamentoIds);

        //Gera map com
        for(Opportunity orcamento : OpportunityDAO.getInstance().buscarOrcamentosPorId(orcamentoIds)){
            System.debug('Orcamento da base --------------------- ' + orcamento);
            if(!mapOrcamenteRemuneracoes.containsKey(orcamento.Id)){
                mapOrcamenteRemuneracoes.put(orcamento.Id, new List<RemuneracaoOrcamento__c>());
            }

            mapOrcamenteRemuneracoes.get(orcamento.Id).addAll(orcamento.RemuneracoesOrcamento__r);
        }

        //Realiza validação, não deixando inserir/atualizar um tipo de remuneração já existente
        System.debug('Remuneracao na trigger --------------------- ' + remuneracoesOrcamento);
        for(RemuneracaoOrcamento__c remOrcamento : remuneracoesOrcamento){
            for(RemuneracaoOrcamento__c remOrcamentoExistente : mapOrcamenteRemuneracoes.get(remOrcamento.Oportunidade__c)){

                System.debug('remOrcamento.Id ---------------- ' + remOrcamento.Id);
                System.debug('remOrcamentoExistente.Id -------------------- ' + remOrcamentoExistente.Id);
                System.debug('remOrcamento.TipoRemuneracao__c ----------------- ' + remOrcamento.TipoRemuneracao__c);
                System.debug('remOrcamentoExistente.TipoRemuneracao__c ------------------ ' + remOrcamentoExistente.TipoRemuneracao__c);

                if(remOrcamento.Id != remOrcamentoExistente.Id && remOrcamento.TipoRemuneracao__c == remOrcamentoExistente.TipoRemuneracao__c){
                    remOrcamento.addError('Remuneração já cadastrada.');
                }
            }
        }
    }

    //Valida o tipo de remuneração escolhido, com relação ao produto do canal
    public void validarDadosEmProdutoCanal(List<RemuneracaoOrcamento__c> remuneracoesOrcamento){
        Set<Id> orcamentoIds = new Set<Id>();
        Set<Id> produtoIds = new Set<Id>();
        Map<Id, Opportunity> mapOrcamento = new Map<Id, Opportunity>();
        Map<Id, ProdutoCanal__c> mapOrcamentoProdutoCanal = new Map<Id, ProdutoCanal__c>();

        //Recupera todas as ids de orçamento para realizar busca de orçamentos
        for(RemuneracaoOrcamento__c remOrcamento : remuneracoesOrcamento){
            orcamentoIds.add(remOrcamento.Oportunidade__c);
        }

        //Recupera as ids de produtos para encontrar os Produtos do canal
        for(Opportunity orcamento : OpportunityDAO.getInstance().buscarOrcamentosPorId(orcamentoIds)){
            mapOrcamento.put(orcamento.Id, orcamento);
            mapOrcamentoProdutoCanal.put(orcamento.Id, null);
            produtoIds.add(orcamento.Produto__c);

        }

        //Realiza busca dos produtos do canal, e completa map mapOrcamentoProdutoCanal
        for(ProdutoCanal__c produtoCanal : ProdutoCanalBO.getInstance().buscarProdutoCanalPorProdutos(produtoIds)){



            for(Id orcamentoId : mapOrcamentoProdutoCanal.keySet()){
                Opportunity orcamento = mapOrcamento.get(orcamentoId);

                //Encontra o produto do canal relacionado com a oportunidade
                if(orcamento.Produto__c ==  produtoCanal.Produto__c)// && orcamento.CanalDistribuicao__c ==  produtoCanal.CanalDistribuicao__c){
                {
                    mapOrcamentoProdutoCanal.put(orcamentoId, produtoCanal);
                }
            }
        }

        //Realiza as validações
        for(RemuneracaoOrcamento__c remOrcamento : remuneracoesOrcamento){
            ProdutoCanal__c prodCanal = mapOrcamentoProdutoCanal.get(remOrcamento.Oportunidade__c);

            if(prodCanal != null){
                //Verifica se o tipo de remuneraçao da RemuneracaoOrcamento__c existe nas Remunerações do produto do canal
                Boolean tipoRemuneracaoExistente = false;
                RemuneracaoCanal__c remuneracaoProdutoCanalEncontrado;

                for(RemuneracaoCanal__c remuneracaoProdutoCanal : prodCanal.RemuneracoesProdutoCanal__r){
                    system.debug('Remuneração Produto Canal: '+ remuneracaoProdutoCanal.TipoRemuneracao__c);
                    system.debug('Remuneração Orçamento: '+ remOrcamento.TipoRemuneracao__c);
                    if(remuneracaoProdutoCanal.TipoRemuneracao__c == remOrcamento.TipoRemuneracao__c){
                        tipoRemuneracaoExistente = true;
                        remuneracaoProdutoCanalEncontrado = remuneracaoProdutoCanal;
                        break;
                    }
                }

                //Caso encontre o tipo de remuneração no produto do canal, valida os limites
                if(tipoRemuneracaoExistente){
                    this.validarLimiteRemuneracoesProdutoCanal(remOrcamento, remuneracaoProdutoCanalEncontrado);
                }
                else{
                    remOrcamento.addError('Tipo de remuneração não existe no canal.');
                }
            }
            else{
                remOrcamento.addError('Não foi encontrado o produto do canal para este orçamento.');
            }
        }
    }

    //Valida limite min/max com relação as remunerações do produto do canal
    private void validarLimiteRemuneracoesProdutoCanal(RemuneracaoOrcamento__c remOrcamento, RemuneracaoCanal__c remuneracaoProdutoCanal){
        if(remOrcamento.Percentual__c < remuneracaoProdutoCanal.LimiteMinimo__c){
            remOrcamento.addError('Percentual de carregamento abaixo do limite do produto comercial.');
        }

        if(remOrcamento.Percentual__c > remuneracaoProdutoCanal.LimiteMaximo__c)
        {
            remOrcamento.addError('Percentual de carregamento acima do limite do produto comercial. ' + remOrcamento.Percentual__c + ' X ' + remuneracaoProdutoCanal );
        }
    }

    //Valida o se o valor de carregamento gerado pelo calculo de todas as remunerações não vai ultrapassar valor total de cada
    public void validarPercentualCarregamento(List<RemuneracaoOrcamento__c> listRemuneracaoOrcamento){

        // Declara variaveis
        List<RemuneracaoOrcamento__c> listRemuneracaoOrcamentoRestantes = new List<RemuneracaoOrcamento__c>();
        List<String> listMensagem = new List<String>();
        Set<Id> setOrcamentoId = new Set<Id>();
        RemuneracaoOrcamento__c remuneracaoOrcamentoAgenciamento;
        Date vigenciaInicial;
        Date vigenciaFinal;
        Decimal limiteTotalCarregamento;
        String mensagem = '';
        Decimal totalCarregamentoCalculado;

        // Itera as remuneracoes do orcamento
        for(RemuneracaoOrcamento__c remuneracaoOrcamento : listRemuneracaoOrcamento){
            setOrcamentoId.add(remuneracaoOrcamento.Oportunidade__c);
        }

        // Busca mais informacoes da RemuneracaoOrcamento
        for(RemuneracaoOrcamento__c remuneracaoOrcamento : dao.buscarRemuneracoesOportunidade(setOrcamentoId)){
            limiteTotalCarregamento = remuneracaoOrcamento.Oportunidade__r.Produto__r.LimiteTotalCarregamento__c;
            vigenciaInicial = remuneracaoOrcamento.Oportunidade__r.VigenciaInicial__c;
            vigenciaFinal = remuneracaoOrcamento.Oportunidade__r.VigenciaFinal__c;

            if(remuneracaoOrcamento.TipoRemuneracao__r.Name == 'AGENCIAMENTO'){
                remuneracaoOrcamentoAgenciamento = remuneracaoOrcamento;
            }else{
                listRemuneracaoOrcamentoRestantes.add(remuneracaoOrcamento);
            }
        }

        // Validacoes basicas
        if(limiteTotalCarregamento == null){
            listMensagem.add('Limite total de carregamento não informado no produto');
        }
        if(vigenciaInicial == null){
            listMensagem.add('Vigência inicial não informada no orçamento');
        }
        if(vigenciaFinal == null){
            listMensagem.add('Vigência final não informada no orçamento');
        }

        // Verifica se há erro Apresenta o erro
        if(!listMensagem.isEmpty()){
            mensagem = String.join(listMensagem,', ');

            for(RemuneracaoOrcamento__c remuneracaoOrcamento : listRemuneracaoOrcamento){
                if(String.isNotEmpty(mensagem)){
                    remuneracaoOrcamento.addError(mensagem);
                    continue;
                }
            }
            return ;
        }

        // calculo do termo 1
        Decimal termo1 = 0;
        if(remuneracaoOrcamentoAgenciamento != null){

            // Calcula a quantidade de meses entre a vigencia inicial e final
            Integer quantidadeMeses = calcularQuantidadeMesesEntreDatas(vigenciaInicial, vigenciaFinal);

            if(quantidadeMeses != 0 && remuneracaoOrcamentoAgenciamento.Percentual__c != null)
                termo1 = remuneracaoOrcamentoAgenciamento.Percentual__c / quantidadeMeses;
        }

        // calculo do termo 2
        Decimal termo2 = 0;
        Decimal somatoriaPercentuais = 0;
        for(RemuneracaoOrcamento__c remuneracaoOrcamento : listRemuneracaoOrcamentoRestantes)
        {
            if(remuneracaoOrcamento.Percentual__c == null)
                continue;
            somatoriaPercentuais += remuneracaoOrcamento.Percentual__c;
        }


        termo2 = somatoriaPercentuais * (100 - termo1) / 100;
        totalCarregamentoCalculado = termo1 + termo2;

        // Validação final
        if(limiteTotalCarregamento < totalCarregamentoCalculado)
        {
            for(RemuneracaoOrcamento__c remuneracaoOrcamento : listRemuneracaoOrcamento){

                remuneracaoOrcamento.addError('Percentual de carregamento (' + totalCarregamentoCalculado.setScale(2) +
                        ') acima do limite do produto comercial (' + limiteTotalCarregamento.setScale(2) + ')');
            }
        }
    }

    public Integer calcularQuantidadeMesesEntreDatas(Date vigenciaInicial, Date vigenciaFinal){

        Integer quantidadeMeses = vigenciaInicial.monthsBetween(vigenciaFinal);

        Date dataInicialTemp = date.newInstance(vigenciaInicial.year(),vigenciaInicial.month(),vigenciaInicial.day());
        dataInicialTemp = dataInicialTemp.addMonths(quantidadeMeses);

        if(vigenciaFinal.day() > (dataInicialTemp.day() + 1)) quantidadeMeses--;

        return quantidadeMeses;
    }
}