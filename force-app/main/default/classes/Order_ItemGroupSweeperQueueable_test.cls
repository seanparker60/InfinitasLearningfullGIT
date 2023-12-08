@istest
public with sharing class Order_ItemGroupSweeperQueueable_test {
    

    public static testmethod void ItemGroupSweeperQueueable1(){

        test.starttest();


        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Noordhoff',true,true);

        Set<String> Set_AccId = new Set<String>();
        for(Account acc:lstAccount){
            Set_AccId.add(acc.id);
        }

        AccountSubsidiary__c[] lstAccountSubsidiary = [Select id,Account__c from AccountSubsidiary__c where Account__c in:Set_AccId ];

        Map<String,String> Map_AccSub = new Map<String,String>();
        Integer i=0;
        for(AccountSubsidiary__c  sub:lstAccountSubsidiary){
            sub.NetsuiteInternalId__c = '12345'+i;
            Map_AccSub.put(sub.Account__c,sub.id);
            i++;
        }

        update lstAccountSubsidiary;
        
        List<Product2> lstProductItemGroup = TestDataFactory.insertProducts(5,false);
        List<Product2> lstProductItem = TestDataFactory.insertProducts(1,false);

        Integer ISBN = lstProductItemGroup.size()+1;
        
        i = 0;
        for(Product2 prod:lstProductItem){
            prod.ISBN__c = prod.ISBN__c + i;
            prod.EAN__c = prod.EAN__c + i;
           // prod.itemGroupManualBlock__c = true;
            i++;
        }


        insert lstProductItem;
        insert lstProductItemGroup;


        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
 
        Pricebook2 PricebookCustom = TestDataFactory.insertPricebookCustom('Plantyn - All 2023');
 
        List<ProductComponent__c> lstProductComponent = Order_TestDataFactory.InsertGroupComponent(lstProductItem,lstProductItemGroup,true);

        Order_TestDataFactory.InsertPricing(lstProductItemGroup,null,true);
        Pricing__c[] lstPricing = Order_TestDataFactory.InsertPricing(lstProductItem,lstProductComponent,true);

        

        Pricing__c[] lstPricingComponent = Order_TestDataFactory.InsertPricingProductComponent(lstProductComponent,false);
        
     //   for(Pricing__c price:lstPricingComponent){
    //         price.ListRate__c =null;
    //     }
         insert lstPricingComponent;

        String OrderExternalId = 'Ext123';


        Pricing__c[] lstPricingCheck = [Select ProductComponent__r.Product__c from Pricing__c where ProductComponent__r.Product__c !=: null AND ProductComponent__r.MainProduct__c != null]; //where ProductComponent__r.Product__c !=: null

        system.debug('**Price check: lstPricingCheck**'+lstPricingCheck.size());


       PricebookEntry[] lstPricebookEntry = [Select id, Pricebook2.Name,Product2.ISBN__c, UnitPrice from PricebookEntry where Pricebook2.Name like: '%Plantyn%' ];

       
       for(PricebookEntry pbe:lstPricebookEntry){
            if(!pbe.Pricebook2.Name.contains('Standard')){
                PricebookCustom.id = pbe.Pricebook2Id;
            }
            system.debug('**Before Pricebook2.Name**'+pbe.Pricebook2.Name);
            system.debug('**Before Product2.ISBN**'+pbe.Product2.ISBN__c);
            system.debug('**Before UnitPrice**'+pbe.UnitPrice);
       }
      
       List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,PricebookCustom.id,true);
      
       List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,PricebookCustom.id,true);
       List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
       List<Order_ImportOrderItemGroupUpdate.Request> lst_request = new  List<Order_ImportOrderItemGroupUpdate.Request>();


       lstAccount = [Select NetsuiteInternalId__c from Account];
       List<ImportOrder__c> lstinsertImportOrder = Order_TestDataFactory.insertImportOrderOrder(lstAccount,false,OrderExternalId,'eCommerce B2B');
       lstinsertImportOrder[0].Status__c = 'Completed';
       insert lstinsertImportOrder;

       List<ImportOrder__c> lstinsertImportOrderItem = Order_TestDataFactory.insertImportOrderItem(lstProductItem,false,OrderExternalId,null,'eCommerce B2B');
       List<ImportOrder__c> lstinsertImportOrderItemGroup = Order_TestDataFactory.insertImportOrderItem(lstProductItemGroup,false,OrderExternalId,lstProductItem[0].EAN__c,'eCommerce B2B');
       lstinsertImportOrderItem.addAll(lstinsertImportOrderItemGroup);
       
       for(ImportOrder__c io : lstinsertImportOrderItem){
            io.Status__c = 'Completed';
            io.NetSalesPrice__c = 5;     
       }
       insert lstinsertImportOrderItem;


       lstOrderItems = [Select id,OrderId,Product2.EAN__c from OrderItem];
       for(OrderItem item:lstOrderItems){
        for(ImportOrder__c io : lstinsertImportOrderItem){
            if(io.ProductId__c == item.Product2.EAN__c){
                Order_ImportOrderItemGroupUpdate.Request request = new Order_ImportOrderItemGroupUpdate.Request();
                io.OrderProduct__c = item.id;
                request.SingleOrderItems = item;
                io.Order__c = item.OrderId;
                request.ImportOrder = io;
                lst_request.add(request);
            }
     
        }
           
       }
       
       update lstinsertImportOrderItem;

       Order_ImportOrderItemGroupUpdate.OrderItemGroupUpdate(lst_request);


       OrderItem[] lstOrderItem = [Select ImportItemGroupEAN__c,ItemGroup__c,OrderId From orderItem];

       for(OrderItem item:lstOrderItem){
            item.ItemGroup__c = null;
            item.ImportItemGroupEAN__c = item.OrderId;
       }

       update lstOrderItem;

       List<Id> OrderId = new List<Id>();
       OrderId.add(lstOrder[0].id);
       Order_B2BOrderInvocable.UpdateOrderItemsfuture(OrderId);


       test.stoptest();
       

    }


    public static testmethod void ItemGroupSweeperQueueable2(){

        test.starttest();

        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Noordhoff',true,true);

        Set<String> Set_AccId = new Set<String>();
        for(Account acc:lstAccount){
            Set_AccId.add(acc.id);
        }

        AccountSubsidiary__c[] lstAccountSubsidiary = [Select id,Account__c from AccountSubsidiary__c where Account__c in:Set_AccId ];

        Map<String,String> Map_AccSub = new Map<String,String>();
        Integer i=0;
        for(AccountSubsidiary__c  sub:lstAccountSubsidiary){
            sub.NetsuiteInternalId__c = '12345'+i;
            Map_AccSub.put(sub.Account__c,sub.id);
            i++;
        }

        update lstAccountSubsidiary;
        
        List<Product2> lstProductItemGroup = TestDataFactory.insertProducts(5,false);
        List<Product2> lstProductItem = TestDataFactory.insertProducts(1,false);

        Integer ISBN = lstProductItemGroup.size()+1;
        
        i = 0;
        for(Product2 prod:lstProductItem){
            prod.ISBN__c = prod.ISBN__c + i;
            prod.EAN__c = prod.EAN__c + i;
            prod.itemGroupManualBlock__c = true;
            i++;
        }


        insert lstProductItem;
        insert lstProductItemGroup;


        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
 
        Pricebook2 PricebookCustom = TestDataFactory.insertPricebookCustom('Plantyn - All 2023');
 
        List<ProductComponent__c> lstProductComponent = Order_TestDataFactory.InsertGroupComponent(lstProductItem,lstProductItemGroup,true);

        Order_TestDataFactory.InsertPricing(lstProductItemGroup,null,true);
        Pricing__c[] lstPricing = Order_TestDataFactory.InsertPricing(lstProductItem,lstProductComponent,true);

        

        Pricing__c[] lstPricingComponent = Order_TestDataFactory.InsertPricingProductComponent(lstProductComponent,false);
        
      //  for(Pricing__c price:lstPricingComponent){
      //       price.ListRate__c =null;
      //   }
         insert lstPricingComponent;

        String OrderExternalId = 'Ext123';


        Pricing__c[] lstPricingCheck = [Select ProductComponent__r.Product__c from Pricing__c where ProductComponent__r.Product__c !=: null AND ProductComponent__r.MainProduct__c != null]; //where ProductComponent__r.Product__c !=: null

        system.debug('**Price check: lstPricingCheck**'+lstPricingCheck.size());


       PricebookEntry[] lstPricebookEntry = [Select id, Pricebook2.Name,Product2.ISBN__c, UnitPrice from PricebookEntry where Pricebook2.Name like: '%Plantyn%' ];

       
       for(PricebookEntry pbe:lstPricebookEntry){
            if(!pbe.Pricebook2.Name.contains('Standard')){
                PricebookCustom.id = pbe.Pricebook2Id;
            }
            system.debug('**Before Pricebook2.Name**'+pbe.Pricebook2.Name);
            system.debug('**Before Product2.ISBN**'+pbe.Product2.ISBN__c);
            system.debug('**Before UnitPrice**'+pbe.UnitPrice);
       }
      
       List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,PricebookCustom.id,true);
      
       List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,PricebookCustom.id,true);
       List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
       List<Order_ImportOrderItemGroupUpdate.Request> lst_request = new  List<Order_ImportOrderItemGroupUpdate.Request>();


       lstAccount = [Select NetsuiteInternalId__c from Account];
       List<ImportOrder__c> lstinsertImportOrder = Order_TestDataFactory.insertImportOrderOrder(lstAccount,false,OrderExternalId,'eCommerce B2B');
       lstinsertImportOrder[0].Status__c = 'Completed';
       insert lstinsertImportOrder;

       List<ImportOrder__c> lstinsertImportOrderItem = Order_TestDataFactory.insertImportOrderItem(lstProductItem,false,OrderExternalId,null,'eCommerce B2B');
       List<ImportOrder__c> lstinsertImportOrderItemGroup = Order_TestDataFactory.insertImportOrderItem(lstProductItemGroup,false,OrderExternalId,lstProductItem[0].EAN__c,'eCommerce B2B');
       lstinsertImportOrderItem.addAll(lstinsertImportOrderItemGroup);
       
       for(ImportOrder__c io : lstinsertImportOrderItem){
            io.Status__c = 'Completed';
            io.NetSalesPrice__c = 5;     
       }
       insert lstinsertImportOrderItem;


       lstOrderItems = [Select id,OrderId,Product2.EAN__c from OrderItem];
       for(OrderItem item:lstOrderItems){
        for(ImportOrder__c io : lstinsertImportOrderItem){
            if(io.ProductId__c == item.Product2.EAN__c){
                Order_ImportOrderItemGroupUpdate.Request request = new Order_ImportOrderItemGroupUpdate.Request();
                io.OrderProduct__c = item.id;
                io.Order__c = item.OrderId;
                item.ImportItemGroupEAN__c = item.OrderId;
                request.SingleOrderItems = item;
                request.ImportOrder = io;
                lst_request.add(request);
            }
     
        }
           
       }
       update lstinsertImportOrderItem;

       Order_ImportOrderItemGroupUpdate.OrderItemGroupUpdate(lst_request);

       OrderItem[] lstOrderItem = [Select ImportItemGroupEAN__c,ItemGroup__c,OrderId From orderItem];

       for(OrderItem item:lstOrderItem){
            item.ItemGroup__c = null;
            item.ImportItemGroupEAN__c = item.OrderId;
       }

       update lstOrderItem;


       List<Id> OrderId = new List<Id>();
       OrderId.add(lstOrder[0].id);
       System.enqueueJob(new Order_ItemGroupSweeperQueueable(OrderId,'Completed'));


       test.stoptest();
       

    }





