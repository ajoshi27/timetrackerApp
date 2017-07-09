/**
* @author Amitkumar Joshi
* @date 07/2/2017
*
*
* @description A  batch class which will run at scheduled time and generate the timesheets for last week.
* It will iterate over all time entry history records and create the timesheet for a last week for each user. It will also link newly created
* timesheet records to a project and time entry records.
*/
global class TW_GenerateTimesheetBatch implements Database.Batchable<sObject>, Database.Stateful{
   
     // A map contain users and it's related timesheet record. it will be used to create timesheet record in finish method
   global Map<String, TimeWatch__Project_Timesheet__c> userToTimesheetMap;   
    
    // A map contain users and related time entry records.this map will be used to link time entry records to timesheet.
   global Map<String,List<TimeWatch__Project_Time_Entry__c>>  userToTimeEntryListMap;
    
    // A set contain unique list of time entry id.
    global Set<String>  timeEntrySet;
    
    /**
    * @description Start method of a batch. When this batch class runs, this method will be executed first. This method will fetch
    * all time entry history records for last 7 days.
    * 
    * @param BC Database.BatchableContext
    * @return void
    */
   global Database.QueryLocator start(Database.BatchableContext BC){
       System.debug('TW_GenerateTimesheetBatch, start(), start');
       
      DateTime startDate =  System.now() - 7; // start date of time entry history records
      DateTime endDate = system.now(); // end date of time entry history records
      
       // A map contain users and it's related timesheet record. it will be used to create timesheet record in finish method
      userToTimesheetMap = new Map<String, TimeWatch__Project_Timesheet__c>();
       
       // A map contain users and related time entry records. 
      userToTimeEntryListMap =  new Map<String,List<TimeWatch__Project_Time_Entry__c>>();
      timeEntrySet = new Set<String>();
       
       // find out all time entry history records for last 7 days.
      String query='select Id, createdById, TimeWatch__Project_Manager_Id__c, CreatedBy.Name,TimeWatch__Invoice_Amount__c, TimeWatch__End_Date__c,TimeWatch__Project_Record_Id__c,TimeWatch__Project_Time_Entry__c'
          +',TimeWatch__Total_Time_Spent__c from TimeWatch__Project_Time_Entry_History__c where TimeWatch__End_Date__c>=:startDate and TimeWatch__End_Date__c <=:endDate';
      
       System.debug('TW_GenerateTimesheetBatch, start(), end');
       
       return Database.getQueryLocator(query);
   }
	
    /**
    * @description Execute method of a batch. When this batch class runs, this method will be executed in batches of records.it will process
    *  200 records per batch. if there are 400 records, it will execute twice. it will process all time entry history records and populate
    *  the timeshee records for each user.
    * 
    * @param BC Database.BatchableContext
    * @param scope List of TimeWatch__Project_Time_Entry_History__c records which need to be processed to generate the timesheet for each user.
    * @return void
    */
   global void execute(Database.BatchableContext BC, List<TimeWatch__Project_Time_Entry_History__c> scope){
       System.debug('TW_GenerateTimesheetBatch, execute(), start');
       TW_GenerateTimesheetBatchHelper.executeTimeSheetBatch(scope,userToTimesheetMap,userToTimeEntryListMap,TimeEntrySet);
       System.debug('TW_GenerateTimesheetBatch, execute(), end');
   }
   
    /**
    * @description finish method of a batch. When this batch class runs, this method will be executed in the end. This method will
    *  insert the TimeWatch__Project_Timesheet__c records which have been populated in executed method.
    * 
    * @param BC Database.BatchableContext
    * @return void
    */
   global void finish(Database.BatchableContext BC){
       System.debug('TW_GenerateTimesheetBatch, finish(), start' + userToTimesheetMap);
       TW_GenerateTimesheetBatchHelper.createTimesheetRecord(userToTimesheetMap,userToTimeEntryListMap);
       System.debug('TW_GenerateTimesheetBatch, finish(), end');
   }
}