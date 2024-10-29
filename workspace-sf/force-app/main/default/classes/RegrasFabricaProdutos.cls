/**************************************************************************************************************************************************************************
 * 
 *  Classe responsável pelas regras em comum que vários objetos possuem referentes a Fabrica de produtos.
 *
 **************************************************************************************************************************************************************************/
public class RegrasFabricaProdutos {    

    /**
     * Atribui tipo de registro comercial para os objetos filhos de produto, se estiver vinculado a um produto comercial
     *
     */
    public static void vincularTipoRegistroComercialFilhoProduto(List<SObject> registros, String objeto){
        Set<Id> produtosIds = new Set<Id>();
        Map<Id, Id> produtoTipoRegistroObjeto = new Map<Id, Id>();
        Id tipoRegistroObjetoTecnica = RecordTypeBO.buscarTipoRegistro(objeto, 'ProdutoTecnico').Id;
        Id tipoRegistroObjetoComercial = RecordTypeBO.buscarTipoRegistro(objeto, 'ProdutoComercial').Id;
        Id tipoRegistroProdutoComercial = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id;
        
        //Busca os produtos afim de decobrir o tipo de registro
        for(SObject registro : registros){
            produtosIds.add((Id)registro.get('Produto__c'));
        }

        //Busca os produtos afim de decobrir o tipo de registro
        for(Product2 produto : ProductBO.getInstance().buscarProdutos(produtosIds, false)){
            Id tipoRegistroObjeto = produto.RecordTypeId == tipoRegistroProdutoComercial ? tipoRegistroObjetoComercial : tipoRegistroObjetoTecnica;
            produtoTipoRegistroObjeto.put(produto.Id, tipoRegistroObjeto);
        }

        //Realiza atribuição de tipo de registro
        for(SObject registro : registros){
            registro.put('RecordTypeId', produtoTipoRegistroObjeto.get((Id)registro.get('Produto__c')));
        }
    }

    /**
     * Atribui tipo de registro comercial para os objetos filhos de garantia do produto, se estiver vinculado a um produto comercial
     *
     */
    public static void vincularTipoRegistroComercialFilhoGarantiaProduto(List<SObject> registros, String objeto){
        Set<Id> garantiasIds = new Set<Id>();
        Map<Id, Id> garantiaProdutoTipoRegistroObjeto = new Map<Id, Id>();
        Id tipoRegistroObjetoTecnica = RecordTypeBO.buscarTipoRegistro(objeto, 'ProdutoTecnico').Id;
        Id tipoRegistroObjetoComercial = RecordTypeBO.buscarTipoRegistro(objeto, 'ProdutoComercial').Id;
        Id tipoRegistroGarantiaProdutoComercial = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id;
        
        //Busca os produtos afim de decobrir o tipo de registro
        for(SObject registro : registros){
            garantiasIds.add((Id)registro.get('GarantiaProduto__c'));
        }

        //Busca os produtos afim de decobrir o tipo de registro
        for(GarantiaProduto__c garantia : GarantiaProdutoBO.getInstance().buscarGarantiasProduto(garantiasIds, false)){
            Id tipoRegistroObjeto = garantia.RecordTypeId == tipoRegistroGarantiaProdutoComercial ? tipoRegistroObjetoComercial : tipoRegistroObjetoTecnica;
            garantiaProdutoTipoRegistroObjeto.put(garantia.Id, tipoRegistroObjeto);
        }

        //Realiza atribuição de tipo de registro
        for(SObject registro : registros){
            registro.put('RecordTypeId', garantiaProdutoTipoRegistroObjeto.get((Id)registro.get('GarantiaProduto__c')));
        }
    }

