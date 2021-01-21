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
            
  }
    
    @isTest
    public static void testOnOpportunityo(){
        Id recordTypeId = [select id from RecordType where SobjectType = 'Opportunity' Limit 1].id ;
         Account account = new Account(
            name= 'TestName');
        insert account; 
        
        Opportunity opportunity = new Opportunity(
            AccountId = account.id,
            Name = 'oppTest',
            StageName = 'Prospecting',
            CloseDate = Date.today());
            RecordTypeId = recordTypeId;
        insert opportunity;
        
          
    }
     
        
    
}