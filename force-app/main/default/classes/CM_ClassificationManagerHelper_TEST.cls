@isTest
public class CM_ClassificationManagerHelper_TEST {
    
    @TestSetup
    static void makeData() {
        Account acc = CM_TestDatafactory.createAccount(true);
        Contact con = CM_TestDatafactory.createContact(acc, true);
        List<ClassificationAttribute__c> caLst = CM_TestDatafactory.createClassificationAttribute(true);
        List<ClassificationAttributeValue__c> cav1Lst = CM_TestDatafactory.createClassificationAttributeValue(caLst, true);
        List<ClassificationAttributeValue__c> cav2Lst = CM_TestDatafactory.createClassificationAttributeValueWithParent(cav1Lst, true);
        List<ClassificationData__c> cdLst = CM_TestDatafactory.createClassificationData(con, cav1Lst, true);
    }

    @IsTest
    static void TestGetClassificationAttrionAttributes() {
        
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
            List<ClassificationAttribute__c> conCaLst = CM_ClassificationManagerHelper.getClassificationAttributes(String.ValueOf(con.Id));
            List<ClassificationAttribute__c> accCaLst = CM_ClassificationManagerHelper.getClassificationAttributes(String.ValueOf(acc.Id));
        Test.stopTest();
        
        System.assertEquals(1, conCaLst.size());
        System.assertEquals(1, accCaLst.size());

    }

    @IsTest
    static void TestGetClassificationAttributeValuesByAttributeId(){
        
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        ClassificationAttribute__c conCav = [SELECT Id FROM ClassificationAttribute__c WHERE ObjectName__c = 'Contact'];
        ClassificationAttribute__c accCav = [SELECT Id FROM ClassificationAttribute__c WHERE ObjectName__c = 'Account'];

        Test.startTest();
            List<ClassificationAttributeValue__c> conCavLst = CM_ClassificationManagerHelper.getClassificationAttributeValueByAttributeId(String.valueOf(conCav.Id), String.ValueOf(con.Id));
            List<ClassificationAttributeValue__c> accCavLst = CM_ClassificationManagerHelper.getClassificationAttributeValueByAttributeId(String.valueOf(accCav.Id), String.ValueOf(acc.Id));
        Test.stopTest();
        
        System.assertEquals(1, conCavLst.size());
        System.assertEquals(1, accCavLst.size());

    }

    @IsTest
    static void TestGetClassificationAttributeValueByParentId(){
        
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        ClassificationAttributeValue__c conCav = [SELECT Id FROM ClassificationAttributeValue__c WHERE ObjectName__c = 'Contact' AND ClassificationAttributeValue__c = null];
        ClassificationAttributeValue__c accCav = [SELECT Id FROM ClassificationAttributeValue__c WHERE ObjectName__c = 'Account' AND ClassificationAttributeValue__c = null];

        Test.startTest();
            List<ClassificationAttributeValue__c> conCavLst = CM_ClassificationManagerHelper.getClassificationAttributeValueByParentId(String.ValueOf(conCav.Id), String.valueOf(con.Id));
            List<ClassificationAttributeValue__c> accCavLst = CM_ClassificationManagerHelper.getClassificationAttributeValueByParentId(String.valueOf(accCav.Id), String.valueOf(acc.Id));
        Test.stopTest();
        
        System.assertEquals(1, conCavLst.size());
        System.assertEquals(1, accCavLst.size());

    }

    @IsTest
    static void TestCreateClassificationDataShouldSucceed(){
        
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<ClassificationAttributeValue__c> cavLst = [SELECT Id, ObjectName__c, ClassificationAttributeValue__c, ClassificationAttribute__c FROM ClassificationAttributeValue__c WHERE ClassificationAttributeValue__c != null];
        String ContactResult = '';
        String AccountResult = '';

        System.assertEquals(2, cavLst.size());

        Test.startTest();
            for (ClassificationAttributeValue__c cav : cavLst) {
                String recordId = '';
                String AttributeId = String.valueOf(cav.ClassificationAttribute__c);
                String AttributeValueId = String.valueOf(cav.ClassificationAttributeValue__c);
                String AttributeValue2Id = String.valueOf(cav.Id);
                String AttributeValue3Id ='';
                String AttributeValue4Id = '';
                String yearValue = '';
                String gradeValue  = '';
                String studentNumberValue = '';

                if (cav.ObjectName__c == 'Contact') {
                    recordId = String.valueOf(con.Id);
                    ContactResult = CM_ClassificationManagerHelper.createClassificationData(recordId, AttributeId, AttributeValueId, AttributeValue2Id, AttributeValue3Id, AttributeValue4Id, yearValue, gradeValue, studentNumberValue);
                } else {
                    recordId = String.valueOf(acc.Id);
                    AccountResult = CM_ClassificationManagerHelper.createClassificationData(recordId, AttributeId, AttributeValueId, AttributeValue2Id, AttributeValue3Id, AttributeValue4Id, yearValue, gradeValue, studentNumberValue);
                }
            }
        Test.stopTest();

        System.assertEquals(4, [SELECT COUNT() FROM ClassificationData__c]);
        System.assertEquals('Succesfully created the Classification Data Record.', ContactResult);
        System.assertEquals('Succesfully created the Classification Data Record.', AccountResult);
        
    }

