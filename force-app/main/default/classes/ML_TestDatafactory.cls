@IsTest
public class ML_TestDatafactory {

    public static List<Campaign> createCampaigns(Id ownerId) {

        List<Campaign> campaignList = new List<Campaign>();

        for (Integer i = 0; i < 5; i++) {
            Campaign cam = new Campaign();
            cam.Name = 'Test Campaign ' +(i+1);
            cam.IsActive = true;
            if (i < 3) {
                cam.OwnerId = ownerId;
            }
            campaignList.add(cam);
        }

        insert campaignList;
        return campaignList;
    }

    public static List<Case> createCases(Id ownerId, Id accountId, Id contactId) {

        List<Case> caseList = new List<Case>();

        for (Integer i = 0; i < 10; i++) {
            Case c = new Case();
            c.AccountId = accountId;
            c.ContactId = contactId;
            c.Status = 'New';
            c.Origin = 'Email';
            if (i < 6) {
                c.OwnerId = ownerId;
            }
            caseList.add(c);
        }

        insert caseList;
        return caseList;
    }

    public static List<Opportunity> createOpportunities(Id ownerId) {

        List<Opportunity> opportunityList = new List<Opportunity>();

        for (Integer i = 0; i < 5; i++) {
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opportunity ' + (i+1);
            opp.StageName = 'S4 Proposal';
            opp.CloseDate = Date.today().addMonths(3);
            if (i < 4) {
                opp.OwnerId = ownerId;
            }
            opportunityList.add(opp);
        }

        insert opportunityList;
        return opportunityList;
    }

    public static List<Order> createOrders(Id ownerId, Id accountId) {

        List<Order> orderList = new List<Order>();

        for (Integer i = 0; i < 10; i++) {
            Order o = new Order();
            o.AccountId = accountId;
            o.EffectiveDate = Date.today();
            o.Status = 'Draft';
            if (i < 6) {
                o.OwnerId = ownerId;
            }
            orderList.add(o);
        }

        insert orderList;
        return orderList;
    }

    public static List<Contact> createContacts(Id ownerId, Id accountId) {

        List<Contact> contactList = new List<Contact>();

        for (Integer i = 0; i < 5; i++) {
            Contact con = new Contact();
            con.FirstName = 'Test';
            con.LastName = 'Contact ' + (i+1);
            con.Email = 'testContact' + (i+1) + '@test.com';
            con.AccountId = accountId;
            if (i < 3) {
                con.OwnerId = ownerId;
            }
            contactList.add(con);
        }
        insert contactList;
        return contactList;
    }

    public static List<Account> createAccounts(Id ownerId) {

        System.debug('OwnerId in Acc method => ' + ownerId);

        Id recordTypeId = [SELECT Id FROM Recordtype WHERE sObjectType = 'Account' AND Name = 'B2B Educational' LIMIT 1].Id;
        List<Account> accountList = new List<Account>();

        for (Integer i = 0; i < 5; i++) {
            Account acc = new Account();
            Acc.RecordTypeId = recordTypeId;
            Acc.Name = 'Test Account '+ (i+1);
            Acc.OperatingCompany__c = 'Plantyn';
            acc.CustomerCategory__c = 'Educational Institution';
            Acc.NetsuiteInternalId__c = '1234'+i;
            Acc.ShippingCity = 'Amsterdam';
            Acc.ShippingCountry = 'Netherlands';
            Acc.BillingCountry = 'Netherlands';
            Acc.ShippingPostalCode = '1224AM';
            Acc.BillingPostalCode = '1224AM';
            Acc.ShippingStreet = 'DePijp22';
            Acc.BillingStreet = 'DePijp22';
            Acc.invoicingEmail__c = 'test@test.be';
            Acc.Type = 'Customer';
            acc.Area__c = 'Dutch';
            if (i < 2) {
                acc.OwnerId = ownerId;
            }

            accountList.add(acc);
        }
        insert accountList;
        return accountList;
    }

    public static User createUser() {

        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test.com';
        u.Username = 'testuser_username@test.com';
        u.FederationIdentifier = 'testuser@test.com';
        u.Alias = 'tu';
        u.profileId = [SELECT Id FROM Profile WHERE Name = 'Plantyn' LIMIT 1].Id;
        u.TimeZoneSidKey = 'Europe/Amsterdam';
        u.LocaleSidKey = 'nl_NL';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.LanguageLocaleKey = 'nl_NL';

        insert u;
        return u;
    }

