USE [DW_Source]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[viewReport_FIP]
AS


SELECT distinct
	la.DATE_BOOKED [Booking Date]	
	,(
		CASE 
			WHEN la.LoanApplicationTypeId = 1
				THEN 'Full Application'
			WHEN la.LoanApplicationTypeId = 2
				THEN 'Additional Funding'
			END
		) [Loan Applicantion Type]
	,la.EXT_REF_NO [Loan Number]
	,(CASE 
		WHEN MOS.OfferCount > 1
			THEN 'True'
		ELSE	'False'
		END) [MultipleOfferFlag]
	, LAC.ApplicationCount
	,'' [KYC Status]
	,'' [KYC Notes]
	,'' [Pends Resolution Date]
	,FORMAT(la.ESTIMATED_SERVICE_DATE, 'MM/dd/yyyy') [Date Funded]
	,'' [CRB Status]
	,'' [US Bank KYC Status]
	,'' [US Bank Pends Resolution Date]
	,'' [HCS/US Bank]
	,'' [HCS Exception Notes]
	,ar.LastName [Borrower Last Name]
	,ar.FirstName [Borrower First Name]
	,FORMAT(CONVERT(DATETIME,ar.DOB, 100), 'yyyyMMdd') [Borrower DOB]
	,REPLACe(a.SSN,'-','') [Borrower SSN]
	,ad_Physical.STREET_LINE_1 [Borrower Address]
	,ad_Physical.CITY [Borrower City]
	,ad_Physical.STATE [Borrower State]
	,ad_Physical.ZIP_CODE [Borrower Zip]
	,la.TERMS [Term]
	,CONVERT(DECIMAL(12, 2), la.APR * 100) [APR]
	,(CONVERT(DECIMAL(12, 2), la.MONTHLY_PAYMENT) * la.TERMS - la.loan_Amount) AS [Finance Charge]
	,CONVERT(DECIMAL(12, 2), la.MONTHLY_PAYMENT * la.TERMS) [Total Payments]
	,CONVERT(DECIMAL(12, 2), la.LOAN_AMOUNT) [Loan Amount]
	,CONVERT(DECIMAL(12, 3), la.MONTHLY_PAYMENT) [Current Monthly Payment]
	,CASE 
		WHEN COALESCE(la.Promo_Term, 0) > 0
			THEN 'Yes'
		ELSE 'No'
		END [SAC Y/N]
	,FORMAT(CONVERT(DATETIME,la.[ESTIMATED_SERVICE_DATE], 100), 'yyyyMMdd') [Treatment Date]
	,FORMAT(CONVERT(DATETIME, dateadd(D, 35, la.ESTIMATED_SERVICE_DATE), 100), 'MM/dd/yyyy') [First Payment Due Date]
	,ofc.ProviderName [Provider]
	,la.MDF [MDF]
	,id.NAME [Identification Type]
	,ai.IdentificationStateIssuance [ID Issuer]
	,ai.IdentificationNumber [Id Number]
	,REPLACE(TRY_CONVERT(VARCHAR,ai.IdentificationExpirationDate, 6),' ','-') [Id Expiration Date]
	,la.Applicant_Id [Borrower ID]
	,'CSC' [Platform]
	,ar.PhoneNumber [Borrower Phone Number]
	,ar.MobileNumber [Borrower Mobile Number]
	,ar.[EMAIL] [Borrower Email]
	,0 - CONVERT(DECIMAL(12, 2), (la.LOAN_AMOUNT * (1 - la.mdf))) AS [Net Funding 1]
	,'6' [Asset Class]
	,'Medical' [Loan Purpose]
	,s.STATUS_NAME [Loan Status]
	,'CSC' [Investor]
	,'TCI' [Servicer]
	,CONVERT(VARCHAR, la.DATE_APPLIED, 112) [Application Date]
	,CONVERT(VARCHAR, la.DATE_APPLIED, 112) [Reg B Decision Date]
	,CONVERT(VARCHAR, dateadd(D, 1, la.DATE_APPLIED), 112) [Note Date]
	,CONVERT(VARCHAR, dateadd(D, 4, la.DATE_APPLIED), 112) [Purchase Date]
	,CONVERT(VARCHAR, dateadd(D, 35, la.ESTIMATED_SERVICE_DATE), 112) [Payment Due Date]
	,CONVERT(DECIMAL(12, 2), la.LOAN_AMOUNT) [Approved Loan Amount]
	,'Monthly' [PmtFreq]
	,0 [Origination Fee]
	,CONVERT(DECIMAL(12, 3), la.APR * 100) [Rate]
	,la.TERMS [Amortization]
	,1 [Rate Type]
	,'no' [Prior Loan Flag]
	,d_arch.FICO AS [FICO]
	,CONVERT(VARCHAR, la.DATE_APPLIED, 112) AS [FICO Date]
	,d_arch.FICO AS [Credit Grade]
	,CONVERT(DECIMAL(12, 2), cr.RevUtilization / 100.0) AS [Debt Utilization]
	,CONVERT(DECIMAL(12, 3), cr.RevBalance) AS [Total Revolving Debt]
	,'' [Credit Inquiries-12 months]
	,'' [DQ - Past 24 months]
	,'' [Accounts Opened - Past 24 months]
	,'' [Open Credit Lines]
	,'' [Collections Excluding Medical]
	,'' [Public Records On File]
	,'' [Months Since Last Record]
	,'' [Homeowner Flag]
	,'' [Employment Length]
	,'' [Employer]
	,CONVERT(DECIMAL(15, 3), ae.GROSS_INCOME) [Annual Income]
	,CONVERT(DECIMAL(12, 2), 75*(cr.[DebttoIncomeRatio] / 100.0)) AS [DTI]
	,d_arch.MLA_Flag [MLA Flag]
	,CONVERT(DECIMAL(12, 2), la.APR * 100) [MAPR]
	,(
		CASE 
			WHEN mhb.MERCHANT_HIERARCHY_BANK_ID IS NULL
				THEN mb.routing_number
			ELSE mhb.routing_number
			END
		) [Bank Routing Number]
	,(
		CASE 
			WHEN mhb.MERCHANT_HIERARCHY_BANK_ID IS NULL
				THEN mb.account_number
			ELSE mhb.account_number
			END
		) [Bank Account Number]
	,1 [Account Type]
	,'CCD' [Standard Entry Type Code]
	,ofc.ProviderName [Receiver Name]
	,'N' [Same Day Flag]
	,'' [AddendaRecord]
	,ofc.ProviderName [Merchant Name]
	,'$'+ CAST(CONVERT(DECIMAL(10,2), (la.LOAN_AMOUNT * la.MDF)) as VARCHAR) [Merchant Fee]
	,pr.RefundAmount [Refund Amount]
	,'' [Adjusted Loan Amount]
	,'' [Adjusted Net Funding]
	,'' [Adjusted Origination Fee]
	,'' [Adjusted Current Monthly Payment]
	,COALESCE(pr.UpdatedDate, pr.[CreatedDate]) [Refund Date]
	,'' [Adjusted Merchant Fee]
	,CONVERT(VARCHAR, dateadd(M, CONVERT(INT, la.Terms), dateadd(D, 35, la.ESTIMATED_SERVICE_DATE)),112) [Final Payment Date]
	,CONVERT(DECIMAL(12, 2), la.MONTHLY_PAYMENT) [Final Payment]
	,12 [PPY]
	,la.[QUORUM_REF_ID] [TCCID]
	,'' [CoBorrower Last Name]
	,'' [CoBorrower First Name]
	,'' [CoBorrower City]
	,'' [CoBorrower State]
	,'' [CoBorrower Zip]
	,'' [CoBorrower DOB]
	,'' [CoBorrower SSN]
	,'' [CoBorrower Phone]
	,'' [CoBorrower Email]
	,'' [CoBorrower FICO]
	,FORMAT(TRY_CONVERT(DATETIME,d_arch.TransactionTimeStamp, 100), 'MM/dd/yyyy HH:mm:ss') [Transaction Time Stamp]
	,d_arch.PartnerReferenceID [Partner Reference Id]
	,ofc.ProviderName [Merchant Processor]
	,(CASE WHEN d_arch.Title = 'NA' THEN '' ELSE d_arch.Title END) [Title]
	,ar.FirstName [First Name]
	,(CASE WHEN d_arch.MI = 'NA' THEN '' ELSE d_arch.MI END) [MI]
	,ar.LastName [LastName]
	,(CASE WHEN d_arch.Generation = 'NA' THEN '' ELSE d_arch.Generation END) [Generation]
	,ad_Physical.STREET_LINE_1 [Physical Address 1]
	,(CASE WHEN ad_Physical.STREET_LINE_2 is null THEN '' ELSE d_arch.PhysicalAddress2 END) [Physical Address 2]
	,ad_Physical.CITY [Physical City]
	,ad_Physical.[STATE] [Physical State]
	,ad_Physical.ZIP_CODE [Physical Zip]
	,d_arch.PhysicalCountryCode [Physical Country Code]
	,d_arch.ResidenceStatus [Residence Status]
	,ad_Mailing.STREET_LINE_1 [Mailing Address 1]
	,(CASE WHEN ad_Mailing.STREET_LINE_2 is null THEN '' ELSE d_arch.MailingAddress2 END) [Mailing Address 2]
	,ad_Mailing.CITY [Mailing City]
	,ad_Mailing.[STATE] [Mailing State]
	,ad_Mailing.ZIP_CODE [Mailing Zip]
	,d_arch.MailingCountryCode [Mailing Country Code]
	,d_arch.TIN [TIN]
	,FORMAT(TRY_CONVERT(DATETIME,d_arch.DOB, 100),'MM/dd/yyyy') [DOB]
	,d_arch.HomePhone [Home Phone]
	,d_arch.PhoneType [Phone Type]
	,(CASE WHEN d_arch.EmailAddress = 'NA' THEN '' ELSE d_arch.EmailAddress END) [Email Address]
	,d_arch.StatusCode [Status Code]
	,d_arch.StatusMessage [Status Message]
	,d_arch.ReferenceID [Reference Id]
	,d_arch.Decision [Decision]
	,FORMAT(TRY_CONVERT(DATETIME,d_arch.DecisionTime), 'MM/dd/yyyy HH:mm:ss') [Decision Time]
	,(CASE WHEN d_arch.AdverseActions = 'NA' THEN '' ELSE d_arch.AdverseActions END) [Adverse Actions]
	,d_arch.BureauAmount [Bureau Amount]
	,la.TRANSACTION_ID [Transaction ID]
	,d_arch.TCIReferenceID [TCI Reference Id]
	,(CASE WHEN d_arch.TCIFamily = 'NA' THEN '' ELSE d_arch.TCIFamily END) [TCI Family]
	,(CASE WHEN d_arch.TCILoss = 'NA' THEN '' ELSE d_arch.TCILoss END) [TCI Loss]
	,(CASE WHEN d_arch.Under18 = 'NA' THEN '' ELSE d_arch.Under18 END) [Under 18]
	,(CASE WHEN d_arch.Fraud = 'NA' THEN '' ELSE d_arch.Fraud END) [Fraud]
	,d_arch.FICO [fico Score]
	,d_arch.CreditCounseling [Credit Counseling]
	,d_arch.Bankruptcy [Bankruptcy]
	,d_arch.Foreclosure [Foreclosure]
	,d_arch.DeliqTradeLines [Deliq Trade Lines]
	,d_arch.QFCU [QFCU]
	,d_arch.EmploymentStatus [Employment Status]
	,d_arch.ApplicationStatus [Application Status]
	,d_arch.FNIQueue [FNI Queue]
	,d_arch.MerchantID [Merchant ID]
	,d_arch.CSCContractID [CSC Contract Id]
	,FORMAT(TRY_CONVERT(DATETIME,d_arch.FundingDate,100), 'MM/dd/yyyy') [Funding Date] 
	,lpd.CODE [Product Type]
	,(CASE WHEN d_arch.LoanDescription = 'NA' THEN '' ELSE d_arch.LoanDescription END) [Loan Description]
	,(CONVERT(DECIMAL(12, 2), la.LOAN_AMOUNT) * 100) [LoanAmount] 
	,CONVERT(DECIMAL(12, 2), la.APR * 10000) [Interest Rate]
	,la.TERMS [Loan Term]
	,(CONVERT(DECIMAL(12, 2), la.MONTHLY_PAYMENT ) * 100) [Loan Payment]
	,REPLACE(CONVERT(VARCHAR(9), TRY_CONVERT(VARCHAR,d_arch.LoanDueDate,103), 6), ' ', '-') [Loan Due Date]
	,(CASE WHEN d_arch.ProductManufacturer = 'NA' THEN '' ELSE d_arch.ProductManufacturer END) [Product Manufacturer]
	,(CASE WHEN d_arch.ProductIdentifier = 'NA' THEN '' ELSE d_arch.ProductIdentifier END) [Product Identifier]
	,(CASE WHEN d_arch.LoanMaturityDate = 'NA' THEN '' ELSE d_arch.LoanMaturityDate END) [Loan Maturity Date]
	,d_arch.[GUID] [GUID]
	,FORMAT(TRY_CONVERT(DATETIME,d_arch.GUIDTimeAndDateStamp, 100), 'MM/dd/yyyy HH:mm:ss') [GUID Time and Stamp]
	,d_arch.BookingStatusCode [Booking Status Code]
	,d_arch.BookingStatusMessage [Booking Status Message]
	,d_arch.BookingTransactionID [Booking Transaction Id]
	,d_arch.PartnerStatus [Partner Status]
	,d_arch.TINType [Tin Type]
	,d_arch.IDType [Id Type]
	,d_arch.IDIssuer [IdIssuer]
	,FORMAT(TRY_CONVERT(DATETIME, d_arch.IDExpirationDate, 100),'MM/dd/yyyy') [IDExpirationDate]
	,d_arch.GrossAnnualIncome [Gross Annual Income]
	,FORMAT(CONVERT(DATETIME,LASH.EsignDate, 100), 'MM/dd/yyyy HH:mm:ss') [Esign Date]
	,FORMAT(CONVERT(DATETIME,d.CreatedDate, 100), 'MM/dd/yyyy HH:mm:ss') as [Contract Date]

