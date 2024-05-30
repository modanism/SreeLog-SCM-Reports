Declare @Office varchar(20)
Declare @Client varchar(20)
Declare @PortOfLoading Varchar(20)
Declare @PortOfDischarge Varchar(20)
Declare @FromDate Varchar(20)
Declare @ToDate Varchar(20)
Declare @JobType Varchar(20)
Declare @ShipmentStatus Varchar(20)
Declare @CustomerId uniqueidentifier
Declare @FromDt DateTime
declare @ToDt DateTime
Declare @ShippingLine varchar(100)
Declare @SalesPIC varchar(100)
DECLARE @ServiceType uniqueidentifier
declare @POL varchar(120)
Declare @POD varchar(120)

SET @PortOfLoading = ''
SET @PortOfDischarge = ''
SET @JobType = 'Export'
SET @ShipmentStatus = ''

SET @Client #~2$ET$@CLIENT$T$MN~#
SET @FromDate #~3$ET$@FROMDATE$T$MY~#
SET @ToDate #~4$ET$@TODATE$T$MY~#
SET @ShippingLine #~6$ET$@SHIPPINGLINE$D$MN~#
SET @SalesPIC #~7$ET$@SALESPERSONS$L$MN~#
set @POL #~8$ET$@PORTOFLOADING$T$MN~#
set @POD #~9$ET$@PORTOFDISCHARGE$T$MN~#




SELECT @ServiceType = id from Sys_Service where Code = 'Sea-Freight'


---------------- LOGIC ---------------------------------
If(@FromDate <> '')
	SET @FromDt = Cast(@FromDate as DateTime)
If(@ToDate <> '')
	SET @ToDt = Cast(@ToDate + ' 23:59:59' as DateTime)


declare @ShipperType uniqueidentifier
declare @ConsingeeType uniqueidentifier
Declare @CarrierType uniqueidentifier


select @ShipperType = Id from Sys_PartyTypes where Code = 'Shipper'
select @ConsingeeType = Id from Sys_PartyTypes where Code = 'Consignee'
select @CarrierType = id from Sys_PartyTypes where Code = 'ShippingLine'

CREATE TABLE #SeaJobs
(
	Office VARCHAR(100), ClientName VARCHAR(100), SalesPIC VARCHAR(100), BookingNo VARCHAR(50), BookingDate DateTime,BookingStatus VARCHAR(50),
	JobType VARCHAR(20), JobNo VARCHAR(50), Shipper VARCHAR(100), Consignee VARCHAR(100), 
	JobStatus VARCHAR(20), CreatedBy VARCHAR(50), CreatedOn DateTime,
	ETD DateTime, ETA DateTime, ATD DateTime, ATA DateTime, RSD Datetime,
	Carrier VARCHAR(100), MBL VARCHAR(100), MBLDate DateTime, HBL VARCHAR(100), HBLDate DateTime,
	POLCode VARCHAR(50), POLName VARCHAR(100), PODCode VARCHAR(50), PODName VARCHAR(100),
	PlaceOfReceiptCode VARCHAR(50), PlaceOfReceiptName VARCHAR(100),
	PlaceOfDeliveryCode VARCHAR(50), PlaceOfDeliveryName VARCHAR(100),
	OriginCountry VARCHAR(100), DestinationCountry VARCHAR(100),
	TotalPackages Numeric(26, 5), TotalPackagesUOM VARCHAR(50),
	TotalNetWeight Numeric(26, 5), TotalGrossWeight Numeric(26, 5), TotalChargeableWeight Numeric(26, 5), TotalWeightUOM VARCHAR(50),
	TotalVolume Numeric(26, 5), TotalVolumeUOM VARCHAR(50),
	VesselName VARCHAR(100), VoyageNo VARCHAR(50), VoyageDate DateTime,
	[Open Date CY]VARCHAR(100) ,[Close Date CY] VARCHAR(100),[Internal/External] VARCHAR(100),
	Sequence int,
	ActivityName VARCHAR(50), ActivityETD DateTime, ActivityETA DateTime,
	ActivityATD DateTime, ActivityATA DateTime, ActivityDuration varchar(20), NextActivityGap Varchar(20),
	ActivityUpdatedon DateTime, ActivityUpdateby VARCHAR(50),
	CarrierBookingNo VARCHAR(50),Bookingid uniqueidentifier,processid uniqueidentifier,BkServiceid uniqueidentifier,
	servicecode varchar(50),ShipmentMode varchar(50),
	SalesPICNAME varchar(50)
)

