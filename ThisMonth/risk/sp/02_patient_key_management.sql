-- Active: 1744989381097@@172.20.10.4@1433@DBS_Ass
-- =============================================
-- Patient Data Security System - Key Management
-- =============================================

-- =======================================================
-- Procedure: CreatePatientAsymmetricKey
-- =======================================================
-- Creates a patient-specific asymmetric key for encryption
-- Uses the patient ID from the currently executing user 
-- context or an explicitly provided PID.
-- =======================================================
DROP PROCEDURE IF EXISTS CreatePatientAsymmetricKey;
CREATE OR ALTER PROCEDURE CreatePatientAsymmetricKey
    @PID varchar(6) = NULL -- Optional: If NULL, will use SYSTEM_USER (format: PT001)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- If PID not provided, extract from SYSTEM_USER (format expected: 'PT001')
    IF @PID IS NULL
    BEGIN
        SET @PID = SYSTEM_USER;
        -- Check if SYSTEM_USER is a valid patient ID format (assumes PID format is PT001)
        IF SUBSTRING(@PID, 1, 2) != 'PT' OR ISNUMERIC(SUBSTRING(@PID, 3, LEN(@PID)-2)) = 0
        BEGIN
            RAISERROR('Invalid patient ID format in SYSTEM_USER. Expected format: PT001', 16, 1);
            RETURN;
        END;
    END;
    
    DECLARE @KeyName varchar(100) = 'PatientKey_' + @PID;
    DECLARE @SQL nvarchar(MAX);
    DECLARE @Password nvarchar(100) = 'PatientTemp' + @PID + 'Key!';
    
    -- Check if the patient exists
    IF NOT EXISTS (SELECT 1 FROM Patient WHERE PID = @PID)
    BEGIN
        RAISERROR('Patient does not exist.', 16, 1);
        RETURN;
    END;
    
    -- Check if key already exists for this patient
    IF EXISTS (SELECT 1 FROM PatientKeys WHERE PID = @PID)
    BEGIN
        PRINT 'Key already exists for patient ' + @PID;
        RETURN;
    END;
    
    -- Create asymmetric key for the patient
    SET @SQL = N'
    IF NOT EXISTS (SELECT * FROM sys.asymmetric_keys WHERE name = ''' + @KeyName + ''')
    BEGIN
        CREATE ASYMMETRIC KEY ' + @KeyName + ' 
        WITH ALGORITHM = RSA_2048
        ENCRYPTION BY PASSWORD = ''' + @Password + ''';
    END;';
    
    EXEC sp_executesql @SQL;
    
    -- Record the key in our tracking table
    INSERT INTO PatientKeys (PID, KeyName)
    VALUES (@PID, @KeyName);
    
    PRINT 'Asymmetric key created for patient ' + @PID;
END;
GO

-- =======================================================
-- Procedure: GrantPatientDecryptPermission
-- =======================================================
-- Grants a patient permission to decrypt their own data
-- Creates a database user for the patient if it doesn't exist
-- Grants VIEW DEFINITION and CONTROL permissions on their key
-- =======================================================
DROP PROCEDURE IF EXISTS GrantPatientDecryptPermission;
CREATE OR ALTER PROCEDURE GrantPatientDecryptPermission
    @PID varchar(6) = NULL -- Optional: If NULL, will use SYSTEM_USER (format: PT001)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- If PID not provided, extract from SYSTEM_USER
    IF @PID IS NULL
    BEGIN
        SET @PID = USER_NAME();
        -- Check if SYSTEM_USER is a valid patient ID format
        IF SUBSTRING(@PID, 1, 2) != 'PT' OR ISNUMERIC(SUBSTRING(@PID, 3, LEN(@PID)-2)) = 0
        BEGIN
            RAISERROR('Invalid patient ID format in SYSTEM_USER. Expected format: PT001', 16, 1);
            RETURN;
        END;
    END;
    
    DECLARE @KeyName varchar(100);
    DECLARE @SQL nvarchar(MAX);
    DECLARE @PatientUser varchar(100) = @PID; -- User name is now the same as PID
    
    -- Get the key name for this patient
    SELECT @KeyName = KeyName 
    FROM PatientKeys 
    WHERE PID = @PID;
    
    IF @KeyName IS NULL
    BEGIN
        RAISERROR('No key found for this patient.', 16, 1);
        RETURN;
    END;
    
    -- Create database user for the patient if it doesn't exist
    SET @SQL = N'
    IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = ''' + @PatientUser + ''')
    BEGIN
        CREATE USER ' + @PatientUser + ' WITHOUT LOGIN;
        ALTER ROLE Patients ADD MEMBER ' + @PatientUser + ';
    END;';
    
    EXEC sp_executesql @SQL;
    
    -- Grant VIEW DEFINITION permission on the key
    SET @SQL = N'GRANT VIEW DEFINITION ON ASYMMETRIC KEY::' + @KeyName + ' TO ' + @PatientUser + ';';
    EXEC sp_executesql @SQL;
    
    -- Grant CONTROL permission on the key so they can decrypt
    SET @SQL = N'GRANT CONTROL ON ASYMMETRIC KEY::' + @KeyName + ' TO ' + @PatientUser + ';';
    EXEC sp_executesql @SQL;
    
    PRINT 'Decrypt permission granted to patient ' + @PID;
END;
GO

-- =======================================================
-- Procedure: GenerateKeysForExistingPatients
-- =======================================================
-- Creates encryption keys for all patients who don't have one
-- Grants appropriate permissions to each patient
-- Typically run during initial setup or after adding new patients
-- =======================================================
DROP PROCEDURE IF EXISTS GenerateKeysForExistingPatients;
CREATE OR ALTER PROCEDURE GenerateKeysForExistingPatients
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @PID varchar(6);
    
    -- Cursor to iterate through all patients who don't have keys
    DECLARE patient_cursor CURSOR FOR
    SELECT PID FROM Patient WHERE PID NOT IN (SELECT PID FROM PatientKeys);
    
    OPEN patient_cursor;
    FETCH NEXT FROM patient_cursor INTO @PID;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Create key for this patient
        EXEC CreatePatientAsymmetricKey @PID;
        
        -- Grant permissions to this patient
        EXEC GrantPatientDecryptPermission @PID;
        
        FETCH NEXT FROM patient_cursor INTO @PID;
    END;
    
    CLOSE patient_cursor;
    DEALLOCATE patient_cursor;
    
    PRINT 'Keys generated for all existing patients.';
END;
GO