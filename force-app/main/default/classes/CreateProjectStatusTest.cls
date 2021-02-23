/**
 * @description       : 
 * @author            : 
 * @last modified on  : 03/02/2021
 * @last modified by  : ¤ → alessio.marra@nexusat.it
**/
@IsTest(SeeAllData=true)
public class CreateProjectStatusTest {

	private static List<TriggerSetting__mdt> createCustomMetadataOpportunity(Boolean status) {
		List<TriggerSetting__mdt> triggerSettingMDT = (List<TriggerSetting__mdt>) Json.deserialize(
			'[' +
				'{' +
					'"DeveloperName": "Nexus",' +
					'"OpportunityBeforeInsert__c": "' + status + '"' +
				'}' +
			']'
			,List<TriggerSetting__mdt>.class
		); 
		return triggerSettingMDT;
	}

	private static List<TriggerSetting__mdt> createCustomMetadataQuote(Boolean status) {
		List<TriggerSetting__mdt> triggerSettingMDT = (List<TriggerSetting__mdt>) Json.deserialize(
			'[' +
				'{' +
					'"DeveloperName": "Nexus",' +
					'"QuoteAfterInsert__c": "' + status + '"' +
				'}' +
			']'
			,List<TriggerSetting__mdt>.class
		); 
		return triggerSettingMDT;
	}

	private static Id getRecordTypeId(String objectName, String recordTypeName) {
		return [SELECT Id FROM RecordType WHERE sObjectType = :objectName AND DeveloperName = :recordTypeName AND isActive = true LIMIT 1].Id;
	}

	@IsTest
	static void createStatusTest() {

		Test.startTest();
		TriggerUtilities.TriggerSettingOpportunity = createCustomMetadataOpportunity(false);
		TriggerUtilities.TriggerSettingQuote = createCustomMetadataQuote(true);

		OpportunitySetting__c sett = [SELECT Id, FteWhere__c FROM OpportunitySetting__c LIMIT 1];
		sett.FteWhere__c = 'Name = \'TS-00521 Test\'';
		update sett;

		//Insert Account
		Account testAccount = New Account();
		testAccount.Name = 'testAccount 1';
		testAccount.PriceBook__c = Test.getStandardPricebookId();
		insert testAccount;

		//Insert Opportunity
		Opportunity opp = New Opportunity();
		opp.Name = 'TS-00521 Test';
		opp.AccountId = testAccount.Id;
		opp.RecordTypeId = getRecordTypeId('Opportunity', 'NexusStandard');
		opp.CloseDate = Date.today();
		opp.StageName = 'Closed Won';
		opp.ReferenceNumber__c = 'TS-00521';
		insert opp;

		//Insert Quote
		Quote quoteTest = New Quote();
		quoteTest.Name = 'test';
		quoteTest.OpportunityId = opp.Id;
		quoteTest.Status = 'Accepted';
		quoteTest.RecordTypeId = getRecordTypeId('Quote', 'Nexus');
		insert quoteTest;

		Opportunity opp1 = [SELECT Id, Name, SyncedQuoteId FROM Opportunity WHERE name = 'TS-00521 Test'];
		opp1.SyncedQuoteId = quoteTest.Id;
		update opp1;

		List<Id> listOppId = new List<Id>();
		Id oppId = [SELECT Id, Name, SyncedQuoteId FROM Opportunity WHERE name = 'TS-00521 Test'].Id;
		listOppId.add(oppId);
		CreateProjectStatus.createProjectStatusInvocable(listOppId);
		Test.stopTest();
	}
}