@isTest
public class Contact_BeforeTest {
	private static final String PRIM = 'Primary';
	private static final String TESTWORD = 'Test';
	private static final Integer ACCOUNTCOUNT = 500;
	
	@isTest
	public static void createContactWithPrimaryTitle() {
		Account account = SObjectFactory2.createAccount(1)[0];
		account.Phone = '2552525';
		update account;

		Contact cont = new Contact(
			LastName = account.Name,
			Title = PRIM
		);

		Test.startTest();
		insert cont;
		Test.stopTest();

		List<Contact> conts = [SELECT Id, AccountId, Phone FROM Contact WHERE AccountId = :account.Id];

		System.assertEquals(1, conts.size(), 'Count contact is not true');
		System.assertEquals(account.Id, conts[0].AccountId, 'Account Id is not true');
		System.assertEquals(account.Phone, conts[0].Phone, 'Contact Phone is not true');
	}

	@isTest
	public static void negativeCreateContactWithPrimaryTitle() {
		Account account = SObjectFactory2.createAccount(1)[0];

		Contact cont = new Contact(
			LastName = account.Name,
			Title = TESTWORD
		);

		Test.startTest();
		insert cont;
		Test.stopTest();

		List<Contact> conts = [SELECT Id, AccountId FROM Contact WHERE AccountId = :account.Id];

		System.assertEquals(0, conts.size(), 'Count contact is not true');
	}

	@isTest
	public static void bulkCreateContactWithPrimaryTitle() {
		List<Account> accounts = SObjectFactory2.createAccount(ACCOUNTCOUNT);
		List<Contact> contacts = new List<Contact>();
		Set<Id> accIds = new Set<Id>();

		for(Account acc: accounts) {
			Contact cont = new Contact(
				LastName = acc.Name,
				Title = PRIM
			);
			contacts.add(cont);
			accIds.add(acc.Id);
		}

		Test.startTest();
		insert contacts;
		Test.stopTest();

		List<Contact> conts = [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accIds];

		System.assertEquals(ACCOUNTCOUNT, conts.size(), 'Count contact is not true');
	}
}
