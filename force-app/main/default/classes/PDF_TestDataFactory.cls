@IsTest
public class PDF_TestDataFactory {
    
    public static Map<String,Account> createAccounts(Boolean doInsert) {

        Id B2BEducationalAccountId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('B2BEducational').getRecordTypeId();
        Map<String, Account> accountMap = New Map<String, Account>();

        List<Account> accLst = New List<Account>();
        for (Integer i = 0; i < 2; i++) {
            Account acc = New Account();
            if (i == 0) {
                acc.Name = 'Test Ship-to Account';
            } else {
                acc.Name = 'Test Bill-to Account';
            }
            acc.RecordTypeId = B2BEducationalAccountId;
            acc.TypeOfAccount__c = 'Sales';
            acc.NumberofStudents__c = 0;
            acc.NetsuiteInternalId__c = '123456789' + i;
            acc.NetsuiteCustomerNumber__c = acc.NetsuiteInternalId__c;
            acc.VatNumberRequired__c = 'No';
            acc.CommunicationLanguage__c = 'nl_NL';
            acc.Area__c = 'Dutch';
            acc.OperatingCompany__c = 'Plantyn';
            accLst.add(acc);
        }
        if (doInsert) {
            insert accLst;
        }

        for (Account acc : accLst) {
            accountMap.put(acc.Name, acc);
        }

        return accountMap;
    }

    public static Order createOrder(Map<String, Account> accountMap, Boolean doInsert) {

        Date today = Date.today();

        Order o = New Order();
        o.AccountId = accountMap.get('Test Bill-to Account').Id;
        o.Billto__c = accountMap.get('Test Bill-to Account').Id;
        o.Shipto__c = accountMap.get('Test Ship-to Account').Id;
        o.Status = 'Draft';
        o.EffectiveDate = today;
        o.Type = 'Regular';
        o.ShippingCostMethod__c = 'Based on weight Domestic';
        o.OperatingCompany__c = 'Plantyn';
        o.Pricebook2Id = Test.getStandardPricebookId();

        if (doInsert) {
            insert o;
        }

        return o;
    }

    public static List<OrderItem> createOrderItems(Map<String, Account> accountMap, Order order, Integer amount, Boolean doInsert) {

        List<OrderItem> orderItemList = New List<OrderItem>();
        Product2 p = New Product2(Name = 'TestProduct', IsRegularOrderPossible__c = true);
        insert p;

        Id stdPbId = Test.getStandardPricebookId();
        PricebookEntry pbE = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = p.Id, UnitPrice = 25.0, isActive = true, Subsidiary__c = 'Plantyn');
        insert pbE;

        VAT__c vatRule = New VAT__c(Rate__c = 0.6, TaxCode__c = 'SR-BE', Description__c = 'Reduced rate - other', Product__c = 'Low', IsActive__c = true, Subsidiary__c = 'Plantyn', Nexus__c = '3');
        insert vatRule;

        for (Integer i = 0; i < amount; i++) {
            OrderItem oi = New OrderItem();
            oi.UnitPrice = 25.00;
            oi.OrderId = order.Id;
            oi.PricebookEntryId = pbE.Id;
            oi.NetSuiteIdBilltoAccount__c = '1234567890';
            oi.NetSuiteIdShiptoAccount__c = '1234567891';
            oi.OrderLineType__c = 'Regular';
            oi.Quantity = 10;
            oi.ShipToAccount__c = accountMap.get('Test Ship-to Account').Id;
            oi.VATRule__c = vatRule.Id;
            orderItemList.add(oi);
        }

        if (doInsert) {
            insert orderItemList;
        }

        return orderItemList;
    }

}