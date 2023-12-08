/*******************************************************
 * bg_CustomSettingUtils
 *
 *  Class hold Utility methods for Custom Settings
 *
 *  Class processess Custom Settings to determine if any of their fields are incorrect
 *  
 *  Test Class - bg_CustomSettingUtilsTest
 * 
 * Author: Joseph Gallagher
 * Created: 07-01-2015
 * Author: Joseph Gallagher
 * Created: 13-06-2015
 * Changes: Added additional methods for new objects - Account Group and Account Group Membership
 *          IB - SOW009 make methods generic
******************************************************/
public without sharing class bg_CustomSettingUtils 
{   
    /*
        SOW009 generic method to check custom setting for a particular object
    */
    public static bg_CustomSettingValidity ValidateCalloutCustomSettingsForObject(String objectName)
    {
        // Create Wrapper Instance
        bg_CustomSettingValidity csValidity = new bg_CustomSettingValidity();
        String errorMessage = '';
        // Assumption mapping is successful
        csValidity.isValid = true;
        // Instantiate List of Invalid Field Names
        csValidity.invalidFields = New List<String>();
        // Get fields for this object from the custom setting
        Map<String, AWSCalloutFields__mdt> settingsFieldsMap = GetObjectCustomSettingFieldsMap(objectName);
        // Get Map for the fields on the object                         
        Map<String, Schema.SObjectField> objectFieldsMap = GetObjectFieldMap(objectName);
        if (objectFieldsMap == null)
        {
            // if the object name is not valid then raise an error
            csValidity.isValid = false;             
            errorMessage = Label.AWSInvalidObject + objectName;
        }
        else if (settingsFieldsMap.keyset().size() == 0)
        {
            csValidity.isValid = false;             
            errorMessage = Label.AWSIntegrationNotDefined + objectName;
        }
        else
        {
            for(AWSCalloutFields__mdt calloutField : settingsFieldsMap.values())
            {                   
                //Boolean fieldFound = false;               
                if(!objectFieldsMap.containsKey(calloutField.SourceFieldName__c.toLowerCase()))
                {
                    // if the field does not exist on the object then add an error
                    //csValidity.invalidFields.add(calloutField.SourceFieldName__c);
                    system.debug('**ERROR ON FIELD: **'+calloutField.SourceFieldName__c);
                    errorMessage += Label.AWSFieldNotValidInCustomSetting + calloutField.SourceFieldName__c + '; ';         
                    csValidity.isValid = false;
                }
                else
                {
                    // found the field, if there is a data type override is an invalid cast then raise an error
                    if ( calloutField.DataType__c != null)
                    {
                        if (calloutField.DataType__c == 'Integer')
                        {
                            if (objectFieldsMap.get(calloutField.SourceFieldName__c).getDescribe().getType() != Schema.DisplayType.String)
                            {
                                // the source data type is not supported for the target type
                                errorMessage +=     Label.AWSFieldTypeConversionInvalid + calloutField.SourceFieldName__c + '; ';
                                csValidity.isValid = false;
                            }
                        }
                        else
                        {
                            // the target data type is not supported
                            errorMessage +=     Label.AWSFieldTypeConversionInvalid + calloutField.SourceFieldName__c + '; ';
                            csValidity.isValid = false;
                        }
                    }
                }                   
            }
        }   
        if(errorMessage.length() > 0)
        {
            csValidity.errorMessage = errorMessage;
        }
        return csValidity;
    }   
    /*
        Method to validate that the General Integration Setting has values for username and password
    */
    public static boolean validateGeneralIntegrationSettings()
    {
        Boolean result = true;

// NEED TO REPLACE THIS
        GeneralIntegrationSettings__mdt[] setting = [Select AWSCalloutUsername__c,AWSCalloutPassword__c From GeneralIntegrationSettings__mdt limit 1]; // = GeneralIntegrationSettings__mdt.getOrgDefaults();
        
        if ( setting == null)
        {
            result = false;
        } 
        else if(setting[0].AWSCalloutUsername__c == null || setting[0].AWSCalloutPassword__c == null)
        {
            result = false;
        }
        return result;
    }
    public static Map<String, AWSCalloutFields__mdt> GetObjectCustomSettingFieldsMap(String objectName)
    {
        Map<String, AWSCalloutFields__mdt> allObjectsMap = new Map<String, AWSCalloutFields__mdt>();
        Map<String, AWSCalloutFields__mdt> customSettingFieldsMap  = new Map<String, AWSCalloutFields__mdt>();
       
        // NEED TO REPLACE THIS
       // allObjectsMap = AWSCalloutFields__mdt.getAll(); 
       
       AWSCalloutFields__mdt[] AWSCalloutFields = [Select SourceFieldName__c,IncludeFieldIfNull__c,DataType__c,SourceObject__c,DestinationFieldName__c from  AWSCalloutFields__mdt];

       for(AWSCalloutFields__mdt field:AWSCalloutFields){
                        //system.debug('*****'+field.SourceFieldName__c);
                    // system.debug('*****'+field.DataType__c);
                    // system.debug('*****'+field.DestinationFieldName__c);
                        //system.debug('*****'+field.SourceObject__c);
            allObjectsMap.put(field.SourceObject__c+field.SourceFieldName__c,field);
        }
       
       
        
        // now loop over this, extract the entries for this object and create a map keyed by Source Field Name
        for (AWSCalloutFields__mdt cf : allObjectsMap.values() )
        {
            if ( cf.SourceObject__c == objectName)
            {
                
                customSettingFieldsMap.put(cf.SourceFieldName__c, cf);
            }
        }
        return customSettingFieldsMap;
    }   
    public static Map<String, Schema.SObjectField> GetObjectFieldMap(String objectName)
    {
        Map<String, Schema.SObjectField> objectFieldMap;
        Schema.getGlobalDescribe().get(objectName);
        if(objectFieldMap==null)
        {
            Schema.sObjectType objectType = Schema.getGlobalDescribe().get(objectName);
            if (objectType != null)
            {
                objectFieldMap = objectType.getDescribe().fields.getMap();
            }
        }
        return objectFieldMap;
    }
    /*
        Validates AWS Integration Results Wrapper And Updates Error Message Accordingly
        Accepts Custom Label Associated with the AWS Settings being evaluated and the AWS Wrapper Class to be evaluated
    */
/*  private static void ValidateAWSIntegrationResultsWrapper(bg_CustomSettingValidity AWSValidityWrapper, String errorPrefix)
    {
        if(!AWSValidityWrapper.isValid)
        {           
            AWSValidityWrapper.errorMessage = errorPrefix + ' ' + String.join(AWSValidityWrapper.invalidFields, ', ');                  
        }
    }
*/  
}