public class AU_createAccountsFromAgodiData {

    public static Map<String,Account> getCurrentPlantynAccounts() {
        System.debug('[AU_createAccountsFromAgodiData] - getCurrentPlantynAccounts');

        // Get the current Plantyn Accounts from SalesForce
        List<Account> currentPlantynAccounts = new List<Account>();
        try {
            currentPlantynAccounts = [SELECT 
                Id, 
                Name, 
                NumberOfStudents__c, 
                LegalName__c, 
                PurchasingGroup__c, 
                ExternalCustomerId__c, 
                ExternalDatabase__c,
                PhoneCountry__c,
                CustomerDiscountGroup__c 
                FROM Account 
                WHERE OperatingCompany__c = 'Plantyn'
                AND ExternalDatabase__c = 'Agodi' 
                AND ExternalCustomerId__c != ''];

        } catch (Exception e) {
            System.debug('ERROR: ' + e.getMessage());
            HandleCustomException.LogException(e);
        }
        
        // and create a map from these to Match Agodi Data with SalesForce data
        Map<String,Account> plantynAccountmap = new Map<String,Account>();
        for(Account a : currentPlantynAccounts) {
            plantynAccountmap.put(a.ExternalCustomerId__c,a);
        }

        return plantynAccountmap;

    }

}