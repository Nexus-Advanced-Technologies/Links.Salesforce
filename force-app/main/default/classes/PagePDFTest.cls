@isTest 
public class PagePDFTest 
{
      public static String getRecordTypeId(String sobjectName, String recordTypeName){
		
		return Schema.getGlobalDescribe().get(sobjectName).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
	}
    @isTest
    static void testMethod1() 
    {
    
        Account account = new Account (RecordTypeId = getRecordTypeId('Account','Nexus'),Name='Test');
        insert account;
        Contact contact = new Contact (RecordTypeId = getRecordTypeId('Contact','Links'),LastName='Test');
        insert contact;
        Product2 prod = new Product2(Name = 'Intern 2021',
                                     Family = 'Standard',
                                     ProductCoDe = 'IN',
                                     IsActive = true);
        insert prod;
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
        
        Opportunity opportunity = new Opportunity (RecordTypeId = getRecordTypeId('Opportunity','Links'),Name='Test',AccountId=account.Id,CloseDate=Date.today(),StageName='Prospecting',Pricebook2Id=customPB.Id);
        insert opportunity;
        
        Quote quote = new Quote(RecordTypeId = getRecordTypeId('Quote','Links'),Name='Test',OpportunityId = opportunity.id);
        insert quote;
        QuoteLineItem quoteLineItem = new QuoteLineItem(Product2Id=prod.Id,Revenue_Type__c='6',Quantity=1,QuoteId=quote.id,PricebookEntryId=customPrice.id,DDTotal__c=5,UnitPrice=customPrice.UnitPrice);
        insert quoteLineItem;
        Cost__c cost = new Cost__c(Revenue_Type__c='6',Quantity__c=1,Quote__c=quote.id,Cost_Value__c=5);
        insert cost;
        Quote_Revenue__c quoteRevenue = new Quote_Revenue__c(Revenue_Type__c='6',Quote__c=quote.id,LinksRevenue__c=5);
        insert quoteRevenue;
        
        
        RevenueTypesCS__c rtCS = new RevenueTypesCS__c();
        rtCS.Name = 'Prestazioni di Servizi';
        rtCS.DefaultMargin__c = 30;
        rtCS.MinMargin__c = 20;
        insert rtCS;
        
        Test.StartTest(); 
        
        ApexPages.currentPage().getParameters().put('id',quote.id);
        ApexPages.StandardController pdf = new ApexPages.StandardController(quote);
        PagePDF objQuote = new PagePDF();
        objQuote.getQuoteObj();
        objQuote.getQuoteLineItem();
        objQuote.getCostObj();
        objQuote.getEconomicPlanPDF();
        objQuote.getTotalEconomicPlanPDF();
        
        Test.StopTest();
    }
}