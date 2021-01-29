/**
 * @description       : 
 * @author            : 
 * @last modified on  : 25/01/2021
 * @last modified by  : ¤ → alessio.marra@nexusat.it
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0                                               Initial Version
 * 1.1   25/01/2021   ¤ → alessio.marra@nexusat.it   Added controll to enable/disable
**/
trigger QuoteTrigger on Quote (after insert) {

	//Get Trigger.new List splitted by company in Map(company, list)
	Map<String, List<Quote>> triggerNewSplittedMap = TriggerUtilities.splitByCompany(Trigger.new);

	//Get CustomMetadata with trigger information for each company
	Map<String, TriggerSetting__mdt> triggerSettings = new Map<String, TriggerSetting__mdt>();
	for (TriggerSetting__mdt var : [SELECT DeveloperName, QuoteAfterInsert__c FROM TriggerSetting__mdt]) {
		triggerSettings.put(var.DeveloperName, var);
	}

	if (triggerNewSplittedMap.containsKey('Nexus')) {
		List<Quote> triggerNewSplitted = triggerNewSplittedMap.get('Nexus');

		if (Trigger.isAfter && Trigger.isInsert) {
			if (triggerSettings.get('Nexus').QuoteAfterInsert__c) {
				QuoteTriggerHelper.assignAccountPricebookToQuote(triggerNewSplitted);
			}
		}
	}
}