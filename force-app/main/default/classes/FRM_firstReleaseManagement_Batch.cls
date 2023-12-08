/*/
*   @ Created By: Jannes Kleerebezem
*   @ Created on: 27-12-2021
*
*   Use: 
*   Used to for Scheduled First ReleaseManagement process.
*
*   To manualy run the Batch job:
*   in example below the OpCo = Plantyn
*   FRM_firstReleaseManagement_Batch firstReleaseBatch = new FRM_firstReleaseManagement_Batch('Plantyn');
*   Id batchprocessid = Database.executebatch(firstReleaseBatch, 200);
/*/

global class FRM_firstReleaseManagement_Batch implements Database.Batchable<sObject>, Database.Stateful {
    
    global String opCo;
    global List<ImportOrder__c> importOrderList = new List<ImportOrder__c>();
    global List<ImportOrder__c> importOrderItemList = new List<ImportOrder__c>();

    global FRM_firstReleaseManagement_Batch(String OperatingCompany) {
        this.opCo = OperatingCompany;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('FRM_firstReleaseManagement_Batch - START - Opco: ' + opCo);

        String query = '';
        if (opCo == 'Plantyn') {
            query = 'SELECT Id, ISBN__c, StockNumber__c, Type__c, Subsidiary__c FROM Product2 WHERE Subsidiary__c = \'Plantyn\' AND Type__c = \'Inventory Item\' AND Stocknumber__c != null AND Stocknumber__c > 0 AND FirstPublicationDate__c = YESTERDAY';
        } else if (opCo == 'Noordhoff') {
            query = 'SELECT Id, ISBN__c, StockNumber__c, Type__c, Subsidiary__c FROM Product2 WHERE Subsidiary__c = \'Noordhoff\' AND ISBN__c != \'\' AND FirstPublicationDate__c = YESTERDAY';
        } else if (opCo == 'Liber') {
            query = 'SELECT Id, ISBN__c, StockNumber__c, Type__c, Subsidiary__c FROM Product2 WHERE Subsidiary__c = \'Liber\' AND FirstPublicationDate__c = LAST_QUARTER';
        } else {
            System.debug('We did not receive a correct Operating Company (' + opCo + ')');
        }
        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Product2> scope) {
        System.debug('FRM_firstReleaseManagement_Batch - EXECUTE - Opco: ' + opCo);

        System.debug('scope size = ' + scope.size());

        Map<String, List<ImportOrder__c>> importOrderMap = new Map<String, List<ImportOrder__c>>();

        // Plantyn specific
        if (opCo == 'Plantyn') {
            importOrderMap = FRM_createSalesOrders.createSalesOrdersForPlantyn(scope);
            this.importOrderList.addAll(importOrderMap.get('orders'));
            this.importOrderItemList.addAll(importOrderMap.get('orderItems'));
        }
        
        // Noordhoff specific
        if (opCo == 'Noordhoff') {
            importOrderMap = FRM_createSalesOrders.createSalesOrdersForNoordhoff(scope);
            this.importOrderList.addAll(importOrderMap.get('orders'));
            this.importOrderItemList.addAll(importOrderMap.get('orderItems'));
        }

        // Liber specific
        if (opCo == 'Liber') {
            importOrderMap = FRM_createSalesOrders.createSalesOrdersForLiber(scope);
            this.importOrderList.addAll(importOrderMap.get('orders'));
            this.importOrderItemList.addAll(importOrderMap.get('orderItems'));
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('FRM_firstReleaseManagement_Batch - FINISH - Opco: ' + opCo);

        if (this.importOrderItemList.size() > 0) {
            
            // Set last Order Item to trigger businesslogic
            this.importOrderItemList.get(this.importOrderItemList.size() - 1).TriggerBusinessLogic__c = true;

            // Insert orders
            try {
                insert this.importOrderList;
            } catch (Exception e) {
                HandleCustomException.LogException(e);
            }

            // Insert order items
            try {
                insert this.importOrderItemList;
            } catch (Exception e) {
                HandleCustomException.LogException(e);
            }

        }

    }

}