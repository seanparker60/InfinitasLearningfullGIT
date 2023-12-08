public with sharing class Order_IntegrationOrderItemsFromOrder {
    

    //Possible delete: Being Managed by Order Activate Queable job

    Public static boolean lockActivateAPISendOrderItems;

    @invocablemethod
    public static void UpdateOrderItems (List<Id> OrderId){
        if(lockActivateAPISendOrderItems != true){
            UpdateOrderItemsfuture (OrderId);
        }
        
    }
    
    @future
    public static void UpdateOrderItemsfuture (List<Id> OrderId){    
        
        lockActivateAPISendOrderItems = true;

        OrderItem[] lst_OrdItem = [Select IntegrationFactorySend__c from OrderItem where OrderId in: OrderId];

        List<Id> Set_ItemId = new List<Id>();
        for(OrderItem item:lst_OrdItem){
            Set_ItemId.add(item.id);
            //item.IntegrationFactorySend__c = true;            
        }

     //   bg_AllObjectInvocableHandler.AllObjectInvocableHandler(Set_ItemId);

       // update lst_OrdItem;

    }    


}