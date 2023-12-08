public with sharing class Order_ActivateAPISendOrderItems {
    
    Public static boolean lockActivateAPISendOrderItems;

    @invocablemethod
    public static void UpdateOrderItems (List<Id> OrderId){
        if(lockActivateAPISendOrderItems != true){
            UpdateOrderItemsfuture (OrderId);
        }
        
    }
    
  //  @future
    public static void UpdateOrderItemsfuture (List<Id> OrderId){    
        
        //Possible delete -- API triggers are not happening in the class anymore.

        system.debug('**UpdateOrderItemsfuture: OrderId**'+OrderId);

        lockActivateAPISendOrderItems = true;

        OrderItem[] lst_OrdItem = [Select id,Order.Status,OrderStatus__c,OrderId from OrderItem where OrderId in: OrderId Order by id ASC];

        List<Id> Set_ItemId = new List<Id>();
        List<Id> Set_OrdId = new List<Id>();
        Set<String> Set_CurrentStatus = new Set<String>();

        for(OrderItem item:lst_OrdItem){
             Set_OrdId.add(item.OrderId);
          //  Set_ItemId.add(item.id);
          //  Set_CurrentStatus.add(item.Order.Status);
            item.OrderStatus__c = 'Activated'; //item.Order.Status;            
        }

        
        
        try{
            
            update lst_OrdItem;
            
            if(Test.isRunningTest() && UTIL_TestClassExceptions.TESTCLASSEXCEPTION==True)
			{

                CalloutException e = new CalloutException();
                e.setMessage('Error');
                throw e;        
			}
            //UTIL_TriggerController.OrderItemTriggerSwitch = false;
            /*
            if(Set_CurrentStatus.contains('Activated')){
            
                //  UTIL_TriggerController.OrderItemTriggerSwitch = false;
                 // Order_AssetsCreateOnOrderActivation.processAssetsFromOrder(Set_OrdId);
                 // bg_AllObjectInvocableHandler.AllObjectInvocableHandler(Set_ItemId);
          
            }
            */

        }
        catch(exception e){

            system.debug('**UpdateOrderItemsfuture: Error: getmessage**'+e.getmessage());
            HandleCustomException.LogException(e,lst_OrdItem[0].id);
        }
        

    }    
}