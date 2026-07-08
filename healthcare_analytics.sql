CREATE DATABASE healthcare_analytics
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
USE healthcare_analytics;
SELECT '[STEP 1 COMPLETE] Healthcare Database Created!' AS status;
SET FOREIGN_KEY_CHECKS = 0;
CREATE TABLE IF NOT EXISTS departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    department_code VARCHAR(10) UNIQUE,
    description TEXT,
    location VARCHAR(100),
    phone_extension VARCHAR(10),
    bed_count INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS doctors (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    specialization VARCHAR(100),
    department_id INT,
    license_number VARCHAR(50) UNIQUE,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    years_of_experience INT DEFAULT 0,
    qualification VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    consultation_fee DECIMAL(10,2) DEFAULT 0.00
);
CREATE TABLE IF NOT EXISTS patients (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    blood_type ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'),
    phone VARCHAR(20),
    email VARCHAR(100),
    address TEXT,
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    registration_date DATE NOT NULL,
    has_insurance BOOLEAN DEFAULT FALSE,
    insurance_provider VARCHAR(100),
    insurance_id VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    chronic_conditions TEXT,
    allergies TEXT
);
CREATE TABLE IF NOT EXISTS diagnoses (
    diagnosis_id INT PRIMARY KEY AUTO_INCREMENT,
    icd10_code VARCHAR(10) UNIQUE NOT NULL,
    diagnosis_name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    is_chronic BOOLEAN DEFAULT FALSE
);
CREATE TABLE IF NOT EXISTS medications (
    medication_id INT PRIMARY KEY AUTO_INCREMENT,
    medication_name VARCHAR(100) NOT NULL,
    generic_name VARCHAR(100),
    drug_class VARCHAR(100),
    form VARCHAR(50),  -- tablet, injection, etc.
    strength VARCHAR(50),
    manufacturer VARCHAR(100),
    unit_cost DECIMAL(10,2),
    requires_prescription BOOLEAN DEFAULT TRUE
);
CREATE TABLE IF NOT EXISTS appointments (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATETIME NOT NULL,
    status ENUM('Scheduled', 'Completed', 'Cancelled', 'No-Show') DEFAULT 'Scheduled',
    reason TEXT,
    notes TEXT,
    duration_minutes INT DEFAULT 15,
    consultation_room VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    follow_up_needed BOOLEAN DEFAULT FALSE
);
CREATE TABLE IF NOT EXISTS admissions (
    admission_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    admission_date DATETIME NOT NULL,
    discharge_date DATETIME,
    admission_type ENUM('Emergency', 'Elective', 'Transfer') DEFAULT 'Emergency',
    admission_reason TEXT,
    room_number VARCHAR(20),
    bed_number VARCHAR(10),
    department_id INT,
    attending_doctor_id INT,
    discharge_summary TEXT,
    status ENUM('Admitted', 'Discharged', 'Transferred') DEFAULT 'Admitted',
    total_charges DECIMAL(12,2) DEFAULT 0.00,
    insurance_coverage DECIMAL(12,2) DEFAULT 0.00,
    patient_payment DECIMAL(12,2) DEFAULT 0.00
);
CREATE TABLE IF NOT EXISTS patient_diagnoses (
    patient_diagnosis_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    diagnosis_id INT NOT NULL,
    diagnosed_date DATE NOT NULL,
    diagnosed_by_doctor_id INT,
    severity ENUM('Mild', 'Moderate', 'Severe') DEFAULT 'Moderate',
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT
);
CREATE TABLE IF NOT EXISTS prescriptions (
    prescription_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    medication_id INT NOT NULL,
    prescribed_date DATE NOT NULL,
    dosage VARCHAR(50),
    frequency VARCHAR(50),
    duration_days INT,
    quantity INT,
    refills_allowed INT DEFAULT 0,
    instructions TEXT,
    status ENUM('Active', 'Completed', 'Cancelled') DEFAULT 'Active'
);
CREATE TABLE IF NOT EXISTS lab_tests (
    test_id INT PRIMARY KEY AUTO_INCREMENT,
    test_name VARCHAR(100) NOT NULL,
    test_code VARCHAR(20) UNIQUE,
    normal_range_min DECIMAL(10,2),
    normal_range_max DECIMAL(10,2),
    unit VARCHAR(20),
    department_id INT,
    cost DECIMAL(10,2) DEFAULT 0.00
);
CREATE TABLE IF NOT EXISTS lab_results (
    result_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    test_id INT NOT NULL,
    ordered_by_doctor_id INT,
    test_date DATE NOT NULL,
    result_value DECIMAL(10,2),
    result_notes TEXT,
    status ENUM('Pending', 'Completed', 'Abnormal') DEFAULT 'Pending',
    is_critical BOOLEAN DEFAULT FALSE
);
CREATE TABLE IF NOT EXISTS billing (
    bill_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    admission_id INT,
    bill_date DATE NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    insurance_covered DECIMAL(12,2) DEFAULT 0.00,
    patient_payable DECIMAL(12,2) NOT NULL,
    payment_status ENUM('Pending', 'Partially Paid', 'Paid', 'Insurance Claim') DEFAULT 'Pending',
    due_date DATE,
    payment_date DATE
);
ALTER TABLE doctors 
ADD FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL;
ALTER TABLE appointments 
ADD FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
ADD FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE CASCADE;
ALTER TABLE admissions 
ADD FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
ADD FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL,
ADD FOREIGN KEY (attending_doctor_id) REFERENCES doctors(doctor_id) ON DELETE SET NULL;

ALTER TABLE patient_diagnoses 
ADD FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
ADD FOREIGN KEY (diagnosis_id) REFERENCES diagnoses(diagnosis_id) ON DELETE RESTRICT,
ADD FOREIGN KEY (diagnosed_by_doctor_id) REFERENCES doctors(doctor_id) ON DELETE SET NULL;

ALTER TABLE prescriptions 
ADD FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
ADD FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE CASCADE,
ADD FOREIGN KEY (medication_id) REFERENCES medications(medication_id) ON DELETE RESTRICT;

ALTER TABLE lab_tests 
ADD FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL;

ALTER TABLE lab_results 
ADD FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
ADD FOREIGN KEY (test_id) REFERENCES lab_tests(test_id) ON DELETE RESTRICT,
ADD FOREIGN KEY (ordered_by_doctor_id) REFERENCES doctors(doctor_id) ON DELETE SET NULL;

ALTER TABLE billing 
ADD FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
ADD FOREIGN KEY (admission_id) REFERENCES admissions(admission_id) ON DELETE SET NULL;

SET FOREIGN_KEY_CHECKS = 1;
SELECT '✅ All medical tables created with foreign keys!' AS status;

SELECT '1. Inserting departments...' AS progress;
INSERT INTO departments (department_name, department_code, description, bed_count) VALUES
('Cardiology', 'CARD', 'Heart and cardiovascular care', 50),
('Neurology', 'NEUR', 'Brain and nervous system disorders', 40),
('Orthopedics', 'ORTH', 'Bones and joints', 60),
('Pediatrics', 'PEDI', 'Child healthcare', 45),
('Oncology', 'ONCO', 'Cancer treatment', 35),
('Emergency', 'EMER', 'Emergency care', 30),
('General Medicine', 'GMED', 'General healthcare', 80);

SELECT '2. Inserting doctors...' AS progress;
INSERT INTO doctors (first_name, last_name, specialization, department_id, license_number, years_of_experience, consultation_fee) VALUES
('Robert', 'Miller', 'Cardiologist', 1, 'DOC123456', 15, 200.00),
('Sarah', 'Johnson', 'Cardiac Surgeon', 1, 'DOC123457', 20, 500.00),
('David', 'Chen', 'Neurologist', 2, 'DOC123458', 12, 180.00),
('Lisa', 'Patel', 'Neurosurgeon', 2, 'DOC123459', 18, 450.00),
('Michael', 'Brown', 'Orthopedic Surgeon', 3, 'DOC123460', 10, 220.00),
('Jennifer', 'Wilson', 'Pediatrician', 4, 'DOC123461', 8, 150.00),
('James', 'Taylor', 'Oncologist', 5, 'DOC123462', 14, 250.00),
('Emily', 'Davis', 'Emergency Medicine', 6, 'DOC123463', 6, 120.00),
('Thomas', 'Anderson', 'General Physician', 7, 'DOC123464', 10, 100.00);

