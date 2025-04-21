----------------------------------------------------------
---- Track Appointment Inserts or Updates Via Trigger ----
----------------------------------------------------------

-- Create an Audit Table
CREATE TABLE AppointmentAudit (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    InsertedBy SYSNAME,
    InsertedAt DATETIME DEFAULT GETDATE(),
    ActionType VARCHAR(10), -- 'Insert' or 'Update'
    StaffID VARCHAR(6),
    PID VARCHAR(6),
    Date DATETIME,
    Status VARCHAR(10)
);

---------------
-- Test Case --
--------------- 

-- Test the Trigger
EXECUTE AS USER = 'ST004';

EXEC dbo.ManageAppointment
    @Action = 'Create',
    @StaffID = 'ST001',
    @PID = 'PT001',
    @Date = '2025-07-10 09:00:00';

-- Check the Appointment table
SELECT * FROM Appointment

-- Update the same appointment
EXEC dbo.ManageAppointment
    @Action = 'UpdateStatus',
    @StaffID = 'ST001',
    @PID = 'PT001',
    @Date = '2025-07-10 09:00:00',
    @Status = 'Done';

REVERT;

-- Check the Audit Log
SELECT * FROM AppointmentAudit;

-- Check the appointment table
SELECT * FROM Appointment