USE DBTickets
GO
TRUNCATE TABLE [dbo].[Connect_Time_Worked]
GO

INSERT INTO dbo.Connect_Time_Worked 

SELECT *
FROM OPENQUERY (TDEDCCWSQL01,'EXEC(''USE cwwebapp_td;
SELECT

   t.time_recID AS [TimeRecid]
   ,t.Last_Update AS [Last_Updated]
  ,t.SR_Service_RecID as [Ticket_Number]
  ,m.Member_ID AS [Member_ID]
  ,Concat(m.First_Name, '''' '''',m.Last_Name) as [Engineer]
  ,m.First_Name AS [First_Name]
  ,m.Last_Name AS [Last_Name]
  ,c.Company_Name AS [Company_Name]
  ,sr.team_name AS [ResolverGroup]
  --,CONCAT(ms.First_Name,'''' '''',ms.Last_name) AS [Ticket_Assigned_To]
  ,''''Not Applicable'''' AS [Ticket_Assigned_To]
  ,ol.Description as [Office_Location]
  ,t.Hours_Bill as [Time_Worked_Hours]
  ,t.Notes AS [Customer_Notes]
  ,t.Internal_Note
  ,ts.Description [Time_Status]
  ,t.Hours_Actual AS [Hours_Actual]
  ,agr.AGR_Name AS [Agreement]
  ,wr.Description AS [Work_Role]
  ,wt.Description AS [Work_Type]
  ,CASE 
  WHEN t.Billable_Flag = 1 AND t.Invoice_Flag = 1 THEN ''''B'''' 
  WHEN t.Billable_Flag = 0 AND t.Invoice_Flag = 0 THEN ''''NB'''' 
  WHEN t.Billable_Flag = 0 AND t.Invoice_Flag = 1 THEN ''''NC'''' 
  WHEN t.Billable_Flag = 1 AND t.Invoice_Flag = 0 THEN ''''ND''''
  END AS [Billing_Status] 
  ,CASE 
  WHEN t.Billable_Flag = 1 AND t.Invoice_Flag = 1 THEN ''''Billable'''' 
  WHEN t.Billable_Flag = 0 AND t.Invoice_Flag = 0 THEN ''''No Charge'''' 
  WHEN t.Billable_Flag = 0 AND t.Invoice_Flag = 1 THEN ''''Do Not Bill'''' 
  WHEN t.Billable_Flag = 1 AND t.Invoice_Flag = 0 THEN ''''No Default''''
  END AS [Billing_Status_Desc] 
  ,ISNULL(CASE WHEN t.Billable_Flag = 1 AND t.Invoice_Flag = 1 THEN t.Hours_Invoiced END,0) AS [Hours_B]
  ,ISNULL(CASE WHEN t.Billable_Flag = 0 AND t.Invoice_Flag = 0 THEN t.Hours_Invoiced END,0) AS [Hours_NB]
  ,ISNULL(CASE WHEN t.Billable_Flag = 0 AND t.Invoice_Flag = 1 THEN t.Hours_Invoiced END,0) AS [Hours_NC]
  ,CASE WHEN wt.Utilization_Flag = 1 THEN ''''Y'''' ELSE ''''N'''' END AS [Utilized]
  ,ISNULL(CASE WHEN wt.Utilization_Flag = 1 THEN t.Hours_Actual END,0) AS [Hours_Utilized]
  ,ISNULL(CASE WHEN wt.Utilization_Flag = 0 THEN t.Hours_Actual END,0) AS [Hours_Non_utilized]
  ,ISNULL(t.Agr_Hours,0) AS [Hours_Agreement]
  ,t.Hourly_Rate AS [Hourly_Rate]
  ,CONVERT(decimal(9,2),t.Hours_Invoiced * t.Hourly_Rate * t.Billable_Flag) AS [Billable_Amount]
  ,ISNULL(t.Adjustment,0) AS [Adjustment]
  ,ISNULL(t.Agr_Amount,0) AS [Agreement_Amount]
  ,CASE WHEN DATEDIFF(DAY, t.Date_Start, Current_Timestamp) <= 30 THEN ''''1''''  ELSE ''''0'''' END AS [Month1]
  ,CASE WHEN DATEDIFF(DAY, t.Date_Start, Current_Timestamp) > 30 AND DATEDIFF(DAY, t.Date_Start, Current_Timestamp) <= 60 THEN ''''1''''  ELSE ''''0'''' END AS [Month2]
  ,CASE WHEN DATEDIFF(DAY, t.Date_Start, Current_Timestamp) > 60 AND DATEDIFF(DAY, t.Date_Start, Current_Timestamp) <= 90 THEN ''''1''''  ELSE ''''0'''' END AS [Month3]
  ,CASE WHEN DATEDIFF(DAY, t.Date_Start, Current_Timestamp) > 90 AND DATEDIFF(DAY, t.Date_Start, Current_Timestamp) <= 120 THEN ''''1''''  ELSE ''''0'''' END AS [Month4]
  ,olm.Description as [Member_Owner_Level_Desc]
  ,CASE WHEN DATEDIFF(WEEK, t.Date_Start, Current_Timestamp) = 1 THEN ''''1''''  ELSE ''''0'''' END AS [Week1]
  ,CASE WHEN DATEDIFF(WEEK, t.Date_Start, Current_Timestamp) = 2 THEN ''''1''''  ELSE ''''0'''' END AS [Week2]
  ,CASE WHEN DATEDIFF(WEEK, t.Date_Start, Current_Timestamp) = 3 THEN ''''1''''  ELSE ''''0'''' END AS [Week3]
  ,CASE WHEN DATEDIFF(WEEK, t.Date_Start, Current_Timestamp) = 4 THEN ''''1''''  ELSE ''''0'''' END AS [Week4]
  ,CASE WHEN DATEDIFF(WEEK, t.Date_Start, Current_Timestamp) = 5 THEN ''''1''''  ELSE ''''0'''' END AS [Week5]
  ,CASE WHEN DATEDIFF(WEEK, t.Date_Start, Current_Timestamp) > 5 THEN ''''1''''  ELSE ''''0'''' END AS [>Week5]
  ,sr.Summary
FROM dbo.Time_Entry AS t INNER JOIN
  dbo.Member AS m ON m.Member_RecID = t.Member_RecID 
  LEFT JOIN  dbo.Company AS c ON c.Company_RecID = t.Company_RecID
  LEFT JOIN  dbo.v_rpt_Service AS sr ON sr.TicketNbr = t.SR_Service_RecID
  --LEFT OUTER JOIN  Schedule AS sched ON sr.TicketNbr = sched.RecID AND sched.Close_flag = 0
 --LEFT OUTER JOIN Member as ms ON sched.Xref_Mbr_RecID = ms.Member_RecID
  LEFT JOIN dbo.Owner_Level AS ol ON ol.Owner_Level_RecID = t.Owner_Level_RecID
  LEFT JOIN dbo.Billing_Unit AS bu ON bu.Billing_Unit_RecID = t.Billing_Unit_RecID
  LEFT JOIN dbo.Activity_Type AS wt ON wt.Activity_Type_RecID = t.Activity_Type_RecID
  LEFT JOIN dbo.AGR_Header AS agr ON agr.AGR_Header_RecID = t.Agr_Header_RecID
  LEFT JOIN dbo.Activity_Class AS wr ON wr.Activity_Class_RecID = t.Activity_Class_RecID
  LEFT JOIN dbo.TE_Charge_Code AS cc ON cc.TE_Charge_Code_RecID = t.TE_Charge_Code_RecID
  LEFT JOIN dbo.TE_Status AS ts ON ts.TE_Status_ID = t.TE_Status_ID 
  LEFT JOIN dbo.Owner_Level AS olm ON olm.Owner_Level_RecID = m.Owner_Level_RecID

WHERE DATEDIFF (DAY, t.Date_Start, CURRENT_TIMESTAMP) <= 120 --and cc.Description is Null
'')')