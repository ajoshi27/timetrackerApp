/**
* @author Amitkumar Joshi
* @date 06/17/2017
*
*
* @description This class implements the TW_TriggerInterface. it contains the basic trigger event methods like beforeInsert, beforeUpdate
* beforeDelete etc. These methods will be fired on insert , update and delete events of TimeWatch__Project_Task__c record.
*  
*/
public class TW_ProjectTaskTriggerHandler implements TW_TriggerInterface{
    
    /**
    * @description constructor. create the new instance of TW_ProjectTaskTriggerHandler using this.
    */
	public TW_ProjectTaskTriggerHandler(){
        System.debug('TW_ProjectTaskTriggerHandler constructor called');
    }
    
    /**
    * @description this method will be fired whenever TimeWatch__Project_Task__c records are inserted in bulk using bulk API.
    * This method will be fire before records are committed to database. You can perform activity like record validation
    *  in this method.
    * 
    * @return void
    */
    public void bulkBefore(){
        System.debug('TW_ProjectTaskTriggerHandler, bulkBefore called');
    }
    
    /**
    * @description this method will be fired whenever TimeWatch__Project_Task__c records are inserted in bulk using using bulk API.
    * This method will be fire After records are committed to database. You can perform activity like sending emails,
    *  inserting/updating child records in this method.
    * 
    * @return void
    */
    public void bulkAfter(){
      System.debug('TW_ProjectTaskTriggerHandler, bulkAfter called');
    }
    
    /**
    * @description this method will be fired whenever TimeWatch__Project_Task__c records are inserted.
    * This method will be fire before records are committed to database. You can perform activity like record validation
    *  in this method.
    * 
    * @return void
    */
    public void beforeInsert(List<SObject> lstsObjectNew){
        System.debug('TW_ProjectTaskTriggerHandler, beforeInsert called');
    }
    
    /**
    * @description this method will be fired whenever TimeWatch__Project_Task__c records are updated.
    * This method will be fire before records are committed to database. You can perform activity like record validation
    *  in this method.
    * 
    * @return void
    */
    public void beforeUpdate(List<SObject> lstsObjectNew,List<SObject> lstsObjectOld) {
     
       System.debug('TW_ProjectTaskTriggerHandler, beforeUpdate called');
    }
    
    /**
    * @description this method will be fired whenever TimeWatch__Project_Task__c records are deleted.
    * This method will be fire before records are committed to database.
    * 
    * @return void
    */
    public void beforeDelete(List<SObject> lstsObjectOld){   
       System.debug('TW_ProjectTaskTriggerHandler, beforeDelete called');
    }
    
    /**
    * @description this method will be fired whenever TimeWatch__Project_Task__c records are inserted either from UI or
    * from data data loader. This method will be fire After records are committed to database. You can perform activity like sending emails,
    *  inserting/updating child records in this method.
    * 
    * @return void
    */
    public void afterInsert(List<SObject> lstsObjectNew){
       System.debug('TW_ProjectTaskTriggerHandler, afterInsert called');
        TW_ProjectTaskTriggerHelper.shareRecordsWithProjectMember(lstsObjectNew);
    }
    
    /**
    * @description this method will be fired whenever TimeWatch__Project_Task__c records are updated  from UI or
    * from data data loader. This method will be fire After records are committed to database. You can perform activity like sending emails,
    *  inserting/updating child records in this method.
    * 
    * @return void
    */
    public void afterUpdate(List<SObject> lstsObjectNew,List<SObject> lstsObjectOld, Map<Id,SObject> oldMap){
       System.debug('TW_ProjectTaskTriggerHandler, afterUpdate called');
        
    }
    
     /**
    * @description this method will be fired whenever TimeWatch__Project_Task__c records are deleted  from UI or
    * from data data loader. This method will be fire After records are committed to database. 
    * 
    * @return void
    */
    public void afterDelete(List<SObject> lstsObjectOld){
        System.debug('TW_ProjectTaskTriggerHandler, afterDelete called');
    }
    
    /**
     *@description This method is called once all records have been processed by the trigger. Use this 
     * method to accomplish any final operations such as creation or updates of other records.
     * 
     * @return void
     */
    public void andFinally(){ 
        System.debug('TW_ProjectTaskTriggerHandler, andFinally called');
    }
}