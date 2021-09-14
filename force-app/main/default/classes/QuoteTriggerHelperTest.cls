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
            '"QuoteBeforeInsert__c": "' + status + '",' +
            '"QuoteBeforeUpdate__c": "' + status + '",' +
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
            StageName = 'Prospecting',
            CloseDate = Date.today()
        );
        insert opp;
        
        List<Quote> listOfQuote = new List<Quote>();
        Opportunity opp2 = [SELECT Id,Name,AccountId FROM Opportunity WHERE Name = 'Test opportunity'];
        System.debug('opp2'+opp2);
        
        Quote quoteForPdf = new Quote(
            Name = 'Quote for PDF Content',
            OpportunityId = opp.Id,
            Status = '3',
            QuoteNumber__c = '2021-1',
            RecordTypeId = getRecordTypeId('Links')
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
        
        PaymentType__c pt = new PaymentType__c(
            Name='100AChiusura',
            Type__c = 'One Shot'
        );
        insert pt;
        
        Opportunity opp = new Opportunity(
            Name = 'Test opportunity',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            PaymentType__c = pt.Id,
            Amount = 4000
        );
        insert opp;
        Quote quoteOld = new Quote(
            Name = 'test',
            OpportunityId = opp.Id,
            Status = '1',
            RecordTypeId = getRecordTypeId('Links')
        );
        insert quoteOld;
        
        Quote quo = new Quote(
            Name = 'Quote for PDF Content',
            OpportunityId = opp.Id,
            Status = '3',
            RecordTypeId = getRecordTypeId('Links')
        );
        insert quo;
        
        /*
Quote quo2 = new Quote(
Name = 'Quote for PDF Content',
OpportunityId = opp.Id,
Status = '4',
RecordTypeId = getRecordTypeId('Links')
);
insert quo2;*/
        
        Quote quo3 = new Quote(
            Name = 'Quote for PDF Content',
            OpportunityId = opp.Id,
            Status = '5',
            RecordTypeId = getRecordTypeId('Links')
        );
        insert quo3;
        
        Test.startTest();
        TriggerUtilities.TriggerSettingQuote = createCustomMetadata(true);
        
        QuoteTriggerHelper.setOpportunityAmount(quo,quoteOld);
        QuoteTriggerHelper.setOpportunityAmount(quo3,quoteOld);
        Test.stopTest();  
    }
    
    @isTest
    static void testGenerateQuoteNumber(){
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;
        
        Opportunity opp = new Opportunity(
            Name = 'Test opportunity',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Amount = 4000
        );
        insert opp;
        
        List<Quote> quoteInsertNew = new List<Quote>();
        for(Integer i = 0; i<5; i++){
            Quote quote = new Quote();
            quote.Name = 'Test ' + i;
            quote.RecordTypeId = getRecordTypeId('Links');
            quote.OpportunityId = opp.Id;
            quote.Status = '2';
            quoteInsertNew.add(quote);
        }
        insert quoteInsertNew;
        Test.startTest();
        TriggerUtilities.TriggerSettingQuote = createCustomMetadata(true);
        QuoteTriggerHelper.generateQuoteNumber(quoteInsertNew);
        Test.stopTest();  
    }
    
    @isTest
    static void testProtocolNumber(){
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;
        
        Opportunity opp = new Opportunity(
            Name = 'Test opportunity',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Amount = 4000
        );
        insert opp;
        
        Map<id,Quote> oldmap = new Map<id,Quote>();
        List<Quote> newList = new List<Quote>();
        Quote oldQuote = new Quote();
        oldQuote.Name = 'Test893';
        oldQuote.OpportunityId = opp.Id;
        oldQuote.Status = '1';
        oldQuote.RecordTypeId =  getRecordTypeId('Links');
        insert oldQuote;
        oldmap.put(oldQuote.Id,oldQuote);
        
        Test.startTest();
        TriggerUtilities.TriggerSettingQuote = createCustomMetadata(true);
        oldQuote.Status = '2';
        update oldQuote;
        newList.add(oldQuote);
        QuoteTriggerHelper.generateProtocolNumber(newList,oldmap);
        Test.stopTest();  
    }
    
    
    @isTest
    static void testResetProtocolNumber(){
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;
        
        Opportunity opp = new Opportunity(
            Name = 'Test opportunity',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Amount = 4000
        );
        insert opp;
        
        Map<id,Quote> oldmap = new Map<id,Quote>();
        List<Quote> newList = new List<Quote>();
        Quote oldQuote = new Quote();
        oldQuote.Name = 'Test893';
        oldQuote.OpportunityId = opp.Id;
        oldQuote.Status = '3';
        oldQuote.RecordTypeId = getRecordTypeId('Links');
        insert oldQuote;
        oldmap.put(oldQuote.Id,oldQuote);
        
        Test.startTest();
        TriggerUtilities.TriggerSettingQuote = createCustomMetadata(true);
        oldQuote.Status = '0';
        update oldQuote;
        newList.add(oldQuote);
        QuoteTriggerHelper.resetProtocolNumber(newList,oldmap);
        Test.stopTest();  
    }
    
    
    
    @isTest
    static void testAttachDocument(){
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;
        
        Opportunity opp = new Opportunity(
            Name = 'Test opportunity',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Amount = 4000
        );
        insert opp;
        
        Quote quoteNew = new Quote();
        quoteNew.Name = 'Test893';
        quoteNew.OpportunityId = opp.Id;
        quoteNew.RecordTypeId = getRecordTypeId('Links');
        quoteNew.Status = '3';
        insert quoteNew;
        
        Protocol__c protocol = new Protocol__c();
        protocol.Name = '2021-1/1';
        protocol.Quote__c = quoteNew.Id;
        insert protocol;
        
        quoteNew.Protocol__c = protocol.Id;
        update quoteNew;
        
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'test.jpg',
            VersionData = Blob.valueOf('Test'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = protocol.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        Test.startTest();
        TriggerUtilities.TriggerSettingQuote = createCustomMetadata(true);
        QuoteTriggerHelper.hasDocumentProtocol(quoteNew);
        Test.stopTest();  
    }
    
    @isTest
    static void checkStatus(){
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;
        
        Opportunity opp = new Opportunity(
            Name = 'Test opportunity',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Amount = 4000
        );
        insert opp;
        
        Quote quoteOld = new Quote();
        quoteOld.Name = 'Test893';
        quoteOld.OpportunityId = opp.Id;
        quoteOld.RecordTypeId = getRecordTypeId('Links');
        quoteOld.Status = '0';
        insert quoteOld;
        
        Quote quoteNew = new Quote();
        quoteNew.Name = 'Test893';
        quoteNew.OpportunityId = opp.Id;
        quoteNew.RecordTypeId = getRecordTypeId('Links');
        quoteNew.Status = '1';
        insert quoteNew;
        
        Test.startTest();
        TriggerUtilities.TriggerSettingQuote = createCustomMetadata(true);
        QuoteTriggerHelper.checkStatusQuote(quoteNew,quoteOld);
        Test.stopTest();  
        
        
    }
    
}