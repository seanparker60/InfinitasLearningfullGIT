public class LPD_customListPriceDiscountView_Helper {
    
    @AuraEnabled(cacheable=true)
    public static List<ListPriceDiscount__c> getListPriceDiscountRecords(Id recordId) {
        System.debug('LPD_customListPriceDiscountView_Helper - getListPriceDscountRecords');

        Product2 selectedProduct = [SELECT ProductDiscountGroup__c, Subsidiary__c, OrderLineType__c, MarketSegment__c FROM Product2 WHERE Id = :recordId LIMIT 1];
        String productDiscountGroup = selectedProduct.ProductDiscountGroup__c;
        String subsidiary = selectedProduct.Subsidiary__c;
        List<String> orderLineType = selectedProduct.OrderLineType__c.split(';');
        String marketSegment = selectedProduct.MarketSegment__c;

        List<ListPriceDiscount__c> lpdLst = new List<ListPriceDiscount__c>();

        lpdLst = [SELECT Id, 
            Name, 
            StartQuantity__c, 
            Rate__c, 
            ProductDiscountGroup__c, 
            DiscountType__c, 
            MarketSegment__c, 
            CustomerDiscountGroup__c, 
            OrderLineType__c 
            FROM ListPriceDiscount__c 
            WHERE IsActive__c = true 
            AND ProductDiscountGroup__c = :productDiscountGroup 
            AND Subsidiary__c = :subsidiary 
            AND OrderLineType__c IN :orderLineType
            ORDER BY CustomerDiscountGroup__c ASC, OrderLineType__c DESC, MarketSegment__c DESC, StartQuantity__c ASC];

        return lpdLst;
    }

    @AuraEnabled(cacheable=true)
    public static List<ListPriceDiscount__c> getListPriceDiscountRecordsForAccount(Id recordId) {
        System.debug('LPD_customListPriceDiscountView_Helper - getListPriceDiscountRecordsForAccount');

        Account currentAccount = [SELECT CustomerDiscountGroup__c FROM Account WHERE Id =: recordId LIMIT 1];
        String customerDiscountGroup = currentAccount.CustomerDiscountGroup__c;

        List<ListPriceDiscount__c> lpdLst = new List<ListPriceDiscount__c>();

        lpdLst = [SELECT Id, 
            Name, 
            StartQuantity__c, 
            Rate__c, 
            ProductDiscountGroup__c, 
            DiscountType__c, 
            MarketSegment__c, 
            CustomerDiscountGroup__c, 
            OrderLineType__c 
            FROM ListPriceDiscount__c 
            WHERE IsActive__c = true 
            AND CustomerDiscountGroup__c = :customerDiscountGroup 
            ORDER BY ProductDiscountGroup__c ASC, OrderLineType__c DESC, MarketSegment__c DESC, StartQuantity__c ASC];

        return lpdLst;
    }

}