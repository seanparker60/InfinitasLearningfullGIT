@Istest
public with sharing class Order_AccountSubsidiary_Test {
    



public static testmethod void Order_AccountSubsidiary(){

    TestDataFactory.insertAccountsSubsidiary(1, 'Noordhoff',true,true);

    UTIL_TestClassExceptions.TESTCLASSEXCEPTION=true;

    List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Noordhoff',true,false);

    lstAccount[0].name = 'Subsid1';
    lstAccount[0].NetsuiteInternalId__c = '10000';

    insert lstAccount;

    List<Id> Accid = new List<Id>();

    for(Account acc:lstAccount){
        Accid.add(acc.id);
    }

    Order_AccountSubsidiary.AccountSubsidiary(Accid);


}

}