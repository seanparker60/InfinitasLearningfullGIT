@istest
public with sharing class ImportShipping_HandleImports_test {

    public static testmethod void ImportShipping(){
        
        Test.startTest();   
            Order_TestDataFactory.insertImportOrderItem(10, true);
        Test.stopTest();
        
    }


}