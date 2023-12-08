public  without sharing class PDF_orderToPdfController {
    
    public Id recordId = ApexPages.currentPage().getParameters().get('Id');

    public List<OrderItem> getOrderItems() {
        List<OrderItem> results = [SELECT Id, ProductName__c, Quantity, DiscountedPrice__c FROM OrderItem WHERE OrderId = :recordId];
        return results;
    }

    public Map<String,OrderItem> getItemMap() {
        List<OrderItem> orderItems = [SELECT Id, ProductName__c, Quantity, DiscountedPrice__c FROM OrderItem WHERE OrderId = :recordId];

        Map<String,OrderItem> itemMap = new Map<String,OrderItem>();
        for (OrderItem oi : orderItems) {
            if (itemMap.get(oi.ProductName__c) == null) {
                itemMap.put(oi.ProductName__c, oi);
            } else {
                itemMap.get(oi.ProductName__c).Quantity += oi.Quantity;
            }
        }
        return itemMap;
    }

    public Map<Account,List<OrderItem>> getOrderItemsPerShipTo() {

        Map<Account,List<OrderItem>> returmMap = new Map<Account,List<OrderItem>>();
        List<OrderItem> orderItemList = [SELECT Id, ProductName__c, Quantity,  ShipToAccount__c, Product2.ISBN__c, Discount__c FROM OrderItem WHERE OrderId = :recordId];
        Set<Id> shipToAccountIds = new Set<Id>();
        for (orderItem oi : orderItemList) {
            shipToAccountIds.add(oi.ShipToAccount__c);
        }

        List<Account> shipToAccounts = [SELECT Id, Name, ShippingStreet, ShippingPostalCode, ShippingCity, ShippingCountry FROM Account WHERE Id IN :shipToAccountIds];
        for (Account shipToAccount : shipToAccounts) {
            List<OrderItem> tmpOrderItemLst = new List<OrderItem>();
            for (OrderItem shipToOrderItem : orderItemList) {
                if (shipToOrderItem.ShipToAccount__c == shipToAccount.Id) {
                    tmpOrderItemLst.add(shipToOrderItem);
                }
            }
            returmMap.put(shipToAccount, tmpOrderItemLst);
        }
        return returmMap;
    }

    public Set<String> getItemMapKeys() {
        return getItemMap().keySet();
    }

    public Account getBillToAccount() {
        Id billingAccountId = [SELECT Billto__c FROM Order WHERE Id = :recordId LIMIT 1].Billto__c;
        Account account = [SELECT Id, NetsuiteCustomerNumber__c, ExternalCustomerId__c, CustomerNumber__c, VATNumber__c, Name, BillingStreet, BillingPostalCode, BillingCity, BillingCountry FROM Account WHERE Id = :billingAccountId];
        return account;
    }

    public Order getOrderDetails() {
        Order orderDetails = [SELECT Id, ShippingCost__c, OrderNotificationEmail__c, QuoteVersion__c, ShipbyDate__c, OrderNumber, TotalOrderDiscount__c, TotalAmount FROM Order WHERE Id = :recordId];
        if (orderDetails.ShippingCost__c == null) {
            orderDetails.ShippingCost__c = 0;
        }
        if (orderDetails.QuoteVersion__c == null || orderDetails.QuoteVersion__c == 0) {
            orderDetails.QuoteVersion__c = 1;
        }

        return orderDetails;
    }

    public Double getVat() {
        List<OrderItem> orderItems = [SELECT VAT__c FROM OrderItem WHERE OrderId = :recordId];

        Double vatAmount = 0;
        for (OrderItem oi : orderItems) {
            vatAmount += oi.VAT__c;
        }
        return vatAmount;
    }

    public OrderPdfSetting__mdt getTranslations() {
        String communicationLanguage = getCommunicationLanguage();
        return [SELECT 
                BillTo__c, 
                Date__c, 
                CustomerVATNumber__c, 
                DebtorNr__c, 
                Items__c, 
                OrderHeaderTitle__c, 
                OrderNo__c, 
                PricePerPiece__c, 
                Quantity__c, 
                VATStatement__c, 
                SettledDiscount__c, 
                Discount__c, 
                Subtotal__c, 
                Total__c,
                VAT__c, 
                ValidUntill__c, 
                ShippingAddress__c,
                Email__c,
                Version__c,
                CustomerNumber__c,
                ShippingCost__c,
                Page__c,
                From__c
            FROM OrderPdfSetting__mdt 
            WHERE Label = :communicationLanguage 
            LIMIT 1];
    }

    public OrderPdfSetting__mdt getOpCoSettings() {
        String operatingCompany = getOperatingComany();
        String commLanguage = getCommunicationLanguage();
        
        if(operatingCompany != 'Plantyn'){
            return [SELECT 
                    Footer__c, 
                    LogoUrl__c, 
                    Currency__c
                    FROM OrderPdfSetting__mdt 
                    WHERE Label = :operatingCompany 
                    LIMIT 1];
        } else {
            String opCo_ComLang = operatingCompany + '_' + commLanguage; // ie: Plantyn_FR
            
            return [SELECT 
                    Footer__c, 
                    LogoUrl__c, 
                    Currency__c
                    FROM OrderPdfSetting__mdt 
                    WHERE Label = :opCo_ComLang 
                    LIMIT 1];
        }

    }

    public String getCommunicationLanguage() {

        String communicationLanguage = [SELECT Billto__r.CommunicationLanguage__c FROM Order WHERE Id = :recordId LIMIT 1].Billto__r.CommunicationLanguage__c;

        if (communicationLanguage == 'nl_NL') {
            communicationLanguage = 'NL';
        } else if (communicationLanguage == 'fr_FR') {
            communicationLanguage = 'FR';
        } else if(communicationLanguage == 'sv_SE') {
            communicationLanguage = 'SE';
        }else if (String.isBlank(communicationLanguage) || communicationLanguage == 'en') {
            communicationLanguage = 'ENG';
        }

        return communicationLanguage;
    }

    public String getOperatingComany() {
        String OperatingCompany = [SELECT OperatingCompany__c FROM Order WHERE Id = :recordId LIMIT 1].OperatingCompany__c;

        if (OperatingCompany == null) {
            OperatingCompany = 'Noordhoff';
        }

        system.debug('OperatingCompany: ' + OperatingCompany);
        return OperatingCompany;
    }

    public class Items {
        public String name;
        public Double Quantity;
        public Double Price; 
    }

}