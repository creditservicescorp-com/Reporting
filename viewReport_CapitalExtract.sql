USE [DW_Source]
GO

/****** Object:  View [dbo].[viewReport_CapitalExtract]    Script Date: 7/21/2017 3:05:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[viewReport_CapitalExtract]
AS
select * from
  (SELECT DISTINCT
      cast(ldate.[LoadDateID] as date) as [LoadDateID],
      [Account_Number]
      ,apps.TCIReferenceID TCIReferenceID
      , apps.EXT_REF_NO [TRN #]
      , accts.referenceno [ReferenceNo]
      , d_arch.ReferenceID [DailyArchive ReferenceID]
      -- Credit Report info
      ,cr.[TotalTrades]
      ,cr.[MonthsonFile]
      ,cr.[30days]
      ,cr.[60days]
      ,cr.[90days]
      ,cr.[UnpaidCollections]
      ,cr.[BankruptIndication]
      ,cr.[MajorDerogatory]
      ,cr.[MinorDerogatory]
      ,cr.[DelinquentBalance]
      ,CASE -- Added case statement to set OldestTrade to NULL when it contains value of 'NA', required due to conversion to date datatype
         WHEN cr.[OldestTrade] = 'NA' 
	    THEN NULL
	    ELSE cast(cr.[OldestTrade] as date) 
	  END as [OldestTrade]
      ,cr.[SatisfactoryTrades]
      ,cr.[TooNewToRate]
      ,cr.[Openwithin3mos]
      ,cr.[Inquiries]
      ,cr.[RevUtilization]/100.0 [Rev Utilization]
      ,cr.[RevBalance] [Rev Balance]
      ,cr.[InstallBal]
      ,cr.[MortgageBal]
      ,cr.[TotalBal]
      ,cr.[TotalMonthlyDebt]
      ,cr.[DebttoIncomeRatio]
      ,cr.[TotalUnsecureBalance]
      ,cr.[BalIncomeRatioStudent]
      ,cr.[BalIncomeRatioNoStudent]
      ,cr.[RevolvingCreditLimit]
      ,cr.[TradelineswithActive]
      ,cr.[TradelinesinCollection]
      ,cr.[CollectionLastStatusDate]
      ,cr.[NumLinesinChargeOff]
      ,cr.[TotBalofLinesinChargeOff]
      ,cr.[TotalBalofLineswithDelinquency]
      ,cr.[HiRevolvingCreditLimit]
      ,cr.[ChargeOffLastStatusDate]
      ,cr.[NumLineswithRepossession]
      ,cr.[RepossessionLastStatusDate]
      ,cr.[TotalDebtwithQuorumFCU]
      ,cr.[TotalUnsecureDebtwithQuorumFCU]
      ,cr.[Foreclosure]
      ,cr.[NumLinesinForeclosure]
      ,cr.[TotalBalofLinesinForeclosure]
      ,cr.[ForeclosureLastStatusDate]
      ,cr.[Bankruptcy]
      ,cr.[NumLinesinBankruptcy]
      ,cr.[TotalBalofLinesinBankruptcy]
      ,cr.[BankruptcyLastStatusDate]
      ,cr.[CreditCounseling]
      ,cr.[NumLineswithCounseling]
      ,cr.[TotalBalofLineswithCounseling]
      ,cr.[CurrentDelinquency]
      ,cr.[NumLineswithDelinqency]

      -- Loan App info
      , apps.[Status]   AS [TRN Status]
      , apps.[Application_Date]
      , DatePart(m, apps.[Application_Date]) [App Month]
      , DatePart(yyyy, apps.[Application_Date]) [App Year]
      , FORMAT(apps.[Application_Date], 'MM-yyyy') [App MonthYr]
      , f.[Loan_Amount]
      , apps.APR
      , apps.term
      , d_arch.FICO
      , apps.scorecard [Tier Price]
      , srcProds.CODE         [ProductCode]
      , srcProds.PAYMENT_TYPE [Product_Type]

      -- Merchant Info
      , prov.Provider_Name [Merchant]
      , prov.Provider_ID [Merchant ID]
	  , prov.[Entity_Name] [OfficeName]
      , prov.Vertical [Vertical]
	  , res.Reseller_Name [Reseller]
	  
	  -- Borrower Info
      --, cast(d_arch.[DOB] as date) as [Borrfower DOB]
	  , d_arch.[DOB]  as [Borrfower DOB]
      , d_arch.[PhysicalState] [Borrower State]
      , d_arch.[PhysicalZip] [Borrower Zip]
      , d_arch.[GrossAnnualIncome]

      -- Facts table info
      ,f.[AccountCount]                 as       [Fact AccountCount]
      ,f.[Delinquent_Count]                 as       [Fact Delinquent_Count]
      ,f.[Delinquent_Balance]                 as       [Fact Delinquent_Balance]
      ,f.[Delinquent_Payment]                 as       [Fact Delinquent_Payment]
      ,f.[Payment_Amount]                     as       [Fact Payment_Amount]
      ,f.[Loan_Amount]                  as       [Fact Loan_Amount]
      ,f.[Losses_Amount]                      as       [Fact Losses_Amount]
      ,f.[Current_Balance]                    as       [Fact Current_Balance]
      ,f.[Principal_Balance]                  as       [Fact Principal_Balance]
      ,f.[Interest_Balance]                   as       [Fact Interest_Balance]
      ,f.[Fees_Balance]                 as       [Fact Fees_Balance]
      ,f.[Delnocycles]                  as       [Fact Delnocycles]
      ,f.[Delnodays]                    as       [Fact Delnodays]
      ,f.[Cycle_Payments]                     as       [Fact Cycle_Payments]
      ,f.[Total_Amount_Due]                   as       [Fact Total_Amount_Due]
      ,f.[Current_Amount_Due]                 as       [Fact Current_Amount_Due]
      ,f.[PastDue_Amt]                  as       [Fact PastDue_Amt]
      ,f.[Last_Statement_Balance]                   as       [Fact Last_Statement_Balance]
      ,f.[Last_Statement_Payment]                   as       [Fact Last_Statement_Payment]
      ,f.[APR]                    as       [Fact APR]
      ,f.[DelinquentBalance_1]                    as       [Fact Bucket_Amount_1 - 30 days Del]
      ,f.[DelinquentBalance_2]                    as       [Fact Bucket_Amount_2 - 60 days Del]
      ,f.[DelinquentBalance_3]                    as       [Fact Bucket_Amount_3 - 90 days Del]
      ,f.[DelinquentBalance_4]                    as       [Fact Bucket_Amount_4 - 120 days Del]
      ,f.[DelinquentBalance_5]                    as       [Fact Bucket_Amount_5 - 150 days Del]
      ,f.[DelinquentBalance_6]                    as       [Fact Bucket_Amount_6 - 180 days Del]
      ,f.[Months_Open]                  as       [Fact Months_Open]
      ,f.[Payoff_Months]                      as       [Fact Payoff_Months]

      -- Accounts Info
      ,accts.[Status]   AS       [Accounts Status]
      ,accts.[Status_Dt]   AS       [Accounts Status_Dt]
      ,accts.[Close_Date]   AS       [Accounts Close_Date]
      ,accts.[ReferenceNo]   AS       [Accounts ReferenceNo]
      ,accts.[Cycle_Dt]   AS       [Accounts Cycle_Dt]
      ,accts.[Cycle_Code]   AS       [Accounts Cycle_Code]
      ,accts.[Term]   AS       [Accounts Term]
      ,accts.[Payment_Due_Dt]   AS       [Accounts Payment_Due_Dt]
      ,accts.[Last_Statement_Date]   AS       [Accounts Last_Statement_Date]
      ,accts.[Next_Statement_Dt]   AS       [Accounts Next_Statement_Dt]
      ,accts.[Account_End_Dt]   AS       [Accounts Account_End_Dt]
      ,accts.[DelinqBucketNum]   AS       [Accounts DelinqBucketNum]

      -- PHX / Servicing file info
      , phx.[TotalAmountDue] [PHX TotalAmountDue]
      , phx.[CurrentAmountdue] [PHX CurrentAmountdue]
      , phx.[DataDt] [PHX Promo Payoff Date]
      , (Case When srcProds.[PAYMENT_TYPE] = 'Promo' Then 'Yes' Else '' End)  [Promo]
      , cast(srcProds.promo_term as int)                                      [Promo Term]
      , COALESCE(phx.opendt, phxco.opendt) [PHX OpenDate]
      , CONVERT(DECIMAL(10, 2), srcApps.MDF*100.0)                    [MDF]
	  , accts.LoanPoolTag as [LoanPoolTag]
	  ,accts.FirstPaymentDelinquent

    FROM DW_Main.[dbo].[LNAccts_Facts] AS f
    JOIN DW_Main.[dbo].[LNAccts_AccountDim] AS accts
      ON f.AccountDim_Key = accts.[AccountDim_Key]
    JOIN DW_Main.[dbo].[LNAccts_ApplicationDim] AS apps
      ON f.[ApplicationDim_Key] = apps.[ApplicationDim_Key]

   
    LEFT OUTER JOIN [dbo].[CreditReports_History] cr
      ON cr.TCIID = apps.TCIReferenceID

    LEFT OUTER JOIN [dbo].[LNAccts_AccountDim_ServicingFile_txt] phx
      ON phx.[AccountNumber] = accts.[Account_Number]

    JOIN DW_Main.[dbo].[LNAccts_LoadDateDim] AS ldate
      ON f.[LoadDateDim_Key] = ldate.[LoadDateDim_Key]
    JOIN DW_Main.[dbo].[LNAccts_Source] AS src
      ON f.[Source_Key] = src.[Source_Key]

    JOIN DW_Main.[dbo].[LNAccts_ProviderDim] AS prov
      ON f.[ProviderDim_Key] = prov.[ProviderDim_Key]
	JOIN DW_Main.dbo.LNAccts_ResellerDim as Res
		ON f.ResellerDim_Key = res.ResellerDim_Key

/*  Commented out 7/18/2017 due to unpopulated TCIReferenceID in the LNAccts_ApplicationDim table
 
    LEFT OUTER JOIN [dbo].[CreditReports_DailyArchive_History] AS d_arch
      ON d_arch.[TCIReferenceID] = apps.TCIReferenceID
	  AND d_arch.LoadDate_ID = (select top 1 loaddate_id from dbo.[CreditReports_DailyArchive_History] where TCIReferenceID = d_arch.TCIReferenceID order by LoadDate_ID desc) 
*/   

    LEFT OUTER JOIN [dbo].[Extracts_Daily_OraclePDB_LOAN_APPLICATION] srcApps
      ON srcApps.loan_application_id = apps.loan_application_id


