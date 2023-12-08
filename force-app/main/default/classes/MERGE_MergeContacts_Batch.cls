global with sharing class MERGE_MergeContacts_Batch implements Database.Batchable<AggregateResult>, Database.Stateful {
    /*/
    *   @ Created By: Jannes Kleerebezem
    *   @ Created on: 08-02-2021
    *
    *   Use: 
    *   ==> Start Batch to first match on TeacherNumber and after that automaticly continue with Email matching:
    *   MERGE_MergeContacts_Batch  MergeCon = new MERGE_MergeContacts_Batch();
    *   Id batchprocessid = Database.executebatch(MergeCon, 1);
    *   or:
    *   ==> If you want to run Only the Mering on TeacherNumber Matching:
    *   MERGE_MergeContacts_Batch  MergeCon = new MERGE_MergeContacts_Batch(true, false, false);
    *   Id batchprocessid = Database.executebatch(MergeCon, 1);
    *   or:
    *   ==> If you want to run Only the Mering on Email Matching:
    *   MERGE_MergeContacts_Batch  MergeCon = new MERGE_MergeContacts_Batch(false, false, true);
    *   Id batchprocessid = Database.executebatch(MergeCon, 1);
    *   
    /*/

    global Boolean isEmailMatching;
    global Boolean isTeacherNumnerMatching;
    global Boolean isPersonAccountMatching;
    global Boolean unFinished = false;
    global Boolean runFullJob = false;

    global MERGE_MergeContacts_Batch() {
        this.isTeacherNumnerMatching = true;
        this.isPersonAccountMatching = false;
        this.isEmailMatching = false;
        this.runFullJob = true;
    }

    global MERGE_MergeContacts_Batch(Boolean matchOnTeacherNumber, Boolean matchOnPersonAccount, Boolean matchOnEmail) {
        this.isTeacherNumnerMatching = matchOnTeacherNumber;
        this.isPersonAccountMatching = matchOnPersonAccount;
        this.isEmailMatching = matchOnEmail;
        this.runFullJob = false;
    }

    global MERGE_MergeContacts_Batch(Boolean runAll, Boolean matchOnTeacherNumber, Boolean matchOnPersonAccount, Boolean matchOnEmail) {
        this.isTeacherNumnerMatching = matchOnTeacherNumber;
        this.isPersonAccountMatching = matchOnPersonAccount;
        this.isEmailMatching = matchOnEmail;
        this.runFullJob = runAll;
    }

    global Iterable<AggregateResult> start(Database.BatchableContext BC){
        System.debug(LoggingLevel.INFO,'Class: MERGE_MergeContacts_Batch - Start method');

        String query = '';
        if (isEmailMatching && isTeacherNumnerMatching) {
            System.debug('Please make sure to only select one of the matchingTypes!');
        } else if (isEmailMatching) {
            query = 'SELECT COUNT(Id) cnt, Email FROM Contact WHERE Email != null AND AccountId != null GROUP BY Email HAVING COUNT(Id) > 1';
        } else if (isTeacherNumnerMatching) {
            query = 'SELECT COUNT(Id) cnt, TeacherNumber__c FROM Contact where TeacherNumber__c != null AND AccountId != null GROUP BY TeacherNumber__c HAVING Count(Id) > 1';
        } else if (isPersonAccountMatching) {
            query = 'SELECT COUNT(Id) cnt, AccountId FROM Contact WHERE Account.OldAccountisPersonAccount__c = true GROUP BY AccountId HAVING COUNT(Id) > 1';
        } else {
            System.debug('Make sure to select at least one of the matchingTypes');
        }
        if (Test.isRunningTest()) {
            query += ' LIMIT 1';
        }

        System.debug(LoggingLevel.INFO, 'query =' + query);
        
        return new UTIL_AggregateResultIterable(query);
    }

    global void execute(Database.BatchableContext BC, List<AggregateResult> scope){
        System.debug(LoggingLevel.INFO,'Class: MERGE_MergeContacts_Batch - Execute method');
       
        List<Contact> contactList = new List<Contact>();
        
        if (isTeacherNumnerMatching) {
            String TeacherNumber;
            for (AggregateResult ar : scope) {
                TeacherNumber = String.ValueOf(ar.get('TeacherNumber__c'));
            }
            contactList = [SELECT Id, Email, OldContactId__c, Phone, MobilePhone, CommunicationLanguage__c, OperatingCompany__c, MailingStreet, MailingCity, MailingCountry, TeacherNumber__c, AccountId FROM Contact WHERE ManualMergeCheck__c = false AND TeacherNumber__c = :TeacherNumber ORDER BY LastModifiedDate DESC];
        } 
        else if (isEmailMatching) {
            String emailForMatching;
            for (AggregateResult ar : scope) {
                emailForMatching = String.ValueOf(ar.get('Email'));
            }
            List<Contact> tempContactList = [SELECT Id, Email, OldContactId__c, Phone, MobilePhone, CommunicationLanguage__c, OperatingCompany__c, MailingStreet, MailingCity, MailingCountry, TeacherNumber__c, AccountId, TeacherSchoolNumber__c FROM Contact WHERE ManualMergeCheck__c = false AND Email = :emailForMatching ORDER BY LastModifiedDate DESC];
            Contact mainContact;
            for (Contact c : tempContactList) {
                if (mainContact == null) {
                    mainContact = c;
                    contactList.add(c);
                } else {
                    if (c.AccountId == mainContact.AccountId || (c.TeacherSchoolNumber__c != null && c.TeacherSchoolNumber__c == mainContact.TeacherSchoolNumber__c)) {
                        contactList.add(c);
                    }
                }
            }
        } else if (isPersonAccountMatching) {
            Id accountId;
            for (AggregateResult ar : scope) {
                    accountId = Id.valueOf((String)ar.get('AccountId'));
            }
            contactList = [SELECT Id, Email, OldContactId__c, Phone, MobilePhone, CommunicationLanguage__c, OperatingCompany__c, MailingStreet, MailingCity, MailingCountry, TeacherNumber__c, AccountId, TeacherSchoolNumber__c FROM Contact WHERE ManualMergeCheck__c = false AND AccountId = :accountId ORDER BY LastModifiedDate DESC];
        } else {
            System.debug('No Matching Type selected.');
        }


        System.debug(LoggingLevel.INFO, 'contactList size = ' + contactList.size());
        List<Contact> lstContact = new List<Contact>();

        Integer loopSize;
        if (contactList.size() <= 3) {
            loopSize = contactList.size();
        } else {
            loopSize = 3;
            unFinished = true;
        }
        
        for (Integer i = 0; i < loopSize; i++) {
            lstContact.add(contactList[i]);
        }

        System.debug(LoggingLevel.DEBUG, 'lstContact size = ' + lstContact.size());
        if (lstContact.size() > 1) {
            MERGE_MergeContact.MergeContacts(lstContact);
        }
       
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug(LoggingLevel.INFO,'Class: MERGE_MergeContacts_Batch - Finish method');

        System.debug(LoggingLevel.INFO, 'Unfinished = ' + unFinished);
        System.debug(LoggingLevel.INFO, 'runFullJob = ' + runFullJob);
        System.debug(LoggingLevel.INFO, 'isTeacherNumnerMatching = ' + isTeacherNumnerMatching);
        System.debug(LoggingLevel.INFO, 'isPersonAccountMatching = ' + isPersonAccountMatching);
        System.debug(LoggingLevel.INFO, 'isEmailMatching = ' + isEmailMatching);

        if (unfinished) {
            if (runFullJob) {
                MERGE_MergeContacts_Batch  MergeCon = new MERGE_MergeContacts_Batch(true, isTeacherNumnerMatching, isPersonAccountMatching, isEmailMatching);
                Id batchprocessid = Database.executebatch(MergeCon, 1);
                System.debug('Id of next batch Job: ' + batchprocessid);
            } else {
                MERGE_MergeContacts_Batch  MergeCon = new MERGE_MergeContacts_Batch(isTeacherNumnerMatching, isPersonAccountMatching, isEmailMatching);
                Id batchprocessid = Database.executebatch(MergeCon, 1);
                System.debug('Id of next batch Job: ' + batchprocessid);
            }
        } else if (runFullJob && isTeacherNumnerMatching) {
            System.debug('TeacherNumber Matching is finished, starting PersonAccount matching');
            MERGE_MergeContacts_Batch  MergeCon = new MERGE_MergeContacts_Batch(true, false, true, false);
            Id batchprocessid = Database.executebatch(MergeCon, 1);
            System.debug('Id of next batch Job: ' + batchprocessid);
        } else if (runFullJob && isPersonAccountMatching) {
            System.debug('PersonAccount Matching is finished, starting Email matching');
            MERGE_MergeContacts_Batch  MergeCon = new MERGE_MergeContacts_Batch(true, false, false, true);
            Id batchprocessid = Database.executebatch(MergeCon, 1);
            System.debug('Id of next batch Job: ' + batchprocessid);
        } else {
            System.debug('Finished!');
        }

    }

}