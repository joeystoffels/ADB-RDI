/*
 VERSIE 2
 Statement dat per land de percentages en totalen geeft over een jaar in kolommen.
 */

DECLARE @StartDate DATE = '20180501'
DECLARE @EndDate DATE = '20190501'

SELECT country_name AS CountryName
	,[january] AS January
	,[february] AS February
	,[march] AS March
	,[april] AS April
	,[may] AS May
	,[june] AS June
	,[july] AS July
	,[august] AS August
	,[september] AS September
	,[october] AS October
	,[november] AS November
	,[december] AS December
	,(
		SELECT Count(purchase_date)
		FROM purchase
		INNER JOIN [user] u ON purchase.email_address = u.email_address
		WHERE pivotresult.country_name = u.country_name
		) AS TotalItems
FROM (
	SELECT u1.country_name
		,Datename(month, p1.purchase_date) AS month
		,CONCAT (
			CONVERT(DECIMAL(4, 2), (
					100 / (
						SELECT CONVERT(DECIMAL(4, 2), Count(*))
						FROM purchase p3
						INNER JOIN [user] u3 ON p3.email_address = u3.email_address
						WHERE u1.country_name = u3.country_name
						GROUP BY u3.country_name
						) * (
						SELECT Count(*)
						FROM purchase p2
						INNER JOIN [user] u2 ON p2.email_address = u2.email_address
						WHERE Datename(month, p2.purchase_date) = Datename(month, p1.purchase_date)
							AND u2.country_name = u1.country_name
						)
					))
			,'%'
			) AS percentage
	FROM purchase p1
	INNER JOIN [user] u1 ON p1.email_address = u1.email_address
	WHERE p1.purchase_date BETWEEN @StartDate
			AND @EndDate
	GROUP BY u1.country_name
		,Datename(month, p1.purchase_date)
	) AS PivotData
PIVOT(Max(percentage) FOR pivotdata.month IN (
			[January]
			,[February]
			,[March]
			,[April]
			,[May]
			,[June]
			,[July]
			,[August]
			,[September]
			,[October]
			,[November]
			,[December]
			)) AS PivotResult