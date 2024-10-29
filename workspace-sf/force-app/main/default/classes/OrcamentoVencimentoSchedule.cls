//PLV-2673 - Início
/**
 * @author Daniel Zampieri
 * @version 1.0
 * @date 2019-09-10
 * @description Schedule Batch para vencer as oportunidades
 */
global class OrcamentoVencimentoSchedule implements Database.Batchable<SObject>,Database.AllowsCallouts, Database.Stateful, Schedulable {

	global final String query;

    global List<Error> lErros = new List<Error>();

    //PLV-2673-Mochila - INICIO - Fix para ajustar a logica e classe de teste
	//Construtor padrão
	global OrcamentoVencimentoSchedule() {

		this('0 0 1 * * ? *','Orçamento Vencimento Batch');
 	}

	//Construtor criado para receber a data como parâmetro
	global OrcamentoVencimentoSchedule(String dataExecucao, String nomeSchedule) {

        query = 'SELECT Id, StageName, DataVencimento__c '+
                +'FROM Opportunity '+
                +'WHERE StageName IN  (\'Disponível para contratação\', \'Em criação\') '+
                +'AND DataVencimento__c < TODAY';
        
 		system.schedule(nomeSchedule, dataExecucao, this);
     }
     //PLV-2673-Mochila - FIM

	//Método execute do schedule
	global void execute(SchedulableContext SC) {
        system.debug('Entrou no EXECUTE do Schedule.');
		database.executebatch(this);

    }

	//Método start do batch
 	global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('Entrou no START do Batch.');
 		return Database.getQueryLocator(query);
 	}

	//Método execute do batch
 	global void execute(Database.BatchableContext BC, List<SObject> scope) {
        system.debug('Entrou no EXECUTE do Batch.');
        List<Opportunity> lOrcamento = (List<Opportunity>)scope;
        List<Opportunity> lOrcamento2Update = new List<Opportunity>();
        for(Opportunity orcamento: lOrcamento){
            orcamento.StageName = 'Vencido';
            lOrcamento2Update.add(orcamento);
        }

        Database.SaveResult[] lstSr = Database.update(lOrcamento2Update);
 
        for(Database.SaveResult sr : lstSr){
            if(!sr.isSuccess()){
                System.debug('Lista de Erros '+ sr.getErrors());
                //lErros.add(new Error(sr.getId(), sr.getErrors()));
            }
        }

 	}

	//Método finish do batch
 	global void finish(Database.BatchableContext BC) {
        system.debug('Entrou no FINISH do Batch.');
        //Serializar a lista de erros e mandar por e-mail
        /*if(!lErros.isEmpty()){
            List<Id> idAdministradores = new List<Id>();
            List<User> administradores = [SELECT Id FROM User WHERE Profile.Name = 'Administrador do sistema'];
            for(User user: administradores){
                idAdministradores.add(user.Id);
            }
            Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage();
            mail.setTargetObjectIds(idAdministradores);
            mail.subject = 'Lista de Erros - Orçamento Vencimento Batch';
            mail.setDescription(JSON.serialize(lErros));
            Messaging.sendEmail(new Messaging.MassEmailMessage[] { mail });
        }*/
    }

    public class Error {

        String id {get;set;}
        List<Database.Error> MensagemErros {get;set;}

        public Error(Id id, List<Database.Error> MensagemErros){
            this.id = id;
            this.MensagemErros = MensagemErros;
        }
    }
}
//PLV-2673 - Fim