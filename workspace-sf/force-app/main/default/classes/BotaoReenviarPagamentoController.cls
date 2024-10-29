/**
 * Created by Alessandro Ponte on 19/09/2018.
 */

public class BotaoReenviarPagamentoController {
	private static PagamentoBO bo = PagamentoBO.getInstance();

    /*@AuraEnabled
    public static String ativarParceiro(String idParceiro){
        return JSON.serialize(bo.ativarParceiro(Id.valueOf(idParceiro)));
    }*/
    
    //INICIO | PLV-2376-29
    @AuraEnabled
    public static String reenviarPagamento(String idPagamento){
    	return JSON.serialize(bo.reenviarPagamento(idPagamento));
    }
    //FIM | PLV-2376-29
}