/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [name]
      ,[dev_name]
      ,[Interface]
      ,[description]
      ,[IfAlias]
      ,[IF_Speed]
      ,[origin]
      ,[Percentage]
      ,[IfType]
      ,[Traffic Direction]
  FROM [CA_UIM].[dbo].[LT_Int_Util_BizHrs]
  where origin like '%maddock%' --and ifAlias like '%wan%'