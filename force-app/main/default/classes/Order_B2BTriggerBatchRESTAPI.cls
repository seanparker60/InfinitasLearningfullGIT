@RestResource(urlMapping='/B2BTriggerBatch/*')
global with sharing class Order_B2BTriggerBatchRESTAPI {
    @HttpGet
    global static String doGet() {
        
        String resp='Success';
        try{
            Order_BatchUpdateB2BOrders  B2BOrders = new Order_BatchUpdateB2BOrders();
            database.executebatch(B2BOrders ,1);
        }
        catch(exception e){
            resp=e.getmessage();
        }

        return resp;
    }


@invocablemethod
public static void startBatch(){

    Order_BatchUpdateB2BOrders  B2BOrders = new Order_BatchUpdateB2BOrders();
        database.executebatch(B2BOrders ,1);
}

}