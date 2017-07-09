/**
* @author Amitkumar Joshi
* @date 06/18/2017
*
* @description This is the controller class for StopWatch lightning component. It contain the Start and stop timer methods.
*
*/
public class TW_StopwatchController {
	
    /**
    * @description return the latest TimeWatch__Project_Time_Entry__c record for the current context user for the given task. This method will be called
    * whenever user view any task record. This method will be called immediately when timer component is loaded on task record.
    * 
    * @param Id taskId  task record Id which currently user is viewing.
    * 
    * @return TimeWatch__Project_Time_Entry__c  A time entry record.
    */
    @AuraEnabled
    public static TimeWatch__Project_Time_Entry__c getTimeEntry(Id taskId) {
        System.debug('TW_StopwatchController, getTimeEntry(), start, taskId=' + taskId);
        try{
            List<TimeWatch__Project_Time_Entry__c> timeEntryList = [select Id, TimeWatch__Start_Date__c, TimeWatch__End_Date__c, TimeWatch__Total_time_spent_Millis__c,
                                                                    TimeWatch__Start_Time_Millis__c,TimeWatch__Stop_Time_Millis__c, TimeWatch__Status__c 
                                                                    from TimeWatch__Project_Time_Entry__c where CreatedById=:UserInfo.getUserId() 
                                                                    and TimeWatch__Project_Task__c=:taskId order by CreatedDate desc];
            if(timeEntryList.size()>0){
                 System.debug('TW_StopwatchController, getTimeEntry(), end, taskId=' + taskId + ' returning ' + timeEntryList.get(0));
                return timeEntryList.get(0);
            }else{
                System.debug('TW_StopwatchController, getTimeEntry(), end, taskId=' + taskId + ' returning null');
                return null;
            }
            
        }catch(Exception e){
            System.debug('TW_StopwatchController, getTimeEntry(), Error occurred=' + e);
            throw e;
        }
    }
    
    /**
    * @description return the latest TimeWatch__Project_Time_Entry__c record for the current context user for the given task and time entry id. This
    * method will be called when user press 'Start' button on timer component on task record. It will start the timer.
    * 
    * @param Id taskId  task record Id which currently user is viewing.
    * @param Id timeEntryId  latest time entry Id associated with this task.
    * 
    * @return TimeWatch__Project_Time_Entry__c  A time entry record.
    */
    @AuraEnabled
    public static TimeWatch__Project_Time_Entry__c  start(Id taskId, Id timeEntryId) {
		System.debug('TW_StopwatchController, getTimeEntry(), start, taskId :' + taskId + ', timeEntryId :' + timeEntryId );
        
        TimeWatch__Project_Time_Entry__c timeEntry = null; 
        
        try{
        	
        	
            if(timeEntryId==null){
                 timeEntry= new TimeWatch__Project_Time_Entry__c();
                 timeEntry.TimeWatch__Project_Task__c = taskId;
            }else{
            
                 timeEntry = [select Id, TimeWatch__Start_Date__c, TimeWatch__End_Date__c, 
                                                                        TimeWatch__Start_Time_Millis__c,TimeWatch__Stop_Time_Millis__c, TimeWatch__Status__c ,TimeWatch__Total_time_spent_Millis__c 
                                                                        from TimeWatch__Project_Time_Entry__c where CreatedById=:UserInfo.getUserId() 
                                                                        and Id=:timeEntryId order by CreatedDate desc];
            }
            
            timeEntry.TimeWatch__Status__c ='Start';
            timeEntry.TimeWatch__Start_Date__c = System.now();
            timeEntry.TimeWatch__End_Date__c = null;
            timeEntry.TimeWatch__Start_Time_Millis__c = System.currentTimeMillis();
            timeEntry.TimeWatch__Stop_Time_Millis__c = 0;
            upsert timeEntry;
            System.debug('TW_StopwatchController, getTimeEntry(), end , taskId :' + taskId + ', timeEntryId :' + timeEntryId );
        }catch(System.QueryException e){
        	System.debug('TW_StopwatchController, getTimeEntry(), Error Occurred : ' +e + ' for taskId=' + taskId + ',timeEntryId='+timeEntryId);
            throw e;
        }
        return timeEntry;
    }
    
    /**
    * @description This method will be called when user press 'Stop' button on timer component on task record. It
    * will update the TimeWatch__Project_Time_Entry__c with status as 'Stop' and it will stop the timer.
    * @param Id timeEntryId  latest time entry Id associated with this task.
    * @param Id laptime  total time spent by user on this task.
    * 
    * @return void
    */
    @AuraEnabled
    public static void stop(Id timeEntryId,Integer laptime) {
		System.debug('TW_StopwatchController, getTimeEntry(), start , timeEntryId :' + timeEntryId + ', laptime :' + laptime );
        try{
            // find the current time entry
            TimeWatch__Project_Time_Entry__c timeEntry = [select Id, TimeWatch__Start_Date__c, TimeWatch__Project_Task__r.TimeWatch__Project__c, TimeWatch__End_Date__c,TimeWatch__Total_time_spent_Millis__c, 
                                                                    TimeWatch__Start_Time_Millis__c,TimeWatch__Stop_Time_Millis__c, TimeWatch__Status__c 
                                                                    from TimeWatch__Project_Time_Entry__c where CreatedById=:UserInfo.getUserId() 
                                                                    and Id=:timeEntryId order by CreatedDate desc];
            
            timeEntry.TimeWatch__Status__c ='Stop';
          	timeEntry.TimeWatch__End_Date__c = System.now();
            update timeEntry;
            System.debug('TW_StopwatchController, getTimeEntry(), end , timeEntryId :' + timeEntryId + ', laptime :' + laptime );
                     
        }catch(System.QueryException e){
        	System.debug('TW_StopwatchController, getTimeEntry(), Error Occurred : ' +e + ' for timeEntryId='+timeEntryId);
            throw e;
        }
        
    }
    
    
}