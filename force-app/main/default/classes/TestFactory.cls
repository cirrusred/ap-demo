@isTest
public class TestFactory {
    
    //Create a bulk amount of Cases for testing
    public static List<Case> createOpenCases (Integer numOfCasesToCreate) {
        List<Case> listOfCases = new List<Case>();
        
        for(Integer i=0; i<numOfCasesToCreate; i++){
            Case newCase = new Case(Subject='TestCase ' + i, Status='Open',
                                    Origin='Email', 
                                    Description='TestCase Description ' + i);
            
            listOfCases.add(newCase);
        }
        
        //create and return list
        insert listOfCases;
        return listOfCases;
    }
    
    //Create a bulk amount of Accounts
    public static List<Account> createAccounts (Integer numOfAcctsToCreate) {
        List<Account> listOfAccounts = new List<Account>();
        
        for(Integer i=0; i<numOfAcctsToCreate; i++){
            Account newAcct = new Account(Name='Test Co ' + i,
                                          Website='www.test.co',
                                    	  Description='TestCase Description ' + i);
            
            listOfAccounts.add(newAcct);
        }
		
        //create and return list
        insert listOfAccounts;
        return listOfAccounts;
    }
}