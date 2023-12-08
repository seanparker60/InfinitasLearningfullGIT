@Istest
public with sharing class Order_BatchResetAccountAssetRenewal_test {
        
        public static testmethod void AccountswithRenwalAssets (){
    
            test.startTest();
              List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Noordhoff',true,true); 
             
              for(Account acc:lstAccount){
                acc.RenewalAssetToday__c = true;
              }

              update lstAccount;
             
             UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;
             Order_BatchResetAccountAssetRenewal  AssetRenewal = new Order_BatchResetAccountAssetRenewal();   
             String chron = '0 0 23 * * ?';        
             system.schedule('Test Sched', chron, AssetRenewal);  
      
             test.stoptest();
      
      
         }
    
    
    
    }