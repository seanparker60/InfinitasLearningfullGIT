@Istest
public with sharing class Order_UpdateVatOnItems_test {
    
    
    Public static testmethod void UpdateVatOnItems(){
        
        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Noordhoff',true,true);
        
        Set<String> Set_AccId = new Set<String>();
        Set<String> Set_Shipping = new Set<String>();
        
        for(Account acc:lstAccount){
            Set_AccId.add(acc.id);
            Set_Shipping.add(acc.ShippingCountry);
        }
        
        AccountSubsidiary__c[] lstAccountSubsidiary = [Select id,Account__c from AccountSubsidiary__c where Account__c in:Set_AccId ];
        
        Map<String,String> Map_AccSub = new Map<String,String>();
        Integer i=0;
        for(AccountSubsidiary__c  sub:lstAccountSubsidiary){
            sub.NetsuiteInternalId__c = '88776'+i;
            Map_AccSub.put(sub.Account__c,sub.id);
            i++;
        }
        
        update lstAccountSubsidiary;
        
        List<Product2> lstProduct = TestDataFactory.insertProducts(3,true);
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,true);
        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
        Order_TestDataFactory.InsertVAT(Set_Shipping, lstProduct, true);
        
        UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;
        Order_UpdateVatOnItems.UpdateVatOnItems(lstOrderItems);
        
    }
    
    Public static testmethod void UpdateVatOnItems2(){
        
        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Noordhoff',true,true);
        
        Set<String> Set_AccId = new Set<String>();
        Set<String> Set_Shipping = new Set<String>();
        
        for(Account acc:lstAccount){
            Set_AccId.add(acc.id);
            Set_Shipping.add(acc.ShippingCountry);
        }
        
        AccountSubsidiary__c[] lstAccountSubsidiary = [Select id,Account__c from AccountSubsidiary__c where Account__c in:Set_AccId ];
        
        Map<String,String> Map_AccSub = new Map<String,String>();
        Integer i=0;
        for(AccountSubsidiary__c  sub:lstAccountSubsidiary){
            sub.NetsuiteInternalId__c = '88776'+i;
            Map_AccSub.put(sub.Account__c,sub.id);
            i++;
        }
        
        update lstAccountSubsidiary;
        
        List<Product2> lstProduct = TestDataFactory.insertProducts(3,false);
        for(Product2 prod : lstProduct){
            prod.Vat__c = 'Low';
        }
        insert lstProduct;
        
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,true);
        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
        Order_TestDataFactory.InsertVAT(Set_Shipping, lstProduct, true);
        List<VAT__c> vatLs = [SELECT Id, Subsidiary__c, NexusCountry__c FROM VAT__c];
        
        for(VAT__c vat : vatLs){
            vat.Subsidiary__c = 'Noordhoff';
            vat.NexusCountry__c = 'NL';
            vat.Product__c = 'Low';
            vat.rate__c = 21;
        }
        update vatLs;
        
        UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;
        Order_UpdateVatOnItems.UpdateVatOnItems(lstOrderItems);
        
    }
}