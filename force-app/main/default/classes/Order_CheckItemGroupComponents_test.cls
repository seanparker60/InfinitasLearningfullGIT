@Istest
public with sharing class Order_CheckItemGroupComponents_test {
    

    public static testmethod void Order_StructurediscountCalculation3(){
        test.startTest();

        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Noordhoff',true,true);
        
        List<Product2> lstProductItemGroup = TestDataFactory.insertProducts(3,true);
        List<Product2> lstProductItem = TestDataFactory.insertProducts(1,false);

        Integer x=0;
        for(Product2 prod:lstProductItem){
            if(x==0){
                prod.Renewal__c = 'Manual';
            }
            else{
                prod.Renewal__c = null;
            }
            x++;
        }
        insert lstProductItem;

        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();


        List<ProductComponent__c> lstProductComponent = Order_TestDataFactory.InsertGroupComponent(lstProductItem,lstProductItemGroup,true);
        
       
        List<PricebookEntry> lstPricebookEntryItemGroup = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProductItemGroup,true);
        List<PricebookEntry> lstPricebookEntryItem = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProductItem,true);
        lstPricebookEntryItemGroup.AddAll(lstPricebookEntryItem);
        
        //Fires Process Builder (Invocable method)
        Order_TestDataFactory.InsertPricing(lstProductItem,lstProductComponent,true);
        Order_TestDataFactory.InsertPricingProductComponent(lstProductComponent,true);

        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,true);

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

        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntryItemGroup,true);        
        List<OrderShipto__c> lst_OrderShipto = Order_TestDataFactory.insertOrderShipto(1,lstOrder, lstAccount,true);

        TestDataFactory.insertAsset(standardPricebook.id,lstProductItem,lstAccount, lstAccount,true);

        List<ListPriceDiscount__c> ListPriceDiscount = Order_TestDataFactory.insertListPriceDiscount(5,'Regular','Workbooks',true);
        Order_TestDataFactory.insertListPriceDiscount(1,'Inspection Copy','Workbooks',true);  
  

        List<String> ShiptoId = new List<String>(); 
        for(OrderShipto__c ord:lst_OrderShipto){
            ShiptoId.add(ord.Id); 
        }

        List<Id> lst_AccountId = new List<Id>();
        lst_AccountId.add(lstAccount[0].id);

        List<String> lst_ShipTo = new List<String>();
        for(Account acc:lstAccount){
            lst_ShipTo.add(acc.id);
        }
        

        
        
        Map<String,String> Map_itemGroup = new Map<String,String>();
        
        x=0;
        for(OrderItem item:lstOrderItems){
            Map_itemGroup.put(item.Product2Id ,item.id );

            //Add list price discounts
            for(ListPriceDiscount__c lpd:ListPriceDiscount){
                item.ListPriceDiscount__c = lpd.id;
            }
            item.ShipToAccount__c=lstAccount[0].id;
            item.OrderLineType__c ='Regular';
            

            if(x==0){
                item.ManualDiscount__c = 'Recurring Percentage';
                item.ManualDiscountPercent__c = 5;
            }
            else if(x==1){
                item.ManualDiscount__c = 'Recurring Amount';
                item.ManualDiscountValue__c = 5;
            }
            else{

            }
            
            x++;
        }    
    
        for(OrderItem item:lstOrderItems){            
            for(ProductComponent__c prod:lstProductComponent){
                 if(item.Product2Id == prod.Product__c && prod.MainProduct__c != null){
                    item.ItemGroup__c = Map_itemGroup.get(prod.MainProduct__c);
                    item.ProductType__c = 'Inventory Item';
                 }
                 else{
                    item.DiscountedPriceItemGroup__c = item.quantity * 100;
                    item.ListPriceItemGroup__c = item.quantity * 123;
                    item.NetSalesPriceItemGroup__c =   item.quantity * 100;
                    item.ProductType__c = 'Item Group';
                }         
            } 
        }

        update lstOrderItems;

       
        
        
        
        for(Order ord:lstOrder){
            ord.ActivateforBatchProcessing__c =true;
            ord.NetSuiteIdShiptoAccount__c = '887760';
            ord.NetSuiteIdAccountSubsidiary__c = Map_AccSub.get(ord.Billto__c); 
            ord.AccountSubsidiary__c = Map_AccSub.get(ord.Billto__c);
           // ord.OrderStatus__c = 'Activated';
        }

        update lstOrder;


        OrderItem[] lstItemGroups = [Select id from OrderItem where  ProductType__c = 'Item Group' limit 1 ];
        delete lstItemGroups;

        List<Id> OrderId = new List<Id>();
        OrderId.add(lstOrder[0].id);
        Order_CheckItemGroupComponents.CheckItemGroupComponents(OrderId);


           test.stopTest();
    }    

}