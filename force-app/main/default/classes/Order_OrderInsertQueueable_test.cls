@Istest
public with sharing class Order_OrderInsertQueueable_test {
    
    Public static testmethod void OrderInsertQueueable1(){
     Test.startTest();
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


        for(OrderItem item:lstOrderItems){
            OrderId.add(item.id);
        }

       // Order_ActivateAPISendOrderItems.UpdateOrderItems(OrderId);
       UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;
        System.enqueueJob(new Order_OrderInsertQueueable(Null,lstOrder[0].id, 100,true,lstAccount));

        Test.stopTest();
        
    }



    Public static testmethod void OrderInsertQueueable2(){
        Test.startTest();
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
   
           Order_ActivateAPISendOrderItems.UpdateOrderItems(OrderId);
           UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;
           System.enqueueJob(new Order_OrderInsertQueueable(lstContract[0].id,null, 100,true,lstAccount));
   
           Test.stopTest();
           
       }
   


}