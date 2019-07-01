USE odisee;
GO
DROP TRIGGER IF EXISTS TR_No_Overlap_In_Subscriptions;
DROP PROCEDURE IF EXISTS SP_InsertDemoData;
GO

--  --------------------------------------------------------
--  Trigger
--  --------------------------------------------------------
CREATE TRIGGER TR_No_Overlap_In_Subscriptions
    ON User_Subscription
    INSTEAD OF INSERT, UPDATE
    AS
BEGIN
    SET NOCOUNT ON; -- Stops the message that shows the count of the number of rows affected

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
        RETURN;

    BEGIN TRY
        PRINT 'In try block';

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
--                 IF EXISTS(SELECT '!'
--                           FROM (SELECT I.*,
--                                        (SELECT COUNT(*)
--                                         FROM Marriage M
--                                         WHERE (I.HusbandID = M.HusbandID
--                                             AND (I.WifeID <> M.WifeID
--                                                 AND I.DateMarriage <> M.DateMarriage
--                                                 AND ((M.DateMarriage < I.DateMarriage AND M.DateDivorce IS NULL)
--                                                     OR I.DateMarriage BETWEEN M.DateMarriage AND M.DateDivorce
--                                                     OR (M.DateDivorce IS NULL AND I.DateDivorce IS NULL))))) AS Fouten
--                                 FROM Inserted I) a
--                           WHERE Fouten > 0
--                     -- And the same construct for WifeID
--                     )
--
--
--
--                 IF EXISTS(SELECT '!'
--                           FROM (SELECT I.*,
--                                        (SELECT COUNT(*)
--                                         FROM Marriage M
--                                         WHERE (I.HusbandID = M.HusbandID
--                                             AND (I.WifeID <> M.WifeID
--                                                 AND I.DateMarriage <> M.DateMarriage
--                                                 AND ((M.DateMarriage < I.DateMarriage AND M.DateDivorce IS NULL)
--                                                     OR I.DateMarriage BETWEEN M.DateMarriage AND M.DateDivorce
--                                                     OR (M.DateDivorce IS NULL AND I.DateDivorce IS NULL))))) AS Fouten
--                                 FROM Inserted I) a
--                           WHERE Fouten > 0
--                     -- And the same construct for WifeID
--                     )





                                select 1 from
                        User_Subscription AS US, inserted AS I
--                  where I.subscription_startdate <= US.subscription_enddate
--                  AND (I.subscription_enddate IS NULL OR I.subscription_enddate >= US.subscription_startdate)
                                where I.email_address = US.email_address
                   AND ((I.subscription_startdate >= US.subscription_startdate AND I.subscription_startdate <= US.subscription_enddate)  OR (I.subscription_enddate >= US.subscription_startdate AND I.subscription_enddate <= US.subscription_enddate))

--                      SELECT *
--                      FROM table1,table2
--                      WHERE table2.start <= table1.end
--                        AND (table2.end IS NULL OR table2.end >= table1.start)


--                      SELECT 'Subscription'
--                      FROM User_Subscription AS US
--                      inner join inserted AS I on US.email_address = I.email_address
--                      WHERE I.subscription_startdate >= US.subscription_startdate
--                        AND ISNULL(I.subscription_enddate, DATEADD(year, 100, US.subscription_enddate)) <= ISNULL(US.subscription_enddate, DATEADD(year, 100, I.subscription_enddate))


-- --                  (
--                 SELECT 'Subscription'
--                 FROM inserted AS I
--                 WHERE EXISTS
--                     (
--                         SELECT 'Subscription'
--                         FROM User_Subscription AS US
--                         where I.subscription_startdate <= US.subscription_enddate
--                           AND (I.subscription_enddate IS NULL OR I.subscription_enddate >= US.subscription_startdate)
--                     )
            )
            THROW 50002, 'Inserted subscription falls in to an excisting subscription period.', 1;


            insert into User_Subscription
        values (@email_address, @country_name, @subscription_type, @subscription_type_name, @startDate, @endDate, @monthly_fee);

        PRINT 'Success';
    END TRY
    BEGIN CATCH
        PRINT 'In catch block';
        THROW; -- Using TROW handles ROLLBACK and bubbles up the thrown error.
    END CATCH;
END;
PRINT 'Success1';

GO

--  --------------------------------------------------------
--  Demo data
--  --------------------------------------------------------

CREATE PROCEDURE SP_InsertDemoData
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [User]
    VALUES ('test@test.nl',
            'The Netherlands',
            'Test user',
            'Delete',
            'this user',
            'M',
            NULL);
    INSERT INTO User_Subscription
    VALUES ('test@test.nl',
            'The Netherlands',
            'Basic',
            'Basic',
            '2017-03-01',
            '2018-03-01',
            3.00);
    INSERT INTO User_Subscription
    VALUES ('test@test.nl',
            'The Netherlands',
            'Basic',
            'Basic',
            '2018-05-01',
            '2019-05-01',
            3.00);
    INSERT INTO User_Subscription
    VALUES ('test@test.nl',
            'The Netherlands',
            'Basic',
            'Basic',
            '2019-06-01',
            NULL,
            3.00);
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
GO
select *
from [User]
GO
select *
from [User_Subscription];
GO
INSERT INTO User_Subscription
VALUES ('test@test.nl',
        'The Netherlands',
        'Basic',
        'Basic',
        DATEADD(day, -1, '2017-03-01'),
        DATEADD(day, -1, '2018-03-01'),
        3.00);
