/**
* @author Amitkumar Joshi
* @date 07/2/2017
*
*
* @description A trigger on Project_Timesheet__c object. Once new timesheet is generated, share it will all related project members.
* Also link this timesheet record with time entry and project records.
*/
trigger TW_ProjectTimesheetTrigger on Project_Timesheet__c (before insert, before update, before delete, after insert, after update, after delete) {
    // Retrive the flag to Check if this trigger should be executed or not
    TimeWatch__Trigger_Settings__c projectTimesheetTriggerSetting = TimeWatch__Trigger_Settings__c.getValues('TimeWatch__Project_Timesheet__c');
    // create trigger handler and process the business logic
    if(projectTimesheetTriggerSetting != null && projectTimesheetTriggerSetting.TimeWatch__Active__c){
        TW_TriggerFactory.createHandler(Project_Timesheet__c.sObjectType); 
    } 
}