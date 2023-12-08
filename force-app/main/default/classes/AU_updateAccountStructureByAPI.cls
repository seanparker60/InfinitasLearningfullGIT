/*/
*
*   Created By: Jannes Kleerebezem
*
*   Use to start the queue for updating the structure of Agodi Accounts
*   System.enqueueJob(new AU_updateAccountStructureByAPI(Map<String, Id> schoolNumberAccountIdMap));
*   or
*   System.enqueueJob(new AU_updateAccountStructureByAPI(Map<String, Id> schoolNumberAccountIdMap, Integer startNumber));
*
*   #############################################
*   #       MODIFICATION HISTORY                #
*   #############################################
*   Date        Initials    What was done
*   ---------------------------------------------
*   14-09-2022  JK          Created
*
/*/

public class AU_updateAccountStructureByAPI implements Queueable, Database.AllowsCallouts {

    Map<String, Id> accountMap;
    Integer start;
    Id agodiUpdateId;
    Map<String,Account> currentPlantynAccounts;
    List<String> schoolNumberList = new List<String>();
    List<Account> accountsForUpdate;
    List<Account> totalAccountList;
    List<Database.SaveResult> results;
    List<Id> createdAccountIdList, updatedAccountIdList;

    Integer batchSize = 75;
    Boolean keepCounting = true;

    public AU_updateAccountStructureByAPI(Map<String, Id> schoolNumberAccountIdMap, Map<String,Account> PlantynAccounts, Id agodiId, List<Id> createdAccounts, List<Id> updatedAccounts) {
        this.accountMap = schoolNumberAccountIdMap;
        this.start = 0;
        this.currentPlantynAccounts = PlantynAccounts;
        System.debug('schoolNumberAccountIdMap ==> ' + schoolNumberAccountIdMap);
        this.schoolNumberList.addAll(schoolNumberAccountIdMap.keySet());
        this.agodiUpdateId = agodiId;
        this.results = new List<Database.SaveResult>();
        this.createdAccountIdList = createdAccounts;
        this.updatedAccountIdList = updatedAccounts;
    }

    public AU_updateAccountStructureByAPI(Map<String, Id> schoolNumberAccountIdMap, Map<String,Account> PlantynAccounts, Integer startNumber, Id AgodiId, List<Account> accountsToUpdate, List<Database.SaveResult> resultList, List<Id> createdAccounts, List<Id> updatedAccounts) {
        System.debug('AU_updateAccountStructureByAPI.AU_updateAccountStructureByAPI(schoolNumberAccountIdMap, Startnumber: ' + startNumber + ')');
        this.accountMap = schoolNumberAccountIdMap;
        this.start = startNumber;
        this.currentPlantynAccounts = PlantynAccounts;
        this.schoolNumberList.addAll(schoolNumberAccountIdMap.keySet());
        this.agodiUpdateId = agodiId;
        this.accountsForUpdate = accountsToUpdate;
        this.results = resultList;
        this.createdAccountIdList = createdAccounts;
        this.updatedAccountIdList = updatedAccounts;
    }

    public void execute(QueueableContext context) {

        if (this.accountsForUpdate == null) {
            this.accountsForUpdate = new List<Account>();
        }

        List<Account> accountsToUpdateThisBatch = new List<Account>();

        System.debug('this.accountMap.size() ==> ' + this.accountMap.size());
        while (this.keepCounting && this.accountMap.size() > 0) {
            for (Integer i = this.start; i < math.min(this.accountMap.size(),(this.start + this.batchSize)); i++) {
                if (i >= (this.accountMap.size()-1)) {
                    this.keepCounting = false;
                    break;
                } else {
                    System.debug('i ==> ' + i);
                    Account acc = getAccountDetails(this.schoolNumberList[i], this.currentPlantynAccounts);
                    if (acc != null) {
                        accountsToUpdateThisBatch.add(acc);
                        this.accountsForUpdate.add(acc);
                    }
                }
            }
            System.debug('accountsToUpdateThisBatch: \n' + JSON.serializePretty(accountsToUpdateThisBatch));

            this.results.addAll(Database.Update(accountsToUpdateThisBatch, false));

            System.debug('keepCounting = ' + keepCounting);
            if (this.keepCounting) {
                this.start = this.start + this.batchSize;

                if (!Test.isRunningTest()) {
                    System.enqueueJob(new AU_updateAccountStructureByAPI(this.accountMap, this.currentPlantynAccounts, this.start, this.agodiUpdateId, this.accountsForUpdate, this.results, this.createdAccountIdList, this.updatedAccountIdList));
                }
                return;
            }
        }

        handleSaveResults(this.results, this.accountsForUpdate, this.agodiUpdateId);

        if (!Test.isRunningTest()) {
            System.enqueueJob(new AU_createAccSubsidiaries_queueable(this.createdAccountIdList, this.updatedAccountIdList));
        }

    }

