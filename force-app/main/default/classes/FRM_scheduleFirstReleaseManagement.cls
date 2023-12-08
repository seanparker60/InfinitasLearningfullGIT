/*/
*   @ Created By: Jannes Kleerebezem
*   @ Created on: 27-12-2021
*
*   Use: 
*   Used to schedule the first release management batch job.
*
*   EXAMPLE:
*   FRM_scheduleFirstReleaseManagement frmScheduled = new FRM_scheduleFirstReleaseManagement('Plantyn');
*   String sch = '0 0 01 * * ? *'; // seconds minutes hours day_of_month month day_of_week optional_year
*   String jobId = system.schedule('First release management - Plantyn - daily', sch, frmScheduled);
/*/

global class FRM_scheduleFirstReleaseManagement implements Schedulable {
    
    global String opCo;

    global FRM_scheduleFirstReleaseManagement(String operatingCompany) {
        this.opCo = operatingCompany;
    }

    global void execute(SchedulableContext sc) {
        FRM_firstReleaseManagement_Batch frm = new FRM_firstReleaseManagement_Batch(this.opCo);
        Database.executeBatch(frm);
    }
}