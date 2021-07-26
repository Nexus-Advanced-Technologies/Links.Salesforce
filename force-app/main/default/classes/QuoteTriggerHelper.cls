/**
 * @description       : 
 * @author            : Œ
 * @last modified on  : 16-07-2021
 * @last modified by  : Œ
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   22-04-2021   Œ   Initial Version
 * 1.1   23-04-2021   RC   Add Method generateContentVersionPDF and checkRegisteredStatus for generatinf PDF Page on File Section
 * 1.2   12-05-2021   RC   setOpportunityAmount
**/
public class QuoteTriggerHelper {
    
    /**
Assign account pricebook to quotes. 
If account has not pricebook assigned, it's assigned standard one.
*/
    public static void assignAccountPricebookToQuote(List<Quote> quotes){
        List<Quote> quoteList = [
            SELECT Id,AccountId,Pricebook2Id
            FROM Quote 
            WHERE Id IN :quotes 
        ];
        
        System.debug('quotes: '+quoteList);
        List<Id> accountIds = new List<Id>();
        
        for(Quote q : quoteList) {
            System.debug('Account: '+q.AccountId);
            accountIds.add(q.AccountId);            
        }
        Map<Id,Account> accounts = new Map<Id,Account>(
            [SELECT Id,PriceBook__c,Name
             FROM Account
             WHERE Id IN :accountIds ]
        );
        System.debug('Map Account: '+accounts);
        Pricebook2 standardPriceBook;
        if(Test.isRunningTest()) {
            standardPriceBook = new Pricebook2(Id = Test.getStandardPricebookId());
        } else {
            standardPriceBook = [
            SELECT Id,IsActive,IsStandard,Name 
            FROM Pricebook2 
            WHERE IsActive = true 
            AND IsStandard = true 
        ];
        }
        System.debug('Standard PriceBook: '+standardPriceBook);
        for(Quote q : quoteList) {
            System.debug('Quote PriceBook before update: '+q.Pricebook2Id);
            System.debug('Account: '+q.AccountId);
            if(q.AccountId != null){
                Account a = accounts.get(q.AccountId);
                System.debug('Account: '+a.Id+' '+a.Name+' - PriceBook: '+a.PriceBook__c);
                if(a.PriceBook__c != null){
                    q.Pricebook2Id = a.PriceBook__c;
                } else {
                    q.Pricebook2Id = standardPriceBook.Id;
                }
            } else {
                q.Pricebook2Id = standardPriceBook.Id;
            }
            System.debug('Quote PriceBook after update: '+q.Pricebook2Id);
        }
        if (!quoteList.isEmpty()) {
            update quoteList;
        }
    }
    @future(callout = true)
    public static void generateContentVersionPDF(Id quoteId){
        Quote q = [SELECT Id, Name, LastModifiedDate FROM Quote WHERE Id = :quoteId];
		String formattedDate = q.LastModifiedDate.format('dd-MM-yyyy');
        ContentVersion conVer = new ContentVersion();
        PageReference PDf =  Page.ViewPDFPage;
        PDf.getParameters().put('Id',q.Id);
        PDf.setRedirect(true);
        Blob b ;
        if(!Test.isRunningTest()){
            b = PDf.getContent();
        }else{
            b = Blob.valueOf('Hello');
        }
        conVer.ContentLocation = 'S'; 
        conVer.PathOnClient = '.pdf';
        conVer.Title = 'Economic Plan '+ q.Name + ' ' + formattedDate; 
        conVer.VersionData = b;
        insert conVer;    
        
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = q.Id; 
        conDocLink.ContentDocumentId = conDoc;  
        conDocLink.shareType = 'V';
        insert conDocLink;
       
    }
    public static  Boolean checkRegisteredStatus(Quote quoteNew, Quote quoteOld){
        Boolean statusCheck;
        if(quoteNew.Status == '3' && quoteOld.Status == '2'){
            statusCheck = true;
        }else{
            statusCheck=false;
        }
        return statusCheck;
    }


    public static void setOpportunityAmount(Quote quoteNew){
        List<Opportunity> opportunityToUpdate = new List<Opportunity>(); 
        Id opportunityId = quoteNew.OpportunityId;
            for(Quote q : [SELECT Id, OpportunityId, Total_Revenue__c, Opportunity.Amount, Status, Opportunity.StageName
                           FROM Quote 
                           WHERE OpportunityId =:opportunityId]){
                    if(quoteNew.Id == q.Id && quoteNew.Status == '4'){
                        Opportunity opp = new Opportunity();
                        opp.Id = quoteNew.OpportunityId;
                        opp.Amount = q.Total_Revenue__c;
                        opp.StageName = 'Milestone Planning';
                        opportunityToUpdate.add(opp);
                    } else if(quoteNew.Id == q.Id && quoteNew.Status == '5'){
                        Opportunity opp = new Opportunity();
                        opp.Id = quoteNew.OpportunityId;
                        opp.Amount = q.Total_Revenue__c;
                        opp.StageName = 'Closed Lost';
                        opportunityToUpdate.add(opp);
                        }
                    }
        update opportunityToUpdate;
        }
}