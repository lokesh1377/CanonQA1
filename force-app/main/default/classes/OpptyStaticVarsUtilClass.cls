/*********************************************************
        Author: XELLERATION         
        Purpose: This Utility Class is usedto store static  
        variables that can be used accross objects in a context.    
        1.0 - Brandon Cassis - 03/17/2015 - Created
**********************************************************/
public class OpptyStaticVarsUtilClass{

    public static string AEProfileId;
    
    public static string getAEProfile() {
    
        if(AEProfileId == null || AEProfileId == '') {
            
            try {
                AEProfileId = [select Id From Profile where name = :System.Label.AEProfileName limit 1].id;
            } catch(Exception e) {
                ErrorLog.storeException(e.getMessage());
            }
        } 
        return AEProfileId;
    }
}