/*******************************************************
 * bg_CustomSettingValidity
 *
 *  Wrapper class contains assessment if custom setting fields are valid, a set of fields that are invalid if any and the error message to be displayed/saved
 *  
 *  Test Class - bg_CustomSettingUtilsTest
 * 
 * Author: Joseph Gallagher
 * Created: 08-01-2015
 * Changes: 
******************************************************/
public with sharing class bg_CustomSettingValidity 
{
  //Wrapper class contains if setting fields are valid, a set of fields that are invalid if any and the error message to be displayed/saved
  public Boolean isValid {get;set;}
  public List<String> invalidFields {get;set;}
  public String errorMessage {get;set;}
}