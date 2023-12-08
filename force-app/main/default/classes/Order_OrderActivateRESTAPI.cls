@RestResource(urlMapping='/Order/*')
global with sharing class Order_OrderActivateRESTAPI {
    
    @HttpPost
    global static String doPost(String OrdId) {
        
        Order[] lstOrder = [Select id,Billto__c,MaxOrderLine__c,MaxOrderLine__r.RelatedOrderActivationready__c,AccountId,status,ActivateforBatchProcessing__c,RelatedOrderActivationBlock__c,ValidateIGComponentMismatch__c from Order where Id =: OrdId];
        
        //String resp='Success';

        String resp='NA';
        
        
        try{
            
            OrderItem[] lst_OrdItem = [Select id,Order.Status,OrderStatus__c,OrderId from OrderItem where OrderId =: OrdId];

            system.debug('**Ready To Activate**'+lstOrder[0].MaxOrderLine__r.RelatedOrderActivationready__c);

            if(lstOrder[0].MaxOrderLine__r.RelatedOrderActivationready__c == true || lstOrder[0].MaxOrderLine__c == null){    
                for(OrderItem item:lst_OrdItem){
                    item.OrderStatus__c = 'Activated';            
                }
                update lst_OrdItem;
                lstOrder[0].RelatedOrderActivationBlock__c = false;
                lstOrder[0].status='Activated';
                resp='Success';

                if(lstOrder[0].MaxOrderLine__c != null){
                    MaxOrderLine__c[] lstMaxOrderLine =[Select id,OrdersActivated__c,ExpectedActivationCount__c,ActivationStart__c,ActivationMessage__c,CheckActivationProcessing__c from MaxOrderLine__c Where id =: lstOrder[0].MaxOrderLine__c]; 
                    
                    if(lstMaxOrderLine[0].OrdersActivated__c == 0 || lstMaxOrderLine[0].OrdersActivated__c == null){
                        lstMaxOrderLine[0].ActivationStart__c = system.now();
                    }
                    if(lstMaxOrderLine[0].OrdersActivated__c == null){
                        lstMaxOrderLine[0].OrdersActivated__c = 1;
                    }
                    else{
                        lstMaxOrderLine[0].OrdersActivated__c += 1;
                    }
                    

                    if(lstMaxOrderLine[0].OrdersActivated__c == lstMaxOrderLine[0].ExpectedActivationCount__c){
                        lstMaxOrderLine[0].ActivationMessage__c =  'All orders Activated';
                    }
                    else{
                        lstMaxOrderLine[0].ActivationMessage__c = 'Processing Activations';
                    }          
                    
                    lstMaxOrderLine[0].ActivationProblem__c = false;
                    lstMaxOrderLine[0].CheckActivationProcessing__c =  true;

                    update lstMaxOrderLine;
                } 
                
                
            }    
           //lstOrder[0].ActivateforBatchProcessing__c=false;



            update lstOrder;
            
            // Until winter release 2024
            lstOrder = [Select id,Billto__c,MaxOrderLine__c,MaxOrderLine__r.RelatedOrderActivationready__c,AccountId,status,ActivateforBatchProcessing__c,RelatedOrderActivationBlock__c,ValidateIGComponentMismatch__c from Order where Id =: OrdId];
            if(lstOrder[0].ValidateIGComponentMismatch__c == true){
                resp = 'failed';
            }
            

            system.debug('**Ready To Activate: res**'+resp);

            
        }
        catch(exception e){

            resp=e.getmessage();
            system.debug('**Order Activation: Error**'+e.getmessage());

            /* For winter release 2024
            if(resp.contains('Item group')){
                lstOrder[0].ValidateIGComponentMismatch__c = true;
                lstOrder[0].status='Draft';
                Update lstOrder;
            }
            */
        }

        return resp;
    }

    
    public static String IntegrateOrders(Set<String> Set_OrderId){

        JSONParser parser;
        HttpResponse res1;
        
        String accessToken,endPoint,DMLType,reqbody,objbody;
        String OrderId;
        for(String oid:Set_OrderId){
            OrderId = oid;
        }

        DMLType = 'POST';
        endPoint= URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/Order/'; //'https://CS128.salesforce.com
        accessToken= userinfo.getSessionId();
        reqbody =     '{"OrdId" : "'+OrderId+'"}';


        Http h2 = new Http();
        HttpRequest req1 = new HttpRequest();
        req1.setHeader('Authorization','Bearer ' + accessToken);
        req1.setHeader('Content-Type','application/json');
        req1.setHeader('accept','application/json');
        req1.setTimeout(120000);   
     
        system.debug('**reqbody**'+reqbody);
        system.debug('**DMLType**'+DMLType);
        system.debug('**endPoint**'+endPoint);

        req1.setEndpoint(endPoint);
        req1.setBody(reqbody);
        req1.setMethod(DMLType);

        string result;
        if(!Test.isRunningTest()){
            res1 = h2.send(req1);
            result = res1.getbody();
        }
        else{
            result = 'failed';
        }
        
        
        system.debug('**result*'+result);

        if(result.contains('failed')){

            ErrorLog__c errorLog = new ErrorLog__c();
            errorLog.Errororigin__c = 'Apex';
            errorLog.RelatedToId__c = OrderId;
            errorLog.ExceptionMessage__c = result;
            errorLog.ExceptionType__c = 'API Order Activation';
            database.insert(errorLog);
        }

        return result;
    }

    
}