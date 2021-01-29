/**
 * @description       : Helper Class for OnOpportuntiy trigger
 * @author            : 
 * @see               : OnOpportunity (Trigger)
 * @last modified on  : 24/01/2021
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
		System.debug('¤ debug1');
		List<AggregateResult> aggregateResultLst = [Select Max(ReferenceNumber__c) MaxReferenceNumber FROM Opportunity GROUP BY RecordTypeId];
		if (aggregateResultLst != null) {
			for (AggregateResult variable : aggregateResultLst) {
				System.debug('¤ debug2');
				
				String CompanyAcronym = String.valueOf(variable.get('MaxReferenceNumber')).substringBefore('-');
				Integer MaxNumber = Integer.valueOf(String.valueOf(variable.get('MaxReferenceNumber')).substringAfter('-'));
				System.debug('¤ CompanyAcronym ' + CompanyAcronym);
				System.debug('¤ MaxNumber ' + MaxNumber);
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
}
