public with sharing class ContactTriggerHandler {

    public static void execute(){
        if(Trigger.isAfter){
            if(Trigger.isInsert){
                SetAccountPrimaryContact(Trigger.New);
                
            }

        }

    }

    public static void SetAccountPrimaryContact(List<Contact> contactList){

        List<Account> accountToUpdateList   = new List<Account>();
        Set<Id> accountIds                  = new Set<Id>();

        for(Contact con : contactList){
            accountIds.add(con.AccountId);
        }

        List<Account> linkedAccountsList = [SELECT Id, Primary_Contact__c FROM Account where Id =: accountIds];

        for(Contact con : contactList){
            for(Account acc : linkedAccountsList){
                if(con.AccountId != null && con.AccountId == acc.Id && acc.Primary_Contact__c  != con.Id && con.role__c != null && con.role__c.contains('Decision Maker')){
                    acc.Primary_Contact__c  = con.Id;
                    accountToUpdateList.add(acc);
                }

            }
            
        }

        Database.update(accountToUpdateList);

    }


}