    @IsTest
    static void TestCreateClassificationDataShouldBeDuplicate(){
        
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<ClassificationAttributeValue__c> cavLst = [SELECT Id, ObjectName__c, ClassificationAttributeValue__c, ClassificationAttribute__c FROM ClassificationAttributeValue__c WHERE ClassificationAttributeValue__c != null];
        String ContactResult = '';
        String AccountResult = '';

        System.assertEquals(2, cavLst.size());

        Test.startTest();
            for (ClassificationAttributeValue__c cav : cavLst) {
                String recordId = '';
                String AttributeId = String.valueOf(cav.ClassificationAttribute__c);
                String AttributeValueId = String.valueOf(cav.ClassificationAttributeValue__c);
                String AttributeValue2Id = '';
                String AttributeValue3Id ='';
                String AttributeValue4Id = '';
                String yearValue = '';
                String gradeValue  = '';
                String studentNumberValue = '';

                if (cav.ObjectName__c == 'Contact') {
                    recordId = String.valueOf(con.Id);
                    ContactResult = CM_ClassificationManagerHelper.createClassificationData(recordId, AttributeId, AttributeValueId, AttributeValue2Id, AttributeValue3Id, AttributeValue4Id, yearValue, gradeValue, studentNumberValue);
                } else {
                    recordId = String.valueOf(acc.Id);
                    AccountResult = CM_ClassificationManagerHelper.createClassificationData(recordId, AttributeId, AttributeValueId, AttributeValue2Id, AttributeValue3Id, AttributeValue4Id, yearValue, gradeValue, studentNumberValue);
                }
            }
        Test.stopTest();

        System.assertEquals(2, [SELECT COUNT() FROM ClassificationData__c]);
        System.assertEquals('We have already found this ClassificationData on this Contact', ContactResult);
        System.assertEquals('We have already found this ClassificationData on this Account', AccountResult);
        
    }

    @IsTest
    static void TestCreateClassificationDataEmpty(){
        
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<ClassificationAttributeValue__c> cavLst = [SELECT Id, ObjectName__c, ClassificationAttributeValue__c, ClassificationAttribute__c FROM ClassificationAttributeValue__c WHERE ClassificationAttributeValue__c != null];
        String ContactResult = '';
        String AccountResult = '';

        System.assertEquals(2, cavLst.size());

        Test.startTest();
            for (ClassificationAttributeValue__c cav : cavLst) {
                String recordId = '';
                String AttributeId = '';
                String AttributeValueId = '';
                String AttributeValue2Id = '';
                String AttributeValue3Id ='';
                String AttributeValue4Id = '';
                String yearValue = '';
                String gradeValue  = '';
                String studentNumberValue = '';

                if (cav.ObjectName__c == 'Contact') {
                    recordId = String.valueOf(con.Id);
                    ContactResult = CM_ClassificationManagerHelper.createClassificationData(recordId, AttributeId, AttributeValueId, AttributeValue2Id, AttributeValue3Id, AttributeValue4Id, yearValue, gradeValue, studentNumberValue);
                } else {
                    recordId = String.valueOf(acc.Id);
                    AccountResult = CM_ClassificationManagerHelper.createClassificationData(recordId, AttributeId, AttributeValueId, AttributeValue2Id, AttributeValue3Id, AttributeValue4Id, yearValue, gradeValue, studentNumberValue);
                }
            }
        Test.stopTest();

        System.assertEquals(2, [SELECT COUNT() FROM ClassificationData__c]);
        System.assertEquals('Please select at least one value', ContactResult);
        System.assertEquals('Please select at least one value', AccountResult);
        
    }

}