    public static User createSecondUser() {

        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User 2';
        u.Email = 'testuser2@test.com';
        u.Username = 'testuser2_username@test.com';
        u.FederationIdentifier = 'testuser2@test.com';
        u.Alias = 'tu2';
        u.profileId = [SELECT Id FROM Profile WHERE Name = 'Plantyn' LIMIT 1].Id;
        u.TimeZoneSidKey = 'Europe/Amsterdam';
        u.LocaleSidKey = 'nl_NL';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.LanguageLocaleKey = 'nl_NL';

        insert u;
        return u;
    }
    
    public class SwellMock implements HttpCalloutMock {

        public HttpResponse respond (HttpRequest req) {

            String body = '';

            body +='{';
            body +=    '"count": 1,';
            body +=    '"page_count": 1,';
            body +=    '"page": 1,';
            body +=    '"results": [';
            body +=     ' {';
            body +=        '"client_id": "infinitas-noordhoff-nl-prod",';
            body +=        '"notify": true,';
            body +=        '"all_permissions": true,';
            body +=        '"invited": true,';
            body +=        '"invite_key": null,';
            body +=        '"date_created": "2021-01-22T06:37:09.337Z",';
            body +=        '"role": "admin",';
            body +=        '"date_last_login": "2023-05-05T11:32:36.371Z",';
            body +=        '"date_updated": "2023-05-05T11:32:36.374Z",';
            body +=        '"id": "123a1234b123456cc123456d",';
            body +=        '"name": "Test User",';
            body +=        '"email": "testuser@test.com"';
            body +=     '}';
            body +=   ']';
            body +='}';

            HttpResponse res = new HttpResponse();

            res.setBody(body);
            res.setStatusCode(200);
            return Res;
        }
    }

    public class ZdMock implements HttpCalloutMock {

        public HttpResponse respond (HttpRequest req) {

            String body = '';

            body +='{';
            body +=    '"users": [';
            body +=        '{';
            body +=            '"id": 123456789012,';
            body +=            '"url": "https://noordhoff1615549383.zendesk.com/api/v2/users/380055098117.json",';
            body +=            '"name": "Test User",';
            body +=            '"email": "testuser@test.com",';
            body +=            '"created_at": "2021-03-12T11:43:14Z",';
            body +=            '"updated_at": "2023-05-05T09:45:45Z",';
            body +=            '"time_zone": "Amsterdam",';
            body +=            '"iana_time_zone": "Europe/Amsterdam",';
            body +=            '"phone": null,';
            body +=            '"shared_phone_number": null,';
            body +=            '"photo": null,';
            body +=            '"locale_id": 1,';
            body +=            '"locale": "en-US",';
            body +=            '"organization_id": 360410085177,';
            body +=            '"role": "admin",';
            body +=            '"verified": true,';
            body +=            '"external_id": null,';
            body +=            '"tags": [],';
            body +=            '"alias": null,';
            body +=            '"active": true,';
            body +=            '"shared": false,';
            body +=            '"shared_agent": false,';
            body +=            '"last_login_at": "2023-05-05T09:45:45Z",';
            body +=            '"two_factor_auth_enabled": null,';
            body +=            '"signature": null,';
            body +=            '"details": "",';
            body +=            '"notes": "",';
            body +=            '"role_type": 4,';
            body +=            '"custom_role_id": 360015203817,';
            body +=            '"moderator": true,';
            body +=            '"ticket_restriction": null,';
            body +=            '"only_private_comments": false,';
            body +=            '"restricted_agent": false,';
            body +=            '"suspended": false,';
            body +=            '"default_group_id": 360006114757,';
            body +=            '"report_csv": true,';
            body +=            '"user_fields": {';
            body +=                '"agent_ooo": false,';
            body +=                '"mobilephone": null,';
            body +=                '"phone": null,';
            body +=                '"salesforcecontactid": null,';
            body +=                '"teachernumber": null,';
            body +=                '"zdsync": false';
            body +=            '}';
            body +=        '}';
            body +=    '],';
            body +=    '"next_page": null,';
            body +=    '"previous_page": null,';
            body +=    '"count": 1';
            body +='}';

            HttpResponse res = new HttpResponse();

            res.setBody(body);
            res.setStatusCode(200);
            return Res;
        }
    }
}