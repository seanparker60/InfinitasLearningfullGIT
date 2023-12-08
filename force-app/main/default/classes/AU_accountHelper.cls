public class AU_accountHelper implements Queueable {

    List<Account> AccountsIM, AccountsSG, AccountsS;
    Map<String, Id> accountMapScholen = new Map<String, Id>();
    
    List<Id> createdAccounts = new List<Id>();
    List<Id> updatedAccounts = new List<Id>();

    public Boolean imCreated = false;
    public Boolean sgCreated = false;
    public Boolean sCreated = false;

    Integer batchSize = 300;

    AgodiUpdate__c au;

    public AU_accountHelper(AgodiUpdate__c agodiUpdate, List<Account> scholenAccounts) {
        this.au = agodiUpdate;
        this.AccountsS = scholenAccounts;
        this.imCreated = true;
        this.sgCreated = true;
    }

    public AU_accountHelper(List<Account> accountListIM, List<Account> accountListSG, List<Account> accountListS) {
        System.debug('AU_accountHelper - upsert');
        this.AccountsIM = accountListIM;
        this.AccountsSG = accountListSG;
        this.AccountsS = accountListS;

        au = new AgodiUpdate__c();
        insert au;
    }

    public void execute(QueueableContext context) {
                
        // ############# UPSERT ACCOUNTS #############
        if (!imCreated) {

            System.debug('Create IM Accounts');
            Database.UpsertResult[] resultsIM = Database.upsert(this.AccountsIM, false);
            imCreated = true;

            for (Integer i = 0; i < resultsIM.size(); i++) {
                if (resultsIM[i].isSuccess()) {
                    if (resultsIM[i].isCreated()) {
                        this.createdAccounts.add(this.AccountsIM[i].Id);
                    } else {
                        this.updatedAccounts.add(this.AccountsIM[i].Id);
                    }
                }
            }
            handleUpsertResults('InrichtendeMacht', resultsIM, this.AccountsIM, this.au.Id);

            if (!Test.isRunningTest()) {
                System.enqueueJob(this);
                return;
            }

        } else if (!sgCreated) {

            System.debug('Create SG Accounts');
            Database.UpsertResult[] resultsSG = Database.upsert(this.AccountsSG, false);
            sgCreated = true;

            for (Integer i = 0; i < resultsSG.size(); i++) {
                if (resultsSG[i].isSuccess()) {
                    if (resultsSG[i].isCreated()) {
                        this.createdAccounts.add(this.AccountsSG[i].Id);
                    } else {
                        this.updatedAccounts.add(this.AccountsSG[i].Id);
                    }
                }
            }
            handleUpsertResults('ScholenGemeenschappen', resultsSG, this.AccountsSG, this.au.Id);

            if (!Test.isRunningTest()) {
                System.enqueueJob(this);
                return;
            }

        } else {

            System.debug('Create S Accounts || this.AccountsS Size = ' + this.AccountsS.size());
            if (!this.AccountsS.isEmpty()) {
                
                List<Account> tempAccountSList = new List<Account>();
                for (Integer i = 0; i < math.min(this.batchSize, this.AccountsS.size()); i++) {
                    tempAccountSList.add(this.AccountsS.remove(0));
                }
                System.debug('tempAccountSList size = ' + tempAccountSList.size()); // TEMP Testing
                Database.UpsertResult[] resultsS = Database.upsert(tempAccountSList, false);

                for (Integer i = 0; i < resultsS.size(); i++) {
                    if (resultsS[i].isSuccess()) {
                        if (resultsS[i].isCreated()) {
                            this.createdAccounts.add(tempAccountSList[i].Id);
                        } else {
                            this.updatedAccounts.add(tempAccountSList[i].Id);
                        }
                    }
                }

                System.debug('resultsS size ==> ' + resultsS.size() + ' || tempAccountSList size ==> ' + tempAccountSList.size());
                accountMapScholen.putAll(handleUpsertResults('Scholen', resultsS, tempAccountSList, this.au.Id));
                if (!Test.isRunningTest()) {
                    System.enqueueJob(this);
                    // System.enqueueJob(new AU_accountHelper(this.au, this.AccountsS));
                    return;
                }
            
            } else if (!Test.isRunningTest()) {
                // Next step ==> Get updated list of Agodi Accounte before  create structure between School and Inrichtende machten + Scolengemeenschappen
                System.enqueueJob(new AU_agodiHelper(false, true, accountMapScholen, au.Id, this.createdAccounts, this.updatedAccounts));
            }
        }
    }

    public static Map<String, Id> handleUpsertResults(String accountType, List<Database.UpsertResult> results, List<Account> accounts, Id agodiUpdateId) {
        Map<String, Id> returnMap = new Map<String, Id>();

        // ############# GET RESULTS FROM UPSERT #############
        String resultString = '';

        System.debug('AgodiUpdateId ==> ' + agodiUpdateId);
        for (Integer i = 0; i < results.size(); i++) {
            if (results[i].isSuccess()) {
                returnMap.put(accounts[i].ExternalCustomerId__c, accounts[i].Id);
                if (results[i].isCreated()) {
                    resultString += accountType + ',' + accounts[i].Id + ',' + accounts[i].ExternalCustomerId__c + ',inserted,\n';
                } else {
                    resultString += accountType + ',' + accounts[i].Id + ',' + accounts[i].ExternalCustomerId__c + ',updated,\n';
                }
            } else {
                String tmperr = '';
                for (Database.Error err : results[i].getErrors()) {
                    tmperr += '==> ' + err.getStatusCode() + ' : ' + err.getMessage();
                    System.debug('==========> ERROR: ' + err.getMessage());
                }
                resultString += accountType + ',' + accounts[i].Id + ',' + accounts[i].ExternalCustomerId__c + ',error,' + tmperr + '\n';
            }
        }

        // ############# CREATE FILE FROM RESULTS OF UPSERT AND ATTACH TO AGODI-UPDATE RECORD #############
        String content = 'AccountType,ID,ExternalCustomerId,Result,error\n';
        content += resultString;

        // create File (ContentVersion)
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';
        conVer.PathOnClient = 'Results_' + accountType + '.csv';
        conVer.Title = 'Results_' + accountType + '.csv';
        conVer.VersionData = Blob.valueOf(content);
        insert conVer;

        // Link file to object
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = agodiUpdateId;
        conDocLink.ContentDocumentId = conDoc;
        conDocLink.shareType = 'V';
        insert conDocLink;

        return returnMap;
    }

}