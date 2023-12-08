global class UTIL_AggregateResultIterator implements Iterator<AggregateResult> {
    /*/
    *   @ Created By: Jannes Kleerebezem
    *   @ Created on: 15-02-2021
    *
    *   Use: 
    *   class for using Aggregate Results in Batch classes (use Together with "UTIL_AggregateResultIterable")
    *   Batch Apex class should use: implements Database.Batchable<AggregateResult>
    *   for Start Method: global Iterable<AggregateResult> start(Database.BatchableContext BC)
    *   for Execute Method: global void execute(Database.BatchableContext BC, List<AggregateResult> scope)
    *   
    /*/
    
    AggregateResult [] results {get;set;}
    // tracks which result item is returned
    Integer index {get; set;}

    global UTIL_AggregateResultIterator(String query) {
        index = 0;
        results = Database.query(query);
    }

    global boolean hasNext() {
        return results != null && !results.isEmpty() && index < results.size();
    }

    global AggregateResult next() {
        return results[index++];
    }
}