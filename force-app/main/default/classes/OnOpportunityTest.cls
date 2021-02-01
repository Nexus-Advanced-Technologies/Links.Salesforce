/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @see               : OnOpportunity (Trigger)
 * @see               : TriggerSetting (CustomMetadata)
 * @important         : The OpportunityBeforeInsert__c field on TriggerSetting__mdt for Nexus record must be enabled for a positive test result
 * @last modified on  : 01/02/2021
 * @last modified by  : ¤ → alessio.marra@nexusat.it
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   01-21-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@IsTest
public class OnOpportunityTest {

	private static Id getRecordTypeId(String objectName, String recordTypeName) {
		return [SELECT Id FROM RecordType WHERE sObjectType = :objectName AND DeveloperName = :recordTypeName AND isActive = true LIMIT 1].Id;
	}

	private static Id insertAccount(String name) {
		Account acc = new Account();
		acc.Name = name;
		insert acc;
		return acc.Id;
	}

	private static Id insertOpportunity(String name, Id recordTypeId) {
		Opportunity opp = new Opportunity();
		opp.Name = name;
		opp.AccountId = insertAccount('Account Test (' + name + ')');
		opp.StageName = 'Prospect';
		opp.CloseDate = Date.newInstance(2020, 01, 01);
		opp.RecordTypeId = recordTypeId;
		insert opp;
		return opp.Id;
	}

	private static Id insertOpportunity(String name, String referenceNumber, Id recordTypeId) {
		Opportunity opp = new Opportunity();
		opp.Name = name;
		opp.AccountId = insertAccount('Account Test (' + name + ')');
		opp.StageName = 'Prospect';
		opp.CloseDate = Date.newInstance(2020, 01, 01);
		opp.ReferenceNumber__c = referenceNumber;
		opp.RecordTypeId = recordTypeId;
		insert opp;
		return opp.Id;
	}

	private static List<TriggerSetting__mdt> createCustomMetadata(Boolean status) {
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

	@IsTest
	static void testGenerateReferenceNumber() {

		Id recordTypeId = getRecordTypeId('Opportunity', 'NexusStandard');
		
		Test.startTest();
		TriggerUtilities.TriggerSettingOpportunity = createCustomMetadata(true);
		insertOpportunity('Opp1', recordTypeId);
		insertOpportunity('Opp2', recordTypeId);
		Test.stopTest();

		Opportunity opp1 = [SELECT ReferenceNumber__c FROM Opportunity WHERE Name = 'Opp1' LIMIT 1];
		Opportunity opp2 = [SELECT ReferenceNumber__c FROM Opportunity WHERE Name = 'Opp2' LIMIT 1];

		System.assertEquals('NX-00000', opp1.ReferenceNumber__c);
		System.assertEquals('NX-00001', opp2.ReferenceNumber__c);
	}

	@IsTest
	static void testReferenceNumberNull() {

		Id recordTypeId = getRecordTypeId('Opportunity', 'NexusStandard');
		
		Test.startTest();
		TriggerUtilities.TriggerSettingOpportunity = createCustomMetadata(false);
		try {
			insertOpportunity('Opp1', recordTypeId);
			System.assert(false);
		} catch (Exception e) {
			System.assert(e.getMessage().contains('Reference Number can not be blank'));
		}
		Test.stopTest();
	}

	@IsTest
	static void testReferenceNumberDuplicate() {

		Id recordTypeId = getRecordTypeId('Opportunity', 'NexusStandard');
		
		Test.startTest();
		TriggerUtilities.TriggerSettingOpportunity = createCustomMetadata(false);
		insertOpportunity('Opp1', 'NX-00000', recordTypeId);
		try {
			insertOpportunity('Opp2', 'NX-00000', recordTypeId);
			System.assert(false);
		} catch (Exception e) {
			System.assert(e.getMessage().contains('Reference Number is duplicate in '));
		}
		Test.stopTest();
	}

	@IsTest
	static void testReferenceNumberChanged() {

		Id recordTypeId = getRecordTypeId('Opportunity', 'NexusStandard');
		
		Test.startTest();
		TriggerUtilities.TriggerSettingOpportunity = createCustomMetadata(false);
		Id oppId = insertOpportunity('Opp1', 'NX-00000', recordTypeId);
		Opportunity opp = new Opportunity();
		opp.Id = oppId;
		opp.ReferenceNumber__c = 'changed';
		try {
			update opp;
			System.assert(false);
		} catch (Exception e) {
			System.assert(e.getMessage().contains('Reference Number can not be changed'));
		}
		Test.stopTest();
	}
}