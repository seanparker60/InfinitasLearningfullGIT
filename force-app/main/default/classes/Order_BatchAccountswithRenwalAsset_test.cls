@Istest
public with sharing class Order_BatchAccountswithRenwalAsset_test {
    
    public static testmethod void AccountswithRenwalAssets (){

        test.startTest();
          List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Noordhoff',true,true); 
          
          
          List<Product2> lstProduct = TestDataFactory.insertProducts(1,true);
          Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
          List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
          List<Asset>lst_Asset = TestDataFactory.insertAsset(standardPricebook.id ,lstProduct,lstAccount, lstAccount,false);
          Insert lst_Asset;
  
         List<Id> AssetId = new List<Id>();
         for(Asset ass:lst_Asset){
           AssetId.add(ass.Id);
         } 
         UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;
         Order_Batch_AccountswithRenwalAssets  AssetRenewal = new Order_Batch_AccountswithRenwalAssets();   
         String chron = '0 0 23 * * ?';        
         system.schedule('Test Sched', chron, AssetRenewal);  
  
         test.stoptest();
  
  
     }



}