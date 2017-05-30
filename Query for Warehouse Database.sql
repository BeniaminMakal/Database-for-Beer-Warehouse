
/* Script to create database*/

USE [master]
GO

CREATE DATABASE [Warehouse.Tests]
GO
USE [Warehouse.Tests]
GO

CREATE TABLE [dbo].[Sale] (
Sale_ID int identity(1,1) NOT NULL,
Employee_ID int NOT NULL,
PartnerName varchar(255) NOT NULL,
Invoice_ID int NOT NULL,
Sale_date datetime,
Operation_status int CHECK (Operation_status = 0 OR Operation_status = 1) DEFAULT (0),
CONSTRAINT PK_Sale PRIMARY KEY CLUSTERED (Sale_ID) 
)
GO

CREATE TABLE [dbo].[InvoiceHeaders] (
Invoice_ID int identity(1,1) NOT NULL,
PartnerID varchar(255) NOT NULL,
Payment varchar(30) NOT NULL,
Discount int,
Date_time datetime,
Invoice_value float NOT NULL
CONSTRAINT PK_Invoice_header PRIMARY KEY CLUSTERED (Invoice_ID))
GO

CREATE TABLE [dbo].[InvoiceItems] (
ID int NOT NULL identity(1,1),
Invoice_ID int NOT NULL,
Product_name varchar(255) NOT NULL,
Unit_price int NOT NULL CHECK (Unit_price>0),
Amount float NOT NULL,
Unit_of_measurement varchar(50) NOT NULL,
Serial_number varchar(255) NOT NULL, 
Bar_code bigint NOT NULL,
CONSTRAINT PK_Invoice_items PRIMARY KEY CLUSTERED (ID))
GO

CREATE TABLE [dbo].[Employees] (
Employee_ID int identity(1,1) NOT NULL, 
Em_LOGIN varchar (50) NOT NULL,
Position varchar(255) NOT NULL,
Em_Name varchar(255) NOT NULL,
Surname varchar(255) NOT NULL
CONSTRAINT PK_Employee PRIMARY KEY CLUSTERED (Employee_ID))
GO


CREATE TABLE [dbo].[Products] (
ProductID varchar(255) NOT NULL UNIQUE,
Product_name varchar(255) NOT NULL UNIQUE,
Brewery varchar(255) NOT NULL, 
Distributor varchar(255),
Price int NOT NULL,
P_type varchar(50) NOT NULL,
Amount int CHECK (Amount>=0),
Unit_of_measurement varchar(50) NOT NULL,
Bar_code bigint UNIQUE NOT NULL,
CONSTRAINT PK_Product PRIMARY KEY CLUSTERED (ProductID))
GO

CREATE TABLE [dbo].[ProductsTypes] (
ProductTypeID varchar(255) NOT NULL,
ProductTypeName varchar(50) NOT NULL UNIQUE,
CONSTRAINT PK_Product_Type PRIMARY KEY CLUSTERED (ProductTypeID))
GO

CREATE TABLE [dbo].[ExpirationDates](
ExpirationDateID int identity (1,1) NOT NULL,
Product_name varchar(255) NOT NULL,
Serial_number varchar(255) NOT NULL,
Expiration_date datetime NOT NULL,
CONSTRAINT PK_Expiration_dates PRIMARY KEY CLUSTERED (ExpirationDateID)
)
GO

CREATE TABLE [dbo].[PartnerTypes](
TypeID int identity(1,1) NOT NULL,
TypeName varchar(255) NOT NULL,
CONSTRAINT PK_TypeID PRIMARY KEY CLUSTERED (TypeID))
GO

CREATE TABLE [dbo].[CustomerTypes] (
CustomerType varchar(50) NOT NULL, 
Discount int CHECK (Discount >= 0) DEFAULT (0)
CONSTRAINT PK_CustomerType PRIMARY KEY CLUSTERED (CustomerType))
GO

CREATE TABLE [dbo].[TradingPartners](
PartnerID varchar(255) NOT NULL,
PartnerName varchar(255) NOT NULL UNIQUE,
NIP varchar(20),
City varchar(255) NOT NULL,
Address varchar (255) NOT NULL,
PostalCode varchar(50) NOT NULL,
Telephone varchar (50) NOT NULL,
Email varchar(255) NOT NULL,
WWW varchar(255),
CustomerType varchar(50),
CONSTRAINT PK_dDistributor PRIMARY KEY CLUSTERED (PartnerID))
GO

