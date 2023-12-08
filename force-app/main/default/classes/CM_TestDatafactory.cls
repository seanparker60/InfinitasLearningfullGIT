@isTest
public class CM_TestDatafactory {
    
    public static Account createAccount(Boolean doInsert) {
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.OperatingCompany__c = 'Plantyn';
        acc.Area__c = 'Dutch';

        if (doInsert) {
            insert acc;
        }
        return acc;
    }
    
    public static Contact createContact(Account acc, Boolean doInsert) {
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.OperatingCompany__c = 'Plantyn';
        con.AccountId = acc.Id;

        if (doInsert) {
            insert con;
        }
        return con;
    }

    public static List<ClassificationAttribute__c> createClassificationAttribute(Boolean doInsert) {
        
        List<ClassificationAttribute__c> caLst = new List<ClassificationAttribute__c>();

        ClassificationAttribute__c ca1 = new ClassificationAttribute__c();
        ca1.Name = 'Test Contact ClassificationAttribute';
        ca1.OperatingCompany__c = 'Plantyn';
        ca1.ObjectName__c = 'Contact';

        ClassificationAttribute__c ca2 = new ClassificationAttribute__c();
        ca2.Name = 
        ca2.OperatingCompany__c = 'Plantyn';
        ca2.ObjectName__c = 'Account';

        caLst.add(ca1);
        caLst.add(ca2);

        if (doInsert) {
            insert caLst;
        }
        return caLst;
    }

    public static List<ClassificationAttributeValue__c> createClassificationAttributeValue(List<ClassificationAttribute__c> caLst, Boolean doInsert) {
        
        List<ClassificationAttributeValue__c> cavLst = new List<ClassificationAttributeValue__c>();
        
        for (ClassificationAttribute__c ca : caLst) {
            ClassificationAttributeValue__c cav = new ClassificationAttributeValue__c();
            cav.Name = ca.ObjectName__c + ' Test ClassificationAttributeValue';
            cav.ClassificationAttribute__c = ca.Id;
            cav.ObjectName__c = ca.ObjectName__c;
            cav.OperatingCompany__c = ca.OperatingCompany__c;
            cav.Active__c = true;
            cavLst.add(cav);
        }
        

        if (doInsert) {
            insert cavLst;
        }
        return cavLst;
    }

    public static List<ClassificationAttributeValue__c> createClassificationAttributeValueWithParent(List<ClassificationAttributeValue__c> cavLst, Boolean doInsert) {
        
        List<ClassificationAttributeValue__c> cavInsertLst = new List<ClassificationAttributeValue__c>();
        for (ClassificationAttributeValue__c cav : cavLst) {
            ClassificationAttributeValue__c newCav = new ClassificationAttributeValue__c();
            newCav.Name = 'Test ClassificationAttributeValue';
            newCav.ClassificationAttribute__c = cav.ClassificationAttribute__c;
            newCav.ClassificationAttributeValue__c = cav.Id;
            newCav.ObjectName__c = cav.ObjectName__c;
            newCav.OperatingCompany__c = cav.OperatingCompany__c;
            newCav.Active__c = true;
            cavInsertLst.add(newCav);
        }

        if (doInsert) {
            insert cavInsertLst;
        }
        return cavInsertLst;
    }

    public static List<ClassificationData__c> createClassificationData(Contact con, List<ClassificationAttributeValue__c> cavLst, Boolean doInsert) {
        
        List<ClassificationData__c> cdLst = new List<ClassificationData__c>();
        for (ClassificationAttributeValue__c cav : cavLst) {
            ClassificationData__c cd = new ClassificationData__c();
            cd.ClassificationAttribute__c = cav.ClassificationAttribute__c;
            cd.ClassificationAttributeValue__c = cav.Id;
            cd.OperatingCompany__c = cav.OperatingCompany__c;
            if (cav.ObjectName__c == 'Contact') {
                cd.Contact__c = con.Id;
            } else {
                cd.Account__c = con.AccountId;
            }
            cdLst.add(cd);
        }

        if (doInsert) {
            insert cdLst;
        }
        return cdLst;
    }

}