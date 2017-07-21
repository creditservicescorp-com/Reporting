USE [DW_Source]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER VIEW [dbo].[viewReport_AllAppsExtract] AS
    SELECT DISTINCT
        /*
            apps.LoadDate_ID,
            apps.EXT_REF_NO,
            apps.TCIReferenceID,
            apps.Application_Date,
            apps.Loan_Application_ID,
            apps.Status,
            apps.Status_Grouping,

            d_arch.LoadDate_ID,
            cr.LoadDate_ID,
            la.[QUORUM_REF_ID],
            la.APPLICANT_ID,

            la.LOAN_APPLICATION_STATUS_ID                                    [LOAN_APPLICATION_STATUS_ID],
            la.APPLICANT_ID,
        */
        la.EXT_REF_NO                                                    [TRN],
        la.[QUORUM_REF_ID]                                               [TCIReferenceID],

        (CASE -- new lender/scoring logic added to portal July 2017
			WHEN lnd.LenderId = 1
            THEN 'CRB'
			WHEN lnd.LenderId = 2
			THEN 'Quorum'
        END)                                                          [Routing],

        s.STATUS_NAME                                                    [Status],
        la.APR                                                           [APR],
        la.MDF                                                           [MDF],
        cast(la.DATE_APPLIED as date)                                    [App Date],
        cast(la.DATE_FUNDED as date)                                     [Funded Date],
        cast(la.DATE_CANCELLED as date)                                  [Cancelled Date],
        d_arch.FICO                                                      [FICO],
        la.SCORECARD                                                     [Scorecard],
        prod.PAYMENT_TYPE                                                [ProductType],
        prod.CODE                                                        [ProductCode],
        prod.NAME                                                        [ProductName],
        ofc.ProviderName                                                 [Provider],
        r.RESELLER_NAME                                                  [Reseller],

        la.LOAN_AMOUNT                                                   [App Amount],
		la.APPROVED_AMOUNT                                               [Approved Amount],
		la.OVERRIDE_AMOUNT                                               [Override Amount],
		(CASE WHEN isnull(OVERRIDE_SOURCE_ID, 0) = 2 THEN 'FNI'
			WHEN isnull(OVERRIDE_SOURCE_ID, 0) = 1 THEN 'Quorum'
			WHEN isnull(APPROVED_AMOUNT, 0) > 0 THEN 'No Override'
			ELSE 'N/A' END)												 [Override Source],

        la.TERMS                                                         [Term],
        a.LAST_NAME                                                      [Last Name],
        a.FIRST_NAME                                                     [First Name],
        ad.STATE                                                         [State],
		ad.ZIP_CODE														 [ZipCode],
        v.CODE                                                           [Vertical],

        ofc.EntityName                                                   [Office],
        la.MONTHLY_PAYMENT                                               [Monthly Payment],

        isnull(laSrc.Name,'')                                            [App Source],

        refund.GrossRefundAmount * (-1.00)                               [GrossRefundAmount],
        refund.LastRefundDate                                            [LastRefundDate],
		lp.Tag															 [LoanPoolTag],
		ofc.ProviderID as [Merchant Id]  -- requested and added on 6/7/2017


    FROM dbo.Extracts_Daily_OraclePDB_LOAN_APPLICATION la (nolock)
        JOIN dbo.Extracts_Daily_OraclePDB_APPLICANT a (nolock)
            ON a.APPLICANT_ID = la.APPLICANT_ID
        JOIN dbo.Extracts_Daily_OraclePDB_APPLICANT_ADDRESS ad (nolock)
            ON ad.APPLICANT_ADDRESS_ID = la.APPLICANT_ADDRESS_ID
        JOIN [dbo].[viewProviderEntityOffices_v2] ofc (nolock)
            ON ofc.Hierarchy_ID = la.ASSIGNED_OFFICE_ID
        JOIN [dbo].[Extracts_Daily_OraclePDB_LOAN_APPLICATION_STATUS] s (nolock)
            ON s.LOAN_APPLICATION_STATUS_ID = la.LOAN_APPLICATION_STATUS_ID
        LEFT OUTER JOIN [dbo].[Extracts_Daily_OraclePDB_LOAN_PRODUCT_DTL] prod (nolock)
			ON prod.LOAN_PROD_DTL_ID = la.LOAN_PROD_DTL_ID

