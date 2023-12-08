@isTest
public with sharing class LivestormWebhookListener_Test {

    public static testmethod void LivestormWebhookListenerHandlePostTest() {
        String mockRequestString  = '{"attendee":{"identify":"c3c084f2-82ba-4a03-8a3d-0deb2cd174dd","created_at":"2022-09-07T11:49:21.201Z","first_name":"Test","last_name":"Noordhoff Livestorm","email":"a01f3236-1cc2-40ce-a668-737937f8ae5e@email.webhook.site","avatar_link":null,"referrer":null,"utm_source":null,"utm_medium":null,"utm_term":null,"utm_content":null,"utm_campaign":null,"browser_version":"104.0","browser_name":"Firefox","os_name":"Windows","os_version":"10.0","screen_height":"864","screen_width":"1536","ip_city":null,"ip_country_code":null,"ip_country_name":null,"password_key":"c49193f9c16f97e8a6cce6","connection_link":"https://app.livestorm.co/p/da27e724-3e00-42f7-94f5-ae0e042d8cab/live?email=a01f3236-1cc2-40ce-a668-737937f8ae5e%40email.webhook.site\u0026key=c49193f9c16f97e8a6cce6","fields":{}},"webinar":{"identify":"da27e724-3e00-42f7-94f5-ae0e042d8cab","title":"Test event Daniël","slug":"test-event-daniel","created_at":"2022-09-05T13:07:36.639Z","estimated_duration":1800,"registration_link":"https://app.livestorm.co/p/da27e724-3e00-42f7-94f5-ae0e042d8cab","published_at":"2022-09-05T13:13:36.077Z","nb_registered":7,"room_link":"https://app.livestorm.co/p/da27e724-3e00-42f7-94f5-ae0e042d8cab/live?s=399f9400-f150-4f15-a195-fc6beeddcb8c","estimated_started_at":"2022-09-15T16:00:00.000Z"}}';
        
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = '/Webhook/*';
        RestContext.request.requestBody = Blob.valueOf(mockRequestString);
        Test.startTest();
        LivestormWebhookListener.handlePost();
        Test.stopTest();

        List<LivestormImport__c> liList = [SELECT Id FROM LivestormImport__c];
        System.debug('LivestormWebhookListener_Test liList: '  + liList);
        System.assertEquals(1, liList.size());
    }

}