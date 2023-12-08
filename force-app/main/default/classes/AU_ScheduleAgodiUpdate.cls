/*/
*   @ Created By: Jannes Kleerebezem
*   @ Created on: 03-01-2022
*
*   Use: 
*   Used to schedule the Agodi update.
*
*   EXAMPLE:
*   AU_ScheduleAgodiUpdate agodiSchedule = new AU_ScheduleAgodiUpdate();
*   String sch = '0 0 01 01 * ? *'; // seconds minutes hours day_of_month month day_of_week optional_year
*   String jobId = system.schedule('Agodi Update - monthly', sch, agodiSchedule);
/*/


global class AU_ScheduleAgodiUpdate implements Schedulable {

    global void execute(SchedulableContext sc) {
        System.debug('AU_ScheduleAgodiUpdate - EXECUTE');

        AU_StartAgodiUpdate.start();
        
        System.debug('AU_ScheduleAgodiUpdate - END');
    }
    
}