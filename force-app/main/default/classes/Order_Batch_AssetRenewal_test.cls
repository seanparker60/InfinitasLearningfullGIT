@Istest
public with sharing class Order_Batch_AssetRenewal_test {

    public static testmethod void AssetRenewal (){

        test.startTest();
          List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Noordhoff',true,false); 
          
          for(Account acc:lstAccount){
            acc.RenewalAssetToday__c = true;
          }
          insert lstAccount;

          
          List<Product2> lstProduct = TestDataFactory.insertProducts(1,true);
          Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
          List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
          List<Asset>lst_Asset = TestDataFactory.insertAsset(standardPricebook.id ,lstProduct,lstAccount, lstAccount,false);
          Insert lst_Asset;
  
         List<Id> AssetId = new List<Id>();
         for(Asset ass:lst_Asset){
           AssetId.add(ass.Id);
         } 
         
         Order_Batch_AssetRenewal  AssetRenewal = new Order_Batch_AssetRenewal();   
         String chron = '0 0 23 * * ?';        
         system.schedule('Test Sched', chron, AssetRenewal);  
  
         test.stoptest();
  
  
     }
}