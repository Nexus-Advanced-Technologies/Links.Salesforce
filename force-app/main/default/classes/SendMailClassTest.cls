/**
* @description       : 
* @author            : 
* @last modified on  : 25/01/2021
* @last modified by  : ¤ → alessio.marra@nexusat.it
* Modifications Log 
* Ver   Date         Author                         Modification
* 1.0                                               Initial Version
* 1.1   25/01/2021   ¤ → alessio.marra@nexusat.it   Review ApiName Nomenclature
**/
@isTest
private class SendMailClassTest {
    public static String getRecordTypeId(String sobjectName, String recordTypeName){
        
        return Schema.getGlobalDescribe().get(sobjectName).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    }
    @TestSetup
    static void dataFactory(){
        //Insert Profile
        Profile pf= [Select Id 
                     FROM profile 
                     WHERE Name='System Administrator' OR Name='Amministratore del sistema'];
        
        //Insert User
        User u = new User(
            ProfileId = pf.Id,
            LastName = 'Test',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u;
        
        //Insert Account
        Account testAccount = New Account(Name = 'testAccount');
        insert testAccount;
        
        //Insert Contact
        Contact testContactCustomer = new Contact(FirstName = 'Test', LastName = 'Test', AccountId = testAccount.Id);
        insert testContactCustomer;
        
        //Get RecordType of Tipo_Pagamento_Dettaglio __c -->Recursive
        Id tpdRtRicorsicoId = [SELECT Id FROM RecordType WHERE DeveloperName = 'NexusRecursive' AND SObjectType = 'PaymentTypeDetail__c'].Id;
        
        //Insert Tipo_Pagamento__C -->Recursive
        PaymentType__c tpTest= new PaymentType__c();
        tpTest.Name = 'Test';
        tpTest.Type__c = 'Recursive';
        insert tptest;
        
        //Get Id of Tipo_Pagamento_Dettaglio __c -->Recursive
        Id tpTestRecursiveId = [SELECT Id 
                                FROM PaymentType__c 
                                WHERE Type__c = 'Recursive'
                                LIMIT 1].Id;
        
        //Insert Tipo_Pagamento_Dettaglio __c -->Recursive
        PaymentTypeDetail__c tpdtest = new PaymentTypeDetail__c();
        tpdTest.Name = 'Test';
        tpdTest.RecordTypeId = tpdRtRicorsicoId;
        tpdTest.FeeCount__c = 3;
        tpdTest.MeasurementUnitMonthly__c = 3;
        tpdTest.FeeValue__c = 1000;
        tpdTest.PaymentType__c = tpTestRecursiveId;
        insert tpdTest;
        
        //Custom setting
        SetAddressSetting__c cs = new SetAddressSetting__c();
        cs.DeliveryDefault__c = 'a@a.gmail.com';
        cs.SalesDefault__c = 'a@a.gmail.com';
        cs.EmailCDG__c = 'a@a.gmail.com';
        cs.OtherAddress__c = 'a@a.gmail.com';
        insert cs;
        
        OpportunitySetting__c sett = new OpportunitySetting__c(
            FteWhere__c = 'Name = \'oppTest\''
        );
        insert sett;
        
        //Insert Opportunity -->Recursive
        Opportunity opp = New Opportunity();
        opp.Name = 'oppTest';
        opp.AccountId = testAccount.Id;
        opp.CloseDate = Date.today();
        opp.StageName = 'Prospecting';
        opp.PaymentType__c = tpTestRecursiveId;
        opp.ReferenceNumber__c = 'NX';
        insert opp;
        
        //Get Reference_Number__c of Opportunity
        String oppReferenceNumberTest = [SELECT ReferenceNumber__c FROM Opportunity LIMIT 1].ReferenceNumber__c;
        System.debug('Ø---------ReferenceNumber__c '+oppReferenceNumberTest);
        
        //Update Opportunity to Stage = Proposal/Price Quote
        Opportunity opp1 = [SELECT Id, StageName 
                            FROM Opportunity
                            WHERE Name = 'oppTest'
                            LIMIT 1];
        opp1.StageName = 'Proposal/Price Quote';
        update opp1;
        
        //Get RecordType of Invoice_Milestone__c
        Id invMilRecTypId = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'NexusRecursive' AND SObjectType = 'InvoiceMilestone__c'].Id;
        
        //Insert Invoice_Milestone__c
        InvoiceMilestone__c imTest = New InvoiceMilestone__c();
        imTest.Name = 'Invoice Milestone Test';
        imTest.Opportunity__c = opp.Id;
        imTest.ExpectedDate__c = Date.today();
        imTest.RecordTypeId = invMilRecTypId;
        insert imTest;        
        
        //Insert ContentVersion
        ContentVersion cv = new ContentVersion(
            ContentLocation = 'S',
            VersionData = Blob.valueOf('Fake Content'),
            Title = oppReferenceNumberTest +'.pdf',
            PathOnClient = oppReferenceNumberTest +'.pdf',
            TagCsv = null
        );
        insert cv;
        
        //get ContentDocumentId
        Id cdId = [SELECT Id, ContentDocumentId 
                   FROM ContentVersion 
                   LIMIT 1].ContentDocumentId;
        
        //Insert ContentDocumentLink
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = opp.Id;
        cdl.ContentDocumentId = cdId;
        cdl.ShareType = 'V';      
        insert cdl;
    }
    @isTest
    static void SendEmailGetOppFieldTest(){
        Id oppId = [SELECT Id 
                    FROM Opportunity
                    LIMIT 1].Id;
        
        SendEmailClass.getOppField(oppId);
    }
    @isTest
    static void SendEmailBodyTest(){
        Id oppId = [SELECT Id 
                    FROM Opportunity
                    LIMIT 1].Id;
        
        SendEmailClass.EmailBody(oppId);
    }
    @isTest
    static void SendOppBodyTest(){
        Id oppId = [SELECT Id 
                    FROM Opportunity
                    LIMIT 1].Id;
        
        SendEmailClass.OppBody(oppId);
    }
    @isTest
    static void sendEmailTest(){
        Id oppId = [SELECT Id 
                    FROM Opportunity
                    LIMIT 1].Id;
        
        SendEmailClass.sendEmail(oppId);
    }
    @isTest
    static void sendTestEmailAllStates(){
        Id oppId = [SELECT Id 
                    FROM Opportunity
                    LIMIT 1].Id;
        List<String> toAddressListTest = new List<String>();
        toAddressListTest.add('test@test.it');
        SendEmailClass.sendEmailAllStates(oppId, toAddressListTest);
    }    
    @isTest
    static void OpportunityOneShot(){
        Id accountId = [SELECT Id 
                        FROM Account
                        LIMIT 1].Id;
        
        //Insert Tipo_Pagamento__C -->One Shot
        PaymentType__c tpOneShotTest= New PaymentType__c();
        tpOneShotTest.Name = 'Test';
        tpOneShotTest.Type__c = 'One Shot';
        insert tpOneShotTest;
        
        //Get Id of Tipo_Pagamento_Dettaglio __c -->One Shot
        Id tpTestOneShotId = [SELECT Id 
                              FROM PaymentType__c 
                              WHERE Type__c = 'One Shot'
                              LIMIT 1].Id;
        
        Id tpdRtOneShotId = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'NexusOneShot' AND SObjectType = 'PaymentTypeDetail__c'].Id;
        
