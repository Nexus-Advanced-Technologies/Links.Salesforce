/**
 * @description       : 
 * @author            : Œ
 * @group             : 
 * @last modified on  : 04-05-2021
 * @last modified by  : Œ
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   03-25-2021   Œ   Initial Version
**/
public class QuoteLineItemTriggerHelper {
    

    public static void quoteLineItemUpdateTotalHRCost(List<QuoteLineItem> triggerQuoteLine) {
        System.debug('Œ QuoteLineItemTriggerHelper - quoteLineItemUpdateTotalHRCost'  );
        
       
       
      Set<Id> quoteIDLst = new Set<Id>(); 
        for (QuoteLineItem record : triggerQuoteLine){
            quoteIDLst.add(record.QuoteId);
        }
        System.debug('Œ quoteLineItemUpdateTotalHRCost  QUOTE ID LIST' + quoteIDLst);

        List<Quote> quoteList = [SELECT Id, LinksTotalHRCost__c, (SELECT id, TotalCost__c FROM QuoteLineItems)
                                 FROM Quote
                                 WHERE id =:quoteIDLst];

        List<Quote> updatedQuoteList = new List<Quote>();
       
        for (Quote quoteRecord : quoteList){
          
            quoteRecord.LinksTotalHRCost__c = 0;
            for (QuoteLineItem quoteLineItemRecord: quoteRecord.QuoteLineItems){
                    quoteRecord.LinksTotalHRCost__c +=   quoteLineItemRecord.TotalCost__c;               
            }
           Quote q = new Quote(
             id = quoteRecord.id,
             LinksTotalHRCost__c = quoteRecord.LinksTotalHRCost__c
           );
           updatedQuoteList.add(q);
        }

        update updatedQuoteList;
      
       
    }
}