/**
 * @description       : 
 * @author            : ¤ → alessio.marra@nexusat.it
 * @last modified on  : 03/02/2021
 * @last modified by  : ¤ → alessio.marra@nexusat.it
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   03/02/2021   ¤ → alessio.marra@nexusat.it   Initial Version
**/
@IsTest
public class OnContentDocumentLinkTest {

	private static List<DocumentLinkSetting__mdt> createCustomMetadata(String userRoleName, String linkedEntityId, String shareType) {
		List<DocumentLinkSetting__mdt> MetadataType = (List<DocumentLinkSetting__mdt>) Json.deserialize(
			'[' +
				'{' +
					'"DeveloperName": "' + userRoleName + '",' +
					'"LinkedEntityId__c": "' + linkedEntityId + '",' +
					'"ShareType__c": "' + shareType + '"' +
				'}' +
			']'
			,List<DocumentLinkSetting__mdt>.class
		); 
		return MetadataType;
	}

	private static Id insertChatterGroup(String name, String collaborationType) {
		CollaborationGroup cg = new CollaborationGroup();
		cg.Name = name;
		cg.CollaborationType = collaborationType;
		insert cg;
		return cg.Id;
	}

	private static Id insertContentDocument(String data) {
		ContentVersion cv = new ContentVersion();
		cv.Title = data;
		cv.PathOnClient = data + '.txt';
		cv.VersionData = Blob.valueOf(data);
		cv.IsMajorVersion = true;
		insert cv;
		return cv.Id;
	}

	@IsTest
	static void testShareToChatterGroup() {

		Id chatterGroupId = insertChatterGroup('Test', 'Private');

		Id userRoleId = UserInfo.getUserRoleId();
		String userRoleName = [SELECT DeveloperName FROM UserRole WHERE Id = :userRoleId LIMIT 1].DeveloperName;
		
		Test.startTest();
		OnContentDocumentLinkHelper.DocumentLinkSetting = createCustomMetadata(userRoleName, chatterGroupId, 'V');
		insertContentDocument('Test');
		Test.stopTest();

		Id contentDocumentId = [SELECT Id FROM ContentDocument LIMIT 1].Id;
		List<ContentDocumentLink> documentLinks = [SELECT Id, LinkedEntityId, ShareType FROM ContentDocumentLink WHERE ContentDocumentId = :contentDocumentId];
		Id expectedChatterGroupId;
		for (ContentDocumentLink variable : documentLinks) {
			if (variable.ShareType == 'V') {
				expectedChatterGroupId = variable.LinkedEntityId;
			}
		}

		System.assertEquals(2, documentLinks.size());
		System.assertEquals(chatterGroupId, expectedChatterGroupId);
	}
}