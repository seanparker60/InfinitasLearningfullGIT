public with sharing class Order_RelatedOrderProcess {
    
    public class Request{ 
        @invocablevariable Public String ProcessToRun; 
        @invocablevariable Public String MaxOrderLineId;
    }
    public class Response{ 
        @invocablevariable Public Boolean Status;
    }

    
    @invocablemethod
    public static void RelatedOrderProcess(List<Request> req){
        
        List<Id> MaxOrderLineId = new List<Id>();
        MaxOrderLineId.add(req[0].MaxOrderLineId);

        if(req[0].ProcessToRun =='TriggerBusinessRules'){
            RelatedOrderProcessIvocable(MaxOrderLineId);
        }
        else if(req[0].ProcessToRun =='ActivateOrders'){
            activateOrders(MaxOrderLineId);
        }
        
 
    }

    /*
    @invocablemethod
    public static void RelatedOrderProcess(List<Id> MaxOrderLineId){
        RelatedOrderProcessIvocable(MaxOrderLineId);
    }
    */

    @future
    public static void RelatedOrderProcessIvocable(List<Id> MaxOrderLineId){
        MaxOrderLine__c[] lstMaxOrderLine = [Select id,ActivationReadyCount__c,ExpectedActivationCount__c,	TriggerBusinessRules__c from MaxOrderLine__c where id in: MaxOrderLineId]; 

                
        Order[] lst_Order = Order_OrderandOrdeItemHandler.returnQueryOrder(null, MaxOrderLineId); 
       
        try{
                List<Id> Lst_OrdId = new List<Id>();

                for(Order ord:lst_Order){
                    Lst_OrdId.add(ord.id);
                }

                OrderItem[]   lst_OrdItem = Order_OrderandOrdeItemHandler.returnQueryOrderItems(null,Lst_OrdId);

                //LIST PRICE DISCOUNT
                Set<String> Set_CusDiscountGroup = new Set<String>();
                Set<String> Set_OperatingCo = new Set<String>();
                Set<String> Set_ProdDiscountGroup = new Set<String>();
                Set<String> Set_OrderLineItemType = new Set<String>();
                Set<String> Set_MarketSegment = new Set<String>();

                for(OrderItem item:lst_OrdItem){
                    Set_CusDiscountGroup.add(item.Order.Billto__r.CustomerDiscountGroup__c); 
                    Set_OperatingCo.add(item.Order.Billto__r.OperatingCompany__c);
                    Set_ProdDiscountGroup.add(item.Product2.ProductDiscountGroup__c);
                    Set_OrderLineItemType.add(item.OrderLineType__c);
                    Set_MarketSegment.add(item.Product2.MarketSegment__c);
                }
                
                ListPriceDiscount__c[] lst_ListPriceDiscountRegular = Order_OrderandOrdeItemHandler.returnListPriceDiscount(lst_Order, Set_CusDiscountGroup, Set_OperatingCo, Set_ProdDiscountGroup, Set_OrderLineItemType, Set_MarketSegment);
                Order_OrderandOrdeItemHandler.OrderItemBusinessLogichandler(lst_OrdItem,lst_Order,Lst_OrdId, 'TriggerBusinessRules',lst_ListPriceDiscountRegular, null);
                
                List<Order> lstInsertedOrd = [Select ValidationErrorsOrder__c,ValidationErrorsOrderProducts__c from Order where id in: Lst_OrdId];
                    
                    Integer Count=0, ActiveReady=0;
                    for(Order ord:lstInsertedOrd){

                        if(ord.ValidationErrorsOrder__c==0 && ord.ValidationErrorsOrderProducts__c==0){
                            ActiveReady++;
                        }
                        
                        Count++;
                    }
                    lstMaxOrderLine[0].ActivationReadyCount__c = ActiveReady;
                    lstMaxOrderLine[0].ExpectedActivationCount__c = Count;
                    lstMaxOrderLine[0].TriggerBusinessRules__c = false;
                    Update lstMaxOrderLine;
        }
        catch(exception e){
            HandleCustomException.LogException(e,lst_Order[0].id);
        }
            /*
            lstMaxOrderLine = [Select id,RelatedOrderActivationready__c from MaxOrderLine__c where id in: MaxOrderLineId];             

            if(lstMaxOrderLine[0].RelatedOrderActivationready__c ==True){
                activateOrders(MaxOrderLineId);
            }
            */
            
        



    }

    
    public static void activateOrders(List<Id> MaxOrderLineId){
        MaxOrderLine__c[] lstMaxOrderLine = [Select id,RelatedOrderActivationready__c from MaxOrderLine__c where id in: MaxOrderLineId]; 
        Order[] lst_Order = Order_OrderandOrdeItemHandler.returnQueryOrder(null, MaxOrderLineId); 

        try{ 
            for(Order ord:lst_Order){
                ord.ActivateforBatchProcessing__c =true;
            }

            update lst_Order;
        }
        catch(exception e){

            HandleCustomException.LogException(e,lst_Order[0].id);
        }

        if(lstMaxOrderLine[0].RelatedOrderActivationready__c ==True){
            Order_BatchOrderActivateAssetRenewal  orderActivate = new Order_BatchOrderActivateAssetRenewal();
            database.executebatch(orderActivate ,1);
        }
    }
}