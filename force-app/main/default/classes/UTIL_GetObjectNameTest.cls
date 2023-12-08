@isTest
public class UTIL_GetObjectNameTest {
 
 @isTest
 public static void testReturnObjectName(){
 //Create and insert lead record
 Lead testLead = new Lead();
 testLead.Status = 'Open';
 testLead.Salutation = 'Mr.';
 testLead.FirstName = 'Tim';
 testLead.LastName = 'Testin';
 testLead.Company = 'Test Company';
 testLead.OperatingCompany__c = 'Plantyn';
 insert testLead;
 
 //Return newly created lead record 
 Lead[] LeadList = new List<Lead>();
 LeadList = [Select Id from Lead where FirstName = 'Tim' AND LastName = 'Testin' AND Company = 'Test Company' LIMIT 1];
 
 String[] IdList = new List<string> ();
 
 For (Lead l: LeadList){
 IdList.add(l.Id);
 }
 test.startTest();
 String[] results = UTIL_getObjectName.returnObjectName(IdList);
 test.stopTest();
 System.assertEquals('Lead', results[0], 'ERROR IN GetObjectNameTest.testReturnObjectName : sObject Name did not match');
 }

}