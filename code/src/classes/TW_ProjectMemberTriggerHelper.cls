/**
* @author Amitkumar Joshi
* @date 06/20/2017
*
*
* @description It contains the helper and utility methods for TimeWatch__Project_Member__c  object trigger.All
*  This method will be called from TW_ProjectMemberTriggerHandler.class. Every time new Project Member has been
* Added, methods of this class will fire. It has method to share  project related time entries, timesheet, tasks with this new member.
* If new member is 'Manager' then update related project record with manager details.
*/
public class TW_ProjectMemberTriggerHelper {
    
   /**
    * @description Whenever new project member is added to a project, share project related tasks, time entries and timesheet with it.
    * This method will be called from TimeWatch__Project_Member__c trigger, whenever new member is added or updated.
    * @param projectMemberList List of TimeWatch__Project_Member__c records.
    * @return void
    */
    public static void shareRecordsWithProjectMember(List<TimeWatch__Project_Member__c> projectMemberList){
        System.debug('TW_ProjectMemberTriggerHelper shareRecordsWithProjectMember(), start');
        List<Id> projectIdList = new List<Id>();
        List<Id> taskIdList = new List<Id>();
        
        // List of timesheet related to this project which need to be shared with new project member
        List<TimeWatch__Project_Timesheet__c>  timesheetList = new List<TimeWatch__Project_Timesheet__c>();
        
        // A map of project Id to it's related project members
        Map<Id,List<TimeWatch__Project_Member__c>> projIdToProjMemberMap = new Map<Id,List<TimeWatch__Project_Member__c>>();
        
        // Iterate over newly added project members and create the list of related projects
        for(TimeWatch__Project_Member__c projMember : projectMemberList){
            // create list of projects.
            projectIdList.add(projMember.TimeWatch__Project__c);
        }
        // Fetch all projects with it's timesheets and tasks.
        List<TimeWatch__Project__c> projectList = [select Id, ownerId, (select Id, OwnerId from Project_Tasks__r), (select Id,OwnerId from Project_Timesheets__r) from TimeWatch__Project__c where Id IN:projectIdList];
       
        
        // Share project record with read access to members. If new user is manager then give edit access on project.
        createProjectShare(projectMemberList, projectList, projIdToProjMemberMap);
        
        // if new user is manager then update it on Project record
        updateProjectManagerOnProject(projectMemberList,projectIdList);
        
        // Share project task records with read access to project members. If new user is manager then give read/edit access to Manager.
        createTaskShareRecords(projectMemberList, projectList, projIdToProjMemberMap,taskIdList,timesheetList);
        
        // If new user is manager then Share All Time Entry records with Manager.
        createTimeEntryShare(projectMemberList,taskIdList);
        
        // If new user is manager then Share All project timesheet with Manager.
        createTimesheetShare(projectMemberList,timesheetList);
        System.debug('TW_ProjectMemberTriggerHelper shareRecordsWithProjectMember(), end');
    }
    
     /**
    * @description Whenever new project member is added to a project, check if this member is 'Manager'. if it then update it's 
    * value of related project field TimeWatch__Project_Manager__c
    * 
    * @param projectMemberList List of TimeWatch__Project_Member__c records.
    * @param projectIdList List of projectId.
    * @return void
    */
    private static void updateProjectManagerOnProject(List<TimeWatch__Project_Member__c> projectMemberList,List<Id> projectIdList){
        System.debug('TW_ProjectMemberTriggerHelper updateProjectManagerOnProject(), start');
        
        // Map of projectid and it's related Manager
        Map<String,String> projectIdToManagerUserMap = new Map<String,String>();
        List<TimeWatch__Project__c> prjTOUpdate = new List<TimeWatch__Project__c>();
        
        // Iterate over newly inserted project member and find out the manager user
        for(TimeWatch__Project_Member__c projMember : projectMemberList){
           
            if(projMember.TimeWatch__Role__c == 'Manager'){
            	projectIdToManagerUserMap.put(projMember.TimeWatch__Project__c,projMember.TimeWatch__User__c);
            }
        }
      
        // Iterage over all projects and for each project, update the manager user value.
        for(Id prjId : projectIdList){
            
            if(projectIdToManagerUserMap.get(prjId)!=null){
                TimeWatch__Project__c prj = new TimeWatch__Project__c(Id=prjId, TimeWatch__Project_Manager__c=projectIdToManagerUserMap.get(prjId));
                prjTOUpdate.add(prj);
            }
        }
        
        // update the project record list
        if(prjTOUpdate.size()>0){
            update prjTOUpdate;
        }
        System.debug('TW_ProjectMemberTriggerHelper updateProjectManagerOnProject(), end');
    }
    
