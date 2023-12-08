public without sharing class OrderAddressInvocable {
    public class Request {
        @InvocableVariable
        public string street;
        @InvocableVariable
        public string housenumber;
        @InvocableVariable
        public string housenumberAddition;
        @InvocableVariable
        public string postalcode;
        @InvocableVariable
        public string country;
        @InvocableVariable
        public string city;
        @InvocableVariable
        public string addressId;
        @InvocableVariable
        public string orderId;
        @InvocableVariable
        public string shipToAccountId;
    }
    
    public class Response {
        @InvocableVariable
        public boolean retVal;
    }

    
    @InvocableMethod(label='Update Address on Order Items')
    public static List<Response> updateOrderItems(List<Request> requests){
        List<OrderItem> orderItemLs = new List<OrderItem>();
        
        if(requests[0].shipToAccountId != null){
            orderItemLs = [SELECT Id from OrderItem WHERE OrderId = :requests[0].orderId AND ShipToAccount__c =: requests[0].shipToAccountId];
        } else {
           orderItemLs = [SELECT Id from OrderItem WHERE OrderId = :requests[0].orderId];
        }
        
        
        for(OrderItem oItem : orderItemLs){
            oItem.ShipToAddress__c = requests[0].addressId; 
            oItem.ShipToAddressValidated__c = true; 
            oItem.ShippingHouseNumber__c = requests[0].housenumber; 
            oItem.ShippingHouseNumberAddition__c = requests[0].housenumberAddition; 
            oItem.ShippingStreetName__c = requests[0].street; 
            oItem.ShippingCity__c = requests[0].city; 
            oItem.ShippingCountry__c = requests[0].country; 
            oItem.ShippingPostalCode__c = requests[0].postalcode; 
            oItem.ShippingStreet__c = requests[0].street + ' ' + requests[0].housenumber + requests[0].housenumberAddition; 
        }
        
        update orderItemLs;
        
        
        List<Response> res = new List<Response>();
        Response r = new Response();
        r.retVal = true;
        res.add(r);
        
        return res;
    }
}