SELECT '3. Inserting patients...' AS progress;
INSERT INTO patients (first_name, last_name, date_of_birth, gender, blood_type, phone, registration_date, has_insurance, chronic_conditions, allergies) VALUES
('John', 'Smith', '1985-03-15', 'Male', 'A+', '555-0101', '2020-01-15', TRUE, 'Hypertension, Type 2 Diabetes', 'Penicillin'),
('Mary', 'Johnson', '1978-07-22', 'Female', 'O-', '555-0102', '2019-05-10', TRUE, 'Asthma, Arthritis', 'Peanuts'),
('Robert', 'Davis', '1992-11-05', 'Male', 'B+', '555-0103', '2021-02-20', FALSE, NULL, 'Shellfish'),
('Susan', 'Wilson', '1965-02-28', 'Female', 'AB+', '555-0104', '2018-11-15', TRUE, 'Heart Disease, High Cholesterol', 'Latex'),
('Michael', 'Brown', '1958-09-12', 'Male', 'O+', '555-0105', '2020-08-05', TRUE, 'COPD, Hypertension', 'Aspirin'),
('Lisa', 'Taylor', '1988-06-30', 'Female', 'A-', '555-0106', '2022-03-01', FALSE, 'Migraine', 'Sulfa drugs'),
('David', 'Miller', '1975-04-18', 'Male', 'B-', '555-0107', '2019-09-22', TRUE, 'Type 1 Diabetes', 'Iodine'),
('Jessica', 'Anderson', '1995-12-03', 'Female', 'O+', '555-0108', '2023-01-10', TRUE, NULL, 'Eggs'),
('William', 'Thomas', '1948-08-25', 'Male', 'A+', '555-0109', '2017-06-18', TRUE, 'Parkinsons, Dementia', 'Codeine'),
('Elizabeth', 'Martin', '1982-01-14', 'Female', 'AB-', '555-0110', '2021-11-30', FALSE, 'Hypothyroidism', 'None');

SELECT '4. Inserting diagnoses (ICD10 codes)...' AS progress;
INSERT INTO diagnoses (icd10_code, diagnosis_name, category, is_chronic) VALUES
('I10', 'Essential (primary) hypertension', 'Cardiovascular', TRUE),
('I25', 'Chronic ischemic heart disease', 'Cardiovascular', TRUE),
('I48', 'Atrial fibrillation and flutter', 'Cardiovascular', TRUE),
('E11', 'Type 2 diabetes mellitus', 'Endocrine', TRUE),
('G43', 'Migraine', 'Neurological', TRUE),
('G20', 'Parkinson disease', 'Neurological', TRUE),
('G30', 'Alzheimer disease', 'Neurological', TRUE),
('G40', 'Epilepsy', 'Neurological', TRUE),
('J45', 'Asthma', 'Respiratory', TRUE),
('J44', 'Other chronic obstructive pulmonary disease', 'Respiratory', TRUE),
('M17', 'Gonarthrosis [arthrosis of knee]', 'Musculoskeletal', TRUE),
('M54', 'Dorsalgia (back pain)', 'Musculoskeletal', FALSE),
('E03', 'Hypothyroidism', 'Endocrine', TRUE),
('E78', 'Disorders of lipoprotein metabolism', 'Metabolic', TRUE),
('R51', 'Headache', 'General Symptoms', FALSE),
('R05', 'Cough', 'Respiratory', FALSE);
SELECT '5. Inserting medications...' AS progress;
INSERT INTO medications (medication_name, generic_name, drug_class, form, strength) VALUES
('Lisinopril', 'Lisinopril', 'ACE Inhibitor', 'Tablet', '10mg'),
('Metformin', 'Metformin', 'Biguanide', 'Tablet', '500mg'),
('Atorvastatin', 'Atorvastatin', 'Statin', 'Tablet', '20mg'),
('Warfarin', 'Warfarin', 'Anticoagulant', 'Tablet', '5mg'),
('Levodopa', 'Levodopa', 'Dopamine precursor', 'Tablet', '100mg'),
('Donepezil', 'Donepezil', 'Cholinesterase inhibitor', 'Tablet', '10mg'),
('Sumatriptan', 'Sumatriptan', 'Triptan', 'Tablet', '50mg'),
('Albuterol', 'Albuterol', 'Bronchodilator', 'Inhaler', '90mcg'),
('Fluticasone', 'Fluticasone', 'Corticosteroid', 'Inhaler', '110mcg'),
('Ibuprofen', 'Ibuprofen', 'NSAID', 'Tablet', '400mg'),
('Acetaminophen', 'Acetaminophen', 'Analgesic', 'Tablet', '500mg'),
('Levothyroxine', 'Levothyroxine', 'Thyroid hormone', 'Tablet', '50mcg'),
('Amoxicillin', 'Amoxicillin', 'Penicillin', 'Capsule', '500mg'),
('Azithromycin', 'Azithromycin', 'Macrolide', 'Tablet', '250mg');

SELECT '6. Inserting lab tests...' AS progress;
INSERT INTO lab_tests (test_name, test_code, normal_range_min, normal_range_max, unit, department_id) VALUES
('Complete Blood Count', 'CBC', 4.5, 11.0, '10^3/uL', 7),
('Hemoglobin A1c', 'HbA1c', 4.0, 5.6, '%', 7),
('Cholesterol Total', 'CHOL', 125, 200, 'mg/dL', 1),
('Low Density Lipoprotein', 'LDL', 0, 100, 'mg/dL', 1),
('High Density Lipoprotein', 'HDL', 40, 60, 'mg/dL', 1),
('Thyroid Stimulating Hormone', 'TSH', 0.4, 4.0, 'mIU/L', 7),
('Alanine Aminotransferase', 'ALT', 7, 56, 'U/L', 7),
('Aspartate Aminotransferase', 'AST', 10, 40, 'U/L', 7),
('Creatinine', 'CREAT', 0.6, 1.3, 'mg/dL', 7),
('Blood Urea Nitrogen', 'BUN', 7, 20, 'mg/dL', 7),
('Troponin I', 'TROP', 0, 0.04, 'ng/mL', 1),
('Brain Natriuretic Peptide', 'BNP', 0, 100, 'pg/mL', 1),
('C-Reactive Protein', 'CRP', 0, 3.0, 'mg/L', 7),
('Erythrocyte Sedimentation Rate', 'ESR', 0, 20, 'mm/hr', 7);
SELECT '7. Inserting appointments...' AS progress;
INSERT INTO appointments (patient_id, doctor_id, appointment_date, status, reason) VALUES
(1, 1, DATE_SUB(NOW(), INTERVAL 5 DAY), 'Completed', 'Hypertension follow-up'),
(2, 4, DATE_SUB(NOW(), INTERVAL 10 DAY), 'Completed', 'Migraine evaluation'),
(3, 7, DATE_SUB(NOW(), INTERVAL 3 DAY), 'Completed', 'General checkup'),
(4, 1, DATE_SUB(NOW(), INTERVAL 15 DAY), 'Completed', 'Chest pain evaluation'),
(5, 8, DATE_SUB(NOW(), INTERVAL 1 DAY), 'Scheduled', 'COPD exacerbation'),
(6, 2, DATE_SUB(NOW(), INTERVAL 20 DAY), 'Completed', 'Cardiac consultation'),
(7, 5, DATE_SUB(NOW(), INTERVAL 7 DAY), 'Cancelled', 'Orthopedic consultation'),
(8, 3, DATE_SUB(NOW(), INTERVAL 12 DAY), 'Completed', 'Neurology follow-up'),
(9, 6, NOW(), 'Scheduled', 'Oncology consultation'),
(10, 7, DATE_ADD(NOW(), INTERVAL 2 DAY), 'Scheduled', 'Annual physical');
SELECT '8. Inserting admissions...' AS progress;
INSERT INTO admissions (patient_id, admission_date, discharge_date, admission_type, admission_reason, department_id, attending_doctor_id, status, total_charges) VALUES
(1, '2024-01-10 14:30:00', '2024-01-15 11:00:00', 'Emergency', 'Chest pain, rule out MI', 1, 1, 'Discharged', 12500.00),
(4, '2024-01-05 09:15:00', '2024-01-12 16:45:00', 'Elective', 'Coronary angiography', 1, 2, 'Discharged', 18500.00),
(6, '2024-01-18 22:45:00', '2024-01-20 10:30:00', 'Emergency', 'Severe migraine with aura', 2, 4, 'Discharged', 8500.00),
(5, '2024-01-25 08:00:00', NULL, 'Emergency', 'COPD exacerbation', 6, 8, 'Admitted', 3500.00),
(9, '2024-01-22 15:20:00', NULL, 'Elective', 'Neurological evaluation', 2, 3, 'Admitted', 9200.00);
SELECT '9. Inserting patient diagnoses...' AS progress;
INSERT INTO patient_diagnoses (patient_id, diagnosis_id, diagnosed_date, diagnosed_by_doctor_id, severity) VALUES
(1, 1, '2020-02-15', 1, 'Moderate'),
(1, 4, '2020-03-10', 1, 'Mild'),
(2, 5, '2019-06-01', 4, 'Severe'),
(4, 2, '2018-12-10', 1, 'Severe'),
(4, 14, '2019-01-05', 1, 'Moderate'),
(5, 9, '2020-09-15', 8, 'Moderate'),
(5, 1, '2020-10-03', 7, 'Mild'),
(6, 5, '2022-03-15', 4, 'Moderate'),
(7, 4, '2019-10-22', 7, 'Moderate'),
(9, 6, '2017-08-20', 3, 'Severe'),
(10, 13, '2021-12-05', 7, 'Mild');

