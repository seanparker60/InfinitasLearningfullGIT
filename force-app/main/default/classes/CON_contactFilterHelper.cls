public class CON_contactFilterHelper {

    @AuraEnabled(cacheable=true)
    public static List<String> setBaseClassificationAttributes(String recordId) {

        List<String> returnList = new List<String>();
        String userId = UserInfo.getUserId();
        Id sId = Id.valueOf(recordId);
        String sobjectType = sId.getSObjectType().getDescribe().getName();
        System.debug('sobjectType ==> ' + sobjectType);

        String accId;
        if(sobjectType == 'Account'){
            accId = recordId;
        }else if(sobjectType == 'Opportunity'){
            accId = [SELECT AccountId FROM Opportunity WHERE Id = :recordId LIMIT 1].AccountId;
        }

        String opCo = [SELECT OperatingCompany__c FROM Account WHERE Id = :accId LIMIT 1].OperatingCompany__c;
        String attributeQuery = 'SELECT Id, Name FROM ClassificationAttribute__c WHERE ObjectName__c = \'Contact\' AND OperatingCompany__c = \'' + opCo + '\' ORDER BY Name';

        System.debug('setBaseClassificationAttributes query ==> ' + attributeQuery);
        List<ClassificationAttribute__c> caLst = Database.query(attributeQuery);

        for (ClassificationAttribute__c ca : caLst) {
            if (!returnList.contains(ca.Name)) {
                returnList.add(ca.Name);
            }
        }

        return returnList;

    }

    @AuraEnabled(cacheable=true)
    public static List<String> setBaseClassificationAttributeValues(String recordId) {

        List<String> returnList = new List<String>();
        String userId = UserInfo.getUserId();
        Id sId = Id.valueOf(recordId);
        String sobjectType = sId.getSObjectType().getDescribe().getName();
        System.debug('sobjectType ==> ' + sobjectType);
        
        String accId;
        if(sobjectType == 'Account'){
            accId = recordId;
        }else if(sobjectType == 'Opportunity'){
            accId = [SELECT AccountId FROM Opportunity WHERE Id = :recordId LIMIT 1].AccountId;
        }

        String opCo = [SELECT OperatingCompany__c FROM Account WHERE Id = :accId LIMIT 1].OperatingCompany__c;
        String attributeValueQuery = 'SELECT Id, Name FROM ClassificationAttributeValue__c WHERE Active__c = true AND ObjectName__c = \'Contact\' AND OperatingCompany__c = \'' + opCo + '\' ORDER BY Name';

        System.debug('setBaseClassificationAttributeValues query ==> ' + attributeValueQuery);
        List<ClassificationAttributeValue__c> cavLst = Database.query(attributeValueQuery);

        for (ClassificationAttributeValue__c cav : cavLst) {
            if (!returnList.contains(cav.Name)) {
                returnList.add(cav.Name);
            }
        }

        return returnList;

    }

    @AuraEnabled(cacheable=true)
    public static List<String> getBaseClassificationAttributeValuesBasedOnAttribute(String recordId, String attributeName) {

        List<String> returnList = new List<String>();
        String userId = UserInfo.getUserId();
        Id sId = Id.valueOf(recordId);
        String sobjectType = sId.getSObjectType().getDescribe().getName();
        System.debug('sobjectType ==> ' + sobjectType);
        
        String accId;
        if(sobjectType == 'Account'){
            accId = recordId;
        }else if(sobjectType == 'Opportunity'){
            accId = [SELECT AccountId FROM Opportunity WHERE Id = :recordId LIMIT 1].AccountId;
        }

        String opCo = [SELECT OperatingCompany__c FROM Account WHERE Id = :accId LIMIT 1].OperatingCompany__c;
        String attributeValueQuery = 'SELECT Id, Name FROM ClassificationAttributeValue__c WHERE Active__c = true AND ClassificationAttribute__r.Name = \'' + attributeName + '\' AND ObjectName__c = \'Contact\' AND OperatingCompany__c = \'' + opCo + '\' ORDER BY Name';

        System.debug('getBaseClassificationAttributeValuesBasedOnAttribute query ==> ' + attributeValueQuery);
        List<ClassificationAttributeValue__c> cavLst = Database.query(attributeValueQuery);

        for (ClassificationAttributeValue__c cav : cavLst) {
            if (!returnList.contains(cav.Name)) {
                returnList.add(cav.Name);
            }
        }

        return returnList;

    }
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> searchContact(String recordId, String attributeName, String attributeValueName) {
    System.debug('CON_contactFilterHelper.searchContact(recordId: ' + recordId + ', attributeName: ' + attributeName + ', attributeValueName: ' + attributeValueName + ')');

        String userId = UserInfo.getUserId();
        String sobjectType;

        List<Id> availableContactIdList = new List<Id>();
        List<Contact> availableContacts = new List<Contact>();
        List<Contact> contactsToReturn = new List<Contact>();

        if (recordId != null) {
            Id sId = Id.valueOf(recordId);
            sobjectType = sId.getSObjectType().getDescribe().getName();
            System.debug('sobjectType ==> ' + sobjectType);

            if (sobjectType == 'Account') {

                // ACCOUNT SPECIFIC
                List<AccountContactRelation> acrLst = [SELECT ContactId FROM AccountContactRelation WHERE AccountId = :recordId];
                for (AccountContactRelation acr : acrLst) {
                    availableContactIdList.add(acr.ContactId);
                }

            } else if (sobjectType == 'Opportunity') {
                
                // OPPORTUNITY SPECIFIC
                Set<Id> opportunityContactIds = new Set<Id>();
                for (OpportunityContactRole ocr : [SELECT ContactId FROM OpportunityContactRole WHERE OpportunityId = :recordId]) {
                    opportunityContactIds.add(ocr.ContactId);
                }
                Opportunity opportunity = [SELECT ContactId FROM Opportunity WHERE Id = :recordId LIMIT 1];
                if (opportunityContactIds.contains(opportunity.ContactId)) {
                    opportunityContactIds.add(opportunity.ContactId);
                }
                availableContactIdList.addAll(opportunityContactIds);
            }
            
            availableContacts.addAll([SELECT Id, Name, Phone, Email, IsInactive__c FROM Contact WHERE Id IN :availableContactIdList]);
        }
        
        String accId;
        if(sobjectType == 'Account'){
            accId = recordId;
        }else if(sobjectType == 'Opportunity'){
            accId = [SELECT AccountId FROM Opportunity WHERE Id = :recordId LIMIT 1].AccountId;
        }

        String opCo = [SELECT OperatingCompany__c FROM Account WHERE Id = :accId LIMIT 1].OperatingCompany__c;
        String classificationDataQuery = 'SELECT Id, Contact__c FROM ClassificationData__c WHERE Contact__c IN :availableContactIdList AND Active__c = true AND OperatingCompany__c = \'' + opCo + '\'';
        

        if (attributeName != null && attributeName != '') {
            classificationDataQuery += ' AND ClassificationAttribute__r.Name = \'' + attributeName + '\'';
        }
        if (attributeValueName != null && attributeValueName != '') {
            classificationDataQuery += ' AND (ClassificationAttributeValue__r.Name = \'' + attributeValueName + '\'';
            classificationDataQuery += ' OR ClassificationAttributeSubValue__r.Name = \'' + attributeValueName + '\'';
            classificationDataQuery += ' OR ClassificationAttributeSubValue2__r.Name = \'' + attributeValueName + '\'';
            classificationDataQuery += ' OR ClassificationAttributeSubValue3__r.Name = \'' + attributeValueName + '\'';
            classificationDataQuery += ' OR ClassificationAttributeSubValue4__r.Name = \'' + attributeValueName + '\')';
        }
        
        System.debug('classificationDataQuery ==> ' + classificationDataQuery);
        List<ClassificationData__c> cdLst = Database.query(classificationDataQuery);

        Set<Id> classificationContactIdSet = new Set<Id>();
        for (ClassificationData__c cd : cdLst) {
            classificationContactIdSet.add(cd.Contact__c);
        }

        Set<Id> contactIdSet = new Set<Id>();

        if (recordId != null) {
            Id sId = Id.valueOf(recordId);
            sobjectType = sId.getSObjectType().getDescribe().getName();
            System.debug('sobjectType ==> ' + sobjectType);

            if (sobjectType == 'Account') {

                // ACCOUNT SPECIFIC
                List<AccountContactRelation> acrLst = [SELECT ContactId FROM AccountContactRelation WHERE ContactId IN :classificationContactIdSet AND AccountId = :recordId];
                for (AccountContactRelation acr : acrLst) {
                    contactIdSet.add(acr.ContactId);
                }

            } else if (sobjectType == 'Opportunity') {
                
                // OPPORTUNITY SPECIFIC
                Set<Id> opportunityContactIds = new Set<Id>();
                for (OpportunityContactRole ocr : [SELECT ContactId FROM OpportunityContactRole WHERE ContactId IN :classificationContactIdSet AND OpportunityId = :recordId]) {
                    opportunityContactIds.add(ocr.ContactId);
                }
                Opportunity opportunity = [SELECT ContactId FROM Opportunity WHERE Id = :recordId LIMIT 1];
                if (classificationContactIdSet.contains(opportunity.ContactId)) {
                    opportunityContactIds.add(opportunity.ContactId);
                }
                contactIdSet.addAll(opportunityContactIds);
            }
            
            contactsToReturn.addAll([SELECT Id, Name, Phone, Email, IsInactive__c FROM Contact WHERE Id IN :contactIdSet]);
        } else {
            contactsToReturn = [SELECT Id, Name, Phone, Email, IsInactive__c FROM Contact WHERE Id IN :classificationContactIdSet];
        }

        if ((attributeName == null || attributeName == '') && (attributeValueName == null || attributeValueName == '')) {
            contactsToReturn = availableContacts;
        }

        System.debug('contactsToReturn.size() ==> ' + contactsToReturn.size());
        return contactsToReturn;
    }

    @AuraEnabled (cacheable=true)
    public static List<Contact> fetchContacts(String currentRecordId, String searchKey){
        System.debug('fetchContacts recordId ==> ' + currentRecordId + ' . fetchContacts searchKey ==> ' + searchKey);

        List<Id> availableContactIdList = new List<Id>();
        Id sId = Id.valueOf(currentRecordId);
        String sobjectType = sId.getSObjectType().getDescribe().getName();
        System.debug('sobjectType ==> ' + sobjectType);

        if (sobjectType == 'Account') {
            // ACCOUNT SPECIFIC
            List<AccountContactRelation> acrLst = [SELECT ContactId FROM AccountContactRelation WHERE AccountId = :currentRecordId];
            for (AccountContactRelation acr : acrLst) {
                availableContactIdList.add(acr.ContactId);
            }

        } else if (sobjectType == 'Opportunity') {
            // OPPORTUNITY SPECIFIC
            Set<Id> opportunityContactIds = new Set<Id>();
            for (OpportunityContactRole ocr : [SELECT ContactId FROM OpportunityContactRole WHERE OpportunityId = :currentRecordId]) {
                opportunityContactIds.add(ocr.ContactId);
            }
            availableContactIdList.addAll(opportunityContactIds);
        }

        List <Contact> contactList = new List<Contact>();
        String strgkeyword = '%'+searchKey+'%';
        String query = 'SELECT Id, Name, Phone, Email, IsInactive__c FROM Contact WHERE Id IN :availableContactIdList' ;
        if(!String.isEmpty(searchKey)){
            query += ' AND (Name LIKE \'%'+searchKey+'%\' OR Email LIKE \'%'+searchKey+'%\' OR Phone LIKE \'%'+searchKey+'%\')';
        }
        System.debug('fetchContacts query ==> ' + query);
        contactList = Database.query(query);
        System.debug('contactList ==> ' + contactList.size());
        return contactList;
    }

}