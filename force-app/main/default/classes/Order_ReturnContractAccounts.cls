public with sharing class Order_ReturnContractAccounts {
    
    public class Request{ 
        @invocablevariable Public String RecordId; 

        @invocablevariable Public Account BilltoAccount; 
        @invocablevariable Public String PricebookId; 
        @invocablevariable Public String RequestType;
        @invocablevariable Public Boolean MultipleShipto;

    }
    public class Response{ 
        @invocablevariable Public List<Account> ListOfAccounts;
        @invocablevariable Public Decimal AccountListSize;          
    }


   
    @invocablemethod
    public static List<Response> ContractAccounts(List<Request> req){

        List<Response> responses;

        
        try {

            responses = processContractAccounts(req);
            if(Test.isRunningTest() && UTIL_TestClassExceptions.TESTCLASSEXCEPTION==True){
                CalloutException e = new CalloutException();
                e.setMessage('Error');
                throw e;        
              }
                
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            HandleCustomException.LogException(e);
            system.debug('** Error Message: '+e.getMessage());   
        }
        finally {
            // Something executed whether there was an error or not
        }
        
        return responses;

    }    

    
    public static List<Response> processContractAccounts(List<Request> req){

         
        Account[] lstContractAccounts;
        
        Account[] lstShiptoAccounts;

        List<string> recordIdStrings = new List<string>();
        recordIdStrings.Add(req[0].RecordId);
        List<String> ObjectName = UTIL_getObjectName.returnObjectName(recordIdStrings);
        
        system.debug('**req[0].RecordId**'+req[0].RecordId);
        
        Order[] CurOrder = [Select Billto__c,Shipto__c from Order where id =: req[0].RecordId];

       // system.debug('**ObjectName[0]**'+ObjectName[0] +'***Cur Order***'+CurOrder[0].id);
        system.debug('**RequestType**'+req[0].RequestType);
        Set<String> Set_AccountId = new Set<String>();
        if(req[0].RequestType == 'AccountShipto'){
            system.debug('**RequestType**'+req[0].RequestType);
           

                OrderShipto__c[] lstOrderShipto = [Select id,ShiptoAccount__c from OrderShipto__c where Order__c =: CurOrder[0].id];
                for(OrderShipto__c ord:lstOrderShipto){
                    Set_AccountId.add(ord.ShiptoAccount__c);
                }
                system.debug('**Set_AccountId**'+Set_AccountId);
                lstShiptoAccounts = [Select id,Name,Type,ShippingStreet,ShippingCity,	ExternalCustomerId__c,PurchasingGroup__c,NumberofStudents__c from Account where ValidateErrors__c = false AND (id=:CurOrder[0].Billto__c OR PurchasingGroup__c =:CurOrder[0].Billto__c OR ParentId=:CurOrder[0].Billto__c OR SalesAccount__c=:CurOrder[0].Billto__c OR DefaultBillto__c=:CurOrder[0].Billto__c) AND id not in: Set_AccountId AND NumberofStudents__c !=: null];
        
        }
        else if(req[0].RequestType == 'OrderShipto'){
            
            
                system.debug('**OrderShipto1**');
            if(ObjectName[0] =='Contract'){                
                lstShiptoAccounts = [Select id,Name,Type,ShippingStreet,ShippingCity,	ExternalCustomerId__c,PurchasingGroup__c,NumberofStudents__c from Account where ValidateErrors__c = false AND  (PurchasingGroup__c =:req[0].BilltoAccount.Id OR ParentId=:req[0].BilltoAccount.Id OR SalesAccount__c=:req[0].BilltoAccount.Id OR DefaultBillto__c=:req[0].BilltoAccount.Id) AND NumberofStudents__c !=: null];
            }
            else if(ObjectName[0] =='Order' ){
                system.debug('**OrderShipto2**');
                OrderShipto__c[] lstOrderShipto = [Select name,id,ShiptoAccount__c from OrderShipto__c where Order__c =: CurOrder[0].Id];
                for(OrderShipto__c ord:lstOrderShipto){
                    Set_AccountId.add(ord.ShiptoAccount__c);
                }
                system.debug('**OrderShipto3**'+Set_AccountId);
                lstShiptoAccounts = [Select id,Name,Type,ShippingStreet,ShippingCity,	ExternalCustomerId__c,PurchasingGroup__c,NumberofStudents__c from Account where id in: Set_AccountId AND ValidateErrors__c = false AND NumberofStudents__c !=: null];   
            
            }
            
            

            if(lstShiptoAccounts.size()==0 && req[0].MultipleShipto == true && ObjectName[0] !='Contract'){
                lstShiptoAccounts = [Select id,Name,Type,ShippingStreet,ShippingCity,	ExternalCustomerId__c,PurchasingGroup__c,NumberofStudents__c from Account where ValidateErrors__c = false AND (PurchasingGroup__c =:CurOrder[0].Billto__c OR id=:CurOrder[0].Billto__c OR ParentId=:CurOrder[0].Billto__c OR SalesAccount__c=:CurOrder[0].Billto__c OR DefaultBillto__c=:CurOrder[0].Billto__c) AND NumberofStudents__c !=: null];
            }
            else if(lstShiptoAccounts.size()==0 && (req[0].MultipleShipto == null || req[0].MultipleShipto == false) && ObjectName[0] !='Contract' ){
                lstShiptoAccounts = [Select id,Name,Type,ShippingStreet,ShippingCity,	ExternalCustomerId__c,PurchasingGroup__c,NumberofStudents__c from Account where id=:CurOrder[0].Shipto__c  AND ValidateErrors__c = false AND NumberofStudents__c !=: null];
            }

            system.debug('**req[0].MultipleShipto**'+req[0].MultipleShipto);
            system.debug('**lstShiptoAccounts**'+lstShiptoAccounts);
            
        }

            
        lstContractAccounts = lstShiptoAccounts;

        List<Response> responses = new List<Response>();
        Response res = new Response();
        res.ListOfAccounts = lstContractAccounts; 
        res.AccountListSize = lstContractAccounts.size();
        responses.add(res);
        return responses;

    }    

    
    

}