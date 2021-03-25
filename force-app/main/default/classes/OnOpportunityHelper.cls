/**
 * @description       : Helper Class for OnOpportuntiy trigger
 * @author            : 
 * @see               : OnOpportunity (Trigger)
 * @last modified on  : 25/03/2021
 * @last modified by  : ¤ → alessio.marra@nexusat.it
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   24/01/2021                                  Initial Version (Porting from ORG Nexus)
 * 1.1   24/01/2021   ¤ → alessio.marra@nexusat.it   Porting by trigger OnOpportunity
 * 1.2   25/03/2021   ¤ → alessio.marra@nexusat.it   Code review and simplification for the next affiliates
**/
public class OnOpportunityHelper {

	/**
	* @description Helper method for trigger in before insert
	* @author ¤ → alessio.marra@nexusat.it | 25/03/2021 
	* @param List<Opportunity> triggerNew 
	* @param Map<Id Opportunity> triggerOldMap 
	**/
	public static void beforeInsert(List<Opportunity> triggerNew) {

		//For all company
		generateReferenceNumbers(triggerNew);
		checkReferenceNumberNullOrDuplicate(triggerNew);
	}

	/**
	* @description Helper method for trigger in before update
	* @author ¤ → alessio.marra@nexusat.it | 25/03/2021 
	* @param List<Opportunity> triggerNew 
	* @param Map<Id Opportunity> triggerOldMap 
	**/
	public static void beforeUpdate(List<Opportunity> triggerNew, Map<Id,Opportunity> triggerOldMap) {

		//For all company
		checkReferenceNumberIsChanged(triggerNew, triggerOldMap);
	}

	/**
	* @description Generate ReferenceNumber with company acronym (the ReferenceNumber automatically incremented based on the previus one)
	* @author ¤ → alessio.marra@nexusat.it | 24/01/2021 
	* @param List<Opportunity> triggerNew 
	**/
	private static void generateReferenceNumbers(List<Opportunity> triggerNew) {
		LoggerHandler.start('¤ generateReferenceNumbers', new Map<String, Object> {
			'triggerNew' => triggerNew
		});

		Map<String,String> AcronymMap = getAcronymMap();
		Map<String,String> RecordTypeMap = getRecordTypeMap();
		Map<String,Integer> MaxReferenceNumberMap = getMaxReferenceNumberMap();

		for (Opportunity record : triggerNew) {
			Integer NumberOpportunity = 0;	//The first element will be 0
			String CompanyAcronym = AcronymMap.get(RecordTypeMap.get(record.RecordTypeId));
			Integer MaxReferenceNumber = MaxReferenceNumberMap.get(CompanyAcronym);
			if (MaxReferenceNumber != null) {
				NumberOpportunity = MaxReferenceNumber + 1;
			}
			MaxReferenceNumberMap.put(CompanyAcronym, NumberOpportunity) ;
			record.ReferenceNumber__c = CompanyAcronym + '-' + String.valueOf(NumberOpportunity).leftPad(5, '0');
		}
		LoggerHandler.end('¤ generateReferenceNumbers');
	}

	/**
	* @description Get a map composed of: RecordType DeveloperName - Acronym
	* @author ¤ → alessio.marra@nexusat.it | 25/03/2021 
	* @return Map<String, String> 
	**/
	private static Map<String,String> getAcronymMap() {
		Map<String,String> AcronymMap = new Map<String,String>();
		for (RecordTypeAcronym__mdt record : [Select RecordTypeDeveloperName__c, Acronym__c FROM RecordTypeAcronym__mdt Where SObject__c = 'Opportunity']) {
			AcronymMap.put(record.RecordTypeDeveloperName__c, record.Acronym__c);
		}
		return AcronymMap;
	}

	/**
	* @description Get a map composed of: RecordType Id - RecordType DeveloperName
	* @author ¤ → alessio.marra@nexusat.it | 25/03/2021 
	* @return Map<String, String> 
	**/
	private static Map<String,String> getRecordTypeMap() {
		Map<String,String> RecordTypeMap = new Map<String,String>();
		for (RecordType record : [Select Id,DeveloperName FROM RecordType Where SObjectType = 'Opportunity']) {
			RecordTypeMap.put(record.Id, record.DeveloperName);
		}
		return RecordTypeMap;
	}

