/*/
*
*   Created By: Jannes Kleerebezem
*
*   Use to deactivate inactive Swell Users by API
*   to start:
*   System.enqueueJob(new SWELL_deactivateInactiveUsers());
*
*   #############################################
*   #       MODIFICATION HISTORY                #
*   #############################################
*   Date        Initials    What was done
*   ---------------------------------------------
*   16-01-2023  JK          Created
*
/*/


public class SWELL_deactivateInactiveUsers implements Queueable, Database.AllowsCallouts {

    String baseEndpoint = 'https://api.swell.store';
    
    public void execute(QueueableContext context) {

        String body = getInactiveUsers(baseEndpoint);

        List<User> userList = new List<User>();

        if (body == '') {
            System.debug('Body is empty');
            return;
        }
        JSONParser parser = JSON.createParser(body);

        while (parser.nextToken() != null) {

            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    
                    User usr = (user)parser.readValueAs(User.class);
                    if (usr == null) {
                        break;
                    }
                    parser.skipChildren();

                    userList.add(usr);
                }
            }
        }

        System.debug('-------------------------------------[ Complete User List ]-------------------------------------\n' + JSON.serializePretty(userList));

        List<User> userDeleteList = new List<User>();
        for (User u : userList) {
            if (Datetime.now().addMonths(-2) > u.date_last_login && u.role_id != null && u.role_id != '620baedfc8305b013d3a0e3d') {
                userDeleteList.add(u);
            }
        }

        if (userDeleteList.size() == 0 ) {
            System.debug('No users to delete');
        } else {
            System.debug('-------------------------------------[ User Delete List ]------------------------------------\n' + JSON.serializePretty(userDeleteList));

            Boolean deletionSuccessfull = deteleUsers(baseEndpoint, userDeleteList);
            System.debug('DeletionSuccessfull = ' + deletionSuccessfull);
        }

    }

    public static String getInactiveUsers(String baseEndpoint) {

        string twoMonthsAgo = String.valueOf(Date.today().addMonths(-2)) + 'T00:00:00.000z';
        String body = '';

        // SET FILTERS
        String filters = '?where[date_last_login][$lt]=' + twoMonthsAgo;// + '&where[active]=true';

        // CREATE ENDPOINT
        String endpoint = baseEndpoint + '/:users';

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

        return body;
    }

    public class User {
        // public String client_id;
        // public Boolean notify;
        // public Boolean all_permissions;
        // public Boolean invited;
        // public String invite_key;
        // public Datetime date_created;
        // public Role role;
        public Datetime date_last_login;
        // public Datetime date_updated;
        public String role_id;
        public String id;
        public String name;
        public String email;
    }

    public class Role {public String name;}

    public static Boolean deteleUsers(String baseEndpoint, List<User> userList) {
        Boolean successfullDetelion = false;


        for (User u : userList) {

            // CREATE ENDPOINT
            String endpoint = baseEndpoint + '/:users/' + u.id;

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
            if (statusCode == 200) {
                System.debug('Successfull deletion of User');
                successfullDetelion = true;
            } else if (statusCode > 499 && statusCode < 600) {
                System.debug('There seems to be a problem on the Swell API server, Statuscode: ' + res.getStatusCode());
            } else {
                System.debug('Incorrect response from Swell API, Statuscode: ' + res.getStatusCode());
            }

        }

        return successfullDetelion;
    }

}