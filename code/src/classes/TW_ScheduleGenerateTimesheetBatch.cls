/**
* @author Amitkumar Joshi
* @date 07/2/2017
*
*
* @description A schedulable class to schedule TW_GenerateTimesheetBatch
*/
global class TW_ScheduleGenerateTimesheetBatch implements Schedulable {
   global void execute(SchedulableContext sc) {
      TW_GenerateTimesheetBatch b = new TW_GenerateTimesheetBatch(); 
      database.executebatch(b);
   }
}