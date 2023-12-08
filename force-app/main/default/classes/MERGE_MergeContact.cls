public with sharing class MERGE_MergeContact {
    
    public MERGE_MergeContact() {

    }

    public static void MergeContacts(List<Contact> contactList){
        System.debug(LoggingLevel.INFO, 'MERGE_MergeContact - MergeContacts');
 
        Boolean masterContactIsSet = false;
        Boolean manualCheck = false;
        Contact masterContact = new Contact();
        List<Contact> duplicateContacts = new List<Contact>();
        Set<Id> Set_Accid = new Set<Id>();
    
        for (Contact con: contactList) {
            // Merge contacts if there are multiple contacts with the same TeacherNumber__c                
            if (!masterContactIsSet) {
                masterContact = con;
                masterContactIsSet = true;
            } else {
                // check if the Contact needs to be manualy Checked
                if ((con.Phone != null && con.Phone != masterContact.Phone && masterContact.Phone != null) || (con.MobilePhone	!= null && con.MobilePhone != masterContact.MobilePhone && masterContact.MobilePhone != null) || (con.Email != null && con.Email != masterContact.Email && masterContact.Email != null) || (con.TeacherNumber__c != null && masterContact.TeacherNumber__c != con.TeacherNumber__c  && masterContact.TeacherNumber__c != null)) {
                    manualCheck = true;
                    System.debug('MERGE_MergeContact - Contact is for Manual Check');
                } else {
                    Boolean changedData = false;
                    // check if the master Contact has empty fields and if it does fill them with values of the duplicate contacts
                    if (masterContact.Email == null && con.Email != null) {
                        masterContact.Email = con.Email;
                        changedData = true;
                    }
                    if (masterContact.Phone == null && con.Phone != null) {
                        masterContact.Phone = con.Phone;
                        changedData = true;
                    }
                    if (masterContact.MobilePhone == null && con.MobilePhone != null) {
                        masterContact.MobilePhone = con.MobilePhone;
                        changedData = true;
                    }
                    if (masterContact.CommunicationLanguage__c == null && con.CommunicationLanguage__c != null) {
                        masterContact.CommunicationLanguage__c = con.CommunicationLanguage__c;
                        changedData = true;
                    }
                    if (masterContact.OperatingCompany__c == null && con.OperatingCompany__c != null) {
                        masterContact.OperatingCompany__c = con.OperatingCompany__c;
                        changedData = true;
                    }
                    if (masterContact.MailingStreet == null && con.MailingStreet != null) {
                        masterContact.MailingStreet = con.MailingStreet;
                        changedData = true;
                    }
                    if (masterContact.MailingCity == null && con.MailingCity != null) {
                        masterContact.MailingCity = con.MailingCity;
                        changedData = true;
                    }
                    if (masterContact.MailingCountry == null && con.MailingCountry != null) {
                        masterContact.MailingCountry = con.MailingCountry;
                        changedData = true;
                    }
                    if (masterContact.AccountId == null && con.AccountId != null) {
                        masterContact.AccountId = con.AccountId;
                        changedData = true;
                    }
                    if (changedData) {
                        Database.SaveResult updateResult = Database.Update(masterContact, false);
                        if (updateResult.isSuccess()) {
                        	System.Debug(LoggingLevel.INFO, 'MERGE_MergeContact - Successfuly updated MasterAccount.');
                    	} else {
                        	for (Database.Error e : updateResult.getErrors()) {
                            	System.Debug(LoggingLevel.ERROR, 'MERGE_MergeContact - ERROR: ' + e.getMessage());
                        	}
                    	}
                    }
                }
                duplicateContacts.add(con);
                if (con.AccountId != null) {
                    Set_Accid.add(con.AccountId);
                }
            }
        }
        
        if (manualCheck) {
                
            // if Manual Check is needed set the checkbox on Contacts for manual checking to true
            List<Contact> contactsToUpdate = new List<Contact>();
            masterContact.ManualMergeCheck__c = true;
            contactsToUpdate.add(masterContact);
            for (Contact c : duplicateContacts) {
                c.ManualMergeCheck__c = true;
                contactsToUpdate.add(c);
            }
            update contactsToUpdate;
    
        } else {
    
            // if no manual check is needed merge contacts
            Database.MergeResult[] results = Database.merge(masterContact, duplicateContacts, false);
                    
            for (Database.MergeResult res : results) {
                if (res.isSuccess()) {
                    System.Debug('MERGE_MergeContact - Successfuly merged Contacts into Contact with ID: ' + res.getId());
                } else {
                    for (Database.Error err : res.getErrors()) {
                        System.Debug('MERGE_MergeContact - ERROR: ' + err.getMessage());
                    }
                }
            }
            
            List<AccountContactRelation> acrList = new List<AccountContactRelation>();
            for (Id accountId : Set_Accid) {
    
                AccountContactRelation acr = new AccountContactRelation();
                acr.ContactId = masterContact.Id;
                acr.AccountId = accountId;
                acrList.add(acr);
            }
    
            Database.SaveResult[] saveResults = Database.insert(acrList, false);
            for (Database.SaveResult sr : saveResults) {
                if (sr.isSuccess()) {
                    System.Debug('MERGE_MergeContact - Successfuly inserted AccountContactRelation with Id ' + sr.getId());
                } else {
                    for (Database.Error err : sr.getErrors()) {
                        System.Debug('MERGE_MergeContact - ERROR: ' + err.getMessage());
                    }
                }
            }
        }
        
    }
}