/**
* @description       : 
* @author            : Œ
* @last modified on  : 19/10/2022
* @last modified by  : ¤ → alessio.marra@nexusat.it
* Modifications Log 
* Ver   Date         Author   Modification
* 1.0   22-04-2021   Œ   Initial Version
* 1.1   23-04-2021   RC   Add Method generateContentVersionPDF and checkRegisteredStatus for generatinf PDF Page on File Section
* 1.2   12-05-2021   RC   setOpportunityAmount
* 1.3   30-07-2021   RC   generateQuoteNumber,generateProtocolNumber,resetProtocolNumber,hasDocumentProtocol
**/
public without sharing class QuoteTriggerHelper {
    private static final String QUOTE_RECORD_TYPE_LINKS = Schema.getGlobalDescribe().get('Quote').getDescribe().getRecordTypeInfosByName().get('Links').getRecordTypeId();
    
    /**
Assign account pricebook to quotes. 
If account has not pricebook assigned, it's assigned standard one.
*/
    public static void assignAccountPricebookToQuote(List<Quote> quotes){
        List<Quote> quoteList = [
            SELECT Id,AccountId,Pricebook2Id
            FROM Quote 
            WHERE Id IN :quotes 
        ];
        
        System.debug('quotes: '+quoteList);
        List<Id> accountIds = new List<Id>();
        
        for(Quote q : quoteList) {
            System.debug('Account: '+q.AccountId);
            accountIds.add(q.AccountId);            
        }
        Map<Id,Account> accounts = new Map<Id,Account>(
            [SELECT Id,PriceBook__c,Name
             FROM Account
             WHERE Id IN :accountIds ]
        );
        System.debug('Map Account: '+accounts);
        Pricebook2 standardPriceBook;
        if(Test.isRunningTest()) {
            standardPriceBook = new Pricebook2(Id = Test.getStandardPricebookId());
        } else {
            standardPriceBook = [
                SELECT Id,IsActive,IsStandard,Name 
                FROM Pricebook2 
                WHERE IsActive = true 
                AND IsStandard = true 
            ];
        }
        System.debug('Standard PriceBook: '+standardPriceBook);
        for(Quote q : quoteList) {
            System.debug('Quote PriceBook before update: '+q.Pricebook2Id);
            System.debug('Account: '+q.AccountId);
            if(q.AccountId != null){
                Account a = accounts.get(q.AccountId);
                System.debug('Account: '+a.Id+' '+a.Name+' - PriceBook: '+a.PriceBook__c);
                if(a.PriceBook__c != null){
                    q.Pricebook2Id = a.PriceBook__c;
                } else {
                    q.Pricebook2Id = standardPriceBook.Id;
                }
            } else {
                q.Pricebook2Id = standardPriceBook.Id;
            }
            System.debug('Quote PriceBook after update: '+q.Pricebook2Id);
        }
        if (!quoteList.isEmpty()) {
            update quoteList;
        }
    }
    @future(callout = true)
    public static void generateContentVersionPDF(Id quoteId){
        Quote q = [SELECT Id, Name, LastModifiedDate,QuoteNumber__c FROM Quote WHERE Id = :quoteId];
        String formattedDate = q.LastModifiedDate.format('dd-MM-yyyy');
        ContentVersion conVer = new ContentVersion();
        PageReference PDf =  Page.ViewPDFPage;
        PDf.getParameters().put('Id',q.Id);
        PDf.setRedirect(true);
        Blob b ;
        if(!Test.isRunningTest()){
            b = PDf.getContent();
        }else{
            b = Blob.valueOf('Hello');
        }
        conVer.ContentLocation = 'S'; 
        conVer.PathOnClient = '.pdf';
        conVer.Title = 'Economic Plan '+ q.Name + ' ' + formattedDate + '-' + q.QuoteNumber__c.subStringAfter('-'); 
        conVer.VersionData = b;
        insert conVer;    
        
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = q.Id; 
        conDocLink.ContentDocumentId = conDoc;  
        conDocLink.shareType = 'V';
        insert conDocLink;
        
        
        
    }
    public static  Boolean checkRegisteredStatus(Quote quoteNew, Quote quoteOld){
        Boolean statusCheck;
        if(quoteNew.Status == '3' && quoteOld.Status == '2'){
            statusCheck = true;
        }else{
            statusCheck=false;
        }
        return statusCheck;
    }
    
    
    public static void setOpportunityAmount(Quote quoteNew, Quote quoteOld){
        system.debug('************************' + quoteOld.Status);
        List<Opportunity> opportunityToUpdate = new List<Opportunity>(); 
        Id opportunityId = quoteNew.OpportunityId;
        for(Quote q : [SELECT Id, OpportunityId, Total_Revenue__c, Opportunity.Amount, Status, Opportunity.StageName
                       FROM Quote 
                       WHERE OpportunityId =:opportunityId]){
                           if(quoteNew.Id == q.Id && quoteNew.Status == '3' && quoteOld.Status != '3'){
                               Opportunity opp = new Opportunity();
                               opp.Id = quoteNew.OpportunityId;
                               opp.Amount = q.Total_Revenue__c;
                               opp.StageName = 'Quote Presented';
                               opportunityToUpdate.add(opp);
                           } 
                           else if(quoteNew.Id == q.Id && quoteNew.Status == '4' && quoteOld.Status != '4'){
                               Opportunity opp = new Opportunity();
                               opp.Id = quoteNew.OpportunityId;
                               opp.Amount = q.Total_Revenue__c;
                               opp.StageName = 'Milestone Planning';
                               opportunityToUpdate.add(opp);
                           } else if(quoteNew.Id == q.Id && quoteNew.Status == '5' && quoteOld.Status != '5'){
                               Opportunity opp = new Opportunity();
                               opp.Id = quoteNew.OpportunityId;
                               opp.Amount = q.Total_Revenue__c;
                               opp.StageName = 'Closed Lost';
                               opportunityToUpdate.add(opp);
                           }
                       }
        update opportunityToUpdate;
    }
    
    public static void generateQuoteNumber(List<Quote> quoteList){
        Map<Integer,Integer> quoteNumberMap = new Map<Integer,Integer>();
        List<AggregateResult> getQuoteNumber = [SELECT MAX(QuoteNumber__c)MaxQuoteNumber FROM Quote WHERE QuoteNumber__c != '' AND QuoteNumber__c != Null];
        System.debug(getQuoteNumber);
        for(AggregateResult maxQuoteNumber : getQuoteNumber){
            if(maxQuoteNumber.get('MaxQuoteNumber') != Null){
                quoteNumberMap.put(
                    Integer.valueOf(((String)maxQuoteNumber.get('MaxQuoteNumber')).subStringBefore('-')),
                    Integer.valueOf(((String)maxQuoteNumber.get('MaxQuoteNumber')).subStringAfter('-'))
                );
            }
        }
        for(Quote quote : quoteList){
            Integer year = Date.Today().Year();
            Integer quoteNumber = 0;
            if(quoteNumberMap.containsKey(year)){
                quoteNumber = quoteNumberMap.get(year);
            }
            quoteNumber ++;
            quote.QuoteNumber__c = year + '-' + String.valueOf(quoteNumber).leftPad(4, '0');
            quoteNumberMap.put(year,quoteNumber);
        }
    }
    
    
    public static void generateProtocolNumber(List<Quote> listNewQuote,Map<Id,Quote> oldMapQuote){
        Map<String,Integer> quoteProtocolMap = new Map<String,Integer>();
        List<Protocol__c> protocolList = new List<Protocol__c>();
        Set<Id> quoteId = new Set<Id>();
        for(Quote idQuote : listNewQuote){
            quoteId.add(idQuote.Id);
        }
        List<AggregateResult> getQuoteNumber = [SELECT MAX(Name)MaxProtocolNumber FROM Protocol__c WHERE Name != '' AND Name != Null AND Quote__c IN : quoteId];
        for(AggregateResult maxProtocolNumber : getQuoteNumber){
            if(maxProtocolNumber.get('MaxProtocolNumber') != Null){
                quoteProtocolMap.put(
                    ((String)maxProtocolNumber.get('MaxProtocolNumber')).subStringBefore('/'),
                    Integer.valueOf(((String)maxProtocolNumber.get('MaxProtocolNumber')).subStringAfter('/'))
                );
            }
        }
        for(Quote quoteNew : listNewQuote){
            Integer progressive = 0;
            if(quoteProtocolMap.containsKey(quoteNew.QuoteNumber__c)){
                progressive = quoteProtocolMap.get(quoteNew.QuoteNumber__c);
            }
            progressive++;
            if(oldMapQuote.get(quoteNew.Id).Status == '1' && quoteNew.Status == '2'){
                Protocol__c protocolGenerate = new Protocol__c();
                protocolGenerate.Name = quoteNew.QuoteNumber__c + '/' + progressive;
                protocolGenerate.Quote__c =  quoteNew.Id;
                quoteProtocolMap.put(quoteNew.QuoteNumber__c,progressive);
                protocolList.add(protocolGenerate);
            }
            insert protocolList;
            for(Protocol__c p : protocolList){
                quoteNew.Protocol__c = p.Id;
                quoteNew.ProtocolNumber__c = p.Name;
            }
        }
    }
    
    public static void resetProtocolNumber(List<Quote> listNewQuote,Map<Id,Quote> oldMapQuote){
        for(Quote quoteNew : listNewQuote){
            if(oldMapQuote.get(quoteNew.Id).Status != '0' && quoteNew.Status == '0'){
                quoteNew.Protocol__c = Null;
                quoteNew.ProtocolNumber__c = Null;
            }
        }
    }
    
    public static boolean hasDocumentProtocol(Quote newQuote){
        List<ContentDocumentLink> numberContentDocument = [SELECT LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: newQuote.Protocol__c];
        return numberContentDocument.size()<1;
    }
    public static boolean checkStatusQuote(Quote newQuote,Quote oldQuote){
        Boolean checkStatus;
        Integer oldNumber = integer.valueof(oldQuote.Status);
        Integer newNumber = integer.valueof(newQuote.Status);
        String newStatus = string.valueOf(newQuote.Status);
        if(oldNumber<newNumber && newNumber>oldNumber+1 && !newStatus.equals('5')){
            checkStatus = true;
        }else{
            checkStatus = false;
        }
        return checkStatus;
    }
    
    public static Set<Id> getSetId(List<Quote> listObject){
        Set<Id> setIds = new Set<Id>();
        for(Quote ob :  listObject){
            setIds.add(ob.Id);
        }
        return setIds;
    }
    
    public static void generateOrder(List<Quote> newQuoteList){
        try{ 
            Set<Id> quoteId = getSetId(newQuoteList);
            List<Order> listOrderToInsert = generateOrders(newQuoteList);
            insert listOrderToInsert;
            Map<Id,Id> associateOrder = getAssociatedOrder(listOrderToInsert);
            insert generateOrderLineItem(quoteId,associateOrder);
            insert generateCostOrderDetail(quoteId,associateOrder);
        }catch(DmlException  e){
            System.debug('Order Error DmlExceptionException: ' + e.getMessage());
            throw new DmlException('IL NOME INSERITO RISULTA MAGGIORE DELLA LUNGHEZZA CONSENTITA! MODIFICA IL NOME E RIPROVA');
        }
        catch(Exception e){
            System.debug('Order Error AuraException: ' + e.getMessage());
            throw new AuraException('Errore Durante la Generazione Ordine! Controlla i Dati Inseriti e riprova! Contatta Admin di Sistema!' + e.getMessage());
        }
    }
    
    public static List<Order> generateOrders(List<Quote> newQuoteList){
        List<Order> listOrderToInsert = new List<Order>();
        for(Quote quote : newQuoteList){
            Order order = new Order();
            order.AccountId = quote.AccountId;
            order.Amount__c = quote.Total_Revenue__c;
            order.EffectiveDate = Date.Today();
            order.Name = 'Order - ' + quote.Name;
            order.Pricebook2Id = quote.Pricebook2Id;
            order.QuoteId = quote.Id;
            order.Status = 'Draft';
            listOrderToInsert.add(order);
        }
        return listOrderToInsert;
    }
    
    public static Map<Id,Id> getAssociatedOrder(List<Order> orderList){
        Map<Id,Id> mapAssociatdOrder = new Map<Id,Id>();
        
        for(Order order : orderList){
            mapAssociatdOrder.put(order.QuoteId,order.Id);
            
        }
        return mapAssociatdOrder;
    }
    
    
    public static List<OrderItem> generateOrderLineItem(Set<Id> quoteIds,Map<Id,Id> mapAssociatdOrder){
        List<QuoteLineItem> quoteLineItemList = [SELECT id,DDTotal__c,DDOvernightAllowance__c,DDTotalCost__c,DDTravelAllowance__c,ListPrice,Description,OvernightAllowanceCost__c,
                                                 Quantity,Revenue_Type__c,TotalCostHR__c,TravelAllowanceCost__c,UnitPrice,PricebookEntryId,QuoteId
                                                 FROM QuoteLineItem
                                                 WHERE QuoteId IN : quoteIds];
        List<OrderItem> orderItemToInsert = new List<OrderItem>();
        for(QuoteLineItem quoteLineItem : quoteLineItemList){
            OrderItem orderItem = new OrderItem();
            orderItem.DDTotal__c = quoteLineItem.DDTotal__c;
            orderItem.DDOvernightAllowance__c = quoteLineItem.DDOvernightAllowance__c;
            orderItem.DDTravelAllowance__c = quoteLineItem.DDTravelAllowance__c;
            orderItem.ListPrice = quoteLineItem.ListPrice;
            orderItem.Description = quoteLineItem.Description;
            orderItem.Quantity = quoteLineItem.Quantity;
            orderItem.RevenueType__c = quoteLineItem.Revenue_Type__c;
            orderItem.TotalCostHR__c = quoteLineItem.TotalCostHR__c;
            orderItem.UnitPrice = quoteLineItem.UnitPrice;
            orderItem.OrderId = mapAssociatdOrder.get(quoteLineItem.QuoteId);
            orderItem.PricebookEntryId = quoteLineItem.PricebookEntryId;
            orderItemToInsert.add(orderItem);
        }
        return orderItemToInsert;
    }
    
    public static List<Cost_Order_Detail__c> generateCostOrderDetail(Set<Id> quoteIds, Map<Id,Id> mapAssociatdOrder){
        List<Cost__c> costList = [SELECT id,Quote__c FROM Cost__c WHERE Quote__c IN : quoteIds];
        List<Cost_Order_Detail__c> orderCostToInsert = new List<Cost_Order_Detail__c>();
        for(Cost__c cost : costList){
            Cost_Order_Detail__c costOrderDetail = new Cost_Order_Detail__c();
            costOrderDetail.Related_Cost__c = cost.Id;
            costOrderDetail.Order__c = mapAssociatdOrder.get(cost.Quote__c);
            orderCostToInsert.add(costOrderDetail);
        }
        return orderCostToInsert;
    }

    public static void checkOneQuoteForOpportunity(List<Quote> triggerNew) {
        Set<Id> opportunityIds = new Set<Id>();
        for (Quote quote : triggerNew) {
            opportunityIds.add(quote.OpportunityId);
        }
        List<AggregateResult> aggrOpportunitiesWithMoreQuote = [
            SELECT OpportunityId
            FROM Quote
            WHERE OpportunityId IN :opportunityIds
            AND RecordTypeId = :QUOTE_RECORD_TYPE_LINKS
            GROUP BY OpportunityId
            HAVING count(Id) > 1
        ];
        Set<Id> opportunityIdsWithMoreQuote = new Set<Id>();
        for (AggregateResult aggr : aggrOpportunitiesWithMoreQuote) {
            opportunityIdsWithMoreQuote.add((Id)aggr.get('OpportunityId'));
        }
        for (Quote quote : triggerNew) {
            if (opportunityIdsWithMoreQuote.contains(quote.OpportunityId)) {
                quote.addError(Label.ErrorMoreQuote);
            }
        }
    }
}