SELECT '10. Inserting prescriptions...' AS progress;
INSERT INTO prescriptions (patient_id, doctor_id, medication_id, prescribed_date, dosage, frequency, duration_days) VALUES
(1, 1, 1, '2024-01-15', '10mg', 'Once daily', 30),
(1, 1, 2, '2024-01-15', '500mg', 'Twice daily', 30),
(4, 1, 3, '2024-01-12', '20mg', 'Once daily at bedtime', 30),
(4, 1, 4, '2024-01-12', '5mg', 'Once daily', 30),
(2, 4, 7, '2024-01-10', '50mg', 'As needed for migraine', 10),
(5, 8, 9, '2024-01-25', '2 puffs', 'Every 6 hours as needed', 7),
(10, 7, 12, '2021-12-05', '50mcg', 'Once daily', 90),
(9, 3, 6, '2024-01-22', '10mg', 'Once daily', 30);

SELECT '11. Inserting lab results...' AS progress;
INSERT INTO lab_results (patient_id, test_id, ordered_by_doctor_id, test_date, result_value, status) VALUES
(1, 2, 1, '2024-01-15', 6.8, 'Abnormal'), 
(1, 3, 1, '2024-01-15', 240, 'Abnormal'),  
(1, 5, 1, '2024-01-15', 35, 'Abnormal'),   
(4, 11, 1, '2024-01-10', 0.12, 'Abnormal'), 
(4, 12, 1, '2024-01-10', 450, 'Abnormal'),   
(3, 1, 7, '2024-01-03', 7.2, 'Completed'),   
(8, 6, 7, '2023-12-20', 2.1, 'Completed');   

SELECT '12. Inserting billing...' AS progress;
INSERT INTO billing (patient_id, admission_id, bill_date, total_amount, insurance_covered, patient_payable, payment_status) VALUES
(1, 1, '2024-01-16', 12500.00, 10000.00, 2500.00, 'Paid'),
(4, 2, '2024-01-13', 18500.00, 14800.00, 3700.00, 'Partially Paid'),
(6, 3, '2024-01-21', 8500.00, 0.00, 8500.00, 'Pending'),
(5, 4, DATE(NOW()), 3500.00, 0.00, 3500.00, 'Pending'),
(9, 5, DATE(NOW()), 9200.00, 7360.00, 1840.00, 'Insurance Claim');

SELECT '13. Updating statistics...' AS progress;
UPDATE admissions 
SET discharge_date = DATE_ADD(admission_date, INTERVAL FLOOR(RAND() * 7 + 3) DAY)
WHERE discharge_date IS NULL 
AND admission_date < DATE_SUB(NOW(), INTERVAL 2 DAY);

UPDATE lab_results 
SET is_critical = TRUE 
WHERE result_id IN (1, 4, 5);
SELECT 
    (SELECT COUNT(*) FROM patients) AS total_patients,
    (SELECT COUNT(*) FROM doctors) AS total_doctors,
    (SELECT COUNT(*) FROM appointments) AS total_appointments,
    (SELECT COUNT(*) FROM admissions) AS total_admissions,
    (SELECT COUNT(*) FROM prescriptions) AS total_prescriptions,
    (SELECT COUNT(DISTINCT patient_id) FROM admissions WHERE status = 'Admitted') AS currently_admitted,
    (SELECT SUM(total_amount) FROM billing WHERE payment_status != 'Paid') AS outstanding_bills;

SELECT '=========================================' AS separator_line;
SELECT 'BASIC HEALTHCARE ANALYTICS' AS title;
SELECT '=========================================' AS separator_line;
SELECT '1. HOSPITAL OVERVIEW STATISTICS' AS query_name;
SELECT 
    (SELECT COUNT(*) FROM patients) AS total_patients,
    (SELECT COUNT(*) FROM doctors) AS total_doctors,
    (SELECT COUNT(*) FROM appointments WHERE DATE(appointment_date) = CURDATE()) AS todays_appointments,
    (SELECT COUNT(*) FROM admissions WHERE status = 'Admitted') AS currently_admitted,
    (SELECT COUNT(*) FROM admissions WHERE MONTH(admission_date) = MONTH(CURDATE())) AS monthly_admissions,
    (SELECT ROUND(AVG(total_charges), 2) FROM admissions WHERE discharge_date IS NOT NULL) AS avg_admission_cost,
    (SELECT ROUND(AVG(TIMESTAMPDIFF(DAY, admission_date, discharge_date)), 1) 
     FROM admissions WHERE discharge_date IS NOT NULL) AS avg_length_of_stay;

SELECT '---' AS separator_line;
SELECT '2. PATIENT DEMOGRAPHICS' AS query_name;
SELECT 
    gender,
    COUNT(*) AS patient_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM patients), 2) AS percentage,
    ROUND(AVG(TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE())), 1) AS avg_age,
    MIN(TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE())) AS min_age,
    MAX(TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE())) AS max_age,
    SUM(has_insurance) AS insured_count,
    ROUND(SUM(has_insurance) * 100.0 / COUNT(*), 2) AS insurance_coverage_rate
FROM patients
GROUP BY gender
ORDER BY patient_count DESC;

SELECT '---' AS separator_line;
SELECT '3. DEPARTMENT PERFORMANCE' AS query_name;
SELECT 
    d.department_name,
    COUNT(DISTINCT doc.doctor_id) AS doctor_count,
    COUNT(DISTINCT a.admission_id) AS total_admissions,
    COUNT(DISTINCT CASE WHEN a.status = 'Admitted' THEN a.admission_id END) AS current_admissions,
    ROUND(AVG(a.total_charges), 2) AS avg_admission_cost,
    ROUND(AVG(TIMESTAMPDIFF(DAY, a.admission_date, a.discharge_date)), 1) AS avg_length_of_stay_days,
    ROUND(SUM(a.total_charges), 2) AS total_revenue
FROM departments d
LEFT JOIN doctors doc ON d.department_id = doc.department_id
LEFT JOIN admissions a ON d.department_id = a.department_id
GROUP BY d.department_id, d.department_name
ORDER BY total_admissions DESC;