        //Insert Tipo_Pagamento_Dettaglio __c -->One Shot
        PaymentTypeDetail__c tpdOneShotTest = new PaymentTypeDetail__c();
        tpdOneShotTest.Name = 'Test';
        tpdOneShotTest.RecordTypeId = tpdRtOneShotId;
        tpdOneShotTest.PaymentType__c = tpTestOneShotId;
        tpdOneShotTest.Value__c = 20;
        tpdOneShotTest.Rank__c = 1;
        insert tpdOneShotTest;
        
        //Insert Opportunity -->One Shot
        Opportunity opp = New Opportunity();
        opp.Name = 'oppTest2';
        opp.AccountId = accountId;
        opp.CloseDate = Date.today();
        opp.StageName = 'Prospecting';
        opp.PaymentType__c = tpTestOneShotId;
        opp.Amount = 1234;
        opp.RecordTypeId = getRecordTypeId('Opportunity','Links');
        insert opp;
        
        //Update Opportunity to Stage = Proposal/Price Quote
        Opportunity opp1 = [SELECT Id, StageName 
                            FROM Opportunity
                            WHERE Name = 'oppTest2'
                            LIMIT 1];
        opp1.StageName = 'Proposal/Price Quote';
        update opp1;
        PianificazioneFattureController.createInvoiceMilestone(opp1.Id);
    }
    @isTest
    static void OpportunityRecursive(){
        Id accountId = [SELECT Id 
                        FROM Account
                        LIMIT 1].Id;
        
        //Insert Tipo_Pagamento__C -->Recursive
        PaymentType__c tpOneShotTest = new PaymentType__c();
        tpOneShotTest.Name = 'Test';
        tpOneShotTest.Type__c = 'Recursive';
        insert tpOneShotTest;
        
        //Get Id of Tipo_Pagamento_Dettaglio __c -->One Shot
        Id tpTestRecId = [SELECT Id 
                          FROM PaymentType__c 
                          WHERE Type__c = 'Recursive'
                          LIMIT 1].Id;
        
        Id tpdRtRectId = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'NexusRecursive' AND SObjectType = 'PaymentTypeDetail__c'].Id;
        
        //Insert Tipo_Pagamento_Dettaglio __c -->One Shot
        PaymentTypeDetail__c tpdOneShotTest = new PaymentTypeDetail__c();
        tpdOneShotTest.Name = 'Test';
        tpdOneShotTest.MeasurementUnitMonthly__c = 2;
        tpdOneShotTest.FeeCount__c = 1;
        tpdOneShotTest.RecordTypeId = tpdRtRectId;
        tpdOneShotTest.PaymentType__c = tpTestRecId;
        tpdOneShotTest.Value__c = 20;
        insert tpdOneShotTest;
        
        //Insert Opportunity -->One Shot
        Opportunity opp = New Opportunity();
        opp.Name = 'oppTest2';
        opp.AccountId = accountId;
        opp.CloseDate = Date.today();
        opp.StageName = 'Prospecting';
        opp.PaymentType__c = tpTestRecId;
        opp.Amount = 1234;
        opp.RecordTypeId = getRecordTypeId('Opportunity','Links');
        insert opp;
        
        //Update Opportunity to Stage = Proposal/Price Quote
        Opportunity opp1 = [SELECT Id, StageName 
                            FROM Opportunity
                            WHERE Name = 'oppTest2'
                            LIMIT 1];
        opp1.StageName = 'Proposal/Price Quote';
        update opp1;
        PianificazioneFattureController.createInvoiceMilestone(opp1.Id);
    }
}