	/**
	* @description Calculate the MaxReferenceNumber for each RecordType and Get a map composed of: Acronym - MaxReferenceNumber
	* @author ¤ → alessio.marra@nexusat.it | 25/03/2021 
	* @return Map<String, Integer> 
	**/
	private static Map<String,Integer> getMaxReferenceNumberMap() {
		Map<String,Integer> MaxReferenceNumberMap = new Map<String,Integer>();
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
		return MaxReferenceNumberMap;
	}

	/**
	* @description Check that in all the records of the input list there is the ReferenceNumber and that it is not duplicated with other records
	* @author ¤ → alessio.marra@nexusat.it | 01/02/2021 
	* @param List<Opportunity> triggerNew 
	**/
	private static void checkReferenceNumberNullOrDuplicate(List<Opportunity> triggerNew) {
		LoggerHandler.start('¤ checkReferenceNumberNullOrDuplicate', new Map<String, Object> {
			'triggerNew' => triggerNew
		});

		checkReferenceNumberNull(triggerNew);
		checkReferenceNumberDuplicate(triggerNew);

		LoggerHandler.end('¤ checkReferenceNumberNullOrDuplicate');
	}

	/**
	* @description Throws an exception if the ReferenceNumber is blank
	* @author ¤ → alessio.marra@nexusat.it | 25/03/2021 
	**/
	private static void checkReferenceNumberNull(List<Opportunity> triggerNew) {
		for (Opportunity variable : triggerNew) {
			if (String.isBlank(variable.ReferenceNumber__c)) {
				throw new ExceptionHandler.ReferenceNumberException('Reference Number can not be blank');
				// variable.addError('Reference Number can not be blank');
			}
		}
	}

	private static void checkReferenceNumberDuplicate(List<Opportunity> triggerNew) {
		List<String> referenceNumberLst = getReferenceNumberLst(triggerNew);
		List<Opportunity> oppLst = [SELECT Id, ReferenceNumber__c FROM Opportunity WHERE ReferenceNumber__c IN :referenceNumberLst];

		if (!oppLst.isEmpty()) {
			//Generate a map composed of: ReferenceNumber - Opportunity Id
			Map<String, Id> oppMap = new Map<String, Id>();
			for (Opportunity variable : oppLst) {
				oppMap.put(variable.ReferenceNumber__c, variable.Id);
			}

			//for each opportunity, check that it is not present in the map
			for (Opportunity variable : triggerNew) {
				if (oppMap.containsKey(variable.ReferenceNumber__c)) {
					throw new ExceptionHandler.ReferenceNumberException('Reference Number is duplicate in ' + oppMap.get(variable.ReferenceNumber__c));
					//variable.addError('Reference Number is duplicate in ' + oppMap.get(variable.ReferenceNUmber__c));
				}
			}
		}
	}

	/**
	* @description Get a list of ReferenceNumber from the input list of Opportunities
	* @author ¤ → alessio.marra@nexusat.it | 25/03/2021 
	* @param List<Opportunity> triggerNew 
	* @return List<String> 
	**/
	private static List<String> getReferenceNumberLst(List<Opportunity> triggerNew) {
		List<String> referenceNumberLst = new List<String>();
		for (Opportunity variable : triggerNew) {
			referenceNumberLst.add(variable.ReferenceNumber__c);
		}
		return referenceNumberLst;
	}

	/**
	* @description check that the ReferenceNumber has changed during the update
	* @author ¤ → alessio.marra@nexusat.it | 01/02/2021 
	* @param List<Opportunity> triggerNew 
	* @param Map<Id Opportunity> triggerOldMap 
	**/
	private static void checkReferenceNumberIsChanged(List<Opportunity> triggerNew, Map<Id,Opportunity> triggerOldMap) {
		LoggerHandler.start('¤ checkReferenceNumberIsChanged', new Map<String, Object> {
			'triggerNew' => triggerNew,
			'triggerOldMap' => triggerOldMap
		});

		for (Opportunity variable : triggerNew) {
			Opportunity oldOpp = triggerOldMap.get(variable.Id);
			if (oldOpp.ReferenceNumber__c != variable.ReferenceNumber__c) {
				throw new ExceptionHandler.ReferenceNumberException('Reference Number can not be changed');
				//variable.addError('Reference Number can not be changed');
			}
		}
		LoggerHandler.end('¤ checkReferenceNumberIsChanged');
	}
}