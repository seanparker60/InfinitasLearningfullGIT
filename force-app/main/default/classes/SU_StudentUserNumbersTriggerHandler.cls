public class SU_StudentUserNumbersTriggerHandler {
    
    public static void calculateStudentNumbers(List<StudentAndUsernumbers__c> suList) {
        
        Set<Id> accountIds = new Set<Id>();

        for (StudentAndUsernumbers__c su : suList) {
            accountIds.add(su.Account__c);
        }

        List<StudentAndUsernumbers__c> fullSuList = [SELECT 
                                                        Id, 
                                                        Account__c, 
                                                        TotalNumber__c, 
                                                        KindergartenNumber__c, 
                                                        PrimaryEducationNumber__c, 
                                                        SecondaryEducationNumber__c, 
                                                        HigherEducationNumber__c, 
                                                        VocationalEducationNumber__c,
                                                        IsDeleted 
                                                    FROM StudentAndUsernumbers__c WHERE 
                                                        Account__c IN :accountIds AND 
                                                        Type__c = 'Student Numbers' AND 
                                                        StartDate__c <= TODAY AND 
                                                        (EndDate__c >= TODAY OR EndDate__c = null) ORDER BY Account__c];

        List<Account> accountList = new List<Account>();
        
        Id lastAccountId;
        Account acc = new Account();

        for (StudentAndUsernumbers__c su : fullSuList) {
        
            if (lastAccountId == null) {
                
                lastAccountId = su.Account__c;
                accountIds.remove(su.Account__c);
                acc.Id = su.Account__c;

                if (su.IsDeleted) {
                    acc.NumberofStudents__c = null;
                    acc.KGStudents__c = null;
                    acc.PEStudents__c = null;
                    acc.SEStudents__c = null;
                    acc.HEStudents__c = null;
                    acc.VEStudents__c = null;
                }

                else {
                    if (su.TotalNumber__c != null) {
                        acc.NumberofStudents__c = su.TotalNumber__c;
                    }
                    if (su.KindergartenNumber__c != null) {
                        acc.KGStudents__c = su.KindergartenNumber__c;
                    }
                    if (su.KindergartenNumber__c != null) {
                        acc.PEStudents__c = su.PrimaryEducationNumber__c;
                    }
                    if (su.SecondaryEducationNumber__c != null) {
                        acc.SEStudents__c = su.SecondaryEducationNumber__c;
                    }
                    if (su.HigherEducationNumber__c != null) {
                        acc.HEStudents__c = su.HigherEducationNumber__c;
                    }
                    if (su.VocationalEducationNumber__c != null) {
                        acc.VEStudents__c = su.VocationalEducationNumber__c;
                    }
    
                    if (su.Id == fullSuList[fullSuList.size()-1].Id) {
                        accountList.add(acc);
                    }
                }

            } else if (lastAccountId != su.Account__c) {
                
                accountList.add(acc);
                acc = new Account();
                lastAccountId = su.Account__c;
                accountIds.remove(su.Account__c);
                acc.Id = su.Account__c;

                if (su.IsDeleted) {
                    acc.NumberofStudents__c = null;
                    acc.KGStudents__c = null;
                    acc.PEStudents__c = null;
                    acc.SEStudents__c = null;
                    acc.HEStudents__c = null;
                    acc.VEStudents__c = null;
                }

                else {
                    if (su.TotalNumber__c != null) {
                        acc.NumberofStudents__c = su.TotalNumber__c;
                    }
                    if (su.KindergartenNumber__c != null) {
                        acc.KGStudents__c = su.KindergartenNumber__c;
                    }
                    if (su.KindergartenNumber__c != null) {
                        acc.PEStudents__c = su.PrimaryEducationNumber__c;
                    }
                    if (su.SecondaryEducationNumber__c != null) {
                        acc.SEStudents__c = su.SecondaryEducationNumber__c;
                    }
                    if (su.HigherEducationNumber__c != null) {
                        acc.HEStudents__c = su.HigherEducationNumber__c;
                    }
                    if (su.VocationalEducationNumber__c != null) {
                        acc.VEStudents__c = su.VocationalEducationNumber__c;
                    }
    
                    if (su.Id == fullSuList[fullSuList.size()-1].Id) {
                        accountList.add(acc);
                    }
                }
                
            } else {

                if (!su.IsDeleted) {
                    if (su.TotalNumber__c != null) {
                        acc.NumberofStudents__c += su.TotalNumber__c;
                    }
                    if (su.KindergartenNumber__c != null) {
                        acc.KGStudents__c += su.KindergartenNumber__c;
                    }
                    if (su.KindergartenNumber__c != null) {
                        acc.PEStudents__c += su.PrimaryEducationNumber__c;
                    }
                    if (su.SecondaryEducationNumber__c != null) {
                        acc.SEStudents__c += su.SecondaryEducationNumber__c;
                    }
                    if (su.HigherEducationNumber__c != null) {
                        acc.HEStudents__c += su.HigherEducationNumber__c;
                    }
                    if (su.VocationalEducationNumber__c != null) {
                        acc.VEStudents__c += su.VocationalEducationNumber__c;
                    }
    
                    if (su.Id == fullSuList[fullSuList.size()-1].Id) {
                        accountList.add(acc);
                    }
                }
            }
        }

        if (accountIds.size() > 0) {
            for (Id accId : accountIds) {
                acc.Id = accId;
                acc.NumberofStudents__c = null;
                acc.KGStudents__c = null;
                acc.PEStudents__c = null;
                acc.SEStudents__c = null;
                acc.HEStudents__c = null;
                acc.VEStudents__c = null;
                accountList.add(Acc);
            }
        }

        try {
            update accountList;
        } catch (Exception e) {
            System.debug('An error occured: ' + e.getMessage());
            HandleCustomException.LogException(e);
        }
    }

}