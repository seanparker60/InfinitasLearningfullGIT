/*******************************************************
 * bg_CustomSettingValidity
 *
 * DML operation is not passed to the Queable class bg_RESTCalloutUtility. This class defines variable to pass the DML as well as the exitsing IDs of records
 *  
 *  Test Class - 
 * 
 * Author: Sean Parker
 * Created: 20-10-2020
 * Changes: 
******************************************************/

public with sharing class bg_CustomApiParameter {
    
    public Set<ID> ids;
    Public String DMLOperation;

}