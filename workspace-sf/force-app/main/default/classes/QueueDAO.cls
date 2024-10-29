/**
 * Queue DAO
 * @author Fernando Barcellos @ 20/07/2018
 *
 **/
public with sharing class QueueDAO {
	public static final QueueDAO instance = new QueueDAO();
  	public static QueueDAO getInstance() {
    	return instance;
	}

	public Group buscarFilaPorNome(String name) {
		List<Group> lstGroup = new List<Group>();

		lstGroup = [SELECT	Id,
							Type,
							Name
					FROM 	Group
					WHERE 	DeveloperName = :name
					AND Type = 'Queue'];
		if (lstGroup.size() > 0 )
			return lstGroup.get(0);
		else
			return null;
	}
}