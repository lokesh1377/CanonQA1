@isTest
private class CustomLoginControllerTest {

    static testMethod void testLogin() {
    	test.startTest();
    	PageReference oLogin = new PageReference('/apex/CustomLogin');
    	test.setCurrentPage(oLogin);
    	CustomLoginController oLoginController = new CustomLoginController();
    	oLoginController.forwardToAuthPage();
    	oLoginController.username = 'username';
    	oLoginController.password = 'password';
    	oLoginController.login();
    	test.stopTest();
    }
}