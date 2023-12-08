@IsTest
public with sharing class PDF_orderToPdfController_TEST {

    @TestSetup
    static void makeData(){
        Map<String,Account> accountMap = PDF_TestDataFactory.createAccounts(true);
        Order order = PDF_TestDataFactory.createOrder(accountMap, true);
        List<OrderItem> orderItemList = PDF_TestDataFactory.createOrderItems(accountMap, order, 5, true);
    }

    @IsTest
    static void testGetOrderItems(){
        
        Order o = [SELECT Id FROM Order LIMIT 1];

        PDF_orderToPdfController controller = New PDF_orderToPdfController();
        controller.recordId = o.Id;

        Test.startTest();
            List<OrderItem> orderItems = controller.getOrderItems();
        Test.stopTest();
        
        System.assertEquals(5, orderItems.size());
    }
    
    @IsTest
    static void testGetItemMap(){
        
        Order o = [SELECT Id FROM Order LIMIT 1];

        PDF_orderToPdfController controller = New PDF_orderToPdfController();
        controller.recordId = o.Id;

        Test.startTest();
            Map<String, OrderItem> orderItemMap = controller.getItemMap();
        Test.stopTest();
        
        System.assertEquals(50, orderItemMap.get('TestProduct').Quantity);
    }

    @IsTest
    static void testGetOrderItemsPerShipTo(){
        
        Account shipToAcc = [SELECT Id, Name, ShippingStreet, ShippingPostalCode, ShippingCity, ShippingCountry FROM Account WHERE Name = 'Test Ship-to Account' LIMIT 1];
        Order o = [SELECT Id FROM Order LIMIT 1];

        PDF_orderToPdfController controller = New PDF_orderToPdfController();
        controller.recordId = o.Id;

        Test.startTest();
            Map<Account, List<OrderItem>> shipToAccountItemMap = controller.getOrderItemsPerShipTo();
        Test.stopTest();
        
        System.assertEquals(5, shipToAccountItemMap.get(shipToAcc).size());
    }

    @IsTest
    static void testGetBillToAccount(){
        
        Account billToAccount = [SELECT Id, ExternalCustomerId__c, CustomerNumber__c, VATNumber__c, Name, BillingStreet, BillingPostalCode, BillingCity, BillingCountry FROM Account WHERE Name = 'Test Bill-to Account' LIMIT 1];
        Order o = [SELECT Id FROM Order LIMIT 1];

        PDF_orderToPdfController controller = New PDF_orderToPdfController();
        controller.recordId = o.Id;

        Test.startTest();
            Account billToAccountFromController = controller.getBillToAccount();
        Test.stopTest();
        
        System.assertEquals(billToAccount.Id, billToAccountFromController.Id);
    }

    @IsTest
    static void testGetOrderDetails(){
        
        Order o = [SELECT Id, ShippingCost__c, OrderNotificationEmail__c, QuoteVersion__c, ShipbyDate__c, OrderNumber, TotalOrderDiscount__c, TotalAmount FROM Order LIMIT 1];
        o.ShippingCost__c = 0;

        PDF_orderToPdfController controller = New PDF_orderToPdfController();
        controller.recordId = o.Id;

        Test.startTest();
            Order orderFromController = controller.getOrderDetails();
        Test.stopTest();
        
        System.assertEquals(o, orderFromController);
    }

    @IsTest
    static void testGetVat(){
        
        Order o = [SELECT Id FROM Order LIMIT 1];

        PDF_orderToPdfController controller = New PDF_orderToPdfController();
        controller.recordId = o.Id;

        Test.startTest();
            Double vatAmount = controller.getVat();
        Test.stopTest();
        
        System.assertEquals(7.5, vatAmount);
    }

    @IsTest
    static void testGetTranslations(){
        
        Order o = [SELECT Id FROM Order LIMIT 1];

        PDF_orderToPdfController controller = New PDF_orderToPdfController();
        controller.recordId = o.Id;

        Test.startTest();
            OrderPdfSetting__mdt translationsFromController = controller.getTranslations();
        Test.stopTest();
        
        System.assertEquals('Factuur Adres', translationsFromController.BillTo__c);
        System.assertEquals('Order Nr.', translationsFromController.OrderNo__c);
    }

    @IsTest
    static void testGetOpCoSettings(){
        
        Order o = [SELECT Id FROM Order LIMIT 1];

        PDF_orderToPdfController controller = New PDF_orderToPdfController();
        controller.recordId = o.Id;

        Test.startTest();
            OrderPdfSetting__mdt opcoSetting = controller.getOpCoSettings();
        Test.stopTest();
        
        System.assertEquals('Plantyn N.V.', opcoSetting.Footer__c.left(12));
        System.assertEquals('https://infinitaslearning--devcentral--c.visualforce.com/resource/1621258049000/PlantynInformatLogo?', opcoSetting.LogoUrl__c);
    }

}