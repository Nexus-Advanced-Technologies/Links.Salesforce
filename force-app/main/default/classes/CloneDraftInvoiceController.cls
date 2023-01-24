/**
 * @description       : 
 * @author            : §
 * @group             : 
 * @last modified on  : 01-31-2022
 * @last modified by  : §
**/
public class CloneDraftInvoiceController {
    
    @AuraEnabled(cacheable=true)
    public static List<Id> fetchOpportunityId(Id recordId){
        
        List<OpportunityDocumentAlyante__c> oppDocIdList = [SELECT Opportunity__c FROM OpportunityDocumentAlyante__c WHERE DocumentAlyante__c = :recordId];
        Set<Id> ids = new Set<Id>();
        for(OpportunityDocumentAlyante__c v : oppDocIdList){
            ids.add(v.Opportunity__c);
        }
        return new List<Id>(ids);
    }  
    
    @AuraEnabled(cacheable=true)
    public static List<Id> fetchInvoiceMilestoneId(Id recordId){
        
        List<InvoiceMilestoneDocumentAlyante__c> invoiceMilestoneIdList = [SELECT InvoiceMilestone__c FROM InvoiceMilestoneDocumentAlyante__c WHERE DocumentAlyante__c = :recordId];
        Set<Id> ids = new Set<Id>();
        for(InvoiceMilestoneDocumentAlyante__c v : invoiceMilestoneIdList){
            ids.add(v.InvoiceMilestone__c);
        }
        return new List<Id>(ids);
    }

    @AuraEnabled
    public static void cloneDocumentDetails(Id recordId, Id clonedDocumentId){
        List<DocumentDetailAlyante__c> documentDetails = new List<DocumentDetailAlyante__c>();

        documentDetails = [SELECT Amount__c, Content__c, Document__c, EndCompetence__c, Project__c, RevenueType__c, StartCompetence__c, Tags__c
                           FROM DocumentDetailAlyante__c
                           WHERE Document__c = :recordId];

        List<DocumentDetailAlyante__c> clonedList = documentDetails.deepClone(false, false, false);

        for(DocumentDetailAlyante__c clone : clonedList) {
            clone.Document__c = clonedDocumentId;
        }

         try {
            insert clonedList;    
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<DocumentDetailAlyante__c> getDocumentDetails(Id recordId){
        List<DocumentDetailAlyante__c> documentDetails = new List<DocumentDetailAlyante__c>();
        try {
            documentDetails = [SELECT Amount__c, Name, Content__c, Document__c, EndCompetence__c, Project__c, Project__r.Name, RevenueType__c, StartCompetence__c, Tags__c
                            FROM DocumentDetailAlyante__c
                            WHERE Document__c = :recordId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return documentDetails;
    }    
    @AuraEnabled
    public static List<DocumentDetailAlyante__c> createDocumentDetails(List<DocumentDetailAlyante__c> documentDetails) {
        try {
            insert documentDetails;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return documentDetails;
    }
    @AuraEnabled
    public static void deleteDocument(Id docId){
        DocumentAlyante__c doc = new DocumentAlyante__c(Id = docId);
        try {
            delete doc;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}