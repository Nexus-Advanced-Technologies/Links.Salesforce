/**
* @description       : Apex Controller for PDF Page
* @author            : Riccardo Costantini
* @last modified on  : 27--04-2021
* @last modified by  : 
* Modifications Log 
* Ver   Date         Author   Modification
* 0.5.1   14-04-2021   RC   Initial Version
* 0.6.0   27-04-2021   RC   Modifiche concettuali apportate relative al cambio algoritmico dell'Economic Plan
**/

public class PagePDF{
    //Get Quote Object
    public Quote getQuoteObj(){
        String idQuote = ApexPages.currentPage().getParameters().get('id');
        Quote quoteObj = [SELECT Id, Name, Account.Name, Opportunity.Name, Description, IsMarginValid__c, isMinMarginValid__c, Opportunity_Risk_Level__c, 
                          EndDate__c, ProtocolNumber__c, StartDate__c, ApprovedDate__c, Total_Revenue__c, Opportunity_Risk_Level_Description__c,
                          Total_Cost__c, LinksTotalHRCost__c, TotalQuotaATI__c 
                          FROM Quote
                          WHERE Id = :idQuote];
        return quoteObj;
    } 
    
    //Get Quote Line Item
    public List<QuoteLineItem> getQuoteLineItem(){
        String idQuote = ApexPages.currentPage().getParameters().get('id');
        List<QuoteLineItem> getQuoteLineItem = [SELECT Id, Product2.Name, Quantity, UnitPrice, Description,
                                                Revenue_Type__c, TotalCostHR__c, DDTotalCost__c, DDTotal__c, TotalCost__c, 
                                                OvernightAllowanceCost__c, TravelAllowanceCost__c, DDOvernightAllowance__c, DDTravelAllowance__c 
                                                FROM QuoteLineItem
                                                WHERE QuoteId = :idQuote];
        return getQuoteLineItem;
    } 
    
    
    //Get List of Cost
    public List<Cost__c> getCostObj(){
        String idQuote = ApexPages.currentPage().getParameters().get('id');
        List<Cost__c> costObj = [SELECT Id, Cost_Type__c, Quote__r.Name, Quantity__c, Cost_Value__c,
                                 Description__c, Note__c, TotalCostValue__c, ExpectedPaymentsDays__c, DocumentDate__c, Revenue_Type__c 
                                 FROM Cost__c
                                 WHERE Quote__c = :idQuote];
        return costObj;
    }
    
    //Get List of Quote Revenue
    public List<Quote_Revenue__c> getQuoteRevenue(){
        String idQuote = ApexPages.currentPage().getParameters().get('id');
        List<Quote_Revenue__c> getQuoteRevenue = [SELECT Revenue_Type__c, TotalRevenue__c, Customer__c, ExpectedPaymentsDays__c, 
                                                  QuotaATI__c, DocumentDate__c, Note__c, LinksRevenue__c, Quote__r.LinksTotalHRCost__c,
                                                  BillSubject__c, Quote__c, Name, Id 
                                                  FROM Quote_Revenue__c
                                                  WHERE Quote__c = :idQuote];

        return getQuoteRevenue;
    }
    
    public List<EconomicPlanController.EconomicPlan> getEconomicPlanPDF(){
        String idQuote = ApexPages.currentPage().getParameters().get('id');
        return EconomicPlanController.getEconomicPlan(idQuote);
    }
    
    public EconomicPlanController.EconomicPlan getTotalEconomicPlanPDF(){
        String idQuote = ApexPages.currentPage().getParameters().get('id');
        return EconomicPlanController.getTotalEconomicPlan(idQuote);
    }
}