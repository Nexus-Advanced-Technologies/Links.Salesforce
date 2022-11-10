/**
 * @description       : 
 * @author            : ¤ → alessio.marra@nexusat.it
 * @last modified on  : 01-15-2022
 * @last modified by  : §
**/
public with sharing class JunctionRelatedListController {

	public class Wrapper {
		@AuraEnabled public String recordId;
		@AuraEnabled public List<FieldWrapper> fields;
	}

	public class FieldWrapper {
		@AuraEnabled public String apiName;
		@AuraEnabled public String label;
		@AuraEnabled public Object value;
		@AuraEnabled public Boolean required;
		@AuraEnabled public String type;

		public FieldWrapper(Schema.FieldSetMember fieldSetMember, Object value){
			this.apiName = fieldSetMember.getFieldPath();
			this.label = fieldSetMember.getLabel();
			this.required = fieldSetMember.getRequired();
			this.type = fieldSetMember.getSObjectField().getDescribe().getSoapType().name();
			
			this.value = value;
		}
	}

	private static final String QUERY_BASE_TEMPLATE = 'SELECT Id, {0} FROM {1}';
	private static final String QUERY_ADD_CONDITION_TEMPLATE = '{0} WHERE {1} {2} {3}';
	private static final String QUERY_ADD_LIMIT_TEMPLATE = '{0} LIMIT {1}';

	@AuraEnabled(cacheable=true)
	public static List<Wrapper> fetchRecords (
		Id recordId,
		String childRelation,
		String otherParentObjectName,
		String otherParentFieldNameRelation,
		String otherParentFieldSet
	) {
		String objectName = recordId.getSObjectType().getDescribe().getName();

		Map<String, Schema.FieldSetMember> fieldSetMembers = getFieldSet(otherParentObjectName, otherParentFieldSet);
		//System.debug(Json.serializePretty(fieldSetMembers));

		//TODO	aggiungere toLabel() quando il campo è una picklist

		List<String> innerFields = new List<String>();
		for (String variable : fieldSetMembers.keySet()) {
			innerFields.add(otherParentFieldNameRelation + '.' + variable);
		}

		String innerQuery = String.format(QUERY_BASE_TEMPLATE, new List<Object> {
			String.join(innerFields, ', '),
			childRelation
		});
		
		//TODO	Condizione da concatenare alla inner query

		String query = String.format(QUERY_BASE_TEMPLATE, new List<Object> {
			'(' + innerQuery + ')',
			objectName
		});

		query = String.format(QUERY_ADD_CONDITION_TEMPLATE, new List<Object> {
			query,
			'Id',
			'=',
			'\'' + String.escapeSingleQuotes(recordId) + '\''
		});
		
		query = String.format(QUERY_ADD_LIMIT_TEMPLATE, new List<Object> {
			query,
			'1'
		});

		System.debug('¤ query: ' + query);
		SObject result = Database.query(query);
		// System.debug(Json.serializePretty(result));

		Map<String, Object> resultDeserialized = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(result));
		// System.debug(Json.serializePretty(resultDeserialized));

		Map<String, Object> resultRelationDeserialized = (Map<String, Object>) resultDeserialized.get(childRelation);
		// System.debug(Json.serializePretty(resultRelationDeserialized));

		List<Object> childResultsDeserialized = (List<Object>) resultRelationDeserialized.get('records');
		// System.debug(Json.serializePretty(childResultsDeserialized));

		List<Wrapper> wrappers = new List<Wrapper>();
		for (Object variable : childResultsDeserialized) {
			System.debug('¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤');
			Map<String, Object> childDeserialized = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(variable));
			// System.debug(Json.serializePretty(childDeserialized));

			Map<String, Object> parentDeserialized = (Map<String, Object>) childDeserialized.get(otherParentFieldNameRelation);
			// System.debug(Json.serializePretty(parentDeserialized));

			List<FieldWrapper> fieldsWrapper = new List<FieldWrapper>();
			for(String key : parentDeserialized.keySet()) {
				Object value = parentDeserialized.get(key);
				if (!fieldSetMembers.containsKey(key)) {
					continue;
				}
				Schema.FieldSetMember fieldSetMember = fieldSetMembers.get(key);
				FieldWrapper fieldWrapper = new FieldWrapper(fieldSetMember, value);
				fieldsWrapper.add(fieldWrapper);
			}

			Wrapper wrapper = new Wrapper();
			wrapper.recordId = (String) parentDeserialized.get('Id');
			wrapper.fields = fieldsWrapper;
			// System.debug(Json.serializePretty(wrapper));
			wrappers.add(wrapper);
		}

		// System.debug(childResultsDeserialized);
		//System.debug(JSON.serializePretty(result.OpportunityDocumentsAlyante__r));
		
		
		// system.debug( 'values are ' + listValues ); 
		// List < String > strList = listValues.split( '-' ); 
		// system.debug( 'values are ' + strList ); 
		// RelatedListWrapper objWrap = new RelatedListWrapper();
		 
		// if ( strList.size() == 8 ) { 
		 
		//     String recordId = strList.get( 0 ); 
		//     String objectName = strList.get( 1 ); 
		//     String parentFieldAPIName = strList.get( 2 ); 
		//     String fieldName = strList.get( 3 ); 
		//     String fieldValue = strList.get( 4 ); 
		//     String filterType = strList.get( 5 ); 
		//     String operator = strList.get( 6 ); 
		//     String fieldsList = strList.get( 7 ); 
			 
		//     String strSOQL = 'SELECT Id';
		//     strSOQL += ', ' + fieldsList;
		//     String filter = ' FROM ' + objectName + ' WHERE ' + parentFieldAPIName + ' = \'' + recordId + '\' AND '; 
		//     if ( filterType == 'String' )     
		//         filter += fieldName + ' = \'' + fieldValue + '\''; 
		//     else if ( filterType == 'Boolean' )     
		//         filter += fieldName + ' = ' + fieldValue; 
		//     else 
		//         filter += fieldName + ' ' + operator + ' ' + fieldValue; 
		//     String strCountSOQL = ' SELECT COUNT() ' + filter;
		//     objWrap.recordCount = Database.countQuery( strCountSOQL );
		//     strSOQL += filter + ' LIMIT 3';     
		//     objWrap.listRecords = Database.query( strSOQL ); 
			 
		// }   
		// return objWrap;
		return wrappers;
	}
	
	private static Map<String, Schema.FieldSetMember> getFieldSet(
		String objectName,
		String fieldSetName
	) {
		Map<String, Schema.FieldSetMember> fieldSetMemberMap = new Map<String, Schema.FieldSetMember>();
		Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
		Schema.SObjectType sObjectTypeObj = globalDescribeMap.get(objectName);
		Schema.DescribeSObjectResult describeSObjectResultObj = sObjectTypeObj.getDescribe();
		Schema.FieldSet fieldSetObj = describeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
		List<Schema.FieldSetMember> fieldSetMemberList = fieldSetObj.getFields();
		for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList)
		{
			fieldSetMemberMap.put(fieldSetMemberObj.getFieldPath(), fieldSetMemberObj);
			/*
			system.debug('API Name ====>' + fieldSetMemberObj.getFieldPath()); //api name
			system.debug('Label ====>' + fieldSetMemberObj.getLabel());
			system.debug('Required ====>' + fieldSetMemberObj.getRequired());
			system.debug('DbRequired ====>' + fieldSetMemberObj.getDbRequired());
			system.debug('Type ====>' + fieldSetMemberObj.getType());   //type - STRING,PICKLIST
			*/
		}
		return fieldSetMemberMap;
	}
}