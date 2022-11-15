/**
 * @description       : 
 * @author            : mattia.miglietta@nexusat.it
 * @last modified on  : 14-11-2022
 * @last modified by  : mattia.miglietta@nexusat.it
**/
public with sharing class createDocumentDetailAlyanteController {
    @AuraEnabled (cacheable=true)
    public static Map<String, String> getRecordDefaultValues(String documentRecordId){
        Map<String, String> fieldValues = new Map<String, String>();
        try {
            List <OpportunityDocumentAlyante__c> oppDocuments = [SELECT Id, Opportunity__c FROM OpportunityDocumentAlyante__c WHERE DocumentAlyante__c = :documentRecordId];
            if(oppDocuments.size() > 0) {
                ProjectStatus__c proj = [SELECT Id FROM ProjectStatus__c WHERE Opportunity__c = :oppDocuments[0].Opportunity__c LIMIT 1];
                fieldValues.put('Project__c', proj.Id);
            }
            return fieldValues;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}