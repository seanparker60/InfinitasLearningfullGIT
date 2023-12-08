public with sharing class Order_OrderActivateQueueHandler implements Queueable,Database.AllowsCallouts {
    
    Private  Set<String> Set_QOrderId;
    Private  String Qchecked;
    Public  String checked;
    Public String Status;
    Private  Set<String> Set_Checked;

    public Order_OrderActivateQueueHandler(Set<String> Set_QOrderId,String Qchecked,String Status,Set<String> Set_Checked) {
        this.Set_QOrderId = Set_QOrderId;
        this.Qchecked = Qchecked;
        this.Status =  Status;
        this.Set_Checked = Set_Checked;
    }

    public void execute(System.QueueableContext qc) {
       
        string response;
        if(Status == 'Activated'){
            //response = Order_OrderActivateRESTAPI.OrderActivateRESTAPI(Set_QOrderId);
            response = Order_OrderActivateRESTAPI.IntegrateOrders(Set_QOrderId);
        }
       
        system.System.debug('**response out**'+response);

        if( Status != 'Activated' || response == null || response.contains('NA') || (response != null && response.contains('failed'))){
            
            system.System.debug('**response In**'+response);
            checknextOrder(Qchecked,Set_Checked);
        }

        

    }    

    public static void checknextOrder(String checked,Set<String> Set_Checked){

                OrderLineItemMaxCount__mdt[] OrderLineItemMaxCount;
       
               if(test.isrunningtest()){
                   OrderLineItemMaxCount = [Select Count__c from OrderLineItemMaxCount__mdt where MasterLabel='TestCount'];
               }
               else{
                   OrderLineItemMaxCount = [Select Count__c from OrderLineItemMaxCount__mdt where MasterLabel='LiveCount'];
               }
   
               Decimal FIXEDLINECOUNT;
               FIXEDLINECOUNT =  OrderLineItemMaxCount[0].Count__c;
               
               Order[] nextOrder = [SELECT Id,Billto__c,Source__c,ValidateB2BLineCountError__c FROM Order where id not in: Set_Checked AND id !=:checked AND  ActivateforBatchProcessing__c =:true AND ValidateB2BLineCountError__c=:0 AND  LineCount__c <=: FIXEDLINECOUNT  and Status !=: 'Activated' AND  Status !=: 'Cancelled' and ValidationErrorsOrder__c =:0 and ValidationErrorsOrderProducts__c =:0 and LineCount__c >:0 Order by LineCount__c ASC limit 1];
               
               
               system.debug('**Order Created:Set_checked'+checked);
                system.debug('**Order Created:nextOrder'+nextOrder.size());

                Set<String> Set_OrderId = new Set<String>();
                String CurOrder; 

                for(Order ord:nextOrder){
                   
                        Set_OrderId.add(ord.Id);
                        checked = ord.id;
                }

                system.debug('**Order Created: 1'+Set_OrderId);
        
               
                OrderItem[] lstOrdeItems = [Select id,Asset__c,OrderId from OrderItem where OrderId in: Set_OrderId ];
                

                Set_OrderId = new Set<String>();
                
                for (OrderItem item:lstOrdeItems) {
                    Set_OrderId.add(item.OrderId);
                    CurOrder = item.OrderId;
                }
                system.debug('**Order Created: 2'+Set_OrderId);
                
                
                if( Set_OrderId.size()>0){    
                    
                    if((checked == null || CurOrder != null) && nextOrder.size()>0){
                        Set_checked.Add(checked);
                        if(!test.isRunningTest()){
                            System.enqueueJob(new Order_OrderActivateQueueHandler(Set_OrderId,checked,'Activated',Set_Checked));
                        }
  
                    }
                    
                } 
                else if((checked == null || CurOrder == null) && nextOrder.size()>0 ){
                    Set_checked.Add(checked);
                    if(!test.isRunningTest()){
                        System.enqueueJob(new Order_OrderActivateQueueHandler(null,checked,'Failed',Set_Checked));
                    }    
                }   
                
    }

}