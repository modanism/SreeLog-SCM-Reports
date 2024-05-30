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
Declare @Trucker varchar(100)
DECLARE @ServiceType uniqueidentifier
Declare @ReportFor varchar(40)
Declare @serviceClass varchar(40)

SET @Office #~6$ET$@OFFICECODE$L$MY~#
SET @Client #~2$ET$@CLIENT$T$MN~#
SET @PortOfLoading = ''
SET @PortOfDischarge = ''
SET @FromDate #~3$ET$@FROMDATE$T$MN~#
SET @ToDate #~4$ET$@TODATE$T$MN~#
SET @JobType = 'Local' -- #~6$ET$@JOBTYPE$T$MN~#
SET @ShipmentStatus #~5$ET$@JOBSTATUS1$L$MN~#
SET @Trucker #~5$ET$@PARTY$T$MN~#
SET @ReportFor #~7$ET$@REPORTFOR$D$MN~#

/*
SET @Office = 'IBJKT'
SET @Client = ''
SET @PortOfLoading = ''
SET @PortOfDischarge = ''
SET @FromDate = '1 sep 20'
SET @ToDate = '30 sep 20'
SET @JobType = 'Local' -- #~6$ET$@JOBTYPE$T$MN~#
SET @ShipmentStatus = ''
SET @ShippingLine = ''
*/

SELECT @ServiceType = id from Sys_Service where Code = 'Road-Freight'


---------------- LOGIC ---------------------------------
If(@FromDate <> '')
	SET @FromDt = Cast(@FromDate as DateTime)
else
	SET @FromDt = dbo.fn_getStartEndDate(@ReportFor, 'From')

If(@ToDate <> '')
	SET @ToDt = Cast(@ToDate + ' 23:59:59' as DateTime)
else
    Set @ToDt = dbo.fn_getStartEndDate(@ReportFor, 'To')

declare @ShipperType uniqueidentifier
declare @ConsingeeType uniqueidentifier
Declare @CarrierType uniqueidentifier


select @ShipperType = Id from Sys_PartyTypes where Code = 'Shipper'
select @ConsingeeType = Id from Sys_PartyTypes where Code = 'Consignee'
select @CarrierType = id from Sys_PartyTypes where Code = 'ShippingLine'

CREATE TABLE #Jobs
(

Office VARCHAR(100), ClientName VARCHAR(100), SalesPIC VARCHAR(100), BookingNo VARCHAR(50), BookingDate DateTime,
JobType VARCHAR(20), JobNo VARCHAR(50), Shipper VARCHAR(100), Consignee VARCHAR(100),
JobStatus VARCHAR(20), CreatedBy VARCHAR(50), CreatedOn DateTime,
ETD DateTime, ETA DateTime, ATD DateTime, ATA DateTime, RSD DateTime,
Carrier VARCHAR(100), MBL VARCHAR(200), MBLDate DateTime, HBL VARCHAR(200), HBLDate DateTime,
POLCode VARCHAR(50), POLName VARCHAR(100), PODCode VARCHAR(50), PODName VARCHAR(100),
PlaceOfReceiptCode VARCHAR(50), PlaceOfReceiptName VARCHAR(100),
PlaceOfDeliveryCode VARCHAR(50), PlaceOfDeliveryName VARCHAR(100),
OriginCountry VARCHAR(100), DestinationCountry VARCHAR(100),
TotalPackages Numeric(26, 5), TotalPackagesUOM VARCHAR(50),
TotalNetWeight Numeric(26, 5), TotalGrossWeight Numeric(26, 5), TotalWeightUOM VARCHAR(50),
TotalVolume Numeric(26, 5), TotalVolumeUOM VARCHAR(50),
VesselName VARCHAR(100), VoyageNo VARCHAR(50), VoyageDate DateTime,

VehicleNo varchar(20), Ownership varchar(20), Trucker Varchar(100),

JobShipperRef VARCHAR(100), PONo VARCHAR(100),
Remarks VARCHAR(300), [Service Class] varchar(40)

)

INSERT INTO #Jobs
select COff.Code 'Office', Client.Name 'Client', '' 'SalesPIC', BI.BookingNumber 'BookingNo', BI.BookingDate 'BookingDate',
BP.Code 'JobType', BP.ProcessNumber 'JobNo', ShipperParty.Name 'Shipper', ConsigneeParty.Name 'Consignee',
BP.Status 'JobStatus', BP.CreatedBy 'JobCreatedBy', BP.CreatedOn 'JobCreatedOn',
BS.ETDDatetime 'ETD', BS.ETADatetime 'ETA', BS.ATDDatetime 'ATD', BS.ATADatetime 'ATA',
convert(varchar(12), dbo.fn_TimeZone(BI.ETDDatetime, BI.ETDTimeZoneId), 106) 'RSD',
ShippingLineParty.Name 'Carrier', BS.WayBillNo 'MBL', BS.WayBillDate 'MBLDate', BS.HouseWayBillNo 'HBL', BS.HouseWayBillDate 'HBLDate',
PL.Code 'PortOfLoadingCode', PL.Name 'PortOfLoadingName', PD.Code 'PortOfDischargeCode', PD.Name 'PortOfDischargeName',
POR.Code 'PlaceOfReceiptCode', POR.Name 'PlaceOfReceiptName', POD.Code 'PlaceOfDeliveryCode', POD.Name 'PlaceOfDeliveryName',
OCountry.Name 'CountryOfOrigin', DCountry.Name 'CountryOfDestination', BS.TotalPackages, PackageUOM.Name 'PackageUOM',
BS.NetWeight 'TotalNetWeight', BS.GrossWeight 'TotalGrossWeight', WeightUOM.Code 'TotalWeightUOM', BS.VolumeValue 'TotalVolume', VolumeUOM.Code 'TotalVolumeUOM',
BS.VesselName, BS.VoyageNo, BS.VoyageDateDateTime 'VesselVoyageDate',

