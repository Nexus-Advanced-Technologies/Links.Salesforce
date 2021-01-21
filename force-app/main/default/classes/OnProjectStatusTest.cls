@isTest
public class OnProjectStatusTest {
    @testSetUp
    public static void testOnProjectStatus(){
        
        TriggerCustomSetting__c triggerCustomSetting = new TriggerCustomSetting__c();
        triggerCustomSetting.NexusProjectStatusAfterInsert__c = true;
        triggerCustomSetting.NexusProjectStatusAfterUpdate__c = true;
        triggerCustomSetting.NexusProjectStatusBeforeInsert__c = true;
        triggerCustomSetting.NexusProjectStatusBeforeUpdate__c = true;

        OpportunitySetting__c sett = new OpportunitySetting__c(
           FteWhere__c = 'Name = \'testName\''
        );
        insert sett;
           
        Account account = new Account(
            name= 'TestName');
        insert account;
        
        Opportunity opportunity = new Opportunity(
            AccountId = account.id,
            Name = 'oppTest',
            StageName = 'Prospecting',
            CloseDate = Date.today());
        insert opportunity;
        
        Project_Status__c ProjectStatus = new Project_Status__c(
            name = 'testName',
            Budget_gg__c = 10000,
            Data_fine_prevista__c = Date.today()+30,
            Stima_gg_a_terminare__c = 5,
            Opportunity__c = opportunity.Id);
        insert ProjectStatus;
    }
    
    
    @istest
    public static void testOnProjectStatusSchedulable(){
        OnProjectStatusSchedulable ops = new OnProjectStatusSchedulable();
        String CRON_EXP = '0 0 0 15 3 ? 2022';
        System.schedule('test', CRON_EXP, ops);
        
    }
    
}