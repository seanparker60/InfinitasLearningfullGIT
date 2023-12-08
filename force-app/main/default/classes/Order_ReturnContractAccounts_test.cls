@istest

public with sharing class Order_ReturnContractAccounts_test {


    public static testmethod void Order_ReturnContractAccounts(){

        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Noordhoff',true,true);
        
        List<Product2> lstProduct = TestDataFactory.insertProducts(3,true);
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,true);
        Order_TestDataFactory.insertOrderShipto(1,lstOrder, lstAccount,true);

        List<Id> lst_AccountId = new List<Id>();
        lst_AccountId.add(lstAccount[1].id);

        List<Order_ReturnContractAccounts.Request> request = new List<Order_ReturnContractAccounts.Request>();

        //1
        system.debug('**lstOrder[0].Id1**'+lstOrder[0].Id);

        Order_ReturnContractAccounts.Request req = new Order_ReturnContractAccounts.Request();
        req.RecordId = lstOrder[0].Id;
        req.BilltoAccount = lstAccount[0] ;
        req.PricebookId =  standardPricebook.id ;
        req.RequestType = 'AccountShipto' ; 
         
        request.add(req);

        Order_ReturnContractAccounts.ContractAccounts(request);

        //2
        request = new List<Order_ReturnContractAccounts.Request>();
        system.debug('**lstOrder[0].Id2**'+lstOrder[0].Id);

        req = new Order_ReturnContractAccounts.Request();
        req.RecordId = lstOrder[0].Id;
        req.BilltoAccount = lstAccount[0] ;
        req.PricebookId =  standardPricebook.id ;
        req.RequestType = 'OrderShipto' ; 
         
        request.add(req);

        Order_ReturnContractAccounts.ContractAccounts(request);

        //3
        
        request = new List<Order_ReturnContractAccounts.Request>();
        system.debug('**lstOrder[0].Id3**'+lstOrder[0].Id);

        req = new Order_ReturnContractAccounts.Request();
        req.RecordId = lstContract[0].Id;
        req.BilltoAccount = lstAccount[0] ;
        req.PricebookId =  standardPricebook.id ;
        req.RequestType = 'OrderShipto' ; 
         
        request.add(req);

        Order_ReturnContractAccounts.ContractAccounts(request);
        

        //4

        OrderShipto__c[] lstOrderShipto = [Select id,ShiptoAccount__c from OrderShipto__c ];
        delete lstOrderShipto;

        request = new List<Order_ReturnContractAccounts.Request>();
        system.debug('**lstOrder[0].Id2**'+lstOrder[0].Id);

        req = new Order_ReturnContractAccounts.Request();   
        req.RecordId = lstOrder[0].Id;
        req.MultipleShipto = true;
        req.BilltoAccount = null;
        req.PricebookId =  standardPricebook.id ;
        req.RequestType = 'OrderShipto' ; 
         
        request.add(req);

        Order_ReturnContractAccounts.ContractAccounts(request);
        
        //5
        
        request = new List<Order_ReturnContractAccounts.Request>();
        system.debug('**lstOrder[0].Id2**'+lstOrder[0].Id);

        req = new Order_ReturnContractAccounts.Request();   
        req.RecordId = lstOrder[0].Id;
        
        req.BilltoAccount = null;
        req.PricebookId =  standardPricebook.id ;
        req.RequestType = 'OrderShipto' ; 
         
        request.add(req);


        UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;
        Order_ReturnContractAccounts.ContractAccounts(request);
        
    }

}