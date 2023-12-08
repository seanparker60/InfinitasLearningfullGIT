global with sharing class MERGE_MergeAccounts_Batch implements Database.Batchable<sObject>, Database.Stateful {
    /*/
    *   @ Created By: Jannes Kleerebezem
    *   @ Created on: 09-02-2021
    *
    *   Use: 
    *   ==> Start Batch to first match on ExternalCustomerId and after that automaticly continue with OldAccountId matching:
    *   MERGE_MergeAccounts_Batch  MergeAcc = new MERGE_MergeAccounts_Batch();
    *   Id batchprocessid = Database.executebatch(MergeAcc, 1);
    *   or:
    *   ==> if you only want to do ExternalCustomerId matching for all OpCo's:
    *   MERGE_MergeAccounts_Batch  MergeAcc = new MERGE_MergeAccounts_Batch(false, true, false);
    *   Id batchprocessid = Database.executebatch(MergeAcc, 1);
    *   or:
    *   ==> if you only want to do OldAccountId matching for all OpCo's:
    *   MERGE_MergeAccounts_Batch  MergeAcc = new MERGE_MergeAccounts_Batch(false, false, true);
    *   Id batchprocessid = Database.executebatch(MergeAcc, 1);
    *   or:
    *   ==> if you only want to do ExternalCustomerId matching for Plantyn:
    *   MERGE_MergeAccounts_Batch  MergeAcc = new MERGE_MergeAccounts_Batch(false, true, false, 'Plantyn');
    *   Id batchprocessid = Database.executebatch(MergeAcc, 1);
    *   or:
    *   ==> if you only want to do OldAccountId matching for Plantyn 'Plantyn':
    *   MERGE_MergeAccounts_Batch  MergeAcc = new MERGE_MergeAccounts_Batch(false, false, true, 'Plantyn');
    *   Id batchprocessid = Database.executebatch(MergeAcc, 1);
    *   
    /*/

    global Boolean unfinished = false;
    global Boolean isExternalCustomerIdMatch;
    global Boolean isOldAccountIdMatch;
    global Boolean runFullJob;
    global String errors;
    global String merges;
    global String operatingCompany;
    global Integer mergeBatches = 0;
    global Integer batchRepetitions = 0;
    global String csvString = 'MasterAccountId, Duplicate1AccountId, Duplicate2AccountId, FieldUpdates, status\n';

    // for full merge run
    global MERGE_MergeAccounts_Batch() {
        this.isExternalCustomerIdMatch = true;
        this.isOldAccountIdMatch = false;
        this.runFullJob = true;
    }

    // for merge run on all OpCos with options to only run ExternalCustomerId match or only OldAccountId Match
    global MERGE_MergeAccounts_Batch(Boolean runAll, Boolean matchOnExternalCustomerId, Boolean matchOnOldAccountId) {
        this.isExternalCustomerIdMatch = matchOnExternalCustomerId;
        this.isOldAccountIdMatch = matchOnOldAccountId;
        this.runFullJob = runAll;
    }

    // full option matching (mainly ment for the Batch chaining)
    global MERGE_MergeAccounts_Batch(Boolean runAll, Boolean matchOnExternalCustomerId, Boolean matchOnOldAccountId, String OpCo) {
        this.isExternalCustomerIdMatch = matchOnExternalCustomerId;
        this.isOldAccountIdMatch = matchOnOldAccountId;
        this.runFullJob = runAll;
        this.operatingCompany = OpCo;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug(LoggingLevel.INFO, 'class: MERGE_MergeAccounts_Batch - Start Method');

        String query = '';
        if (isExternalCustomerIdMatch && isOldAccountIdMatch) {
            System.debug(LoggingLevel.ERROR, 'Please select only one matchingType');
        } else if (isExternalCustomerIdMatch) {
            // query for ExternalCustomerId Matching
            query = 'SELECT Id, ExternalCustomerId__c, Type, ShippingCity, ShippingStreet FROM Account WHERE ExternalCustomerId__c != null';
        } else if (isOldAccountIdMatch) {
            // query for OldAccountId Matching
            query = 'SELECT Id, OldAccountId__c FROM Account WHERE OldAccountId__c != null';
        } else {
            System.debug(LoggingLevel.ERROR, 'Please make sure to select one of the MatchingTypes');
        }
        if (operatingCompany != null) {
            // add OpCo to the query if this is added to the options
            query += ' AND OperatingCompany__c = \'' + operatingCompany + '\'';
        }
        if (Test.isRunningTest()) {
            // Test specific query additions
            if (isExternalCustomerIdMatch) {
                query += ' AND ExternalCustomerId__c = \'123456789\' LIMIT 1';
            } else {
                query += ' AND OldAccountId__c = \'hijklmno\' LIMIT 1';
            }
        }
        
        System.Debug(LoggingLevel.INFO, 'query = ' + query);

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        System.debug(LoggingLevel.INFO, 'class: MERGE_MergeAccounts_Batch - Execute Method');

        List<Account> accountList = new List<Account>();
        
        if (isExternalCustomerIdMatch && isOldAccountIdMatch) {
            System.debug(LoggingLevel.ERROR, 'Please select only one matchingType');
        
        }else if (isExternalCustomerIdMatch) { // Get Accounts for ExternalCustomerId Matching
            System.debug(LoggingLevel.DEBUG, 'isExternalCustomerIdMatch');
            String externalCustomerId;
            String ShippingCity;
            String customerCategory;
            String shippingStreet;
            for (Account a : scope) {
                externalCustomerId = a.ExternalCustomerId__c;
                ShippingCity = a.ShippingCity;
                customerCategory = a.Type;
                shippingStreet = a.ShippingStreet;
            }
            System.debug(LoggingLevel.DEBUG, '=====> externalCustomerId = ' + externalCustomerId);
            accountList = [SELECT Id, ManualMergeCheck__c, ExternalCustomerId__c, KGStudents__c, HEStudents__c, PEStudents__c, SEStudents__c, VEStudents__c, OldAccountIdOrigin__c, OperatingCompany__c, OldAccountId__c, InvoicingEmail__c, LastAgodiUpdate__c, ParentId, PurchasingGroup__c, NumberofStudents__c, KlopotekNumber__c, Categories__c, OwnerId FROM Account WHERE ExternalCustomerId__c = :externalCustomerId AND ShippingCity != null AND ShippingCity = :ShippingCity AND ShippingStreet = :shippingStreet AND Type = :customerCategory ORDER BY OldAccountId__c DESC NULLS LAST];
        
        } else if (isOldAccountIdMatch) { // Get Accounts for OldAccountId Matching
            System.debug(LoggingLevel.DEBUG, 'isOldAccountIdMatch');
            String oldAccountId;
            for (Account acc : scope) {
                oldAccountId = acc.OldAccountId__c;
            }
            System.debug(LoggingLevel.DEBUG, '=====> oldAccountId = ' + oldAccountId);
            accountList = [SELECT Id, ManualMergeCheck__c, ExternalCustomerId__c, KGStudents__c, HEStudents__c, PEStudents__c, SEStudents__c, VEStudents__c, OldAccountIdOrigin__c, OperatingCompany__c, OldAccountId__c, InvoicingEmail__c, LastAgodiUpdate__c, ParentId, PurchasingGroup__c, NumberofStudents__c, KlopotekNumber__c, Categories__c, OwnerId FROM Account WHERE OldAccountId__c = :oldAccountId ORDER BY LastModifiedDate DESC];
        
        } else {
            System.debug(LoggingLevel.ERROR, 'Please select a matchingType.');
        }
        
		System.debug(LoggingLevel.DEBUG, 'accountlist size = ' + accountList.size());

        List<Account> lstAccount = new List<Account>();
        integer loopSize;
        Boolean manualCheck = false;

        // Add the first 3 accounts to a new list for merging (we can only merge 3 accounts ath the time)
        for (Integer i = 0; i < accountList.size(); i++) {
            if (accountList[i].ManualMergeCheck__c) { // if accounts are already marked for manual check mark the duplicate accounts also for manual merge check
                manualCheck = true;
            } else if (lstAccount.size() < 3){
                lstAccount.add(accountList[i]);
            } else {
                unfinished = true;// if we have more than 3 Accounts to merge we should do another merge run.
            }
        }

        // Start merging Class: MERGE_MergeAccount with the generates Account list
        Map<String, List<String>> results = new Map<String, List<String>>();
        if (lstAccount.size() > 1) {
            System.debug(LoggingLevel.DEBUG, '=====> Starting Account merge with ' + lstAccount.size() + ' Accounts.');
            results = MERGE_MergeAccount.MergeAccounts(lstAccount, manualCheck);
            mergeBatches ++;
            for (String success : results.get('successes')) {
                merges += (success + '\n');
            }
            for (String err : results.get('errors')) {
                errors += (err + '\n');
            }
            for (String csvData : results.get('forCsv')) {
                csvString += csvData;
            }
        } else {
            System.debug(LoggingLevel.INFO, 'Skipped Account merge (no duplicates).');
        }

    }

    global void finish(Database.BatchableContext BC) {
        System.debug(LoggingLevel.INFO, 'class: MERGE_MergeAccounts_Batch - Finish Method');

        System.debug(LoggingLevel.INFO, 'Results of Merge operation (finished with ' + mergeBatches + ' batches that should merge Accounts):');
        System.debug(LoggingLevel.INFO, 'Successes:\n' + merges);
        System.debug(LoggingLevel.INFO, 'Errors:\n' + errors);

        // Sent Email with results
        //Create csv attachment from String
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(csvString);
        string csvname= 'MergeResults.csv';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);

        //Create email message
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        String[] toAddresses = new list<string> {'jkleerebezem@infinitaslearning.com'};
        String subject ='MergeResults';
        email.setSubject(subject);
        email.setToAddresses( toAddresses );
        String bodyText = 'In the attachment of this E-mail the results of the Merging can be found.';
        if (unfinished) {
            bodyText += '\nThere are more records to merge so we wil make anouther run!';
        } else if (runFullJob && isExternalCustomerIdMatch) {
            bodyText += '\n The ExternalCustomerId Matching is finished, we will proceed woth the OldAccountId Matching.';
        } else {
            bodyText += '\nWe are finished!';
        }
        email.setPlainTextBody(bodyText);
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});

        //Sent email
        if (!Test.isRunningTest()) {
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }
        
        if (unfinished) { // if the batch is unfinished run another batch

            MERGE_MergeAccounts_Batch MergeAcc = new MERGE_MergeAccounts_Batch(runFullJob, isExternalCustomerIdMatch, isOldAccountIdMatch, operatingCompany);
            Id batchprocessid = Database.executeBatch(MergeAcc, 1);
            System.debug(LoggingLevel.INFO, 'Id of next batch Job: ' + batchprocessid);
        
        } else if (runFullJob && isExternalCustomerIdMatch && operatingCompany != null) { // if the batch is finished, it is a full run and it is ExternalCustomerId match continue with OldAccountId match - optin WITH OpCo
        
            MERGE_MergeAccounts_Batch MergeAcc = new MERGE_MergeAccounts_Batch(runFullJob, false, true, operatingCompany);
            Id batchprocessid = Database.executeBatch(MergeAcc, 1);
            System.debug(LoggingLevel.INFO, 'Id of next batch Job: ' + batchprocessid);
        
        } else if (runFullJob && isExternalCustomerIdMatch) { // if the batch is finished, it is a full run and it is ExternalCustomerId match continue with OldAccountId match - optin WITHOUT OpCo
        
            MERGE_MergeAccounts_Batch MergeAcc = new MERGE_MergeAccounts_Batch(runFullJob, false, true);
            Id batchprocessid = Database.executeBatch(MergeAcc, 1);
            System.debug(LoggingLevel.INFO, 'Id of next batch Job: ' + batchprocessid);
        
        } else { // End if we are done
        
            System.debug(LoggingLevel.INFO, 'Finished!');
        
        }

    }

}