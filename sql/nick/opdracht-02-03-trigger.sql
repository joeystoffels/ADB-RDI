USE odisee;
GO
DROP TRIGGER IF EXISTS TR_No_Overlap_In_Subscriptions;
DROP PROCEDURE IF EXISTS SP_InsertDemoData;  
GO
EXEC sp_set_session_context 
     'email_address', 
     'test@test.nl';
EXEC sp_set_session_context 
     'startDate01', 
     '2017-03-01';
EXEC sp_set_session_context 
     'endDate01', 
     '2018-03-01';
EXEC sp_set_session_context 
     'startDate02', 
     '2018-05-01';
EXEC sp_set_session_context 
     'endDate02', 
     '2019-05-01';
EXEC sp_set_session_context 
     'startDate03', 
     '2019-06-01';
GO

--  --------------------------------------------------------
--  Trigger
--  --------------------------------------------------------
CREATE TRIGGER TR_No_Overlap_In_Subscriptions ON User_Subscription
INSTEAD OF INSERT, UPDATE
AS
     BEGIN

         SET NOCOUNT ON; -- Stops the message that shows the count of the number of rows affected

         SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
	     BEGIN TRANSACTION;

         -- Declare variables
         DECLARE @email_address EMAIL;
         DECLARE @country_name COUNTRY;
         DECLARE @subscription_type TYPE;
         DECLARE @subscription_type_name VARCHAR(255);
         DECLARE @startDate DATE;
         DECLARE @endDate DATE;
         DECLARE @monthly_fee PRICE;
         IF NOT EXISTS
         (
             SELECT *
             FROM inserted
         )
             RETURN; -- If nothing is inserted
         BEGIN TRY
             SELECT @email_address = email_address
             FROM inserted;
             SELECT @country_name = country_name
             FROM inserted;
             SELECT @subscription_type = subscription_type
             FROM inserted;
             SELECT @subscription_type_name = subscription_type_name
             FROM inserted;
             SELECT @startDate = subscription_startdate
             FROM inserted;
             SELECT @endDate = subscription_enddate
             FROM inserted;
             SELECT @monthly_fee = monthly_fee
             FROM inserted;
             IF EXISTS
             (
                 SELECT *
                 FROM User_Subscription
                 WHERE ISNULL(@endDate, DATEADD(year, 100, @endDate)) <= subscription_startdate
                       OR subscription_enddate >= @startDate
                       AND email_address = @email_address
             )
                 THROW 50002, 'Subscriptions can not overlap', 1;
             INSERT INTO User_Subscription
             VALUES
             (@email_address, 
              @country_name, 
              @subscription_type, 
              @subscription_type_name, 
              @startDate, 
              @endDate, 
              @monthly_fee
             );
             --
         END TRY
         BEGIN CATCH
             THROW; -- Using TROW handles ROLLBACK and bubbles up the thrown error.
         END CATCH;
     END;

     COMMIT TRANSACTION;
 GO

--  --------------------------------------------------------
--  Demo data
--  --------------------------------------------------------

CREATE PROCEDURE SP_InsertDemoData
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @email_address VARCHAR(255)= CONVERT(VARCHAR(255), SESSION_CONTEXT(N'email_address'));
        DECLARE @startDate01 DATE= CONVERT(DATE, SESSION_CONTEXT(N'startDate01'));
        DECLARE @endDate01 DATE= CONVERT(DATE, SESSION_CONTEXT(N'endDate01'));
        DECLARE @startDate02 DATE= CONVERT(DATE, SESSION_CONTEXT(N'startDate02'));
        DECLARE @endDate02 DATE= CONVERT(DATE, SESSION_CONTEXT(N'endDate02'));
        DECLARE @startDate03 DATE= CONVERT(DATE, SESSION_CONTEXT(N'startDate03'));
        INSERT INTO [User]
        VALUES
        (@email_address, 
         'The Netherlands', 
         'Test user', 
         'Delete', 
         'this user', 
         'M', 
         NULL
        );
        INSERT INTO User_Subscription
        VALUES
        (@email_address, 
         'The Netherlands', 
         'Basic', 
         'Basic', 
         @startDate01, 
         @endDate01, 
         3.00
        );
        INSERT INTO User_Subscription
        VALUES
        (@email_address, 
         'The Netherlands', 
         'Basic', 
         'Basic', 
         @startDate02, 
         @endDate02, 
         3.00
        );
        INSERT INTO User_Subscription
        VALUES
        (@email_address, 
         'The Netherlands', 
         'Basic', 
         'Basic', 
         @startDate03, 
         NULL, 
         3.00
        );
    END;
GO

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------
-- Scenario 01:
-- [XXXXX]
--   [XXXXX]
-- The enddate of the inserted subscription overlaps an startDate of an other subscription;
-- Result: Throw Error
BEGIN TRANSACTION;
EXEC SP_InsertDemoData;
INSERT INTO User_Subscription
VALUES
('test@test.nl', 
 'The Netherlands', 
 'Basic', 
 'Basic', 
 DATEADD(day, -1, CONVERT(DATE, SESSION_CONTEXT(N'startDate01'))), 
 DATEADD(day, -1, CONVERT(DATE, SESSION_CONTEXT(N'endDate01'))), 
 3.00
);
ROLLBACK TRANSACTION;

