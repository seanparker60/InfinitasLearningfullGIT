global class UTIL_AggregateResultIterable implements Iterable<AggregateResult> {
    /*/
    *   @ Created By: Jannes Kleerebezem
    *   @ Created on: 15-02-2021
    *
    *   Use: 
    *   class for using Aggregate Results in Batch classes (use Together with "UTIL_AggregateResultIterator")
    *   Batch Apex class should use: implements Database.Batchable<AggregateResult>
    *   for Start Method: global Iterable<AggregateResult> start(Database.BatchableContext BC)
    *   for Execute Method: global void execute(Database.BatchableContext BC, List<AggregateResult> scope)
    *   
    /*/

    private String query;
    
    global UTIL_AggregateResultIterable(String soql) {
        query = soql;
    }

    global Iterator<AggregateResult> Iterator(){
        return new UTIL_AggregateResultIterator(query);
    }
}