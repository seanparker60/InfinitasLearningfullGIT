@isTest
public class OrderProductReferencesController_TEST {
    @testSetup
    public static void makeData(){
        
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
            item.CustomerReference__c = 'ref';
        }
        
        insert lstOrderItems;
    }
    
    public static testMethod void testOrderProductReferencesController(){
        OrderItem ord = [SELECT Id,CustomerReference__c, OrderId  FROM OrderItem LIMIT 1];
		test.startTest();
        List<OrderItem> testLs = OrderProductReferencesController.getOrderProducts(ord.OrderId);
        
        OrderProductReferencesController.saveRecords(testLs);
        test.stopTest();
    }
}