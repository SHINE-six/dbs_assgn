-- Active: 1744989381097@@172.20.10.4@1433@DBS_Ass
-- =============================================
-- Patient Data Security System - Database Setup
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
-- Patient Key Tracking Table
-- ==========================
-- This table keeps track of the asymmetric keys created for each patient
-- Each patient gets their own encryption key for their personal data
DROP TABLE IF EXISTS PatientKeys;
CREATE TABLE PatientKeys (
    PID varchar(6) PRIMARY KEY,
    KeyName varchar(100) NOT NULL,
    CreatedDate datetime DEFAULT GETDATE(),
    LastUpdated datetime DEFAULT GETDATE(),
    FOREIGN KEY (PID) REFERENCES Patient (PID)
)

SELECT * FROM PatientKeys;

ALTER TABLE Patient
ADD PPassportNumber_encrypt varbinary(MAX) NULL,
ADD PaymentCardNumber_encrypt varbinary(MAX) NULL,

-- ==========================
-- Database Roles Setup
-- ==========================
-- Creates role for patients if it doesn't exist
IF NOT EXISTS (
    SELECT * FROM sys.database_principals
    WHERE name = 'Patients' AND type = 'R'
)
BEGIN
    PRINT 'Patients role does not exist. Ask Yi Kai why.';
END