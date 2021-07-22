/**
 * @description       : 
 * @author            : ↨ -> giuseppe.alemanno@nexusat.it
 * @last modified on  : 15/07/2021
 * @last modified by  : 
**/
@isTest
public class OnQuoteLineItemTrigger_Test {
	@TestSetup
    static void testOnQuoteLineItemTrigger(){
        
        Id stdPriceBookId = test.getStandardPricebookId();
        Id LinksRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Links').getRecordTypeId();
        Id NexusRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('NexusGreaterAmount').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'acc test';
        insert acc;
        
        Opportunity oppLinks = new Opportunity();
        oppLinks.Name = 'Linkstest';
        oppLinks.AccountId = acc.Id;
        oppLinks.CloseDate = date.Today().addDays(5);
        oppLinks.StageName = 'Milestone Planning';
        oppLinks.Pricebook2Id = stdPriceBookId;
        insert oppLinks;
        
        Opportunity oppNexus = new Opportunity();
        oppNexus.Name = 'Nexustest';
        oppNexus.AccountId = acc.Id;
        oppNexus.CloseDate = date.Today().addDays(5);
        oppNexus.StageName = 'Milestone Planning';
        oppNexus.Pricebook2Id = stdPriceBookId;
        insert oppNexus;
        
       Quote qLinks = new Quote();
        qLinks.Name = 'Linksquote';
        qLinks.OpportunityId = oppLinks.Id;
        insert qLinks;

        Quote qNexus = new Quote();
        qNexus.Name = 'Nexusquote';
        qNexus.OpportunityId = oppNexus.Id;
        insert qNexus;
        
        Product2 p = new Product2();
        p.Name = 'pName';
        p.ProductCode = 'pCode';
        p.Family = 'Standard';
		p.isActive = true;
		insert p;
        
		PricebookEntry pbE = new PricebookEntry();
		pbE.Product2Id = p.Id;
		pbE.Pricebook2Id = stdPriceBookId;     
        pbE.InternalCost__c = 1.0;
        pbE.IsActive = true;
        pbE.UnitPrice = 1.0;
		insert pbE;
        
        QuoteLineItem qliLinks = new QuoteLineItem();
        qliLinks.Product2Id = p.Id;
		qliLinks.Quantity = 10;
		qliLinks.UnitPrice = 1.0;
		qliLinks.QuoteId = qLinks.Id;
        qliLinks.PricebookEntryId = pbE.Id;
        
		
		
        QuoteLineItem qliNexus = new QuoteLineItem();
        qliNexus.Product2Id = p.Id;
		qliNexus.Quantity = 10;
		qliNexus.UnitPrice = 1.0;
		qliNexus.QuoteId = qNexus.Id;
        qliNexus.PricebookEntryId = pbE.Id;
		
		insert new List <QuoteLineItem>{qliLinks, qliNexus};
    }
    
    @isTest
    static void testInsertQuoteLineItem(){
        Quote qLinks = [SELECT Id FROM Quote WHERE Name = 'Linksquote'];
        Quote qNexus = [SELECT Id FROM Quote WHERE Name = 'Nexusquote'];
        
		Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry pbE = [SELECT Id FROM PricebookEntry LIMIT 1];
		
        QuoteLineItem qliLinks = new QuoteLineItem();
        qliLinks.Product2Id = prod.Id;
		qliLinks.Quantity = 10;
		qliLinks.UnitPrice = 1.0;
		qliLinks.QuoteId = qLinks.Id;
        qliLinks.PricebookEntryId = pbE.Id;
		
		
        QuoteLineItem qliNexus = new QuoteLineItem();
        qliNexus.Product2Id = prod.Id;
		qliNexus.Quantity = 10;
		qliNexus.UnitPrice = 1.0;
		qliNexus.QuoteId = qNexus.Id;
        qliNexus.PricebookEntryId = pbE.Id;
		
        Test.startTest();
		insert new List <QuoteLineItem>{qliLinks, qliNexus};
        Test.stopTest();

    }
    
    @isTest
    static void testUpdateQuotLineItem(){
        List<QuoteLineItem> qliList = [SELECT Id, UnitPrice FROM QuoteLineItem];
        
        for(QuoteLineItem qli : qliList){
            qli.UnitPrice = 2.0;
        }
        
        Test.startTest();
        update qliList;
        Test.stopTest();
    }
    
    @isTest
    static void testDeleteQuotLineItem(){
        List<QuoteLineItem> qliList = [SELECT Id, UnitPrice FROM QuoteLineItem];
        
        Test.startTest();
        delete qliList;
        Test.stopTest();
    }
}