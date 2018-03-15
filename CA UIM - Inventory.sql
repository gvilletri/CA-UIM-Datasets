SELECT DISTINCT top 10000 

--D.dev_name,d.probe_na
CS.name,CS.origin,CS.os_name,CS.os_description,CS.os_type,CS.os_version,CS.dedicated,d.probe_name,
CS.origin,Cs.OS_type,cs.os_description,CMA.PrimaryIPV4Address,CMA.PrimaryOSType,CMA.DisplayName,
CMA.CorrelationNames,CMA.Origin,CMA.typeName,CMA.Roles,CMA.label,
csa.ComputerName,csa.BiosSystemID,
ss.sys_type
--CS.[name],D.dev_name, CS.origin,Cs.OS_type,cs.os_description,d.probe_name,CS.dedicated, CS.[description]

FROM CM_COMPUTER_SYSTEM CS
  JOIN CM_DEVICE D
    on CS.cs_id = D.cs_id

  LEFT JOIN CM_SNMP_SYSTEM ss
     on ss.cs_id = d.cs_id


              LEFT JOIN [dbo].[CM_DEVICE_ATTRIBUTE]
                           pivot (MIN (dev_attr_value) 
                                  for dev_attr_key in ([PrimaryIPV4Address],[PrimaryRole],[PrimaryOSType],[CorrelationNames],[DisplayName],[typeName],[Origin],[Roles],[label])) as CMA
          ON D.dev_id = CMA.dev_id

          LEFT JOIN [dbo].[CM_COMPUTER_SYSTEM_ATTR]
                           pivot (MIN (cs_attr_value) 
                                  for cs_attr_value in ([AssetNumber],[BiosSystemID],[ComputerName],[DisplayAlias])) as CSA
              ON cs.cs_id = CSA.cs_id


where d.probe_name not in ('discovery','niscache','discovery_agent') and CMA.Origin is not Null