INSERT INTO #SeaJobs
select COff.Code 'Office', Client.Name 'Client', SLPIC.Contact_Email 'SalesPIC', BI.BookingNumber 'BookingNo', BI.BookingDate 'BookingDate',Bi.Status 'BookingStatus', 
BP.Code 'JobType', BP.ProcessNumber 'JobNo', ShipperParty.Name 'Shipper', ConsigneeParty.Name 'Consignee',
BP.Status 'JobStatus', BP.CreatedBy 'JobCreatedBy', BP.CreatedOn 'JobCreatedOn',
BS.ETDDatetime 'ETD', BS.ETADatetime 'ETA', BS.ATDDatetime 'ATD', BS.ATADatetime 'ATA',
convert(varchar(12), dbo.fn_TimeZone(BI.ETDDatetime, BI.ETDTimeZoneId), 106) 'RSD',
ShippingLineParty.Name 'Carrier', BS.WayBillNo 'MAWB', BS.WayBillDate 'MAWBDate', BS.HouseWayBillNo 'HAWB', BS.HouseWayBillDate 'HAWBDate',
PL.Code 'PortOfLoadingCode', PL.Name 'PortOfLoadingName',
PD.Code 'PortOfDischargeCode', PD.Name 'PortOfDischargeName',
POR.Code 'PlaceOfReceiptCode', POR.Name 'PlaceOfReceiptName',
POD.Code 'PlaceOfDeliveryCode', POD.Name 'PlaceOfDeliveryName',
OCountry.Name 'CountryOfOrigin', DCountry.Name 'CountryOfDestination', 
BS.TotalPackages, PackageUOM.Name 'PackageUOM',
BS.NetWeight 'TotalNetWeight', BS.GrossWeight 'TotalGrossWeight', BS.ChargeableWeight 'Total Chargable Weight',
WeightUOM.Code 'TotalWeightUOM', BS.VolumeValue 'TotalVolume', VolumeUOM.Code 'TotalVolumeUOM',
BS.VesselName, BS.VoyageNo, BS.VoyageDateDateTime 'VesselVoyageDate',

-- UserDefined Field
cf.[Open Date CY],cf.[Close Date CY],[Internal-External],
-- ACTIVITY --
Act.SequenceNumber as Sequence,
ACT.Name, ACT.ETDDatetime 'ActivityETD', ACT.ETADatetime 'ActivityETA', 
	ACT.ATDDatetime 'ActivityATD', ACT.ATADatetime 'ActivityATA', ACT.Duration, ACT.NextActivityGap,
	act.LastModifiedOn,act.LastModifiedBy,
	Bs.CarrierBookingReferenceNumber 'CarrierBookingNo',
	Bi.id,bp.id,BS.Id,ss.code as servicecode,
	SM.Name as ShipmentMode,salespicNAME


from Bkg_BookingInfo BI WITH (NOLOCK) 
	left join Bkg_BookingProcess BP WITH (NOLOCK) on BP.BookingInfoId = bi.id
	LEFT JOIN cust_office cOff WITH (NOLOCK) ON cOff.Id = BP.OwnerOfficeId AND cOff.IsActive = 1 AND cOff.IsDeleted = 0
	LEFT JOIN Sys_TransportationMode TSMode WITH (NOLOCK) ON BP.TransportationModeId = TSMode.Id AND tsMode.IsActive = 1
	Left JOIN Bkg_BookingService BS WITH (NOLOCK) ON BP.BookingServiceId = bs.Id AND bs.IsDeleted = 0 AND bs.IsActive = 1
		LEFT JOIN Bkg_BookingParty ShipperParty ON BS.Id = ShipperParty.BookingServiceId 
			AND ShipperParty.PartyTypeId = @ShipperType and ShipperParty.IsDeleted = 0
		LEFT JOIN Bkg_BookingParty ConsigneeParty ON BS.Id = ConsigneeParty.BookingServiceId 
			AND ConsigneeParty.PartyTypeId = @ConsingeeType and ConsigneeParty.IsDeleted = 0
		LEFT JOIN Bkg_BookingParty ShippingLineParty ON BS.Id = ShippingLineParty.BookingServiceId 
			AND ShippingLineParty.PartyTypeId = @CarrierType and ShippingLineParty.IsDeleted = 0
		LEFT JOIN Cust_Location PL WITH (NOLOCK) ON PL.ID = BS.portofLoadingId
		LEFT JOIN Cust_Location PD WITH (NOLOCK) ON PD.ID = BS.PortOfDischargeId
		LEFT JOIN Cust_Location POR WITH (NOLOCK) ON POR.ID = BS.portofLoadingId
		LEFT JOIN Cust_Location POD WITH (NOLOCK) ON POD.ID = BS.PortOfDischargeId
		LEFT JOIN Sys_UOM WeightUOM WITH (NOLOCK) ON WeightUOM.ID = BS.[WeightUOMId]
		LEFT JOIN Sys_UOM VolumeUOM WITH (NOLOCK) ON VolumeUOM.ID = BS.VolumeUOMId
		LEFT JOIN Cust_Country OCountry WITH (NOLOCK) on BS.CountryOfOriginId = OCountry.Id
		LEFT JOIN Cust_Country DCountry WITH (NOLOCK) on BS.CountryOfDestinationId = DCountry.Id
   		LEFT JOIN Sys_UOM PackageUOM WITH (NOLOCK) ON BS.PackageUOMId = PackageUOM.Id AND PackageUOM.UOMType = 'Packages'
	
		LEFT JOIN cust_clients Client WITH (NOLOCK) ON BI.ClientId = Client.Id AND client.IsActive = 1 AND Client.IsDeleted = 0
	LEFT JOIN Bkg_BookingActivity ACT ON ACT.BookingProcessId = BP.Id AND ACT.IsDeleted = 0
	LEFT JOIN Sys_Process SYSPROC WITH(NOLOCK) ON SYSPROC.Id = BP.ProcessId
	left join Sys_Service SS with(nolock) on ss.id = bs.ServiceId
	left join Sys_ShipmentMode SM with(nolock) on SM.id = bi.ShipmentModeId
	--Custom fields
