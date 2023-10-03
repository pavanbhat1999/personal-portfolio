public with sharing class caseDataLoad {
    public caseDataLoad() {
        return;
    }
    // Method for inserting bulk cases
    @AuraEnabled
    public static String insertCaseBulk(String caseJson){
        try{
        System.debug(caseJson);
        List<Case> caseList = (List<Case>) JSON.deserialize(caseJson, List<Case>.class);
        System.debug('Deserelized Case'+caseList);
        List<Case> finalCaseList = new List<Case>();
        List<Account> accountTemp;
        for(Case c : caseList){
            //process case here 
            Case finalCase = new Case();
            finalCase.Status = c.Status;
            finalCase.Origin = c.Origin;
            finalCase.Subject = c.Subject;
            // find account mechanism
            //System.debug('account name '+c.AccountId);
            
           
            // FIXME:check if no account provided
            // if(c.AccountId==''){
            //     return 'One or more accounts are left empty';
            // }
            accountTemp = [select Id from account where name=:c.AccountId LIMIT 1];
            if(accountTemp.isEmpty()){
                return 'This Account is not Present in ORG: '+c.AccountId ;
            }
            if(!accountTemp.isEmpty()){
            System.debug('account found'+ accountTemp);
            finalCase.AccountId = accountTemp[0].Id;
            }
            finalCaseList.add(finalCase);
        }
        System.debug('Final Case to be inserted ' + finalCaseList);
       
            //(Database.insert(finalCaseList));
            return 'Case Load Success';
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
            
        }
    }
}