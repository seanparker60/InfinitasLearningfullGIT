@IsTest
public class KLOPOTEK_ManageClassificationsBatch_TEST {

    @TestSetup
    static void makeData(){
        KLOPOTEK_TestDataFactory.createData();
    }

    @IsTest
    static void test_ManageClassifications_Batch(){

        List<KlopotekClassification__c> kcLst = [SELECT  Id, CatCode__c, DocNr__c, SchNr__c, ValueDecimal__c, OperatingCompany__c FROM KlopotekClassification__c WHERE IsProcessed__c = false];
        
        Test.startTest();
            KLOPOTEK_ManageClassifications_Batch kmc = new KLOPOTEK_ManageClassifications_Batch();
            Database.executeBatch(kmc);
        Test.stopTest();
        
        System.assertEquals(20, [SELECT Id FROM ClassificationData__c].size());

    }
}