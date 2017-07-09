/**
* @author Amitkumar Joshi
* @date 06/16/2017
*
*
* @description It contains the helper and utility methods for TimeWatch__Project_Time_Entry__c  object trigger.All
*  This method will be called from TW_ProjectTimeEntryTriggerHandler.class. It has methods to calculate the invoice amount 
*  from total time spent, share time entry record with project manager and insert project time entry history record whenever
*  user start and stop the timer on tasks record.
*/
public class TW_ProjectTimeEntryTriggerHelper {
	
    /**
    * @description Calculate the total time spent in hours from milliseconds and invoice amont (time spent * hourly rate)
    * it will iterate over each time entry record and calculate the total ttime spent and invoice amount for each entry.
    * This method will be called from TimeWatch__Project_Time_Entry__c trigger, whenever new time entry is added or updated.
    * @param timeEntryList List of TimeWatch__Project_Time_Entry__c records.
    * @return void
    */
    public static void calculateTimeSpentNInvoiceAmt(List<TimeWatch__Project_Time_Entry__c> timeEntryList, Map<Id, TimeWatch__Project_Time_Entry__c> timeEntryOldMap){
		System.debug('TW_ProjectTimeEntryTriggerHelper, calculateTimeSpentNInvoiceAmt(), start');
        
        // A map containing project membes for each project. This map is used to find hourly rate for each project member.
        Map<String, Map<String,Double>> projectIdToTeamMemberMap = getprojectIdToTeamMemberMap(timeEntryList);
        
        // Iterate over list of time entries and calculate the time spent and invoice amount.
        for(TimeWatch__Project_Time_Entry__c timeEntry : timeEntryList){
            
            // Only entry whose status is stop should be considered for calculation. If timer is still running, no need to consider those entries.
            if(timeEntry.TimeWatch__Status__c=='Stop'){
                timeEntry.TimeWatch__Start_Time_Millis__c = timeEntry.TimeWatch__Start_Date__c.getTime();
                if(timeEntry.TimeWatch__End_Date__c!=null){
                	timeEntry.TimeWatch__Stop_Time_Millis__c = timeEntry.TimeWatch__End_Date__c.getTime();
                }else{
                    timeEntry.TimeWatch__Stop_Time_Millis__c = System.currentTimeMillis();
                }
                TimeWatch__Project_Time_Entry__c oldTimeEntry = (timeEntryOldMap!=null ? timeEntryOldMap.get(timeEntry.Id) : null);
                // calculate total time spent(in milliseconds) from stop watch stop time minus stop watch start time.
                if(oldTimeEntry==null || (oldTimeEntry!=null && (oldTimeEntry.TimeWatch__Stop_Time_Millis__c!= timeEntry.TimeWatch__Stop_Time_Millis__c || oldTimeEntry.TimeWatch__Start_Time_Millis__c!= timeEntry.TimeWatch__Start_Time_Millis__c))){
                	timeEntry.TimeWatch__Total_time_spent_Millis__c= timeEntry.TimeWatch__Total_time_spent_Millis__c + (timeEntry.TimeWatch__Stop_Time_Millis__c - timeEntry.TimeWatch__Start_Time_Millis__c);
                }
                timeEntry.TimeWatch__Total_Time_in_hours__c = TW_StopwatchUtil.convertMillsToHours(Integer.valueOf(timeEntry.TimeWatch__Total_time_spent_Millis__c));
                Id prjId = timeEntry.TimeWatch__Project_id__c;
                Id userId = (timeEntry.CreatedById!=null? timeEntry.CreatedById : UserInfo.getUserId());
                
                //find out project member details for this time entry to check the hourly rate.
                Map<String,Double> teamMember = projectIdToTeamMemberMap.get(prjId);
                
                if(teamMember!=null){
                    Double hourlyRate = (teamMember.get(userId)==null? 0: Double.valueof(teamMember.get(userId)));
                    // calculate invoice amount (timespent * hourly rate)
                    timeEntry.TimeWatch__Invoice_Amount__c = TW_StopwatchUtil.calculateInvoicedAmount(
                        Double.valueof(timeEntry.TimeWatch__Total_time_spent_Millis__c) ,hourlyRate);
                }
            }
           
        }
        System.debug('TW_ProjectTimeEntryTriggerHelper, calculateTimeSpentNInvoiceAmt(), end');
    }
    
