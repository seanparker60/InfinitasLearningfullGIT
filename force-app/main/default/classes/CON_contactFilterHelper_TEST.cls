@isTest
public  class CON_contactFilterHelper_TEST {
    
    @TestSetup
    static void makeData(){

        Id B2BEdicationalRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('B2B Educational').getRecordTypeId();
        String OpCo = 'Plantyn';

        Account acc = New Account();
        acc.RecordTypeId = B2BEdicationalRecordTypeId;
        acc.Name = 'Test Account';
        acc.OperatingCompany__c = OpCo;
        acc.NumberofStudents__c = 0;
        acc.TypeOfAccount__c = 'Sales';
        acc.Area__c = 'Dutch';
        //acc.CustomerCategory__c = 'Educational Institution';
        insert acc;

        List<Contact> conLst = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            Contact con = New Contact();
            con.FirstName = 'Test';
            con.LastName = 'Contact ' + (i+1);
            con.AccountId = acc.Id;
            con.OperatingCompany__c = OpCo;
            con.Email = (i+1) + 'testEmail@test.com';
            conLst.add(con);
        }
        insert conLst;

        List<ClassificationAttribute__c> caLst = new List<ClassificationAttribute__c>();
        for (Integer i = 0; i < 2; i++) {
            ClassificationAttribute__c ca = new ClassificationAttribute__c();
            ca.Name = 'Test Classification Attribute ' + (i+1);
            ca.ObjectName__c = 'Contact';
            ca.OperatingCompany__c = OpCo;
            caLst.add(ca);
        }
        insert caLst;

        List<ClassificationAttributeValue__c> cavLst = new List<ClassificationAttributeValue__c>();
        for (Integer i = 0; i < 5; i++) {
            ClassificationAttributeValue__c cav = new ClassificationAttributeValue__c();
            cav.Name = 'Test Classification Attribute Value ' + (i+1);
            cav.ClassificationAttribute__c = caLst[0].Id;
            cav.ObjectName__c = 'Contact';
            cav.OperatingCompany__c = OpCo;
            cav.Active__c = true;
            cavLst.add(cav);
        }
        insert cavLst;

        List<ClassificationData__c> cdLst = New List<ClassificationData__c>();
        for (Integer i = 0; i < 5; i++) {
            ClassificationData__c cd = New ClassificationData__c();
            cd.Name = 'Test ClassificationData ' + (i+1);
            if (i < 3) {
                cd.ClassificationAttribute__c = caLst[0].Id;
            } else {
                cd.ClassificationAttribute__c = caLst[1].Id;
            }
            cd.Contact__c = conLst[i].Id;
            cd.ClassificationAttributeValue__c = cavLst[i].Id;
            cd.OperatingCompany__c = OpCo;
            cd.Active__c = true;
            cdLst.Add(cd);
        }
        insert cdLst;

