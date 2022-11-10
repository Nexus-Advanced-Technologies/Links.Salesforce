/**
 * @description       : 
 * @author            : §
 * @group             : 
 * @last modified on  : 01-20-2022
 * @last modified by  : §
**/
trigger OnDocumentDetailAlyanteTrigger on DocumentDetailAlyante__c (before insert) {
    Map<String, TriggerSetting__mdt> triggerSettings = new Map<String, TriggerSetting__mdt>();
	
    for (TriggerSetting__mdt var : TriggerUtilities.TriggerSettingDocumentDetailAlyante) {
		triggerSettings.put(var.DeveloperName, var);
	}

    if(triggerSettings.get('Links').DocumentDetailAlyanteBeforeInsert__c) {
        for(DocumentDetailAlyante__c documentDetail : OnDocumentDetailAlyanteTriggerHelper.blockCreateRecords(Trigger.new)){
            documentDetail.addError('You cannot enter a detail for a locked document');
        }
    }
}