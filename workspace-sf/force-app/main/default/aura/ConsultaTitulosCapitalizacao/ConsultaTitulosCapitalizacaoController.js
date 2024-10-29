/**
 * Created by Alessandro Ponte on 17/12/2018.
 */
({
    doInit : function(component, event, helper) {

        // Inicializa o atributo consultarEstoqueTO
        let consultarEstoqueTO = component.get('v.consultarEstoqueTO');
        component.set('v.consultarEstoqueTO',JSON.parse(consultarEstoqueTO));

        // Busca e popula o select de parceiros
        let inputParceiro = component.find("InputSelectParceiro");
        helper.buscarParceiros( component, inputParceiro );

    },

    consultarEstoqueController: function (component, event, helper) {

        if(helper.validar(component)){
            helper.consultarEstoqueHelper(component);
        }

    },

    alterouParceiro : function (component, event, helper) {

        // Recupera o valor selecionado
        let parceiroSelecionado = event.getSource().get('v.value');
        let InputSelectProdutoParceiro = component.find('InputSelectProdutoParceiro');

        let mapParceiros = component.get('v.mapParceiros');
        if(parceiroSelecionado || parceiroSelecionado != ''){
            let parceiro = mapParceiros[parceiroSelecionado];
            let listProdutosParceiro = parceiro.ProdutosParceiro__r;

            // Verifica se o parceiro tem produto
            if(listProdutosParceiro && listProdutosParceiro.length > 0){

                let mapProdutosParceiro = helper.gerarMapa(listProdutosParceiro);
                helper.popularSelectAPartirMap(component, InputSelectProdutoParceiro, mapProdutosParceiro, 'produtosParceiro');

            }else{
                helper.popularSelectAPartirMap(component, InputSelectProdutoParceiro, undefined);
            }
        }else{
            helper.popularSelectAPartirMap(component, InputSelectProdutoParceiro, undefined);
        }




    }
})