--------------------------------------------------
---- Implement Hashing Patient Payment Card on PPhone ----
--------------------------------------------------

-- Test Case -- Before Implementation (Showing PaymenTCardPinCode is visible)

SELECT PID, PName, PaymentCardNumber, PaymentCardPinCode FROM Patient

-----------------------------------------------------------------------------------------------

-- Add a new column for hashed PINs
ALTER TABLE Patient
ADD HashedPinCode VARBINARY(64);  -- SHA-512 produces 64-byte hashes

-- Hash existing PINs using SHA-512
UPDATE Patient
SET HashedPinCode = HASHBYTES('SHA2_512', PaymentCardPinCode);

-- Remove plaintext PINs
ALTER TABLE Patient
DROP COLUMN PaymentCardPinCode;
EXEC sp_rename 'Patient.HashedPinCode', 'PaymentCardPinCode', 'COLUMN';

------------------------------------------------------------------------

-- Test Case -- 
SELECT PID, PaymentCardPinCode FROM Patient;
