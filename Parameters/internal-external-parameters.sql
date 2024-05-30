
-- Query
select distinct [Internal-External] RID,[Internal-External] DESCRIPTION from (
		Select Bi.bookingnumber,EntityId,Entity,	DisplayName 'UDF', 	ef.FieldValue 'Value'
		from Cust_ExtensionFields EF 
		left join Cust_ExtensionFieldMetaData EFMD	on EFMD.Id = ef.ExtensionFieldMetaDataId 
		left join Bkg_BookingInfo BI on BI.id = ef.EntityId
		where bi.BookingNumber is not null 
		) src
		pivot(	min ([Value])	for [UDF] in ([Open Date CY],[Close Date CY],[Internal-External])) piv

-- Data Type            : VARCHAR
-- Size                 : 30
-- Is Access Right Base	: NO
-- Default Control      : Select