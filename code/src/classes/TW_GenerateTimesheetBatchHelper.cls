/**
* @author Amitkumar Joshi
* @date 07/2/2017
*
*
* @description A  helper class for TW_GenerateTimesheetBatch class. It contain the method to process the
* TimeWatch__Project_Time_Entry_History__c records created during last 7 days for all the users and create the timesheet for
* each user and save it to data base.
*/
public class TW_GenerateTimesheetBatchHelper {
    
    /**
    * @description iterate over TimeWatch__Project_Time_Entry_History__c records and populate the map of user and it's timesheet.
    * Populate the map of user and it's related TimeWatch__Project_Time_Entry__c records. these maps will be used to link timesheet Id to
    *  releated time entry records and to create the timesheet record for each user.
    * 
    * @param scope List of TimeWatch__Project_Time_Entry_History__c records to create the timesheet for each user
    * @param userToTimesheetMap  A map contain users and it's related timesheet record. it will be used to create timesheet record in finish method
    * @param userToTimeEntryListMap A map contain users and related time entry records. 
    * @param timeEntrySet A set contain unique list of time entry id related to  TimeWatch__Project_Time_Entry_History__c records.
    * 
    * @return void
    */
    public static void executeTimeSheetBatch(List<TimeWatch__Project_Time_Entry_History__c> scope
                                             , Map<String, TimeWatch__Project_Timesheet__c> userToTimesheetMap
                                             , Map<String,List<TimeWatch__Project_Time_Entry__c>>  userToTimeEntryListMap,Set<String>  timeEntrySet){
        
        System.debug('TW_GenerateTimesheetBatchHelper, executeTimeSheetBatch(), start' + scope);
         
        // Iterate over all time entry history records.
        for(TimeWatch__Project_Time_Entry_History__c timeEntryHist :scope ){
            
            Integer timeEntryHisttotalTime = Integer.valueOf((timeEntryHist.TimeWatch__Total_Time_Spent__c !=null ? timeEntryHist.TimeWatch__Total_Time_Spent__c : 0));
            
            // check if timesheet record for this entry's owner is already exists. if it exists then add this time entry hist record's total time spent and 
            // invoice amount to the timesheet's total time spent  and invoice amount values.
            if(userToTimesheetMap.get(timeEntryHist.CreatedById) !=null){
                TimeWatch__Project_Timesheet__c timesheet = userToTimesheetMap.get(timeEntryHist.CreatedById);
                
                 Double  timesheetTotalTime = (timesheet.TimeWatch__Total_time__c !=null ? timesheet.TimeWatch__Total_time__c : 0);
				
                //Add total invoice amount of this entry to the timesheet's invoice amount
                timesheet.TimeWatch__Invoice_Amount__c = (timesheet.TimeWatch__Invoice_Amount__c !=null ? timesheet.TimeWatch__Invoice_Amount__c : 0) 
                    + (timeEntryHist.TimeWatch__Invoice_Amount__c !=null ? timeEntryHist.TimeWatch__Invoice_Amount__c : 0);
                
                // Add total time spent value of this time entry hist record to the timesheet's total time spent value
                timesheet.TimeWatch__Total_time__c =   timesheetTotalTime + TW_StopwatchUtil.convertMillsToHours(timeEntryHisttotalTime);
                
                // put timesheet record of this entry's user to the map.
                userToTimesheetMap.put(timeEntryHist.CreatedById,timesheet);
                
          
            }else{
                // if timesheet is not exists on userToTimesheetMap then we need to create new one
                TimeWatch__Project_Timesheet__c timesheet = new TimeWatch__Project_Timesheet__c();
                
                // populate timesheet name
                timesheet.Name = Label.TW_WeekFrom +' '+ (System.today() - 7).day() +'  -  ' +TW_StopwatchUtil.getTextMonthFirst3Chars((System.today() - 7).month())
                    +' ' + Label.TW_To+' '+ (System.today() ).day() +'  -  ' +TW_StopwatchUtil.getTextMonthFirst3Chars((System.today() ).month())+'  -  ' +timeEntryHist.CreatedBy.Name;
                
                timesheet.TimeWatch__Start_Date__c = System.today() - 7;
                timesheet.TimeWatch__End_Date__c = System.today();
                timesheet.TimeWatch__Project__c = timeEntryHist.TimeWatch__Project_Record_Id__c;
                
                timesheet.OwnerId = timeEntryHist.CreatedById;
                timesheet.TimeWatch__Timesheet_Manager__c = timeEntryHist.TimeWatch__Project_Manager_Id__c;
                timesheet.TimeWatch__Invoice_Amount__c = (timesheet.TimeWatch__Invoice_Amount__c !=null ? timesheet.TimeWatch__Invoice_Amount__c : 0) 
                    + (timeEntryHist.TimeWatch__Invoice_Amount__c !=null ? timeEntryHist.TimeWatch__Invoice_Amount__c : 0);
                
                timesheet.TimeWatch__Total_time__c = (timesheet.TimeWatch__Total_time__c !=null ? timesheet.TimeWatch__Total_time__c : 0)  
                    + TW_StopwatchUtil.convertMillsToHours(Integer.valueOf((timeEntryHist.TimeWatch__Total_Time_Spent__c !=null ? timeEntryHist.TimeWatch__Total_Time_Spent__c : 0)));
                
                userToTimesheetMap.put(timeEntryHist.CreatedById,timesheet);
                
            }
            
            // populate the map that contains the time entry records for each user. this map will be used to link time entry records to timesheet.
            if(!timeEntrySet.contains(timeEntryHist.TimeWatch__Project_Time_Entry__c)){
                List<TimeWatch__Project_Time_Entry__c> timeEntryList = userToTimeEntryListMap.get(timeEntryHist.CreatedById);
                if(timeEntryList==null){
                    timeEntryList = new List<TimeWatch__Project_Time_Entry__c>();
                }
                timeEntryList.add(new TimeWatch__Project_Time_Entry__c(Id=timeEntryHist.TimeWatch__Project_Time_Entry__c) );
                userToTimeEntryListMap.put(timeEntryHist.CreatedById,timeEntryList);
                timeEntrySet.add(timeEntryHist.TimeWatch__Project_Time_Entry__c);
            }
        }
        System.debug('TW_GenerateTimesheetBatchHelper, executeTimeSheetBatch(), end'  + userToTimesheetMap);
    }
    