    public static Account getAccountDetails(String schoolNumber, Map<String, Account> currentPlantynAccounts) {
        System.debug('AU_AgodiUpdateByAPI.getAccountDetails(' + schoolNumber + ')');

        String endpoint = 'https://onderwijs.api.vlaanderen.be/instellingsgegevens/instelling/v2/instelling';
        String key = 'eBVx7fy6T3iEaZMLjGjUUPiKaSDT9rSG';
        String completeEndpoint = endpoint + '/' + schoolNumber + '?apikey=' + key;

        // Instantiate a new http object
        Http h = new Http();
        
        // Instantiate a new HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(completeEndpoint);
        req.setTimeout(60000); //sets maximum timeout
        req.setMethod('GET');
        req.setHeader('Content-type', 'application/json');

        // Send the request, and return a response
        HttpResponse res = h.send(req);
        String body = res.getBody();

        Integer statusCode = res.getStatusCode();

        System.debug('STATUSCODE ===> ' + statusCode);

        Account acc = new Account();
        Boolean returnAccount = false;

        if (currentPlantynAccounts.containsKey(schoolNumber)) {
            acc.Id = currentPlantynAccounts.get(schoolNumber).Id;
        } else {
            return null;
        }

        if (statusCode == 200) {

            JSONParser parser = JSON.createParser(body);
            
            // Create List of Instellingen from returned JSON
            while (parser.nextToken() != null) {

                InstellingDetails inst = (InstellingDetails)parser.readValueAs(InstellingDetails.class);
                if (inst == null) {
                    break;
                }
                
                if (inst.instelling_bestuur != null) {
                    if (currentPlantynAccounts.containsKey(String.valueOf(inst.instelling_bestuur.instellingsnummer))) {
                        returnAccount = true;
                        acc.PurchasingGroup__c = currentPlantynAccounts.get(String.valueOf(inst.instelling_bestuur.instellingsnummer)).Id;
                    }
                }

                if (inst.instelling_scholengemeenschap != null) {
                    if (currentPlantynAccounts.containsKey(String.valueOf(inst.instelling_scholengemeenschap.instellingsnummer))) {
                        returnAccount = true;
                        acc.ParentId = currentPlantynAccounts.get(String.valueOf(inst.instelling_scholengemeenschap.instellingsnummer)).Id;
                    }
                }
            }
        } else {
            System.debug('Incorrect Response from API, Statuscode: ' + statusCode);
            return null;
        }

        if (returnAccount) {
            return acc;
        } else {
            return null;
        }

    }

