--Demo Script

declare @bookingid uniqueidentifier
declare @Billid uniqueidentifier
Select @bookingid = id  from Bkg_BookingInfo where Bookingnumber like '17-MC-SHI-INV-00001'

--ContractAttachmentDetails (Worksheet)
Select * from Contract_BkgCostCntrctAttInfo
Select * from Contract_BkgRevCntrctAttInfo

--MarginDetails
Select * from Contract_BookingMargin 
where BookingProcessId in (SElect id from Bkg_BookingProcess where BookingInfoId = @bookingid) and IsActive = 1 and IsDeleted = 0

Select * from Contract_BookingMarginDetail 
where bookingmarginid in (Select ID from Contract_BookingMargin where BookingProcessId in 
(SElect id from Bkg_BookingProcess where BookingInfoId = @bookingid and IsActive = 1 and IsDeleted = 0) and IsActive = 1 and IsDeleted = 0)
and IsActive = 1 and IsDeleted = 0

--JobSheet
select * from Bill_JobSheetCharge 
where BookingProcessId in (SElect id from Bkg_BookingProcess where BookingInfoId = @bookingid and IsActive = 1 and IsDeleted = 0) 
and IsDeleted = 0

--Officewise amount in JobSheet
Select CO.Name, BaseAmount, BillingAmount, BJC.* from Bill_JobSheetCharge BJC (Nolock)
join Cust_office CO (Nolock) on CO.Id = BJC.OfficeId

--Invoice
Select @billid = BillingDocumentHeaderid from Bill_JobSheetCharge 
where BookingProcessId in (SElect id from Bkg_BookingProcess where BookingInfoId = @bookingid and isactive = 1 and isdeleted = 0) and isdeleted = 0

select * from Bill_BillingDocumentHeader where id =  @billid and isactive = 1 and isdeleted = 0 --3D1D1BAF-B88C-44D9-9C14-A7EB007E9701

select * from Bill_BillingDocumentDetail 
where DocumentHeaderId in (select id from Bill_BillingDocumentHeader where id =  @billid and IsActive = 1 and IsDeleted = 0)
and IsDeleted = 0

--Invoice Charge Allocation
select * from Bill_BillingChrgAllocDtl where BookingInfoId = @bookingid and IsDeleted = 0

--Invoice Tax Allocation
select * from Bill_BillingChargeTaxDetail
where BillingDocumentDetailId in 
		(select id from Bill_BillingDocumentDetail where DocumentHeaderId in 
				(select id from Bill_BillingDocumentHeader where id =  @billid and IsActive = 1 and IsDeleted = 0) and IsDeleted = 0)
and IsDeleted = 0

select * from Bill_BillChrgAllocationTaxDtl 
where BillingChargeAllocDetailId in 
	(select ID from Bill_BillingChargeTaxDetail where BillingDocumentDetailId in 
		(select id from Bill_BillingDocumentDetail where DocumentHeaderId in 
			(select id from Bill_BillingDocumentHeader where id =  @billid and IsActive = 1 and IsDeleted = 0)
		and IsDeleted = 0)
	and IsDeleted = 0)