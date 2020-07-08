@isTest
public class CaseCalloutJobsMock implements HttpCalloutMock {
    
    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;
    
    //Constructor for class implmenting HTTPCalloutMock (used for testing)
    public CaseCalloutJobsMock(Integer code, String status, String body,
                       			Map<String, String> responseHeaders) {
            
            //Set the initial values on construction
            this.code = code;
            this.status = status;
            this.body = body;
            this.responseHeaders = responseHeaders;
    }
    
    
    //Method returning HTTPResponse, to be used in tests to send 'fake' response
    public HTTPResponse respond(HttpRequest req){
        
        //Prepare the HTTPResponse, using the variables defined on initialisation
        HttpResponse response = new HttpResponse();
        response.setStatusCode(code);
        response.setStatus(status);
        response.setBody(body);
        
        if (responseHeaders != null) {
            for (String key : responseHeaders.keySet()) {
                response.setHeader(key, responseHeaders.get(key));
            }
        }
        return response;
    }

}