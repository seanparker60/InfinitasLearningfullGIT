@IsTest
public class FRM_firstReleaseManagement_Batch_TEST {
    
    @TestSetup
    static void makeData(){
        Product2[] products = FRM_TestDatafactory.createProducts(true);
        Account[] accounts = FRM_TestDatafactory.createAccounts(true);
        firstReleasePartner__c[] firstReleasePartners = FRM_TestDatafactory.createFirstReleasePartners(accounts, true);
    }
    
    @IsTest
    static void testPlantyn(){
        
        Test.startTest();
            FRM_firstReleaseManagement_Batch firstReleaseBatch = new FRM_firstReleaseManagement_Batch('Plantyn');
            Id batchprocessid = Database.executebatch(firstReleaseBatch, 200);
        Test.stopTest();
        
    }

    @IsTest
    static void testNoordhoff(){
        
        Test.startTest();
            FRM_firstReleaseManagement_Batch firstReleaseBatch = new FRM_firstReleaseManagement_Batch('Noordhoff');
            Id batchprocessid = Database.executebatch(firstReleaseBatch, 200);
        Test.stopTest();
        
    }

    @IsTest
    static void testLiber(){

        Product2[] products = [SELECT Id, Name, Subsidiary__c, ISBN__c, Stocknumber__c, Type__c, FirstPublicationDate__c FROM Product2 ORDER BY Subsidiary__c];
        System.Debug('PRODUCTS:\n' + JSON.serializePretty(products));
        
        Test.startTest();
            FRM_firstReleaseManagement_Batch firstReleaseBatch = new FRM_firstReleaseManagement_Batch('Liber');
            Id batchprocessid = Database.executebatch(firstReleaseBatch, 200);
        Test.stopTest();
        
    }

}