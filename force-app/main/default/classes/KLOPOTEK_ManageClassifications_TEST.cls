@IsTest
public class KLOPOTEK_ManageClassifications_TEST {

    @TestSetup
    static void makeData(){
        KLOPOTEK_TestDataFactory.createData();
    }

    @IsTest
    static void test_createClassifications(){

        List<KlopotekClassification__c> kcLst = [SELECT  Id, ContactId__c, AccountId__c, CatCode__c, DocNr__c, SchNr__c, ValueDecimal__c, OperatingCompany__c FROM KlopotekClassification__c WHERE IsProcessed__c = false];
        
        Test.startTest();
            KLOPOTEK_ManageClassifications.createClassifications(kcLst);
        Test.stopTest();
        
        System.assertEquals(20, [SELECT Id FROM ClassificationData__c].size());

    }
}