CREATE TABLE [dbo].[TradingPartnerType](
TradingPartnerTypeID int identity(1, 1) NOT NULL,
PartnerID varchar(255) NOT NULL,
TypeID int NOT NULL,
CONSTRAINT PK_TradingPartnerTypeID PRIMARY KEY CLUSTERED (TradingPartnerTypeID)
)


/* This part is adding foreign keys */

ALTER TABLE [dbo].[TradingPartnerType] WITH NOCHECK ADD CONSTRAINT [FK_TradingPartnersType] FOREIGN KEY ([PartnerID])
REFERENCES [dbo].[TradingPartners]([PartnerID])
GO

ALTER TABLE [dbo].[TradingPartnerType] WITH NOCHECK ADD CONSTRAINT [FK_Types] FOREIGN KEY ([TypeID])
REFERENCES [dbo].[PartnerTypes]([TypeID])
GO

ALTER TABLE [dbo].[InvoiceItems] WITH NOCHECK ADD CONSTRAINT [FK_Product_bar_code] FOREIGN KEY ([Bar_code])
REFERENCES [dbo].[Products]([Bar_code])
GO

ALTER TABLE [dbo].[ExpirationDates] WITH NOCHECK ADD CONSTRAINT [FK_Product_name] FOREIGN KEY ([Product_name])
REFERENCES [dbo].[Products]([Product_name])
GO

ALTER TABLE [dbo].[Sale]  WITH NOCHECK ADD  CONSTRAINT [FK_Sale_Employee] FOREIGN KEY([Employee_ID])
REFERENCES [dbo].[Employees] ([Employee_ID])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Sale]  WITH NOCHECK ADD  CONSTRAINT [FK_Sale_Invoice_Headers] FOREIGN KEY([Invoice_ID])
REFERENCES [dbo].[InvoiceHeaders] ([Invoice_ID])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Sale]  WITH NOCHECK ADD  CONSTRAINT [FK_Sale_TradingPartner] FOREIGN KEY([PartnerName])
REFERENCES [dbo].[TradingPartners] ([PartnerName])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[InvoiceHeaders]  WITH NOCHECK ADD  CONSTRAINT [FK_Invoice_Headers_Customer] FOREIGN KEY([PartnerID])
REFERENCES [dbo].[TradingPartners] ([PartnerID])
ON DELETE NO ACTION
GO

ALTER TABLE [dbo].[InvoiceItems]  WITH NOCHECK ADD  CONSTRAINT [FK_Invoice_Headers_ID] FOREIGN KEY([Invoice_ID])
REFERENCES [dbo].[InvoiceHeaders] ([Invoice_ID])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[InvoiceItems]  WITH NOCHECK ADD  CONSTRAINT [FK_Invoice_items_ID] FOREIGN KEY([Product_name])
REFERENCES [dbo].[Products] ([Product_name])
GO

ALTER TABLE [dbo].[InvoiceItems]  WITH NOCHECK ADD  CONSTRAINT [FK_Invoice_items_Product_name] FOREIGN KEY([Product_name])
REFERENCES [dbo].[Products] ([Product_name])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Products]  WITH NOCHECK ADD  CONSTRAINT [FK_Products_P_type] FOREIGN KEY([P_type])
REFERENCES [dbo].[ProductsTypes] ([ProductTypeName])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Products]  WITH NOCHECK ADD  CONSTRAINT [FK_Products_Distributor] FOREIGN KEY([Distributor])
REFERENCES [dbo].[TradingPartners] ([PartnerName])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Products]  WITH NOCHECK ADD  CONSTRAINT [FK_Products_Brewery] FOREIGN KEY([Brewery])
REFERENCES [dbo].[TradingPartners] ([PartnerName])
ON DELETE NO ACTION
GO

ALTER TABLE [dbo].[TradingPartners]  WITH NOCHECK ADD  CONSTRAINT [FK_TradingPartnerType] FOREIGN KEY([CustomerType])
REFERENCES [dbo].[CustomerTypes] ([CustomerType])
ON DELETE CASCADE
GO

