SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ================================================
-- Author:        Pratham Choudhary
-- Create date:   06-02-2004
-- Description:   Stored Procedure demonstrating
--                local and global temporary tables
-- ================================================
CREATE PROCEDURE dbo.CreateTemporaryTable
AS
BEGIN
    SET NOCOUNT ON;

    -- Global temporary table (shared across sessions)
    IF OBJECT_ID('tempdb..##TempGlobal') IS NOT NULL
        DROP TABLE ##TempGlobal;

    SELECT TOP 5 *
    INTO ##TempGlobal
    FROM Person.Address;

    -- Local temporary table (session-specific)
    SELECT TOP 5 *
    INTO #TempLocal
    FROM Person.Address;

    -- View global temp table data
    SELECT * FROM ##TempGlobal;

    -- DELETE allows rollback
    DELETE FROM #TempLocal;

    -- DROP removes the table permanently (cannot rollback)
    DROP TABLE #TempLocal;

    -- XML output example
    SELECT uu.FirstName
    FROM Person.Person uu
    FOR XML AUTO;
END
GO