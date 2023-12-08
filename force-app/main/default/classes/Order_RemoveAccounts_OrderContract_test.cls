@istest
public with sharing class Order_RemoveAccounts_OrderContract_test {
    
    
    public static testmethod void Order_RemoveAccounts_OrderContract(){

        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Noordhoff',true,true);
        
        List<Product2> lstProduct = TestDataFactory.insertProducts(3,true);
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,true);
        Order_TestDataFactory.insertOrderShipto(1,lstOrder, lstAccount,true);

        List<Id> lst_AccountId = new List<Id>();
        lst_AccountId.add(lstAccount[1].id);

        List<Order_RemoveAccounts_OrderContract.Request> request = new List<Order_RemoveAccounts_OrderContract.Request>();

        
        system.debug('**lstOrder[0].Id**'+lstOrder[0].Id);

        Order_RemoveAccounts_OrderContract.Request req = new Order_RemoveAccounts_OrderContract.Request();
        req.RecordId = lstOrder[0].Id;
        req.BilltoAccount = lstAccount[0] ;
        req.PricebookId =  standardPricebook.id ;
        req.RequestType = '' ; 
        req.ExistingContract= 'yes'; 
        req.ContractRenewal = 'no'  ;
        req.PricingMethod = 'LicenseUsageBasedRate' ;
        req.ContractRequired = 'yes';
        req.ListOfAccountIds = lst_AccountId;
        request.add(req);

        UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;
        Order_RemoveAccounts_OrderContract.ContractAccounts(request);

        
    }
}