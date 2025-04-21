-- -- Create the Trigger on Appointment
CREATE OR ALTER TRIGGER trg_AuditAppointmentChanges
ON Appointment
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- INSERT logging: only rows not in 'deleted'
    INSERT INTO AppointmentAudit (InsertedBy, ActionType, StaffID, PID, Date, Status)
    SELECT SYSTEM_USER, 'Insert', i.StaffID, i.PID, i.Date, i.Status
    FROM inserted i
    LEFT JOIN deleted d
        ON i.StaffID = d.StaffID AND i.PID = d.PID AND i.Date = d.Date
    WHERE d.StaffID IS NULL;

    -- UPDATE logging: only when status actually changes
    ;WITH ChangedRows AS (
        SELECT 
            i.StaffID, i.PID, i.Date, i.Status,
            ROW_NUMBER() OVER (PARTITION BY i.StaffID, i.PID, i.Date ORDER BY i.StaffID) AS rn
        FROM inserted i
        JOIN deleted d
            ON i.StaffID = d.StaffID AND i.PID = d.PID AND i.Date = d.Date
        WHERE ISNULL(i.Status, '') <> ISNULL(d.Status, '')
    )
    INSERT INTO AppointmentAudit (InsertedBy, ActionType, StaffID, PID, Date, Status)
    SELECT SYSTEM_USER, 'Update', StaffID, PID, Date, Status
    FROM ChangedRows
    WHERE rn = 1;  -- Only one log entry per actual change
END;