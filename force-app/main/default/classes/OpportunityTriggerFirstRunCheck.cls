/*********************************************************
        Author: XELLERATION         
        Purpose: This Class is used to hold static
        variables checking for recursive triggers.        
        1.1 - Brandon Cassis - 03/09/2015 - Updated
**********************************************************/

public class OpportunityTriggerFirstRunCheck {
    public static boolean firstRun = true;
    
    //Used to control the opportunity amount calculation check.
    private static boolean run = true;
    public static boolean runOpptyOnce(){
        if(run){
         run=false;
         return true;
        }else{
            return run;
        }
    }
}