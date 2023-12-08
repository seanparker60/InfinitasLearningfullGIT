@IsTest
public class LPD_customListPriceDiscountView_TEST {
    
    @TestSetup
    static void makeData(){
        
        Product2 p = New Product2();
        p.Name = 'Test Product';
        p.ProductDiscountGroup__c = 'Workbooks';
        p.Subsidiary__c = 'Plantyn';
        p.IsInspectionCopyOrderPossible__c = true;
        p.IsRegularOrderPossible__c = true;
        p.MarketSegment__c = 'Primary Education';
        insert p;

        List<ListPriceDiscount__c> lpdLst = new List<ListPriceDiscount__c>();

        for (Integer i = 0; i < 5; i++) {
            ListPriceDiscount__c lpd = New ListPriceDiscount__c();
            lpd.Subsidiary__c = 'Plantyn';
            lpd.StartQuantity__c = (i * 10) + 1;
            lpd.Rate__c = 0.00 + (i > 0 ? i / 10 : 0);
            lpd.ProductDiscountGroup__c = 'Workbooks';
            lpd.DiscountType__c = 'Market Segment';
            lpd.MarketSegment__c = 'PrimaryEducation';
            lpd.CustomerDiscountGroup__c = 'Educational Institution';
            lpd.OrderLineType__c = 'Regular';
            lpd.IsActive__c = true;
            lpdLst.add(lpd);
        }
        insert lpdLst;

        List<Account> accounts = MERGE_TestDataFactory.createAccounts(1, false);
        Id B2BEdicationalRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('B2B Educational').getRecordTypeId();

        accounts[0].RecordTypeId = B2BEdicationalRecordTypeId;
        accounts[0].CustomerCategory__c = 'Educational Institution';
        accounts[0].CustomerDiscountGroup__c = 'Educational Institution';
        insert accounts;

    }

    @IsTest
    static void testGetListPriceDiscountRecords(){
        
        Id productId = [SELECT Id FROM Product2 LIMIT 1].Id;

        Test.startTest();
            List<ListPriceDiscount__c> lpdLst = LPD_customListPriceDiscountView_Helper.getListPriceDiscountRecords(productId);
        Test.stopTest();
        
        System.assertEquals(5, lpdLst.size());
    }

    @isTest
    static void testGetListPriceDiscountRecordsForAccount() {

        Account testAccount = [SELECT Id FROM Account Limit 1];

        Test.startTest();
        List<ListPriceDiscount__c> lpdLst = LPD_customListPriceDiscountView_Helper.getListPriceDiscountRecordsForAccount(testAccount.Id);
        Test.stopTest();

        System.assertEquals(5, lpdLst.size());
    }
}