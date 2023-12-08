//@RestResource(urlMapping='/Accounts/*')
global class NS_NetSuite {
    /*
    @HttpPost
    global static String doPost(String OrdId) {
        
        Order[] lstOrder = [Select id,Billto__c,AccountId from Order where Id =: OrdId];
        String resp='Success';
        try{
            updateNsViaOrderTrigger(lstOrder);
        }
        catch(exception e){
            resp=e.getmessage();
        }

        return resp;
    }
    */



    @InvocableMethod
    public static void updateNsViaOrderTrigger(List<Order> OrderId) {
        System.debug('NS_NetSuite - updateNsViaOrderTrigger');
        
        Set<Id> accountUpdateIds = new Set<Id>();
        Set<Id> orderIds = new Set<Id>();

        for (Order o : OrderId) {

           if(o.ActivateforAssetRenewal__c != true){
                if (o.Billto__c != null) {
                    accountUpdateIds.add(o.Billto__c);
                    orderIds.add(o.Id);
                }
                if (o.AccountId != null) {
                    accountUpdateIds.add(o.AccountId);
                    orderIds.add(o.Id);
                }
            } 
        }

     if(orderIds.size()>0){  
          
                List<OrderItem> orderItems = [SELECT Id, ShipToAccount__c, Account__c FROM OrderItem WHERE OrderId in :orderIds];
                for (OrderItem oi : orderItems) {
                    if (oi.ShipToAccount__c != null) {
                        accountUpdateIds.add(oi.ShipToAccount__c);
                    }
                    if (oi.Account__c != null) {
                        accountUpdateIds.add(oi.Account__c);
                    }
                }
                System.debug('NS_NetSuite - Size of accountUpdateIds = ' + accountUpdateIds.size());

                List<AccountSubsidiary__c> accSubs = [SELECT Id FROM AccountSubsidiary__c WHERE Deleted__c =: false and Account__c IN :accountUpdateIds FOR UPDATE];
                System.debug('NS_NetSuite - Size of accSubs = ' + accSubs.size());

                List<AccountSubsidiary__c> accSubsToUpdate = new List<AccountSubsidiary__c>();

       
         
                for (AccountSubsidiary__c accSub : accSubs) {
                    
                    accSub.IntegrationFactorySend__c = true;
                    accSubsToUpdate.add(accSub);
                }

                if (accSubsToUpdate.size() > 0) {
                    try{
                        update accSubsToUpdate;
                    }
                    catch(exception e){

                    }

                    
                }

                //Added by Sean 14/6 SOQL with for loop
                List<Account> accountsToUpdate = new List<Account>([Select id,IntegrationFactorySend__c From Account Where id in:accountUpdateIds FOR UPDATE]);
                
                for(Account acc:accountsToUpdate){
                    acc.IntegrationFactorySend__c = true;
                }

                /* Commented out by Sean 14/6 SOQL with for loop above
                for (Id accountId : accountUpdateIds) {
                    System.debug('NS_NetSuite - AccountId = ' + accountId);
                    Account Acc = new Account();
                    Acc.Id = accountId;
                    Acc.IntegrationFactorySend__c = true;
                    accountsToUpdate.add(Acc);
                }
                */

                if (accountsToUpdate.size() > 0) {
                    try{
                        update accountsToUpdate;
                    }
                    catch(exception e){

                    }
                }
        }
    }

}