SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Pratham Choudhary
-- Create date: 05-02-2026
-- =============================================

ALTER TRIGGER  Tri_Insert_Customers
	ON	[sales].[customers]
	AFTER INSERT 
AS 
BEGIN
	SET NOCOUNT ON;
	DECLARE @name varchar(max)
	SET @name = (SELECT first_name from inserted)

	INSERT into Loginfo (Id, Logtext) values(NEWID(), @name + ' Is inserted' + GETDATE())
END

INSERT INTO sales.customers
                  (first_name, last_name, phone, email, street, city, state, zip_code)
VALUES ('Pratham', 'Choudhary', '8076975271', 'cpratham66@gmail.com', 'Posh', 'Noida', 'UP', '20133')

Select * from loginfo