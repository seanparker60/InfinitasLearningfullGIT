@Istest
public with sharing class Order_BatchUpdateB2BOrders_test {
    
    public static testmethod void BatchUpdateB2BOrders (){

        test.startTest();
        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Noordhoff',true,true);

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
        
        for(Order ord:lstOrder){
            ord.ActivateforBatchProcessing__c =true;
        }
        
        Insert lstOrder;
    
        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,false); 
    
        insert lstOrderItems;
    /*
        for(Order ord:lstOrder){
            ord.TriggerBusinessRules__c =true;
        }
       
        update lstOrder;

        Date CurrrentDay = system.today()-1;
        Order[] qOrder = [SELECT Id,Billto__c,Type,TriggerBusinessRules__c,Status,ActivateforBatchProcessing__c,Source__c,LineCount__c,ValidationErrorsOrder__c,ValidationErrorsOrderProducts__c  FROM Order ]; // where 	LineCount__c >:0 AND Type != 'RenewalOrder' AND createddate >: CurrrentDay and Status !=: 'Activated' AND (TriggerBusinessRules__c =:true OR (ValidationErrorsOrder__c >:0 OR ValidationErrorsOrderProducts__c >:0)) ];

        system.debug('***B2BOrder: LineCount***'+qOrder[0].LineCount__c);
        system.debug('***B2BOrder: TriggerBusinessRules***'+qOrder[0].TriggerBusinessRules__c);
        system.debug('***B2BOrder: Type***'+qOrder[0].Type);
        system.debug('***B2BOrder: Status***'+qOrder[0].Status);
        system.debug('***B2BOrder: Status***'+qOrder[0].ValidationErrorsOrder__c);
        system.debug('***B2BOrder: Status***'+qOrder[0].ValidationErrorsOrderProducts__c);
        
        */ 

        UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;
        Order_BatchUpdateB2BOrders  B2BOrders = new Order_BatchUpdateB2BOrders();  
        database.executebatch(B2BOrders ,100);

        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, B2BOrders); 
        
       
       // database.executebatch(B2BOrders ,1);
  
     }



}