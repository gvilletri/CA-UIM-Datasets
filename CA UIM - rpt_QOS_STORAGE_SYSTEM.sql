
declare @startDate datetime = dateadd(month, datediff(month, 0, getdate()) - 2, 0); -- 1st day of previous month
declare @endDate datetime = dateadd(millisecond, -3, dateadd(month, 2, @startdate)); -- 3 milliseconds before current month starts

TRUNCATE TABLE [CA_UIM].[dbo].[LT_rpt_QOS_STORAGE_SYSTEM]

GO

INSERT INTO [CA_UIM].[dbo].[LT_rpt_QOS_STORAGE_SYSTEM]
	
select w.probe
,w.dedicated
,w.description 
,w.name
,w.dev_name
,w.dev_ip
,w.ci_name
,CAST(SUM(w.samplevalue)/COUNT(w.Samplerate) AS decimal(18,4)) AS AVERAGE_QOS_VALUE
,w.origin
,ThisMonth
,LastMonth
,Last2Month
,QOSTYPE
FROM 
( 

/** RN_QOS_DATA_0311 QOS_STORAGE_CPU_UTILIZATION   5.1.3:4      NULL **/

SELECT 
QD.probe,CS.dedicated,CS.description ,CS.name,D.dev_name,D.dev_ip,CI.ci_name,RN.samplevalue,RN.Samplerate,CS.origin,RN.sampletime
,CASE WHEN CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 1, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0))) THEN '1'  ELSE '0' END AS [ThisMonth]
,CASE WHEN CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 2, dateadd(month, datediff(month, 0, getdate()) - 3, 0))) THEN '1'  ELSE '0' END AS [LastMonth]
,CASE WHEN CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 3, 0) and dateadd(millisecond, -3, dateadd(month, 3, dateadd(month, datediff(month, 0, getdate()) - 5, 0))) THEN '1'  ELSE '0' END AS [Last2Month]
,'QOS_STORAGE_CPU_UTILIZATION' AS QOSTYPE

FROM CM_COMPUTER_SYSTEM CS
      JOIN CM_DEVICE D
            ON CS.cs_id = D.cs_id
   JOIN CM_CONFIGURATION_ITEM CI
            ON D.dev_id = CI.dev_id
   JOIN CM_CONFIGURATION_ITEM_METRIC CIM
            ON CI.ci_id = CIM.ci_id
  JOIN S_QOS_DATA QD
            ON  QD.ci_metric_id = CIM.ci_metric_id and CIM.ci_metric_type = '5.1.3:4'       -- 5.1.3:4 = QOS_STORAGE_CPU_UTILIZATION
  -- JOIN S_QOS_SNAPSHOT QS
            --ON QD.table_id = QS.table_id
  JOIN RN_QOS_DATA_0311 AS RN
            ON QD.table_id = RN.table_id

WHERE CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 3, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0)))

UNION
SELECT 
QD.probe,CS.dedicated,CS.description ,CS.name,D.dev_name,D.dev_ip,CI.ci_name,HN.sampleavg,HN.max_samplevalue,CS.origin,HN.sampletime
,CASE WHEN CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 1, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0))) THEN '1'  ELSE '0' END AS [ThisMonth]
,CASE WHEN CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 2, dateadd(month, datediff(month, 0, getdate()) - 3, 0))) THEN '1'  ELSE '0' END AS [LastMonth]
,CASE WHEN CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 3, 0) and dateadd(millisecond, -3, dateadd(month, 3, dateadd(month, datediff(month, 0, getdate()) - 5, 0))) THEN '1'  ELSE '0' END AS [Last2Month]
,'QOS_STORAGE_CPU_UTILIZATION' AS QOSTYPE
FROM CM_COMPUTER_SYSTEM CS
      JOIN CM_DEVICE D
            ON CS.cs_id = D.cs_id
   JOIN CM_CONFIGURATION_ITEM CI
            ON D.dev_id = CI.dev_id
   JOIN CM_CONFIGURATION_ITEM_METRIC CIM
            ON CI.ci_id = CIM.ci_id
  JOIN S_QOS_DATA QD
            ON  QD.ci_metric_id = CIM.ci_metric_id and CIM.ci_metric_type = '5.1.3:4'       -- 5.1.3:4 = QOS_STORAGE_CPU_UTILIZATION
  -- JOIN S_QOS_SNAPSHOT QS
            --ON QD.table_id = QS.table_id
  JOIN HN_QOS_DATA_0311 AS HN
            ON QD.table_id = HN.table_id

