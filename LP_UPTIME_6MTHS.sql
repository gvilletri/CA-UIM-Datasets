 SELECT newid() as id
,w.Task_ResolverGroup
,'Thomas Duryea Logicalis' as Task_time_worked_user_CompanyName
,CAST(SUM(w.Hours)as DECIMAL(18,3)) AS [Hours]
,LTRIM(RTRIM(w.Task_time_worked_user)) AS Task_time_worked_user
,w.companyname

,CAST( CASE WHEN w.week1 = 1 THEN 'Week1' ELSE CAST(w.week1 AS varchar(20)) END AS varchar(20)) AS Week1
,CAST( CASE WHEN w.week2 = 1 THEN 'Week2' ELSE CAST(w.week2 AS varchar(20)) END AS varchar(20)) AS Week2
,CAST( CASE WHEN w.week3 = 1 THEN 'Week3' ELSE CAST(w.week3 AS varchar(20)) END AS varchar(20)) AS Week3
,CAST( CASE WHEN w.week4 = 1 THEN 'Week4' ELSE CAST(w.week4 AS varchar(20)) END AS varchar(20)) AS Week4
--,CAST( CASE WHEN w.week2 = 1 THEN 'Week2' ELSE w.week2 END AS varchar(20))
--,CAST( CASE WHEN w.week3 = 1 THEN 'Week3' ELSE w.week3 END AS varchar(20))
--,CAST( CASE WHEN w.week4 = 1 THEN 'Week4' ELSE w.week4 END AS varchar(20))

--,CASE WHEN CAST(w.week2 AS varchar(20)) = 1 THEN 'Week1' ELSE w.week2 END
--,CASE WHEN CAST(w.week3 AS varchar(20)) = 1 THEN 'Week1' ELSE w.week3 END
--,CASE WHEN CAST(w.week4 AS varchar(20)) = 1 THEN 'Week1' ELSE w.week4 END
,w.description
,w.ticketnumber
 FROM (
SELECT newid() as id 
,ResolverGroup as [Task_ResolverGroup]
,CAST(SUM(Hours_Actual) as DECIMAL(18,3))   AS Hours
,Engineer AS [Task_time_worked_user]
,[company_name] as companyname
,week1
,week2
,week3
,week4
,Summary as description
,TicketNumber
FROM [DBTickets].[dbo].[Connect_Time_Worked]

WHERE Member_Owner_Level_Desc = 'TDL'
 
GROUP BY
ResolverGroup
,Engineer
,company_name
,week1
,week2
,week3
,week4
,summary
,TicketNumber


Union

SELECT newid() as id 
    ,[Task_ResolverGroup]
	,CAST(SUM(Task_time_worked_seconds)as DECIMAL(18,3)) /60 /60 AS Hours
	,[Task_time_worked_user]
	,companyname
    ,week1
	,week2
	,week3
	,week4
	,Task_desctription as description
	,Task_Number as TicketNumber
FROM [DBTickets].[dbo].[Optimal_Task_Time_Worked]

--WHERE Task_time_worked_user_CompanyName = 'Thomas Duryea Logicalis'
 
GROUP BY
Task_ResolverGroup
,Task_time_worked_user
,companyname
,week1
,week2
,week3
,week4
,Task_desctription
,Task_Number

Union

SELECT newid() as id 
    ,TicketResolverGroup
    ,CAST(SUM(Journal_Duration_seconds)as DECIMAL(18,3)) / 60 / 60  AS Hours
	,JournalFullName
	,companyname
	,week1
	,week2
	,week3
	,week4
	,ticketdescription as Summary
	,TicketNumber
FROM [DBTickets].[dbo].[nVisage_Time_Worked]

--WHERE Task_time_worked_user_CompanyName = 'Thomas Duryea Logicalis'
 
GROUP BY
TicketResolverGroup
,JournalFullName
,companyname
,week1
,week2
,week3
,week4
,ticketdescription
,TicketNumber


) as w

GROUP BY
w.Task_ResolverGroup
--,w.Date_Created
,w.Task_time_worked_user
,w.companyname
,w.week1
,w.week2
,w.week3
,w.week4   
,w.description
,w.TicketNumber 