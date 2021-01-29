/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @see               : OnOpportunity (Trigger)
 * @see               : TriggerSetting (CustomMetadata)
 * @important         : The OpportunityBeforeInsert__c field on TriggerSetting__mdt for Nexus record must be enabled for a positive test result
 * @last modified on  : 24/01/2021
 * @last modified by  : ¤ → alessio.marra@nexusat.it
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   01-21-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest
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
		opp.accountId = insertAccount('Account Test (' + name + ')');
		opp.StageName = 'Prospect';
		opp.CloseDate = Date.newInstance(2020, 01, 01);
		opp.RecordTypeId = recordTypeId;
		insert opp;
		return opp.Id;
	}

	@IsTest
	static void testGenerateReferenceNumber() {

		Id recordTypeId = getRecordTypeId('Opportunity', 'NexusStandard');
		
		Test.startTest();
		insertOpportunity('Opp1', recordTypeId);
		insertOpportunity('Opp2', recordTypeId);
		Test.stopTest();

		Opportunity opp1 = [SELECT ReferenceNumber__c FROM Opportunity WHERE Name = 'Opp1' LIMIT 1];
		Opportunity opp2 = [SELECT ReferenceNumber__c FROM Opportunity WHERE Name = 'Opp2' LIMIT 1];

		System.assertEquals('NX-00000', opp1.ReferenceNumber__c);
		System.assertEquals('NX-00001', opp2.ReferenceNumber__c);
	}
}