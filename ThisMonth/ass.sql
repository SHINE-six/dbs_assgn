-- Active: 1744989381097@@172.20.10.4@1433@DBS_Ass

-- Get all tables
SELECT * FROM information_schema.tables;

-- Schema
Create Table Staff (
    StaffID varchar(6) primary key, -- also acts as the system user id
    SName varchar(100) not null,
    SPassportNumber varchar(50) not null,
    SPhone varchar(20),
    Position varchar(20)
);

SELECT * FROM Staff;

Create Table Patient (
    PID varchar(6) primary key, -- also acts as the system user id
    PName varchar(100) not null,
    PPassportNumber varchar(50) not null,
    PPhone varchar(20),
    PaymentCardNumber varchar(20),
    PaymentCardPinCode varchar(20)
);
SELECT * FROM Patient;
SELECT PID, PPassportNumber, PaymentCardNumber FROM Patient_Encrypted;

Create Table Prescription (
    PresID int identity(1, 1) primary key,
    PatientID varchar(6) references Patient (PID),
    DoctorID varchar(6) references Staff (StaffID),
    PresDateTime datetime not null,
    Status varchar(10)
);

SELECT * FROM Prescription;

-- New, Dispensed, Cancelled
Create Table Medicine (
    MedID varchar(10) primary key,
    MedName varchar(100) not null
);

SELECT * FROM Medicine;

Create Table PrescriptionMedicine (
    PresID int references Prescription (PresID),
    MedID varchar(10) references Medicine (MedID),
    Primary Key (PresID, MedID)
);

SELECT * FROM PrescriptionMedicine;

Create Table Appointment (
    StaffID varchar(6),
    PID varchar(6),
    Date datetime,
    Status varchar(10) -- New, Done, Cancelled
);

SELECT * FROM Appointment;

-- Dummy Data

-- Staff Data
INSERT INTO Staff (StaffID, SName, SPassportNumber, SPhone, Position) VALUES
('ST001', 'Dr. John Smith', 'A12345678', '+1-555-123-4567', 'Doctor'),
('ST002', 'Dr. Emily Johnson', 'B87654321', '+1-555-234-5678', 'Doctor'),
('ST003', 'Dr. Michael Brown', 'C23456789', '+1-555-345-6789', 'Doctor'),
('ST004', 'Nurse Sarah Wilson', 'D34567890', '+1-555-456-7890', 'Nurse'),
('ST005', 'Nurse Robert Davis', 'E45678901', '+1-555-567-8901', 'Nurse'),
('ST006', 'Pharmacist Lisa Taylor', 'F56789012', '+1-555-678-9012', 'Pharmacist'),
('ST007', 'Pharmacist James Anderson', 'G67890123', '+1-555-789-0123', 'Pharmacist'),
('ST008', 'Admin Jane Martinez', 'H78901234', '+1-555-890-1234', 'Admin');

-- Patient Data
INSERT INTO Patient (PID, PName, PPassportNumber, PPhone, PaymentCardNumber, PaymentCardPinCode) VALUES
('PT001', 'Alice Williams', 'P12345678', '+1-555-111-2222', '4111111111111111', '1234'),
('PT002', 'Bob Miller', 'P23456789', '+1-555-222-3333', '5555555555554444', '2345'),
('PT003', 'Charlie Garcia', 'P34567890', '+1-555-333-4444', '3782822463100005', '3456'),
('PT004', 'Diana Rodriguez', 'P45678901', '+1-555-444-5555', '6011111111111117', '4567'),
('PT005', 'Edward Martinez', 'P56789012', '+1-555-555-6666', '4242424242424242', '5678'),
('PT006', 'Fiona Johnson', 'P67890123', '+1-555-666-7777', '5105105105105100', '6789'),
('PT007', 'George Wilson', 'P78901234', '+1-555-777-8888', '4012888888881881', '7890'),
('PT008', 'Hannah Davis', 'P89012345', '+1-555-888-9999', '5555555555554444', '8901'),
('PT009', 'Ian Smith', 'P90123456', '+1-555-999-0000', '6011000990139424', '9012'),
('PT010', 'Jessica Brown', 'P01234567', '+1-555-000-1111', '3714496353984312', '0123'),
('PT011', 'Kevin Taylor', 'P11223344', '+1-555-111-3333', '4111111111111111', '1122'),
('PT012', 'Laura Anderson', 'P22334455', '+1-555-222-4444', '5105105105105100', '2233'),
('PT013', 'Mike Thompson', 'P33445566', '+1-555-333-5555', '4012888888881881', '3344'),
('PT014', 'Nancy Lee', 'P44556677', '+1-555-444-6666', '5555555555554444', '4455'),
('PT015', 'Oscar Martinez', 'P55667788', '+1-555-555-7777', '6011000990139424', '5566');

-- Medicine Data
INSERT INTO Medicine (MedID, MedName) VALUES
('MED001', 'Amoxicillin'),
('MED002', 'Lisinopril'),
('MED003', 'Metformin'),
('MED004', 'Atorvastatin'),
('MED005', 'Albuterol'),
('MED006', 'Omeprazole'),
('MED007', 'Levothyroxine'),
('MED008', 'Amlodipine'),
('MED009', 'Prednisone'),
('MED010', 'Ibuprofen'),
('MED011', 'Acetaminophen'),
('MED012', 'Loratadine'),
('MED013', 'Fluoxetine'),
('MED014', 'Simvastatin'),
('MED015', 'Ciprofloxacin');

