USE [DW_Source]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER VIEW [dbo].[viewReport_RIP] AS


SELECT DISTINCT 
    CAST(r.CreatedDate  as date) as [Refund Request Date]
   ,la.Applicant_Id [Borrower ID]
   	,la.EXT_REF_NO [Loan Number]
	,'CSC' [Platform]
	,'6' [Asset Class]
	,'Medical' [Loan Purpose]
--    ,s.STATUS_NAME [Loan Status]
	,3 as [Loan Status]
	,'CSC' [Investor]
	,'TCI' [Servicer]
	,CONVERT(VARCHAR, la.DATE_APPLIED, 112) [Application Date]
	,CONVERT(VARCHAR, la.DATE_APPLIED, 112) [Reg B Decision Date]
	,CONVERT(VARCHAR, dateadd(D, 1, la.DATE_APPLIED), 112) [Note Date]
	,FORMAT(CONVERT(DATETIME,la.[ESTIMATED_SERVICE_DATE], 100), 'yyyyMMdd') [Treatment Date]
	,CONVERT(VARCHAR, dateadd(D, 4, la.DATE_APPLIED), 112) [Purchase Date]
   ,CONVERT(VARCHAR, dateadd(D, 35, la.ESTIMATED_SERVICE_DATE), 112) [Payment Due Date]
	,ar.LastName [Borrower Last Name]
	,ar.FirstName [Borrower First Name]
	,FORMAT(CONVERT(DATETIME,ar.DOB, 100), 'yyyyMMdd') [Borrower DOB]
	,REPLACe(a.SSN,'-','') [Borrower SSN]
	,ad_Physical.STREET_LINE_1 [Borrower Address]
	,ad_Physical.CITY [Borrower City]
	,ad_Physical.STATE [Borrower State]
	,ad_Physical.ZIP_CODE [Borrower Zip]
   	,ar.PhoneNumber [Borrower Phone Number]
	-- ,ar.MobileNumber [Borrower Mobile Number]
	,ar.[EMAIL] [Borrower Email]
	,CONVERT(DECIMAL(12, 2), la.LOAN_AMOUNT) [Approved Loan Amount]
	,CONVERT(DECIMAL(12, 2), la.LOAN_AMOUNT) [Loan Amount]
    ,CONVERT(DECIMAL(12, 2), (la.LOAN_AMOUNT * (1 - la.mdf))) AS [Net Funding]
	,CONVERT(DECIMAL(12, 2), la.MONTHLY_PAYMENT) [Current Monthly Payment]
	,'Monthly' [PmtFreq]
	,0 [Origination Fee]
	,CONVERT(DECIMAL(12, 3), la.APR * 100) [Rate]	
	,CONVERT(DECIMAL(12, 2), la.APR * 100) [APR]
	,la.TERMS [Amortization]
	,la.TERMS [Term]
		,1 [Rate Type]
	,'no' [Prior Loan Flag]
	,d_arch.FICO AS [FICO]
	,CONVERT(VARCHAR, la.DATE_APPLIED, 112) AS [FICO Date]
	,d_arch.FICO AS [Credit Grade]
	,CONVERT(DECIMAL(12, 2), cr.RevUtilization / 100.0) AS [Debt Utilization]
	,CONVERT(DECIMAL(12, 2), cr.RevBalance) AS [Total Revolving Debt]
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
	,CONVERT(DECIMAL(15, 2), ae.GROSS_INCOME) [Annual Income]
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
	,1 as [Account Type]
	,'CCD' [Standard Entry Type Code]
	,ofc.ProviderName [Receiver Name]
	,'N' [Same Day Flag]	
	,'' [AddendaRecord]
	,ofc.ProviderName [Merchant Name]
	,'$'+ CAST(CONVERT(DECIMAL(10,2), (la.LOAN_AMOUNT * la.MDF)) as VARCHAR) [Merchant Fee]
	,CONVERT(DECIMAL(12, 2),round((creq.RefundAmount * (1-CONVERT(DECIMAL(10,3), (la.LOAN_AMOUNT * la.MDF)) / CONVERT(DECIMAL(12, 3), la.LOAN_AMOUNT))), 2)) as [Refund Amount]
    ,CONVERT(DECIMAL(12, 2), round((la.LOAN_AMOUNT - creq.RefundAmount), 4)) [Adjusted Loan Amount]
    ,CASE WHEN CONVERT(DECIMAL(12, 2), (la.LOAN_AMOUNT * (1 - la.mdf))) - CONVERT(DECIMAL(12, 4),(creq.RefundAmount * (1-CONVERT(DECIMAL(10,4), (la.LOAN_AMOUNT * la.MDF)) / CONVERT(DECIMAL(12, 4), la.LOAN_AMOUNT)))) < 0 
		  THEN 0 
		  ELSE CONVERT(DECIMAL(12, 2), round(CONVERT(DECIMAL(12, 4), (la.LOAN_AMOUNT * (1 - la.mdf))) - CONVERT(DECIMAL(12, 4),(creq.RefundAmount * (1-CONVERT(DECIMAL(10,4), (la.LOAN_AMOUNT * la.MDF)) / CONVERT(DECIMAL(12, 4), la.LOAN_AMOUNT)))), 4))
	 END [Adjusted Net Funding]
    ,0 [Adjusted Origination Fee]    
	,CASE WHEN (la.LOAN_AMOUNT - creq.RefundAmount) = 0
		 THEN 0
		 ELSE CONVERT(DECIMAL(12, 2), la.MONTHLY_PAYMENT)
     END as [Adjusted Current Monthly Payment]
	 ,CONVERT(varchar(8),getdate(),112) [Refund Date]
	,CASE WHEN CONVERT(DECIMAL(12, 2), (la.LOAN_AMOUNT * (1 - la.mdf))) - creq.RefundAmount < 0 
		  THEN round(0, 2)
		  ELSE (CONVERT(DECIMAL(12, 2), round(((la.LOAN_AMOUNT - creq.RefundAmount))  - (CONVERT(DECIMAL(12, 3), CONVERT(DECIMAL(12, 3), (la.LOAN_AMOUNT * (1 - la.mdf))) - CONVERT(DECIMAL(12, 3),(creq.RefundAmount * (1-CONVERT(DECIMAL(10,3), (la.LOAN_AMOUNT * la.MDF)) / CONVERT(DECIMAL(12, 3), la.LOAN_AMOUNT)))))),2)))
	 END
	as [Adjusted Merchant Fee]
	,CONVERT(VARCHAR, dateadd(M, CONVERT(INT, la.Terms), dateadd(D, 35, la.ESTIMATED_SERVICE_DATE)),112) [Final Payment Date]
	,CONVERT(DECIMAL(12, 2), la.MONTHLY_PAYMENT) [Final Payment]
	,CONVERT(DECIMAL(12, 2), round((CONVERT(DECIMAL(12, 3), la.MONTHLY_PAYMENT) * la.TERMS - la.loan_Amount), 2)) AS [Finance Charge]
	,CONVERT(DECIMAL(12, 2), round(la.MONTHLY_PAYMENT * la.TERMS, 2)) [Total Payments]
	,12 [PPY]
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
    ,la.QUORUM_REF_ID as TCIID
	 ,CASE 
		   WHEN  DATEPART(DW, GETDATE()) = 6
		   THEN cast(DATEADD(d, 3, getdate()) as date) 
		   WHEN  DATEPART(DW, GETDATE()) = 7
		   THEN cast(DATEADD(d, 2, getdate()) as date)
		   ELSE cast(DATEADD(d, 1, getdate()) as date)
	   END as [CRB Refund Date] 
	 ,'' as [FDR Account Number] -- 
	 ,phx.accountnumber as [HCS Account Number] 
	 ,CONVERT(DECIMAL(12, 2), round(creq.RefundAmount, 2)) as [Refund Request]  
	 -- ,FORMAT(CONVERT(DECIMAL(10,2), (la.LOAN_AMOUNT * la.MDF)) / CONVERT(DECIMAL(10, 2), la.LOAN_AMOUNT), 'p') as  [MDR]
	 ,datediff(d, CAST(la.DATE_BOOKED as date), CAST(r.CreatedDate  as date) ) as [Days Since Booking]