FROM dbo.Extracts_Daily_OraclePDB_LOAN_APPLICATION la
JOIN dbo.Extracts_Daily_OraclePDB_APPLICANT a ON a.APPLICANT_ID = la.APPLICANT_ID
JOIN [dbo].[Extracts_Daily_OraclePDB_ApplicationRequest] appr ON appr.ApplicationRequestId = la.LOAN_APPLICATION_ID
JOIN [dbo].[Extracts_Daily_OraclePDB_ApplicantRequest] ar ON appr.ApplicantRequestId = ar.ApplicantRequestId
--JOIN [dbo].[Extracts_Daily_OraclePDB_ApplicantIdentification] ai ON ai.ApplicantRequestId = ar.ApplicantRequestId
OUTER APPLY(SELECT TOP 1 * FROM [dbo].[Extracts_Daily_OraclePDB_ApplicantIdentification] I WHERE I.ApplicantRequestId = ar.ApplicantRequestId ORDER BY ApplicantIdentificationId desc)ai
JOIN dbo.Extracts_Daily_OraclePDB_IDENTIFICATION_TYPE id ON ai.IdentificationTypeId = id.[IDENTIFICATION_TYPE_ID]
JOIN [dbo].[viewProviderEntityOffices] ofc ON ofc.Hierarchy_ID = la.ASSIGNED_OFFICE_ID
JOIN [dbo].[Extracts_Daily_OraclePDB_LOAN_APPLICATION_STATUS] s ON s.LOAN_APPLICATION_STATUS_ID = la.LOAN_APPLICATION_STATUS_ID

