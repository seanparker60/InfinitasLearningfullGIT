/**
* https://dev.azure.com/infinitas/Converse/_boards/board/t/Order%20to%20Cash/Backlog%20items/?workitem=187546
* Process to summarize and provide insights into the apex jobs run in a day
**/
global class UTIL_ApexJobSummary {
    
    @InvocableMethod(label='Create Apex Job Summaries')
    public static void createSummaries(List<Request> req){
        // pass start and end date from flow, and create a new ApexJobSummary__c per date (with all of its related items being for that date)
        // if nothing passed, it uses TODAY as the date
        
        if(req.size() > 0 ){            
            while(req[0].startDate <= req[0].endDate){
                // create ApexJobSummary__c (header) for specified date, with related apex jobs (all of them), as well as ApexJobRun__c for summaries
                system.debug('== filterDT: ' + req[0].startDate);
                
                UTIL_ApexJobSummary_BATCH bc = new UTIL_ApexJobSummary_BATCH(req[0].startDate);
                Id batchId = Database.executeBatch(bc, 5);
                
                req[0].startDate = req[0].startDate.addDays(1);
            }
        } else {
            // create ApexJobSummary__c (header), with related apex jobs (all of them), as well as ApexJobRun__c for summaries
            Date nowDT = System.now().date();
            system.debug('== nowDT, filterDT: ' + nowDT);
            
            UTIL_ApexJobSummary_BATCH bc = new UTIL_ApexJobSummary_BATCH(nowDT);
            Id batchId = Database.executeBatch(bc, 5);
        }
    }
    
    public class Request {
        @InvocableVariable
        public Date startDate;
        @InvocableVariable
        public Date endDate;
    }
}