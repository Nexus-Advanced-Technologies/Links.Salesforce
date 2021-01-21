@isTest(SeeAllData=true)
private class QuoteTriggerHelperTest {
    @isTest
    static void testAssignStandardPricebookToQuote(){

        TriggerCustomSetting__c triggerCustomSetting = new TriggerCustomSetting__c();
        triggerCustomSetting.NexusQuoteAfterInsert__c = true;

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
            OpportunityId = oppWithoutPricebook2.Id
        );

        listQuote.add(quoteWithStandardPricebook);

        Test.startTest();
        insert listQuote;
        QuoteTriggerHelper.assignAccountPricebookToQuote(listQuote);        
        Test.stopTest();

        Quote quoteWithStandardPricebook2 = [SELECT Id,Name,Pricebook2Id,Pricebook2.Name FROM Quote WHERE Name = 'Quote With Standard Pricebook'];
        
        Pricebook2 standardPricebook = [SELECT Id,Name FROM Pricebook2 WHERE Id = :Test.getStandardPricebookId()];

        System.assertEquals(standardPricebook.Name,quoteWithStandardPricebook2.Pricebook2.Name);
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
            Price_Book__c = generalPricebook2.Id
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
        insert listQuote;
        QuoteTriggerHelper.assignAccountPricebookToQuote(listQuote);        
        Test.stopTest();

        Quote quoteWithGeneralPricebook2 = [SELECT Id,Name,Pricebook2Id,Pricebook2.Name FROM Quote WHERE Name = 'Quote With General Pricebook'];
        
        System.assertEquals('Test Pricebook General',quoteWithGeneralPricebook2.Pricebook2.Name);
    }
}