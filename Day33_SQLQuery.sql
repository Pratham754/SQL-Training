GO

DROP TABLE IF EXISTS dbo.Product_Practice;
SELECT TOP (5000)
	ProductID,
	Name,
	ProductNumber,
	Color,
	ListPrice,
	ModifiedDate
INTO dbo.Product_Practice
FROM Production.Product
ORDER BY ProductID;

-- Create Clustered Index
CREATE CLUSTERED INDEX CX_Product_Practice_ProductID
ON dbo.Product_Practice(ProductID);

-- Verify indexes
SELECT i.index_id, i.name, i.type_desc
FROM sys.indexes i
WHERE i.object_id = OBJECT_ID('dbo.Product_Practice');

SELECT COUNT(i.index_id) FROM sys.indexes i