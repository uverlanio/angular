//INICIO | PLV-2233-27 
/*
*  @author Everymind - Sprint 27
*  @Descrição: manipulação de dados referentes ao objeto nota fiscal
*/
public with sharing class NotaFiscalBO {
    
    public NotaFiscalBO() {}
    private static final NotaFiscalBO instancia = new NotaFiscalBO();
    public static NotaFiscalBO getInstance(){ return instancia; }

    /*
    *  @author Everymind - Sprint 27
    *  @Descrição: Atualiza obj pagamento de acordo com as informações da NF
    */
    @future(callout=true)
    public static void atualizaPagamento(String strListNew){
        PagamentoDAO daoPgto = PagamentoDAO.getInstance();
        List<NotaFiscal__c> listaNew= (List<NotaFiscal__c>)JSON.deserialize(strListNew, List<NotaFiscal__c>.class);
        List<Integer> setChavePgto = new List<Integer>();
        List<Pagamento__x> lstPagamento = new List<Pagamento__x>();
        List<Pagamento__x> lstPagamentoUpdate = new List<Pagamento__x>();
        Map<Integer, NotaFiscal__c> mapNfs = new Map<Integer, NotaFiscal__c>();
        //INICIO | PLV-2376-29
        List<ControleIntegracao__c> lstLog = new List<ControleIntegracao__c>();
        //FIM | PLV-2376-29
        
        // monta chave de busca p/ obter os pagamentos relacionados as notas fiscais
        System.debug('monta chave de busca p/ obter os pagamentos relacionados as notas fiscais'); 
        for(NotaFiscal__c nf: listaNew){
            //PLV-3918-FIX4 - INICIO
            if(String.isNotBlank(nf.Pagamento__c)){
                if(!setChavePgto.contains(Integer.valueOf(nf.Pagamento__c))){
                    setChavePgto.add(Integer.valueOf(nf.Pagamento__c));
                    mapNfs.put(Integer.valueOf(nf.Pagamento__c), nf);
                }
            }
             //PLV-3918-FIX4 - FIM
        }
        
        // lista os pagamentos relacionados
        System.debug(JSON.serialize(setChavePgto));
        lstPagamento = daoPgto.buscarPagamentosPorIdcs(setChavePgto);
        System.debug(JSON.serialize(lstPagamento));

        if(!lstPagamento.isEmpty()){
            // varre osregistros de pgt e atualiza o status pela nf
            for(Pagamento__x pgto : lstPagamento){

                NotaFiscal__c nf = mapNfs.get(Integer.valueOf(pgto.Id__c));
                System.debug('atualizaPagamento >> nf' + nf);
            
                if(nf.StatusAprovacao__c == 'Pendente')
                    pgto.Status__c = 'PAGAMENTO EM APROVAÇÃO';
                //INICIO | PLV-2376-29
                else if(nf.StatusAprovacao__c == 'Aprovado'){
                    pgto.Status__c = 'PAGAMENTO LIBERADO';
                   
                    // cria log na controle integração quando status do pagamento for alterado p/ PAGAMENTO LIBERADO
                    ControleIntegracao__c log = new ControleIntegracao__c();
                    log.CodigoIntegracao__c = '25';
                    log.DataCriacaoRegistro__c = Date.today();
                    // INICIO | PLV-2376-28-ajustes
                    log.IdObjeto__c = String.ValueOf(pgto.Id__c);
                    // FIM | PLV-2376-28-ajustes
                    log.Status__c = 'Pendente';

                    lstLog.add(log);
                }
                //FIM | PLV-2376-29
                    
                else if(nf.StatusAprovacao__c == 'Reprovado')
                    pgto.Status__c = 'PAGAMENTO REJEITADO';
                    
                lstPagamentoUpdate.add(pgto);
            }
        }
        
        // Atualiza tb pagamento
        if(!Test.isRunningTest()){
            if (lstPagamento.size() > 0){
                System.debug('lstPagamentoUpdate >> ' + JSON.serialize(lstPagamentoUpdate));
                Database.updateAsync(lstPagamentoUpdate);
                //INICIO | PLV-2376-29
                // insere o registro de log

                Insert lstLog;
                //FIM | PLV-2376-29
            }

        }
    }
}
//FIM | PLV-2233-27