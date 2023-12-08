global class ResyncFailedOrderApiCalloutMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        // Send response test data
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"success": true,"correlationId": "sample string"}');
        response.setStatusCode(200);
        return response;
    }
}