SELECT '---' AS separator_line;
SELECT '4. DOCTOR PERFORMANCE ANALYSIS' AS query_name;
SELECT 
    CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
    dep.department_name,
    d.specialization,
    d.years_of_experience,
    COUNT(DISTINCT a.appointment_id) AS total_appointments,
    COUNT(DISTINCT ad.admission_id) AS total_admissions,
    COUNT(DISTINCT p.prescription_id) AS prescriptions_written,
    ROUND(AVG(a.duration_minutes), 0) AS avg_appointment_minutes,
    ROUND(SUM(ad.total_charges), 2) AS generated_revenue
FROM doctors d
LEFT JOIN departments dep ON d.department_id = dep.department_id
LEFT JOIN appointments a ON d.doctor_id = a.doctor_id
LEFT JOIN admissions ad ON d.doctor_id = ad.attending_doctor_id
LEFT JOIN prescriptions p ON d.doctor_id = p.doctor_id
GROUP BY d.doctor_id, d.first_name, d.last_name, dep.department_name, d.specialization, d.years_of_experience
ORDER BY total_appointments DESC;

SELECT '---' AS separator_line;
SELECT '5. MOST COMMON DIAGNOSES' AS query_name;
SELECT 
    diag.diagnosis_name,
    diag.icd10_code,
    diag.category,
    COUNT(DISTINCT pd.patient_id) AS patient_count,
    COUNT(DISTINCT pd.patient_diagnosis_id) AS diagnosis_count,
    ROUND(COUNT(DISTINCT pd.patient_id) * 100.0 / (SELECT COUNT(*) FROM patients), 2) AS prevalence_percentage,
    CASE 
        WHEN diag.is_chronic THEN 'Chronic'
        ELSE 'Acute'
    END AS condition_type
FROM diagnoses diag
LEFT JOIN patient_diagnoses pd ON diag.diagnosis_id = pd.diagnosis_id
GROUP BY diag.diagnosis_id, diag.diagnosis_name, diag.icd10_code, diag.category, diag.is_chronic
HAVING patient_count > 0
ORDER BY patient_count DESC
LIMIT 10;

