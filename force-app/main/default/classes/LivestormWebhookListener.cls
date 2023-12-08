@RestResource(urlMapping='/Webhook/*')
global class LivestormWebhookListener {
	@HttpPost
    global static void handlePost() {
        try{
            String webhookBody = RestContext.request.requestBody.toString();
            System.debug('LivestormWebhookListener webhookBody 1: ' + webhookBody);
            //when Livestorm sends emailconsent as a blank String "" which happens when the consent field is false, then default to false to allow deserialize to not cause exception
            webhookBody = webhookBody.replace('"emailconsent":""', '"emailconsent":false');
            System.debug('LivestormWebhookListener webhookBody 2: ' + webhookBody);
            livestormStructure ls = (livestormStructure)System.JSON.deserialize(webhookBody, livestormStructure.class);
            
            LivestormImport__c livestormRecord = new LivestormImport__c();
            //Attendee data
            livestormRecord.AttendeeIdentify__c = ls.attendee.identify;
            livestormRecord.AttendeeCreatedAt__c = ls.attendee.created_at;
            livestormRecord.AttendeeFirstName__c = ls.attendee.first_name;
            livestormRecord.AttendeeLastName__c = ls.attendee.last_name;
            livestormRecord.AttendeeEmail__c = ls.attendee.email;
            livestormRecord.AttendeeConnectionLink__c = ls.attendee.connection_link;
            System.debug('LivestormWebhookListener ls.attendee.fields: ' + ls?.attendee?.fields);
            if(ls.attendee.fields != null){
                livestormRecord.EmailConsent__c = ls?.attendee?.fields?.emailconsent != null ?  ls.attendee.fields.emailconsent : false;
            }

            //Webinar data
            livestormRecord.WebinarIdentify__c = ls.webinar.identify;
            livestormRecord.WebinarSlug__c = ls.webinar.slug;
            livestormRecord.WebinarCreatedAt__c = ls.webinar.created_at;
            livestormRecord.WebinarRoomLink__c = ls.webinar.room_link;
            livestormRecord.WebinarEstimatedStartedAt__c = ls.webinar.estimated_started_at;
            livestormRecord.LivestormJSON__c = webhookBody;
            
            insert livestormRecord;
            
        } catch (Exception ex){
            System.debug('LivestormWebhookListener Exception: ' + ex);
        }
    }
    
    public class livestormStructure{
        public cls_attendee attendee;
        public cls_webinar webinar;
    }
    class cls_attendee {
        public String identify;
        public String created_at;
        public String first_name;
        public String last_name;
        public String email;
        public String avatar_link;
        public String referrer;
        public String utm_source;
        public String utm_medium;
        public String utm_term;
        public String utm_content;
        public String utm_campaign;
        public String browser_version;
        public String browser_name;
        public String os_name;
        public String os_version;
        public String screen_height;
        public String screen_width;
        public String ip_city;
        public String ip_country_code;
        public String ip_country_name;
        public String password_key;
        public String connection_link;
        public cls_fields fields;
    }

    class cls_fields {
        public Boolean emailconsent;
    }

    class cls_webinar {
        public String identify;
        public String title;
        public String slug;
        public String created_at;
        public Integer estimated_duration;
        public String registration_link;
        public String published_at;
        public Integer nb_registered;
        public String room_link;
        public String estimated_started_at;
    }
    
}