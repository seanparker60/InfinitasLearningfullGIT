public class ZD_suspendInactiveUsers_Invocable {
    
    @InvocableMethod(label='Suspend Inactive Zendesk Users' description='Suspends users that have not logged in for over 1 month --> Only Agents, Admins are excluded.')
    public static void start() {
        System.debug('Starting - ZD_suspendInactiveUsers');
        System.enqueueJob(new ZD_suspendInactiveUsers());
    }

}