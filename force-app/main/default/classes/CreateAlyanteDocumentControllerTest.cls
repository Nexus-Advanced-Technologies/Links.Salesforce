/**
 * @description       : 
 * @author            : ¤ → alessio.marra@nexusat.it
 * @last modified on  : 21/02/2022
 * @last modified by  : ¤ → alessio.marra@nexusat.it
**/
@IsTest
public class CreateAlyanteDocumentControllerTest {
    @TestSetup
    static void makeData() {
        
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today()
        );
        insert opp;

        InvoiceMilestone__c inv = new InvoiceMilestone__c(
            Name = 'Test Invoice Milestone',
            Opportunity__c = opp.Id,
            ExpectedDate__c = Date.today()
        );
        insert inv;
    }

    @IsTest
    static void fetchOpportunityOptionsTest() {
        List<Opportunity> opps = [SELECT Id FROM Opportunity];
        List<Id> oppIds = new List<Id>();
        for (Opportunity variable : opps) {
            oppIds.add(variable.Id);
        }
        
        Test.startTest();
        List<Opportunity> ret = CreateAlyanteDocumentController.fetchOpportunityOptions(oppIds);
        Test.stopTest();
        
        System.assertEquals(opps.size(), ret.size());
    }

    @IsTest
    static void fetchOpportunityOptionsExceptionTest() {
        Test.startTest();
        try {
            List<Opportunity> ret = CreateAlyanteDocumentController.fetchOpportunityOptions(null);
            System.assert(false);
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @IsTest
    static void fetchMilestoneOptionsTest() {
        List<InvoiceMilestone__c> invs = [SELECT Id FROM InvoiceMilestone__c];
        List<Id> invIds = new List<Id>();
        for (InvoiceMilestone__c variable : invs) {
            invIds.add(variable.Id);
        }
        
        Test.startTest();
        List<InvoiceMilestone__c> ret = CreateAlyanteDocumentController.fetchMilestoneOptions(invIds);
        Test.stopTest();
        
        System.assertEquals(invs.size(), ret.size());
    }

    @IsTest
    static void fetchMilestoneOptionsExceptionTest() {
        Test.startTest();
        try {
            List<InvoiceMilestone__c> ret = CreateAlyanteDocumentController.fetchMilestoneOptions(null);
            System.assert(false);
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }
}