/**
 * @description       : 
 * @author            : Œ - Mirco Centrone
 * @last modified on  : 30-07-2021
 * @last modified by  : Œ
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   15-07-2021   Œ   Initial Version
**/
@IsTest
public with sharing class EconomicPlanControllerTest {
    
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

    
    private static List<TriggerSetting__mdt> createQuoteCustomMetadata(Boolean status) {
        List<TriggerSetting__mdt> triggerSettingMDT = (List<TriggerSetting__mdt>) Json.deserialize(
            '[' +
				'{' +
					'"DeveloperName": "Nexus",' +
					'"QuoteAfterInsert__c": "' + status + '",' +
					'"QuoteAfterUpdate__c": "' + status + '"' +
				'},' +
				'{' +
					'"DeveloperName": "Links",' +
					'"QuoteAfterInsert__c": "' + status + '",' +
					'"QuoteAfterUpdate__c": "' + status + '"' +
				'}' +
            ']'
            ,List<TriggerSetting__mdt>.class
        ); 
        return triggerSettingMDT;
    }

    private static String name = 'Test9956';

    public static String getRecordTypeId(String sobjectName, String recordTypeName){
		return Schema.getGlobalDescribe().get(sobjectName).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
	}

    @TestSetup
    static void makeData(){
        TriggerUtilities.TriggerSettingQuoteLineItem = createCustomMetadata(false);
        TriggerUtilities.TriggerSettingQuote = createQuoteCustomMetadata(false);
        
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
        
        Account account = new Account (RecordTypeId = getRecordTypeId('Account','Customer'),Name=name, Pricebook__c = customPB.Id );
        insert account;

        Opportunity opportunity = new Opportunity (RecordTypeId = getRecordTypeId('Opportunity','Links'),Name=name,AccountId=account.Id,CloseDate=Date.today(),StageName='Prospecting',Pricebook2Id=customPB.Id);
        insert opportunity;

		//Insert Quote
		Quote quoteTest = New Quote();
		quoteTest.Name = name;
		quoteTest.OpportunityId = opportunity.id;
		quoteTest.Status = '0';
		quoteTest.RecordTypeId = getRecordTypeId('Quote', 'Links');
        quoteTest.Pricebook2Id = Test.getStandardPricebookId();
		insert quoteTest;

        Product2 p2 = new Product2(Name = 'Intern 2021',
                                    Family = 'Standard',
                                    ProductCoDe = 'IN',
                                    IsActive = true);
        insert p2;
        PricebookEntry pb = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(), 
            Product2Id = p2.Id,
            UnitPrice = 10000, 
            IsActive = true);
        insert pb;
        QuoteLineItem con = new QuoteLineItem(QuoteId = quoteTest.id, PricebookEntryId = pb.id, Quantity = 1, Revenue_Type__c = '6' , UnitPrice = 1000 );
        insert con;
        Cost__c  cost = new Cost__c(Quote__c = quoteTest.id, Revenue_Type__c = '6');
        insert cost;
        Quote_Revenue__c  quoteRevenue = new Quote_Revenue__c(Quote__c = quoteTest.id, Revenue_Type__c = '6');
        insert quoteRevenue;
    }


    @IsTest
    static void getEconomicPlanTest(){
       
        RevenueTypesCS__c rtCS = new RevenueTypesCS__c();
        rtCS.Name = 'Prestazioni di Servizi';
        rtCS.DefaultMargin__c = 30;
        rtCS.MinMargin__c = 20;
        insert rtCS;
        
        Test.startTest();
        EconomicPlanController.getTotalEconomicPlan([SELECT id FROM Quote WHERE Name=: name LIMIT 1].id);
        Test.stopTest();
        delete [SELECT id FROM Quote WHERE Name=: name LIMIT 1];
    }
    @IsTest
    static void getEconomicPlanTestFAIL(){
       
        Test.startTest();
        try{
        EconomicPlanController.getTotalEconomicPlan([SELECT id FROM Quote WHERE Name=: name LIMIT 1].id);
        }
        catch(NullPointerException e){

        }
        Test.stopTest();
        delete [SELECT id FROM Quote WHERE Name=: name LIMIT 1];
    }
    @IsTest
    static void setQuoteIsMarginValidTEST(){
        
        EconomicPlanController.CustomWrapper cw = new EconomicPlanController.CustomWrapper();
        cw.quoteId = [SELECT id FROM Quote WHERE Name=: name LIMIT 1].id;
        cw.marginCheck = true;
        cw.totalMarginCheck = true;
        cw.costHRMargin = 100000;
        cw.costMargin = 100000;

        Test.startTest();
        EconomicPlanController.setQuoteIsMarginValid(cw);
        Test.stopTest();
        delete [SELECT id FROM Quote WHERE Name=: name LIMIT 1];
    }

}