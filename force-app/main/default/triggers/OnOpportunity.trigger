/**
 * @description       : Trigger OnOpportuntiy
 * @author            : 
 * @see               : OnOpportunityHelper (Class)
 * @see               : TriggerUtilities (Class)
 * @see               : TriggerSetting (CustomMetadata)
 * @last modified on  : 26/03/2021
 * @last modified by  : ¤ → alessio.marra@nexusat.it
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   21/01/2021                                        Initial Version
 * 1.1   24/01/2021   ¤ → alessio.marra@nexusat.it         Added controll to enable/disable
 * 1.2   01/02/2021   ¤ → alessio.marra@nexusat.it         Added controll for all company if ReferenceNumber is Null or Duplicate in Insert and if ReferenceNumber is Changed in Update
 * 1.3   01/02/2021   ¤ → alessio.marra@nexusat.it         Add CustomMetadata in TriggerUtilities with @TestVisible
 * 1.4   25/03/2021   ¤ → alessio.marra@nexusat.it         The split logic has been moved to the OnOpportunityHelper class
 * 1.5   26/03/2021   ¤ → alessio.marra@nexusat.it         Removed all commented code in version 1.4
**/
trigger OnOpportunity on Opportunity (before insert, before update) {
	LoggerHandler.start('¤ OnOpportunity');

	if (Trigger.isBefore && Trigger.isInsert) {
		OnOpportunityHelper.beforeInsert(Trigger.new);
	}

	if (Trigger.isBefore && Trigger.isUpdate) {
		OnOpportunityHelper.beforeUpdate(Trigger.new, Trigger.oldMap);
	}

	LoggerHandler.end('¤ OnOpportunity');
}