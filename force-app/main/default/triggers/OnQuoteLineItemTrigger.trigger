/**
 * @description       : 
 * @author            : Œ
 * @group             : 
 * @last modified on  : 03-26-2021
 * @last modified by  : Œ
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   03-25-2021   Œ   Initial Version
**/
trigger OnQuoteLineItemTrigger on QuoteLineItem (after insert, after update, after delete) {
	System.debug('OnQuoteLineItemTrigger Triggered');
	Map<String, List<QuoteLineItem>> triggerNewSplittedMap = new Map<String, List<QuoteLineItem>>();
	Map<String, List<QuoteLineItem>> triggerOldSplittedMap = new Map<String, List<QuoteLineItem>>();
	List<QuoteLineItem> triggerNewSplitted = new List<QuoteLineItem>();
	List<QuoteLineItem> triggerOldSplitted = new List<QuoteLineItem>();
	
	//Get Trigger.new List splitted by company in Map(company, list)
	if (!Trigger.isDelete) {
		 triggerNewSplittedMap = TriggerUtilities.splitByCompany(Trigger.new);
	}Else{
		 triggerOldSplittedMap = TriggerUtilities.splitByCompany(Trigger.old);
	}
	//Get CustomMetadata with trigger information for each company
	Map<String, TriggerSetting__mdt> triggerSettings = new Map<String, TriggerSetting__mdt>();
	for (TriggerSetting__mdt var : TriggerUtilities.TriggerSettingQuoteLineItem) {
		triggerSettings.put(var.DeveloperName, var);
	}

	if (triggerNewSplittedMap.containsKey('Nexus')) {
		List<QuoteLineItem> triggerNewSplitted = triggerNewSplittedMap.get('Nexus');

		if (Trigger.isAfter && Trigger.isInsert) {
			
		}
	}

	if (triggerNewSplittedMap.containsKey('Links') || triggerOldSplittedMap.containsKey('Links')) {
		if (!Trigger.isDelete) {
			triggerNewSplitted = triggerNewSplittedMap.get('Links');
		}Else{
			System.debug('OnQuoteLineItemTrigger SPLIT MAP');
			triggerOldSplitted = triggerOldSplittedMap.get('Links');
		}

		if (Trigger.isAfter && Trigger.isInsert) {
			if (triggerSettings.get('Links').QuoteLineItemAfterInsert__c) {
				System.debug('OnQuoteLineItemTrigger AFTER INSERT');
				QuoteLineItemTriggerHelper.quoteLineItemUpdateTotalHRCost(triggerNewSplitted);
			}
		}	
		if (Trigger.isAfter && Trigger.isUpdate) {
            if (triggerSettings.get('Links').QuoteLineItemAfterUpdate__c) {
				System.debug('OnQuoteLineItemTrigger AFTER UPDATE');
				QuoteLineItemTriggerHelper.quoteLineItemUpdateTotalHRCost(triggerNewSplitted);
			}
        }
		if (Trigger.isAfter && Trigger.isDelete) {
            if (triggerSettings.get('Links').QuoteLineItemAfterDelete__c) {
				System.debug('OnQuoteLineItemTrigger AFTER DELETE');
				System.debug('OnQuoteLineItemTrigger triggerOldSplitted  ' + triggerOldSplitted);
				System.debug('OnQuoteLineItemTrigger trigger.Old  ' + trigger.Old);
				QuoteLineItemTriggerHelper.quoteLineItemUpdateTotalHRCost(triggerOldSplitted);
			}
        }

	}

}