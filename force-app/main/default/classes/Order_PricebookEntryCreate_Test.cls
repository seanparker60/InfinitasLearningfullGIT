@Istest
public with sharing class Order_PricebookEntryCreate_Test {
   
    Public static testmethod void PricebookEntryCreate(){

        List<Product2> lstProductItemGroup = TestDataFactory.insertProducts(3,true);
        List<Product2> lstProductItem = TestDataFactory.insertProducts(1,true);
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProductItem,true);

        Pricebook2 PricebookCustom = TestDataFactory.insertPricebookCustom('Plantyn - All Products 2021');
        lstPricebookEntry = TestDataFactory.insertPricebookEntry(PricebookCustom.id ,lstProductItem,true);

        List<ProductComponent__c> lstProductComponent = Order_TestDataFactory.InsertGroupComponent(lstProductItem,lstProductItemGroup,true);
        Pricing__c[] lstPricing = Order_TestDataFactory.InsertPricing(lstProductItem,lstProductComponent,true);

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



        //Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        //List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct);
        


    }
    Public static testmethod void PricebookEntryCreate1(){

        UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;
        List<Product2> lstProductItemGroup = TestDataFactory.insertProducts(3,true);
        List<Product2> lstProductItem = TestDataFactory.insertProducts(1,true);
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProductItem,true);

        Pricebook2 PricebookCustom = TestDataFactory.insertPricebookCustom('Plantyn - All Products 2021');
        lstPricebookEntry = TestDataFactory.insertPricebookEntry(PricebookCustom.id ,lstProductItem,true);

        List<ProductComponent__c> lstProductComponent = Order_TestDataFactory.InsertGroupComponent(lstProductItem,lstProductItemGroup,true);
        Pricing__c[] lstPricing = Order_TestDataFactory.InsertPricing(lstProductItem,lstProductComponent,true);

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

        Order_PricebookEntryCreate.PricebookEntryCreate(PriceId);

    }

    Public static testmethod void PricebookEntryCreate2(){

        UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;
        List<Product2> lstProductItemGroup = TestDataFactory.insertProducts(3,true);
        List<Product2> lstProductItem = TestDataFactory.insertProducts(1,true);
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProductItem,true);

        Pricebook2 PricebookCustom = TestDataFactory.insertPricebookCustom('Plantyn - All Products 2021');
        lstPricebookEntry = TestDataFactory.insertPricebookEntry(PricebookCustom.id ,lstProductItem,true);

        List<ProductComponent__c> lstProductComponent = Order_TestDataFactory.InsertGroupComponent(lstProductItem,lstProductItemGroup,true);
        Pricing__c[] lstPricing = Order_TestDataFactory.InsertPricing(lstProductItem,lstProductComponent,true);

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

        for(Pricing__c price:lstPricing){
            price.StartDate__c= price.EndDate__c+15;
            price.EndDate__c = price.StartDate__c+115;   
        }

        update lstPricing;

        List<Id> PriceId = new List<Id>();
        for(Pricing__c price:lstPricing){
            PriceId.add(price.id);
        }

        Order_PricebookEntryCreate.PricebookEntryCreate(PriceId);

    }
    Public static testmethod void PricebookEntryCreate3(){

        UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;
        List<Product2> lstProductItemGroup = TestDataFactory.insertProducts(3,true);
        List<Product2> lstProductItem = TestDataFactory.insertProducts(1,true);
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProductItem,true);

        Pricebook2 PricebookCustom = TestDataFactory.insertPricebookCustom('Plantyn - All Products 2021');
        lstPricebookEntry = TestDataFactory.insertPricebookEntry(PricebookCustom.id ,lstProductItem,true);

        List<ProductComponent__c> lstProductComponent = Order_TestDataFactory.InsertGroupComponent(lstProductItem,lstProductItemGroup,true);
        Pricing__c[] lstPricing = Order_TestDataFactory.InsertPricing(lstProductItem,lstProductComponent,true);

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
        

        for(Product2 prod: lstProductItem){
            prod.MarketSegment__c = 'Professional';
            prod.SoldInSegment__c = 'Professional';
        }
        
        update lstProductItem;
        
        system.debug('****Segment Update***');
        
        Order_PricebookEntryCreate.PricebookEntryCreate(PriceId);

    }

}