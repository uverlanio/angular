/**
 * Created by Alessandro Ponte on 19/09/2018.
 */

public class BotaoAtivarParceiroController {

    private static ParceiroBO bo = ParceiroBO.getInstance();

    @AuraEnabled
    public static String ativarParceiro(String idParceiro){
        return JSON.serialize(bo.ativarParceiro(Id.valueOf(idParceiro)));
    }

}