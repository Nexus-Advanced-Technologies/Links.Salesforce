/**
 * @description       : 
 * @author            : 
 * @last modified on  : 25/01/2021
 * @last modified by  : ¤ → alessio.marra@nexusat.it
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0                                               Initial Version
 * 1.1   25/01/2021   ¤ → alessio.marra@nexusat.it   Review ApiName Nomenclature
**/
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
		Id invMilRecTypId = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'NexusRecursive' AND SObjectType = 'InvoiceMilestone__c' LIMIT 1].Id;
		 //Insert Invoice_Milestone__c
		InvoiceMilestone__c imTest = New InvoiceMilestone__c();
		imTest.Name = 'Invoice Milestone Test';
		imTest.Opportunity__c = opp.Id;
		imTest.ExpectedDate__c = Date.today();
		imTest.RecordTypeId = invMilRecTypId;
		imTest.Amount__c = 1000;
		imTest.Stage__c = 'Fattura Inviata';
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