    /**
     * Realiza a verificação se um registro pode ser editado ou excluído, de acordo com o que foi configurado no produto técnico
     *
     */ 
    public static void validarPermissaoEdicaoExclusaoItemProdutoComercial(List<SObject> registros, String objeto){
        List<String> objetoTecnicoIds = new List<String>();
        Map<Id, Id> mapTecnicoComercial = new Map<Id, Id>();
        Map<Id, SObject> mapComercial = new Map<Id, SObject>(); 

        //Separa a id dos registros a serem buscados. Considera apenas os registros de produto comercial
        for(SObject registro : registros){
            Id registroTecnicoId = (Id)registro.get(objeto);

            if(registroTecnicoId != null){
                objetoTecnicoIds.add('\'' + registroTecnicoId + '\'');
                mapTecnicoComercial.put(registroTecnicoId, (Id)registro.get('Id'));
                mapComercial.put((Id)registro.get('Id'), registro);
            }
        }       

        if(!objetoTecnicoIds.isEmpty()){
            //Encontra os registros técnicos
            String criterio = 'Id IN ('+ String.join(objetoTecnicoIds, ', ') + ')';
            List<SObject> registrosTecnico = Database.query(Util.gerarQuery(objeto, SObjectSchema.listarCamposEditaveis(objeto), new List<String>{criterio}));

            //Verifica se o registro pode ser editado, de acordo com o que foi configurado no resgistro técnico
            for(SObject registroTec : registrosTecnico){
                if(Boolean.valueOf(registroTec.get('PermiteAlterarProdutoComercial__c')) == false){
                    SObject registroComercial = mapComercial.get(mapTecnicoComercial.get((Id)registroTec.get('Id')));
                    registroComercial.addError('Não é permitido editar ou excluir este registro, devido as configurações no produto técnico.');
                }
            }
        }
    }

    /*********************************************************************************************************
    *
    * Habilita novamente a flag que permite que as regra de limite sejam executadas
    *
    *********************************************************************************************************/
    public static void habilitarValidacaoRegrasProdutoComercial(List<SObject> registros, String objeto, String nomeTriggerHandler){
        List<SObject> registrosAtualizar = new List<SObject>();
        List<String> registrosIds = new List<String>();

        for(SObject registro : registros){
            if(!(Boolean)registro.get('ValidarRegrasProdutoComercial__c')){
                registrosIds.add('\'' + (Id)registro.get('Id') + '\'');
            }
        }

        if(!registrosIds.isEmpty()){
            //Monta o critério da busca dos registros a serem validados
            String criterio = 'Id IN ('+ String.join(registrosIds, ', ') + ')';

            for(SObject registro : Database.query(Util.gerarQuery(objeto, SObjectSchema.listarCamposEditaveis(objeto), new List<String>{criterio}))){
                registro.put('ValidarRegrasProdutoComercial__c', true);
                registrosAtualizar.add(registro);
            }

            if(!registrosAtualizar.isEmpty()){
                TriggerHandler.bypass(nomeTriggerHandler);
                update registrosAtualizar;
            }
        }
    }

    /*********************************************************************************************************
    *
    * Verifica se é possível criação/edição/exclusao dos filhos de Garantia do Produto
    *
    *********************************************************************************************************/
    public static void validarPossibilidadeDMLProdutoComercialFilhosGarantiaProduto(List<SObject> registros, String objeto, String objetoRelacionado){
        Set<Id> garantiaComercialIds = new Set<Id>();
        List<SObject> registrosValidar = new List<SObject>();
        Id recordTypeIdProdutoComercial = RecordTypeBO.buscarTipoRegistro(objeto, 'ProdutoComercial').Id;

        //Verifica se são dependencias de produto comercial e armazena ids da garatia comercial
        for(SObject registro : registros){
            if((Id)registro.get('RecordTypeId') == recordTypeIdProdutoComercial && (Boolean)registro.get('ValidarRegrasProdutoComercial__c')){
                garantiaComercialIds.add((Id)registro.get('GarantiaProduto__c'));
                registrosValidar.add(registro);
            }
        }

        if(!garantiaComercialIds.isEmpty()){
            GarantiaProdutoBO objGarantiaBO = GarantiaProdutoBO.getInstance();
            Set<Id> garantiaTecnicaIds = new Set<Id>();
            Map<Id, List<SObject>> garantiaComercialRegistrosValidarTecnico = new Map<Id, List<SObject>>();
            Map<Id, Id> garantiaTecnicaComercial = new Map<Id, Id>();

            //Encontra as garantias técnicas através das garantias comerciais
            for(GarantiaProduto__c garantiaComercial : objGarantiaBO.buscarGarantiasProduto(garantiaComercialIds, false)){
                garantiaTecnicaIds.add(garantiaComercial.GarantiaProduto__c);


                //Gera map contento a correspondencia de garantia comercial - garantia técnica
                garantiaTecnicaComercial.put(garantiaComercial.GarantiaProduto__c, garantiaComercial.Id);

                //Gera map para conter a relação garantia comercial - Lista de dependente garantias tecnicos correspondentes
                garantiaComercialRegistrosValidarTecnico.put(garantiaComercial.Id, new List<SObject>());
            }

            //Encontra as garantias técnicas. Finaliza a geração de map 
            for(SObject garantiaTecnica : objGarantiaBO.buscarGarantiasProduto(garantiaTecnicaIds, true)){
                Id garantiaComercialId = garantiaTecnicaComercial.get((Id)garantiaTecnica.get('Id'));

                if(garantiaComercialId != null){
                    System.debug(garantiaTecnica);

                    //Preenche o map com as dependencias da garantia técnica
                    List<SObject> listaRelacionada = garantiaTecnica.getSObjects(objetoRelacionado);
                    if(listaRelacionada != null)
                        garantiaComercialRegistrosValidarTecnico.get(garantiaComercialId).addAll(listaRelacionada);
                }
            }

            //Valida itens da trigger, para verificar se eles podem ou não serem criados ou editados
            //PLV-5348 INÍCIO
            // for(SObject registro : registrosValidar){
            //     if(garantiaComercialRegistrosValidarTecnico.containsKey((Id)registro.get('GarantiaProduto__c')) && !garantiaComercialRegistrosValidarTecnico.get((Id)registro.get('GarantiaProduto__c')).isEmpty()){
            //         registro.addError('Não é possível criar, editar ou excluir registros neste objeto. Para este produto comercial, esses dados devem ser iguais ao do técnico.');
            //     }
            // }
            //PLV-5348 FIM
        }
    }

