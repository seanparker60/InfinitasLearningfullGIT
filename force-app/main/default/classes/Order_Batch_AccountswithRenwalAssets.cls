global with sharing class Order_Batch_AccountswithRenwalAssets implements Database.Batchable<sObject>,Schedulable{
    
    public Order_Batch_AccountswithRenwalAssets(){

    }

    global Database.QueryLocator start(Database.BatchableContext BC){  
           
        Date CurrrentDay = system.today();
        Date RenewalDay = system.today();
        return Database.getQueryLocator([SELECT BillToAccount__c  from asset     where
            BillToAccount__r.RenewalAssetToday__c =: false
            AND 
            (Product2Id !=: null AND BillToAccount__c !=: null AND PricingMethod__c !=: null )
            AND((
            ( CancellationDate__c >: CurrrentDay OR CancellationDate__c =:null)   
            AND ( 
                (RenewalDate__c  =: RenewalDay OR RenewalRunDate__c =: CurrrentDay) 
                /*
                AND 
                (
                    (QuantityUpdateCheckYearly__c =: false)
                    OR(QuantityUpdateCheckYearly__c =: True AND RenewalDate__c  <=: RenewalDay AND QuantityStartDate__c <=:CurrrentDay AND QuantityEndDate__c >=:CurrrentDay  )
                )
                */
            )
            AND LastRenewalUpdate__c !=: CurrrentDay              
            AND AutomatedRenewProcess__c =: true  
           // AND Contract__c =:null
            AND Product2.Type__c != 'Item Group'
            )
            OR(
                AssetRenewalTrigger__c =: true
                AND Product2.Type__c != 'Item Group'
            ))

            ]  ); 
            
            // WHERE ACCOUNT HAS ACTIVE ASSET
    }
    
    global void execute(Database.BatchableContext BC, List<asset> scope){
       
        Set<String> Set_Asset = new Set<String>();
        for (Asset ass : scope) {
            Set_Asset.add(ass.BillToAccount__c);
        }
        system.debug('**Set_Asset : Size**'+scope.size());
        
        Account[] lstAccount = [SELECT Id,RenewalAssetToday__c  FROM Account where id in: Set_Asset AND RenewalAssetToday__c =: false];

       
        if(lstAccount.size()>0){
            for(Account acc:lstAccount){
                acc.RenewalAssetToday__c = true;
            }
            try{
                update lstAccount;
                if(Test.isRunningTest() && UTIL_TestClassExceptions.TESTCLASSEXCEPTION==True){
                    CalloutException e = new CalloutException();
                    e.setMessage('Error');
                    throw e;        
                  }
            }
            catch (exception e){
                HandleCustomException.LogException(e,lstAccount[0].id);
            }
                
        }
       
    }
    global void finish(Database.BatchableContext BC){

        Order_Batch_AssetRenewal  AssetRenewal = new Order_Batch_AssetRenewal();
        database.executebatch(AssetRenewal ,1);

    }
    
    global void execute(SchedulableContext sc)
    {
        Order_Batch_AccountswithRenwalAssets  AssetRenewal = new Order_Batch_AccountswithRenwalAssets();
        database.executebatch(AssetRenewal ,500);
    }


}