SELECT '---' AS separator_line;
SELECT '6. APPOINTMENT ANALYSIS' AS query_name;
SELECT 
    DATE(appointment_date) AS appointment_day,
    DAYNAME(appointment_date) AS day_of_week,
    COUNT(*) AS appointment_count,
    SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) AS completed,
    SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled,
    SUM(CASE WHEN status = 'No-Show' THEN 1 ELSE 0 END) AS no_shows,
    ROUND(SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS completion_rate
FROM appointments
WHERE appointment_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY DATE(appointment_date), DAYNAME(appointment_date)
ORDER BY appointment_date DESC;

SELECT '---' AS separator_line;
SELECT '7. MEDICATION USAGE ANALYSIS' AS query_name;
SELECT 
    m.medication_name,
    m.generic_name,
    m.drug_class,
    COUNT(DISTINCT p.prescription_id) AS prescription_count,
    COUNT(DISTINCT p.patient_id) AS unique_patients,
    SUM(p.quantity) AS total_quantity_prescribed,
    MIN(p.prescribed_date) AS first_prescribed,
    MAX(p.prescribed_date) AS last_prescribed,
    ROUND(AVG(p.duration_days), 0) AS avg_duration_days
FROM medications m
LEFT JOIN prescriptions p ON m.medication_id = p.medication_id
GROUP BY m.medication_id, m.medication_name, m.generic_name, m.drug_class
HAVING prescription_count > 0
ORDER BY prescription_count DESC;

SELECT '---' AS separator_line;
SELECT '8. LABORATORY TEST STATISTICS' AS query_name;
SELECT 
    lt.test_name,
    lt.test_code,
    dep.department_name,
    COUNT(DISTINCT lr.result_id) AS test_count,
    SUM(CASE WHEN lr.status = 'Abnormal' THEN 1 ELSE 0 END) AS abnormal_results,
    SUM(CASE WHEN lr.is_critical = TRUE THEN 1 ELSE 0 END) AS critical_results,
    ROUND(AVG(lr.result_value), 2) AS avg_result_value,
    ROUND(SUM(CASE WHEN lr.status = 'Abnormal' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS abnormal_rate_percentage
FROM lab_tests lt
LEFT JOIN departments dep ON lt.department_id = dep.department_id
LEFT JOIN lab_results lr ON lt.test_id = lr.test_id
GROUP BY lt.test_id, lt.test_name, lt.test_code, dep.department_name
ORDER BY test_count DESC;

SELECT '---' AS separator_line;
SELECT '9. BILLING AND REVENUE ANALYSIS' AS query_name;
SELECT 
    MONTH(bill_date) AS month,
    YEAR(bill_date) AS year,
    COUNT(*) AS total_bills,
    ROUND(SUM(total_amount), 2) AS total_revenue,
    ROUND(SUM(insurance_covered), 2) AS insurance_payments,
    ROUND(SUM(patient_payable), 2) AS patient_payments,
    SUM(CASE WHEN payment_status = 'Paid' THEN 1 ELSE 0 END) AS paid_bills,
    SUM(CASE WHEN payment_status = 'Pending' THEN 1 ELSE 0 END) AS pending_bills,
    ROUND(SUM(CASE WHEN payment_status = 'Paid' THEN patient_payable ELSE 0 END) * 100.0 / SUM(patient_payable), 2) AS collection_rate
FROM billing
WHERE bill_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY YEAR(bill_date), MONTH(bill_date)
ORDER BY year DESC, month DESC;

SELECT '10. PATIENT READMISSION ANALYSIS' AS query_name;
SELECT 
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    COUNT(a.admission_id) AS total_admissions,
    MIN(a.admission_date) AS first_admission,
    MAX(a.admission_date) AS latest_admission,
    (SELECT COUNT(*) 
     FROM admissions a2 
     WHERE a2.patient_id = p.patient_id
     AND EXISTS (
         SELECT 1 FROM admissions a3 
         WHERE a3.patient_id = p.patient_id
         AND a3.admission_date < a2.admission_date
         AND TIMESTAMPDIFF(DAY, a3.discharge_date, a2.admission_date) <= 30
     )) AS readmissions_30_days,
    ROUND(AVG(TIMESTAMPDIFF(DAY, a.admission_date, a.discharge_date)), 1) AS avg_length_of_stay
FROM patients p
LEFT JOIN admissions a ON p.patient_id = a.patient_id
WHERE a.discharge_date IS NOT NULL
GROUP BY p.patient_id, p.first_name, p.last_name
HAVING total_admissions >= 1
ORDER BY total_admissions DESC, readmissions_30_days DESC;
SELECT '=========================================' AS separator_line;
SELECT 'BASIC HEALTHCARE ANALYTICS COMPLETED!' AS final_status;
SELECT '=========================================' AS separator_line;
SET @ref_date = CURDATE();
SELECT '=========================================' AS separator_line;
SELECT 'ADVANCED HEALTHCARE INSIGHTS' AS title;
SELECT '=========================================' AS separator_line;
SELECT '1. PATIENT RISK STRATIFICATION' AS insight_name;
WITH patient_risk AS (
    SELECT 
        p.patient_id,
        CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
        TIMESTAMPDIFF(YEAR, p.date_of_birth, @ref_date) AS age,
        p.gender,
        COUNT(DISTINCT pd.diagnosis_id) AS chronic_condition_count,
        COUNT(DISTINCT a.admission_id) AS total_admissions,
        COUNT(DISTINCT lr.result_id) AS abnormal_lab_count,
        SUM(CASE WHEN lr.is_critical = TRUE THEN 1 ELSE 0 END) AS critical_lab_count,
        SUM(CASE WHEN pd.diagnosis_id IN (1,2,4,6,9) THEN 1 ELSE 0 END) AS major_condition_count
    FROM patients p
    LEFT JOIN patient_diagnoses pd ON p.patient_id = pd.patient_id
    LEFT JOIN admissions a ON p.patient_id = a.patient_id
    LEFT JOIN lab_results lr ON p.patient_id = lr.patient_id AND lr.status = 'Abnormal'
    GROUP BY p.patient_id, p.first_name, p.last_name, p.date_of_birth, p.gender
)
SELECT 
    patient_id,
    patient_name,
    age,
    gender,
    chronic_condition_count,
    total_admissions,
    abnormal_lab_count,
    (chronic_condition_count * 3) + 
    (total_admissions * 2) + 
    (abnormal_lab_count) + 
    (CASE WHEN age > 60 THEN 2 WHEN age > 40 THEN 1 ELSE 0 END) AS risk_score,
    CASE 
        WHEN (chronic_condition_count * 3) + (total_admissions * 2) + (abnormal_lab_count) + 
             (CASE WHEN age > 60 THEN 2 WHEN age > 40 THEN 1 ELSE 0 END) >= 10 THEN '[HIGH RISK]'
        WHEN (chronic_condition_count * 3) + (total_admissions * 2) + (abnormal_lab_count) + 
             (CASE WHEN age > 60 THEN 2 WHEN age > 40 THEN 1 ELSE 0 END) >= 5 THEN '[MODERATE RISK]'
        ELSE '[LOW RISK]'
    END AS risk_category
FROM patient_risk
ORDER BY risk_score DESC;

SELECT '---' AS separator_line;
SELECT '2. TREATMENT EFFICACY ANALYSIS' AS insight_name;
WITH diagnosis_treatment AS (
    SELECT 
        pd.diagnosis_id,
        d.diagnosis_name,
        m.medication_name,
        COUNT(DISTINCT p.patient_id) AS patient_count,
        AVG(TIMESTAMPDIFF(DAY, pd.diagnosed_date, CURDATE())) AS avg_days_since_diagnosis,
        AVG(pr.duration_days) AS avg_treatment_duration,
        SUM(CASE WHEN a.admission_id IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(DISTINCT p.patient_id) AS no_admission_rate
    FROM patient_diagnoses pd
    JOIN diagnoses d ON pd.diagnosis_id = d.diagnosis_id
    JOIN patients p ON pd.patient_id = p.patient_id
    LEFT JOIN prescriptions pr ON p.patient_id = pr.patient_id
    LEFT JOIN medications m ON pr.medication_id = m.medication_id
    LEFT JOIN admissions a ON p.patient_id = a.patient_id 
        AND a.admission_date > pd.diagnosed_date
    WHERE d.is_chronic = TRUE
    GROUP BY pd.diagnosis_id, d.diagnosis_name, m.medication_name
    HAVING patient_count >= 1
)
SELECT 
    diagnosis_name,
    medication_name,
    patient_count,
    ROUND(avg_days_since_diagnosis, 0) AS avg_days_since_diagnosis,
    ROUND(avg_treatment_duration, 0) AS avg_treatment_days,
    ROUND(no_admission_rate, 2) AS no_admission_percentage,
    CASE 
        WHEN no_admission_rate > 90 THEN '[EXCELLENT EFFICACY]'
        WHEN no_admission_rate > 75 THEN '[GOOD EFFICACY]'
        WHEN no_admission_rate > 50 THEN '[MODERATE EFFICACY]'
        ELSE '[POOR EFFICACY]'
    END AS efficacy_rating
FROM diagnosis_treatment
ORDER BY no_admission_rate DESC;

SELECT '---' AS separator_line;
SELECT '3. RESOURCE UTILIZATION OPTIMIZATION' AS insight_name;
WITH department_utilization AS (
    SELECT 
        d.department_id,
        d.department_name,
        d.bed_count,
        COUNT(DISTINCT a.admission_id) AS total_admissions_last_month,
        COUNT(DISTINCT CASE WHEN a.status = 'Admitted' THEN a.admission_id END) AS current_admissions,
        COUNT(DISTINCT app.appointment_id) AS appointments_last_month,
        ROUND(AVG(TIMESTAMPDIFF(HOUR, a.admission_date, a.discharge_date)), 1) AS avg_hours_occupied,
        ROUND(SUM(a.total_charges), 2) AS monthly_revenue
    FROM departments d
    LEFT JOIN admissions a ON d.department_id = a.department_id 
        AND a.admission_date >= DATE_SUB(@ref_date, INTERVAL 30 DAY)
    LEFT JOIN appointments app ON d.department_id = (SELECT department_id FROM doctors WHERE doctor_id = app.doctor_id)
        AND app.appointment_date >= DATE_SUB(@ref_date, INTERVAL 30 DAY)
    GROUP BY d.department_id, d.department_name, d.bed_count
)
SELECT 
    department_name,
    bed_count,
    current_admissions,
    total_admissions_last_month,
    appointments_last_month,
    ROUND(current_admissions * 100.0 / NULLIF(bed_count, 0), 2) AS bed_occupancy_rate,
    monthly_revenue,
    ROUND(monthly_revenue / NULLIF(bed_count, 0), 2) AS revenue_per_bed,
    CASE 
        WHEN current_admissions * 100.0 / NULLIF(bed_count, 0) > 90 THEN '[OVERUTILIZED]'
        WHEN current_admissions * 100.0 / NULLIF(bed_count, 0) > 70 THEN '[OPTIMAL]'
        WHEN current_admissions * 100.0 / NULLIF(bed_count, 0) > 40 THEN '[UNDERUTILIZED]'
        ELSE '[SEVERELY UNDERUTILIZED]'
    END AS utilization_status
FROM department_utilization
ORDER BY bed_occupancy_rate DESC;

SELECT '---' AS separator_line;
SELECT '4. DISEASE PROGRESSION ANALYSIS' AS insight_name;
WITH patient_timeline AS (
    SELECT 
        p.patient_id,
        CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
        pd.diagnosed_date,
        d.diagnosis_name,
        d.category,
        d.is_chronic,
        LAG(d.diagnosis_name) OVER (PARTITION BY p.patient_id ORDER BY pd.diagnosed_date) AS previous_diagnosis,
        LAG(pd.diagnosed_date) OVER (PARTITION BY p.patient_id ORDER BY pd.diagnosed_date) AS previous_date,
        TIMESTAMPDIFF(MONTH, 
            LAG(pd.diagnosed_date) OVER (PARTITION BY p.patient_id ORDER BY pd.diagnosed_date), 
            pd.diagnosed_date
        ) AS months_since_previous
    FROM patients p
    JOIN patient_diagnoses pd ON p.patient_id = pd.patient_id
    JOIN diagnoses d ON pd.diagnosis_id = d.diagnosis_id
)
SELECT 
    diagnosis_name,
    category,
    is_chronic,
    COUNT(DISTINCT patient_id) AS patient_count,
    AVG(months_since_previous) AS avg_months_to_next_diagnosis,
    MIN(months_since_previous) AS min_months_to_next,
    MAX(months_since_previous) AS max_months_to_next,
    GROUP_CONCAT(DISTINCT previous_diagnosis ORDER BY previous_diagnosis) AS common_previous_conditions,
    CASE 
        WHEN AVG(months_since_previous) < 12 THEN '[RAPID PROGRESSION]'
        WHEN AVG(months_since_previous) < 24 THEN '[MODERATE PROGRESSION]'
        ELSE '[SLOW PROGRESSION]'
    END AS progression_rate
FROM patient_timeline
WHERE previous_diagnosis IS NOT NULL
GROUP BY diagnosis_name, category, is_chronic
HAVING patient_count >= 1
ORDER BY avg_months_to_next_diagnosis;

SELECT '---' AS separator_line;
SELECT '5. PREDICTIVE READMISSION RISK' AS insight_name;
WITH admission_features AS (
    SELECT 
        a.admission_id,
        p.patient_id,
        CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
        TIMESTAMPDIFF(YEAR, p.date_of_birth, a.admission_date) AS age_at_admission,
        p.gender,
        d.department_name,
        COUNT(DISTINCT pd.diagnosis_id) AS chronic_condition_count,
        COUNT(DISTINCT lr.result_id) AS abnormal_labs_during_stay,
        TIMESTAMPDIFF(DAY, a.admission_date, a.discharge_date) AS length_of_stay,
        a.total_charges,
        CASE WHEN EXISTS (
            SELECT 1 FROM admissions a2 
            WHERE a2.patient_id = a.patient_id 
            AND a2.admission_date < a.admission_date
            AND TIMESTAMPDIFF(DAY, a2.discharge_date, a.admission_date) <= 30
        ) THEN 1 ELSE 0 END AS had_previous_readmission
    FROM admissions a
    JOIN patients p ON a.patient_id = p.patient_id
    JOIN departments d ON a.department_id = d.department_id
    LEFT JOIN patient_diagnoses pd ON p.patient_id = pd.patient_id 
        AND pd.diagnosed_date < a.admission_date
    LEFT JOIN lab_results lr ON p.patient_id = lr.patient_id 
        AND lr.test_date BETWEEN a.admission_date AND a.discharge_date
        AND lr.status = 'Abnormal'
    WHERE a.discharge_date IS NOT NULL
    GROUP BY a.admission_id, p.patient_id, p.first_name, p.last_name, p.date_of_birth, 
             p.gender, d.department_name, a.admission_date, a.discharge_date, a.total_charges
)
SELECT 
    patient_id,
    patient_name,
    age_at_admission,
    gender,
    department_name,
    chronic_condition_count,
    abnormal_labs_during_stay,
    length_of_stay,
    total_charges,
    had_previous_readmission,
    ROUND(
        (chronic_condition_count * 0.3) + 
        (abnormal_labs_during_stay * 0.2) + 
        (CASE WHEN length_of_stay > 7 THEN 0.2 ELSE 0 END) + 
        (CASE WHEN age_at_admission > 60 THEN 0.15 ELSE 0 END) + 
        (had_previous_readmission * 0.15), 
    2) AS readmission_risk_score,
    CASE 
        WHEN ROUND(
            (chronic_condition_count * 0.3) + 
            (abnormal_labs_during_stay * 0.2) + 
            (CASE WHEN length_of_stay > 7 THEN 0.2 ELSE 0 END) + 
            (CASE WHEN age_at_admission > 60 THEN 0.15 ELSE 0 END) + 
            (had_previous_readmission * 0.15), 
        2) > 0.7 THEN '[HIGH READMISSION RISK]'
        WHEN ROUND(
            (chronic_condition_count * 0.3) + 
            (abnormal_labs_during_stay * 0.2) + 
            (CASE WHEN length_of_stay > 7 THEN 0.2 ELSE 0 END) + 
            (CASE WHEN age_at_admission > 60 THEN 0.15 ELSE 0 END) + 
            (had_previous_readmission * 0.15), 
        2) > 0.4 THEN '[MODERATE RISK]'
        ELSE '[LOW RISK]'
    END AS risk_category
FROM admission_features
ORDER BY readmission_risk_score DESC
LIMIT 15;
SELECT '---' AS separator_line;
SELECT 'COST-BENEFIT ANALYSIS OF TREATMENTS' AS insight_name;
WITH treatment_outcomes AS (
    SELECT 
        m.medication_name,
        COALESCE(d.diagnosis_name, 'General Treatment') AS diagnosis_name,
        COUNT(DISTINCT pr.patient_id) AS patient_count,
        ROUND(AVG(m.unit_cost * pr.quantity * pr.duration_days / 30), 2) AS avg_monthly_cost,
        COUNT(DISTINCT pr.patient_id) - COUNT(DISTINCT a.admission_id) AS patients_without_readmission,
        ROUND(
            (COUNT(DISTINCT pr.patient_id) - COUNT(DISTINCT a.admission_id)) * 100.0 / 
            NULLIF(COUNT(DISTINCT pr.patient_id), 0), 
            2
        ) AS success_rate_percentage,
        ROUND(AVG(a.total_charges), 2) AS avg_admission_cost_when_failed
    FROM prescriptions pr
    JOIN medications m ON pr.medication_id = m.medication_id
    JOIN patients p ON pr.patient_id = p.patient_id
    LEFT JOIN patient_diagnoses pd ON p.patient_id = pd.patient_id
    LEFT JOIN diagnoses d ON pd.diagnosis_id = d.diagnosis_id
    LEFT JOIN admissions a ON p.patient_id = a.patient_id 
        AND a.admission_date > pr.prescribed_date
        AND TIMESTAMPDIFF(DAY, pr.prescribed_date, a.admission_date) <= 90
    WHERE pr.status IN ('Active', 'Completed') 
    GROUP BY m.medication_name, COALESCE(d.diagnosis_name, 'General Treatment')
    HAVING COUNT(DISTINCT pr.patient_id) >= 1
)
SELECT 
    medication_name,
    diagnosis_name,
    patient_count,
    avg_monthly_cost,
    success_rate_percentage,
    avg_admission_cost_when_failed,
    ROUND(avg_monthly_cost * 12 / NULLIF(success_rate_percentage, 100), 2) AS cost_per_percentage_point,
    CASE 
        WHEN success_rate_percentage >= 85 AND avg_monthly_cost < 100 THEN '[HIGHLY COST-EFFECTIVE]'
        WHEN success_rate_percentage >= 70 AND avg_monthly_cost < 200 THEN '[COST-EFFECTIVE]'
        WHEN success_rate_percentage >= 50 THEN '[MODERATELY EFFECTIVE]'
        WHEN success_rate_percentage > 0 THEN '[NEEDS IMPROVEMENT]'
        ELSE '[INSUFFICIENT DATA]'
    END AS cost_benefit_rating
FROM treatment_outcomes
ORDER BY success_rate_percentage DESC, avg_monthly_cost ASC;
SELECT '=========================================' AS separator_line;
SELECT 'ADVANCED HEALTHCARE INSIGHTS COMPLETED!' AS final_status;
SELECT '=========================================' AS separator_line;

SELECT '=========================================' AS separator_line;
SELECT 'REAL-TIME MEDICAL DASHBOARD' AS title;
SELECT '=========================================' AS separator_line;
SELECT '1. TODAYS HOSPITAL OVERVIEW' AS section;
SELECT 
    'Current Time' AS metric,
    DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s') AS value
UNION ALL
SELECT 
    'Total Patients',
    FORMAT((SELECT COUNT(*) FROM patients), 0)
UNION ALL
SELECT 
    'Currently Admitted',
    (SELECT COUNT(DISTINCT patient_id) FROM admissions WHERE status = 'Admitted')
UNION ALL
SELECT 
    "Today's Appointments",
    (SELECT COUNT(*) FROM appointments WHERE DATE(appointment_date) = CURDATE())
UNION ALL
SELECT 
    'Emergency Cases Today',
    (SELECT COUNT(*) FROM admissions WHERE DATE(admission_date) = CURDATE() AND admission_type = 'Emergency')
UNION ALL
SELECT 
    'Pending Lab Results',
    (SELECT COUNT(*) FROM lab_results WHERE status = 'Pending')
UNION ALL
SELECT 
    'Critical Alerts',
    (SELECT COUNT(*) FROM lab_results WHERE is_critical = TRUE AND test_date = CURDATE())
UNION ALL
SELECT 
    'Bed Occupancy Rate',
    CONCAT(ROUND(
        (SELECT COUNT(*) FROM admissions WHERE status = 'Admitted') * 100.0 / 
        NULLIF((SELECT SUM(bed_count) FROM departments), 0), 1), '%');

SELECT '---' AS separator_line;
SELECT '2. DEPARTMENT STATUS BOARD' AS section;
SELECT 
    d.department_name,
    d.bed_count,
    (SELECT COUNT(*) FROM admissions a WHERE a.department_id = d.department_id AND a.status = 'Admitted') AS occupied_beds,
    (SELECT COUNT(*) FROM doctors doc WHERE doc.department_id = d.department_id AND doc.is_active = TRUE) AS active_doctors,
    (SELECT COUNT(*) FROM appointments app 
     WHERE (SELECT department_id FROM doctors WHERE doctor_id = app.doctor_id) = d.department_id
     AND DATE(app.appointment_date) = CURDATE()) AS todays_appointments,
    (SELECT ROUND(AVG(TIMESTAMPDIFF(MINUTE, appointment_date, NOW())), 0) 
     FROM appointments app 
     WHERE (SELECT department_id FROM doctors WHERE doctor_id = app.doctor_id) = d.department_id
     AND DATE(app.appointment_date) = CURDATE()
     AND app.status = 'Scheduled') AS avg_wait_time_minutes,
    CASE 
        WHEN (SELECT COUNT(*) FROM admissions a WHERE a.department_id = d.department_id AND a.status = 'Admitted') * 100.0 / d.bed_count > 90 THEN '[HIGH OCCUPANCY]'
        WHEN (SELECT COUNT(*) FROM admissions a WHERE a.department_id = d.department_id AND a.status = 'Admitted') * 100.0 / d.bed_count > 70 THEN '[MODERATE]'
        ELSE '[AVAILABLE]'
    END AS status
FROM departments d
WHERE d.is_active = TRUE
ORDER BY occupied_beds DESC;

SELECT '---' AS separator_line;
SELECT '3. EMERGENCY DEPARTMENT METRICS' AS section;
SELECT 
    'Last 24 Hours' AS time_period,
    COUNT(*) AS total_emergency_cases,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, admission_date, 
        CASE WHEN discharge_date IS NOT NULL THEN discharge_date ELSE NOW() END)), 0) AS avg_processing_minutes,
    COUNT(DISTINCT attending_doctor_id) AS doctors_on_duty,
    ROUND(SUM(total_charges), 2) AS emergency_revenue,
    CONCAT(ROUND(COUNT(CASE WHEN TIMESTAMPDIFF(MINUTE, admission_date, discharge_date) < 120 THEN 1 END) * 100.0 / COUNT(*), 1), '%') AS fast_track_rate
FROM admissions 
WHERE admission_type = 'Emergency'
AND admission_date >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
UNION ALL
SELECT 
    'Last 7 Days' AS time_period,
    COUNT(*) AS total_emergency_cases,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, admission_date, 
        CASE WHEN discharge_date IS NOT NULL THEN discharge_date ELSE NOW() END)), 0) AS avg_processing_minutes,
    COUNT(DISTINCT attending_doctor_id) AS doctors_on_duty,
    ROUND(SUM(total_charges), 2) AS emergency_revenue,
    CONCAT(ROUND(COUNT(CASE WHEN TIMESTAMPDIFF(MINUTE, admission_date, discharge_date) < 120 THEN 1 END) * 100.0 / COUNT(*), 1), '%') AS fast_track_rate
