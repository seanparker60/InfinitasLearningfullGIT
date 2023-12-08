/* 
USE for scheduling via Execute Anonymous:
==> only have to fill the Report API Name and Object API Name in the "reportApiName" and ObjectApiName String Values
the rest of the code is automatic, Report will be scheduled every weekday at 8:00 (AM)
If the report needs to be scheduled at another time or day(s) please change the CHRON code ("sch" String value)

------------------------------------------- EXECUTE ANONYMOUS CODE ------------------------------------------------
// FILL Report API Name and Object API Name in String Value below
String reportApiName = 'Failed_AWS_syncs_Accounts';
String ObjectApiName = 'Account';


Report rep = [SELECT  Id FROM Report WHERE DeveloperName = :reportApiName LIMIT 1];
String reportId = rep.Id;
    
RTS_ReportToSlack reportSchedule = new RTS_ReportToSlack(reportId, reportApiName, ObjectApiName);
// Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
String sch = '00 00 08 ? * 2-6';
String scheduledJobName = 'Report to Slack: ' + reportApiName;
String jobID = System.schedule(scheduledJobName, sch, reportSchedule);
------------------------------------------------ END OF CODE ------------------------------------------------------
*/


global class RTS_ReportToSlack implements System.Schedulable,Database.AllowsCallouts {
    
    global String ReportId;
    global String Title;
    global String ObjectName;
    global RTS_ReportToSlack(String reportId, String title, String objectName) {
        this.ReportId = reportId;
        this.Title = title;
        this.ObjectName = objectName;
    }
    global void execute(SchedulableContext sc) {
        sendNow(this.ReportId, this.Title, this.ObjectName);
    }

    @future(callout=true)
    global static void sendNow(String reportId, String title, String objectName) {
        System.debug(LoggingLevel.INFO, 'RTS_ReportToSlack - sendNow(reportId: ' + reportId + ', title: ' + title + ', objectName: ' + objectName + ')');

        String query = 'SELECT COUNT(Id), ErrorMessageForAWSUpdate__c FROM ' + objectName + ' GROUP BY ErrorMessageForAWSUpdate__c';
        System.debug(LoggingLevel.INFO, 'query ==> ' + query);

        List<AggregateResult> results = new List<AggregateResult>();
        try {
            System.debug(LoggingLevel.DEBUG,'==> check 01');
            results = Database.query(query);
            System.debug(LoggingLevel.DEBUG,'==> check 02');
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'An error happened on the querying the Database: ' + e.getMessage());
            HandleCustomException.LogException(e);
        }
        System.debug(LoggingLevel.INFO, 'size of results ==> ' + results.size());

        String body = 'Please find below the results of report - ' + title + '\n\n';

        if (results.size() > 0) {
            for (AggregateResult ar : results) {
                String subject = (String) ar.get('ErrorMessageForAWSUpdate__c');
                if (subject == null) {
                    subject = ' -- no error message received --';
                }
                body += subject + ' ==> ' + ar.get('expr0') + '\n';
            }
        } else {
            body += 'We did not find any error messages on this Object.\n';
        }
        
        body += '\nLink to Report: https://infinitaslearning--devcentral.lightning.force.com/' + reportId;

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setSubject('Failed AWS Syncs on - ' + objectName);
        message.setPlainTextBody(body);
        message.setToAddresses(new String[] { 'jkleerebezem@infinitaslearning.com','bsc-support@infinitaslearning.com' } );

        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message } );
        } catch (Exception e) {
            HandleCustomException.LogException(e);
        }
    }

    // private static List<String> splitFileInHalf(String content) {
    //     Integer halfCount = content.indexOf('\n',(content.length()/2));

    //     String firstString = content.Substring(content.indexOf('\n')+1,halfCount);
    //     String secondString = content.Substring(halfCount+1);

    //     List<String> returnList = new List<String>();
    //     returnList.add(firstString);
    //     returnList.add(secondString);

    //     return returnList;
    // }
}