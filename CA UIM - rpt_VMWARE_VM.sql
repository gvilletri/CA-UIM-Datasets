TRUNCATE TABLE [CA_UIM].[dbo].[LT_rpt_QOS_VMWARE_VM]

declare @startDate datetime = dateadd(month, datediff(month, 0, getdate()) - 1, 0); -- 1st day of previous month
declare @endDate datetime = dateadd(millisecond, -3, dateadd(month, 2, @startdate)); -- 3 milliseconds before current month starts

INSERT INTO [CA_UIM].[dbo].[LT_rpt_QOS_VMWARE_VM]

select w.probe
,w.dedicated
,w.description 
,w.name
,w.dev_name
,w.dev_ip
,w.ci_name
,CAST(SUM(w.samplevalue)/COUNT(w.Samplerate) AS decimal(18,3)) AS AVERAGE_QOS_VALUE
,w.origin
,ThisMonth
,LastMonth
,QOSTYPE
FROM 
( 

/** RN_QOS_DATA_0163 QOS_VMWARE_VM_CPU_AGGREGATE_USAGE CPU Usage (Average/Rate)   1.5:1 **/

SELECT 
QD.probe,CS.dedicated,CS.description ,CS.name,D.dev_name,D.dev_ip,CI.ci_name,RN.samplevalue,RN.Samplerate,CS.origin,RN.sampletime
,CASE WHEN CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 1, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0))) THEN '1'  ELSE '0' END AS [ThisMonth]
,CASE WHEN CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 2, dateadd(month, datediff(month, 0, getdate()) - 3, 0))) THEN '1'  ELSE '0' END AS [LastMonth]
,'QOS_VMWARE_VM_CPU_AGGREGATE_USAGE' AS QOSTYPE

FROM CM_COMPUTER_SYSTEM CS
      JOIN CM_DEVICE D
            ON CS.cs_id = D.cs_id
   JOIN CM_CONFIGURATION_ITEM CI
            ON D.dev_id = CI.dev_id
   JOIN CM_CONFIGURATION_ITEM_METRIC CIM
            ON CI.ci_id = CIM.ci_id
  JOIN S_QOS_DATA QD
            ON  QD.ci_metric_id = CIM.ci_metric_id and CIM.ci_metric_type = '1.5:1'       -- 1.5:1 = QOS_VMWARE_VM_CPU_AGGREGATE_USAGE
  -- JOIN S_QOS_SNAPSHOT QS
            --ON QD.table_id = QS.table_id
  JOIN RN_QOS_DATA_0163 AS RN
            ON QD.table_id = RN.table_id

WHERE CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0)))

UNION
SELECT 
QD.probe,CS.dedicated,CS.description ,CS.name,D.dev_name,D.dev_ip,CI.ci_name,HN.sampleavg,HN.max_samplevalue,CS.origin,HN.sampletime
,CASE WHEN CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 1, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0))) THEN '1'  ELSE '0' END AS [ThisMonth]
,CASE WHEN CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 2, dateadd(month, datediff(month, 0, getdate()) - 3, 0))) THEN '1'  ELSE '0' END AS [LastMonth]
,'QOS_VMWARE_VM_CPU_AGGREGATE_USAGE' AS QOSTYPE
FROM CM_COMPUTER_SYSTEM CS
      JOIN CM_DEVICE D
            ON CS.cs_id = D.cs_id
   JOIN CM_CONFIGURATION_ITEM CI
            ON D.dev_id = CI.dev_id
   JOIN CM_CONFIGURATION_ITEM_METRIC CIM
            ON CI.ci_id = CIM.ci_id
  JOIN S_QOS_DATA QD
            ON  QD.ci_metric_id = CIM.ci_metric_id and CIM.ci_metric_type = '1.5:1'       -- 1.5:1 = QOS_VMWARE_VM_CPU_AGGREGATE_USAGE
  -- JOIN S_QOS_SNAPSHOT QS
            --ON QD.table_id = QS.table_id
  JOIN HN_QOS_DATA_0163 AS HN
            ON QD.table_id = HN.table_id

WHERE CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0)))

