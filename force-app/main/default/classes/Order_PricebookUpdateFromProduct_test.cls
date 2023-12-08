@Istest
public with sharing class Order_PricebookUpdateFromProduct_test {
    

    Public static testmethod void PricebookUpdateFromProduct(){
        Test.startTest();
   
        List<Product2> lstProductItemGroup = TestDataFactory.insertProducts(3,true);
        List<Product2> lstProductItem = TestDataFactory.insertProducts(1,true);
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProductItem,true);

        Pricebook2 PricebookCustom = TestDataFactory.insertPricebookCustom('Plantyn - All Products 2021');
        lstPricebookEntry = TestDataFactory.insertPricebookEntry(PricebookCustom.id ,lstProductItem,true);

        List<ProductComponent__c> lstProductComponent = Order_TestDataFactory.InsertGroupComponent(lstProductItem,lstProductItemGroup,true);
        Pricing__c[] lstPricing = Order_TestDataFactory.InsertPricing(lstProductItem,lstProductComponent,true);

        Pricing__c[] lstPricingComponent = Order_TestDataFactory.InsertPricingProductComponent(lstProductComponent,true);

        
        List<Id> ProductId = new List<Id>();

        for(Product2 prod:lstProductItem){
            ProductId.add(prod.id);
        }
        
        UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;
        Order_PricebookUpdateFromProduct.PricebookUpdateFromProduct(ProductId);
   
        Test.stopTest();
           
       }

}