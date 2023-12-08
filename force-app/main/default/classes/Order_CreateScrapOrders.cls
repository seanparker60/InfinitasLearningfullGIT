public class Order_CreateScrapOrders {

    public class FlowInputs{
        @InvocableVariable
        public String amountToScrap;

        @InvocableVariable
        public Product2 product;
        
        @InvocableVariable
        public String orderRef;
    }

    @InvocableMethod(label='Invoke Apex')
    public static void invokeMethod(List<FlowInputs> flowInputs) {
        System.debug('Order_CreateScrapOrders - invokeMethod');

        System.debug(flowInputs[0].product);
        System.debug(flowInputs[0].amountToScrap);

        Map<Product2, String> productQuantityScrapMap = new Map<Product2, String>();
        productQuantityScrapMap.put(flowInputs[0].product, flowInputs[0].amountToScrap);
        System.debug(productQuantityScrapMap);
        
        String orderRef = flowInputs[0].orderRef;

        Map<String, List<ImportOrder__c>> returnedImportOrderMap = setupScrapOrders(productQuantityScrapMap, orderRef);
        createScrapOrders(returnedImportOrderMap);

    }

    public static void createScrapOrders(Map<String, List<ImportOrder__c>> importOrdersMap) {
        System.debug('Order_CreateScrapOrders - createScrapOrders');
        
        List<ImportOrder__c> importOrderList = new List<ImportOrder__c>();
        importOrderList.addAll(importOrdersMap.get('orders'));
        System.debug('Order: '+ importOrderList);
        
        List<ImportOrder__c> importOrderItemList = new List<ImportOrder__c>();
        importOrderItemList.addAll(importOrdersMap.get('orderItems'));
        System.debug('Order Items: '+ importOrderItemList);

        if (importOrderItemList.size() > 0) {
            
            // Set last Order Item to trigger businesslogic
            importOrderItemList.get(importOrderItemList.size() - 1).TriggerBusinessLogic__c = true;

            // Insert orders
            try {
                insert importOrderList;
            } catch (Exception e) {
                HandleCustomException.LogException(e);
            }

            // Insert order items
            try {
                insert importOrderItemList;
            } catch (Exception e) {
                HandleCustomException.LogException(e);
            }

        }

    }

    public static Map<String, List<ImportOrder__c>> setupScrapOrders(Map<Product2, String> productsToScrapMap, String orderRef) {
        System.debug('Order_CreateScrapOrders - setupScrapOrders');

        Set<String> operatingCompanySet = new Set<String>();
        List<Product2> products = new List<Product2>();
        for(Product2 thisProduct : productsToScrapMap.keySet()){
            products.add(thisProduct);
            operatingCompanySet.add(thisProduct.Subsidiary__c);
        }

        List<Scrap_Orders_Setting__mdt> scrapOrderSettingList = [SELECT Id, Label, OrderAccountId__c FROM Scrap_Orders_Setting__mdt WHERE OperatingCompany__c IN : operatingCompanySet];
        System.debug(scrapOrderSettingList);
        Set<String> scrapOrderAccountIdSet = new Set<String>();
        for(Scrap_Orders_Setting__mdt scrapOrdersMdtSetting : scrapOrderSettingList){
            scrapOrderAccountIdSet.add(scrapOrdersMdtSetting.OrderAccountId__c);
        }

        List<Account> scrapOrderAccountList = new List<Account>();
        if(Test.isRunningTest()){
            // TEST CLASS ONLY WILL ENTER THIS CONDITION. BYPASS NEEDED BECAUSE TEST CLASS CANNOT QUERY ACCOUNT SPECIFIED IN METADATA
            scrapOrderAccountList = [SELECT NetsuiteCustomerNumber__c, OperatingCompany__c, CurrencyIsoCode FROM Account LIMIT 1];
            
        } else {
            // LIVE RUN -> TEST IS NOT RUNNING.
            scrapOrderAccountList = [SELECT NetsuiteCustomerNumber__c, OperatingCompany__c, CurrencyIsoCode FROM Account WHERE Id IN : scrapOrderAccountIdSet];
        }
        System.debug(scrapOrderAccountList);

        List<ImportOrder__c> importOrderList = new List<ImportOrder__c>();
        List<ImportOrder__c> importOrderItemList = new List<ImportOrder__c>();

        Map<String, List<ImportOrder__c>> returnMap = new Map<String, List<ImportOrder__c>>();

        for(Account scrapOrderAccount : scrapOrderAccountList){

            String todaysDateString = String.valueOf(Date.today().format());
            String externalOrderId = scrapOrderAccount.NetsuiteCustomerNumber__c + '-' + todaysDateString;
            String shippingCostMethodNSId = '0';
            if(scrapOrderAccount.OperatingCompany__c == 'Plantyn'){
                shippingCostMethodNSId = '196';
            } else if (scrapOrderAccount.OperatingCompany__c == 'Liber'){
                shippingCostMethodNSId = '7525';
            }
            
            // Create order Header
            ImportOrder__c order = new ImportOrder__c();
            order.customerNo__c = scrapOrderAccount.NetsuiteCustomerNumber__c;
            order.orderDate__c = todaysDateString;
            order.Source__c = 'B2B Salesforce';
            order.OperatingCompany__c = scrapOrderAccount.OperatingCompany__c;
            order.ExternalOrderId__c = externalOrderId;
            order.LineCount__c = products.size();
            order.orderType__c = 'Scrap';
            order.ShippingCostMethodNsId__c = shippingCostMethodNSId;
            order.CurrencyIsoCode = scrapOrderAccount.CurrencyIsoCode;
            order.orderRef__c = orderRef;
            importOrderList.add(order);

            // Create Order Items
            for (Product2 product : products) {
                ImportOrder__c orderItem = new ImportOrder__c();
                orderItem.customerNo__c = scrapOrderAccount.NetsuiteCustomerNumber__c;
                orderItem.ProductId__c = product.ISBN__c;
                orderItem.quantity__c = Decimal.valueOf(productsToScrapMap.get(product));
                orderItem.orderRef__c = orderRef;
                orderItem.orderItemRef__c = orderRef;
                orderItem.orderDate__c = todaysDateString;
                orderItem.ExternalOrderId__c = externalOrderId;
                orderItem.Source__c = 'B2B Salesforce';
                orderItem.LineItemType__c = 'Scrap';
                orderItem.discountRate__c = 100;
                orderItem.TriggerBusinessLogic__c = false;
                orderItem.CurrencyIsoCode = scrapOrderAccount.CurrencyIsoCode;
                importOrderItemList.add(orderItem);
            }

        }

        returnMap.put('orders',importOrderList);
        returnMap.put('orderItems', importOrderItemList);

        return returnMap;
        
    }

}