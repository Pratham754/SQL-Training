--SELECT NEWID();  -- generate a random GUID

select * from sysobjects  -- It returns information about database objects in the current database.

select distinct xtype from sysobjects
-- It returns all unique object types present in the current database.
-- xtype is a code that tells what type of database object it is.

select * from sysobjects where xtype = 'U'
-- It returns all user-defined tables in the current database.

-- to diagnois it tools -> SQL Server

select * from sysobjects

select * from sysobjects group by xtype 
-- whatever is coming after group by that should only be there in SELECT statement


select xtype, count(xtype) from sysobjects group by xtype 

select name, xtype, count(xtype) from sysobjects group by xtype, name

select 
	xtype, 
	count(xtype) as CountOfObjects 
from sysobjects 
group by xtype 
order by xtype 
-- where xtype = 'U   -- we cannot use where with group by 

select 
	xtype, 
	count(xtype) as CountOfObjects 
from sysobjects 
group by xtype 
having xtype = 'U'  -- use having instead of where
order by xtype 

select 
	xtype, 
	count(xtype) as CountOfObjects into t1
	-- using INTO is not a good practice
from sysobjects 
group by xtype 
having xtype = 'U'
go
SELECT * from t1
select * from sysobjects

-- Subquery.. to use group by and where together, here g1 is a temporary result working as an alias
SELECT * from
(SELECT 
	xtype, 
	count(xtype) as CountOfObjects 
from sysobjects 
group by xtype) g1 where g1.xtype = 'U'

-- Performing INNER JOIN on 2 queries
SELECT id, name
FROM sysobjects
WHERE xtype = 'U';

SELECT id, colid, name
FROM syscolumns;

SELECT 
    o.name AS TableName,
    c.name AS ColumnName
FROM sysobjects o
INNER JOIN syscolumns c
    ON o.id = c.id
WHERE o.xtype = 'U';

--INNER JOIN Examples

select 
	o.name as TableName,
	c.name as ColumnName,
	o.xtype as ObjectType
From sysobjects o
INNER JOIN syscolumns c
	ON o.id= c.id
where o.xtype= 'U';

-- Working on Adventure Database	
[Person].[Person]
[Person].[Address]

-- UNION
SELECT top 15 * from [Person].[Person]
union
SELECT top 15 * from [Person].[Person] order by BusinessEntityID desc
-- this throws error because it has XML datatype and we cannot perform union on it

SELECT top 15 BusinessEntityID, LastName from [Person].[Person]
union all				-- union all considers duplicates also
SELECT top 15 BusinessEntityID, LastName from [Person].[Person] order by BusinessEntityID desc

SELECT top 1 BusinessEntityID, LastName from [Person].[Person]
union					-- union doesnot consider duplicate values, so only one output will be there instead of 2
SELECT top 1 BusinessEntityID, LastName from [Person].[Person]