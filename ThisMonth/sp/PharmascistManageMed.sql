DROP PROCEDURE IF EXISTS dbo.ManageMedicineDetails;

-- Procedure for pharmacists to manage medicine details
CREATE PROCEDURE dbo.ManageMedicineDetails
    @Action varchar(10),                 -- 'ADD' or 'UPDATE'
    @MedID varchar(10) = NULL,          -- Required for UPDATE
    @MedName varchar(100) = NULL        -- Required for ADD and UPDATE
AS
BEGIN
    -- Declare variables
    DECLARE @CurrentStaffID varchar(6);
    DECLARE @StaffPosition varchar(20);
    
    -- Get the current logged-in user's StaffID
    SET @CurrentStaffID = SYSTEM_USER;
    
    -- Check if the user exists and is a pharmacist
    SELECT @StaffPosition = Position 
    FROM Staff 
    WHERE StaffID = @CurrentStaffID;
    
    IF @StaffPosition IS NULL
    BEGIN
        RAISERROR('Current user is not a valid staff member.', 16, 1);
        RETURN;
    END
    
    IF @StaffPosition <> 'Pharmacist'
    BEGIN
        RAISERROR('Only pharmacists are authorized to manage medicine details.', 16, 1);
        RETURN;
    END
    
    -- Process based on action
    IF @Action = 'ADD'
    BEGIN
        -- Validate input parameters
        IF @MedName IS NULL
        BEGIN
            RAISERROR('Medicine name is required for adding a new medicine.', 16, 1);
            RETURN;
        END
        
        IF @MedID IS NULL
        BEGIN
            RAISERROR('Medicine ID is required for adding a new medicine.', 16, 1);
            RETURN;
        END
        
        -- Check if medicine with the same ID already exists
        IF EXISTS (SELECT 1 FROM Medicine WHERE MedID = @MedID)
        BEGIN
            RAISERROR('A medicine with this ID already exists. Use UPDATE to modify existing medicines.', 16, 1);
            RETURN;
        END
        
        -- Insert new medicine
        INSERT INTO Medicine (MedID, MedName)
        VALUES (@MedID, @MedName);
        
        -- Return the newly added medicine
        SELECT * FROM Medicine WHERE MedID = @MedID;
    END
    ELSE IF @Action = 'UPDATE'
    BEGIN
        -- Validate input parameters
        IF @MedID IS NULL
        BEGIN
            RAISERROR('Medicine ID is required for updating medicine details.', 16, 1);
            RETURN;
        END
        
        -- Check if medicine exists
        IF NOT EXISTS (SELECT 1 FROM Medicine WHERE MedID = @MedID)
        BEGIN
            RAISERROR('Medicine with specified ID does not exist. Use ADD to create a new medicine.', 16, 1);
            RETURN;
        END
        
        -- Validate that name was provided for update
        IF @MedName IS NULL
        BEGIN
            RAISERROR('Medicine name is required for updating medicine details.', 16, 1);
            RETURN;
        END
        
        -- Update medicine details
        UPDATE Medicine
        SET MedName = @MedName
        WHERE MedID = @MedID;
        
        -- Return the updated medicine
        SELECT * FROM Medicine WHERE MedID = @MedID;
    END
    ELSE
    BEGIN
        RAISERROR('Invalid action. Valid actions are ADD or UPDATE.', 16, 1);
        RETURN;
    END
END;
GO

-- Grant permissions to the Pharmacists role
GRANT EXECUTE ON dbo.ManageMedicineDetails TO Pharmacists;

-- Example usage:
-- To add a new medicine:
EXECUTE AS USER = 'ST006';
EXEC dbo.ManageMedicineDetails @Action = 'ADD', @MedID = 'MED016', @MedName = 'Azithromycin';
REVERT;

-- To update an existing medicine:
EXECUTE AS USER = 'ST006';
EXEC dbo.ManageMedicineDetails @Action = 'UPDATE', @MedID = 'MED016', @MedName = 'Azithromycin 250mg';
REVERT;
