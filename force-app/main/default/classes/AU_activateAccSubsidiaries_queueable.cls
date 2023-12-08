public class AU_activateAccSubsidiaries_queueable implements Queueable {
    
    public void execute(QueueableContext context) {
        System.debug('AU_activateAccSubsidiaries_queueable - execute - START');

        List<AccountSubsidiary__c> accSubs = [SELECT Id, AgodiUpdateIsRunning__c FROM AccountSubsidiary__c WHERE AgodiUpdateIsRunning__c = true LIMIT 500];

        for (AccountSubsidiary__c accSub : accSubs) {
            accSub.AgodiUpdateIsRunning__c = false;
        }

        update accSubs;

        if (accSubs.size() == 500) {
            Id jobId = System.enqueueJob(new AU_activateAccSubsidiaries_queueable());
            System.debug('AU_activateAccSubsidiaries_queueable is enqueued with Job Id: ' + jobID);
        } else {
            System.debug('===> Agodi Update is completed!');
        }

        System.debug('AU_activateAccSubsidiaries_queueable - execute - END');
    }

}