/**
 * @author Renato Matheus Simião
 * @version 1.0
 * @date 2019-08-26
 * @description Helper class for Triggers
 */
 // INICIO - PLV-2610
public with sharing class TriggerHelper {
	// PLV-3316 Inicio
	private static List<SObject> tNew {

		get {return (List<SObject>) Trigger.new;}
		set;
	}

	/*private static Map<Id, SObject> tNewMap {

		get {return (Map<Id, SObject>) Trigger.newMap;}
		set;
	}

	private static List<SObject> tOld {

		get {return (List<SObject>) Trigger.old;}
		set;
	}*/

	private static Map<Id, SObject> tOldMap {

		get {return (Map<Id, SObject>) Trigger.oldMap;}
		set;
	}

    public static Boolean isChanged(SObject pSObject, String pField) {
		System.debug('pSObject1 ' + pSObject);
        System.debug('pField1 ' + pField);
		return isChanged(pSObject, new Set<String>{pField});
	}

	public static Boolean isChanged(SObject pSObject, Set<String> psField) {
		System.debug('pSObject2 ' + pSObject);
        System.debug('psField2 ' + psField);
        System.debug('tOldMap ' + tOldMap);
		for (String field : psField) {

			SObject sObjectOld = Trigger.isUpdate ? tOldMap.get(pSObject.Id) : null;

			if (pSObject.get(field) != null &&
				(Trigger.isInsert ||
				(Trigger.isUpdate && pSObject.get(field) != sObjectOld.get(field))))
				return true;
		}

		return false;
	}
	
	public static void validateUnique(String pSObjectName) {

		validateUnique(pSObjectName, 'CompositeKey__c');
	}

	public static void validateUnique(String pSObjectName, String pFieldCK) {

    	// store the valid records
    	List<SObject> lRecords = new List<SObject>();
    	// store the composite keys
    	Set<String> sCompositeKeys = new Set<String>();

    	for (SObject record : tNew) {

    		if (Trigger.isInsert ||
    			(String) record.get(pFieldCK) != (String) tOldMap.get(record.Id).get(pFieldCK)) {

    			// If have duplicate composite key when load bulk records
                if (sCompositeKeys.contains((String) record.get(pFieldCK))) {
                    record.addError('Registro duplicado na própria carga ('+pFieldCK+'): '+record.get(pFieldCK));
                    //Duplicate composite key has been found when load bulk records!
                } else {
                    lRecords.add(record);
                    sCompositeKeys.add((String) record.get(pFieldCK));
                }
    		} 
    	}

    	if (lRecords.isEmpty() || sCompositeKeys.isEmpty()) return;
    	// store the composite keys from the database
    	Set<String> sCompositeKeysDB = new Set<String>();

    	String soql = 'SELECT Id, '+pFieldCK+
                       ' FROM '+pSObjectName+
                      ' WHERE '+pFieldCK+' IN :sCompositeKeys'+
                      '   AND Id NOT IN :lRecords';

        //Database.query(StringHelper.soqlReplaceSet(soql, ':sCompositeKeys', sCompositeKeys))
    	for (SObject record : Database.query(soql))
            sCompositeKeysDB.add((String) record.get(pFieldCK));

        if (sCompositeKeysDB.isEmpty()) return;

    	for (SObject record : lRecords) {

    		// if have a composite key duplicate compared to the database
            if (sCompositeKeysDB.contains((String) record.get(pFieldCK)))
                record.addError('Registro duplicador no banco de dados ('+pFieldCK+'): '+record.get(pFieldCK));
                //'Duplicate composite key has been found when insert a new record!'
    	}
    }
	// PLV-3316 FIM
}
 // FIM - PLV-2610