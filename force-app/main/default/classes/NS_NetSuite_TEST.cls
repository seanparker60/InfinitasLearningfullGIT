@isTest
public class NS_NetSuite_TEST {

  
    @TestSetup
    static void makeData(){
        NS_TestDataFactory.createAccounts(3, true);
    }

    @IsTest
    static void testOnOrder(){

        Account billtoAccount = [SELECT Id, Email__c, LastUpdateToAWS__c, ShippingStreet, ShippingPostalCode, ShippingCity, ShippingCountry FROM Account WHERE Name = 'Test Account 1' LIMIT 1];
        List<Account> shipToAccounts = [SELECT Id, Email__c, LastUpdateToAWS__c FROM Account WHERE Name != 'Test Account 1'];
        List<AccountSubsidiary__c> accSubsBefore = [SELECT Id, LastUpdateToAWS__c FROM AccountSubsidiary__c];
        for (Integer i = 0; i < accSubsBefore.size(); i++) {
            accSubsBefore[i].NetsuiteInternalId__c = 'xyz123' + i;
        }
        update accSubsBefore;

        // Store current Last AWS Updates
        map<Id, Datetime> AccountInitialAwasUpdates = new Map<Id, Datetime>();
        AccountInitialAwasUpdates.put(billtoAccount.Id, billtoAccount.LastUpdateToAWS__c);
        for (Account acc : shipToAccounts) {
            acc.LastUpdateToAWS__c = system.now();
            AccountInitialAwasUpdates.put(acc.Id, acc.LastUpdateToAWS__c);
        }

        map<Id, Datetime> AccountSubsInitialAwasUpdates = new Map<Id, Datetime>();
        for (AccountSubsidiary__c accSubBefore : accSubsBefore) {
            AccountSubsInitialAwasUpdates.put(accSubBefore.Id, accSubBefore.LastUpdateToAWS__c);
        }
        
        AccountSubsidiary__c billToAccountSub = [SELECT Id FROM AccountSubsidiary__c WHERE Account__c = :billtoAccount.Id LIMIT 1];
        System.debug('NS_NetSuite_TEST - Bill-To Account Subsidiary Id = ' + billToAccountSub.Id);

        Test.startTest();
            Order order = NS_TestDataFactory.createOrder(billtoAccount, false);
            order.AccountSubsidiary__c = billToAccountSub.Id;
            order.AccountSubsidiary__c = accSubsBefore[0].Id;
            order.NetSuiteIdAccountSubsidiary__c = '123456';
            order.Shipto__c = shipToAccounts[0].id; 
            insert order;
            NS_TestDataFactory.createOrderItems(order, shipToAccounts, true);
            List<OrderItem> oiLst = [SELECT Id, NetsuiteInternalId__c, ValidateAll__c
            FROM OrderItem WHERE OrderId = :order.Id];
            for (OrderItem oi : oiLst) {
                System.debug('#### OrderItemId ==> '+ oi.Id + '####');
                System.debug('#### NetsuiteInternalId__c ==> '+ oi.NetsuiteInternalId__c);
                System.debug('#### ValidateAll__c ==> '+ oi.ValidateAll__c);
            }
            System.debug('NS_NetSuite_TEST - AccountSubsidiary = ' + order.AccountSubsidiary__c);
           

            order.TriggerBusinessRules__c = true;
            update order;
            system.debug('##After Trigger business rules##'+shipToAccounts[0].id);
            

            Order testOrder = [SELECT Id,
            ShippingStreet, 
            ShippingCity, 
            ShippingPostalCode, 
            ShippingCountry,
            ValidationErrorsOrder__c,
            ValidationErrorsOrderProducts__c,
            ValidateActivateAccountSubsidiaryRequir__c,
            ValidateActivateEmailsRequired__c,
            ValidateActivateShippingAddressRequired__c,
            ValidateActivateValidation__c,
            ValidateB2BLineCountError__c,
            ValidateDigitalforNetherlands__c,
            ValidateInventoryOnMultipleLocations__c,
            ValidateReferenceNumberCheck__c,
            ValidateShipToEmpty__c,
            ValidateBillToEmpty__c
            FROM Order WHERE Id = :order.Id];
        
        System.debug('#### Order Id #### ==> ' + testOrder.Id);
        System.debug('#### ShippingStreet ==> ' + testOrder.ShippingStreet);
        System.debug('#### ShippingCity ==> ' + testOrder.ShippingCity);
        System.debug('#### ShippingPostalCode ==> ' + testOrder.ShippingPostalCode);
        System.debug('#### ShippingCountry ==> ' + testOrder.ShippingCountry);
        System.debug('#### ValidationErrorsOrder ==> ' + testOrder.ValidationErrorsOrder__c);
        System.debug('#### ValidationErrorsOrderProducts ==> ' + testOrder.ValidationErrorsOrderProducts__c);
        System.debug('#### ValidateActivateAccountSubsidiaryRequir ==> ' + testOrder.ValidateActivateAccountSubsidiaryRequir__c);
        System.debug('#### ValidateActivateEmailsRequired ==> ' + testOrder.ValidateActivateEmailsRequired__c);
        System.debug('####ValidateActivateShippingAddressRequired ==> ' + testOrder.ValidateActivateShippingAddressRequired__c);
        System.debug('#### ValidateActivateValidation ==> ' + testOrder.ValidateActivateValidation__c);
        System.debug('#### ValidateB2BLineCountError ==> ' + testOrder.ValidateB2BLineCountError__c);
        System.debug('####ValidateDigitalforNetherlands ==> ' + testOrder.ValidateDigitalforNetherlands__c);
        System.debug('#### ValidateInventoryOnMultipleLocations ==> ' + testOrder.ValidateInventoryOnMultipleLocations__c);
        System.debug('#### ValidateReferenceNumberCheck==> ' + testOrder.ValidateReferenceNumberCheck__c);
        System.debug('#### ValidateShipToEmpty ==> ' + testOrder.ValidateShipToEmpty__c);
        System.debug('#### ValidateBillToEmpty ==> ' + testOrder.ValidateBillToEmpty__c);
        
            order.Status = 'Activated';
            update order;
        Test.stopTest();

        List<AccountSubsidiary__c> accSubsAfter = [SELECT Id, LastUpdateToAWS__c, IntegrationFactorySend__c FROM AccountSubsidiary__c];
        List<Account> accsAfter = [SELECT Id, LastUpdateToAWS__c, IntegrationFactorySend__c FROM Account];
        
        // Check if the update to NS now has been done
        for (Account accAfter : accsAfter) {
           // System.debug('NS_NetSuite_TEST - initial Account AWS Update: ' + AccountInitialAwasUpdates.get(accAfter.Id).time());
          //  System.debug('NS_NetSuite_TEST - Current Account AWS Update: ' + accAfter.LastUpdateToAWS__c.time());
           // System.assertEquals(true, accAfter.IntegrationFactorySend__c || accAfter.LastUpdateToAWS__c.time() > AccountInitialAwasUpdates.get(accAfter.Id).time());
        }
        for (AccountSubsidiary__c accSubAfter : accSubsAfter) {
           // System.debug('NS_NetSuite_TEST - Initial Account Subsidiary AWS Update: ' + AccountSubsInitialAwasUpdates.get(accSubAfter.Id).time());
           // System.debug('NS_NetSuite_TEST - Current Account Subsidiary AWS Update: ' + accSubAfter.LastUpdateToAWS__c.time());
           // System.assertEquals(true, accSubAfter.IntegrationFactorySend__c || accSubAfter.LastUpdateToAWS__c.time() > AccountSubsInitialAwasUpdates.get(accSubAfter.Id).time());
        }        
    }



    

}