/*
* Connor Huglin 2022/11/23: https://dev.azure.com/infinitas/Converse/_boards/board/t/Order%20to%20Cash/Backlog%20items/?workitem=185828
* Functionality to remove records older than 3 months
*/
global class UTIL_CleanObjectRecordsScheduleable Implements Schedulable {
    public sObjectType sObjType;
    public Date filterStartDate;
    public Date filterEndDate;
    public Date startDate;
    public Date endDate;
    public Integer numberOfWeeks;
    
    global void execute(SchedulableContext sc)
    {
        callJob();
    }

    public void callJob(){
        List<Objects_to_Clean__mdt> objectsToCleanMDT = Objects_to_Clean__mdt.getAll().values();
        
        for(Objects_to_Clean__mdt obj : objectsToCleanMDT){
            SummaryofObjectsCleaned__c summaryRecord = new SummaryofObjectsCleaned__c();
            summaryRecord.ObjectAPIName__c = obj.ObjectAPIName__c;
            summaryRecord.CountofRecordsDeleted__c = 0;
            summaryRecord.MonthsDataGoesBack__c = obj.MonthsDataShouldGoBack__c;
            insert summaryRecord;
            
            // set date logic
            setDateData(obj);
            
            // create weekly summary records with totals and call batch 
            Set<Id> summaryIdSet = createWeeklyData(obj, summaryRecord.Id);
            
			// for summary record (child), fetch children per the start/enddate and necessary filters (opco, object )
            // update the necessary fields (ie: IntegrationRecords__c for SystemMonitors etc)
            // create excel csv per child and attach to parent
            
            if(summaryIdSet.size() > 0){
                // get summary records with their necessary data
                List<SummaryofObjectsCleaned__c> summaryRecords = [SELECT Id, StartDate__c, EndDate__c, ObjectAPIName__c, SummaryCount__c, Parent__c, CountofRecordsDeleted__c, WeekinYear__c, Year__c FROM SummaryofObjectsCleaned__c WHERE Id IN: summaryIdSet];
                
                for(SummaryofObjectsCleaned__c summRecChild : summaryRecords){
                    system.debug('summRecChild.StartDate__c: ' + summRecChild.StartDate__c);
                    system.debug('filterStartDate: ' + filterStartDate);
                    
                    // not sure why but it was creating a summary record for the week after the filterStartDate
                    if(summRecChild.StartDate__c > filterStartDate){
                        delete summRecChild;
                    } else {
                        UTIL_CleanObjectRecords bc = new UTIL_CleanObjectRecords(obj, summaryRecord.Id, sObjType, summRecChild, summaryRecord, filterStartDate);
                        Id batchId = Database.executeBatch(bc);
                    }
                }
                
                // update the count on the parent
                List<SummaryofObjectsCleaned__c > sumLs = [SELECT Id, SummaryCount__c from SummaryofObjectsCleaned__c where Parent__c = :summaryRecord.Id];
                
                for(SummaryofObjectsCleaned__c summary : sumLs){
                    summaryRecord.CountofRecordsDeleted__c += summary.SummaryCount__c;
                }

                update summaryRecord;
            } 
        }
    }
    
    public void setDateData(Objects_to_Clean__mdt mdtObject){
        // override start date
        if(mdtObject.OverrideStartDate__c != null){
            startDate = mdtObject.OverrideStartDate__c;
        } else {
            startDate = Date.today();
        }
        
        // keep records from the filterStartDate until today. summarize/delete the records created < filterStartDate
        endDate = Date.valueOf(startDate).addMonths(-(Integer)mdtObject.MonthsDataShouldGoBack__c); // date that data is valid until
        filterStartDate = endDate;
        system.debug('filterStartDate: ' + filterStartDate);
        
        sObjType = ((sObject) Type.forName(mdtObject.ObjectAPIName__c).newInstance()).getSObjectType();      
    }
    
    public Set<Id> createWeeklyData(Objects_to_Clean__mdt mdtObject, Id parentId){
        String query = 'SELECT Count(ID)total, week_in_year(CreatedDate)weekNum, calendar_year(CreatedDate)calYear FROM ' + mdtObject.ObjectAPIName__c + ' WHERE DAY_ONLY(CreatedDate) <= :filterStartDate GROUP BY week_in_year(CreatedDate), calendar_year(CreatedDate)';
        //system.debug('createWeeklyData query: ' + query);
        List<AggregateResult> aggResLs = Database.query(query);
        
        List<SummaryofObjectsCleaned__c> weeklySummary = new List<SummaryofObjectsCleaned__c>();
        for(AggregateResult aggRes : aggResLs){
            
            Integer totalRecords = Integer.valueOf(aggRes.get('total'));
            Integer weekNum = Integer.valueOf(aggRes.get('weekNum'));
            Integer calYear = Integer.valueOf(aggRes.get('calYear'));
            
            SummaryofObjectsCleaned__c summaryChild = new SummaryofObjectsCleaned__c();
            summaryChild.ObjectAPIName__c = mdtObject.ObjectAPIName__c;
            summaryChild.SummaryCount__c = totalRecords;
            summaryChild.WeekInYear__c = weekNum;
            summaryChild.Year__c = calYear;
            summaryChild.Parent__c = parentId;
            summaryChild.MonthsDataGoesBack__c = mdtObject.MonthsDataShouldGoBack__c;
            
            system.debug('summaryChild: ' + summaryChild);
            weeklySummary.add(summaryChild);
        }
        
        insert weeklySummary;
        
        return new Map<Id,SObject>(weeklySummary).keySet();
    }
}