Left join (select * from (
								Select Processnumber,Bi.bookingnumber,EntityId,Entity,	DisplayName 'UDF', 	ef.FieldValue 'Value'
								from Cust_ExtensionFields EF left join Cust_ExtensionFieldMetaData EFMD
								on EFMD.Id = ef.ExtensionFieldMetaDataId Left join  Bkg_BookingProcess BP on bp.id = ef.EntityId left join Bkg_BookingInfo BI on BI.id = bp.BookingInfoId
								where bi.BookingNumber is not null and Entity = 'Sea'
								) src
								pivot(	min ([Value])	for [UDF] in ([Open Date CY],[Close Date CY],[Vessel Name])) piv 	
				) as CF 
on CF.BookingNumber = bi.BookingNumber and cf.ProcessNumber = bp.ProcessNumber

Left join (select * from (
		Select Bi.bookingnumber,EntityId,Entity,	DisplayName 'UDF', 	ef.FieldValue 'Value'
		from Cust_ExtensionFields EF 
		left join Cust_ExtensionFieldMetaData EFMD	on EFMD.Id = ef.ExtensionFieldMetaDataId 
		left join Bkg_BookingInfo BI on BI.id = ef.EntityId
		where bi.BookingNumber is not null 
		) src
		pivot(	min ([Value])	for [UDF] in ([Open Date CY],[Close Date CY],[Internal-External])) piv 	
		) as BCF 
on BCF.BookingNumber = bi.BookingNumber 

-- Sales PIC
left join (Select Bi.Id, CR.Contact_Email + '[' + cr.Contact_PersonName_FirstName + ']' as Contact_Email,cr.Contact_PersonName_FirstName + ' ' + cr.Contact_PersonName_LastName AS salespicNAME from 
Bkg_BookingTeam BT with(nolock) 
inner join Bkg_BookingInfo BI with(nolock) on BI.id = bt.BookingInfoId and bt.IsDeleted = 0  
inner join Cust_ResOfficeResFuncMap RORF with(nolock) on RORF.Id = bt.ResOfficeResFuncMapId
inner join Cust_Resource CR with(nolock) on cr.Id = bt.ResourceId
inner join Sys_ResourceFunction RF with(nolock) on rf.Id = rorf.ResourceFunctionId and rf.id = '457d6ee0-e130-4948-8359-3a7c3ca38a51') as SLPIC
on SLPIC.id = bi.Id

	WHERE isnull(BP.Status,'') not in ('Completed','Cancel','Close') and ShipperParty.Name is not null
		AND cOff.Code = 'JKT'
		and bi.Status = 'Confirmed'
		AND (@Client = '' OR Client.Code = @Client)
		AND (BI.BookingDate BETWEEN @FromDt AND @ToDt)
		AND (isNull(@ShippingLine, '') = '' OR ShippingLineParty.Name like '%' + isNull(@ShippingLine, '') + '%')
		AND (isNull(@SalesPIC, '') = '' OR SLPIC.salespicNAME like '%' + isNull(@ShippingLine, '') + '%')
		AND (isNull(@POL, '') = '' OR PL.Code like '%' + isNull(@POL, '') + '%')
		AND (isNull(@POD, '') = '' OR PD.Code like '%' + isNull(@POD, '') + '%')

		


