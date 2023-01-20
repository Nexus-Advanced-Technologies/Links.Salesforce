/**
 * @description       : 
 * @author            : ¤ → alessio.marra@nexusat.it
 * @last modified on  : 16/12/2022
 * @last modified by  : ¤ → alessio.marra@nexusat.it
**/
@isTest
private class PdfPreviewControllerTest {

    @testSetup
    static void makeData() {
        IntranetAPI__c intranetAPI = new IntranetAPI__c(
            BaseUrl__c = 'baseUrl',
            Username__c = 'username',
            Password__c = 'password',
            PreviewDocumentEndpoint__c = 'previewDocument'
        );
        insert intranetAPI;

        DocumentAlyante__c document = new DocumentAlyante__c(
            ExtIdAlyante__c = 'extid'
        );
        insert document;
    }

    @isTest
    private static void testGetCredentials() {
        // Test data setup
        IntranetAPI__c intranetAPI = IntranetAPI__c.getOrgDefaults();

        // Actual test
        Test.startTest();
        IntranetAPI__c credentials = PdfPreviewController.getCredentials();
        Test.stopTest();

        // Asserts
        System.assertEquals(intranetAPI, credentials);
    }

    @isTest
    private static void testGetDocumentRecord() {
        // Test data setup
        Id documentId = [SELECT Id FROM DocumentAlyante__c LIMIT 1].Id;

        // Actual test
        Test.startTest();
        DocumentAlyante__c document = PdfPreviewController.getDocumentRecord(documentId);
        Test.stopTest();

        // Asserts
        System.assertEquals(documentId, document.Id);
    }

    
    @isTest
    private static void testGetDocumentRecordWrongId() {
        // Test data setup
        String documentId = 'wrongid';

        // Actual test
        Test.startTest();
        try {
            DocumentAlyante__c document = PdfPreviewController.getDocumentRecord(documentId);
            System.assert(false);
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }
}