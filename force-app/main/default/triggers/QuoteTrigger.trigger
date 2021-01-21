trigger QuoteTrigger on Quote (after insert) {

    TriggerCustomSetting__c triggerCustomSettings = TriggerCustomSetting__c.getOrgDefaults();

    if(Trigger.isAfter && Trigger.isInsert) {
        if(triggerCustomSettings.NexusQuoteAfterInsert__c == true) {
            QuoteTriggerHelper.assignAccountPricebookToQuote(Trigger.new);
        }
    }
}