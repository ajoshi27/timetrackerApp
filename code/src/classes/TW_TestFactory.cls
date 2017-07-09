/**
* @author Amitkumar Joshi
* @date 06/18/2017
*
*
* @description This is the test factory class. It contains the test utility method to create new records for any object.
* It has the method to create single record as well as records in bulk.
*/
@isTest
public class TW_TestFactory {
   
     public static User createTestPlatformUser(String fName, String lName ){
         
        Profile platformUser = [select id from Profile where Name = 'Standard Platform User'];
      
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
       
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = fName,
                                lastName = lName,
                                email = uniqueName + '@test' + orgId + '.org',
                                Username = uniqueName + '@test' + orgId + '.org',
                                EmailEncodingKey = 'ISO-8859-1',
                                Alias = uniqueName.substring(18, 23),
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US',
                                ProfileId = platformUser.Id);
         
         
             insert tuser;
      
         assignPermissionSetToUser(tuser.Id);
        return tuser;
    }
    
    @future
    public static void assignPermissionSetToUser(Id userId){
        PermissionSet ps = [SELECT ID, Name From PermissionSet WHERE Name = 'TimeWatch_Standard_Access'];
	    insert new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = ps.Id );
    }
    
    /**
    * @description It creates a new Sobject of given type.It will just return the instance of that object with 
    *  default field poluated. it will not insert in database.
    * 
    * @param SObject sObj  object which user wants to create.
    * 
    * @return SObject return the instance of the SObject.
    */
	public static SObject createSObject(SObject sObj) {
		// Check what type of object we are creating and add any defaults that are needed.
		String objectName = String.valueOf(sObj.getSObjectType());
		// Construct the default values class. Salesforce doesn't allow '__' in class names
		String defaultClassName = 'TW_TestFactory.' + objectName.replaceAll('__c|__', '') + 'Defaults';
		// If there is a class that exists for the default values, then use them
		if (Type.forName(defaultClassName) != null) {
			sObj = createSObject(sObj, defaultClassName);
		}
		return sObj;
	}
	
     /**
    * @description It creates a new Sobject of given type.It will just return the instance of that object with 
    *  default field poluated. if doInsert flag is true then it will insert record in dabase.
    * 
    * @param SObject sObj  object which user wants to create.
    * @param Boolean doInsert  if object need to be inserted in database
    * 
    * @return SObject return the instance of the SObject.
    */
	public static SObject createSObject(SObject sObj, Boolean doInsert) {
		SObject retObject = createSObject(sObj);
		if (doInsert) {
			insert retObject;
		}
		return retObject;
	}
	
    /**
    * @description It creates a new Sobject of given type.It will just return the instance of that object with 
    *  default field poluated. it will not insert the record in database. if defaultClassName is specified, it will
    *  instanciate object of that type.
    * 
    * @param SObject sObj  object which user wants to create.
    * @param String defaultClassName  pass class name whose instance wants to create.
    * 
    * @return SObject return the instance of the SObject.
    */
	public static SObject createSObject(SObject sObj, String defaultClassName) {
		// Create an instance of the defaults class so we can get the Map of field defaults
		Type t = Type.forName(defaultClassName);
		if (t == null) {
			Throw new TestFactoryException('Invalid defaults class.');
		}
		FieldDefaults defaults = (FieldDefaults)t.newInstance();
		addFieldDefaults(sObj, defaults.getFieldDefaults());
		return sObj;
	}
	
    /**
    * @description It creates a new Sobject of given type.It will just return the instance of that object with 
    *  default field poluated. if doInsert flag is true then it will insert record in dabase. if defaultClassName is specified, it will
    *  instanciate object of that type.
    * 
    * @param SObject sObj  object which user wants to create.
    * @param String defaultClassName  pass class name whose instance wants to create.
    * @param String doInsert  if object need to be inserted in database
    * 
    * @return SObject return the instance of the SObject.
    */
	public static SObject createSObject(SObject sObj, String defaultClassName, Boolean doInsert) {
		SObject retObject = createSObject(sObj, defaultClassName);
		if (doInsert) {
			insert retObject;
		}
		return retObject;
	}
	
     /**
    * @description It creates a new Sobject of given type. It will create the number of records 
    * as specified in numberOfObjects. it will not commit any records in database.
    * 
    * @param SObject sObj  type of record which user wants to create.
    * @param Integer numberOfObjects  number of records you want to create
    * 
    * @return SObject[] return the instance of the SObject.
    */
	public static SObject[] createSObjectList(Sobject sObj, Integer numberOfObjects) {
		return createSObjectList(sObj, numberOfObjects, (String)null);
	}
	
    /**
    * @description It creates a new Sobject of given type. It will create the number of records 
    * as specified in numberOfObjects. If doInsert is true then it will commit those records in database.
    * 
    * @param SObject sObj  type of record which user wants to create.
    * @param Integer numberOfObjects  number of records you want to create
    * @param Boolean doInsert  if object need to be inserted in database
    * 
    * @return SObject[] return the instance of the SObject.
    */
	public static SObject[] createSObjectList(SObject sObj, Integer numberOfObjects, Boolean doInsert) {
		SObject[] retList = createSObjectList(sObj, numberOfObjects, (String)null);
		if (doInsert) {
			insert retList;
		}
		return retList;
	}
	
   /**
    * @description It creates a new Sobject of given type. It will create the number of records 
    * as specified in numberOfObjects. If doInsert is true then it will commit those records in database.
    * If defaultClassName is specified then it will create the object of that type.
    * 
    * @param SObject sObj  type of record which user wants to create.
    * @param Integer numberOfObjects  number of records you want to create
    * @param String defaultClassName  pass class name whose instance wants to create.
    * @param Boolean doInsert  if object need to be inserted in database
    * 
    * @return SObject[] return the instance of the SObject.
    */
	public static SObject[] createSObjectList(SObject sObj, Integer numberOfObjects, String defaultClassName, Boolean doInsert) {
		SObject[] retList = createSObjectList(sObj, numberOfObjects, defaultClassName);
		if (doInsert) {
			insert retList;
		}
		return retList;
	}
	
    /**
    * @description It creates a new Sobject of given type. It will create the number of records 
    * as specified in numberOfObjects. It will not commit those records in database.
    * If defaultClassName is specified then it will create the object of that type.
    * 
    * @param SObject sObj  type of record which user wants to create.
    * @param Integer numberOfObjects  number of records you want to create
    * @param String defaultClassName  pass class name whose instance wants to create.
    * 
    * @return SObject[] return the instance of the SObject.
    */
	public static SObject[] createSObjectList(Sobject sObj, Integer numberOfObjects, String defaultClassName) {
		SObject[] sObjs = new SObject[] {};
		SObject newObj;

		// Get one copy of the object
		if (defaultClassName == null) {
			newObj = createSObject(sObj);
		} else {
			newObj = createSObject(sObj, defaultClassName);
		}

		// Get the name field for the object
		String nameField = nameFieldMap.get(String.valueOf(sObj.getSObjectType()));
		if (nameField == null) {
			nameField = 'Name';
		}

		// Clone the object the number of times requested. Increment the name field so each record is unique
		for (Integer i = 0; i < numberOfObjects; i++) {
			SObject clonedSObj = newObj.clone(false, true);
			//clonedSObj.put(nameField, (String)clonedSObj.get(nameField) + ' ' + i);
			sObjs.add(clonedSObj);
		}
		return sObjs;
	}
	
  /**
    * @description loop through all given default fields and put them in Sobject and return it.
    * 
    * @param SObject sObj  type of record which user wants to create.
    * @param Map<String, Object> defaults default values of the given fields.
    * 
    * @return SObject[] return the instance of the SObject. for example if you pass Case as Sobject and in the map 
    * specify the value of case description and comment fields. It will set those value on case object.
    */
	private static void addFieldDefaults(SObject sObj, Map<String, Object> defaults) {
		// Loop through the map of fields and if they are null on the object, fill them.
		for (String field : defaults.keySet()) {
			if (sObj.get(field) == null) {
				sObj.put(field, defaults.get(field));
			}
		}
	}

	// When we create a list of SObjects, we need to
	private static Map<String, String> nameFieldMap = new Map<String, String> {
		'Contact' => 'LastName',
		'Case' => 'Subject'
	};

	public class TestFactoryException extends Exception {}

	// Use the FieldDefaults interface to set up values you want to default in for all objects.
	public interface FieldDefaults {
		Map<String, Object> getFieldDefaults();
	}

	// To specify defaults for objects, use the naming convention [ObjectName]Defaults.
	// For custom objects, omit the __c from the Object Name

	public class AccountDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults() {
			return new Map<String, Object> {
				'Name' => 'Test Account'+ System.currentTimeMillis()
			};
		}
	}
    
    public class ProjectDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults() {
			return new Map<String, Object> {
				'Name' => 'Test Project' + System.currentTimeMillis(),
                'TimeWatch__Start_Date__c'=> System.now(),
                'TimeWatch__End_Date__c'=> System.now() + 10,
                'TimeWatch__Budget__c'=>1000000
			};
		}
	}
    
    public class Project_TaskDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults() {
			return new Map<String, Object> {
				'Name' => 'Test task' + System.currentTimeMillis()
              
			};
		}
	}
  
    
}