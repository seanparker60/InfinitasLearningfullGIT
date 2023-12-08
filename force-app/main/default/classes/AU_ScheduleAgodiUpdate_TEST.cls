@isTest
public class AU_ScheduleAgodiUpdate_TEST {

    @TestSetup
    static void makeData(){
        Account[] accounts = AU_TestDataFactory.createAccounts(true);
    }

    @IsTest
    public static void TestSchedule() {

        String CRON_EXP = '0 0 0 15 3 ? 2023';

        String monthValue;
        String yearValue;
        if (system.now().month() == 12) {
            monthValue = '01';
            yearValue = string.valueof(system.now().year()+1);
        } else {
            monthValue = string.valueof(system.now().month()+1).length() > 1 ? string.valueof(system.now().month()+1) : '0' + string.valueof(system.now().month()+1);
            yearValue = string.valueof(system.now().year());
        }

        CRON_EXP = '0 0 0 ' + '01' +' ' + monthValue + ' ? ' + yearValue;

        Test.startTest();

            AU_ScheduleAgodiUpdate agodiSchedule = new AU_ScheduleAgodiUpdate();
            String jobId = system.schedule('Agodi Test Schedule', CRON_EXP, agodiSchedule);

        Test.stopTest();

        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals(yearValue + '-'+ monthValue + '-01 00:00:00', String.valueOf(ct.NextFireTime));

    }
}