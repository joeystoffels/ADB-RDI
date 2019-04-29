ALTER TABLE odisee.dbo.Review

DROP CONSTRAINT CK_category_filled_check
GO

ALTER FUNCTION check_ReviewCategory (
	@category VARCHAR(255)
	,@product_id INT
	,@email_address VARCHAR(255)
	)
RETURNS BIT
AS
BEGIN
	DECLARE @Answer BIT;

	SET @Answer = CASE
			WHEN EXISTS (
					SELECT *
					FROM odisee.dbo.Review_Category AS RC
					WHERE RC.product_id = @product_id
						AND RC.email_address = @email_address
						AND RC.category_name = @category
					)
				THEN 1
			ELSE 0
			END;

	RETURN @Answer;
END
GO

ALTER TABLE odisee.dbo.Review ADD CONSTRAINT CK_category_filled_check CHECK (
	[dbo].[check_ReviewCategory]('Plot', [product_id], [email_address]) = 1
	AND [dbo].[check_ReviewCategory]('Acting', [product_id], [email_address]) = 1
	AND (
		[dbo].[check_ReviewCategory]('Cinematography', [product_id], [email_address]) = 1
		OR [dbo].[check_ReviewCategory]('Music and Sound', [product_id], [email_address]) = 1
		)
	)
GO

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194492
	,'nickhartjes@gmail.com'
	,'Acting'
	,5
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194492
	,'nickhartjes@gmail.com'
	,'Cinematography'
	,6
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194492
	,'nickhartjes@gmail.com'
	,'Plot'
	,7
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194493
	,'nickhartjes@gmail.com'
	,'Acting'
	,4
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194493
	,'nickhartjes@gmail.com'
	,'Cinematography'
	,5
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194493
	,'nickhartjes@gmail.com'
	,'Plot'
	,6
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194494
	,'nickhartjes@gmail.com'
	,'Acting'
	,3
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194494
	,'nickhartjes@gmail.com'
	,'Cinematography'
	,4
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194494
	,'nickhartjes@gmail.com'
	,'Plot'
	,5
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194495
	,'nickhartjes@gmail.com'
	,'Acting'
	,7
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194495
	,'nickhartjes@gmail.com'
	,'Cinematography'
	,8
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194495
	,'nickhartjes@gmail.com'
	,'Plot'
	,9
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194496
	,'nickhartjes@gmail.com'
	,'Acting'
	,8
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194496
	,'nickhartjes@gmail.com'
	,'Cinematography'
	,9
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194496
	,'nickhartjes@gmail.com'
	,'Plot'
	,10
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194497
	,'nickhartjes@gmail.com'
	,'Acting'
	,4
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194497
	,'nickhartjes@gmail.com'
	,'Cinematography'
	,7
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194497
	,'nickhartjes@gmail.com'
	,'Plot'
	,6
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194498
	,'nickhartjes@gmail.com'
	,'Acting'
	,5
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194498
	,'nickhartjes@gmail.com'
	,'Cinematography'
	,7
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194498
	,'nickhartjes@gmail.com'
	,'Plot'
	,4
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194499
	,'nickhartjes@gmail.com'
	,'Acting'
	,4
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194499
	,'nickhartjes@gmail.com'
	,'Cinematography'
	,9
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194499
	,'nickhartjes@gmail.com'
	,'Plot'
	,3
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194500
	,'nickhartjes@gmail.com'
	,'Acting'
	,3
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194500
	,'nickhartjes@gmail.com'
	,'Cinematography'
	,4
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194500
	,'nickhartjes@gmail.com'
	,'Plot'
	,1
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194501
	,'nickhartjes@gmail.com'
	,'Acting'
	,4
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194501
	,'nickhartjes@gmail.com'
	,'Cinematography'
	,4
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194501
	,'nickhartjes@gmail.com'
	,'Plot'
	,3
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194502
	,'nickhartjes@gmail.com'
	,'Acting'
	,3
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194502
	,'nickhartjes@gmail.com'
	,'Cinematography'
	,8
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194502
	,'nickhartjes@gmail.com'
	,'Plot'
	,7
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194503
	,'nickhartjes@gmail.com'
	,'Acting'
	,5
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194503
	,'nickhartjes@gmail.com'
	,'Cinematography'
	,6
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194503
	,'nickhartjes@gmail.com'
	,'Plot'
	,6
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194504
	,'nickhartjes@gmail.com'
	,'Acting'
	,5
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194504
	,'nickhartjes@gmail.com'
	,'Cinematography'
	,5
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194504
	,'nickhartjes@gmail.com'
	,'Plot'
	,5
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194505
	,'nickhartjes@gmail.com'
	,'Acting'
	,7
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194505
	,'nickhartjes@gmail.com'
	,'Cinematography'
	,7
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194505
	,'nickhartjes@gmail.com'
	,'Plot'
	,7
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194506
	,'nickhartjes@gmail.com'
	,'Acting'
	,5
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194506
	,'nickhartjes@gmail.com'
	,'Cinematography'
	,7
	)

