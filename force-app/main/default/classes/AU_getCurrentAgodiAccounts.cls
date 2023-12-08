/*/
*
*   Created By: Jannes Kleerebezem
*
*   Use to start the queue for the Agodi Studentnumbers Update
*   System.enqueueJob(new AU_getCurrentAgodiAccounts());
*
*   #############################################
*   #       MODIFICATION HISTORY                #
*   #############################################
*   Date        Initials    What was done
*   ---------------------------------------------
*   11-10-2023  JK          Created
*
/*/

public class AU_getCurrentAgodiAccounts implements Queueable {

    public String lastId;
    public List<Account> accountList;

    public AU_getCurrentAgodiAccounts() {
        this.lastId = '';
        this.accountList = new List<Account>();
    }

    public AU_getCurrentAgodiAccounts(String lastQueriedId, List<Account> accounts) {
        this.lastId = lastQueriedId;
        this.accountList = accounts;
    }

    public void execute(QueueableContext context) {
        
        List<Account> newAccountList = getCurrentPlantynAccounts(this.lastId);
        this.accountList.addAll(newAccountList);
        
        if (!Test.isRunningTest()) {
            if (newAccountList.size() == 50000) {
                System.enqueueJob(new AU_getCurrentAgodiAccounts(newAccountList[newAccountList.size()-1].Id, this.accountList));
            } else {
                System.enqueueJob(new AU_AgodiStudentNumbersUpdateByAPI(this.accountList));
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
                    ExternalCustomerId__c, 
                    ExternalDatabase__c
                    FROM Account 
                    WHERE OperatingCompany__c = 'Plantyn'
                    AND ExternalDatabase__c = 'Agodi' 
                    AND ExternalCustomerId__c != '' LIMIT 50000];
            } else {
                currentPlantynAccounts = [SELECT 
                    Id, 
                    ExternalCustomerId__c, 
                    ExternalDatabase__c
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