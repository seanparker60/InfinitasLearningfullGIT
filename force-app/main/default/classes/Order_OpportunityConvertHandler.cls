public with sharing class Order_OpportunityConvertHandler {
   

    public class Request{ 
        @invocablevariable Public List<OrderItem> lstSingleOrderItem;     
    }
    public class Response{ 
        @invocablevariable Public List<OrderItem> lstSingleOrderItem;
    }


    @invocablemethod
    public static List<Response> OpportunityConvertHandler(List<Request> req){

        Map<String,String> Map_OrderGroup = new Map<String,String>();
        
        system.debug('**Opp ItemGroup: 1**');
        OrderItem[] lstSingleOrderItem; 
        
        Set<String> Set_Id = new Set<string>();

        for(OrderItem item:req[0].lstSingleOrderItem){
            Set_Id.add(item.id);           
        }    

        lstSingleOrderItem = [Select id,ProductType__c,OpportunityProduct__c,OpportunityProduct__r.ItemGroupId__c,ItemGroup__c from OrderItem where id in: Set_Id ];

        for(OrderItem item:lstSingleOrderItem){
            if(item.ProductType__c =='Item Group'){
                Map_OrderGroup.put(item.OpportunityProduct__c,item.id);
            }
            system.debug('**Opp ItemGroup: 2**'+Map_OrderGroup);
        }

        system.debug('**Opp ItemGroup: 3**');


        for(OrderItem item:lstSingleOrderItem){

            system.debug('**Opp ItemGroup: 4**'+Map_OrderGroup.get(item.OpportunityProduct__r.ItemGroupId__c));

            if(Map_OrderGroup.get(item.OpportunityProduct__r.ItemGroupId__c) != null){
                item.ItemGroup__c = Map_OrderGroup.get(item.OpportunityProduct__r.ItemGroupId__c);
                item.ItemGroupId__c = Map_OrderGroup.get(item.OpportunityProduct__r.ItemGroupId__c);
            }
        }
        
        update lstSingleOrderItem;


        List<Response> responses = new List<Response>();
        Response res = new Response();

        res.lstSingleOrderItem = req[0].lstSingleOrderItem;

        responses.add(res);
        
        return responses;
    }

}