INSERT INTO dbo.Optimal_RequestItems 

SELECT *
,GETDATE() AS DateCreated
FROM OPENQUERY (SERVICENOW,
'SELECT 
--sc_request.company, 
sc_req_item.number as TicketNumber,
sc_request.opened_at SystemCreatedDate,
sc_req_item.opened_at TicketOpenDate,
sc_req_item.short_description as TicketDescription,
sc_cat_item.name as TicketCategory,
sc_cat_item.short_description as TicketSubCategory,
sc_request.number as TicketSource,
sc_req_item.sys_class_name as TicketType,
--sc_req_item..[assignment_group] as ResolverGroupID,
sc_req_item.closed_at as TicketDateResolved,
sc_req_item.state as TicketState,
sc_request.request_state as TicketIncidentState,
sc_req_item.priority as TicketPriority,
--sc_request.sys_domain,
sc_request.close_notes as TicketResolutionNotes,
sc_req_item.sys_updated_on as TicketLastUpdatedDate,
core_company.country as Country,
core_company.[name] as CompanyName,
sys_user_group.[name] AS TicketResolverGroup,
sys_user.user_name as TicketAssignedToUserId,
sys_user.[name] as TicketAssignedTo,
su.[name] as TicketClosedBy
from sc_req_item
left join sc_request
on sc_req_item.request=sc_request.[sys_id]
--left join cmdb_ci
--on sc_request.cmdb_ci = cmdb_ci.[sys_id]
left join sys_user_group
on sc_req_item.assignment_group = sys_user_group.sys_id
left join sys_user
on sc_req_item.assigned_to = sys_user.sys_id
left join sys_user su
on sc_req_item.closed_by = su.sys_id
left join sc_cat_item
on sc_req_item.cat_item=sc_cat_item.[sys_id]
----left join metric_instance mi
----on sc_request.[sys_id] = mi.id
left join core_company 
 on sc_request.company=core_company.[sys_id]
WHERE (CAST(sc_req_item.sys_created_on as TIMESTAMP) BETWEEN DATEADD(Month, -24, now()) and now()) and sc_req_item.state != 3 and sc_req_item.state != 4 and sc_req_item.state != 7 and core_company.country is not NULL
OR  ((CAST(sc_req_item.closed_at as TIMESTAMP) BETWEEN DATEADD(DAY, -92, now()) and now()) and sc_req_item.state = 3 and core_company.country is not NULL)
OR  ((CAST(sc_req_item.closed_at as TIMESTAMP) BETWEEN DATEADD(DAY, -92, now()) and now()) and sc_req_item.state = 4 and core_company.country is not NULL)
OR  ((CAST(sc_req_item.closed_at as TIMESTAMP) BETWEEN DATEADD(DAY, -92, now()) and now()) and sc_req_item.state = 7 and core_company.country is not NULL)
')

IF(@@RowCount>100) GOTO Succeeds

GOTO Fails
Succeeds:  
PRINT 'Warning: More than 1000 rows retrieved';
DECLARE @ArchivePeriod DATETIME = DATEADD(MINUTE,-30,GETDATE());

DELETE      
      FROM        [dbo].[Optimal_RequestItems]
      where       [dbo].[Optimal_RequestItems].DateCreated < @ArchivePeriod

Fails:
PRINT 'Warning: zero rows count retrieved';
