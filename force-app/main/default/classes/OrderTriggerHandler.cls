public with sharing class OrderTriggerHandler {

    public static void execute(){
        if(Trigger.isBefore){
            if(Trigger.isInsert){
                linkPrimaryContact(Trigger.New);
                
            }

        }

    }

    private static void linkPrimaryContact(List<Order> orderList){

        Set<Id> accountIds                  = new Set<Id>();
        for(Order o : orderList){
            accountIds.add(o.AccountId);
        }

        List<Account> linkedAccounts = [SELECT Id, Primary_Contact__c FROM Account where Id =: accountIds];

        for (Order o : orderList){
            for(Account linkedaccount: linkedAccounts){
                if(o.AccountId != null && o.AccountId == linkedaccount.Id){
                    o.Primary_Contact__c = linkedaccount.Primary_Contact__c;
                }
            }
        }

    }

}
