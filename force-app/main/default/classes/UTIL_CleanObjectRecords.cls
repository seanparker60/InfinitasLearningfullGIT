/*
* Connor Huglin 2022/11/23: https://dev.azure.com/infinitas/Converse/_boards/board/t/Order%20to%20Cash/Backlog%20items/?workitem=185828
* Functionality to remove records older than 3 months and store summary of records per month
*/
global class UTIL_CleanObjectRecords implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    private Objects_to_Clean__mdt mdtObject;
    private Id summaryParentId;
    private sObjectType sObjType;
    private Date startDate;
    private Date endDate;
    private List<sObject> recordsToInsert;
    private Set<Id> recordIdSet;
    private SummaryofObjectsCleaned__c summRecord;
    private SummaryofObjectsCleaned__c summParentBatch;
    private List<sObject> summarizedRecords;
    private Boolean deleteCurrentANDAddNew;
    private Date initialFilterDate;
    
    public UTIL_CleanObjectRecords(Objects_to_Clean__mdt mdtObjRec, Id summRecId, sObjectType sObjType, SummaryofObjectsCleaned__c summaryRecord, SummaryofObjectsCleaned__c summaryParentBatch, Date filterStartDate) {
        mdtObject = mdtObjRec;
        summaryParentId = summRecId;
        sObjType = sObjType;
        summRecord = summaryRecord;
        summParentBatch = summaryParentBatch;
        recordsToInsert = new List<sObject>();
        recordIdSet = new Set<Id>();
        deleteCurrentANDAddNew = false;
        initialFilterDate = filterStartDate;
    }
    
    global Iterable<sObject> start(Database.BatchableContext bc) {
        // get actual records for the summary record        
        startDate = summRecord.StartDate__c;
        endDate = summRecord.EndDate__c;
        
        system.debug('startDate == : ' + startDate);
        system.debug('endDate == : ' + endDate);
        
        String dynamicQuery;
        if(startDate < initialFilterDate && endDate > initialFilterDate){
            dynamicQuery = 'SELECT Id FROM ' + mdtObject.ObjectAPIName__c + ' WHERE DAY_ONLY(CreatedDate) >= :startDate AND DAY_ONLY(CreatedDate) <= :initialFilterDate';
        } else {
            dynamicQuery = 'SELECT Id FROM ' + mdtObject.ObjectAPIName__c + ' WHERE DAY_ONLY(CreatedDate) >= :startDate AND DAY_ONLY(CreatedDate) <= :endDate';
        }

        return database.getQueryLocator(dynamicQuery);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> records){
        Set<Id> tempIdSet = (new Map<Id,SObject>(records)).keySet(); // only executes in batches of 200, so add each 200 to a bigger list
        recordIdSet.addAll(tempIdSet); // add all record ids to set
    } 
    
    public void updateSummaryData(){
        List<SummaryofObjectsCleaned__c> recordsToInsert = new List<SummaryofObjectsCleaned__c>();
        
        if(recordIdSet.size() > 0){
            // for system monitor records, check how many integration records there were and split per object type
            if(summRecord.ObjectAPIName__c == 'SystemMonitor__c'){
                // single query
                String aggResQuery = 'SELECT COUNT(Id)Total, Object__c Obj, OperatingCompany__c OpCo, Type__c recType FROM ' + summRecord.ObjectAPIName__c + ' WHERE (DAY_ONLY(CreatedDate) >= :startDate AND DAY_ONLY(CreatedDate) <= :endDate) AND Id IN :recordIdSet GROUP BY Object__c, OperatingCompany__c, Type__c';
                List<AggregateResult> aggResult = Database.query(aggResQuery);
                
                if(aggResult.size() > 0){
                    // we now want to split the weeklySummary (header) into separate records for the weekly summary. so instead of 1 records, we might have 3 (for object/opco/type)
                    // it will create a new record for integration type records as well as queueable type records
                    // so Integeration Order will be one record, and Queueable Order will be its own record
                    for(integer i = 0; i < aggResult.size(); i++){
                        SummaryofObjectsCleaned__c summaryChild = new SummaryofObjectsCleaned__c();
                        summaryChild.ObjectAPIName__c = summRecord.ObjectAPIName__c;
                        summaryChild.SummaryCount__c = (Decimal)aggResult[i].get('Total');
                        summaryChild.Parent__c = summaryParentId;
                        summaryChild.MonthsDataGoesBack__c = mdtObject.MonthsDataShouldGoBack__c;
                        summaryChild.WeekinYear__c = summRecord.WeekinYear__c;
                        summaryChild.Year__c = summRecord.Year__c;
                        summaryChild.IntegrationRecords__c = String.valueOf(aggResult[i].get('recType')) == 'Integration' ? (Integer)aggResult[i].get('Total') : 0;
                        summaryChild.IntegrationObjectType__c = String.valueOf(aggResult[i].get('Obj'));
                        summaryChild.OperatingCompany__c = String.valueOf(aggResult[i].get('OpCo'));
                        
                        recordsToInsert.add(summaryChild);  
                    }
                    
                    deleteCurrentANDAddNew = true;
                    
                    insert recordsToInsert;
                    delete summRecord;
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        // process each batch of records
        try {            
			updateSummaryData();
            
            if(recordIdSet.size() > 0){
                // create excel csvs with data
                // delete records if marked in metadata
                UTIL_CleanObjectRecords_Excel excelCreate = new UTIL_CleanObjectRecords_Excel(summaryParentId, mdtObject, startDate, endDate);
                Id batchId = Database.executeBatch(excelCreate);
            }
            
            /*DateTime nextStart = DateTime.Now().addMinutes(1);
            CronTrigger[] cronJob = [SELECT Id, StartTime from CronTrigger WHERE CronJobDetail.Name LIKE '%UTIL_CleanObjectRecordsScheduleable%' AND StartTime != null];
            
            for(CronTrigger cron : cronJob){
                System.abortJob(cron.Id);
            }*/
            
        } catch (Exception exc){
            System.debug('Something went wrong when trying to delete the records: ' + exc);
        }
    }    
}