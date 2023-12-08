public class CS_contactSelectorHelper {
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> returnContacts(String recordId) {
        System.debug(LoggingLevel.INFO, 'CS_contactSelectorHelper - returnContacts(recordId: ' + recordId + ')');
        
        Lead ld = [SELECT Id, OperatingCompany__c, MatchType__c, FirstName, LastName, Email FROM Lead WHERE Id = :recordId LIMIT 1];

        if (ld.Email != '') {
            ld.Email = 'blablabla_unmatchable_email@unmatchable_email_is_set.test';
        }
        Map<String, Lead> params = new Map<String, Lead>();
        params.put('sov_Lead',ld);

        Flow.Interview.FindMatchingContacts matchContacts = new Flow.Interview.FindMatchingContacts(params);
        matchContacts.start();

        List<Contact> MatchedContacts = new List<Contact>();
        
        MatchedContacts = (List<Contact>) matchContacts.getVariableValue('soc_Contacts');

        System.debug('MatchedContacts?.size() ==> ' + MatchedContacts?.size());
        List<Id> contactIds = new List<Id>();
        if (MatchedContacts?.size() > 0) {
            for (Contact c : MatchedContacts) {
                contactIds.add(c.Id);
            }
        }

        List<Contact> contactLst = [SELECT Id, OperatingCompany__c, FirstName, LastName, Email, AccountId, Account.Name FROM Contact WHERE Id IN :contactIds];
        
        System.debug('contactLst: ' + contactLst);

        return contactLst;

    }

    @AuraEnabled
    public static void markForContactSelection(String recordId) {
        System.debug(LoggingLevel.INFO, 'CS_contactSelectorHelper - markForContactSelection');

        Lead ld = new Lead();
        ld.Id = recordId;
        ld.AutoConvertContactMatchStatus__c = 'Multiple results';
        update ld;

    }

    @AuraEnabled
    public static void updateLead(String leadId, String contactId){
        System.debug(LoggingLevel.INFO, 'CS_contactSelectorHelper - updateLead');

        System.debug('leadId = ' + leadId + ' // contactId = ' +contactId);
        Lead ld = new Lead(); 
        ld.Id = leadId;
        ld.Contact__c = contactId;
        ld.AutoConvertContactMatchStatus__c = '';

        update ld;
    }

}