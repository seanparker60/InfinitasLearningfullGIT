global class UTIL_ApexJobSummary_BATCH implements Database.Batchable<sObject> {
    private Date dateSelected;
    
    public UTIL_ApexJobSummary_BATCH(Date startDate){
        dateSelected = startDate;
    }
    
    global Iterable<sObject> start(Database.BatchableContext bc) {
        system.debug('=== inside batch, dateSelected: ' + dateSelected);
        String dynamicQuery = 'SELECT Id, ApexClass.Name, MethodName, CompletedDate, TotalJobItems, JobItemsProcessed, NumberOfErrors, ExtendedStatus, JobType, Status, CreatedDate, CreatedBy.Name FROM AsyncApexJob WHERE DAY_ONLY(CreatedDate) = :dateSelected';
        
        return database.getQueryLocator(dynamicQuery);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> records){
        if(records.size() > 0){
            List<ApexJob__c> apexJobsToProcess = new List<ApexJob__c>();
            List<ApexJobRun__c> apexJobRunsToProcess = new List<ApexJobRun__c>();
            
            // loop through each apex job for dateSelected
            // check if a summary header already exists for the apex class
            // if summary header exists, add apex job to the summary
            // else create header, then create a "run" to link to the header
            for(sObject apexJob : records){
                system.debug('apexJob: ' + apexJob);
                DateTime apexJobRunDT = DateTime.valueOf(apexJob.get('CreatedDate'));
                system.debug('apexJobRunDT: ' + apexJobRunDT);
                String apexJobRunHour = String.valueOf(apexJobRunDT.hour()); // this returns as one hour ahead of apexJobRunDT, so subtract 1
                
                // do some magic on the datetime
                if(apexJobRunHour.length() == 1){
                    // it's am, add a 0 in front
                    apexJobRunHour = '0' + apexJobRunHour;
                }
                
                system.debug('apexJobRunHour: ' + apexJobRunHour);
                
                String apexClassName;
                if(apexJob.getSObject('ApexClass') == null){
                    apexClassName = '';
                } else{
                    apexClassName = String.valueOf(apexJob.getSObject('ApexClass').get('Name'));
                }
                
                String apexJobType = String.valueOf(apexJob.get('JobType'));
                
                // check if a summary header already exists for combo of ApexClass, JobType and Job Date. If not, create it
                List<ApexJobSummary__c> apexJobSummaryLs = [SELECT Id from ApexJobSummary__c WHERE ApexClass__c =: apexClassName AND JobType__c =: apexJobType AND JobDate__c = :dateSelected];
                
                ApexJob__c apexJobRecord = new ApexJob__c();
                apexJobRecord.ApexJobId__c = apexJob.Id;
                apexJobRecord.ApexClass__c = apexClassName;
                apexJobRecord.ApexMethod__c = String.valueOf(apexJob.get('MethodName'));
                apexJobRecord.SubmittedDate__c = DateTime.valueOf(apexJob.get('CreatedDate'));
                apexJobRecord.JobType__c = String.valueOf(apexJob.get('JobType'));
                apexJobRecord.Status__c = String.valueOf(apexJob.get('Status'));
                apexJobRecord.StatusDetail__c = String.valueOf(apexJob.get('ExtendedStatus'));
                apexJobRecord.TotalBatches__c = Integer.valueOf(apexJob.get('TotalJobItems'));
                apexJobRecord.BatchesProcessed__c = Integer.valueOf(apexJob.get('JobItemsProcessed'));
                apexJobRecord.Failures__c = Integer.valueOf(apexJob.get('NumberOfErrors'));
                apexJobRecord.SubmittedBy__c = String.valueOf(apexJob.getSObject('CreatedBy').get('Name'));
                apexJobRecord.CompletionDate__c = DateTime.valueOf(apexJob.get('CompletedDate'));
                system.debug('=== apexJobRecord: ' + apexJobRecord);
                
                if(apexJobSummaryLs.size() > 0){
                    // there should only be 1 record per combo for the Summary Header
                    // so now look to see if there is already a summary run for the hour of apexJob
                    // then create the ApexJobRun__c related records for apexJobSummaryLs[0].Id
                    
                    String apexJobRunHourFilter;
                    if(apexJobRunHour == '00'){
                        apexJobRunHour = '00:00';
                    }
                    
                    apexJobRunHourFilter = '%' + apexJobRunHour + '%'; 
                    
                    
                    system.debug('=== apexJobRunHourFilter: ' + apexJobRunHourFilter);
                    List<ApexJobRun__c> apexJobRunLs = [SELECT Id, RunTime__c, TotalBatches__c, TotalFailures__c, TotalSuccesses__c from ApexJobRun__c WHERE ApexJobSummary__c =: apexJobSummaryLs[0].Id AND RunTime__c LIKE :apexJobRunHourFilter];
                    system.debug('apexJobRunLs: ' + apexJobRunLs);
                    
                    // set parent id for ApexJob__c (parent is the summary/header record)
                    apexJobRecord.ApexJobSummary__c = apexJobSummaryLs[0].Id;
                    
                    if(apexJobRunLs.size() > 0){
                        // there should only be 1 apexJonRunLs (because it is grouped/filtered per hour - so you cannot have two records for same hour), so add to it
                        // add to ApexJobRun__c
                        
                        // add the numbers from the apexJob to the existing hourly summary record's numbers
                        ApexJobRun__c apexJobRun = apexJobRunLs[0];
                        apexJobRun.Id = apexJobRunLs[0].Id;
                        apexJobRun.TotalBatches__c += Integer.valueOf(apexJob.get('TotalJobItems'));
                        apexJobRun.TotalFailures__c += Integer.valueOf(apexJob.get('NumberOfErrors'));
                        apexJobRun.TotalSuccesses__c += Integer.valueOf(apexJob.get('JobItemsProcessed'));
                        
                        update apexJobRun;
						apexJobRecord.ApexJobRun__c = apexJobRun.Id;

                        system.debug('[UPDATE] ApexJobRun__c: ' + apexJobRun);
                    } else {
                        // create ApexJobRun__c 
                        
                        ApexJobRun__c apexJobRun = new ApexJobRun__c();
                        apexJobRun.TotalBatches__c = Integer.valueOf(apexJob.get('TotalJobItems'));
                        apexJobRun.TotalFailures__c = Integer.valueOf(apexJob.get('NumberOfErrors'));
                        apexJobRun.TotalSuccesses__c = Integer.valueOf(apexJob.get('JobItemsProcessed'));
                        apexJobRun.ApexJobSummary__c = apexJobSummaryLs[0].Id;
                        
                        Schema.DescribeFieldResult fieldDetail = ApexJobRun__c.RunTime__c.getDescribe(); 
                        List<Schema.PicklistEntry> ple = fieldDetail.getPicklistValues();
                        for(Schema.PicklistEntry pickListVal : ple){
                            if(String.valueOf(pickListVal.getValue()).contains(apexJobRunHour)){
                                system.debug('=+= get hour from pickval: ' + String.valueOf(pickListVal.getValue()));
                                apexJobRun.RunTime__c = String.valueOf(pickListVal.getValue());
                            }
                        }  
                        
                        insert apexJobRun;
						apexJobRecord.ApexJobRun__c = apexJobRun.Id;

                        system.debug('[INSERT] ApexJobRun__c: ' + apexJobRun);
                    }
                    
                } else {
                    // create summary header
                    ApexJobSummary__c apexJobSummary = new ApexJobSummary__c();
                    apexJobSummary.ApexClass__c = apexClassName;
                    apexJobSummary.JobType__c = String.valueOf(apexJob.get('JobType'));
                    apexJobSummary.JobDate__c = dateSelected;
                    
                    // shouldn't be too many of these, so can do DML here to insert header/summary
                    insert apexJobSummary;
                    system.debug('[INSERT] apexJobSummary: ' + apexJobSummary);
                    
                    // now create a jobrun for the job that triggered the header creation
                    ApexJobRun__c apexJobRun = new ApexJobRun__c();
                    apexJobRun.TotalBatches__c = Integer.valueOf(apexJob.get('TotalJobItems'));
                    apexJobRun.TotalFailures__c = Integer.valueOf(apexJob.get('NumberOfErrors'));
                    apexJobRun.TotalSuccesses__c = Integer.valueOf(apexJob.get('JobItemsProcessed'));
                    apexJobRun.ApexJobSummary__c = apexJobSummary.Id;
                    
                    if(apexJobRunHour == '00'){
                        apexJobRunHour = '00:00';
                    }
                    
                    Schema.DescribeFieldResult fieldDetail = ApexJobRun__c.RunTime__c.getDescribe(); 
                    List<Schema.PicklistEntry> ple = fieldDetail.getPicklistValues();
                    for(Schema.PicklistEntry pickListVal : ple){
                        if(String.valueOf(pickListVal.getValue()).contains(apexJobRunHour)){
                            system.debug('=+= get hour from pickval: ' + String.valueOf(pickListVal.getValue()));
                            apexJobRun.RunTime__c = String.valueOf(pickListVal.getValue());
                        }
                    }  
                    
                    insert apexJobRun;

                    system.debug('[INSERT AFTER HEADER INS] ApexJobRun__c: ' + apexJobRun);
                    
                    // set parent id for ApexJob__c (parent is the summary/header record)
                    apexJobRecord.ApexJobSummary__c = apexJobSummary.Id;
                    apexJobRecord.ApexJobRun__c = apexJobRun.Id;
                }
                apexJobsToProcess.add(apexJobRecord);
            }
            
            system.debug('apexJobsToProcess.size(): ' + apexJobsToProcess.size());
            
            
            if(apexJobsToProcess.size() > 0)
                insert apexJobsToProcess;
        }
    } 
    
    
    global void finish(Database.BatchableContext bc){
        // go through all integration system monitor's per hour and link to ApexJobRun__c for bg_RESTCalloutUtil 
        List<ApexJobRun__c> apexJobRunsPerHour = new List<ApexJobRun__c>();
        List<ApexJob__c> apexJobsToUpdate = new List<ApexJob__c>();
        
        if(!test.isRunningTest()){
            apexJobRunsPerHour = [SELECT Id, RunTime__c FROM ApexJobRun__c WHERE ApexJobSummary__r.ApexClass__c = 'bg_RESTCalloutUtil' AND ApexJobSummary__r.JobDate__c = :dateSelected];
        } else {
            apexJobRunsPerHour = [SELECT Id, RunTime__c FROM ApexJobRun__c];
        }
        
        List<SystemMonitor__c> systemMonitorsToAssign = [SELECT Id, CreatedDate, ApexJob__c FROM SystemMonitor__c WHERE DAY_ONLY(CreatedDate) = :dateSelected ORDER BY CreatedDate ASC];
        
        system.debug('systemMonitorsToAssign.size(): ' + systemMonitorsToAssign.size());
        
        for(ApexJobRun__c apexJobHourlySummary : apexJobRunsPerHour){
            // fetch apex jobs, and compare createddate for each to the system monitor's created date. if no match, do best guess scenario
            // the number of system monitors doesn't always = number of apex jobs
            List<ApexJob__c> apexJobs = [SELECT Id, SubmittedDate__c, LinkedToSystemMonitor__c FROM ApexJob__c WHERE ApexJobRun__c =: apexJobHourlySummary.Id ORDER BY SubmittedDate__c ASC];
            system.debug('apexJobs.size(): ' + apexJobs.size());
            
            // loop through each SystemMonitor__c and compare createddate time to apexJobHourlySummary's hour
            
            for(SystemMonitor__c sysMon : systemMonitorsToAssign){
                Boolean hasAssignedApexJob = false;
                String sysMonCreatedHour = String.valueOf(sysMon.CreatedDate.hour());
                Integer sysMonCreatedMinute = Integer.valueOf(sysMon.CreatedDate.minute());
                
                // do some magic on the datetime
                if(sysMonCreatedHour.length() == 1){
                    // it's am, add a 0 in front
                    sysMonCreatedHour = '0' + sysMonCreatedHour;
                }
                
                sysMonCreatedHour = sysMonCreatedHour + ':00';
                system.debug('sysMon Id: ' + sysMon.Id + ' created in hour: ' + sysMonCreatedHour);
                
                if(apexJobHourlySummary.RunTime__c.contains(sysMonCreatedHour)){
                    // the system monitor was created within the hour of apexJobHourlySummary, so lets link them
                    sysMon.ApexJobRun__c = apexJobHourlySummary.Id;
                    
                    // try link the system monitor to an apex job record
                    // apex job submitted date time will always be before the system monitor's created date (apex job creates the system monitor)
                    DateTime sysMonCreatedDatePlus1Min = sysMon.CreatedDate.addMinutes(1);  
                    DateTime sysMonCreatedDatePlus2Min = sysMon.CreatedDate.addMinutes(2);
                    DateTime sysMonCreatedDatePlus3Min = sysMon.CreatedDate.addMinutes(3);
                    DateTime sysMonCreatedDatePlus5Min = sysMon.CreatedDate.addMinutes(5);
                    
                    system.debug('=== sysMon.createdate: ' + sysMon.CreatedDate);
                    
                    if(sysMon.ApexJob__c == null){
                        for(ApexJob__c apexJob : apexJobs){
                            if(hasAssignedApexJob == false){
                                system.debug('=== apexJob.SubmittedDate__c: ' + apexJob.SubmittedDate__c);
                                
                                // if apexJobs.size() == systemMonitorsToAssign.size(), assign one apex job to one system monitor
                                if(apexJobs.size() == systemMonitorsToAssign.size()){
                                    if(apexJob.LinkedToSystemMonitor__c == false){
                                        if(apexJob.SubmittedDate__c == sysMon.CreatedDate){
                                            // exact match, link them
                                            sysMon.ApexJob__c = apexJob.Id;
                                            apexJob.LinkedToSystemMonitor__c = true;
                                            
                                            //apexJobsToUpdate.add(apexJob);
                                            hasAssignedApexJob = true;
                                        } else if (apexJob.SubmittedDate__c <= sysMonCreatedDatePlus1Min){
                                            // check if they are within 1 minute of each other
                                            sysMon.ApexJob__c = apexJob.Id;
                                            apexJob.LinkedToSystemMonitor__c = true;
                                            
                                            //apexJobsToUpdate.add(apexJob);
                                            hasAssignedApexJob = true;
                                        } else if (apexJob.SubmittedDate__c <= sysMonCreatedDatePlus2Min){
                                            // check if they are within 2 minutes of each other
                                            sysMon.ApexJob__c = apexJob.Id;
                                            apexJob.LinkedToSystemMonitor__c = true;
                                            
                                            //apexJobsToUpdate.add(apexJob);
                                            hasAssignedApexJob = true;
                                        } else if (apexJob.SubmittedDate__c <= sysMonCreatedDatePlus3Min){
                                            // check if they are within 3 minutes of each other
                                            sysMon.ApexJob__c = apexJob.Id;
                                            apexJob.LinkedToSystemMonitor__c = true;
                                            
                                            //apexJobsToUpdate.add(apexJob);
                                            hasAssignedApexJob = true;
                                        } else if (apexJob.SubmittedDate__c <= sysMonCreatedDatePlus5Min){
                                            // check if they are within 5 minutes of each other
                                            sysMon.ApexJob__c = apexJob.Id;
                                            apexJob.LinkedToSystemMonitor__c = true;
                                            
                                            //apexJobsToUpdate.add(apexJob);
                                            hasAssignedApexJob = true;
                                        }
                                    }
                                } else {
                                    // one apex job can be linked to multiple system monitors
                                    // but we need to ensure that all system monitors aren't linked to the same job
                                    
                                    Integer apexJobSubmittedMinute = Integer.valueOf(apexJob.SubmittedDate__c.minute());
                                    system.debug('=== sys mon created min: ' + sysMonCreatedMinute + ' -- apex job submitted min: ' + apexJobSubmittedMinute);
                                    
                                    if(apexJobSubmittedMinute == sysMonCreatedMinute){
                                        // exact match, link them
                                        sysMon.ApexJob__c = apexJob.Id;
                                        apexJob.LinkedToSystemMonitor__c = true;
                                        
                                        //apexJobsToUpdate.add(apexJob);
                                        //hasAssignedApexJob = true;
                                    } 
                                    
                                    /*if(apexJob.SubmittedDate__c == sysMon.CreatedDate){
                                        // exact match, link them
                                        sysMon.ApexJob__c = apexJob.Id;
                                        apexJob.LinkedToSystemMonitor__c = true;
                                        
                                        //apexJobsToUpdate.add(apexJob);
                                        hasAssignedApexJob = true;
                                    } else if (apexJob.SubmittedDate__c <= sysMonCreatedDatePlus1Min){
                                        // check if they are within 1 minute of each other
                                        sysMon.ApexJob__c = apexJob.Id;
                                        apexJob.LinkedToSystemMonitor__c = true;
                                        
                                        //apexJobsToUpdate.add(apexJob);
                                        hasAssignedApexJob = true;
                                    } else if (apexJob.SubmittedDate__c <= sysMonCreatedDatePlus2Min){
                                        // check if they are within 2 minutes of each other
                                        sysMon.ApexJob__c = apexJob.Id;
                                        apexJob.LinkedToSystemMonitor__c = true;
                                        
                                        //apexJobsToUpdate.add(apexJob);
                                        hasAssignedApexJob = true;
                                    } else if (apexJob.SubmittedDate__c <= sysMonCreatedDatePlus3Min){
                                        // check if they are within 3 minutes of each other
                                        sysMon.ApexJob__c = apexJob.Id;
                                        apexJob.LinkedToSystemMonitor__c = true;
                                        
                                        //apexJobsToUpdate.add(apexJob);
                                        hasAssignedApexJob = true;
                                    } else if (apexJob.SubmittedDate__c <= sysMonCreatedDatePlus5Min){
                                        // check if they are within 5 minutes of each other
                                        sysMon.ApexJob__c = apexJob.Id;
                                        apexJob.LinkedToSystemMonitor__c = true;
                                        
                                        //apexJobsToUpdate.add(apexJob);
                                        hasAssignedApexJob = true;
                                    }*/
                                }
                                
                                system.debug('=== sysMon.ApexJob__c: ' + sysMon.ApexJob__c);   
                            }
                        }
                    }
                }
            }
        }
        
        update systemMonitorsToAssign;
        //update apexJobsToUpdate;
    }
}