    /**
    * @description Insert TimeWatch__Project_Time_Entry_History__c record whenever TimeWatch__Project_Time_Entry__c record
    *  is added or updated. This method will be called from TimeWatch__Project_Time_Entry__c trigger, whenever new time entry is added or updated.  
    *  it will copy time start date, time stop date, invoice amount, timespent details from TimeWatch__Project_Time_Entry__c to 
    *  TimeWatch__Project_Time_Entry_History__c record and insert it. These time history records will be useful when we have to show the 
    * daywise breakup of time spent on project by the user.
    * 
    * @param timeEntryList List of TimeWatch__Project_Time_Entry__c records.
    * @param timeEntryOldMap 
    * @return void
    */
    public static void insertProjectTimeEntryHistory(List<TimeWatch__Project_Time_Entry__c> timeEntryList, Map<Id, TimeWatch__Project_Time_Entry__c> timeEntryOldMap){
                                                         
        System.debug('TW_ProjectTimeEntryTriggerHelper, insertProjectTimeEntryHistory(), start');
        
        // Find out all time entries and related time entry history records.                                                  
        List<TimeWatch__Project_Time_Entry__c> tempTimeEntryList =[select Id, (select Id, TimeWatch__Start_Date__c,TimeWatch__End_Date__c,TimeWatch__Total_Time_Spent__c from Project_Time_Entry_Histories__r) from TimeWatch__Project_Time_Entry__c where Id IN:timeEntryList];
        
        // Create map of project Id and related project members using each time entry.
        Map<String, Map<String,Double>> projectIdToTeamMemberMap = getprojectIdToTeamMemberMap(timeEntryList);
        
        // Time entry history records to be inserted
        List<TimeWatch__Project_Time_Entry_History__c> insertProjectTimeEntryHistoryList = new  List<TimeWatch__Project_Time_Entry_History__c>();
        // Time entry history records to be updated
        List<TimeWatch__Project_Time_Entry_History__c> updateProjectTimeEntryHistoryList = new  List<TimeWatch__Project_Time_Entry_History__c>();
        
        for(TimeWatch__Project_Time_Entry__c timeEntry: timeEntryList){
            TimeWatch__Project_Time_Entry__c oldTimeEntry = (timeEntryOldMap!=null?timeEntryOldMap.get(timeEntry.Id):null);
           
            if(timeEntry.TimeWatch__Status__c=='Stop'){
                if(oldTimeEntry!=null){ // when user stop the timer using Timer component on Task or when manually edit the Time entry record.
                    
                    /* If user updated the existing time entry and reduce the time spent then there is no need to insert new TimeWatch__Project_Time_Entry_History__c. Only update
                    existing one*/
                    if(timeEntry.TimeWatch__Total_time_spent_Millis__c < oldTimeEntry.TimeWatch__Total_time_spent_Millis__c){
                        // Update existing time Entry History record related to this Time Entry.
                        if(timeEntry.Project_Time_Entry_Histories__r.size()>0){
                            TimeWatch__Project_Time_Entry_History__c projectTimeEntryHistory = populateTimeEntryHistFromTimeEntry(
                            timeEntry, timeEntry.Project_Time_Entry_Histories__r.get(0),projectIdToTeamMemberMap);
                        
                            updateProjectTimeEntryHistoryList.add(projectTimeEntryHistory);
                    	}
                    }else if(timeEntry.TimeWatch__Status__c != oldTimeEntry.TimeWatch__Status__c){ // when user stop the running timer on task record.
                        // create new time Entry History record.
                        TimeWatch__Project_Time_Entry_History__c projectTimeEntryHistory = populateTimeEntryHistFromTimeEntry(
                        timeEntry, null,projectIdToTeamMemberMap);
                    
                        projectTimeEntryHistory.TimeWatch__Project_Time_Entry__c = timeEntry.Id;
                        insertProjectTimeEntryHistoryList.add(projectTimeEntryHistory);
                    }
                    
                }else{  // when user insert the new time entry manually.
                    // create new time Entry History record.
                    TimeWatch__Project_Time_Entry_History__c projectTimeEntryHistory = populateTimeEntryHistFromTimeEntry(
                    timeEntry, null,projectIdToTeamMemberMap);
                
                    projectTimeEntryHistory.TimeWatch__Project_Time_Entry__c = timeEntry.Id;
                    insertProjectTimeEntryHistoryList.add(projectTimeEntryHistory);
                }
                
            }
            
        }
       
        // Commit new Time Entry History records to database
        if(insertProjectTimeEntryHistoryList.size()>0){
            insert insertProjectTimeEntryHistoryList;
        }
        
        // Commit update on existing Time Entry History records to database
        if(updateProjectTimeEntryHistoryList.size()>0){
            update updateProjectTimeEntryHistoryList;
        }
        System.debug('TW_ProjectTimeEntryTriggerHelper, insertProjectTimeEntryHistory(), end');
    }
    
