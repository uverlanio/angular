/**
 * @author AVX - Daniel Zampieri
 * @date 2019-02-27
 * @description Framework to provide functionality in test class
 */
public abstract class SObjectFactory {

	public Integer DEFAULT_BULK_RECORDS = 20;
	public String FIELD_INTERATOR = 'Name';

	public List<SObject> LIST_SOBJECT_FIELD_INTERATOR;

	private SObject record {get;set;}
	private List<SObject> lRecord {get;set;}

	public SObjectFactory(SObject pRecord){
		record = pRecord;
	}

	public void setReecord(SObject pRecord){
		record = pRecord;
	}

	public SObject getRecord(){
		return record;
	}

	public SObject cloneRecord(){
		return record.clone();
	}

	public virtual SObject createRecord(){
		if(record.id == null){
			insert record;
		}
		return record;
	}

	public List<SObject> getRecords(){

		if(lRecord == null){

			lRecord = new List<SObject>();

			for(Integer i = 0; i < DEFAULT_BULK_RECORDS; i++){

				SObject recordCloned = record.clone();

				if(LIST_SOBJECT_FIELD_INTERATOR == null){
					recordCloned.put(FIELD_INTERATOR, record.get(FIELD_INTERATOR) + ' ' + i);
				}else{
					recordCloned.put(FIELD_INTERATOR, LIST_SOBJECT_FIELD_INTERATOR.get(i).id);
				}

				lRecord.add(recordCloned);	  
			}
		}
		return lRecord;
	}

	public List<SObject> createRecords(){

		lRecord = getRecords();

		if(!lRecord.isEmpty() && lRecord.get(0).id == null){
			insert lRecord;
		}
		return lRecord;
	}
}