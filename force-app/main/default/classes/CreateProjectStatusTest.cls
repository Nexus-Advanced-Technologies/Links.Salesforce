@isTest(SeeAllData=true)
public class CreateProjectStatusTest {
    @isTest
    static void createStatusTest(){

        OpportunitySetting__c sett = new OpportunitySetting__c(
           FteWhere__c = 'Name = \'NX-00521 Test\''
        );
        insert sett;

        TriggerCustomSetting__c triggerCustomSetting = new TriggerCustomSetting__c();
        triggerCustomSetting.NexusProjectStatusAfterInsert__c = true;
        triggerCustomSetting.NexusProjectStatusAfterUpdate__c = true;
        triggerCustomSetting.NexusProjectStatusBeforeInsert__c = true;
        triggerCustomSetting.NexusProjectStatusBeforeUpdate__c = true;

        //Insert Account
        Account testAccount = New Account();
        testAccount.Name = 'testAccount 1';
        testAccount.Price_Book__c = Test.getStandardPricebookId();
        insert testAccount;

        Id recStandarId = [SELECT Id, DeveloperName, Name 
                                FROM RecordType
                                WHERE DeveloperName = 'Oppurtunity_Standard'].Id;

        //Insert Opportunity
        Opportunity opp = New Opportunity();
        opp.Name = 'NX-00521 Test';
        opp.AccountId = testAccount.Id;
        opp.RecordTypeId = recStandarId;
        opp.CloseDate = Date.today();
        opp.StageName = 'Closed Won';
        insert opp;

        //Insert Quote
        Quote quoteTest = New Quote();
        quoteTest.Name = 'test';
        quoteTest.OpportunityId = opp.Id;
        quoteTest.Status = 'Accepted'; 
        insert quoteTest;

        Opportunity opp1 = [SELECT Id, Name, SyncedQuoteId FROM Opportunity WHERE name = 'NX-00521 Test'];
        opp1.SyncedQuoteId = quoteTest.Id;
        update opp1;

        Test.startTest();
        List<Id> listOppId = new List<Id>();
        Id oppId = [SELECT Id, Name, SyncedQuoteId FROM Opportunity WHERE name = 'NX-00521 Test'].Id;
        listOppId.add(oppId);
        CreateProjectStatus.createProjectStatusInvocable(listOppId);
        Test.stopTest();
    }
}