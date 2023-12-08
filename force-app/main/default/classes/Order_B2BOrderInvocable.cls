public with sharing class Order_B2BOrderInvocable {
  

    @invocablemethod
    public static void UpdateOrderItems (List<Id> OrderId){
        UpdateOrderItemsfuture (OrderId);
    }//  @future
    public static void UpdateOrderItemsfuture (List<Id> OrderId){    
        
        
        Map<String,String> Map_ShipToOrd = new Map<String,String>();
        List<String> lstOrderId = new List<String>();
        List<String> Lst_OrdId = new List<String>(); 
        Set<String> Set_Source = new Set<String>();
        Set<String> Set_Opco = new Set<String>();
        Set<String> ShiptoId = new Set<String>();
        String OrdShip;


        OrderItem[]   lst_OrdItem = Order_OrderandOrdeItemHandler.returnQueryOrderItems(null,OrderId);
        Order[] lst_Order = Order_OrderandOrdeItemHandler.returnQueryOrder(OrderId, null);

        


        for(Order ord:lst_Order){
            Lst_OrdId.add(ord.id);
            ShiptoId.add(ord.Billto__c);
            Set_Opco.add(ord.OperatingCompany__c);
            Set_Source.add(ord.Source__c);
           // OrderLineType = ord.Type;
        }
        
        for(OrderItem item:lst_OrdItem){
            ShiptoId.add(item.ShipToAccount__c);
            OrdShip = item.OrderId;
            OrdShip += item.ShipToAccount__c;
            Map_ShipToOrd.put(OrdShip,item.ShipToAccount__c);
            lstOrderId.add(item.OrderId);
            
         
        }

        OrderShipto__c[] existingShipto = [Select ShipToAccount__c,Order__c from OrderShipto__c where Order__c in: OrderId  ]; 
       
        Set<String> Set_ExistShip = new Set<String>();
        
        for(OrderShipto__c shipto:existingShipto){            
            OrdShip = shipto.Order__c;
            OrdShip += shipto.ShipToAccount__c;
            Set_ExistShip.add(OrdShip);
        }

        List<OrderShipto__c> lst_OrderShipto = new List<OrderShipto__c>();
        List<Map<String,String>> lst_AccSubMaps = new List<Map<String,String>>();
        
        lst_AccSubMaps =  Order_ProductSelectController.returnAccountSubsidiary(ShiptoId);

        Map<String,String> Map_Subsid = new Map<String,String>();
        Map<String,String> Map_Netsuite = new Map<String,String>(); 


        //Order_ProductSelectController.returnAccountSubsidiary(ShiptoId)[0];
        Map_Subsid =  lst_AccSubMaps[0];
        Map_Netsuite = lst_AccSubMaps[1];

        Map<String,String> Map_ShipToOrdChecker = new Map<String,String>();
        Set<String> Set_CusDiscountGroup = new Set<String>();
        Set<String> Set_OperatingCo = new Set<String>();
        Set<String> Set_ProdDiscountGroup = new Set<String>();
        Set<String> Set_OrderLineItemType = new Set<String>();
        Set<String> Set_MarketSegment = new Set<String>();
        
       // Map<String,Date> Map_FixedStartDate = new Map<String,Date>();
       // Map<String,Date> Map_FreeFromDate = new Map<String,Date>();
        Date FixedStartDate;
        Date FreeFromDate;
        Integer year;

        Boolean ItemGroupSweep = false;
        for(OrderItem item:lst_OrdItem){ 
             

            OrdShip = item.OrderId;
            OrdShip += item.ShipToAccount__c;


            //ADDED
            item.AccountSubsidiary__c = Map_Subsid.get(item.ShipToAccount__c);

            if(Map_ShipToOrdChecker.get(OrdShip)  == null && Map_ShipToOrd.get(OrdShip) != null && !Set_ExistShip.Contains(OrdShip) ){
                
                   OrderShipto__c Shipto = new OrderShipto__c();  
                    Shipto.Order__c  = item.OrderId; 
                    Shipto.ShiptoAccount__c = Map_ShipToOrd.get(OrdShip);         
                    lst_OrderShipto.add(Shipto);
                    Map_ShipToOrdChecker.put(OrdShip,item.ShipToAccount__c);
            }  
            
            //List Price Discount Filters
            Set_CusDiscountGroup.add(item.Order.Billto__r.CustomerDiscountGroup__c); 
            Set_OperatingCo.add(item.Order.Billto__r.OperatingCompany__c);
            Set_ProdDiscountGroup.add(item.Product2.ProductDiscountGroup__c);
            Set_OrderLineItemType.add(item.OrderLineType__c);
            
           // Set_MarketSegment.add(item.Product2.MarketSegment__c);

           /* Order date Item Calculations:

            if(item.Product2.FixedStartDate__c != null){
                year = item.Order.ShipbyDate__c.year();
                FixedStartDate = date.newinstance(year, item.Product2.FixedStartDate__c.month(), item.Product2.FixedStartDate__c.day());
                Map_FixedStartDate.put(item.OrderId,FixedStartDate);
                FreeFromDate = date.newinstance(system.today().year()+1, 1, 1);
                Map_FreeFromDate.put(item.OrderId,FreeFromDate);
            }
            system.debug('**B2B**:FreeFromDate 1'+ FreeFromDate);
            if(item.Product2.FreeFromDate__c != null && item.Product2.FixedStartDate__c != null){
                FreeFromDate = date.newinstance(system.today().year()+1, item.Product2.FreeFromDate__c.month(), item.Product2.FreeFromDate__c.day());
                Map_FreeFromDate.put(item.OrderId,FreeFromDate);
                if(item.Order.ShipbyDate__c < FreeFromDate && year>system.today().year()){
                    year -= 1;
                    FixedStartDate = date.newinstance(year, item.Product2.FixedStartDate__c.month(), item.Product2.FixedStartDate__c.day());                
                    Map_FixedStartDate.put(item.OrderId,FixedStartDate);
                }
                
            }
            */


            if(item.ImportItemGroupEAN__c != null && item.ItemGroup__c == null && item.ProductType__c != 'Item Group'){
                ItemGroupSweep = true;
            }
            
        }
	    
        

   if(Order_ItemGroupSweeperQueueable.ItemGroupCheckDone == null && ItemGroupSweep == true){
        system.debug('***ItemGroupSweeperQueueable 1**');
        System.enqueueJob(new Order_ItemGroupSweeperQueueable(OrderId,'Process'));
   }        
   else if(lst_OrdItem.size()>0 && ItemGroupSweep == false){      
   
  
    try{
        
        system.debug('***ItemGroupSweeperQueueable 10**'+Order_ItemGroupSweeperQueueable.ItemGroupCheckDone);
            Date CurDate = system.today();
           
            OrderActivationRules__mdt[] OrderActivationRules = [Select Source__c, Status__c,OperatingCompany__c from OrderActivationRules__mdt where Source__c in: Set_Source AND OperatingCompany__c in:Set_Opco];
                
            Map<String,String> Map_ActiveStatus = new Map<String,String>();

            String OpcoSource;
            for(OrderActivationRules__mdt act:OrderActivationRules){
                OpcoSource = act.OperatingCompany__c;
                OpcoSource += act.Source__c;
                Map_ActiveStatus.put(OpcoSource,act.Status__c);
            }
          
            system.debug('**OrderActivationRules**:Map_ActiveStatus'+ Map_ActiveStatus);

            OrderLineItemMaxCount__mdt[] OrderLineItemMaxCount;
       
            if(test.isrunningtest()){
                OrderLineItemMaxCount = [Select Count__c from OrderLineItemMaxCount__mdt where MasterLabel='TestCount'];
            }
            else{
                OrderLineItemMaxCount = [Select Count__c from OrderLineItemMaxCount__mdt where MasterLabel='LiveCount'];
            }

            //------ Order date Item Calculations: Moved here to get Date for Order before order is updated
			
            lst_OrdItem =Order_ProductCalculationDates.UpdateOrderItemDate(lst_OrdItem,lst_Order);		 
			
            //----

            Decimal FIXEDLINECOUNT;
            FIXEDLINECOUNT =  OrderLineItemMaxCount[0].Count__c;
            TriggerBusinessRules__mdt[] TriggerBusinessRules = [Select AutoRun__c,OrderRetries__c from TriggerBusinessRules__mdt];

            for(Order ord:lst_Order){
                
                if(ord.TriggerBusinessRulesRetries__c >= TriggerBusinessRules[0].OrderRetries__c ){
                    ord.TriggerBusinessRulesRetries__c =0;
                }
                else{
                    ord.TriggerBusinessRulesRetries__c = ord.TriggerBusinessRulesRetries__c + 1;
                }
                ord.AccountSubsidiary__c = Map_Subsid.get(ord.Billto__c);
                if(ord.PaymentMethod__c == null){
                    ord.PaymentMethod__c = ord.Billto__r.PaymentMethod__c;
                }
                ord.NetSuiteIdShiptoAccount__c = ord.Shipto__r.NetsuiteInternalId__c;
                ord.NetSuiteIdAccountSubsidiary__c = Map_Netsuite.get(ord.Billto__c); 
                ord.TriggerBusinessRules__c = false;

                system.debug('**B2B**:AccountSubsidiary'+ ord.AccountSubsidiary__c);
                system.debug('**B2B**:NetSuiteIdShiptoAccount'+ ord.NetSuiteIdShiptoAccount__c);
                system.debug('**B2B**:NetSuiteIdAccountSubsidiary'+ ord.NetSuiteIdAccountSubsidiary__c);

                if(ord.Source__c !='B2B Salesforce' ){ 
                   
                    OpcoSource = ord.OperatingCompany__c;
                    OpcoSource += ord.Source__c;

                    system.debug('**OrderActivationRules**:Status'+ Map_ActiveStatus.get(OpcoSource));

                    if(OrderActivationRules.size()>0 && Map_ActiveStatus.get(OpcoSource) == 'Active' && ord.LineCount__c <= FIXEDLINECOUNT){
                        ord.ActivateforBatchProcessing__c=true;
                    } 
                    else{
                        ord.ActivateforBatchProcessing__c=false;
                    } 
                    
                    if(ord.LineCount__c > FIXEDLINECOUNT){
                        ord.RelatedOrderActivationBlock__c =  true;
                    }
                }
               
                // if an order has missing email values, retriggering business rules should check if the account email fields have values - if so, use those values

                ord.BillingAddressNote__c = ord.Account.BillingAddressNotes__c; 
                ord.ShippingAddressNote__c = ord.Account.ShippingAddressNotes__c;

                
                
                if(ord.DigitalActivationEmail__c == null){
                    ord.DigitalActivationEmail__c = ord.Account.DigitalActivationEmail__c != null ? ord.Account.DigitalActivationEmail__c : '';
                }

                // use order's bill to invoice email
                if(ord.InvoiceEmail__c == null){
                    ord.InvoiceEmail__c = ord.Billto__r.InvoicingEmail__c != null ? ord.Billto__r.InvoicingEmail__c : '';
                } 
                if(ord.InvoiceEmail2__c == null){
                    ord.InvoiceEmail2__c = ord.Account.InvoiceEmail2__c != null ? ord.Account.InvoiceEmail2__c : '';
                } 
                //If Billing email is populated on Importer with the ship to it needs to change
                if(ord.BillingReminderEmail__c == null || ord.Billto__c !=  ord.AccountId){
                    ord.BillingReminderEmail__c = ord.Billto__r.BillingReminderEmail__c != null ? ord.Billto__r.BillingReminderEmail__c : '';
                }
                if(ord.BillingReminderEmail2__c == null || ord.Billto__c !=  ord.AccountId){
                    ord.BillingReminderEmail2__c = ord.Billto__r.BillingReminderEmail2__c != null ? ord.Billto__r.BillingReminderEmail2__c : '';
                } 
                system.debug('here');
                // use order's ship to order notification email
                if(ord.OrderNotificationEmail__c == null){
                    if(ord.Shipto__c != null){
                        ord.OrderNotificationEmail__c = ord.Shipto__r.OrderNotificationEmail__c;
                    } else {
                        ord.OrderNotificationEmail__c = ord.Account.OrderNotificationEmail__c;
                    }                    
                   
                }   
                
                if(ord.OrderNotificationEmail2__c != null){
                    // set OrderNotificationEmail2__c to null if it is the same as OrderNotificationEmail__c
                    if(ord.OrderNotificationEmail2__c == ord.OrderNotificationEmail__c){
                        ord.OrderNotificationEmail2__c = null;
                    }
                }
                system.debug('ord.OrderNotificationEmail2__c: ' + ord.OrderNotificationEmail2__c);
                
                /*
                Order date Item Calculations:
                if(ord.ShipbyDate__c > Map_FixedStartDate.get(ord.id) && ord.ShipbyDate__c  < Map_FreeFromDate.get(ord.id)){
                    ord.ShipbyDate__c = Map_FixedStartDate.get(ord.id)-1;   
                    ord.EffectiveDate = Map_FixedStartDate.get(ord.id)-1;  
                    
                    system.debug('*** Order STart Date**'+ord.EffectiveDate);
                }
                */
                //Order date Item Calculations:
                if(Order_ProductCalculationDates.Map_ShipByDate.size()>0){                             
                   
                    ord.EffectiveDate = Order_ProductCalculationDates.Map_EffectiveDate.get(ord.id);
                   
                    // ord.ShipByDate__c = Order_ProductCalculationDates.Map_ShipByDate.get(ord.id); 
                   // ord.DateUpdateBlock__c = true;    
                   
                   system.debug('***Dates :ord.ShipByDate'+ord.ShipByDate__c);
                    system.debug('***Dates :ord.EffectiveDate'+ord.EffectiveDate);
                }
                /*
                else if(ord.ShipbyDate__c > Map_FixedStartDate.get(ord.id) && ord.ShipbyDate__c  < Map_FreeFromDate.get(ord.id)){
                    ord.ShipbyDate__c = Map_FixedStartDate.get(ord.id)-1;                        	
                    ord.EffectiveDate = Map_FixedStartDate.get(ord.id)-1;  
                    ord.DateUpdateBlock__c = true;
                    system.debug('*** Order STart Date**'+ord.EffectiveDate);	            
                }
                */
                /*
                ord.DateUpdateBlock__c set to false in Order_OrderUtilityQueueable.UpdateOrderDates
                From Order_OrderItemTriggerQueueable
                */


            }
            
            update lst_Order;
            Insert lst_OrderShipto;
           

            ListPriceDiscount__c[] lst_ListPriceDiscountRegular = Order_OrderandOrdeItemHandler.returnListPriceDiscount(lst_Order, Set_CusDiscountGroup, Set_OperatingCo, Set_ProdDiscountGroup, Set_OrderLineItemType, Set_MarketSegment);
           system.debug('**LPD 1**'+lst_ListPriceDiscountRegular);

           Order_OrderandOrdeItemHandler.OrderItemBusinessLogichandler(lst_OrdItem,lst_Order,Lst_OrdId, 'TriggerBusinessRules',lst_ListPriceDiscountRegular, null);

           
        
            
            if(Test.isRunningTest() && UTIL_TestClassExceptions.TESTCLASSEXCEPTION==True){
                CalloutException e = new CalloutException();
                e.setMessage('Error');
                throw e;        
              }
        }
        catch(exception e){

            
            system.debug('**B2BOrderInv**: error: '+e.getmessage());
            HandleCustomException.LogException(e,lst_OrdItem[0].id);
        
        }
 
    }  


    }
   

}