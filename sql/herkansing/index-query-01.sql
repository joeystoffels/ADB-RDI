USE ODISEE;
GO
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO
DECLARE @MovieInReeks INT= 207989;
WITH moviereeks
     AS (SELECT product_id, 
                title, 
                previous_product_id, 
                publication_year
         FROM product
         WHERE product_id = @MovieInReeks
         UNION
         SELECT product_id, 
                title, 
                previous_product_id, 
                publication_year
         FROM product
         WHERE previous_product_id = @MovieInReeks
         UNION ALL
         SELECT P.product_id, 
                P.title, 
                P.previous_product_id, 
                P.publication_year
         FROM product P
              JOIN moviereeks M ON P.product_id = M.previous_product_id)
     SELECT product_id AS ITEM_ID, 
            title AS TITLE, 
            ROW_NUMBER() OVER(
            ORDER BY publication_year) AS Volgnummer
     FROM moviereeks
     GROUP BY product_id, 
              title, 
              publication_year;
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

--  SQL Server Execution Times:
--    CPU time = 0 ms,  elapsed time = 0 ms.
-- SQL Server parse and compile time:
--    CPU time = 0 ms, elapsed time = 0 ms.
--
--  SQL Server Execution Times:
--    CPU time = 0 ms,  elapsed time = 0 ms.
--
-- (3 rows affected)
-- Table 'Worktable'. Scan count 2, logical reads 29, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Product'. Scan count 1, logical reads 3366, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--
-- (1 row affected)
--
--  SQL Server Execution Times:
--    CPU time = 65 ms,  elapsed time = 64 ms.


-- Drop constraints

ALTER TABLE [dbo].[Review] DROP CONSTRAINT [FK_REVIEW_PRODUCT_O_PRODUCT];
GO
ALTER TABLE [dbo].[Purchase] DROP CONSTRAINT [FK_PURCHASE_PRODUCT_O_PRODUCT];
GO
ALTER TABLE [dbo].[Product_Genre] DROP CONSTRAINT [FK_PRODUCT__PRODUCT_G_PRODUCT];
GO
ALTER TABLE [dbo].[Product] DROP CONSTRAINT [FK_PRODUCT_PREVIOUS__PRODUCT];
GO
ALTER TABLE [dbo].[Movie_Director] DROP CONSTRAINT [FK_MOVIE_DI_DIRECTS_PRODUCT];
GO
ALTER TABLE [dbo].[Default_Game_Price] DROP CONSTRAINT [FK_DEFAULT__GAMEDEFAU_PRODUCT];
GO
ALTER TABLE [dbo].[Cast] DROP CONSTRAINT [FK_CAST_CAST_OF_M_PRODUCT]
GO

-- Finally we can delete PK_PRODUCT
ALTER TABLE Product DROP CONSTRAINT PK_PRODUCT;
GO

-- So we can add a clustered PK
ALTER TABLE Product
ADD CONSTRAINT PK_PRODUCT PRIMARY KEY CLUSTERED(product_id);

ALTER TABLE [dbo].[Review]
WITH CHECK
ADD CONSTRAINT [FK_REVIEW_PRODUCT_O_PRODUCT] FOREIGN KEY([product_id]) REFERENCES [dbo].[Product]([product_id]);
GO

ALTER TABLE [dbo].[Purchase]
WITH CHECK
ADD CONSTRAINT [FK_PURCHASE_PRODUCT_O_PRODUCT] FOREIGN KEY([product_id]) REFERENCES [dbo].[Product]([product_id]);
GO

ALTER TABLE [dbo].[Product_Genre]
WITH CHECK
ADD CONSTRAINT [FK_PRODUCT__PRODUCT_G_PRODUCT] FOREIGN KEY([product_id]) REFERENCES [dbo].[Product]([product_id]);
GO

ALTER TABLE [dbo].[Product]
WITH CHECK
ADD CONSTRAINT [FK_PRODUCT_PREVIOUS__PRODUCT] FOREIGN KEY([previous_product_id]) REFERENCES [dbo].[Product]([product_id]);
GO

ALTER TABLE [dbo].[Movie_Director]
WITH CHECK
ADD CONSTRAINT [FK_MOVIE_DI_DIRECTS_PRODUCT] FOREIGN KEY([product_id]) REFERENCES [dbo].[Product]([product_id]);
GO


ALTER TABLE [dbo].[Default_Game_Price]
WITH CHECK
ADD CONSTRAINT [FK_DEFAULT__GAMEDEFAU_PRODUCT] FOREIGN KEY([product_id]) REFERENCES [dbo].[Product]([product_id]);
GO

ALTER TABLE [dbo].[Cast]  WITH CHECK ADD  CONSTRAINT [FK_CAST_CAST_OF_M_PRODUCT] FOREIGN KEY([product_id])
REFERENCES [dbo].[Product] ([product_id])
GO

--  --------------------------------------------------------
--  Create index
--  --------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_Product_productid_title ON Product
(product_id
) INCLUDE(title, previous_product_id, publication_year);

--  --------------------------------------------------------
--  Remove index
--  --------------------------------------------------------
DROP INDEX IX_Product_productid_title ON Product;