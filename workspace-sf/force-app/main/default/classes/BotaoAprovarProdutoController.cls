/**
 * Created by Alessandro Ponte on 25/10/2018.
 */

public class BotaoAprovarProdutoController {

    private static ProductBO bo = ProductBO.getInstance();

    @AuraEnabled
    public static String aprovarProduto(String idProduto){
        return JSON.serialize(bo.aprovarProduto(Id.valueOf(idProduto)));
    }
}