    /*********************************************************************************************************
    *
    * Verifica se um tipo de remuneração está válido em um objeto que seja filho de ProdutoCanal__c
    *
    *********************************************************************************************************/
    public static void validarTipoRemuneracaoFilhosProdutoCanal(List<SObject> registros, String objeto){
        List<String> produtoCanalIds = new List<String>();
        Map<Id, List<SObject>> mapRegistrosValidar = new Map<Id, List<SObject>>();
        
        //Recupera ids de todos os produtos do canal
        for(SObject registro : registros){
            Id idProdutoCanal = (Id)registro.get('ProdutoCanal__c');
            produtoCanalIds.add('\'' + idProdutoCanal + '\'');

            if(!mapRegistrosValidar.containsKey(idProdutoCanal)){
                mapRegistrosValidar.put(idProdutoCanal, new List<SObject>());
            }

            mapRegistrosValidar.get(idProdutoCanal).add(registro);
        }

        //Busca os produtos do canal 
        if(!produtoCanalIds.isEmpty()){
            Set<Id> produtosIds = new Set<Id>();
            Map<Id, Id> mapProdutoCanalProduto = new Map<Id, Id>();
            Map<Id, Id> mapProdutoCanalProduto2 = new Map<Id, Id>();
            Map<Id, Set<Id>> mapProdutoTiposRemuneracao = new Map<Id, Set<Id>>();
            Map<Id, List<RemuneracaoProduto__c>> mapRemuneracaoProdutoParticipacoes = new Map<Id, List<RemuneracaoProduto__c>>();

            String criterio = 'Id IN ('+ String.join(produtoCanalIds, ', ') + ')';

            //Recupera as ids do produto relacionado com o produto do canal. Cria map com a relaçao do produto o canal e o produto
            for(ProdutoCanal__c produtoCanal : Database.query(Util.gerarQuery('ProdutoCanal__c', SObjectSchema.listarCamposEditaveis('ProdutoCanal__c'), new List<String>{criterio}))){
                produtosIds.add(produtoCanal.Produto__c);               
                mapProdutoCanalProduto.put(produtoCanal.Id, produtoCanal.Produto__c);
                mapProdutoCanalProduto2.put(produtoCanal.Produto__c, produtoCanal.Id);
            }

            //Busca as remunerações do produto. Gera a relação do produto com os tipos de remuneração
            for(RemuneracaoProduto__c remuneracaoProduto : RemuneracaoProdutoDAO.getInstance().buscarRemuneracaoProdutoPorProdutos(produtosIds)){
                if(!mapProdutoTiposRemuneracao.containsKey(remuneracaoProduto.Produto__c)){
                    mapProdutoTiposRemuneracao.put(remuneracaoProduto.Produto__c, new Set<Id>());
                }
                mapProdutoTiposRemuneracao.get(remuneracaoProduto.Produto__c).add(remuneracaoProduto.TipoRemuneracao__c);

                Id idProdutoCanal = mapProdutoCanalProduto2.get(remuneracaoProduto.Produto__c);
                if(!mapRemuneracaoProdutoParticipacoes.containsKey(idProdutoCanal)){
                    mapRemuneracaoProdutoParticipacoes.put(idProdutoCanal, new List<RemuneracaoProduto__c>());
                }
                mapRemuneracaoProdutoParticipacoes.get(idProdutoCanal).add(remuneracaoProduto);
            }

            //Realiza as validações se se o tipo de remuneração existe ou não no produto
            for(Id registroId : mapRegistrosValidar.keySet()){
                //Recupera os tipos de remuneracao relacionados ao produto
                Set<Id> tiposRemuneracaoProduto = mapProdutoTiposRemuneracao.get(mapProdutoCanalProduto.get(registroId));

                //Valida os registros
                for(SObject registro : mapRegistrosValidar.get(registroId)){
                    Id tipoRemuneracaoId = (Id)registro.get('TipoRemuneracao__c');
                    Id idProdutoCanal = (Id)registro.get('ProdutoCanal__c');

                    //Verifica se o tipo de remuneracao existe no produto
                    if (tipoRemuneracaoId != null && (tiposRemuneracaoProduto == null || !tiposRemuneracaoProduto.contains(tipoRemuneracaoId))){
                        registro.addError('Este tipo de remuneração não está na remuneração do produto.');
                    }

                    // VALIDACAO DOS PERCENTUAIS DE PARTICIPACAO
                    Decimal valorMinimo;
                    Decimal valorMaximo;
                    List<RemuneracaoProduto__c> remuneracoesProduto = mapRemuneracaoProdutoParticipacoes.get(idProdutoCanal);

                    for (RemuneracaoProduto__c rp : remuneracoesProduto) {
                        if (rp.TipoRemuneracao__c == tipoRemuneracaoId) {
                            valorMinimo = rp.LimiteMinimo__c;
                            valorMaximo = rp.LimiteMaximo__c;
                        }
                    }

                    if(objeto != 'RemuneracaoCanal__c'){
                        Decimal valorParticipacao = (Decimal)registro.get('Participacao__c');
                        
                        //Verifica se o valor da participação está dentro da faixa de valores mínimo e máximo da remuneração do produto
                        if ((valorParticipacao > valorMaximo) || (valorParticipacao < valorMinimo)) {
                            registro.addError('O valor percentual da participação está fora da faixa da remuneração do produto. Mínimo: ' + valorMinimo + ' e máximo: ' + valorMaximo + '.');
                        }
                        // VALIDACAO DOS PERCENTUAIS DE PARTICIPACAO
                    }

                }
            }
        }    
    }
    //PLV-2549 - Avanxo - Inicio - Métodos criados para comparar a garantia relacionada do produto técnico com a garantia relacionada do produto comercial
    public static void validarGarantiaRelacionada (List<GarantiaRelacionada__c> lstGaranRelac){

        Id recordTypeIdProdutoComercial = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id;
        List<GarantiaRelacionada__c> lstGaranComer = [  SELECT  Id, 
                                                                GarantiaProduto__r.Produto__r.ProdutoTecnico__c, 
                                                                GarantiaProduto__r.Garantia__r.Sigla__c, 
                                                                TipoDependencia__c,
                                                                GarantiaRelacionada__r.Garantia__r.Sigla__c,
                                                                Incremento__c,
                                                                Acumulativa__c
                                                        FROM GarantiaRelacionada__c
                                                        WHERE Id IN :lstGaranRelac
                                                        AND GarantiaProduto__r.Produto__r.RecordTypeId = :recordTypeIdProdutoComercial];

        system.debug('Lista Relacionada Comercial: ' + lstGaranComer);
        if(lstGaranComer.isEmpty()) return;

        Set<Id> setIdProdTec = new Set<Id>();

        for(GarantiaRelacionada__c GR : lstGaranComer){
            setIdProdTec.add(GR.GarantiaProduto__r.Produto__r.ProdutoTecnico__c);
        }

        system.debug('Produto Tecnico: ' + setIdProdTec);

        if(setIdProdTec.isEmpty()) return;

        List<GarantiaRelacionada__c> lstGaranTec = [SELECT  GarantiaProduto__r.Garantia__r.Sigla__c, 
                                                            TipoDependencia__c,
                                                            GarantiaRelacionada__r.Garantia__r.Sigla__c,
                                                            Incremento__c,
                                                            Acumulativa__c
                                                    FROM GarantiaRelacionada__c
                                                    WHERE GarantiaProduto__r.Produto__c IN :setIdProdTec];

        system.debug('Lista Relacionada Tecnico: ' + lstGaranTec);

        GarantiaRelacionada__c garantiaComErro = new GarantiaRelacionada__c();

        for(GarantiaRelacionada__c garantiaRelacionadaComer: lstGaranComer){
            // Trazer na tela que está nulo
            if(lstGaranTec.isEmpty()){
                system.debug('ENTROU NO IF DE VAZIO!!!!');
                garantiaComErro = garantiaRelacionadaComer;
                break;
            }
            
            for(GarantiaRelacionada__c garantiaRelacionadaTecnica: lstGaranTec){
                if(!compararCamposGarantias(garantiaRelacionadaComer, garantiaRelacionadaTecnica)){
                    garantiaComErro = garantiaRelacionadaComer;
                    //break;
                }else{
                    garantiaComErro = null;
                    break;
                }
            }
        }

        system.debug('Garantia com erro: ' + garantiaComErro);

        if(garantiaComErro != null ){
            for(GarantiaRelacionada__c erroGarantia: lstGaranRelac){
                system.debug('Retorno do contains: ' + lstGaranRelac.contains(garantiaComErro));
                system.debug('IDs ' + erroGarantia.id + '-' + garantiaComErro.id);
                if(erroGarantia.Id == garantiaComErro.Id){
                    system.debug('Entrou no if do contem');
                    erroGarantia.addError('Os campos da garantia relacionada comercial não condizem com os campos da garantia relacionada técnica');
                }
            }
        }
    }

