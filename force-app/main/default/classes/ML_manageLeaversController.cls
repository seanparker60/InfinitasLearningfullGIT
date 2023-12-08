public class ML_manageLeaversController {
    
    @AuraEnabled
    public static List<User> getUsers(){
        
        List<User> userList = [SELECT Id, Email, Name FROM User];

        return userList;

    }

    @AuraEnabled
    public static string getZendeskUser(String email){

        System.Domain domain = System.DomainParser.parse(URL.getOrgDomainUrl());

        String endpoint = '';
        String Authentication;
        if (domain.getSandboxName() != null) {
            endpoint = 'https://noordhoff1615549383.zendesk.com/api/v2/users/search.json?query=email:' + email; // Sandbox endpoint
            Authentication = 'Basic cndpbGxlbXNAaW5maW5pdGFzbGVhcm5pbmcuY29tL3Rva2VuOmFsQ0IzNFRuQzZzWFltTjRScDFESTU5ODlHTEJ2TjVHVlpNNE9WczE=';
        } else {
            endpoint = 'https://noordhoff.zendesk.com/api/v2/users/search.json?query=email:' + email + ' role:agent'; // Production Endpoint
            Authentication = 'Basic amtsZWVyZWJlemVtQGluZmluaXRhc2xlYXJuaW5nLmNvbS90b2tlbjpVd09wbkhtOWx6RUQ3Z2M5aXBOakhrc1c0QlR5YXRYaFpXTEZFMEo0';
        }

        // Instantiate a new http object
        Http h = new Http();

        // Instantiate a new HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setTimeout(60000); //sets maximum timeout
        req.setMethod('GET');
        req.setHeader('Content-type', 'application/json');
        req.setHeader('Authorization', Authentication); // Login Details

        System.debug('Request: ' + req);
        String body = '';

        // Send the request, and return a response
        try {
            HttpResponse res = h.send(req);
            body = res.getBody();

            Integer statusCode = res.getStatusCode();

            if (statusCode == 200) {
                System.debug('Correct Response from API, Statuscode: ' + statusCode + ', returning body.');
                System.debug('Body:\n' + body);
                System.debug('JSON Body:\n' + JSON.serializePretty(body));

            } else {
                System.debug('Incorrect Response from API, Statuscode: ' + statusCode);
                body = '';
            }
            if (body == '') {
                System.debug('Body is empty');
                return '';
            }
        } catch (Exception exc) {
            return 'Error: ' + Exc.getMessage();
        } 

        JSONParser parser = JSON.createParser(body);

        Integer counter = 1;
        Integer parserCount = 1;

        List<Usr> userList = new List<Usr>();
        String userIds = '';

        while (parser.nextToken() != null) {

            if (parser.getCurrentToken() == JSONToken.START_ARRAY && parser.getCurrentName() == 'users') {

                System.debug('Round ' + counter);
                counter ++;

                while (parser.nextToken() != null) {

                    System.debug('ParserCount ' + parserCount);
                    parserCount ++;
                    
                    Usr usr = (Usr)parser.readValueAs(Usr.class);
                    if (usr == null) {
                        break;
                    }
                    parser.skipChildren();

                    userList.add(usr);
                    System.debug('User ==> \n' + JSON.serializePretty(usr));

                    if (userIds.length() > 1) {
                        userIds += ',' + usr.id;
                    } else userIds = usr.id;
                }
            }
        }

        if (userList.size() > 1) {
            System.debug('Too many users are found on this email address');
        } else if (userList.size() < 1) {
            System.debug('No users are found on this email address');
        }

        return userIds;
    }

    @AuraEnabled
    public static Integer suspendZendeskdUser (String userId) {
        Integer responseStatus;

        System.Domain domain = System.DomainParser.parse(URL.getOrgDomainUrl());

        String endpoint = '';
        String Authorization;
        if (domain.getSandboxName() != null) {
            endpoint = 'https://noordhoff1615549383.zendesk.com/api/v2/users/update_many.json'; // Sandbox endpoint
            Authorization = 'Basic cndpbGxlbXNAaW5maW5pdGFzbGVhcm5pbmcuY29tL3Rva2VuOmFsQ0IzNFRuQzZzWFltTjRScDFESTU5ODlHTEJ2TjVHVlpNNE9WczE=';
        } else {
            endpoint = 'https://noordhoff.zendesk.com/api/v2/users/update_many.json'; // Production Endpoint
            Authorization = 'Basic amtsZWVyZWJlemVtQGluZmluaXRhc2xlYXJuaW5nLmNvbS90b2tlbjpVd09wbkhtOWx6RUQ3Z2M5aXBOakhrc1c0QlR5YXRYaFpXTEZFMEo0';
        }

        String updatedUsers = '{"id": ' + userId + ', "suspended": true, "user_type": "end_user"}';

        // Create Body
        String body = '{"users": [' + updatedUsers + '] }';
    
        // Instantiate a new http object
        Http h = new Http();
        
        // Instantiate a new HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setTimeout(60000); //sets maximum timeout
        req.setMethod('PUT');
        req.setHeader('Content-type', 'application/json');
        req.setHeader('Authorization', Authorization); // Login Details
        req.setBody(body);

        // Send the request, and return a response
        HttpResponse res = h.send(req);

        responseStatus = res.getStatusCode();

        return responseStatus;
    }

     // #################### WRAPPER CLASS FOR ZD USERS ####################
     public class Usr {
        public String id;
        public String url;
        public String name;
        public String email;
        public Datetime created_at;
        public Datetime updated_at;
        public String time_zone;
        public String iana_time_zone;
        public String phone;
        public String shared_phone_number;
        public Integer locale_id;
        public String locale;
        public String organization_id;
        public String role;
        public Boolean verified;
        public String external_id;
        public String alias;
        public Boolean active;
        public Boolean shared;
        public String shared_agent;
        public Datetime last_login_at;
        public String two_factor_auth_enabled;
        public String signature;
        public String details;
        public String notes;
        public Integer role_type;
        public String custom_role_id;
        public Boolean moderator;
        public String ticket_restriction;
        public Boolean only_private_comments;
        public Boolean restricted_agent;
        public Boolean suspended;
        public String default_group_id;
        public Boolean report_csv;
        public UserFields user_fields;
    }

    public class UserFields {
        public Boolean agent_ooo;
        public String mobilephone;
        public String phone;
        public String teachernumber;
        public Boolean zdsync;
    }

    @AuraEnabled
    public static string getSwellUser(String email){
        
        String body = '';

        // CREATE ENDPOINT
        String endpoint = 'https://api.swell.store/:users?where[email]=' + email;

        // Instantiate a new http object
        Http h = new Http();

        // Instantiate a new HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setTimeout(20000);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Basic aW5maW5pdGFzLW5vb3JkaG9mZi1ubC1wcm9kOjNicjFZaWxXeElPR3phdk04VGxTV2RxYXFacWlKYUxY');
        req.setHeader('Content-type', 'application/json');

        System.debug('full Request ==> ' + req);

        // Send the request, and return the response
        HttpResponse res = h.send(req);
        Integer statusCode = res.getStatusCode();
        if (statusCode == 200) {
            body = res.getBody();
        } else if (statusCode > 499 && statusCode < 600) {
            System.debug('There seems to be a problem on the Swell API server, Statuscode: ' + res.getStatusCode());
            System.debug('Body: ' + res.getBody());
        } else {
            System.debug('Incorrect response from Swell API, Statuscode: ' + res.getStatusCode());
        }

        System.debug('BODY:\n' + body);

        List<swellUser> swellUserList = new List<swellUser>();

        if (body == '') {
            System.debug('Body is empty');
            return '';
        }
        JSONParser parser = JSON.createParser(body);
        String swellUserIds = '';

        while (parser.nextToken() != null) {

            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    
                    swellUser usr = (swellUser)parser.readValueAs(swellUser.class);
                    if (usr == null) {
                        break;
                    }
                    parser.skipChildren();

                    swellUserList.add(usr);

                    if (swellUserIds.length() > 1) {
                        swellUserIds += ',' + usr.id;
                    } else {
                        swellUserIds = usr.id;
                    }
                }
            }
        }

        System.debug('-------------------------------------[ Complete User List ]-------------------------------------\n' + JSON.serializePretty(swellUserList));

        return swellUserIds;

    }

    @AuraEnabled
    public static Integer deleteSwellUser(String userId) {
        
        // CREATE ENDPOINT
        String endpoint = 'https://api.swell.store/:users/' + userId;

        // Instantiate a new http object
        Http h = new Http();

        // Instantiate a new HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setTimeout(20000);
        req.setMethod('DELETE');
        req.setHeader('Authorization', 'Basic aW5maW5pdGFzLW5vb3JkaG9mZi1ubC1wcm9kOjNicjFZaWxXeElPR3phdk04VGxTV2RxYXFacWlKYUxY');
        // req.setHeader('Content-type', 'application/json');

        System.debug('full Request ==> ' + req);

        // Send the request, and return the response
        HttpResponse res = h.send(req);
        Integer statusCode = res.getStatusCode();

        return statusCode;

    }

    // #################### WRAPPER CLASS FOR SWELL USERS ####################
    public class swellUser {
        public Datetime date_last_login;
        public String role_id;
        public String id;
        public String name;
        public String email;
    }

    @AuraEnabled
    public static List<Account> checkAccounts(String ownerId){
        return [SELECT Id FROM Account WHERE OwnerId = :ownerId];
    }

    @AuraEnabled
    public static List<Contact> checkContacts(String ownerId){
        return [SELECT Id FROM Contact WHERE OwnerId = :ownerId];
    }

    @AuraEnabled
    public static List<Order> checkOrders(String ownerId){
        return [SELECT Id FROM Order WHERE Status = 'Draft' AND OwnerId = :ownerId];
    }

    @AuraEnabled
    public static List<Opportunity> checkOpportunities(String ownerId){
        return [SELECT Id FROM Opportunity WHERE IsClosed = false AND OwnerId = :ownerId];
    }

    @AuraEnabled
    public static List<Case> checkCases(String ownerId){
        return [SELECT Id FROM Case WHERE IsClosed = false AND OwnerId = :ownerId];
    }

    @AuraEnabled
    public static List<Campaign> checkCampaigns(String ownerId){
        return [SELECT Id FROM Campaign WHERE IsActive = true AND OwnerId = :ownerId];
    }

    @AuraEnabled
    public static List<Dashboard> checkDashboards(String ownerId){
        return [SELECT Id, Title FROM Dashboard WHERE RunningUserId = :ownerId];
    }

    @AuraEnabled
    public static List<ApexIds__mdt> checkCustomMetadataTypes(String ownerId){

        List<ApexIds__mdt> returnList = new List<ApexIds__mdt>();

        List<ApexIds__mdt> apexIdRecords = ApexIds__mdt.getAll().Values();
        for(ApexIds__mdt aid : apexIdRecords) {

            System.debug('Check Values:\nownerId: ' + ownerId + '\nGeneralId__c: ' + aid.GeneralId__c + '\nNoordhoffId__c: ' + aid.NoordhoffId__c + '\nPlantynId__c: ' + aid.PlantynId__c + '\nLiberId__c: ' + aid.LiberId__c);
            if (aid.GeneralId__c == ownerId || aid.NoordhoffId__c == ownerId || aid.PlantynId__c == ownerId || aid.LiberId__c == ownerId) {
                returnList.add(aid);
            }
        }

        return returnList;
    }

    @AuraEnabled
    public static String deactivateUser(String userId){
        
        String errors = '';

        user u = new User();
        u.Id = userId;
        u.IsActive = false;
        
        Database.SaveResult sr = Database.update(u, false);

        if (!sr.success) {
            for(Database.Error err : sr.getErrors()) {
                errors += err.getMessage() + '\n';
            }
        }
        
        if (errors.length() > 1) {
            return '\n---------- Account update Errors --------- \n' + errors + '----------------------------------------';
        } else {
            return 'Success';
        }
    }

    @AuraEnabled
    public static String updateAccountOwner(List<Account> accounts, String newOwnerId){
        
        String errors = '';

        if (accounts.size() > 0) {
            for (Account acc : accounts) {
                acc.OwnerId = newOwnerId;
            }
        }
        
        List<Database.SaveResult> srLst = Database.update(accounts, false);

        for (Database.SaveResult sr : srLst) {
            if (!sr.success) {
                for(Database.Error err : sr.getErrors()) {
                    errors += err.getMessage() + '\n';
                }
            }
        }
        
        if (errors.length() > 1) {
            return '\n---------- Account update Errors --------- \n' + errors + '----------------------------------------';
        } else {
            return 'Success';
        }
    }

    @AuraEnabled
    public static String updateContactOwner(List<Contact> contacts, String newOwnerId){
        
        String errors = '';

        if (contacts.size() > 0) {
            for (Contact con : contacts) {
                con.OwnerId = newOwnerId;
            }
        }
        
        List<Database.SaveResult> srLst = Database.update(contacts, false);

        for (Database.SaveResult sr : srLst) {
            if (!sr.success) {
                for(Database.Error err : sr.getErrors()) {
                    errors += err.getMessage() + '\n';
                }
            }
        }
        
        if (errors.length() > 1) {
            return '\n---------- Contact update Errors --------- \n' + errors + '----------------------------------------';
        } else {
            return 'Success';
        }
    }

    @AuraEnabled
    public static String updateOrderOwner(List<Order> orders, String newOwnerId){
        
        String errors = '';

        if (orders.size() > 0) {
            for (Order order : orders) {
                order.OwnerId = newOwnerId;
            }
        }
        
        List<Database.SaveResult> srLst = Database.update(orders, false);

        for (Database.SaveResult sr : srLst) {
            if (!sr.success) {
                for(Database.Error err : sr.getErrors()) {
                    errors += err.getMessage() + '\n';
                }
            }
        }
        
        if (errors.length() > 1) {
            return '\n---------- Order update Errors --------- \n' + errors + '----------------------------------------';
        } else {
            return 'Success';
        }
    }

    @AuraEnabled
    public static String updateOpportunityOwner(List<Opportunity> opportunity, String newOwnerId){
        
        String errors = '';

        if (opportunity.size() > 0) {
            for (Opportunity opp : opportunity) {
                opp.OwnerId = newOwnerId;
            }
        }
        
        List<Database.SaveResult> srLst = Database.update(opportunity, false);

        for (Database.SaveResult sr : srLst) {
            if (!sr.success) {
                for(Database.Error err : sr.getErrors()) {
                    errors += err.getMessage() + '\n';
                }
            }
        }
        
        if (errors.length() > 1) {
            return '\n---------- Opportunity update Errors --------- \n' + errors + '----------------------------------------';
        } else {
            return 'Success';
        }
    }

    @AuraEnabled
    public static String updateCaseOwner(List<Case> cases, String newOwnerId){
        
        String errors = '';

        if (cases.size() > 0) {
            for (Case c : cases) {
                c.OwnerId = newOwnerId;
            }
        }
        
        List<Database.SaveResult> srLst = Database.update(cases, false);

        for (Database.SaveResult sr : srLst) {
            if (!sr.success) {
                for(Database.Error err : sr.getErrors()) {
                    errors += err.getMessage() + '\n';
                }
            }
        }
        
        if (errors.length() > 1) {
            return '\n---------- Case update Errors --------- \n' + errors + '----------------------------------------';
        } else {
            return 'Success';
        }
    }

    @AuraEnabled
    public static String updateCampaignOwner(List<Campaign> campaigns, String newOwnerId){
        
        String errors = '';

        if (campaigns.size() > 0) {
            for (Campaign c : campaigns) {
                c.OwnerId = newOwnerId;
            }
        }
        
        List<Database.SaveResult> srLst = Database.update(campaigns, false);

        for (Database.SaveResult sr : srLst) {
            if (!sr.success) {
                for(Database.Error err : sr.getErrors()) {
                    errors += err.getMessage() + '\n';
                }
            }
        }
        
        if (errors.length() > 1) {
            return '\n---------- Campaign update Errors --------- \n' + errors + '----------------------------------------';
        } else {
            return 'Success';
        }
    }

}