-- Prescription Data
INSERT INTO Prescription (PatientID, DoctorID, PresDateTime, Status) VALUES
('PT001', 'ST001', '2025-01-10 09:30:00', 'Dispensed'),
('PT002', 'ST002', '2025-01-15 10:45:00', 'Dispensed'),
('PT003', 'ST003', '2025-01-20 14:15:00', 'Dispensed'),
('PT004', 'ST001', '2025-02-05 11:30:00', 'Dispensed'),
('PT005', 'ST002', '2025-02-10 16:00:00', 'Cancelled'),
('PT006', 'ST003', '2025-02-15 09:15:00', 'Dispensed'),
('PT007', 'ST001', '2025-03-01 13:45:00', 'New'),
('PT008', 'ST002', '2025-03-10 15:30:00', 'New'),
('PT001', 'ST003', '2025-03-20 10:00:00', 'New'),
('PT002', 'ST001', '2025-04-05 14:30:00', 'New'),
('PT003', 'ST002', '2025-04-15 11:45:00', 'Dispensed'),
('PT004', 'ST003', '2025-04-25 10:15:00', 'Dispensed'),
('PT005', 'ST001', '2025-05-10 09:45:00', 'New'),
('PT006', 'ST002', '2025-05-20 13:30:00', 'Cancelled'),
('PT007', 'ST003', '2025-06-01 15:15:00', 'Dispensed');

-- PrescriptionMedicine Data (assuming 1-3 medicines per prescription)
INSERT INTO PrescriptionMedicine (PresID, MedID) VALUES
(1, 'MED001'), (1, 'MED010'),
(2, 'MED002'), (2, 'MED006'),
(3, 'MED003'), (3, 'MED008'), (3, 'MED011'),
(4, 'MED004'), (4, 'MED009'),
(5, 'MED005'), 
(6, 'MED001'), (6, 'MED012'),
(7, 'MED007'), (7, 'MED010'),
(8, 'MED013'), (8, 'MED005'),
(9, 'MED002'), (9, 'MED014'), (9, 'MED010'),
(10, 'MED003'), (10, 'MED011'),
(11, 'MED015'), (11, 'MED006'),
(12, 'MED007'), (12, 'MED008'), (12, 'MED012'),
(13, 'MED009'), (13, 'MED013'),
(14, 'MED004'), (14, 'MED010'),
(15, 'MED015'), (15, 'MED001');

-- Appointment Data
INSERT INTO Appointment (StaffID, PID, Date, Status) VALUES
('ST001', 'PT001', '2025-01-09 09:00:00', 'Done'),
('ST002', 'PT002', '2025-01-14 10:30:00', 'Done'),
('ST003', 'PT003', '2025-01-19 14:00:00', 'Done'),
('ST001', 'PT004', '2025-02-04 11:00:00', 'Done'),
('ST002', 'PT005', '2025-02-09 15:30:00', 'Cancelled'),
('ST003', 'PT006', '2025-02-14 09:00:00', 'Done'),
('ST001', 'PT007', '2025-02-28 13:30:00', 'Done'),
('ST002', 'PT008', '2025-03-09 15:00:00', 'Done'),
('ST003', 'PT009', '2025-03-15 10:30:00', 'Done'),
('ST001', 'PT010', '2025-03-22 14:00:00', 'Cancelled'),
('ST002', 'PT011', '2025-04-04 09:30:00', 'Done'),
('ST003', 'PT012', '2025-04-14 11:30:00', 'Done'),
('ST001', 'PT013', '2025-04-24 10:00:00', 'Done'),
('ST002', 'PT014', '2025-05-09 09:30:00', 'Done'),
('ST003', 'PT015', '2025-05-19 13:00:00', 'Cancelled'),
('ST001', 'PT001', '2025-05-31 15:00:00', 'Done'),
('ST002', 'PT002', '2025-06-10 10:00:00', 'New'),
('ST003', 'PT003', '2025-06-15 11:30:00', 'New'),
('ST001', 'PT004', '2025-06-20 14:00:00', 'New'),
('ST002', 'PT005', '2025-06-25 09:30:00', 'New');


CREATE ROLE Doctors;
CREATE ROLE Nurses;
CREATE ROLE Pharmacists;
CREATE ROLE Patients;
CREATE ROLE Admins;

-- Get all roles
SELECT * FROM sys.database_principals WHERE type = 'R';

-- GET all users
SELECT * FROM sys.database_principals WHERE type IN ('S', 'U');

-- GET ALL PROCEDURE
SELECT * FROM information_schema.routines WHERE routine_type = 'PROCEDURE';

-- GRANT Admins to be able to perform all actions
GRANT SELECT, INSERT, UPDATE, DELETE ON Staff TO Admins;
GRANT SELECT, INSERT, UPDATE, DELETE ON Patient TO Admins;
GRANT SELECT, INSERT, UPDATE, DELETE ON Prescription TO Admins;
GRANT SELECT, INSERT, UPDATE, DELETE ON Medicine TO Admins;
GRANT SELECT, INSERT, UPDATE, DELETE ON PrescriptionMedicine TO Admins;
GRANT SELECT, INSERT, UPDATE, DELETE ON Appointment TO Admins;
GRANT SELECT, INSERT, UPDATE, DELETE ON PatientKeys TO Admins;
GRANT SELECT, INSERT, UPDATE, DELETE ON StaffKeys TO Admins;