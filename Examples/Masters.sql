-- Master tables
Declare @Partyid uniqueidentifier

Select  @Partyid = Id  from Cust_Party (Nolock)  where name = 'HERMOON AGENCIES LTD'

Select * from Cust_Party (Nolock)  where id = @Partyid
select spt.name,PPTM.* from Cust_PartyPartyTypeMap PPTM (Nolock) 
left join Sys_PartyTypes SPT (Nolock) ON SPT.id = PPTM.PartyTypeId 
where partyid = @Partyid

Select * from Cust_PartyPartyTypeMap
Select * from Sys_PartyTypes

-- Party Tables
select * from Cust_PartyLocation (Nolock) where partyid = @Partyid
select * from Cust_PartyContact (Nolock) where PartyLocationId in (select ID from Cust_PartyLocation where partyid = @Partyid)
Select * from Cust_PartyOfficeDetail (Nolock)
Select * from Cust_PartyOfficeTaxExempDetail (Nolock)

-- Charge master
select * from Bill_ChargeCode (Nolock)
select * from Bill_ChargeCodeOfficeMap (Nolock)
select * from Bill_ChargeCodeOfficeTaxMap (Nolock)

--Currency
select * from cust_currency (Nolock)

--Country
select * from Cust_country (Nolock)

--Location
select * from Cust_Location (Nolock)

--Route
Select * from Cust_Route (Nolock)
Select * from Cust_RouteLeg (Nolock)

--AddressType
Select * from cust_addresstype (Nolock)

--Vessel
select * from Cust_Vessel (Nolock)

--Equipment
select * from Cust_EquipmentSize (Nolock)
select * from Cust_EquipmentTypes (Nolock)
select * from Cust_Equipment (Nolock)
select * from Cust_EquipmentGroupMap  (Nolock)
select * from Cust_EquipmentGroup (Nolock)


--Product
select * from Cust_Product  (Nolock)
select * from Cust_ProductBillOfMaterial  (Nolock)
select * from Cust_ProductClientMap (Nolock)
select * from Cust_ProductOfficeMap (Nolock)
select * from Cust_ProductPackageStructre  (Nolock)
select * from Cust_ProductVendorDetails  (Nolock)
select * from Cust_ProductVendorPriceDetail (Nolock)
select * from Cust_ProductCategory  (Nolock)

--Activity
select * from Cust_Activity (Nolock)
select * from Cust_ActivityClientMap (Nolock)
select * from Cust_ActivityOfficeMap (Nolock)

--Reasons
Select * from Cust_Reasons (Nolock)

--Bond
Select * from Cust_BondType (Nolock)
Select * from Cust_BondForm (Nolock)
Select * from Cust_Bond (Nolock)
Select * from Cust_BondOfficeMap (Nolock)


--System master
Select * from Sys_PartyTypes
Select * from Sys_Process
Select * from Sys_QuantityUOM
select * from Sys_Service
select * from Sys_ShipmentMode
Select * from Sys_IncoTerms
Select * from Sys_Timezone
Select * from Sys_HarmonizedSystem
Select * from Sys_MovementType
Select * from Sys_ShipmentType
Select * from Sys_ServiceType
Select * from Sys_TransportationMode