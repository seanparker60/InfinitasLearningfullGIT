@istest
public with sharing class Order_BatchUpdateOrdersOnMerge_test {
    
    public static testmethod void UpdateOrdersOnMerge(){
    test.startTest();
        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Plantyn',true,true);

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
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,false);
        
        
        Insert lstOrder;
    
        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,false); 
    
        insert lstOrderItems;
    
        
        
         

        
        

        UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;
        Order_BatchUpdateOrdersOnMerge  OrdersOnMerge = new Order_BatchUpdateOrdersOnMerge(Set_AccId);  
        String chron = '0 0 23 * * ?';        
        
        database.executebatch(OrdersOnMerge ,100);
        //database.executebatch(B2BOrders ,1);
        system.schedule('Test Sched', chron, OrdersOnMerge); 
        
     }
}