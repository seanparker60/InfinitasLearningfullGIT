@isTest
public class RTS_ReportToSlack_TEST {
    
    @IsTest(SeeAllData='true')
    static void Test01(){
        
        Test.startTest();
            // FILL Report API Name in String Value below
            String reportApiName = 'Failed_AWS_syncs_Accounts';
            String objectName = 'Account';

            Report rep = [SELECT  Id FROM Report WHERE DeveloperName = 'Failed_AWS_syncs_Accounts' LIMIT 1];
            String reportId = rep.Id;
                
            RTS_ReportToSlack reportSchedule = new RTS_ReportToSlack(reportId, reportApiName, objectName);
            // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
            String sch = '00 00 08 ? * 2-6';
            String scheduledJobName = 'TEST Report to Slack: ' + reportApiName;
            String jobID = System.schedule(scheduledJobName, sch, reportSchedule);
        Test.stopTest();
        
    }
    
}