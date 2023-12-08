trigger Order_PriceTrigger on Pricing__c (before delete) {

    if (trigger.isDelete) {

      //  system.debug('**Trigger: Order_ProductComponet**'+trigger.old);

        Order_ProductComponentPrice.removedeleteProductPrice(trigger.oldMap);
    }

}