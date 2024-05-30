Select * from Contract_ContractInfo where ContractNumber = 'O2776CQ2300004'
Select * from Contract_ContractInfoOfficeMap where ContractInfoId = 'FBB32B44-3987-4BD1-BB5A-B0BB008F179D'
Select * from Contract_ContractService where ContractInfoId = 'FBB32B44-3987-4BD1-BB5A-B0BB008F179D'
Select SCC.FieldName,CSD.* from Contract_ContractServiceDetail CSD (nolock)
Left Join Sys_ContractConfig SCC (nolock) on CSD.ContractConfigId = SCC.Id
where ContractServiceId = '02C840D1-C4CB-4560-84EA-B0BB00909FDC'
Select * from Contract_ContractSvcActChrg (nolock) where ContractServiceId = '02C840D1-C4CB-4560-84EA-B0BB00909FDC' 
Select * from Contract_ServiceChargeBase (nolock) where ContractSvcActChargeId = 'B7DC1BD7-F7B1-45AF-A454-B0BB0090A04E' 
Select * from Contract_ServiceChargeBaseSlab (nolock) where ServiceChargeBaseid = '6C499E4C-B5BF-4CE7-ACC4-B0BB0090A050'
select * from Sys_ChargeBasedOn where Id = '425754C6-4263-4797-9F79-2E99B8E6CFC3'

Select * from Sys_ContractConfig