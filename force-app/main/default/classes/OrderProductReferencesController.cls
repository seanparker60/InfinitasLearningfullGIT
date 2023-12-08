public without sharing class OrderProductReferencesController {
	@AuraEnabled(cacheable=true)
    public static List<sObject> getOrderProducts(Id recordId){
        system.debug('recordId: ' + recordId);
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        
        List<sObject> retVal = new list<sObject>();
        
        if(sObjName == 'Opportunity'){
            retVal = [SELECT Id, ProductName__c, EAN__c, ProductType__c, Quantity, CustomerReference__c FROM OpportunityLineItem WHERE OpportunityId =: recordId];
        } else {
            retVal = [SELECT Id, ProductName__c, ProductEAN__c, ProductType__c, Quantity, CustomerReference__c FROM OrderItem WHERE OrderId =: recordId];
        }
        
        system.debug('products- retVal: ' + retVal);
        
        return retVal;
    }
    
    @AuraEnabled(cacheable=false)
    public static void saveRecords(List<sObject> orderProducts){
        update orderProducts;
    }
}