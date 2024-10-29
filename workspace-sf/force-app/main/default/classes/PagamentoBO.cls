/**
 * Created by Fabio Rente on 17/04/2019.
 */

public class PagamentoBO {
	private static final PagamentoBO instancia = new PagamentoBO();
	private static PagamentoDAO dao = PagamentoDAO.getInstance();

	public PagamentoBO() {}

	public static PagamentoBO getInstance(){
        return instancia;
    }

    //INICIO | PLV-2376-29
    public RetornoAcaoBotaoTO reenviarPagamento(String pagamentoId) {

        // variaveis
        RetornoAcaoBotaoTO retorno = new RetornoAcaoBotaoTO();
        List<Id> idPagamentos = new List<Id>();
        
        if(String.isNotBlank(pagamentoId))
            idPagamentos.add(Id.valueOf(pagamentoId));

        List<Pagamento__x> listPagamento = dao.buscarPagamentosPorIds(idPagamentos);
        //FIM | PLV-2376-29

        // Recupera dados do pagamento
        Pagamento__x pagamento = listPagamento[0];

        if(pagamento.Status__c != 'ERRO'){
            retorno.tipo = RetornoAcaoBotaoTO.WARNING;
            retorno.mensagens.add('Pagamento não pode ser reenviado, pois o Status não esta como "Devolvido"!');
        }else{
            pagamento.Status__c = 'EM REPROCESSAMENTO';
            try {
                
                //INICIO | PLV-2376-29
                // Atualiza tb pagamento
                if(!Test.isRunningTest())
                    Database.updateAsync(pagamento);

                // Efetua o Controle de Integração (25) - Cria um registro com Status - Pendente 
                CriarControleIntegracao(pagamento);
                //FIM | PLV-2376-29

                retorno.tipo = RetornoAcaoBotaoTO.SUCCESS;
                retorno.mensagens.add('Pagamento reenviado com sucesso!');
            }catch (Exception e){
                retorno.tipo = RetornoAcaoBotaoTO.ERROR;
                retorno.mensagens.add('Erro ao tentar reenviar o pagamento!');
                retorno.mensagens.add(e.getMessage());
            }
        }

        return retorno;
    }

    //INICIO | PLV-2376-29
    private void CriarControleIntegracao(Pagamento__x pagamento)
    {
        ControleIntegracao__c log = new ControleIntegracao__c();

        log.IdExterno__c = String.valueOf(pagamento.Id__c);
        log.CodigoIntegracao__c     = '25';
        log.DataCriacaoRegistro__c  = Date.today();
        // INICIO | PLV-2376-28-ajustes
        log.IdObjeto__c = String.ValueOf(pagamento.Id__c);
        // FIM | PLV-2376-28-ajustes
        log.Status__c               = 'Pendente';

        insert log;

        System.debug('Gravou Controle Integração Pagamento');

    }
    //FIM | PLV-2376-29
}