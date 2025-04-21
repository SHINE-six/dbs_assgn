------------------------------------------------------------------
---- Implement Dynamic Data Masking on Patient's table PPhone ----
------------------------------------------------------------------

-- Test Case -- Before Solution Implementation (Showing Admin can view Patient's Phone Number)
--Admin
EXECUTE AS USER = 'A001';
SELECT PID, PName, PPhone FROM Patient;
REVERT;

-----------------------------------------------------------------------------------------------

-- Alter the Patient table to add masking
ALTER TABLE Patient
ALTER COLUMN PPhone ADD MASKED WITH (FUNCTION = 'partial(4,"-XXX-XXX-",4)');

-- Grant UNMASK permission to Nurses and Patients
GRANT UNMASK TO Nurses;
GRANT UNMASK TO Patients;

----------------------------------------------------------------------------------

-- Test Case --
--Admin
EXECUTE AS USER = 'A001';
SELECT * FROM PatientPersonalDataView;
REVERT;

--Nurse
EXECUTE AS USER = 'ST004'; -- Nurse
SELECT * FROM PatientPersonalDataView;
REVERT;

--Patient
EXECUTE AS USER = 'PT001'; -- Patient
SELECT * FROM PatientPersonalDataView;
REVERT;