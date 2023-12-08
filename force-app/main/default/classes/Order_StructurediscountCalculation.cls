public with sharing class Order_StructurediscountCalculation {
    
      public class Request{ 
        @invocablevariable Public String ExistingContract ;   
        @invocablevariable Public String ContractRenewal;  
        @invocablevariable Public String PricingMethod;  
        @invocablevariable Public String ContractRequired;    
        @invocablevariable Public String GroupBasedType;
        @invocablevariable Public String ContractId;
        @invocablevariable Public String OrderId;
       // @invocablevariable Public List<Account> ListOfAccounts;
       @invocablevariable Public List<Id> ListOfAccountIds; 
        @invocablevariable Public List<Id> ListOfIds;  
    }
    public class Response{ 
        @invocablevariable Public Decimal totalnumbers ; 
        @invocablevariable Public String ExistingContract ;   
        @invocablevariable Public String ContractRenewal;  
        @invocablevariable Public String PricingMethod;  
        @invocablevariable Public String ContractRequired;    
    }
    
   

    @invocablemethod
    public static List<Response> start(List<Request> req){

        List<Response> responses;
        
        try {
            system.debug('**Start Method:**');
            responses = Calculation(req); 

            if(Test.isRunningTest() && UTIL_TestClassExceptions.TESTCLASSEXCEPTION==True){
                CalloutException e = new CalloutException();
                e.setMessage('Error');
                throw e;        
            }
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            HandleCustomException.LogException(e);
               
        }
        finally {
            // Something executed whether there was an error or not
        }
        
        return responses;

    }    

    
    public static List<Response> Calculation(List<Request> req){
        List<Id> ListOfIds;
        system.debug('**req**'+req);

   
      
     Decimal totalnumbers;

     //Check if Contract has Orders - ie a new contract
     if(req[0].ContractId != null && req[0].ContractId != ''){
        List<Id> lstCon = new List<Id>();
        lstCon.add(req[0].ContractId);

        totalnumbers =  getStudentNumberContract(lstCon);

        if(totalnumbers == 0){
            req[0].ExistingContract = 'no'; // Set to No - use total number of students
        }
     }

     if(req[0].OrderId != null && req[0].ExistingContract == 'yes'){
        Order[] Order = [Select id,ContractId from Order where Id=:req[0].OrderId]; 
        List<Id> lstCon = new List<Id>();
        lstCon.add(Order[0].ContractId);

        totalnumbers =  getStudentNumberContract(lstCon);

        if(totalnumbers == 0){
            req[0].ExistingContract = 'no'; // Set to No - use total number of students
        }
     }

     //Determing list of Ids for Query - Account or Contract

     if(req[0].ContractId != null && req[0].PricingMethod !='AccountStudents' && (req[0].ContractRenewal == 'yes' || (req[0].ContractRenewal == 'no' && totalnumbers > 0 )) ){
        system.debug('**Add Contract Id**');
        req[0].ListOfIds = new List<Id>(); 
        req[0].ListOfIds.add(req[0].ContractId);
     }
     else if(req[0].ListOfAccountIds.size()>0 ){ //&&   req[0].PricingMethod =='AccountStudents'
                
                req[0].ListOfIds = new List<Id>();
                for(Id acc:req[0].ListOfAccountIds){
                    req[0].ListOfIds.add(acc);
                }
                       
    }
        
        system.debug('**req[0].ExistingContract**'+req[0].ExistingContract);

        totalnumbers =  PricingHandler( req[0].ExistingContract, req[0].ContractRenewal, req[0].PricingMethod,  req[0].ContractRequired, req[0].GroupBasedType, req[0].ListOfIds );
       // PricingHandler('Yes','Yes','OrderProductQuantity', 'None','None',List<Id> ListOfIds){

        if(totalnumbers == null){
            totalnumbers = 0;  
        }
        
        system.debug('**totalnumbers**'+totalnumbers);
        List<Response> responses = new List<Response>();
        Response res = new Response();
        res.totalnumbers = totalnumbers;
        res.ExistingContract = req[0].ExistingContract;
        res.ContractRenewal = req[0].ContractRenewal; 
        res.PricingMethod = req[0].PricingMethod;   
        responses.add(res);
        return responses;
	
    }
    



    public static Decimal PricingHandler(String ExistingContract,String ContractRenewal, String PricingMethod, String ContractRequired,String GroupBasedType,List<Id> ListOfIds ){
        

        system.debug('**ContractRenewal**'+ContractRenewal);

        Decimal totalnumbers;
        try{
            system.debug('**ExistingContract**'+ExistingContract);
            if(ExistingContract=='yes'){
        
                if(ContractRenewal == 'yes'){
            
                    if(PricingMethod=='OrderProductQuantity'){
                        totalnumbers=   getAssetNunbersExistingContract(ListOfIds,'OrderProductQuantity');
                    }
                    else if(PricingMethod=='ProductUsageBased' || PricingMethod=='ProductDiscountGroupUsageBased'){
                        totalnumbers=    getAssetNunbersExistingContract(ListOfIds,PricingMethod);
                    }
                    else if(PricingMethod=='AccountStudents'){
                        
                       // if(GroupBasedType == 'OnAccount'){
                            system.debug('**On Account**');
                            totalnumbers=   getStudentNumberAccount(ListOfIds); //SHIP TO'S
                       // }
                      //  else if(GroupBasedType == 'OnClassification'){
                      //      totalnumbers= getStudentNumberClassification(ListOfIds);
                     //   }
                      //  else{
                       //     System.debug('Error-IncorrectOption - ExistingContract(YES),ContractRenewal(YES),PricingMethod(AccountStudents)');
        
                        //}				
        
                    }
                    else{
                        System.debug('Error-IncorrectOption - ExistingContract(YES),ContractRenewal(YES)');
                    }
                }
                else if(ContractRenewal == 'no'){
                
                    if(PricingMethod=='OrderProductQuantity' || PricingMethod=='AccountStudents' || PricingMethod=='ProductUsageBased' || PricingMethod=='ProductDiscountGroupUsageBased'){
                        totalnumbers= getStudentNumberContract(ListOfIds);
                    }
                    else{
                        System.debug('Error-IncorrectOption - ExistingContract(YES),ContractRenewal(NO)');
                    }
                
                }
                else{
                    System.debug('Error-IncorrectOption - ExistingContract(YES)');
                }
            
            }
            else if(ExistingContract=='no'){
                    
                
                if(ContractRequired=='yes'){ 
                    if(PricingMethod=='OrderProductQuantity'){
                        //Calculate the total Quantity on Order??
                    }
                    if(PricingMethod=='AccountStudents' || PricingMethod=='ProductUsageBased' || PricingMethod=='ProductDiscountGroupUsageBased'){
                        totalnumbers= getStudentNumberAccount(ListOfIds); //SHIP TO'S
                    }	
                    else{
                        System.debug('Error-IncorrectOption - ExistingContract(NO),ContractRequired(YES)');
                    }
                }    
                else if(ContractRequired=='no'){
        
                    if(PricingMethod=='AccountStudents' || PricingMethod=='ProductUsageBased' || PricingMethod=='ProductDiscountGroupUsageBased'){
                        totalnumbers= getStudentNumberAccount(ListOfIds); //SHIP TO'S
                    }		
                    else{
                        System.debug('Error-IncorrectOption - ExistingContract(NO),ContractRequired(NO)');
                    }
                }
            }
            else{
                System.debug('Error-IncorrectOption - ExistingContract(Not selected)');
            }
        
        
        }
        catch(exception ex){
           System.debug('Error:'+ex);
        }
        //totalnumbers = 315;
        return totalnumbers;
    }

    Public static Decimal getStudentNumberContract(List<Id> lstCon){

        Contract[] lstContract = [Select NumberofUsers__c,SoldUsers__c from  Contract where id in:lstCon AND SoldUsers__c != null]; // Based on Pricebook
        
        Decimal totalnumbers = 0; 
        for(Contract con:lstContract){

            totalnumbers += con.SoldUsers__c;
        }
        system.debug('**getStudentNumberContract**');

        
        return totalnumbers;
    }

    Public static Decimal getStudentNumberAccount(List<Id> lstAccId){

        Account[] lstAccount = [Select NumberOfStudents__c from  Account where id in:lstAccId];
        
        Decimal totalnumbers = 0; 
        for(Account acc:lstAccount){
            totalnumbers += acc.NumberOfStudents__c;
        }
        system.debug('**getStudentNumberAccount**');
       
        return totalnumbers;
    }

     


    public static Decimal getAssetNunbersExistingContract(List<Id> lstContract,String PricingMethod){
	
        
        Date TodayDate = system.today();
        Asset[] lstActiveAsset =  [Select id,Quantity,NumberofActiveUsers__c,Product2.CoreLicense__c from Asset where IsActive__c =: true and PurchaseDate <=:TodayDate and UsageEndDate>=:TodayDate and Contract__c in:lstContract AND Product2.CoreLicense__c =:true];
        
         
        Decimal totalnumbers = 0;
        for(Asset a:lstActiveAsset){
            if(PricingMethod == 'OrderProductQuantity'){
                totalnumbers += a.Quantity;
            }
            else if(PricingMethod == 'ProductUsageBased' || PricingMethod=='ProductDiscountGroupUsageBased'){
                totalnumbers += a.NumberofActiveUsers__c;
            }		
        }
        system.debug('**getAssetNunbersExistingContract**');

        return totalnumbers;
    
    }

    

   

}