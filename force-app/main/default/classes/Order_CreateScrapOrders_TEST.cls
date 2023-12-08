@isTest
public with sharing class Order_CreateScrapOrders_TEST {

    @TestSetup
    static void makeData(){

        List<Product2> productItemList = TestDataFactory.insertProducts(1,false);
        for(Product2 testProduct : productItemList){
            testProduct.Subsidiary__c = 'Plantyn';
        }
        insert productItemList;

        TestDataFactory.insertAccounts(1,'Plantyn',true);

    }

    public static testmethod void testScrapOrderInvokeMethod() {

        Product2 product = [SELECT Subsidiary__c, ISBN__c FROM Product2 LIMIT 1];

        Test.startTest();
        List<Order_CreateScrapOrders.FlowInputs> flowInputTestList = new List<Order_CreateScrapOrders.FlowInputs>();
        Order_CreateScrapOrders.FlowInputs flowInputTest = new Order_CreateScrapOrders.FlowInputs();
        flowInputTest.product = product;
        flowInputTest.amountToScrap = '1';
        flowInputTestList.add(flowInputTest);
        Order_CreateScrapOrders.invokeMethod(flowInputTestList);
        Test.stopTest();

        List<ImportOrder__c> testImportOrders = [SELECT Id FROM ImportOrder__c];
        //1 IMPORT ORDER FOR ORDER & 1 IMPORT ORDER FOR ORDER PRODUCT
        System.assertEquals(2, testImportOrders.size());
    }

}