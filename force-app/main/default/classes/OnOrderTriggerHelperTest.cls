@isTest
public class OnOrderTriggerHelperTest {
    
    @TestSetup
    static void makeData(){
        
        Account a = new Account();
        a.Name = 'Test Name';
        insert a;
        
        Product2 prod = new Product2(Name = 'Intern 2021',
                                     Family = 'Standard',
                                     ProductCoDe = 'IN',
                                     IsActive = true);
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = prod.Id,
            UnitPrice = 10000, 
            IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Links', 
                                             isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, 
            Product2Id = prod.Id,
            UnitPrice = 12000, 
            IsActive = true);
        insert customPrice;
        
        Id rtId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Links' AND SObjectType = 'Order' LIMIT 1].id;
        
        Order o = new Order();
        o.RecordTypeId = rtId;
        o.EffectiveDate = date.today();
        o.AccountId = a.Id;
        o.Status = 'Draft';
        o.Pricebook2Id = customPB.Id;
        insert o;
        
        OrderItem oi = new OrderItem();
        oi.Product2Id = prod.Id;
        oi.ListPrice = customPrice.UnitPrice;
        oi.Quantity = 3;
        oi.UnitPrice = 50;
        oi.OrderId = o.id;
        oi.PricebookEntryId = customPrice.Id;
        insert oi;
        
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'test',
            PathOnClient   = 'test.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
        List<ContentDocument> documents = [SELECT Id, Title FROM ContentDocument];
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = documents[0].id;
        cdl.LinkedEntityId = o.Id;
        insert cdl;
    }
    
    @isTest
    public static void hasContractOrderTest(){
        
        Order o = [SELECT Status FROM Order LIMIT 1];
        o.Status = 'Activated';
        update o;
        test.startTest();
        OnOrderTriggerHelper.hasContractOrder(o);
        test.stopTest();
    }
    
}