     /**
    * @description Whenever new project member is added to a project, share related project record with it.
    *  if it is manager, give edit access otherwise give read access. Records will be shared using Apex managed sharing.
    * 
    * @param projectMemberList List of TimeWatch__Project_Member__c records.
    * @param projectList List of projectId.
    * @param projIdToProjMemberMap A Map of project and it's related members.
    * 
    * @return void
    */
    private static void createProjectShare(List<TimeWatch__Project_Member__c> projectMemberList,List<TimeWatch__Project__c> projectList , Map<Id,List<TimeWatch__Project_Member__c>> projIdToProjMemberMap){
                                               
        System.debug('TW_ProjectMemberTriggerHelper createProjectShare(), start');
                                               
        Map<Id, TimeWatch__Project__c> projectIdToProjectMap = new Map<Id, TimeWatch__Project__c>();
        
        // Iterate over all the projects and create a map of project to it's related members                                       
		for(TimeWatch__Project__c prj : projectList){
            projectIdToProjectMap.put(prj.Id, prj);
        }
        
        // List of project share records.
		List<TimeWatch__Project__Share> projectShareList = new List<TimeWatch__Project__Share>();
                                               
        // Share project record with read access to members and Edit access to Manager
        for(TimeWatch__Project_Member__c projMember : projectMemberList){
            
            If(projectIdToProjectMap.get(projMember.TimeWatch__Project__c)!=null 
                   && projMember.TimeWatch__User__c != projectIdToProjectMap.get(projMember.TimeWatch__Project__c).ownerId){
                
                TimeWatch__Project__Share prjShare = new TimeWatch__Project__Share();
                prjShare.ParentID = projMember.TimeWatch__Project__c;
                
                // if it is manager user, give edit access else read access       
                if(projMember.TimeWatch__Role__c == 'Manager'){
                    prjShare.AccessLevel = 'Edit';
                }else if(projMember.TimeWatch__Role__c != 'Manager'){
                    prjShare.AccessLevel = 'Read';
                }
                prjShare.RowCause = Schema.TimeWatch__Project__Share.RowCause.Manual;
                prjShare.UserOrGroupId = projMember.TimeWatch__User__c;
                
                projectShareList.add(prjShare);
        	}
            
            List<TimeWatch__Project_Member__c> prjMemList = null;
            
            if(projIdToProjMemberMap.get(projMember.TimeWatch__Project__c)!=null){
                prjMemList = projIdToProjMemberMap.get(projMember.TimeWatch__Project__c);
            }else{
                prjMemList = new List<TimeWatch__Project_Member__c>();
            }
            prjMemList.add(projMember);
            // create the map of project Id to its member. this Map will be used while sharing tasks and time entries.
            projIdToProjMemberMap.put(projMember.TimeWatch__Project__c, prjMemList);
        }
        // insert prject share records
        if(projectShareList.size()>0){
            insert projectShareList;
        }
        System.debug('TW_ProjectMemberTriggerHelper createProjectShare(), end');
    }
    
   /**
    * @description Whenever new project member is added to a project, share related task records with it.
    *  if it is manager, give edit access otherwise give read access. Records will be shared using Apex managed sharing.
    * 
    * @param projectMemberList List of TimeWatch__Project_Member__c records.
    * @param projectList List of projectId.
    * @param projIdToProjMemberMap A Map of project and it's related members.
    * @param taskIdList A list of tasks related to this project.
    * @param timesheetList A list of timesheet related to this project.
    * 
    * @return void
    */
    private static void createTaskShareRecords(List<TimeWatch__Project_Member__c> projectMemberList,List<TimeWatch__Project__c> projectList, Map<Id,List<TimeWatch__Project_Member__c>> projIdToProjMemberMap,List<Id> taskIdList,List<TimeWatch__Project_Timesheet__c>  timesheetList){
        
        System.debug('TW_ProjectMemberTriggerHelper, createTaskShareRecords(), start');
        // List of taskshare records which need to be inserted.
		List<TimeWatch__Project_Task__Share> taskShareList = new List<TimeWatch__Project_Task__Share>();                                   
        
        // Iterate over all projects, find out related tasks and share with newly added project members.
        for(TimeWatch__Project__c prj : projectList){
             
            // Share project task records with read access to users and read/edit access to manager
            if(prj.Project_Tasks__r.size()>0){
                
                for(TimeWatch__Project_Task__c prjTask : prj.Project_Tasks__r){
                  
                    List<TimeWatch__Project_Member__c> prjMemList = projIdToProjMemberMap.get(prj.Id);
                    
                    if(prjMemList!=null && prjMemList.size()>0){
                        for(TimeWatch__Project_Member__c projMember : prjMemList){
                            if(projMember.TimeWatch__User__c!=prjTask.OwnerId){
                                TimeWatch__Project_Task__Share taskShare = new TimeWatch__Project_Task__Share();
                                taskShare.ParentID = prjTask.Id;
                                if(projMember.TimeWatch__Role__c == 'Manager'){
                                    taskShare.AccessLevel = 'Edit';
                                }else{
                                    taskShare.AccessLevel = 'Read';
                                }
                                taskShare.RowCause = Schema.TimeWatch__Project__Share.RowCause.Manual;
                                taskShare.UserOrGroupId = projMember.TimeWatch__User__c;
                                taskShareList.add(taskShare);
                        	}
                        }
                    }
                    taskIdList.add(prjTask.Id);
                    
                }
        	}
           
            if(prj.Project_Timesheets__r.size()>0){
            	timesheetList.add(prj.Project_Timesheets__r);
            }
        }
        
        if(taskShareList.size()>0){
            insert taskShareList;
        }  
		System.debug('TW_ProjectMemberTriggerHelper, createTaskShareRecords(), end');
   	}
    
