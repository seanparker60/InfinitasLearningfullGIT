@Istest
public with sharing class Order_UpdateShippingCostsFromItems_test {
    
    Public static testmethod void UpdateShippingCostsFromItemsDomestic(){

        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Noordhoff',true,true);
   
           Set<String> Set_AccId = new Set<String>();
           Set<String> Set_Operating = new Set<String>();

           for(Account acc:lstAccount){
               Set_AccId.add(acc.id);
               Set_Operating.add(acc.OperatingCompany__c);
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
           List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,false);
           Order_TestDataFactory.InsertShippingCost(Set_Operating, true);

           for(OrderItem item:lstOrderItems){
                item.ShippingIndicationRule__c = 'Based on weight Domestic';
           }

           insert lstOrderItems;

           Order[] CurOrder = [Select Billto__r.OperatingCompany__c From Order ];
        
            List<String> shippingRuleList = new List<String>{'PU - Based on weight Domestic'};
            insertShippingCosts(shippingRuleList, CurOrder[0], true);

           UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;
           Order_UpdateShippingCostsFromItems.UpdateShippingCostsFromItems(lstOrderItems, CurOrder[0]);

    }


    Public static testmethod void UpdateShippingCostsFromItemsNonDomestic(){

        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Noordhoff',true,true);
   
           Set<String> Set_AccId = new Set<String>();
           Set<String> Set_Operating = new Set<String>();

           for(Account acc:lstAccount){
               Set_AccId.add(acc.id);
               Set_Operating.add(acc.OperatingCompany__c);
           }
           
           system.debug('**Set_Operating:'+Set_Operating);

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
           List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,false);
           Order_TestDataFactory.InsertShippingCost(Set_Operating, true);
           for(OrderItem item:lstOrderItems){
                item.ShippingIndicationRule__c = 'Based on weight non Domestic';
           }

           insert lstOrderItems;

           Order[] CurOrder = [Select Billto__r.OperatingCompany__c From Order ];

            List<String> shippingRuleList = new List<String>{'PU - Based on weight non Domestic'};
            insertShippingCosts(shippingRuleList, CurOrder[0], true);
        
           UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;
           Order_UpdateShippingCostsFromItems.UpdateShippingCostsFromItems(lstOrderItems, CurOrder[0]);

    }

    Public static testmethod void UpdateShippingCostsFromItemsTotal(){
        
        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Noordhoff',true,true);
        
        Set<String> Set_AccId = new Set<String>();
        Set<String> Set_Operating = new Set<String>();
        
        for(Account acc:lstAccount){
            Set_AccId.add(acc.id);
            Set_Operating.add(acc.OperatingCompany__c);
        }
        
        system.debug('**Set_Operating:'+Set_Operating);
        
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
        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,false);
        Order_TestDataFactory.InsertShippingCost(Set_Operating, true);
        for(OrderItem item:lstOrderItems){
            item.ShippingIndicationRule__c = 'Based on order total';
        }
        
        insert lstOrderItems;
        
        Order[] CurOrder = [Select Billto__r.OperatingCompany__c From Order ];
        
        List<String> shippingRuleList = new List<String>{'Order Total'};
        insertShippingCosts(shippingRuleList, CurOrder[0], true);
        
        UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;
        Order_UpdateShippingCostsFromItems.UpdateShippingCostsFromItems(lstOrderItems, CurOrder[0]);
        
    }
    
    Public static testmethod void UpdateShippingCostsFromItemsDomAndTotal(){
        
        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Noordhoff',true,true);
        
        Set<String> Set_AccId = new Set<String>();
        Set<String> Set_Operating = new Set<String>();
        
        for(Account acc:lstAccount){
            Set_AccId.add(acc.id);
            Set_Operating.add(acc.OperatingCompany__c);
        }
        
        system.debug('**Set_Operating:'+Set_Operating);
        
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
        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(2,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,false);
        Order_TestDataFactory.InsertShippingCost(Set_Operating, true);
        /*for(OrderItem item:lstOrderItems){
        item.ShippingIndicationRule__c = 'Based on order total';
        }*/
        lstOrderItems[0].ShippingIndicationRule__c = 'Based on order total';
        lstOrderItems[1].ShippingIndicationRule__c = 'Based on weight Domestic';
        insert lstOrderItems;
        
        Order[] CurOrder = [Select Billto__r.OperatingCompany__c From Order ];
        
        List<String> shippingRuleList = new List<String>{'PU - Based on weight Domestic','Order Total'};
        insertShippingCosts(shippingRuleList, CurOrder[0], true);
        
        UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;
        Order_UpdateShippingCostsFromItems.UpdateShippingCostsFromItems(lstOrderItems, CurOrder[0]);
        
    }
    
    Public static testmethod void UpdateShippingCostsFromItemsNonDomAndTotal(){
        
        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Noordhoff',true,true);
        
        Set<String> Set_AccId = new Set<String>();
        Set<String> Set_Operating = new Set<String>();
        
        for(Account acc:lstAccount){
            Set_AccId.add(acc.id);
            Set_Operating.add(acc.OperatingCompany__c);
        }
        
        system.debug('**Set_Operating:'+Set_Operating);
        
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
        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(2,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,false);
        Order_TestDataFactory.InsertShippingCost(Set_Operating, true);
        /*for(OrderItem item:lstOrderItems){
        item.ShippingIndicationRule__c = 'Based on order total';
        }*/
        lstOrderItems[0].ShippingIndicationRule__c = 'Based on order total';
        lstOrderItems[1].ShippingIndicationRule__c = 'Based on weight non Domestic';
        insert lstOrderItems;
        
        Order[] CurOrder = [Select Billto__r.OperatingCompany__c From Order ];
        
        List<String> shippingRuleList = new List<String>{'PU - Based on weight non Domestic','Order Total'};
        insertShippingCosts(shippingRuleList, CurOrder[0], true);
        
        UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;
        Order_UpdateShippingCostsFromItems.UpdateShippingCostsFromItems(lstOrderItems, CurOrder[0]);
        
    }
    
    Public static testmethod void UpdateShippingCostsFromItemsDomAndNonDom(){
        
        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Noordhoff',true,true);
        
        Set<String> Set_AccId = new Set<String>();
        Set<String> Set_Operating = new Set<String>();
        
        for(Account acc:lstAccount){
            Set_AccId.add(acc.id);
            Set_Operating.add(acc.OperatingCompany__c);
        }
        
        system.debug('**Set_Operating:'+Set_Operating);
        
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
        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(2,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,false);
        Order_TestDataFactory.InsertShippingCost(Set_Operating, true);
        /*for(OrderItem item:lstOrderItems){
        item.ShippingIndicationRule__c = 'Based on order total';
        }*/
        lstOrderItems[0].ShippingIndicationRule__c = 'Based on weight non Domestic';
        lstOrderItems[1].ShippingIndicationRule__c = 'Based on weight Domestic';
        insert lstOrderItems;
        
        Order[] CurOrder = [Select Billto__r.OperatingCompany__c From Order ];
        
        List<String> shippingRuleList = new List<String>{'PU - Based on weight non Domestic','PU - Based on weight Domestic'};
        insertShippingCosts(shippingRuleList, CurOrder[0], true);
        
        UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;
        Order_UpdateShippingCostsFromItems.UpdateShippingCostsFromItems(lstOrderItems, CurOrder[0]);
        
    }
    
    Public static testmethod void UpdateShippingCostsFromItemsAll(){
        
        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Noordhoff',true,true);
        
        Set<String> Set_AccId = new Set<String>();
        Set<String> Set_Operating = new Set<String>();
        
        for(Account acc:lstAccount){
            Set_AccId.add(acc.id);
            Set_Operating.add(acc.OperatingCompany__c);
        }
        
        system.debug('**Set_Operating:'+Set_Operating);
        
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
        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(3,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,false);
        Order_TestDataFactory.InsertShippingCost(Set_Operating, true);
        /*for(OrderItem item:lstOrderItems){
        item.ShippingIndicationRule__c = 'Based on order total';
        }*/
        lstOrderItems[0].ShippingIndicationRule__c = 'Based on weight non Domestic';
        lstOrderItems[1].ShippingIndicationRule__c = 'Based on weight Domestic';
        lstOrderItems[2].ShippingIndicationRule__c = 'Based on order total';
        insert lstOrderItems;
        
        Order[] CurOrder = [Select Billto__r.OperatingCompany__c From Order ];
        
        List<String> shippingRuleList = new List<String>{'PU - Based on weight non Domestic','PU - Based on weight Domestic','Order Total'};
        insertShippingCosts(shippingRuleList, CurOrder[0], true);
        
        UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;
        Order_UpdateShippingCostsFromItems.UpdateShippingCostsFromItems(lstOrderItems, CurOrder[0]);
        
    }
    
    Public static testmethod void UpdateShippingCostsFromItemsNoShipping(){
        
        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Noordhoff',true,true);
        
        Set<String> Set_AccId = new Set<String>();
        Set<String> Set_Operating = new Set<String>();
        
        for(Account acc:lstAccount){
            Set_AccId.add(acc.id);
            Set_Operating.add(acc.OperatingCompany__c);
        }
        
        system.debug('**Set_Operating:'+Set_Operating);
        
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
        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,false);
        Order_TestDataFactory.InsertShippingCost(Set_Operating, true);
        for(OrderItem item:lstOrderItems){
            item.ShippingIndicationRule__c = 'Based on order total';
        }
        
        insert lstOrderItems;
        
        Order[] CurOrder = [Select Billto__r.OperatingCompany__c From Order ];
        
        UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;
        Order_UpdateShippingCostsFromItems.UpdateShippingCostsFromItems(lstOrderItems, CurOrder[0]);
        
    }
    
    Public static List<ShippingCost__c> insertShippingCosts(List<String> shippingRuleList, Order CurOrder, Boolean doInsert){
        List<ShippingCost__c> shippingCostList = new List<ShippingCost__c>();
        ShippingCost__c shippingcost;
        
        for(String shinningRule : shippingRuleList){
            shippingcost = new ShippingCost__c();
            shippingcost.Name = shinningRule;
            shippingcost.Charge__c = 5;
            shippingcost.ShippingRule__c = shinningRule;
            shippingcost.StartRangeValue__c = 0;
            shippingcost.RangeValue__c = 1000000;
            shippingcost.Subsidiary__c = CurOrder.Billto__r.OperatingCompany__c;
            shippingcost.IsActive__c = true;
            shippingCostList.add(shippingcost);
        }
        
        
        if(doInsert){
            insert shippingCostList;
        }
        
        return shippingCostList;
    }

}