    public static Boolean compararCamposGarantias(GarantiaRelacionada__c garantiaRelacionadaComer, GarantiaRelacionada__c garantiaRelacionadaTecnica){
        system.debug('Primeira validação: ' + garantiaRelacionadaComer.GarantiaProduto__r.Garantia__r.Sigla__c + ' ' + garantiaRelacionadaTecnica.GarantiaProduto__r.Garantia__r.Sigla__c);
        system.debug('Segunda validação: ' + garantiaRelacionadaComer.TipoDependencia__c + ' ' + garantiaRelacionadaTecnica.TipoDependencia__c);
        system.debug('Terceira validação: ' + garantiaRelacionadaComer.GarantiaRelacionada__r.Garantia__r.Sigla__c + ' ' + garantiaRelacionadaTecnica.GarantiaRelacionada__r.Garantia__r.Sigla__c);
        system.debug('Quarta validação: ' + garantiaRelacionadaComer.Incremento__c + ' ' + garantiaRelacionadaTecnica.Incremento__c);
        system.debug('Quinta validação: ' + garantiaRelacionadaComer.Acumulativa__c + ' ' + garantiaRelacionadaTecnica.Acumulativa__c);
        
        return 
            garantiaRelacionadaComer.GarantiaProduto__r.Garantia__r.Sigla__c == garantiaRelacionadaTecnica.GarantiaProduto__r.Garantia__r.Sigla__c &&
            garantiaRelacionadaComer.TipoDependencia__c == garantiaRelacionadaTecnica.TipoDependencia__c &&
            garantiaRelacionadaComer.GarantiaRelacionada__r.Garantia__r.Sigla__c == garantiaRelacionadaTecnica.GarantiaRelacionada__r.Garantia__r.Sigla__c &&
            garantiaRelacionadaComer.Incremento__c == garantiaRelacionadaTecnica.Incremento__c &&
            garantiaRelacionadaComer.Acumulativa__c == garantiaRelacionadaTecnica.Acumulativa__c;
    }

    //PLV-2549 - Avanxo - Fim
}