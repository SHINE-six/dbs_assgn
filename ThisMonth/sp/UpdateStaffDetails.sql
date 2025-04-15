DROP PROCEDURE IF EXISTS dbo.UpdateStaffDetails;

-- Procedure for staff members to update their own details using the current logged-in user
CREATE PROCEDURE dbo.UpdateStaffDetails
    @SName varchar(100) = NULL,
    @SPhone varchar(20) = NULL
AS
BEGIN
    DECLARE @CurrentStaffID varchar(6);
    
    -- Get the current logged-in user's StaffID
    -- Assuming the database login name matches the StaffID
    SET @CurrentStaffID = SYSTEM_USER;
    
    -- Verify the user exists in the Staff table
    IF NOT EXISTS (SELECT 1 FROM Staff WHERE StaffID = @CurrentStaffID)
    BEGIN
        RAISERROR('Current user is not a valid staff member.', 16, 1);
        RETURN;
    END

    -- Update only non-NULL fields
    UPDATE Staff
    SET 
        SName = ISNULL(@SName, SName),
        SPhone = ISNULL(@SPhone, SPhone)
    WHERE StaffID = @CurrentStaffID;

    -- Return updated record
    SELECT * FROM Staff WHERE StaffID = @CurrentStaffID;
END;
GO

-- Grant permissions to roles
GRANT EXECUTE ON dbo.UpdateStaffDetails TO Doctors;
GRANT EXECUTE ON dbo.UpdateStaffDetails TO Nurses;
GRANT EXECUTE ON dbo.UpdateStaffDetails TO Pharmacists;
GRANT EXECUTE ON dbo.UpdateStaffDetails TO Admins;

-- Test the procedure
EXEC AS USER = 'ST001';
EXEC dbo.UpdateStaffDetails 
    @SName = 'Dr. Foo',
    @SPhone = NULL;
REVERT;