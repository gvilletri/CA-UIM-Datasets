USE DBTickets
GO


INSERT INTO [dbo].[Optimal_Task_Time_Worked]

Select 
Task_Number
,Task_State
,Task_sys_created_by
,Task_parent
,Task_made_sla
,Task_sys_updated_by
,Task_opened_by
,Task_created_on
,Task_closed_at
,Task_Priority
,Task_time
,Task_opened_at
,Task_active
,Task_business_duration
,Task_sys_class_name
,Task_closed_by
,Task_contact_type
,Task_urgency
,Task_assignedTo
,Task_mod_count
,Task_sys_updated
,Task_description
,CompanyName
,Task_ResolverGroup
,Task_time_worked_user
,Task_time_worked_userId
,Task_time_worked_seconds
,Task_time_worked_sys_created
,Country
,GETDATE() as DateCreated
,Task_time_worked_user_CompanyName
,'1' as Month1
,'0' as Month2
,'0' as Month3
,'0' as Month4
,CASE WHEN DATEDIFF(WEEK, Task_created_on, Current_Timestamp) = 1 THEN '1'  ELSE '0' END AS [Week1]
,CASE WHEN DATEDIFF(WEEK, Task_created_on, Current_Timestamp) = 2 THEN '1'  ELSE '0' END AS [Week2]
,CASE WHEN DATEDIFF(WEEK, Task_created_on, Current_Timestamp) = 3 THEN '1'  ELSE '0' END AS [Week3]
,CASE WHEN DATEDIFF(WEEK, Task_created_on, Current_Timestamp) = 4 THEN '1'  ELSE '0' END AS [Week4]
,CASE WHEN DATEDIFF(WEEK, Task_created_on, Current_Timestamp) = 5 THEN '1'  ELSE '0' END AS [Week5]
,CASE WHEN DATEDIFF(WEEK, Task_created_on, Current_Timestamp) > 5 THEN '1'  ELSE '0' END AS [>Week5]
 FROM OPENQUERY (SERVICENOW,
'SELECT
task.number as Task_Number,
task.state as Task_State,
task.sys_created_by as Task_sys_created_by,
task.parent as Task_parent,
task.made_sla as Task_made_sla,
--task.u_task_for,
task.sys_updated_by as Task_sys_updated_by,
--task.opened_by,
u_openedby.[name] as Task_opened_by,
task.sys_created_on Task_created_on,
task.closed_at as Task_closed_at,
--cmdb_ci.name as Task_ci_name,
task.priority as Task_Priority,
task.time_worked as Task_time,
task.opened_at as Task_opened_at,
task.active as Task_active,
task.business_duration as Task_business_duration,
--task.assignment_group,
task.sys_class_name as Task_sys_class_name,
--task.closed_by,
u_closedby.[name] as Task_closed_by,
task.contact_type as Task_contact_type,
task.urgency as Task_urgency,
--task.company,
--task.assigned_to,
u_assignedto.[name] as Task_assignedTo,
task.sys_mod_count as Task_mod_count,
task.sys_updated_on as Task_sys_updated,
task.short_description as Task_description,
core_company.[name] as CompanyName,
sys_user_group.[name] AS Task_ResolverGroup,
--ttw.sys_created_on as Task_Time_Date_Created,
----uttw.user_name,
--ttw.time_worked as Task_time_worked,
--ttw.user,
u_time_worked.name as Task_time_worked_user,
u_time_worked.user_name as Task_time_worked_userId,
ttw.time_in_seconds as Task_time_worked_seconds,
ttw.sys_created_on as Task_time_worked_sys_created,
core_company.country as Country,
cu.[name] as Task_time_worked_user_CompanyName
from task
left join task_time_worked ttw
 on ttw.task= task.sys_id 
--left join cmdb_ci
-- on Task.cmdb_ci = cmdb_ci.[sys_id]
left join sys_user_group
 on task.assignment_group = sys_user_group.sys_id
left join sys_user u_openedby
 on task.opened_by = u_openedby.sys_id
left join sys_user u_closedby
 on task.closed_by = u_closedby.sys_id
left join sys_user u_assignedto
 on task.assigned_to = u_assignedto.sys_id
left join sys_user u_time_worked
 on ttw.user = u_time_worked.sys_id
left join core_company 
 on task.company=core_company.[sys_id]
left join core_company cu
 on u_time_worked.company=cu.[sys_id]

WHERE task.sys_created_on BETWEEN DATEADD(DAY, -15, now()) and now()
--WHERE task.sys_created_on BETWEEN DATEADD(DAY, -30, now()) and DATEADD(DAY, -16, now())
--WHERE CAST(task.sys_created_on as TIMESTAMP) BETWEEN DATEADD(DAY, -30, now()) and DATEADD(DAY, -16, now())
--order by task.sys_id desc
')  WHERE Task_time_worked_sys_created BETWEEN DATEADD(DAY, -30, getdate()) and getdate()


IF(@@RowCount>100) GOTO Succeeds

GOTO Fails
Succeeds:  
PRINT 'Warning: More than 1000 rows retrieved';
DECLARE @ArchivePeriod DATETIME = DATEADD(HOUR,-3,GETDATE());

DELETE      
      FROM       [dbo].[Optimal_Task_Time_Worked]
      where       [dbo].[Optimal_Task_Time_Worked].Date_Created < @ArchivePeriod and [dbo].[Optimal_Task_Time_Worked].Month1 = '1'

Fails:
PRINT 'Warning: zero rows count retrieved';
