public class CaseCalloutJobs implements Queueable, Database.AllowsCallouts { 

    private Set<Case> enqueuedCases { get; set; }
    private Set<Case> actionedCases { get; set; }
    
    //Constructor, storing input list values for processing below
    public CaseCalloutJobs(Set<Case> inputCases){
        this.enqueuedCases = inputCases;
    }
    
    //Queueable Context execution.  Run through each 
    public void execute(QueueableContext context) {
        
        //expected input is a filtered list of cases, where status was updated to 'Closed'
        List<Case_Callout__c > caseCallouts = new List<Case_Callout__c >();


		//As Salesforce has a limit of 100 callouts per transaction, use counter to requeue (if needed)
		integer i = 0;
        
        //Check each case, to ensure status has changed and is currently 'Closed'
        for(Case newCase : enqueuedCases){
          
            //Set a timer for processing...
            Long timerStart = System.now().getTime();
            
            //Create initial Case Callout for each case, and add it to the map
            Case_Callout__c caseCallOutStatus = new Case_Callout__c(Case__c = newCase.Id,
                                                                 AgentId__c = newCase.LastModifiedById,
                                                                 Response_Status__c = 'Pending',
                                                                 Request_Sent__c = DateTime.now());
           
            //Prepare the HTTP request body            
            String reqBody = '{\"id\":\"' + newCase.Id + '\",\"agentid\":\"' + newCase.LastModifiedById + '\"}';
            
            try{
                //prepare the HTTP POST request
                Http h = new Http();
                HttpRequest request = new HttpRequest();
                request.setMethod('POST');
                request.setEndpoint('https://nfapihub.herokuapp.com/');
                request.setBody(reqBody);
                request.setTimeout(6000);
                HttpResponse response = h.send(request);
                                
                //If Response = 200, everything is OK
                if(response.getStatusCode() == 200){
                    caseCallOutStatus.Response_Status__c = 'OK';
                //Else Reponse = Error
                }else{
                    caseCallOutStatus.Response_Status__c = 'Error';
                }
                
                //Set the Response Text (can be used to diagnose issues in request)
                caseCallOutStatus.Response_Text__c  = response.getBody();
                
            }
            catch(Exception e){
                caseCallOutStatus.Response_Status__c = 'Failed ';
                
            }
            
            //Add the finishing touches, close off timer and add into list
            DateTime timerEnd = DateTime.now();
            caseCallOutStatus.Response_Duration__c = (System.now().getTime()) - timerStart;
            caseCallouts.add(caseCallOutStatus);
            
            //increment counter
            i++;
            
           	//trigger.new can have up to 200 records, though salesforce has a limit of 100 callouts
           	//so process up to 100, and then remove the cases already processed, and enqueue another job
            if(i < 100){
	            actionedCases.add(newCase);
            }
            else{
                //remove the already actioned cases
                enqueuedCases.removeAll(actionedCases);
                //exit the loop
                break;
            }
            
    	}
    
        
        //now insert the Case Callouts up to where processed
        if(!caseCallouts.isEmpty()){
            insert caseCallouts;
            
        }
        
        //if the enqueuedCases set still contains records, then enqueue another job
        if(!enqueuedCases.isEmpty()){
            System.enqueueJob(new CaseCalloutJobs(enqueuedCases));
        }
        
	}
}