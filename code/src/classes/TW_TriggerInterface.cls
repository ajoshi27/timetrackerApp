/**
* @author Amitkumar Joshi
* @date 06/18/2017
*
* @description This interface is used to implement the central trigger pattern. Whenever you add new trigger on object, you need to create one
* handler class and that handler class has to implement this interface and all of it's method.
*
*/
public interface TW_TriggerInterface {
    /**
    * @description This method is called prior to execution of a BEFORE trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    * 
    * @return void
    */
  void bulkBefore();
    /**
    * @description This method is called prior to execution of a AFTER trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    * 
    * @return void
    */
  void bulkAfter();
    /**
    * @description  This method is called iteratively for each record to be inserted during a BEFORE
    *  trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
    * 
    * @param List<SObject> so  A list of Sobject affected by this trigger event.
    * @return void
    */
  void beforeInsert(List<SObject> so);
 
   /**
    * @description This method is called iteratively for each record to be updated during a BEFORE
    *  trigger. 
    * 
    * @param List<SObject> oldSo A list of Old objects. it contains the old value of records.
    * @param List<SObject> so  A list of Sobject affected by this trigger event.
    * @return void
    */
  void beforeUpdate(List<SObject> oldSo, List<SObject> so);
 /**
    * @description This method is called iteratively for each record to be deleted during a BEFORE
    *  trigger. 
    * 
    * @param List<SObject> oldSo  A list of Sobject affected by this trigger event.
    * @return void
    */
  void beforeDelete(List<SObject> oldSo);
  /**
    * @description This method is called iteratively for each record inserted during an AFTER
    * trigger. Always put field validation in the 'After' methods in case another trigger
    * has modified any values. The record is 'read only' by this point.
    * 
    * @param List<SObject> so  A list of Sobject affected by this trigger event.
    * @return void
    */
  void afterInsert(List<SObject> so);
    
  /**
    * @description This method is called iteratively for each record updated during an AFTER
    * 
    * @param List<SObject> oldSo  A list of old Sobject affected by this trigger event.
    * @param List<SObject> So  A list of Sobject affected by this trigger event.
    * @param Map<Id,Sobject> oldMap  A Map of record Id to its record contains old values
    * 
    * @return void
    */
  void afterUpdate(List<SObject> oldSo, List<SObject> so, Map<Id,Sobject> oldMap);
 
    /**
    * @description This method is called iteratively for each record deleted during an AFTER
    * trigger.
    * 
    * @param List<SObject> oldSo  A list of Sobject affected by this trigger event.
    * @return void
    */
  void afterDelete(List<SObject> oldSo);
    
  /**
    * @description This method is called once all records have been processed by the trigger. Use this 
    * method to accomplish any final operations such as creation or updates of other records.
    * 
    * @return void
    */
  void andFinally();
}