UNION

/**  RN_QOS_DATA_1283      QOS_VMWARE_VM_CPU_USAGE_MHZ OverallCpuUsage      1.5:35 **/

SELECT 
QD.probe,CS.dedicated,CS.description ,CS.name,D.dev_name,D.dev_ip,CI.ci_name,RN.samplevalue,RN.Samplerate,CS.origin,RN.sampletime
,CASE WHEN CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 1, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0))) THEN '1'  ELSE '0' END AS [ThisMonth]
,CASE WHEN CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 2, dateadd(month, datediff(month, 0, getdate()) - 3, 0))) THEN '1'  ELSE '0' END AS [LastMonth]
,'QOS_VMWARE_VM_CPU_USAGE_MHZ' AS QOSTYPE

FROM CM_COMPUTER_SYSTEM CS
      JOIN CM_DEVICE D
            ON CS.cs_id = D.cs_id
   JOIN CM_CONFIGURATION_ITEM CI
            ON D.dev_id = CI.dev_id
   JOIN CM_CONFIGURATION_ITEM_METRIC CIM
            ON CI.ci_id = CIM.ci_id
  JOIN S_QOS_DATA QD
            ON  QD.ci_metric_id = CIM.ci_metric_id and CIM.ci_metric_type = '1.5:35'       -- 1.5:35 = QOS_VMWARE_VM_CPU_USAGE_MHZ
  -- JOIN S_QOS_SNAPSHOT QS
            --ON QD.table_id = QS.table_id
  JOIN RN_QOS_DATA_1283 AS RN
            ON QD.table_id = RN.table_id

WHERE CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0)))

UNION
SELECT 
QD.probe,CS.dedicated,CS.description ,CS.name,D.dev_name,D.dev_ip,CI.ci_name,HN.sampleavg,HN.max_samplevalue,CS.origin,HN.sampletime
,CASE WHEN CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 1, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0))) THEN '1'  ELSE '0' END AS [ThisMonth]
,CASE WHEN CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 2, dateadd(month, datediff(month, 0, getdate()) - 3, 0))) THEN '1'  ELSE '0' END AS [LastMonth]
,'QOS_VMWARE_VM_CPU_USAGE_MHZ' AS QOSTYPE
FROM CM_COMPUTER_SYSTEM CS
      JOIN CM_DEVICE D
            ON CS.cs_id = D.cs_id
   JOIN CM_CONFIGURATION_ITEM CI
            ON D.dev_id = CI.dev_id
   JOIN CM_CONFIGURATION_ITEM_METRIC CIM
            ON CI.ci_id = CIM.ci_id
  JOIN S_QOS_DATA QD
            ON  QD.ci_metric_id = CIM.ci_metric_id and CIM.ci_metric_type = '1.5:35'       -- 1.5:35 = QOS_VMWARE_VM_CPU_USAGE_MHZ
  -- JOIN S_QOS_SNAPSHOT QS
            --ON QD.table_id = QS.table_id
  JOIN HN_QOS_DATA_1283 AS HN
            ON QD.table_id = HN.table_id

WHERE CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0)))

UNION

/**  RN_QOS_DATA_0259      QOS_VMWARE_VM_DISK_AGGREGATE_USAGE Disk Usage    1.1:31 **/

SELECT 
QD.probe,CS.dedicated,CS.description ,CS.name,D.dev_name,D.dev_ip,CI.ci_name,RN.samplevalue,RN.Samplerate,CS.origin,RN.sampletime
,CASE WHEN CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 1, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0))) THEN '1'  ELSE '0' END AS [ThisMonth]
,CASE WHEN CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 2, dateadd(month, datediff(month, 0, getdate()) - 3, 0))) THEN '1'  ELSE '0' END AS [LastMonth]
,'QOS_VMWARE_VM_DISK_AGGREGATE_USAGE' AS QOSTYPE

