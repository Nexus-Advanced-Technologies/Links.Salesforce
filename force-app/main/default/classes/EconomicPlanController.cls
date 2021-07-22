/**
 * @description       : Apex Controller for LWC economicPlanTableComponent 
 * @author            : Œ | Mirco Centrone
 * @last modified on  : 19-07-2021
 * @last modified by  : Œ
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 0.5.1   01-04-2021   Œ   Initial Version
 * 0.6.0   26-04-2021   Œ   Modifiche all'algoritmo di approvazione e calcolo dell'economicPlan, richieste dal cliente.
 * 0.6.1   07-07-2021   Œ   Aggiunti campi in Update nel metodo setQuoteIsMarginValid che ritornano dal Javascript.
**/

public without sharing class EconomicPlanController {

    public without sharing class EconomicPlan{
        @AuraEnabled public String revenueType{get;set;}
        @AuraEnabled public Double costHR{get;set;}
        @AuraEnabled public Double cost{get;set;}
        @AuraEnabled public Double linksRevenue{get;set;}
        @AuraEnabled public Double ATI{get;set;}
        @AuraEnabled public Double totalRevenue;
        @AuraEnabled public Double defaultMarginPercent{get;set;}
        @AuraEnabled public Double minMarginPercent{get;set;}
        @AuraEnabled public Double minMargin{get;set;}
        @AuraEnabled public Double margin{get;set;}
        @AuraEnabled public Double profit;
        @AuraEnabled public Boolean marginCheck{get;set;}
        @AuraEnabled public Boolean rowError{get;set;}

        public void setMarginProfit(){
            this.margin = this.linksRevenue - this.costHR - this.cost;
            if(this.linksRevenue!=0){
                this.profit = ((this.linksRevenue - this.costHR - this.cost)/ (this.linksRevenue));
            }else{
                this.profit = 0;
            }
        }
        public Double getProfit(){
            return this.profit;
        }

        public void setMarginCheck(){
            this.marginCheck = this.profit >= this.defaultMarginPercent ? true : false; 
        }  
        public Boolean getMarginCheck(){
            return this.marginCheck;
        }

        public void setMinMargin(){
            this.minMargin = this.linksRevenue * this.minMarginPercent ;
        } 
        public Double getMinMargin(){
            return this.minMargin;
        }

        public void setTotalRevenue(){
            this.totalRevenue = this.linksRevenue + this.ATI;
        }
        public Double getTotalRevenue(){
            return this.totalRevenue;
        } 
    }

     /**
    * @description  : Wrapper for the Javascript callback.
    * @author Œ | 01-04-2021 
    **/
    @TestVisible
    private class CustomWrapper{
        @AuraEnabled
        public Id quoteId { get; set; }
        @AuraEnabled
        public Boolean marginCheck{ get; set; }
        @AuraEnabled
        public Boolean totalMarginCheck{ get; set; }
        @AuraEnabled
        public Integer costHRMargin{ get; set;}
        @AuraEnabled
        public Integer costMargin{ get; set;}
    } 

    /**
    * @description  : Get Economic Plan fields from Quote's related objects and calculate if profit margin is valid for each Revenue Type.
    * @author Œ | 01-04-2021 
    * @param id quoteID 
    * @return List<EconomicPlan>
    **/
    @AuraEnabled(cacheable=true)
    public static List<EconomicPlan> getEconomicPlan(id quoteID){
        System.debug('Œ EconomicPlanController.getEconomicPlan{ ');

        List<EconomicPlan> econPlanList = new List<EconomicPlan>();
        Map<String,AggregateResult> quoteHRCostMap = getQuoteHRCosts(quoteID);
        Map<String,AggregateResult> quoteCostMap = getQuoteCosts(quoteID);
        Map<String,AggregateResult> quoteRevenueMap = getQuoteRevenues(quoteID);
    
        Set<String> revenueTypeKeySet = new Set<String>();
        revenueTypeKeySet.addAll(quoteHRCostMap.keySet());
        revenueTypeKeySet.addAll(quoteCostMap.keySet());
        revenueTypeKeySet.addAll(quoteRevenueMap.keySet());

        for (String rT: revenueTypeKeySet){
            EconomicPlan econPlan= new EconomicPlan(); 
            econPlan.revenueType = rT;
           
            if(quoteRevenueMap.containsKey(rT)){
                econPlan.linksRevenue = getRevenue(quoteRevenueMap.get(rT)) !=null ? getRevenue(quoteRevenueMap.get(rT)) : 0;
                econPlan.ATI = getRevenueATI(quoteRevenueMap.get(rT)) !=null ? getRevenueATI(quoteRevenueMap.get(rT)) : 0;
            }else{
                econPlan.linksRevenue = 0;
                econPlan.ATI = 0;
            }
            if(quoteHRCostMap.containsKey(rT)){
                econPlan.costHR = getHRCost(quoteHRCostMap.get(rT)) !=null ? getHRCost(quoteHRCostMap.get(rT)) : 0;
            }else{
                econPlan.costHR = 0;
            }
            if(quoteCostMap.containsKey(rT)){
                econPlan.cost = getCost(quoteCostMap.get(rT)) !=null ? getCost(quoteCostMap.get(rT)) : 0;
            }else{
                econPlan.cost = 0;
            }
            econPlan.setMarginProfit();
            econPlan.setTotalRevenue();
            econplan.rowError = false;
            try {
                //Get DefaultMarginPercent, MinMarginPercent values for the current Revenue Type (rT), from RevenueTypesCS__c Custom Setting.
                RevenueTypesCS__c rTCustomSetting = RevenueTypesCS__c.getInstance(rT);
                econplan.defaultMarginPercent = rTCustomSetting.DefaultMargin__c /100;
                econplan.setMarginCheck();
                econplan.minMarginPercent = rTCustomSetting.MinMargin__c /100;
                econplan.setMinMargin();
            } catch (NullPointerException e) {
                //If Revenue type is not found then:
                econplan.defaultMarginPercent = null;
                econplan.marginCheck = false;
                econplan.rowError = true;   
                if(rT==null){
                    econPlan.revenueType = 'Revenue Type field not populated in one or many records.';
                } else{
                    econPlan.revenueType = 'Revenue Type missing or not found into Custom Setting: "Revenue Types CS" --> ('+econPlan.revenueType+')';
                }
            } 
            econPlanList.add(econPlan);
        }
        System.debug(' } Œ EconomicPlanController.getEconomicPlan');
        return  econPlanList;
    }

    /*
    * @description : Get Economic Plan rollUp fields from Quote.
    * @author Œ | 01-04-2021 
    * @param id quoteID 
    * @return EconomicPlan 
    **/
    @AuraEnabled(cacheable=true)
    public static EconomicPlan getTotalEconomicPlan(id quoteId){
        System.debug('Œ EconomicPlanController.getTotalEconomicPlan{ ');
        Double totalHRCost = 0;  
        Double totalCost = 0;
        Double totalLinksRevenue = 0;
        Double totalATI = 0;
        Double totalMinMargin = 0;
        for (EconomicPlan econP: getEconomicPlan(quoteId)){
            totalHRCost += econP.costHR;
            totalCost += econP.cost;
            totalLinksRevenue += econP.linksRevenue;
            totalATI += econP.ATI;
            totalMinMargin += econP.minMargin;
        }
        EconomicPlan econPlan= new EconomicPlan();
        econPlan.revenueType = 'TOTAL';
        econPlan.costHR = totalHRCost;
        econPlan.cost = totalCost;
        econPlan.linksRevenue = totalLinksRevenue;
        econPlan.ATI = totalATI;
        if(totalLinksRevenue!= 0){
            econPlan.minMarginPercent = totalMinMargin / totalLinksRevenue;
        }else{
            econPlan.minMarginPercent = 0;
        }
        econPlan.setTotalRevenue();
        econPlan.setMarginProfit(); 
        econPlan.setMinMargin();
        System.debug(' }Œ EconomicPlanController.getTotalEconomicPlan');
        return econPlan;
    }



    /**
    * @description : Set Quote's isMarginValid__c fields, according to the marginCheck got from the Javascript callback.
    * @author Œ | 09-04-2021 
    * @param CustomWrapper wrapper 
    * @return String
    **/
    @AuraEnabled
    public static Quote setQuoteIsMarginValid(CustomWrapper wrapper){
        System.debug('Œ EconomicPlanController.setQuoteIsMarginValid { ');
        
        Quote quote = [SELECT isMarginValid__c, isMinMarginValid__c, CostHRMargin__c, CostMargin__c, Status FROM Quote WHERE Id=:wrapper.quoteId LIMIT 1];
       
        if(wrapper.marginCheck != null  && wrapper.totalMarginCheck != null){
                    
                    quote.isMarginValid__c = wrapper.marginCheck;
                    quote.isMinMarginValid__c = wrapper.totalMarginCheck;
                    quote.CostHRMargin__c = wrapper.CostHRMargin;
                    quote.CostMargin__c = wrapper.CostMargin;
                    System.debug('Œ Update quoteToUpdate -> '+ quote);
                    try {
                        update quote;
                    } catch (Exception e) {
                        throw new AuraHandledException(e.getMessage());
                    } 
                    return quote;             
        }
        System.debug(' } Œ EconomicPlanController.setQuoteIsMarginValid ');
        return quote;
    }

    /**
    * @description 
    * @author Œ | 01-04-2021 
    * @param id quoteID 
    * @return Map<String, AggregateResult> 
    **/
    private static Map<String,AggregateResult> getQuoteHRCosts(id quoteID){
        List<AggregateResult> quoteHRCostsList = [SELECT SUM(TotalCost__c) TotalHRCost, toLabel(Revenue_Type__c) Revenue_Type__c
                                                    FROM QuoteLineItem 
                                                    WHERE quoteID=:quoteID 
                                                    GROUP BY Revenue_Type__c ];
        Map<String,AggregateResult> quoteHRCostsMap = new  Map<String,AggregateResult>();
        for (AggregateResult record: quoteHRCostsList){
            quoteHRCostsMap.put((String)record.get('Revenue_Type__c'), record);
        }
        return quoteHRCostsMap;

    }

    /**
    * @description 
    * @author Œ | 01-04-2021 
    * @param id quoteID 
    * @return Map<String, AggregateResult> 
    **/
    private static Map<String,AggregateResult> getQuoteCosts(id quoteID){    
        List<AggregateResult> quoteCostsList = [SELECT SUM(TotalCostValue__c) TotalCost, toLabel(Revenue_Type__c) Revenue_Type__c
                                                    FROM Cost__c 
                                                    WHERE Quote__c=:quoteID 
                                                    GROUP BY Revenue_Type__c ];
        Map<String,AggregateResult> quoteCostsMap = new  Map<String,AggregateResult>();
        for (AggregateResult record: quoteCostsList){
            quoteCostsMap.put((String)record.get('Revenue_Type__c'), record);
        }
        return quoteCostsMap;
    }

    /**
    * @description 
    * @author Œ | 01-04-2021 
    * @param id quoteID 
    * @return Map<String, AggregateResult> 
    **/
    private static Map<String,AggregateResult> getQuoteRevenues(id quoteID){
        List<AggregateResult> quoteRevenueList = [SELECT SUM(LinksRevenue__c) TotalLinksRevenue, SUM(QuotaATI__c) TotalATI, toLabel(Revenue_Type__c) Revenue_Type__c
                                                    FROM Quote_Revenue__c 
                                                    WHERE Quote__c=:quoteID 
                                                    GROUP BY Revenue_Type__c ];
        Map<String,AggregateResult> quoteRevenueMap = new  Map<String,AggregateResult>();
        for (AggregateResult record: quoteRevenueList){
            quoteRevenueMap.put((String)record.get('Revenue_Type__c'), record);
        }
        return quoteRevenueMap;
    }

    /**
    * @description 
    * @author Œ | 01-04-2021 
    * @param AggregateResult HRCostList 
    * @return Double 
    **/
    private static Double getHRCost(AggregateResult HRCostList){
        return (Double)HRCostList.get('TotalHRCost');
    }

    /**
    * @description 
    * @author Œ | 01-04-2021 
    * @param AggregateResult costList 
    * @return Double 
    **/
    private static Double getCost(AggregateResult costList){
        return (Double)costList.get('TotalCost');
    }

    /**
    * @description 
    * @author Œ | 01-04-2021 
    * @param AggregateResult revenueList 
    * @return Double 
    **/
    private static Double getRevenue(AggregateResult revenueList){
        return (Double) revenueList.get('TotalLinksRevenue');
    }

    /**
    * @description 
    * @author Œ | 01-04-2021 
    * @param AggregateResult revenueATIList 
    * @return Double 
    **/
    private static Double getRevenueATI(AggregateResult revenueATIList){
        return (Double)revenueATIList.get('TotalATI');
    }

}