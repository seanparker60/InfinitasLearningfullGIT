@isTest
public with sharing class Order_AssetRenewalDatesInvoc_TEST {
    public static testmethod void testResetAssetsRenewalDates(){

        List<Order_AssetRenewalDatesInvoc.FlowInputs> flowInputsTestList = new List<Order_AssetRenewalDatesInvoc.FlowInputs>();
        Order_AssetRenewalDatesInvoc.FlowInputs flowInputsTest = new Order_AssetRenewalDatesInvoc.FlowInputs();

        Test.startTest();

        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Plantyn',true,true);
        List<Product2> lstProduct = TestDataFactory.insertProducts(1,true);
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Asset>lst_Asset = TestDataFactory.insertAsset(standardPricebook.id ,lstProduct,lstAccount, lstAccount,false);
        insert lst_Asset;

        List<String> assetIds = new List <String>();
        for(Asset ass:lst_Asset){
            assetIds.add(ass.Id);
        }
        flowInputsTest.assetsIdList = assetIds;
        flowInputsTest.allowRenewal = true;
        flowInputsTestList.add(flowInputsTest);

        Order_AssetRenewalDatesInvoc.resetAssetsRenewalDates(flowInputsTestList);

        List<Asset> updatedAssetList = [SELECT AssetRenewalTrigger__c FROM Asset WHERE Id =: lst_Asset[0].Id];
        System.assertEquals(true, updatedAssetList[0].AssetRenewalTrigger__c);
        Test.stopTest();
    }
}