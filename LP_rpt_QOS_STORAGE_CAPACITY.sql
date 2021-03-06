/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 --csa.[cs_id]
      --,csa.[cs_attr_key]
      csa.[cs_attr_value]
	  ,cs.os_type
	  ,cs.os_name
  FROM [CA_UIM].[dbo].[CM_COMPUTER_SYSTEM_ATTR] csa
       JOIN [dbo].[CM_COMPUTER_SYSTEM] cs
	   on cs.cs_id = csa.cs_id
  where csa.cs_attr_key like '%model%'  and cs.os_type not like '%windows%'
  Group by csa.[cs_attr_value],cs.os_name,cs.os_type
  order by cs.os_name,csa.[cs_attr_value]