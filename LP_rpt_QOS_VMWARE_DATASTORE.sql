/*
--declare @RNTABLE VARCHAR(50) = (Select Distinct r_table from S_QOS_DATA SQD
--                      JOIN CM_CONFIGURATION_ITEM_METRIC CIM
--                      ON SQD.ci_metric_id = CIM.ci_metric_id
--                      Where CIM.ci_metric_type = '11.1:3');

--declare @METRIC_DESC VARCHAR(100) = (Select * FROM CM_CONFIGURATION_ITEM_METRIC_DEFINITION CIMD
--                      Where CIMD.met_description LIKE '%Utilization%');

--declare @HNTABLE VARCHAR(50) =  (Select Distinct h_table from S_QOS_DATA SQD
--                      JOIN CM_CONFIGURATION_ITEM_METRIC CIM
--                      ON SQD.ci_metric_id = CIM.ci_metric_id
--                      Where CIM.ci_metric_type = '11.1:3' );

--declare @Origin VARCHAR (50) = (Select Distinct CS.origin from  CM_COMPUTER_SYSTEM CS);
*/


declare @startDate datetime = dateadd(month, datediff(month, 0, getdate()) - 1, 0); -- 1st day of previous month
declare @endDate datetime = dateadd(millisecond, -3, dateadd(month, 1, @startdate)); -- 3 milliseconds before current month starts

