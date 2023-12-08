@istest
public with sharing class Order_AssetRenewal_test {  
   
   public static testmethod void OrderAssetRenewal1 (){

      test.startTest();
        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Noordhoff',true,true); 
        
        
        List<Product2> lstProduct = TestDataFactory.insertProducts(1,true);
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Asset>lst_Asset = TestDataFactory.insertAsset(standardPricebook.id ,lstProduct,lstAccount, lstAccount,false);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        
        for(Asset ass:lst_Asset){
            ass.PricingMethod__c ='OrderProductQuantity';
            ass.Contract__c = lstContract[0].id;
            ass.RenewalDate__c  = system.today();
            ass.AutomatedRenewProcess__c = true;
        }

        Insert lst_Asset;
        Order_AssetRenewal.RenewAssets();
        /*
       List<Id> AssetId = new List<Id>();
       for(Asset ass:lst_Asset){
         AssetId.add(ass.Id);
       } 

       Order_AssetRenewal.RenewAssets(AssetId);
       */

       test.stoptest();


   }
    
   public static testmethod void OrderAssetRenewal2 (){
      test.startTest();
      List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Noordhoff',true,true);     
      List<Product2> lstProduct = TestDataFactory.insertProducts(1,true);
      Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
      List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
      List<Asset>lst_Asset = TestDataFactory.insertAsset(standardPricebook.id ,lstProduct,lstAccount, lstAccount,false);
      List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        
      List<Id> AssetId = new List<Id>();
      
      for(Asset ass:lst_Asset){        
         ass.PricingMethod__c ='AccountStudents';
         ass.Contract__c = lstContract[0].id;
         ass.RenewalDate__c  = system.today();
         ass.AutomatedRenewProcess__c = true;
      } 
    
      insert lst_Asset;
      Order_AssetRenewal.RenewAssets();
      /*
      for(Asset ass:lst_Asset){
         AssetId.add(ass.Id);        
      } 

      Order_AssetRenewal.RenewAssets(AssetId);
      */

      test.stoptest();
 }


 public static testmethod void OrderAssetRenewal3 (){
   test.startTest();
   List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Noordhoff',true,true);     
   List<Product2> lstProduct = TestDataFactory.insertProducts(1,true);
   Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
   List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
   
   List<ListPriceDiscount__c> ListPriceDiscount = Order_TestDataFactory.insertListPriceDiscount(5,'Regular','Workbooks',true);
   ListPriceDiscount = Order_TestDataFactory.insertListPriceDiscount(1,'Inspection Copy','Workbooks',false); 
   
   
   List<Asset>lst_Asset = TestDataFactory.insertAsset(standardPricebook.id ,lstProduct,lstAccount, lstAccount,false);
   List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
     
   List<Id> AssetId = new List<Id>();
   for(Asset ass:lst_Asset){        
      ass.PricingMethod__c ='ProductUsageBased';
      ass.Contract__c = lstContract[0].id;
      ass.RenewalDate__c  = system.today();
      ass.AutomatedRenewProcess__c = true;
   } 

   insert lst_Asset;
   Order_AssetRenewal.RenewAssets();
   /*
   for(Asset ass:lst_Asset){
      AssetId.add(ass.Id);     
   } 
   Order_AssetRenewal.RenewAssets(AssetId);
   */

   test.stoptest();
}


public static testmethod void OrderAssetRenewal4 (){
   test.startTest();
   List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Noordhoff',true,true);     
   List<Product2> lstProduct = TestDataFactory.insertProducts(1,true);
   Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
   List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
   List<Asset>lst_Asset = TestDataFactory.insertAsset(standardPricebook.id ,lstProduct,lstAccount, lstAccount,false);
   List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
     

   for(Asset ass:lst_Asset){
      ass.PricingMethod__c ='ProductDiscountGroupUsageBased';
      ass.Contract__c = lstContract[0].id;
      ass.RenewalDate__c  = system.today();
      ass.AutomatedRenewProcess__c = true;
   }     
   
   insert lst_Asset;
   Order_AssetRenewal.RenewAssets();

   /*
   UTIL_TestClassExceptions.TESTCLASSEXCEPTION=true;
   List<Id> AssetId = new List<Id>();
   for(Asset ass:lst_Asset){
      AssetId.add(ass.Id);     
   } 
   Order_AssetRenewal.RenewAssets(AssetId);
   */

   test.stoptest();
}

public static testmethod void OrderAssetRenewal5 (){
   test.startTest();
   List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Noordhoff',true,true);     
   List<Product2> lstProduct = TestDataFactory.insertProducts(1,true);
   Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
   List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
   List<Asset>lst_Asset = TestDataFactory.insertAsset(standardPricebook.id ,lstProduct,lstAccount, lstAccount,false);
   List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
     

   for(Asset ass:lst_Asset){
      ass.PricingMethod__c ='ProductDiscountGroupUsageBased';
      ass.Contract__c = lstContract[0].id;
      ass.RenewalDate__c  = system.today();
      ass.AutomatedRenewProcess__c = true;
   }     
   
   insert lst_Asset;

   
   Order_AssetRenewal.RenewAssets();

   test.stoptest();
}
public static testmethod void OrderAssetRenewal6 (){
   test.startTest();
   List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Plantyn',true,true);     
   

   Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
   Pricebook2 PricebookCustom = TestDataFactory.insertPricebookCustom('Plantyn - All 2021');
   Pricebook2 PricebookCustomFollowon = TestDataFactory.insertPricebookCustom('Plantyn - All 2022');
    
   
   List<Product2> lstProduct = TestDataFactory.insertProducts(1,false);
   List<Product2> lstProductSuccessor = TestDataFactory.insertProducts(1,false);

   lstProduct[0].Subsidiary__c = 'Plantyn';
   lstProductSuccessor[0].Subsidiary__c = 'Plantyn';

   insert lstProduct;
   insert lstProductSuccessor;

   Order_TestDataFactory.UpdateSuccessorItem(lstProduct, lstProductSuccessor, true);


   PricebookCustom.FollowUpPriceBook__c = PricebookCustomFollowon.id;
   PricebookCustom.isactive = false;
   PricebookCustom.Name = 'Master';
   Update PricebookCustom; 

   PricebookCustomFollowon.name = 'Successor';
   Update PricebookCustomFollowon;

   List<Product2> lstProductAll = new List<Product2>();
   lstProductAll.addall(lstProduct);
   lstProductAll.addall(lstProductSuccessor);

   List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProductAll,true);
   lstPricebookEntry = TestDataFactory.insertPricebookEntry(PricebookCustom.id ,lstProductAll,true);
   lstPricebookEntry = TestDataFactory.insertPricebookEntry(PricebookCustomFollowon.id ,lstProductAll,true);


   PricebookEntry[] lstPricebookEntryExist = [Select isactive,PriceBook2.Name, id,Product2Id, Pricebook2Id,Product2.IsSuccessorItemActive__c,Product2.SuccessorItem__c,Product2.SuccessorItem__r.IsActive,Product2.Stocknumber__c,Product2.StockLevel__c, Product2.PlannedPrintDate__c 
        from PricebookEntry where Pricebook2Id !=:standardPricebook.id]; // 

        for(PricebookEntry pbe:lstPricebookEntryExist){
            pbe.isactive = true;
            system.debug('***Order_AssetRenewal_test: PriceBook2.Name***'+pbe.PriceBook2.Name);
            system.debug('***Order_AssetRenewal_test: Product2Id***'+pbe.Product2Id);
            system.debug('***Order_AssetRenewal_test: SuccessorItem***'+pbe.Product2.SuccessorItem__c);
        }
        update lstPricebookEntryExist;
   
   
   List<Asset>lst_Asset = TestDataFactory.insertAsset(PricebookCustom.id ,lstProduct,lstAccount, lstAccount,false);
   List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,PricebookCustom.id,true);
     

   for(Asset ass:lst_Asset){
      ass.PricingMethod__c ='ProductDiscountGroupUsageBased';
      ass.Contract__c = lstContract[0].id;
      ass.RenewalDate__c  = system.today();
      ass.AutomatedRenewProcess__c = true;
   }     
   
   insert lst_Asset;

      
   
   Order_AssetRenewal.RenewAssets();

   test.stoptest();
}






}