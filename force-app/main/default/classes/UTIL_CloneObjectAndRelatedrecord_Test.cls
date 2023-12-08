@isTest
public class UTIL_CloneObjectAndRelatedrecord_Test {
    @TestSetup
    static void makeData(){
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
    }

    public static testMethod void UTIL_CloneObjectAndRelatedrecord_Test() {
        List<UTIL_CloneObjectAndRelatedrecord.FlowInputs> request = new List<UTIL_CloneObjectAndRelatedrecord.FlowInputs>();
        UTIL_CloneObjectAndRelatedrecord.FlowInputs flowInput = new UTIL_CloneObjectAndRelatedrecord.FlowInputs();
        //UTIL_CloneObjectAndRelatedrecord util_Clone = new UTIL_CloneObjectAndRelatedrecord();

        flowInput.recordId = [SELECT Id FROM Order LIMIT 1].Id;
        request.add(flowInput);

        test.startTest();
        UTIL_CloneObjectAndRelatedrecord.CloneRelatedListItems(request);
        test.stopTest();
    }
}