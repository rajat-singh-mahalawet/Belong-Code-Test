trigger AccountContactRelationTrigger on AccountContactRelation (before insert,after insert,before update,after update,before delete, after delete,after undelete) {
    AccountContactRelationTriggerHandler.execute();
}