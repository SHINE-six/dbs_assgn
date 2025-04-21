-- filepath: /home/shine/Documents/School/DBS/asgn/src/ThisMonth/risk/04_views_and_permissions.sql
-- Active: 1744989381097@@172.20.10.4@1433@DBS_Ass
-- =============================================
-- Patient Data Security System - Views and Permissions
-- =======================================================
-- View: PatientPersonalDataView
-- =======================================================
-- Secure view that decrypts patient data for authorized users
-- Users can only see their own data when accessed via SYSTEM_USER
-- All sensitive data remains encrypted at the database level
-- =======================================================
DROP VIEW IF EXISTS dbo.PatientPersonalDataView;
CREATE OR ALTER VIEW dbo.PatientPersonalDataView 
AS
SELECT
    p.PID,
    p.PName,
    dbo.PatientDecryptData (
        CONVERT(varchar(6), USER_NAME()),
        p.PPassportNumber
    ) AS PPassportNumber,
    p.PPhone,
    dbo.PatientDecryptData (
        CONVERT(varchar(6), USER_NAME()),
        p.PaymentCardNumber
    ) AS PaymentCardNumber,
    p.PaymentCardPinCode
FROM Patient p
    JOIN PatientKeys pk ON p.PID = pk.PID
WHERE 
    -- Security predicate: patients can only see their own data
    p.PID = CASE 
        WHEN IS_MEMBER('Patients') = 1 THEN USER_NAME() -- Patients see their own data
        WHEN IS_MEMBER('Nurses') = 1 THEN p.PID -- Nurses can see all
        WHEN IS_MEMBER('Admins') = 1 THEN p.PID -- Admins can see all
        ELSE NULL -- Others see nothing
    END
    OR IS_MEMBER('db_owner') = 1; -- Database owners can see all records
GO

-- =======================================================
-- Permissions
-- =======================================================
-- Grant appropriate permissions to roles

-- Patients can see their own data in the secure view
GRANT SELECT ON dbo.PatientPersonalDataView TO Patients;
GRANT SELECT ON dbo.PatientPersonalDataView TO Nurses;
GRANT SELECT ON dbo.PatientPersonalDataView TO Admins;
