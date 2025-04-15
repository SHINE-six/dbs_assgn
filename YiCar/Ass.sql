USE DBS_Ass;

--Create Role
CREATE ROLE Doctors;
CREATE ROLE Pharmacists;
CREATE ROLE Patients;
CREATE ROLE Nurses;
CREATE ROLE Admins;


--Create Login
--Doctor
CREATE LOGIN ST001 WITH PASSWORD = 'D1'
CREATE LOGIN ST002 WITH PASSWORD = 'D2'
CREATE LOGIN ST003 WITH PASSWORD = 'D3'

Create User ST001 For Login ST001
Go
Create User ST002 For Login ST002
Go
Create User ST003 For Login ST003
Go

--Nurse
CREATE LOGIN ST004 WITH PASSWORD = 'N4'
CREATE LOGIN ST005 WITH PASSWORD = 'N5'

Create User ST004 For Login ST004
Go
Create User ST005 For Login ST005
Go

--Pharmarcist
CREATE LOGIN ST006 WITH PASSWORD = 'P6'
CREATE LOGIN ST007 WITH PASSWORD = 'P7'

Create User ST006 For Login ST006
Go
Create User ST007 For Login ST007
Go

--Patients
CREATE LOGIN PT001 WITH PASSWORD = 'PT1'
CREATE LOGIN PT002 WITH PASSWORD = 'PT2'
CREATE LOGIN PT003 WITH PASSWORD = 'PT3'

Create User PT001 For Login PT001
Go
Create User PT002 For Login PT002
Go
Create User PT003 For Login PT003
Go

--Admin
CREATE LOGIN A001 WITH PASSWORD = 'A1'
CREATE LOGIN A002 WITH PASSWORD = 'A2'

Create User A001 For Login A001
Go
Create User A002 For Login A002
Go

-- Add user to role
ALTER ROLE Doctors ADD MEMBER ST001
ALTER ROLE Doctors ADD MEMBER ST002
ALTER ROLE Doctors ADD MEMBER ST003

ALTER ROLE Nurses ADD MEMBER ST004
ALTER ROLE Nurses ADD MEMBER ST005

ALTER ROLE Pharmacists ADD MEMBER ST006
ALTER ROLE Pharmacists ADD MEMBER ST007

ALTER ROLE Patients ADD MEMBER PT001
ALTER ROLE Patients ADD MEMBER PT002
ALTER ROLE Patients ADD MEMBER PT003

ALTER ROLE Admins ADD MEMBER A001
ALTER ROLE Admins ADD MEMBER A002

--Test - Create Login but not assign to a role
CREATE LOGIN testingForNoRoleLogin WITH PASSWORD = 'testing'
CREATE USER testingForNoRoleLogin FOR LOGIN testingForNoRoleLogin
GO

--Testing on SQL Server Audit
USE master;
GO

-- Step 1: Create the server audit (writes to a file)
CREATE SERVER AUDIT Audit_PatientActivity
TO FILE (
    FILEPATH = 'C:\SQLAudit\'  -- Make sure this folder exists and SQL Server has write access
)
WITH (ON_FAILURE = CONTINUE);

-- Step 2: Enable the server audit
ALTER SERVER AUDIT Audit_PatientActivity
WITH (STATE = ON);

-- Step 3: Create a database audit specification (track DELETE on Patients table)
USE DBS_Ass;
GO

CREATE DATABASE AUDIT SPECIFICATION Audit_Delete_Patients
FOR SERVER AUDIT Audit_PatientActivity
ADD (DELETE ON dbo.Patient BY Admins)  -- You can specify a role/user instead of PUBLIC
WITH (STATE = ON);

-- Grant select and delete permission to admins
GRANT SELECT,DELETE ON Patient TO Admins

-- Admin accidentally delete one patients
EXECUTE AS USER = 'A001'

DELETE FROM Patient WHERE PID = 'PT015'

REVERT;

-- We can see what happen with below select
SELECT *
FROM sys.fn_get_audit_file('C:\SQLAudit\*.sqlaudit', NULL, NULL);





