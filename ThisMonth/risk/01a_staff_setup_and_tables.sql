-- Active: 1744989381097@@172.20.10.4@1433@DBS_Ass
-- =============================================
-- Staff Data Security System - Database Setup
-- =============================================
-- Master Key Configuration
-- ==========================
-- Creates the database master key which is used to protect other keys and certificates
IF EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
    DROP MASTER KEY;
IF NOT EXISTS (
    SELECT * FROM sys.symmetric_keys
    WHERE name = '##MS_DatabaseMasterKey##'
)
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'StrongDbMasterKeyPassword456!'
    PRINT 'Database Master Key created successfully.'
END
ELSE
BEGIN
    PRINT 'Database Master Key already exists.'
END;

-- ==========================
-- Staff Key Tracking Table
-- ==========================
-- This table keeps track of the asymmetric keys created for each staff member
-- Each staff member gets their own encryption key for their personal data
DROP TABLE IF EXISTS StaffKeys;
CREATE TABLE StaffKeys (
    StaffID varchar(6) PRIMARY KEY,
    KeyName varchar(100) NOT NULL,
    CreatedDate datetime DEFAULT GETDATE(),
    LastUpdated datetime DEFAULT GETDATE(),
    FOREIGN KEY (StaffID) REFERENCES Staff (StaffID)
)

SELECT * FROM StaffKeys;

ALTER TABLE Staff
ADD SPassportNumber_encrypt varbinary(MAX) NULL