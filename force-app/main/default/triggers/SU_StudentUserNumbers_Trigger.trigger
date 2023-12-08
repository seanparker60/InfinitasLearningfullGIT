trigger SU_StudentUserNumbers_Trigger on StudentAndUsernumbers__c (after insert, after update, after delete) {

    if (trigger.isInsert || trigger.isUpdate) {
        SU_StudentUserNumbersTriggerHandler.calculateStudentNumbers(trigger.new);
    }

    if (trigger.isDelete) {
        SU_StudentUserNumbersTriggerHandler.calculateStudentNumbers(trigger.old);
    }

}