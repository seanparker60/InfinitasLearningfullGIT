@IsTest
public class ML_manageLeaversController_TEST {
    
    @TestSetup
    static void makeData(){
        System.runAs(new User(Id = Userinfo.getUserId())) {
            ML_TestDatafactory.createUser();
            ML_TestDatafactory.createSecondUser();
        }        
        User u = [SELECT Id FROM User WHERE UserName = 'testuser_username@test.com'];
        List<Account> accounts = ML_TestDatafactory.createAccounts(u.Id);
        List<Contact> contacts = ML_TestDatafactory.createContacts(u.Id, accounts[0].Id);
        List<Order> orders = ML_TestDatafactory.createOrders(u.Id, accounts[0].Id);
        List<Opportunity> opportunities = ML_TestDatafactory.createOpportunities(u.Id);
        List<Case> cases = ML_TestDatafactory.createCases(u.Id, accounts[0].Id, contacts[0].Id);
        List<Campaign> campaigns = ML_TestDatafactory.createCampaigns(u.Id);
    }

    @IsTest
    public static void testRecordMethods() {
        User u = [SELECT Id FROM User WHERE UserName = 'testuser_username@test.com'];
        User u2 = [SELECT Id FROM User WHERE UserName = 'testuser2_username@test.com'];

        Test.startTest();
            // TEST Check Record
            List<Account> accountList =         ML_manageLeaversController.checkAccounts(String.valueOf(u.Id));
            List<Contact> contactList =         ML_manageLeaversController.checkContacts(String.valueOf(u.Id));
            List<Order> orderList =             ML_manageLeaversController.checkOrders(String.valueOf(u.Id));
            List<Opportunity> opportunityList = ML_manageLeaversController.checkOpportunities(u.Id);
            List<Case> caseList =               ML_manageLeaversController.checkCases(u.Id);
            List<Campaign> campaignList =       ML_manageLeaversController.checkCampaigns(u.Id);
            List<ApexIds__mdt> apexIdList =     ML_manageLeaversController.checkCustomMetadataTypes(u.Id);

            // Test Update RecordOwner
            String accountResult =      ML_manageLeaversController.updateAccountOwner(accountList, u2.Id);
            String contactResult =      ML_manageLeaversController.updateContactOwner(contactList, u2.Id);
            String orderResult =        ML_manageLeaversController.updateOrderOwner(orderList, u2.Id);
            String opportunityResult =  ML_manageLeaversController.updateOpportunityOwner(opportunityList, u2.Id);
            String caseResult =         ML_manageLeaversController.updateCaseOwner(caseList, u2.Id);
            String campaignResult =     ML_manageLeaversController.updateCampaignOwner(campaignList, u2.Id);
        Test.stopTest();

        // Assert check record results
        System.assertEquals(2, accountList.size());
        System.assertEquals(3, contactList.size());
        System.assertEquals(6, orderList.size());
        System.assertEquals(4, opportunityList.size());
        System.assertEquals(6, caseList.size());
        System.assertEquals(3, campaignList.size());

        // Assert update recordOwner results
    }

    @IsTest
    public static void testDeactivateUser() {
        User u = [SELECT Id FROM User WHERE UserName = 'testuser_username@test.com'];

        Test.startTest();
            String result = ML_manageLeaversController.deactivateUser(u.Id);
        Test.stopTest();

        System.assertEquals('Success', result);
        System.assertEquals(false, [SELECT IsActive FROM User WHERE UserName = 'testuser_username@test.com' LIMIT 1].IsActive);
    }
    
    @IsTest
    public static void testgetObjects() {
        User u = [SELECT Id FROM User WHERE UserName = 'testuser_username@test.com'];

        List<Case> debugCaseList = [SELECT Id, IsClosed FROM Case];
        Integer counter = 1;
        for (Case c : debugCaseList) {
            System.debug('Case ' + counter + ' IsClosed => ' + c.IsClosed);
        }

        Test.startTest();
            List<Account> accountList = ML_manageLeaversController.checkAccounts(String.valueOf(u.Id));
            List<Contact> contactList = ML_manageLeaversController.checkContacts(String.valueOf(u.Id));
            List<Order> orderList = ML_manageLeaversController.checkOrders(String.valueOf(u.Id));
            List<Opportunity> opportunityList = ML_manageLeaversController.checkOpportunities(u.Id);
            List<Case> caseList = ML_manageLeaversController.checkCases(u.Id);
            List<Campaign> campaignList = ML_manageLeaversController.checkCampaigns(u.Id);
            List<ApexIds__mdt> apexIdList = ML_manageLeaversController.checkCustomMetadataTypes(u.Id);
        Test.stopTest();

        System.assertEquals(2, accountList.size());
        System.assertEquals(3, contactList.size());
        System.assertEquals(6, orderList.size());
        System.assertEquals(4, opportunityList.size());
        System.assertEquals(6, caseList.size());
        System.assertEquals(3, campaignList.size());
    }

    @IsTest
    static void testGetZendeskUser(){
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ML_TestDatafactory.ZdMock());
            String userId = ML_manageLeaversController.getZendeskUser('testuser@test.com');
        Test.stopTest();

        system.assertEquals('123456789012', userId);
    }

    @IsTest
    static void testSuspendZendeskdUser(){
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ML_TestDatafactory.ZdMock());
            Integer responseCode = ML_manageLeaversController.suspendZendeskdUser('123456789012');
        Test.stopTest();

        system.assertEquals(200, responseCode);
    }

    @IsTest
    static void testGetSwellUser(){
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ML_TestDatafactory.SwellMock());
            String userId = ML_manageLeaversController.getSwellUser('testuser@test.com');
        Test.stopTest();

        system.assertEquals('123a1234b123456cc123456d', userId);
    }

    @IsTest
    static void testDeleteSwellUser(){
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ML_TestDatafactory.SwellMock());
            Integer statuscode = ML_manageLeaversController.deleteSwellUser('123a1234b123456cc123456d');
        Test.stopTest();

        system.assertEquals(200, statuscode);
    }
}