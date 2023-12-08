public class AU_StartAgodiUpdate {
    
    @AuraEnabled
    public static void start() {
        System.enqueueJob(new AU_agodiHelper(true, false));
    }

}