/**
 * @description       : 
 * @author            : Massimo Frangiamore
 * @group             : 
 * @last modified on  : 13/09/2022
 * @last modified by  : francesco.coli@nexusat.it
**/
public with sharing class createIntranetQuote {
    @AuraEnabled
    public static void uploadFile(String base64, String filename, String recordId) {
        system.debug('si sono qui');
        Opportunity o = getOpportunity(recordId);
        String s = o.StageName;
        String ops = [SELECT PaymentType__c  FROM Opportunity WHERE Id = :recordId LIMIT 1].PaymentType__c;      
        try{
        if (!String.isBlank(ops)) {           
            Quote q = generateQuote(o);
        generateQuoteLine(q, o);
        toVerified(q);
        QuoteTriggerHelper.generateContentVersionPDF(q.Id);
        q = toRegistered(q);
        attachFileToProtocol(q, base64, filename);
        toPresented(q);
        toApproved(q);
        attachFileToOrder(q,base64,filename);
        o.StageName = s;
        update o;
        } else {
            throw new AuraHandledException('Payment Type is blank');   
        }
            }   catch(Exception e){
                System.debug(e);
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
    
    private static Quote generateQuote(Opportunity op){
        Id recordTypeId =Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Links').getRecordTypeId();
        Pricebook2 pb = new Pricebook2();
        pb = [SELECT Id FROM Pricebook2 WHERE ExtId__c ='Links2022'];
        Quote q = new Quote();
        q.Name = op.Name;
        q.RecordTypeId = recordTypeId;
        q.Pricebook2Id = pb.Id;
        q.StartDate__c = Date.today();
        q.OpportunityId = op.Id;
        q.isMinMarginValid__c = true;
        
        insert q;
        generateRevenue(q, op);
        return q;
    }

    private static Opportunity getOpportunity(id OppId){
        return [SELECT Id, Name, Amount, PaymentType__c, StageName FROM Opportunity WHERE Id = :OppId];
    }

    private static void generateRevenue(Quote q, Opportunity o) {
        Quote_Revenue__c revenue = new Quote_Revenue__c();
        revenue.Revenue_Type__c = '6';
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
        Product2 prd = [SELECT Id FROM Product2 WHERE Name = 'Consultant' AND ProductCode = 'CS' LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE Product2Id = :prd.Id AND ExtId__c = 'LINKS1087'];
        RevenueTypesCS__c rcs = [SELECT DefaultMargin__c FROM RevenueTypesCS__c WHERE Name='Fixed-Price Projects/Services'];
        Integer DDTotal = Integer.valueOf(((o.Amount*Integer.valueOf(rcs.DefaultMargin__c))/100)/175);
        qli.QuoteId = q.Id;
        qli.Product2Id = prd.Id;
        qli.Quantity = 1;
        qli.UnitPrice = 175.00;
        qli.Revenue_Type__c = '6';
        qli.PricebookEntryId = pbe.Id;
        qli.DDTotal__c = DDtotal;
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

}
