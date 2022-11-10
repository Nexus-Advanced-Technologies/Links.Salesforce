/**
 * @description       : 
 * @author            : §
 * @group             : 
 * @last modified on  : 10/11/2022
 * @last modified by  : manolo.giannotta@nexusat.it
**/
trigger OnDocumentAlyanteTrigger on DocumentAlyante__c (after insert, before update, before delete) {
	Map<String, TriggerSetting__mdt> triggerSettings = new Map<String, TriggerSetting__mdt>();
	
	for (TriggerSetting__mdt var : TriggerUtilities.TriggerSettingDocumentAlyante) {
		triggerSettings.put(var.DeveloperName, var);
	}

	if (Trigger.isAfter && Trigger.isInsert && triggerSettings.get('Links').DocumentAlyanteAfterInsert__c) {
		OnDocumentAlyanteTriggerHelper.lockRecordsByRecordTypeDeveloperName(Trigger.new,'ActiveInvoice');
		OnDocumentAlyanteTriggerHelper.lockRecordsByRecordTypeDeveloperName(Trigger.new,'CreditNote');
	}
	
	if (Trigger.isBefore && Trigger.isUpdate && triggerSettings.get('Links').DocumentAlyanteAfterUpdate__c) {
		OnDocumentAlyanteTriggerHelper.lockRecordsByRecordTypeDeveloperName(Trigger.new,'ActiveInvoice');
		OnDocumentAlyanteTriggerHelper.lockRecordsByRecordTypeDeveloperName(Trigger.new,'CreditNote');
		OnDocumentAlyanteTriggerHelper.lockRecordsByRecordTypeDeveloperName(Trigger.new,'PassiveInvoice');
		// OnDocumentAlyanteTriggerHelper.blockModifyRecord (Trigger.new, Trigger.oldMap, 'PassiveInvoice');
		// OnDocumentAlyanteTriggerHelper.checkRecordToLock(Trigger.new, Trigger.oldMap, 'PassiveInvoice', new Set<String>{ 'ToBePayed', 'Payed' });
		OnDocumentAlyanteTriggerHelper.checkRecordToLock(Trigger.new, Trigger.oldMap, 'PreInvoice', new Set<String>{ 'ToBeEmitted' });
		OnDocumentAlyanteTriggerHelper.hasDetails(Trigger.newMap);
	}

	System.debug(triggerSettings);
	if (Trigger.isBefore && Trigger.isDelete && triggerSettings.get('Links').DocumentAlyanteBeforeDelete__c) {
		OnDocumentAlyanteTriggerHelper.deleteRelation(Trigger.old);
	}
}