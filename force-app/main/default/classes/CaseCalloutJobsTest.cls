@isTest
public class CaseCalloutJobsTest {

 	private static final String RESPONSE_BODY_SUCCESS = '{\"success\":true,\"secretKey\":\"testASDFGHJK123456\"}';
    private static final String RESPONSE_BODY_TIMEOUT = '{\"success\":false,\"error\":\"the api timed out\"}';
    private static final String RESPONSE_BODY_ERROR = '{\"success\":false,\"error\":\"id is invalid\"}';
    public static final String RESPONSE_HEADER_PARAM_NAME = 'Content-Type';
    public static final String RESPONSE_HEADER_CONTENT_TYPE = 'application/json';
 
    @isTest
    //this test will create an successful response, and the cases SHOULD have a secret key
    public static void testSuccess_OnCallout(){
        
        //create the cases
        List<Case> testCases = TestFactory.createOpenCases(5);
        
        //setup the Mock Callout, to be used within the test class
        Map<String, String> responseHeaders = new Map<String, String>{RESPONSE_HEADER_PARAM_NAME=>RESPONSE_HEADER_CONTENT_TYPE};
        
        CaseCalloutJobsMock testCalloutSuccess = new CaseCalloutJobsMock(200,'Complete',
                                                                         RESPONSE_BODY_SUCCESS,
                                                                         responseHeaders);
        
        test.setMock(HttpCalloutMock.class, testCalloutSuccess);
    
        
		Test.startTest();
        
        //update the cases to closed & test callout
        for(Case c : testCases){
            c.Status = 'Closed';
            c.Reason = 'Complex functionality';
        }
        
        update testCases;
        
        list<Case_Callout__c> queryCasesCallouts = [Select Id, Secret_Key__c, Response_Text__c, Response_Status__c,
                                            				Case__r.Id, Case__r.Subject, Case__r.Status, 
                                                    		Case__r.Reason, Case__r.Secret_Key__c
                                            		From Case_Callout__c];
        
        for(Case_Callout__c cc: queryCasesCallouts){
            //test the resposne code (should be 200)
            system.assertEquals('OK', cc.Response_Status__c, 'Assert failed: Response Code');
            
            //test the secret key was added to the related case
            system.assertEquals('testASDFGHJK123456', cc.Case__r.Secret_Key__c, 'Assert failed: Key not on Case');
        }
        
   
        Test.stopTest();    
    }
    
    
    @isTest
    //this test will create an error response, and the cases should NOT have a secret key
    public static void testError_OnCallout(){
        
        //create the cases
        List<Case> testCases = TestFactory.createOpenCases(5);
        
        //setup the Mock Callout, to be used within the test class
        Map<String, String> responseHeaders = new Map<String, String>{RESPONSE_HEADER_PARAM_NAME=>RESPONSE_HEADER_CONTENT_TYPE};
        
        CaseCalloutJobsMock testCalloutSuccess = new CaseCalloutJobsMock(500,'Internal Server Error',
                                                                         RESPONSE_BODY_ERROR,
                                                                         responseHeaders);
        
        test.setMock(HttpCalloutMock.class, testCalloutSuccess);
    
        
		Test.startTest();
        
        //update the cases to closed & test callout
        for(Case c : testCases){
            c.Status = 'Closed';
            c.Reason = 'Complex functionality';
        }
        
        update testCases;
        
        list<Case_Callout__c> queryCasesCallouts = [Select Id, Secret_Key__c, Response_Text__c, Response_Status__c,
                                            				Case__r.Id, Case__r.Subject, Case__r.Status, 
                                                    		Case__r.Reason, Case__r.Secret_Key__c
                                            		From Case_Callout__c];
        
        for(Case_Callout__c cc: queryCasesCallouts){
            //test the resposne code (should be 200)
            system.assertEquals('Error', cc.Response_Status__c, 'Assert failed: Response Code');
            
            //test the secret key was added to the related case
            system.assertEquals('', cc.Case__r.Secret_Key__c, 'Assert failed: Key was populated on Case');
        }
        
   
        Test.stopTest();    
    }
    
    
    
    @isTest
    //this test will create an successful response, when more than 100 cases updates/triggered
    //will also ensure api limits are not reached on scale, instead will enqueue/chain another job
    public static void testSuccess_OnBulkCallout(){
        
        //create the cases
        List<Case> testCases = TestFactory.createOpenCases(200);
        
        //setup the Mock Callout, to be used within the test class
        Map<String, String> responseHeaders = new Map<String, String>{RESPONSE_HEADER_PARAM_NAME=>RESPONSE_HEADER_CONTENT_TYPE};
        
        CaseCalloutJobsMock testCalloutSuccess = new CaseCalloutJobsMock(200,'Complete',
                                                                         RESPONSE_BODY_SUCCESS,
                                                                         responseHeaders);
        
        test.setMock(HttpCalloutMock.class, testCalloutSuccess);
    	
		Test.startTest();
        
        //update the cases to closed & test callout
        for(Case c : testCases){
            c.Status = 'Closed';
            c.Reason = 'Complex functionality';
        }
        
        update testCases;
        
        list<Case_Callout__c> queryCasesCallouts = [Select Id, Secret_Key__c, Response_Text__c, Response_Status__c,
                                            				Case__r.Id, Case__r.Subject, Case__r.Status, 
                                                    		Case__r.Reason, Case__r.Secret_Key__c
                                            		From Case_Callout__c];
        
        for(Case_Callout__c cc: queryCasesCallouts){
            //test the resposne code (should be 200)
            system.assertEquals('OK', cc.Response_Status__c, 'Assert failed: Response Code');
            
            //test the secret key was added to the related case
            system.assertEquals('testASDFGHJK123456', cc.Case__r.Secret_Key__c, 'Assert failed: Key not on Case');
        }
        
   
        Test.stopTest();    
    }
}