    /**
    * @description populate TimeWatch__Project_Time_Entry_History__c record details from TimeWatch__Project_Time_Entry__c
    * record.This method will be called from TimeWatch__Project_Time_Entry__c trigger, whenever new time entry is added or updated.
    * @param timeEntry existing TimeWatch__Project_Time_Entry__c record.
    * @param projectTimeEntryHistory An existing or new TimeWatch__Project_Time_Entry_History__c record.
    * @param projectIdToTeamMemberMap  A map of project id to it's project members.
    * 
    * @return TimeWatch__Project_Time_Entry_History__c  a time entry history record to be inserted/updated in database.
    */
    private static TimeWatch__Project_Time_Entry_History__c populateTimeEntryHistFromTimeEntry(
        TimeWatch__Project_Time_Entry__c timeEntry,TimeWatch__Project_Time_Entry_History__c projectTimeEntryHistory
        ,Map<String, Map<String,Double>> projectIdToTeamMemberMap){
        
		System.debug('TW_ProjectTimeEntryTriggerHelper, populateTimeEntryHistFromTimeEntry(), start');
        
        // initiate time entry history record. It will come as a null when new history record need to be created. possible scenario is every time
        //  timer is stopped from task or manually insert new time entry record.    
        if(projectTimeEntryHistory==null){
            projectTimeEntryHistory = new TimeWatch__Project_Time_Entry_History__c();
        }
        
        projectTimeEntryHistory.TimeWatch__Start_Date__c = timeEntry.TimeWatch__Start_Date__c;
        projectTimeEntryHistory.TimeWatch__End_Date__c = timeEntry.TimeWatch__End_Date__c;
        projectTimeEntryHistory.TimeWatch__Total_Time_Spent__c = timeEntry.TimeWatch__End_Date__c.getTime() - timeEntry.TimeWatch__Start_Date__c.getTime();
        Id prjId = timeEntry.TimeWatch__Project_id__c;
        Id userId = (timeEntry.CreatedById!=null? timeEntry.CreatedById : UserInfo.getUserId());
        
        Map<String,Double> teamMember = projectIdToTeamMemberMap.get(prjId);
        
        if(teamMember!=null){
			Double hourlyRate = (teamMember.get(userId)==null? 0: Double.valueof(teamMember.get(userId)));
			
            // calculate invoice amount for this history record.
            projectTimeEntryHistory.TimeWatch__Invoice_Amount__c = TW_StopwatchUtil.calculateInvoicedAmount(
                Double.valueof(projectTimeEntryHistory.TimeWatch__Total_Time_Spent__c) ,hourlyRate);
        }
        
        System.debug('TW_ProjectTimeEntryTriggerHelper, populateTimeEntryHistFromTimeEntry(), end');
        return projectTimeEntryHistory;
    }
    
