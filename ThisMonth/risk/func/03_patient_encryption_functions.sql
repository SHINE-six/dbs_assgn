-- filepath: /home/shine/Documents/School/DBS/asgn/src/ThisMonth/risk/03_encryption_functions.sql
-- Active: 1744989381097@@172.20.10.4@1433@DBS_Ass
-- =============================================
-- Patient Data Security System - Encryption Functions
-- =======================================================
-- Function: PatientEncryptData
-- =======================================================
-- Encrypts data using a patient-specific asymmetric key
-- Uses the patient ID from SYSTEM_USER if not explicitly provided
-- Has size limitations due to RSA encryption (max ~245 bytes)
-- =======================================================
DROP FUNCTION IF EXISTS dbo.PatientEncryptData;

CREATE OR ALTER FUNCTION dbo.PatientEncryptData(
    @PID varchar(6),
    @data NVARCHAR(MAX)
)
RETURNS VARBINARY(MAX)
AS
BEGIN
    -- RSA encryption has a size limitation (~245 bytes for RSA_2048)
    DECLARE @encryptedData VARBINARY(MAX);
    DECLARE @keyName VARCHAR(100);
    
    -- Get the key name for this patient
    SELECT @keyName = KeyName 
    FROM PatientKeys 
    WHERE PID = @PID;
    
    -- Only encrypt if data is not null, not too long, and key exists
    IF @data IS NOT NULL AND DATALENGTH(@data) <= 245 AND @keyName IS NOT NULL
    BEGIN
        -- Use patient-specific key for encryption
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
-- Function: PatientDecryptData
-- =======================================================
-- Decrypts data using a patient-specific asymmetric key
-- Uses the patient ID from SYSTEM_USER if not explicitly provided
-- Returns meaningful error messages if decryption fails
-- =======================================================
DROP FUNCTION IF EXISTS dbo.PatientDecryptData;

CREATE OR ALTER FUNCTION dbo.PatientDecryptData(
    @PID varchar(6),
    @encryptedData VARBINARY(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @decryptedData NVARCHAR(MAX);
    DECLARE @keyName VARCHAR(100);
    -- Ensure exact same password format as used during key creation
    -- N prefix ensures Unicode string handling is consistent
    DECLARE @password NVARCHAR(100) = N'PatientTemp' + @PID + N'Key!';
    
    -- Get the key name for this patient - DON'T use TRIM as it wasn't used during encryption
    SELECT @keyName = KeyName 
    FROM PatientKeys 
    WHERE PID = @PID;
    
    -- If @keyName is NULL, there's no key for this patient
    IF @keyName IS NULL
        RETURN @encryptedData;

    -- Decrypt the data using the asymmetric key if it exists
    IF @encryptedData IS NOT NULL
    BEGIN
        -- Include the password used during key creation
        SET @decryptedData = CONVERT(NVARCHAR(MAX), DECRYPTBYASYMKEY(ASYMKEY_ID(@keyName), @encryptedData, @password));
        
        -- If decryption fails, return an error message
        IF @decryptedData IS NULL
            RETURN 'ERROR: Decryption failed for patient ' + @PID;
    END
    ELSE
    BEGIN
        RETURN NULL; -- No data to decrypt
    END
    
    RETURN @decryptedData;
END;
GO