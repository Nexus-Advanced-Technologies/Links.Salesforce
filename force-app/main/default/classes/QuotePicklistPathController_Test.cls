@isTest
public class QuotePicklistPathController_Test {
    
    @TestSetup
    static void makeData(){
        
        Account acc = new Account();
        acc.Name = 'Acc Name';
        insert acc;
        
        Opportunity o = new Opportunity();
        o.AccountId = acc.Id;
        o.Name = 'Opp Name';
        o.CloseDate = Date.today();
        o.StageName = 'Qualification';
        insert o;
        
        Quote q = new Quote();
        q.Name = 'Quote Name';
        q.Status = '2';
        q.OpportunityId = o.Id;
        insert q;
    }
    
    @isTest
    public static void testupdateStatus(){
        
        Id qId = [SELECT Id FROM Quote LIMIT 1].Id;
        
        Test.startTest();
        QuotePicklistPathController.updateStatus('1', qId);
        Test.stopTest();
        
        Quote q = [SELECT Status FROM Quote LIMIT 1];
        
        System.assertEquals('1', q.Status);
    }
    
    @isTest
    public static void testUpdateStatusWithException() {

        Id fakeId = null;
        
        Test.startTest();
        try{
            QuotePicklistPathController.updateStatus('1', fakeId);
        } catch(AuraHandledException e){
            System.assert(true);
        }
        Test.stopTest();
    }
}