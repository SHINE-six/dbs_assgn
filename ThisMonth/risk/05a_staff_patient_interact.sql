-- filepath: /home/shine/Documents/School/DBS/asgn/src/ThisMonth/risk/interact.sql
-- Active: 1744989381097@@172.20.10.4@1433@DBS_Ass
-- =============================================
-- Staff Data Security System - Test Script
-- =============================================
-- This file contains SQL commands to test and populate the
-- staff data encryption system. It demonstrates:
-- 1. Creating staff-specific encryption keys
-- 2. Encrypting and storing sensitive staff data
-- 3. Testing data access with appropriate user contexts
-- Author: [Your Name]
-- Date: April 21, 2025
-- =============================================

-- =======================================================
-- Step 1: Setup and Initial Data Population
-- =======================================================

-- Generate encryption keys for all staffs
PRINT '===== Generating Staff Encryption Keys =====';
EXEC GenerateKeysForExistingStaffs;

-- Check if keys were created
SELECT TOP 5 * FROM StaffKeys;


PRINT '===== Encrypting Staff Data =====';
UPDATE Staff
SET 
    SPassportNumber_encrypt = dbo.StaffEncryptData(StaffID, SPassportNumber)
WHERE StaffID IN (SELECT StaffID FROM StaffKeys);

ALTER TABLE Staff
DROP COLUMN SPassportNumber;

EXEC sp_rename 'Staff.SPassportNumber_encrypt', 'SPassportNumber', 'COLUMN';

SELECT * FROM Staff;


-- =======================================================
-- Step 2: Test Data Access as Different Users
-- =======================================================

EXECUTE AS USER = 'ST004';
SELECT * FROM dbo.StaffPersonalDataView;
REVERT;

EXECUTE AS USER = 'A001';
-- Try accessing data through the secure view
SELECT * FROM dbo.StaffPersonalDataView;
-- Return to original user
REVERT;
