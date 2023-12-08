@istest
public with sharing class Order_OrderActivateRESTAPI_test {

    public static testmethod void Order_OrderActivateRESTAPI1(){

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
         

        Set<String> Set_QOrderId = new Set<String>();

        String OrderId;
        for(Order ord:lstOrder){
            Set_QOrderId.add(ord.id);
            OrderId = ord.id;
        }

        UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;
        Order_OrderActivateRESTAPI.IntegrateOrders(Set_QOrderId);
        Order_OrderActivateRESTAPI.doPost(OrderId);

    }

    public static testmethod void Order_OrderActivateRESTAPI2(){

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

        OrderLineItemMaxCount__mdt[] OrderLineItemMaxCount = [Select Count__c from OrderLineItemMaxCount__mdt where MasterLabel='TestCount'];

        Integer count = integer.valueof(OrderLineItemMaxCount[0].Count__c)+3;

        List<Product2> lstProduct = TestDataFactory.insertProducts(1,true);
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(2,lstAccount,lstContract,standardPricebook.id,false);
        
        for(Order ord:lstOrder){
            ord.ActivateforBatchProcessing__c =true;
            ord.NetSuiteIdShiptoAccount__c = '887760';
            ord.NetSuiteIdAccountSubsidiary__c = Map_AccSub.get(ord.Billto__c); 
            ord.AccountSubsidiary__c = Map_AccSub.get(ord.Billto__c);
        }
        
        Insert lstOrder;
        
        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(count,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
         

        UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;
        MaxOrderLine__c MaxOrderLine = new MaxOrderLine__c();

        lstOrder = [Select LineCount__c,TotalAmount,MaxOrderLine__c From Order ];

        MaxOrderLine.LineCount__c = lstOrder[1].LineCount__c + lstOrder[0].LineCount__c;
        MaxOrderLine.OrderTotal__c = lstOrder[1].TotalAmount + lstOrder[0].TotalAmount;
        MaxOrderLine.ExpectedActivationCount__c = lstOrder.size(); 
        MaxOrderLine.ActivationReadyCount__c = lstOrder.size();
        
        insert MaxOrderLine;

        lstOrder[1].MasterOrder__c = lstOrder[0].id;
        lstOrder[1].MaxOrderLine__c = MaxOrderLine.id;
        lstOrder[0].MaxOrderLine__c = MaxOrderLine.id;

       
        update lstOrder;
        
        

        Order_RelatedOrderProcess Related = new Order_RelatedOrderProcess(); 
       
        List<Order_RelatedOrderProcess.Request> lst_req = new List<Order_RelatedOrderProcess.Request>();

        Order_RelatedOrderProcess.Request req = new Order_RelatedOrderProcess.Request();
        req.ProcessToRun = 'TriggerBusinessRules';
        req.MaxOrderLineId = MaxOrderLine.id;
        lst_req.add(req);

        Order_RelatedOrderProcess.RelatedOrderProcess(lst_req);
        MaxOrderLine__c[] lstMaxOrderLine =[Select id,RelatedOrderActivationready__c,ExpectedActivationCount__c from MaxOrderLine__c Where id =: lstOrder[0].MaxOrderLine__c]; 
        
        system.debug('****ValidateMAXActivationExpected***'+lstMaxOrderLine[0].ExpectedActivationCount__c);
        system.debug('****ValidateMAXActivation***'+lstMaxOrderLine[0].RelatedOrderActivationready__c);
        system.debug('****ValidateMAXActivationSize***'+lstMaxOrderLine.size());

        Set<String> Set_QOrderId = new Set<String>();

        String OrderId;
        Order[] nextOrder = [SELECT id, MaxOrderLine__r.RelatedOrderActivationready__c,MaxOrderLine__r.ExpectedActivationCount__c  FROM Order where id =: lstOrder[0].id];
        
        for(Order ord:nextOrder){
            Set_QOrderId.add(ord.id);
            OrderId = ord.id;
            system.debug('****ValidateMAXActivationExpectedOrd***'+ord.MaxOrderLine__r.RelatedOrderActivationready__c);
            system.debug('****ValidateMAXActivationOrd***'+ord.MaxOrderLine__r.ExpectedActivationCount__c);
        }
    
        UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;
        Order_OrderActivateRESTAPI.IntegrateOrders(Set_QOrderId);
        Order_OrderActivateRESTAPI.doPost(OrderId);
        
        /*
        Order[] nextOrder = [SELECT LineCount__c,ActivateforBatchProcessing__c,ValidateAccountErrors__c,ValidateActivateAccountSubsidiaryRequir__c,ValidateActivateEmailsRequired__c,ValidateActivateShippingAddressRequired__c,ValidateActivateValidation__c,ValidateB2BLineCountError__c,ValidateBilltoErrors__c,ValidateBillingAddress__c,ValidateBillToEmpty__c,ValidateCreditLimitCheck__c,ValidateFreeAndServiceMustbeZeroOnActiv__c,ValidateInventoryOnMultipleLocations__c,ValidateNetSalesPrice__c,ValidateOrderAmount__c,ValidateReferenceNumberCheck__c,ValidateShiptoErrors__c,ValidateShippingCostExclVAT__c,ValidateShippingAddress__c,ValidateShipToEmpty__c,ValidateTotalLineItemQuantities__c,ValidateDigitalforNetherlands__c,ValidateStartEndDateonOnItems__c,ValidationErrorsOrder__c,ValidationErrorsOrderProducts__c
        FROM Order ];
        
        
        system.debug('***ValidateAccountErrors__c**'+nextOrder[0].ValidateAccountErrors__c);
        system.debug('***ValidateActivateAccountSubsidiaryRequir__c**'+nextOrder[0].ValidateActivateAccountSubsidiaryRequir__c);
        system.debug('***ValidateActivateEmailsRequired__c**'+nextOrder[0].ValidateActivateEmailsRequired__c);
        system.debug('***ValidateActivateShippingAddressRequired__c**'+nextOrder[0].ValidateActivateShippingAddressRequired__c);
        system.debug('***ValidateActivateValidation__c**'+nextOrder[0].ValidateActivateValidation__c);
        system.debug('***ValidateB2BLineCountError__c**'+nextOrder[0].ValidateB2BLineCountError__c);
        system.debug('***ValidateBilltoErrors__c**'+nextOrder[0].ValidateBilltoErrors__c);
        system.debug('***ValidateBillingAddress__c**'+nextOrder[0].ValidateBillingAddress__c);
        system.debug('***ValidateBillToEmpty__c**'+nextOrder[0].ValidateBillToEmpty__c);
        system.debug('***ValidateCreditLimitCheck__c**'+nextOrder[0].ValidateCreditLimitCheck__c);
        system.debug('***ValidateFreeAndServiceMustbeZeroOnActiv__c**'+nextOrder[0].ValidateFreeAndServiceMustbeZeroOnActiv__c);
        system.debug('***ValidateInventoryOnMultipleLocations__c**'+nextOrder[0].ValidateInventoryOnMultipleLocations__c);
        system.debug('***ValidateNetSalesPrice__c**'+nextOrder[0].ValidateNetSalesPrice__c);
        system.debug('***ValidateOrderAmount__c**'+nextOrder[0].ValidateOrderAmount__c);
        system.debug('***ValidateReferenceNumberCheck__c**'+nextOrder[0].ValidateReferenceNumberCheck__c);
        system.debug('***ValidateShiptoErrors__c**'+nextOrder[0].ValidateShiptoErrors__c);
        system.debug('***ValidateShippingCostExclVAT__c**'+nextOrder[0].ValidateShippingCostExclVAT__c);
        system.debug('***ValidateShippingAddress__c**'+nextOrder[0].ValidateShippingAddress__c);
        system.debug('***ValidateShipToEmpty__c**'+nextOrder[0].ValidateShipToEmpty__c);
        system.debug('***ValidateTotalLineItemQuantities__c**'+nextOrder[0].ValidateTotalLineItemQuantities__c);
        system.debug('***ValidateDigitalforNetherlands__c**'+nextOrder[0].ValidateDigitalforNetherlands__c);
        system.debug('***ValidateStartEndDateonOnItems__c**'+nextOrder[0].ValidateStartEndDateonOnItems__c);
        system.debug('***ValidationErrorsOrder__c**'+nextOrder[0].ValidationErrorsOrder__c);
        system.debug('***ValidationErrorsOrderProducts__c**'+nextOrder[0].ValidationErrorsOrderProducts__c);
        
    */
       
        
    }

}