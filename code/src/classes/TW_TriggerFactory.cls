/**
* @author Amitkumar Joshi
* @date 06/18/2017
*
* @description This is Trigger Factory class. This class is used to implement the central trigger factory.
* Whenever you add new trigger to any object, you need to create one Handler apex class and initialize that handler
* apex class instance in here in the getHandler method. This class has create handler method which will execute the method based on trigger event. 
* I.e. insert, delete, update
*/
public class TW_TriggerFactory {
   /**
    * @description private static method to get the appropriate handler for the object type.
    * Modify this method to add any additional handlers.
    * 
    * @param Schema.sObjectType soType  Object type tolocate (SObject.sObjectType)
    * 
    * @return TW_TriggerInterface   trigger handler if one exists or null.
    */
    private static TW_TriggerInterface getHandler(Schema.sObjectType soType){    
        System.debug('TW_TriggerFactory, getHandler(), start');
       if (soType == TimeWatch__Project_Time_Entry__c.sObjectType){
            return new TW_ProjectTimeEntryTriggerHandler();
       }else if (soType == TimeWatch__Project_Member__c.sObjectType){
            return new TW_ProjectMemberTriggerHandler();
       }else if (soType == TimeWatch__Project_Task__c.sObjectType){
            return new TW_ProjectTaskTriggerHandler();
       }else if (soType == TimeWatch__Project_Timesheet__c.sObjectType){
            return new TW_ProjectTimesheetTriggerHandler();
       }
        System.debug('TW_TriggerFactory, getHandler(), end');
        return null;
    }
   /**
    * @description method to create and execute a trigger handler. Call this method from any new trigger to
    * execute the handler class logic.
    * 
    * @param Schema.sObjectType soType  Object type tolocate (SObject.sObjectType)
    * 
    * @return void
    */
     public static void createHandler(Schema.sObjectType soType)  {
         System.debug('TW_TriggerFactory, createHandler(), start');
         
        // Get a handler appropriate to the object being processed
        TW_TriggerInterface handler = getHandler(soType);
        
        // Make sure we have a handler registered, new handlers must be registered in the getHandler method.
        if (handler == null) {
            System.debug('TW_TriggerFactory, createHandler(), end returning null');
            return;
        }
        
        // Execute the handler to fulfil the trigger
        execute(handler);
         System.debug('TW_TriggerFactory, createHandler(), end');
    }
    
    /**
    * @description method to excute trigger handler logic.
    * 
    * @param TW_TriggerInterface handler  A handler class sepcific to trigger.
    * 
    * @return void
    */
    private static void execute(TW_TriggerInterface handler) {
         System.debug('TW_TriggerFactory, execute(), start');
        // Before Trigger
        if (Trigger.isBefore){
            // Call the bulk before to handle any caching of data and enable bulkification
            handler.bulkBefore();
            
            // Iterate through the records to be deleted passing them to the handler.
            if (Trigger.isDelete){
                    handler.beforeDelete(Trigger.old);
            }
            // Iterate through the records to be inserted passing them to the handler.
            else if (Trigger.isInsert){
                    handler.beforeInsert(Trigger.new);
            }
            // Iterate through the records to be updated passing them to the handler.
            else if (Trigger.isUpdate){
                    handler.beforeUpdate(Trigger.new,Trigger.old);
            }
        }
        else
        {
            // Call the bulk after to handle any caching of data and enable bulkification
            handler.bulkAfter();
            
            // Iterate through the records deleted passing them to the handler.
            if (Trigger.isDelete){ 
                    handler.afterDelete(Trigger.old);
            }
            // Iterate through the records inserted passing them to the handler.
            else if (Trigger.isInsert){
                    handler.afterInsert(Trigger.new);
            }
            // Iterate through the records updated passing them to the handler.
            else if (Trigger.isUpdate){
                    handler.afterUpdate(Trigger.new,Trigger.old,Trigger.oldMap);
            }
        }
        
        // Perform any post processing
        handler.andFinally();
        System.debug('TW_TriggerFactory, execute(), end');
    }
}