FROM admissions 
WHERE admission_type = 'Emergency'
AND admission_date >= DATE_SUB(NOW(), INTERVAL 7 DAY);

SELECT '---' AS separator_line;
SELECT '4. CRITICAL PATIENT ALERTS (ALL TIME)' AS section;
SELECT 
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    a.room_number,
    a.bed_number,
    d.department_name,
    CONCAT(doc.first_name, ' ', doc.last_name) AS attending_doctor,
    TIMESTAMPDIFF(HOUR, a.admission_date, NOW()) AS hours_admitted,
    lt.test_name,
    lr.result_value,
    lt.normal_range_min,
    lt.normal_range_max,
    lt.unit,
    lr.test_date,
    CASE 
        WHEN lr.result_value > lt.normal_range_max * 1.5 THEN '[CRITICALLY HIGH]'
        WHEN lr.result_value < lt.normal_range_min * 0.5 THEN '[CRITICALLY LOW]'
        ELSE '[ABNORMAL]'
    END AS alert_level
FROM lab_results lr
JOIN lab_tests lt ON lr.test_id = lt.test_id
JOIN patients p ON lr.patient_id = p.patient_id
LEFT JOIN admissions a ON p.patient_id = a.patient_id AND a.status = 'Admitted'
LEFT JOIN departments d ON a.department_id = d.department_id
LEFT JOIN doctors doc ON a.attending_doctor_id = doc.doctor_id
WHERE lr.is_critical = TRUE
ORDER BY lr.test_date DESC;

