/*******************************************************
 * bg_AWSJSONGenerationUtil
 *
 *  Class holds Utility Methods for generating JSON for AWS callouts
 *  
 *  Test Class - bg_LocationUtilsTest
 * 
 * Author: Andy White
 * Created: 12-01-2016
 * Changes: 02-02-2016 ASD BG : Updated Account.Address_Country__c to Address_Country_v2__c pull in a different value from the location object as specified by a custom label
 *          05-02-2016 ASD BG : Removed Phone from number and left to create as string
 *          24-02-2016 ASD BG : Removed Double from the Integer Cast
 *          14-06-2016 JG BG : Added Capability to handle Account Group and Account Group Membership records
 *          28-07-2016 IB BG : SOW009 generic methods to format JSON for any object
******************************************************/
public class bg_AWSJSONGenerationUtil 
{  
    /*
        SOW009 generic method to get the data for a given object and set of fields passed in
    */
    public static map<Id, sObject> GetDataForCallout(String objectName, List<AWSCalloutFields__mdt> fieldsForQuery, Set<Id> ids)
    {
        // Build query from Custom Setting   
        String query = 'SELECT ID';
        for(AWSCalloutFields__mdt s : fieldsForQuery) 
        {
            if(s.SourceFieldName__c !='Id')
            {
                query += ', ' + s.SourceFieldName__c + ' ';
            }
        }
        /* 
            Account is a special case in that we also need to embed the Location in the JSON message, this was not refactored
            in SOW009 due to the impact on downstream systems and it is the only example.
        */


            //REMOVE ACCOUNTS SPECIFIC CALLS - Sean Parker 13/10/2020       
            /*
            if (objectName == 'Account')
            {
                query += ', Location__c';
            }
            */


        // Add FROM statement
        query += ' FROM ';
        query += objectName;
        //If filter provided add filter
        if(ids != null && !ids.isEmpty())
        {
            query += ' where Id IN :ids';
        }
        // Query all locations
        Map<Id, sObject> theSObjectMap = new Map<Id, sObject>((List<sObject>)database.query(query));
        return theSObjectMap;
    }
    /*
        SOW009 generic method for all AWS callouts - Note the validation of the Custom Setting Values must be undertaken prior to this method being called
    */

