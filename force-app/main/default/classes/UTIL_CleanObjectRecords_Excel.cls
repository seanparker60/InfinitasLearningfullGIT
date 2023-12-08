global class UTIL_CleanObjectRecords_Excel implements Database.Batchable<sObject>, Database.Stateful  {
    public List<sObject> recordLs; 
    public sObjectType sObjType;
    public Id summaryRecordId;
    public Objects_to_Clean__mdt mdtObject;
    public Date startDate;
    public Date endDate;
    
    public UTIL_CleanObjectRecords_Excel(Id sumRecId, Objects_to_Clean__mdt mdtObj, Date sDate, Date eDate){
        this.sObjType = sObjType;
        this.summaryRecordId = sumRecId;
        this.mdtObject = mdtObj;
        this.startDate = sDate;
        this.endDate = eDate;
    }
    
    global Iterable<sObject> start(Database.BatchableContext bc) {
        // get actual records for the summary record        
        List<String> accessibleFieldApiNames = new List<String>();
        
        sObjType = ((sObject) Type.forName(mdtObject.ObjectAPIName__c).newInstance()).getSObjectType();      
        
        for(Schema.SObjectField field : sObjType.getDescribe().fields.getMap().values()){
            Schema.DescribeFieldResult dfr = field.getDescribe();
            if(dfr.isAccessible()){
                accessibleFieldApiNames.add(dfr.getName());
            }
        }
        
        system.debug('UTIL_CleanObjectRecords_Excel startDate == : ' + startDate);
        system.debug('UTIL_CleanObjectRecords_Excel endDate == : ' + endDate);

        String dynamicQuery;
        if(mdtObject.ObjectAPIName__c == 'SystemMonitor__c'){
            dynamicQuery = 'SELECT {0} FROM {1} WHERE DAY_ONLY(CreatedDate) >= :startDate AND DAY_ONLY(CreatedDate) <= :endDate ORDER BY OperatingCompany__c, Object__c';
        } else {
            dynamicQuery = 'SELECT {0} FROM {1} WHERE DAY_ONLY(CreatedDate) >= :startDate AND DAY_ONLY(CreatedDate) <= :endDate';
        }
        
        return Database.getQueryLocator(String.format(dynamicQuery, new List<String>{String.join(accessibleFieldApiNames, ', '), mdtObject.ObjectAPIName__c}));
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> records) {
        // create excel sheet as attachment and add it to the summary record
        String fileHeader = '';
        String opCoName = '';
        String objectName = mdtObject.ObjectAPIName__c; // gets updated to the actual object later for the system monitors
        
        // create excel header dynamically
        for(Schema.SObjectField field : sObjType.getDescribe().fields.getMap().values()){
            Schema.DescribeFieldResult dfr = field.getDescribe();
            if(dfr.isAccessible()){
                fileHeader += dfr.getName() + ',';
            }
        }
        
        // set file header row
        fileHeader.removeEnd(',');
        fileHeader += ' \n';
        String finalStr = fileHeader;
        
        for(sObject obj : records){
            String recordStr = ''; // new row per record
            List<Schema.SObjectField> recordFields = sObjType.getDescribe().fields.getMap().values();
            
            // build each row in the excel sheet
            for(Schema.SObjectField field : recordFields){
                Schema.DescribeFieldResult dfr = field.getDescribe();
                if(dfr.isAccessible()){
                    Object fieldValueObj = obj.get(dfr.getName());
                    
                    // set opco for file name
                    if(dfr.getName() == 'OperatingCompany__c'){
                        if(fieldValueObj != null){
                            opCoName = String.valueOf(JSON.serialize(fieldValueObj));
                        }
                    }
                    
                    // set object (only really used for integration system monitors (not applicable to error logs))
                    if(dfr.getName() == 'Object__c'){
                        if(fieldValueObj != null){
                            objectName = String.valueOf(JSON.serialize(fieldValueObj));
                        }
                    }
                                        
                    String fieldValueObjSerialized = String.valueOf(JSON.serialize(fieldValueObj));
                    fieldValueObjSerialized = fieldValueObjSerialized.replaceAll('(\\r|\\n)+', ' ');
                    fieldValueObjSerialized = '"' + fieldValueObjSerialized.replaceAll('"', '\'')  + '"';
                    
                    
                    recordStr += fieldValueObjSerialized + ',';
                }
            }
            
            recordStr.removeEnd(',');
            recordStr += ' \n';
            finalStr += recordStr;
        }
        
        //system.debug('finalStr: ' + finalStr);
        
        // set attachment attributes
        Blob csvBlob = Blob.valueOf(finalStr);
        Attachment att = new Attachment();
        att.ContentType = 'application/xml';
        att.ParentId = summaryRecordId;
        att.Body = csvBlob;
        att.Name = opCoName + '_' + objectName + '_Start-' + startDate + '_End-' + endDate + '_.csv';
        insert att;
        system.debug('att: ' + att);
        
        // delete the records from the object if the metadata setting is checked
        if(mdtObject.DeleteOldRecords__c){
            Database.DeleteResult[] deleteResults = Database.delete(records, true);
        }
    }
    
    global void finish(Database.BatchableContext bc){

    }
    
}