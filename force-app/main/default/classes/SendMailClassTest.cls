@isTest
private class SendMailClassTest {    
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
        Id tpdRtRicorsicoId = [SELECT Id, DeveloperName 
                               FROM RecordType 
                               WHERE DeveloperName = 'Ricorsivo'].Id;
        
        //Insert Tipo_Pagamento__C -->Recursive
        Tipo_Pagamento__c tpTest= New Tipo_Pagamento__c();
        tpTest.Name = 'Test';
        tpTest.Tipo__c = 'Recursive';
        insert tptest;
        
        //Get Id of Tipo_Pagamento_Dettaglio __c -->Recursive
        Id tpTestRecursiveId = [SELECT Id 
                                FROM Tipo_Pagamento__c 
                                WHERE Tipo__c = 'Recursive'
                                LIMIT 1].Id;
        
        //Insert Tipo_Pagamento_Dettaglio __c -->Recursive
        Tipo_Pagamento_Dettaglio__c tpdtest = New Tipo_Pagamento_Dettaglio__c();
        tpdTest.Name = 'Test';
        tpdTest.RecordTypeId = tpdRtRicorsicoId;
        tpdTest.Numero_Canoni__c = 3;
        tpdTest.Unit_di_misura__c = 3;
        tpdTest.Valore_Canone__c = 1000;
        tpdTest.Tipo_Pagamento__c = tpTestRecursiveId;
        insert tpdTest;
        
        //Custom setting
        setAddress__c cs = new setAddress__c();
        cs.DeliveryDefault__c = 'a@a.gmail.com';
        cs.SalesDefault__c = 'a@a.gmail.com';
        cs.emailCDG__c = 'a@a.gmail.com';
        cs.otherAddress__c = 'a@a.gmail.com';
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
        opp.Tipo_Pagamento__c = tpTestRecursiveId;
        opp.Reference_Number__c = 'NX';
        insert opp;
        
        //Get Reference_Number__c of Opportunity
        String oppReferenceNumberTest = [SELECT Reference_Number__c FROM Opportunity LIMIT 1].Reference_Number__c;
        System.debug('Ø---------Reference_Number__c '+oppReferenceNumberTest);
        
        //Update Opportunity to Stage = Proposal/Price Quote
        Opportunity opp1 = [SELECT Id, StageName 
                            FROM Opportunity
                            WHERE Name = 'oppTest'
                            LIMIT 1];
        opp1.StageName = 'Proposal/Price Quote';
        update opp1;
        
        //Get RecordType of Invoice_Milestone__c
        Id invMilRecTypId = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'Recursive'].Id;
        
        //Insert Invoice_Milestone__c
        Invoice_Milestone__c imTest = New Invoice_Milestone__c();
        imTest.Name = 'Invoice Milestone Test';
        imTest.Opportunity__c = opp.Id;
        imTest.Data_prevista__c = Date.today();
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
        Tipo_Pagamento__c tpOneShotTest= New Tipo_Pagamento__c();
        tpOneShotTest.Name = 'Test';
        tpOneShotTest.Tipo__c = 'One Shot';
        insert tpOneShotTest;
        
        //Get Id of Tipo_Pagamento_Dettaglio __c -->One Shot
        Id tpTestOneShotId = [SELECT Id 
                              FROM Tipo_Pagamento__c 
                              WHERE Tipo__c = 'One Shot'
                              LIMIT 1].Id;
        
        Id tpdRtOneShotId = [SELECT Id, DeveloperName 
                             FROM RecordType 
                             WHERE DeveloperName = 'One_Shoot'].Id;
        
        //Insert Tipo_Pagamento_Dettaglio __c -->One Shot
        Tipo_Pagamento_Dettaglio__c tpdOneShotTest = New Tipo_Pagamento_Dettaglio__c();
        tpdOneShotTest.Name = 'Test';
        tpdOneShotTest.RecordTypeId = tpdRtOneShotId;
        tpdOneShotTest.Tipo_Pagamento__c = tpTestOneShotId;
        tpdOneShotTest.Valore__c = 20;
        tpdOneShotTest.Rank__c = 1;
        insert tpdOneShotTest;

        //Insert Opportunity -->One Shot
        Opportunity opp = New Opportunity();
        opp.Name = 'oppTest2';
        opp.AccountId = accountId;
        opp.CloseDate = Date.today();
        opp.StageName = 'Prospecting';
        opp.Tipo_Pagamento__c = tpTestOneShotId;
        opp.Amount = 1234;
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
        Tipo_Pagamento__c tpOneShotTest= New Tipo_Pagamento__c();
        tpOneShotTest.Name = 'Test';
        tpOneShotTest.Tipo__c = 'Recursive';
        insert tpOneShotTest;
        
        //Get Id of Tipo_Pagamento_Dettaglio __c -->One Shot
        Id tpTestRecId = [SELECT Id 
                              FROM Tipo_Pagamento__c 
                              WHERE Tipo__c = 'Recursive'
                              LIMIT 1].Id;
        
        Id tpdRtRectId = [SELECT Id, DeveloperName 
                             FROM RecordType 
                             WHERE DeveloperName = 'Ricorsivo'].Id;
        
        //Insert Tipo_Pagamento_Dettaglio __c -->One Shot
        Tipo_Pagamento_Dettaglio__c tpdOneShotTest = New Tipo_Pagamento_Dettaglio__c();
        tpdOneShotTest.Name = 'Test';
        tpdOneShotTest.Unit_di_misura__c = 2;
        tpdOneShotTest.Numero_Canoni__c = 1;
        tpdOneShotTest.RecordTypeId = tpdRtRectId;
        tpdOneShotTest.Tipo_Pagamento__c = tpTestRecId;
        tpdOneShotTest.Valore__c = 20;
        insert tpdOneShotTest;

        //Insert Opportunity -->One Shot
        Opportunity opp = New Opportunity();
        opp.Name = 'oppTest2';
        opp.AccountId = accountId;
        opp.CloseDate = Date.today();
        opp.StageName = 'Prospecting';
        opp.Tipo_Pagamento__c = tpTestRecId;
        opp.Amount = 1234;
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