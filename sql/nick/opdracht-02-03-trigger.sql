USE odisee;
GO
DROP TRIGGER IF EXISTS TR_No_Overlap_In_Subscriptions;
DROP PROCEDURE IF EXISTS SP_InsertDemoData;
GO

--  --------------------------------------------------------
--  Trigger
--  --------------------------------------------------------
CREATE TRIGGER TR_No_Overlap_In_Subscriptions ON User_Subscription
AFTER INSERT, UPDATE
AS
     BEGIN
         SET NOCOUNT ON; -- Stops the message that shows the count of the number of rows affected

         IF NOT EXISTS
         (
             SELECT *
             FROM inserted
         )
             RETURN;
         BEGIN TRY
             IF EXISTS
             (
                 SELECT 'Overlap'
                 FROM
                 (
                     SELECT CASE
                                WHEN(subscription_startdate BETWEEN(LAG(subscription_startdate, 1) OVER(
                                    ORDER BY email_address)) AND(LAG(ISNULL(subscription_enddate, DATEADD(year, 100, GETDATE())), 1) OVER(
                                    ORDER BY email_address)))
                                    OR (ISNULL(subscription_enddate, DATEADD(year, 100, GETDATE())) BETWEEN(LAG(subscription_startdate, 1) OVER(
                                    ORDER BY email_address)) AND(LAG(ISNULL(subscription_enddate, DATEADD(year, 100, GETDATE())), 1) OVER(
                                    ORDER BY email_address)))
                                    OR (subscription_startdate < (LAG(subscription_startdate, 1) OVER(
                                        ORDER BY email_address))
                                        AND ISNULL(subscription_enddate, DATEADD(year, 100, GETDATE())) > (LAG(ISNULL(subscription_enddate, DATEADD(year, 100, GETDATE())), 1) OVER(
                                            ORDER BY email_address)))
                                    OR (subscription_startdate > (LAG(subscription_startdate, 1) OVER(
                                        ORDER BY email_address))
                                        AND ISNULL(subscription_enddate, DATEADD(year, 100, GETDATE())) < (LAG(ISNULL(subscription_enddate, DATEADD(year, 100, GETDATE())), 1) OVER(
                                            ORDER BY email_address)))
                                THEN 'yes'
                                WHEN(LAG(subscription_startdate, 1) OVER(
                            ORDER BY email_address)) IS NULL
                                THEN NULL
                                ELSE 'no'
                            END AS OverLapping
                     FROM User_Subscription
                 ) AS OL
                 WHERE OL.OverLapping = 'yes'
             )
                 THROW 50002, 'Inserted subscription(s) overlaps an excisting subscription period.', 1;
         END TRY
         BEGIN CATCH
             PRINT 'In catch block';
             THROW; -- Using TROW handles ROLLBACK and bubbles up the thrown error.
         END CATCH;
     END;
GO

--  --------------------------------------------------------
--  Demo data
--  --------------------------------------------------------

CREATE PROCEDURE SP_InsertDemoData
AS
    BEGIN
        SET NOCOUNT ON;
        INSERT INTO [User]
        VALUES
        ('test@test.nl', 
         'The Netherlands', 
         'Test user', 
         'Delete', 
         'this user', 
         'M', 
         NULL
        );
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
        INSERT INTO User_Subscription
        VALUES
        ('test@test.nl', 
         'The Netherlands', 
         'Basic', 
         'Basic', 
         '2018-05-01', 
         '2019-05-01', 
         3.00
        );
        INSERT INTO User_Subscription
        VALUES
        ('test@test.nl', 
         'The Netherlands', 
         'Basic', 
         'Basic', 
         '2019-06-01', 
         NULL, 
         3.00
        );
    END;
GO

--  --------------------------------------------------------
--  Testscenario's
--  --------------------------------------------------------

-- First insert demo data
DELETE FROM User_Subscription WHERE email_address = 'test@test.nl'
DELETE FROM [User] WHERE email_address = 'test@test.nl'
EXEC SP_InsertDemoData;


-- Scenario 01:
-- [XXXXX]
--   [XXXXX]
-- The enddate of the inserted subscription overlaps an startDate of an other subscription;
-- Result: Throw Error
BEGIN TRANSACTION;
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
-- Result: Success
BEGIN TRANSACTION;
INSERT INTO User_Subscription
VALUES
('test@test.nl', 
 'The Netherlands', 
 'Basic', 
 'Basic', 
 DATEADD(day, 1, '2018-03-05'), 
 DATEADD(day, -1, '2018-04-05'), 
 3.00
);
ROLLBACK TRANSACTION;


-- Scenario 06:
-- [XXXX]
-- [XXXX]
-- Result: Throw Error
BEGIN TRANSACTION;
INSERT INTO User_Subscription
VALUES
('test@test.nl', 
 'The Netherlands', 
 'Basic', 
 'Basic', 
 DATEADD(day, 0, '2017-03-01'), 
 DATEADD(day, 0, '2017-03-01'), 
 3.00
);
ROLLBACK TRANSACTION;


-- Scenario 07:
--       [XXXX]
-- [XXXX ---> geen einde
-- Result: Throw Error
BEGIN TRANSACTION;
INSERT INTO User_Subscription
VALUES
('test@test.nl', 
 'The Netherlands', 
 'Basic', 
 'Basic', 
 DATEADD(day, 14, '2019-06-01'), 
 DATEADD(day, 34, '2019-06-01'), 
 3.00
);
ROLLBACK TRANSACTION;


-- Scenario 08:
--       [XXXX]
-- [XXXX] 
-- Result: Success
BEGIN TRANSACTION;
DELETE FROM User_Subscription
WHERE subscription_startdate = '2019-06-01'
      AND ISNULL(subscription_enddate, DATEADD(year, 100, GETDATE())) IS NULL;
INSERT INTO User_Subscription
VALUES
('test@test.nl', 
 'The Netherlands', 
 'Basic', 
 'Basic', 
 DATEADD(day, 14, '2019-06-01'), 
 DATEADD(day, 34, '2019-06-01'), 
 3.00
);
ROLLBACK TRANSACTION;


-- Scenario 09:
--       [XXXX]
-- [XXXX]
-- AND
-- [XXXXXX]
--  [XXX]
-- Result: Throw Error
BEGIN TRANSACTION;
DELETE FROM User_Subscription
WHERE subscription_startdate = '2019-06-01'
      AND ISNULL(subscription_enddate, DATEADD(year, 100, GETDATE())) IS NULL;
INSERT INTO User_Subscription
VALUES
('test@test.nl', 
 'The Netherlands', 
 'Basic', 
 'Basic', 
 DATEADD(day, 14, '2019-06-01'), 
 DATEADD(day, 34, '2019-06-01'), 
 3.00
),
('test@test.nl', 
 'The Netherlands', 
 'Basic', 
 'Basic', 
 DATEADD(day, -1, '2017-03-01'), 
 DATEADD(day, 1, '2018-03-01'), 
 3.00
);
ROLLBACK TRANSACTION;


--  --------------------------------------------------------
--  Cleanup
--  --------------------------------------------------------
DROP TRIGGER IF EXISTS TR_No_Overlap_In_Subscriptions;
DROP PROCEDURE IF EXISTS SP_InsertDemoData;
GO