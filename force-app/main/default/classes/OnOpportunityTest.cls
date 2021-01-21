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
@isTest
public class OnOpportunityTest {
    
	@testSetUp
    public static void testOnOpportunity(){
        
    TriggerCustomSetting__c triggerCustomSetting = new TriggerCustomSetting__c();
        //triggerCustomSetting.OnOpportunity_Before_Insert__c = true;

       /* RecordTypeAcronim__mdt recordTypeAcronim = new RecordTypeAcronim__mdt (
        Acronim__c = 'Test',
        RecordTypeDeveloperName__c = 'Test1',
        SObject__c = 'Test-1'
        );

        insert recordTypeAcronim;
        */            
        //RecordTypeAcronim__mdt recordTypeAcronim = new RecordTypeAcronim__mdt();      

  }
    
   @isTest
    public static void testOnOpportunityo(){
        Id recordTypeId = [select id from RecordType where SobjectType = 'Opportunity' Limit 1].id ;
        Id recordTypeId1 = [select id from RecordType where SobjectType = 'Opportunity' and Id != :recordTypeId Limit 1].id ;

         Account account = new Account(
            name= 'TestName');
        insert account; 

        
        
        Opportunity opportunity = new Opportunity(
            AccountId = account.id,
            Name = 'oppTest',
            StageName = 'Prospecting',
            CloseDate = Date.today());
            RecordTypeId = recordTypeId1;
        insert opportunity;

        Opportunity opportunity1 = new Opportunity(
            AccountId = account.id,
            Name = 'oppTest',
            StageName = 'Prospecting',
            CloseDate = Date.today());
            RecordTypeId = recordTypeId;
        insert opportunity1;

        Opportunity opportunity2 = new Opportunity(
            AccountId = account.id,
            Name = 'oppTest',
            StageName = 'Prospecting',
            CloseDate = Date.today());
            RecordTypeId = recordTypeId;
        insert opportunity2;
    }
}