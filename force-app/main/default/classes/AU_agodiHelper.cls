/*/
*
*   Created By: Jannes Kleerebezem
*
*   Use in Addition to the Agodi classes to assist in Getting all the Agodi Accounts in Salesforce
*   System.enqueueJob(new AU_agodiHelper());
*
*   #############################################
*   #       MODIFICATION HISTORY                #
*   #############################################
*   Date        Initials    What was done
*   ---------------------------------------------
*   16-09-2022  JK          Created
*
/*/

public class AU_agodiHelper implements Queueable, Database.AllowsCallouts {
    
    Boolean start_AU_AgodiUpdateByAPI = false;
    Boolean start_AU_updateAccountStructureByAPI = false;
    String lastId;
    Id agodiUpdateId;
    List<Account> agodiAccounts;
    Map<String, Id> accountMapScholen;
    List<Id> createdAccountIdList, updatedAccountIdList;

    public AU_agodiHelper(Boolean start_AgodiUpdate, Boolean start_UpdateAccountStructure) {

        if (start_AgodiUpdate && start_UpdateAccountStructure) {
            System.debug('ERROR, you can only start the Agodi Update OR the AccountStructure update, not both!');
            return;
        } else {
            this.start_AU_AgodiUpdateByAPI = start_AgodiUpdate;
            this.start_AU_updateAccountStructureByAPI = start_UpdateAccountStructure;
        }

        this.lastId = '';
    }

    public AU_agodiHelper(Boolean start_AgodiUpdate, Boolean start_UpdateAccountStructure, Map<String, Id> AccountScholenMap, Id agodiId, List<Id> createdAccountIds, List<Id> updatedAccountIds) {

        if (start_AgodiUpdate && start_UpdateAccountStructure) {
            System.debug('ERROR, you can only start the Agodi Update OR the AccountStructure update, not both!');
            return;
        } else {
            this.start_AU_AgodiUpdateByAPI = start_AgodiUpdate;
            this.start_AU_updateAccountStructureByAPI = start_UpdateAccountStructure;
            this.accountMapScholen = AccountScholenMap;
            this.agodiUpdateId = agodiId;
            this.createdAccountIdList = createdAccountIds;
            this.updatedAccountIdList = updatedAccountIds;
        }

        this.lastId = '';
    }

    public AU_agodiHelper(Boolean start_AgodiUpdate, Boolean start_UpdateAccountStructure, List<Account> accounts, String LastAccountId) {

        if (start_AgodiUpdate && start_UpdateAccountStructure) {
            System.debug('ERROR, you can only start the Agodi Update OR the AccountStructure update, not both!');
            return;
        } else {
            this.start_AU_AgodiUpdateByAPI = start_AgodiUpdate;
            this.start_AU_updateAccountStructureByAPI = start_UpdateAccountStructure;
        }

        this.lastId = LastAccountId;
        this.agodiAccounts = accounts;
    }

    public AU_agodiHelper(Boolean start_AgodiUpdate, Boolean start_UpdateAccountStructure, List<Account> accounts, Map<String, Id> AccountScholenMap, String LastAccountId) {

        if (start_AgodiUpdate && start_UpdateAccountStructure) {
            System.debug('ERROR, you can only start the Agodi Update OR the AccountStructure update, not both!');
            return;
        } else {
            this.start_AU_AgodiUpdateByAPI = start_AgodiUpdate;
            this.start_AU_updateAccountStructureByAPI = start_UpdateAccountStructure;
            this.accountMapScholen = AccountScholenMap;
        }

        this.lastId = LastAccountId;
        this.agodiAccounts = accounts;
    }

    public void execute(QueueableContext context) {

        Boolean rerun = false;

        List<Account> agodiAccountList = new List<Account>();
        if (this.agodiAccounts != null) {
            agodiAccountList = this.agodiAccounts;
        }

        List<Account> newAccounts = getCurrentPlantynAccounts(this.lastId);
        agodiAccountList.addAll(newAccounts);

        if (newAccounts.size() == 50000) {
            this.lastId = newAccounts[newAccounts.size()-1].Id;
            rerun = true;
        }

        if (rerun) {
            System.debug('rerunning [AU_agodiHelper]');
            if (this.accountMapScholen != null) {
                System.enqueueJob(new AU_agodiHelper(this.start_AU_AgodiUpdateByAPI, this.start_AU_updateAccountStructureByAPI, agodiAccountList, this.accountMapScholen, this.lastId));
            } else {
                System.enqueueJob(new AU_agodiHelper(this.start_AU_AgodiUpdateByAPI, this.start_AU_updateAccountStructureByAPI, agodiAccountList, this.lastId));
            }
        } else {

            // create AccountMap
            Map<String,Account> plantynAccountmap = new Map<String,Account>();
            for(Account a : agodiAccountList) {
                plantynAccountmap.put(a.ExternalCustomerId__c,a);
            }

            if (!Test.isRunningTest()) {

                if (this.start_AU_AgodiUpdateByAPI) {
                    System.debug('Starting [AU_AgodiUpdateByAPI]');
                    System.enqueueJob(new AU_AgodiUpdateByAPI(plantynAccountmap));
                }
        
                if (this.start_AU_updateAccountStructureByAPI) {
                    System.debug('Starting [AU_updateAccountStructureByAPI]');
                    System.enqueueJob(new AU_updateAccountStructureByAPI(this.accountMapScholen, plantynAccountmap, this.agodiUpdateId, this.createdAccountIdList, this.updatedAccountIdList));
                }

            }

        }

    }

    public static List<Account> getCurrentPlantynAccounts(String lastId) {
        System.debug('[AU_createAccountsFromAgodiData] - getCurrentPlantynAccounts');

        // Get the current Plantyn Accounts from SalesForce
        List<Account> currentPlantynAccounts = new List<Account>();
        try {
            if (lastId == '') {
                currentPlantynAccounts = [SELECT 
                    Id, 
                    Name, 
                    NumberOfStudents__c, 
                    LegalName__c, 
                    PurchasingGroup__c, 
                    ExternalCustomerId__c, 
                    ExternalDatabase__c,
                    PhoneCountry__c,
                    CustomerDiscountGroup__c,
                    Hfdstructuur__c 
                    FROM Account 
                    WHERE OperatingCompany__c = 'Plantyn'
                    AND ExternalDatabase__c = 'Agodi' 
                    AND ExternalCustomerId__c != '' LIMIT 50000];
            } else {
                currentPlantynAccounts = [SELECT 
                    Id, 
                    Name, 
                    NumberOfStudents__c, 
                    LegalName__c, 
                    PurchasingGroup__c, 
                    ExternalCustomerId__c, 
                    ExternalDatabase__c,
                    PhoneCountry__c,
                    CustomerDiscountGroup__c,
                    Hfdstructuur__c 
                    FROM Account 
                    WHERE OperatingCompany__c = 'Plantyn'
                    AND ExternalDatabase__c = 'Agodi' 
                    AND ExternalCustomerId__c != '' 
                    AND Id > :lastId LIMIT 50000];
            }
            

        } catch (Exception e) {
            System.debug('ERROR: ' + e.getMessage());
            HandleCustomException.LogException(e);
        }

        return currentPlantynAccounts;
    }

}