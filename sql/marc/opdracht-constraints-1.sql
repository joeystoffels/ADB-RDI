/* 
    Opdracht Constraints
    Implementeer onderstaande constraints. Het kan zijn dat je een aantal al tijdens de casus DDDQ heb geïdentificeerd en/of zelfs al gemaakt. 
	Lever in dat geval die code weer in voor deze casus. Indien je de constraints procedureel oplost, maak je zowel een Stored Procedure als een After Trigger. 
	
	Zorg voor nette error handling in jouw code en schrijf een complete testset voor beide constraint implementaties. 
	Leg uit of de SP of Trigger jouw voorkeur heeft en uiteraard waarom. Als je bij een constraint vindt dat een Instead Of Trigger de betere variant is, 
	maak je die ook en leg je uit waarom dit de beste oplossing is voor deze constraint.

	1) Een film of spel hoort altijd bij minimaal één genre.
*/
/*
  Bij deze eerste Stored Procedure (spProduct_InsertMovie) moet het mogelijk zijn om:

  1) Een foutmelding te gooien wanneer er een movie wordt opgeslagen zonder genres
  2) Een movie op te slaan met 1 genre
  3) Een movie op te slaan met 2 genres

  Voor deze functionaliteit kon geen trigger worden gerealiseerd. In de Product_Genre tabel bevindt
  zich namelijk een foreign key constraint welke verwacht dat er een product in de Product tabel staat.
  Een trigger zou alleen betrekking hebben op de Product tabel, en kan enkel een error gooien wanneer
  er zich geen genre in de Product_Genre tabel zou bevinden. Dit is in principe altijd het geval, behalve
  wanneer er een 'Unknown' genre in de Product_Genre tabel geplaatst zou worden. Dit is echter niet het gewenste
  resultaat. Derhalve wordt er alleen gebruik gemaakt van een stored procedure.
*/

-- Bij het toevoegen van een 'Movie' of 'Game', worden de bijbehorende genres meegegeven als Table Valued Parameter. 
CREATE TYPE GenreTableType AS TABLE (Genre_name GENRE PRIMARY KEY)
GO

-- Vervolgens maken we de Stored Procedure aan welke de Table Valued Parameter meekrijgt.
-- Middels deze Stored Procedure kunnen een movie toevoegen aan de tabel Product.
CREATE
	OR

ALTER PROCEDURE spProduct_InsertMovie (
	@previous_product_id ID
	,@title TITLE
	,@cover_image COVER_IMAGE
	,@description DESCRIPTION
	,@price PRICE
	,@publication_year YEAR
	,@duration DURATION
	,@url URL
	,@GenreTableType GenreTableType READONLY
	)
AS
DECLARE @product_id ID = (
		SELECT MAX(product_id) + 1
		FROM Product
		);

-- Eerst controleren of er wel genres zijn toegevoegd, ander kunnen we direct stoppen
IF (
		(
			SELECT COUNT(*)
			FROM @GenreTableType
			) = 0
		)
BEGIN
	ROLLBACK TRANSACTION;
	THROW 60000,'Toevoegen Product alleen mogelijk indien er minimaal 1 genre middels een @GenreTableType wordt opgegeven!',1;
END;

-- Blijkbaar zijn er genres aanwezig, dus Product toevoegen
INSERT INTO Product (
	product_id
	,product_type
	,previous_product_id
	,title
	,cover_image
	,description
	,movie_default_price
	,publication_year
	,duration
	,url
	)
VALUES (
	@product_id
	,'Movie'
	,@previous_product_id
	,@title
	,@cover_image
	,@description
	,@price
	,@publication_year
	,@duration
	,@url
	)

-- En genres toevoegen
INSERT INTO Product_Genre
SELECT @product_id
	,Genre_name
FROM @GenreTableType
GO

-- Testdata: Movie toevoegen zonder genre, resulteert in foutmelding
BEGIN TRANSACTION

DECLARE @GenreTableType GenreTableType
DECLARE @MovieTitle TITLE = 'Movie - Test zonder genres'

EXEC spProduct_InsertMovie NULL
	,@MovieTitle
	,NULL
	,NULL
	,3.00
	,2019
	,240
	,NULL
	,@GenreTableType

COMMIT TRANSACTION
GO

-- Testdata: Movie toevoegen met één genre
BEGIN TRANSACTION

DECLARE @GenreTableType GenreTableType
DECLARE @MovieTitle TITLE = 'Movie - Test met één genre'

INSERT INTO @GenreTableType
VALUES ('Action')

EXEC spProduct_InsertMovie NULL
	,@MovieTitle
	,NULL
	,NULL
	,3.00
	,2019
	,240
	,NULL
	,@GenreTableType

-- Test om te controleren dat er twee genres zijn toegevoegd
SELECT *
FROM Product p
JOIN Product_Genre pg ON p.product_id = pg.product_id
WHERE p.product_id = (
		SELECT MAX(product_id)
		FROM Product
		)

-- Testdata vervolgens weer opschonen
DELETE
FROM Product_Genre
WHERE Product_Genre.product_id = (
		SELECT product_id
		FROM Product
		WHERE title = @MovieTitle
		)

DELETE
FROM Product
WHERE title = @MovieTitle

COMMIT TRANSACTION
GO

-- Testdata: Movie toevoegen met twee genres
BEGIN TRANSACTION

DECLARE @GenreTableType GenreTableType
DECLARE @MovieTitle TITLE = 'Movie - Test met twee genres'

INSERT INTO @GenreTableType
VALUES ('Action')
	,('Horror')

EXEC spProduct_InsertMovie NULL
	,@MovieTitle
	,NULL
	,NULL
	,3.00
	,2019
	,240
	,NULL
	,@GenreTableType

