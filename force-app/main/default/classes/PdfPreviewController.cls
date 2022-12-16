/**
 * @description       : 
 * @author            : mattia.miglietta@nexusat.it
 * @last modified on  : 16/12/2022
 * @last modified by  : ¤ → alessio.marra@nexusat.it
**/
public with sharing class PdfPreviewController {
    @AuraEnabled(cacheable=true)
    public static IntranetAPI__c getCredentials() {
        return IntranetAPI__c.getOrgDefaults();
    }

    @AuraEnabled
    public static DocumentAlyante__c getDocumentRecord(Id recordId) {
        DocumentAlyante__c document = [SELECT Id, ExtIdAlyante__c FROM DocumentAlyante__c WHERE Id = :recordId LIMIT 1];
        if (document == null) {
            throw new AuraHandledException('Document not found');
        }
        return document;
    }
}
