/**
 * @description       : 
 * @author            : francesco.coli@nexusat.it
 * @last modified on  : 19/09/2022
 * @last modified by  : francesco.coli@nexusat.it
**/
@isTest
public class CreateIntranetQuote_test{

    @TestSetup
    static void makeData(){
        IntranetQuoteGeneration__c custSettings = new IntranetQuoteGeneration__c(
            PriceBookName__c = 'Links2022',
            ProductCode__c = 'CS',
            ProductName__c = 'Consultant',
            RevenueType__c = '6'
        );
        insert custSettings;

        Account account = new Account(
            Name = 'TestAcc',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId()
        );
        insert account;

        Product2 productt = new Product2(
            Name = 'Consultant',
            ProductCode = 'CS',
            IsActive = true
        );
        insert productt;

        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = productt.Id,
            UnitPrice = 10000,
            IsActive = true);
        insert standardPrice;
 
        PaymentType__c paymentType = new PaymentType__c(
            Name = '100% allordine',
            Type__c = 'One Shot',
            RecordTypeId = Schema.SObjectType.PaymentType__c.getRecordTypeInfosByName().get('Nexus').getRecordTypeId()
        );
        insert paymentType;

        Opportunity opportunity = new Opportunity(
            Name = 'test123',
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Nexus').getRecordTypeId(),
            AccountId = account.Id,
            CloseDate = Date.today(),
            StageName = 'Qualification',
            Amount = 20000,
            PaymentType__c = paymentType.Id
        );
        insert opportunity;

        Pricebook2 pricebook = new Pricebook2(
            Name = 'Links 2022',
            ExtId__c = 'Links2022',
            RecordTypeId = Schema.SObjectType.Pricebook2.getRecordTypeInfosByName().get('Links').getRecordTypeId()
        );
        insert pricebook;

        PricebookEntry pricebookentry = new PricebookEntry(
            Pricebook2Id = pricebook.Id,
            Product2Id = productt.Id,
            UnitPrice = 175,
            IsActive = true,
            UseStandardPrice = false
        );
        insert pricebookentry;

        RevenueTypesCS__c revenuetypecs = new RevenueTypesCS__c(
            DefaultMargin__c = 35,
            Name = 'Fixed-Price Projects/Services',
            MinMargin__c = 32
        );
        insert revenuetypecs;       
    }
    @isTest 
    public static void testUploadFile (){
        String base64 = EncodingUtil.base64Encode(Blob.valueof('teststring'));
        String filename = 'Test name 123';
        String recordId = [SELECT Id FROM Opportunity LIMIT 1].Id;


        test.startTest();
        createIntranetQuote.uploadFile(base64, filename, recordId);
        test.stopTest();

        }


}
