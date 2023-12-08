@Istest
public with sharing class Order_AssetRenewalLineItemQueueable_test {
    

    public static testmethod void AssetRenewalLineItemQueueable1(){

        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Noordhoff',true,true);     
        List<Product2> lstProduct = TestDataFactory.insertProducts(1,true);
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Asset>lst_Asset = TestDataFactory.insertAsset(standardPricebook.id ,lstProduct,lstAccount, lstAccount,true);
        

        Map<Decimal,List<OrderItem>> Map_OrderItems = new Map<Decimal,List<OrderItem>>();
        UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;
        System.enqueueJob(new Order_AssetRenewalLineItemQueueable(null,Map_OrderItems,lst_Asset,null,null));
    
    }
/*
    public static testmethod void AssetRenewalLineItemQueueable2(){

        Map<Decimal,List<OrderItem>> Map_OrderItems = new Map<Decimal,List<OrderItem>>();
        System.enqueueJob(new Order_AssetRenewalLineItemQueueable(null,Map_OrderItems,null,null, null,null));
    
    }
*/

}