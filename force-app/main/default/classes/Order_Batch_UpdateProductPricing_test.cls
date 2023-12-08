@Istest
public with sharing class Order_Batch_UpdateProductPricing_test {
   
    Public static testmethod void Batch_UpdateProductPricingDaily(){

        List<Product2> lstProductItemGroup = TestDataFactory.insertProducts(3,true);
        List<Product2> lstProductItem = TestDataFactory.insertProducts(1,true);
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProductItem,true);

        Pricebook2 PricebookCustom = TestDataFactory.insertPricebookCustom('Plantyn - All Products 2021');
        lstPricebookEntry = TestDataFactory.insertPricebookEntry(PricebookCustom.id ,lstProductItem,true);

        List<ProductComponent__c> lstProductComponent = Order_TestDataFactory.InsertGroupComponent(lstProductItem,lstProductItemGroup,true);
        Pricing__c[] lstPricing = Order_TestDataFactory.InsertPricing(lstProductItem,lstProductComponent,true);

        system.debug('**Pricing Records**'+lstPricing);

/*
        Pricing__c[] lstPricingComponent = Order_TestDataFactory.InsertPricingProductComponent(lstProductComponent,true);

        lstPricing.addall(lstPricingComponent);

        //Products not added to the Price book with Pricing
        lstProductItemGroup = TestDataFactory.insertProducts(3,true);
        lstProductItem = TestDataFactory.insertProducts(1,true);
        lstProductComponent = Order_TestDataFactory.InsertGroupComponent(lstProductItem,lstProductItemGroup,true);
        Pricing__c[] lstPricing2 = Order_TestDataFactory.InsertPricing(lstProductItem,lstProductComponent,true);
        Pricing__c[] lstPricingComponent2 = Order_TestDataFactory.InsertPricingProductComponent(lstProductComponent,true);

        lstPricing.addall(lstPricing2);
        lstPricing.addall(lstPricingComponent2);


        List<Id> PriceId = new List<Id>();
        for(Pricing__c price:lstPricing){
            PriceId.add(price.id);
        }

        UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;
        Order_PricebookEntryCreate.PricebookEntryCreate(PriceId);
*/

        Order_Batch_UpdateProductPricingDaily PricingDaily = new Order_Batch_UpdateProductPricingDaily();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, PricingDaily);  

        Order_Batch_UpdateProductPricingDaily  Pricing = new Order_Batch_UpdateProductPricingDaily();
        database.executebatch(Pricing ,10);

    }

}