FROM CM_COMPUTER_SYSTEM CS
      JOIN CM_DEVICE D
            ON CS.cs_id = D.cs_id
   JOIN CM_CONFIGURATION_ITEM CI
            ON D.dev_id = CI.dev_id
   JOIN CM_CONFIGURATION_ITEM_METRIC CIM
            ON CI.ci_id = CIM.ci_id
  JOIN S_QOS_DATA QD
            ON  QD.ci_metric_id = CIM.ci_metric_id and CIM.ci_metric_type = '1.1:31'       -- 1.1:31 = QOS_VMWARE_VM_DISK_AGGREGATE_USAGE
  -- JOIN S_QOS_SNAPSHOT QS
            --ON QD.table_id = QS.table_id
  JOIN RN_QOS_DATA_0259 AS RN
            ON QD.table_id = RN.table_id

WHERE CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0)))

UNION
SELECT 
QD.probe,CS.dedicated,CS.description ,CS.name,D.dev_name,D.dev_ip,CI.ci_name,HN.sampleavg,HN.max_samplevalue,CS.origin,HN.sampletime
,CASE WHEN CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 1, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0))) THEN '1'  ELSE '0' END AS [ThisMonth]
,CASE WHEN CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 2, dateadd(month, datediff(month, 0, getdate()) - 3, 0))) THEN '1'  ELSE '0' END AS [LastMonth]
,'QOS_VMWARE_VM_DISK_AGGREGATE_USAGE' AS QOSTYPE
FROM CM_COMPUTER_SYSTEM CS
      JOIN CM_DEVICE D
            ON CS.cs_id = D.cs_id
   JOIN CM_CONFIGURATION_ITEM CI
            ON D.dev_id = CI.dev_id
   JOIN CM_CONFIGURATION_ITEM_METRIC CIM
            ON CI.ci_id = CIM.ci_id
  JOIN S_QOS_DATA QD
            ON  QD.ci_metric_id = CIM.ci_metric_id and CIM.ci_metric_type = '1.1:31'       -- 1.1:31 = QOS_VMWARE_VM_DISK_AGGREGATE_USAGE
  -- JOIN S_QOS_SNAPSHOT QS
            --ON QD.table_id = QS.table_id
  JOIN HN_QOS_DATA_0259 AS HN
            ON QD.table_id = HN.table_id

WHERE CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0)))


UNION

/**  RN_QOS_DATA_0183      QOS_VMWARE_VM_GUEST_MEMORY_USAGE_PCT     GuestMemoryUsage (in % of Memory)       1.17.2:19 **/

SELECT 
QD.probe,CS.dedicated,CS.description ,CS.name,D.dev_name,D.dev_ip,CI.ci_name,RN.samplevalue,RN.Samplerate,CS.origin,RN.sampletime
,CASE WHEN CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 1, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0))) THEN '1'  ELSE '0' END AS [ThisMonth]
,CASE WHEN CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 2, dateadd(month, datediff(month, 0, getdate()) - 3, 0))) THEN '1'  ELSE '0' END AS [LastMonth]
,'QOS_VMWARE_VM_GUEST_MEMORY_USAGE_PCT' AS QOSTYPE

FROM CM_COMPUTER_SYSTEM CS
      JOIN CM_DEVICE D
            ON CS.cs_id = D.cs_id
   JOIN CM_CONFIGURATION_ITEM CI
            ON D.dev_id = CI.dev_id
   JOIN CM_CONFIGURATION_ITEM_METRIC CIM
            ON CI.ci_id = CIM.ci_id
  JOIN S_QOS_DATA QD
            ON  QD.ci_metric_id = CIM.ci_metric_id and CIM.ci_metric_type = '1.17.2:19'       -- 1.17.2:19 = QOS_VMWARE_VM_GUEST_MEMORY_USAGE_PCT
  -- JOIN S_QOS_SNAPSHOT QS
            --ON QD.table_id = QS.table_id
  JOIN RN_QOS_DATA_0183 AS RN
            ON QD.table_id = RN.table_id

WHERE CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0)))

