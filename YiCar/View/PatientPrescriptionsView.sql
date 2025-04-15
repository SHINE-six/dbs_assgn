USE DBS_Ass

-- Patients View - check their own prescription records
ALTER VIEW dbo.PatientPrescriptionsView
AS
SELECT
    p.PresID,
    p.PatientID,
    p.DoctorID,
	s.SName AS DoctorName,
    p.PresDateTime,
    p.Status
FROM Prescription p
INNER JOIN Staff s ON p.DoctorID = s.StaffID
WHERE PatientID = USER_NAME();

GRANT SELECT ON dbo.PatientPrescriptionsView TO Patients

-- Simulate login as patient
EXECUTE AS USER = 'PT001';

-- Try selecting from the view
SELECT * FROM dbo.PatientPrescriptionsView;

-- Revert back
REVERT;


-----