/*TRIGGERS*/

CREATE TRIGGER TR_GET_DATETIME_SALE ON Sale
AFTER INSERT
AS
UPDATE Sale
SET Sale_date = GETDATE()
WHERE Sale_ID = (SELECT MAX(Sale_ID) FROM Sale);
GO

CREATE TRIGGER TR_GET_DATETIME_INVOICE_H ON Sale
AFTER INSERT
AS
UPDATE InvoiceHeaders
SET Date_time = GETDATE()
WHERE Invoice_ID = (SELECT MAX(Invoice_ID) FROM InvoiceHeaders);
GO


CREATE TRIGGER TR_SET_OPERATION_STATUS ON Sale
AFTER INSERT
AS
UPDATE Sale
SET Operation_Status = 1
WHERE Sale_ID = (SELECT MAX(Sale_ID) FROM Sale);
GO


/*Creating logins, users and grant them roles */
IF NOT EXISTS (SELECT name FROM sys.sql_logins WHERE name = 'cashier1')
BEGIN 
CREATE LOGIN cashier1 WITH PASSWORD = 'cashier1'
END
CREATE USER cashier1 FOR LOGIN cashier1
GO

IF NOT EXISTS (SELECT name FROM sys.sql_logins WHERE name = 'cashier2')
BEGIN 
CREATE LOGIN cashier2 WITH PASSWORD = 'cashier2'
END
CREATE USER cashier2 FOR LOGIN cashier2
GO

IF NOT EXISTS (SELECT name FROM sys.sql_logins WHERE name = 'cashier3')
BEGIN 
CREATE LOGIN cashier3 WITH PASSWORD = 'cashier3'
END
CREATE USER cashier3 FOR LOGIN cashier3
GO

IF NOT EXISTS (SELECT name FROM sys.sql_logins WHERE name = 'cashier4')
BEGIN 
CREATE LOGIN cashier4 WITH PASSWORD = 'cashier4'
END
CREATE USER cashier4 FOR LOGIN cashier4
GO

IF NOT EXISTS (SELECT name FROM sys.sql_logins WHERE name = 'cashier5')
BEGIN 
CREATE LOGIN cashier5 WITH PASSWORD = 'cashier5'
END
CREATE USER cashier5 FOR LOGIN cashier5
GO

IF NOT EXISTS (SELECT name FROM sys.sql_logins WHERE name = 'cashier6')
BEGIN 
CREATE LOGIN cashier6 WITH PASSWORD = 'cashier6'
END
CREATE USER cashier6 FOR LOGIN cashier6
GO

IF NOT EXISTS (SELECT name FROM sys.sql_logins WHERE name = 'cashier7')
BEGIN 
CREATE LOGIN cashier7 WITH PASSWORD = 'cashier7'
END
CREATE USER cashier7 FOR LOGIN cashier7
GO

IF NOT EXISTS (SELECT name FROM sys.sql_logins WHERE name = 'warehouseman1')
BEGIN 
CREATE LOGIN warehouseman1 WITH PASSWORD = 'warehouseman1'
END
CREATE USER warehouseman1 FOR LOGIN warehouseman1
GO

IF NOT EXISTS (SELECT name FROM sys.sql_logins WHERE name = 'warehouseman2')
BEGIN 
CREATE LOGIN warehouseman2 WITH PASSWORD = 'warehouseman2'
END
CREATE USER warehouseman2 FOR LOGIN warehouseman2
GO

IF NOT EXISTS (SELECT name FROM sys.sql_logins WHERE name = 'boss')
BEGIN 
CREATE LOGIN boss WITH PASSWORD = 'boss'
END
CREATE USER boss FOR LOGIN boss
GO

IF NOT EXISTS (SELECT name FROM sys.sql_logins WHERE name = 'w_admin')
BEGIN 
CREATE LOGIN w_admin WITH PASSWORD = 'admin'
END
CREATE USER w_admin FOR LOGIN w_admin
GO

ALTER ROLE db_datawriter ADD MEMBER cashier1
GO 
ALTER ROLE db_datareader ADD MEMBER cashier1
GO

