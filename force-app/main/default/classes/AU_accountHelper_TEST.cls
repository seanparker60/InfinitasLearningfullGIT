@IsTest
public class AU_accountHelper_TEST {

    @IsTest
    static void test01(){

        Account[] accounts = AU_TestDataFactory.createAccounts(false);
        Account imAccount;
        Account sgAccount;
        Account sAccount;
        for (Account acc : accounts) {
            acc.AgodiUpdateInProgress__c = true;
            if (acc.ExternalCustomerId__c == '123456') {
                imAccount = acc;
            } else if (acc.ExternalCustomerId__c == '654321') {
                sgAccount = acc;
            } else if (acc.ExternalCustomerId__c == '987654') {
                sAccount = acc;
            }
        }
        System.debug('IM ext. custId: ' + imAccount.ExternalCustomerId__c + ' Account ==> ' + imAccount);
        System.debug('SG ext. custId: ' + sgAccount.ExternalCustomerId__c + ' Account ==> ' + sgAccount);
        System.debug('S ext. custId: ' + sAccount.ExternalCustomerId__c + ' Account ==> ' + sAccount);

        List<Account> AccountsIM = new List<Account>{imAccount};
        List<Account> AccountsSG = new List<Account>{sgAccount};
        List<Account> AccountsS = new List<Account>{sAccount};

        AU_accountHelper ah = new AU_accountHelper(AccountsIM, AccountsSG, AccountsS);
        
        Test.startTest();
            System.enqueueJob(ah);
        Test.stopTest();
        
        System.assertEquals('School 1', [SELECT Name FROM Account WHERE ExternalCustomerId__c = '123456'].Name);
    }

    @IsTest
    static void test02(){

        Account[] accounts = AU_TestDataFactory.createAccounts(false);
        Account imAccount;
        Account sgAccount;
        Account sAccount;
        for (Account acc : accounts) {
            acc.AgodiUpdateInProgress__c = true;
            if (acc.ExternalCustomerId__c == '123456') {
                imAccount = acc;
            } else if (acc.ExternalCustomerId__c == '654321') {
                sgAccount = acc;
            } else if (acc.ExternalCustomerId__c == '987654') {
                sAccount = acc;
            }
        }
        System.debug('IM ext. custId: ' + imAccount.ExternalCustomerId__c + ' Account ==> ' + imAccount);
        System.debug('SG ext. custId: ' + sgAccount.ExternalCustomerId__c + ' Account ==> ' + sgAccount);
        System.debug('S ext. custId: ' + sAccount.ExternalCustomerId__c + ' Account ==> ' + sAccount);

        List<Account> AccountsIM = new List<Account>{imAccount};
        List<Account> AccountsSG = new List<Account>{sgAccount};
        List<Account> AccountsS = new List<Account>{sAccount};

        AU_accountHelper ah = new AU_accountHelper(AccountsIM, AccountsSG, AccountsS);
        ah.imCreated = true;
        
        Test.startTest();
            System.enqueueJob(ah);
        Test.stopTest();
        
        System.assertEquals('School 2', [SELECT Name FROM Account WHERE ExternalCustomerId__c = '654321'].Name);
    }

    @IsTest
    static void test03(){

        Account[] accounts = AU_TestDataFactory.createAccounts(false);
        Account imAccount;
        Account sgAccount;
        Account sAccount;
        for (Account acc : accounts) {
            acc.AgodiUpdateInProgress__c = true;
            if (acc.ExternalCustomerId__c == '123456') {
                imAccount = acc;
            } else if (acc.ExternalCustomerId__c == '654321') {
                sgAccount = acc;
            } else if (acc.ExternalCustomerId__c == '987654') {
                sAccount = acc;
            }
        }
        System.debug('IM ext. custId: ' + imAccount.ExternalCustomerId__c + ' Account ==> ' + imAccount);
        System.debug('SG ext. custId: ' + sgAccount.ExternalCustomerId__c + ' Account ==> ' + sgAccount);
        System.debug('S ext. custId: ' + sAccount.ExternalCustomerId__c + ' Account ==> ' + sAccount);

        List<Account> AccountsIM = new List<Account>{imAccount};
        List<Account> AccountsSG = new List<Account>{sgAccount};
        List<Account> AccountsS = new List<Account>{sAccount};

        AU_accountHelper ah = new AU_accountHelper(AccountsIM, AccountsSG, AccountsS);
        ah.imCreated = true;
        ah.sgCreated = true;
        
        Test.startTest();
            System.enqueueJob(ah);
        Test.stopTest();
        
        System.assertEquals('School 3', [SELECT Name FROM Account WHERE ExternalCustomerId__c = '987654'].Name);
    }
}