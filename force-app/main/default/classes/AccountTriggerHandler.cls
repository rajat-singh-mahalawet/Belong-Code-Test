public with sharing class AccountTriggerHandler {

    public static void execute(){
        if(Trigger.isAfter){
            if(Trigger.isUpdate){

                List<Account> updatedAccPrimaryContact              = new List<Account>();
                List<Account> oldUpdatedAccList                     = new List<Account>();
                Map<Id, Account> oldItemsAccMap                     = (Map<Id, Account>)(Trigger.oldMap);             
                List<Account> newItems                              = Trigger.new;

                for(Account accNew  : newItems){
                    //String.isNotBlank(accNew.Primary_Contact__c) &&
                    if( accNew.Primary_Contact__c != oldItemsAccMap.get(accNew.id).Primary_Contact__c){
                        updatedAccPrimaryContact.add(accNew);
                        oldUpdatedAccList.add(oldItemsAccMap.get(accNew.id));
                    }
                }

                if(!updatedAccPrimaryContact.isEmpty()){

                updateAccountContactRelationship(oldUpdatedAccList,updatedAccPrimaryContact);

                updateOrderPrimaryContact(updatedAccPrimaryContact);
                }
                
            }
        }
    }

    public static void updateAccountContactRelationship(List<Account> AccoutListOld, List<Account> AccountListNew){
        Set<Id> contactIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();

        for (Account accOld : AccoutListOld){
            if(accOld.Primary_Contact__c != null){
                contactIds.add(accOld.Primary_Contact__c);
                accountIds.add(accOld.Id);
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

        for (Account accNew : AccountListNew){
            if(accNew.Primary_Contact__c != null){
                contactIds.add(accNew.Primary_Contact__c);
                accountIds.add(accNew.Id);
            }
        }

        Map<Id,Contact> contactRolesMap                      = new Map<Id, Contact>([SELECT Id, Role__c FROM Contact WHERE Id IN :contactIds]);
        List<AccountContactRelation> newDecisionMakers      = [SELECT Roles, accountid,contactid FROM AccountContactRelation
                                                                WHERE accountID IN :accountIds
                                                                AND contactID IN : contactIds
                                                                AND Roles EXCLUDES ('Decision Maker')];
        
        if(!newDecisionMakers.isEmpty()){

            for(AccountContactRelation acrNew : newDecisionMakers){
                //String roleList   = acrNew.Roles.split(';');
                String newRole      = acrNew.Roles;

                if(String.isNotBlank(newRole)){
                    newRole += '; ';
                }

                for (String conRole : (contactRolesMap.get(acrNew.ContactId).Role__c).split(';') ){

                    if(!newRole.contains(conRole)){
                        newRole     += conRole + '; ';                            
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

    public static void updateOrderPrimaryContact(List<Account> accountList){

        List<Order> orderToUpdateList       = new List<Order>();
        Set<Id> accountIds                  = new Set<Id>();

        for(Account acc : accountList){
            //if(acc.Primary_Contact__c != null){
                accountIds.add(acc.Id);
            //}
        }

        List<Order> linkedOrderList = [SELECT Id, Primary_Contact__c, AccountId FROM Order WHERE AccountId IN :accountIds];

        for(Account acc : accountList){
            for(Order linkedOrder : linkedOrderList){
                if(linkedOrder.AccountId == acc.Id && acc.Primary_Contact__c  != linkedOrder.Primary_Contact__c){
                    linkedOrder.Primary_Contact__c  = acc.Primary_Contact__c;
                    orderToUpdateList.add(linkedOrder);
                }

            }
            
        }

        if(orderToUpdateList.size() > 0){
            Database.update(orderToUpdateList);
        }

    }
}