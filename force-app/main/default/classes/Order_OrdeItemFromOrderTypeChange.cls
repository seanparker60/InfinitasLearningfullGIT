public with sharing class Order_OrdeItemFromOrderTypeChange {
    public class Request{ 
        @invocablevariable Public String OrderId;
        @invocablevariable Public String OrderLineItemType;
    }  

    @invocablemethod
    Public static void UpdateOrderListPriceDiscountAll(List<Request> req){
          
        system.debug('**UpdateOrderListPriceDiscountAll2**');
        Order[] lst_Order = [Select EffectiveDate,ShipByDate__c,Pricebook2Id,Billto__r.PaymentMethod__c,
        PaymentMethod__c ,Billto__r.CustomerDiscountGroup__c,PricingMethod__c,Billto__c,
        Billto__r.OperatingCompany__c,ShippingCost__c,ShippingCostDomestic__c,ShippingCostNonDomestic__c
        from Order where id =: req[0].OrderId];

        List<String> Lst_OrdId = new List<String>();
        Set<String> ShiptoId = new Set<String>();

            for(Order ord:lst_Order){
                Lst_OrdId.add(ord.id);
                ShiptoId.add(ord.Billto__c);
            }

          /*  OrderLineItemType__c, */
            OrderItem[] lst_OrdItem;
            
            List<Id> lstOrdId = new List<Id>();
            lst_OrdId.add(req[0].OrderId);
            lst_OrdItem =   Order_OrderandOrdeItemHandler.returnQueryOrderItems(null,lst_OrdId); 

            system.debug('**UpdateOrderListPriceDiscountAll3**');
            Set<String> Set_CusDiscountGroup = new Set<String>();
            Set<String> Set_OperatingCo = new Set<String>();
            Set<String> Set_ProdDiscountGroup = new Set<String>();
            Set<String> Set_OrderLineItemType = new Set<String>();
            Set<String> Set_MarketSegment = new Set<String>();

            for(OrderItem item:lst_OrdItem){
                Set_CusDiscountGroup.add(item.Order.Billto__r.CustomerDiscountGroup__c); 
                Set_OperatingCo.add(item.Order.Billto__r.OperatingCompany__c);
                Set_ProdDiscountGroup.add(item.Product2.ProductDiscountGroup__c);
                
                Set_MarketSegment.add(item.Product2.MarketSegment__c);

                if(req[0].OrderLineItemType.contains('Service')){
                  
                    item.OrderLineType__c ='Service';
                    
                }
                else if(req[0].OrderLineItemType.contains('Free')){

                    item.OrderLineType__c ='Free';
                }
                else if(req[0].OrderLineItemType.contains('Regular')){

                    item.OrderLineType__c ='Regular';
                }


                Set_OrderLineItemType.add(item.OrderLineType__c);
            }    
            
            Date CurDate = system.today();
            ListPriceDiscount__c[] lst_ListPriceDiscountRegular = [Select Id,DiscountType__c,ProductDiscountGroup__c,Subsidiary__c,CustomerDiscountGroup__c,OrderLineType__c, MarketSegment__c,Rate__c,StartQuantity__c From ListPriceDiscount__c  
                                                                                                        where  EndDate__c >=:CurDate 
                                                                                                        AND StartDate__c  <=:CurDate
                                                                                                        AND CustomerDiscountGroup__c in: Set_CusDiscountGroup
                                                                                                        AND Subsidiary__c in: Set_OperatingCo 
                                                                                                        AND ProductDiscountGroup__c in: Set_ProdDiscountGroup 
                                                                                                        AND OrderLineType__c in: Set_OrderLineItemType  
                                                                                                        AND MarketSegment__c in: Set_MarketSegment    
                                                                                                        ORDER BY StartQuantity__c DESC];


           
            lst_OrdItem = Order_UpdateOrderListPriceDiscountAll.ProcessUpdate(Null,Lst_OrdId,Null,lst_OrdItem,lst_ListPriceDiscountRegular);


            system.debug('**UpdateOrderListPriceDiscountAll4:  '+req[0].OrderLineItemType);
            update lst_OrdItem;

             

    }
}