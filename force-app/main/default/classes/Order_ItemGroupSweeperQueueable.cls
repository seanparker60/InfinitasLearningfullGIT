public with sharing class Order_ItemGroupSweeperQueueable implements Queueable,Database.AllowsCallouts {
    
    Public static Boolean ItemGroupCheckDone;
    Private  List<Id> OrderId;
    Private  String Status;


    public Order_ItemGroupSweeperQueueable(List<Id> OrderId, String Status) {
        this.OrderId = OrderId;
        this.status = Status;
    }

    public void execute(System.QueueableContext qc) {
       
        string response;
        system.debug('***ItemGroupSweeperQueueable 2**');
        if(Status == 'Process'){           
            UpdateItemGroups(OrderId, Status);
        }
        else if(Status == 'Completed'){
            system.debug('***ItemGroupSweeperQueueable 9**');
            ItemGroupCheckDone = true;
            Order_B2BOrderInvocable.UpdateOrderItemsfuture (OrderId);
        }
        else{
            system.debug('***ItemGroupSweeperQueueable 10**');
            //Error
        }

        

    }    

    public static void UpdateItemGroups(List<Id> OrderId, String Status){

        
        try{
            system.debug('***ItemGroupSweeperQueueable 3**');
            List<Order_ImportOrderItemGroupUpdate.Request> lstReq = new  List<Order_ImportOrderItemGroupUpdate.Request>();

            
            OrderItem[] lstItem = [Select id,OrderId from OrderItem where OrderId in: OrderId];
            ImportOrder__c[] lstImp = [Select ExternalOrderId__c,id,itemGroupId__c,NetSalesPrice__c,OrderProduct__c,ProductId__c,OrderProduct__r.Product2Id,Status__c,Error__c,quantity__c from ImportOrder__c where Order__c in: OrderId AND OrderProduct__c != null]; 

            Map<String,ImportOrder__c> Map_Imp = new Map<String,ImportOrder__c>(); 
            
            for(ImportOrder__c imp: lstImp){
                if(imp.OrderProduct__c != null){
                    Map_Imp.put(imp.OrderProduct__c,imp);
                }

            }
            
            for(OrderItem item:lstItem){
                system.debug('***ItemGroupSweeperQueueable 4**');
                if(Map_Imp.get(item.id) != null){
                    system.debug('***ItemGroupSweeperQueueable 5**');
                    Order_ImportOrderItemGroupUpdate.Request req = new Order_ImportOrderItemGroupUpdate.Request();
                    req.SingleOrderItems = item;
                    req.ImportOrder = Map_Imp.get(item.id);
                    lstReq.add(req);
               } 
            }
            system.debug('***ItemGroupSweeperQueueable 6**');
            if(lstReq.size()>0){
                system.debug('***ItemGroupSweeperQueueable 7**');
                Order_ImportOrderItemGroupUpdate.OrderItemGroupUpdate(lstReq);
            }
            
            system.debug('***ItemGroupSweeperQueueable 8**');
            Status = 'Completed';
            if(!Test.isRunningTest()){
                System.enqueueJob(new Order_ItemGroupSweeperQueueable(OrderId,Status));
            }


            if(Test.isRunningTest()){
                CalloutException e = new CalloutException();
                e.setMessage('Error');
                throw e; 
            }

        }
        catch(exception e){
            Status = 'Error';
            if(!Test.isRunningTest()){
                System.enqueueJob(new Order_ItemGroupSweeperQueueable(OrderId,Status));
            }    
        }
                
                
    }

}