/**
* @description       : 
* @author            : 
* @last modified on  : 16-07-2021
* @last modified by  : Œ
* Modifications Log 
* Ver   Date         Author                         Modification
* 1.0                                               Initial Version
* 1.1   25/01/2021   ¤ → alessio.marra@nexusat.it   Review ApiName Nomenclature
* 1.2   01/02/2021   ¤ → alessio.marra@nexusat.it   Add CustomMetadata in TriggerUtilities with @TestVisible
**/
@IsTest
private class QuoteTriggerHelperTest {

	private static Id getRecordTypeId(String name) {
		return [SELECT Id FROM RecordType WHERE SobjectType = 'Quote' AND DeveloperName = :name LIMIT 1].Id;
    }
    
    private static List<TriggerSetting__mdt> createCustomMetadata(Boolean status) {
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
    
    @isTest
    static void testAssignStandardPricebookToQuote(){
        
        Account accountWithoutPricebook = new Account(
            Name = 'Test Account Without Pricebook'
        );
        insert accountWithoutPricebook;
        
        Account accountWithoutPricebook2 = [SELECT Id FROM Account WHERE Name = 'Test Account Without Pricebook'];
        
        Opportunity oppWithoutPricebook = new Opportunity(
            Name = 'Test opportunity without Pricebook',
            AccountId = accountWithoutPricebook.Id,
            StageName = 'New',
            CloseDate = Date.today()
        );
        insert oppWithoutPricebook;
        
        List<Quote> listQuote = new List<Quote>();
        Opportunity oppWithoutPricebook2 = [SELECT Id,Name,AccountId FROM Opportunity WHERE Name = 'Test opportunity without Pricebook'];
        System.debug('oppWithoutPricebook2'+oppWithoutPricebook2);
        
        Quote quoteWithStandardPricebook = new Quote(
            Name = 'Quote With Standard Pricebook',
            OpportunityId = oppWithoutPricebook2.Id,
			RecordTypeId = getRecordTypeId('Nexus')
        );
        
        listQuote.add(quoteWithStandardPricebook);
        
        Test.startTest();
        //TriggerUtilities.TriggerSettingQuote = createCustomMetadata(true);
       // insert listQuote;
        Test.stopTest();
        
        //Quote quoteWithStandardPricebook2 = [SELECT Id,Pricebook2Id FROM Quote WHERE Name = 'Quote With Standard Pricebook'];
        
       // System.assertEquals(Test.getStandardPricebookId(),quoteWithStandardPricebook2.Pricebook2Id);
    }
    
    @isTest
    static void testAssignAccountGeneralPricebookToQuote(){
        
        Pricebook2 generalPricebook = new Pricebook2(
            Name = 'Test Pricebook General',
            IsActive = true
        );
        insert generalPricebook;
        
        Pricebook2 generalPricebook2 = [SELECT Id FROM Pricebook2 WHERE Name = 'Test Pricebook General'];
        
        Account accountWithPricebook = new Account(
            Name = 'Test Account With Pricebook',
            PriceBook__c = generalPricebook2.Id
        );
        insert accountWithPricebook;
        
        Account accountWithPricebook2 = [SELECT Id FROM Account WHERE Name = 'Test Account With Pricebook'];
        
        Opportunity oppWithPricebook = new Opportunity(
            Name = 'Test opportunity with Pricebook',
            AccountId = accountWithPricebook2.Id,
            StageName = 'New',
            CloseDate = Date.today()
        );
        insert oppWithPricebook;
        
        List<Quote> listQuote = new List<Quote>();
        Opportunity oppWithPricebook2 = [SELECT Id,Name,AccountId FROM Opportunity WHERE Name = 'Test opportunity with Pricebook'];
        
        System.debug('oppWithPricebook2'+oppWithPricebook2);
        
        
        Quote quoteWithGeneralPricebook = new Quote(
            Name = 'Quote With General Pricebook',
            OpportunityId = oppWithPricebook2.Id
        );
        
        listQuote.add(quoteWithGeneralPricebook);
        
        Test.startTest();
        TriggerUtilities.TriggerSettingQuote = createCustomMetadata(true);
        insert listQuote;
        QuoteTriggerHelper.assignAccountPricebookToQuote(listQuote);
        Test.stopTest();
    }
    
	@isTest
	static void testGenerateContentVersionPDF(){

		Account acc = new Account(
			Name = 'Test Account'
		);
	 	insert acc;

	 	Opportunity opp = new Opportunity(
	 		Name = 'Test opportunity',
	 		AccountId = acc.Id,
	 		StageName = 'New',
	 		CloseDate = Date.today()
	 	);
	 	insert opp;

	 	List<Quote> listOfQuote = new List<Quote>();
	 	Opportunity opp2 = [SELECT Id,Name,AccountId FROM Opportunity WHERE Name = 'Test opportunity'];
	 	System.debug('opp2'+opp2);

	 	Quote quoteForPdf = new Quote(
	 		Name = 'Quote for PDF Content',
	 		OpportunityId = opp.Id,
	 		Status = '3'
	 	);
	 	insert quoteForPdf;

	 	Test.startTest();
	 	//TriggerUtilities.TriggerSettingQuote = createCustomMetadata(true);
	 	QuoteTriggerHelper.generateContentVersionPDF(quoteForPdf.id);
	 	Test.stopTest();
	 }
	
    @isTest
    static void testSetOpportunityAmount(){
        
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;
        
        Opportunity opp = new Opportunity(
            Name = 'Test opportunity',
            AccountId = acc.Id,
            StageName = 'New',
            CloseDate = Date.today(),
            Amount = 4000
        );
        insert opp;
        
        Quote quo = new Quote(
            Name = 'Quote for PDF Content',
            OpportunityId = opp.Id,
            Status = '3'
        );
        
        Test.startTest();
        TriggerUtilities.TriggerSettingQuote = createCustomMetadata(true);
        insert quo;
        Test.stopTest();
        
    }
    
}