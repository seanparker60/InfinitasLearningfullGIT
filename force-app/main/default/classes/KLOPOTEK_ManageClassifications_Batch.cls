/*/
*   @ Created By: Jannes Kleerebezem
*   @ Created on: 31-03-2021
*
*   Use: 
*   ==> Standard functionality is to run the Batch by schedule (via the class "KLOPOTEK_ManageClassifications_scheduler"), for funning this batch manualy use:
*   KLOPOTEK_ManageClassifications_Batch  manageClassifications = new KLOPOTEK_ManageClassifications_Batch();
*   Id batchprocessid = Database.executebatch(manageClassifications, 200);
*   
/*/
global class KLOPOTEK_ManageClassifications_Batch implements Database.Batchable<sObject>, Database.Stateful {

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, ContactId__c, AccountId__c, CatCode__c, DocNr__c, SchNr__c, ValueDecimal__c, OperatingCompany__c, IsProcessed__c FROM KlopotekClassification__c WHERE IsProcessed__c = false';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<KlopotekClassification__c> scope) {
        KLOPOTEK_ManageClassifications.createClassifications(scope);
    }

    global void finish(Database.BatchableContext BC) {

    }
}