ALTER ROLE db_datawriter ADD MEMBER cashier2
GO 
ALTER ROLE db_datareader ADD MEMBER cashier2
GO

ALTER ROLE db_datawriter ADD MEMBER cashier3
GO 
ALTER ROLE db_datareader ADD MEMBER cashier3
GO

ALTER ROLE db_datawriter ADD MEMBER cashier4
GO 
ALTER ROLE db_datareader ADD MEMBER cashier4
GO

ALTER ROLE db_datawriter ADD MEMBER cashier5
GO 
ALTER ROLE db_datareader ADD MEMBER cashier5
GO

ALTER ROLE db_datawriter ADD MEMBER cashier6
GO 
ALTER ROLE db_datareader ADD MEMBER cashier6
GO

ALTER ROLE db_datawriter ADD MEMBER cashier7
GO
ALTER ROLE db_datareader ADD MEMBER cashier7
GO 

ALTER ROLE db_datawriter ADD MEMBER warehouseman1
GO 
ALTER ROLE db_datareader ADD MEMBER warehouseman1
GO

ALTER ROLE db_datawriter ADD MEMBER warehouseman2
GO 
ALTER ROLE db_datareader ADD MEMBER warehouseman2
GO

ALTER ROLE db_datawriter ADD MEMBER boss
GO 
ALTER ROLE db_datareader ADD MEMBER boss
GO
ALTER ROLE db_securityadmin ADD MEMBER boss
GO
ALTER ROLE db_accessadmin ADD MEMBER boss
GO

ALTER ROLE db_datawriter ADD MEMBER w_admin
GO 
ALTER ROLE db_datareader ADD MEMBER w_admin
GO
ALTER ROLE db_securityadmin ADD MEMBER w_admin
GO
ALTER ROLE db_accessadmin ADD MEMBER w_admin
GO
ALTER ROLE db_backupoperator ADD MEMBER w_admin
GO
ALTER ROLE db_ddladmin ADD MEMBER w_admin
GO
ALTER ROLE db_owner ADD MEMBER w_admin


/*Example content for database*/

INSERT INTO CustomerTypes (CustomerType, Discount)
VALUES ('DETAL', 0)

INSERT INTO CustomerTypes (CustomerType, Discount)
VALUES ('HURT', 5)

INSERT INTO CustomerTypes (CustomerType, Discount)
VALUES ('VIP', 10)

INSERT INTO TradingPartners (PartnerID, PartnerName, City, Address, PostalCode, Telephone, Email, WWW)
VALUES ('cefb2832-58a7-4e51-848e-16b91e8f67d1', 'We love beer', 'Sosnowiec', 'ul. Zielona 2', '15-232', '123456789', 'we_love_beer@beer.pl', 'www.welovebeer.pl')

INSERT INTO TradingPartners (PartnerID, PartnerName, City, Address, PostalCode, Telephone, Email, WWW)
VALUES ('493d6b52-345e-47c0-9161-3703c965d43a', 'Beer masters', 'Wroc³aw', 'ul. Czerwona 99', '50-531', '321654987', 'beer_masters@beer.pl', 'www.beermasters.pl')

INSERT INTO TradingPartners (PartnerID, PartnerName, City, Address, PostalCode, Telephone, Email, WWW)
VALUES ('a8b94340-b14b-4541-8d5a-c93544c3048b', 'Darkest beers', 'Kraków', 'ul. Niebieska 745', '15-232', '741852963', 'darkest_beers@beer.pl', 'www.darkestbeers.pl')

INSERT INTO TradingPartners (PartnerID, PartnerName, City, Address, PostalCode, Telephone, Email, WWW)
VALUES ('c11006d7-9052-415b-9a30-decc5a897cbe', 'Hops', 'Wroc³aw', 'ul. Ciemna 12', '50-634', '123654897', 'hops@beer.pl', 'www.hops.pl')

INSERT INTO TradingPartners (PartnerID, PartnerName, City, Address, PostalCode, Telephone, Email, WWW)
VALUES ('2a540d48-6d4b-4dc3-a234-63ecce4e6767', 'For The Sun', 'Kostom³oty', 'ul. Sucha 2', '80-532', '365854795', 'For_The_Sun@beer.pl', 'www.forthesun.pl')

