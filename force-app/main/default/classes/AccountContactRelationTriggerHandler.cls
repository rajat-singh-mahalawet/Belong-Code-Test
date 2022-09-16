public with sharing class AccountContactRelationTriggerHandler {

    public static final String ACCOUNTCONTACT_DM_ROLE = 'Decision Maker';

    public AccountContactRelationTriggerHandler() {

    }

    public static void execute(){
        if(Trigger.isBefore){

            if(Trigger.isInsert){
                //populate Role from Contact
                AccountContactRelationRolecreate(Trigger.New);
                
            }
        }

        if(Trigger.isAfter){

            if(Trigger.isInsert){
                //populate Role from Contact
                UpdatePrimaryContact(Trigger.new);
                
            }

            if(Trigger.isUpdate){

                List<AccountContactRelation> updatedACRWithNewRole  = new List<AccountContactRelation>();
                Map<Id, AccountContactRelation> oldItemsAcrMap      = new Map<Id, AccountContactRelation>();
                oldItemsAcrMap                                      = (Map<Id, AccountContactRelation>)(Trigger.oldMap);                
                List<AccountContactRelation> newItems               = Trigger.new;

                for(AccountContactRelation acr  : newItems){
                   // if(acr.Roles != oldItemsAcrMap.get(acr.id).Roles){
                        updatedACRWithNewRole.add(acr);
                    //}
                }

                system.debug(updatedACRWithNewRole);
                
                if(!updatedACRWithNewRole.isEmpty()){

                    UpdatePrimaryContact(newItems);
                    //decision maker rel was removed on Account.
                    RemovePrimaryContact(newItems,false);
                }

            }
        }
    }


    public static void AccountContactRelationRolecreate(List<AccountContactRelation> acrList) {
        Set<Id> contactIds = new Set<Id>();

        for(AccountContactRelation acr  :   acrList){
            contactIds.add(acr.contactId); 
        }

        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id , role__c FROM Contact WHERE ID IN :contactIds]);

        for(AccountContactRelation acr  : acrList){
            acr.Roles  = contactMap.get(acr.contactId).role__c;   
        }   
      
    }
    
    public static void UpdatePrimaryContact(List<AccountContactRelation> acrList){
        Map<id,AccountContactRelation> accountMap               = new Map<id,AccountContactRelation>();
        Map<string,AccountContactRelation> newDecisionMakerMap  = new Map<string,AccountContactRelation>();
        Set<id> AccountIds                                      = new Set<id>();

        for(AccountContactRelation acr : acrList){
            if(acr.Roles!=null){
                if(acr.Roles.contains(ACCOUNTCONTACT_DM_ROLE)){
                    accountMap.put(acr.AccountId, acr);
                    newDecisionMakerMap.put(acr.AccountId + '-' + acr.ContactId, acr);
                    accountIds.add(acr.AccountId);
                }
            }
        }

        if(!accountIds.isEmpty()){
            List<Account> accToBeUpdated = [SELECT Primary_Contact__c from Account WHERE id IN :accountIds];

            for(Account a   : accToBeUpdated){
                a.Primary_Contact__c = accountMap.get(a.id).ContactId;
            }

            if(!accToBeUpdated.isEmpty()){
                update accToBeUpdated;
                
                UpdatePreviousDecisionMaker(AccountIds,newDecisionMakerMap);
            }
        }
    }

    public static void UpdatePreviousDecisionMaker(Set<id> AccountIds, Map<string,AccountContactRelation> newDecisionMakerMap){

        List<AccountContactRelation> oldDecisionMakers      = [SELECT Roles, accountid,contactid FROM AccountContactRelation
                                                                WHERE accountID IN :AccountIds
                                                                AND Roles INCLUDES (:ACCOUNTCONTACT_DM_ROLE)];

        List<AccountContactRelation> accContactToBeUpdated  = new List<AccountContactRelation>();
        
        if(!oldDecisionMakers.isEmpty()){

            for(AccountContactRelation acrOld : oldDecisionMakers){

                if(!newDecisionMakerMap.ContainsKey(acrOld.accountId + '-' + acrOld.contactId)){//exclude new decisionmaker

                    String[] roleList   = acrOld.Roles.split(';');
                    String newRole      = '';

                    for(String role :   roleList){
                        if(!role.equals(ACCOUNTCONTACT_DM_ROLE)){
                            newRole     += role + '; ';                            
                        }
                    }
                    acrOld.roles = newRole;
                    accContactToBeUpdated.add(acrOld);
                }
            }

            if(!accContactToBeUpdated.isEmpty()){
                update accContactToBeUpdated;
            }            
        }                                                       
    }
    
    public static void RemovePrimaryContact(List<AccountContactRelation> acrNewList, Boolean isDelete){

        Map<id,AccountContactRelation> accountACRMap            = new Map<id,AccountContactRelation>();

        for(AccountContactRelation acr  : acrNewList){
            if(acr.Roles!=null){
                if(isDelete){
                    accountACRMap.put(acr.AccountId, acr);
                }else{
                    if(!acr.Roles.contains(ACCOUNTCONTACT_DM_ROLE)){
                        accountACRMap.put(acr.AccountId, acr);
                    }
                }
            }
        }

        Map<id,AccountContactRelation> accountWithDecisionMaker = new Map<id,AccountContactRelation>();

        for(AccountContactRelation acr  : [SELECT Roles, accountid, contactid FROM AccountContactRelation 
                                                        WHERE accountID IN :accountACRMap.keySet()
                                                        AND Roles INCLUDES (:ACCOUNTCONTACT_DM_ROLE)]){
            accountWithDecisionMaker.put(acr.accountid,acr);                                                
        }
    
        List<Account> accountToBeUpdated = new List<Account>();

        for(Account acc : [SELECT Primary_Contact__c FROM Account WHERE id IN :accountACRMap.keySet() AND Primary_Contact__c != null]){
            if(!accountWithDecisionMaker.containsKey(acc.id)){
                acc.Primary_Contact__c  = null;
                accountToBeUpdated.add(acc);
            }
        }
        
        if(!accountToBeUpdated.isEmpty()){
            update accountToBeUpdated;
        }
        
        
        
    }
}