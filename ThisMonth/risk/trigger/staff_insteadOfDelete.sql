-- Active: 1744989381097@@172.20.10.4@1433@DBS_Ass

ALTER TABLE Staff
ADD active BIT DEFAULT 1 NOT NULL;

-- Create INSTEAD OF DELETE trigger to mark staff as inactive instead of deleting
CREATE OR ALTER TRIGGER TR_Staff_InsteadOfDelete
ON Staff
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;  -- Prevents extra result sets from interfering with the trigger's operation
    
    -- Update the active status to false (0) for the staff being deleted
    UPDATE s
    SET s.active = 0
    FROM Staff s
    INNER JOIN deleted d ON s.StaffID = d.StaffID;
    
    PRINT 'Staff record(s) marked as inactive instead of being deleted.';
END;

-- Example of how to select only active staff
SELECT * FROM Staff WHERE active = 1;

DELETE FROM Staff WHERE StaffID = 'ST001';  -- This will now mark the staff as inactive instead of deleting

UPDATE Staff
SET active = 1
WHERE StaffID = 'ST001';  -- This will reactivate the staff record