/**
 * An apex page controller that exposes the site forgot password functionality
 */
public with sharing class CustomForgotPasswordController {
    public String username {get; set;}   
       
    public CustomForgotPasswordController() {}
	
  	public PageReference forgotPassword() {
  		boolean success = Site.forgotPassword(username);
  		PageReference pr = Page.CustomForgotPasswordConfirm;
  		pr.setRedirect(true);
  		
  		if (success) {  			
  			return pr;
  		}
  		return null;
  	}
}