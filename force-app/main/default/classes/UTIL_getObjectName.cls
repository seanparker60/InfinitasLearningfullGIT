global class UTIL_getObjectName {

 @InvocableMethod
 public static List<string> returnObjectName(List<string> recordIdStrings){
 // object Ids to return
 List<string> objectNames = new List<string>();
 // get record name
 Id recordId = Id.valueOf(recordIdStrings[0]);
 String objectName = recordId.getSobjectType().getDescribe().getName();
 // add object name to list
 objectNames.add(recordId.getSobjectType().getDescribe().getName());
 // return
 return objectNames;
 }
}