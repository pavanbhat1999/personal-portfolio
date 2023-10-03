@IsTest
private class CreateContactOnAccountInsertTest {
    @TestSetup
    static void setup() {
        // Create test records
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            Account acct = new Account();
            acct.Name = 'Test Account ' + i;
            accounts.add(acct);
        }
        insert accounts;
    }
    
    @IsTest
    static void testCreateContactOnAccountInsert() {
        // Get the custom setting value
       
        List<AccountTrigger__c> lst = [SELECT id FROM AccountTrigger__c];
        lst[0].Active__c = true;
        update lst;
        
        // Create a new Account
        Account acct = new Account();
        acct.Name = 'New Test Account';
        insert acct;
        
        // Check if a Contact was created
        List<Contact> contacts = [SELECT Id, FirstName, LastName, AccountId FROM Contact WHERE AccountId = :acct.Id];
        System.assertEquals(1, contacts.size(), 'A Contact should have been created for the new Account');
        System.assertEquals('John', contacts[0].FirstName, 'The Contact\'s first name should be John');
        System.assertEquals('Doe', contacts[0].LastName, 'The Contact\'s last name should be Doe');
        System.assertEquals(acct.Id, contacts[0].AccountId, 'The Contact should be associated with the new Account');
    }
    
    @IsTest
    static void testCreateContactOnAccountInsertDisabled() {
        // Get the custom setting value
         List<AccountTrigger__c> lst = [SELECT id FROM AccountTrigger__c];
        lst[0].Active__c = false;
        update lst;
        
        // Create a new Account
        Account acct = new Account();
        acct.Name = 'New Test Account';
        insert acct;
        
        // Check that no Contact was created
        List<Contact> contacts = [SELECT Id FROM Contact WHERE AccountId = :acct.Id];
        System.assertEquals(0, contacts.size(), 'No Contact should have been created since the custom setting is disabled');
    }
}