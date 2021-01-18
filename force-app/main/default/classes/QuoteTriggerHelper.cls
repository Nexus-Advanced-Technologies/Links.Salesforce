public class QuoteTriggerHelper {

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
            [SELECT Id,Price_Book__c,Name
            FROM Account
            WHERE Id IN :accountIds]
        );
        System.debug('Map Account: '+accounts);
        Pricebook2 standardPriceBook = [
            SELECT Id,IsActive,IsStandard,Name 
            FROM Pricebook2 
            WHERE IsActive = true 
                AND IsStandard = true
        ];           
        System.debug('Standard PriceBook: '+standardPriceBook);
        for(Quote q : quoteList) {
            System.debug('Quote PriceBook before update: '+q.Pricebook2Id);
            System.debug('Account: '+q.AccountId);
            if(q.AccountId != null){
                Account a = accounts.get(q.AccountId);
                System.debug('Account: '+a.Id+' '+a.Name+' - PriceBook: '+a.Price_Book__c);
                if(a.Price_Book__c != null){
                    q.Pricebook2Id = a.Price_Book__c;
                } else {
                    q.Pricebook2Id = standardPriceBook.Id;
                }
            } else {
                q.Pricebook2Id = standardPriceBook.Id;
            }
            System.debug('Quote PriceBook after update: '+q.Pricebook2Id);
        }
        update quoteList;
    }
}