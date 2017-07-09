/**
* @author Amitkumar Joshi
* @date 07/2/2017
*
*
* @description A trigger on Project_Time_Entry__c object. Once new time entry is added to task, share it will all related project members.
* Also create new Project_Time_Entry_History__c record and link it with this time entry record.
*/
trigger TW_ProjectTimeEntryTrigger on Project_Time_Entry__c (before insert, before update, before delete, after insert, after update, after delete) {
    
    // Retrive the flag to Check if this trigger should be executed or not
    TimeWatch__Trigger_Settings__c projectTimeTriggerSetting = TimeWatch__Trigger_Settings__c.getValues('TimeWatch__Project_Time_Entry__c');
    
    // create trigger handler and process the business logic
    if(projectTimeTriggerSetting != null && projectTimeTriggerSetting.TimeWatch__Active__c){
        TW_TriggerFactory.createHandler(Project_Time_Entry__c.sObjectType); 
    }   

}