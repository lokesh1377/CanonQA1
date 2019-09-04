/**
  * Controller Class object for Visualforce page.
  *
  * Used By: CustomLoginPage
  * 
  * @author NTT Data: Louis Wooldridge
  * @date July 9, 2015
  *
  * @update
  */
global class CustomLoginController {
	global String username {get;set;}
	global String password {get;set;}
	
	global CustomLoginController(){
	}
	global PageReference forwardToAuthPage(){
		return new PageReference('/CustomLoginPage');
	}
	global PageReference login(){
	try{
		PageReference oLoginPage = Site.login(username, password, null);
		return oLoginPage;
		
	}catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: ' + e.getMessage())); return null;}
    }
}