WHERE CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 3, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0)))

UNION

/** RN_QOS_DATA_0147 QOS_STORAGE_IOPS   5.1.3:6      NULL **/


SELECT 
QD.probe,CS.dedicated,CS.description ,CS.name,D.dev_name,D.dev_ip,CI.ci_name,RN.samplevalue,RN.Samplerate,CS.origin,RN.sampletime
,CASE WHEN CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 1, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0))) THEN '1'  ELSE '0' END AS [ThisMonth]
,CASE WHEN CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 2, dateadd(month, datediff(month, 0, getdate()) - 3, 0))) THEN '1'  ELSE '0' END AS [LastMonth]
,CASE WHEN CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 3, 0) and dateadd(millisecond, -3, dateadd(month, 3, dateadd(month, datediff(month, 0, getdate()) - 5, 0))) THEN '1'  ELSE '0' END AS [Last2Month]
,'QOS_STORAGE_IOPS' AS QOSTYPE

FROM CM_COMPUTER_SYSTEM CS
      JOIN CM_DEVICE D
            ON CS.cs_id = D.cs_id
   JOIN CM_CONFIGURATION_ITEM CI
            ON D.dev_id = CI.dev_id
   JOIN CM_CONFIGURATION_ITEM_METRIC CIM
            ON CI.ci_id = CIM.ci_id
  JOIN S_QOS_DATA QD
            ON  QD.ci_metric_id = CIM.ci_metric_id and CIM.ci_metric_type = '5.1.3:6'       -- 5.1.3:6 = QOS_STORAGE_IOPS
  -- JOIN S_QOS_SNAPSHOT QS
            --ON QD.table_id = QS.table_id
  JOIN RN_QOS_DATA_0147 AS RN
            ON QD.table_id = RN.table_id

WHERE CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 3, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0)))


UNION
SELECT 
QD.probe,CS.dedicated,CS.description ,CS.name,D.dev_name,D.dev_ip,CI.ci_name,HN.sampleavg,HN.max_samplevalue,CS.origin,HN.sampletime
,CASE WHEN CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 1, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0))) THEN '1'  ELSE '0' END AS [ThisMonth]
,CASE WHEN CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 2, dateadd(month, datediff(month, 0, getdate()) - 3, 0))) THEN '1'  ELSE '0' END AS [LastMonth]
,CASE WHEN CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 3, 0) and dateadd(millisecond, -3, dateadd(month, 3, dateadd(month, datediff(month, 0, getdate()) - 5, 0))) THEN '1'  ELSE '0' END AS [Last2Month]
,'QOS_STORAGE_IOPS' AS QOSTYPE
FROM CM_COMPUTER_SYSTEM CS
      JOIN CM_DEVICE D
            ON CS.cs_id = D.cs_id
   JOIN CM_CONFIGURATION_ITEM CI
            ON D.dev_id = CI.dev_id
   JOIN CM_CONFIGURATION_ITEM_METRIC CIM
            ON CI.ci_id = CIM.ci_id
  JOIN S_QOS_DATA QD
            ON  QD.ci_metric_id = CIM.ci_metric_id and CIM.ci_metric_type = '5.1.3:6'       -- 5.1.3:6 = QOS_STORAGE_IOPS
  -- JOIN S_QOS_SNAPSHOT QS
            --ON QD.table_id = QS.table_id
  JOIN HN_QOS_DATA_0147 AS HN
            ON QD.table_id = HN.table_id

WHERE CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 3, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0)))


) AS w

--WHERE w.sampletime between @startDate and @endDate
--and DATEPART(hh,w.sampletime) >= 7 AND DATEPART(hh,w.sampletime) <= 17
--                 -- gets the hour of the day from the datetime
--AND DATEPART(dw,w.sampletime) >= 3 AND DATEPART(dw,w.sampletime) <= 5
--                 -- gets the day of the week from the datetime

GROUP BY w.probe,w.dedicated,w.description,w.name,w.dev_name, w.dev_ip,w.ci_name,w.origin,ThisMonth,LastMonth,Last2Month,QOSTYPE