select Distinct Office , ClientName , SalesPIC , BookingNo , BookingDate ,BookingStatus ,
	JobType, JobNo, Shipper, Consignee, 
	JobStatus, CreatedBy, CreatedOn,
	ETD, ETA, ATD, ATA, RSD ,
	Carrier, MBL, MBLDate , HBL , HBLDate,
	POLCode , POLName , PODCode , PODName ,
	PlaceOfReceiptCode , PlaceOfReceiptName ,
	PlaceOfDeliveryCode , PlaceOfDeliveryName ,
	OriginCountry , DestinationCountry ,
	TotalPackages , TotalPackagesUOM ,
	TotalNetWeight , TotalGrossWeight , TotalChargeableWeight , TotalWeightUOM ,
	TotalVolume , TotalVolumeUOM ,
	VesselName , VoyageNo , VoyageDate ,
	[Open Date CY] ,[Close Date CY] ,[Internal/External] ,
	CarrierBookingNo ,Bookingid ,processid,BKServiceid,servicecode,ShipmentMode,SalesPICNAME
	Into #BKDetails From #SeaJobs 

	

-- Get Booking equipment details
select sj.BookingNo,bp.ProcessNumber,ces.code as Esize, Be.id as Ecount  into #Equipment 
from #BKDetails sj with (Nolock)
left join Bkg_BookingProcess BP  with(nolock) on bp.BookingInfoId = sj.Bookingid and bp.id = sj.processid
left join Bkg_BookingEquipment bE with(Nolock) on be.BookingProcessId = bp.id and be.IsDeleted = 0 
left join Cust_Equipment CE with(Nolock) on ce.id = be.EquipmentId
left join Cust_EquipmentSize CES with(Nolock) on ces.id = ce.EquipmentSizeId
group by sj.BookingNo,bp.ProcessNumber,ces.code, Be.id 



select BookingNo,ProcessNumber,Esize, count(Ecount) as Ecount Into #EquipmentDetails 
from #Equipment group by BookingNo,ProcessNumber,Esize


update #EquipmentDetails set esize = 'Others' where esize not in ('20','40')

select *,Cast('' as varchar(30)) as ContainerSumamry  into #BkgEQPDetails from (	select BookingNo,ProcessNumber,Esize, Ecount as 'Value' from #EquipmentDetails
		) src
		pivot(	min ([Value])	for [Esize] in ([20],[40],[Others])) piv 	

update #BkgEQPDetails set ContainerSumamry = ContainerSumamry + cast([20] as varchar(20)) + ' X 20"' where [20] is not null
update #BkgEQPDetails set ContainerSumamry = ContainerSumamry + cast([40] as varchar(20)) + ' X 40"' where [40] is not null
update #BkgEQPDetails set ContainerSumamry = ContainerSumamry + cast([Others] as varchar(20)) + ' X Other' where [Others] is not null




Select bk.MBL, bk.BookingNo, bk.ClientName , bk.POLName, bk.PODName, right(convert(varchar(50), bk.BookingDate ,6),6) as Monthyear,
Sum(bkeq.[20]) as [20], sum(BKeq.[40]) as [40] ,Sum(bkeq.Others) as [Others],
Sum(bk.TotalNetWeight) as NetWtight,Sum(bk.TotalVolume) as TotalVolume , bk.Carrier,
Bk.SalesPIC,bk.servicecode,ShipmentMode
into #details  from #BKDetails BK
left join #BkgEQPDetails BKEQ on BKEQ.BookingNo = bk.BookingNo and bkeq.ProcessNumber = bk.JobNo
where bk.servicecode in ('Sea-Freight','Air-Freight')
group by bk.MBL, bk.BookingNo, bk.ClientName , bk.POLName, bk.PODName,right(convert(varchar(50), bk.BookingDate ,6),6),
bk.Carrier,Bk.SalesPIC,bk.servicecode,ShipmentMode

update #details set NetWtight = 0 where ShipmentMode <> 'LCL'
update #details set TotalVolume = 0 where servicecode <> 'Air-Freight'

select  MBL, BookingNo, ClientName , POLName, PODName, Monthyear,
Sum([20]) as [20], sum([40]) as [40] ,Sum(Others) as [Others],
Sum(NetWtight) as LCL,Sum(TotalVolume) as [AFR] ,Carrier,
SalesPIC from #details
group by MBL, BookingNo, ClientName , POLName, PODName, Monthyear,Carrier,SalesPIC

DROP TABLE #SeaJobs

--SELECT right(convert(varchar(50), getdate(),6),6) 





