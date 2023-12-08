public class CM_ClassificationManagerHelper {

@AuraEnabled(cacheable=true)
    public static List<ClassificationAttribute__c> getClassificationAttributes (String recordId) {
        System.debug(LoggingLevel.INFO, 'CM_ClassificationManagerHelper - getClassificationAttributes ('+ recordId + ')');

        String OpCo = GetOperatingCompany(recordId);
        String objectName = Id.ValueOf(recordId).getSObjectType().getDescribe().getName();

        return [SELECT Id, Name FROM ClassificationAttribute__c WHERE OperatingCompany__c = :OpCo AND ObjectName__c = :objectName ORDER BY Name];
    }

@AuraEnabled(cacheable=true)
    public static List<ClassificationAttributeValue__c> getClassificationAttributeValueByAttributeId (Id attributeId, String recordId) {
        System.debug(LoggingLevel.INFO, 'CM_ClassificationManagerHelper - getClassificationAttributeValueByAttributeId (' + attributeId + ', ' + recordId + ')');

        String OpCo = GetOperatingCompany(recordId);
        String objectName = Id.ValueOf(recordId).getSObjectType().getDescribe().getName();

        return [SELECT Id, Name FROM ClassificationAttributeValue__c WHERE OperatingCompany__c = :OpCo AND ClassificationAttribute__c = :attributeId AND ClassificationAttributeValue__c = null AND ObjectName__c = :objectName AND Active__c = true ORDER BY Name];
    }

@AuraEnabled(cacheable=true)
    public static List<ClassificationAttributeValue__c> getClassificationAttributeValueByParentId (Id parentId, String recordId) {
        System.debug(LoggingLevel.INFO, 'CM_ClassificationManagerHelper - getClassificationAttributeValueByParentId (' + parentId + ', ' + recordId + ')');
        
        String OpCo = GetOperatingCompany(recordId);
        String objectName = Id.ValueOf(recordId).getSObjectType().getDescribe().getName();

        return [SELECT Id, Name FROM ClassificationAttributeValue__c WHERE OperatingCompany__c = :OpCo AND ClassificationAttributeValue__c = :parentId AND ObjectName__c = :objectName AND Active__c = true ORDER BY Name];
    }

@AuraEnabled
    public static String createClassificationData(String recordId, String AttributeId, String AttributeValueId, String AttributeValue2Id, String AttributeValue3Id, String AttributeValue4Id, String yearValue, String gradeValue, String studentNumberValue){
        System.debug(LoggingLevel.INFO, 'CM_ClassificationManagerHelper - createClassificationData (' + recordId + ', ' + AttributeId + ',' + AttributeValueId + ',' + ',' + AttributeValue2Id + ',' + AttributeValue3Id + ',' + AttributeValue4Id + ',' + yearValue + ',' + gradeValue + ')');

        Boolean createData = true;
        String result = '';
        String objectName = Id.ValueOf(recordId).getSObjectType().getDescribe().getName();

        String attributeName;
        String value1Name = 'Unknown';
        String value2Name;
        String value3Name;
        String value4Name;
        
        String aId;
        String avId;
        String asvId;
        String as2vId;
        String as3vId;

        String queryExistingClassificationData = 'SELECT Id FROM ClassificationData__c WHERE ';

        if (AttributeId.length() > 1) {
            value1Name = [SELECT Name FROM ClassificationAttribute__c WHERE Id = :AttributeId LIMIT 1].Name;
            queryExistingClassificationData += 'ClassificationAttribute__c = \'' + AttributeId + '\' AND ';
        } else {
            queryExistingClassificationData += 'ClassificationAttribute__c = null AND ';
        }
        if (AttributeValueId.length() > 1) {
            queryExistingClassificationData += 'ClassificationAttributeValue__c = \'' + AttributeValueId + '\' AND ';
        } else {
            queryExistingClassificationData += 'ClassificationAttributeValue__c = null AND ';
        }
        if (AttributeValue2Id.length() > 1) {
            queryExistingClassificationData += 'ClassificationAttributeSubValue__c = \'' + AttributeValue2Id + '\' AND ';
        } else {
            queryExistingClassificationData += 'ClassificationAttributeSubValue__c = null AND ';
        }
        if (AttributeValue3Id.length() > 1) {
            queryExistingClassificationData += 'ClassificationAttributeSubValue2__c = \'' + AttributeValue3Id + '\' AND ';
        } else {
            queryExistingClassificationData += 'ClassificationAttributeSubValue2__c = null AND ';
        }
        if (AttributeValue4Id.length() > 1) {
            queryExistingClassificationData += 'ClassificationAttributeSubValue3__c = \'' + AttributeValue4Id + '\'';
        } else {
            queryExistingClassificationData += 'ClassificationAttributeSubValue3__c = null';
        }

        if (objectName == 'Contact') {
            queryExistingClassificationData += ' AND Contact__c = \'' + recordId + '\'';
        } else {
            queryExistingClassificationData += ' AND Account__c = \'' + recordId + '\'';
        }

        System.debug('query = ' + queryExistingClassificationData);
        List<ClassificationData__c> cdLst = Database.query(queryExistingClassificationData);
        
        if (cdLst.size() > 0) {
            result = 'We have already found this ClassificationData on this ' + objectName;
            createData = false;
        } else {
            ClassificationData__c cd = new ClassificationData__c();
            cd.Name = value1Name;
            cd.Active__c = true;
            cd.OperatingCompany__c = GetOperatingCompany(recordId);
            if (AttributeId.length() > 1) {
                cd.ClassificationAttribute__c = AttributeId;
            } else {
                createData = false;
                result = 'Please select at least one value';
            }
            if (AttributeValueId.length() > 1) {
                cd.ClassificationAttributeValue__c = AttributeValueId;
            }
            if (AttributeValue2Id.length() > 1) {
                cd.ClassificationAttributeSubValue__c = AttributeValue2Id;
            }
            if (AttributeValue3Id.length() > 1) {
                cd.ClassificationAttributeSubValue2__c = AttributeValue3Id;
            }
            if (AttributeValue4Id.length() > 1) {
                cd.ClassificationAttributeSubValue3__c = AttributeValue4Id;
            }

            if (objectName == 'Contact') {
                cd.Contact__c = recordId;
                if (yearValue.length() > 0) {
                    cd.SchoolYear__c = yearValue;
                }
                if (gradeValue.length() > 0) {
                    cd.Grade__c = Decimal.valueOf(gradeValue);
                }
            } else {
                cd.Account__c = recordId;
                if (studentNumberValue.length() > 0) {
                    cd.NumberOfStudents__c = Decimal.ValueOf(studentNumberValue);
                }
            }
            
            if (createData) {
                Database.SaveResult sr = Database.insert(cd, false);
                if (sr.isSuccess()) {
                    result = 'Succesfully created the Classification Data Record.';
                } else {
                    String insertErrors = '';
                    for (Database.Error err : sr.getErrors()) {
                        insertErrors += err.getMessage();
                    }
                    result = 'We encounterd the next errors inserting the Classification Data Record: \n' + insertErrors;
                }
            }
        }
        System.debug('CM_ClassificationManagerHelper result: ' + result);
        return result;
    }

    public static String GetOperatingCompany (String recordId) {

        String objectName = Id.ValueOf(recordId).getSObjectType().getDescribe().getName();

        String OpCo = '';
        if (objectName == 'Contact') {
            OpCo = [SELECT OperatingCompany__c FROM Contact WHERE Id = :recordId LIMIT 1].OperatingCompany__c;
        } else {
            OpCo = [SELECT OperatingCompany__c FROM Account WHERE Id = :recordId LIMIT 1].OperatingCompany__c;
        }
        return OpCo;
    }

}