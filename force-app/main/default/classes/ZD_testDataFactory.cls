@IsTest
public class ZD_testDataFactory {

    public class correctMock implements HttpCalloutMock {
        
        public HttpResponse respond (HttpRequest req) {

            HttpResponse res = new HttpResponse();
            String body = '{"users": [';

            if (req.getMethod() == 'GET') {

                Datetime now = Datetime.now();
                String oneyearAgo = now.addYears(-1).format('yyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                String threeMonthsAgo = now.addMonths(-3).format('yyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                String oneMonthAgo = now.addMonths(-1).format('yyy-MM-dd\'T\'HH:mm:ss\'Z\'');

                for (Integer i = 1; i <= 12; i++) {
                    body += '{'; // Start of User

                    body += '"id": 3929502239' + i + ',';
                    body += '"url": "https://noordhoff1648817829.zendesk.com/api/v2/users/3929502239' + i + '.json",';
                    body += '"name": "Test User ' + i + '",';
                    body += '"email": "tu' + i + '@test.com",';
                    body += '"created_at": "2022-04-01T12:57:32Z",';

                    if (i <= 6) {
                        body += '"updated_at": "' + oneMonthAgo + '",';
                    } else {
                        body += '"updated_at": "' + threeMonthsAgo + '",';
                    }
                    
                    body += '"time_zone": "Amsterdam",';
                    body += '"iana_time_zone": "Europe/Amsterdam",';
                    body += '"phone": null,';
                    body += '"shared_phone_number": null,';
                    body += '"photo": null,';
                    body += '"locale_id": 1,';
                    body += '"locale": "en-US",';
                    body += '"organization_id": null,';

                    if (isEven(i)) {
                        body += '"role": "admin",';
                    } else {
                        body += '"role": "agent",';
                    }
                    
                    body += '"verified": true,';
                    body += '"external_id": null,';
                    body += '"tags": [';
                    body += '"alpha"';
                    body += '],';
                    body += '"alias": "",';
                    body += '"active": true,';
                    body += '"shared": false,';
                    body += '"shared_agent": false,';
                    body += '"last_login_at": "2023-01-27T14:46:13Z",';
                    body += '"two_factor_auth_enabled": null,';
                    body += '"signature": "",';
                    body += '"details": "",';
                    body += '"notes": "",';
                    body += '"role_type": 4,';
                    body += '"custom_role_id": 4731310317469,';
                    body += '"moderator": true,';
                    body += '"ticket_restriction": null,';
                    body += '"only_private_comments": false,';
                    body += '"restricted_agent": false,';
                    body += '"suspended": false,';
                    body += '"default_group_id": 4731298377757,';
                    body += '"report_csv": true,';
                    body += '"user_fields": {';
                    body += '"agent_ooo": false,';
                    body += '"mobilephone": null,';
                    body += '"phone": null,';
                    body += '"teachernumber": null,';
                    body += '"zdsync": false';
                    body += '}';

                    if (i < 12) {
                        body +='},'; // End of User
                    } else {
                        body +='}'; // End of Last User
                    }
                    
                }

                body += '],"next_page": null,"previous_page": null,"count": 20}';
            } else if (req.getMethod() == 'PUT') {
                body = '';
            }

            res.setBody(body);
            res.setStatusCode(200);

            return res;
        }
    }

    public static Boolean isEven(Integer checkNumber) {
        Boolean result = false;

        if (math.mod(checkNumber, 2) == 0) {
            result = true;
        }

        return result;
    }
}