INSERT INTO TradingPartners (PartnerID, PartnerName, City, Address, PostalCode, Telephone, Email, WWW)
VALUES ('737c3851-603e-46dc-a7e9-de4828d7808a', 'Green_Hops', 'Ko³o', 'ul. Mokra 64', '70-564', '123654897', 'green_hops@beer.pl', 'www.greenhops.pl')

INSERT INTO TradingPartners (PartnerID, PartnerName, NIP, City, Address, PostalCode, Telephone, Email, WWW, CustomerType)
VALUES ('a3206530-8bae-42ec-98e7-d0065436b244', 'GRAF', '8992683494', 'Wroc³aw', 'ul. Gajowa 22', '50-289', '745896523', 'graf@beer.com', 'www.graf.com', 'VIP')

INSERT INTO TradingPartners (PartnerID, PartnerName, NIP, City, Address, PostalCode, Telephone, Email, WWW, CustomerType)
VALUES ('29ec05f8-5f2d-4913-ad41-7cb59f1747ad', 'Semafor', '8997849878', 'Oleœnica', 'ul. Cebulowa 16', '40-239', '741852965', 'semafor@beer.com', 'www.semafor.com', 'HURT')

INSERT INTO TradingPartners (PartnerID, PartnerName, NIP, City, Address, PostalCode, Telephone, Email, WWW, CustomerType)
VALUES ('b7d8d658-f2d2-43be-a9b8-53dc1b855b93', 'Ma³pka', '8889652121', 'Wroc³aw', 'ul. Hutnicza 2', '50-001', '854125652', 'malpka@beer.com', 'www.malpka.com', 'HURT')

INSERT INTO TradingPartners (PartnerID, PartnerName, NIP, City, Address, PostalCode, Telephone, Email, WWW, CustomerType)
VALUES ('abf5f831-8db1-4f6a-9fe3-ed081682abcc', 'Kropka', '6527896598', 'Wroc³aw', 'ul. Wiejska 74', '50-031', '745985125', 'kropka@beer.com', 'www.kropka.com', 'VIP')

INSERT INTO Employees (Position, Em_LOGIN, Em_Name, Surname)
VALUES ('cashier', 'cashier1', 'John', 'Walker')

INSERT INTO Employees (Position, Em_LOGIN, Em_Name, Surname)
VALUES ('cashier', 'cashier2', 'Juan', 'Moore')

INSERT INTO Employees (Position, Em_LOGIN, Em_Name, Surname)
VALUES ('cashier', 'cashier3', 'Richard', 'Perez')

INSERT INTO Employees (Position, Em_LOGIN, Em_Name, Surname)
VALUES ('cashier', 'cashier4', 'Dennis', 'Wood')

INSERT INTO Employees (Position, Em_LOGIN, Em_Name, Surname)
VALUES ('cashier', 'cashier5', 'Paul', 'Collins')

INSERT INTO Employees (Position, Em_LOGIN, Em_Name, Surname)
VALUES ('cashier', 'cashier6', 'Christopher', 'Edwards')

INSERT INTO Employees (Position, Em_LOGIN, Em_Name, Surname)
VALUES ('cashier', 'cashier7', 'Jason', 'Stewart')

INSERT INTO Employees (Position, Em_LOGIN, Em_Name, Surname)
VALUES ('warehouseman', 'warehouseman1', 'Jeremy', 'Mitchell')

INSERT INTO Employees (Position, Em_LOGIN, Em_Name, Surname)
VALUES ('warehouseman', 'warehouseman2', 'David', 'Scott')

INSERT INTO Employees (Position, Em_LOGIN, Em_Name, Surname)
VALUES ('boss', 'boss', 'Peter', 'Anderson')

INSERT INTO ProductsTypes (ProductTypeID, ProductTypeName)
VALUES ('d9ce5acd-ae5c-4a2c-b3a9-b7dafad1115a', 'Lager')

INSERT INTO ProductsTypes (ProductTypeID, ProductTypeName)
VALUES ('809b4385-df4c-4f94-9889-ea26a995804c','Porter')

INSERT INTO ProductsTypes (ProductTypeID, ProductTypeName)
VALUES ('07c6a482-515f-4773-8295-ddd7dd557059','Wheat beer')

