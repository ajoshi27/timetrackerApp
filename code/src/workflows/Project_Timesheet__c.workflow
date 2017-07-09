<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>TimeTracker_Notify_user_about_timesheet_approval</fullName>
        <description>TimeTracker - Notify user about timesheet approval</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>TimeTracker_Email_Templates/Time_sheet_Approval_notification</template>
    </alerts>
    <alerts>
        <fullName>TimeTracker_Notify_user_about_timesheet_rejection</fullName>
        <description>TimeTracker - Notify user about timesheet rejection</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>TimeTracker_Email_Templates/Time_sheet_Rejection_notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Time_Tracker_Mark_Timesheet_as_approve</fullName>
        <description>Mark the time sheet as approved</description>
        <field>IsApproved__c</field>
        <literalValue>1</literalValue>
        <name>Time Tracker - Mark Timesheet as approve</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
