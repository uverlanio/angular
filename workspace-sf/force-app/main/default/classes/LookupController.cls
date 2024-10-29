/**
 * Created by Alessndro Ponte on 11/06/2018.
 */

public with sharing class LookupController {

  @AuraEnabled
  public static List<Account> searchText(String searchText, String sObjectName, List<String> listFields, Map<String,String> mapFieldsController) {

    if(listFields == null || listFields.isEmpty()) listFields = new List<String>();
    String fieldString = 'Id,Name';

    List<String> listSobjectType = new List<String>();
    listSobjectType.add(sObjectName);

    List<Schema.DescribeSObjectResult> lDescribeSObjectResults = Schema.describeSObjects(listSobjectType);
    Map<String, Schema.SObjectField> mapObjectFields = lDescribeSObjectResults[0].SObjectType.getDescribe().fields.getMap();

    // Declara variavel para as clausulas WHERE
    String conditions = '';
    Integer count = 0;

    // Verifica se existe condicoes e se o campo existe
    if(!mapFieldsController.isEmpty()) {

      for (String apiFieldController : mapFieldsController.keySet()) {
        Schema.SObjectField sObjectField = mapObjectFields.get(apiFieldController);
        if(sObjectField == null) continue;

        String value = mapFieldsController.get(apiFieldController);
        if(String.isBlank(value)) continue;

        conditions += (count == 0) ? ' WHERE ' : ' AND ';
        conditions += apiFieldController + ' = \'' + value + '\'';
        count++;
      }
    }



    for(String field : listFields) {
      Schema.SObjectField sObjectField = mapObjectFields.get(field);
      if(sObjectField == null) continue;
      fieldString += ',' + field;
    }

    String soslString = 'FIND \'' +
        String.escapeSingleQuotes(searchText) + '\' IN ALL FIELDS RETURNING ' + sObjectName + '(' + fieldString + '' + conditions + ')';

    System.debug('SOSL Pesquisa =============== ' + soslString);

    List<sObject> listSObjects = new List<sObject>();

    List<List<SObject>> results = Search.query(soslString);
    for (List<SObject> sobjs : results) {
      for (SObject sobj : sobjs) {
        listSObjects.add(sobj);
      }
    }
    return listSObjects;
  }

}