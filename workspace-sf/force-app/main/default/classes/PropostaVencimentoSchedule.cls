// PLV-4337 - INICIO
/*
*  @author: Squad Avanxo 
*  @description: Schedule Batch para vencer as propostas
*/
global class PropostaVencimentoSchedule implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful, Schedulable {

    global final String query;
    global final String className;
    
    // Construtor padrão
    global PropostaVencimentoSchedule() {
        if( Test.isRunningTest() )  { this( '0 0 23 * * ?', 'testSchedule' ); }
        if( !Test.isRunningTest() ) { this( '0 0 1 * * ? *', 'Proposta Vencimento Batch' ); }
    }
    
    // Construtor criado para receber a data como parâmetro
    global PropostaVencimentoSchedule( String dataExecucao, String nomeSchedule ) {
        className = 'PropostaVencimentoSchedule';
        
        query = ''
            + 'SELECT Id, Status, DataVencimento__c, Massificados__c '
            + 'FROM Quote '
            + 'WHERE Status IN (\'Em criação\') '
            + 'AND DataVencimento__c < TODAY '
            + 'AND Massificados__c = false';
        
        System.schedule( nomeSchedule, dataExecucao, this );
    }
    
    // Método execute do schedule
    global void execute( SchedulableContext SC ) {
        System.debug( className + ' - Entrou no EXECUTE do Schedule.' );
        
        database.executebatch( this );
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
        List< Quote > listaProposta2Update = new List< Quote >();
        for( Quote proposta: listaProposta ) {
            proposta.Status = 'Vencida';
            listaProposta2Update.add( proposta );
        }
        
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