@IsTest
public class SWELL_TestDataFactory {
    public class correctMock implements HttpCalloutMock {
        
        public HttpResponse respond (HttpRequest req) {

            System.debug('Correct Mock request received, Method: ' + req.getMethod());

            String oneyearAgo = String.ValueOf(Datetime.now().addYears(-1).format('yyy-MM-dd\'T\'HH:mm:ss\'Z\''));
            String threeMonthsAgo = String.ValueOf(Datetime.now().addMonths(-3).format('yyy-MM-dd\'T\'HH:mm:ss\'Z\''));
            String oneMonthAgo = String.ValueOf(Datetime.now().addMonths(-1).format('yyy-MM-dd\'T\'HH:mm:ss\'Z\''));

            HttpResponse res = new HttpResponse();

            String body = '{"count": 13,"results": [';

            if (req.getMethod() == 'GET') {
                for (Integer i = 1; i <= 12; i++) {
                    body += '{';
                    body += '"client_id": "infinitas-noordhoff-nl-prod",';
                    body += '"notify": true,';
                    body += '"invite_key": null,';
                    body += '"date_created": "2021-11-25T15:43:59.629Z",';
    
                    if (isEven(i)) {
                        body += '"role": "admin",';
                    } else {
                        body += '"role": {"id": "620baedfc8305b013d3a0e40","type": "developer","name": "Developer","permissions": {"products": "view","orders": "view"}},';
                        body += '"role_id": "620baedfc8305b013d3a0e40",';
                    }
    
                    body += '"date_updated": "2022-12-06T10:49:56.743Z",';
                    if (i < 6) {
                        body += '"date_last_login": "' + oneMonthAgo  + '",';
                    } else {
                        body += '"date_last_login": "' + threeMonthsAgo  + '",';
                    }
                    
                    body += '"id": "619faf3fe557835d296bfbc' + i + '",';
                    body += '"name": "Test Subject ' + i + '",';
                    body += '"email": "ts' + i + '@test.com"';
                    
                    if (i < 12) {
                        body +='},';
                    } else {
                        body +='}';
                    }
                }
    
                body += '],"page": 1}';
            } else if (req.getMethod() == 'DELETE') {
                body = '';
            }

            
            

            res.setBody(body);
            res.setStatusCode(200);

            return res;
        }
    }

    public class incorrectMock01 implements HttpCalloutMock {
        
        public HttpResponse respond (HttpRequest req) {

            System.debug('Correct Mock request received, Method: ' + req.getMethod());

            HttpResponse res = new HttpResponse();

            String body = '';
            res.setBody(body);
            res.setStatusCode(500);

            return res;
        }
    }

    public class incorrectMock02 implements HttpCalloutMock {
        
        public HttpResponse respond (HttpRequest req) {

            System.debug('Correct Mock request received, Method: ' + req.getMethod());

            HttpResponse res = new HttpResponse();

            String body = '';
            res.setBody(body);
            res.setStatusCode(410);

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