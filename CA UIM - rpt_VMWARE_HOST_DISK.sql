TRUNCATE TABLE [CA_UIM].[dbo].[LT_rpt_QOS_VMWARE_HOST_DISK]

declare @startDate datetime = dateadd(month, datediff(month, 0, getdate()) - 1, 0); -- 1st day of previous month
declare @endDate datetime = dateadd(millisecond, -3, dateadd(month, 2, @startdate)); -- 3 milliseconds before current month starts

INSERT INTO [CA_UIM].[dbo].[LT_rpt_QOS_VMWARE_HOST_DISK]

select w.probe
,w.dedicated
,w.description 
,w.name
,w.dev_name
,w.dev_ip
,CAST(SUM(w.samplevalue)/COUNT(w.Samplerate) AS decimal(18,3)) AS AVERAGE_QOS_VALUE
,w.origin
,ThisMonth
,LastMonth
,QOSTYPE
FROM 
( 

/** RN_QOS_DATA_0203 QOS_VMWARE_HOST_DISK_WRITE_RATE       liitesxi4.syr.local/Disk/naa.6006016002f01a00143d6785f0abe211/Disk Write Rate     1.1:30 **/

SELECT 
QD.probe,CS.dedicated,CS.description ,CS.name,D.dev_name,D.dev_ip,RN.samplevalue,RN.Samplerate,CS.origin,RN.sampletime
,CASE WHEN CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 1, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0))) THEN '1'  ELSE '0' END AS [ThisMonth]
,CASE WHEN CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 2, dateadd(month, datediff(month, 0, getdate()) - 3, 0))) THEN '1'  ELSE '0' END AS [LastMonth]
,'QOS_VMWARE_HOST_DISK_WRITE_RATE' AS QOSTYPE

FROM CM_COMPUTER_SYSTEM CS
      JOIN CM_DEVICE D
            ON CS.cs_id = D.cs_id
   JOIN CM_CONFIGURATION_ITEM CI
            ON D.dev_id = CI.dev_id
   JOIN CM_CONFIGURATION_ITEM_METRIC CIM
            ON CI.ci_id = CIM.ci_id
  JOIN S_QOS_DATA QD
            ON  QD.ci_metric_id = CIM.ci_metric_id and CIM.ci_metric_type = '1.1:30'       -- 1.1:30 = QOS_VMWARE_HOST_DISK_WRITE_RATE
  -- JOIN S_QOS_SNAPSHOT QS
            --ON QD.table_id = QS.table_id
  JOIN RN_QOS_DATA_0203 AS RN
            ON QD.table_id = RN.table_id

WHERE CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0)))

UNION
SELECT 
QD.probe,CS.dedicated,CS.description ,CS.name,D.dev_name,D.dev_ip,HN.sampleavg,HN.max_samplevalue,CS.origin,HN.sampletime
,CASE WHEN CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 1, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0))) THEN '1'  ELSE '0' END AS [ThisMonth]
,CASE WHEN CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 2, dateadd(month, datediff(month, 0, getdate()) - 3, 0))) THEN '1'  ELSE '0' END AS [LastMonth]
,'QOS_VMWARE_HOST_DISK_WRITE_RATE' AS QOSTYPE
FROM CM_COMPUTER_SYSTEM CS
      JOIN CM_DEVICE D
            ON CS.cs_id = D.cs_id
   JOIN CM_CONFIGURATION_ITEM CI
            ON D.dev_id = CI.dev_id
   JOIN CM_CONFIGURATION_ITEM_METRIC CIM
            ON CI.ci_id = CIM.ci_id
  JOIN S_QOS_DATA QD
            ON  QD.ci_metric_id = CIM.ci_metric_id and CIM.ci_metric_type = '1.1:30'       -- 1.1:30 = QOS_VMWARE_HOST_DISK_WRITE_RATE
  -- JOIN S_QOS_SNAPSHOT QS
            --ON QD.table_id = QS.table_id
  JOIN HN_QOS_DATA_0203 AS HN
            ON QD.table_id = HN.table_id

WHERE CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0)))

UNION

/**  RN_QOS_DATA_0187      QOS_VMWARE_HOST_DISK_READ_RATE       liitesxi5.syr.local/Disk/naa.6006016002f01a004e7e64faf3abe211/Disk Read Rate      1.1:29 **/

SELECT 
QD.probe,CS.dedicated,CS.description ,CS.name,D.dev_name,D.dev_ip,RN.samplevalue,RN.Samplerate,CS.origin,RN.sampletime
,CASE WHEN CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 1, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0))) THEN '1'  ELSE '0' END AS [ThisMonth]
,CASE WHEN CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 2, dateadd(month, datediff(month, 0, getdate()) - 3, 0))) THEN '1'  ELSE '0' END AS [LastMonth]
,'QOS_VMWARE_HOST_DISK_READ_RATE' AS QOSTYPE

FROM CM_COMPUTER_SYSTEM CS
      JOIN CM_DEVICE D
            ON CS.cs_id = D.cs_id
   JOIN CM_CONFIGURATION_ITEM CI
            ON D.dev_id = CI.dev_id
   JOIN CM_CONFIGURATION_ITEM_METRIC CIM
            ON CI.ci_id = CIM.ci_id
  JOIN S_QOS_DATA QD
            ON  QD.ci_metric_id = CIM.ci_metric_id and CIM.ci_metric_type = '1.1:29'       -- 1.1:29 = QOS_VMWARE_HOST_DISK_READ_RATE
  -- JOIN S_QOS_SNAPSHOT QS
            --ON QD.table_id = QS.table_id
  JOIN RN_QOS_DATA_0187 AS RN
            ON QD.table_id = RN.table_id

