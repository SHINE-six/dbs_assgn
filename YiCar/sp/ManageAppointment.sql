-----
USE DBS_Ass


--Nurse Procedure -- Manage Appointments
ALTER PROCEDURE dbo.ManageAppointment
    @Action VARCHAR(20),            -- 'Create' or 'UpdateStatus'
    @StaffID VARCHAR(6),
    @PID VARCHAR(6),
    @Date DATETIME = NULL,          -- Only needed for creation or duplicate record
    @Status VARCHAR(10) = NULL		-- Only need when Updating Status
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate status
    IF @Status NOT IN ('Done', 'Cancelled', NULL)
    BEGIN
        RAISERROR('Invalid status. Allowed: Done, Cancelled. No need to specify Status when Create', 16, 1);
        RETURN;
    END

    -- Validate StaffID is a Doctor
    IF NOT EXISTS (
        SELECT 1 FROM Staff WHERE StaffID = @StaffID AND Position = 'Doctor'
    )
    BEGIN
        RAISERROR('StaffID does not exist or is not a Doctor.', 16, 1);
        RETURN;
    END

    -- Validate PID exists
    IF NOT EXISTS (
        SELECT 1 FROM Patient WHERE PID = @PID
    )
    BEGIN
        RAISERROR('PID does not exist in Patients.', 16, 1);
        RETURN;
    END

    IF @Action = 'Create'
    BEGIN
        -- Validate date
        IF @Date IS NULL OR @Date <= GETDATE()
        BEGIN
            RAISERROR('Date must be in the future.', 16, 1);
            RETURN;
        END

        INSERT INTO Appointment (StaffID, PID, Date, Status)
        VALUES (@StaffID, @PID, @Date, 'New');
    END
	ELSE IF @Action = 'UpdateStatus'
	BEGIN
		-- Check if matching appointments exist
		DECLARE @MatchCount INT;

		SELECT @MatchCount = COUNT(*)
		FROM Appointment
		WHERE StaffID = @StaffID AND PID = @PID;

		IF @Status IS NULL
		BEGIN
			RAISERROR('Please specify Canceled or Done when updating status', 16, 1);
			RETURN;
		END

		IF @MatchCount = 0
		BEGIN
			RAISERROR('Appointment not found for given StaffID and PID.', 16, 1);
			RETURN;
		END

		-- If multiple matches and no date provided, raise an error
		IF @MatchCount > 1 AND @Date IS NULL
		BEGIN
			RAISERROR('Multiple appointments found. Please specify the appointment date.', 16, 1);
			RETURN;
		END

		-- Update specific appointment by date if provided
		IF @Date IS NOT NULL
		BEGIN
			IF NOT EXISTS (
				SELECT 1 FROM Appointment WHERE StaffID = @StaffID AND PID = @PID AND Date = @Date
			)
			BEGIN
				RAISERROR('No appointment found for the given StaffID, PID, and Date.', 16, 1);
				RETURN;
			END

			UPDATE Appointment
			SET Status = @Status
			WHERE StaffID = @StaffID AND PID = @PID AND Date = @Date;
		END
		ELSE
		BEGIN
			-- Only one match exists, so safe to update
			UPDATE Appointment
			SET Status = @Status
			WHERE StaffID = @StaffID AND PID = @PID;
		END
	END
    ELSE
    BEGIN
        RAISERROR('Invalid action. Use Create or UpdateStatus.', 16, 1);
    END
END;
GO

-- Grant EXECUTE permission to Nurse role
GRANT EXECUTE ON ManageAppointment TO Nurses;


-- Testing Manage Appointment SP
EXECUTE AS USER = 'ST004'

-- Fail - StaffID not a doctor
EXEC ManageAppointment
    @Action = 'Create',
    @StaffID = 'ST004',
    @PID = 'PT008',
	@Date = '2025-06-29 09:30:00.000';

-- Fail - Unknown Patients
EXEC ManageAppointment
    @Action = 'Create',
    @StaffID = 'ST003',
    @PID = 'PT108',
	@Date = '2025-06-29 09:30:00.000';

-- Fail - not Future Time
EXEC ManageAppointment
    @Action = 'Create',
    @StaffID = 'ST003',
    @PID = 'PT008',
	@Date = '2024-06-29 09:30:00.000';

-- Fail - Multiple Record for same doctor and patient
EXEC ManageAppointment
    @Action = 'UpdateStatus',
    @StaffID = 'ST002',
    @PID = 'PT005',
	@Status = 'Done';

REVERT;


-------