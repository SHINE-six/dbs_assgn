use DBS_Ass

use master

Select * From Patient
Select * From Staff
Select * from Appointment
Select * From Prescription
Select * From PrescriptionMedicine
Select * From Medicine

SELECT name, type_desc, is_disabled, create_date
FROM sys.server_principals
WHERE type IN ('S', 'U') -- S = SQL Login, U = Windows Login
ORDER BY name;

SELECT name, type_desc, authentication_type_desc
FROM sys.database_principals
WHERE type IN ('S', 'U', 'G') AND name NOT LIKE 'dbo'
ORDER BY name;

SELECT dp.name AS DatabaseUser, sp.name AS ServerLogin
FROM sys.database_principals dp
JOIN sys.server_principals sp ON dp.sid = sp.sid
WHERE dp.type IN ('S', 'U') -- SQL/Windows users
ORDER BY dp.name;

SELECT roles.[name] as role_name, members.[name] as user_name
FROM sys.database_role_members 
INNER JOIN sys.database_principals roles 
ON database_role_members.role_principal_id = roles.principal_id
INNER JOIN sys.database_principals members 
ON database_role_members.member_principal_id = members.principal_id
WHERE roles.name = 'Admins'

SELECT m.name AS UserName, r.name AS RoleName
FROM sys.database_role_members drm
JOIN sys.database_principals r ON drm.role_principal_id = r.principal_id
JOIN sys.database_principals m ON drm.member_principal_id = m.principal_id
WHERE m.name LIKE 'ST%' OR m.name LIKE 'PT%';

SELECT r.name AS RoleName
FROM sys.server_role_members m
JOIN sys.server_principals r ON m.role_principal_id = r.principal_id
JOIN sys.server_principals p ON m.member_principal_id = p.principal_id
WHERE r.name = 'sysadmin' AND p.name = 'Admins';


SELECT SERVERPROPERTY('Edition') AS Edition, SERVERPROPERTY('ProductVersion') AS Version;


--Testing on SQL Server Audit
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
