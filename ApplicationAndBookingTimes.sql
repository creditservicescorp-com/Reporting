USE [DW_Source]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[ApplicationAndBookingTimes]
AS


with cte as(

SELECT 
DATEADD(hh, -4, DATE_APPLIED) as EST_ApplicationDatetime, 
DATE_APPLIED as Utc_ApplicationDatetime, 
cast(DATEADD(hh, -4, DATE_APPLIED) as date) as [EST_ApplicationDate], 
 case 
 when DATEPART(hour,DATEADD(hh, -4, DATE_APPLIED) ) BETWEEN 13 AND 23
 then cast(datepart(hour, convert(varchar, DATEADD(hh,-4, DATE_APPLIED), 100)) - 12 as varchar(10)) + right(convert(varchar, DATEADD(hh,-4, DATE_APPLIED), 100), 2) +' - ' + cast(datepart(hour, convert(varchar, DATEADD(hh,-4, DATE_APPLIED), 100)) - 11 as varchar(10))  + right(convert(varchar, DATEADD(hh,-3, DATE_APPLIED), 100), 2) 
 when DATEPART(hour,DATEADD(hh, -4, DATE_APPLIED) ) = 12 
 then cast(datepart(hour, convert(varchar, DATEADD(hh,-4, DATE_APPLIED), 100))  as varchar(10)) + right(convert(varchar, DATEADD(hh,-4, DATE_APPLIED), 100), 2) +' - ' + cast(1  as varchar(1))  +  right(convert(varchar, DATEADD(hh,-3, DATE_APPLIED), 100), 2)  
 when DATEPART(hour,DATEADD(hh, -4, DATE_APPLIED) ) = 0
 then cast(datepart(hour, convert(varchar, DATEADD(hh,-4, DATE_APPLIED), 100)) + 12  as varchar(10)) + right(convert(varchar, DATEADD(hh,-4, DATE_APPLIED), 100), 2) +' - ' + cast(1  as varchar(1))  + right(convert(varchar, DATEADD(hh,-3, DATE_APPLIED), 100), 2) 
 else cast(datepart(hour, convert(varchar, DATEADD(hh,-4, DATE_APPLIED), 100)) as varchar(10)) + right(convert(varchar, DATEADD(hh,-4, DATE_APPLIED), 100), 2) +' - ' +  cast(datepart(hour, convert(varchar, DATEADD(hh,-3, DATE_APPLIED), 100))  as varchar(10))  + right(convert(varchar, DATEADD(hh,-3, DATE_APPLIED), 100), 2) end as [EST_ApplicationHourRange],
 case 
 when DATEPART(hour,DATEADD(hh, -4, DATE_APPLIED)) BETWEEN 13 AND 23
 then 
 cast(datepart(hour, convert(varchar, DATEADD(hh,-4, DATE_APPLIED), 100))  as varchar(10)) 
 when DATEPART(hour,DATEADD(hh, -4, DATE_APPLIED) ) = 12 
 then cast(datepart(hour, convert(varchar, DATEADD(hh,-4, DATE_APPLIED), 100))   as varchar(10)) 
 when DATEPART(hour,DATEADD(hh, -4, DATE_APPLIED) ) = 0
 then 24
 else cast(datepart(hour, convert(varchar, DATEADD(hh,-4, DATE_APPLIED), 100)) as varchar(10)) end as [EST_ApplicationHourNum]
, DATENAME(dw, DATEADD(hh,-4, DATE_APPLIED)) as [ApplicationDayName], 

 --==================================================================================================
 -- End applied info, start booked info
 --==================================================================================================

 DATEADD(hh, -4, DATE_BOOKED) as EST_BookingDatetime, 
DATE_BOOKED as Utc_BookingDatetime, 
cast(DATEADD(hh, -4, DATE_BOOKED) as date) as [EST_BookingDate], 
  case 
 when DATEPART(hour,DATEADD(hh, -4, DATE_BOOKED) ) BETWEEN 13 AND 23
 then cast(datepart(hour, convert(varchar, DATEADD(hh,-4, DATE_BOOKED), 100)) - 12 as varchar(10)) + right(convert(varchar, DATEADD(hh,-4, DATE_BOOKED), 100), 2) +' - ' + cast(datepart(hour, convert(varchar, DATEADD(hh,-4, DATE_BOOKED), 100)) - 11 as varchar(10))  + right(convert(varchar, DATEADD(hh,-3, DATE_BOOKED), 100), 2) 
 when DATEPART(hour,DATEADD(hh, -4, DATE_BOOKED) ) = 12 
 then cast(datepart(hour, convert(varchar, DATEADD(hh,-4, DATE_BOOKED), 100))  as varchar(10)) + right(convert(varchar, DATEADD(hh,-4, DATE_BOOKED), 100), 2) +' - ' + cast(1  as varchar(1))  +  right(convert(varchar, DATEADD(hh,-3, DATE_BOOKED), 100), 2)  
 when DATEPART(hour,DATEADD(hh, -4, DATE_BOOKED) ) = 0
 then cast(datepart(hour, convert(varchar, DATEADD(hh,-4, DATE_BOOKED), 100)) + 12  as varchar(10)) + right(convert(varchar, DATEADD(hh,-4, DATE_BOOKED), 100), 2) +' - ' + cast(1  as varchar(1))  + right(convert(varchar, DATEADD(hh,-3, DATE_BOOKED), 100), 2) 
 else cast(datepart(hour, convert(varchar, DATEADD(hh,-4, DATE_BOOKED), 100)) as varchar(10)) + right(convert(varchar, DATEADD(hh,-4, DATE_BOOKED), 100), 2) +' - ' +  cast(datepart(hour, convert(varchar, DATEADD(hh,-3, DATE_BOOKED), 100))  as varchar(10))  + right(convert(varchar, DATEADD(hh,-3, DATE_BOOKED), 100), 2) end as [EST_BookingHourRange],
  case 
 when DATEPART(hour,DATEADD(hh, -4, DATE_BOOKED)) BETWEEN 13 AND 23
 then 
 cast(datepart(hour, convert(varchar, DATEADD(hh,-4, DATE_BOOKED), 100))  as varchar(10)) 
 when DATEPART(hour,DATEADD(hh, -4, DATE_BOOKED) ) = 12 
 then cast(datepart(hour, convert(varchar, DATEADD(hh,-4, DATE_BOOKED), 100))   as varchar(10)) 
 when DATEPART(hour,DATEADD(hh, -4, DATE_BOOKED) ) = 0
 then 24
 else cast(datepart(hour, convert(varchar, DATEADD(hh,-4, DATE_BOOKED), 100)) as varchar(10)) end as [EST_BookingHourNum]
  ,DATENAME(dw, DATEADD(hh,-4, DATE_BOOKED)) as [BookingDayName]
  FROM dbo.Extracts_Daily_OraclePDB_LOAN_APPLICATION app WITH (NOLOCK)
  )

 select * from cte 
 


GO


