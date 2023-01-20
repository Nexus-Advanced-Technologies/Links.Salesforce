/**
 * @description       : 
 * @author            : §
 * @group             : 
 * @last modified on  : 11/10/2022
 * @last modified by  : manolo.giannotta@nexusat.it
**/
public class OnDocumentAlyanteTriggerHelper {
	
	public static void lockRecordsByRecordTypeDeveloperName(List<DocumentAlyante__c> triggerNew, String recordTypeDeveloperName) {
		Id rtId = Schema.SObjectType.DocumentAlyante__c.getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();
		
		List<DocumentAlyante__c> documentsToLock = new List<DocumentAlyante__c>();
		
		for (DocumentAlyante__c document : triggerNew){
			if(document.RecordTypeId == rtId) {
				documentsToLock.add(document);
			}
		}
		lockRecords(documentsToLock);

		if(documentsToLock.size() > 0) {
			List<DocumentDetailAlyante__c> documentDetails = [SELECT Id FROM DocumentDetailAlyante__c WHERE Document__c IN :documentsToLock];
			lockRecords(documentDetails);
		}
	}
	
	private static void lockRecords(List<sObject> lockRecords) {
		Approval.LockResult[] lrList = Approval.lock(lockRecords, false);
		
		// Iterate through each returned result
		for(Approval.LockResult lr : lrList) {
			if (lr.isSuccess()) {
				// Operation was successful, so get the ID of the record that was processed
				System.debug('Successfully locked record with ID: ' + lr.getId());
			}
			else {
				// Operation failed, so get all errors
				for(Database.Error err : lr.getErrors()) {
					System.debug('The following error has occurred.');
					System.debug(err.getStatusCode() + ': ' + err.getMessage());
					System.debug('Record fields that affected this error: ' + err.getFields());
				}
			}
		}
	}
	
	// public static void blockModifyRecord (List<DocumentAlyante__c> triggerNew, Map<Id, DocumentAlyante__c> triggerOldMap, String recordTypeDeveloperName) {
		
	// 	if(isAdminUser()) {
	// 		return;
	// 	}
		
	// 	Id rtId = Schema.SObjectType.DocumentAlyante__c.getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();
	// 	Map<Id, List<String>> updatedPreInvoice = changedFields(triggerNew, triggerOldMap, rtId);

	// 	for(DocumentAlyante__c doc : triggerNew) {
	// 		if(updatedPreInvoice.containsKey(doc.Id)) {
	// 			if(updatedPreInvoice.get(doc.Id).size() == 1 && updatedPreInvoice.get(doc.Id).contains('Status__c')) {
	// 				if(doc.Status__c == 'ToBePayed' && triggerOldMap.get(doc.Id).Status__c == 'Emitted') {
	// 					continue;
	// 				} else {
	// 					doc.addError('You can only pass to "To Be Payed" status');
	// 				}
	// 			} else {
	// 				doc.addError('You cannot modify this Document');
	// 			}
	// 		}
	// 	}
	// }

	public static void checkRecordToLock(List<DocumentAlyante__c> triggerNew, Map<Id, DocumentAlyante__c> triggerOldMap, String recordTypeDeveloperName, Set<String> status) {
		Id rtId = Schema.SObjectType.DocumentAlyante__c.getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();
		List<DocumentAlyante__c> documentsToLock = new List<DocumentAlyante__c>();

		for(DocumentAlyante__c doc : triggerNew) {
			if(doc.Status__c != triggerOldMap.get(doc.Id).Status__c && status.contains(doc.Status__c) && doc.RecordTypeId == rtId) {
				documentsToLock.add(doc);
			}
		}

		lockRecords(documentsToLock);

		if(documentsToLock.size() > 0) {
			List<DocumentDetailAlyante__c> documentDetails = [SELECT Id FROM DocumentDetailAlyante__c WHERE Document__c IN :documentsToLock];
			lockRecords(documentDetails);
		}
	}

	public static void hasDetails(Map<Id, DocumentAlyante__c> triggerNewMap) {
		Id rtId = Schema.SObjectType.DocumentAlyante__c.getRecordTypeInfosByDeveloperName().get('PreInvoice').getRecordTypeId();
		Set<Id> documentsIdToCheck = new Set<Id>();
		for(Id docId : triggerNewMap.keySet()) {
			DocumentAlyante__c doc = triggerNewMap.get(docId);
			if(doc.RecordTypeId == rtId && doc.Status__c == 'ToBeEmitted') {
				documentsIdToCheck.add(docId);
			}
		}

		if(documentsIdToCheck.size() > 0) {
			List<Object> results = [SELECT Id, (SELECT Id FROM DocumentsDetails__r) FROM DocumentAlyante__c WHERE Id IN :documentsIdToCheck];

			for(Object result : results) {
				Map<String, Object> resultDeserialized = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(result));

				// if it has no details, DocumentsDetails__r inner query is null
				Map<String, Object> resultChildRelationshipDeserialized = (Map<String, Object>) resultDeserialized.get('DocumentsDetails__r');
				if (resultChildRelationshipDeserialized == null) {
					DocumentAlyante__c doc = triggerNewMap.get((Id) resultDeserialized.get('Id'));
					doc.addError('There must be at least one detail of the document');
				}
			}
		}
	}

	// private static Boolean isAdminUser() {
	// 	return [SELECT PermissionsModifyAllData FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1].PermissionsModifyAllData;
	// }
	
	// private static Map<Id, List <String>> changedFields(List<sObject> triggerNew, Map<Id, sObject> triggerOldMap, Id rtId){
	// 	Map<Id, List<String>> changeDocumentFileds = new Map<Id, List<String>>();
	// 	List<Schema.SObjectField> documentFields = Schema.SObjectType.DocumentAlyante__c.fields.getMap().values();
		
	// 	List<String> documentAPIFieldNames = new List<String>();
		
	// 	for(Schema.SObjectField s : documentFields ){
	// 		documentAPIFieldNames.add(s.getDescribe().getName());
	// 	}
		
	// 	for(sObject documentRecord : triggerNew){
	// 		sObject oldRecord = triggerOldMap.get(documentRecord.Id);
	// 		List<String> updateFields = new List<String>();

	// 		if(oldRecord.get('RecordTypeId') != rtId) {
	// 			continue;
	// 		}

	// 		for(String field : documentAPIFieldNames){
	// 			if(documentRecord.get(field)!= oldRecord.get(field)){
	// 				updateFields.add(field);
	// 			}
	// 		}
	// 		changeDocumentFileds.put(documentRecord.Id, updateFields);
	// 	}
	// 	 return changeDocumentFileds;
	// }

	public static void deleteRelation(List<DocumentAlyante__c> triggerOld){
		List<DocumentRelationAlyante__c> relations = [SELECT Id FROM DocumentRelationAlyante__c WHERE Child__c IN :triggerOld];
		delete relations;
	}
}