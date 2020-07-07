public class CaseCalloutJobs implements Queueable, Database.AllowsCallouts { 

    private List<Case> queueCases { get; set; }
    
    //Constructor, storing input list values for processing below
    public CaseCalloutJobs(List<Case> inputCases){
        this.queueCases = inputCases;
    }
    
    //Queueable Context execution.  Run through each 
    public void execute(QueueableContext context) {
        
        //expected input is a filtered list of cases, where status was updated to 'Closed'
        List<Case_Callout__c > caseCallouts = new List<Case_Callout__c >();


		//As Salesforce has a limit of 100 callouts per transaction, use counter to requeue (if needed)
		integer i = 0;
        
        //Check each case, to ensure status has changed and is currently 'Closed'
        for(Case newCase : queueCases){
          
            //increment counter
            i++;
            
            //create initial Case Callout for each case, and add it to the map
            caseCallouts.add(new Case_Callout__c(Case__c = newCase.Id,
                                                 AgentId__c = newCase.LastModifiedById,
                                                 Response_Status__c = 'Queued'));
            
        
    	}
    
        //http://enreeco.blogspot.com/2014/11/salesforce-apex-queueable-interfaces.html#tldr_async_queueable
        
        //create 
        if(!caseCallouts.isEmpty()){
            insert caseCallouts;
        }
    
	}
}