/**
 * @description       : 
 * @author            : Massimo Frangiamore
 * @group             : 
 * @last modified on  : 01-25-2023
 * @last modified by  : Massimo Frangiamore
**/
@IsTest
global class JiraApiPlugin_Test implements HttpCalloutMock {
    @TestSetup
    static void makeData(){
        insert new JiraNexus__c(Username__c = 'Value',JiraToken__c = 'Value',Url__c = 'Value.com');
        Account a = new Account(name = 'testAccount');
        insert a;
        Opportunity o = new Opportunity(name ='OpportunityTest', AccountId = a.id, StageName = 'new',CloseDate = date.today());
        insert o;
        ProjectStatus__c p = new ProjectStatus__c( name = 'TestProject', Opportunity__c = o.id);
        insert p;
    }
    @IsTest
    static void callServiceDeskChiusuraServiceDesk(){
        List<Id> ids =  new List<Id>();
        for(ProjectStatus__c p : [SELECT Id,Name FROM ProjectStatus__c]){
            ids.add(p.Id);
        }
        Test.setMock(HttpCalloutMock.class, new JiraApiPlugin_Test());
        JiraApiPlugin.callServiceDeskChiusuraServiceDesk(ids);
    }
   
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"test": "test"}');
        response.setStatusCode(200);
        return response; 
    }
    
}