/**
 * @description       : Utility class for triggers
 * @author            : ¤ → alessio.marra@nexusat.it
 * @see               : OnOpportunity (Trigger)
 * @see               : TriggerSetting (CustomMetadata)
 * @last modified on  : 01-20-2022
 * @last modified by  : §
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
				TriggerSettingQuote = [SELECT DeveloperName, QuoteAfterInsert__c, QuoteAfterUpdate__c,QuoteBeforeInsert__c, QuoteBeforeUpdate__c FROM TriggerSetting__mdt];
			}
			return TriggerSettingQuote;
		}
		set;
	}
    
    	@TestVisible
	public static List<TriggerSetting__mdt> TriggerSettingOrder {
		get{
			if(TriggerSettingOrder == null) {
				TriggerSettingOrder = [SELECT DeveloperName, OrderBeforeUpdate__c FROM TriggerSetting__mdt];
			}
			return TriggerSettingOrder;
		}
		set;
	}

	public static List<TriggerSetting__mdt> TriggerSettingQuoteLineItem {
		get{
			if(TriggerSettingQuoteLineItem == null) {
				TriggerSettingQuoteLineItem = [SELECT DeveloperName, QuoteLineItemAfterInsert__c, 	QuoteLineItemAfterUpdate__c, QuoteLineItemAfterDelete__c FROM TriggerSetting__mdt];
			}
			return TriggerSettingQuoteLineItem;
		}
		set;
	}

	public static List<TriggerSetting__mdt> TriggerSettingDocumentAlyante {
		get {
			if(TriggerSettingDocumentAlyante == null) {
				TriggerSettingDocumentAlyante = [SELECT DeveloperName, DocumentAlyanteAfterInsert__c, DocumentAlyanteAfterUpdate__c, DocumentAlyanteBeforeUpdate__c, DocumentAlyanteBeforeDelete__c FROM TriggerSetting__mdt];
			}
			return TriggerSettingDocumentAlyante;
		}
		set;
	}

	public static List<TriggerSetting__mdt> TriggerSettingDocumentDetailAlyante {
		get {
			if(TriggerSettingDocumentDetailAlyante == null) {
				TriggerSettingDocumentDetailAlyante = [SELECT DeveloperName, DocumentDetailAlyanteBeforeInsert__c FROM TriggerSetting__mdt];
			}
			return TriggerSettingDocumentDetailAlyante;
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
    
    
    public static Map<String, List<Order>> splitByCompany(List<Order> orderLst) {
		System.debug('¤ splitByCompany {');
		System.debug('¤ orderLst: ' + orderLst);

		//Map for the result of this method
		Map<String, List<Order>> orderMapLst = new Map<String, List<Order>>();
		
		Map<Id, String> recordTypesMap = getRecordType('Order');
		List<String> companyNameLst = getCompany();

		for (Order record: orderLst) {
			if (!recordTypesMap.containsKey(record.RecordTypeId)) {
				throw new TriggerUtilitiesException('This record type does not exist or you do not have permissions (' + record.RecordTypeId + ')');
			}

			String recordTypeDeveloperName = recordTypesMap.get(record.RecordTypeId);

			for (String companyName : companyNameLst) {
				if (recordTypeDeveloperName.contains(companyName)) {
					List<Order> orderInnerLst = new List<Order>();
					if (orderMapLst.containsKey(companyName)) {
						orderInnerLst = orderMapLst.get(companyName);
					}
					orderInnerLst.add(record);
					orderMapLst.put(companyName, orderInnerLst);
				}
			}
		}

		checkAllSplitted(orderLst, orderMapLst);

		System.debug('¤ opportuntiyMapLst: ' + orderMapLst);
		System.debug('¤ } slitByCompany');
		return orderMapLst;
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

	public static Map<String, List<QuoteLineItem>> splitByCompany(List<QuoteLineItem> quoteLineItemLst) {
		System.debug('¤ splitByCompany {');
		System.debug('¤ QuoteLineItem ' + quoteLineItemLst);

		Set<Id> QuoteIdSet = new Set<id>();
		for (QuoteLineItem quoteLineItem: quoteLineItemLst){
			QuoteIdSet.add(quoteLineItem.QuoteId);
		}
		List<Quote> quoteList = [SELECT id, RecordTypeId FROM Quote WHERE id =:QuoteIdSet];
		System.debug(quoteList);
		

		Map<id, id> quoteRecordTypeIdMap = new Map<id, id>();
		for (Quote record: quoteList){
			quoteRecordTypeIdMap.put(record.id, record.RecordTypeId);
		}

		//Map for the result of this method
		Map<String, List<QuoteLineItem>> quoteLineItemMapLst = new Map<String, List<QuoteLineItem>>();
		
		Map<Id, String> recordTypesMap = getRecordType('Quote');
		List<String> companyNameLst = getCompany();

		for (QuoteLineItem record: quoteLineItemLst) {
			Id parentRecordTypeId = quoteRecordTypeIdMap.get(record.QuoteId);
			if (!recordTypesMap.containsKey(parentRecordTypeId)) {
				throw new TriggerUtilitiesException('This record type does not exist or you do not have permissions (' + parentRecordTypeId + ')');
			}

			String recordTypeDeveloperName = recordTypesMap.get(parentRecordTypeId);

			for (String companyName : companyNameLst) {
				if (recordTypeDeveloperName.contains(companyName)) {
					List<QuoteLineItem> quoteLineItemInnerLst = new List<QuoteLineItem>();
					if (quoteLineItemMapLst.containsKey(companyName)) {
						quoteLineItemInnerLst = quoteLineItemMapLst.get(companyName);
					}
					quoteLineItemInnerLst.add(record);
					quoteLineItemMapLst.put(companyName, quoteLineItemInnerLst);
				}
			}
		}

		checkAllSplitted(quoteLineItemLst, quoteLineItemMapLst);

		System.debug('¤ quoteLineItemMapLst: ' + quoteLineItemMapLst);
		System.debug('¤ } slitByCompany');
		return quoteLineItemMapLst;
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
	private static List<String> getCompany() {
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