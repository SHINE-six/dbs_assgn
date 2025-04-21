-- filepath: /home/shine/Documents/School/DBS/asgn/src/ThisMonth/risk/04_views_and_permissions.sql
-- Active: 1744989381097@@172.20.10.4@1433@DBS_Ass
-- =============================================
-- Staff Data Security System - Views and Permissions
-- =======================================================
-- View: StaffPersonalDataView
-- =======================================================
-- Secure view that decrypts staff data for authorized users
-- Users can only see their own data when accessed via SYSTEM_USER
-- All sensitive data remains encrypted at the database level
-- =======================================================
DROP VIEW IF EXISTS dbo.StaffPersonalDataView;
CREATE OR ALTER VIEW dbo.StaffPersonalDataView 
AS
SELECT
    s.StaffID,
    s.SName,
    dbo.StaffDecryptData (
        CONVERT(varchar(6), USER_NAME()),
        s.SPassportNumber
    ) AS SPassportNumber,
    s.SPhone,
    s.Position
FROM Staff s
    JOIN StaffKeys pk ON s.StaffID = pk.StaffID
WHERE 
    -- Security predicate: staffs can only see their own data
    s.StaffID = CASE 
        WHEN IS_MEMBER('Doctors') = 1 THEN USER_NAME() -- Staffs see their own data
        WHEN IS_MEMBER('Pharmacists') = 1 THEN USER_NAME() -- Staffs see their own data
        WHEN IS_MEMBER('Nurses') = 1 THEN USER_NAME() -- Staffs see their own data
        WHEN IS_MEMBER('Admins') = 1 THEN s.StaffID -- Admins can see all
        ELSE NULL -- Others see nothing
    END
    OR IS_MEMBER('db_owner') = 1; -- Database owners can see all records
GO

-- =======================================================
-- Permissions
-- =======================================================
-- Grant appropriate permissions to roles

-- Staffs can see their own data in the secure view
GRANT SELECT ON dbo.StaffPersonalDataView TO Doctors;
GRANT SELECT ON dbo.StaffPersonalDataView TO Pharmacists;
GRANT SELECT ON dbo.StaffPersonalDataView TO Nurses;
GRANT SELECT ON dbo.StaffPersonalDataView TO Admins;