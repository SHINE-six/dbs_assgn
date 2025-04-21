-- filepath: /home/shine/Documents/School/DBS/asgn/src/ThisMonth/risk/interact.sql
-- Active: 1744989381097@@172.20.10.4@1433@DBS_Ass
-- =============================================
-- Patient Data Security System - Test Script
-- =============================================
-- This file contains SQL commands to test and populate the
-- patient data encryption system. It demonstrates:
-- 1. Creating patient-specific encryption keys
-- 2. Encrypting and storing sensitive patient data
-- 3. Testing data access with appropriate user contexts
-- Author: [Your Name]
-- Date: April 21, 2025
-- =============================================

-- =======================================================
-- Step 1: Setup and Initial Data Population
-- =======================================================

-- Generate encryption keys for all patients
PRINT '===== Generating Patient Encryption Keys =====';
EXEC GenerateKeysForExistingPatients;

-- Check if keys were created
SELECT TOP 5 * FROM PatientKeys;


PRINT '===== Encrypting Patient Data =====';
UPDATE Patient
SET 
    PPassportNumber_encrypt = dbo.PatientEncryptData(PID, PPassportNumber),
    PaymentCardNumber_encrypt = dbo.PatientEncryptData(PID, PaymentCardNumber)
WHERE PID IN (SELECT PID FROM PatientKeys);

ALTER TABLE Patient
DROP COLUMN PPassportNumber, PaymentCardNumber;

EXEC sp_rename 'Patient.PPassportNumber_encrypt', 'PPassportNumber', 'COLUMN';
EXEC sp_rename 'Patient.PaymentCardNumber_encrypt', 'PaymentCardNumber', 'COLUMN';

SELECT * FROM Patient;


-- =======================================================
-- Step 2: Test Data Access as Different Users
-- =======================================================

EXECUTE AS USER = 'ST004';
SELECT * FROM dbo.PatientPersonalDataView;
REVERT;

EXECUTE AS USER = 'A001';
-- Try accessing data through the secure view
SELECT * FROM dbo.PatientPersonalDataView;
-- Return to original user
REVERT;
