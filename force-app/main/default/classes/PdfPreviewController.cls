/**
 * @description       : 
 * @author            : mattia.miglietta@nexusat.it
 * @last modified on  : 15-12-2022
 * @last modified by  : mattia.miglietta@nexusat.it
**/
public with sharing class PdfPreviewController {
    @AuraEnabled(cacheable=true)
    public static String getExtIdAlyante(String recordId, IntranetAPI__c credentials){
        String extId;
        try {
            extId = [SELECT ExtIdAlyante__c FROM DocumentAlyante__c WHERE Id =:recordId].ExtIdAlyante__c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return extId;
    }
    @AuraEnabled(cacheable=true)
    public static IntranetAPI__c getCredentials(){
        IntranetAPI__c credentials = new IntranetAPI__c();
        try {
            credentials = IntranetAPI__c.getInstance('SalesforceDEV');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return credentials;
    }
}
