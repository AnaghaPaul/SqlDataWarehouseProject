/*
Script Purpose:
This script creates a new database named ' DataWarehouse' after checking if it already exists.
If the database exists, it is dropped and recreated.
Additionally , the scripts sets schemas within the database : 'brown', 'silver', and gold'.

WARNING:
Running this script will drop the entire 'DataWarehouse' database if it exists.
All data in the database will be permanently deleted.
Proceed with caution and ensure you have proper backups before running this script.*/

USE master;

GO

--Delete and recreate the 'DataWarehouse' database 
IF EXISTS (SELECT  1 FROM sys.databases WHERE name='DataWarehouse')
BEGIN
     ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	 DROP DATABASE DataWarehouse;
	 END;

--Create the 'DataWarehouse' database
CREATE DATABASE DataWarehouse;
GO
USE DataWarehouse;
GO

/* We have 3 layers in our datawarehouse structure - Bronze, Silver and Gold. We are going to create 3 schemas for the layers.*/

CREATE SCHEMA bronze;
GO --Seperator
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
