@Istest
public with sharing class Order_OrdeItemFromOrderTypeChange_test {
   
    public static testmethod void Order_OrdeItemFromOrderTypeChange(){

        test.startTest();
        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Noordhoff',true,true);
        
        List<Product2> lstProduct = TestDataFactory.insertProducts(2,true);

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

        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,true);

       

        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);

       


        List<OrderShipto__c> lst_OrderShipto = Order_TestDataFactory.insertOrderShipto(1,lstOrder, lstAccount,true);
        Order_TestDataFactory.insertListPriceDiscount(5,'Regular','Workbooks',true);

        for(Order ord:lstOrder){
            ord.Type ='ServiceOrder';
            ord.OrderTypeJobRun__c = true;
        }
        

        system.debug('***Updadate Service Order**');
        update lstOrder;
    }


}