
Solution Overview/Preamble

Initially, first thought was to test the API via Postman to see if a JSON array object was able to be reference… This is obviously dependant on API config on the other system. Ie to have the Workforce Planning API to handle many records in single call out, by sending an array of value-pairs (case Id and agentId).  Though testing with Postman, this didn’t appear to work.

Instead, testing the API via Postman it appears the API handles POST transaction, using form-data.  

 
So assuming, a single value (representing a single case record), I am using a Queueable Interface solution, which allows for chaining of jobs, up to a limit of 50 at one time.  The solution includes: 

-	A trigger on case object, would fire after an update to the case, this would then invoke trigger handler class
-	Trigger Handler class, would first test records in trigger.newMap, meet criteria to where status is changed, and now closed.  Then test how many queueable processes are running currently.
-	Apex Class which implements the Queueable interface, which will query cases updated to closed and process API
-	Additional field on case to store ‘secret key’ on case record
o	Profile access/visibility/etc to be defined
-	A new ‘callout’ object, which links to the case record and stores transaction information.  This could allow for redundancy, where API timesout, allowing cases to be ‘resent’ via api at a later time.



Justifications
-	@Future annotated methods can’t be called/invoked from another future callout
-	Queueable interface allows you to setup and enqueue the next run of the queueable job, effectively allowing you to chain the running of the job to the completion of the one before it (as of Summer ’15 release)
-	Queueable interface allows for parallel running / processing, dependant of SF server capacity (instead of serial processing).  This should help re: volume of transactions.
-	Queueable allows for asynchronous running of processes, which allows more efficient running within Salesforce for large volume processing.
-	Queueable interface also allows for sObject record to be parsed in, allowing for quicker processing (compared to @future which is primitive data type only, this means we avoid additional queries needed to get other information from Case)
-	Assumptions have been made about other triggers, workflows and flows which may also update the case object.  If CPU processing time was a consideration (due to other long running process) a different solution may be more appropriate.