/*
        OUTER APPLY (
                SELECT top 1 QUORUM_REF_ID, LOAN_APPLICATION_ID, LOAN_APPLICATION_STATUS_ID
                    FROM DEV_Source.dbo.Extracts_Daily_OraclePDB_LOAN_APPLICATION la2 (nolock)
                    WHERE la2.APPLICANT_ID = la.APPLICANT_ID and la2.LOAN_APPLICATION_STATUS_ID NOT IN (3,2)
                          and la2.LOAN_APPLICATION_ID <> la.LOAN_APPLICATION_ID
                    ORDER BY la2.LOAN_APPLICATION_ID DESC
            ) prev_app


        LEFT OUTER JOIN
            (SELECT LoadDate_ID, TCIID, RevUtilization, RevBalance, DebttoIncomeRatio
                FROM Dev_Source.[dbo].[CreditReports_History] crh (nolock)
                UNION ALL
             SELECT LoadDate_ID, TCIID, RevUtilization, RevBalance, DebttoIncomeRatio
                FROM Dev_Source.[dbo].CreditBureauReports_DailyConsolidatedTable crd (nolock)
            ) AS cr
                ON cr.TCIID = la.QUORUM_REF_ID
                   OR cr.TCIID = prev_app.QUORUM_REF_ID
                -- apps.TCIReferenceID
*/

        LEFT OUTER JOIN [dbo].[CreditReports_DailyArchive_History] AS d_arch (nolock)
            ON d_arch.[TCIReferenceID] = la.QUORUM_REF_ID
                -- apps.TCIReferenceID

        LEFT OUTER JOIN [dbo].[Extracts_Daily_OraclePDB_MERCHANT_CONFIG] mc (nolock)
			ON mc.MERCHANT_ID = ofc.ProviderID

        LEFT OUTER JOIN [dbo].[Extracts_Daily_OraclePDB_RESELLER] r (nolock)
			ON r.RESELLER_ID = ofc.RESELLER_ID
        LEFT OUTER JOIN [dbo].[Extracts_Daily_OraclePDB_VERTICAL] v (nolock)
			ON v.VERTICAL_ID = ofc.VERTICAL_ID

        LEFT OUTER JOIN [dbo].[Extracts_Daily_OraclePDB_LOAN_APPLICATION_REQUEST] lar (nolock)
			ON lar.UUID = la.UUID
        LEFT OUTER JOIN [dbo].[Extracts_Daily_OraclePDB_LOAN_APPLICATION_SOURCE] laSrc (nolock)
            ON laSrc.LoanApplicationSourceId = lar.LOAN_APPLICATION_SOURCE_ID


        OUTER APPLY (SELECT SUM(RefundAmount) GrossRefundAmount, MAX(pr.CreatedDate) LastRefundDate
                        FROM [dbo].[Extracts_Daily_OraclePDB_PARTIAL_REFUND] pr ( NOLOCK )
                        WHERE pr.LoanApplicationId = la.LOAN_APPLICATION_ID ) refund
		LEFT OUTER JOIN [dbo].[Extracts_Daily_OraclePDB_LoanPool] lp
			ON lp.LoanApplicationId = la.LOAN_APPLICATION_ID
			
		INNER JOIN dbo.Extracts_Daily_OraclePDB_Scoring sc on la.ScoringId = sc.ScoringId
		INNER JOIN dbo.Extracts_Daily_OraclePDB_Lender lnd on sc.LenderId = lnd.LenderId
    WHERE --la.LoadDate_ID <> 'NA' AND datediff(D, la.LoadDate_ID, getdate()) = 1 AND /*Commenting loadDate as all the data is coming from extracts table*/
		  isnull(mc.DEMO, 0) = 0          
          AND la.LOAN_APPLICATION_STATUS_ID NOT IN(3,60, 61, 100, 199);  -- All apps which went successfully through approval process




GO


