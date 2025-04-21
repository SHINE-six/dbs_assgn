-- filepath: /home/shine/Documents/School/DBS/asgn/src/ThisMonth/risk/03_encryption_functions.sql
-- Active: 1744989381097@@172.20.10.4@1433@DBS_Ass
-- =============================================
-- Staff Data Security System - Encryption Functions
-- =======================================================
-- Function: StaffEncryptData
-- =======================================================
-- Encrypts data using a staff-specific asymmetric key
-- Uses the staff ID from SYSTEM_USER if not explicitly provided
-- Has size limitations due to RSA encryption (max ~245 bytes)
-- =======================================================
DROP FUNCTION IF EXISTS dbo.StaffEncryptData;

CREATE OR ALTER FUNCTION dbo.StaffEncryptData(
    @StaffID varchar(6),
    @data NVARCHAR(MAX)
)
RETURNS VARBINARY(MAX)
AS
BEGIN
    -- RSA encryption has a size limitation (~245 bytes for RSA_2048)
    DECLARE @encryptedData VARBINARY(MAX);
    DECLARE @keyName VARCHAR(100);
    
    -- Get the key name for this staff
    SELECT @keyName = KeyName 
    FROM StaffKeys 
    WHERE StaffID = @StaffID;
    
    -- Only encrypt if data is not null, not too long, and key exists
    IF @data IS NOT NULL AND DATALENGTH(@data) <= 245 AND @keyName IS NOT NULL
    BEGIN
        -- Use staff-specific key for encryption
        SET @encryptedData = ENCRYPTBYASYMKEY(ASYMKEY_ID(@keyName), CONVERT(NVARCHAR(100), @data));
    END
    ELSE
    BEGIN
        -- Return NULL for invalid data or missing key
        SET @encryptedData = NULL;
    END
    
    RETURN @encryptedData;
END;
GO

-- =======================================================
-- Function: StaffDecryptData
-- =======================================================
-- Decrypts data using a staff-specific asymmetric key
-- Uses the staff ID from SYSTEM_USER if not explicitly provided
-- Returns meaningful error messages if decryption fails
-- =======================================================
DROP FUNCTION IF EXISTS dbo.StaffDecryptData;

CREATE OR ALTER FUNCTION dbo.StaffDecryptData(
    @StaffID varchar(6),
    @encryptedData VARBINARY(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @decryptedData NVARCHAR(MAX);
    DECLARE @keyName VARCHAR(100);
    -- Ensure exact same password format as used during key creation
    -- N prefix ensures Unicode string handling is consistent
    DECLARE @password NVARCHAR(100) = N'StaffTemp' + @StaffID + N'Key!';
    
    -- Get the key name for this staff - DON'T use TRIM as it wasn't used during encryption
    SELECT @keyName = KeyName 
    FROM StaffKeys 
    WHERE StaffID = @StaffID;
    
    -- If @keyName is NULL, there's no key for this staff
    IF @keyName IS NULL
        RETURN @encryptedData;

    -- Decrypt the data using the asymmetric key if it exists
    IF @encryptedData IS NOT NULL
    BEGIN
        -- Include the password used during key creation
        SET @decryptedData = CONVERT(NVARCHAR(MAX), DECRYPTBYASYMKEY(ASYMKEY_ID(@keyName), @encryptedData, @password));
        
        -- If decryption fails, return an error message
        IF @decryptedData IS NULL
            RETURN 'ERROR: Decryption failed for staff ' + @StaffID;
    END
    ELSE
    BEGIN
        RETURN NULL; -- No data to decrypt
    END
    
    RETURN @decryptedData;
END;
GO