public class UTIL_CleanObjectRecordsInvocable {
	@InvocableMethod(label='Clean objects and create summaries')
    public static void cleanObjects(){
        UTIL_CleanObjectRecordsScheduleable ctrl = new UTIL_CleanObjectRecordsScheduleable();
        ctrl.execute(null);
    }
}