INSERT INTO odisee.dbo.Review_Category
VALUES (
	194506
	,'nickhartjes@gmail.com'
	,'Plot'
	,2
	)
GO

SELECT *
FROM odisee.dbo.Review_Category
GO

INSERT INTO odisee.dbo.Review (
	product_id
	,email_address
	,review_date
	,description
	)
VALUES (
	194492
	,'nickhartjes@gmail.com'
	,'2019-04-21'
	,'Text'
	)

INSERT INTO odisee.dbo.Review (
	product_id
	,email_address
	,review_date
	,description
	)
VALUES (
	194493
	,'nickhartjes@gmail.com'
	,'2019-04-22'
	,'Text'
	)

INSERT INTO odisee.dbo.Review (
	product_id
	,email_address
	,review_date
	,description
	)
VALUES (
	194494
	,'nickhartjes@gmail.com'
	,'2019-04-23'
	,'Text'
	)

INSERT INTO odisee.dbo.Review (
	product_id
	,email_address
	,review_date
	,description
	)
VALUES (
	194495
	,'nickhartjes@gmail.com'
	,'2019-04-24'
	,'Text'
	)

INSERT INTO odisee.dbo.Review (
	product_id
	,email_address
	,review_date
	,description
	)
VALUES (
	194496
	,'nickhartjes@gmail.com'
	,'2019-04-25'
	,'Text'
	)

INSERT INTO odisee.dbo.Review (
	product_id
	,email_address
	,review_date
	,description
	)
VALUES (
	194497
	,'nickhartjes@gmail.com'
	,'2019-04-26'
	,'Text'
	)

INSERT INTO odisee.dbo.Review (
	product_id
	,email_address
	,review_date
	,description
	)
VALUES (
	194498
	,'nickhartjes@gmail.com'
	,'2019-04-27'
	,'Text'
	)

INSERT INTO odisee.dbo.Review (
	product_id
	,email_address
	,review_date
	,description
	)
VALUES (
	194499
	,'nickhartjes@gmail.com'
	,'2019-04-28'
	,'Text'
	)

INSERT INTO odisee.dbo.Review (
	product_id
	,email_address
	,review_date
	,description
	)
VALUES (
	194500
	,'nickhartjes@gmail.com'
	,'2019-04-20'
	,'Text'
	)

INSERT INTO odisee.dbo.Review (
	product_id
	,email_address
	,review_date
	,description
	)
VALUES (
	194501
	,'nickhartjes@gmail.com'
	,'2019-04-19'
	,'Text'
	)

INSERT INTO odisee.dbo.Review (
	product_id
	,email_address
	,review_date
	,description
	)
VALUES (
	194502
	,'nickhartjes@gmail.com'
	,'2019-04-18'
	,'Text'
	)

INSERT INTO odisee.dbo.Review (
	product_id
	,email_address
	,review_date
	,description
	)
VALUES (
	194503
	,'nickhartjes@gmail.com'
	,'2019-04-17'
	,'Text'
	)

INSERT INTO odisee.dbo.Review (
	product_id
	,email_address
	,review_date
	,description
	)
VALUES (
	194504
	,'nickhartjes@gmail.com'
	,'2019-04-16'
	,'Text'
	)

INSERT INTO odisee.dbo.Review (
	product_id
	,email_address
	,review_date
	,description
	)
VALUES (
	194505
	,'nickhartjes@gmail.com'
	,'2019-04-15'
	,'Text'
	)

INSERT INTO odisee.dbo.Review (
	product_id
	,email_address
	,review_date
	,description
	)
VALUES (
	194506
	,'nickhartjes@gmail.com'
	,'2019-04-14'
	,'Text'
	)
GO

SELECT *
FROM odisee.dbo.Review
GO