FROM dbo.Extracts_Daily_OraclePDB_REQUEST r 
LEFT OUTER JOIN dbo.Extracts_Daily_OraclePDB_LOAN_APPLICATION_CHANGE_REQUEST creq on creq.RequestId = r.RequestId
LEFT OUTER JOIN dbo.Extracts_Daily_OraclePDB_REQUEST_TYPE rt on rt.RequestTypeId = r.RequestTypeId
LEFT OUTER JOIN dbo.Extracts_Daily_OraclePDB_REQUEST_STATUS rs on rs.RequestStatusId = r.RequestStatusId
LEFT OUTER JOIN dbo.Extracts_Daily_OraclePDB_LOAN_APPLICATION la on creq.LoanApplicationId = la.LOAN_APPLICATION_ID
LEFT OUTER JOIN [dbo].[Extracts_Daily_OraclePDB_PARTIAL_REFUND] pr ON pr.LoanAppChangeRequestId = creq.LoanAppChangeRequestId
INNER JOIN [dbo].[Extracts_Daily_OraclePDB_ApplicationRequest] appr ON appr.ApplicationRequestId = la.LOAN_APPLICATION_ID
INNER JOIN [dbo].[Extracts_Daily_OraclePDB_ApplicantRequest] ar ON appr.ApplicantRequestId = ar.ApplicantRequestId
INNER JOIN [dbo].[Extracts_Daily_OraclePDB_LOAN_APPLICATION_STATUS] s ON s.LOAN_APPLICATION_STATUS_ID = la.LOAN_APPLICATION_STATUS_ID
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
INNER JOIN dbo.Extracts_Daily_OraclePDB_APPLICANT_ADDRESS ad_Physical ON ad_Physical.ApplicantRequestId = ar.ApplicantRequestId and ad_Physical.AddressTypeId = 1 
LEFT OUTER JOIN dbo.Extracts_Daily_OraclePDB_APPLICANT_EMPLOYER_INFO ae ON ae.ApplicantRequestId = ar.ApplicantRequestId
INNER JOIN [dbo].[viewProviderEntityOffices] ofc ON ofc.Hierarchy_ID = la.ASSIGNED_OFFICE_ID
LEFT OUTER JOIN [dbo].[Extracts_Daily_OraclePDB_MERCHANT_BANK] mb ON mb.MERCHANT_ID = ofc.ProviderID
LEFT OUTER JOIN [dbo].[Extracts_Daily_OraclePDB_MERCHANT_HIERARCHY_BANK] mhb ON mhb.MERCHANT_HIERARCHY_ID = ofc.Hierarchy_ID
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
LEFT OUTER JOIN dbo.Extracts_Daily_OraclePDB_APPLICANT a ON a.APPLICANT_ID = la.APPLICANT_ID
LEFT OUTER JOIN [dbo].[Extracts_Daily_OraclePDB_MERCHANT_CONFIG] mc ON mc.MERCHANT_ID = ofc.ProviderID
LEFT OUTER JOIN dbo.CreditReports_PHX_File_PHX_File_Extract_TXT phx on left(d_arch.transactionid,25) = left(phx.referenceno, 25)
INNER JOIN dbo.Extracts_Daily_OraclePDB_Scoring sc on la.ScoringId = sc.ScoringId
INNER JOIN dbo.Extracts_Daily_OraclePDB_Lender lnd on sc.LenderId = lnd.LenderId
WHERE la.LoadDate_ID <> 'NA'
	AND datediff(D, la.LoadDate_ID, getdate()) = 1 
	AND r.RequestStatusId = 1
	AND isnull(mc.DEMO, 0) = 0
	AND lnd.LenderId = 1 -- CRB
	AND la.LOAN_APPLICATION_STATUS_ID != 30 







GO