-- Added on 7/18/2017 to replace join above. 
	LEFT OUTER JOIN dbo.CreditReports_DailyArchive_History d_arch
	on d_arch.TCIReferenceID = srcApps.QUORUM_REF_ID
	AND d_arch.LoadDate_ID = (select top 1 loaddate_id from dbo.[CreditReports_DailyArchive_History] where TCIReferenceID = d_arch.TCIReferenceID order by LoadDate_ID desc) -- Added to retrieve the most latest instance of the TRN from the credit history file    

    LEFT OUTER JOIN [dbo].[Extracts_Daily_OraclePDB_LOAN_PRODUCT_DTL] srcProds
      ON srcProds.loan_prod_dtl_id = srcApps.loan_prod_dtl_id
	LEFT OUTER JOIN [dbo].[CreditReports_PHX_File_ChargedOff_Accounts] phxCO
      ON phxCO.[AccountNumber] = accts.[Account_Number]
    WHERE 1=1
      AND apps.Status_Grouping = 'Active'
      AND datediff(d, ldate.[LoadDateActualDate], getdate()) = 1
	 AND ldate.[LoadDateID]  <> 'NA' -- only retrieve records with a valid load date
      AND src.[Source_ID] IN ('ServicingLoad', 'LoadPhxChargedOffAccounts')
 
  union all

