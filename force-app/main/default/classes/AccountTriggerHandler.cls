public with sharing class AccountTriggerHandler {

    public static void execute(){
        if(Trigger.isAfter){
            if(Trigger.isUpdate){
                updateOrderPrimaryContact(Trigger.New);
                
            }
        }
    }

    public static void updateOrderPrimaryContact(List<Account> accountList){

        List<Order> orderToUpdateList       = new List<Order>();
        Set<Id> accountIds                  = new Set<Id>();

        for(Account acc : accountList){
            accountIds.add(acc.Id);
        }

        List<Order> linkedOrderList = [SELECT Id, Primary_Contact__c, AccountId FROM Order WHERE AccountId =: accountIds];

        for(Account acc : accountList){
            for(Order linkedOrder : linkedOrderList){
                if(linkedOrder.AccountId == acc.Id && acc.Primary_Contact__c  != linkedOrder.Primary_Contact__c){
                    linkedOrder.Primary_Contact__c  = acc.Primary_Contact__c;
                    orderToUpdateList.add(linkedOrder);
                }

            }
            
        }

        Database.update(orderToUpdateList);

    }
}
