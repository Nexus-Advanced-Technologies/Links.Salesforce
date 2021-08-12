/**
 * @description       : 
 * @author            : 
 * @last modified on  : 04-05-2021
 * @last modified by  : Œ
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0                                               Initial Version
 * 1.1   25/01/2021   ¤ → alessio.marra@nexusat.it   Added controll to enable/disable
 * 1.2   01/02/2021   ¤ → alessio.marra@nexusat.it   Add CustomMetadata in TriggerUtilities with @TestVisible
 * 1.3   22/04/2021  RC → Riccardo Costantini        Add New Trigger on Quote Links in After Update for View PDF Page in File Section 
 * 1.4   12/05/2021  RC → Riccardo Costantini        Modify QuoteTriggerHelper.setOpportunityAmount(q);
**/
trigger QuoteTrigger on Quote (after insert, after update,before insert,before update) {

	//Get Trigger.new List splitted by company in Map(company, list)
	Map<String, List<Quote>> triggerNewSplittedMap = TriggerUtilities.splitByCompany(Trigger.new);
	Map<String, List<Quote>> triggerOldSplittedMap = new Map<String, List<Quote>>();
	if (Trigger.isAfter && Trigger.isUpdate) {
	 triggerOldSplittedMap = TriggerUtilities.splitByCompany(Trigger.old);
	}


	//Get CustomMetadata with trigger information for each company
	Map<String, TriggerSetting__mdt> triggerSettings = new Map<String, TriggerSetting__mdt>();
	for (TriggerSetting__mdt var : TriggerUtilities.TriggerSettingQuote) {
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



	if (triggerNewSplittedMap.containsKey('Links')) {
		List<Quote> triggerNewSplitted = triggerNewSplittedMap.get('Links');


		if(Trigger.isBefore && Trigger.isInsert){
			if (triggerSettings.get('Links').QuoteBeforeInsert__c) {
				QuoteTriggerHelper.generateQuoteNumber(triggerNewSplitted);
			}
		}
		if(Trigger.isBefore && Trigger.isUpdate){
			if (triggerSettings.get('Links').QuoteBeforeInsert__c) {
				System.debug('start Trigger before Update ');
				QuoteTriggerHelper.generateProtocolNumber(triggerNewSplitted,Trigger.OldMap);
				QuoteTriggerHelper.resetProtocolNumber(triggerNewSplitted,Trigger.OldMap);
				for(Quote quote : triggerNewSplitted){
					if(quote.Status == '3' && Trigger.OldMap.get(quote.Id).Status != '3'){
						if(QuoteTriggerHelper.hasDocumentProtocol(quote)){
							quote.addError('NON PUOI PASSARE ALLO STATO PRESENTED SE NON CI SONO FILE ALLEGATI NEL PROTOCOLLO');
						}
					}
				}
			}
		}
		if (Trigger.isAfter && Trigger.isUpdate) {
			System.debug('start Trigger after Update ');
			List<Quote> triggerOldSplitted = triggerOldSplittedMap.get('Links');
			if (triggerSettings.get('Links').QuoteAfterUpdate__c) {
				System.debug('Custom MetaData True');
				Map<Id, Quote> triggerNewMap = new Map<Id, Quote>();
				Map<Id, Quote> triggerOldMap = new Map<Id, Quote>();
				for(Quote q : triggerNewSplitted){
					triggerNewMap.put(q.id, q);
				}
				for(Quote q : triggerOldSplitted){
					triggerOldMap.put(q.id, q);
				}
				for(Quote q : triggerNewMap.values()){
					System.debug('For TriggerNewMap');
					System.debug('Quote: ' + q);
					Boolean checkStatus = QuoteTriggerHelper.checkRegisteredStatus(q, triggerOldMap.get(q.Id));
                    QuoteTriggerHelper.setOpportunityAmount(q,triggerOldMap.get(q.Id));
					if(checkStatus == true){
						System.debug('checkStatus == true');
						QuoteTriggerHelper.generateContentVersionPDF(q.Id);
					}
					
				}
			}
		}
	}
}