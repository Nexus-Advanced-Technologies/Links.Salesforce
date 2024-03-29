/**
* @description       : 
* @author            : 
* @last modified on  : 19/10/2022
* @last modified by  : ¤ → alessio.marra@nexusat.it
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

    private static Id getOpportunityRecordTypeId(String name) {
        return [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = :name LIMIT 1].Id;
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
            Status = '0',
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
        
        Opportunity opportunity = new Opportunity(
            Name = 'Test opportunity',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            PaymentType__c = pt.Id,
            Amount = 4000
        );
        insert opportunity;

        Quote quote = new Quote(
            Name = 'Quote',
            OpportunityId = opportunity.Id,
            Status = '0',
            RecordTypeId = getRecordTypeId('Links')
        );
        insert quote;
        Quote quoteOld = quote.clone(false, true, true, true);
        
        Test.startTest();
        TriggerUtilities.TriggerSettingQuote = createCustomMetadata(true);

        quote.Status = '3';
        QuoteTriggerHelper.setOpportunityAmount(quote, quoteOld);

        quote.Status = '4';
        QuoteTriggerHelper.setOpportunityAmount(quote, quoteOld);

        quote.Status = '5';
        QuoteTriggerHelper.setOpportunityAmount(quote, quoteOld);
        Test.stopTest();
    }
    
    @isTest
    static void testGenerateQuoteNumber(){
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;
        
        Opportunity opportunity1 = new Opportunity(
            Name = 'Test opportunity 1',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Amount = 4000
        );
        Opportunity opportunity2 = new Opportunity(
            Name = 'Test opportunity 2',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Amount = 4000
        );
        insert new List<Opportunity>{ opportunity1, opportunity2 };

        List<Quote> quotes = new List<Quote>();
        Quote quote1 = new Quote(
            Name = 'Test 1',
            RecordTypeId = getRecordTypeId('Links'),
            OpportunityId = opportunity1.Id,
            Status = '0'
        );
        quotes.add(quote1);
        Quote quote2 = new Quote(
            Name = 'Test 2',
            RecordTypeId = getRecordTypeId('Links'),
            OpportunityId = opportunity2.Id,
            Status = '0'
        );
        quotes.add(quote2);
        insert quotes;

        Test.startTest();
        TriggerUtilities.TriggerSettingQuote = createCustomMetadata(true);
        QuoteTriggerHelper.generateQuoteNumber(quotes);
        Test.stopTest();
    }
    
    @isTest
    static void testProtocolNumber(){
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;
        
        Opportunity opportunity = new Opportunity(
            Name = 'Test opportunity',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Amount = 4000
        );
        insert opportunity;
        
        Quote quote = new Quote(
            Name = 'Quote',
            OpportunityId = opportunity.Id,
            Status = '0',
            RecordTypeId = getRecordTypeId('Links')
        );
        insert quote;
        Quote quoteOld = quote.clone(false, true, true, true);
        
        Test.startTest();
        TriggerUtilities.TriggerSettingQuote = createCustomMetadata(true);
        
        quote.Status = '1';
        quoteOld.Status = '2';
        List<Quote> newList = new List<Quote>{ quote };
        Map<Id,Quote> oldmap = new Map<Id,Quote>{
            quote.Id => quoteOld
        };
        QuoteTriggerHelper.generateProtocolNumber(newList,oldmap);
        Test.stopTest();
    }
    
    
    @isTest
    static void testResetProtocolNumber(){
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;
        
        Opportunity opportunity = new Opportunity(
            Name = 'Test opportunity',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Amount = 4000
        );
        insert opportunity;
        
        Quote quote = new Quote(
            Name = 'Quote',
            OpportunityId = opportunity.Id,
            Status = '0',
            RecordTypeId = getRecordTypeId('Links')
        );
        insert quote;
        Quote quoteOld = quote.clone(false, true, true, true);
        
        Test.startTest();
        TriggerUtilities.TriggerSettingQuote = createCustomMetadata(true);
        
        quote.Status = '1';
        List<Quote> newList = new List<Quote>{ quote };
        Map<Id,Quote> oldmap = new Map<Id,Quote>{
            quote.Id => quoteOld
        };
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
        quoteNew.Status = '0';
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
        
        Opportunity opportunity = new Opportunity(
            Name = 'Test opportunity',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Amount = 4000
        );
        insert opportunity;
        
        Quote quote = new Quote(
            Name = 'Quote',
            OpportunityId = opportunity.Id,
            Status = '0',
            RecordTypeId = getRecordTypeId('Links')
        );
        insert quote;
        Quote quoteOld = quote.clone(false, true, true, true);
        
        Test.startTest();
        TriggerUtilities.TriggerSettingQuote = createCustomMetadata(true);

        quote.Status = '1';
        QuoteTriggerHelper.checkStatusQuote(quote,quoteOld);
        Test.stopTest();
    }
       
    @isTest
    static void testGenerateOrder(){
            Account acc = new Account(
                Name = 'Test Account'
            );
            insert acc;
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

            Pricebook2 customPB = new Pricebook2(Name='Links', 
                                isActive=true);
            insert customPB;
                
            PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, 
            Product2Id = prod.Id,
            UnitPrice = 1200, 
            IsActive = true);
            insert customPrice;
            //***************************************************************************** */
            Opportunity opportunity = new Opportunity(
                Name = 'Test opportunity',
                AccountId = [SELECT id FROM Account LIMIT 1].Id,
                StageName = 'Prospecting',
                RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Links' LIMIT 1].Id,
                CloseDate = Date.today(),
                Pricebook2Id=[SELECT id FROM Pricebook2 LIMIT 1].Id
            );
            insert opportunity;
                
            Quote quote = new Quote();
            quote.Name = 'Test893';
            quote.OpportunityId = opportunity.Id;
            quote.RecordTypeId = getRecordTypeId('Links');
            insert quote;

            Quote quoteNew = [SELECT Id,AccountId,Total_Revenue__c,Name,Pricebook2Id FROM Quote WHERE Id =: quote.Id];

            Quote_Revenue__c revenue = new Quote_Revenue__c();
            revenue.Revenue_Type__c = '6';
            revenue.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Revenue__c' AND DeveloperName = 'Links' LIMIT 1].Id;
            revenue.LinksRevenue__c	 = 50000;
            revenue.Quote__c = quoteNew.Id;
            insert revenue;

            
            QuoteLineItem quoteLineItem = new QuoteLineItem(
                Product2Id=prod.Id,
                Revenue_Type__c='6',
                Quantity=1,
                QuoteId=quote.id,
                PricebookEntryId=customPrice.id,
                DDTotal__c=5,
                TotalCostHR__c=100,
                DDOvernightAllowance__c = 1,
                DDTravelAllowance__c = 1,
                Description = 'test',
                UnitPrice=customPrice.UnitPrice);
            insert quoteLineItem;

            Cost__c cost = new Cost__c(Revenue_Type__c='6',Quantity__c=1,Quote__c=quoteNew.id,Cost_Value__c=5);
            insert cost;

            RevenueTypesCS__c rtCS = new RevenueTypesCS__c();
            rtCS.Name = 'Prestazioni di Servizi';
            rtCS.DefaultMargin__c = 30;
            rtCS.MinMargin__c = 20;
            insert rtCS;

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
            List<Quote> listQuote = new List<Quote>();
            listQuote.add(quoteNew);
            
            Test.startTest();
            TriggerUtilities.TriggerSettingQuote = createCustomMetadata(true);
            QuoteTriggerHelper.generateOrder(listQuote);
            Test.stopTest(); 
    }

    @isTest
    private static void testCheckOneQuoteForOpportunitySuccess() {
        Account account = new Account(
            Name = 'Test Account'
        );
        insert account;

        Opportunity opportunity = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = account.Id,
            StageName = 'Prospecting',
            RecordTypeId = getOpportunityRecordTypeId('Links'),
            CloseDate = Date.today()
        );
        insert opportunity;

        Quote quote = new Quote(
            Name = 'Test Quote',
            OpportunityId = opportunity.Id,
            RecordTypeId = getRecordTypeId('Links')
        );

        Test.startTest();
        TriggerUtilities.TriggerSettingQuote = createCustomMetadata(true);
        insert quote;
        Test.stopTest();

        Integer count = (Integer)[SELECT count(Id) c FROM Quote][0].get('c');
        System.assertEquals(1, count, 'The quote should have been created');
    }

    @isTest
    private static void testCheckOneQuoteForOpportunityError() {
        Account account = new Account(
            Name = 'Test Account'
        );
        insert account;

        Opportunity opportunity = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = account.Id,
            StageName = 'Prospecting',
            RecordTypeId = getOpportunityRecordTypeId('Links'),
            CloseDate = Date.today()
        );
        insert opportunity;
        
        TriggerUtilities.TriggerSettingQuote = createCustomMetadata(true);
        Quote quote = new Quote(
            Name = 'Test Quote',
            OpportunityId = opportunity.Id,
            RecordTypeId = getRecordTypeId('Links')
        );
        insert quote;

        Quote otherQuote = new Quote(
            Name = 'Test Quote equal opportunity',
            OpportunityId = opportunity.Id,
            RecordTypeId = getRecordTypeId('Links')
        );

        Test.startTest();
        TriggerUtilities.TriggerSettingQuote = createCustomMetadata(true);

        try {
            insert otherQuote;
            System.assert(false);
        } catch (DmlException e) {
            System.assert(true);
        }
        Test.stopTest();

        Integer count = (Integer)[SELECT count(Id) c FROM Quote][0].get('c');
        System.assertEquals(1, count, 'The quote should have been created');
    }
}