UNION
SELECT 
QD.probe,CS.dedicated,CS.description ,CS.name,D.dev_name,D.dev_ip,CI.ci_name,HN.sampleavg,HN.max_samplevalue,CS.origin,HN.sampletime
,CASE WHEN CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 1, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0))) THEN '1'  ELSE '0' END AS [ThisMonth]
,CASE WHEN CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 2, dateadd(month, datediff(month, 0, getdate()) - 3, 0))) THEN '1'  ELSE '0' END AS [LastMonth]
,'QOS_VMWARE_VM_GUEST_MEMORY_USAGE_PCT' AS QOSTYPE
FROM CM_COMPUTER_SYSTEM CS
      JOIN CM_DEVICE D
            ON CS.cs_id = D.cs_id
   JOIN CM_CONFIGURATION_ITEM CI
            ON D.dev_id = CI.dev_id
   JOIN CM_CONFIGURATION_ITEM_METRIC CIM
            ON CI.ci_id = CIM.ci_id
  JOIN S_QOS_DATA QD
            ON  QD.ci_metric_id = CIM.ci_metric_id and CIM.ci_metric_type = '1.17.2:19'       -- 1.17.2:19 = QOS_VMWARE_VM_GUEST_MEMORY_USAGE_PCT
  -- JOIN S_QOS_SNAPSHOT QS
            --ON QD.table_id = QS.table_id
  JOIN HN_QOS_DATA_0183 AS HN
            ON QD.table_id = HN.table_id

WHERE CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0)))

UNION

/**  RN_QOS_DATA_0197      QOS_VMWARE_VM_NUM_CPU      NumCPU 1.17.1:5 **/

SELECT 
QD.probe,CS.dedicated,CS.description ,CS.name,D.dev_name,D.dev_ip,CI.ci_name,RN.samplevalue,RN.Samplerate,CS.origin,RN.sampletime
,CASE WHEN CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 1, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0))) THEN '1'  ELSE '0' END AS [ThisMonth]
,CASE WHEN CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 2, dateadd(month, datediff(month, 0, getdate()) - 3, 0))) THEN '1'  ELSE '0' END AS [LastMonth]
,'QOS_VMWARE_VM_NUM_CPU' AS QOSTYPE

FROM CM_COMPUTER_SYSTEM CS
      JOIN CM_DEVICE D
            ON CS.cs_id = D.cs_id
   JOIN CM_CONFIGURATION_ITEM CI
            ON D.dev_id = CI.dev_id
   JOIN CM_CONFIGURATION_ITEM_METRIC CIM
            ON CI.ci_id = CIM.ci_id
  JOIN S_QOS_DATA QD
            ON  QD.ci_metric_id = CIM.ci_metric_id and CIM.ci_metric_type = '1.17.1:5'       -- 1.17.1:5 = QOS_VMWARE_VM_NUM_CPU
  -- JOIN S_QOS_SNAPSHOT QS
            --ON QD.table_id = QS.table_id
  JOIN RN_QOS_DATA_0197 AS RN
            ON QD.table_id = RN.table_id

WHERE CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0)))

UNION
SELECT 
QD.probe,CS.dedicated,CS.description ,CS.name,D.dev_name,D.dev_ip,CI.ci_name,HN.sampleavg,HN.max_samplevalue,CS.origin,HN.sampletime
,CASE WHEN CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 1, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0))) THEN '1'  ELSE '0' END AS [ThisMonth]
,CASE WHEN CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 2, dateadd(month, datediff(month, 0, getdate()) - 3, 0))) THEN '1'  ELSE '0' END AS [LastMonth]
,'QOS_VMWARE_VM_NUM_CPU' AS QOSTYPE
FROM CM_COMPUTER_SYSTEM CS
      JOIN CM_DEVICE D
            ON CS.cs_id = D.cs_id
   JOIN CM_CONFIGURATION_ITEM CI
            ON D.dev_id = CI.dev_id
   JOIN CM_CONFIGURATION_ITEM_METRIC CIM
            ON CI.ci_id = CIM.ci_id
  JOIN S_QOS_DATA QD
            ON  QD.ci_metric_id = CIM.ci_metric_id and CIM.ci_metric_type = '1.17.1:5'       -- 1.17.1:5 = QOS_VMWARE_VM_NUM_CPU
  -- JOIN S_QOS_SNAPSHOT QS
            --ON QD.table_id = QS.table_id
  JOIN HN_QOS_DATA_0197 AS HN
            ON QD.table_id = HN.table_id

