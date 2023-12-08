global with sharing class Order_Batch_UpdateProductPricingDaily implements Database.Batchable<sObject>,Schedulable{
    
    global Database.QueryLocator start(Database.BatchableContext BC){  
           
        
        return Database.getQueryLocator([SELECT IsActive__c,RetriggerPricing__c from Pricing__c  where ProductComponent__c =:null AND StartDate__c <=: system.today() AND EndDate__c >=: system.today() AND IsActive__c =:true]  ); // WHERE ACCOUNT HAS ACTIVE ASSET
    }
    
    global void execute(Database.BatchableContext BC, List<Pricing__c> scope){
       
        for (Pricing__c price : scope) {
            price.RetriggerPricing__c = true;
        }
       
       update scope;
    }
    global void finish(Database.BatchableContext BC){

      

    }
    
    global void execute(SchedulableContext sc)
    {
        Order_Batch_UpdateProductPricingDaily  Pricing = new Order_Batch_UpdateProductPricingDaily();
        database.executebatch(Pricing ,10);
    }



}