select *
from [User_Subscription];
GO
ROLLBACK TRANSACTION;

-- Scenario 02:
--    [XXXXX]
-- [XXXXX]
-- The startDate of the inserted subscription overlaps an endDate of an other subscription;
-- Result: Throw Error
BEGIN TRANSACTION;
EXEC SP_InsertDemoData;
INSERT INTO User_Subscription
VALUES (CONVERT(VARCHAR(255), SESSION_CONTEXT(N'email_address')),
        'The Netherlands',
        'Basic',
        'Basic',
        DATEADD(day, 1, '2017-03-01'),
        DATEADD(day, 1, '2018-03-01'),
        3.00);
ROLLBACK TRANSACTION;

-- Scenario 03:
--  [XXX]
-- [XXXXXX]
-- Result: Throw Error
BEGIN TRANSACTION;
EXEC SP_InsertDemoData;
select * from [User_Subscription];
INSERT INTO User_Subscription
VALUES ('test@test.nl',
        'The Netherlands',
        'Basic',
        'Basic',
        DATEADD(day, 1, '2017-03-01'),
        DATEADD(day, -1, '2018-03-01'),
        3.00);
ROLLBACK TRANSACTION;

-- Scenario 04:
-- [XXXXXX]
--  [XXX]
-- Result: Throw Error
BEGIN TRANSACTION;
EXEC SP_InsertDemoData;
INSERT INTO User_Subscription
VALUES (CONVERT(VARCHAR(255), SESSION_CONTEXT(N'email_address')),
        'The Netherlands',
        'Basic',
        'Basic',
        DATEADD(day, -1, '2017-03-01'),
        DATEADD(day, 1, '2018-03-01'),
        3.00);
ROLLBACK TRANSACTION;

-- Scenario 05:
--        [XXXX]
-- [XXXX]        [XXXX]
-- Result: Throw Error
BEGIN TRANSACTION;
EXEC SP_InsertDemoData;
INSERT INTO User_Subscription
VALUES (CONVERT(VARCHAR(255), SESSION_CONTEXT(N'email_address')),
        'The Netherlands',
        'Basic',
        'Basic',
        DATEADD(day, 1, '2017-03-01'),
        DATEADD(day, -1, CONVERT(DATE, SESSION_CONTEXT(N'startDate02'))),
        3.00);
ROLLBACK TRANSACTION;

-- Scenario 06:
-- [XXXX]
-- [XXXX]
-- Result: Throw Error
BEGIN TRANSACTION;
EXEC SP_InsertDemoData;
INSERT INTO User_Subscription
VALUES (CONVERT(VARCHAR(255), SESSION_CONTEXT(N'email_address')),
        'The Netherlands',
        'Basic',
        'Basic',
        DATEADD(day, 0, '2017-03-01'),
        DATEADD(day, 0, '2017-03-01'),
        3.00);
ROLLBACK TRANSACTION;

-- Scenario 07:
--       [XXXX]
-- [XXXX ---> geen einde
-- Result: Throw Error
BEGIN TRANSACTION;
EXEC SP_InsertDemoData;
INSERT INTO User_Subscription
VALUES (CONVERT(VARCHAR(255), SESSION_CONTEXT(N'email_address')),
        'The Netherlands',
        'Basic',
        'Basic',
        DATEADD(day, 14, CONVERT(DATE, SESSION_CONTEXT(N'startDate03'))),
        DATEADD(day, 34, CONVERT(DATE, SESSION_CONTEXT(N'startDate03'))),
        3.00);
ROLLBACK TRANSACTION;

-- Scenario 08:
--       [XXXX]
-- [XXXX] 
-- Result: Success
BEGIN TRANSACTION;
EXEC SP_InsertDemoData;
DELETE
FROM User_Subscription
WHERE subscription_startdate = CONVERT(DATE, SESSION_CONTEXT(N'startDate03'))
  AND subscription_enddate IS NULL;
INSERT INTO User_Subscription
VALUES (CONVERT(VARCHAR(255), SESSION_CONTEXT(N'email_address')),
        'The Netherlands',
        'Basic',
        'Basic',
        DATEADD(day, 14, CONVERT(DATE, SESSION_CONTEXT(N'startDate03'))),
        DATEADD(day, 34, CONVERT(DATE, SESSION_CONTEXT(N'startDate03'))),
        3.00);
ROLLBACK TRANSACTION;

--  --------------------------------------------------------
--  Cleanup
--  --------------------------------------------------------
DROP TRIGGER IF EXISTS TR_No_Overlap_In_Subscriptions;
DROP PROCEDURE IF EXISTS SP_InsertDemoData;
GO