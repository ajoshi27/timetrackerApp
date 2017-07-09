/**
* @author Amitkumar Joshi
* @date 06/18/2017
*
*
* @description It contains the helper and utility methods for TimeWatch__Project_Task__c  object trigger.
* these methods will be called from TW_ProjectTaskTriggerHandler.class. It has method
*  to share task records with project manager and other member of the projects.
*/
public class TW_ProjectTaskTriggerHelper {
   /**
    * @description Share new task records with project manager and project members. Project manager should have an edit access to all new tasks related to the project. 
    * Give other members to read access to all new tasks. Apex managed sharing is used to share the record.This method will be called from 
    *  TimeWatch__Project_Task__c after insert trigger, whenever new  task is created.
    * 
    * @param projectTaskList  List of new TimeWatch__Project_Task__c records.
    * 
    * @return void
    */
     public static void shareRecordsWithProjectMember(List<TimeWatch__Project_Task__c> projectTaskList){
         System.debug('TW_ProjectTaskTriggerHelper, shareRecordsWithProjectMember(), start');
         List<Id> projectIdList = new List<Id>();
         
         // task share list to be created for each member of the project
         List<TimeWatch__Project_Task__Share> taskShareList = new List<TimeWatch__Project_Task__Share>();
         
         // project member list with which the tasks to be shared.
         List<TimeWatch__Project_Member__c> projectMemberList = new List<TimeWatch__Project_Member__c>();
         
         //Iterate over all new tasks and create related project list
         for(TimeWatch__Project_Task__c task: projectTaskList){
             projectIdList.add(task.TimeWatch__Project__c);
         }
         
         // fetch all the the related projects and its members.
        List<TimeWatch__Project__c> projectList = [select Id, (select Id,TimeWatch__Role__c, TimeWatch__User__c from Project_Teams__r) from TimeWatch__Project__c where Id IN:projectIdList];
        
         // Iterate over project and create the list of members.
        for(TimeWatch__Project__c prj : projectList){
                projectMemberList.addall(prj.Project_Teams__r);
        }
         // Iterate over tasks and give access to project members.
        for(TimeWatch__Project_Task__c task: projectTaskList){
            for(TimeWatch__Project_Member__c projMember : projectMemberList){
                if(projMember.TimeWatch__User__c!=task.OwnerId){
                    TimeWatch__Project_Task__Share taskShare = new TimeWatch__Project_Task__Share();
                    taskShare.ParentID = task.Id;
                    
                    // If member is Manager then give edit access else give read access
                    if(projMember.TimeWatch__Role__c == 'Manager'){
                        taskShare.AccessLevel = 'Edit';
                    }else{
                        taskShare.AccessLevel = 'Read';
                    }
                    taskShare.RowCause = Schema.TimeWatch__Project_Task__Share.RowCause.Manual;
                    taskShare.UserOrGroupId = projMember.TimeWatch__User__c;
                    taskShareList.add(taskShare);
                }
            }
        }
         // insert tasks share list in to database.
        if(taskShareList.size()>0){
            insert taskShareList;
        }  
         System.debug('TW_ProjectTaskTriggerHelper, shareRecordsWithProjectMember(), end');
     }

}