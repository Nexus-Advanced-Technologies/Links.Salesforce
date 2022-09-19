/**
 * @description       : 
 * @author            : Massimo Frangiamore
 * @group             : 
 * @last modified on  : 19/09/2022
 * @last modified by  : francesco.coli@nexusat.it
**/
public with sharing class createIntranetQuote {
    private static IntranetQuoteGeneration__c settings;
    private static IntranetQuoteGeneration__c getSettings() {
        if(settings == null){
               settings = IntranetQuoteGeneration__c.getOrgDefaults();
        }
        return settings;
        
    }
    @AuraEnabled
    public static void uploadFile(String base64, String filename, String recordId) {
        system.debug('si sono qui');
        Opportunity opportunity = getOpportunity(recordId);
        //Id rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Links' and SobjectType = 'Quote'].Id;
        //Id opQ = [SELECT OpportunityId FROM Quote WHERE OpportunityId = :recordId AND RecordTypeId = :rt LIMIT 1].OpportunityId;      
        if(string.isBlank(fileName)){
            throw new  AuraHandledException('Missing file');
        }
        try{
        canCreateQuote(recordId);
            if (!String.isBlank(opportunity.PaymentType__c)) {     
                Quote quote = generateQuote(opportunity);
                toVerified(quote);
                QuoteTriggerHelper.generateContentVersionPDF(quote.Id);
                quote = toRegistered(quote);
                attachFileToProtocol(quote, base64, filename);
                toPresented(quote);
                toApproved(quote);
                attachFileToOrder(quote,base64,filename);
                opportunity.StageName = opportunity.StageName;
                update opportunity;
            } else {
                throw new AuraHandledException('Payment Type is blank');
            }
        // } else {
        //     throw new AuraHandledException('Links quote already generated');   
        // }
            }   catch(Exception e){
                System.debug(e.getStackTraceString());
                System.debug(e.getMessage());
                throw new AuraHandledException(e.getMessage());   
            }       
    }
    private static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        try {
            insert cv;
            return cv;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
        SELECT ContentDocumentId 
        FROM ContentVersion 
        WHERE Id =: contentVersionId
        ].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        // ShareType is either 'V', 'C', or 'I'
        // V = Viewer, C = Collaborator, I = Inferred
        cdl.ShareType = 'V';
        try {
            insert cdl;
        return cdl;
        } catch(DMLException e) {
            System.debug(e);
        return null;
        }
    }
    
    private static Quote generateQuote(Opportunity opportunity){
        Id recordTypeId =Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Links').getRecordTypeId();
        Pricebook2 priceBook = new Pricebook2();
        priceBook = [SELECT Id FROM Pricebook2 WHERE ExtId__c = :getSettings().PriceBookName__c];
        Quote quote = new Quote();
        quote.Name = opportunity.Name;
        quote.RecordTypeId = recordTypeId;
        quote.Pricebook2Id = priceBook.Id;
        quote.StartDate__c = Date.today();
        quote.OpportunityId = opportunity.Id;
        quote.isMinMarginValid__c = true;
        
        insert quote;
        generateRevenue(quote, opportunity);
        generateQuoteLine(quote, opportunity);
        return quote;
    }

    private static Opportunity getOpportunity(id OppId){
        return [SELECT Id, Name, Amount, PaymentType__c, StageName FROM Opportunity WHERE Id = :OppId];
    }

    private static void generateRevenue(Quote q, Opportunity o) {
        Quote_Revenue__c revenue = new Quote_Revenue__c();
        revenue.Revenue_Type__c = getSettings().RevenueType__c; 
        revenue.Quote__c = q.Id;
        revenue.LinksRevenue__c = o.Amount;
        insert revenue;
    } 

    private static void toVerified(Quote q){
        q.Status = '1';
        update q;

    }
    private static Quote toRegistered(Quote q){
        q.Status = '2';
        update q;
        q = [SELECT Id, Protocol__c FROM Quote WHERE Id = :q.Id];
        return q;
    }
    private static void attachFileToProtocol(Quote q,String base64, String filename){
        ContentVersion cv = createContentVersion(base64, filename);
        system.debug(cv.Id);
        system.debug(q.Protocol__c);
        createContentLink(cv.Id, q.Protocol__c);
    }
    private static void toPresented(Quote q){
        q.Status = '3';
        update q;
    }
    private static void generateQuoteLine(Quote q, Opportunity o){
        QuoteLineItem qli = New QuoteLineItem();
        Product2 prd = [SELECT Id FROM Product2 WHERE Name = :getSettings().ProductName__c AND ProductCode = :getSettings().ProductCode__c LIMIT 1]; 
        PricebookEntry pbe = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Product2Id = :prd.Id AND Pricebook2Id = :q.Pricebook2Id];
        RevenueTypesCS__c rcs = [SELECT DefaultMargin__c FROM RevenueTypesCS__c WHERE Name='Fixed-Price Projects/Services'];
        System.debug('rcs: '+rcs);
        qli.QuoteId = q.Id;
        qli.Product2Id = prd.Id;
        qli.Quantity = 1;
        qli.UnitPrice = pbe.UnitPrice;
        qli.Revenue_Type__c = getSettings().RevenueType__c;  
        qli.PricebookEntryId = pbe.Id;
        qli.DDTotal__c = (Integer)(((o.Amount*(100-rcs.DefaultMargin__c))/100)/pbe.UnitPrice).Round(System.RoundingMode.DOWN);
        insert qli;
   
    }
    private static void toApproved(Quote q){
        q.Status = '4';
        update q;
    }
    private static void attachFileToOrder(Quote q,String base64, String filename){
        ContentVersion cv = createContentVersion(base64, filename);
        Order ord = new Order();
        ord = [SELECT Id FROM Order WHERE QuoteId = :q.Id];
        createContentLink(cv.Id, ord.Id);
    }
    public static void canCreateQuote(Id oppId){
    List<Quote> quoteList = [SELECT Id FROM Quote WHERE OpportunityId = :oppId];
            if(quoteList.size() > 0){
                throw new AuraHandledException('Cannot create quote');
            }     
    }

}
