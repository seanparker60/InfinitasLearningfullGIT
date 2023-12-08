@isTest
public class NS_TestDataFactory {

    public static List<Account> createAccounts(Integer amount, Boolean doInsert) {

        Id B2BEdicationalRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('B2B Educational').getRecordTypeId();

        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < amount; i++) {
            Account acc = new Account();
            acc.Name = 'Test Account ' + (i+1);
            acc.Email__c = 'TestAccount' + (i+1) + '@test.com';
            acc.NumberofStudents__c = 1;
            acc.OperatingCompany__c = 'Plantyn';
            acc.ShippingStreet = 'TestStreet 123';
            acc.ShippingPostalCode = '1234';
            acc.ShippingCity = 'Durbuy';
            acc.ShippingCountry = 'Belgium';
            acc.RecordTypeId = B2BEdicationalRecordTypeId;
            acc.CustomerCategory__c = 'Educational Institution';
            acc.TypeOfAccount__c = 'Sales and Order';
            acc.Area__c = 'Dutch';
            acc.LastUpdateToAWS__c = system.now();
            acc.CommunicationLanguage__c = 'nl_NL';
            acc.BillingReminderEmail__c = 'TestAccount' + (i+1) + '@test.com';
            acc.DigitalActivationEmail__c = 'TestAccount' + (i+1) + '@test.com';
            acc.InvoicingEmail__c = 'TestAccount' + (i+1) + '@test.com';
            acc.OrderNotificationEmail__c = 'TestAccount' + (i+1) + '@test.com';
            accounts.add(acc);
        }

        if (doInsert) {
            insert accounts;
        }

        return accounts;
    }

    public static Order createOrder(Account account, Boolean doInsert){
        
        Order o = new Order();
        o.Billto__c = account.Id;
        o.AccountId = account.Id;
        o.Pricebook2Id = Test.getStandardPricebookId();
        o.Status = 'Draft';
        o.EffectiveDate = Date.today();
        o.PricingMethod__c = 'ProductDiscountGroupUsageBased';
        o.PaymentMethod__c = 'Invoice';
        o.MultipleShippingLocations__c = true;
        o.InvoiceEmail__c = account.Email__c;
        o.BillingReminderEmail__c = account.Email__c;
        o.OrderNotificationEmail__c = account.Email__c;
        o.ShippingStreet = account.ShippingStreet;
        o.ShippingCity = account.ShippingCity;
        o.ShippingPostalCode = account.ShippingPostalCode;
        o.ShippingCountry = account.ShippingCountry;
        o.OperatingCompany__c = 'Plantyn';

        if (doInsert) {
            insert o;
        }

        return o;
    }

    public static List<OrderItem> createOrderItems (Order order, List<Account> accounts, Boolean doInsert) {

        Product2 p = new Product2();
        p.Name = 'testProduct';
        p.IsRegularOrderPossible__c = true;
        insert p;

        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.Product2Id = p.Id;
        pbe.UnitPrice = 50.00;
        pbe.IsActive = true;
        pbe.Subsidiary__c = 'Plantyn';
        insert pbe;

        List<OrderItem> orderItems = new List<OrderItem>();
        for (Account acc : accounts) {
            OrderItem oi = new OrderItem();
            oi.NetSuiteIdBilltoAccount__c = '123456';
            oi.NetSuiteIdShiptoAccount__c = '654321';
            oi.NetsuiteInternalId__c = 'abcdef';
            oi.OrderId = order.Id;
            oi.AccountSubsidiary__c = [SELECT Id FROM AccountSubsidiary__c WHERE Account__c = :acc.Id LIMIT 1].Id;
            oi.PricebookEntryId = pbe.Id;
            oi.ShipToAccount__c = acc.Id;
            oi.Account__c = order.Billto__c;
            oi.Quantity = 1.0;
            oi.NetsuiteQuantity__c = 1.0;
            oi.OrderLineType__c = 'Regular';
            oi.IsRegularOrderPossible__c = true;
            oi.UnitPrice = 39.50;
            oi.ListPrice = 50.00;
            oi.StartDate__c = order.EffectiveDate;
            oi.EndDate = order.EffectiveDate.addMonths(12);
            orderItems.add(oi);
        }

        if (doInsert) {
            insert orderItems;
        }

        return orderItems;

    }
    
}