public class UpdateAgodiData {

    public static void updateData() {

        Map<String,String> downloadLocations = getFileWithMostRecentDownloadLocations();
        String inrichtendeMachtenRawFile = getFile(downloadLocations.get('Inrichtende_machten'));
        String scholenGemeenschappenRwaFile = getFile(downloadLocations.get('Scholengemeenschappen'));
        String scholenRawFile = getFile(downloadLocations.get('Scholen'));

        System.debug('Scholen Raw File = ' + scholenRawFile.length() + ' characters long.');
        System.debug('Scholengemeenschappen Raw File = ' + scholenGemeenschappenRwaFile.length() + ' characters long.');
        System.debug('Inrichtende Machten Raw File = ' + inrichtendeMachtenRawFile.length() + ' characters long.');

        AgodiUpdate__c au = new AgodiUpdate__c();
        insert au;

        insertFile(inrichtendeMachtenRawFile, 'inrichtendeMachten.txt', au.Id);
        insertFile(scholenGemeenschappenRwaFile, 'scholenGemeenschappen.txt', au.Id);
        insertFile(scholenRawFile, 'scholen.txt', au.Id);

        // agodiProcessFiles apf = new agodiProcessFiles(inrichtendeMachtenRawFile, scholenGemeenschappenRwaFile, scholenRawFile);
        // ID jobId = System.enqueueJob(apf);

    }

    public static Map<String,String> getFileWithMostRecentDownloadLocations() {

        map<String, String> downloadLocationMap = new Map<String, String>();
        List<String> files = new List<String>();

        // Instantiate a new http object
        Http h = new Http();
        
        // Instantiate a new HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://agodi.login.kanooh.be/sites/default/files/atoms/files/links_meest_recent_0.txt');
        req.setTimeout(60000); //sets maximum timeout
        req.setMethod('GET');

        // Send the request, and return a response
        HttpResponse res = h.send(req);
        Blob body = res.getBodyAsBlob();
        
        // Create Map from downloaded file
        files = body.toString().split('\r\n');

        for(String row : files) {
            if(row.length() > 1) {
                List<String> seperatedLine = new List<String>();
                seperatedLine = row.replace('"','').split(';');
                downloadLocationMap.put(seperatedLine[0],seperatedLine[2]);
            }
        }

        System.debug('Scholen Download Location = ' + downloadLocationMap.get('Scholen'));
        System.debug('Scholengemeenschappen Download Location = ' + downloadLocationMap.get('Scholengemeenschappen'));
        System.debug('Inrichtende_machten Download Location = ' + downloadLocationMap.get('Inrichtende_machten'));

        return downloadLocationMap;

    }

    public static String getFile(String location) {

        System.debug('Location = ' + location);

        // Instantiate a new http object
        Http h = new Http();

        // Instantiate a new HTTP request
        HttpRequest req = new HttpRequest();

        // req.setEndpoint(location+'&Format=txt');
        req.setEndpoint(location);
        req.setTimeout(60000); //sets maximum timeout
        req.setMethod('GET');

        System.debug('EndPoint = ' + req.getEndpoint());

        // Send the request, and return a response
        HttpResponse res = h.send(req);

        // Check if redirect is needed just as long untill we get the correct response
        Integer redirect = 1;
        if(res.getStatusCode() == 301 || res.getStatusCode() == 302) {
            while(res.getStatusCode() == 301 || res.getStatusCode() == 302) {
                System.debug('REDIRECT ' + redirect);
                System.debug('StatusCode  ==> ' + res.getStatusCode());
                System.debug('new Header ==> ' + res.getHeader('Location'));
                req.setEndpoint(res.getHeader('Location'));
                res = new Http().send(req);
                redirect ++;
            }
        }

        System.debug('##### WE HAVE GOT THE FILE! #####');
        String rawFile = res.getBody();

        return rawFile;
    }
  
    private static void insertFile(String content, String name, Id parentRecordId){
    
        // create File (ContentVersion)
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';
        conVer.PathOnClient = name;
        conVer.Title = name;
        conVer.VersionData = EncodingUtil.base64Decode(content);
        insert conVer;

        // Link file to object
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = parentRecordId;
        conDocLink.ContentDocumentId = conDoc;
        conDocLink.shareType = 'V';
        insert conDocLink;

    }

}