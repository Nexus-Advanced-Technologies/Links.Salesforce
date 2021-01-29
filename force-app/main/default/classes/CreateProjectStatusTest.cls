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
@isTest(SeeAllData=true)
public class CreateProjectStatusTest {
	@isTest
	static void createStatusTest(){

		OpportunitySetting__c sett = new OpportunitySetting__c(
			FteWhere__c = 'Name = \'NX-00521 Test\''
		);
		insert sett;

		//Insert Account
		Account testAccount = New Account();
		testAccount.Name = 'testAccount 1';
		testAccount.PriceBook__c = Test.getStandardPricebookId();
		insert testAccount;

		Id recStandarId = [SELECT Id, DeveloperName, Name 
							FROM RecordType
							WHERE DeveloperName = 'NexusStandard'].Id;
		
		Id recordTypeQuote = [SELECT Id FROM RecordType WHERE SObjectType = 'Quote' AND DeveloperName = 'Nexus' AND IsActive = true LIMIT 1].Id;

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
		quoteTest.RecordTypeId = recordTypeQuote;
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