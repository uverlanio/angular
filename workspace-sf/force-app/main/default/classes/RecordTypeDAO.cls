public class RecordTypeDAO 
{
	private static final RecordTypeDAO instance = new RecordTypeDAO();
	public static RecordTypeDAO getInstance() { return instance; }
	private RecordTypeDAO() { }

	public List<RecordType> listar() 
	{
		return [
			SELECT
				Id,
				Name,
				DeveloperName,
				SobjectType
			FROM
				RecordType
		];
	}

	public List<RecordType> getListRecordTypeBySobject(String sobjectType) 
	{
		return 
		[
			SELECT 
				Id,
				Name,
				SobjectType,
				DeveloperName
			FROM 
				RecordType
			// WHERE 
			// 	SobjectType = :sobjectType
		];
	}
}