WHERE CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0)))

UNION
SELECT 
QD.probe,CS.dedicated,CS.description ,CS.name,D.dev_name,D.dev_ip,HN.sampleavg,HN.max_samplevalue,CS.origin,HN.sampletime
,CASE WHEN CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 1, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0))) THEN '1'  ELSE '0' END AS [ThisMonth]
,CASE WHEN CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 2, dateadd(month, datediff(month, 0, getdate()) - 3, 0))) THEN '1'  ELSE '0' END AS [LastMonth]
,'QOS_VMWARE_HOST_DISK_READ_RATE' AS QOSTYPE
FROM CM_COMPUTER_SYSTEM CS
      JOIN CM_DEVICE D
            ON CS.cs_id = D.cs_id
   JOIN CM_CONFIGURATION_ITEM CI
            ON D.dev_id = CI.dev_id
   JOIN CM_CONFIGURATION_ITEM_METRIC CIM
            ON CI.ci_id = CIM.ci_id
  JOIN S_QOS_DATA QD
            ON  QD.ci_metric_id = CIM.ci_metric_id and CIM.ci_metric_type = '1.1:29'       -- 1.1:29= QOS_VMWARE_HOST_DISK_READ_RATE
  -- JOIN S_QOS_SNAPSHOT QS
            --ON QD.table_id = QS.table_id
  JOIN HN_QOS_DATA_0187 AS HN
            ON QD.table_id = HN.table_id

WHERE CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0)))

UNION

/**  RN_QOS_DATA_0211      QOS_VMWARE_HOST_DISK_QUEUE_LATENCY       Disk/naa.60002ac0000000000000001e0000b5c5/Disk Queue Latency  1.1:46 **/

SELECT 
QD.probe,CS.dedicated,CS.description ,CS.name,D.dev_name,D.dev_ip, RN.samplevalue,RN.Samplerate,CS.origin,RN.sampletime
,CASE WHEN CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 1, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0))) THEN '1'  ELSE '0' END AS [ThisMonth]
,CASE WHEN CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 2, dateadd(month, datediff(month, 0, getdate()) - 3, 0))) THEN '1'  ELSE '0' END AS [LastMonth]
,'QOS_VMWARE_HOST_DISK_QUEUE_LATENCY' AS QOSTYPE

FROM CM_COMPUTER_SYSTEM CS
      JOIN CM_DEVICE D
            ON CS.cs_id = D.cs_id
   JOIN CM_CONFIGURATION_ITEM CI
            ON D.dev_id = CI.dev_id
   JOIN CM_CONFIGURATION_ITEM_METRIC CIM
            ON CI.ci_id = CIM.ci_id
  JOIN S_QOS_DATA QD
            ON  QD.ci_metric_id = CIM.ci_metric_id and CIM.ci_metric_type = '1.1:46'       -- 1.1:46 = QOS_VMWARE_HOST_DISK_QUEUE_LATENCY
  -- JOIN S_QOS_SNAPSHOT QS
            --ON QD.table_id = QS.table_id
  JOIN RN_QOS_DATA_0211 AS RN
            ON QD.table_id = RN.table_id

WHERE CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0)))

UNION
SELECT 
QD.probe,CS.dedicated,CS.description ,CS.name,D.dev_name,D.dev_ip, HN.sampleavg,HN.max_samplevalue,CS.origin,HN.sampletime
,CASE WHEN CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 1, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0))) THEN '1'  ELSE '0' END AS [ThisMonth]
,CASE WHEN CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 2, dateadd(month, datediff(month, 0, getdate()) - 3, 0))) THEN '1'  ELSE '0' END AS [LastMonth]
,'QOS_VMWARE_HOST_DISK_QUEUE_LATENCY' AS QOSTYPE
FROM CM_COMPUTER_SYSTEM CS
      JOIN CM_DEVICE D
            ON CS.cs_id = D.cs_id
   JOIN CM_CONFIGURATION_ITEM CI
            ON D.dev_id = CI.dev_id
   JOIN CM_CONFIGURATION_ITEM_METRIC CIM
            ON CI.ci_id = CIM.ci_id
  JOIN S_QOS_DATA QD
            ON  QD.ci_metric_id = CIM.ci_metric_id and CIM.ci_metric_type = '1.1:46'       -- 1.1:46 = QOS_VMWARE_HOST_DISK_QUEUE_LATENCY
  -- JOIN S_QOS_SNAPSHOT QS
            --ON QD.table_id = QS.table_id
  JOIN HN_QOS_DATA_0211 AS HN
            ON QD.table_id = HN.table_id

WHERE CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0)))




) AS w


WHERE w.sampletime between @startDate and @endDate
and DATEPART(hh,w.sampletime) >= 7 AND DATEPART(hh,w.sampletime) <= 17
--                 -- gets the hour of the day from the datetime
AND DATEPART(dw,w.sampletime) >= 3 AND DATEPART(dw,w.sampletime) <= 5
--                 -- gets the day of the week from the datetime
--AND dedicated = 'VirtualMachine'

GROUP BY w.probe,w.dedicated,w.description,w.name,w.dev_name, w.dev_ip,w.origin,ThisMonth,LastMonth,QOSTYPE