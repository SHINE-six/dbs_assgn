-- File: PrescriptionMedicineView.sql
-- This view joins Prescription, PrescriptionMedicine, and Medicine tables
-- to provide a comprehensive view of all prescriptions with their medicines

CREATE OR ALTER VIEW PrescriptionMedicineView AS
SELECT
    p.PresID,
    SUBSTRING(CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', p.PatientID), 2), 1, 4) AS PatientID,
    SUBSTRING(CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', p.DoctorID), 2), 1, 4) AS DoctorID,
    p.PresDateTime,
    p.Status AS PrescriptionStatus,
    m.MedName
FROM 
    Prescription p
    INNER JOIN PrescriptionMedicine pm ON p.PresID = pm.PresID
    INNER JOIN Medicine m ON pm.MedID = m.MedID;
GO

GRANT SELECT ON PrescriptionMedicineView TO Pharmacists;

-- Example queries to test the view:

-- Get all prescriptions with their medicines
SELECT * FROM PrescriptionMedicineView;

-- Get prescriptions for a specific patient
SELECT * FROM PrescriptionMedicineView WHERE PatientID = '7445';

-- Get prescriptions with a specific medicine
SELECT * FROM PrescriptionMedicineView WHERE MedName = 'Amoxicillin';

-- Get new prescriptions that haven't been dispensed yet
SELECT * FROM PrescriptionMedicineView WHERE PrescriptionStatus = 'New';

-- Count medicines per prescription
SELECT PresID, COUNT(*) AS MedicineCount
FROM PrescriptionMedicineView
GROUP BY PresID
ORDER BY PresID;

-- Get the most commonly prescribed medicines
SELECT MedName, COUNT(*) AS PrescriptionCount
FROM PrescriptionMedicineView
GROUP BY MedName
ORDER BY PrescriptionCount DESC;
