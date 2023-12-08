public class SWELL_deleteInactiveUsers_Invocable {
    
    @InvocableMethod(label='Delete Inactive Swell Users' description='Deletes Swell users that have not logged in for over 2 months --> Admins are excluded.')
    public static void start() {
        System.debug('Starting - SWELL_deactivateInactiveUsers');
        System.enqueueJob(new SWELL_deactivateInactiveUsers());
    }

}