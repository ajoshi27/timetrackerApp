({
    
	loadTimeEntry : function(component,event,helper) {
		var action = component.get("c.getTimeEntry");
        action.setParams({
        	taskId : component.get("v.recordId")
        });
    	
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                
                component.set("v.timeEntry", response.getReturnValue());
                component.set("v.clocktimer", 0);
                this.setTimer(component,event,helper);
              
            } else if (response.getState() === "ERROR") {
                component.set("v.message", response.getError());
            } 
             
        });
    
        $A.enqueueAction(action);
	},
    setTimer : function(component,event,helper) {
        
        var timeEntry = component.get("v.timeEntry");
        var div = component.find("time").getElement();
        
        var id = 'load';
        if(typeof event.target != "undefined"){
            id = event.target.id;
        }
        
        var	clsStopwatch = function() {
            
            var totalTimeSpent = (timeEntry? timeEntry.TimeWatch__Total_time_spent_Millis__c : 0);
            var	now	= function() {
                return (new Date()).getTime();
            };
            
            if(timeEntry!=null && timeEntry.TimeWatch__Status__c=='Start'){
                totalTimeSpent = timeEntry.TimeWatch__Total_time_spent_Millis__c + (now() - timeEntry.TimeWatch__Start_Time_Millis__c);
            }
            
            // Private vars
            var	startAt	= startAt || 0;	// Time of last start / resume. (0 if not running)
            var	lapTime	= totalTimeSpent || 0;	// Time on the clock when last stopped in milliseconds

            // Public methods
            // Start or resume
            this.start = function() {
                helper.startTimer(component,event);
                startAt	= startAt ? startAt : now();
            };

            // Stop or pause
            this.stop = function() {
                // If running, update elapsed time otherwise keep it
                lapTime	= startAt ? lapTime + now() - startAt : lapTime;
                startAt	= 0; // Paused
                helper.stopTimer(component,event,lapTime);
            };
			
            this.initLoad = function() {
                startAt	= startAt ? startAt : now();
            };
            
            // Reset
            this.reset = function() {
                lapTime = startAt = 0;
                component.set("v.timeEntry", null);
            };

            // Duration
            this.time = function() {
               return lapTime + (startAt ? now() - startAt : 0);
            };
           
            
        };

        var stopwatch = component.get("v.stopwatch");
        var x = stopwatch || new clsStopwatch();
        if(!stopwatch){
        	component.set("v.stopwatch", x);
        }

        
        function load(){
            
            if(timeEntry!=null && timeEntry.TimeWatch__Status__c=='Start'){
                
               var clocktimer = setInterval(update, 1);
               component.set("v.clocktimer", clocktimer);
               x.initLoad();
            }else{
            	update();
            }
        }
        

        function update() {
            
            div.innerHTML = "Time: " + helper.formatTime(x.time());
        }
        
   		switch(id){
			
            case "start":
                var clocktimer = setInterval(update, 1);
                component.set("v.clocktimer", clocktimer);
				x.start();
                break;
            case "stop":
                x.stop();
                var clocktimer = component.get("v.clocktimer");
                clearInterval(clocktimer);
                break;
            case "load":
                load();
                break;
            case "newtime":
                x.stop();
                x.reset();
                var clocktimer = setInterval(update, 1);
                component.set("v.clocktimer", clocktimer);
				x.start();
                
                break;
            default:
                stop();
                break;
        }
        
    },
    startTimer : function(component,event) {
        var timeEntry = component.get("v.timeEntry");
        
        var action = component.get("c.start");
        action.setParams({
            taskId : component.get("v.recordId"),
            timeEntryId : (timeEntry? timeEntry.Id : null)
        });
        
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                
                component.set("v.timeEntry", response.getReturnValue());
                component.set("v.clocktimer", 0);
               
            }else if (response.getState() === "ERROR") {
                component.set("v.message", response.getError());
            }
            
        });
        
        $A.enqueueAction(action);
    },
    stopTimer : function(component,event,lapTime) {
        var timeEntry = component.get("v.timeEntry");
        
        var action = component.get("c.stop");
        action.setParams({
            timeEntryId : (timeEntry? timeEntry.Id : null),
            laptime : lapTime
        });
        
        action.setCallback(this, function(response) {
            if (response.getState() === "ERROR") {
                component.set("v.message", response.getError());
            } 
            
        });
        
        $A.enqueueAction(action);
    },
    pad : function (num, size) {
            var s = "0000" + num;
            return s.substr(s.length - size);
    },
    formatTime : function (time) {
            var h = 0;
			var m = 0;
			var s = 0;
			var ms = 0;
            var newTime = '';

            h = Math.floor( time / (60 * 60 * 1000) );
            time = time % (60 * 60 * 1000);
            m = Math.floor( time / (60 * 1000) );
            time = time % (60 * 1000);
            s = Math.floor( time / 1000 );
            ms = time % 1000;

            newTime = this.pad(h, 2) + ':' + this.pad(m, 2) + ':' + this.pad(s, 2) + ':' + this.pad(ms, 3);
            return newTime;
    }
})