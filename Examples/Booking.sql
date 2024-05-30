declare @bookingid uniqueidentifier

Select @bookingid = id  from Bkg_BookingInfo where Bookingnumber like '18-MC-SHI-BO-01103'

Select [dbo].[fn_TimeZone](ETDDatetime,ETDTimeZoneId),ETDDatetime,ETDTimeZoneId, * from Bkg_BookingInfo (Nolock) where id = @bookingid

--Booking Jobs
select * from Bkg_BookingProcess (Nolock) where bookinginfoid =  @bookingid and IsActive = 1 and IsDeleted = 0
select [dbo].[fn_TimeZone](ATADatetime,ATATimeZoneId),ATADatetime,ATATimeZoneId,* from Bkg_BookingService (Nolock) 
where bookinginfoid =  @bookingid and IsActive = 1 and IsDeleted = 0

--Activity
select * from Bkg_BookingActivity (Nolock)
where bookinginfoid =  @bookingid and IsActive = 1 and IsDeleted = 0

--Product Item
select LI.* from Bkg_LineItem LI (Nolock)
join Cust_Product (Nolock) CP on CP.Id = LI.ProductId and CP.IsActive = 1 and CP.IsDeleted = 0
where bookinginfoid =  @bookingid  and LI.IsDeleted = 0 

--Adding Package
Select BPKG.* from Bkg_BookingInfo BI (Nolock)
join Bkg_EquipmentPackageGroupMap EPGM (nolock) on BI.Id = EPGM.BookingInfoId 
join Bkg_PackageGroup BPG (Nolock) on BPG.Id = EPGM.PackageGroupId and BPG.IsDeleted = 0
join [Bkg_PackageGroupPackageMap] PGPM (Nolock) on PGPM.PackageGroupId = BPG.Id 
join [Bkg_Package] BPKG (Nolock) on BPKG.Id = PGPM.PackageId and  BPKG.IsDeleted = 0
where BI.IsActive = 1 and BI.IsDeleted = 0

Select PGLI.* from Bkg_BookingInfo BI (Nolock)
join Bkg_EquipmentPackageGroupMap EPGM (nolock) on BI.Id = EPGM.BookingInfoId
join Bkg_PackageGroup BPG (Nolock) on BPG.Id = EPGM.PackageGroupId and BPG.IsDeleted = 0
join [Bkg_PackageGroupLineItemMap] PGLI (Nolock) on PGLI.PackageGroupId = BPG.Id 
join bkg_LineItem BLI (Nolock) on BLI.Id = PGLI.LineItemId and BLI.IsDeleted = 0
where BI.IsActive = 1 and BI.IsDeleted = 0

--Adding Equipment
select * from Bkg_BookingEquipment (Nolock) 
where bookinginfoid =  @bookingid and IsActive = 1 and IsDeleted = 0

select * from Bkg_BookingEquipmentSealNoMap (Nolock)
where bookinginfoid =  @bookingid and IsDeleted = 0

--Equipment Product Mapping
Select be.EquipmentNumber,BLI.Description,PGL.quantityvalue from Bkg_BookingEquipment BE (Nolock) 
left join Bkg_EquipmentPackageGroupMap EPG (Nolock) on EPG.EquipmentId = BE.id
Left join Bkg_PackageGroupLineItemMap PGL (Nolock) on PGL.PackageGroupId = epg.PackageGroupId 
left join Bkg_LineItem BLI (Nolock) on BLI.id =PGL.LineItemId 
where Be.bookinginfoid =  @bookingid and be.IsDeleted  = 0

 --Adding Vehicle
select * from Bkg_BookingVehicle (Nolock)
where bookinginfoid = @bookingid and IsActive = 1 and IsDeleted = 0

 --Booking Party
select BBP.* from Bkg_BookingParty BBP (Nolock)
left join Sys_PartyTypes PT (Nolock) on BBP.PartyTypeId = pt.id and PT.IsActive = 1 
left join Cust_Party CP (Nolock) on CP.id = BBP.PartyId  and CP.IsActive = 1 and CP.IsDeleted = 0
where BookingInfoId = @bookingid and CP.IsDeleted = 0

select * from Bkg_BookingPartyContact (Nolock)
where Bookingpartyid in (Select id from bkg_bookingparty where bookinginfoid = @bookingid and IsDeleted = 0 )
and IsDeleted = 0

--Consol Booking
Select * from Bkg_ConsolItem CI (Nolock)
join Bkg_BookingInfo BIC (nolock) on BIC.Id = Ci.ConsolBookingId and BIC.IsActive = 1 and BIC.IsDeleted = 0
where BIC.BookingNumber = '17-MC-SHI-CBO-00001'
