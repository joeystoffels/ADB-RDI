USE ODISEE;
GO

SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

DECLARE @Country VARCHAR(MAX)= 'The Netherlands';
DECLARE @Month INT= 4;
DECLARE @Year INT= 2019;
WITH YearMonthCountryTotals(Year,
                           Month,
                           Country,
                           ItemsPerMonth)
    AS (SELECT YEAR(P.purchase_date) AS Year,
               MONTH(P.purchase_date) AS Month,
               U.country_name AS Country,
               COUNT(P.purchase_date) AS ItemsPerMonth
        FROM Purchase AS P
             INNER JOIN [User] AS U ON P.email_address = U.email_address
        GROUP BY YEAR(P.purchase_date),
                 MONTH(P.purchase_date),
                 U.country_name
        HAVING U.country_name = @Country
               AND ((YEAR(P.purchase_date) = @Year
                     AND MONTH(P.purchase_date) <= @Month)
                    OR (YEAR(P.purchase_date) = (@Year - 1)
                        AND MONTH(P.purchase_date) > @Month)))
    SELECT YMT1.Year,
           YMT1.Month,
           YMT1.ItemsPerMonth,
           FORMAT(YMT1.ItemsPerMonth / SUM(YMT1.ItemsPerMonth), 'P') AS PercentageOfTotal
    FROM YearMonthCountryTotals AS YMT1
    GROUP BY YMT1.Year,
             YMT1.Month,
             YMT1.ItemsPerMonth,
             YMT1.Country;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO


--  SQL Server Execution Times:
--    CPU time = 0 ms,  elapsed time = 2 ms.
-- SQL Server parse and compile time:
--    CPU time = 15 ms, elapsed time = 15 ms.
--
--  SQL Server Execution Times:
--    CPU time = 0 ms,  elapsed time = 0 ms.
--
--  SQL Server Execution Times:
--    CPU time = 0 ms,  elapsed time = 0 ms.
--
--  SQL Server Execution Times:
--    CPU time = 0 ms,  elapsed time = 0 ms.
--
-- (1 row affected)
-- Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'User'. Scan count 0, logical reads 33, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Purchase'. Scan count 1, logical reads 2, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--
-- (1 row affected)
--
--  SQL Server Execution Times:
--    CPU time = 0 ms,  elapsed time = 79 ms.


-- Drop constraints
ALTER TABLE [dbo].[User_Subscription] DROP CONSTRAINT [FK_USER_SUB_USER_OF_U_USER]
GO

ALTER TABLE [dbo].[Review] DROP CONSTRAINT [FK_REVIEW_USER_OF_R_USER]
GO

ALTER TABLE [dbo].[Purchase] DROP CONSTRAINT [FK_PURCHASE_USER_OF_P_USER]
GO

ALTER TABLE [dbo].[Invoice] DROP CONSTRAINT [FK_INVOICE_USER_OF_I_USER]
GO


-- Finally we can delete PK_PRODUCT
ALTER TABLE [User] DROP CONSTRAINT PK_USER;
GO

-- So we can add a clustered PK
ALTER TABLE [User]
ADD CONSTRAINT PK_USER PRIMARY KEY CLUSTERED(email_address);


-- Add constraints
ALTER TABLE [dbo].[User_Subscription]  WITH CHECK ADD  CONSTRAINT [FK_USER_SUB_USER_OF_U_USER] FOREIGN KEY([email_address])
REFERENCES [dbo].[User] ([email_address])
GO

ALTER TABLE [dbo].[User_Subscription] CHECK CONSTRAINT [FK_USER_SUB_USER_OF_U_USER]
GO

ALTER TABLE [dbo].[Review]  WITH CHECK ADD  CONSTRAINT [FK_REVIEW_USER_OF_R_USER] FOREIGN KEY([email_address])
REFERENCES [dbo].[User] ([email_address])
GO

ALTER TABLE [dbo].[Review] CHECK CONSTRAINT [FK_REVIEW_USER_OF_R_USER]
GO


ALTER TABLE [dbo].[Purchase]  WITH CHECK ADD  CONSTRAINT [FK_PURCHASE_USER_OF_P_USER] FOREIGN KEY([email_address])
REFERENCES [dbo].[User] ([email_address])
GO

ALTER TABLE [dbo].[Purchase] CHECK CONSTRAINT [FK_PURCHASE_USER_OF_P_USER]
GO

ALTER TABLE [dbo].[Invoice]  WITH CHECK ADD  CONSTRAINT [FK_INVOICE_USER_OF_I_USER] FOREIGN KEY([email_address])
REFERENCES [dbo].[User] ([email_address])
GO

ALTER TABLE [dbo].[Invoice] CHECK CONSTRAINT [FK_INVOICE_USER_OF_I_USER]
GO





--  --------------------------------------------------------
--  Create index
--  --------------------------------------------------------
-- CREATE NONCLUSTERED INDEX IX_User_emailaddress_countryname2 ON [Purchase](email_address) INCLUDE(purchase_date);



--  --------------------------------------------------------
--  Remove index
--  --------------------------------------------------------

-- DROP INDEX IX_User_emailaddress_countryname ON [User];
-- DROP INDEX IX_User_emailaddress_countryname2 ON [Purchase];