    public static String GenerateJSONStringForAWSCallout(String objectName, Set<Id> ids)
    {
        // Get the custom setting fields for this object
        Map<String, AWSCalloutFields__mdt> fieldsForCalloutMap = bg_CustomSettingUtils.GetObjectCustomSettingFieldsMap(objectName);
        // Create Map for Object Fields                       
        Map<String, Schema.SObjectField> objectFieldMap = bg_CustomSettingUtils.GetObjectFieldMap(objectName);
        //Get the objects that we are passing to AWS
        Map<Id, sObject> theSObjectMap = GetDataForCallout(objectName, fieldsForCalloutMap.values(), ids);
        // If we are processing Accounts then we also need to embed the Location
        // Build set of Location Ids
        Map<Id, sObject> accountLocationsMap;
        Set<Id> locationIds = new Set<Id>();
        Map<String, AWSCalloutFields__mdt> locationFieldsForCalloutMap;
        Map<String, Schema.SObjectField> locationObjectFieldMap;

        //REMOVE ACCOUNTS SPECIFIC CALLS - Sean Parker 13/10/2020 
        /*
                if ( objectName == 'Account' )
                {
                    locationObjectFieldMap = bg_CustomSettingUtils.GetObjectFieldMap('Location__c');
                    locationFieldsForCalloutMap = bg_CustomSettingUtils.GetObjectCustomSettingFieldsMap('Location__c');
                    System.debug('+++ locationFieldsForCalloutMap = ' + locationFieldsForCalloutMap);
                    for(sObject o : theSObjectMap.values())
                    {
                        if(o.get('Location__c') != null)
                        {
                            locationIds.add((ID)o.get('Location__c'));   
                        }
                    }
                    //Get Locations for JSON
                    accountLocationsMap = GetDataForCallout('Location__c', locationFieldsForCalloutMap.values(), locationIds);
                }
        */      
        
        // Set up a JSONGenerate Object
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName(Label.AWSCalloutArrayFieldName);     
        gen.writeStartArray();
        for(sObject objectToGenerateJSONString : theSObjectMap.values())
        {
            //Start object
            gen.writeStartObject();
            AddFields(gen, objectToGenerateJSONString, objectFieldMap, fieldsForCalloutMap);
            /* 
                Account is a special case in that we also need to embed the Location in the JSON message, adding the 
                fields is now in a private helper to allow embedded Locations to use it
            */

            //REMOVE ACCOUNTS SPECIFIC CALLS - Sean Parker 13/10/2020 
            /*
                    if ( objectName == 'Account' )
                    {
                        gen.writeFieldName(Label.AWSCalloutArrayLocationFieldName); 
                        gen.writeStartObject();
                        String location = String.valueOf(objectToGenerateJSONString.get('Location__c'));
                        AddFields(gen, accountLocationsMap.get(location), locationObjectFieldMap, locationFieldsForCalloutMap);
                        gen.writeEndObject(); 
                    }
            */


            gen.writeEndObject(); 
        }
        gen.writeEndArray();
        gen.writeEndObject();
        return gen.getAsString();
    }
    /*
        Helper method to add fields to JSON payload
    */
    private static void AddFields(JSONGenerator gen, sObject objectToGenerateJSONString, Map<String, Schema.SObjectField> objectFieldMap, Map<String, AWSCalloutFields__mdt> fieldsForCalloutMap)
    {
        // Loop through fields in custom setting       
        for(AWSCalloutFields__mdt calloutField  : fieldsForCalloutMap.values())
        {   
            String s = calloutField.SourceFieldName__c;
            // Get field type
            Schema.DisplayType fieldType = objectFieldMap.get(s).getDescribe().getType();
            //Check if field not null
            
            if(s == 'LastModifiedUnix__c'){
                
                Datetime unixtime =  Datetime.now();
                Decimal m = unixtime.getTime();
                gen.writeNumberField(fieldsForCalloutMap.get(s).DestinationFieldName__c , m);
            }
            else{
            
                    if(objectToGenerateJSONString.get(s) != null)
                    {                                                     
                        // Build Location part of the JSON                                              
                        if( fieldType==Schema.DisplayType.Integer || calloutField.DataType__c == 'Integer')
                        {
                            gen.writeNumberField(fieldsForCalloutMap.get(s).DestinationFieldName__c , Integer.valueOf(objectToGenerateJSONString.get(s)));
                        }
                        else if(fieldType==Schema.DisplayType.Double || fieldType==Schema.DisplayType.Currency)
                        {
                            gen.writeNumberField(fieldsForCalloutMap.get(s).DestinationFieldName__c , Double.valueOf(objectToGenerateJSONString.get(s)));
                        }
                        else if(fieldType==Schema.DisplayType.DateTime)
                        {
                            gen.writeDateTimeField(fieldsForCalloutMap.get(s).DestinationFieldName__c , DateTime.valueOf(objectToGenerateJSONString.get(s)));
                        }
                        else if(fieldType==Schema.DisplayType.Date)
                        {
                            gen.writeDateField(fieldsForCalloutMap.get(s).DestinationFieldName__c , Date.valueOf(objectToGenerateJSONString.get(s)));
                        }
                        else if(fieldType==Schema.DisplayType.Reference)
                        {                           
                            gen.writeIdField(fieldsForCalloutMap.get(s).DestinationFieldName__c , String.valueOf(objectToGenerateJSONString.get(s)));
                        }
                        else if(fieldType==Schema.DisplayType.Boolean)
                        {
                            gen.writeBooleanField(fieldsForCalloutMap.get(s).DestinationFieldName__c , Boolean.valueOf(objectToGenerateJSONString.get(s)));
                        }
                        else
                        {   
                            gen.writeStringField(fieldsForCalloutMap.get(s).DestinationFieldName__c , String.valueOf(objectToGenerateJSONString.get(s)));
                        }
                    }
                    else if(fieldsForCalloutMap.get(s).IncludeFieldIfNull__c)
                    {
                        if (fieldType==Schema.DisplayType.String || fieldType==Schema.DisplayType.TextArea)
                        {
                            gen.writeStringField(fieldsForCalloutMap.get(s).DestinationFieldName__c , '');
                        }
                        else
                        {
                            gen.writeNullField(fieldsForCalloutMap.get(s).DestinationFieldName__c);
                        }
                    } 
            }                 
        }
    }
}