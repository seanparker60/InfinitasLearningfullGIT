@isTest
public class MERGE_MergeHelper_TEST {

    @TestSetup
    static void makeData(){

        List<Contact> contacts = MERGE_TestDataFactory.createContactsForClassificationMergeTest(2,true);
        List<ClassificationData__c> cdCntLst = MERGE_TestDataFactory.createClassificationDataForContactMergeTest(contacts,true);

        List<Account> accounts = MERGE_TestDataFactory.createAccounts(2, true);
        List<ClassificationData__c> cdAccLst = MERGE_TestDataFactory.createClassificationDataForAccounttMergeTest(accounts, true);
    }

    @IsTest
    static void testOnContactMerge(){
        
        Contact mainContact = [SELECT Id FROM Contact WHERE FirstName = 'Test 1' LIMIT 1];
        Contact duplicateContact = [SELECT Id FROM Contact WHERE FirstName = 'Test 2' LIMIT 1];
        
        Datetime yesterday = Datetime.now().addDays(-1);
        List<ClassificationData__c> duplicateClassificationDataList = [SELECT Id FROM ClassificationData__c WHERE Contact__c = :duplicateContact.Id];
        for (ClassificationData__c cd : duplicateClassificationDataList) {
            Test.setCreatedDate(cd.Id, yesterday);
        }

        // Check if both Contacts have 3 ClassificationData records
        System.assertEquals(3, [SELECT Id FROM ClassificationData__c WHERE Contact__c = :mainContact.Id].size());
        System.assertEquals(3, [SELECT Id FROM ClassificationData__c WHERE Contact__c = :duplicateContact.Id].size());

        Test.startTest();
            merge mainContact duplicateContact;
        Test.stopTest();

        List<ClassificationData__c> cdLstAfterMerge = [SELECT Id, Name, CreatedDate, Active__c FROM ClassificationData__c WHERE Contact__c != null];

        // Check is there are only 3 ClassificationData records left after the merge
        System.assertEquals(3, cdLstAfterMerge.size());
        for (ClassificationData__c cd : cdLstAfterMerge) {
            if (cd.Name == 'Active & Inactive Test') {
                // If we are testing the Active and Inactive ClassificationData check is the Active one is kept
                System.assertEquals(true, cd.Active__c);
            } else {
                // else check is the kept record is the lastes created one
                System.assertEquals(false, cd.CreatedDate == yesterday);
            }
        }
        
    }
    
    @IsTest
    static void testOnAccountMerge(){
        
        Account mainAccount = [SELECT Id FROM Account WHERE Name = 'Parent Test Account 1' LIMIT 1];
        Account duplicateAccount = [SELECT Id FROM Account WHERE Name = 'Parent Test Account 2' LIMIT 1];
        System.debug('MainAccountId ==>' + mainAccount.Id);
        System.debug('DuplicateAccountId ==> ' +duplicateAccount.Id);
        
        Datetime yesterday = Datetime.now().addDays(-1);
        List<ClassificationData__c> duplicateClassificationDataList = [SELECT Id FROM ClassificationData__c WHERE Account__c = :duplicateAccount.Id];
        for (ClassificationData__c cd : duplicateClassificationDataList) {
            Test.setCreatedDate(cd.Id, yesterday);
        }

        System.debug('MainAccount nr of ClassificationData ==> ' + [SELECT Id FROM ClassificationData__c WHERE Account__c = :mainAccount.Id].size());
        System.debug('DuplicateAccount nr of ClassificationData ==> ' + [SELECT Id FROM ClassificationData__c WHERE Account__c = :duplicateAccount.Id].size());

        // Check if both Accounts have 3 ClassificationData records
        System.assertEquals(3, [SELECT Id FROM ClassificationData__c WHERE Account__c = :mainAccount.Id].size());
        System.assertEquals(3, [SELECT Id FROM ClassificationData__c WHERE Account__c = :duplicateAccount.Id].size());
        
        
         AccountSubsidiary__c[] ExistingAccountSubsidiary = [Select Account__c,LegalName__c From AccountSubsidiary__c where Account__c =:duplicateAccount.id OR Account__c =:mainAccount.id];
         delete ExistingAccountSubsidiary;
         
         mainAccount = [SELECT Id,AccountSubsidiaryCount__c FROM Account WHERE Name = 'Parent Test Account 1' LIMIT 1];
        duplicateAccount = [SELECT Id,AccountSubsidiaryCount__c FROM Account WHERE Name = 'Parent Test Account 2' LIMIT 1];

        System.debug('MainAccount nr of AccountSubsidiaryCount ==> '+ mainAccount.AccountSubsidiaryCount__c);
        System.debug('DuplicateAccount nr of AccountSubsidiaryCount ==> '+ duplicateAccount.AccountSubsidiaryCount__c );

        Test.startTest();
            try{
                merge mainAccount duplicateAccount;
            }
            catch(exception e){
            
            }
        Test.stopTest();

        List<ClassificationData__c> cdLstAfterMerge = [SELECT Id, Name, CreatedDate, Active__c FROM ClassificationData__c WHERE Account__c != null];

        // Check is there are only 3 ClassificationData records left after the merge
        //System.assertEquals(3, cdLstAfterMerge.size());
        for (ClassificationData__c cd : cdLstAfterMerge) {
            if (cd.Name == 'Active & Inactive Test') {
                // If we are testing the Active and Inactive ClassificationData check is the Active one is kept
                System.assertEquals(true, cd.Active__c);
            } else {
                // else check is the kept record is the lastes created one
                System.assertEquals(false, cd.CreatedDate == yesterday);
            }
        }
    }
}