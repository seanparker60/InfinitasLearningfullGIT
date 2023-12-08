@isTest
public class MERGE_TestDataFactory {

    public static Id getPlantynUserId() {
        return [SELECT Id FROM User WHERE OperatingCompany__c = 'Plantyn' LIMIT 1].Id;
    }

    public static Id getSystemUserId() {
        return [SELECT Id FROM User WHERE Name = 'System User' LIMIT 1].Id;
    }
    
    public static List<Account> createAccounts(integer count, Boolean doinsert) {
        
        List<Account> Accounts = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            Account a = new Account();
            a.Name = 'Parent Test Account ' + (i + 1);
            a.OperatingCompany__c = 'Plantyn';
            a.Area__c = 'Dutch';
            accounts.add(a);
        }
        if (doinsert) {
            insert accounts;
        }

        return accounts;
    }

    public static List<Account> createAccountsForAccountMatchTest1(integer count, List<Account> accountLst, Boolean doinsert) {

        List<Account> Accounts = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            Account a = new Account();
            a.Name = 'Test Account ' + (i + 1);
            a.NumberofStudents__c = 0;
            a.ExternalCustomerId__c = '123456789';
            a.ShippingCity = 'Antwerpen';
            a.ShippingStreet = 'TestStraat 1';
            a.Type = 'School';
            a.OperatingCompany__c = 'Plantyn';
            a.Area__c = 'Dutch';
            
            if (i == (count - 1)) {
                a.OldAccountId__c = 'abcdefg';
            }
            if (i == 0) {
                a.OwnerId = getPlantynUserId();
                a.Categories__c = 'Top-30';
                a.OldAccountIdOrigin__c = 'IL';
                a.InvoicingEmail__c = 'test@test.com';
                a.LastAgodiUpdate__c = date.today();
                a.ParentId = accountLst[0].Id;
                a.PurchasingGroup__c = accountLst[1].Id;
                a.NumberofStudents__c = 60;
                a.HEStudents__c = 10;
                a.KGStudents__c = 11;
                a.PEStudents__c = 12;
                a.SEStudents__c = 13;
                a.VEStudents__c = 14;
            } else {
                a.OwnerId = getSystemUserId();
            }
            System.debug(LoggingLevel.DEBUG, 'Account to add: ' + a);
            accounts.add(a);
        }
        if (doinsert) {
            insert accounts;
        }

        return accounts;
    }

    public static List<Account> createAccountsForAccountMatchTest2(integer count, List<Account> accountLst, Boolean doinsert) {

        List<Account> Accounts = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            Account a = new Account();
            a.Name = 'Test Account ' + (i + 1);
            a.OldAccountId__c = 'hijklmno';
            a.OldAccountIdOrigin__c = 'IL';
            a.OperatingCompany__c = 'Plantyn';
            a.Area__c = 'Dutch';
            a.NumberofStudents__c = 0;
            if (i == (count - 1)) {
                a.OwnerId = getPlantynUserId();
                a.Categories__c = 'A';
                a.OldAccountId__c = 'abcdefg';
                a.ExternalCustomerId__c = '987654321';
                a.OldAccountIdOrigin__c = 'IL';
                a.InvoicingEmail__c = 'test@test.com';
                a.LastAgodiUpdate__c = date.today();
                a.ParentId = accountLst[0].Id;
                a.PurchasingGroup__c = accountLst[1].Id;
                a.NumberofStudents__c = 60;
                a.HEStudents__c = 10;
                a.KGStudents__c = 11;
                a.PEStudents__c = 12;
                a.SEStudents__c = 13;
                a.VEStudents__c = 14;
            } else {
                a.OwnerId = getSystemUserId();
            }
            System.debug(LoggingLevel.DEBUG, 'Account to add: ' + a);
            accounts.add(a);
        }
        if (doinsert) {
            insert accounts;
        }

        return accounts;
    }

    public static List<Contact> createContactsForEmailMatchingOnTeacherSchoolNumber(integer numberOfContactsPerAccount, List<Account> accounts, Boolean doInsert) {
        
        List<Contact> contacts = new List<Contact>();
        Integer accountCounter = 1;
        for (Account account : accounts) {
            Integer contactCounter = 1;
            for (Integer i = 0; i < numberOfContactsPerAccount; i++) {
                String commLang = 'Dutch';
                String opCo = 'Noordhoff';
                String country = 'Netherlands';
                if (accountCounter == 3) {
                    commLang = 'English';
                    opCo = 'Plantyn';
                    country = 'Belgium';
                }
                Contact c = new Contact();
                c.FirstName = 'Test';
                c.LastName = 'Contact ' + (i + 1);
                c.Email = 'email@test.com';
                c.TeacherSchoolNumber__c = '123456789';
                c.Accountid = account.Id;
                //if (accountCounter != 1) {
                    c.Phone = '1234567890';
                    c.MobilePhone = '0897564321';
                    c.CommunicationLanguage__c = commLang;
                    c.OperatingCompany__c = opCo;
                    c.MailingStreet = 'TestStreet ' + accountCounter + contactCounter;
                    c.MailingCity = 'Test City ' + accountCounter + contactCounter;
                    c.MailingCountry = country;
                //}
                contacts.add(c);
                System.debug('Contact to add: ' + c);
                contactCounter ++;
            }
            accountCounter ++;
        }
        if (doInsert) {
            insert contacts;
        }
        return contacts;
    }

    public static List<Contact> createContactsForManualCheck(integer numberOfContactsPerAccount, List<Account> accounts, Boolean doInsert) {
        
        List<Contact> contacts = new List<Contact>();
        Integer accountCounter = 1;
        for (Account account : accounts) {
            Integer contactCounter = 1;
            for (Integer i = 0; i < numberOfContactsPerAccount; i++) {
                String commLang = 'Dutch';
                String opCo = 'Noordhoff';
                String country = 'Netherlands';
                if (accountCounter == 3) {
                    commLang = 'English';
                    opCo = 'Plantyn';
                    country = 'Belgium';
                }
                Contact c = new Contact();
                c.FirstName = 'Test';
                c.LastName = 'Contact ' + (i + 1);
                c.Email = 'email4@test.com';
                c.TeacherSchoolNumber__c = '123456789';
                c.Accountid = account.Id;
                //if (accountCounter != 1) {
                    c.Phone = '1234567' + accountCounter + contactCounter;
                    c.MobilePhone = '7654321' + accountCounter + contactCounter;
                    c.CommunicationLanguage__c = commLang;
                    c.OperatingCompany__c = opCo;
                    c.MailingStreet = 'TestStreet ' + accountCounter + contactCounter;
                    c.MailingCity = 'Test City ' + accountCounter + contactCounter;
                    c.MailingCountry = country;
                //}
                contacts.add(c);
                System.debug('Contact to add: ' + c);
                contactCounter ++;
            }
            accountCounter ++;
        }
        if (doInsert) {
            insert contacts;
        }
        return contacts;
    }

    public static List<Contact> createContactsForEmailMatchingOnAccount(integer count, Account account, Boolean doInsert) {

        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < count; i++) {
            Contact c = new Contact();
            c.FirstName = 'Test2';
            c.LastName = 'Contact2 ' + (i + 1);
            c.Email = 'email2@test.com';
            c.AccountId = account.Id;
            c.OperatingCompany__c = 'Plantyn';
            contacts.add(c);
        }
        if (doInsert) {
            insert contacts;
        }
        return contacts;
    }

    public static List<Contact> createContactsForTeacherNumberMatching(Integer count, List<Account> accounts, Boolean doInsert) {

        List<Contact> contacts = new List<Contact>();
        for (Account account : accounts) {
            for (Integer i = 0; i < count; i++) {
                Contact c = new Contact();
                c.FirstName = 'Test3';
                c.LastName = 'Test3 ' + (i + 1);
                c.Email = 'email3@test.com';
                c.TeacherNumber__c = '987654321';
                c.AccountId = account.Id;
                c.OperatingCompany__c = 'Plantyn';
                contacts.add(c);
            }
        }
        if (doInsert) {
            insert contacts;
        }
        return contacts;
    }

    public static Contact createContact(Account account, Boolean doInsert) {
        
        Contact c = new Contact();
        c.FirstName = 'Test';
        c.LastName = 'Name';
        c.Email = 'Testmail@test.com';
        c.AccountId = account.Id;
         if (doInsert) {
            insert c;
         }
         return c;
    }

    public static AccountContactRelation createAccountContactRelations(Account account, Contact contact, Boolean doInsert) {

        AccountContactRelation acr = new AccountContactRelation();
        acr.AccountId = account.Id;
        acr.ContactId = contact.Id;
        System.debug('Creating AccountContactRelation with ContactId: ' + acr.ContactId + ' and AccountId: ' + acr.AccountId);

         if (doInsert) {
            insert acr;
         }
         return acr;
    }

    public static List<Contact> createContactsForClassificationMergeTest(Integer amount, Boolean doInsert) {

        List<Contact> returnList = new List<Contact>();
        Account acc = createAccounts(1,false)[0];
        acc.Name = 'Test Acc';
        insert acc;

        for (Integer i = 0; i < amount; i++) {
            Contact c = new Contact();
            c.FirstName = 'Test ' + (i+1);
            c.LastName = 'Contact';
            c.Email = (i+1) + 'testEmail@test.com';
            c.AccountId = acc.Id;
            c.OperatingCompany__c = 'Plantyn';
            returnList.add(c);
        }

        if (doInsert) {
            insert returnList;
        }

        return returnList;
    }

    public static List<ClassificationData__c> createClassificationDataForContactMergeTest(List<Contact> contacts, Boolean doInsert) {

        ClassificationAttribute__c ca = new ClassificationAttribute__c();
        ca.Name = 'Test ClassificationAttribute';
        ca.ObjectName__c = 'Contact';
        ca.OperatingCompany__c = 'Plantyn';
        insert ca;

        List<ClassificationAttributeValue__c> cav1Lst = new List<ClassificationAttributeValue__c>();
        List<ClassificationAttributeValue__c> cav2Lst = new List<ClassificationAttributeValue__c>();
        List<ClassificationAttributeValue__c> cav3Lst = new List<ClassificationAttributeValue__c>();
        for (Integer i = 0; i < 5; i++) {
            ClassificationAttributeValue__c cav1 = new ClassificationAttributeValue__c();
            cav1.Name = 'Test Active and Inactive ClassificationData ' + (i+1);
            cav1.OperatingCompany__c = 'Plantyn';
            cav1.ObjectName__c = 'Contact';
            cav1.Active__c = true;
            cav1.ClassificationAttribute__c = ca.id;
            cav1Lst.add(cav1);
            ClassificationAttributeValue__c cav2 = new ClassificationAttributeValue__c();
            cav2.Name = 'Test Active ClassificationData ' + (i+1);
            cav2.OperatingCompany__c = 'Plantyn';
            cav2.ObjectName__c = 'Contact';
            cav2.Active__c = true;
            cav2.ClassificationAttribute__c = ca.id;
            cav2Lst.add(cav2);
            ClassificationAttributeValue__c cav3 = new ClassificationAttributeValue__c();
            cav3.Name = 'Test Inactive ClassificationData ' + (i+1);
            cav3.OperatingCompany__c = 'Plantyn';
            cav3.ObjectName__c = 'Contact';
            cav3.Active__c = true;
            cav3.ClassificationAttribute__c = ca.id;
            cav3Lst.add(cav3);
        }
        insert cav1Lst;
        insert cav2Lst;
        insert cav3Lst;

        for (Integer i = 1; i < cav1Lst.size(); i++) {
            cav1Lst[i].ClassificationAttributeValue__c = cav1Lst[i-1].Id;
            cav2Lst[i].ClassificationAttributeValue__c = cav2Lst[i-1].Id;
            cav3Lst[i].ClassificationAttributeValue__c = cav3Lst[i-1].Id;
        }
        update cav1Lst;
        update cav2Lst;
        update cav3Lst;
        
        List<ClassificationData__c> returnList = new List<ClassificationData__c>();

        // Create Classifications for Active + Inactive mergeTest
        ClassificationData__c cd1 = new ClassificationData__c();
        cd1.Name = 'Active & Inactive Test';
        cd1.ClassificationAttribute__c = ca.Id;
        cd1.ClassificationAttributeValue__c = cav1Lst[0].Id;
        cd1.ClassificationAttributeSubValue__c = cav1Lst[1].Id;
        cd1.ClassificationAttributeSubValue2__c = cav1Lst[2].Id;
        cd1.ClassificationAttributeSubValue3__c = cav1Lst[3].Id;
        cd1.ClassificationAttributeSubValue4__c = cav1Lst[4].Id;
        cd1.Contact__c = contacts[0].Id;
        cd1.Active__c = true;
        returnList.add(cd1);
        ClassificationData__c cd2 = new ClassificationData__c();
        cd2.ClassificationAttribute__c = ca.Id;
        cd2.ClassificationAttributeValue__c = cav1Lst[0].Id;
        cd2.ClassificationAttributeSubValue__c = cav1Lst[1].Id;
        cd2.ClassificationAttributeSubValue2__c = cav1Lst[2].Id;
        cd2.ClassificationAttributeSubValue3__c = cav1Lst[3].Id;
        cd2.ClassificationAttributeSubValue4__c = cav1Lst[4].Id;
        cd2.Contact__c = contacts[1].Id;
        cd2.Active__c = false;
        returnList.add(cd2);
        
        // Create Classifications for active mergeTest
        ClassificationData__c cd3 = new ClassificationData__c();
        cd3.ClassificationAttribute__c = ca.Id;
        cd3.ClassificationAttributeValue__c = cav2Lst[0].Id;
        cd3.ClassificationAttributeSubValue__c = cav2Lst[1].Id;
        cd3.ClassificationAttributeSubValue2__c = cav2Lst[2].Id;
        cd3.ClassificationAttributeSubValue3__c = cav2Lst[3].Id;
        cd3.ClassificationAttributeSubValue4__c = cav2Lst[4].Id;
        cd3.Active__c = true;
        cd3.Contact__c = contacts[0].Id;
        returnList.add(cd3);
        ClassificationData__c cd4 = new ClassificationData__c();
        cd4.ClassificationAttribute__c = ca.Id;
        cd4.ClassificationAttributeValue__c = cav2Lst[0].Id;
        cd4.ClassificationAttributeSubValue__c = cav2Lst[1].Id;
        cd4.ClassificationAttributeSubValue2__c = cav2Lst[2].Id;
        cd4.ClassificationAttributeSubValue3__c = cav2Lst[3].Id;
        cd4.ClassificationAttributeSubValue4__c = cav2Lst[4].Id;
        cd4.Active__c = true;
        cd4.Contact__c = contacts[1].Id;
        returnList.add(cd4);

        // Create Classifications for inActive mergeTest
        ClassificationData__c cd5 = new ClassificationData__c();
        cd5.ClassificationAttribute__c = ca.Id;
        cd5.ClassificationAttributeValue__c = cav3Lst[0].Id;
        cd5.ClassificationAttributeSubValue__c = cav3Lst[1].Id;
        cd5.ClassificationAttributeSubValue2__c = cav3Lst[2].Id;
        cd5.ClassificationAttributeSubValue3__c = cav3Lst[3].Id;
        cd5.ClassificationAttributeSubValue4__c = cav3Lst[4].Id;
        cd5.Active__c = false;
        cd5.Contact__c = contacts[0].Id;
        returnList.add(cd5);
        ClassificationData__c cd6 = new ClassificationData__c();
        cd6.ClassificationAttribute__c = ca.Id;
        cd6.ClassificationAttributeValue__c = cav3Lst[0].Id;
        cd6.ClassificationAttributeSubValue__c = cav3Lst[1].Id;
        cd6.ClassificationAttributeSubValue2__c = cav3Lst[2].Id;
        cd6.ClassificationAttributeSubValue3__c = cav3Lst[3].Id;
        cd6.ClassificationAttributeSubValue4__c = cav3Lst[4].Id;
        cd6.Active__c = false;
        cd6.Contact__c = contacts[1].Id;
        returnList.add(cd6);

        if (doInsert) {
            insert returnList;
        }

        return returnList;
    }

    public static List<ClassificationData__c> createClassificationDataForAccounttMergeTest(List<Account> accounts, Boolean doInsert) {

        for (Account acc : accounts) {
            System.debug('Accounts in TestDatafactory ==> ' + acc.Id);
        }

        ClassificationAttribute__c ca = new ClassificationAttribute__c();
        ca.Name = 'Test ClassificationAttribute';
        ca.ObjectName__c = 'Contact';
        ca.OperatingCompany__c = 'Plantyn';
        insert ca;

        List<ClassificationAttributeValue__c> cav1Lst = new List<ClassificationAttributeValue__c>();
        List<ClassificationAttributeValue__c> cav2Lst = new List<ClassificationAttributeValue__c>();
        List<ClassificationAttributeValue__c> cav3Lst = new List<ClassificationAttributeValue__c>();
        for (Integer i = 0; i < 5; i++) {
            ClassificationAttributeValue__c cav1 = new ClassificationAttributeValue__c();
            cav1.Name = 'Test Active and Inactive ClassificationData ' + (i+1);
            cav1.OperatingCompany__c = 'Plantyn';
            cav1.ObjectName__c = 'Account';
            cav1.Active__c = true;
            cav1.ClassificationAttribute__c = ca.id;
            cav1Lst.add(cav1);
            ClassificationAttributeValue__c cav2 = new ClassificationAttributeValue__c();
            cav2.Name = 'Test Active ClassificationData ' + (i+1);
            cav2.OperatingCompany__c = 'Plantyn';
            cav2.ObjectName__c = 'Account';
            cav2.Active__c = true;
            cav2.ClassificationAttribute__c = ca.id;
            cav2Lst.add(cav2);
            ClassificationAttributeValue__c cav3 = new ClassificationAttributeValue__c();
            cav3.Name = 'Test Inactive ClassificationData ' + (i+1);
            cav3.OperatingCompany__c = 'Plantyn';
            cav3.ObjectName__c = 'Account';
            cav3.Active__c = true;
            cav3.ClassificationAttribute__c = ca.id;
            cav3Lst.add(cav3);
        }
        insert cav1Lst;
        insert cav2Lst;
        insert cav3Lst;

        for (Integer i = 1; i < cav1Lst.size(); i++) {
            cav1Lst[i].ClassificationAttributeValue__c = cav1Lst[i-1].Id;
            cav2Lst[i].ClassificationAttributeValue__c = cav2Lst[i-1].Id;
            cav3Lst[i].ClassificationAttributeValue__c = cav3Lst[i-1].Id;
        }
        update cav1Lst;
        update cav2Lst;
        update cav3Lst;
        
        List<ClassificationData__c> returnList = new List<ClassificationData__c>();

        // Create Classifications for Active + Inactive mergeTest
        ClassificationData__c cd1 = new ClassificationData__c();
        cd1.Name = 'Active & Inactive Test';
        cd1.ClassificationAttribute__c = ca.Id;
        cd1.ClassificationAttributeValue__c = cav1Lst[0].Id;
        cd1.ClassificationAttributeSubValue__c = cav1Lst[1].Id;
        cd1.ClassificationAttributeSubValue2__c = cav1Lst[2].Id;
        cd1.ClassificationAttributeSubValue3__c = cav1Lst[3].Id;
        cd1.ClassificationAttributeSubValue4__c = cav1Lst[4].Id;
        cd1.Account__c = accounts[0].Id;
        cd1.Active__c = true;
        returnList.add(cd1);
        ClassificationData__c cd2 = new ClassificationData__c();
        cd2.ClassificationAttribute__c = ca.Id;
        cd2.ClassificationAttributeValue__c = cav1Lst[0].Id;
        cd2.ClassificationAttributeSubValue__c = cav1Lst[1].Id;
        cd2.ClassificationAttributeSubValue2__c = cav1Lst[2].Id;
        cd2.ClassificationAttributeSubValue3__c = cav1Lst[3].Id;
        cd2.ClassificationAttributeSubValue4__c = cav1Lst[4].Id;
        cd2.Account__c = accounts[1].Id;
        cd2.Active__c = false;
        returnList.add(cd2);
        
        // Create Classifications for active mergeTest
        ClassificationData__c cd3 = new ClassificationData__c();
        cd3.ClassificationAttribute__c = ca.Id;
        cd3.ClassificationAttributeValue__c = cav2Lst[0].Id;
        cd3.ClassificationAttributeSubValue__c = cav2Lst[1].Id;
        cd3.ClassificationAttributeSubValue2__c = cav2Lst[2].Id;
        cd3.ClassificationAttributeSubValue3__c = cav2Lst[3].Id;
        cd3.ClassificationAttributeSubValue4__c = cav2Lst[4].Id;
        cd3.Active__c = true;
        cd3.Account__c = accounts[0].Id;
        returnList.add(cd3);
        ClassificationData__c cd4 = new ClassificationData__c();
        cd4.ClassificationAttribute__c = ca.Id;
        cd4.ClassificationAttributeValue__c = cav2Lst[0].Id;
        cd4.ClassificationAttributeSubValue__c = cav2Lst[1].Id;
        cd4.ClassificationAttributeSubValue2__c = cav2Lst[2].Id;
        cd4.ClassificationAttributeSubValue3__c = cav2Lst[3].Id;
        cd4.ClassificationAttributeSubValue4__c = cav2Lst[4].Id;
        cd4.Active__c = true;
        cd4.Account__c = accounts[1].Id;
        returnList.add(cd4);

        // Create Classifications for inActive mergeTest
        ClassificationData__c cd5 = new ClassificationData__c();
        cd5.ClassificationAttribute__c = ca.Id;
        cd5.ClassificationAttributeValue__c = cav3Lst[0].Id;
        cd5.ClassificationAttributeSubValue__c = cav3Lst[1].Id;
        cd5.ClassificationAttributeSubValue2__c = cav3Lst[2].Id;
        cd5.ClassificationAttributeSubValue3__c = cav3Lst[3].Id;
        cd5.ClassificationAttributeSubValue4__c = cav3Lst[4].Id;
        cd5.Active__c = false;
        cd5.Account__c = accounts[0].Id;
        returnList.add(cd5);
        ClassificationData__c cd6 = new ClassificationData__c();
        cd6.ClassificationAttribute__c = ca.Id;
        cd6.ClassificationAttributeValue__c = cav3Lst[0].Id;
        cd6.ClassificationAttributeSubValue__c = cav3Lst[1].Id;
        cd6.ClassificationAttributeSubValue2__c = cav3Lst[2].Id;
        cd6.ClassificationAttributeSubValue3__c = cav3Lst[3].Id;
        cd6.ClassificationAttributeSubValue4__c = cav3Lst[4].Id;
        cd6.Active__c = false;
        cd6.Account__c = accounts[1].Id;
        returnList.add(cd6);

        for (ClassificationData__c cd : returnList) {
            System.debug('ClassificationData.Account__c ==> ' + cd.Account__c);
        }

        if (doInsert) {
            insert returnList;
        }

        return returnList;
    }

}