    public static void handleSaveResults(List<Database.SaveResult> results, List<Account> accounts, Id agodiUpdateId) {

        // ############# GET RESULTS FROM UPSERT #############
        String resultString = '';

        for (Integer i = 0; i < results.size(); i++) {
            if (results[i].isSuccess()) {
                resultString += accounts[i].Id + ',' + accounts[i].ParentId + ',' + accounts[i].PurchasingGroup__c + ',Updated,\n';
            } else {
                String tmperr = '';
                for (Database.Error err : results[i].getErrors()) {
                    tmperr += '==> ' + err.getStatusCode() + ' : ' + err.getMessage();
                    System.debug('==========> ERROR: ' + err.getMessage());
                }
                resultString += accounts[i].Id + ',' + accounts[i].ParentId + ',' + accounts[i].PurchasingGroup__c + ',error,' + tmperr + '\n';
            }
        }

        // ############# CREATE FILE FROM RESULTS OF UPSERT AND ATTACH TO AGODI-UPDATE RECORD #############
        String content = 'ID,ParentId,PurcharingGroup__c,Status,Error\n';
        content += resultString;

        // create File (ContentVersion)
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';
        conVer.PathOnClient = 'Results_AccountStructure_Update.csv';
        conVer.Title = 'Results_AccountStructure_Update.csv';
        conVer.VersionData = Blob.valueOf(content);
        insert conVer;

        // Link file to object
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = agodiUpdateId;
        conDocLink.ContentDocumentId = conDoc;
        conDocLink.shareType = 'V';
        insert conDocLink;
    }

    // ########## WRAPPER CLASS INSTELLING DETAILS ##########
    public class InstellingDetails {
        public String instelling_naam;
        public String instelling_naam_volledig;
        public String instelling_volledige_naam;
        public Integer instelling_nummer;
        public Integer instelling_hoofdzetel_vestigingsnr;
        public String instelling_postcode;
        public String instelling_gemeente;
        public String instelling_straatnaam;
        public String instelling_huisnummer;
        public String instelling_busnummer;
        public String instelling_provincie;
        public instelling_niveau instelling_niveau; 
        public Boolean instelling_buitengewoon;
        public Boolean instelling_biedt_deeltijds_aan;
        public Boolean instelling_biedt_voltijds_aan;
        public instelling_net instelling_net;
        public instelling_levensbeschouwing instelling_levensbeschouwing;
        public instelling_taalstelsel instelling_taalstelsel;
        public String instelling_kbo_ondernemingsnummer;
        public String instelling_kbo_vestigingseenheidsnummer;
        public String instelling_telefoon;
        public String instelling_email;
        public String instelling_website;
        public String instelling_gemeente_nis;
        public String instelling_crab_code;
        public instelling_directeur instelling_directeur;
        public instelling_bestuur instelling_bestuur;
        public instelling_clb instelling_clb;
        public instelling_koepel instelling_koepel;
        public instelling_scholengemeenschap instelling_scholengemeenschap;
        public internaat internaat;
        public String instelling_begindatum;
        public String instelling_einddatum;
        public instelling_status_erkenning instelling_status_erkenning;
        public instelling_type instelling_type;
        //public instelling_hoofdstructuur instelling_hoofdstructuur;
        public instelling_pedagogische_methode instelling_pedagogische_methode;
        public instelling_soort_bestuur instelling_soort_bestuur;
        public String instelling_datum_laatste_wijziging;
    }
    public class instelling_niveau { public String code,omschrijving; }
    public class instelling_type { public String code,omschrijving; }
    public class instelling_net { public String code,omschrijving; }
    public class instelling_levensbeschouwing { public String code,omschrijving; }
    public class instelling_status_erkenning { public String code,omschrijving; }
    public class instelling_taalstelsel { public String code,omschrijving; }
    public class instelling_pedagogische_methode { public String code,omschrijving; }
    public class instelling_soort_bestuur { public String code,omschrijving; }
    public class instelling_directeur { public String naam; public String voornaam; }
    public class instelling_bestuur { public Integer instellingsnummer; public String naam; }
    public class instelling_clb { public Integer instellingsnummer; public String naam; }
    public class instelling_koepel { public Integer instellingsnummer; public String naam; }
    public class instelling_scholengemeenschap { public Integer instellingsnummer; public String naam; }
    public class internaat { public Integer instellingsnummer; public String naam; }
    //public class instelling_hoofdstructuur { public List<CodeOmschrijving> CodeOmschrijving; }
    //public class CodeOmschrijving { public String code,omschrijving; }
    // ########## END WRAPPER CLASS INSTELLING DETAILS ##########
}