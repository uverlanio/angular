/**
 * @author Isabela (Globant)
 * @date 2019-09-26
 * @description QueueableQTD (Custom Setting) Factory Class
 * Classe criada por conta da história PLV-3460
 */
@isTest
public class QueueableQTDFactory extends SObjectFactory{
	private static QueueableQTD__c staticRecord;
	private static QueueableQTD__c getRecordStatic(String nome, Integer qtd){
		if(staticRecord == null){
			staticRecord = new QueueableQTD__c(Quantidade__c = qtd, Name = nome);
		}
		return staticRecord;
	}
	public QueueableQTDFactory(){
		this('QueueableSendContract', 20); //PLV-3460 Fix 5 - INICIO/FIM
	}
	public QueueableQTDFactory(String nome, Integer qtd) {
		super(getRecordStatic(nome,qtd));
	}
}