SELECT '---' AS separator_line;
SELECT '5. PHYSICIAN PERFORMANCE TODAY' AS section;
SELECT 
    doc.doctor_id,
    CONCAT(doc.first_name, ' ', doc.last_name) AS doctor_name,
    doc.specialization,
    dep.department_name,
    COUNT(DISTINCT app.appointment_id) AS todays_appointments,
    COUNT(DISTINCT CASE WHEN app.status = 'Completed' THEN app.appointment_id END) AS completed_appointments,
    COUNT(DISTINCT pr.prescription_id) AS prescriptions_today,
    COUNT(DISTINCT CASE WHEN a.admission_date >= CURDATE() THEN a.admission_id END) AS new_admissions,
    ROUND(AVG(app.duration_minutes), 0) AS avg_appointment_minutes,
    CONCAT(ROUND(COUNT(DISTINCT CASE WHEN app.status = 'Completed' THEN app.appointment_id END) * 100.0 / 
           NULLIF(COUNT(DISTINCT app.appointment_id), 0), 1), '%') AS completion_rate
FROM doctors doc
LEFT JOIN departments dep ON doc.department_id = dep.department_id
LEFT JOIN appointments app ON doc.doctor_id = app.doctor_id AND DATE(app.appointment_date) = CURDATE()
LEFT JOIN prescriptions pr ON doc.doctor_id = pr.doctor_id AND DATE(pr.prescribed_date) = CURDATE()
LEFT JOIN admissions a ON doc.doctor_id = a.attending_doctor_id AND DATE(a.admission_date) = CURDATE()
WHERE doc.is_active = TRUE
GROUP BY doc.doctor_id, doc.first_name, doc.last_name, doc.specialization, dep.department_name
HAVING todays_appointments > 0 OR prescriptions_today > 0 OR new_admissions > 0
ORDER BY todays_appointments DESC;

SELECT '---' AS separator_line;
SELECT '6. REVENUE DASHBOARD' AS section;
SELECT 
    'Today' AS period,
    ROUND(SUM(CASE WHEN DATE(bill_date) = CURDATE() THEN total_amount ELSE 0 END), 2) AS total_revenue,
    ROUND(SUM(CASE WHEN DATE(bill_date) = CURDATE() THEN insurance_covered ELSE 0 END), 2) AS insurance_revenue,
    ROUND(SUM(CASE WHEN DATE(bill_date) = CURDATE() THEN patient_payable ELSE 0 END), 2) AS patient_revenue,
    ROUND(SUM(CASE WHEN DATE(bill_date) = CURDATE() AND payment_status = 'Paid' THEN patient_payable ELSE 0 END), 2) AS collected_today
FROM billing
UNION ALL
SELECT 
    'This Week',
    ROUND(SUM(CASE WHEN bill_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) THEN total_amount ELSE 0 END), 2),
    ROUND(SUM(CASE WHEN bill_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) THEN insurance_covered ELSE 0 END), 2),
    ROUND(SUM(CASE WHEN bill_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) THEN patient_payable ELSE 0 END), 2),
    ROUND(SUM(CASE WHEN bill_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) AND payment_status = 'Paid' THEN patient_payable ELSE 0 END), 2)
FROM billing
UNION ALL
SELECT 
    'This Month',
    ROUND(SUM(CASE WHEN MONTH(bill_date) = MONTH(CURDATE()) AND YEAR(bill_date) = YEAR(CURDATE()) THEN total_amount ELSE 0 END), 2),
    ROUND(SUM(CASE WHEN MONTH(bill_date) = MONTH(CURDATE()) AND YEAR(bill_date) = YEAR(CURDATE()) THEN insurance_covered ELSE 0 END), 2),
    ROUND(SUM(CASE WHEN MONTH(bill_date) = MONTH(CURDATE()) AND YEAR(bill_date) = YEAR(CURDATE()) THEN patient_payable ELSE 0 END), 2),
    ROUND(SUM(CASE WHEN MONTH(bill_date) = MONTH(CURDATE()) AND YEAR(bill_date) = YEAR(CURDATE()) AND payment_status = 'Paid' THEN patient_payable ELSE 0 END), 2)
FROM billing;

