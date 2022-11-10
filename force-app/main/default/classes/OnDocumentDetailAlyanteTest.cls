/**
 * @description       : 
 * @author            : §
 * @group             : 
 * @last modified on  : 01-20-2022
 * @last modified by  : §
**/
@isTest
public class OnDocumentDetailAlyanteTest {
    private static final Id ACTIVE_INVOICE_RT = getDocumentRecordTypeIdByDeveloperName('ActiveInvoice');
    @TestSetup static void makeData(){
        
        User testUser = createUser();
        insert testUser;
        
        Account testAccount = createAccount('Test Account');
        insert testAccount;
        
        DocumentAlyante__c invoice = createDocumentAlyante('Emitted', testAccount.Id, ACTIVE_INVOICE_RT);
        insert invoice;
    }
    
    private static DocumentDetailAlyante__c createDocument(){
        Id createDocumentDetailAlyante = [SELECT Id FROM DocumentAlyante__c LIMIT 1].Id;
        
        return new DocumentDetailAlyante__c(
            Document__c = createDocumentDetailAlyante
        );    
    }
    
    @isTest static void insertDocumentDetailTest() {
        User u = [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
       
        TriggerUtilities.TriggerSettingDocumentDetailAlyante = createCustomMetadata(true);
        System.runAs(u) {
            Test.startTest();
            try {
                insert createDocument();
                System.assert(false);
            } catch(Exception e) {
                System.assert(true);
            }
            
            Test.stopTest();
        }
    }
    
    
    private static User createUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        String username = 'testuser@test' + Math.round(Math.random() * 10000) + '.com';
        
        return new User(
            Alias = 'standt',
            Email = username,
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = username
        );
    }
    
    private static Id getDocumentRecordTypeIdByDeveloperName(String rtDeveloperName) {
        return Schema.sObjectType.DocumentAlyante__c.getRecordTypeInfosByDeveloperName().get(rtDeveloperName).getRecordTypeId();
    }
    
    private static Account createAccount(String name) {
        return new Account(
            Name = name
        );
    }
    
    private static DocumentAlyante__c createDocumentAlyante(String status, Id accountId, Id rtId) {
        return new DocumentAlyante__c(
            Status__c = status,
            Account__c = accountId,
            RecordTypeId = rtId
        );
    }
    
    private static DocumentDetailAlyante__c createDocumentDetailAlyante(Id documentAlyanteId){
        return new DocumentDetailAlyante__c(
            Document__c = documentAlyanteId
        );
    }

    private static List<TriggerSetting__mdt> createCustomMetadata(Boolean status) {
		List<TriggerSetting__mdt> triggerSettingMDT = (List<TriggerSetting__mdt>) Json.deserialize(
			'[' +
				'{' +
					'"DeveloperName": "Links",' +
					'"DocumentDetailAlyanteBeforeInsert__c": "' + status + '"' +
				'}' +
			']'
			,List<TriggerSetting__mdt>.class
		); 
		return triggerSettingMDT;
	}
}