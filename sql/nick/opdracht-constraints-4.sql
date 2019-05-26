-- Constraint 4:
-- De datum waarop een film wordt bekeken valt binnen de/een abonnementperiode.

USE odisee

-- Scenario's
--

-- Testscenario's
-- Film valt voor de abonnementperiode
-- Film valt na de abonnementperiode
-- Film valt gelijk aan de startdag van de abonnementperiode.
-- Film valt gelijk aan de einddag van de abonnementperiode.
-- Film valt tussen een abbonementsperiode in

CREATE TRIGGER dbo.Purchase.testTrigger
    ON dbo.Purchase
    AFTER INSERT, UPDATE
    AS
BEGIN
    SET NOCOUNT ON;

    ------- Declare variables
    declare @email nvarchar(4000)

    IF NOT EXISTS (SELECT * FROM inserted) RETURN; -- Speed is everything, nothing to do (for insert,update)? RETURN
    BEGIN TRY

        set @email = (select email_address from inserted)
        /* put your checks here. Make sure they are SET based. Make sure you test every trigger
           with statements with one and more records; mixing valid and invalid records.
           This block usually starts with something like:
        IF EXISTS(...) */
        -- and if something (negative select) is found, throw an error.
        THROW 50001, 'Beautifull error message, readable for users...', 1;
    END TRY
    BEGIN CATCH
        THROW -- Using TROW handles ROLLBACK and bubbles up the thrown error.
        /* If more control is necassary RAISERROR can still be used,
           but Transaction management needs to be taken care of and
           quircks are present. i.e. code after RAISERROR is still executed. */
    END CATCH
END

--
--
-- CREATE PROCEDURE <procedurename>
-- -- Variable list
-- AS
-- -- unless you're very sure you need XACT_ABORT or NOCOUNT OFF, set them ON by default!
-- SET NOCOUNT, XACT_ABORT ON
-- /* Procedure must start its own transaction (if necessary of course).*/
-- --SET TRANSACTION ISOLATION LEVEL ...
-- BEGIN TRANSACTION;
--
-- BEGIN TRY
--     /* Database actions executed here.*/
--
--     /* Get here if no errors. If under Transaction, we must commit the transaction */
--     COMMIT TRANSACTION;
-- END TRY
-- BEGIN CATCH
--     /* An error occurred. If under Transaction, ROLLBACK complete transaction;
--        this includes any outer transactions!
--        Take care with nested Transactions. Another (nested) Transaction could
--        have ROLLBACK-ed our Transaction, hence the XACT_STATE check. */
--     IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
--     THROW;
-- END CATCH
-- GO
