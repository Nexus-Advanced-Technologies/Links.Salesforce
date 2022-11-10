/**
 * @description       : 
 * @author            : §
 * @group             : 
 * @last modified on  : 01-28-2022
 * @last modified by  : §
**/
public class CreateAlyanteDocumentController {
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> fetchOpportunityOptions(List<Id> opprtunityIds) {
        List<Opportunity> oppList = new List<Opportunity>();

        try {
            oppList = [SELECT Id, Name FROM Opportunity WHERE Id IN :opprtunityIds];    
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return oppList;
    }

    @AuraEnabled(cacheable=true)
    public static List<InvoiceMilestone__c> fetchMilestoneOptions(List<Id> milestoneIds) {
        List<InvoiceMilestone__c> milestoneList = new List<InvoiceMilestone__c>();
        try {
            milestoneList = [SELECT Id, Name FROM InvoiceMilestone__c WHERE Id IN :milestoneIds];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return milestoneList;
    }
}