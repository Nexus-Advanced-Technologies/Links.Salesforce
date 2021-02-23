@isTest
public class Test_InvoiceMilestoneHandler {

	@testSetup
	static void InvoiceDataSetup() {
		Account testAccount = new Account( Name = 'NexusAT' );
		Insert testAccount;
		
		Opportunity testOpportunity = new Opportunity (
			Name = 'testOpportunity',
			AccountId = testAccount.Id,
			StageName = 'Prospecting',
			CloseDate = Date.today(),
			Description = 'testOpportunityDescription'
			);
		Insert testOpportunity;

		InvoiceMilestoneSetting__c customSetting = new InvoiceMilestoneSetting__c(
			StatoValueForSendEmail__c = 'Da Fatturare',
			IsCurrentRecordUsed__c = true
			);
		Insert customSetting;

		InvoiceMilestone__c testInvoiceMilestone = new InvoiceMilestone__c (
			Amount__c = 100,
			InvoiceExternalCode__c = 'CODXFATTEXT231TEST1',
			Opportunity__c = testOpportunity.Id,
			Stage__c = 'Da Fatturare',
			StartSendEmailWorkflow__c = false,
			ExpectedDate__c  =  Date.valueOf('2019-06-28'),
			RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'InvoiceMilestone__c' AND DeveloperName = 'NexusOneShot'].Id
			);
		Insert testInvoiceMilestone;
	}
	@isTest
	public static void startTestSendEmailWorkflow(){
		InvoiceMilestone__c testInvoiceMilestone = [SELECT Id FROM InvoiceMilestone__c WHERE InvoiceExternalCode__c = 'CODXFATTEXT231TEST1'];
		Test.StartTest();
		InvoiceMilestoneHandler.startSendEmailWorkflow(testInvoiceMilestone.Id);
		Test.StopTest();
	}
}