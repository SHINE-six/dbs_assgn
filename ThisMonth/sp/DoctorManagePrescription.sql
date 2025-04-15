-- Doctor Prescription Management Procedure
DROP PROCEDURE IF EXISTS dbo.DoctorManagePrescription;

CREATE PROCEDURE dbo.DoctorManagePrescription
    @PatientID varchar(6) = NULL, -- Required for 'Add'
    @Action varchar(10), -- 'Add' or 'Update'
    @PresID int = NULL,  -- Required for updates, NULL for new prescriptions
    @Status varchar(10) = 'New',  -- Default for new prescriptions
    @MedicineList varchar(500) = NULL  -- Comma-separated list of medicine IDs
AS
BEGIN
    SELECT 'DoctorManagePrescription procedure started.' AS Result;
    -- Declare variables
    DECLARE @CurrentDoctorID varchar(6);
    DECLARE @NewPresID int;
    DECLARE @MedID varchar(10);
    DECLARE @Position int = 1;
    DECLARE @Delimiter varchar(1) = ',';

    -- Get the current logged-in user's StaffID (doctor)
    SET @CurrentDoctorID = SYSTEM_USER;
    
    -- Verify the user exists in the Staff table and is a doctor
    IF NOT EXISTS (SELECT 1 FROM Staff WHERE StaffID = @CurrentDoctorID AND Position = 'Doctor')
    BEGIN
        RAISERROR('Current user is not a valid doctor.', 16, 1);
        RETURN;
    END
    
    -- Add new prescription
    IF @Action = 'Add'
    BEGIN
      -- Check if the patient exists
      IF NOT EXISTS (SELECT 1 FROM Patient WHERE PID = @PatientID)
      BEGIN
          RAISERROR('Patient does not exist.', 16, 1);
          RETURN;
      END
        -- Insert the prescription
        INSERT INTO Prescription (PatientID, DoctorID, PresDateTime, Status)
        VALUES (@PatientID, @CurrentDoctorID, GETDATE(), @Status);
        
        -- Get the newly created prescription ID
        SET @NewPresID = SCOPE_IDENTITY();
        
        -- If medicines are specified, add them to the prescription
        IF @MedicineList IS NOT NULL
        BEGIN
            -- Parse the comma-separated medicine list and insert each medicine
            WHILE @Position > 0
            BEGIN
                -- Find the next delimiter
                SET @Position = CHARINDEX(@Delimiter, @MedicineList);
                
                -- Extract the medicine ID
                IF @Position > 0
                BEGIN
                    SET @MedID = LTRIM(RTRIM(SUBSTRING(@MedicineList, 1, @Position - 1)));
                    SET @MedicineList = SUBSTRING(@MedicineList, @Position + 1, LEN(@MedicineList));
                END
                ELSE
                BEGIN
                    SET @MedID = LTRIM(RTRIM(@MedicineList));
                END
                
                -- Verify the medicine exists
                IF EXISTS (SELECT 1 FROM Medicine WHERE MedID = @MedID)
                BEGIN
                    -- Insert the medicine to the prescription
                    INSERT INTO PrescriptionMedicine (PresID, MedID)
                    VALUES (@NewPresID, @MedID);
                END
                ELSE
                BEGIN
                    -- Delete the prescription that was just created
                    DELETE FROM Prescription WHERE PresID = @NewPresID;
                    RAISERROR('Medicine %s does not exist. Prescription creation aborted.', 16, 1, @MedID);
                    RETURN;
                END
            END
        END
        
        SELECT 'Prescription added successfully. Prescription ID: ' + CAST(@NewPresID AS varchar) AS Result;
    END
    
    -- Update existing prescription
    ELSE IF @Action = 'Update'
    BEGIN
        -- Check if the prescription exists
        IF NOT EXISTS (SELECT 1 FROM Prescription WHERE PresID = @PresID)
        BEGIN
            RAISERROR('Prescription does not exist.', 16, 1);
            RETURN;
        END
        
        -- Check if the prescription belongs to the current doctor
        IF NOT EXISTS (SELECT 1 FROM Prescription WHERE PresID = @PresID AND DoctorID = @CurrentDoctorID)
        BEGIN
            RAISERROR('You can only update prescriptions that you created.', 16, 1);
            RETURN;
        END
        
        -- Update the prescription status
        UPDATE Prescription
        SET Status = @Status
        WHERE PresID = @PresID;
        
        -- If new medicines are specified, replace the existing medicines
        IF @MedicineList IS NOT NULL
        BEGIN
            -- First validate that all medicines exist before making any changes
            DECLARE @TempMedicineList varchar(500) = @MedicineList;
            DECLARE @TempPosition int = 1;
            DECLARE @TempMedID varchar(10);
            
            WHILE @TempPosition > 0
            BEGIN
                -- Find the next delimiter
                SET @TempPosition = CHARINDEX(@Delimiter, @TempMedicineList);
                
                -- Extract the medicine ID
                IF @TempPosition > 0
                BEGIN
                    SET @TempMedID = LTRIM(RTRIM(SUBSTRING(@TempMedicineList, 1, @TempPosition - 1)));
                    SET @TempMedicineList = SUBSTRING(@TempMedicineList, @TempPosition + 1, LEN(@TempMedicineList));
                END
                ELSE
                BEGIN
                    SET @TempMedID = LTRIM(RTRIM(@TempMedicineList));
                END
                
                -- Verify the medicine exists
                IF NOT EXISTS (SELECT 1 FROM Medicine WHERE MedID = @TempMedID)
                BEGIN
                    RAISERROR('Medicine %s does not exist. Prescription update aborted.', 16, 1, @TempMedID);
                    RETURN;
                END
            END
            
            -- Delete existing medicines for this prescription
            DELETE FROM PrescriptionMedicine WHERE PresID = @PresID;
            
            -- Parse the comma-separated medicine list and insert each medicine
            WHILE @Position > 0
            BEGIN
                -- Find the next delimiter
                SET @Position = CHARINDEX(@Delimiter, @MedicineList);
                
                -- Extract the medicine ID
                IF @Position > 0
                BEGIN
                    SET @MedID = LTRIM(RTRIM(SUBSTRING(@MedicineList, 1, @Position - 1)));
                    SET @MedicineList = SUBSTRING(@MedicineList, @Position + 1, LEN(@MedicineList));
                END
                ELSE
                BEGIN
                    SET @MedID = LTRIM(RTRIM(@MedicineList));
                END
                
                -- Insert the medicine to the prescription (no need to check again)
                INSERT INTO PrescriptionMedicine (PresID, MedID)
                VALUES (@PresID, @MedID);
            END
        END
        
        SELECT 'Prescription updated successfully.' AS Result;
    END
    
    ELSE
    BEGIN
        RAISERROR('Invalid action. Use ''Add'' or ''Update''.', 16, 1);
        RETURN;
    END
END;
GO

-- Grant execute permission to Doctors role
GRANT EXECUTE ON dbo.DoctorManagePrescription TO Doctors;

-- Example usage:
-- Add a new prescription
EXECUTE AS USER = 'ST001';
EXEC dbo.DoctorManagePrescription 
    @PatientID = 'PT001',
    @Action = 'Add',
    @MedicineList = 'MED001,MED002,MED010';
REVERT;

-- Fail test of adding a new prescription
EXECUTE AS USER = 'ST002';
EXEC dbo.DoctorManagePrescription 
    @PatientID = 'PT002',
    @Action = 'Add',
    @MedicineList = 'MED001,MED099,MED010';
REVERT;

-- Update an existing prescription
EXECUTE AS USER = 'ST003';
EXEC dbo.DoctorManagePrescription 
    @Action = 'Update',
    @PresID = 9,
    @Status = 'Dispensed',
    @MedicineList = 'MED001,MED002,MED003';
REVERT;