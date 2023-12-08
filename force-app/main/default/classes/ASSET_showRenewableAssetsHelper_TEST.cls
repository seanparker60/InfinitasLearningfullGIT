@IsTest
public class ASSET_showRenewableAssetsHelper_TEST {
    
    @TestSetup
    static void makeData(){

        Date today = Date.today();
        Id B2BEducationalAccountId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('B2BEducational').getRecordTypeId();
        Id assetRecordtype = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Asset').getRecordTypeId();

        List<Account> accLst = New List<Account>();
        for (Integer i = 0; i < 2; i++) {
            Account acc = New Account();
            if (i == 0) {
                acc.Name = 'Test Ship-to Account';
            } else {
                acc.Name = 'Test Bill-to Account';
            }
            acc.RecordTypeId = B2BEducationalAccountId;
            acc.TypeOfAccount__c = 'Sales';
            acc.NumberofStudents__c = 0;
            acc.Area__c = 'Dutch';
            acc.OperatingCompany__c = 'Plantyn';
            accLst.add(acc);
        }
        insert accLst;

        List<Product2> productLst = New List<Product2>();
        for (Integer i = 0; i < 3; i++) {
            Product2 p = New Product2();
        p.Name = 'TestProduct ' + (i+1);
        p.Type__c = 'Inventory Item';
        if (i == 0) {
            p.Renewal__c = 'Automatic';
        } else {
            p.Renewal__c = 'Not relevant';
        }
        productLst.add(p);
        }
        insert productLst;

        List<Asset> assetLst = New List<Asset>();
        for (Integer i = 0; i < 3; i++) {
            Asset a = new Asset();
            a.Name = 'Test Asset ' + (i+1);
            a.RecordTypeId = assetRecordtype;
            a.Product2Id = productLst[i].Id;
            a.IsActive__c = true;
            a.AccountId = accLst[0].Id;
            a.BillToAccount__c = accLst[1].Id;
            a.ActivationDate__c = today;
            a.UsageEndDate = today.addMonths(12);
            a.RenewalDate__c = today.addMonths(10);
            a.Quantity = 5;
            assetLst.add(a);
        }
        
        insert assetLst;
        
    }

    @IsTest
    static void testGetShipToAssets(){
        
        Account shipTo = [SELECT Id FROM Account WHERE Name = 'Test Ship-to Account' LIMIT 1];

        Test.startTest();
            Asset[] assetLst = ASSET_showRenewableAssetsHelper.getAssetListForShipTo(shipTo.Id);
        Test.stopTest();
        
        System.assertEquals(1, assetLst.size());
    }

    @IsTest
    static void testGetSortedListForShipToAssets(){
        
        Account shipTo = [SELECT Id FROM Account WHERE Name = 'Test Ship-to Account' LIMIT 1];

        Test.startTest();
            Asset[] assetLst = ASSET_showRenewableAssetsHelper.getSortedAssetListForShipTo(String.ValueOf(shipTo.Id), 'customDate', 'ActivationDate__c', 'TODAY');
        Test.stopTest();
        
        System.assertEquals(1, assetLst.size());
    }

    @IsTest
    static void testGetNonRenewableShipToAssets(){
        
        Account shipTo = [SELECT Id FROM Account WHERE Name = 'Test Ship-to Account' LIMIT 1];
        

        Test.startTest();
            Asset[] assetLst = ASSET_showRenewableAssetsHelper.getNonRenewableAssetListForShipTo(shipTo.Id);
        Test.stopTest();
        
        System.assertEquals(2, assetLst.size());
    }

    @IsTest
    static void testGetNonRenewableSortedAssetListForShipTo(){
        
        Account shipTo = [SELECT Id FROM Account WHERE Name = 'Test Ship-to Account' LIMIT 1];
        

        Test.startTest();
            Asset[] assetLst = ASSET_showRenewableAssetsHelper.getNonRenewableSortedAssetListForShipTo(String.ValueOf(shipTo.Id), 'customDate', 'ActivationDate__c', 'TODAY');
        Test.stopTest();
        
        System.assertEquals(2, assetLst.size());
    }

    @IsTest
    static void testGetBillToAssets(){
        
        Account billTo = [SELECT Id FROM Account WHERE Name = 'Test Bill-to Account' LIMIT 1];

        Test.startTest();
            Asset[] assetLst = ASSET_showRenewableAssetsHelper.getAssetListForBillTo(billTo.Id);
        Test.stopTest();
        
        System.assertEquals(1, assetLst.size());
    }

    @IsTest
    static void testGetSortedListForBillToAssets(){
        
        Account billTo = [SELECT Id FROM Account WHERE Name = 'Test Bill-to Account' LIMIT 1];

        Test.startTest();
            Asset[] assetLst = ASSET_showRenewableAssetsHelper.getSortedAssetListForBillTo(String.ValueOf(billTo.Id), 'customDate', 'ActivationDate__c', 'TODAY');
        Test.stopTest();
        
        System.assertEquals(1, assetLst.size());
    }

    @IsTest
    static void testGetNonRenewableBillToAssets(){
        
        Account billTo = [SELECT Id FROM Account WHERE Name = 'Test Bill-to Account' LIMIT 1];
        

        Test.startTest();
            Asset[] assetLst = ASSET_showRenewableAssetsHelper.getNonRenewableAssetListForBillTo(billTo.Id);
        Test.stopTest();
        
        System.assertEquals(2, assetLst.size());
    }

    @IsTest
    static void testGetNonRenewableSortedAssetListForBillTo(){
        
        Account billTo = [SELECT Id FROM Account WHERE Name = 'Test Bill-to Account' LIMIT 1];
        

        Test.startTest();
            Asset[] assetLst = ASSET_showRenewableAssetsHelper.getNonRenewableSortedAssetListForBillTo(String.ValueOf(billTo.Id), 'customDate', 'ActivationDate__c', 'TODAY');
        Test.stopTest();
        
        System.assertEquals(2, assetLst.size());
    }

    @IsTest
    static void testGetAssetRecordType(){
        
        Test.startTest();
            Id assetId = ASSET_showRenewableAssetsHelper.getAssetRecordType();
        Test.stopTest();
        
        System.assertEquals(Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Asset').getRecordTypeId(), assetId);
    }
}