CREATE VIEW dbo.PatientAppointmentsView
AS
SELECT
    A.PID,
    A.StaffID,
    S.SName AS StaffName,
    A.Date,
    A.Status
FROM 
    Appointment A
JOIN 
    Staff S ON A.StaffID = S.StaffID
WHERE 
    A.PID = USER_NAME();  -- Matches logged-in patient's PID
GO

-- Grant read access to patients
GRANT SELECT ON dbo.PatientAppointmentsView TO Patients;

-- Test Case
EXECUTE AS USER = 'PT001';
SELECT * FROM dbo."PatientAppointmentsView";
REVERT;