-- Test om te controleren dat er twee genres zijn toegevoegd
SELECT *
FROM Product p
JOIN Product_Genre pg ON p.product_id = pg.product_id
WHERE p.product_id = (
		SELECT MAX(product_id)
		FROM Product
		)

-- Testdata vervolgens weer opschonen
DELETE
FROM Product_Genre
WHERE Product_Genre.product_id = (
		SELECT product_id
		FROM Product
		WHERE title = @MovieTitle
		)

DELETE
FROM Product
WHERE title = @MovieTitle

COMMIT TRANSACTION
GO

-- Ook maken we de Stored Procedure aan om een game toe te kunnen voegen, deze krijgt ook een Table Valued Parameter mee met de genres.
-- Middels deze Stored Procedure kunnen een game toevoegen aan de tabel Product.
CREATE
	OR

ALTER PROCEDURE spProduct_InsertGame (
	@previous_product_id ID
	,@title TITLE
	,@cover_image COVER_IMAGE
	,@description DESCRIPTION
	,@price PRICE
	,@publication_year YEAR
	,@online_players NUMBER
	,@url URL
	,@GenreTableType GenreTableType READONLY
	)
AS
DECLARE @product_id ID = (
		SELECT MAX(product_id) + 1
		FROM Product
		);

-- Eerst controleren of er wel genres zijn toegevoegd, ander kunnen we direct stoppen
IF (
		(
			SELECT COUNT(*)
			FROM @GenreTableType
			) = 0
		)
BEGIN
	ROLLBACK TRANSACTION;
	THROW 60000, 'Toevoegen Product alleen mogelijk indien er minimaal 1 genre middels een @GenreTableType wordt opgegeven!', 1;
END;

-- Blijkbaar zijn er genres aanwezig, dus Product toevoegen
INSERT INTO Product (
	product_id
	,product_type
	,previous_product_id
	,title
	,cover_image
	,description
	,movie_default_price
	,publication_year
	,number_of_online_players
	,url
	)
VALUES (
	@product_id
	,'Game'
	,@previous_product_id
	,@title
	,@cover_image
	,@description
	,@price
	,@publication_year
	,@online_players
	,@url
	)

-- En genres toevoegen
INSERT INTO Product_Genre
SELECT @product_id
	,Genre_name
FROM @GenreTableType
GO

-- Testdata: Game toevoegen zonder genre, resulteert in foutmelding
BEGIN TRANSACTION

DECLARE @GenreTableType GenreTableType
DECLARE @GameTitle TITLE = 'Game - Test zonder genres'

EXEC spProduct_InsertGame NULL
	,@GameTitle
	,NULL
	,NULL
	,3.00
	,2019
	,16
	,NULL
	,@GenreTableType

COMMIT TRANSACTION
GO

-- Testdata: Game toevoegen met één genre
BEGIN TRANSACTION

DECLARE @GenreTableType GenreTableType
DECLARE @GameTitle TITLE = 'Game - Test met één genre'

INSERT INTO @GenreTableType
VALUES ('Action')

EXEC spProduct_InsertGame NULL
	,@GameTitle
	,NULL
	,NULL
	,3.00
	,2019
	,4
	,NULL
	,@GenreTableType

-- Test om te controleren dat er twee genres zijn toegevoegd
SELECT *
FROM Product p
JOIN Product_Genre pg ON p.product_id = pg.product_id
WHERE p.product_id = (
		SELECT MAX(product_id)
		FROM Product
		)

-- Testdata vervolgens weer opschonen
DELETE
FROM Product_Genre
WHERE Product_Genre.product_id = (
		SELECT product_id
		FROM Product
		WHERE title = @GameTitle
		)

DELETE
FROM Product
WHERE title = @GameTitle

COMMIT TRANSACTION
GO

-- Testdata: Game toevoegen met twee genres
BEGIN TRANSACTION

DECLARE @GenreTableType GenreTableType
DECLARE @GameTitle TITLE = 'Game - Test met twee genres'

INSERT INTO @GenreTableType
VALUES ('Action')
	,('Horror')

EXEC spProduct_InsertGame NULL
	,@GameTitle
	,NULL
	,NULL
	,3.00
	,2019
	,8
	,NULL
	,@GenreTableType

-- Test om te controleren dat er twee genres zijn toegevoegd
SELECT *
FROM Product p
JOIN Product_Genre pg ON p.product_id = pg.product_id
WHERE p.product_id = (
		SELECT MAX(product_id)
		FROM Product
		)

-- Testdata vervolgens weer opschonen
DELETE
FROM Product_Genre
WHERE Product_Genre.product_id = (
		SELECT product_id
		FROM Product
		WHERE title = @GameTitle
		)

DELETE
FROM Product
WHERE title = @GameTitle

COMMIT TRANSACTION
GO

/*
  Middels onderstaande constraint is het mogelijk om:

  1) De ID van een product te wijzigen, waarbij deze ID ook wijzigt in de Product_Genre tabel.
  2) Wanneer een product wordt verwijderd, ook bijbehorende genres worden verwijderd
  3) Wannneer er geen genres meer zijn, ook het prooduct wordt verwijderd (het product kan immers niet bestaan zonder minimaal één genre)
*/

-- Eerst de oude constraint verwijderen omdat deze moet worden aangepast
ALTER TABLE Product_Genre

DROP CONSTRAINT FK_PRODUCT__PRODUCT_G_PRODUCT
GO

-- Nieuwe constraint toevoegen, ditmaal met een ON UPDATE CASCADE en ON DELETE CASCADE
ALTER TABLE Product_Genre ADD CONSTRAINT FK_PRODUCT_ID_IN_PRODUCT FOREIGN KEY (product_id) REFERENCES Product (product_id) 
ON UPDATE CASCADE ON DELETE CASCADE GO