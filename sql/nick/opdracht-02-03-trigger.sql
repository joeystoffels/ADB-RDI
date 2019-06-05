--  --------------------------------------------------------
-- Constraint 3:
-- Het kan natuurlijk gebeuren dat iemand meerdere abonnementsperiodes heeft.
-- Dan kunnen de verschillende abonnementsperiodes van een persoon niet overlappen.
-- https://i.stack.imgur.com/AIBUV.png
-- https://stackoverflow.com/questions/13513932/algorithm-to-detect-overlapping-periods
--  --------------------------------------------------------
USE odisee;
GO
DROP TRIGGER IF EXISTS TR_No_Overlap_In_Subscriptions;
DROP PROCEDURE IF EXISTS SP_DemoData;  
GO

--  --------------------------------------------------------
--  Trigger
--  --------------------------------------------------------
CREATE TRIGGER TR_No_Overlap_In_Subscriptions ON User_Subscription
AFTER INSERT, UPDATE
AS
     BEGIN
         SET NOCOUNT ON; -- Stops the message that shows the count of the number of rows affected
         -- Declare variables
         DECLARE @email NVARCHAR(4000);
         DECLARE @startDate DATE;
         DECLARE @endDate DATE;
         IF NOT EXISTS
         (
             SELECT *
             FROM inserted
         )
             RETURN; -- If nothing is inserted
         BEGIN TRY
             SET @email =
             (
                 SELECT email_address
                 FROM inserted
             );
             SET @startDate =
             (
                 SELECT subscription_startdate
                 FROM inserted
             );
             SET @endDate =
             (
                 SELECT subscription_enddate
                 FROM inserted
             );
             IF EXISTS
             (
                 SELECT *
                 FROM User_Subscription AS US
                 --                 WHERE @startDate < US.subscription_enddate
                 --                       AND US.subscription_startdate < ISNULL(@endDate, '2099-12-31')
                 --                       AND email_address = @email
                 -- WHERE US.subscription_startdate < ISNULL(@endDate, '2099-12-31')
                 --      AND @startDate < US.subscription_enddate
                 --      AND email_address = @email
                 WHERE NOT(ISNULL(@endDate, '2099-12-31') < US.subscription_startdate
                           OR US.subscription_enddate < @startDate)
                       AND email_address = @email
             )
                 THROW 50001, 'There is an overlap in subscriptions', 1;
         END TRY
         BEGIN CATCH
             THROW; -- Using TROW handles ROLLBACK and bubbles up the thrown error.
         END CATCH;
     END;
	 GO

--  --------------------------------------------------------
--  Demo data
--  --------------------------------------------------------

CREATE PROCEDURE SP_DemoData
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @email NVARCHAR(4000)= 'test@test.nl';
        DECLARE @startDate01 DATE= '2017-03-01';
        DECLARE @endDate01 DATE= '2018-03-01';
        DECLARE @startDate02 DATE= '2018-05-01';
        DECLARE @endDate02 DATE= '2019-05-01';
        INSERT INTO [User]
        VALUES
        (@email, 
         'The Netherlands', 
         'Test user', 
         'Delete', 
         'this user', 
         'M', 
         NULL
        );
        INSERT INTO User_Subscription
        VALUES
        (@email, 
         'The Netherlands', 
         'Basic', 
         'Basic', 
         @startDate01, 
         @endDate01, 
         3.00
        );
        INSERT INTO User_Subscription
        VALUES
        (@email, 
         'The Netherlands', 
         'Basic', 
         'Basic', 
         @startDate02, 
         @endDate02, 
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
EXEC SP_DemoData;

INSERT INTO User_Subscription
VALUES
('test@test.nl', 
 'The Netherlands', 
 'Basic', 
 'Basic', 
 DATEADD(day, -1, '2017-03-01'), 
 DATEADD(day, -1, '2018-03-01'), 
 3.00
);

ROLLBACK TRANSACTION;

-- Scenario 02:
--    [XXXXX]
-- [XXXXX]
-- The startDate of the inserted subscription overlaps an endDate of an other subscription;
-- Result: Throw Error
BEGIN TRANSACTION;
EXEC SP_DemoData;

INSERT INTO User_Subscription
VALUES
('test@test.nl', 
 'The Netherlands', 
 'Basic', 
 'Basic', 
 DATEADD(day, 1, '2017-03-01'), 
 DATEADD(day, 1, '2018-03-01'), 
 3.00
);
ROLLBACK TRANSACTION;

-- Scenario 03:
--  [XXX]
-- [XXXXXX]
-- Result: Throw Error
BEGIN TRANSACTION;
EXEC SP_DemoData;

INSERT INTO User_Subscription
VALUES
('test@test.nl', 
 'The Netherlands', 
 'Basic', 
 'Basic', 
 DATEADD(day, 1, '2017-03-01'), 
 DATEADD(day, -1, '2018-03-01'), 
 3.00
);
ROLLBACK TRANSACTION;

-- Scenario 04:
-- [XXXXXX]
--  [XXX]
-- Result: Throw Error
BEGIN TRANSACTION;
EXEC SP_DemoData;

INSERT INTO User_Subscription
VALUES
('test@test.nl', 
 'The Netherlands', 
 'Basic', 
 'Basic', 
 DATEADD(day, -1, '2017-03-01'), 
 DATEADD(day, 1, '2018-03-01'), 
 3.00
);
ROLLBACK TRANSACTION;

-- Scenario 05:
--        [XXXX]
-- [XXXX]        [XXXX]
-- Result: Throw Error
BEGIN TRANSACTION;
EXEC SP_DemoData;

INSERT INTO User_Subscription
VALUES
('test@test.nl', 
 'The Netherlands', 
 'Basic', 
 'Basic', 
 '2018-03-01',
 '2018-04-01',
 3.00
);
ROLLBACK TRANSACTION;

-- Scenario 06:
-- [XXXX]
-- [XXXX]
-- Result: Throw Error
BEGIN TRANSACTION;
EXEC SP_DemoData;

INSERT INTO User_Subscription
VALUES
('test@test.nl', 
 'The Netherlands', 
 'Basic', 
 'Basic', 
 '2017-03-01',
 '2018-03-01',
 3.00
);
ROLLBACK TRANSACTION;

-- Scenario 07:
--       [XXXX]
-- [XXXX]
-- Result: Success
BEGIN TRANSACTION;
EXEC SP_DemoData;

INSERT INTO User_Subscription
VALUES
('test@test.nl', 
 'The Netherlands', 
 'Basic', 
 'Basic', 
 '2019-06-01',
 '2019-07-01',
 3.00  
);
ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Cleanup
--  --------------------------------------------------------
DROP TRIGGER IF EXISTS TR_No_Overlap_In_Subscriptions;
DROP PROCEDURE IF EXISTS SP_DemoData;  
GO