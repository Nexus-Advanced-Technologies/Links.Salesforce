/**
 * @description       : Trigger OnOpportuntiy
 * @author            : 
 * @see               : OnOpportunityHelper (Class)
 * @see               : TriggerUtilities (Class)
 * @see               : TriggerSetting (CustomMetadata)
 * @last modified on  : 24/01/2021
 * @last modified by  : ¤ → alessio.marra@nexusat.it
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   21/01/2021                                        Initial Version
 * 1.1   24/01/2021   ¤ → alessio.marra@nexusat.it         Added controll to enable/disable
**/

trigger OnOpportunity on Opportunity (before insert) {
	System.debug('¤ OnOpportunity {');

	//Get Trigger.new List splitted by company in Map(company, list)
	Map<String, List<Opportunity>> triggerNewSplittedMap = TriggerUtilities.splitByCompany(Trigger.new);

	//Get CustomMetadata with trigger information for each company
	Map<String, TriggerSetting__mdt> triggerSettings = new Map<String, TriggerSetting__mdt>();
	for (TriggerSetting__mdt var : [SELECT DeveloperName, OpportunityBeforeInsert__c FROM TriggerSetting__mdt]) {
		triggerSettings.put(var.DeveloperName, var);
	}

	if (triggerNewSplittedMap.containsKey('Nexus')) {
		List<Opportunity> triggerNewSplitted = triggerNewSplittedMap.get('Nexus');

		if (Trigger.isBefore && Trigger.isInsert) {
			if (triggerSettings.get('Nexus').OpportunityBeforeInsert__c) {
				OnOpportunityHelper.generateReferenceNumber(triggerNewSplitted);
			}
		}
	}
	System.debug('¤ } OnOpportunity');
}