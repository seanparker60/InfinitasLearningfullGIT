@Istest
public with sharing class Order_OpportunityConvertHandler_test {

    public static testmethod void OpportunityConvertHandler(){

        test.startTest();
        
        
        //------------------

        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Plantyn',true,true);
        
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
        
        List<Opportunity> lstOpportunity =  TestDataFactory.insertOpportunityHeader(1,lstAccount,standardPricebook.id,false);
        
        for(Opportunity opp:lstOpportunity){
            opp.PricingMethod__c = 'OrderTotalAmount';
        }

        insert lstOpportunity;


        List<OpportunityLineItem> lstOpportunityItems = TestDataFactory.insertOpportunityItems(2,lstAccount,lstOpportunity, lstPricebookEntryItemGroup,true);
        
        Map<String,String> Map_itemGroup = new Map<String,String>();

        for(OpportunityLineItem prod:lstOpportunityItems){
            Map_itemGroup.put(prod.Product2Id,prod.id);
        }

        for(OpportunityLineItem item:lstOpportunityItems){  
            //  system.debug('**Ord_Prod_ItemGroup: 2**');          
              for(ProductComponent__c prod:lstProductComponent){
                 // system.debug('**Ord_Prod_ItemGroup: 3**');
                   if(item.Product2Id == prod.Product__c && prod.MainProduct__c != null){
                      item.ItemGroup__c = Map_itemGroup.get(prod.MainProduct__c);
                      item.ItemGroupId__c = Map_itemGroup.get(prod.MainProduct__c);
                   } 
                   else{
                          item.DiscountedPriceItemGroup__c = item.quantity * 100;
                          item.ListPriceItemGroup__c = item.quantity * 123;
                          item.NetSalesPriceItemGroup__c =   item.quantity * 100;
                   }          
              } 
          }
  
          update lstOpportunityItems;
       

        List<Id> lst_AccountId = new List<Id>();
        lst_AccountId.add(lstAccount[0].id);
 
        
        
        x=0;
        for(OrderItem item:lstOrderItems){
          // Map_itemGroup.put(item.Product2Id ,item.id );
            item.OpportunityProduct__c = Map_itemGroup.get(item.Product2Id);
            //Add list price discounts
            item.ShipToAccount__c=lstAccount[0].id;
            item.OrderLineType__c ='Inspection Copy';
        }    
        
        
        for(OrderItem item:lstOrderItems){  
          //  system.debug('**Ord_Prod_ItemGroup: 2**');          
            for(ProductComponent__c prod:lstProductComponent){
               // system.debug('**Ord_Prod_ItemGroup: 3**');
                 if(item.Product2Id == prod.Product__c && prod.MainProduct__c != null){
                   // item.ItemGroup__c = Map_itemGroup.get(prod.MainProduct__c);
                    
                 } 
                 else{
                        item.DiscountedPriceItemGroup__c = item.quantity * 100;
                        item.ListPriceItemGroup__c = item.quantity * 123;
                        item.NetSalesPriceItemGroup__c =   item.quantity * 100;
                        item.ProductType__c ='Item Group';
                 }          
            } 
        }

        update lstOrderItems;


        
        
        List<Order_OpportunityConvertHandler.Request> lstreq = new List<Order_OpportunityConvertHandler.Request>();
        Order_OpportunityConvertHandler.Request req = new Order_OpportunityConvertHandler.Request();
        req.lstSingleOrderItem = lstOrderItems;
        lstreq.add(req);
        Order_OpportunityConvertHandler.OpportunityConvertHandler(lstreq);


      test.stopTest();
    }


}