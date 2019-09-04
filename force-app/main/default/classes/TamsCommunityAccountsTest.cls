@isTest
public class TamsCommunityAccountsTest {
	@isTest
	public static void testCommunityAccounts(){
		PageReference acctPage = Page.My_View_Accounts_New;
		Test.setCurrentPage(acctPage);
		List<Account> accts = createAccounts(10);
		
		Test.startTest();
		TamsCommunityAccounts acctController = new TamsCommunityAccounts();
		acctController.sortByName();
		acctController.sortByName();//for Desc
		acctController.sortByName();//for ASC again
		acctController.sortByCity();
		acctController.sortByCity();//For Desc
		acctController.sortByCity();//For ASC again
		acctController.sortByZip();
		acctController.sortByZip();//for Desc
		acctController.sortByZip();//for ASC again
		acctController.sortByState();
		acctController.sortByState();//For Desc
		acctController.sortByState();//For ASC again
		acctController.filterByCity='Tustin';
		acctController.filterByName='TEST';
		acctController.filterByState='CA';
		acctController.filter();
		acctController.refreshPageSize();
		acctController.clearFilter();
		List<Account> accts1 = acctController.getAccounts();

		Test.stopTest();
		System.assert(accts1.size() == 10 ,'Total account count should be 10');
	}

	private static List<Account> createAccounts(Integer cnt){
		List<Account> accts = new List<Account>();
		for(Integer i=0 ; i < cnt; i++){
			Account acct = new Account();
			acct.Name = 'TEST ACCOUNT'+i;
			acct.ShippingCity = 'Tustin';
			acct.ShippingStreet = 'TAMS'+i;
			acct.ShippingState = 'CA';
			acct.ShippingPostalCode = '92570';
			accts.add(acct);
		}
		insert accts;
		return accts;	
	}

}