INSERT INTO ProductsTypes (ProductTypeID, ProductTypeName)
VALUES ('5c6dd9fb-b081-4613-bee3-a54416975f21', 'Stout')

INSERT INTO ProductsTypes (ProductTypeID, ProductTypeName)
VALUES ('e4493fcf-137e-41cd-a315-47db0aaf2564', 'RIS')

INSERT INTO Products (ProductID, Product_name, Brewery, Price, P_type, Amount, Unit_of_measurement, Bar_code)
VALUES ('eec777a8-4c4c-45b7-8312-789a0c8bb536', 'Kazimierskie', 'For The Sun', 9, 'Lager', 100020, '0.5l', 8905415667485)

INSERT INTO Products (ProductID, Product_name, Brewery, Price, P_type, Amount, Unit_of_measurement, Bar_code)
VALUES ('35ee1fab-7bea-463a-9b70-2c8e5602cba1', 'Wroc³awskie', 'For The Sun', 12, 'Porter', 4340, '0.5l', 8596451245557)

INSERT INTO Products (ProductID, Product_name, Brewery, Distributor, Price, P_type, Amount, Unit_of_measurement, Bar_code)
VALUES ('e66fea51-53ad-446d-bbe1-ead3d016c586', 'Hip-Hops', 'Hops', 'We love beer', 10, 'Wheat beer', 7890, '0.5l', 8594006931755)

INSERT INTO Products (ProductID, Product_name, Brewery, Distributor, Price, P_type, Amount, Unit_of_measurement, Bar_code)
VALUES ('f529747e-ad44-42d6-bb32-c47cd34da42b', 'Dark Hoops', 'Hops', 'We love beer', 9, 'Porter', 5000, '0.5l', 8905697841256)

INSERT INTO Products (ProductID, Product_name, Brewery, Distributor, Price, P_type, Amount, Unit_of_measurement, Bar_code)
VALUES ('f10f24c7-29ce-46c0-890e-62c78b7e1e7d', 'Black Leaf', 'Green_Hops', 'Beer masters', 22, 'RIS', 3900, '0.3l', 8707689458741)

INSERT INTO Products (ProductID, Product_name, Brewery, Distributor, Price, P_type, Amount, Unit_of_measurement, Bar_code)
VALUES ('e742bf9d-a6ff-45c4-8fc3-5b5c32460b62', 'Coin', 'Green_Hops', 'Beer masters', 11, 'Stout', 6920, '0.5l', 8905694581245)

INSERT INTO ExpirationDates (Product_name, Serial_number, Expiration_date)
VALUES ('Kazimierskie', '2016/08/12/T23', '2017-05-02 11:11:11')

INSERT INTO ExpirationDates (Product_name, Serial_number, Expiration_date)
VALUES ( 'Wroc³awskie', '2016/11/21/T43', '2017-10-12 20:11:11')

INSERT INTO ExpirationDates (Product_name, Serial_number, Expiration_date)
VALUES ( 'Hip-Hops', '2016/12/01/R213', '2017-02-12 19:20:00')

INSERT INTO ExpirationDates (Product_name, Serial_number, Expiration_date)
VALUES ( 'Hip-Hops', '2016/12/02/R214', '2017-02-12 20:20:00')

INSERT INTO ExpirationDates (Product_name, Serial_number, Expiration_date)
VALUES ( 'Hip-Hops', '2016/12/03/R215', '2017-02-12 12:50:01')

INSERT INTO ExpirationDates (Product_name, Serial_number, Expiration_date)
VALUES ( 'Dark Hoops', '2016/10/11/S32', '2017-04-05 07:31:12')

INSERT INTO ExpirationDates (Product_name, Serial_number, Expiration_date)
VALUES ( 'Dark Hoops', '2016/10/12/S33', '2017-04-06 08:10:45')

INSERT INTO ExpirationDates (Product_name, Serial_number, Expiration_date)
VALUES ( 'Black Leaf', '2016/12/12/W31', '2017-06-12 11:11:01')

INSERT INTO ExpirationDates (Product_name, Serial_number, Expiration_date)
VALUES ( 'Coin', '2016/12/12/8213', '2017-07-14 09:43:21')

