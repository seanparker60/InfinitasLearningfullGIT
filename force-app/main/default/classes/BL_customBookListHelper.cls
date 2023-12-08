public class BL_customBookListHelper {
    
    @AuraEnabled(cacheable=true)
    public static List<Asset> getBookLists(String recordId) {
        System.debug('BL_customBookListHelper.getBookLists(recordId: ' + recordId + ')');

        List<Asset> returnList = new List<Asset>();
        Id booklistRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Asset' AND name = 'Booklist' LIMIT 1].Id;

        returnList = [SELECT 
            Id, 
            Name, 
            SchoolYear__c, 
            Booklist__c, 
            Booklist__r.Name, 
            Subtype__c, 
            Year1__c, 
            Year2__c, 
            Year3__c, 
            Year4__c, 
            Year5__c, 
            Year6__c 
            FROM Asset 
            WHERE AccountId = :recordId 
            AND RecordTypeId = :booklistRecordTypeId
            AND IsSalesStatistic__c = false
            ORDER BY SchoolYear__c ASC, Name ASC];

        return returnList;
    }

    @AuraEnabled(cacheable=true)
    public static List<Asset> getSalesStatistics(String recordId) {
        System.debug('BL_customBookListHelper.getBookLists(recordId: ' + recordId + ')');

        List<Asset> returnList = new List<Asset>();
        Id booklistRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Asset' AND name = 'Booklist' LIMIT 1].Id;

        returnList = [SELECT 
            Id, 
            Name, 
            Product2.Name, 
            Quantity, 
            Value__c, 
            Year__c, 
            OrderDate__c, 
            CreatedDate 
            FROM Asset 
            WHERE AccountId = :recordId 
            AND RecordTypeId = :booklistRecordTypeId
            AND IsSalesStatistic__c = true
            ORDER BY SchoolYear__c DESC, Name ASC];

        return returnList;
    }

}