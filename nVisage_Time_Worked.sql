USE DBTickets
GO

INSERT INTO [dbo].[nVisage_Time_Worked]


SELECT *
FROM OPENQUERY (NVISAGE,'EXEC(''USE nVisage;
Select t.IDENTIFIER AS TicketNumber
,CAST(DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), t.CREATED_UTC) AS DATETIME) AS TicketSystemCreateDate
,CAST(DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), t.CREATED_UTC) AS DATETIME) AS TicketOpenDate
,CAST(DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), tj.CREATED_UTC) AS DATETIME) AS JournalCreateDate
--,tj.EFFECTIVE_CREATED_USERS_ID
,tj.DURATION_SECONDS AS Journal_Duration_seconds
--,utj.CUSTOMER_ID
--,utj.FULL_NAME AS Journal_Full_Name
,SUBSTRING(utj.FULL_NAME, CHARINDEX(''''- '''', utj.FULL_NAME) + 1, LEN(utj.FULL_NAME)) AS JournalFullName
,tj.DESCRIPTION AS JournalDescription
,tj.INTERNAL as JournalInternalFlag
--,tj.REAL_CREATED_USERS_ID
,t.NAME AS TicketDescription
,tcc.[NAME] AS TicketCategory
,tcc.[NAME] AS TicketSubCategory
,ts.NAME AS TicketSource
,t.TYPE AS TicketType
,CAST(DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), tc.CREATED_UTC) AS DATETIME) AS TicketDateResolved
,t.TICKETSTATE AS TicketState
,t.TICKETSTATE AS TicketIncidentState
,t.PRIORITY AS TicketPriority
,tc.Description AS TicketResolutionNotes
,CAST(DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), t.MODIFIED_UTC)  AS DATETIME) AS TicketLastUpdatedDate 
,''''AU'''' AS Country
,c.COMPANY_NAME AS CompanyName
,ttn.NAME AS TicketResolverGroup
, u.USER_NAME AS "TicketAssignedToUserId"
,CASE WHEN DATEDIFF(DAY, DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), tj.CREATED_UTC), Current_Timestamp) <= 30 THEN ''''1''''  ELSE ''''0'''' END AS [Month1]
,CASE WHEN DATEDIFF(DAY, DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), tj.CREATED_UTC), Current_Timestamp) > 30 AND DATEDIFF(DAY, tj.CREATED_UTC, Current_Timestamp) <= 60 THEN ''''1''''  ELSE ''''0'''' END AS [Month2]
,CASE WHEN DATEDIFF(DAY, DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), tj.CREATED_UTC), Current_Timestamp) > 60 AND DATEDIFF(DAY, tj.CREATED_UTC, Current_Timestamp) <= 90 THEN ''''1''''  ELSE ''''0'''' END AS [Month3]
,CASE WHEN DATEDIFF(DAY, DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), tj.CREATED_UTC), Current_Timestamp) > 90 THEN ''''1''''  ELSE ''''0'''' END AS [Month4]
,GETDATE() AS DATE_CREATED
,u.FULL_NAME AS TicketAssignedTo
,CASE WHEN DATEDIFF(Week, DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), tj.CREATED_UTC), Current_Timestamp) = 1 THEN ''''1''''  ELSE ''''0'''' END AS [Week1]
,CASE WHEN DATEDIFF(Week, DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), tj.CREATED_UTC), Current_Timestamp) = 2 THEN ''''1''''  ELSE ''''0'''' END AS [Week2]
,CASE WHEN DATEDIFF(Week, DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), tj.CREATED_UTC), Current_Timestamp) = 3 THEN ''''1''''  ELSE ''''0'''' END AS [Week3]
,CASE WHEN DATEDIFF(Week, DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), tj.CREATED_UTC), Current_Timestamp) = 4 THEN ''''1''''  ELSE ''''0'''' END AS [Week4]
,CASE WHEN DATEDIFF(Week, DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), tj.CREATED_UTC), Current_Timestamp) = 5 THEN ''''1''''  ELSE ''''0'''' END AS [Week5]
,CASE WHEN DATEDIFF(Week, DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), tj.CREATED_UTC), Current_Timestamp) > 5 THEN ''''1''''  ELSE ''''0'''' END AS [>Week5]

