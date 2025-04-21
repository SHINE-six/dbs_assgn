-- Active: 1744989381097@@172.20.10.4@1433@DBS_Ass
-- =============================================
-- Staff Data Security System - Key Management
-- =============================================

-- =======================================================
-- Procedure: CreateStaffAsymmetricKey
-- =======================================================
-- Creates a staff-specific asymmetric key for encryption
-- Uses the staff ID from the currently executing user 
-- context or an explicitly provided StaffID.
-- =======================================================
DROP PROCEDURE IF EXISTS CreateStaffAsymmetricKey;
CREATE OR ALTER PROCEDURE CreateStaffAsymmetricKey
    @StaffID varchar(6) = NULL -- Optional: If NULL, will use SYSTEM_USER (format: PT001)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- If StaffID not provided, extract from SYSTEM_USER (format expected: 'PT001')
    IF @StaffID IS NULL
    BEGIN
        SET @StaffID = SYSTEM_USER;
        -- Check if SYSTEM_USER is a valid staff ID format (assumes StaffID format is PT001)
        IF SUBSTRING(@StaffID, 1, 2) != 'ST' OR ISNUMERIC(SUBSTRING(@StaffID, 3, LEN(@StaffID)-2)) = 0
        BEGIN
            RAISERROR('Invalid staff ID format in SYSTEM_USER. Expected format: ST001', 16, 1);
            RETURN;
        END;
    END;
    
    DECLARE @KeyName varchar(100) = 'StaffKey_' + @StaffID;
    DECLARE @SQL nvarchar(MAX);
    DECLARE @Password nvarchar(100) = 'StaffTemp' + @StaffID + 'Key!';
    
    -- Check if the staff exists
    IF NOT EXISTS (SELECT 1 FROM Staff WHERE StaffID = @StaffID)
    BEGIN
        RAISERROR('Staff does not exist.', 16, 1);
        RETURN;
    END;
    
    -- Check if key already exists for this staff
    IF EXISTS (SELECT 1 FROM StaffKeys WHERE StaffID = @StaffID)
    BEGIN
        PRINT 'Key already exists for staff ' + @StaffID;
        RETURN;
    END;
    
    -- Create asymmetric key for the staff
    SET @SQL = N'
    IF NOT EXISTS (SELECT * FROM sys.asymmetric_keys WHERE name = ''' + @KeyName + ''')
    BEGIN
        CREATE ASYMMETRIC KEY ' + @KeyName + ' 
        WITH ALGORITHM = RSA_2048
        ENCRYPTION BY PASSWORD = ''' + @Password + ''';
    END;';
    
    EXEC sp_executesql @SQL;
    
    -- Record the key in our tracking table
    INSERT INTO StaffKeys (StaffID, KeyName)
    VALUES (@StaffID, @KeyName);
    
    PRINT 'Asymmetric key created for staff ' + @StaffID;
END;
GO

-- =======================================================
-- Procedure: GrantStaffDecryptPermission
-- =======================================================
-- Grants a staff permission to decrypt their own data
-- Creates a database user for the staff if it doesn't exist
-- Grants VIEW DEFINITION and CONTROL permissions on their key
-- =======================================================
DROP PROCEDURE IF EXISTS GrantStaffDecryptPermission;
CREATE OR ALTER PROCEDURE GrantStaffDecryptPermission
    @StaffID varchar(6) = NULL -- Optional: If NULL, will use SYSTEM_USER (format: PT001)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- If StaffID not provided, extract from SYSTEM_USER
    IF @StaffID IS NULL
    BEGIN
        SET @StaffID = SYSTEM_USER;
        -- Check if SYSTEM_USER is a valid staff ID format
        IF SUBSTRING(@StaffID, 1, 2) != 'ST' OR ISNUMERIC(SUBSTRING(@StaffID, 3, LEN(@StaffID)-2)) = 0
        BEGIN
            RAISERROR('Invalid staff ID format in SYSTEM_USER. Expected format: ST001', 16, 1);
            RETURN;
        END;
    END;
    
    DECLARE @KeyName varchar(100);
    DECLARE @SQL nvarchar(MAX);
    DECLARE @StaffUser varchar(100) = @StaffID; -- User name is now the same as StaffID
    
    -- Get the key name for this staff
    SELECT @KeyName = KeyName 
    FROM StaffKeys 
    WHERE StaffID = @StaffID;
    
    IF @KeyName IS NULL
    BEGIN
        RAISERROR('No key found for this staff.', 16, 1);
        RETURN;
    END;
    
    -- Grant VIEW DEFINITION permission on the key
    SET @SQL = N'GRANT VIEW DEFINITION ON ASYMMETRIC KEY::' + @KeyName + ' TO ' + @StaffUser + ';';
    EXEC sp_executesql @SQL;
    
    -- Grant CONTROL permission on the key so they can decrypt
    SET @SQL = N'GRANT CONTROL ON ASYMMETRIC KEY::' + @KeyName + ' TO ' + @StaffUser + ';';
    EXEC sp_executesql @SQL;
    
    PRINT 'Decrypt permission granted to staff ' + @StaffID;
END;
GO

-- =======================================================
-- Procedure: GenerateKeysForExistingStaffs
-- =======================================================
-- Creates encryption keys for all staffs who don't have one
-- Grants appropriate permissions to each staff
-- Typically run during initial setup or after adding new staffs
-- =======================================================
DROP PROCEDURE IF EXISTS GenerateKeysForExistingStaffs;
CREATE OR ALTER PROCEDURE GenerateKeysForExistingStaffs
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StaffID varchar(6);
    
    -- Cursor to iterate through all staffs who don't have keys
    DECLARE staff_cursor CURSOR FOR
    SELECT StaffID FROM Staff WHERE StaffID NOT IN (SELECT StaffID FROM StaffKeys);
    
    OPEN staff_cursor;
    FETCH NEXT FROM staff_cursor INTO @StaffID;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Create key for this staff
        EXEC CreateStaffAsymmetricKey @StaffID;
        
        -- Grant permissions to this staff
        EXEC GrantStaffDecryptPermission @StaffID;
        
        FETCH NEXT FROM staff_cursor INTO @StaffID;
    END;
    
    CLOSE staff_cursor;
    DEALLOCATE staff_cursor;
    
    PRINT 'Keys generated for all existing staffs.';
END;
GO