        Opportunity testOpp = new Opportunity();
        testOpp.Name = 'Test Opportunity';
        testOpp.AccountId = acc.Id;
        testOpp.CloseDate = System.today();
        testOpp.StageName = 'First Contact';
        testOpp.ContactId = conLst[0].Id;
        insert testOpp;
    }

    @IsTest
    static void testSetBaseClassificationAttributes(){
        
        Test.startTest();
            List<String> caLst = CON_contactFilterHelper.setBaseClassificationAttributes(String.valueOf([SELECT Id FROM Account LIMIT 1].Id));
        Test.stopTest();

        System.assertEquals(2, caLst.size());
    }

    @IsTest
    static void testSetBaseClassificationAttributesWithOpportunity(){
        
        Test.startTest();
            List<String> caLst = CON_contactFilterHelper.setBaseClassificationAttributes(String.valueOf([SELECT Id FROM Opportunity LIMIT 1].Id));
        Test.stopTest();

        System.assertEquals(2, caLst.size());
    }

    @IsTest
    static void testSetBaseClassificationAttributeValues(){
        
        Test.startTest();
            List<String> cavLst = CON_contactFilterHelper.setBaseClassificationAttributeValues(String.valueOf([SELECT Id FROM Account LIMIT 1].Id));
        Test.stopTest();

        System.assertEquals(5, cavLst.size());
    }

    @IsTest
    static void testSetBaseClassificationAttributeValuesWithOpportunity(){
        
        Test.startTest();
            List<String> cavLst = CON_contactFilterHelper.setBaseClassificationAttributeValues(String.valueOf([SELECT Id FROM Opportunity LIMIT 1].Id));
        Test.stopTest();

        System.assertEquals(5, cavLst.size());
    }

    @IsTest
    static void testGetBaseClassificationAttributeValuesBasedOnAttribute(){
        
        Test.startTest();
            List<String> cavLst = CON_contactFilterHelper.getBaseClassificationAttributeValuesBasedOnAttribute(String.valueOf([SELECT Id FROM Account LIMIT 1].Id), 'Test Classification Attribute 1');
        Test.stopTest();

        System.assertEquals(5, cavLst.size());
    }

    @IsTest
    static void testGetBaseClassificationAttributeValuesBasedOnAttributeWithOpportunity(){
        
        Test.startTest();
            List<String> cavLst = CON_contactFilterHelper.getBaseClassificationAttributeValuesBasedOnAttribute(String.valueOf([SELECT Id FROM Opportunity LIMIT 1].Id), 'Test Classification Attribute 1');
        Test.stopTest();

        System.assertEquals(5, cavLst.size());
    }

    @IsTest
    static void testSearchContact1(){
        
        Test.startTest();
            List<Contact> conLst = CON_contactFilterHelper.searchContact(String.valueOf([SELECT Id FROM Account LIMIT 1].Id), '', '');
        Test.stopTest();

        System.assertEquals(5, conLst.size());
    }

    @IsTest
    static void testSearchContact2(){
        
        Test.startTest();
            List<Contact> conLst = CON_contactFilterHelper.searchContact(String.valueOf([SELECT Id FROM Account LIMIT 1].Id), 'Test Classification Attribute 1', '');
        Test.stopTest();

        System.assertEquals(3, conLst.size());
    }

    @IsTest
    static void testSearchContact3(){
        
        Test.startTest();
            List<Contact> conLst = CON_contactFilterHelper.searchContact(String.valueOf([SELECT Id FROM Account LIMIT 1].Id), 'Test Classification Attribute 1', 'Test Classification Attribute Value 1');
        Test.stopTest();

        System.assertEquals(1, conLst.size());
    }

    @IsTest
    static void testSearchContact4(){
        
        List<Contact> conLst = New List<Contact>();
        Test.startTest();
            conLst = CON_contactFilterHelper.searchContact(String.valueOf([SELECT Id FROM Account LIMIT 1].Id), 'Test Classification Attribute 1', 'Test Classification Attribute Value 5');
        Test.stopTest();

        System.assertEquals(0, conLst.size());
    }

    @IsTest
    static void testSearchContactWithOpportunity(){
        
        Test.startTest();
            List<Contact> conLst = CON_contactFilterHelper.searchContact(String.valueOf([SELECT Id FROM Opportunity LIMIT 1].Id), '', '');
        Test.stopTest();

        System.assertEquals(1, conLst.size());
    }

    @IsTest
    static void testFetchContacts(){
        
        List<Contact> conLst = New List<Contact>();
        Test.startTest();
            conLst = CON_contactFilterHelper.fetchContacts(String.valueOf([SELECT Id FROM Account LIMIT 1].Id), 'Test Contact');
        Test.stopTest();

        System.assertNotEquals(0, conLst.size());
    }

    @IsTest
    static void testFetchContactsWithOpportunity(){
        
        List<Contact> conLst = New List<Contact>();
        Test.startTest();
            conLst = CON_contactFilterHelper.fetchContacts(String.valueOf([SELECT Id FROM Opportunity LIMIT 1].Id), 'Test Contact');
        Test.stopTest();

        System.assertNotEquals(0, conLst.size());
    }
}