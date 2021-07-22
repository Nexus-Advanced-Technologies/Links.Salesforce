@isTest
private class QuoteLineItemTriggerHelperTest {
    
    private static String name = 'Costi Risorse Umane Links';
    
    public static String getRecordTypeId(String sobjectName, String recordTypeName){
		return Schema.getGlobalDescribe().get(sobjectName).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
	}

    @TestSetup
    static void makeData(){
        List<TriggerSetting__mdt> customMetaData = createCustomMetadata(true);
        Account account = new Account (RecordTypeId = TestDataFactory.getRecordTypeId('Account','Nexus'),Name=name);
        insert account;
        Product2 prod = new Product2(Name = 'Intern 2021',
                                     Family = 'Standard',
                                     ProductCoDe = 'IN',
                                     IsActive = true);
        insert prod;
        /********************************************************************** */
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = prod.Id,
            UnitPrice = 10000, 
            IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Costi Risorse Umane Links', 
                                             isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, 
            Product2Id = prod.Id,
            UnitPrice = 12000, 
            IsActive = true);
        insert customPrice;
        //***************************************************************************** */
        
        Opportunity opportunity = new Opportunity (RecordTypeId = getRecordTypeId('Opportunity','Links'),Name=name,AccountId=account.Id,CloseDate=Date.today(),StageName='Prospecting',Pricebook2Id=customPB.Id);
        insert opportunity;
        
        Quote quote = new Quote(RecordTypeId = getRecordTypeId('Quote','Links'),Name=name,OpportunityId = opportunity.id);
        insert quote;
        
    }
    
    
    private static List<TriggerSetting__mdt> createCustomMetadata(Boolean status) {
        List<TriggerSetting__mdt> triggerSettingMDT = (List<TriggerSetting__mdt>) Json.deserialize(
            '[' +
            '{' +
            '"DeveloperName": "Links",' +
            '"QuoteLineItemAfterDelete__c": "' + status + '"' +
            '}' +
            ']' +
            '[' +
            '{' +
            '"DeveloperName": "Links",' +
            '"QuoteLineItemAfterInsert__c": "' + status + '"' +
            '}' +
            ']' +
            '[' +
            '{' +
            '"DeveloperName": "Links",' +
            '"QuoteLineItemAfterUpdate__c": "' + status + '"' +
            '}' +
            ']'
            ,List<TriggerSetting__mdt>.class
        ); 
        return triggerSettingMDT;
    }
    @isTest
    private static void quoteLineItemUpdateTotalHRCostTEST(){
        Test.startTest();
        List<QuoteLineItem> quoteLineItemList = new List<QuoteLineItem>();
        for(Integer i=0;i<10;i++){
            QuoteLineItem q = new QuoteLineItem();
            q.QuoteId = [SELECT id FROM Quote WHERE name =: name LIMIT 1].id;
            q.PricebookEntryId = [SELECT id FROM PricebookEntry WHERE PriceBook2.Name =: name LIMIT 1].Id;
            q.Quantity = 1;
            q.Revenue_Type__c = '6';
            q.UnitPrice = 100;
            quoteLineItemList.add(q);
        }
        insert quoteLineItemList;
        update quoteLineItemList;
        delete quoteLineItemList;
        Test.stopTest();
        
    }
    
}