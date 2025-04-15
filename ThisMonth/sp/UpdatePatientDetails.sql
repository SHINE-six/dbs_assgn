DROP PROCEDURE IF EXISTS dbo.UpdatePatientDetails;

-- Procedure for patients to update their own details
CREATE PROCEDURE dbo.UpdatePatientDetails
    @PName varchar(100) = NULL,
    @PPhone varchar(20) = NULL,
    @PaymentCardNumber varchar(20) = NULL,
    @PaymentCardPinCode varchar(20) = NULL
AS
BEGIN
    DECLARE @CurrentPatientID varchar(6);
    
    -- Get the current logged-in user's PatientID
    -- Assuming the database login name matches the PatientID
    SET @CurrentPatientID = SYSTEM_USER;
    
    -- Verify the user exists in the Patient table
    IF NOT EXISTS (SELECT 1 FROM Patient WHERE PID = @CurrentPatientID)
    BEGIN
        RAISERROR('Current user is not a valid patient.', 16, 1);
        RETURN;
    END

    -- Update only non-NULL fields
    UPDATE Patient
    SET 
        PName = ISNULL(@PName, PName),
        PPhone = ISNULL(@PPhone, PPhone),
        PaymentCardNumber = ISNULL(@PaymentCardNumber, PaymentCardNumber),
        PaymentCardPinCode = ISNULL(@PaymentCardPinCode, PaymentCardPinCode)
    WHERE PID = @CurrentPatientID;

    -- Return updated record
    SELECT * FROM Patient WHERE PID = @CurrentPatientID;
END;
GO

-- Grant permissions to roles
GRANT EXECUTE ON dbo.UpdatePatientDetails TO Patients;


-- Test the procedure
EXECUTE AS USER = 'PT001';
EXEC dbo.UpdatePatientDetails 
    @PName = 'Alice Williams', 
    @PPhone = '+1-555-111-2222', 
    @PaymentCardNumber = NULL, 
    @PaymentCardPinCode = NULL;
REVERT;