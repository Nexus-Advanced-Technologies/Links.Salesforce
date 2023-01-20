/**
 * @description       : 
 * @author            : mattia.miglietta@nexusat.it
 * @last modified on  : 15-11-2022
 * @last modified by  : mattia.miglietta@nexusat.it
**/
@isTest
public with sharing class DocumentDetailControllerTest {
    @TestSetup
    static void makeData(){
        DocumentAlyante__c doc = new DocumentAlyante__c();
        insert doc;
        Opportunity opp = new Opportunity(Name='test', StageName='test', CloseDate=System.today());
        insert opp;
        OpportunityDocumentAlyante__c oppAndDoc = new OpportunityDocumentAlyante__c(Opportunity__c=opp.Id, DocumentAlyante__c = doc.Id);
        insert oppAndDoc;
        ProjectStatus__c proj  = new ProjectStatus__c(Opportunity__c= opp.Id);
        insert proj;
    }
    @isTest
    static void getProjectTest() {
        DocumentAlyante__c doc = [SELECT Id FROM DocumentAlyante__c LIMIT 1];
        createDocumentDetailAlyanteController.getRecordDefaultValues(doc.Id);
    }
}