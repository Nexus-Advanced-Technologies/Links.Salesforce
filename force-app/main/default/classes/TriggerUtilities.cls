/**
 * @description       : Utility class for triggers
 * @author            : ¤ → alessio.marra@nexusat.it
 * @see               : OnOpportunity (Trigger)
 * @see               : TriggerSetting (CustomMetadata)
 * @last modified on  : 25/03/2021
 * @last modified by  : ¤ → alessio.marra@nexusat.it
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   24/01/2021   ¤ → alessio.marra@nexusat.it   Initial Version
 * 1.1   01/02/2021   ¤ → alessio.marra@nexusat.it   Add attribute TriggerSettingOpportunity, TriggerSettingProjectStatus, TriggerSettingQuote
**/
public class TriggerUtilities {

	@TestVisible
	public static List<TriggerSetting__mdt> TriggerSettingOpportunity {
		get{
			if(TriggerSettingOpportunity == null) {
				TriggerSettingOpportunity = [SELECT DeveloperName, OpportunityBeforeInsert__c FROM TriggerSetting__mdt];
			}
			return TriggerSettingOpportunity;
		}
		set;
	}

	@TestVisible
	public static List<TriggerSetting__mdt> TriggerSettingProjectStatus {
		get{
			if(TriggerSettingProjectStatus == null) {
				TriggerSettingProjectStatus = [SELECT DeveloperName, ProjectStatusAfterInsert__c, ProjectStatusAfterUpdate__c, ProjectStatusBeforeInsert__c, ProjectStatusBeforeUpdate__c FROM TriggerSetting__mdt];
			}
			return TriggerSettingProjectStatus;
		}
		set;
	}

	@TestVisible
	public static List<TriggerSetting__mdt> TriggerSettingQuote {
		get{
			if(TriggerSettingQuote == null) {
				TriggerSettingQuote = [SELECT DeveloperName, QuoteAfterInsert__c FROM TriggerSetting__mdt];
			}
			return TriggerSettingQuote;
		}
		set;
	}

	public class TriggerUtilitiesException extends Exception {}

	/**
	* @description Splits the Opportunity list with the different companies based on the Record Type
	* @author ¤ → alessio.marra@nexusat.it | 24/01/2021 
	* @param List<Opportunity> opportunityLst 
	* @return Map<String, List<Opportunity>> 
	**/
	public static Map<String, List<Opportunity>> splitByCompany(List<Opportunity> opportunityLst) {
		System.debug('¤ splitByCompany {');
		System.debug('¤ opportunityLst: ' + opportunityLst);

		//Map for the result of this method
		Map<String, List<Opportunity>> opportuntiyMapLst = new Map<String, List<Opportunity>>();
		
		Map<Id, String> recordTypesMap = getRecordType('Opportunity');
		List<String> companyNameLst = getCompany();

		for (Opportunity record: opportunityLst) {
			if (!recordTypesMap.containsKey(record.RecordTypeId)) {
				throw new TriggerUtilitiesException('This record type does not exist or you do not have permissions (' + record.RecordTypeId + ')');
			}

			String recordTypeDeveloperName = recordTypesMap.get(record.RecordTypeId);

			for (String companyName : companyNameLst) {
				if (recordTypeDeveloperName.contains(companyName)) {
					List<Opportunity> opportunityInnerLst = new List<Opportunity>();
					if (opportuntiyMapLst.containsKey(companyName)) {
						opportunityInnerLst = opportuntiyMapLst.get(companyName);
					}
					opportunityInnerLst.add(record);
					opportuntiyMapLst.put(companyName, opportunityInnerLst);
				}
			}
		}

		checkAllSplitted(opportunityLst, opportuntiyMapLst);

		System.debug('¤ opportuntiyMapLst: ' + opportuntiyMapLst);
		System.debug('¤ } slitByCompany');
		return opportuntiyMapLst;
	}

