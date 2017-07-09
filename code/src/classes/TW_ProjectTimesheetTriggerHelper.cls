/**
* @author Amitkumar Joshi
* @date 06/18/2017
*
*
* @description It contains the helper and utility methods for TimeWatch__Project_Timesheet__c  object trigger.All
* This method will be called from TW_ProjectTimesheetTriggerHandler.class. It has method
*  to share timesheet record with project manager.
*/
public class TW_ProjectTimesheetTriggerHelper {
    
   /**
    * @description Share these timesheet records with project manager. Project manager should have an access to all timesheet
    * records of all users related to the project. Whenever new timesheet record gets created, share with project manager and give edit access.
    * Apex managed sharing is used to share the record.This method will be called from TimeWatch__Project_Timesheet__c after insert trigger, whenever new 
    * timesheet generated.
    * @param timesheetList  List of existing TimeWatch__Project_Timesheet__c records.
    * 
    * @return void
    */
	public static void shareRecordsWithProjectMember(List<TimeWatch__Project_Timesheet__c> timesheetList){
         System.debug('TW_ProjectTimesheetTriggerHelper shareRecordsWithProjectMember(), start');
        List<Id> projectIdList = new List<Id>();
        
        //List of timesheet share records which need to be inserted.
        List<TimeWatch__Project_Timesheet__Share> timesheetShareList = new List<TimeWatch__Project_Timesheet__Share>();
        List<TimeWatch__Project_Member__c> projectMemberList = new List<TimeWatch__Project_Member__c>();
        
        // Find all related project and create the list.
        for(TimeWatch__Project_Timesheet__c timesheet: timesheetList){
             projectIdList.add(timesheet.TimeWatch__Project__c);
        } 
         
         // fetch all the related projects
        List<TimeWatch__Project__c> projectList = [select Id, (select Id,TimeWatch__Role__c,TimeWatch__User__c from Project_Teams__r) from TimeWatch__Project__c where Id IN:projectIdList];
        
        for(TimeWatch__Project__c prj : projectList){
                projectMemberList.addAll(prj.Project_Teams__r);
        }
        
        // share timesheet records with Manager. Give edit access to them.
        for(TimeWatch__Project_Timesheet__c timesheet: timesheetList){
            for(TimeWatch__Project_Member__c projMember : projectMemberList){
                
                if(projMember.TimeWatch__Role__c == 'Manager' && projMember.TimeWatch__User__c !=timesheet.OwnerId){
                    TimeWatch__Project_Timesheet__Share timesheetShare = new TimeWatch__Project_Timesheet__Share();
                    timesheetShare.ParentID = timesheet.Id;
                    timesheetShare.RowCause = Schema.TimeWatch__Project_Timesheet__Share.RowCause.Manual;
                    timesheetShare.UserOrGroupId = projMember.TimeWatch__User__c;
                    timesheetShare.AccessLevel = 'Edit';
                    timesheetShareList.add(timesheetShare);
                }
                
            }
        }
        if(timesheetShareList.size()>0){
            insert timesheetShareList;
        }  
        System.debug('TW_ProjectTimesheetTriggerHelper shareRecordsWithProjectMember(), end');
    }
    
    
}