LEFT OUTER JOIN dbo.Extracts_Daily_OraclePDB_APPLICANT_EMPLOYER_INFO ae ON ae.ApplicantRequestId = ar.ApplicantRequestId
LEFT OUTER JOIN dbo.Extracts_Daily_OraclePDB_APPLICANT_ADDRESS ad_Physical ON ad_Physical.ApplicantRequestId = ar.ApplicantRequestId and ad_Physical.AddressTypeId = 1 -- Physical address for applicant verified from credit bureau
LEFT OUTER JOIN dbo.Extracts_Daily_OraclePDB_APPLICANT_ADDRESS ad_Mailing ON ad_Mailing.ApplicantRequestId = ar.ApplicantRequestId and ad_Mailing.AddressTypeId = 2 -- Mailing address provided by applicant
LEFT OUTER JOIN [dbo].[Extracts_Daily_OraclePDB_MERCHANT_BANK] mb ON mb.MERCHANT_ID = ofc.ProviderID
LEFT OUTER JOIN [dbo].[Extracts_Daily_OraclePDB_MERCHANT_HIERARCHY_BANK] mhb ON mhb.MERCHANT_HIERARCHY_ID = ofc.Hierarchy_ID
LEFT OUTER JOIN (
	SELECT LoadDate_ID
		,TCIID
		,RevUtilization
		,RevBalance
		,DebttoIncomeRatio
	FROM [dbo].[CreditReports_History] crh
	
	UNION ALL
	
	SELECT LoadDate_ID
		,TCIID
		,RevUtilization
		,RevBalance
		,DebttoIncomeRatio
	FROM [dbo].CreditBureauReports_DailyConsolidatedTable crd
	) AS cr ON cr.TCIID = la.QUORUM_REF_ID
