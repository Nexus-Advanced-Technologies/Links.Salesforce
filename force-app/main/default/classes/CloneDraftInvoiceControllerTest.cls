@isTest
public class CloneDraftInvoiceControllerTest {
    
    @TestSetup static void makeData(){
        
        Account acc = new Account();
        acc.Name = 'Acc Name';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Opp Name';
        opp.CloseDate = Date.Today().addDays(10);
        opp.StageName = 'Prospeting';
        insert opp;
        
        ProjectStatus__c ps = new ProjectStatus__c(
            Name = 'Status',
            //RecordTypeId = '01209000000l0oLAAQ',
            Opportunity__c = opp.Id,
            Account__c = acc.Id,
            BudgetDD__c = 2.0,
            EmailNotification__c = 'roberto.desimone@nexusat.it',
            ReferenceNumber__c = 'LK-00000',
            SendInvoiceEmail__c = false,
            Stage__c = 'Analisi requisiti',
            UpdateDate__c = Date.newInstance(2022,02,01));
      	insert ps;
        
        DocumentAlyante__c da = new DocumentAlyante__c();
        da.Date__c = Date.today();
        insert da;
        
        DocumentDetailAlyante__c dda = new DocumentDetailAlyante__c();
        dda.Amount__c = 30;
        dda.Content__c = 'Test Content';
        dda.Document__c = da.Id;
        dda.EndCompetence__c = Date.Today().addDays(10);
        dda.Project__c = ps.Id;
        dda.RevenueType__c = '25';
        dda.StartCompetence__c = Date.Today();
        dda.Tags__c = 'Sviluppo software;Manutenzione correttiva';
        insert dda;
        
            
        OpportunityDocumentAlyante__c oppDA = new OpportunityDocumentAlyante__c();
        oppDa.Opportunity__c = opp.Id;
        oppDa.DocumentAlyante__c = da.Id;
        insert oppDa;
        
        InvoiceMilestone__c im = new InvoiceMilestone__c(
            Name = 'LK-00000 - Tes - 90',
            RecordTypeId = '01209000000mArWAAU',
            //Amount__c = 20000.0,
            //Description__c = '40 - Test',
            ExpectedDate__c = Date.newInstance(2022,01,12),
            //Rank__c = 1.0,
            Stage__c = 'Draft',
            StartSendEmailWorkflow__c = false,
            Opportunity__c = opp.Id,
            Year__c = '2022');
        insert im;
        
        InvoiceMilestoneDocumentAlyante__c imDA = new InvoiceMilestoneDocumentAlyante__c();
        imDA.InvoiceMilestone__c = im.Id;
        imDA.DocumentAlyante__c = da.Id;
        insert imDA;
        
        
    }
    
    @isTest
    public static void fetchOpportunityIdTest(){
        Id daId = [SELECT Id FROM DocumentAlyante__c].Id;
        Test.startTest();
        CloneDraftInvoiceController.fetchOpportunityId(daId);
        Test.stopTest();
    }
    
    @isTest
    public static void fetchInvoiceMilestoneIdTest(){
        Id daId = [SELECT Id FROM DocumentAlyante__c].Id;
        Test.startTest();
        CloneDraftInvoiceController.fetchInvoiceMilestoneId(daId);
        Test.stopTest();
    }
    
    @isTest
    public static void cloneDocumentDetailsTest(){
        id ddaId = [SELECT Id FROM DocumentDetailAlyante__c].id;
        id daId = [SELECT Id FROM DocumentAlyante__c].id;
        Test.startTest();
		CloneDraftInvoiceController.cloneDocumentDetails(ddaId, daId);
		Test.stopTest();        
    }
}