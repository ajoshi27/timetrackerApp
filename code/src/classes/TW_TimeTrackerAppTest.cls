/**
* @author Amitkumar Joshi
* @date 06/18/2017
*
* @description This is the test class which will test the timer start, stop functionality.
*
*/
@isTest
Private class TW_TimeTrackerAppTest {
    
    /**
    * @description This is setup data method. create all necessary data which will require for test methods. It creates the
    * TimeWatch__Trigger_Settings__c, TimeWatch__Project__c, TimeWatch__Project_Task__c,TimeWatch__Project_Member__c  and 
    *  User records.
    * 
    * @return void
    */
	@testSetup static void setup() {
       
        //create TimeWatch__Trigger_Settings__c custom setting entries
        TimeWatch__Trigger_Settings__c projectMembersettings = (TimeWatch__Trigger_Settings__c)TW_TestFactory.createSObject(new TimeWatch__Trigger_Settings__c(Name='TimeWatch__Project_Member__c', TimeWatch__Active__c=true), true);
        TimeWatch__Trigger_Settings__c taskSettings = (TimeWatch__Trigger_Settings__c)TW_TestFactory.createSObject(new TimeWatch__Trigger_Settings__c(Name='TimeWatch__Project_Task__c', TimeWatch__Active__c=true), true);
        TimeWatch__Trigger_Settings__c timesheetSettings = (TimeWatch__Trigger_Settings__c)TW_TestFactory.createSObject(new TimeWatch__Trigger_Settings__c(Name='TimeWatch__Project_Timesheet__c', TimeWatch__Active__c=true), true);
        TimeWatch__Trigger_Settings__c timeentrySettings = (TimeWatch__Trigger_Settings__c)TW_TestFactory.createSObject(new TimeWatch__Trigger_Settings__c(Name='TimeWatch__Project_Time_Entry__c', TimeWatch__Active__c=true), true);
        
        // create new Account.
        Account testAcc = (Account)TW_TestFactory.createSObject(new Account(), true);
        
        // create new project.
        TimeWatch__Project__c testPrj = (TimeWatch__Project__c)TW_TestFactory.createSObject(new TimeWatch__Project__c());
        testPrj.TimeWatch__Client_Name__c = testAcc.Id;
        insert testPrj;
        
        // create new tasks for a project.
        List<TimeWatch__Project_Task__c> taskList = (List<TimeWatch__Project_Task__c>)TW_TestFactory.createSObjectList(new TimeWatch__Project_Task__c(), 5);
        for(TimeWatch__Project_Task__c tsk :taskList ){
            tsk.TimeWatch__Project__c = testPrj.Id;
        }
        insert taskList;
        // create manager user with platform license
        User mgrUsr = TW_TestFactory.createTestPlatformUser('TestManager', 'One');
        
		 // create member user with platform license
        User memberUsr = TW_TestFactory.createTestPlatformUser('TestMember', 'One');
        
      
    }
    
    /**
    * @description it valiates all the data which is created by setup() method.
    * 
    * @return void
    */
     @isTest static void testValidateNewData() {
         Test.startTest();
         
         // check if account is created successfully.
         List<Account> acc = [select Id from Account limit 1];
         system.assert(acc.size()>0);
         // check if project  is created successfully.
         List<TimeWatch__Project__c> testPrj = [select Id from TimeWatch__Project__c limit 1];
         system.assert(testPrj.size()>0);
         // check if task is created successfully.
         List<TimeWatch__Project_Task__c> testTsk = [select Id from TimeWatch__Project_Task__c limit 1];
         system.assert(testTsk.size()>0);
        
         
         Test.stopTest();
         
     }

    /**
    * @description it will test Generate Timesheet function and check if Manager has access to it.
    * It will also check approval of timesheet and lock and unlock timesheet functionalities
    * It will schedule the batch class to run biweekly.
    * 
    * @return void
    */
    @isTest static void testGenerateTimesheet() {
        Test.startTest();
         TimeWatch__Project__c testPrj = [select Id from TimeWatch__Project__c limit 1];
             
         // Add new Project Member
        User memberUser = [select Id from User where firstname=:'TestMember'];
        TimeWatch__Project_Member__c prjMember = (TimeWatch__Project_Member__c)TW_TestFactory.createSObject(
            new TimeWatch__Project_Member__c(TimeWatch__Role__c='Member', TimeWatch__Project__c=testPrj.Id,TimeWatch__User__c=memberUser.Id));
        
        insert prjMember;
         // Add new Project Manager
        User mgrUser = [select Id from User where firstname=:'TestManager'];
        TimeWatch__Project_Member__c prjManager = (TimeWatch__Project_Member__c)TW_TestFactory.createSObject(
            new TimeWatch__Project_Member__c(TimeWatch__Role__c='Manager', TimeWatch__Project__c=testPrj.Id,TimeWatch__User__c=mgrUser.Id));
		
        insert prjManager; 
        
        System.runAs(memberUser){
             
            //Add new Time entry
            TimeWatch__Project__c tempTestPrj = [select Id from TimeWatch__Project__c limit 1];
      	    List<TimeWatch__Project_Task__c> testTsk = [select Id from TimeWatch__Project_Task__c where TimeWatch__Project__c=:tempTestPrj.Id order by createdDate asc limit 1];
            
            system.assert(testTsk.size()>0);
            Datetime startDate = system.now()-2;
            Datetime stopDate = system.now();
            TimeWatch__Project_Time_Entry__c timeEntry = (TimeWatch__Project_Time_Entry__c)TW_TestFactory.createSObject(
            new TimeWatch__Project_Time_Entry__c(TimeWatch__Start_Date__c=startDate, TimeWatch__End_Date__c=stopDate,TimeWatch__Project_Task__c=testTsk.get(0).Id, TimeWatch__Status__c='Stop'));
            insert timeEntry;
            
             TimeWatch__Project_Time_Entry__c timeEntry1 = (TimeWatch__Project_Time_Entry__c)TW_TestFactory.createSObject(
            new TimeWatch__Project_Time_Entry__c(TimeWatch__Start_Date__c=startDate, TimeWatch__End_Date__c=stopDate,TimeWatch__Project_Task__c=testTsk.get(0).Id, TimeWatch__Status__c='Stop'));
            insert timeEntry1;
            
            List<TimeWatch__Project_Time_Entry__c> tempTimeEntry = [select id, TimeWatch__Start_Date__c,TimeWatch__End_Date__c from TimeWatch__Project_Time_Entry__c
                                                                   where TimeWatch__Start_Date__c=:startDate and TimeWatch__End_Date__c=:stopDate];
            
            system.assert(tempTimeEntry.size()>0);
            
             //update existing time entry with reduce the time spent
            if(tempTimeEntry.size() >0){
                TimeWatch__Project_Time_Entry__c tEntry = tempTimeEntry.get(0);
                tEntry.TimeWatch__End_Date__c = system.now() -1 ;
                update tEntry;
                List<TimeWatch__Project_Time_Entry__c> tempTimeEntry1 = [select id, TimeWatch__Start_Date__c,TimeWatch__End_Date__c from TimeWatch__Project_Time_Entry__c
                                                                   where TimeWatch__Start_Date__c=:startDate and TimeWatch__End_Date__c=: system.now() -1];
            
                system.assert(tempTimeEntry1.size()>0);
            }
        }
        
        TW_GenerateTimesheetBatch batch = new TW_GenerateTimesheetBatch();
        Database.executeBatch(batch,200);
        
        // run batch biweekly.
        TW_ScheduleGenerateTimesheetBatch schClass =  new TW_ScheduleGenerateTimesheetBatch();
        String sch = '0  00 1 3 * ?';
        system.schedule('Test', sch, schClass);
       
         Test.stopTest();
    }
    
     /**
    * @description validate new timer functionality. It will first start new timer, stop it and again restart it.
    * It also checks for negative scenarios like invalid task Id and time entry id
    * 
    * @return void
    */
    @isTest static void testStartNStopTimer() {
        Test.startTest();
        TimeWatch__Project__c testPrj = [select Id from TimeWatch__Project__c limit 1];
      	 List<TimeWatch__Project_Task__c> testTsk = [select Id from TimeWatch__Project_Task__c where TimeWatch__Project__c=:testPrj.Id order by createdDate asc limit 1];
        
        // Start new timer
        TW_StopwatchController.start(testTsk.get(0).id, null);
        TimeWatch__Project_Time_Entry__c timeEntry = TW_StopwatchController.getTimeEntry(testTsk.get(0).id);
        system.assert(timeEntry.TimeWatch__Status__c=='Start');
        
        // Stop timer
        Decimal lapTime = system.currentTimeMillis() - timeEntry.TimeWatch__Start_Time_Millis__c;
        
        TW_StopwatchController.stop(timeEntry.id, Integer.valueof(lapTime));
        TimeWatch__Project_Time_Entry__c stopTimeEntry = TW_StopwatchController.getTimeEntry(testTsk.get(0).id);
        system.assert(stopTimeEntry.TimeWatch__Status__c=='Stop');
        
        // Start existing timer
        TW_StopwatchController.start(testTsk.get(0).id, stopTimeEntry.Id);
        TimeWatch__Project_Time_Entry__c existingTimeEntry = TW_StopwatchController.getTimeEntry(testTsk.get(0).id);
        system.assert(existingTimeEntry.TimeWatch__Status__c=='Start');
        
        // Exception scenario - invalid task Id -1
       TimeWatch__Project_Time_Entry__c invalidTimeEntry = TW_StopwatchController.getTimeEntry(existingTimeEntry.Id); 
        system.assert(invalidTimeEntry==null);
        
       // Exception scenario - invalid timeentry Id in start
       try{
             TW_StopwatchController.start(testTsk.get(0).id, testTsk.get(0).id);
        }catch(System.QueryException e){
            system.assert(e!=null);
        }
        
        // Exception scenario - invalid timeentry Id in stop
       try{
             TW_StopwatchController.stop(testTsk.get(0).id, 0);
        }catch(System.QueryException e){
            system.assert(e!=null);
        }
        Test.stopTest();
    }
      /**
    * @description it will add the new project Manager and project Member on project and check if 
    * these new users have access to the exsting tasks of the project.
    * 
    * @return void
    */
    @isTest static void testShareProjectNRelatedRecordToNewPrjMember() {
        Test.startTest();
        TimeWatch__Project__c testPrj = [select Id from TimeWatch__Project__c limit 1];
       
      	 List<TimeWatch__Project_Task__c> testTsk = [select Id from TimeWatch__Project_Task__c where TimeWatch__Project__c=:testPrj.Id order by createdDate asc limit 1];
        
        // Start new timer
        TW_StopwatchController.start(testTsk.get(0).id, null);
        TimeWatch__Project_Time_Entry__c timeEntry = TW_StopwatchController.getTimeEntry(testTsk.get(0).id);
        system.assert(timeEntry.TimeWatch__Status__c=='Start');
        
        // Stop timer
        Decimal lapTime = system.currentTimeMillis() - timeEntry.TimeWatch__Start_Time_Millis__c;
        
        TW_StopwatchController.stop(timeEntry.id, Integer.valueof(lapTime));
        TimeWatch__Project_Time_Entry__c stopTimeEntry = TW_StopwatchController.getTimeEntry(testTsk.get(0).id);
        system.assert(stopTimeEntry.TimeWatch__Status__c=='Stop');
        
        // Add new Project Manager
        User mgrUser = [select Id from User where firstname=:'TestManager'];
        TimeWatch__Project_Member__c prjManager = (TimeWatch__Project_Member__c)TW_TestFactory.createSObject(
            new TimeWatch__Project_Member__c(TimeWatch__Role__c='Manager', TimeWatch__Project__c=testPrj.Id,TimeWatch__User__c=mgrUser.Id));
		
        insert prjManager;        
        
        //Add new task
        TimeWatch__Project_Task__c task = (TimeWatch__Project_Task__c)TW_TestFactory.createSObject(new TimeWatch__Project_Task__c());
        task.TimeWatch__Project__c = testPrj.Id;
        insert task;
        
        // check if new project manager have edit access to the task
        System.runAs(mgrUser){
            TimeWatch__Project_Task__c tempTask = [select Id from TimeWatch__Project_Task__c where Id=:task.id];
            tempTask.TimeWatch__Description__c ='Testdesc';
            update tempTask;
            system.assert(tempTask.TimeWatch__Description__c!=null);
        }
        Test.stopTest();
    }
  	/**
    * @description it will test following scenarios. 1. Add manual time entry as a member and check if 
    * Manager has access to it 2. 
    * 
    * @return void
    */
    @isTest static void testManuallyAddTimeEntry() {
        Test.startTest();
         TimeWatch__Project__c testPrj = [select Id from TimeWatch__Project__c limit 1];
             
         // Add new Project Member
        User memberUser = [select Id from User where firstname=:'TestMember'];
        TimeWatch__Project_Member__c prjMember = (TimeWatch__Project_Member__c)TW_TestFactory.createSObject(
            new TimeWatch__Project_Member__c(TimeWatch__Role__c='Member', TimeWatch__Project__c=testPrj.Id,TimeWatch__User__c=memberUser.Id));
        
        insert prjMember;
        
        System.runAs(memberUser){
             
            //Add new Time entry
            TimeWatch__Project__c tempTestPrj = [select Id from TimeWatch__Project__c limit 1];
      	    List<TimeWatch__Project_Task__c> testTsk = [select Id from TimeWatch__Project_Task__c where TimeWatch__Project__c=:tempTestPrj.Id order by createdDate asc limit 1];
            
            system.assert(testTsk.size()>0);
            Datetime startDate = system.now()-1;
            Datetime stopDate = system.now();
            TimeWatch__Project_Time_Entry__c timeEntry = (TimeWatch__Project_Time_Entry__c)TW_TestFactory.createSObject(
            new TimeWatch__Project_Time_Entry__c(TimeWatch__Start_Date__c=startDate, TimeWatch__End_Date__c=stopDate,TimeWatch__Project_Task__c=testTsk.get(0).Id, TimeWatch__Status__c='Stop'));
            insert timeEntry;
            List<TimeWatch__Project_Time_Entry__c> tempTimeEntry = [select id, TimeWatch__Start_Date__c,TimeWatch__End_Date__c from TimeWatch__Project_Time_Entry__c
                                                                   where TimeWatch__Start_Date__c=:startDate and TimeWatch__End_Date__c=:stopDate];
            
            system.assert(tempTimeEntry.size()>0);
        }
         Test.stopTest();
    }
     /**
    * @description it will test bulk creation of tasks to ensure the bulkification of Task trigger
    * 
    * @return void
    */
    @isTest static void testBulkTaskInsertionToAProject() {
        
        Test.startTest();
        // create new Account.
        Account testAcc = (Account)TW_TestFactory.createSObject(new Account(), true);
        
        // create new project.
        TimeWatch__Project__c testPrj = (TimeWatch__Project__c)TW_TestFactory.createSObject(new TimeWatch__Project__c());
        testPrj.TimeWatch__Client_Name__c = testAcc.Id;
        insert testPrj;
        
        List<TimeWatch__Project_Task__c> taskList = (List<TimeWatch__Project_Task__c>)TW_TestFactory.createSObjectList(new TimeWatch__Project_Task__c(), 500);
        for(TimeWatch__Project_Task__c tsk :taskList ){
            tsk.TimeWatch__Project__c = testPrj.Id;
        }
        insert taskList;
        system.assert(taskList.size()==500);
        Test.stopTest();
    }
    
    /**
    * @description it will test bulk creation of time entry to ensure the bulkification of Task trigger
    * 
    * @return void
    */
    @isTest static void testBulkTimeEntryInsertionToATask() {
        
        Test.startTest();
        // create new Account.
        Account testAcc = (Account)TW_TestFactory.createSObject(new Account(), true);
        
        // create new project.
        TimeWatch__Project__c testPrj = (TimeWatch__Project__c)TW_TestFactory.createSObject(new TimeWatch__Project__c());
        testPrj.TimeWatch__Client_Name__c = testAcc.Id;
        insert testPrj;
        
        List<TimeWatch__Project_Task__c> taskList = (List<TimeWatch__Project_Task__c>)TW_TestFactory.createSObjectList(new TimeWatch__Project_Task__c(), 1);
        for(TimeWatch__Project_Task__c tsk :taskList ){
            tsk.TimeWatch__Project__c = testPrj.Id;
        }
        insert taskList;
        
        List<TimeWatch__Project_Time_Entry__c> timeEntryList = (List<TimeWatch__Project_Time_Entry__c>)TW_TestFactory.createSObjectList(
            new TimeWatch__Project_Time_Entry__c(TimeWatch__Start_Date__c=System.now() -2, TimeWatch__End_Date__c=System.now()-1,TimeWatch__Project_Task__c=taskList.get(0).Id, TimeWatch__Status__c='Stop'),500);
        
        insert timeEntryList;
        system.assert(timeEntryList.size()==500);
        
        // to coverup time entry bulk delete scenario
        delete timeEntryList;
         List<TimeWatch__Project_Time_Entry__c> deletedTimeEntryList = [select Id from TimeWatch__Project_Time_Entry__c where Id IN: timeEntryList];
        System.assert(deletedTimeEntryList.size()==0);
        // to coverup task bulk delete scenario
        delete taskList;
        List<TimeWatch__Project_Task__c> deletedTaskList= [select Id from TimeWatch__Project_Task__c where Id IN: taskList];
        System.assert(deletedTaskList.size()==0);
         // to coverup project delete scenario
        delete testPrj;
         List<TimeWatch__Project__c> deletedProjectList= [select Id from TimeWatch__Project__c where  Id=: testPrj.Id];
        System.assert(deletedProjectList.size()==0);
        Test.stopTest();
    }
}