     /**
    * @description Whenever new project member is added to a project, share related time entry records with it.
    *  if it is manager, give edit access. Records will be shared using Apex managed sharing.
    * 
    * @param projectMemberList List of TimeWatch__Project_Member__c records.
    * @param taskIdList A list of tasks related to this project.
    * 
    * @return void
    */
    private static void createTimeEntryShare(List<TimeWatch__Project_Member__c> projectMemberList, List<Id> taskIdList){
        System.debug('TW_ProjectMemberTriggerHelper, createTimeEntryShare(), start');
        
        // fetch all tasks with related time entries
        List<TimeWatch__Project_Task__c> taskList = [select Id, (select Id,OwnerId  from Time_Entries__r) from TimeWatch__Project_Task__c where Id IN:taskIdList];
        List<TimeWatch__Project_Time_Entry__Share> timeEntryShareList = new List<TimeWatch__Project_Time_Entry__Share>();
        
        // iterate over tasks and share related time entries with manager user.
        for(TimeWatch__Project_Task__c task : taskList ){
            
            if(task.Time_Entries__r.size()>0){
                
                for(TimeWatch__Project_Time_Entry__c timeEntry : task.Time_Entries__r){
                 
                    if(projectMemberList!=null && projectMemberList.size()>0){ 
                       for(TimeWatch__Project_Member__c projMember : projectMemberList){
                            
                           // Share record only if it is manager
                            if(projMember.TimeWatch__Role__c == 'Manager' && projMember.TimeWatch__User__c !=timeEntry.OwnerId ){
                                TimeWatch__Project_Time_Entry__Share timeEntryShare = new TimeWatch__Project_Time_Entry__Share();
                                timeEntryShare.ParentID = timeEntry.Id;
                                timeEntryShare.AccessLevel = 'Edit';
                                timeEntryShare.RowCause = Schema.TimeWatch__Project_Time_Entry__Share.RowCause.Manual;
                                timeEntryShare.UserOrGroupId = projMember.TimeWatch__User__c;
                                timeEntryShareList.add(timeEntryShare);
                            }
                       }
                   }
                }
        	}
        }
        
        // insert share records
        if(timeEntryShareList.size()>0){
            insert timeEntryShareList;
        }
        System.debug('TW_ProjectMemberTriggerHelper, createTimeEntryShare(), end');
    }
    
    /**
    * @description Whenever new project member is added to a project, share related timesheet records with it.
    *  if it is manager, give edit access. Records will be shared using Apex managed sharing.
    * 
    * @param projectMemberList List of TimeWatch__Project_Member__c records.
    * @param timesheetList A list of timesheet related to this project.
    * 
    * @return void
    */
    private static void createTimesheetShare(List<TimeWatch__Project_Member__c> projectMemberList,List<TimeWatch__Project_Timesheet__c>  timesheetList){
        System.debug('TW_ProjectMemberTriggerHelper, createTimesheetShare(), start');
        
        // list of timesheet share records which need to be inserted
        List<TimeWatch__Project_Timesheet__Share> timesheetShareList = new List<TimeWatch__Project_Timesheet__Share>();
        if(timesheetList!=null && timesheetList.size()>0){
            // iterate over all timesheet records and share with manager user
            for(TimeWatch__Project_Timesheet__c timesheet :timesheetList){
                for(TimeWatch__Project_Member__c projMember : projectMemberList){
                        
                        if(projMember.TimeWatch__Role__c == 'Manager' && projMember.TimeWatch__User__c != timesheet.OwnerId){
                            TimeWatch__Project_Timesheet__Share timesheetShare = new TimeWatch__Project_Timesheet__Share();
                            timesheetShare.ParentID = timesheet.Id;
                            timesheetShare.AccessLevel = 'Edit';
                            timesheetShare.RowCause = Schema.TimeWatch__Project_Timesheet__Share.RowCause.Manual;
                            timesheetShare.UserOrGroupId = projMember.TimeWatch__User__c;
                            timesheetShareList.add(timesheetShare);
                        }
                   }
            }
        }
        System.debug('TW_ProjectMemberTriggerHelper, createTimesheetShare(), end');
    }                          
}