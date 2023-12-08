@Istest
public with sharing class Order_StructurediscountCalculation_test {
    
    public static testmethod void Order_StructurediscountCalculation(){

        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Noordhoff',true,true);
        
        List<Product2> lstProduct = TestDataFactory.insertProducts(3,true);
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,true);
        Order_TestDataFactory.insertOrderShipto(1,lstOrder, lstAccount,true);

        List<Asset>lst_Asset = TestDataFactory.insertAsset(standardPricebook.id ,lstProduct,lstAccount, lstAccount,false);
        
        for(Asset ass:lst_Asset){
            ass.Contract__c = lstContract [0].id;
        }
        
        Insert lst_Asset;

        List<Id> lst_AccountId = new List<Id>();
        lst_AccountId.add(lstAccount[1].id);

        List<Order_StructurediscountCalculation.Request> request = new List<Order_StructurediscountCalculation.Request>();

        Order_StructurediscountCalculation.Request req = new Order_StructurediscountCalculation.Request();
         
        system.debug('**Structure:**');

        req.ContractId = lstContract [0].id;
        req.ExistingContract= 'yes'; 
        req.ContractRenewal = 'no'  ;
        req.PricingMethod = 'ProductUsageBased' ;
        req.ContractRequired = 'yes';
        req.ListOfAccountIds = lst_AccountId;
        request.add(req);
        Order_StructurediscountCalculation.start(request);

        //2
        request = new List<Order_StructurediscountCalculation.Request>();

        req = new Order_StructurediscountCalculation.Request();
         
        req.ContractId = lstContract [0].id;
        req.ExistingContract= 'yes'; 
        req.ContractRenewal = 'yes'  ;
        req.PricingMethod = 'ProductDiscountGroupUsageBased' ;
        req.ContractRequired = 'yes';
        req.ListOfAccountIds = lst_AccountId;
        request.add(req);
        Order_StructurediscountCalculation.start(request);

        //2.1
        request = new List<Order_StructurediscountCalculation.Request>();
        req = new Order_StructurediscountCalculation.Request();
         
        req.ContractId = lstContract [0].id;
        req.ExistingContract= 'yes'; 
        req.ContractRenewal = 'yes'  ;
        req.PricingMethod = 'ProductUsageBased' ;
        req.ContractRequired = 'yes';
        req.ListOfAccountIds = lst_AccountId;
        request.add(req);
        Order_StructurediscountCalculation.start(request);

         //2.2
         request = new List<Order_StructurediscountCalculation.Request>();
         req = new Order_StructurediscountCalculation.Request();
         
         req.ContractId = lstContract [0].id;
         req.ExistingContract= 'yes'; 
         req.ContractRenewal = 'yes'  ;
         req.PricingMethod = 'OrderProductQuantity' ;
         req.ContractRequired = 'yes';
         req.ListOfAccountIds = lst_AccountId;
         request.add(req);
         Order_StructurediscountCalculation.start(request);

        //2.3
         request = new List<Order_StructurediscountCalculation.Request>();
         req = new Order_StructurediscountCalculation.Request();
         
         req.ContractId = lstContract [0].id;
         req.ExistingContract= 'yes'; 
         req.ContractRenewal = 'yes'  ;
         req.PricingMethod = 'AccountStudents' ;
         req.ContractRequired = 'yes';
         req.ListOfAccountIds = lst_AccountId;
         request.add(req);
         Order_StructurediscountCalculation.start(request);
        

        //3
        request = new List<Order_StructurediscountCalculation.Request>();

        req = new Order_StructurediscountCalculation.Request();
         
        req.ContractId = lstContract [0].id;
        req.ExistingContract= 'no'; 
        req.ContractRenewal = 'yes'  ;
        req.PricingMethod = 'ProductDiscountGroupUsageBased' ;
        req.ContractRequired = 'yes';
        req.ListOfAccountIds = lst_AccountId;
        request.add(req);
        Order_StructurediscountCalculation.start(request);

         //4
         request = new List<Order_StructurediscountCalculation.Request>();

         req = new Order_StructurediscountCalculation.Request();
          
         req.ContractId = lstContract [0].id;
         req.ExistingContract= 'no'; 
         req.ContractRenewal = 'yes'  ;
         req.PricingMethod = 'ProductDiscountGroupUsageBased' ;
         req.ContractRequired = 'no';
         req.ListOfAccountIds = lst_AccountId;
         request.add(req);
         Order_StructurediscountCalculation.start(request);


        //5
         request = new List<Order_StructurediscountCalculation.Request>();

         req = new Order_StructurediscountCalculation.Request();
          
         req.ContractId = lstContract[0].id;
         req.OrderId = lstOrder[0].id;
         req.ExistingContract= 'Yes'; 
         req.ContractRenewal = 'yes'  ;
         req.PricingMethod = 'ProductDiscountGroupUsageBased' ;
         req.ContractRequired = 'no';
         req.ListOfAccountIds = lst_AccountId;
         request.add(req);
         Order_StructurediscountCalculation.start(request);

        //6
        lstContract[0].SoldUsers__c = 0;
        update lstContract;

         request = new List<Order_StructurediscountCalculation.Request>();

         req = new Order_StructurediscountCalculation.Request();
          
         req.ContractId = lstContract[0].id;
         req.OrderId = lstOrder[0].id;
         req.ExistingContract= 'Yes'; 
         req.ContractRenewal = 'yes'  ;
         req.PricingMethod = 'ProductDiscountGroupUsageBased' ;
         req.ContractRequired = 'no';
         req.ListOfAccountIds = lst_AccountId;
         request.add(req);
         Order_StructurediscountCalculation.start(request);

        //7
         lstContract[0].SoldUsers__c = 0;
        update lstContract;

         request = new List<Order_StructurediscountCalculation.Request>();

         req = new Order_StructurediscountCalculation.Request();
          
         req.ContractId = null;
         req.OrderId = lstOrder[0].id;
         req.ExistingContract= 'Yes'; 
         req.ContractRenewal = 'yes'  ;
         req.PricingMethod = 'ProductDiscountGroupUsageBased' ;
         req.ContractRequired = 'no';
         req.ListOfAccountIds = lst_AccountId;
         request.add(req);

         UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;
         Order_StructurediscountCalculation.start(request);



    }




}