OUTER APPLY (SELECT TOP 1 * FROM  
(select DailyArchive_History_Key
      ,[TransactionTimeStamp]
      ,[PartnerReferenceID]
      ,[MerchantProcessor]
      ,[Title]
      ,[FirstName]
      ,[MI]
      ,[LastName]
      ,[Generation]
      ,[PhysicalAddress1]
      ,[PhysicalAddress2]
      ,[PhysicalCity]
      ,[PhysicalState]
      ,[PhysicalZip]
      ,[PhysicalCountryCode]
      ,[ResidenceStatus]
      ,[MailingAddress1]
      ,[MailingAddress2]
      ,[MailingCity]
      ,[MailingState]
      ,[MailingZip]
      ,[MailingCountryCode]
      ,[TIN]
      ,[DOB]
      ,[HomePhone]
      ,[PhoneType]
      ,[EmailAddress]
      ,[StatusCode]
      ,[StatusMessage]
      ,[ReferenceID]
      ,[Decision]
      ,[DecisionTime]
      ,[AdverseActions]
      ,[BureauAmount]
      ,[TransactionID]
      ,[TCIReferenceID]
      ,[TCIFamily]
      ,[TCILoss]
      ,[Under18]
      ,[Fraud]
      ,[FICO]
      ,[CreditCounseling]
      ,[Bankruptcy]
      ,[Foreclosure]
      ,[DeliqTradeLines]
      ,[QFCU]
      ,[EmploymentStatus]
      ,[ApplicationStatus]
      ,[FNIQueue]
      ,[MerchantID]
      ,[CSCContractID]
      ,[FundingDate]
      ,[ProductType]
      ,[LoanDescription]
      ,[LoanAmount]
      ,[InterestRate]
      ,[LoanTerm]
      ,[LoanPayment]
      ,[LoanDueDate]
      ,[ProductManufacturer]
      ,[ProductIdentifier]
      ,[LoanMaturityDate]
      ,[GUID]
      ,[GUIDTimeAndDateStamp]
      ,[BookingStatusCode]
      ,[BookingStatusMessage]
      ,[BookingTransactionID]
      ,[PartnerStatus]
      ,[TINType]
      ,[IDType]
      ,[IDIssuer]
      ,[IDNumber]
      ,[IDExpirationDate]
      ,[GrossAnnualIncome]
      ,[LoadDate_ID]
      ,[ReferenceID_LoadDate]
      ,[CumCollBal]
      ,[InBal]
      ,[MinDelInqMos]
      ,[MortBalAmt]
      ,[OpnBnkCrdBal]
      ,[OpnBnkCrdHi]
      ,[TotalBal]
      ,[TotalPayments]
      ,[TradesOpen3]
      ,[CHRGOFF_CNT]
      ,[CURRENT_30_BAL]
      ,[CURRENT_60_BAL]
      ,[CURRENT_90_BAL]
      ,[MIN_CHRGOFF_MOS]
      ,[MAX_OPEN_REV_LIMIT]
      ,[MLA_Flag] from [dbo].[CreditReports_DailyArchive_History]
UNION 
SELECT  null
,[TransactionTimeStamp]
      ,[PartnerReferenceID]
      ,[MerchantProcessor]
      ,[Title]
      ,[FirstName]
      ,[MI]
      ,[LastName]
      ,[Generation]
      ,[PhysicalAddress1]
      ,[PhysicalAddress2]
      ,[PhysicalCity]
      ,[PhysicalState]
      ,[PhysicalZip]
      ,[PhysicalCountryCode]
      ,[ResidenceStatus]
      ,[MailingAddress1]
      ,[MailingAddress2]
      ,[MailingCity]
      ,[MailingState]
      ,[MailingZip]
      ,[MailingCountryCode]
      ,[TIN]
      ,[DOB]
      ,[HomePhone]
      ,[PhoneType]
      ,[EmailAddress]
      ,[StatusCode]
      ,[StatusMessage]
      ,[ReferenceID]
      ,[Decision]
      ,[DecisionTime]
      ,[AdverseActions]
      ,[BureauAmount]
      ,[TransactionID]
      ,[TCIReferenceID]
      ,[TCIFamily]
      ,[TCILoss]
      ,[Under18]
      ,[Fraud]
      ,[FICO]
      ,[CreditCounseling]
      ,[Bankruptcy]
      ,[Foreclosure]
      ,[DeliqTradeLines]
      ,[QFCU]
      ,[EmploymentStatus]
      ,[ApplicationStatus]
      ,[FNIQueue]
      ,[MerchantID]
      ,[CSCContractID]
      ,[FundingDate]
      ,[ProductType]
      ,[LoanDescription]
      ,[LoanAmount]
      ,[InterestRate]
      ,[LoanTerm]
      ,[LoanPayment]
      ,[LoanDueDate]
      ,[ProductManufacturer]
      ,[ProductIdentifier]
      ,[LoanMaturityDate]
      ,[GUID]
      ,[GUIDTimeAndDateStamp]
      ,[BookingStatusCode]
      ,[BookingStatusMessage]
      ,[BookingTransactionID]
      ,[PartnerStatus]
      ,[TINType]
      ,[IDType]
      ,[IDIssuer]
      ,[IDNumber]
      ,[IDExpirationDate]
      ,[GrossAnnualIncome]
      ,[LoadDate_ID]
      ,[ReferenceID_LoadDate]
      ,[CumCollBal]
      ,[InBal]
      ,[MinDelInqMos]
      ,[MortBalAmt]
      ,[OpnBnkCrdBal]
      ,[OpnBnkCrdHi]
      ,[TotalBal]
      ,[TotalPayments]
      ,[TradesOpen3]
      ,[CHRGOFF_CNT]
      ,[CURRENT_30_BAL]
      ,[CURRENT_60_BAL]
      ,[CURRENT_90_BAL]
      ,[MIN_CHRGOFF_MOS]
      ,[MAX_OPEN_REV_LIMIT]
      ,[MLA_FLAG]
  FROM [dbo].[CreditReports_DailyArchive_FNI_txt]) a
 WHERE a.TCIReferenceID = la.QUORUM_REF_ID ORDER BY a.DailyArchive_History_Key desc) d_arch
