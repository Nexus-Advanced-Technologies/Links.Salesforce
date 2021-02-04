/**
 * @description       : Helper Class for OnContentDocumentLink trigger
 * @author            : ¤ → alessio.marra@nexusat.it
 * @last modified on  : 03/02/2021
 * @last modified by  : ¤ → alessio.marra@nexusat.it
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   02/02/2021   ¤ → alessio.marra@nexusat.it   Initial Version
**/
public class OnContentDocumentLinkHelper {

	@TestVisible
	public static List<DocumentLinkSetting__mdt> DocumentLinkSetting {
		get{
			if(DocumentLinkSetting == null) {
				DocumentLinkSetting = [SELECT DeveloperName, LinkedEntityId__c, ShareType__c FROM DocumentLinkSetting__mdt];
			}
			
			return DocumentLinkSetting;
		}
		set;
	}

	/**
	* @description Share document with ChatterGroup by DocumentLinkSetting only ShareType = I
	* @author ¤ → alessio.marra@nexusat.it | 03/02/2021
	* @param List<ContentDocumentLink> triggerNew
	**/
	public static void shareToChatterGroup(List<ContentDocumentLink> triggerNew) {
		System.debug('¤ shareToChatterGroup {');
		System.debug('¤ triggerNew: ' + triggerNew);

		Map<Id, String> userMap = getUserRole();
		Map<String, DocumentLinkSetting__mdt> documentLinkSettingMap = getDocumentLinkSetting();
		List<ContentDocumentLink> contentDocumentLinkToInsert = new List<ContentDocumentLink>();

		for (ContentDocumentLink variable : triggerNew) {
			if (variable.ShareType == 'I') {	//ShareType = I link owner when document is created
				String userRoleDeveloperName = userMap.get(UserInfo.getUserId());
				DocumentLinkSetting__mdt documentSetting = documentLinkSettingMap.get(userRoleDeveloperName);

				if (documentSetting != null) {
					ContentDocumentLink cdl = new ContentDocumentLink();
					cdl.ContentDocumentId = variable.ContentDocumentId;
					cdl.LinkedEntityId = documentSetting.LinkedEntityId__c;
					cdl.ShareType = documentSetting.ShareType__c;
					contentDocumentLinkToInsert.add(cdl);
				}
			}
		}

		if (!contentDocumentLinkToInsert.isEmpty()) {
			insert contentDocumentLinkToInsert;
		}

		System.debug('¤ } shareToChatterGroup');
	}

	/**
	* @description Get all user with UserRole
	* @author ¤ → alessio.marra@nexusat.it | 03/02/2021
	* @return Map<Id, String>
	**/
	private static Map<Id, String> getUserRole() {
		Map<Id, String> userMap = new Map<Id, String>();
		for (User variable : [SELECT Id, UserRole.DeveloperName FROM User]) {
			userMap.put(variable.Id, variable.UserRole.DeveloperName);
		}
		return userMap;
	}

	/**
	* @description Get all DocumentLinkSetting by DeveloperName
	* @author ¤ → alessio.marra@nexusat.it | 03/02/2021
	* @return Map<String, DocumentLinkSetting__mdt>
	**/
	private static Map<String, DocumentLinkSetting__mdt> getDocumentLinkSetting() {
		Map<String, DocumentLinkSetting__mdt> documentLinkSettingMap = new Map<String, DocumentLinkSetting__mdt>();
		for (DocumentLinkSetting__mdt variable : DocumentLinkSetting) {
			documentLinkSettingMap.put(variable.DeveloperName, variable);
		}
		return documentLinkSettingMap;
	}
}
