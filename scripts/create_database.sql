/*
=======
Create DB and Schemas
=======
Purpose:
	This script creates a new DB named 'Warehouse' after checking if it already exists. 
	If it already exists, DB is dropped and recreated. After that three schemas are set up.

CAUTION!
	This script will drop Warehouse DB. All data in the Warehouse DB will be perminantley deleted.
*/


-- DB creation
USE master;

-- Drop and recreate DB in case it already exists 
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Warehouse')
BEGIN
	-- Necessary because a database cannot be droped while it’s being used
	ALTER DATABASE Warehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE Warehouse;
END;

-- Create DB
CREATE DATABASE Warehouse;
USE Warehouse;
GO

-- Create Schemas
CREATE SCHEMA layer1;
GO

CREATE SCHEMA layer2;
GO

CREATE SCHEMA layer3;
GO