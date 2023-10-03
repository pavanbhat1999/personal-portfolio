public without sharing class  CommunitySelfRegController {
    @AuraEnabled
    public static String  createExternalUser(
        String username, String password, String startUrl, String fname, 
        String lname, Boolean hasOptedTracking, Boolean hasOptedSolicit) {
            //return 'hello';
         
            Savepoint sp = null;
            try {
                sp = Database.setsavepoint();
                system.debug(sp);
                
                // Creating a user object. 
                User u = new User();
                u.Username = username;
                u.Email = username;
                u.FirstName = fname;
                u.LastName = lname;
                //u.ProfileId = '00e5i000000txWDAAY';

                // Default UI for mobile is set to S1 for user created using site object. 
                // Enable this perm to change it to community (Experience Cloud).
                u.UserPreferencesHideS1BrowserUI = true;
                
                // Generating unique value for Experience Cloud nickname. 
				String nickname = ((fname != null && fname.length() > 0) ? fname.substring(0,1) : '' ) + lname.substring(0,1);
            	nickname += String.valueOf(Crypto.getRandomInteger()).substring(1,7);
                u.CommunityNickname = nickname;
                
                System.debug('creating user');
                List<Account> lstAccount = new List<Account>();
                Id personAccRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
                Account newAcc = new Account(FirstName=fname, LastName=lname,personemail=username,RecordtypeId=personAccRecordTypeId);
                insert newAcc;
                //lstAccount.add(newAcc);
                // Creating portal user. 
                // Passing in null account ID forces the system to read this from the network setting (set using Experience Workspaces).
                String userId = Site.createExternalUser(u,newAcc.Id,password,true);
                 System.debug('creating user2');
                // Setting consent selection values. 
                // For this, GDPR (Individual and Consent Management) needs to be enabled in the org. 
                Individual ind = new Individual();
                ind.LastName = lname;
                ind.HasOptedOutSolicit = !hasOptedSolicit;
                ind.HasOptedOutTracking = !hasOptedTracking;
                insert(ind);
                System.debug('creating user3');
                 System.debug(u.ContactId);
                // Other contact information can be updated here. 
                Contact contact = new Contact();
                contact.Id = u.ContactId;
                contact.IndividualId = ind.Id;
                update(contact);       
                System.debug('creating user4');
                // return login url. 
                if (userId != null && password != null && password.length() > 1) {  
                    ApexPages.PageReference lgn = Site.login(username, password, startUrl);
                    return lgn.getUrl();
                }
            }
            catch (Exception ex) {
                Database.rollback(sp);
                System.debug(ex.getMessage());
               return ex.getMessage();
            }
            return 'hello'; 

            
            
        }   

}