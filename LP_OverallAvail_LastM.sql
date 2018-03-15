
 
SELECT w.TicketNumber
,w.SystemCreatedDate
,w.TicketOpenDate
,w.TicketDescription
,w.TicketCategory
,w.TicketSubCategory
,w.TicketSource
,w.TicketType
,w.TicketDateResolved
,w.TicketState
,w.TicketIncidentState
,w.TicketPriority
,w.TicketResolutionNotes
,w.TicketLastUpdatedDate
,w.Country
,w.CompanyName
,w.TicketResolverGroup
,w.TicketAssignedToUserId
,w.TicketAssignedTo
,w.TicketClosedBy
,GETDATE() as DateCreated
FROM OPENQUERY (SERVICENOW,
'SELECT 
--incident.company, 
DISTINCT incident.number as TicketNumber,
incident.sys_created_on SystemCreatedDate,
incident.opened_at as TicketOpenDate,
incident.[short_description] as TicketDescription,
incident.category as TicketCategory,
CONCAT(CONCAT(incident.subcategory,'' - ''),incident.u_incident_type) as TicketSubCategory,
incident.u_source as TicketSource,
''Incident'' as TicketType,
--incident.[assignment_group] as ResolverGroupID,
incident.u_resolved_at as TicketDateResolved,
incident.state as TicketState,
incident.incident_state as TicketIncidentState,
incident.priority as TicketPriority,
--incident.sys_domain,
incident.u_resolution_applied as TicketResolutionNotes,
incident.sys_updated_on as TicketLastUpdatedDate,
core_company.country as Country,
core_company.[name] as CompanyName,
sys_user_group.[name] AS TicketResolverGroup,
sys_user.user_name as TicketAssignedToUserId,
sys_user.[name] as TicketAssignedTo,
CASE WHEN su.[name] IS NULL OR su.[name] = '''' THEN (CASE WHEN sures.[name] IS NULL OR sures.[name] = '''' THEN sys_user.[name] ELSE sures.[name] END) ELSE su.[name] END as TicketClosedBy
from incident
--left join cmdb_ci
--on incident.cmdb_ci = cmdb_ci.[sys_id]
left join sys_user_group
on incident.assignment_group = sys_user_group.sys_id
left join sys_user
on incident.assigned_to = sys_user.sys_id
left join sys_user su
on incident.closed_by = su.sys_id
left join sys_user sures
on incident.u_resolved_by = sures.sys_id
--left join metric_instance mi
--on incident.[sys_id] = mi.id
left join core_company 
 on incident.company=core_company.[sys_id]
WHERE (CAST(incident.sys_created_on as TIMESTAMP) BETWEEN DATEADD(MONTH, -1, now()) and now()) and incident.incident_state != 6 and incident.incident_state != 7
OR  ((CAST(incident.sys_created_on as TIMESTAMP) BETWEEN DATEADD(DAY, -10, now()) and now()) and incident.incident_state = 6)
OR  ((CAST(incident.sys_created_on as TIMESTAMP) BETWEEN DATEADD(DAY, -10, now()) and now()) and incident.incident_state = 7)
') as w

where w.CompanyName like '%Patrick%'
order by w.TicketNumber desc