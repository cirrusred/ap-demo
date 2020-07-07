public class CaseTriggerHandler {

    //Handler start method: accepts the newMap and oldMap from the trigger
    public static void start(Map<Id, Case> newCases, Map<Id, Case> oldCases){
        
        //Prepare a callout record, allowing tracking of callouts for cases
        List<Case> pendingCaseCallouts = new List<Case>();

		//Check each case, to ensure status has changed and is currently 'Closed'
        for(Case newCase : newCases.values()){
            Case oldCase = oldCases.get(newCase.Id);
            
            if(newCase.Status == 'Closed' && (oldCase.Status != newCase.Status)){
               //add to list for enqueue job
               pendingCaseCallouts.add(newCase);
            }
        }
        
        //if not empty, then go to enqueue jobs for callout
        if(!pendingCaseCallouts.isEmpty()){
            System.enqueueJob(new CaseCalloutJobs(pendingCaseCallouts));
        }
    }
}