SELECT DISTINCT
      srcApps.[loaddate_id]   [LoadDateID]
      , null [Account_Number]

      , srcApps.QUORUM_REF_ID TCIReferenceID
      , srcApps.EXT_REF_NO [TRN #]
      , null [ReferenceNo]

      , d_arch.ReferenceID [DailyArchive ReferenceID]

      -- Credit Report info
      ,cr.[TotalTrades]
      ,cr.[MonthsonFile]
      ,cr.[30days]
      ,cr.[60days]
      ,cr.[90days]
      ,cr.[UnpaidCollections]
      ,cr.[BankruptIndication]
      ,cr.[MajorDerogatory]
      ,cr.[MinorDerogatory]
      ,cr.[DelinquentBalance]
      -- ,cr.[OldestTrade]   [OldestTrade]
      ,CASE -- Added case statement to set OldestTrade to NULL when it contains value of 'NA', required due to conversion to date datatype
         WHEN cr.[OldestTrade] = 'NA' 
	    THEN NULL
	    ELSE cast(cr.[OldestTrade] as date) 
	  END as [OldestTrade]
      ,cr.[SatisfactoryTrades]
      ,cr.[TooNewToRate]
      ,cr.[Openwithin3mos]
      ,cr.[Inquiries]
      ,cr.[RevUtilization]/100.0 [Rev Utilization]
      ,cr.[RevBalance] [Rev Balance]
      ,cr.[InstallBal]
      ,cr.[MortgageBal]
      ,cr.[TotalBal]
      ,cr.[TotalMonthlyDebt]
      ,cr.[DebttoIncomeRatio]
      ,cr.[TotalUnsecureBalance]
      ,cr.[BalIncomeRatioStudent]
      ,cr.[BalIncomeRatioNoStudent]
      ,cr.[RevolvingCreditLimit]
      ,cr.[TradelineswithActive]
      ,cr.[TradelinesinCollection]
      ,cr.[CollectionLastStatusDate]
      ,cr.[NumLinesinChargeOff]
      ,cr.[TotBalofLinesinChargeOff]
      ,cr.[TotalBalofLineswithDelinquency]
      ,cr.[HiRevolvingCreditLimit]
      ,cr.[ChargeOffLastStatusDate]
      ,cr.[NumLineswithRepossession]
      ,cr.[RepossessionLastStatusDate]
      ,cr.[TotalDebtwithQuorumFCU]
      ,cr.[TotalUnsecureDebtwithQuorumFCU]
      ,cr.[Foreclosure]
      ,cr.[NumLinesinForeclosure]
      ,cr.[TotalBalofLinesinForeclosure]
      ,cr.[ForeclosureLastStatusDate]
      ,cr.[Bankruptcy]
      ,cr.[NumLinesinBankruptcy]
      ,cr.[TotalBalofLinesinBankruptcy]
      ,cr.[BankruptcyLastStatusDate]
      ,cr.[CreditCounseling]
      ,cr.[NumLineswithCounseling]
      ,cr.[TotalBalofLineswithCounseling]
      ,cr.[CurrentDelinquency]
      ,cr.[NumLineswithDelinqency]

      -- Loan App info
      , s.[STATUS_NAME]                           [TRN Status]
      , srcApps.DATE_APPLIED                      [Application_Date]
      , DatePart(m, srcApps.[DATE_APPLIED])       [App Month]
      , DatePart(yyyy, srcApps.[DATE_APPLIED])    [App Year]
      , FORMAT(srcApps.[DATE_APPLIED], 'MM-yyyy') [App MonthYr]

      , srcApps.[Loan_Amount] [Loan_Amount]
      , srcApps.APR   [APR]
      , srcApps.TERMS [term]
      , d_arch.FICO
      , srcApps.SCORECARD     [Tier Price]
      , srcProds.CODE         [ProductCode]
      , srcProds.PAYMENT_TYPE [Product_Type]

      -- Merchant Info
      , ofc.ProviderName  [Merchant]
	  , cast(ofc.ProviderID as varchar(15))     [Merchant ID] -- cast due to default value 'NA' in first union select statement
	  , ofc.EntityName	  [OfficeName]
      , v.CODE            [Vertical]
	  , rs.RESELLER_NAME  [Reseller]

      -- Borrower Info
      --, cast(d_arch.[DOB] as date) as [Borrfower DOB]
	  , d_arch.[DOB] as [Borrfower DOB]
      , d_arch.[PhysicalState] [Borrower State]
      , d_arch.[PhysicalZip]   [Borrower Zip]
      , d_arch.[GrossAnnualIncome]


      -- Facts table info
      ,null  [Fact AccountCount]
      ,null  [Fact Delinquent_Count]
      ,null  [Fact Delinquent_Balance]
      ,null  [Fact Delinquent_Payment]
      ,null  [Fact Payment_Amount]
      ,null  [Fact Loan_Amount]
      ,null  [Fact Losses_Amount]
      ,null  [Fact Current_Balance]
      ,null  [Fact Principal_Balance]
      ,null  [Fact Interest_Balance]
      ,null  [Fact Fees_Balance]
      ,null  [Fact Delnocycles]
      ,null  [Fact Delnodays]
      ,null  [Fact Cycle_Payments]
      ,null  [Fact Total_Amount_Due]
      ,null  [Fact Current_Amount_Due]
      ,null  [Fact PastDue_Amt]
      ,null  [Fact Last_Statement_Balance]
      ,null  [Fact Last_Statement_Payment]
      ,null  [Fact APR]
      ,null  [Fact Bucket_Amount_1 - 30 days Del]
      ,null  [Fact Bucket_Amount_2 - 60 days Del]
      ,null  [Fact Bucket_Amount_3 - 90 days Del]
      ,null  [Fact Bucket_Amount_4 - 120 days Del]
      ,null  [Fact Bucket_Amount_5 - 150 days Del]
      ,null  [Fact Bucket_Amount_6 - 180 days Del]
      ,null  [Fact Months_Open]
      ,null  [Fact Payoff_Months]

      -- Accounts Info
      ,null  [Accounts Status]
      ,null  [Accounts Status_Dt]
      ,null  [Accounts Close_Date]
      ,null  [Accounts ReferenceNo]
      ,null  [Accounts Cycle_Dt]
      ,null  [Accounts Cycle_Code]
      ,null  [Accounts Term]
      ,null  [Accounts Payment_Due_Dt]
      ,null  [Accounts Last_Statement_Date]
      ,null  [Accounts Next_Statement_Dt]
      ,null  [Accounts Account_End_Dt]
      ,null  [Accounts DelinqBucketNum]

      -- PHX / Servicing file info
      , null [PHX TotalAmountDue]
      , null [PHX CurrentAmountdue]
      , null [PHX Promo Payoff Date]
      , null [Promo]
      , null [Promo Term]
      , null [PHX OpenDate]

      , CONVERT(DECIMAL(10, 2), srcApps.MDF*100.0)                    [MDF]
	  ,lp.Tag as [LoanPoolTag]
	  ,NULL as FirstPaymentDelinquent
      
	   FROM [dbo].[Extracts_Daily_OraclePDB_LOAN_APPLICATION] srcApps

--         LEFT OUTER JOIN DW_Main.[dbo].[LNAccts_ApplicationDim] AS apps
--      ON srcApps.loan_application_id = apps.loan_application_id
--              AND isdate(apps.[LoadDate_ID]) = 1
--              AND datediff(d, apps.[LoadDate_ID], getdate()) = 2

    LEFT OUTER JOIN [dbo].[CreditReports_DailyArchive_History] AS d_arch
      ON d_arch.[TCIReferenceID] = srcapps.QUORUM_REF_ID
    AND d_arch.LoadDate_ID = (select top 1 loaddate_id from dbo.[CreditReports_DailyArchive_History] where TCIReferenceID = d_arch.TCIReferenceID order by LoadDate_ID desc) -- Added to retrieve the most latest instance of the TRN from the credit history file
    LEFT OUTER JOIN [dbo].[CreditReports_History] cr
      ON cr.TCIID = srcapps.QUORUM_REF_ID

    JOIN dbo.viewProviderEntityOffices ofc
          ON ofc.[Hierarchy_ID] = srcApps.assigned_office_id
    LEFT OUTER JOIN [dbo].[Extracts_Daily_OraclePDB_VERTICAL] v
      ON v.VERTICAL_ID = ofc.VERTICAL_ID

    LEFT OUTER JOIN [dbo].[Extracts_Daily_OraclePDB_LOAN_PRODUCT_DTL] srcProds
      ON srcProds.loan_prod_dtl_id = srcApps.loan_prod_dtl_id

      JOIN [dbo].[Extracts_Daily_OraclePDB_LOAN_APPLICATION_STATUS] s
      ON s.LOAN_APPLICATION_STATUS_ID=srcApps.LOAN_APPLICATION_STATUS_ID
	LEFT OUTER JOIN dbo.Extracts_Daily_OraclePDB_LoanPool lp
		ON srcApps.Loan_application_id = lp.LoanApplicationId
	LEFT OUTER JOIN dbo.Extracts_Daily_OraclePDB_Reseller rs
		ON rs.RESELLER_ID = ofc.RESELLER_ID

    WHERE 1=1
      AND srcApps.LOAN_APPLICATION_STATUS_ID IN (2, 103)

  union all

  SELECT DISTINCT
    cast(d_arch_mcc.[LoadDate_ID] as date) as [LoadDateID]
    , phx.accountnumber [Account_Number]

    , d_arch_mcc.[TCIReferenceID]
    , d_arch_mcc.[PartnerReferenceID] [TRN #]
    , d_arch_mcc.ReferenceID [DailyArchive ReferenceID]

    , d_arch_mcc.ReferenceID [DailyArchive ReferenceID]

    -- Credit Report info
    ,cr.[TotalTrades]
    ,cr.[MonthsonFile]
    ,cr.[30days]
    ,cr.[60days]
    ,cr.[90days]
    ,cr.[UnpaidCollections]
    ,cr.[BankruptIndication]
    ,cr.[MajorDerogatory]
    ,cr.[MinorDerogatory]
    ,cr.[DelinquentBalance]
    ,CASE -- Added case statement to set OldestTrade to NULL when it contains value of 'NA', required due to conversion to date datatype
         WHEN cr.[OldestTrade] = 'NA' 
	    THEN NULL
	    ELSE cast(cr.[OldestTrade] as date) 
	END as [OldestTrade]
    ,cr.[SatisfactoryTrades]
    ,cr.[TooNewToRate]
    ,cr.[Openwithin3mos]
    ,cr.[Inquiries]
    ,cr.[RevUtilization]/100.0 [Rev Utilization]
    ,cr.[RevBalance] [Rev Balance]
    ,cr.[InstallBal]
    ,cr.[MortgageBal]
    ,cr.[TotalBal]
    ,cr.[TotalMonthlyDebt]
    ,cr.[DebttoIncomeRatio]
    ,cr.[TotalUnsecureBalance]
    ,cr.[BalIncomeRatioStudent]
    ,cr.[BalIncomeRatioNoStudent]
    ,cr.[RevolvingCreditLimit]
    ,cr.[TradelineswithActive]
    ,cr.[TradelinesinCollection]
    ,cr.[CollectionLastStatusDate]
    ,cr.[NumLinesinChargeOff]
    ,cr.[TotBalofLinesinChargeOff]
    ,cr.[TotalBalofLineswithDelinquency]
    ,cr.[HiRevolvingCreditLimit]
    ,cr.[ChargeOffLastStatusDate]
    ,cr.[NumLineswithRepossession]
    ,cr.[RepossessionLastStatusDate]
    ,cr.[TotalDebtwithQuorumFCU]
    ,cr.[TotalUnsecureDebtwithQuorumFCU]
    ,cr.[Foreclosure]
    ,cr.[NumLinesinForeclosure]
    ,cr.[TotalBalofLinesinForeclosure]
    ,cr.[ForeclosureLastStatusDate]
    ,cr.[Bankruptcy]
    ,cr.[NumLinesinBankruptcy]
    ,cr.[TotalBalofLinesinBankruptcy]
    ,cr.[BankruptcyLastStatusDate]
    ,cr.[CreditCounseling]
    ,cr.[NumLineswithCounseling]
    ,cr.[TotalBalofLineswithCounseling]
    ,cr.[CurrentDelinquency]
    ,cr.[NumLineswithDelinqency]


    -- Loan App info
    , null   AS [TRN Status]
    , null [Application_Date]
    , null /* DatePart(m, apps.[Application_Date]) */ [App Month]
    , null /* DatePart(yyyy, apps.[Application_Date]) */ [App Year]
    , null /* FORMAT(apps.[Application_Date], 'MM-yyyy') */ [App MonthYr]
    , d_arch_mcc.[LoanAmount]
    , (d_arch_mcc.InterestRate/(100*100.00)) APR
    , d_arch_mcc.loanterm
    , d_arch_mcc.FICO
    , null [Tier Price]
    , d_arch_mcc.ProductType ProductCode
    , (case when substring(d_arch_mcc.ProductType,2,1)='P' then 'Promo'
      else 'Regular' end) [Product_Type]

    -- Merchant Info
    , 'MCC' [Merchant]
    , null [Merchant ID]
	, null [OfficeName]
    , null [Vertical]
	, null [Reseller]

    -- Borrower Info
    --, cast(d_arch_mcc.[DOB] as date) as [Borrfower DOB]
	, d_arch_mcc.[DOB] as [Borrfower DOB]
    , d_arch_mcc.[PhysicalState] [Borrower State]
    , d_arch_mcc.[PhysicalZip] [Borrower Zip]
    , d_arch_mcc.[GrossAnnualIncome]


    -- Facts table info
    , null [Fact AccountCount]
    , null [Fact Delinquent_Count]
    , null [Fact Delinquent_Balance]
    , null [Fact Delinquent_Payment]
    , null [Fact Payment_Amount]
    , null [Fact Loan_Amount]
    , null [Fact Losses_Amount]
    , null [Fact Current_Balance]
    , null [Fact Principal_Balance]
    , null [Fact Interest_Balance]
    , null [Fact Fees_Balance]
    , null [Fact Delnocycles]
    , null [Fact Delnodays]
    , null [Fact Cycle_Payments]
    , null [Fact Total_Amount_Due]
    , null [Fact Current_Amount_Due]
    , null [Fact PastDue_Amt]
    , null [Fact Last_Statement_Balance]
    , null [Fact Last_Statement_Payment]
    , null [Fact APR]
    , null [Fact Bucket_Amount_1 - 30 days Del]
    , null [Fact Bucket_Amount_2 - 60 days Del]
    , null [Fact Bucket_Amount_3 - 90 days Del]
    , null [Fact Bucket_Amount_4 - 120 days Del]
    , null [Fact Bucket_Amount_5 - 150 days Del]
    , null [Fact Bucket_Amount_6 - 180 days Del]
    , null [Fact Months_Open]
    , null [Fact Payoff_Months]

    -- Accounts Info
    ,accts.[Status]   AS       [Accounts Status]
    ,accts.[Status_Dt]   AS       [Accounts Status_Dt]
    ,accts.[Close_Date]   AS       [Accounts Close_Date]
    ,accts.[ReferenceNo]   AS       [Accounts ReferenceNo]
    ,accts.[Cycle_Dt]   AS       [Accounts Cycle_Dt]
    ,accts.[Cycle_Code]   AS       [Accounts Cycle_Code]
    ,accts.[Term]   AS       [Accounts Term]
    ,accts.[Payment_Due_Dt]   AS       [Accounts Payment_Due_Dt]
    ,accts.[Last_Statement_Date]   AS       [Accounts Last_Statement_Date]
    ,accts.[Next_Statement_Dt]   AS       [Accounts Next_Statement_Dt]
    ,accts.[Account_End_Dt]   AS       [Accounts Account_End_Dt]
    ,accts.[DelinqBucketNum]   AS       [Accounts DelinqBucketNum]

    -- PHX / Servicing file info
    , phx.[TotalAmountDue] [PHX TotalAmountDue]
    , phx.[CurrentAmountdue] [PHX CurrentAmountdue]
    , phx.[DataDT] [PHX Promo Payoff Date]
    , (case when substring(d_arch_mcc.ProductType,2,1)='P' then 'Yes'
      else '' end) [Promo]
    , (case when substring(d_arch_mcc.ProductType,2,1)='P' then substring(d_arch_mcc.ProductType,3,2)
      else null end) [Promo Term]
    , COALESCe(phx.opendt, phxco.opendt) [PHX OpenDate]

    , null            [MDF]
	,Null as [LoanPoolTag]
	,accts.FirstPaymentDelinquent

  FROM [dbo].[CreditReports_DailyArchive_History] AS d_arch_mcc
  left join [dbo].[LNAccts_AccountDim_ServicingFile_txt] phx  
      -- ON d_arch_mcc.[TCIReferenceID] = phx.TCIID
      -- on d_arch_mcc.[PartnerReferenceID] = phx.TCIID
      on left(d_arch_mcc.transactionid,25) = left(phx.referenceno, 25)
	  AND d_arch_mcc.LoadDate_ID = (select top 1 loaddate_id from dbo.[CreditReports_DailyArchive_History] where TCIReferenceID = d_arch_mcc.TCIReferenceID order by LoadDate_ID desc) -- Added to retrieve the most latest instance of the TRN from the credit history file
  left join [dbo].[CreditReports_History] cr
      ON d_arch_mcc.[TCIReferenceID] = cr.TCIID

  left join DW_Main.[dbo].[LNAccts_AccountDim] AS accts
    on accts.[Account_Number] = phx.accountnumber
	LEFT OUTER JOIN [dbo].[CreditReports_PHX_File_ChargedOff_Accounts] phxCO
      ON left(d_arch_mcc.transactionid,25) = left(phxCO.referenceno, 25)

  WHERE 1=1
    AND d_arch_mcc.[PartnerReferenceID] NOT LIKE '%TRN%'
    AND d_arch_mcc.[FNIQueue] = 'Booking Requested'
    AND d_arch_mcc.LoadDate_ID <> 'NA' -- only retrieve records with a valid load date
    AND isnull(accts.[Status], '') <> 'Canceled'
  )  as CombinedCQuery

-- Order by [LoadDateID], [Account_Number], TCIReferenceID

















GO


