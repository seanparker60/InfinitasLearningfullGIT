@istest
public with sharing class Order_OrderandOrdeItemHandler_test {
    

    public static testmethod void testUpdateShippingDates(){

        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Noordhoff',true,true);

        Set<String> Set_AccId = new Set<String>();
        for(Account acc:lstAccount){
            Set_AccId.add(acc.id);
        }

        AccountSubsidiary__c[] lstAccountSubsidiary = [Select id,Account__c from AccountSubsidiary__c where Account__c in:Set_AccId ];

        Map<String,String> Map_AccSub = new Map<String,String>();
        Integer i=0;
        for(AccountSubsidiary__c  sub:lstAccountSubsidiary){
            sub.NetsuiteInternalId__c = '88776'+i;
            Map_AccSub.put(sub.Account__c,sub.id);
            i++;
        }

        update lstAccountSubsidiary;

        List<Product2> lstProduct = TestDataFactory.insertProducts(3,true);
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,true);
        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
         

        List<Id> OrderId = new List<Id>();


        for(Order ord:lstOrder){
            OrderId.add(ord.id);
        }

        UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;
        Order_OrderandOrdeItemHandler.UpdateShippingDates(OrderId);


    }

    public static testmethod void testTriggerhandlerNoordhoff(){
        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Noordhoff',true,true);

        Set<String> Set_AccId = new Set<String>();
        for(Account acc:lstAccount){
            Set_AccId.add(acc.id);
        }

        AccountSubsidiary__c[] lstAccountSubsidiary = [Select id,Account__c from AccountSubsidiary__c where Account__c in:Set_AccId ];

        Map<String,String> Map_AccSub = new Map<String,String>();
        Integer i=0;
        for(AccountSubsidiary__c  sub:lstAccountSubsidiary){
            sub.NetsuiteInternalId__c = '88776'+i;
            Map_AccSub.put(sub.Account__c,sub.id);
            i++;
        }

        update lstAccountSubsidiary;

        List<Product2> lstProduct = TestDataFactory.insertProducts(3,false);
        for(Product2 prod:lstProduct){
            prod.FixedStartDate__c = null;
        }
        insert lstProduct;

        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,true);
        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
         

        /*
        OrderItem[] lstOrderItemGet = [Select id,ShipToAccount__c,ProductLicenseDuration__c,OrderId,Product2.LicenseDuration__c,       
        Quantity,ListPrice,List_Price_Rate__c,Order.ShippingCostExempt__c,Product2Id,ItemGroup__c,
       ShippingCity__c,ShippingCountry__c,ShippingPostalCode__c,ShippingState__c,ShippingStreet__c,
       ShippingIndicationRule__c,Order.ShippingIndicationRule__c,DeliveryType__c,discount__c,TotalDiscountAmount__c,
       Order.Billto__r.CustomerDiscountGroup__c,Order.Billto__r.OperatingCompany__c,Product2.ProductRateGroup__c,
       IsInspectionCopyOrderPossible__c,IsRegularOrderPossible__c,IsUseCopyOrderPossible__c,NetsuiteInternalId__c,DigitalActivationEMail__c,
       ManualDiscountValue__c,Product2.MarketSegment__c,ManualDiscount__c,ManualDiscountPercent__c,NetsuiteListPrice__c,ProductType__c,unitprice,OrderLineType__c,Order.Source__c,Order.DigitalActivationEMail__c,
       Order.PricingMethod__c,ShipToAccount__r.NumberOfStudents__c,Product2.Name,Product2.OrderLineType__c,Product2.ProductDiscountGroup__c,Order.MultipleShippingLocations__c, OrderMultipleShippingLocations__c,
       Order.ShippingCostMethodNS__c, VATRule__c, VATRule__r.Rate__c, LineItemTotal__c, VATCalculated__c, Order.Pricebook2.Name
        from OrderItem];
        */
        List<Id> OrderId = new List<Id>();
        OrderId.add(lstOrder[0].id);
        OrderItem[] lstOrderItemGet = Order_OrderandOrdeItemHandler.returnQueryOrderItems(null,OrderId);
        Order_OrderandOrdeItemHandler.triggerhandler(lstOrderItemGet);


    }

    public static testmethod void testTriggerhandlerLiber(){
        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Liber',true,true);

        Set<String> Set_AccId = new Set<String>();
        for(Account acc:lstAccount){
            Set_AccId.add(acc.id);
        }

        AccountSubsidiary__c[] lstAccountSubsidiary = [Select id,Account__c from AccountSubsidiary__c where Account__c in:Set_AccId ];

        Map<String,String> Map_AccSub = new Map<String,String>();
        Integer i=0;
        for(AccountSubsidiary__c  sub:lstAccountSubsidiary){
            sub.NetsuiteInternalId__c = '88776'+i;
            Map_AccSub.put(sub.Account__c,sub.id);
            i++;
        }

        update lstAccountSubsidiary;

        List<Product2> lstProduct = TestDataFactory.insertProducts(3,false);
        for(Product2 prod:lstProduct){
            prod.FixedStartDate__c = null;
        }
        insert lstProduct;

        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(3,lstAccount,lstContract,standardPricebook.id,true);
        lstOrder[0].ShippingCostExempt__c = true;
        lstOrder[1].ShippingCostExempt__c = false;
        lstOrder[1].ShippingIndicationRule__c = 'Based on order total';
        lstOrder[2].ShippingCostExempt__c = false;
        lstOrder[2].ShippingIndicationRule__c = 'Based on weight Domestic';
        update lstOrder;
        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
        
        /*
        OrderItem[] lstOrderItemGet = [Select id,ShipToAccount__c,ProductLicenseDuration__c,OrderId,Product2.LicenseDuration__c,       
        Quantity,ListPrice,List_Price_Rate__c,Order.ShippingCostExempt__c,Product2Id,ItemGroup__c,
       ShippingCity__c,ShippingCountry__c,ShippingPostalCode__c,ShippingState__c,ShippingStreet__c,
       ShippingIndicationRule__c,Order.ShippingIndicationRule__c,DeliveryType__c,discount__c,TotalDiscountAmount__c,
       Order.Billto__r.CustomerDiscountGroup__c,Order.Billto__r.OperatingCompany__c,Product2.ProductRateGroup__c,
       IsInspectionCopyOrderPossible__c,IsRegularOrderPossible__c,IsUseCopyOrderPossible__c,NetsuiteInternalId__c,DigitalActivationEMail__c,
       ManualDiscountValue__c,Product2.MarketSegment__c,ManualDiscount__c,ManualDiscountPercent__c,NetsuiteListPrice__c,ProductType__c,unitprice,OrderLineType__c,Order.Source__c,Order.DigitalActivationEMail__c,
       Order.PricingMethod__c,ShipToAccount__r.NumberOfStudents__c,Product2.Name,Product2.OrderLineType__c,Product2.ProductDiscountGroup__c,Order.MultipleShippingLocations__c, OrderMultipleShippingLocations__c,
       Order.ShippingCostMethodNS__c, VATRule__c, VATRule__r.Rate__c, LineItemTotal__c, VATCalculated__c, Order.Pricebook2.Name
        from OrderItem];
        */

        List<Id> OrderId = new List<Id>();
        OrderId.add(lstOrder[0].id);
        OrderItem[] lstOrderItemGet = Order_OrderandOrdeItemHandler.returnQueryOrderItems(null,OrderId);
        Order_OrderandOrdeItemHandler.triggerhandler(lstOrderItemGet);

    }

    public static testmethod void testTriggerhandlerPlantyn(){
        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Plantyn',true,true);

        Set<String> Set_AccId = new Set<String>();
        for(Account acc:lstAccount){
            Set_AccId.add(acc.id);
        }

        AccountSubsidiary__c[] lstAccountSubsidiary = [Select id,Account__c from AccountSubsidiary__c where Account__c in:Set_AccId ];

        Map<String,String> Map_AccSub = new Map<String,String>();
        Integer i=0;
        for(AccountSubsidiary__c  sub:lstAccountSubsidiary){
            sub.NetsuiteInternalId__c = '88776'+i;
            Map_AccSub.put(sub.Account__c,sub.id);
            i++;
        }

        update lstAccountSubsidiary;

        List<Product2> lstProduct = TestDataFactory.insertProducts(3,false);
        for(Product2 prod:lstProduct){
            prod.FixedStartDate__c = null;
        }
        insert lstProduct;

        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(3,lstAccount,lstContract,standardPricebook.id,true);
        lstOrder[0].ShippingCostExempt__c = true;
        lstOrder[1].ShippingCostExempt__c = false;
        lstOrder[1].ShippingIndicationRule__c = 'Based on order total';
        lstOrder[2].ShippingCostExempt__c = false;
        lstOrder[2].ShippingIndicationRule__c = 'Based on weight Domestic';
        update lstOrder;
        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
        lstOrderItems[0].ProductType__c = 'Inventory Item';
        lstOrderItems[0].ShippingCity__c = null;
        update lstOrderItems;
        /* 
        OrderItem[] lstOrderItemGet = [Select id,ShipToAccount__c,ProductLicenseDuration__c,OrderId,Product2.LicenseDuration__c,       
        Quantity,ListPrice,List_Price_Rate__c,Order.ShippingCostExempt__c,Product2Id,ItemGroup__c,
       ShippingCity__c,ShippingCountry__c,ShippingPostalCode__c,ShippingState__c,ShippingStreet__c,
       ShippingIndicationRule__c,Order.ShippingIndicationRule__c,DeliveryType__c,discount__c,TotalDiscountAmount__c,
       Order.Billto__r.CustomerDiscountGroup__c,Order.Billto__r.OperatingCompany__c,Product2.ProductRateGroup__c,
       IsInspectionCopyOrderPossible__c,IsRegularOrderPossible__c,IsUseCopyOrderPossible__c,NetsuiteInternalId__c,DigitalActivationEMail__c,
       ManualDiscountValue__c,Product2.MarketSegment__c,ManualDiscount__c,ManualDiscountPercent__c,NetsuiteListPrice__c,ProductType__c,unitprice,OrderLineType__c,Order.Source__c,Order.DigitalActivationEMail__c,
       Order.PricingMethod__c,ShipToAccount__r.NumberOfStudents__c,Product2.Name,Product2.OrderLineType__c,Product2.ProductDiscountGroup__c,Order.MultipleShippingLocations__c, OrderMultipleShippingLocations__c,
       Order.ShippingCostMethodNS__c, VATRule__c, VATRule__r.Rate__c, LineItemTotal__c, VATCalculated__c, Order.Pricebook2.Name
        from OrderItem];
        */

        List<Id> OrderId = new List<Id>();
        OrderId.add(lstOrder[0].id);
        OrderItem[] lstOrderItemGet = Order_OrderandOrdeItemHandler.returnQueryOrderItems(null,OrderId);

        Order_OrderandOrdeItemHandler.triggerhandler(lstOrderItemGet);

    }

    public static testmethod void testReturnQueryOrderItems(){
        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Plantyn',true,true);

        Set<String> Set_AccId = new Set<String>();
        for(Account acc:lstAccount){
            Set_AccId.add(acc.id);
        }

        AccountSubsidiary__c[] lstAccountSubsidiary = [Select id,Account__c from AccountSubsidiary__c where Account__c in:Set_AccId ];

        Map<String,String> Map_AccSub = new Map<String,String>();
        Integer i=0;
        for(AccountSubsidiary__c  sub:lstAccountSubsidiary){
            sub.NetsuiteInternalId__c = '88776'+i;
            Map_AccSub.put(sub.Account__c,sub.id);
            i++;
        }

        update lstAccountSubsidiary;

        List<Product2> lstProduct = TestDataFactory.insertProducts(3,false);
        for(Product2 prod:lstProduct){
            prod.FixedStartDate__c = null;
        }
        insert lstProduct;

        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,true);
        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);

        List<id> List_OrdId = new List<Id> ();
        for(Order ord : lstOrder){
            List_OrdId.add(ord.Id);
        }
        Set<String> Set_OrderItemId = new Set<String> ();
        for(OrderItem oi : lstOrderItems){
            Set_OrderItemId.add(oi.Id);
        }

        Order_OrderandOrdeItemHandler.returnQueryOrderItems(Set_OrderItemId, List_OrdId);

    }
    
    public static testmethod void testBusinessLogicHanlderPlantyn(){
        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Plantyn',true,true);

        Set<String> Set_AccId = new Set<String>();
        for(Account acc:lstAccount){
            Set_AccId.add(acc.id);
        }

        AccountSubsidiary__c[] lstAccountSubsidiary = [Select id,Account__c from AccountSubsidiary__c where Account__c in:Set_AccId ];

        Map<String,String> Map_AccSub = new Map<String,String>();
        Integer i=0;
        for(AccountSubsidiary__c  sub:lstAccountSubsidiary){
            sub.NetsuiteInternalId__c = '88776'+i;
            Map_AccSub.put(sub.Account__c,sub.id);
            i++;
        }

        update lstAccountSubsidiary;

        List<Product2> lstProduct = TestDataFactory.insertProducts(3,false);
        for(Product2 prod:lstProduct){
            prod.FixedStartDate__c = null;
        }
        insert lstProduct;

        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(3,lstAccount,lstContract,standardPricebook.id,true);
        lstOrder[0].ShippingCostExempt__c = true;
        lstOrder[1].ShippingCostExempt__c = false;
        lstOrder[1].ShippingIndicationRule__c = 'Based on order total';
        lstOrder[2].ShippingCostExempt__c = false;
        lstOrder[2].ShippingIndicationRule__c = 'Based on weight Domestic';
        update lstOrder;
        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
        lstOrderItems[0].ProductType__c = 'Inventory Item';
        update lstOrderItems;
        
        List<String> ordIdLs = new List<String>();
        for(Order ord : lstOrder){
            ordIdLs.add(String.valueOf(ord.Id));
        }
         /*
        OrderItem[] lstOrderItemGet = [Select id,ShipToAccount__c,ProductLicenseDuration__c,OrderId,Product2.LicenseDuration__c,       
        Quantity,ListPrice,List_Price_Rate__c,Order.ShippingCostExempt__c,Product2Id,ItemGroup__c,
       ShippingCity__c,ShippingCountry__c,ShippingPostalCode__c,ShippingState__c,ShippingStreet__c,
       ShippingIndicationRule__c,Order.ShippingIndicationRule__c,DeliveryType__c,discount__c,TotalDiscountAmount__c,
       Order.Billto__r.CustomerDiscountGroup__c,Order.Billto__r.OperatingCompany__c,Product2.ProductRateGroup__c,
       IsInspectionCopyOrderPossible__c,IsRegularOrderPossible__c,IsUseCopyOrderPossible__c,NetsuiteInternalId__c,DigitalActivationEMail__c,
       ManualDiscountValue__c,Product2.MarketSegment__c,ManualDiscount__c,ManualDiscountPercent__c,NetsuiteListPrice__c,ProductType__c,unitprice,OrderLineType__c,Order.Source__c,Order.DigitalActivationEMail__c,
       Order.PricingMethod__c,ShipToAccount__r.NumberOfStudents__c,Product2.Name,Product2.OrderLineType__c,Product2.ProductDiscountGroup__c,Order.MultipleShippingLocations__c, OrderMultipleShippingLocations__c,
       Order.ShippingCostMethodNS__c, VATRule__c, VATRule__r.Rate__c, LineItemTotal__c, VATCalculated__c,ListPriceItemGroup__c,ComponentListPrice__c, Order.Pricebook2.Name
        from OrderItem];
        */
        
        List<Id> OrderId = new List<Id>();
        OrderId.add(lstOrder[0].id);
        OrderItem[] lstOrderItemGet = Order_OrderandOrdeItemHandler.returnQueryOrderItems(null,OrderId);

		List<ListPriceDiscount__c> ListPriceDiscount = Order_TestDataFactory.insertListPriceDiscount(5,'Regular','Workbooks',true);
        //Order_OrderandOrdeItemHandler.triggerhandler(lstOrderItemGet);
        
		Order_OrderandOrdeItemHandler.OrderItemBusinessLogichandler(lstOrderItemGet, lstOrder,ordIdLs, 'TriggerBusinessRules',ListPriceDiscount,0 );
        
        Order_OrderandOrdeItemHandler.OrderItemBusinessLogichandler(lstOrderItemGet, lstOrder,ordIdLs, 'ProductSelectorOrderItems',ListPriceDiscount,0 );
        
        Order_OrderandOrdeItemHandler.OrderItemBusinessLogichandler(lstOrderItemGet, lstOrder,ordIdLs, 'AssetRenewal',ListPriceDiscount,0 );
    }

}