/****** Script for SelectTopNRows command from SSMS  ******/
SELECT
      c.Company_Name
      ,c.PhoneNbr
      ,c.PhoneNbr_Fax
      ,c.Website_URL
      ,c.Account_Nbr
      ,c.Last_Update
      ,c.Updated_By
      ,c.Date_Entered
      ,c.Tax_ID
	  ,c.Company_RecID


  FROM [cwwebapp_td].[dbo].[Company] c

  --SELECT dateadd(month, datediff(month, 0, getdate()) - 24, 0)
  --SELECT dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0)))

  WHERE c.Company_RecID IN
  (SELECT   CAST([Company_RecID] AS varchar(20))
  FROM [cwwebapp_td].[dbo].[SR_Service]
  WHERE CAST(Date_Entered as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 12,0) and GETDATE()
  GROUP BY [Company_RecID])

AND  c.Company_RecID NOT IN(
  SELECT   [Company_RecID]
  FROM [cwwebapp_td].[dbo].[SR_Service]
  WHERE CAST(Date_Entered as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 12,0) and GETDATE() AND Summary like '%NMS Message%'
  GROUP BY [Company_RecID])

  --WHERE  CAST(c.Date_Entered as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 36,0) and GETDATE() AND Company_NAME NOT LIKE '%X-%'
  ORDER BY Company_Name ASC