/*
    public static testmethod void ItemGroupSweeperQueueable(){
        test.starttest();

        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Plantyn',true,true);

        Set<String> Set_AccId = new Set<String>();
        for(Account acc:lstAccount){
            Set_AccId.add(acc.id);
        }

        AccountSubsidiary__c[] lstAccountSubsidiary = [Select id,Account__c from AccountSubsidiary__c where Account__c in:Set_AccId ];

        Map<String,String> Map_AccSub = new Map<String,String>();
        Integer i=0;
        for(AccountSubsidiary__c  sub:lstAccountSubsidiary){
            sub.NetsuiteInternalId__c = '12345'+i;
            Map_AccSub.put(sub.Account__c,sub.id);
            i++;
        }

        update lstAccountSubsidiary;

        List<Product2> lstProductItemGroup = TestDataFactory.insertProducts(5,false);
        List<Product2> lstProductItem = TestDataFactory.insertProducts(1,false);

        Integer ISBN = lstProductItemGroup.size()+1;
        
        i = 0;
        for(Product2 prod:lstProductItem){
            prod.ISBN__c = prod.ISBN__c + i;
            //prod.itemGroupManualBlock__c = true;
            i++;
        }

       // lstProductItem[0].itemGroupManualBlock__c = true;



        insert lstProductItem;
        insert lstProductItemGroup;


        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
      //  List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProductItem,true);

        Pricebook2 PricebookCustom = TestDataFactory.insertPricebookCustom('Plantyn - All 2021');
       // lstPricebookEntry = TestDataFactory.insertPricebookEntry(PricebookCustom.id ,lstProductItem,true);

        List<ProductComponent__c> lstProductComponent = Order_TestDataFactory.InsertGroupComponent(lstProductItem,lstProductItemGroup,true);

        
        Order_TestDataFactory.InsertPricing(lstProductItemGroup,null,true);
        Pricing__c[] lstPricing = Order_TestDataFactory.InsertPricing(lstProductItem,lstProductComponent,true);

        Pricing__c[] lstPricingComponent = Order_TestDataFactory.InsertPricingProductComponent(lstProductComponent,true);
     
        String OrderExternalId = 'Ext123';


        Pricing__c[] lstPricingCheck = [Select ProductComponent__r.Product__c from Pricing__c ]; //where ProductComponent__r.Product__c !=: null

        system.debug('**Price check: lstPricingCheck**'+lstPricingCheck.size());


       PricebookEntry[] lstPricebookEntry = [Select id, Pricebook2.Name,Product2.ISBN__c, UnitPrice from PricebookEntry];


       for(PricebookEntry pbe:lstPricebookEntry){
            system.debug('**Before Pricebook2.Name**'+pbe.Pricebook2.Name);
            system.debug('**Before Product2.ISBN**'+pbe.Product2.ISBN__c);
           system.debug('**Before UnitPrice**'+pbe.UnitPrice);
       }



       system.debug('**Before Import Order**');
        lstAccount = [Select NetsuiteInternalId__c from Account];
       List<ImportOrder__c> lstinsertImportOrder = Order_TestDataFactory.insertImportOrderOrder(lstAccount,true,OrderExternalId,'eCommerce B2B');

       Order[] OrderImport = [Select id,Pricebook2.Name from Order];
       system.debug('**Before Import Item:size 1**'+OrderImport.size());
       system.debug('**Before Import Item 1**'+OrderImport[0].Pricebook2.Name);

       List<ImportOrder__c> lstinsertImportOrderItem = Order_TestDataFactory.insertImportOrderItem(lstProductItem,false,OrderExternalId,null,'eCommerce B2B');

       List<ImportOrder__c> lstinsertImportOrderItemGroup = Order_TestDataFactory.insertImportOrderItem(lstProductItemGroup,false,OrderExternalId,lstProductItem[0].ISBN__c,'eCommerce B2B');

       
       lstinsertImportOrderItem.addAll(lstinsertImportOrderItemGroup);
       for(ImportOrder__c io : lstinsertImportOrderItem){
       	    io.NetSalesPrice__c = 5; 
       }
       insert lstinsertImportOrderItem;


       OrderItem[] lstOrderItem = [Select ImportItemGroupEAN__c,ItemGroup__c From orderItem where OrderId =: OrderImport[0].id];

       for(OrderItem item:lstOrderItem){
            item.ItemGroup__c = null;
       }

       update lstOrderItem;

       List<Id> OrderId = new List<Id>();
       OrderId.add(OrderImport[0].id);
       Order_B2BOrderInvocable.UpdateOrderItemsfuture(OrderId);
       
       system.debug('**After Import 1**'+lstinsertImportOrderItem);
       test.stoptest();
    }




    public static testmethod void ItemGroupSweeperQueueable2(){
        test.starttest();

        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Plantyn',true,true);

        Set<String> Set_AccId = new Set<String>();
        for(Account acc:lstAccount){
            Set_AccId.add(acc.id);
        }

        AccountSubsidiary__c[] lstAccountSubsidiary = [Select id,Account__c from AccountSubsidiary__c where Account__c in:Set_AccId ];

        Map<String,String> Map_AccSub = new Map<String,String>();
        Integer i=0;
        for(AccountSubsidiary__c  sub:lstAccountSubsidiary){
            sub.NetsuiteInternalId__c = '12345'+i;
            Map_AccSub.put(sub.Account__c,sub.id);
            i++;
        }

        update lstAccountSubsidiary;

        List<Product2> lstProductItemGroup = TestDataFactory.insertProducts(5,false);
        List<Product2> lstProductItem = TestDataFactory.insertProducts(1,false);

        Integer ISBN = lstProductItemGroup.size()+1;
        
        i = 0;
        for(Product2 prod:lstProductItem){
            prod.ISBN__c = prod.ISBN__c + i;
            //prod.itemGroupManualBlock__c = true;
            i++;
        }


        insert lstProductItem;
        insert lstProductItemGroup;


        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();

        Pricebook2 PricebookCustom = TestDataFactory.insertPricebookCustom('Plantyn - All 2021');

        List<ProductComponent__c> lstProductComponent = Order_TestDataFactory.InsertGroupComponent(lstProductItem,lstProductItemGroup,true);

        
        Order_TestDataFactory.InsertPricing(lstProductItemGroup,null,true);
        Pricing__c[] lstPricing = Order_TestDataFactory.InsertPricing(lstProductItem,lstProductComponent,true);

        Pricing__c[] lstPricingComponent = Order_TestDataFactory.InsertPricingProductComponent(lstProductComponent,true);
     
        String OrderExternalId = 'Ext123';


        Pricing__c[] lstPricingCheck = [Select ProductComponent__r.Product__c from Pricing__c ]; //where ProductComponent__r.Product__c !=: null

        system.debug('**Price check: lstPricingCheck**'+lstPricingCheck.size());


       PricebookEntry[] lstPricebookEntry = [Select id, Pricebook2.Name,Product2.ISBN__c, UnitPrice from PricebookEntry];


       for(PricebookEntry pbe:lstPricebookEntry){
            system.debug('**Before Pricebook2.Name**'+pbe.Pricebook2.Name);
            system.debug('**Before Product2.ISBN**'+pbe.Product2.ISBN__c);
           system.debug('**Before UnitPrice**'+pbe.UnitPrice);
       }



       system.debug('**Before Import Order**');
        lstAccount = [Select NetsuiteInternalId__c from Account];
       List<ImportOrder__c> lstinsertImportOrder = Order_TestDataFactory.insertImportOrderOrder(lstAccount,true,OrderExternalId,'eCommerce B2B');

       Order[] OrderImport = [Select id,Pricebook2.Name from Order];
       system.debug('**Before Import Item:size 1**'+OrderImport.size());
       system.debug('**Before Import Item 1**'+OrderImport[0].Pricebook2.Name);

       List<ImportOrder__c> lstinsertImportOrderItem = Order_TestDataFactory.insertImportOrderItem(lstProductItem,false,OrderExternalId,null,'eCommerce B2B');

       List<ImportOrder__c> lstinsertImportOrderItemGroup = Order_TestDataFactory.insertImportOrderItem(lstProductItemGroup,false,OrderExternalId,lstProductItem[0].ISBN__c,'eCommerce B2B');

       
       lstinsertImportOrderItem.addAll(lstinsertImportOrderItemGroup);
       for(ImportOrder__c io : lstinsertImportOrderItem){
       	    io.NetSalesPrice__c = 5; 
       }
       insert lstinsertImportOrderItem;


       OrderItem[] lstOrderItem = [Select ImportItemGroupEAN__c,ItemGroup__c From orderItem where OrderId =: OrderImport[0].id];

       for(OrderItem item:lstOrderItem){
            item.ItemGroup__c = null;
       }

       update lstOrderItem;

       List<Id> OrderId = new List<Id>();
       OrderId.add(OrderImport[0].id);
       System.enqueueJob(new Order_ItemGroupSweeperQueueable(OrderId,'Completed'));
    
       
       system.debug('**After Import 1**'+lstinsertImportOrderItem);
       test.stoptest();
    }
*/





}