-- VEHICLE --
VEH.VehicleNumber, VEH.Ownership, PV.Name 'Trucker',

BI.ShipperReference 'JobShipperRef', BI.PONo 'PONo',
CASE WHEN BS.Notes is not null THEN BS.Notes else BI.Remarks END 'Remarks',
SCLASS.Description 'Service Class'

from Bkg_BookingProcess BP WITH (NOLOCK)
	LEFT JOIN cust_office cOff WITH (NOLOCK) ON cOff.Id = BP.executingOfficeId AND cOff.IsActive = 1 AND cOff.IsDeleted = 0
	LEFT JOIN Sys_TransportationMode TSMode WITH (NOLOCK) ON BP.TransportationModeId = TSMode.Id AND tsMode.IsActive = 1
	INNER JOIN Bkg_BookingService BS WITH (NOLOCK) ON BP.BookingServiceId = bs.Id AND bs.IsDeleted = 0 AND bs.IsActive = 1
		LEFT JOIN Bkg_BookingParty ShipperParty ON BS.Id = ShipperParty.BookingServiceId
			AND ShipperParty.PartyTypeId = @ShipperType and ShipperParty.IsDeleted = 0
		LEFT JOIN Bkg_BookingParty ConsigneeParty ON BS.Id = ConsigneeParty.BookingServiceId
			AND ConsigneeParty.PartyTypeId = @ConsingeeType and ConsigneeParty.IsDeleted = 0
		LEFT JOIN Bkg_BookingParty ShippingLineParty ON BS.Id = ConsigneeParty.BookingServiceId
			AND ConsigneeParty.PartyTypeId = @CarrierType and ConsigneeParty.IsDeleted = 0
		LEFT JOIN Cust_Location PL WITH (NOLOCK) ON PL.ID = BS.portofLoadingId
		LEFT JOIN Cust_Location PD WITH (NOLOCK) ON PD.ID = BS.PortOfDischargeId
		LEFT JOIN Cust_Location POR WITH (NOLOCK) ON POR.ID = BS.portofLoadingId
		LEFT JOIN Cust_Location POD WITH (NOLOCK) ON POD.ID = BS.PortOfDischargeId
		LEFT JOIN Sys_UOM WeightUOM WITH (NOLOCK) ON WeightUOM.ID = BS.[WeightUOMId]
		LEFT JOIN Sys_UOM VolumeUOM WITH (NOLOCK) ON VolumeUOM.ID = BS.VolumeUOMId
		LEFT JOIN Cust_Country OCountry WITH (NOLOCK) on BS.CountryOfOriginId = OCountry.Id
		LEFT JOIN Cust_Country DCountry WITH (NOLOCK) on BS.CountryOfDestinationId = DCountry.Id
		LEFT JOIN Sys_UOM PackageUOM WITH (NOLOCK) ON BS.PackageUOMId = PackageUOM.Id AND PackageUOM.UOMType = 'Packages'
		INNER JOIN Bkg_BookingInfo BI WITH (NOLOCK) ON bs.BookingInfoId = BI.Id AND BI.IsActive = 1
			LEFT JOIN cust_clients Client WITH (NOLOCK) ON BI.ClientId = Client.Id AND client.IsActive = 1 AND Client.IsDeleted = 0
		left join cust_serviceclass SCLASS on SCLASS.id = BS.ServiceClassId
	LEFT JOIN Bkg_BookingVehicle VEH ON BP.Id = VEH.BookingProcessId
		and VEH.IsDeleted = 0 and VEH.BookingInfoId=BI.Id
		left join Cust_Party PV on PV.id = VEH.PartyId

	LEFT JOIN Sys_Process SYSPROC WITH(NOLOCK) ON SYSPROC.Id = BP.ProcessId
	LEFT JOIN Road_RoadProcess RP WITH(NOLOCK) ON RP.Id = BP.Id


WHERE SYSPROC.ServiceId = @ServiceType
	AND cOff.Code = @Office
	AND (@Client = '' OR Client.Code = @Client)
	AND (BP.Code = @JobType OR @JobType = '')
	AND (BI.BookingDate BETWEEN @FromDt AND @ToDt)
	AND (BP.Status <> 'Cancelled') AND (isnull(@ShipmentStatus, '') = '' or BP.Status = @ShipmentStatus)
	AND (isNull(@Trucker, '') = '' OR PV.Name like '%' + isNull(@Trucker, '') + '%')

	--Test
	--AND (isNull(@serviceClass, '') = '' OR SCLASS.Code = '%' + isNull(@serviceClass, '') + '%')


SELECT ClientName 'Client', [Service Class], JobNo, 
	convert(varchar(12), BookingDate, 106) 'Booking Date',
	Shipper, Consignee, JobShipperRef,
	TotalPackages 'Pkgs', TotalNetWeight 'Net Wt', TotalGrossWeight 'Gross Wt', TotalWeightUOM 'Wt Uom',
	VehicleNo, Ownership, Trucker, 
	PlaceOfReceiptName 'Origin', PlaceOfDeliveryName 'Destination', JobStatus,
	Remarks


FROM #Jobs
Order by BookingDate

DROP TABLE #Jobs