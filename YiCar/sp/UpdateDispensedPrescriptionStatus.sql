USE DBS_Ass

-- Pharmacist SP - Update Dispensed Prescription Status
CREATE PROCEDURE dbo.UpdateDispensedPrescriptionStatus
    @PresID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Step 1: Check if the prescription exists
    IF NOT EXISTS (
        SELECT 1 FROM Prescription WHERE PresID = @PresID
    )
    BEGIN
        RAISERROR('Prescription ID not found.', 16, 1);
        RETURN;
    END

    -- Step 2: Check if the status is 'Cancelled'
    IF EXISTS (
        SELECT 1 FROM Prescription WHERE PresID = @PresID AND Status = 'Cancelled'
    )
    BEGIN
        RAISERROR('Cannot update a cancelled or dispensed prescription.', 16, 1);
        RETURN;
    END

    -- Step 3: Check if it's already Dispensed or not 'New'
    IF EXISTS (
        SELECT 1 FROM Prescription WHERE PresID = @PresID AND Status <> 'New'
    )
    BEGIN
        RAISERROR('Only prescriptions with status ''New'' can be updated to ''Dispensed''.', 16, 1);
        RETURN;
    END

    -- Step 4: Perform the update
    UPDATE Prescription
    SET Status = 'Dispensed'
    WHERE PresID = @PresID;
END;

-- Grant Pharmacists to have the permission to use UpdateDispensedPrescriptionStatus
GRANT EXECUTE ON UpdateDispensedPrescriptionStatus TO Pharmacists;

--Test case
EXECUTE AS USER = 'ST006'

EXEC UpdateDispensedPrescriptionStatus
	@PresID = 14;

REVERT;


-----