/*/
*
*   Created By: Jannes Kleerebezem
*
*   Use to suspend inactive Zendesk Users by API
*   can be called from flows
*   to start:
*   System.enqueueJob(new ZD_suspendInactiveUsers());
*
*   #############################################
*   #       MODIFICATION HISTORY                #
*   #############################################
*   Date        Initials    What was done
*   ---------------------------------------------
*   06-12-2022  JK          Created
*
/*/

public class ZD_suspendInactiveUsers implements Queueable, Database.AllowsCallouts {

    public void execute(QueueableContext context) {

        System.Domain domain = System.DomainParser.parse(URL.getOrgDomainUrl());

        String baseEndpoint;
        if (domain.getSandboxName() != null) {
            baseEndpoint = 'https://noordhoff1648817829.zendesk.com'; // Sandbox endpoint
        } else {
            baseEndpoint = 'https://noordhoff.zendesk.com'; // Production Endpoint
        }
        
        List<User> userList = new List<User>();
        String body = getInactiveUsers(baseEndpoint);

        if (body == '') {
            System.debug('Body is empty');
            return;
        }
        JSONParser parser = JSON.createParser(body);

        Integer counter = 1;
        Integer parserCount = 1;

        while (parser.nextToken() != null) {

            if (parser.getCurrentToken() == JSONToken.START_ARRAY && parser.getCurrentName() == 'users') {

                System.debug('Round ' + counter);
                counter ++;

                while (parser.nextToken() != null) {

                    System.debug('ParserCount ' + parserCount);
                    parserCount ++;
                    
                    User usr = (User)parser.readValueAs(User.class);
                    if (usr == null) {
                        break;
                    }
                    parser.skipChildren();

                    userList.add(usr);
                    System.debug('User ==> \n' + JSON.serializePretty(usr));
                }
            }
        }

        Integer response = suspendUsers(baseEndpoint, userList);
        System.debug('response on Suspending Users = ' + response);

    }

    public static String getInactiveUsers(String baseEndpoint) {

        string oneMonthAgo = String.valueOf(Date.today().addMonths(-1));

        String endpoint = baseEndpoint + '/api/v2/users/search.json';

        // Instantiate a new http object
        Http h = new Http();
        
        // Instantiate a new HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setTimeout(60000); //sets maximum timeout
        req.setMethod('GET');
        req.setHeader('Content-type', 'application/json');
        req.setHeader('query', 'Last sign-in:<' + oneMonthAgo + ' role:agent suspended:false'); // SEARCH QUERY
        req.setHeader('Authorization', 'Basic cndpbGxlbXNAaW5maW5pdGFzbGVhcm5pbmcuY29tL3Rva2VuOlcwMVV1UGxaVUNBZjFEa3FDU0NSbTJDMk8wb2dwN2pUTjBlZERSVkM='); // Login Details
        req.setHeader('Cookie', '_zendesk_cookie=BAhJIhl7ImRldmljZV90b2tlbnMiOnt9fQY6BkVU--459ed01949a36415c1716b5711271c3d08918307; __cfruid=7d8558e9018187c1009bfd2d63c4144de3208b93-1670314222'); // coolie settings

        System.debug('Request: ' + req);

        // Send the request, and return a response
        HttpResponse res = h.send(req);
        String body = res.getBody();

        Integer statusCode = res.getStatusCode();

        if (statusCode == 200) {
            System.debug('Correct Response from API, Statuscode: ' + statusCode + ', returning body.');
            System.debug('Body:\n' + body);
        } else {
            System.debug('Incorrect Response from API, Statuscode: ' + statusCode);
            body = '';
        }

        return body;
    }

    public static Integer suspendUsers (String baseEndpoint, List<User> users) {
        Integer responseStatus;

        String endpoint = baseEndpoint + '/api/v2/users/update_many.json';


        String updatedUsers = '';
        for (User u : users) {
            
            if (updatedUsers != '') {
                updatedUsers += ',';
            }
            updatedUsers += '{"id": ' + u.id + ', "suspended": true, "user_type": "end_user"}';

        }

        // Create Body
        String body = '{"users": [' + updatedUsers + '] }';

        System.debug('Body:\n' + body);
    
        // Instantiate a new http object
        Http h = new Http();
        
        // Instantiate a new HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setTimeout(60000); //sets maximum timeout
        req.setMethod('PUT');
        req.setHeader('Content-type', 'application/json');
        req.setHeader('Authorization', 'Basic cndpbGxlbXNAaW5maW5pdGFzbGVhcm5pbmcuY29tL3Rva2VuOlcwMVV1UGxaVUNBZjFEa3FDU0NSbTJDMk8wb2dwN2pUTjBlZERSVkM='); // Login Details
        req.setHeader('Cookie', '_zendesk_cookie=BAhJIhl7ImRldmljZV90b2tlbnMiOnt9fQY6BkVU--459ed01949a36415c1716b5711271c3d08918307; __cfruid=7d8558e9018187c1009bfd2d63c4144de3208b93-1670314222'); // coolie settings
        req.setBody(body);

        // Send the request, and return a response
        HttpResponse res = h.send(req);

        responseStatus = res.getStatusCode();

        return responseStatus;
    }

    // #################### WRAPPER CLASS FOR USERS ####################
    public class User {
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
        // public String photo;
        public Integer locale_id;
        public String locale;
        public String organization_id;
        public String role;
        public Boolean verified;
        public String external_id;
        // public Tags tags;
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

    // public class Tags {public String tag;}
    public class UserFields {
        public Boolean agent_ooo;
        public String mobilephone;
        public String phone;
        public String teachernumber;
        public Boolean zdsync;
    }
}