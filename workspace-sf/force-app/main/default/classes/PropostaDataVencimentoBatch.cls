// PLV-4337 - INICIO
/*
*  @author: Squad Avanxo 
*  @description: Batch para setar as datas de vencimento das propostas
*/
global class PropostaDataVencimentoBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {

    // Chamada na janela anônima
    // Database.executebatch( new PropostaDataVencimentoBatch(), 50 );

    global final String query;
    global final String className;
    
    // Construtor padrão
    global PropostaDataVencimentoBatch() {
        className = 'PropostaDataVencimentoBatch';

        query = ''
            + 'SELECT Id, Status, DataVencimento__c, Massificados__c, OpportunityId '
            + 'FROM Quote '
            + 'WHERE Status IN (\'Em criação\') '
            + 'AND DataVencimento__c = null '
            + 'AND Massificados__c = false '
            + 'ORDER BY OpportunityId';
    }

    // Método start do batch
    global Database.QueryLocator start( Database.BatchableContext BC ){
        System.debug( className + ' - Entrou no START do Batch.' );
        
        return Database.getQueryLocator( query );
    }
    
    // Método execute do batch
    global void execute( Database.BatchableContext BC, List< SObject > scope ) {
        System.debug( className + ' - Entrou no EXECUTE do Batch.' );
        
        List< Quote > listaProposta = ( List< Quote > ) scope;
        System.debug( className + ' - listaProposta.size(): ' + listaProposta.size() );
        
        List< Quote > listaProposta2Update = new List< Quote >();
        Map< Id, Date > mapaOrcamentoIdDataVencimento = new Map< Id, Date >();
        Integer fezSelect = 0;
        Integer usouMap = 0;
        Date nd = Date.newinstance( 1900, 1, 1 );
        for( Quote proposta: listaProposta ) {
            Date dataVencimento = nd;
            Id orcamentoId = proposta.OpportunityId;
            if( mapaOrcamentoIdDataVencimento.containsKey( orcamentoId ) ) {
                usouMap++;
                dataVencimento = mapaOrcamentoIdDataVencimento.get( orcamentoId );
            } else {
                fezSelect++;
                List< Opportunity > lista = [ SELECT Id, DataVencimento__c, Produto__c, CreatedDate FROM Opportunity WHERE Id =: orcamentoId LIMIT 1 ];
                if( lista.size() == 1 ) {
                    Opportunity orcamento = lista[0];
                    if( orcamento.DataVencimento__c != null ) {
               			Datetime dt = orcamento.DataVencimento__c;
                		Date data = Date.newinstance( dt.year(), dt.month(), dt.day() );
                        dataVencimento = data;
                    } else {
                        List< ParametroVigencia__c > listaPV = [ SELECT ValidadeOrcamento__c FROM ParametroVigencia__c WHERE Produto__c =: orcamento.Produto__c LIMIT 1 ];
                        if ( listaPV.size() == 1 ) {
                            ParametroVigencia__c pv = listaPV[0];
                            if ( pv.ValidadeOrcamento__c != null ) {
                                Datetime dt = orcamento.CreatedDate;
                                Date data = Date.newinstance( dt.year(), dt.month(), dt.day() );
                                dataVencimento = data.addDays( Integer.valueOf( pv.ValidadeOrcamento__c ) );
                                System.debug( 'Data de vencimento setada: ' + proposta.DataVencimento__c );
                            }
                        }
                    }
                }
                mapaOrcamentoIdDataVencimento.put( orcamentoId, dataVencimento );
            }

            if( dataVencimento == nd ) {
                System.debug( className + ' - proposta com problema: ' + proposta.Id );
            } else {
                proposta.DataVencimento__c = dataVencimento;
            	listaProposta2Update.add( proposta );
            }
        }
        
        System.debug( className + ' - fezSelect: ' + fezSelect );
        System.debug( className + ' - usouMap: ' + usouMap );
        System.debug( className + ' - listaProposta2Update.size(): ' + listaProposta2Update.size() );
        
        Database.SaveResult[] listaSaveResult = Database.update( listaProposta2Update );
        
        for( Database.SaveResult sr : listaSaveResult ) {
            if( !sr.isSuccess() ) {
                System.debug( className + ' - Lista de erros: ' + sr.getErrors() );
            }
        }
    }
    
    // Método finish do batch
    global void finish( Database.BatchableContext BC ) {
        System.debug( className + ' - Entrou no FINISH do Batch.' );
    }
}
// PLV-4337 - FIM