/**
* @author Amitkumar Joshi
* @date 07/2/2017
*
*
* @description A trigger on Project_Task__c object. Once new task is added to project, share it will all related project members.
*/
trigger TW_ProjectTaskTrigger on Project_Task__c (before insert, before update, before delete, after insert, after update, after delete) {
    // Retrive the flag to Check if this trigger should be executed or not
    TimeWatch__Trigger_Settings__c projectTaskTriggerTriggerSetting = TimeWatch__Trigger_Settings__c.getValues('TimeWatch__Project_Task__c');
    
    // create trigger handler and process the business logic
    if(projectTaskTriggerTriggerSetting != null && projectTaskTriggerTriggerSetting.TimeWatch__Active__c){
        TW_TriggerFactory.createHandler(Project_Task__c.sObjectType); 
    } 
}