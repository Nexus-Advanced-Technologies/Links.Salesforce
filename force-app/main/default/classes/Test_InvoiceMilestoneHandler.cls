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

	InvoiceMilestoneCustomSetting__c customSetting = new InvoiceMilestoneCustomSetting__c(
		StatoValueForSendEmail__c = 'Da Fatturare',
		isCurrentRecordUsed__c = true
		);
	Insert customSetting;

	Invoice_Milestone__c testInvoiceMilestone = new Invoice_Milestone__c (
		Ammontare__c = 100,
		Codice_Fattura_Esterno__c = 'CODXFATTEXT231TEST1',
		Opportunity__c = testOpportunity.Id,
		Stato__c = 'Da Fatturare',
		startSendEmailWorkflow__c = false,
		Data_prevista__c  =  Date.valueOf('2019-06-28'),
		RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Invoice_Milestone__c' AND DeveloperName = 'One_Shot'].Id
		);
	Insert testInvoiceMilestone;
}
@isTest
public static void startTestSendEmailWorkflow(){
	Invoice_Milestone__c testInvoiceMilestone = [SELECT Id FROM Invoice_Milestone__c WHERE Codice_Fattura_Esterno__c = 'CODXFATTEXT231TEST1'];
	Test.StartTest();
	InvoiceMilestoneHandler.startSendEmailWorkflow(testInvoiceMilestone.Id);
	Test.StopTest();
}
}