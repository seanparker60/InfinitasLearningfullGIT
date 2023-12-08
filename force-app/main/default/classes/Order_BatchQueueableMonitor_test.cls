@Istest
public with sharing class Order_BatchQueueableMonitor_test {
    

    public static testmethod void BatchQueueableMonitor (){

        test.startTest();    

        Datetime NextStart =  Datetime.now().addMinutes(5);
        String hour = String.valueOf(NextStart.hour());
        String min = String.valueOf(NextStart.minute()); 
        String ss = String.valueOf(00);     

        String dayT = String.valueOf(NextStart.day());
        String monthT = String.valueOf(NextStart.Month()); 

        String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + dayT +' '+  monthT+ ' ?';
    
        system.debug('***nextFireTime***'+nextFireTime);    
        Order_BatchQueueableMonitor  orderActivate = new Order_BatchQueueableMonitor();
        System.schedule('B2BActivateOrders: Started At ' + String.valueOf(Datetime.now()), nextFireTime, orderActivate);

        Order_BatchQueueableMonitor  RemoveScheduledJobs = new Order_BatchQueueableMonitor();
        database.executebatch(RemoveScheduledJobs ,1);

        test.stoptest();

    }     


}