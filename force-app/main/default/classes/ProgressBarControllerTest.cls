@isTest
public class ProgressBarControllerTest {
    @TestSetup
    static void makeData(){
        //Insert Account
        Account testAccount = New Account(Name = 'testAccount');
        insert testAccount;
        //Insert Contact
        Contact testContactCustomer = new Contact(FirstName = 'Test', LastName = 'Test', AccountId = testAccount.Id);
        insert testContactCustomer;
        //Insert Opportunity -->Recursive
        Opportunity opp = New Opportunity();
        opp.Name = 'oppTest';
        opp.AccountId = testAccount.Id;
        opp.CloseDate = Date.today();
        opp.StageName = 'Prospecting';
        insert opp;
        //Get RecordType of Invoice_Milestone__c
        Id invMilRecTypId = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'Recursive'].Id;
         //Insert Invoice_Milestone__c
        Invoice_Milestone__c imTest = New Invoice_Milestone__c();
        imTest.Name = 'Invoice Milestone Test';
        imTest.Opportunity__c = opp.Id;
        imTest.Data_prevista__c = Date.today();
        imTest.RecordTypeId = invMilRecTypId;
        imTest.Ammontare__c = 1000;
        imTest.Stato__c = 'Fattura Inviata';
        insert imTest;
    }
    @isTest
    static void getOppFieldsTest(){
        Opportunity opp = [SELECT Id 
                    FROM Opportunity
                    LIMIT 1];
        Id oppId = opp.Id;
        ProgressBarController.getOppFields(oppId);
    }
}