WHERE CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0)))

UNION

/**  RN_QOS_DATA_0152      QOS_VMWARE_VM_POWER_STATE_AVAL    PowerState    1.17:1 **/

SELECT 
QD.probe,CS.dedicated,CS.description ,CS.name,D.dev_name,D.dev_ip,CI.ci_name,RN.samplevalue,RN.Samplerate,CS.origin,RN.sampletime
,CASE WHEN CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 1, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0))) THEN '1'  ELSE '0' END AS [ThisMonth]
,CASE WHEN CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 2, dateadd(month, datediff(month, 0, getdate()) - 3, 0))) THEN '1'  ELSE '0' END AS [LastMonth]
,'QOS_VMWARE_VM_POWER_STATE_AVAL' AS QOSTYPE

FROM CM_COMPUTER_SYSTEM CS
      JOIN CM_DEVICE D
            ON CS.cs_id = D.cs_id
   JOIN CM_CONFIGURATION_ITEM CI
            ON D.dev_id = CI.dev_id
   JOIN CM_CONFIGURATION_ITEM_METRIC CIM
            ON CI.ci_id = CIM.ci_id
  JOIN S_QOS_DATA QD
            ON  QD.ci_metric_id = CIM.ci_metric_id and CIM.ci_metric_type = '1.17:1'       -- 1.17:1 = QOS_VMWARE_VM_POWER_STATE_AVAL
  -- JOIN S_QOS_SNAPSHOT QS
            --ON QD.table_id = QS.table_id
  JOIN RN_QOS_DATA_0152 AS RN
            ON QD.table_id = RN.table_id

WHERE CAST(RN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0)))

UNION
SELECT 
QD.probe,CS.dedicated,CS.description ,CS.name,D.dev_name,D.dev_ip,CI.ci_name,HN.sampleavg,HN.max_samplevalue,CS.origin,HN.sampletime
,CASE WHEN CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 1, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0))) THEN '1'  ELSE '0' END AS [ThisMonth]
,CASE WHEN CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 2, dateadd(month, datediff(month, 0, getdate()) - 3, 0))) THEN '1'  ELSE '0' END AS [LastMonth]
,'QOS_VMWARE_VM_POWER_STATE_AVAL' AS QOSTYPE
FROM CM_COMPUTER_SYSTEM CS
      JOIN CM_DEVICE D
            ON CS.cs_id = D.cs_id
   JOIN CM_CONFIGURATION_ITEM CI
            ON D.dev_id = CI.dev_id
   JOIN CM_CONFIGURATION_ITEM_METRIC CIM
            ON CI.ci_id = CIM.ci_id
  JOIN S_QOS_DATA QD
            ON  QD.ci_metric_id = CIM.ci_metric_id and CIM.ci_metric_type = '1.17:1'       -- 1.17:1 = QOS_VMWARE_VM_POWER_STATE_AVAL
  -- JOIN S_QOS_SNAPSHOT QS
            --ON QD.table_id = QS.table_id
  JOIN HN_QOS_DATA_0152 AS HN
            ON QD.table_id = HN.table_id

WHERE CAST(HN.sampletime as TIMESTAMP) BETWEEN dateadd(month, datediff(month, 0, getdate()) - 2, 0) and dateadd(millisecond, -3, dateadd(month, 1, dateadd(month, datediff(month, 0, getdate()) - 1, 0)))


) AS w


WHERE w.sampletime between @startDate and @endDate
and DATEPART(hh,w.sampletime) >= 7 AND DATEPART(hh,w.sampletime) <= 17
--                 -- gets the hour of the day from the datetime
AND DATEPART(dw,w.sampletime) >= 3 AND DATEPART(dw,w.sampletime) <= 5
--                 -- gets the day of the week from the datetime
AND dedicated = 'VirtualMachine'

GROUP BY w.probe,w.dedicated,w.description,w.name,w.dev_name, w.dev_ip,w.ci_name,w.origin,ThisMonth,LastMonth,QOSTYPE