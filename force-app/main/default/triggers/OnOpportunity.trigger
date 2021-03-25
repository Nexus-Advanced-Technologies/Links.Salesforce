/**
 * @description       : Trigger OnOpportuntiy
 * @author            : 
 * @see               : OnOpportunityHelper (Class)
 * @see               : TriggerUtilities (Class)
 * @see               : TriggerSetting (CustomMetadata)
 * @last modified on  : 25/03/2021
 * @last modified by  : ¤ → alessio.marra@nexusat.it
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   21/01/2021                                        Initial Version
 * 1.1   24/01/2021   ¤ → alessio.marra@nexusat.it         Added controll to enable/disable
 * 1.2   01/02/2021   ¤ → alessio.marra@nexusat.it         Added controll for all company if ReferenceNumber is Null or Duplicate in Insert and if ReferenceNumber is Changed in Update
 * 1.3   01/02/2021   ¤ → alessio.marra@nexusat.it         Add CustomMetadata in TriggerUtilities with @TestVisible
**/
trigger OnOpportunity on Opportunity (before insert, before update) {
	System.debug('¤ OnOpportunity {');

	// //Get Trigger.new List splitted by company in Map(company, list)
	// Map<String, List<Opportunity>> triggerNewSplittedMap = TriggerUtilities.splitByCompany(Trigger.new);

	// //Get CustomMetadata with trigger information for each company
	// Map<String, TriggerSetting__mdt> triggerSettings = new Map<String, TriggerSetting__mdt>();
	// for (TriggerSetting__mdt var : TriggerUtilities.TriggerSettingOpportunity) {
	// 	triggerSettings.put(var.DeveloperName, var);
	// }

	if (Trigger.isBefore && Trigger.isInsert) {
		OnOpportunityHelper.beforeInsert(Trigger.new);
	}

	if (Trigger.isBefore && Trigger.isUpdate) {
		OnOpportunityHelper.beforeUpdate(Trigger.new, Trigger.oldMap);
	}



	// for (String company : TriggerUtilities.getCompany()) {
	// 	if (triggerNewSplittedMap.containsKey(company)) {
	// 		List<Opportunity> triggerNewSplitted = triggerNewSplittedMap.get(company);
	
	// 		if (Trigger.isBefore && Trigger.isInsert) {
	// 			if (triggerSettings.get(company).OpportunityBeforeInsert__c) {
	// 				//OnOpportunityHelper.generateReferenceNumber(triggerNewSplitted);


	// 				Callable extension = (Callable) Type.forName('OnOpportunityHelper').newInstance();
	// 				extension.call('generateReferenceNumber', new Map<String, Object> { 
	// 					'triggerNew' => triggerNewSplitted
	// 				 });
	// 			}
	// 		}
	// 	}
	// }

	// //For all company
	// if (Trigger.isBefore && Trigger.isInsert) {
	// 	OnOpportunityHelper.checkReferenceNumberNullOrDuplicate(Trigger.new);
	// }
	
	// if (Trigger.isBefore && Trigger.isUpdate) {
	// 	OnOpportunityHelper.checkReferenceNumberIsChanged(Trigger.new, Trigger.oldMap);
	// }

	System.debug('¤ } OnOpportunity');
}