-- Scenario 02:
--    [XXXXX]
-- [XXXXX]
-- The startDate of the inserted subscription overlaps an endDate of an other subscription;
-- Result: Throw Error
BEGIN TRANSACTION;
EXEC SP_InsertDemoData;
INSERT INTO User_Subscription
VALUES
(CONVERT(VARCHAR(255), SESSION_CONTEXT(N'email_address')), 
 'The Netherlands', 
 'Basic', 
 'Basic', 
 DATEADD(day, 1, CONVERT(DATE, SESSION_CONTEXT(N'startDate01'))), 
 DATEADD(day, 1, CONVERT(DATE, SESSION_CONTEXT(N'endDate01'))), 
 3.00
);
ROLLBACK TRANSACTION;

-- Scenario 03:
--  [XXX]
-- [XXXXXX]
-- Result: Throw Error
BEGIN TRANSACTION;
EXEC SP_InsertDemoData;
INSERT INTO User_Subscription
VALUES
(CONVERT(VARCHAR(255), SESSION_CONTEXT(N'email_address')), 
 'The Netherlands', 
 'Basic', 
 'Basic', 
 DATEADD(day, 1, CONVERT(DATE, SESSION_CONTEXT(N'startDate01'))), 
 DATEADD(day, -1, CONVERT(DATE, SESSION_CONTEXT(N'endDate01'))), 
 3.00
);
ROLLBACK TRANSACTION;

-- Scenario 04:
-- [XXXXXX]
--  [XXX]
-- Result: Throw Error
BEGIN TRANSACTION;
EXEC SP_InsertDemoData;
INSERT INTO User_Subscription
VALUES
(CONVERT(VARCHAR(255), SESSION_CONTEXT(N'email_address')), 
 'The Netherlands', 
 'Basic', 
 'Basic', 
 DATEADD(day, -1, CONVERT(DATE, SESSION_CONTEXT(N'startDate01'))), 
 DATEADD(day, 1, CONVERT(DATE, SESSION_CONTEXT(N'endDate01'))), 
 3.00
);
ROLLBACK TRANSACTION;

-- Scenario 05:
--        [XXXX]
-- [XXXX]        [XXXX]
-- Result: Throw Error
BEGIN TRANSACTION;
EXEC SP_InsertDemoData;
INSERT INTO User_Subscription
VALUES
(CONVERT(VARCHAR(255), SESSION_CONTEXT(N'email_address')), 
 'The Netherlands', 
 'Basic', 
 'Basic', 
 DATEADD(day, 1, CONVERT(DATE, SESSION_CONTEXT(N'endDate01'))), 
 DATEADD(day, -1, CONVERT(DATE, SESSION_CONTEXT(N'startDate02'))), 
 3.00
);
ROLLBACK TRANSACTION;

-- Scenario 06:
-- [XXXX]
-- [XXXX]
-- Result: Throw Error
BEGIN TRANSACTION;
EXEC SP_InsertDemoData;
INSERT INTO User_Subscription
VALUES
(CONVERT(VARCHAR(255), SESSION_CONTEXT(N'email_address')), 
 'The Netherlands', 
 'Basic', 
 'Basic', 
 DATEADD(day, 0, CONVERT(DATE, SESSION_CONTEXT(N'startDate01'))), 
 DATEADD(day, 0, CONVERT(DATE, SESSION_CONTEXT(N'endDate01'))), 
 3.00
);
ROLLBACK TRANSACTION;

-- Scenario 07:
--       [XXXX]
-- [XXXX ---> geen einde
-- Result: Throw Error
BEGIN TRANSACTION;
EXEC SP_InsertDemoData;
INSERT INTO User_Subscription
VALUES
(CONVERT(VARCHAR(255), SESSION_CONTEXT(N'email_address')), 
 'The Netherlands', 
 'Basic', 
 'Basic', 
 DATEADD(day, 14, CONVERT(DATE, SESSION_CONTEXT(N'startDate03'))), 
 DATEADD(day, 34, CONVERT(DATE, SESSION_CONTEXT(N'startDate03'))), 
 3.00
);
ROLLBACK TRANSACTION;

-- Scenario 08:
--       [XXXX]
-- [XXXX] 
-- Result: Success
BEGIN TRANSACTION;
EXEC SP_InsertDemoData;
DELETE FROM User_Subscription
WHERE subscription_startdate = CONVERT(DATE, SESSION_CONTEXT(N'startDate03'))
      AND subscription_enddate IS NULL;
INSERT INTO User_Subscription
VALUES
(CONVERT(VARCHAR(255), SESSION_CONTEXT(N'email_address')), 
 'The Netherlands', 
 'Basic', 
 'Basic', 
 DATEADD(day, 14, CONVERT(DATE, SESSION_CONTEXT(N'startDate03'))), 
 DATEADD(day, 34, CONVERT(DATE, SESSION_CONTEXT(N'startDate03'))), 
 3.00
);
ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Cleanup
--  --------------------------------------------------------
DROP TRIGGER IF EXISTS TR_No_Overlap_In_Subscriptions;
DROP PROCEDURE IF EXISTS SP_InsertDemoData;  
GO