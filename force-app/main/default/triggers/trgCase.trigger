trigger trgCase on Case (after update) {
    //assumptions have been made that cases wouldn't be created and closed in same transaction.  
    //If this was the case, an 'after insert' would also be more appropriate here.
    

    
}