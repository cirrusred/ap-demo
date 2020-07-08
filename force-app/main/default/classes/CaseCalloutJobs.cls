public class CaseCalloutJobs implements Queueable, Database.AllowsCallouts { 

    private Set<Case> enqueuedCases { get; set; }
    
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
          	system.debug('newCase: ' + newCase);
            //Set a timer for processing...
            Long timerStart = System.now().getTime();
            
            //Create initial Case Callout for each case, and add it to the map
            Case_Callout__c caseCallOutStatus = new Case_Callout__c(Case__c = newCase.Id,
                                                                 AgentId__c = newCase.LastModifiedById,
                                                                 Response_Status__c = 'Pending',
                                                                 Request_Sent__c = DateTime.now());
           
            //Prepare the HTTP request body     
            String reqBody = '{\"id\":\"' + newCase.Id + '\",\"agentid\":\"' + newCase.LastModifiedById + '\"}';
            Map<String,String> reqBodyMap = new Map<String,String>{'id'=> newCase.Id,
                                                                    'agentid'=>newCase.LastModifiedById};
            
            String rqMap = EncodingUtil.urlEncode((String) JSON.serialize(reqBodyMap), 'UTF-8');
            
			//prepare the HTTP POST request
            Http h = new Http();
            HttpRequest request = new HttpRequest();
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setEndpoint('https://nfapihub.herokuapp.com/');
            request.setBody(rqMap);
            request.setTimeout(6000);
            request.setHeader('id', newCase.Id);
            request.setHeader('agentid', newCase.LastModifiedById);
            
            try{
                
                HttpResponse response = h.send(request);
                system.debug('=== ' + response.getBody());
                //If Response = 200, everything is OK
                if(response.getStatusCode() == 200){
                    caseCallOutStatus.Response_Status__c = 'OK';
                    
                    Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                    if(responseMap.containsKey('secretKey')){
                        caseCallOutStatus.Secret_Key__c = string.valueOf(responseMap.get('secretKey'));
                    }
                    
                //Else Reponse = Error
                }else{
                    caseCallOutStatus.Response_Status__c = 'Error';
                }
                
                //Set the Response Text (can be used to diagnose issues in request)
                caseCallOutStatus.Response_Text__c  = response.getBody();
                
            }
            catch(Exception e){
                caseCallOutStatus.Response_Status__c = 'Failed ';
                caseCallOutStatus.Response_Text__c = 'Exception found: ' + e.getStackTraceString();
                
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
                enqueuedCases.remove(newCase);
            }
            else{
                //exit the loop to then continue via a new enqueue job
                break;
            }
            
    	}
    
        
        //now insert the Case Callouts up to where processed
        if(!caseCallouts.isEmpty()){
            //insert the Case Callout records (AlOrNothing = false, to allow partial inserts if errors)
            database.insert(caseCallouts, false);
            
            List<Case> updateCases = new List<Case>();
            //for each case callout, if secret key returned, update the parent case
            for(Case_Callout__c cc : caseCallouts){
                system.debug('cc.Secret_Key__c: ' + cc.Secret_Key__c);
                if(cc.Secret_Key__c != '' && cc.Secret_Key__c != null){
                	updateCases.add(new Case(Id=cc.Case__c,Secret_Key__c=cc.Secret_Key__c));
                }
            }
            
            //if secret key returned, then update cases
            if(!updateCases.isempty()){
                database.update(updateCases, false);
            }
        }
        
        //if the enqueuedCases set still contains records, then enqueue another job
        //this helps with 100x callout per transaction limit
        if(!enqueuedCases.isEmpty() && !Test.isRunningTest()){
            System.enqueueJob(new CaseCalloutJobs(enqueuedCases));
        }
        
	}
    
}