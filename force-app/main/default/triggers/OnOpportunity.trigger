/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-21-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   01-21-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/

trigger OnOpportunity on Opportunity (before insert) {
  Map<String,String> AcronimMap = new Map<String,String>();
  Map<String,String> RecordTypeMap = new Map<String,String>();
  Map<String,Integer> MaxReferenceNumberMap = new Map<String,Integer>();
  List<RecordTypeAcronym__mdt> RecordTypeAcronim = [Select RecordTypeDeveloperName__c, 	Acronym__c FROM RecordTypeAcronym__mdt Where Sobject__c = 'Opportunity'];
  if(Test.isRunningTest()){

    RecordTypeAcronim.add(new RecordTypeAcronym__mdt(RecordTypeDeveloperName__c = 'NexusGreaterAmount',Acronym__c='NX'));
    RecordTypeAcronim.add(new RecordTypeAcronym__mdt(RecordTypeDeveloperName__c = 'NexusStandard',Acronym__c='NX'));
  }
  for (RecordTypeAcronym__mdt record : RecordTypeAcronim) {
    AcronimMap.put(record.RecordTypeDeveloperName__c, record.Acronym__c);
  }
  for (RecordType record : [Select Id,DeveloperName FROM RecordType Where SObjectType = 'Opportunity']) {
    RecordTypeMap.put(record.Id,record.DeveloperName);
  }
  for (AggregateResult variable : [Select Max(Reference_Number__c) MaxReferenceNumber FROM Opportunity GROUP BY RecordTypeId]) {
    String CompanyAcronim = String.valueOf(variable.get('MaxReferenceNumber')).substringBefore('-');
    Integer MaxNumber = Integer.valueOf(String.valueOf(variable.get('MaxReferenceNumber')).substringAfter('-'));
    if(MaxReferenceNumberMap.containsKey(CompanyAcronim )){
      if(MaxNumber > MaxReferenceNumberMap.get(CompanyAcronim)){
        MaxReferenceNumberMap.put(CompanyAcronim, MaxNumber);
      }
    }else{
      MaxReferenceNumberMap.put(CompanyAcronim, MaxNumber);
    }
  }
  for (Opportunity record : Trigger.new) {
    String CompanyAcronim = AcronimMap.get(RecordTypeMap.get(record.RecordTypeId));
    Integer NumberOpportunity = 1;
    if(MaxReferenceNumberMap.containsKey(CompanyAcronim)){
       NumberOpportunity =  MaxReferenceNumberMap.get(CompanyAcronim) + 1;
    }
    MaxReferenceNumberMap.put(CompanyAcronim, NumberOpportunity) ;
    record.Reference_Number__c = CompanyAcronim + '-' +  String.valueOf(NumberOpportunity).leftPad(5, '0');
  }
}