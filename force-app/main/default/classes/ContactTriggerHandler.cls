public with sharing class ContactTriggerHandler {

    public static void execute(){
        if(Trigger.isAfter){
            if(Trigger.isInsert){
                //SetAccountPrimaryContact(Trigger.New);
                
            }
            if(Trigger.isUpdate){
                updateAccountContactRelationship(Trigger.old, Trigger.new);
            }

        }

    }

    public static void SetAccountPrimaryContact(List<Contact> contactList){

        List<Account> accountToUpdateList   = new List<Account>();
        Set<Id> accountIds                  = new Set<Id>();

        for(Contact con : contactList){
            accountIds.add(con.AccountId);
        }

        List<Account> linkedAccountsList = [SELECT Id, Primary_Contact__c FROM Account where Id IN : accountIds];

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

    public static void updateAccountContactRelationship(List<Contact> contactListOld, List<Contact> contactListNew){
        Set<Id> contactIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();

        for (Contact conOld : contactListOld){
            if(conOld.AccountId != null){
                contactIds.add(conOld.Id);
                accountIds.add(conOld.AccountId);
            }
        }

        List<AccountContactRelation> oldDecisionMakers      = [SELECT Roles, accountid,contactid FROM AccountContactRelation
                                                                WHERE accountID IN :accountIds
                                                                AND contactID IN : contactIds
                                                                AND Roles INCLUDES ('Decision Maker')];

        List<AccountContactRelation> accContactToBeUpdated  = new List<AccountContactRelation>();

        if(!oldDecisionMakers.isEmpty()){

            for(AccountContactRelation acrOld : oldDecisionMakers){

                String[] roleList   = acrOld.Roles.split(';');
                String newRole      = '';

                for(String role :   roleList){
                    if(!role.equals('Decision Maker')){
                        newRole     += role + '; ';                            
                    }
                }
                system.debug(newRole);
                system.debug(acrOld.Roles);
                acrOld.roles = newRole;
                accContactToBeUpdated.add(acrOld);
            }

        }

        contactIds                      = new Set<Id>();
        accountIds                      = new Set<Id>();
        Map<Id,String> contactRolesMap  = new Map<Id, String>();

        for (Contact conNew : contactListNew){
            if(conNew.AccountId != null){
                contactIds.add(conNew.Id);
                accountIds.add(conNew.AccountId);
                contactRolesMap.put(conNew.Id, conNew.role__c);
            }
        }

        List<AccountContactRelation> newDecisionMakers      = [SELECT Roles, accountid,contactid FROM AccountContactRelation
                                                                WHERE accountID IN :accountIds
                                                                AND contactID IN : contactIds
                                                                AND Roles EXCLUDES ('Decision Maker')];
        
        if(!newDecisionMakers.isEmpty()){

            for(AccountContactRelation acrNew : newDecisionMakers){
                //String roleList   = acrNew.Roles.split(';');
                String newRole      = acrNew.Roles;


                for (Id conId : contactRolesMap.keySet()){

                    for (String conRole : contactRolesMap.get(conId).split(';') ){

                        if(!newRole.contains(conRole)){
                            newRole     += conRole + '; ';                            
                        }
                    }
                }
                system.debug(newRole);
                system.debug(acrNew.Roles);
                acrNew.roles = newRole;
                accContactToBeUpdated.add(acrNew);
            }

        }

        if(!accContactToBeUpdated.isEmpty()){
            update accContactToBeUpdated;
        }
    }


}