insert into dbo.LT_Int_Util_BizHrs 
select name,dev_name,Interface,description,IfAlias,IF_Speed,origin,SUM(samplevalue)/COUNT(samplevalue) AS Percentage,IfType,'Egress' AS "Traffic Direction" from (

SELECT QD.[probe],CS.dedicated,CS.[description] ,CS.[name],D.dev_name, D.dev_ip,ci_name,cia.[description] AS [Interface], RN.sampletime, RN.samplevalue, CIA.IfType, CS.origin, 
CIA.IfAdminStatus[AdminStatus],CIA.IfAlias,CIA.IfIndex,CIA.IfMTU,CIA.IfOperStatus
--,CIA.IfPhysAddress,CIA.IfType, CIA.instanceName,convert(numeric(38,0),cast(CIA.NomSpeedInBitsPerSec AS float)) AS [IF_Speed],CIA.Origin,CIA.typeName
,CIA.IfPhysAddress, CIA.instanceName,convert(numeric(38,0),cast(CIA.NomSpeedInBitsPerSec AS float)) AS [IF_Speed],CIA.typeName
FROM CM_COMPUTER_SYSTEM CS 
      JOIN CM_DEVICE D
            ON CS.cs_id = D.cs_id 
   JOIN CM_CONFIGURATION_ITEM CI
            ON D.dev_id = CI.dev_id 
   JOIN CM_CONFIGURATION_ITEM_METRIC CIM
            ON CI.ci_id = CIM.ci_id 
   INNER JOIN CM_CONFIGURATION_ITEM_ATTRIBUTE 
   pivot (MIN (ci_attr_value) 
              for ci_attr_key in ([description],[IfAdminStatus],[IfAlias],[IfIndex],[IfMTU],[IfOperStatus],[IfPhysAddress],
                    [IfType],[instanceName],[NomSpeedInBitsPerSec],[Origin],[typeName])) as CIA
            ON CI.ci_id = CIA.ci_id 
  JOIN S_QOS_DATA QD
            ON  QD.ci_metric_id = CIM.ci_metric_id and CIM.ci_metric_type = '11.1:3'        -- 11.1:3 = UtilizationOut
  -- JOIN S_QOS_SNAPSHOT QS
            --ON QD.table_id = QS.table_id
  JOIN RN_QOS_DATA_0100 AS RN
            ON QD.table_id = RN.table_id
WHERE RN.sampletime between @startDate and @endDate 
and DATEPART(hh,RN.sampletime) >= 7 AND DATEPART(hh,RN.sampletime) <= 17 
                 -- gets the hour of the day from the datetime
AND DATEPART(dw,RN.sampletime) >= 3 AND DATEPART(dw,RN.sampletime) <= 5 
                 -- gets the day of the week from the datetime
and CIA.IfIndex < 4002
and CIA.IfAdminStatus = 1 
and CIA.ifoperstatus =1 
--and CIA.iftype not in ('53','24','1','135','7','160','131','71','37','117','23','209','94','103','104')
and CIA.ifalias != ''
--and CS.origin = 'Ventia'
--ORDER by D.dev_name, CI.ci_name 
--group by
--ci_name,CS.[name],QD.[probe],CS.dedicated,CS.[description] , D.dev_ip,RN.samplevalue/**cia.[description], /**RN.sampletime,**/  CIA.IfType, CS.origin, 
--CIA.IfAdminStatus,CIA.IfAlias,CIA.IfIndex,CIA.IfMTU,CIA.IfOperStatus
--,CIA.IfPhysAddress, CIA.instanceName,convert(numeric(38,0),CIA.NomSpeedInBitsPerSec,CIA.typeName**/

UNION

SELECT QD.[probe],CS.dedicated,CS.[description] ,CS.[name],D.dev_name, D.dev_ip,ci_name,cia.[description] AS [Interface], HN.sampletime,HN.sampleavg, CIA.IfType, CS.origin, 
CIA.IfAdminStatus[AdminStatus],CIA.IfAlias,CAST(CIA.IfIndex AS varchar(50)),CIA.IfMTU,CIA.IfOperStatus
--,CIA.IfPhysAddress,CIA.IfType, CIA.instanceName,convert(numeric(38,0),cast(CIA.NomSpeedInBitsPerSec AS float)) AS [IF_Speed],CIA.Origin,CIA.typeName
,CIA.IfPhysAddress, CIA.instanceName,convert(numeric(38,0),cast(CIA.NomSpeedInBitsPerSec AS float)) AS [IF_Speed],CIA.typeName
FROM CM_COMPUTER_SYSTEM CS 
      JOIN CM_DEVICE D
            ON CS.cs_id = D.cs_id 
   JOIN CM_CONFIGURATION_ITEM CI
            ON D.dev_id = CI.dev_id 
   JOIN CM_CONFIGURATION_ITEM_METRIC CIM
            ON CI.ci_id = CIM.ci_id 
   INNER JOIN CM_CONFIGURATION_ITEM_ATTRIBUTE 
   pivot (MIN (ci_attr_value) 
              for ci_attr_key in ([description],[IfAdminStatus],[IfAlias],[IfIndex],[IfMTU],[IfOperStatus],[IfPhysAddress],
                    [IfType],[instanceName],[NomSpeedInBitsPerSec],[Origin],[typeName])) as CIA
            ON CI.ci_id = CIA.ci_id 
  JOIN S_QOS_DATA QD
            ON QD.ci_metric_id = CIM.ci_metric_id and CIM.ci_metric_type = '11.1:3'        -- 11.1:3 = UtilizationOut
  -- JOIN S_QOS_SNAPSHOT QS
            --ON QD.table_id = QS.table_id
  JOIN HN_QOS_DATA_0100 AS HN
            ON QD.table_id = HN.table_id

WHERE HN.sampletime between @startDate and @endDate 
and DATEPART(hh,HN.sampletime) >= 7 AND DATEPART(hh,HN.sampletime) <= 17 
                 -- gets the hour of the day from the datetime
AND DATEPART(dw,HN.sampletime) >= 3 AND DATEPART(dw,HN.sampletime) <= 5 
                 -- gets the day of the week from the datetime

and CIA.IfIndex < 4002
and CIA.IfAdminStatus = 1 
and CIA.ifoperstatus =1 
--and CIA.iftype not in (53,24,1,135,7,160,131,71,37,117,23,209,94,103,104)
and CIA.ifalias != ''
--and CS.origin = 'Ventia'
--ORDER by D.dev_name, CI.ci_name

) as Tbl where iftype not in (53,24,1,135,7,160,131,71,37,117,23,209,94,103,104,33)

group by Interface,name,dev_name,origin,description,IF_Speed,IfAlias,IfType

order by Percentage desc

GO

declare @startDate datetime = dateadd(month, datediff(month, 0, getdate()) - 1, 0); -- 1st day of previous month
declare @endDate datetime = dateadd(millisecond, -3, dateadd(month, 1, @startdate)); -- 3 milliseconds before current month starts

insert into dbo.LT_Int_Util_BizHrs 

select name,dev_name,Interface,description,IfAlias,IF_Speed,origin,SUM(samplevalue)/COUNT(samplevalue) AS Percentage,IfType,'Ingress' AS "Traffic Direction" from (

SELECT QD.[probe],CS.dedicated,CS.[description] ,CS.[name],D.dev_name, D.dev_ip,ci_name,cia.[description] AS [Interface], RN.sampletime, RN.samplevalue, CIA.IfType, CS.origin, 
CIA.IfAdminStatus[AdminStatus],CIA.IfAlias,CIA.IfIndex,CIA.IfMTU,CIA.IfOperStatus
--,CIA.IfPhysAddress,CIA.IfType, CIA.instanceName,convert(numeric(38,0),cast(CIA.NomSpeedInBitsPerSec AS float)) AS [IF_Speed],CIA.Origin,CIA.typeName
,CIA.IfPhysAddress, CIA.instanceName,convert(numeric(38,0),cast(CIA.NomSpeedInBitsPerSec AS float)) AS [IF_Speed],CIA.typeName
FROM CM_COMPUTER_SYSTEM CS 
      JOIN CM_DEVICE D
            ON CS.cs_id = D.cs_id 
   JOIN CM_CONFIGURATION_ITEM CI
            ON D.dev_id = CI.dev_id 
   JOIN CM_CONFIGURATION_ITEM_METRIC CIM
            ON CI.ci_id = CIM.ci_id 
   INNER JOIN CM_CONFIGURATION_ITEM_ATTRIBUTE 
   pivot (MIN (ci_attr_value) 
              for ci_attr_key in ([description],[IfAdminStatus],[IfAlias],[IfIndex],[IfMTU],[IfOperStatus],[IfPhysAddress],
                    [IfType],[instanceName],[NomSpeedInBitsPerSec],[Origin],[typeName])) as CIA
            ON CI.ci_id = CIA.ci_id 
  JOIN S_QOS_DATA QD
            ON  QD.ci_metric_id = CIM.ci_metric_id and CIM.ci_metric_type = '11.1:2'        -- 11.1:2 = UtilizationIn
  -- JOIN S_QOS_SNAPSHOT QS
            --ON QD.table_id = QS.table_id
  JOIN RN_QOS_DATA_0099 AS RN
            ON QD.table_id = RN.table_id
WHERE RN.sampletime between @startDate and @endDate 
and DATEPART(hh,RN.sampletime) >= 7 AND DATEPART(hh,RN.sampletime) <= 17 
                 -- gets the hour of the day from the datetime
AND DATEPART(dw,RN.sampletime) >= 3 AND DATEPART(dw,RN.sampletime) <= 5 
                 -- gets the day of the week from the datetime
and CIA.IfIndex < 4002
and CIA.IfAdminStatus = 1 
and CIA.ifoperstatus =1 
--and CIA.iftype not in ('53','24','1','135','7','160','131','71','37','117','23','209','94','103','104')
and CIA.ifalias != ''
--and CS.origin = 'Ventia'
--ORDER by D.dev_name, CI.ci_name 
--group by
--ci_name,CS.[name],QD.[probe],CS.dedicated,CS.[description] , D.dev_ip,RN.samplevalue/**cia.[description], /**RN.sampletime,**/  CIA.IfType, CS.origin, 
--CIA.IfAdminStatus,CIA.IfAlias,CIA.IfIndex,CIA.IfMTU,CIA.IfOperStatus
--,CIA.IfPhysAddress, CIA.instanceName,convert(numeric(38,0),CIA.NomSpeedInBitsPerSec,CIA.typeName**/

UNION

SELECT QD.[probe],CS.dedicated,CS.[description] ,CS.[name],D.dev_name, D.dev_ip,ci_name,cia.[description] AS [Interface], HN.sampletime,HN.sampleavg, CIA.IfType, CS.origin, 
CIA.IfAdminStatus[AdminStatus],CIA.IfAlias,CAST(CIA.IfIndex AS varchar(50)),CIA.IfMTU,CIA.IfOperStatus
--,CIA.IfPhysAddress,CIA.IfType, CIA.instanceName,convert(numeric(38,0),cast(CIA.NomSpeedInBitsPerSec AS float)) AS [IF_Speed],CIA.Origin,CIA.typeName
,CIA.IfPhysAddress, CIA.instanceName,convert(numeric(38,0),cast(CIA.NomSpeedInBitsPerSec AS float)) AS [IF_Speed],CIA.typeName
FROM CM_COMPUTER_SYSTEM CS 
      JOIN CM_DEVICE D
            ON CS.cs_id = D.cs_id 
   JOIN CM_CONFIGURATION_ITEM CI
            ON D.dev_id = CI.dev_id 
   JOIN CM_CONFIGURATION_ITEM_METRIC CIM
            ON CI.ci_id = CIM.ci_id 
   INNER JOIN CM_CONFIGURATION_ITEM_ATTRIBUTE 
   pivot (MIN (ci_attr_value) 
              for ci_attr_key in ([description],[IfAdminStatus],[IfAlias],[IfIndex],[IfMTU],[IfOperStatus],[IfPhysAddress],
                    [IfType],[instanceName],[NomSpeedInBitsPerSec],[Origin],[typeName])) as CIA
            ON CI.ci_id = CIA.ci_id 
  JOIN S_QOS_DATA QD
            ON QD.ci_metric_id = CIM.ci_metric_id and CIM.ci_metric_type = '11.1:2'        -- 11.1:3 = UtilizationIn
  -- JOIN S_QOS_SNAPSHOT QS
            --ON QD.table_id = QS.table_id
  JOIN HN_QOS_DATA_0099 AS HN
            ON QD.table_id = HN.table_id

WHERE HN.sampletime between @startDate and @endDate 
and DATEPART(hh,HN.sampletime) >= 7 AND DATEPART(hh,HN.sampletime) <= 17 
                 -- gets the hour of the day from the datetime
AND DATEPART(dw,HN.sampletime) >= 3 AND DATEPART(dw,HN.sampletime) <= 5 
                 -- gets the day of the week from the datetime

and CIA.IfIndex < 4002
and CIA.IfAdminStatus = 1 
and CIA.ifoperstatus =1 
--and CIA.iftype not in (53,24,1,135,7,160,131,71,37,117,23,209,94,103,104)
and CIA.ifalias != ''
--and CS.origin = 'Ventia'
--ORDER by D.dev_name, CI.ci_name

) as Tbl where iftype not in (53,24,1,135,7,160,131,71,37,117,23,209,94,103,104,33)

group by Interface,name,dev_name,origin,description,IF_Speed,IfAlias,IfType

order by Percentage desc