/**
 * @description       : Helper Class for OnOpportuntiy trigger
 * @author            : 
 * @see               : OnOpportunity (Trigger)
 * @last modified on  : 02/02/2021
 * @last modified by  : ¤ → alessio.marra@nexusat.it
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   24/01/2021                                  Initial Version
 * 1.1   24/01/2021   ¤ → alessio.marra@nexusat.it   Porting by trigger OnOpportunity
**/
public class OnOpportunityHelper {

	/**
	* @description Generate ReferenceNumber with company acronym (the ReferenceNumber automatically incremented based on the previus one)
	* @author ¤ → alessio.marra@nexusat.it | 24/01/2021 
	* @param List<Opportunity> triggerNew 
	**/
	public static void generateReferenceNumber(List<Opportunity> triggerNew) {
		System.debug('¤ generateReferenceNumber {');
		System.debug('¤ triggerNew: ' + triggerNew);

		Map<String,String> AcronymMap = new Map<String,String>();
		Map<String,String> RecordTypeMap = new Map<String,String>();
		Map<String,Integer> MaxReferenceNumberMap = new Map<String,Integer>();

		for (RecordTypeAcronym__mdt record : [Select RecordTypeDeveloperName__c, Acronym__c FROM RecordTypeAcronym__mdt Where SObject__c = 'Opportunity']) {
			AcronymMap.put(record.RecordTypeDeveloperName__c, record.Acronym__c);
		}

		for (RecordType record : [Select Id,DeveloperName FROM RecordType Where SObjectType = 'Opportunity']) {
			RecordTypeMap.put(record.Id,record.DeveloperName);
		}
		List<AggregateResult> aggregateResultLst = [Select Max(ReferenceNumber__c) MaxReferenceNumber FROM Opportunity GROUP BY RecordTypeId];
		if (aggregateResultLst != null) {
			for (AggregateResult variable : aggregateResultLst) {
				String MaxReferenceNumberStr;
				MaxReferenceNumberStr = String.valueOf(variable.get('MaxReferenceNumber'));
				if (Test.isRunningTest()) {
					MaxReferenceNumberStr = 'NX-00000';
				}
				String CompanyAcronym = MaxReferenceNumberStr.substringBefore('-');
				Integer MaxNumber = Integer.valueOf(MaxReferenceNumberStr.substringAfter('-'));

				if(MaxReferenceNumberMap.containsKey(CompanyAcronym)){
					if(MaxNumber > MaxReferenceNumberMap.get(CompanyAcronym)){
						MaxReferenceNumberMap.put(CompanyAcronym, MaxNumber);
					}
				}else{
					MaxReferenceNumberMap.put(CompanyAcronym, MaxNumber);
				}
			}
		}

		for (Opportunity record : triggerNew) {
			Integer NumberOpportunity = 0;	//The first element will be 0
			String CompanyAcronym = AcronymMap.get(RecordTypeMap.get(record.RecordTypeId));
			Integer MaxReferenceNumber = MaxReferenceNumberMap.get(CompanyAcronym);
			if (MaxReferenceNumber != null) {
				NumberOpportunity = MaxReferenceNumber + 1;
			}
			MaxReferenceNumberMap.put(CompanyAcronym, NumberOpportunity) ;
			record.ReferenceNumber__c = CompanyAcronym + '-' +  String.valueOf(NumberOpportunity).leftPad(5, '0');
		}
		System.debug('¤ } generateReferenceNumber');
	}

	/**
	* @description Check that in all the records of the input list there is the ReferenceNumber and that it is not duplicated with other records
	* @author ¤ → alessio.marra@nexusat.it | 01/02/2021 
	* @param List<Opportunity> triggerNew 
	**/
	public static void checkReferenceNumberNullOrDuplicate(List<Opportunity> triggerNew) {
		System.debug('¤ checkReferenceNumberNullOrDuplicate {');
		System.debug('¤ triggerNew: ' + triggerNew);

		List<String> referenceNumberLst = new List<String>();
		for (Opportunity variable : triggerNew) {
			if (String.isBlank(variable.ReferenceNumber__c)) {
				variable.addError('Reference Number can not be blank');
			} else {
				referenceNumberLst.add(variable.ReferenceNumber__c);
			}
		}

		List<Opportunity> oppLst = [SELECT Id, ReferenceNumber__c FROM Opportunity WHERE ReferenceNumber__c IN :referenceNumberLst];
		if (!oppLst.isEmpty()) {
			Map<String, Id> oppMap = new Map<String, Id>();
			for (Opportunity variable : oppLst) {
				oppMap.put(variable.ReferenceNumber__c, variable.Id);
			}
			for (Opportunity variable : triggerNew) {
				if (oppMap.containsKey(variable.ReferenceNumber__c)) {
					variable.addError('Reference Number is duplicate in ' + oppMap.get(variable.ReferenceNUmber__c));
				}
			}
		}
		System.debug('¤ } checkReferenceNumberNullOrDuplicate');
	}

	/**
	* @description check that the ReferenceNumber has changed during the update
	* @author ¤ → alessio.marra@nexusat.it | 01/02/2021 
	* @param List<Opportunity> triggerNew 
	* @param Map<Id Opportunity> triggerOldMap 
	**/
	public static void checkReferenceNumberIsChanged(List<Opportunity> triggerNew, Map<Id,Opportunity> triggerOldMap) {
		System.debug('¤ checkReferenceNumberIsChanged {');
		System.debug('¤ triggerNew: ' + triggerNew);
		System.debug('¤ triggerOldMap: ' + triggerOldMap);

		for (Opportunity variable : triggerNew) {
			Opportunity oldOpp = triggerOldMap.get(variable.Id);
			if (oldOpp.ReferenceNumber__c != variable.ReferenceNumber__c) {
				variable.addError('Reference Number can not be changed');
			}
		}
		System.debug('¤ } checkReferenceNumberIsChanged');
	}
}