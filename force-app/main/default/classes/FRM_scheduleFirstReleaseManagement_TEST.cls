@isTest
public class FRM_scheduleFirstReleaseManagement_TEST {

    //public static String CRON_EXP = '0 0 0 15 3 ? 2022';

    @IsTest
    public static void testSchedule(){
        String CRON_EXP = '0 0 0 15 3 ? 2022';
        
        String monthValue;
        String yearValue;
        if (system.now().month() == 12) {
            monthValue = '01';
            yearValue = string.valueof(system.now().year()+1);
        } else {
            monthValue = string.valueof(system.now().month()+1);
            yearValue = string.valueof(system.now().year());
        }

        CRON_EXP = '0 0 0 ' + '01' +' ' + monthValue + ' ? ' + yearValue;

        Test.startTest();

            String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new FRM_scheduleFirstReleaseManagement('Plantyn'));

            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();
        
    }
}