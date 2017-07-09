/**
* @author Amitkumar Joshi
* @date 07/2/2017
*
*
* @description A trigger on Project_Member__c object. Once new project member is added to project, it will give access to related
* tasks, time entires to this new member.
*/
trigger TW_ProjectMemberTrigger on Project_Member__c (before insert, before update, before delete, after insert, after update, after delete) {
    
    // Retrive the flag to Check if this trigger should be executed or not
    TimeWatch__Trigger_Settings__c projectMemberTriggerSetting = TimeWatch__Trigger_Settings__c.getValues('TimeWatch__Project_Member__c');
    
    // create trigger handler and process the business logic
    if(projectMemberTriggerSetting != null && projectMemberTriggerSetting.TimeWatch__Active__c){
        TW_TriggerFactory.createHandler(Project_Member__c.sObjectType); 
    } 
}