     /**
    * @description create weekly timesheet records for each user. Update timesheet Id in related TimeWatch__Project_Time_Entry__c records.
    * 
    * @param userToTimesheetMap  A map contain users and it's related timesheet record. it will be used to create timesheet record in finish method
    * @param userToTimeEntryListMap A map contain users and related time entry records. 
    * 
    * @return void
    */
    public static void createTimesheetRecord(Map<String, TimeWatch__Project_Timesheet__c> userToTimesheetMap 
                                             ,Map<String,List<TimeWatch__Project_Time_Entry__c>>  userToTimeEntryListMap){
        
        System.debug('TW_GenerateTimesheetBatchHelper, createTimesheetRecord(), start');
        
        // list of timesheet records which need to be inserted in database for each user.
        List<TimeWatch__Project_Timesheet__c> timesheetListToInsert =  new List<TimeWatch__Project_Timesheet__c>();
        
        // Iterage over userToTimesheetMap and create timesheet for each user.
        for( String userId :  userToTimesheetMap.keySet()){
            if(userToTimesheetMap.get(userId)!=null){
                timesheetListToInsert.add(userToTimesheetMap.get(userId));
            }
        }
        // insert timesheet records in the database.
        if(timesheetListToInsert.size()>0){
            insert timesheetListToInsert;
        }
        
        // List of TimeWatch__Project_Time_Entry__c records which need to be updated for timesheet Id. 
        List<TimeWatch__Project_Time_Entry__c> timeEntryListToUpdate = new List<TimeWatch__Project_Time_Entry__c>();
        
        // update timesheet Id to all related time entry records.
        for(TimeWatch__Project_Timesheet__c timesheet : timesheetListToInsert){
             List<TimeWatch__Project_Time_Entry__c> timeEntryList = userToTimeEntryListMap.get(timesheet.OwnerId);         
            for(TimeWatch__Project_Time_Entry__c timeEntry : timeEntryList){
                timeEntry.TimeWatch__Project_Timesheet__c = timesheet.id;
                timeEntryListToUpdate.add(timeEntry);
            }
        }
        // update time entry records.                                         
        if(timeEntryListToUpdate.size()>0){
            update timeEntryListToUpdate;
        } 
        System.debug('TW_GenerateTimesheetBatchHelper, createTimesheetRecord(), end');
    }
}