LEFT OUTER JOIN [dbo].[Extracts_Daily_OraclePDB_MERCHANT_CONFIG] mc ON mc.MERCHANT_ID = ofc.ProviderID
LEFT OUTER JOIN [dbo].[Extracts_Daily_OraclePDB_PARTIAL_REFUND] pr ON pr.[LoanApplicationId] = la.[LOAN_APPLICATION_ID]
LEFT JOIN [dbo].[Extracts_Daily_OraclePDB_LoanApplicationDocument] lad ON appr.ApplicantRequestId = lad.ApplicationRequestId
JOIN [dbo].[Extracts_Daily_OraclePDB_Document] D ON d.DocumentId = lad.DocumentId and d.DocumentTypeId = 1003 --Unsigned loan application document
OUTER APPLY (SELECT MAX(Created_Date) [EsignDate] FROM [dbo].[Extracts_Daily_OraclePDB_LOAN_APP_STAT_HIST] las WHERE la.Loan_Application_Id = las.[LOAN_APPLICATION_ID] and las.Loan_Application_status_Id = 13) LASH
OUTER APPLY (SELECT COUNT([LOAN_APP_STAT_HIST_ID]) [OfferCount] FROM [dbo].[Extracts_Daily_OraclePDB_LOAN_APP_STAT_HIST] LAH WHERE LAH.[LOAN_APPLICATION_ID] = la.[LOAN_APPLICATION_ID] and LAh.LOAN_APPLICATION_STATUS_ID = 10) MOS
OUTER APPLY (SELECT COUNT(APPLICANT_ID) [ApplicationCount] FROM [dbo].[Extracts_Daily_OraclePDB_LOAN_APPLICATION] LA2 WHERE LA2.Applicant_ID = La.APPLICANT_ID  ) LAC
LEFT OUTER JOIN dbo.Extracts_Daily_OraclePDB_LOAN_PRODUCT_DTL lpd ON lpd.LOAN_PROD_DTL_ID = la.LOAN_PROD_DTL_ID
INNER JOIN dbo.Extracts_Daily_OraclePDB_Scoring sc on la.ScoringId = sc.ScoringId
INNER JOIN dbo.Extracts_Daily_OraclePDB_Lender lnd on sc.LenderId = lnd.LenderId
WHERE la.LoadDate_ID <> 'NA'
	AND isnull(mc.DEMO, 0) = 0
	AND datediff(D, la.LoadDate_ID, getdate()) = 1
	lnd.LenderId = 1 -- CRB 
	--AND d_arch.FNIQueue = 'Booking Requested'
	AND la.ESTIMATED_SERVICE_DATE <= CONVERT (datetime2, GETUTCDATE())
	AND (la.LOAN_APPLICATION_STATUS_ID IN (5, 16) OR ( la.LOAN_APPLICATION_STATUS_ID = 20 AND ProviderId= 1148 and la.DATE_FUNDED >= DATEADD(DAY, -3, GETUTCDATE())))






GO


