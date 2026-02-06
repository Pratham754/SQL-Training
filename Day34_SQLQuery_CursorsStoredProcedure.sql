/* =========================================================
   Inventory Management Demo  Single SQL File
   Author: Pratham Choudhary
   Date  : 05-02-2026
   ========================================================= */

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* =========================================================
   1. DROP & CREATE TABLES
   ========================================================= */

IF OBJECT_ID('dbo.Products', 'U') IS NOT NULL
    DROP TABLE dbo.Products;
GO

CREATE TABLE dbo.Products
(
    ProductId   INT IDENTITY(1,1) PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Category    VARCHAR(50) NOT NULL,
    Price       DECIMAL(10,2) NOT NULL CHECK (Price > 0),
    StockQty    INT NOT NULL CHECK (StockQty >= 0),
    IsActive    BIT NOT NULL DEFAULT 1,
    CreatedAt   DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

IF OBJECT_ID('dbo.ReorderLog', 'U') IS NOT NULL
    DROP TABLE dbo.ReorderLog;
GO

CREATE TABLE dbo.ReorderLog
(
    LogId     INT IDENTITY(1,1) PRIMARY KEY,
    ProductId INT NOT NULL,
    Message   VARCHAR(200) NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

IF OBJECT_ID('dbo.PriceChangeLog', 'U') IS NOT NULL
    DROP TABLE dbo.PriceChangeLog;
GO

CREATE TABLE dbo.PriceChangeLog
(
    LogId     INT IDENTITY(1,1) PRIMARY KEY,
    ProductId INT NOT NULL,
    OldPrice  DECIMAL(10,2) NOT NULL,
    NewPrice  DECIMAL(10,2) NOT NULL,
    ChangedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

/* =========================================================
   2. INSERT SAMPLE DATA
   ========================================================= */

INSERT INTO dbo.Products (ProductName, Category, Price, StockQty)
VALUES
('Wireless Mouse', 'Electronics', 799.00, 50),
('Mechanical Keyboard', 'Electronics', 2499.00, 25),
('Running Shoes', 'Fashion', 1899.00, 40),
('Water Bottle', 'Fitness', 399.00, 120),
('Laptop Backpack', 'Accessories', 1499.00, 35),
('USB-C Cable', 'Electronics', 299.00, 15),
('Gym Gloves', 'Fitness', 499.00, 28);
GO

/* =========================================================
   3. STORED PROCEDURE  PRINT ALL PRODUCTS (CURSOR DEMO)
   ========================================================= */

CREATE OR ALTER PROCEDURE dbo.PrintAllProducts
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @ProductId INT,
        @ProductName VARCHAR(100),
        @Price DECIMAL(10,2);

    DECLARE curProducts CURSOR FAST_FORWARD
    FOR
        SELECT ProductId, ProductName, Price
        FROM dbo.Products
        ORDER BY ProductId;

    OPEN curProducts;
    FETCH NEXT FROM curProducts INTO @ProductId, @ProductName, @Price;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT 'ProductId=' + CAST(@ProductId AS VARCHAR(10))
            + ' | Name=' + @ProductName
            + ' | Price=' + CAST(@Price AS VARCHAR(20));

        FETCH NEXT FROM curProducts INTO @ProductId, @ProductName, @Price;
    END

    CLOSE curProducts;
    DEALLOCATE curProducts;
END;
GO

/* =========================================================
   4. STORED PROCEDURE  LOG LOW STOCK PRODUCTS
   ========================================================= */

CREATE OR ALTER PROCEDURE dbo.LogLowStockProducts
(
    @ReorderLevel INT = 30
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @ProductId INT,
        @ProductName VARCHAR(100),
        @StockQty INT;

    TRUNCATE TABLE dbo.ReorderLog;

    DECLARE curLowStock CURSOR FAST_FORWARD
    FOR
        SELECT ProductId, ProductName, StockQty
        FROM dbo.Products
        WHERE StockQty < @ReorderLevel
        ORDER BY StockQty ASC;

    OPEN curLowStock;
    FETCH NEXT FROM curLowStock INTO @ProductId, @ProductName, @StockQty;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO dbo.ReorderLog(ProductId, Message)
        VALUES
        (
            @ProductId,
            'Reorder needed for ' + @ProductName
            + ' (Stock=' + CAST(@StockQty AS VARCHAR(10)) + ')'
        );

        FETCH NEXT FROM curLowStock INTO @ProductId, @ProductName, @StockQty;
    END

    CLOSE curLowStock;
    DEALLOCATE curLowStock;
END;
GO

/* =========================================================
   5. STORED PROCEDURE UPDATE FASHION PRICES WITH LOGGING
   ========================================================= */

CREATE OR ALTER PROCEDURE dbo.UpdateFashionPrices
(
    @IncreasePercent DECIMAL(5,2) = 5
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @ProductId INT,
        @OldPrice DECIMAL(10,2),
        @NewPrice DECIMAL(10,2);

    DECLARE curFashion CURSOR FAST_FORWARD
    FOR
        SELECT ProductId, Price
        FROM dbo.Products
        WHERE Category = 'Fashion';

    BEGIN TRY
        BEGIN TRAN;

        OPEN curFashion;
        FETCH NEXT FROM curFashion INTO @ProductId, @OldPrice;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @NewPrice = ROUND(@OldPrice * (1 + @IncreasePercent / 100), 2);

            UPDATE dbo.Products
            SET Price = @NewPrice
            WHERE ProductId = @ProductId;

            INSERT INTO dbo.PriceChangeLog(ProductId, OldPrice, NewPrice)
            VALUES (@ProductId, @OldPrice, @NewPrice);

            FETCH NEXT FROM curFashion INTO @ProductId, @OldPrice;
        END

        CLOSE curFashion;
        DEALLOCATE curFashion;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF CURSOR_STATUS('global','curFashion') >= -1
        BEGIN
            CLOSE curFashion;
            DEALLOCATE curFashion;
        END

        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

/* =========================================================
   6. SAMPLE EXECUTION 
   ========================================================= */

-- EXEC dbo.PrintAllProducts;
-- EXEC dbo.LogLowStockProducts 30;
-- EXEC dbo.UpdateFashionPrices 5;

-- SELECT * FROM dbo.Products;
-- SELECT * FROM dbo.ReorderLog;
-- SELECT * FROM dbo.PriceChangeLog;