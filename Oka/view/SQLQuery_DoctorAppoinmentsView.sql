
CREATE VIEW dbo.DoctorAppointmentsView
AS
SELECT
    A.StaffID,
    A.PID AS PatientID,
    P.PName AS PatientName,
    A.Date,
    A.Status
FROM 
    Appointment A
JOIN 
    Patient P ON A.PID = P.PID
WHERE 
    A.StaffID = USER_NAME();  -- Matches logged-in doctor's StaffID
GO

-- Grant read access to doctors
GRANT SELECT ON dbo.DoctorAppointmentsView TO Doctors;

-- Test Case
EXECUTE AS USER = 'ST002';
SELECT * FROM dbo."DoctorAppointmentsView";
REVERT;