	/**
	* @description Splits the ProjectStatus list with the different companies based on the Record Type
	* @author ¤ → alessio.marra@nexusat.it | 25/01/2021 
	* @param List<ProjectStatus__c> projectStatusLst 
	* @return Map<String, List<ProjectStatus__c>> 
	**/
	public static Map<String, List<ProjectStatus__c>> splitByCompany(List<ProjectStatus__c> projectStatusLst) {
		System.debug('¤ splitByCompany {');
		System.debug('¤ projectStatusLst: ' + projectStatusLst);

		//Map for the result of this method
		Map<String, List<ProjectStatus__c>> projectStatusMapLst = new Map<String, List<ProjectStatus__c>>();
		
		Map<Id, String> recordTypesMap = getRecordType('ProjectStatus__c');
		List<String> companyNameLst = getCompany();

		for (ProjectStatus__c record: projectStatusLst) {
			if (!recordTypesMap.containsKey(record.RecordTypeId)) {
				throw new TriggerUtilitiesException('This record type does not exist or you do not have permissions (' + record.RecordTypeId + ')');
			}

			String recordTypeDeveloperName = recordTypesMap.get(record.RecordTypeId);

			for (String companyName : companyNameLst) {
				if (recordTypeDeveloperName.contains(companyName)) {
					List<ProjectStatus__c> projectsStatusInnerLst = new List<ProjectStatus__c>();
					if (projectStatusMapLst.containsKey(companyName)) {
						projectsStatusInnerLst = projectStatusMapLst.get(companyName);
					}
					projectsStatusInnerLst.add(record);
					projectStatusMapLst.put(companyName, projectsStatusInnerLst);
				}
			}
		}

		checkAllSplitted(projectStatusLst, projectStatusMapLst);

		System.debug('¤ projectStatusMapLst: ' + projectStatusMapLst);
		System.debug('¤ } slitByCompany');
		return projectStatusMapLst;
	}

	/**
	* @description Splits the Quote list with the different companies based on the Record Type
	* @author ¤ → alessio.marra@nexusat.it | 25/01/2021 
	* @param List<Quote> quoteLst 
	* @return Map<String, List<Quote>> 
	**/
	public static Map<String, List<Quote>> splitByCompany(List<Quote> quoteLst) {
		System.debug('¤ splitByCompany {');
		System.debug('¤ quoteLst: ' + quoteLst);

		//Map for the result of this method
		Map<String, List<Quote>> quoteMapLst = new Map<String, List<Quote>>();
		
		Map<Id, String> recordTypesMap = getRecordType('Quote');
		List<String> companyNameLst = getCompany();

		for (Quote record: quoteLst) {
			if (!recordTypesMap.containsKey(record.RecordTypeId)) {
				throw new TriggerUtilitiesException('This record type does not exist or you do not have permissions (' + record.RecordTypeId + ')');
			}

			String recordTypeDeveloperName = recordTypesMap.get(record.RecordTypeId);

			for (String companyName : companyNameLst) {
				if (recordTypeDeveloperName.contains(companyName)) {
					List<Quote> quoteInnerLst = new List<Quote>();
					if (quoteMapLst.containsKey(companyName)) {
						quoteInnerLst = quoteMapLst.get(companyName);
					}
					quoteInnerLst.add(record);
					quoteMapLst.put(companyName, quoteInnerLst);
				}
			}
		}

		checkAllSplitted(quoteLst, quoteMapLst);

		System.debug('¤ quoteMapLst: ' + quoteMapLst);
		System.debug('¤ } slitByCompany');
		return quoteMapLst;
	}

	/**
	* @description Get all active Record Types for the passed SObject string
	* @author ¤ → alessio.marra@nexusat.it | 25/01/2021 
	* @param String obj 
	* @return Map<Id, String> 
	**/
	private static Map<Id, String> getRecordType(String obj) {
		Map<Id, String> recordTypesMap = new Map<Id, String>();
		for (recordType var: [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = :obj AND IsActive = true]) {
			recordTypesMap.put(var.Id, var.DeveloperName);
		}
		return recordTypesMap;
	}

	/**
	* @description Get all companies inserted in CustoMetadata (TriggerSetting)
	* @author ¤ → alessio.marra@nexusat.it | 25/01/2021 
	* @return List<String> 
	**/
	public static List<String> getCompany() {
		List<String> companyNameLst = new List<String>();
		for (TriggerSetting__mdt var : [SELECT DeveloperName FROM TriggerSetting__mdt]) {
			companyNameLst.add(var.DeveloperName);
		}
		return companyNameLst;
	}

	/**
	* @description Check that all records have been split
	* @author ¤ → alessio.marra@nexusat.it | 25/01/2021 
	**/
	private static void checkAllSplitted(List<SObject> inLst, Map<String, List<SObject>> outMap) {
		Integer inSize = inLst.size();
		Integer outSize = 0;
		for(String key : outMap.keySet()) {
			outSize += outMap.get(key).size();
		}
		if (inSize != outSize) {
			throw new TriggerUtilitiesException('Not all records have been split with the right company');
		}
	}
}