   /**
    * @description using time entry records create the related project and its project members map.
    * This method will be called from TimeWatch__Project_Time_Entry__c trigger, whenever new time entry is added or updated.
    * @param timeEntryList  List of existing TimeWatch__Project_Time_Entry__c records.
    * 
    * @return Map<String, Map<String,Double>>  A map of project Id and related project member and it's hoursly rate.
    */
    private static Map<String, Map<String,Double>> getprojectIdToTeamMemberMap(List<TimeWatch__Project_Time_Entry__c> timeEntryList){
       
        System.debug('TW_ProjectTimeEntryTriggerHelper,getprojectIdToTeamMemberMap(), start ');
        
        List<String> projectIdList = new List<String>();
        
        // Iterate over all time entry records and create list of related projects.
        for(TimeWatch__Project_Time_Entry__c timeEntry : timeEntryList){
            projectIdList.add(timeEntry.TimeWatch__Project_id__c);
        }
        
        // Map of project Id and it's related project members. this map will be used to find the hourly rate of members.
        Map<String, Map<String,Double>> projectIdToTeamMemberMap = new Map<String, Map<String,Double>>();
        Map<String,Double> teamMemberMap = null;
        
        // find all projects and it's members related to this list of time entries.
        List<TimeWatch__Project__c> projects = [select Id, ( select Id, TimeWatch__Hourly_Rate__c,TimeWatch__User__c from TimeWatch__Project_Teams__r)  from TimeWatch__Project__c where Id IN:projectIdList];
        
        // iterate over the projects and create the map of project and its related members with their hourly rate.
        for(TimeWatch__Project__c project : projects){
            if(projectIdToTeamMemberMap.get(project.id)!=null){
                teamMemberMap = projectIdToTeamMemberMap.get(project.id);
            }else{
                teamMemberMap = new Map<String,Double> ();
            }
             for(TimeWatch__Project_Member__c teamMember : project.TimeWatch__Project_Teams__r){
                    teamMemberMap.put(teamMember.TimeWatch__User__c, teamMember.TimeWatch__Hourly_Rate__c);
             }
            projectIdToTeamMemberMap.put(project.id, teamMemberMap);
        }
        System.debug('TW_ProjectTimeEntryTriggerHelper,getprojectIdToTeamMemberMap(), stope ');
        return projectIdToTeamMemberMap;
    }
    
    /**
    * @description Share these time entry records with project manager. Project manager should have an access to all time entry
    * records of all users related to the project. Whenever new time entry record gets created, share with project manager and give edit access.
    * Apex managed sharing is used to share the record.This method will be called from TimeWatch__Project_Time_Entry__c after insert trigger, whenever new time entry is added.
    * @param timeEntryList  List of existing TimeWatch__Project_Time_Entry__c records.
    * 
    * @return void
    */
    public static void shareRecordsWithProjectMember(List<TimeWatch__Project_Time_Entry__c> timeEntryList){
        List<Id> projectIdList = new List<Id>();
        
        // timeEntryShareList which need to be inserted to share time entry records with manager.
        List<TimeWatch__Project_Time_Entry__Share> timeEntryShareList = new List<TimeWatch__Project_Time_Entry__Share>();
        List<TimeWatch__Project_Member__c> projectMemberList = new List<TimeWatch__Project_Member__c>();
        
        // create the list of projects associated with this time entry list
        for(TimeWatch__Project_Time_Entry__c timeEntry: timeEntryList){
             projectIdList.add(timeEntry.TimeWatch__Project_Id__c);
        }
         
         // fetch all the related projects of these time entries
        List<TimeWatch__Project__c> projectList = [select Id, (select Id,TimeWatch__User__c,TimeWatch__Role__c  from Project_Teams__r) from TimeWatch__Project__c where Id IN:projectIdList];
        
        for(TimeWatch__Project__c prj : projectList){
                projectMemberList.addAll(prj.Project_Teams__r);
        }
        
        // Iterate over time entry list and give access to manager 
        for(TimeWatch__Project_Time_Entry__c timeEntry: timeEntryList){
            for(TimeWatch__Project_Member__c projMember : projectMemberList){
                
                if(projMember.TimeWatch__Role__c == 'Manager' && projMember.TimeWatch__User__c!=timeEntry.OwnerId){
                    TimeWatch__Project_Time_Entry__Share timeEntryShare = new TimeWatch__Project_Time_Entry__Share();
                	timeEntryShare.ParentID = timeEntry.Id;
                    timeEntryShare.AccessLevel = 'Edit';
                    timeEntryShare.RowCause = Schema.TimeWatch__Project_Time_Entry__Share.RowCause.Manual;
                	timeEntryShare.UserOrGroupId = projMember.TimeWatch__User__c;
                	timeEntryShareList.add(timeEntryShare);
                }
                
            }
        }
        
        //insert the time entry share records.
        if(timeEntryShareList.size()>0){
            insert timeEntryShareList;
        }  
        
    }
}