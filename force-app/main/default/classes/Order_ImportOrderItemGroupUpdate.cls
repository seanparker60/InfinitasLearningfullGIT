public with sharing class Order_ImportOrderItemGroupUpdate {
    
    public class Request{ 
        @invocablevariable Public OrderItem SingleOrderItems;
        @invocablevariable Public ImportOrder__c ImportOrder;
    }
    public class Response{ 
        @invocablevariable Public OrderItem SingleOrderItems;
        @invocablevariable Public ImportOrder__c ImportOrder; 
    }


   
    @invocablemethod
    public static List<Response> OrderItemGroupUpdate(List<Request> req){

        system.debug('**Item Group Update: GO**'+req.size());


        List<Response> responses = new List<Response>();
        Response res = new Response();
        List<OrderItem> ListOfOrderItems = new List<OrderItem>();
        List<OrderItem> FlowOrderItems = new List<OrderItem>();
        List<ImportOrder__c> FlowImportOrder = new List<ImportOrder__c>();
        List<ImportOrder__c> ListOfImportOrder = new List<ImportOrder__c>();
        Set<String> Set_OrderId = new Set<String>();
        Set<String> Set_OrderLineId = new Set<String>();

        Set<String> Set_ExternalOrderId = new Set<String>();
        Set<String> Set_ImportOrderId = new Set<String>();

        for(Request r:req){
            Set_OrderId.add(r.SingleOrderItems.OrderId);
            FlowOrderItems.add(r.SingleOrderItems);
            FlowImportOrder.add(r.ImportOrder);
            Set_OrderLineId.add(r.SingleOrderItems.id);
            Set_ExternalOrderId.add(r.ImportOrder.ExternalOrderId__c); 
            Set_ImportOrderId.add(r.ImportOrder.id);  
            system.debug('**Item Group Update:Order Product**'+r.ImportOrder.ProductId__c);        
            //

        }
        
        ListOfOrderItems = [Select id,ItemGroup__c,Product2Id,NetsuiteQuantity__c,Quantity,ProductComponent__c,ProductType__c,NetSalesPriceItemGroup__c,DiscountedPriceItemGroup__c,ListPriceItemGroup__c,ComponentListPrice__c,ManualDiscount__c,ManualDiscountPercent__c,ManualDiscountValue__c from OrderItem where OrderId in: Set_OrderId];
       // ListOfOrderItems.addAll(FlowOrderItems);
        
       /*
        for(OrderItem item:ListOfOrderItems){
            Set_OrderLineId.add(item.id);
        }
        */

        ListOfImportOrder = [Select id,itemGroupId__c,NetSalesPrice__c,OrderProduct__c,ProductId__c,OrderProduct__r.Product2Id,Status__c,Error__c,quantity__c From ImportOrder__c where ExternalOrderId__c in: Set_ExternalOrderId AND ProductId__c !=: null AND id not in: Set_ImportOrderId];
        ListOfImportOrder.addAll(FlowImportOrder);

        
      
        
        system.debug('**Item Group Update: Items Size**'+ListOfOrderItems.size());
        system.debug('**Item Group Update: Import**'+ListOfImportOrder.size());

        ListOfImportOrder = OrderSuccessorUpdate(ListOfOrderItems,ListOfImportOrder);
        
        

        for(ImportOrder__c item:ListOfImportOrder){
            system.debug('**Item Group Update: Return Status **'+item.Status__c);
            if(Set_ImportOrderId.contains(item.id)){
                res = new Response();
                res.SingleOrderItems = null; //item;
                res.ImportOrder = item;
                //  system.debug('**Item Group Update: 11**'+res.SingleOrderItems.PricebookEntryId);
                //  system.debug('**Item Group Update: 11BB**'+res.SingleOrderItems.Product2Id);
                responses.add(res);
                system.debug('**Item Group Update: Return**');
            }
            
        }

        
        return responses;
    }    


    public static List<ImportOrder__c> OrderSuccessorUpdate(List<OrderItem> ListOfOrderItems, List<ImportOrder__c> ListOfImportOrder){  
        
        Map<String,String> Map_ItemGroupId = new Map<String,String>();
        Map<String,String> Map_ItemId = new Map<String,String>();

        Map<String,String> Map_ImportId = new Map<String,String>();
        Map<String,String> Map_GroupProdId = new Map<String,String>();
        Set<String> Set_GroupId = new Set<String>();
        Set<String> Set_ProductId = new Set<String>();
        Set<String> Set_ItemId = new Set<String>();
        Set<String> Set_ItemPriceErrorId = new Set<String>();
        //Map<String,Decimal> Map_Quantity = new Map<String,Decimal>(); // commented out because of this devops item: https://dev.azure.com/infinitas/Converse/_workitems/edit/212385
        Map<String,Decimal> Map_ListPrice = new Map<String,Decimal>();
        Map<String,String> Map_ProductComponent = new Map<String,String>();
        Map<String,Decimal> Map_ManageQuantity = new Map<String,Decimal>();

        Map<String,String> Map_ManualDiscount = new Map<String,String>();
        Map<String,Decimal> Map_ManualDiscountPercent = new Map<String,Decimal>();
        Map<String,Decimal> Map_CustomNSPrice = new Map<String,Decimal>();

        for(ImportOrder__c imp:ListOfImportOrder){
            
            system.debug('**Item Group Update: 1:itemGroupId**'+imp.itemGroupId__c);
			system.debug('imp.quantity__c: ' + imp.quantity__c);
            
            if(imp.itemGroupId__c != null){
                Map_ItemId.put(imp.OrderProduct__c,imp.itemGroupId__c);
                Map_ManageQuantity.put(imp.OrderProduct__c,imp.quantity__c); 
                Map_CustomNSPrice.put(imp.OrderProduct__c,imp.NetSalesPrice__c);

                system.debug('**Item Group Update: Map:Map_ItemId**'+Map_ItemId);
            }
            else{

               
                Map_ImportId.put(imp.ProductId__c,imp.OrderProduct__c);
                system.debug('**Item Group Update: Map: Map_ImportId**'+Map_ImportId);
                system.debug('**Item Group Update: GroupComponentId:Product2Id**'+imp.OrderProduct__r.Product2Id);
            }
        }

        if(Map_ImportId.size()>0){

            Product2[] lstItemGroupProd = [Select id,EAN__c,ISBN__c from Product2 where (EAN__c in: Map_ImportId.keyset() OR ISBN__c in: Map_ImportId.keyset())];

            for(Product2 prod:lstItemGroupProd){
                if(prod.EAN__c != null){
                    Map_GroupProdId.put(prod.EAN__c,prod.Id);
                }
                if(prod.ISBN__c != null){
                    Map_GroupProdId.put(prod.ISBN__c,prod.Id);
                }

            }

            system.debug('**Item Group Update: GroupComponentId: Map_GroupProdI**'+ Map_GroupProdId);
        }
        
        for(OrderItem item: ListOfOrderItems){
           
            if(Map_ItemId.get(item.Id) != null){

                system.debug('**Item Group Update: 1:AllCheck**'+item.Id+'****'+Map_ItemId.get(item.Id)+'****');

                Map_ItemGroupId.put(item.id,Map_ImportId.get(Map_ItemId.get(item.Id)));
                Set_ItemId.add(item.id);
                Set_ProductId.add(item.Product2Id);

                //ItemGroupProductId+ProductComponent
                

                if(item.ManualDiscountPercent__c != null){
                    Map_ManualDiscount.put(Map_ImportId.get(Map_ItemId.get(item.Id)),item.ManualDiscount__c); 
                    Map_ManualDiscountPercent.put(Map_ImportId.get(Map_ItemId.get(item.Id)),item.ManualDiscountPercent__c);
                }

            } 
            else{
                
                Set_GroupId.add(item.Product2Id);
                if(item.ManualDiscountPercent__c != null){
                    Map_ManualDiscount.put(item.id,item.ManualDiscount__c); 
                    Map_ManualDiscountPercent.put(item.id,item.ManualDiscountPercent__c);
                }
                
            }          
        }

        system.debug('**Item Group Update: Set_GroupId**'+Set_GroupId);
        system.debug('**Item Group Update: Set_ProductId**'+Set_ProductId);

        Pricing__c[] lstPrice = [Select ListRate__c,ProductComponent__r.MainProduct__r.itemGroupManualBlock__c,ProductComponent__r.Product__r.Name,Product__c,EndDate__c,IsActive__c,ProductComponent__r.Quantity__c,ProductComponent__r.Type__c,ProductComponent__r.MainProduct__c,ProductComponent__r.Product__c from Pricing__c 
       // Where   ((ProductComponent__r.MainProduct__c in: Set_GroupId) OR (ProductComponent__r.Product__c in: Set_GroupId AND ProductComponent__r.MainProduct__c !=: null))
       Where   ((ProductComponent__r.Product__c in: Set_ProductId AND ProductComponent__r.MainProduct__c in: Set_GroupId))
        
       AND StartDate__c <=: system.today()
        AND EndDate__c >=: system.today()];
        

        system.debug('**Item Group Update: Price**'+lstPrice);
        
        Set<String> Set_ItemGroupBlock  = new Set<String>();

        String GroupComponentId;

        for(Pricing__c price:lstPrice){ 
            
            GroupComponentId = price.ProductComponent__r.MainProduct__c;
            GroupComponentId += price.ProductComponent__r.Product__c;
            system.debug('**Item Group Update: GroupComponentId1**'+GroupComponentId);
            system.debug('price.ProductComponent__r.Quantity__c: ' + price.ProductComponent__r.Quantity__c);
            //Map_Quantity.put(GroupComponentId,price.ProductComponent__r.Quantity__c); // commented out because of this devops item: https://dev.azure.com/infinitas/Converse/_workitems/edit/212385
            Map_ListPrice.put(GroupComponentId,price.ListRate__c);
            Map_ProductComponent.put(GroupComponentId,price.ProductComponent__c);

           // Map_Quantity.put(price.ProductComponent__r.Product__c,price.ProductComponent__r.Quantity__c);
           // Map_ListPrice.put(price.ProductComponent__r.Product__c,price.ListRate__c);
           // Map_ProductComponent.put(price.ProductComponent__r.Product__c,price.ProductComponent__c);
            
            
           system.debug('**Item Group Update: Price**'+price.id);


            if(price.ProductComponent__r.MainProduct__r.itemGroupManualBlock__c == true){
                Set_ItemGroupBlock.add(price.ProductComponent__r.MainProduct__c);
                Set_ItemGroupBlock.add(price.ProductComponent__r.Product__c);
            }
        } 
        
        

        if(Set_ItemId.size()>0){

            Set_GroupId = new Set<String>();
            system.debug('**Item Group Update: 1**'+Set_ItemId);
            Map<String,Decimal> Map_NetSalesPrice = new Map<String,Decimal>();

                    OrderItem[] lstItemGroupComponent = [Select id,UnitPrice,ListPrice,ProductType__c,ComponentListPrice__c,Product2Id,ItemGroupId__c,ManualDiscountPercent__c ,Quantity,NetsuiteQuantity__c,ManualDiscountValue__c,ManualDiscount__c from OrderItem where id in: Set_ItemId AND Product2Id not in: Set_ItemGroupBlock];

                    for(OrderItem item: lstItemGroupComponent){

                        system.debug('**Item Group Update: 2 before**'+Map_ItemGroupId +'**ID**'+ item.Id);
                        if(Map_ItemGroupId.get(item.Id) != null){

                            GroupComponentId = Map_GroupProdId.get(Map_ItemId.get(item.Id));
                            GroupComponentId +=  item.Product2Id;
                            system.debug('**Item Group Update: GroupComponentId2**'+GroupComponentId);

                            String ItemGroupId = Map_ItemGroupId.get(item.Id);

                            Set_GroupId.add(ItemGroupId);

                            item.ItemGroup__c = ItemGroupId;
                            item.DeliveryType__c='Wait for full delivery';                          
                            

                            //Only update item from current order import, otherwise it double counts
                           
                            // commented out because of this devops item: https://dev.azure.com/infinitas/Converse/_workitems/edit/212385
                                /*if(Map_Quantity.get(GroupComponentId) != null){

                                    if(Map_ManageQuantity.get(item.id) != null){
                                        item.NetsuiteQuantity__c = Map_Quantity.get(GroupComponentId) * Map_ManageQuantity.get(item.id);    
                                        item.Quantity = Map_Quantity.get(GroupComponentId) * Map_ManageQuantity.get(item.id);
                                        
                                        system.debug('Map_Quantity.get(GroupComponentId): ' + Map_Quantity.get(GroupComponentId) );
                                        system.debug('Map_ManageQuantity.get(item.id): ' + Map_ManageQuantity.get(item.id) ) ;
                                        system.debug('item.Quantity 1: ' + item.Quantity);
                                    }
                                    else{
                                        item.NetsuiteQuantity__c = Map_Quantity.get(GroupComponentId);    
                                        item.Quantity = Map_Quantity.get(GroupComponentId);
                                    }
                                    
                                }
                                else{
                                    item.NetsuiteQuantity__c = item.Quantity;  
                                }*/
                          
                             if(Map_CustomNSPrice.get(item.id) != null){                                
                                item.UnitPrice = Map_CustomNSPrice.get(item.id);
                             }   
                             else{
                                item.UnitPrice = Map_ListPrice.get(GroupComponentId);    
                             }

                            item.ComponentListPrice__c = Map_ListPrice.get(GroupComponentId);
                            item.ProductComponent__c = Map_ProductComponent.get(GroupComponentId);
                            

                            system.debug('**OrderGroupUpdate: 2 Prod**'+item.Product2Id +'**LP*'+item.ListPrice +'**Comp**'+ item.ComponentListPrice__c + '**Unit*'+item.UnitPrice );
                            
                            try {
                                if(item.ManualDiscount__c == 'One-Off Amount' || item.ComponentListPrice__c > item.UnitPrice){
                                    item.ManualDiscountValue__c = item.ComponentListPrice__c - item.UnitPrice;
                                    item.ManualDiscount__c = 'One-Off Amount';
                                }
                                
                                if(Map_ManualDiscount.get(ItemGroupId) != null){
                                    item.ManualDiscount__c = Map_ManualDiscount.get(ItemGroupId);
                                    item.ManualDiscountPercent__c = Map_ManualDiscountPercent.get(ItemGroupId);
                                    
                                    if(Map_CustomNSPrice.get(item.id) == null){
                                        item.UnitPrice = item.UnitPrice-(item.UnitPrice*(Item.ManualDiscountPercent__c/100));
                                    }
                                    
                                }
                                
                                // commented out because of this devops item: https://dev.azure.com/infinitas/Converse/_workitems/edit/212385
                                /*if(Map_NetSalesPrice.get(ItemGroupId)==null){
                                    Map_NetSalesPrice.put(ItemGroupId,item.UnitPrice * Map_Quantity.get(GroupComponentId));
                                    Map_ListPrice.put(ItemGroupId,item.ComponentListPrice__c * Map_Quantity.get(GroupComponentId));
                                    
                                }
                                else{
                                    Map_NetSalesPrice.put(ItemGroupId,Map_NetSalesPrice.get(ItemGroupId)+ (item.UnitPrice * Map_Quantity.get(GroupComponentId)));
                                    Map_ListPrice.put(ItemGroupId,Map_ListPrice.get(ItemGroupId)+ (item.ComponentListPrice__c * Map_Quantity.get(GroupComponentId)));
                                }*/
                                
                                
                                
                            } catch(Exception exc){
                                system.debug('****OrderGroupUpdate: 2 Prod Error**'+ exc.getMessage());
                                Set_ItemPriceErrorId.add(item.Id);
                            }
                            
                        }
   
                    }

                    OrderItem[] lstItemGroup = [Select id,UnitPrice,ManualDiscountPercent__c ,ManualDiscount__c,ProductType__c,FormGroupId__c,NetSalesPriceItemGroup__c,DiscountedPriceItemGroup__c,ListPriceItemGroup__c from OrderItem where id in: Set_GroupId AND product2Id not in: Set_ItemGroupBlock];

                    for(OrderItem item:lstItemGroup){
                                item.UnitPrice = 0;
                                item.ProductType__c = 'Item Group';
                                item.NetSalesPriceItemGroup__c = Map_NetSalesPrice.get(item.id);
                                item.DiscountedPriceItemGroup__c = Map_ListPrice.get(item.id);
                                item.ListPriceItemGroup__c = Map_ListPrice.get(item.id);
                                item.ComponentListPrice__c = 0;
                                item.FormGroupId__c = item.id;

                                item.ManualDiscount__c = '';
                                item.ManualDiscountPercent__c = null;

                                system.debug('**Item Group Update:Item Group: NetSalesPriceItemGroup**'+item.NetSalesPriceItemGroup__c);
                                system.debug('**Item Group Update:Item Group : DiscountedPriceItemGroup**'+item.DiscountedPriceItemGroup__c);
                                system.debug('**Item Group Update:Item Group : ListPriceItemGroup**'+item.ListPriceItemGroup__c);
                                
                    }



                    try{
                        if(Set_ItemPriceErrorId.size() > 0){
                            OrderItem[] lstItemBadPrices = [Select id from OrderItem where id in: Set_ItemPriceErrorId];
                            
                            // remove item from lstItemGroupComponent
                            for(OrderItem oi : lstItemBadPrices){
                                Integer count = 0;
                                
                                while(count < lstItemGroupComponent.size()){
                                    if(oi.Id == lstItemGroupComponent[count].Id){
                                        lstItemGroupComponent.remove(count);
                                    } else {
                                        count++;
                                    }
                                }
                            }
                            
                            for(ImportOrder__c imp:ListOfImportOrder){
                                if(Set_ItemPriceErrorId.contains(imp.OrderProduct__c)){
                                    imp.Error__c = 'No active prices for current period. Check dates on price record';
                                    imp.Status__c = 'Error';
                                    imp.Order__c = null;
                                }
                                
                                system.debug('**Set_ItemPriceErrorId -- Item Group Update: imp.OrderProduct__c **'+imp.Status__c);
                            }
                            
                            delete lstItemBadPrices;
                        }
                        
                    if(lstItemGroup.size()>0){

                        system.debug('**OrderItemUpdate: Update1 **');
                        update lstItemGroupComponent;
                        system.debug('**OrderItemUpdate: Update2 **');
                        update lstItemGroup;
                    }

                    system.debug('**Item Group Update: Set_ItemGroupBlock **'+Set_ItemGroupBlock);
                    system.debug('**Item Group Update: Set_ItemId **'+ Set_ItemId);
                        
                    if(Set_ItemGroupBlock.size()>0 || Test.isRunningTest()){                       
                            
                        OrderItem[] lstItemGroupBlock = [Select id from OrderItem where (id in: Set_GroupId OR id in: Set_ItemId)  AND  product2Id in: Set_ItemGroupBlock];
                            
                            Set_ItemId = new Set<String>();
                            for(OrderItem item:lstItemGroupBlock){
                                Set_ItemId.add(item.id);
                            }

                            for(ImportOrder__c imp:ListOfImportOrder){

                                
                                if(Set_ItemId.contains(imp.OrderProduct__c)){
                                    imp.Error__c = 'This Item Group is missing Components in Salesforce';
                                    imp.Status__c = 'Error';                                   
                                }

                                system.debug('**Item Group Update: imp.OrderProduct__c **'+imp.Status__c);
                            }


                            delete lstItemGroupBlock;

                    }
                } 
                catch(exception e){
                    system.debug('**ItemGroupUpdate Error**'+ e.getMessage());
                }
        }        

        return ListOfImportOrder;

    }    

}