from dbo.TICKETJOURNAL tj
join dbo.TICKET t
      on tj.TICKET_ID = t.ID
join dbo.SITES s
      on s.ID = t.SITES_ID
join dbo.CUSTOMER c
      on c.ID = s.CUSTOMER_ID
join dbo.SERVICEPROVIDER spl
      on spl.ID = s.SERVICEPROVIDER_ID
left join dbo.ASSETCONFIG ac
        on ac.ID = t.ASSETCONFIG_ID
left join dbo.ASSETCONFIG ap
        on ap.PARENT_ID = ac.ID
left join dbo.ASSET a
        on a.ID = ac.SOURCE_ID
left join dbo.TICKET_ASSET ta
        on ta.ID = t.IDENTIFIER
left join dbo.DEVICES d
        on d.DEVICE_ID =ta.source_ID
left join dbo.DEVICETYPE dt
        on dt.ID=d.DEVICE_TYPE_ID
left join dbo.TICKET_TICKETTEAM tt
      on t.IDENTIFIER=tt.TICKET_ID AND tt.ASSOCIATION =''''Owner''''
left join dbo.TICKETTEAM ttn
        on ttn.ID=tt.TICKETTEAM_ID
left join dbo.TICKETSOURCE ts
           on ts.ID = t.TICKETSOURCE_ID
left join dbo.TICKET_USERS tu
        on t.IDENTIFIER=tu.TICKET_ID AND tu.ASSOCIATION =''''Owner''''
left join dbo.USERS u
        on u.ID=tu.USERS_ID
left join [dbo].[TICKETCLOSURE] tc
           on tc.TICKET_ID=t.IDENTIFIER
left join [dbo].[TICKET_TICKETCLASSIFICATION] ttc
        on ttc.TICKET_ID=t.IDENTIFIER
left join [dbo].[TICKETCLASSIFICATION] tcc
        on tcc.ID=ttc.TICKETCLASSIFICATION_ID
left join dbo.USERS utj
        on utj.ID=tj.EFFECTIVE_CREATED_USERS_ID

WHERE 
(CAST(tj.CREATED_UTC as TIMESTAMP) BETWEEN DATEADD(DAY, -120, GETUTCDATE()) and GETUTCDATE() AND spl.NAME = ''''TDLogicalis''''
AND t.TICKETSTATE not in (''''Resolved'''',''''ResolvedAutoClose'''',''''Closed'''',''''Completed'''',''''Cancelled'''',''''Failed'''') 
AND ttn.NAME not in (''''Singapore GNC Team'''',''''Hong Kong GNC Team'''',''''SG MIS Team'''',''''China GNC Team''''))
--OR (CAST(t.MODIFIED_UTC as TIMESTAMP) BETWEEN DATEADD(DAY, -14, GETUTCDATE()) and GETUTCDATE() 
--AND spl.NAME = ''''TDLogicalis'''' 
--AND t.TICKETSTATE in (''''Resolved'''',''''Closed'''',''''Completed'''',''''Cancelled'''',''''Failed'''') 
--AND ttn.NAME not in (''''Singapore GNC Team'''',''''Hong Kong GNC Team'''',''''SG MIS Team'''',''''China GNC Team''''))
order by t.IDENTIFIER desc
'')')


IF(@@RowCount>1000) GOTO Succeeds

GOTO Fails
Succeeds:  
PRINT 'Warning: More than 1000 rows retrieved';
DECLARE @ArchivePeriod DATETIME = DATEADD(HOUR,-3,GETDATE());

DELETE      
      FROM       [dbo].[nVisage_Time_Worked]
      where       [dbo].[nVisage_Time_Worked].Date_Created < @ArchivePeriod 

Fails:
PRINT 'Warning: zero rows count retrieved';