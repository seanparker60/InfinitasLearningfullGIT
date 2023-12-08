@istest
public with sharing class Order_BatchRemoveScheduledJobs_test {


    public static testmethod void BatchRemoveScheduledJobs (){

        test.startTest();    

        Datetime NextStart =  Datetime.now(); //.addMinutes(5)
        String hour = String.valueOf(NextStart.hour());
        String min = String.valueOf(NextStart.minute()); 
        String ss = String.valueOf(00);     

        String dayT = String.valueOf(NextStart.day());
        String monthT = String.valueOf(NextStart.Month()); 

        String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + dayT +' '+  monthT+ ' ?';
    
        system.debug('***nextFireTime***'+nextFireTime);    
        Order_BatchRemoveScheduledJobs  BatchRemove = new Order_BatchRemoveScheduledJobs();
        System.schedule('B2BActivateOrders: Started At ' + String.valueOf(Datetime.now()), nextFireTime, BatchRemove);

        Order_BatchRemoveScheduledJobs  RemoveScheduledJobs = new Order_BatchRemoveScheduledJobs();
        database.executebatch(RemoveScheduledJobs ,100);

        test.stoptest();

    }     
    public static testmethod void BatchRemoveScheduledJobs2 (){

        test.startTest();    

        Datetime NextStart =  Datetime.now(); //.addMinutes(5)
        String hour = String.valueOf(NextStart.hour());
        String min = String.valueOf(NextStart.minute()); 
        String ss = String.valueOf(00);     

        String dayT = String.valueOf(NextStart.day());
        String monthT = String.valueOf(NextStart.Month()); 

        String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + dayT +' '+  monthT+ ' ?';
    
        system.debug('***nextFireTime***'+nextFireTime);    
        Order_BatchRemoveScheduledJobs  BatchRemove = new Order_BatchRemoveScheduledJobs();
        System.schedule('B2BActivateOrders:' + String.valueOf(Datetime.now()), nextFireTime, BatchRemove);

        test.stoptest();

    }
}