trigger LEAD_leadTrigger on Lead (after insert, after update) {

    if (trigger.isAfter) {

        if (trigger.isInsert) {
            LEAD_leadTriggerHelper.afterInsert(trigger.new);
        }
        if (trigger.isUpdate) {
            LEAD_leadTriggerHelper.afterUpdate(trigger.oldMap, trigger.newMap);
        }
    }

}