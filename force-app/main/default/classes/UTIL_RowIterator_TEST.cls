@isTest
public class UTIL_RowIterator_TEST {

    @TestSetup
    static void makeData(){
        
    }

    @IsTest
    static void Test01(){
        
        String testString = 'This,is,the,first,line\r\nThis,is,the,second,line\r\nThis,is,the,third,line\r\n';
        List<String> testList = new List<String>();
        Test.startTest();
            testList = UTIL_RowIterator.getList(testString,'\r\n');
        Test.stopTest();
        
        System.assertEquals(3, testList.size());
    }
    
}