@IsTest
public class AU_getCurrentAgodiAccounts_TEST {

    @TestSetup
    static void makeData(){
        AU_TestDataFactory.createMultipleAccounts(50, true);
    }

    @IsTest
    static void Test01(){
        
        Test.startTest();
            System.enqueueJob(new AU_getCurrentAgodiAccounts());
        Test.stopTest();
        
    }

    @IsTest
    static void Test02(){

        List<Account> acclst = [SELECT Id FROM Account LIMIT 10];
        
        Test.startTest();
            System.enqueueJob(new AU_getCurrentAgodiAccounts(accLst[accLst.size()-1].Id, acclst));
        Test.stopTest();
        
    }
}