INSERT INTO ExpirationDates (Product_name, Serial_number, Expiration_date)
VALUES ( 'Coin', '2016/12/13/8214', '2017-07-15 19:13:21')

INSERT INTO InvoiceHeaders (PartnerID, Invoice_value, Payment, Discount, Date_time)
VALUES ('a3206530-8bae-42ec-98e7-d0065436b244', 1100, 'CASH', 10, '2017-02-23 11:11:21')

INSERT INTO InvoiceHeaders (PartnerID, Invoice_value, Payment, Discount, Date_time)
VALUES ('29ec05f8-5f2d-4913-ad41-7cb59f1747ad', 1800, 'CREDIT CARD', 5, '2017-01-01 16:00:22')

INSERT INTO InvoiceHeaders (PartnerID, Invoice_value, Payment, Discount, Date_time)
VALUES ('b7d8d658-f2d2-43be-a9b8-53dc1b855b93', 10000, 'TRANSFER', 5, '2017-01-13 07:57:04')

INSERT INTO InvoiceItems (Product_name, Invoice_ID, Amount, Unit_price, Unit_of_measurement, Serial_number, Bar_code)
VALUES ('Coin', 1, 100, 11, '0.5l', '2016/12/23/P09', 8905694581245)

INSERT INTO InvoiceItems (Product_name, Invoice_ID, Amount, Unit_price, Unit_of_measurement, Serial_number, Bar_code)
VALUES ('Dark Hoops', 2, 200, 9, '0.3l', '2016/12/30/R423', 8905697841256)

INSERT INTO InvoiceItems (Product_name, Invoice_ID, Amount, Unit_price, Unit_of_measurement, Serial_number, Bar_code)
VALUES ('Hip-Hops', 3, 1000, 10, '0.5l', '2017/01/23/G543', 8594006931755)

INSERT INTO SALE (Employee_ID, PartnerName, Invoice_ID, Sale_date)
VALUES (1, 'GRAF', 1, '2017-02-23 11:11:21')

INSERT INTO SALE (Employee_ID, PartnerName, Invoice_ID, Sale_date)
VALUES (2, 'Semafor', 2, '2017-01-01 16:00:22')

INSERT INTO SALE (Employee_ID, PartnerName, Invoice_ID, Sale_date)
VALUES (3, 'Ma³pka', 3, '2017-01-13 07:57:04')

INSERT INTO PartnerTypes (TypeName)
VALUES ('Brewery')

INSERT INTO PartnerTypes (TypeName)
VALUES ('Distributor')

INSERT INTO PartnerTypes (TypeName)
VALUES ('Customer')

INSERT INTO TradingPartnerType (PartnerID, TypeID)
VALUES ('cefb2832-58a7-4e51-848e-16b91e8f67d1', 2)

INSERT INTO TradingPartnerType (PartnerID, TypeID)
VALUES ('493d6b52-345e-47c0-9161-3703c965d43a', 2)

INSERT INTO TradingPartnerType (PartnerID, TypeID)
VALUES ('a8b94340-b14b-4541-8d5a-c93544c3048b', 1)

INSERT INTO TradingPartnerType (PartnerID, TypeID)
VALUES ('c11006d7-9052-415b-9a30-decc5a897cbe', 1)

INSERT INTO TradingPartnerType (PartnerID, TypeID)
VALUES ('2a540d48-6d4b-4dc3-a234-63ecce4e6767', 1)

INSERT INTO TradingPartnerType (PartnerID, TypeID)
VALUES ('737c3851-603e-46dc-a7e9-de4828d7808a', 1)

INSERT INTO TradingPartnerType (PartnerID, TypeID)
VALUES ('a3206530-8bae-42ec-98e7-d0065436b244', 3)

INSERT INTO TradingPartnerType (PartnerID, TypeID)
VALUES ('29ec05f8-5f2d-4913-ad41-7cb59f1747ad', 3)

INSERT INTO TradingPartnerType (PartnerID, TypeID)
VALUES ('b7d8d658-f2d2-43be-a9b8-53dc1b855b93', 3)

INSERT INTO TradingPartnerType (PartnerID, TypeID)
VALUES ('abf5f831-8db1-4f6a-9fe3-ed081682abcc', 3)