SELECT '---' AS separator_line;
SELECT '7. MEDICATION INVENTORY ALERTS' AS section;
WITH medication_usage AS (
    SELECT 
        m.medication_id,
        m.medication_name,
        m.generic_name,
        COUNT(DISTINCT pr.prescription_id) AS prescriptions_last_month,
        SUM(pr.quantity) AS total_quantity_prescribed,
        AVG(pr.quantity) AS avg_quantity_per_prescription,
        MAX(pr.prescribed_date) AS last_prescribed_date
    FROM medications m
    LEFT JOIN prescriptions pr ON m.medication_id = pr.medication_id
        AND pr.prescribed_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    GROUP BY m.medication_id, m.medication_name, m.generic_name
)
SELECT 
    medication_name,
    generic_name,
    prescriptions_last_month,
    total_quantity_prescribed,
    avg_quantity_per_prescription,
    DATEDIFF(CURDATE(), last_prescribed_date) AS days_since_last_prescription,
    CASE 
        WHEN prescriptions_last_month = 0 AND DATEDIFF(CURDATE(), last_prescribed_date) > 90 THEN '[LOW USAGE - REVIEW]'
        WHEN prescriptions_last_month > 20 AND DATEDIFF(CURDATE(), last_prescribed_date) < 3 THEN '[HIGH USAGE - RESTOCK]'
        WHEN prescriptions_last_month > 10 THEN '[ACTIVE - MONITOR]'
        ELSE '[NORMAL]'
    END AS inventory_status
FROM medication_usage
ORDER BY prescriptions_last_month DESC;

SELECT '---' AS separator_line;
SELECT '8. PATIENT SATISFACTION INDICATORS' AS section;
SELECT 
    'Appointment Completion Rate' AS metric,
    CONCAT(
        ROUND(
            (SELECT COUNT(*) FROM appointments WHERE status = 'Completed') * 100.0 /
            NULLIF((SELECT COUNT(*) FROM appointments), 0), 
        1), 
        '%'
    ) AS value,
    'Completion percentage' AS description,
    CASE 
        WHEN (SELECT COUNT(*) FROM appointments WHERE status = 'Completed') * 100.0 /
             NULLIF((SELECT COUNT(*) FROM appointments), 0) > 80 THEN '[EXCELLENT]'
        WHEN (SELECT COUNT(*) FROM appointments WHERE status = 'Completed') * 100.0 /
             NULLIF((SELECT COUNT(*) FROM appointments), 0) > 60 THEN '[GOOD]'
        ELSE '[NEEDS IMPROVEMENT]'
    END AS status
UNION ALL
SELECT 
    'Average Hospital Stay' AS metric,
    CONCAT(
        ROUND(AVG(TIMESTAMPDIFF(DAY, admission_date, discharge_date)), 1),
        ' days'
    ) AS value,
    'Length of stay for discharged patients' AS description,
    CASE 
        WHEN AVG(TIMESTAMPDIFF(DAY, admission_date, discharge_date)) < 3 THEN '[EXCELLENT]'
        WHEN AVG(TIMESTAMPDIFF(DAY, admission_date, discharge_date)) < 5 THEN '[GOOD]'
        ELSE '[LONG STAY - REVIEW]'
    END AS status
FROM admissions 
WHERE discharge_date IS NOT NULL
UNION ALL
SELECT 
    'Medication Adherence' AS metric,
    CONCAT(
        ROUND(
            (SELECT COUNT(*) FROM prescriptions WHERE status = 'Completed') * 100.0 /
            NULLIF((SELECT COUNT(*) FROM prescriptions), 0), 
        1), 
        '%'
    ) AS value,
    'Completed prescriptions' AS description,
    CASE 
        WHEN (SELECT COUNT(*) FROM prescriptions WHERE status = 'Completed') * 100.0 /
             NULLIF((SELECT COUNT(*) FROM prescriptions), 0) > 75 THEN '[GOOD]'
        WHEN (SELECT COUNT(*) FROM prescriptions WHERE status = 'Completed') * 100.0 /
             NULLIF((SELECT COUNT(*) FROM prescriptions), 0) > 50 THEN '[MODERATE]'
        ELSE '[POOR - FOLLOW UP NEEDED]'
    END AS status;

SELECT '---' AS separator_line;
SELECT '9. ALL SCHEDULED APPOINTMENTS' AS section;
SELECT 
    app.appointment_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    TIMESTAMPDIFF(YEAR, p.date_of_birth, CURDATE()) AS patient_age,
    CONCAT(doc.first_name, ' ', doc.last_name) AS doctor_name,
    doc.specialization,
    dep.department_name,
    app.appointment_date,
    app.reason,
    app.consultation_room,
    CASE 
        WHEN app.appointment_date > NOW() THEN '[UPCOMING]'
        ELSE '[PAST]'
    END AS status
FROM appointments app
JOIN patients p ON app.patient_id = p.patient_id
JOIN doctors doc ON app.doctor_id = doc.doctor_id
JOIN departments dep ON doc.department_id = dep.department_id
WHERE app.status = 'Scheduled'
ORDER BY app.appointment_date DESC;

SELECT '---' AS separator_line;
SELECT '10. SYSTEM HEALTH CHECK' AS section;
SELECT 
    'Data Integrity' AS check_item,
    CASE 
        WHEN (SELECT COUNT(*) FROM appointments WHERE doctor_id NOT IN (SELECT doctor_id FROM doctors)) = 0 
             AND (SELECT COUNT(*) FROM admissions WHERE patient_id NOT IN (SELECT patient_id FROM patients)) = 0 
        THEN '[PASS]' 
        ELSE '[FAIL - Orphaned Records]'
    END AS status,
    'Foreign key relationships intact' AS details
UNION ALL
SELECT 
    'Active Patients',
    CASE 
        WHEN (SELECT COUNT(*) FROM patients WHERE is_active = TRUE) > 0 THEN '[PASS]'
        ELSE '[WARNING - No active patients]'
    END,
    CONCAT((SELECT COUNT(*) FROM patients WHERE is_active = TRUE), ' active patients')
UNION ALL
SELECT 
    'Pending Lab Results',
    CASE 
        WHEN (SELECT COUNT(*) FROM lab_results WHERE status = 'Pending' AND test_date < DATE_SUB(CURDATE(), INTERVAL 2 DAY)) > 0 THEN '[ALERT - Old pending results]'
        WHEN (SELECT COUNT(*) FROM lab_results WHERE status = 'Pending') > 0 THEN '[WARNING - Pending results]'
        ELSE '[PASS]'
    END,
    CONCAT((SELECT COUNT(*) FROM lab_results WHERE status = 'Pending'), ' pending results')
UNION ALL
SELECT 
    'Unbilled Admissions',
    CASE 
        WHEN (SELECT COUNT(*) FROM admissions a 
              WHERE a.discharge_date IS NOT NULL 
              AND NOT EXISTS (SELECT 1 FROM billing b WHERE b.admission_id = a.admission_id)) > 0 
        THEN '[ALERT - Unbilled discharges]'
        ELSE '[PASS]'
    END,
    CONCAT((SELECT COUNT(*) FROM admissions a 
            WHERE a.discharge_date IS NOT NULL 
            AND NOT EXISTS (SELECT 1 FROM billing b WHERE b.admission_id = a.admission_id)), ' unbilled discharges')
UNION ALL
SELECT 
    'Medication Stock',
    CASE 
        WHEN (SELECT COUNT(*) FROM medications WHERE medication_id NOT IN (SELECT medication_id FROM prescriptions WHERE prescribed_date >= DATE_SUB(CURDATE(), INTERVAL 90 DAY))) > 10 
        THEN '[INFO - Low usage medications]'
        ELSE '[PASS]'
    END,
    CONCAT((SELECT COUNT(*) FROM medications WHERE medication_id NOT IN 
    (SELECT medication_id FROM prescriptions WHERE prescribed_date >= DATE_SUB(CURDATE(), INTERVAL 90 DAY))), ' rarely used medications');
SELECT '=========================================' AS separator_line;
SELECT 'MEDICAL DASHBOARD COMPLETED!' AS final_status;
SELECT '=========================================' AS separator_line;