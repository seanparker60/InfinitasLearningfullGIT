public with sharing class MERGE_MergeAccount {

    public static Map<String, List<String>> MergeAccounts(List<Account> accountList, Boolean manualMergeCheck) {
        System.debug(LoggingLevel.INFO, 'MERGE_MergeAccount.MergeAccounts');

        // Set variables
        Boolean masterAccountIsSet = false;
        Boolean manualCheck = manualMergeCheck;
        Boolean changeData = false;
        Boolean doNotMerge = false;

        Account masterAccount = new Account();
        List<Account> duplicateAccounts = new List<Account>();
        List<Account> ManualCheckAcc = new List<Account>();

        Map<String, List<String>> returnMap = new Map<String, List<String>>();
        List<String> mergeIds = new List<String>();
        List<String> errors = new List<String>();
        String manualCheckInformation = '';

        // for csv feedback:
        String fieldUpdates = '';
        String statusForCsv;
        String masterAccountId = '';
        String duplicate1AccountId = '';
        String duplicate2AccountId = '';

        Integer numberOfMasterAccounts = 0;
        Integer numberOfDuplicateAccounts = 0;

        // get system user Id
        Id systemUserId = [SELECT Id FROM User WHERE Name = 'System User' LIMIT 1].Id;
        
        // Loop through accounts and set the master account and duplicate accounts
        // Fill in the fields InvoicingEmail__c, ExternalCustomerId__c, LastAgodiUpdate__c, ParentId, PurchasingGroup__c and studentnumber fields if these are empty on the master account but can be found on one of the duplicate accounts
        for (Account acc : accountList) {
            Boolean accAddedToList = false;
            if (!masterAccountIsSet) {
                // Set masterAccount
                masterAccount = acc;
                masterAccountIsSet = true;
                numberOfMasterAccounts ++;
            } else if (masterAccount.OwnerId == systemUserId && (masterAccount.KlopotekNumber__c == null || masterAccount.KlopotekNumber__c == '') && (masterAccount.Categories__c == null || masterAccount.Categories__c == '') && (acc.OwnerId != systemUserId || (acc.KlopotekNumber__c != null && acc.KlopotekNumber__c != '') || (acc.Categories__c != null && acc.Categories__c != ''))) {
                // is master Account does not met parameters but duplicate does switch accounts
                duplicateAccounts.add(masterAccount);
                masterAccount = acc;
            } else if ((masterAccount.OwnerId != systemUserId || (masterAccount.KlopotekNumber__c != null && masterAccount.KlopotekNumber__c != '') || (masterAccount.Categories__c != null && masterAccount.Categories__c != '')) && (acc.OwnerId != systemUserId || (acc.KlopotekNumber__c != null && acc.KlopotekNumber__c != '') || (acc.Categories__c != null && acc.Categories__c != ''))) {
                duplicateAccounts.add(acc);
                numberOfMasterAccounts ++;
            }else if (acc.OwnerId == systemUserId && acc.KlopotekNumber__c == null && acc.Categories__c == null) {
                // If the account does not meet masterAccount parameters put it in the duplicateAccount list
                numberOfDuplicateAccounts ++;

                // check if empty fields from master account can be filled with values from the duplicate accounts
                if ((masterAccount.InvoicingEmail__c == null || masterAccount.InvoicingEmail__c == '') && acc.InvoicingEmail__c != null) {
                    masterAccount.InvoicingEmail__c = acc.InvoicingEmail__c;
                    changeData = true;
                    fieldUpdates += 'InvoicingEmail__c;';
                }
                if ((masterAccount.ExternalCustomerId__c == null || masterAccount.ExternalCustomerId__c == '') && acc.ExternalCustomerId__c != null) {
                    masterAccount.ExternalCustomerId__c = acc.ExternalCustomerId__c;
                    changeData = true;
                    fieldUpdates += 'ExternalCustomerId__c;';
                }
                if (masterAccount.LastAgodiUpdate__c == null && acc.LastAgodiUpdate__c != null) {
                    masterAccount.LastAgodiUpdate__c = acc.LastAgodiUpdate__c;
                    changeData = true;
                    fieldUpdates += 'LastAgodiUpdate__c;';
                }
                if (masterAccount.ParentId == null && acc.ParentId != null) {
                    masterAccount.ParentId = acc.ParentId;
                    changeData = true;
                    fieldUpdates += 'ParentId;';
                }
                if (masterAccount.PurchasingGroup__c == null && acc.PurchasingGroup__c != null) {
                    masterAccount.PurchasingGroup__c = acc.PurchasingGroup__c;
                    changeData = true;
                    fieldUpdates += 'PurchasingGroup__c;';
                }
                if ((masterAccount.NumberofStudents__c == null || masterAccount.NumberofStudents__c == 0) && acc.NumberofStudents__c != null) {
                    masterAccount.NumberofStudents__c = acc.NumberofStudents__c;
                    masterAccount.HEStudents__c = acc.HEStudents__c;
                    masterAccount.KGStudents__c = acc.KGStudents__c;
                    masterAccount.PEStudents__c = acc.PEStudents__c;
                    masterAccount.SEStudents__c = acc.SEStudents__c;
                    masterAccount.VEStudents__c = acc.VEStudents__c;
                    changeData = true;
                    fieldUpdates += 'NumberofStudents__c;HEStudents__c;KGStudents__c;PEStudents__c;SEStudents__c;VEStudents__c;';
                }
                if (masterAccount.NumberofStudents__c == null || masterAccount.NumberofStudents__c == 0) {
                    masterAccount.NumberofStudents__c = 1;
                    changeData = true;
                }

                // if we found additional field values for the masterAccount and the accounts are not ment to be manualy checked update the masterAccount
                if (changeData && !manualCheck) {
                    Database.SaveResult updateResult = Database.Update(masterAccount, false);
                    if (updateResult.isSuccess()) {
                        System.Debug(LoggingLevel.INFO, 'Successfuly updated MasterAccount.');
                    } else {
                        for (Database.Error e : updateResult.getErrors()) {
                            errors.add(e.getMessage());
                            // if an error appears during the update store the error and mark the accounts for manual check
                            manualCheck = true;
                            manualCheckInformation = 'The next error occured updating the MasterAccount with Id ' + masterAccount.Id + ': ' + e.getMessage();
                        }
                    }
                    
                }
                if (!accAddedToList) {
                    duplicateAccounts.add(acc);
                }
            }
        }

        System.debug('numberOfMasterAccounts = ' + numberOfMasterAccounts);
        System.debug('numberOfDuplicateAccounts = ' + numberOfDuplicateAccounts);
        if (numberOfMasterAccounts > 1) {
            doNotMerge = true;
            if (numberOfDuplicateAccounts > 0) {
                manualCheck = true;
                manualCheckInformation = 'We found multiple Accounts with KlopotekNumber - Category or a non System User as owner. We don\'t know to what Account to merge the Duplicate Account';
            }
        }

        System.debug('manualCheck = ' + manualCheck + ' and doNotMerge = ' + doNotMerge);
        // MERGING
        if (!manualCheck && !doNotMerge) { // If a manual check is not needed, merge the Accounts

            // get list of AccountContactRelations and Contacts of MainAccount
            List<AccountContactRelation> mainAccAcrLst = [SELECT Id, ContactId FROM AccountContactRelation WHERE AccountId = :masterAccount.Id];
            List<Contact> mainAccContList = [SELECT Id FROM Contact WHERE AccountId = :masterAccount.Id];
            // create List of Contacts relates via AccountContactRelation to the mainAccount
            Set<Id> contactIds = new Set<Id>();
            for (AccountContactRelation acr : mainAccAcrLst) {
                contactIds.add(acr.ContactId);
            }
            for (Contact con: mainAccContList) {
                contactIds.add(con.Id);
            }

            // get list of Contacts of the duplicate Accounts
            set<Id> duplicateAccountIds2 = new Set<Id>();
            for (Account a : duplicateAccounts) {
                duplicateAccountIds2.add(a.Id);
            }
            List<Contact> duplicateAccountContacts = [SELECT Id FROM Contact WHERE AccountId IN: duplicateAccountIds2];

            // transfer Contacts from duplicate Accounts to masterAccount
            Set<Id> masterAccountContacts = new Set<Id>();
            for (Contact c : duplicateAccountContacts) {
                c.AccountId = masterAccount.Id;
                masterAccountContacts.add(c.Id);
            }
            update duplicateAccountContacts;
            
            // recreate AccountContactRelations
            // HdG: commented out references to Related Email and Related Phone, since these fields have been replaced by formula fields
            List<AccountContactRelation> acrLst = [SELECT Id, ContactId, isDirect /* , RelatedEmail__c, RelatedPhone__c */ FROM AccountContactRelation WHERE AccountId IN :duplicateAccountIds2 AND isDirect = false];
            List<AccountContactRelation> acrDeleteList = new List<AccountContactRelation>();
            List<AccountContactRelation> newACRList = new List<AccountContactRelation>();
            Set<Id> relatedContactIds = new Set<Id>();
            for (AccountContactRelation acr : acrLst) {
                if (!relatedContactIds.contains(acr.ContactId) && !contactIds.contains(acr.ContactId) && !masterAccountContacts.contains(acr.ContactId)) {
                    AccountContactRelation newACR = new AccountContactRelation();
                    newACR.ContactId = acr.ContactId;
                    newACR.AccountId = masterAccount.Id;
                    /* newACR.RelatedEmail__c = acr.RelatedEmail__c; */
                    /* newACR.RelatedPhone__c = acr.RelatedPhone__c; */
                    newACRList.add(newACR);
                    relatedContactIds.add(acr.ContactId);
                }
                acrDeleteList.add(acr);
            }
            delete acrDeleteList;
            insert newACRList;
            
            
            Database.MergeResult[] results = Database.merge(masterAccount, duplicateAccounts, false);
            
            for (Database.MergeResult res : results) {
                if (res.isSuccess()) {
                    System.debug(LoggingLevel.INFO, 'Successfuly merged Accounts into Account with ID: ' + res.getId());
                    mergeIds.add(String.valueOf(res.getId()));
                } else {
                    for (Database.Error err : res.getErrors()) {
                        System.debug(LoggingLevel.ERROR, 'ERROR: ' + err.getMessage());
                        errors.add(err.getMessage());
                        // if an error appears during the merge store the error and mark the accounts for manual check
                        manualCheck = true;
                        String duplicateAccountIds;
                        for (Account a : duplicateAccounts) {
                            if(duplicateAccountIds == null) {
                                duplicateAccountIds = a.Id;
                            } else {
                                duplicateAccountIds += '; ' + a.Id;
                            }
                        }
                        manualCheckInformation = 'We encounterd the next error mering the Accounts with Id ' + masterAccount.Id + '; ' + duplicateAccountIds + ': ' + err.getMessage();
                    }
                }
            }
        }

        System.debug('Manualcheck = ' + manualCheck);
        // if manual check is needed update the accounts with the manual merge check box and the manual merging information
        if (manualCheck) {
            Account updateMasterAccount = new Account();
            updateMasterAccount.Id = masterAccount.Id;
            updateMasterAccount.manualMergeCheck__c = true;
            updateMasterAccount.ManualCheckReason__c = manualCheckInformation;
            for (Account acc : duplicateAccounts) {
                acc.ManualMergeCheck__c = true;
                if (manualCheckInformation.length() > 1) {
                    acc.ManualCheckReason__c = manualCheckInformation;
                }
                System.debug(LoggingLevel.DEBUG, 'Adding duplicateAccount with Id ' + acc.Id + ' to the manualCheck list.');
                ManualCheckAcc.add(acc);
            }
            System.debug(LoggingLevel.DEBUG, 'Adding masterAccount with Id ' + updateMasterAccount.Id + ' to the manualCheck list.');
            ManualCheckAcc.add(updateMasterAccount);
            update ManualCheckAcc;
        }

        // generate String for csv feedback
        if (manualCheck) {
            statusForCsv = 'ManualCheck: ' + manualCheckInformation;
            fieldUpdates = 'no field updates have been done';
        } else {
            if (fieldUpdates.length() < 2) {
                fieldUpdates = 'no field updates have been done';
            }
            if (errors.size() > 0) {
                String errorString;
                for (Integer i = 0; i < errors.size(); i++) {
                    if (i == errors.size()-1) {
                        errorString += errors[i];
                    } else {
                        errorString += errors[i] + '; ';
                    }
                }
                statusForCsv = 'Error: ' + errorString;
            } else {
                statusForCsv = 'Merged';
            }
        }
        masterAccountId = masterAccount.Id;
        if (duplicateAccounts.size() == 1) {
            duplicate1AccountId = duplicateAccounts[0].Id;
        } else if (duplicateAccounts.size() == 2) {
            duplicate1AccountId = duplicateAccounts[0].Id;
            duplicate2AccountId = duplicateAccounts[1].Id;
        }

        String csvFeedback = masterAccountId + ',' + duplicate1AccountId + ',' + duplicate2AccountId + ',' + fieldUpdates + ',' + statusForCsv + '\n';
        List<String> csvList = new List<String>();
        csvList.add(csvFeedback);
        returnMap.put('successes', mergeIds);
        returnMap.put('errors', errors);
        returnMap.put('forCsv', csvList);
        return returnMap;
    }
}