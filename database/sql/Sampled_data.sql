-- ========================================
-- COMPREHENSIVE ACCOUNTING & FINANCE DATA
-- ========================================
-- This file contains ALL sample data for the accounting system
-- Run this after database/sql/schema.sql to populate the database with comprehensive test data
-- 
-- 
-- Instructions:
-- 1. Open phpMyAdmin: http://localhost/phpmyadmin
-- 2. Click "BankingDB" database
-- 3. Click "SQL" tab
-- 4. Copy this entire file and paste into SQL box
-- 5. Click "Go" button
-- 6. Wait for success messages
-- ========================================

USE BankingDB;

-- Insert the admin user
-- Password: admin123 (properly hashed with PASSWORD_DEFAULT)
INSERT INTO users (id, username, password_hash, email, full_name, is_active, created_at) 
VALUES (
    1,
    'admin',
    '$2y$10$0G6Iza9uWgZ1y0ea/5lf7.P3qcY6CVgisAdKlNvq.ZnYYc6F.xDXS',
    'admin@system.com',
    'System Administrator',
    TRUE,
    NOW()
) ON DUPLICATE KEY UPDATE 
    username = VALUES(username),
    password_hash = VALUES(password_hash);

-- Insert the finance admin user
-- Email: finance.admin@evergreen.com
-- Username: finance.admin
-- Password: Finance2025
INSERT INTO users (id, username, password_hash, email, full_name, is_active, created_at) 
VALUES (
    2,
    'finance.admin',
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    'finance.admin@evergreen.com',
    'Finance Administrator',
    TRUE,
    NOW()
) ON DUPLICATE KEY UPDATE 
    username = VALUES(username),
    password_hash = VALUES(password_hash);

-- Insert default roles
INSERT INTO roles (name, description) VALUES
('Administrator', 'Full system access with all privileges'),
('Accounting Admin', 'Full administrative access to accounting and finance modules')
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- Assign admin role to the admin user
INSERT INTO user_roles (user_id, role_id) VALUES (1, 1) ON DUPLICATE KEY UPDATE user_id = VALUES(user_id);

-- Assign Accounting Admin role to the finance admin user
INSERT INTO user_roles (user_id, role_id) VALUES (2, 2) ON DUPLICATE KEY UPDATE user_id = VALUES(user_id);

-- ========================================

-- ========================================
-- 3. JOURNAL TYPES & FISCAL PERIODS
-- ========================================

-- Insert comprehensive journal types
INSERT INTO journal_types (code, name, auto_reversing, description) VALUES
('GJ', 'General Journal', FALSE, 'General journal entries'),
('CR', 'Cash Receipt', FALSE, 'Cash receipts and collections'),
('CD', 'Cash Disbursement', FALSE, 'Cash payments and disbursements'),
('PR', 'Payroll', FALSE, 'Payroll journal entries'),
('AP', 'Accounts Payable', FALSE, 'Supplier invoices and payments'),
('AR', 'Accounts Receivable', FALSE, 'Customer invoices and collections'),
('AJ', 'Adjusting Journal', TRUE, 'Period-end adjusting entries'),
('REV', 'Reversing Entry', TRUE, 'Reversing entries for accruals'),
('CLOSE', 'Closing Entry', FALSE, 'Year-end closing entries'),
('OPEN', 'Opening Entry', FALSE, 'Year-beginning opening entries'),
('SAL', 'Sales Journal', FALSE, 'Sales transactions'),
('PUR', 'Purchase Journal', FALSE, 'Purchase transactions'),
('BANK', 'Bank Reconciliation', FALSE, 'Bank reconciliation entries')
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- Insert fiscal periods for multiple years
INSERT INTO fiscal_periods (period_name, start_date, end_date, status) VALUES
-- 2024 Quarters
('FY2024-Q1', '2024-01-01', '2024-03-31', 'closed'),
('FY2024-Q2', '2024-04-01', '2024-06-30', 'closed'),
('FY2024-Q3', '2024-07-01', '2024-09-30', 'closed'),
('FY2024-Q4', '2024-10-01', '2024-12-31', 'closed'),

-- 2025 Quarters
('FY2025-Q1', '2025-01-01', '2025-03-31', 'open'),
('FY2025-Q2', '2025-04-01', '2025-06-30', 'open'),
('FY2025-Q3', '2025-07-01', '2025-09-30', 'open'),
('FY2025-Q4', '2025-10-01', '2025-12-31', 'open'),

-- Monthly periods for 2025
('January 2025', '2025-01-01', '2025-01-31', 'open'),
('February 2025', '2025-02-01', '2025-02-28', 'open'),
('March 2025', '2025-03-01', '2025-03-31', 'open'),
('April 2025', '2025-04-01', '2025-04-30', 'open'),
('May 2025', '2025-05-01', '2025-05-31', 'open'),
('June 2025', '2025-06-01', '2025-06-30', 'open'),
('July 2025', '2025-07-01', '2025-07-31', 'open'),
('August 2025', '2025-08-01', '2025-08-31', 'open'),
('September 2025', '2025-09-01', '2025-09-30', 'open'),
('October 2025', '2025-10-01', '2025-10-31', 'open'),
('November 2025', '2025-11-01', '2025-11-30', 'open'),
('December 2025', '2025-12-01', '2025-12-31', 'open'),

-- 2026 Quarters
('FY2026-Q1', '2026-01-01', '2026-03-31', 'open'),
('FY2026-Q2', '2026-04-01', '2026-06-30', 'open'),
('FY2026-Q3', '2026-07-01', '2026-09-30', 'open'),
('FY2026-Q4', '2026-10-01', '2026-12-31', 'open'),

-- Monthly periods for 2026
('January 2026', '2026-01-01', '2026-01-31', 'open'),
('February 2026', '2026-02-01', '2026-02-28', 'open'),
('March 2026', '2026-03-01', '2026-03-31', 'open'),
('April 2026', '2026-04-01', '2026-04-30', 'open'),
('May 2026', '2026-05-01', '2026-05-31', 'open'),
('June 2026', '2026-06-01', '2026-06-30', 'open'),
('July 2026', '2026-07-01', '2026-07-31', 'open'),
('August 2026', '2026-08-01', '2026-08-31', 'open'),
('September 2026', '2026-09-01', '2026-09-30', 'open'),
('October 2026', '2026-10-01', '2026-10-31', 'open'),
('November 2026', '2026-11-01', '2026-11-30', 'open'),
('December 2026', '2026-12-01', '2026-12-31', 'open')
ON DUPLICATE KEY UPDATE period_name = VALUES(period_name);

-- ========================================
-- 4. HRIS MODULE DATA (Department & Position)
-- ========================================

-- Insert departments
INSERT INTO department (department_id, department_name, description) VALUES
(1, 'IT', 'Information Technology Department'),
(2, 'Human Resources', 'Human Resources Department'),
(3, 'Finance', 'Finance and Accounting Department'),
(4, 'Marketing', 'Marketing and Sales Department'),
(5, 'Operations', 'Operations and Logistics Department'),
(6, 'Customer Service', 'Customer Service Department'),
(7, 'Sales', 'Sales Department')
ON DUPLICATE KEY UPDATE department_name = VALUES(department_name);

-- Insert positions (using backticks because 'position' is a reserved word)
INSERT INTO `position` (position_id, position_title, job_description, salary_grade) VALUES
(1, 'CTO', 'Chief Technology Officer', 15),
(2, 'CFO', 'Chief Financial Officer', 15),
(3, 'COO', 'Chief Operating Officer', 15),
(4, 'Marketing Director', 'Director of Marketing', 14),
(5, 'HR Manager', 'Human Resources Manager', 12),
(6, 'CS Manager', 'Customer Service Manager', 12),
(7, 'Sales Manager', 'Sales Manager', 12),
(8, 'Senior Accountant', 'Senior Accountant', 10),
(9, 'Senior Developer', 'Senior Software Developer', 11),
(10, 'Marketing Specialist', 'Marketing Specialist', 9),
(11, 'Software Developer', 'Software Developer', 9),
(12, 'Accountant', 'Accountant', 8),
(13, 'Sales Executive', 'Sales Executive', 8),
(14, 'CS Representative', 'Customer Service Representative', 7),
(15, 'Operations Coordinator', 'Operations Coordinator', 8),
(16, 'Content Creator', 'Content Creator', 7),
(17, 'Junior Developer', 'Junior Software Developer', 7),
(18, 'Payroll Specialist', 'Payroll Specialist', 8),
(19, 'Sales Representative', 'Sales Representative', 7),
(20, 'Warehouse Supervisor', 'Warehouse Supervisor', 9),
(21, 'Accounts Payable Clerk', 'Accounts Payable Clerk', 7),
(22, 'System Administrator', 'System Administrator', 9),
(23, 'Social Media Manager', 'Social Media Manager', 8),
(24, 'Account Manager', 'Account Manager', 9)
ON DUPLICATE KEY UPDATE position_title = VALUES(position_title);

-- ========================================
-- 4A. EMPLOYEE TABLE DATA (HRIS Core)
-- ========================================
-- Insert employee records linking to departments and positions
-- This connects HRIS module to the payroll system

INSERT INTO employee (employee_id, first_name, last_name, middle_name, gender, birth_date, contact_number, email, address, house_number, street, barangay, city, province, secondary_email, secondary_contact_number, hire_date, department_id, position_id, employment_status) VALUES
-- Management (C-Suite & Directors)
(1, 'Juan', 'Santos', 'Carlos', 'Male', '1980-05-15', '09171234567', 'juan.santos@company.com', 'Makati City, Metro Manila', '123', 'Ayala Avenue', 'Bel-Air', 'Makati City', 'Metro Manila', NULL, NULL, '2020-01-15', 2, 5, 'Active'),
(2, 'Maria Elena', 'Rodriguez', NULL, 'Female', '1978-03-20', '09171234568', 'maria.rodriguez@company.com', 'BGC, Taguig City', '456', 'Bonifacio High Street', 'Fort Bonifacio', 'Taguig City', 'Metro Manila', NULL, NULL, '2019-06-01', 3, 2, 'Active'),
(3, 'Jose Miguel', 'Cruz', NULL, 'Male', '1982-08-10', '09171234569', 'jose.cruz@company.com', 'Ortigas, Pasig City', '789', 'Ortigas Avenue', 'Ortigas Center', 'Pasig City', 'Metro Manila', NULL, NULL, '2021-02-01', 1, 1, 'Active'),
(4, 'Ana Patricia', 'Lopez', NULL, 'Female', '1985-11-25', '09171234570', 'ana.lopez@company.com', 'Mandaluyong City', '321', 'Shaw Boulevard', 'Wack-Wack', 'Mandaluyong City', 'Metro Manila', NULL, NULL, '2020-03-15', 4, 4, 'Active'),
(5, 'Roberto Antonio', 'Garcia', NULL, 'Male', '1981-07-30', '09171234571', 'roberto.garcia@company.com', 'Quezon City', '654', 'EDSA', 'Cubao', 'Quezon City', 'Metro Manila', NULL, NULL, '2019-09-01', 5, 3, 'Active'),
-- Senior Staff (Managers & Senior Specialists)
(6, 'Carmen Sofia', 'Martinez', NULL, 'Female', '1987-04-12', '09171234572', 'carmen.martinez@company.com', 'San Juan City', '987', 'Wilson Street', 'Greenhills', 'San Juan City', 'Metro Manila', NULL, NULL, '2021-05-01', 6, 6, 'Active'),
(7, 'Fernando Luis', 'Torres', NULL, 'Male', '1986-09-18', '09171234573', 'fernando.torres@company.com', 'Pasay City', '147', 'Roxas Boulevard', 'Malate', 'Pasay City', 'Metro Manila', NULL, NULL, '2020-07-01', 7, 7, 'Active'),
(8, 'Isabella Rose', 'Flores', NULL, 'Female', '1989-12-05', '09171234574', 'isabella.flores@company.com', 'Makati City', '258', 'Paseo de Roxas', 'Legaspi Village', 'Makati City', 'Metro Manila', NULL, NULL, '2021-01-15', 3, 8, 'Active'),
(9, 'Miguel Angel', 'Reyes', NULL, 'Male', '1988-06-22', '09171234575', 'miguel.reyes@company.com', 'Taguig City', '369', 'C5 Road', 'Bicutan', 'Taguig City', 'Metro Manila', NULL, NULL, '2020-08-01', 1, 9, 'Active'),
(10, 'Sofia Grace', 'Villanueva', NULL, 'Female', '1990-02-14', '09171234576', 'sofia.villanueva@company.com', 'Mandaluyong City', '741', 'Meralco Avenue', 'San Antonio', 'Mandaluyong City', 'Metro Manila', NULL, NULL, '2021-03-01', 4, 10, 'Active'),
-- Mid-level Staff
(11, 'Carlos Eduardo', 'Mendoza', NULL, 'Male', '1992-10-08', '09171234577', 'carlos.mendoza@company.com', 'Pasig City', '852', 'Julia Vargas Avenue', 'Ortigas', 'Pasig City', 'Metro Manila', NULL, NULL, '2022-01-15', 1, 11, 'Active'),
(12, 'Patricia Isabel', 'Gutierrez', NULL, 'Female', '1991-03-17', '09171234578', 'patricia.gutierrez@company.com', 'Quezon City', '963', 'Quezon Avenue', 'Diliman', 'Quezon City', 'Metro Manila', NULL, NULL, '2022-02-01', 3, 12, 'Active'),
(13, 'Ricardo Manuel', 'Herrera', NULL, 'Male', '1990-07-23', '09171234579', 'ricardo.herrera@company.com', 'Manila City', '159', 'Taft Avenue', 'Ermita', 'Manila City', 'Metro Manila', NULL, NULL, '2021-06-01', 7, 13, 'Active'),
(14, 'Gabriela Alejandra', 'Morales', NULL, 'Female', '1993-05-11', '09171234580', 'gabriela.morales@company.com', 'Makati City', '357', 'Buendia Avenue', 'Pio del Pilar', 'Makati City', 'Metro Manila', NULL, NULL, '2022-03-01', 6, 14, 'Active'),
(15, 'Diego Fernando', 'Ramos', NULL, 'Male', '1992-11-29', '09171234581', 'diego.ramos@company.com', 'Taguig City', '468', 'McKinley Road', 'McKinley Hill', 'Taguig City', 'Metro Manila', NULL, NULL, '2021-09-01', 5, 15, 'Active'),
-- Junior Staff & Support Roles
(16, 'Valentina Sofia', 'Castillo', NULL, 'Female', '1994-08-06', '09171234582', 'valentina.castillo@company.com', 'Pasig City', '570', 'C. Raymundo Avenue', 'Maybunga', 'Pasig City', 'Metro Manila', NULL, NULL, '2022-05-01', 4, 16, 'Active'),
(17, 'Sebastian Alejandro', 'Vega', NULL, 'Male', '1993-12-19', '09171234583', 'sebastian.vega@company.com', 'Quezon City', '681', 'Commonwealth Avenue', 'Batasan Hills', 'Quezon City', 'Metro Manila', NULL, NULL, '2022-04-15', 1, 17, 'Active'),
(18, 'Camila Esperanza', 'Ruiz', NULL, 'Female', '1992-01-31', '09171234584', 'camila.ruiz@company.com', 'Makati City', '792', 'Chino Roces Avenue', 'San Antonio', 'Makati City', 'Metro Manila', NULL, NULL, '2021-11-01', 3, 18, 'Active'),
(19, 'Nicolas Gabriel', 'Silva', NULL, 'Male', '1994-09-14', '09171234585', 'nicolas.silva@company.com', 'Mandaluyong City', '803', 'Boni Avenue', 'Barangka', 'Mandaluyong City', 'Metro Manila', NULL, NULL, '2022-06-01', 7, 19, 'Active'),
(20, 'Lucia Esperanza', 'Jimenez', NULL, 'Female', '1995-04-27', '09171234586', 'lucia.jimenez@company.com', 'Pasay City', '914', 'Macapagal Boulevard', 'Mall of Asia', 'Pasay City', 'Metro Manila', NULL, NULL, '2022-07-01', 6, 14, 'Active'),
-- Additional Staff
(21, 'Andres Felipe', 'Castro', NULL, 'Male', '1991-10-03', '09171234587', 'andres.castro@company.com', 'Taguig City', '025', 'Upper Bicutan Road', 'Upper Bicutan', 'Taguig City', 'Metro Manila', NULL, NULL, '2021-10-01', 5, 20, 'Active'),
(22, 'Mariana Beatriz', 'Ortega', NULL, 'Female', '1993-06-16', '09171234588', 'mariana.ortega@company.com', 'Quezon City', '136', 'Katipunan Avenue', 'Loyola Heights', 'Quezon City', 'Metro Manila', NULL, NULL, '2022-01-01', 3, 21, 'Active'),
(23, 'Santiago Ignacio', 'Pena', NULL, 'Male', '1990-02-28', '09171234589', 'santiago.pena@company.com', 'Makati City', '247', 'Senator Gil Puyat Avenue', 'Bel-Air', 'Makati City', 'Metro Manila', NULL, NULL, '2021-07-15', 1, 22, 'Active'),
(24, 'Daniela Fernanda', 'Vargas', NULL, 'Female', '1994-11-09', '09171234590', 'daniela.vargas@company.com', 'Pasig City', '358', 'Shaw Boulevard', 'Kapitolyo', 'Pasig City', 'Metro Manila', NULL, NULL, '2022-08-01', 4, 23, 'Active'),
(25, 'Alejandro Jose', 'Medina', NULL, 'Male', '1992-05-22', '09171234591', 'alejandro.medina@company.com', 'Mandaluyong City', '469', 'Maysilo Circle', 'Plainview', 'Mandaluyong City', 'Metro Manila', NULL, NULL, '2021-12-01', 7, 24, 'Active')
ON DUPLICATE KEY UPDATE first_name = VALUES(first_name), last_name = VALUES(last_name);

-- ========================================
-- 4B. EMPLOYEE REFERENCE DATA (External HRIS Integration)
-- ========================================
-- This table is used by payroll system via employee_external_no
-- Links to employee table through mapping

INSERT INTO employee_refs (external_employee_no, name, department, position, base_monthly_salary, employment_type, external_source) VALUES
-- Management (C-Suite & Directors) - Philippine Market Rates
('EMP001', 'Juan Carlos Santos', 'Human Resources', 'HR Manager', 65000.00, 'regular', 'HRIS'),
('EMP002', 'Maria Elena Rodriguez', 'Finance', 'CFO', 200000.00, 'regular', 'HRIS'),
('EMP003', 'Jose Miguel Cruz', 'IT', 'CTO', 220000.00, 'regular', 'HRIS'),
('EMP004', 'Ana Patricia Lopez', 'Marketing', 'Marketing Director', 120000.00, 'regular', 'HRIS'),
('EMP005', 'Roberto Antonio Garcia', 'Operations', 'COO', 200000.00, 'regular', 'HRIS'),

-- Senior Staff (Managers & Senior Specialists)
('EMP006', 'Carmen Sofia Martinez', 'Customer Service', 'CS Manager', 55000.00, 'regular', 'HRIS'),
('EMP007', 'Fernando Luis Torres', 'Sales', 'Sales Manager', 70000.00, 'regular', 'HRIS'),
('EMP008', 'Isabella Rose Flores', 'Finance', 'Senior Accountant', 48000.00, 'regular', 'HRIS'),
('EMP009', 'Miguel Angel Reyes', 'IT', 'Senior Developer', 85000.00, 'regular', 'HRIS'),
('EMP010', 'Sofia Grace Villanueva', 'Marketing', 'Marketing Specialist', 42000.00, 'regular', 'HRIS'),

-- Mid-level Staff
('EMP011', 'Carlos Eduardo Mendoza', 'IT', 'Software Developer', 55000.00, 'regular', 'HRIS'),
('EMP012', 'Patricia Isabel Gutierrez', 'Finance', 'Accountant', 35000.00, 'regular', 'HRIS'),
('EMP013', 'Ricardo Manuel Herrera', 'Sales', 'Sales Executive', 40000.00, 'regular', 'HRIS'),
('EMP014', 'Gabriela Alejandra Morales', 'Customer Service', 'CS Representative', 25000.00, 'regular', 'HRIS'),
('EMP015', 'Diego Fernando Ramos', 'Operations', 'Operations Coordinator', 32000.00, 'regular', 'HRIS'),

-- Junior Staff & Support Roles
('EMP016', 'Valentina Sofia Castillo', 'Marketing', 'Content Creator', 28000.00, 'contract', 'HRIS'),
('EMP017', 'Sebastian Alejandro Vega', 'IT', 'Junior Developer', 38000.00, 'contract', 'HRIS'),
('EMP018', 'Camila Esperanza Ruiz', 'Finance', 'Payroll Specialist', 32000.00, 'regular', 'HRIS'),
('EMP019', 'Nicolas Gabriel Silva', 'Sales', 'Sales Representative', 30000.00, 'contract', 'HRIS'),
('EMP020', 'Lucia Esperanza Jimenez', 'Customer Service', 'CS Representative', 25000.00, 'part-time', 'HRIS'),

-- Additional Staff
('EMP021', 'Andres Felipe Castro', 'Operations', 'Warehouse Supervisor', 45000.00, 'regular', 'HRIS'),
('EMP022', 'Mariana Beatriz Ortega', 'Finance', 'Accounts Payable Clerk', 28000.00, 'regular', 'HRIS'),
('EMP023', 'Santiago Ignacio Pena', 'IT', 'System Administrator', 55000.00, 'regular', 'HRIS'),
('EMP024', 'Daniela Fernanda Vargas', 'Marketing', 'Social Media Manager', 35000.00, 'contract', 'HRIS'),
('EMP025', 'Alejandro Jose Medina', 'Sales', 'Account Manager', 50000.00, 'regular', 'HRIS')
ON DUPLICATE KEY UPDATE name = VALUES(name), base_monthly_salary = VALUES(base_monthly_salary);

-- ========================================
-- 4C. USER ACCOUNT LINKING (HRIS-User System Integration)
-- ========================================
-- Links employees to user accounts for system access
-- This connects HRIS employee records to authentication system

-- Link admin user (already exists in users table) to employee system
-- Note: Additional user_account records can be created as needed
-- The employee_id links to the employee table, enabling HRIS-Payroll integration
INSERT INTO user_account (user_id, employee_id, username, password_hash, role, last_login) VALUES
(1, 1, 'admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Admin', NOW() - INTERVAL 5 DAY),
(2, 2, 'finance.admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Accounting Admin', NULL)
ON DUPLICATE KEY UPDATE employee_id = VALUES(employee_id), role = VALUES(role), password_hash = VALUES(password_hash);

-- ========================================
-- HR MANAGER ROLE SETUP (Data Migration)
-- ========================================
-- Update existing user_account records with NULL role to 'Admin' for backward compatibility
-- This ensures all existing admin accounts are properly marked

-- ========================================
-- CREATE ADMIN ACCOUNT
-- ========================================
-- This creates the main admin account for system access
-- Username: admin
-- Password: password
-- Role: Admin
-- IMPORTANT: Change the password in production!
-- ========================================

-- Create admin account in user_account table
-- Links to employee_id 1 (Juan Santos - HR Manager in employee table)
INSERT INTO user_account (employee_id, username, password_hash, role, last_login)
VALUES (
    1, -- Links to employee_id 1 (Juan Santos - HR Manager in employee table)
    'admin', -- username
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- password hash for 'password'
    'Admin', -- role (must be exactly 'Admin')
    NULL -- last_login will be set automatically on first login
)
ON DUPLICATE KEY UPDATE 
    password_hash = VALUES(password_hash),
    role = VALUES(role),
    employee_id = VALUES(employee_id);


UPDATE user_account 
SET role = 'Admin' 
WHERE role IS NULL 
AND username IS NOT NULL;

-- Ensure any existing admin accounts explicitly have 'Admin' role
-- (in case they were created with different role values)
UPDATE user_account 
SET role = 'Admin' 
WHERE username = 'admin' 
AND (role IS NULL OR role != 'Admin');

-- ========================================
-- CREATE HR MANAGER ACCOUNT
-- ========================================
-- This creates an HR Manager account
-- Username: hrmanager
-- Password: password
-- Role: HR Manager
-- ========================================

-- Create HR Manager account
INSERT INTO user_account (employee_id, username, password_hash, role, last_login)
VALUES (
    NULL, -- employee_id (can be set to a valid employee_id if needed)
    'hrmanager', -- username
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- password hash for 'password'
    'HR Manager', -- role (must be exactly 'HR Manager')
    NULL -- last_login will be set automatically on first login
)
ON DUPLICATE KEY UPDATE 
    password_hash = VALUES(password_hash),
    role = VALUES(role);



INSERT INTO employee_attendance (employee_external_no, attendance_date, time_in, time_out, status, hours_worked, overtime_hours, late_minutes, remarks) VALUES
-- ========================================
-- REALISTIC ATTENDANCE PATTERNS FOR NOVEMBER & DECEMBER 2025
-- November Weekends: 1-2, 8-9, 15-16, 22-23, 29-30
-- December Weekends: 6-7, 13-14, 20-21, 27-28
-- Holidays: Nov 30 (Bonifacio Day), Dec 25 (Christmas), Dec 30-31 (Year-end)
-- Note: Some employees work weekends (CS, Sales, Operations)
-- ========================================

-- EMP001 (HR Manager): EXEMPLARY - Perfect attendance, never late, occasional OT
('EMP001', '2025-11-03', '07:55:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP001', '2025-11-04', '07:50:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP001', '2025-11-05', '07:58:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP001', '2025-11-06', '07:55:00', '18:30:00', 'present', 9.50, 1.50, 0, 'Overtime - Month-end reports'),
('EMP001', '2025-11-07', '07:52:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP001', '2025-11-10', '07:48:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP001', '2025-11-11', '07:55:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP001', '2025-11-12', '07:50:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP001', '2025-11-13', '07:58:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP001', '2025-11-14', '07:55:00', '19:00:00', 'present', 10.00, 2.00, 0, 'Overtime - Performance reviews'),
('EMP001', '2025-11-17', '07:52:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP001', '2025-11-18', '07:55:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP001', '2025-11-19', '07:48:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP001', '2025-11-20', '07:55:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP001', '2025-11-21', '07:50:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP001', '2025-11-24', '07:55:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP001', '2025-11-25', '07:52:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP001', '2025-11-26', '07:58:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP001', '2025-11-27', '07:55:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP001', '2025-11-28', '07:50:00', '18:00:00', 'present', 9.00, 1.00, 0, 'Overtime - Month-end closing'),
-- December 2025
('EMP001', '2025-12-01', '07:55:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP001', '2025-12-02', '07:50:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP001', '2025-12-03', '07:58:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP001', '2025-12-04', '07:55:00', '18:30:00', 'present', 9.50, 1.50, 0, 'Overtime - Year-end prep'),
('EMP001', '2025-12-05', '07:52:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP001', '2025-12-08', '07:48:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP001', '2025-12-09', '07:55:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP001', '2025-12-10', '07:50:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP001', '2025-12-11', '07:58:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP001', '2025-12-12', '07:55:00', '19:00:00', 'present', 10.00, 2.00, 0, 'Overtime - Annual reviews'),

-- EMP002 (CFO): EXECUTIVE - Perfect attendance, strategic overtime, very punctual
('EMP002', '2025-11-03', '07:45:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP002', '2025-11-04', '07:50:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP002', '2025-11-05', '07:48:00', '19:00:00', 'present', 10.00, 2.00, 0, 'Overtime - Budget review'),
('EMP002', '2025-11-06', '07:55:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP002', '2025-11-07', '07:52:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP002', '2025-11-10', '07:48:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP002', '2025-11-11', '07:55:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP002', '2025-11-12', '07:50:00', '20:00:00', 'present', 11.00, 3.00, 0, 'Overtime - Board meeting prep'),
('EMP002', '2025-11-13', '07:58:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP002', '2025-11-14', '07:55:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP002', '2025-11-17', '07:52:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP002', '2025-11-18', '07:55:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP002', '2025-11-19', '07:48:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP002', '2025-11-20', '07:55:00', '18:30:00', 'present', 9.50, 1.50, 0, 'Overtime - Financial reports'),
('EMP002', '2025-11-21', '07:50:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP002', '2025-11-24', '07:55:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP002', '2025-11-25', '07:52:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP002', '2025-11-26', '07:58:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP002', '2025-11-27', '07:55:00', '19:30:00', 'present', 10.50, 2.50, 0, 'Overtime - Year-end planning'),
('EMP002', '2025-11-28', '07:50:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
-- December 2025
('EMP002', '2025-12-01', '07:45:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP002', '2025-12-02', '07:50:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP002', '2025-12-03', '07:48:00', '19:00:00', 'present', 10.00, 2.00, 0, 'Overtime - Year-end audit prep'),
('EMP002', '2025-12-04', '07:55:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP002', '2025-12-05', '07:52:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP002', '2025-12-08', '07:48:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP002', '2025-12-09', '07:55:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP002', '2025-12-10', '07:50:00', '20:00:00', 'present', 11.00, 3.00, 0, 'Overtime - Financial statements'),
('EMP002', '2025-12-11', '07:58:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP002', '2025-12-12', '07:55:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),

-- EMP003 (CTO): WORKAHOLIC - Works weekends, frequent overtime, tech deadlines
('EMP003', '2025-11-01', '09:00:00', '15:00:00', 'present', 6.00, 0.00, 0, 'Weekend work - Emergency fix'),
('EMP003', '2025-11-02', '10:00:00', '14:00:00', 'present', 4.00, 0.00, 0, 'Weekend work - System monitoring'),
('EMP003', '2025-11-03', '07:30:00', '20:00:00', 'present', 11.50, 3.50, 0, 'Overtime - System deployment'),
('EMP003', '2025-11-04', '07:45:00', '19:00:00', 'present', 10.25, 2.25, 0, 'Overtime - Bug fixes'),
('EMP003', '2025-11-05', '07:50:00', '18:30:00', 'present', 9.67, 1.67, 0, 'Overtime - Code review'),
('EMP003', '2025-11-06', '07:55:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP003', '2025-11-07', '07:40:00', '21:00:00', 'present', 12.33, 4.33, 0, 'Overtime - Production issue'),
('EMP003', '2025-11-08', '09:00:00', '13:00:00', 'present', 4.00, 0.00, 0, 'Weekend work - Server maintenance'),
('EMP003', '2025-11-10', '07:45:00', '19:30:00', 'present', 10.75, 2.75, 0, 'Overtime - Sprint planning'),
('EMP003', '2025-11-11', '07:50:00', '18:00:00', 'present', 9.17, 1.17, 0, 'Overtime - Architecture review'),
('EMP003', '2025-11-12', '07:55:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP003', '2025-11-13', '07:48:00', '19:00:00', 'present', 10.20, 2.20, 0, 'Overtime - Security audit'),
('EMP003', '2025-11-14', '07:52:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP003', '2025-11-15', '09:00:00', '16:00:00', 'present', 7.00, 0.00, 0, 'Weekend work - Database optimization'),
('EMP003', '2025-11-17', '07:45:00', '20:30:00', 'present', 11.75, 3.75, 0, 'Overtime - Release preparation'),
('EMP003', '2025-11-18', '07:50:00', '19:00:00', 'present', 10.17, 2.17, 0, 'Overtime - Testing'),
('EMP003', '2025-11-19', '07:55:00', '18:00:00', 'present', 9.08, 1.08, 0, 'Overtime - Documentation'),
('EMP003', '2025-11-20', '07:48:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP003', '2025-11-21', '07:52:00', '19:30:00', 'present', 10.63, 2.63, 0, 'Overtime - Deployment'),
('EMP003', '2025-11-22', '10:00:00', '14:00:00', 'present', 4.00, 0.00, 0, 'Weekend work - Monitoring'),
('EMP003', '2025-11-24', '07:45:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP003', '2025-11-25', '07:50:00', '18:30:00', 'present', 9.67, 1.67, 0, 'Overtime - Performance tuning'),
('EMP003', '2025-11-26', '07:55:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP003', '2025-11-27', '07:48:00', '20:00:00', 'present', 11.20, 3.20, 0, 'Overtime - Month-end processing'),
('EMP003', '2025-11-28', '07:52:00', '19:00:00', 'present', 10.13, 2.13, 0, 'Overtime - System backup'),
('EMP003', '2025-11-29', '09:00:00', '15:00:00', 'present', 6.00, 0.00, 0, 'Weekend work - Year-end prep'),
-- December 2025
('EMP003', '2025-12-01', '07:30:00', '20:00:00', 'present', 11.50, 3.50, 0, 'Overtime - Year-end system updates'),
('EMP003', '2025-12-02', '07:45:00', '19:00:00', 'present', 10.25, 2.25, 0, 'Overtime - Security patches'),
('EMP003', '2025-12-03', '07:50:00', '18:30:00', 'present', 9.67, 1.67, 0, 'Overtime - Performance optimization'),
('EMP003', '2025-12-04', '07:55:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP003', '2025-12-05', '07:40:00', '21:00:00', 'present', 12.33, 4.33, 0, 'Overtime - Critical system upgrade'),
('EMP003', '2025-12-07', '09:00:00', '13:00:00', 'present', 4.00, 0.00, 0, 'Weekend work - System monitoring'),
('EMP003', '2025-12-08', '07:45:00', '19:30:00', 'present', 10.75, 2.75, 0, 'Overtime - Database migration'),
('EMP003', '2025-12-09', '07:50:00', '18:00:00', 'present', 9.17, 1.17, 0, 'Overtime - Code deployment'),
('EMP003', '2025-12-10', '07:55:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP003', '2025-12-11', '07:48:00', '19:00:00', 'present', 10.20, 2.20, 0, 'Overtime - Testing new features'),
('EMP003', '2025-12-12', '07:52:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),

-- EMP004 (Marketing Director): GOOD EMPLOYEE - Reliable, occasional late due to client meetings
('EMP004', '2025-11-03', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP004', '2025-11-04', '08:05:00', '17:00:00', 'present', 7.92, 0.00, 5, 'Slightly late'),
('EMP004', '2025-11-05', '08:00:00', '18:00:00', 'present', 9.00, 1.00, 0, 'Overtime - Campaign launch'),
('EMP004', '2025-11-06', '08:15:00', '17:00:00', 'late', 7.75, 0.00, 15, 'Late - Client breakfast meeting'),
('EMP004', '2025-11-07', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP004', '2025-11-10', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP004', '2025-11-11', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP004', '2025-11-12', '08:00:00', '19:00:00', 'present', 10.00, 2.00, 0, 'Overtime - Event preparation'),
('EMP004', '2025-11-13', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP004', '2025-11-14', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Vacation leave - Personal day'),
('EMP004', '2025-11-17', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP004', '2025-11-18', '08:10:00', '17:00:00', 'late', 7.83, 0.00, 10, 'Late - Traffic'),
('EMP004', '2025-11-19', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP004', '2025-11-20', '08:00:00', '18:30:00', 'present', 9.50, 1.50, 0, 'Overtime - Presentation prep'),
('EMP004', '2025-11-21', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP004', '2025-11-24', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP004', '2025-11-25', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP004', '2025-11-26', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP004', '2025-11-27', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP004', '2025-11-28', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
-- December 2025
('EMP004', '2025-12-01', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP004', '2025-12-02', '08:05:00', '17:00:00', 'present', 7.92, 0.00, 5, 'Slightly late'),
('EMP004', '2025-12-03', '08:00:00', '18:00:00', 'present', 9.00, 1.00, 0, 'Overtime - Holiday campaign'),
('EMP004', '2025-12-04', '08:15:00', '17:00:00', 'late', 7.75, 0.00, 15, 'Late - Client meeting'),
('EMP004', '2025-12-05', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP004', '2025-12-08', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP004', '2025-12-09', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP004', '2025-12-10', '08:00:00', '19:00:00', 'present', 10.00, 2.00, 0, 'Overtime - Year-end campaign'),
('EMP004', '2025-12-11', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP004', '2025-12-12', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
-- EMP005 (COO): EXECUTIVE - Perfect attendance, strategic overtime for operations
('EMP005', '2025-11-03', '07:50:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP005', '2025-11-04', '07:55:00', '18:00:00', 'present', 9.08, 1.08, 0, 'Overtime - Operations review'),
('EMP005', '2025-11-05', '07:48:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP005', '2025-11-06', '07:52:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP005', '2025-11-07', '07:55:00', '19:00:00', 'present', 10.08, 2.08, 0, 'Overtime - Logistics planning'),
('EMP005', '2025-11-10', '07:48:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP005', '2025-11-11', '07:55:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP005', '2025-11-12', '07:50:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP005', '2025-11-13', '07:52:00', '18:30:00', 'present', 9.63, 1.63, 0, 'Overtime - Vendor meeting'),
('EMP005', '2025-11-14', '07:55:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP005', '2025-11-17', '07:48:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP005', '2025-11-18', '07:55:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP005', '2025-11-19', '07:50:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP005', '2025-11-20', '07:52:00', '19:30:00', 'present', 10.63, 2.63, 0, 'Overtime - Supply chain review'),
('EMP005', '2025-11-21', '07:55:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP005', '2025-11-24', '07:48:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP005', '2025-11-25', '07:55:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP005', '2025-11-26', '07:50:00', '18:00:00', 'present', 9.17, 1.17, 0, 'Overtime - Process improvement'),
('EMP005', '2025-11-27', '07:52:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP005', '2025-11-28', '07:55:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
-- December 2025
('EMP005', '2025-12-01', '07:50:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP005', '2025-12-02', '07:55:00', '18:00:00', 'present', 9.08, 1.08, 0, 'Overtime - Year-end operations'),
('EMP005', '2025-12-03', '07:48:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP005', '2025-12-04', '07:52:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP005', '2025-12-05', '07:55:00', '19:00:00', 'present', 10.08, 2.08, 0, 'Overtime - Inventory planning'),
('EMP005', '2025-12-08', '07:48:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP005', '2025-12-09', '07:55:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP005', '2025-12-10', '07:50:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP005', '2025-12-11', '07:52:00', '18:30:00', 'present', 9.63, 1.63, 0, 'Overtime - Supply chain review'),
('EMP005', '2025-12-12', '07:55:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
-- EMP006 (CS Manager): CUSTOMER SERVICE - Works some weekends, good attendance
('EMP006', '2025-11-01', '09:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Weekend shift - Customer support'),
('EMP006', '2025-11-03', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP006', '2025-11-04', '08:05:00', '17:00:00', 'present', 7.92, 0.00, 5, 'Slightly late'),
('EMP006', '2025-11-05', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP006', '2025-11-06', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Sick leave - Flu'),
('EMP006', '2025-11-07', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Sick leave - Flu recovery'),
('EMP006', '2025-11-09', '09:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Weekend shift - Customer support'),
('EMP006', '2025-11-10', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP006', '2025-11-11', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP006', '2025-11-12', '08:00:00', '18:00:00', 'present', 9.00, 1.00, 0, 'Overtime - Customer escalation'),
('EMP006', '2025-11-13', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP006', '2025-11-14', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP006', '2025-11-16', '09:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Weekend shift - Customer support'),
('EMP006', '2025-11-17', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP006', '2025-11-18', '08:10:00', '17:00:00', 'late', 7.83, 0.00, 10, 'Late - Traffic'),
('EMP006', '2025-11-19', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP006', '2025-11-20', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP006', '2025-11-21', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP006', '2025-11-23', '09:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Weekend shift - Customer support'),
('EMP006', '2025-11-24', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP006', '2025-11-25', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP006', '2025-11-26', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP006', '2025-11-27', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP006', '2025-11-28', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
-- December 2025
('EMP006', '2025-12-01', '09:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Weekend shift - Customer support'),
('EMP006', '2025-12-02', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP006', '2025-12-03', '08:05:00', '17:00:00', 'present', 7.92, 0.00, 5, 'Slightly late'),
('EMP006', '2025-12-04', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP006', '2025-12-05', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP006', '2025-12-07', '09:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Weekend shift - Customer support'),
('EMP006', '2025-12-08', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP006', '2025-12-09', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP006', '2025-12-10', '08:00:00', '18:00:00', 'present', 9.00, 1.00, 0, 'Overtime - Holiday customer support'),
('EMP006', '2025-12-11', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP006', '2025-12-12', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
-- EMP007: Balanced pattern for days 1-30
('EMP007', '2025-11-01', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP007', '2025-11-02', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP007', '2025-11-03', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP007', '2025-11-04', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP007', '2025-11-05', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP007', '2025-11-06', '08:25:00', '17:00:00', 'late', 8.00, 0.00, 25, 'Late arrival'),
('EMP007', '2025-11-07', '08:00:00', '19:00:00', 'present', 10.00, 2.00, 0, 'Overtime work'),
('EMP007', '2025-11-08', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP007', '2025-11-09', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP007', '2025-11-10', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP007', '2025-11-11', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP007', '2025-11-12', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP007', '2025-11-13', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP007', '2025-11-14', '08:25:00', '17:00:00', 'late', 8.00, 0.00, 25, 'Late arrival'),
('EMP007', '2025-11-15', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP007', '2025-11-16', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP007', '2025-11-17', '08:00:00', '19:00:00', 'present', 10.00, 2.00, 0, 'Overtime work'),
('EMP007', '2025-11-18', '08:00:00', '12:00:00', 'half_day', 4.00, 0.00, 0, 'Half day'),
('EMP007', '2025-11-19', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP007', '2025-11-20', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP007', '2025-11-21', '08:20:00', '17:00:00', 'late', 8.00, 0.00, 20, 'Late arrival'),
('EMP007', '2025-11-22', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP007', '2025-11-23', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP007', '2025-11-24', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP007', '2025-11-25', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP007', '2025-11-26', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP007', '2025-11-27', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP007', '2025-11-28', '08:15:00', '17:00:00', 'late', 8.00, 0.00, 15, 'Late arrival'),
-- December 2025 for EMP007
('EMP007', '2025-12-01', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP007', '2025-12-02', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP007', '2025-12-03', '08:00:00', '19:00:00', 'present', 10.00, 2.00, 0, 'Overtime work'),
('EMP007', '2025-12-04', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP007', '2025-12-05', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP007', '2025-12-08', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP007', '2025-12-09', '08:25:00', '17:00:00', 'late', 8.00, 0.00, 25, 'Late arrival'),
('EMP007', '2025-12-10', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP007', '2025-12-11', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP007', '2025-12-12', '08:00:00', '18:00:00', 'present', 9.00, 1.00, 0, 'Overtime work'),
-- EMP008: Balanced pattern for days 1-30
('EMP008', '2025-11-01', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP008', '2025-11-02', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP008', '2025-11-03', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP008', '2025-11-04', '08:00:00', '20:00:00', 'present', 11.00, 3.00, 0, 'Overtime work'),
('EMP008', '2025-11-05', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP008', '2025-11-06', '08:25:00', '17:00:00', 'late', 8.00, 0.00, 25, 'Late arrival'),
('EMP008', '2025-11-07', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP008', '2025-11-08', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP008', '2025-11-09', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP008', '2025-11-10', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP008', '2025-11-11', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP008', '2025-11-12', '08:15:00', '17:00:00', 'late', 8.00, 0.00, 15, 'Late arrival'),
('EMP008', '2025-11-13', '08:00:00', '19:30:00', 'present', 10.50, 2.50, 0, 'Overtime work'),
('EMP008', '2025-11-14', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP008', '2025-11-15', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP008', '2025-11-16', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP008', '2025-11-17', '08:00:00', '12:00:00', 'half_day', 4.00, 0.00, 0, 'Half day'),
('EMP008', '2025-11-18', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP008', '2025-11-19', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP008', '2025-11-20', '08:15:00', '17:00:00', 'late', 8.00, 0.00, 15, 'Late arrival'),
('EMP008', '2025-11-21', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP008', '2025-11-22', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP008', '2025-11-23', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP008', '2025-11-24', '08:00:00', '20:00:00', 'present', 11.00, 3.00, 0, 'Overtime work'),
('EMP008', '2025-11-25', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP008', '2025-11-26', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP008', '2025-11-27', '08:30:00', '17:00:00', 'late', 8.00, 0.00, 30, 'Late arrival'),
('EMP008', '2025-11-28', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP008', '2025-11-29', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
-- December 2025 for EMP008
('EMP008', '2025-12-01', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP008', '2025-12-02', '08:00:00', '20:00:00', 'present', 11.00, 3.00, 0, 'Overtime work'),
('EMP008', '2025-12-03', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP008', '2025-12-04', '08:15:00', '17:00:00', 'late', 8.00, 0.00, 15, 'Late arrival'),
('EMP008', '2025-12-05', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP008', '2025-12-08', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP008', '2025-12-09', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP008', '2025-12-10', '08:00:00', '19:30:00', 'present', 10.50, 2.50, 0, 'Overtime work'),
('EMP008', '2025-12-11', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP008', '2025-12-12', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
-- EMP009: Balanced pattern for days 1-30
('EMP009', '2025-11-01', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP009', '2025-11-02', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP009', '2025-11-03', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP009', '2025-11-04', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP009', '2025-11-05', '08:20:00', '17:00:00', 'late', 8.00, 0.00, 20, 'Late arrival'),
('EMP009', '2025-11-06', '08:00:00', '18:30:00', 'present', 9.50, 1.50, 0, 'Overtime work'),
('EMP009', '2025-11-07', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP009', '2025-11-08', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP009', '2025-11-09', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP009', '2025-11-10', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP009', '2025-11-11', '08:30:00', '17:00:00', 'late', 8.00, 0.00, 30, 'Late arrival'),
('EMP009', '2025-11-12', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP009', '2025-11-13', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP009', '2025-11-14', '08:00:00', '20:00:00', 'present', 11.00, 3.00, 0, 'Overtime work'),
('EMP009', '2025-11-15', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP009', '2025-11-16', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP009', '2025-11-17', '08:00:00', '12:00:00', 'half_day', 4.00, 0.00, 0, 'Half day'),
('EMP009', '2025-11-18', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP009', '2025-11-19', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP009', '2025-11-20', '08:15:00', '17:00:00', 'late', 8.00, 0.00, 15, 'Late arrival'),
('EMP009', '2025-11-21', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP009', '2025-11-22', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP009', '2025-11-23', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP009', '2025-11-24', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP009', '2025-11-25', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP009', '2025-11-26', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP009', '2025-11-27', '08:00:00', '19:00:00', 'present', 10.00, 2.00, 0, 'Overtime work'),
('EMP009', '2025-11-28', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP009', '2025-11-29', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
-- December 2025 for EMP009
('EMP009', '2025-12-01', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP009', '2025-12-02', '08:20:00', '17:00:00', 'late', 8.00, 0.00, 20, 'Late arrival'),
('EMP009', '2025-12-03', '08:00:00', '18:30:00', 'present', 9.50, 1.50, 0, 'Overtime work'),
('EMP009', '2025-12-04', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP009', '2025-12-05', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP009', '2025-12-08', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP009', '2025-12-09', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP009', '2025-12-10', '08:00:00', '20:00:00', 'present', 11.00, 3.00, 0, 'Overtime work'),
('EMP009', '2025-12-11', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP009', '2025-12-12', '08:15:00', '17:00:00', 'late', 8.00, 0.00, 15, 'Late arrival'),
-- EMP010: Balanced pattern for days 1-30
('EMP010', '2025-11-01', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP010', '2025-11-02', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP010', '2025-11-03', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP010', '2025-11-04', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP010', '2025-11-05', '08:20:00', '17:00:00', 'late', 8.00, 0.00, 20, 'Late arrival'),
('EMP010', '2025-11-06', '08:00:00', '18:30:00', 'present', 9.50, 1.50, 0, 'Overtime work'),
('EMP010', '2025-11-07', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP010', '2025-11-08', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP010', '2025-11-09', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP010', '2025-11-10', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP010', '2025-11-11', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP010', '2025-11-12', '08:15:00', '17:00:00', 'late', 8.00, 0.00, 15, 'Late arrival'),
('EMP010', '2025-11-13', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP010', '2025-11-14', '08:00:00', '20:00:00', 'present', 11.00, 3.00, 0, 'Overtime work'),
('EMP010', '2025-11-15', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP010', '2025-11-16', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP010', '2025-11-17', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP010', '2025-11-18', '08:00:00', '12:00:00', 'half_day', 4.00, 0.00, 0, 'Half day'),
('EMP010', '2025-11-19', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP010', '2025-11-20', '08:15:00', '17:00:00', 'late', 8.00, 0.00, 15, 'Late arrival'),
('EMP010', '2025-11-21', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP010', '2025-11-22', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP010', '2025-11-23', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP010', '2025-11-24', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP010', '2025-11-25', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP010', '2025-11-26', '08:25:00', '17:00:00', 'late', 8.00, 0.00, 25, 'Late arrival'),
('EMP010', '2025-11-27', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP010', '2025-11-28', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP010', '2025-11-29', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
-- December 2025 for EMP010
('EMP010', '2025-12-01', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP010', '2025-12-02', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP010', '2025-12-03', '08:20:00', '17:00:00', 'late', 8.00, 0.00, 20, 'Late arrival'),
('EMP010', '2025-12-04', '08:00:00', '18:30:00', 'present', 9.50, 1.50, 0, 'Overtime work'),
('EMP010', '2025-12-05', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP010', '2025-12-08', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP010', '2025-12-09', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP010', '2025-12-10', '08:15:00', '17:00:00', 'late', 8.00, 0.00, 15, 'Late arrival'),
('EMP010', '2025-12-11', '08:00:00', '20:00:00', 'present', 11.00, 3.00, 0, 'Overtime work'),
('EMP010', '2025-12-12', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),

-- EMP011: Balanced pattern for days 1-30
('EMP011', '2025-11-01', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP011', '2025-11-02', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP011', '2025-11-03', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP011', '2025-11-04', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP011', '2025-11-05', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP011', '2025-11-06', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP011', '2025-11-07', '08:30:00', '17:00:00', 'late', 8.00, 0.00, 30, 'Late arrival'),
('EMP011', '2025-11-08', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP011', '2025-11-09', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP011', '2025-11-10', '08:00:00', '18:00:00', 'present', 9.00, 1.00, 0, 'Overtime work'),
('EMP011', '2025-11-11', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP011', '2025-11-12', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP011', '2025-11-13', '08:20:00', '17:00:00', 'late', 8.00, 0.00, 20, 'Late arrival'),
('EMP011', '2025-11-14', '08:00:00', '12:00:00', 'half_day', 4.00, 0.00, 0, 'Half day'),
('EMP011', '2025-11-15', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP011', '2025-11-16', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP011', '2025-11-17', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP011', '2025-11-18', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP011', '2025-11-19', '08:30:00', '17:00:00', 'late', 8.00, 0.00, 30, 'Late arrival'),
('EMP011', '2025-11-20', '08:00:00', '18:00:00', 'present', 9.00, 1.00, 0, 'Overtime work'),
('EMP011', '2025-11-21', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP011', '2025-11-22', '08:00:00', '19:00:00', 'present', 9.00, 2.00, 0, 'Overtime work'),
('EMP011', '2025-11-23', '08:00:00', '19:00:00', 'present', 9.00, 2.00, 0, 'Overtime work'),
('EMP011', '2025-11-24', '08:00:00', '18:00:00', 'present', 9.00, 1.00, 0, 'Overtime work'),
('EMP011', '2025-11-25', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP011', '2025-11-26', '08:25:00', '17:00:00', 'late', 8.00, 0.00, 25, 'Late arrival'),
('EMP011', '2025-11-27', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP011', '2025-11-28', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP011', '2025-11-29', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
-- December 2025 for EMP011
('EMP011', '2025-12-01', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP011', '2025-12-02', '08:00:00', '18:00:00', 'present', 9.00, 1.00, 0, 'Overtime work'),
('EMP011', '2025-12-03', '08:30:00', '17:00:00', 'late', 8.00, 0.00, 30, 'Late arrival'),
('EMP011', '2025-12-04', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP011', '2025-12-05', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP011', '2025-12-08', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP011', '2025-12-09', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP011', '2025-12-10', '08:00:00', '19:00:00', 'present', 10.00, 2.00, 0, 'Overtime work'),
('EMP011', '2025-12-11', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP011', '2025-12-12', '08:25:00', '17:00:00', 'late', 8.00, 0.00, 25, 'Late arrival'),

-- EMP012: Balanced pattern for days 1-30
('EMP012', '2025-11-01', '08:00:00', '12:00:00', 'half_day', 4.00, 0.00, 0, 'Half day'),
('EMP012', '2025-11-02', '08:00:00', '13:00:00', 'half_day', 5.00, 0.00, 0, 'Half day'),
('EMP012', '2025-11-03', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP012', '2025-11-04', '08:15:00', '17:00:00', 'late', 8.00, 0.00, 15, 'Late arrival'),
('EMP012', '2025-11-05', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP012', '2025-11-06', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP012', '2025-11-07', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP012', '2025-11-08', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP012', '2025-11-09', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP012', '2025-11-10', '08:00:00', '20:00:00', 'present', 9.00, 3.00, 0, 'Overtime work'),
('EMP012', '2025-11-11', '08:30:00', '17:00:00', 'late', 8.00, 0.00, 30, 'Late arrival'),
('EMP012', '2025-11-12', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP012', '2025-11-13', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP012', '2025-11-14', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP012', '2025-11-15', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP012', '2025-11-16', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP012', '2025-11-17', '08:00:00', '12:00:00', 'half_day', 4.00, 0.00, 0, 'Half day'),
('EMP012', '2025-11-18', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP012', '2025-11-19', '08:30:00', '17:00:00', 'late', 8.00, 0.00, 30, 'Late arrival'),
('EMP012', '2025-11-20', '08:00:00', '18:00:00', 'present', 9.00, 1.00, 0, 'Overtime work'),
('EMP012', '2025-11-21', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP012', '2025-11-22', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP012', '2025-11-23', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP012', '2025-11-24', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP012', '2025-11-25', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP012', '2025-11-26', '08:25:00', '17:00:00', 'late', 8.00, 0.00, 25, 'Late arrival'),
('EMP012', '2025-11-27', '08:00:00', '19:00:00', 'present', 10.00, 2.00, 0, 'Overtime work'),
('EMP012', '2025-11-28', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP012', '2025-11-29', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
-- December 2025 for EMP012
('EMP012', '2025-12-01', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP012', '2025-12-02', '08:15:00', '17:00:00', 'late', 8.00, 0.00, 15, 'Late arrival'),
('EMP012', '2025-12-03', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP012', '2025-12-04', '08:00:00', '20:00:00', 'present', 11.00, 3.00, 0, 'Overtime work'),
('EMP012', '2025-12-05', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP012', '2025-12-08', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP012', '2025-12-09', '08:30:00', '17:00:00', 'late', 8.00, 0.00, 30, 'Late arrival'),
('EMP012', '2025-12-10', '08:00:00', '18:00:00', 'present', 9.00, 1.00, 0, 'Overtime work'),
('EMP012', '2025-12-11', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP012', '2025-12-12', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
-- EMP013: Balanced pattern for days 1-30
('EMP013', '2025-11-01', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP013', '2025-11-02', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP013', '2025-11-03', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP013', '2025-11-04', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP013', '2025-11-05', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP013', '2025-11-06', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP013', '2025-11-07', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP013', '2025-11-08', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP013', '2025-11-09', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP013', '2025-11-10', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP013', '2025-11-21', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP013', '2025-11-21', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP013', '2025-11-21', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP013', '2025-11-21', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP013', '2025-11-24', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP013', '2025-11-24', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP013', '2025-11-17', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP013', '2025-11-18', '08:00:00', '12:00:00', 'half_day', 4.00, 0.00, 0, 'Half day'),
('EMP013', '2025-11-19', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP013', '2025-11-20', '08:15:00', '17:00:00', 'late', 8.00, 0.00, 15, 'Late arrival'),
('EMP013', '2025-11-21', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP013', '2025-11-22', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP013', '2025-11-23', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP013', '2025-11-24', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP013', '2025-11-25', '08:00:00', '18:00:00', 'present', 9.00, 1.00, 0, 'Overtime work'),
('EMP013', '2025-11-26', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP013', '2025-11-27', '08:30:00', '17:00:00', 'late', 8.00, 0.00, 30, 'Late arrival'),
('EMP013', '2025-11-28', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP013', '2025-11-29', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
-- December 2025 for EMP013
('EMP013', '2025-12-01', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP013', '2025-12-02', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP013', '2025-12-03', '08:00:00', '18:00:00', 'present', 9.00, 1.00, 0, 'Overtime work'),
('EMP013', '2025-12-04', '08:15:00', '17:00:00', 'late', 8.00, 0.00, 15, 'Late arrival'),
('EMP013', '2025-12-05', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP013', '2025-12-08', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP013', '2025-12-09', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP013', '2025-12-10', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP013', '2025-12-11', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP013', '2025-12-12', '08:30:00', '17:00:00', 'late', 8.00, 0.00, 30, 'Late arrival'),
-- EMP014: Perfect attendance - Never absent, always present, minimal late
('EMP014', '2025-11-01', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP014', '2025-11-02', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP014', '2025-11-03', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP014', '2025-11-04', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP014', '2025-11-05', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP014', '2025-11-06', '08:00:00', '18:00:00', 'present', 9.00, 1.00, 0, 'Overtime work'),
('EMP014', '2025-11-07', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP014', '2025-11-08', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP014', '2025-11-09', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP014', '2025-11-10', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP014', '2025-11-11', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP014', '2025-11-12', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP014', '2025-11-13', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP014', '2025-11-14', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP014', '2025-11-15', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP014', '2025-11-16', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP014', '2025-11-17', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP014', '2025-11-18', '08:00:00', '19:00:00', 'present', 10.00, 2.00, 0, 'Overtime work'),
('EMP014', '2025-11-19', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP014', '2025-11-20', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP014', '2025-11-21', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP014', '2025-11-22', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP014', '2025-11-23', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP014', '2025-11-24', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP014', '2025-11-25', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP014', '2025-11-26', '08:00:00', '18:30:00', 'present', 9.50, 1.50, 0, 'Overtime work'),
('EMP014', '2025-11-27', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP014', '2025-11-28', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP014', '2025-11-29', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
-- December 2025 for EMP014 (Perfect attendance)
('EMP014', '2025-12-01', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP014', '2025-12-02', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP014', '2025-12-03', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP014', '2025-12-04', '08:00:00', '18:00:00', 'present', 9.00, 1.00, 0, 'Overtime work'),
('EMP014', '2025-12-05', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP014', '2025-12-08', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP014', '2025-12-09', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP014', '2025-12-10', '08:00:00', '19:00:00', 'present', 10.00, 2.00, 0, 'Overtime work'),
('EMP014', '2025-12-11', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP014', '2025-12-12', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
-- EMP015: Always late - Present but always arrives late
('EMP015', '2025-11-01', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP015', '2025-11-02', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP015', '2025-11-03', '08:30:00', '17:00:00', 'late', 8.00, 0.00, 30, 'Late arrival'),
('EMP015', '2025-11-04', '08:45:00', '17:00:00', 'late', 8.00, 0.00, 45, 'Late arrival'),
('EMP015', '2025-11-05', '09:00:00', '17:00:00', 'late', 8.00, 0.00, 60, 'Late arrival'),
('EMP015', '2025-11-06', '08:25:00', '17:00:00', 'late', 8.00, 0.00, 25, 'Late arrival'),
('EMP015', '2025-11-07', '08:35:00', '17:00:00', 'late', 8.00, 0.00, 35, 'Late arrival'),
('EMP015', '2025-11-08', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP015', '2025-11-09', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP015', '2025-11-10', '08:40:00', '17:00:00', 'late', 8.00, 0.00, 40, 'Late arrival'),
('EMP015', '2025-11-11', '08:20:00', '17:00:00', 'late', 8.00, 0.00, 20, 'Late arrival'),
('EMP015', '2025-11-12', '09:15:00', '17:00:00', 'late', 8.00, 0.00, 75, 'Late arrival'),
('EMP015', '2025-11-13', '08:30:00', '17:00:00', 'late', 8.00, 0.00, 30, 'Late arrival'),
('EMP015', '2025-11-14', '08:25:00', '17:00:00', 'late', 8.00, 0.00, 25, 'Late arrival'),
('EMP015', '2025-11-15', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP015', '2025-11-16', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP015', '2025-11-17', '08:35:00', '17:00:00', 'late', 8.00, 0.00, 35, 'Late arrival'),
('EMP015', '2025-11-18', '08:50:00', '17:00:00', 'late', 8.00, 0.00, 50, 'Late arrival'),
('EMP015', '2025-11-19', '08:30:00', '17:00:00', 'late', 8.00, 0.00, 30, 'Late arrival'),
('EMP015', '2025-11-20', '08:40:00', '17:00:00', 'late', 8.00, 0.00, 40, 'Late arrival'),
('EMP015', '2025-11-21', '08:20:00', '17:00:00', 'late', 8.00, 0.00, 20, 'Late arrival'),
('EMP015', '2025-11-22', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP015', '2025-11-23', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP015', '2025-11-24', '08:45:00', '17:00:00', 'late', 8.00, 0.00, 45, 'Late arrival'),
('EMP015', '2025-11-25', '08:30:00', '17:00:00', 'late', 8.00, 0.00, 30, 'Late arrival'),
('EMP015', '2025-11-26', '09:00:00', '17:00:00', 'late', 8.00, 0.00, 60, 'Late arrival'),
('EMP015', '2025-11-27', '08:25:00', '17:00:00', 'late', 8.00, 0.00, 25, 'Late arrival'),
('EMP015', '2025-11-28', '08:35:00', '17:00:00', 'late', 8.00, 0.00, 35, 'Late arrival'),
('EMP015', '2025-11-29', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
-- December 2025 for EMP015 (Always late)
('EMP015', '2025-12-01', '08:30:00', '17:00:00', 'late', 8.00, 0.00, 30, 'Late arrival'),
('EMP015', '2025-12-02', '08:45:00', '17:00:00', 'late', 8.00, 0.00, 45, 'Late arrival'),
('EMP015', '2025-12-03', '09:00:00', '17:00:00', 'late', 8.00, 0.00, 60, 'Late arrival'),
('EMP015', '2025-12-04', '08:25:00', '17:00:00', 'late', 8.00, 0.00, 25, 'Late arrival'),
('EMP015', '2025-12-05', '08:35:00', '17:00:00', 'late', 8.00, 0.00, 35, 'Late arrival'),
('EMP015', '2025-12-08', '08:40:00', '17:00:00', 'late', 8.00, 0.00, 40, 'Late arrival'),
('EMP015', '2025-12-09', '08:20:00', '17:00:00', 'late', 8.00, 0.00, 20, 'Late arrival'),
('EMP015', '2025-12-10', '09:15:00', '17:00:00', 'late', 8.00, 0.00, 75, 'Late arrival'),
('EMP015', '2025-12-11', '08:30:00', '17:00:00', 'late', 8.00, 0.00, 30, 'Late arrival'),
('EMP015', '2025-12-12', '08:25:00', '17:00:00', 'late', 8.00, 0.00, 25, 'Late arrival'),
-- EMP016: Frequent leave taker - Always wants to take leave
('EMP016', '2025-11-01', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP016', '2025-11-02', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP016', '2025-11-03', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Vacation leave'),
('EMP016', '2025-11-04', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP016', '2025-11-05', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Sick leave'),
('EMP016', '2025-11-06', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Personal leave'),
('EMP016', '2025-11-07', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP016', '2025-11-08', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP016', '2025-11-09', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP016', '2025-11-10', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP016', '2025-11-11', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP016', '2025-11-12', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP016', '2025-11-13', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP016', '2025-11-14', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP016', '2025-11-15', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP016', '2025-11-16', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP016', '2025-11-17', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP016', '2025-11-18', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP016', '2025-11-19', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP016', '2025-11-20', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP016', '2025-11-21', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP016', '2025-11-22', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP016', '2025-11-23', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP016', '2025-11-24', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP016', '2025-11-25', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP016', '2025-11-26', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP016', '2025-11-27', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP016', '2025-11-28', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP016', '2025-11-29', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
-- December 2025 for EMP016 (Frequent leave taker)
('EMP016', '2025-12-01', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Vacation leave'),
('EMP016', '2025-12-02', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP016', '2025-12-03', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Sick leave'),
('EMP016', '2025-12-04', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP016', '2025-12-05', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Personal leave'),
('EMP016', '2025-12-08', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP016', '2025-12-09', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP016', '2025-12-10', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP016', '2025-12-11', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP016', '2025-12-12', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
-- EMP017: Mixed pattern - Good attendance with occasional issues
('EMP017', '2025-11-01', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP017', '2025-11-02', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP017', '2025-11-03', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP017', '2025-11-04', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP017', '2025-11-05', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP017', '2025-11-06', '08:00:00', '18:00:00', 'present', 9.00, 1.00, 0, 'Overtime work'),
('EMP017', '2025-11-07', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP017', '2025-11-08', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP017', '2025-11-09', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP017', '2025-11-10', '08:15:00', '17:00:00', 'late', 8.00, 0.00, 15, 'Late arrival'),
('EMP017', '2025-11-11', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP017', '2025-11-12', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP017', '2025-11-13', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP017', '2025-11-14', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP017', '2025-11-15', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP017', '2025-11-16', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP017', '2025-11-17', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP017', '2025-11-18', '08:00:00', '19:00:00', 'present', 10.00, 2.00, 0, 'Overtime work'),
('EMP017', '2025-11-19', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP017', '2025-11-20', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP017', '2025-11-21', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP017', '2025-11-22', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP017', '2025-11-23', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP017', '2025-11-24', '08:20:00', '17:00:00', 'late', 8.00, 0.00, 20, 'Late arrival'),
('EMP017', '2025-11-25', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP017', '2025-11-26', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP017', '2025-11-27', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP017', '2025-11-28', '08:00:00', '18:30:00', 'present', 9.50, 1.50, 0, 'Overtime work'),
('EMP017', '2025-11-29', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
-- December 2025 for EMP017
('EMP017', '2025-12-01', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP017', '2025-12-02', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP017', '2025-12-03', '08:00:00', '18:00:00', 'present', 9.00, 1.00, 0, 'Overtime work'),
('EMP017', '2025-12-04', '08:15:00', '17:00:00', 'late', 8.00, 0.00, 15, 'Late arrival'),
('EMP017', '2025-12-05', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP017', '2025-12-08', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP017', '2025-12-09', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP017', '2025-12-10', '08:00:00', '19:00:00', 'present', 10.00, 2.00, 0, 'Overtime work'),
('EMP017', '2025-12-11', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP017', '2025-12-12', '08:20:00', '17:00:00', 'late', 8.00, 0.00, 20, 'Late arrival'),
-- EMP018: Mixed pattern - Often absent and late
('EMP018', '2025-11-01', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP018', '2025-11-02', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP018', '2025-11-03', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP018', '2025-11-04', '08:30:00', '17:00:00', 'late', 8.00, 0.00, 30, 'Late arrival'),
('EMP018', '2025-11-05', '09:00:00', '17:00:00', 'late', 8.00, 0.00, 60, 'Late arrival'),
('EMP018', '2025-11-06', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP018', '2025-11-07', '08:25:00', '17:00:00', 'late', 8.00, 0.00, 25, 'Late arrival'),
('EMP018', '2025-11-08', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP018', '2025-11-09', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP018', '2025-11-10', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP018', '2025-11-11', '08:40:00', '17:00:00', 'late', 8.00, 0.00, 40, 'Late arrival'),
('EMP018', '2025-11-12', '08:20:00', '17:00:00', 'late', 8.00, 0.00, 20, 'Late arrival'),
('EMP018', '2025-11-13', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP018', '2025-11-14', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP018', '2025-11-15', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP018', '2025-11-16', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP018', '2025-11-17', '08:35:00', '17:00:00', 'late', 8.00, 0.00, 35, 'Late arrival'),
('EMP018', '2025-11-18', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP018', '2025-11-19', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP018', '2025-11-20', '08:45:00', '17:00:00', 'late', 8.00, 0.00, 45, 'Late arrival'),
('EMP018', '2025-11-21', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP018', '2025-11-22', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP018', '2025-11-23', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP018', '2025-11-24', '08:30:00', '17:00:00', 'late', 8.00, 0.00, 30, 'Late arrival'),
('EMP018', '2025-11-25', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP018', '2025-11-26', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP018', '2025-11-27', '08:20:00', '17:00:00', 'late', 8.00, 0.00, 20, 'Late arrival'),
('EMP018', '2025-11-28', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP018', '2025-11-29', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
-- December 2025 for EMP018 (Often absent and late)
('EMP018', '2025-12-01', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP018', '2025-12-02', '08:30:00', '17:00:00', 'late', 8.00, 0.00, 30, 'Late arrival'),
('EMP018', '2025-12-03', '09:00:00', '17:00:00', 'late', 8.00, 0.00, 60, 'Late arrival'),
('EMP018', '2025-12-04', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP018', '2025-12-05', '08:25:00', '17:00:00', 'late', 8.00, 0.00, 25, 'Late arrival'),
('EMP018', '2025-12-08', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP018', '2025-12-09', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP018', '2025-12-10', '08:40:00', '17:00:00', 'late', 8.00, 0.00, 40, 'Late arrival'),
('EMP018', '2025-12-11', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP018', '2025-12-12', '08:35:00', '17:00:00', 'late', 8.00, 0.00, 35, 'Late arrival'),
-- EMP019: Mixed pattern - Very bad attendance with many absences
('EMP019', '2025-11-01', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP019', '2025-11-02', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP019', '2025-11-03', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP019', '2025-11-04', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP019', '2025-11-05', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP019', '2025-11-06', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP019', '2025-11-07', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP019', '2025-11-08', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP019', '2025-11-09', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP019', '2025-11-10', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP019', '2025-11-11', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP019', '2025-11-12', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP019', '2025-11-13', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP019', '2025-11-14', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP019', '2025-11-15', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP019', '2025-11-16', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP019', '2025-11-17', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP019', '2025-11-18', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP019', '2025-11-19', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP019', '2025-11-20', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP019', '2025-11-21', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP019', '2025-11-22', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP019', '2025-11-23', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP019', '2025-11-24', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP019', '2025-11-25', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP019', '2025-11-26', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP019', '2025-11-27', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP019', '2025-11-28', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP019', '2025-11-29', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
-- December 2025 for EMP019 (Very bad attendance)
('EMP019', '2025-12-01', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP019', '2025-12-02', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP019', '2025-12-03', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP019', '2025-12-04', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP019', '2025-12-05', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP019', '2025-12-08', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP019', '2025-12-09', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP019', '2025-12-10', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP019', '2025-12-11', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP019', '2025-12-12', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
-- EMP020: Mixed pattern - Good with overtime enthusiast
('EMP020', '2025-11-01', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP020', '2025-11-02', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP020', '2025-11-03', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP020', '2025-11-04', '08:00:00', '19:00:00', 'present', 10.00, 2.00, 0, 'Overtime work'),
('EMP020', '2025-11-05', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP020', '2025-11-06', '08:00:00', '20:00:00', 'present', 11.00, 3.00, 0, 'Overtime work'),
('EMP020', '2025-11-07', '08:00:00', '18:30:00', 'present', 9.50, 1.50, 0, 'Overtime work'),
('EMP020', '2025-11-08', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP020', '2025-11-09', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP020', '2025-11-10', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP020', '2025-11-11', '08:00:00', '19:30:00', 'present', 10.50, 2.50, 0, 'Overtime work'),
('EMP020', '2025-11-12', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP020', '2025-11-13', '08:00:00', '18:00:00', 'present', 9.00, 1.00, 0, 'Overtime work'),
('EMP020', '2025-11-14', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP020', '2025-11-15', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP020', '2025-11-16', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP020', '2025-11-17', '08:00:00', '20:00:00', 'present', 11.00, 3.00, 0, 'Overtime work'),
('EMP020', '2025-11-18', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP020', '2025-11-19', '08:00:00', '19:00:00', 'present', 10.00, 2.00, 0, 'Overtime work'),
('EMP020', '2025-11-20', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP020', '2025-11-21', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP020', '2025-11-22', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP020', '2025-11-23', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP020', '2025-11-24', '08:00:00', '18:30:00', 'present', 9.50, 1.50, 0, 'Overtime work'),
('EMP020', '2025-11-25', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP020', '2025-11-26', '08:00:00', '19:00:00', 'present', 10.00, 2.00, 0, 'Overtime work'),
('EMP020', '2025-11-27', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP020', '2025-11-28', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP020', '2025-11-29', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
-- December 2025 for EMP020 (Overtime enthusiast)
('EMP020', '2025-12-01', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP020', '2025-12-02', '08:00:00', '19:00:00', 'present', 10.00, 2.00, 0, 'Overtime work'),
('EMP020', '2025-12-03', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP020', '2025-12-04', '08:00:00', '20:00:00', 'present', 11.00, 3.00, 0, 'Overtime work'),
('EMP020', '2025-12-05', '08:00:00', '18:30:00', 'present', 9.50, 1.50, 0, 'Overtime work'),
('EMP020', '2025-12-08', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP020', '2025-12-09', '08:00:00', '19:30:00', 'present', 10.50, 2.50, 0, 'Overtime work'),
('EMP020', '2025-12-10', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP020', '2025-12-11', '08:00:00', '18:00:00', 'present', 9.00, 1.00, 0, 'Overtime work'),
('EMP020', '2025-12-12', '08:00:00', '20:00:00', 'present', 11.00, 3.00, 0, 'Overtime work'),
-- EMP021: Mixed pattern - Half day enthusiast
('EMP021', '2025-11-01', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP021', '2025-11-02', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP021', '2025-11-03', '08:00:00', '12:00:00', 'half_day', 4.00, 0.00, 0, 'Half day'),
('EMP021', '2025-11-04', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP021', '2025-11-05', '08:00:00', '12:00:00', 'half_day', 4.00, 0.00, 0, 'Half day'),
('EMP021', '2025-11-06', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP021', '2025-11-07', '08:00:00', '12:00:00', 'half_day', 4.00, 0.00, 0, 'Half day'),
('EMP021', '2025-11-08', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP021', '2025-11-09', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP021', '2025-11-10', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP021', '2025-11-11', '08:00:00', '12:00:00', 'half_day', 4.00, 0.00, 0, 'Half day'),
('EMP021', '2025-11-12', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP021', '2025-11-13', '08:00:00', '12:00:00', 'half_day', 4.00, 0.00, 0, 'Half day'),
('EMP021', '2025-11-14', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP021', '2025-11-15', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP021', '2025-11-16', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP021', '2025-11-17', '08:00:00', '12:00:00', 'half_day', 4.00, 0.00, 0, 'Half day'),
('EMP021', '2025-11-18', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP021', '2025-11-19', '08:00:00', '12:00:00', 'half_day', 4.00, 0.00, 0, 'Half day'),
('EMP021', '2025-11-20', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP021', '2025-11-21', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP021', '2025-11-22', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP021', '2025-11-23', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP021', '2025-11-24', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP021', '2025-11-25', '08:00:00', '12:00:00', 'half_day', 4.00, 0.00, 0, 'Half day'),
('EMP021', '2025-11-26', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP021', '2025-11-27', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP021', '2025-11-28', '08:00:00', '12:00:00', 'half_day', 4.00, 0.00, 0, 'Half day'),
('EMP021', '2025-11-29', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
-- December 2025 for EMP021 (Half day enthusiast)
('EMP021', '2025-12-01', '08:00:00', '12:00:00', 'half_day', 4.00, 0.00, 0, 'Half day'),
('EMP021', '2025-12-02', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP021', '2025-12-03', '08:00:00', '12:00:00', 'half_day', 4.00, 0.00, 0, 'Half day'),
('EMP021', '2025-12-04', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP021', '2025-12-05', '08:00:00', '12:00:00', 'half_day', 4.00, 0.00, 0, 'Half day'),
('EMP021', '2025-12-08', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP021', '2025-12-09', '08:00:00', '12:00:00', 'half_day', 4.00, 0.00, 0, 'Half day'),
('EMP021', '2025-12-10', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP021', '2025-12-11', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP021', '2025-12-12', '08:00:00', '12:00:00', 'half_day', 4.00, 0.00, 0, 'Half day'),
-- EMP022: Mixed pattern - Absent and late mix
('EMP022', '2025-11-01', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP022', '2025-11-02', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP022', '2025-11-03', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP022', '2025-11-04', '09:00:00', '17:00:00', 'late', 8.00, 0.00, 60, 'Late arrival'),
('EMP022', '2025-11-05', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP022', '2025-11-06', '08:45:00', '17:00:00', 'late', 8.00, 0.00, 45, 'Late arrival'),
('EMP022', '2025-11-07', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP022', '2025-11-08', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP022', '2025-11-09', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP022', '2025-11-10', '08:30:00', '17:00:00', 'late', 8.00, 0.00, 30, 'Late arrival'),
('EMP022', '2025-11-11', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP022', '2025-11-12', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP022', '2025-11-13', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP022', '2025-11-14', '08:35:00', '17:00:00', 'late', 8.00, 0.00, 35, 'Late arrival'),
('EMP022', '2025-11-15', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP022', '2025-11-16', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP022', '2025-11-17', '08:50:00', '17:00:00', 'late', 8.00, 0.00, 50, 'Late arrival'),
('EMP022', '2025-11-18', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP022', '2025-11-19', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP022', '2025-11-20', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP022', '2025-11-21', '08:25:00', '17:00:00', 'late', 8.00, 0.00, 25, 'Late arrival'),
('EMP022', '2025-11-22', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP022', '2025-11-23', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP022', '2025-11-24', '08:40:00', '17:00:00', 'late', 8.00, 0.00, 40, 'Late arrival'),
('EMP022', '2025-11-25', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP022', '2025-11-26', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP022', '2025-11-27', '08:30:00', '17:00:00', 'late', 8.00, 0.00, 30, 'Late arrival'),
('EMP022', '2025-11-28', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP022', '2025-11-29', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
-- December 2025 for EMP022 (Absent and late mix)
('EMP022', '2025-12-01', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP022', '2025-12-02', '09:00:00', '17:00:00', 'late', 8.00, 0.00, 60, 'Late arrival'),
('EMP022', '2025-12-03', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP022', '2025-12-04', '08:45:00', '17:00:00', 'late', 8.00, 0.00, 45, 'Late arrival'),
('EMP022', '2025-12-05', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP022', '2025-12-08', '08:30:00', '17:00:00', 'late', 8.00, 0.00, 30, 'Late arrival'),
('EMP022', '2025-12-09', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP022', '2025-12-10', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP022', '2025-12-11', '08:35:00', '17:00:00', 'late', 8.00, 0.00, 35, 'Late arrival'),
('EMP022', '2025-12-12', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
-- EMP023: Mixed pattern - Balanced with occasional issues
('EMP023', '2025-11-01', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP023', '2025-11-02', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP023', '2025-11-03', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP023', '2025-11-04', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP023', '2025-11-05', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP023', '2025-11-06', '08:00:00', '18:00:00', 'present', 9.00, 1.00, 0, 'Overtime work'),
('EMP023', '2025-11-07', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP023', '2025-11-08', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP023', '2025-11-09', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP023', '2025-11-10', '08:20:00', '17:00:00', 'late', 8.00, 0.00, 20, 'Late arrival'),
('EMP023', '2025-11-11', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP023', '2025-11-12', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP023', '2025-11-13', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP023', '2025-11-14', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP023', '2025-11-15', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP023', '2025-11-16', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP023', '2025-11-17', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP023', '2025-11-18', '08:15:00', '17:00:00', 'late', 8.00, 0.00, 15, 'Late arrival'),
('EMP023', '2025-11-19', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP023', '2025-11-20', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP023', '2025-11-21', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP023', '2025-11-22', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP023', '2025-11-23', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP023', '2025-11-24', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP023', '2025-11-25', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP023', '2025-11-26', '08:00:00', '19:00:00', 'present', 10.00, 2.00, 0, 'Overtime work'),
('EMP023', '2025-11-27', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP023', '2025-11-28', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP023', '2025-11-29', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
-- December 2025 for EMP023 (Balanced with occasional issues)
('EMP023', '2025-12-01', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP023', '2025-12-02', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP023', '2025-12-03', '08:00:00', '18:00:00', 'present', 9.00, 1.00, 0, 'Overtime work'),
('EMP023', '2025-12-04', '08:20:00', '17:00:00', 'late', 8.00, 0.00, 20, 'Late arrival'),
('EMP023', '2025-12-05', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP023', '2025-12-08', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP023', '2025-12-09', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP023', '2025-12-10', '08:00:00', '19:00:00', 'present', 10.00, 2.00, 0, 'Overtime work'),
('EMP023', '2025-12-11', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP023', '2025-12-12', '08:15:00', '17:00:00', 'late', 8.00, 0.00, 15, 'Late arrival'),
-- EMP024: Mixed pattern - Very bad attendance with many absences and late
('EMP024', '2025-11-01', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP024', '2025-11-02', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP024', '2025-11-03', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP024', '2025-11-04', '09:15:00', '17:00:00', 'late', 8.00, 0.00, 75, 'Late arrival'),
('EMP024', '2025-11-05', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP024', '2025-11-06', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP024', '2025-11-07', '08:50:00', '17:00:00', 'late', 8.00, 0.00, 50, 'Late arrival'),
('EMP024', '2025-11-08', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP024', '2025-11-09', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP024', '2025-11-10', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP024', '2025-11-11', '09:30:00', '17:00:00', 'late', 8.00, 0.00, 90, 'Late arrival'),
('EMP024', '2025-11-12', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP024', '2025-11-13', '08:45:00', '17:00:00', 'late', 8.00, 0.00, 45, 'Late arrival'),
('EMP024', '2025-11-14', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP024', '2025-11-15', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP024', '2025-11-16', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP024', '2025-11-17', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP024', '2025-11-18', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP024', '2025-11-19', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP024', '2025-11-20', '09:00:00', '17:00:00', 'late', 8.00, 0.00, 60, 'Late arrival'),
('EMP024', '2025-11-21', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP024', '2025-11-22', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP024', '2025-11-23', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP024', '2025-11-24', '08:35:00', '17:00:00', 'late', 8.00, 0.00, 35, 'Late arrival'),
('EMP024', '2025-11-25', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP024', '2025-11-26', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP024', '2025-11-27', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP024', '2025-11-28', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP024', '2025-11-29', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
-- December 2025 for EMP024 (Very bad attendance)
('EMP024', '2025-12-01', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP024', '2025-12-02', '09:15:00', '17:00:00', 'late', 8.00, 0.00, 75, 'Late arrival'),
('EMP024', '2025-12-03', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP024', '2025-12-04', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP024', '2025-12-05', '08:50:00', '17:00:00', 'late', 8.00, 0.00, 50, 'Late arrival'),
('EMP024', '2025-12-08', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP024', '2025-12-09', '09:30:00', '17:00:00', 'late', 8.00, 0.00, 90, 'Late arrival'),
('EMP024', '2025-12-10', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
('EMP024', '2025-12-11', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP024', '2025-12-12', NULL, NULL, 'absent', 0.00, 0.00, 0, 'Absent'),
-- EMP025: Mixed pattern - Good attendance with occasional leave
('EMP025', '2025-11-01', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP025', '2025-11-02', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP025', '2025-11-03', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP025', '2025-11-04', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP025', '2025-11-05', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP025', '2025-11-06', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP025', '2025-11-07', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP025', '2025-11-08', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP025', '2025-11-09', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP025', '2025-11-10', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP025', '2025-11-11', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP025', '2025-11-12', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP025', '2025-11-13', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP025', '2025-11-14', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP025', '2025-11-15', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP025', '2025-11-16', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP025', '2025-11-17', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP025', '2025-11-18', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP025', '2025-11-19', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP025', '2025-11-20', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP025', '2025-11-21', '08:00:00', '18:00:00', 'present', 9.00, 1.00, 0, 'Overtime work'),
('EMP025', '2025-11-22', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP025', '2025-11-23', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
('EMP025', '2025-11-24', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP025', '2025-11-25', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP025', '2025-11-26', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP025', '2025-11-27', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP025', '2025-11-28', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP025', '2025-11-29', NULL, NULL, 'absent', 0.00, 0.00, 0, ''),
-- December 2025 for EMP025 (Good attendance with occasional leave)
('EMP025', '2025-12-01', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP025', '2025-12-02', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP025', '2025-12-03', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP025', '2025-12-04', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP025', '2025-12-05', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP025', '2025-12-08', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP025', '2025-12-09', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day'),
('EMP025', '2025-12-10', NULL, NULL, 'leave', 0.00, 0.00, 0, 'Leave'),
('EMP025', '2025-12-11', '08:00:00', '18:00:00', 'present', 9.00, 1.00, 0, 'Overtime work'),
('EMP025', '2025-12-12', '08:00:00', '17:00:00', 'present', 8.00, 0.00, 0, 'Regular work day')

ON DUPLICATE KEY UPDATE hours_worked = VALUES(hours_worked), status = VALUES(status), overtime_hours = VALUES(overtime_hours), late_minutes = VALUES(late_minutes);
-- ========================================
-- 4E. HRIS ADDITIONAL TABLES (Leave, Contracts, Onboarding, Recruitment)
-- ========================================

-- Leave Types
INSERT INTO leave_type (leave_type_id, leave_name, purpose, duration, paid_unpaid) VALUES
(1, 'Vacation Leave', 'Annual vacation time', 'Per year', 'paid'),
(2, 'Sick Leave', 'Medical leave for illness', 'Per year', 'paid'),
(3, 'Maternity Leave', 'Maternity and childcare', 'Per occurrence', 'paid'),
(4, 'Paternity Leave', 'Paternity and childcare', 'Per occurrence', 'paid'),
(5, 'Emergency Leave', 'Family emergencies', 'Per year', 'paid'),
(6, 'Bereavement Leave', 'Death in family', 'Per occurrence', 'paid'),
(7, 'Service Incentive Leave', 'Service recognition', 'Per year', 'paid'),
(8, 'Sabbatical Leave', 'Extended leave for personal development', 'As needed', 'unpaid'),
(9, 'Study Leave', 'Educational purposes', 'As needed', 'unpaid'),
(10, 'Emergency Leave', 'Unforeseen circumstances', 'As needed', 'unpaid')
ON DUPLICATE KEY UPDATE leave_name = VALUES(leave_name);

-- Leave Requests
INSERT INTO leave_request (leave_request_id, employee_id, leave_type_id, start_date, end_date, total_days, reason, status, approver_id, date_requested, date_approved) VALUES
(1, 1, 1, '2025-12-20', '2025-12-22', 3, 'Year-end vacation with family', 'approved', 5, '2025-12-01', '2025-12-02'),
(2, 3, 2, '2025-11-15', '2025-11-16', 2, 'Medical treatment', 'approved', 5, '2025-11-14', '2025-11-14'),
(3, 7, 1, '2025-12-28', '2025-12-31', 4, 'Holiday vacation', 'pending', NULL, '2025-12-10', NULL),
(4, 12, 6, '2025-11-10', '2025-11-11', 2, 'Family bereavement', 'approved', 2, '2025-11-09', '2025-11-09'),
(5, 8, 3, '2025-01-15', '2025-03-15', 60, 'Maternity leave', 'approved', 2, '2024-12-01', '2024-12-02'),
(6, 15, 5, '2025-12-05', '2025-12-05', 1, 'Family emergency', 'approved', 5, '2025-12-04', '2025-12-04'),
(7, 20, 1, '2025-12-25', '2025-12-27', 3, 'Holiday vacation', 'pending', NULL, '2025-12-15', NULL)
ON DUPLICATE KEY UPDATE status = VALUES(status);

-- Contracts
INSERT INTO contract (contract_id, employee_id, contract_type, start_date, end_date, salary, benefits) VALUES
(1, 1, 'Regular Employment', '2020-01-15', NULL, 65000.00, 'Health insurance, 13th month pay, retirement plan'),
(2, 2, 'Regular Employment', '2019-06-01', NULL, 200000.00, 'Executive benefits package, health insurance, car allowance'),
(3, 16, 'Contractual', '2022-05-01', '2025-04-30', 28000.00, 'Health insurance'),
(4, 17, 'Contractual', '2022-04-15', '2025-04-14', 38000.00, 'Health insurance'),
(5, 19, 'Contractual', '2022-06-01', '2025-05-31', 30000.00, 'Health insurance'),
(6, 20, 'Part-time', '2022-07-01', NULL, 25000.00, 'Pro-rated benefits'),
(7, 24, 'Contractual', '2022-08-01', '2025-07-31', 35000.00, 'Health insurance'),
(8, 3, 'Regular Employment', '2021-02-01', NULL, 220000.00, 'Executive benefits package, health insurance, technology allowance')
ON DUPLICATE KEY UPDATE salary = VALUES(salary);


-- Attendance (Alternative attendance table using employee_id)
INSERT INTO attendance (attendance_id, employee_id, date, time_in, time_out, total_hours, status, remarks) VALUES
(1, 1, '2025-11-03', '2025-11-03 08:00:00', '2025-11-03 17:00:00', 8.00, 'Present', 'Regular work day'),
(2, 2, '2025-11-03', '2025-11-03 08:15:00', '2025-11-03 17:30:00', 8.25, 'Present', 'Late arrival'),
(3, 3, '2025-11-03', '2025-11-03 08:00:00', '2025-11-03 18:00:00', 9.00, 'Present', 'Overtime work'),
(4, 1, '2025-11-04', '2025-11-04 08:20:00', '2025-11-04 17:00:00', 7.67, 'Late', 'Late arrival - 20 minutes'),
(5, 5, '2025-11-05', NULL, NULL, 0.00, 'Absent', 'Absent without leave')
ON DUPLICATE KEY UPDATE status = VALUES(status);

-- System Logs
INSERT INTO system_logs (log_level, log_type, user_id, employee_id, ip_address, user_agent, action, details, request_data, created_at) VALUES
('INFO', 'authentication', 1, 1, '192.168.1.100', 'Mozilla/5.0', 'User Login', 'Admin user logged in successfully', '{"username":"admin"}', NOW() - INTERVAL 2 DAY),
('INFO', 'payroll', 1, 1, '192.168.1.100', 'Mozilla/5.0', 'Payroll Run', 'Payroll processed for November 2025', '{"period":"2025-11","employees":25}', NOW() - INTERVAL 5 DAY),
('WARNING', 'attendance', NULL, 5, '192.168.1.105', 'Mobile App', 'Late Arrival', 'Employee arrived 30 minutes late', '{"employee_id":5,"late_minutes":30}', NOW() - INTERVAL 3 DAY),
('ERROR', 'integration', 1, NULL, '192.168.1.100', 'API Client', 'HRIS Sync Failed', 'Failed to sync employee data from external HRIS', '{"error":"Connection timeout"}', NOW() - INTERVAL 1 DAY),
('INFO', 'loan', 1, 1, '192.168.1.100', 'Mozilla/5.0', 'Loan Created', 'New loan created for employee', '{"loan_no":"LN-1026","employee":"EMP001"}', NOW() - INTERVAL 7 DAY)
ON DUPLICATE KEY UPDATE created_at = VALUES(created_at);

-- Login Attempts
INSERT INTO login_attempts (attempt_id, username, ip_address, attempt_time, success, failure_reason) VALUES
(1, 'admin', '192.168.1.100', NOW() - INTERVAL 2 DAY, TRUE, NULL),
(2, 'admin', '192.168.1.105', NOW() - INTERVAL 3 DAY, FALSE, 'Invalid password'),
(3, 'admin', '192.168.1.100', NOW() - INTERVAL 1 DAY, TRUE, NULL),
(4, 'juan.santos', '192.168.1.110', NOW() - INTERVAL 5 DAY, FALSE, 'User not found'),
(5, 'admin', '10.0.0.50', NOW() - INTERVAL 6 DAY, FALSE, 'Account locked - too many attempts')
ON DUPLICATE KEY UPDATE attempt_time = VALUES(attempt_time);

-- Payroll Payslips (Alternative payslip table using employee_id)
INSERT INTO payroll_payslips (payslip_id, employee_id, pay_period_start, pay_period_end, gross_salary, deduction, net_pay, release_date) VALUES
(1, 1, '2024-11-01', '2024-11-30', 65000.00, 11700.00, 53300.00, '2024-12-05'),
(2, 2, '2024-11-01', '2024-11-30', 200000.00, 36000.00, 164000.00, '2024-12-05'),
(3, 3, '2024-11-01', '2024-11-30', 220000.00, 39600.00, 180400.00, '2024-12-05'),
(4, 8, '2024-11-01', '2024-11-30', 48000.00, 8640.00, 39360.00, '2024-12-05'),
(5, 12, '2024-11-01', '2024-11-30', 35000.00, 6300.00, 28700.00, '2024-12-05')
ON DUPLICATE KEY UPDATE gross_salary = VALUES(gross_salary);


-- ========================================
-- 5. BANK ACCOUNTS
-- ========================================

INSERT INTO bank_accounts (code, name, bank_name, account_number, currency, current_balance, is_active) VALUES
('BANK001', 'Evergreen Main Account', 'BDO Unibank', '1234567890', 'PHP', 2500000.00, TRUE),
('BANK002', 'Evergreen Payroll Account', 'Metrobank', '9876543210', 'PHP', 500000.00, TRUE),
('BANK003', 'Evergreen Operations Account', 'BPI', '5555666677', 'PHP', 1000000.00, TRUE),
('BANK004', 'Evergreen Investment Account', 'Security Bank', 'SB123456789', 'PHP', 1500000.00, TRUE),
('BANK005', 'Evergreen Savings Account', 'EastWest Bank', 'EW987654321', 'PHP', 750000.00, TRUE),
('BANK006', 'Evergreen USD Account', 'BDO Unibank', 'BDO-USD-001', 'USD', 50000.00, TRUE),
('BANK007', 'Evergreen Petty Cash', 'Cash', 'CASH-001', 'PHP', 50000.00, TRUE),
('BANK008', 'Evergreen Emergency Fund', 'UnionBank', 'UB456789123', 'PHP', 300000.00, TRUE)
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- ========================================
-- 6. SALARY COMPONENTS
-- ========================================

-- EARNINGS
INSERT INTO salary_components (code, name, type, calculation_method, value, description, is_active) VALUES
('BASIC', 'Basic Salary', 'earning', 'fixed', 25000.00, 'Monthly basic salary', TRUE),
('MEAL', 'Meal Allowance', 'earning', 'fixed', 2000.00, 'Monthly meal allowance', TRUE),
('COMM', 'Communication Allowance', 'earning', 'fixed', 1500.00, 'Monthly communication allowance', TRUE),
('RICE', 'Rice Subsidy Allowance', 'earning', 'fixed', 1000.00, 'Monthly rice subsidy', TRUE),
('TRANSPORT', 'Transportation Allowance', 'earning', 'fixed', 3000.00, 'Monthly transportation allowance', TRUE),
('NIGHT', 'Night Shift Pay', 'earning', 'per_hour', 50.00, 'Per hour night shift differential', TRUE),
('OT', 'Overtime Pay', 'earning', 'per_hour', 75.00, 'Per hour overtime rate', TRUE),
('WFH_WIFI', 'WFH Wifi Allowance', 'earning', 'fixed', 500.00, 'Work from home wifi allowance', TRUE),
('WFH_ELEC', 'WFH Electricity Subsidy', 'earning', 'fixed', 800.00, 'Work from home electricity subsidy', TRUE),
('BONUS', 'Performance Bonus', 'earning', 'fixed', 5000.00, 'Monthly performance bonus', TRUE),
('COMMISSION', 'Sales Commission', 'earning', 'percent', 2.50, '2.5% of sales', TRUE),
('HAZARD', 'Hazard Pay', 'earning', 'fixed', 1000.00, 'Hazardous work allowance', TRUE),
('SHIFT', 'Shift Differential', 'earning', 'per_hour', 25.00, 'Shift differential pay', TRUE)
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- DEDUCTIONS
INSERT INTO salary_components (code, name, type, calculation_method, value, description, is_active) VALUES
('SSS_EMP', 'SSS Employee Contribution', 'deduction', 'percent', 4.50, 'SSS employee contribution', TRUE),
('PAGIBIG_EMP', 'Pag-IBIG Employee Contribution', 'deduction', 'fixed', 100.00, 'Pag-IBIG employee contribution', TRUE),
('PHILHEALTH_EMP', 'PhilHealth Employee Contribution', 'deduction', 'percent', 3.00, 'PhilHealth employee contribution', TRUE),
('WHT', 'Withholding Tax', 'deduction', 'formula', 0.00, 'BIR withholding tax', TRUE),
('LOAN', 'Salary Loan Deduction', 'deduction', 'fixed', 2000.00, 'Monthly salary loan payment', TRUE),
('ADVANCE', 'Salary Advance', 'deduction', 'fixed', 1500.00, 'Salary advance deduction', TRUE),
('UNIFORM', 'Uniform Deduction', 'deduction', 'fixed', 300.00, 'Uniform cost deduction', TRUE),
('MEDICAL', 'Medical Deduction', 'deduction', 'fixed', 500.00, 'Medical insurance deduction', TRUE),
('LATE', 'Late Deduction', 'deduction', 'per_hour', 50.00, 'Late arrival deduction', TRUE),
('ABSENT', 'Absence Deduction', 'deduction', 'per_day', 1000.00, 'Absence deduction', TRUE)
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- TAXES
INSERT INTO salary_components (code, name, type, calculation_method, value, description, is_active) VALUES
('SSS_TAX', 'SSS Employee Contributions', 'tax', 'percent', 4.50, 'SSS employee contribution', TRUE),
('PAGIBIG_TAX', 'Pag-IBIG (HDMF) Employee Contributions', 'tax', 'fixed', 100.00, 'Pag-IBIG employee contribution', TRUE),
('PHILHEALTH_TAX', 'PhilHealth Employee Contributions', 'tax', 'percent', 3.00, 'PhilHealth employee contribution', TRUE),
('WHT_TAX', 'Withholding Tax', 'tax', 'formula', 0.00, 'BIR withholding tax', TRUE)
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- EMPLOYER CONTRIBUTIONS
INSERT INTO salary_components (code, name, type, calculation_method, value, description, is_active) VALUES
('PAGIBIG_ER', 'Pag-IBIG (HDMF) Employer Contribution', 'employer_contrib', 'fixed', 100.00, 'Pag-IBIG employer contribution', TRUE),
('PHILHEALTH_ER', 'PhilHealth Employer Contribution', 'employer_contrib', 'percent', 3.00, 'PhilHealth employer contribution', TRUE),
('SSS_EC_ER', 'SSS EC ER Contribution', 'employer_contrib', 'fixed', 10.00, 'SSS EC employer contribution', TRUE),
('SSS_ER', 'SSS Employer Contribution', 'employer_contrib', 'percent', 8.50, 'SSS employer contribution', TRUE),
('13TH_MONTH', '13th Month Pay', 'employer_contrib', 'percent', 8.33, '13th month pay', TRUE),
('SIL', 'Service Incentive Leave', 'employer_contrib', 'percent', 0.83, 'Service incentive leave', TRUE)
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- ========================================
-- 8. LOAN TYPES
-- ========================================

INSERT INTO loan_types (code, name, max_amount, max_term_months, interest_rate, description, is_active) VALUES
('SALARY', 'Salary Loan', 50000.00, 12, 0.05, 'Employee salary loan', TRUE),
('EMERGENCY', 'Emergency Loan', 25000.00, 6, 0.08, 'Emergency financial assistance', TRUE),
('HOUSING', 'Housing Loan', 500000.00, 60, 0.06, 'Housing loan assistance', TRUE),
('EDUCATION', 'Education Loan', 100000.00, 24, 0.04, 'Educational assistance loan', TRUE),
('VEHICLE', 'Vehicle Loan', 300000.00, 36, 0.07, 'Vehicle purchase loan', TRUE),
('MEDICAL', 'Medical Loan', 15000.00, 12, 0.03, 'Medical emergency loan', TRUE),
('APPLIANCE', 'Appliance Loan', 20000.00, 18, 0.05, 'Home appliance loan', TRUE),
-- Additional loan types from sample_loan_data.sql
('PL', 'Personal Loan', 500000.00, 60, 12.5000, 'Personal loans for employees', TRUE),
('HL', 'Housing Loan (Extended)', 2000000.00, 360, 8.5000, 'Housing/Home loans with extended terms', TRUE),
('VL', 'Vehicle Loan (Extended)', 1000000.00, 60, 10.0000, 'Auto/Vehicle loans', TRUE),
('EL', 'Emergency Loan (Extended)', 100000.00, 12, 15.0000, 'Quick emergency loans', TRUE),
('SL', 'Salary Loan (Extended)', 200000.00, 24, 14.0000, 'Salary advance loans with higher limits', TRUE)
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- ========================================
-- 8.5 TRANSACTION TYPES
-- ========================================

INSERT INTO transaction_types (type_name, description) VALUES
('Deposit', 'Cash or check deposit into account'),
('Withdrawal', 'Cash withdrawal from account'),
('Transfer', 'Fund transfer between accounts'),
('Payment', 'Bill or loan payment'),
('Fee', 'Service or maintenance fee')
ON DUPLICATE KEY UPDATE type_name = VALUES(type_name);

-- ========================================
-- 9. BANK CUSTOMERS & ACCOUNTS
-- ========================================

-- 50 Bank Customers
INSERT INTO bank_customers (first_name, last_name, email, phone, address) VALUES
('Juan', 'Dela Cruz', 'juan.delacruz@email.com', '09171234501', '123 Rizal St, Manila'),
('Maria', 'Santos', 'maria.santos@email.com', '09171234502', '456 Mabini Ave, Quezon City'),
('Jose', 'Reyes', 'jose.reyes@email.com', '09171234503', '789 Bonifacio Blvd, Makati'),
('Ana', 'Garcia', 'ana.garcia@email.com', '09171234504', '321 Luna St, Pasig'),
('Pedro', 'Ramos', 'pedro.ramos@email.com', '09171234505', '654 Del Pilar St, Taguig'),
('Rosa', 'Cruz', 'rosa.cruz@email.com', '09171234506', '987 Aguinaldo Ave, Cavite'),
('Carlos', 'Torres', 'carlos.torres@email.com', '09171234507', '147 Quezon Blvd, Caloocan'),
('Elena', 'Flores', 'elena.flores@email.com', '09171234508', '258 Roxas St, Mandaluyong'),
('Miguel', 'Rivera', 'miguel.rivera@email.com', '09171234509', '369 Osmena Ave, Paranaque'),
('Sofia', 'Mendoza', 'sofia.mendoza@email.com', '09171234510', '741 Magsaysay Blvd, San Juan'),
('Antonio', 'Hernandez', 'antonio.hernandez@email.com', '09171234511', '852 Laurel St, Las Pinas'),
('Carmen', 'Lopez', 'carmen.lopez@email.com', '09171234512', '963 Aquino Ave, Muntinlupa'),
('Roberto', 'Martinez', 'roberto.martinez@email.com', '09171234513', '159 Marcos Highway, Marikina'),
('Teresa', 'Gonzales', 'teresa.gonzales@email.com', '09171234514', '267 Katipunan Ave, Quezon City'),
('Fernando', 'Bautista', 'fernando.bautista@email.com', '09171234515', '378 Shaw Blvd, Pasig'),
('Isabel', 'Villanueva', 'isabel.villanueva@email.com', '09171234516', '489 EDSA, Mandaluyong'),
('Ricardo', 'Aquino', 'ricardo.aquino@email.com', '09171234517', '591 Aurora Blvd, Quezon City'),
('Lucia', 'Castillo', 'lucia.castillo@email.com', '09171234518', '612 Taft Ave, Manila'),
('Manuel', 'Pascual', 'manuel.pascual@email.com', '09171234519', '723 España Blvd, Manila'),
('Gloria', 'Fernandez', 'gloria.fernandez@email.com', '09171234520', '834 Ortigas Ave, Pasig'),
('Andres', 'De Leon', 'andres.deleon@email.com', '09171234521', '945 C5 Road, Taguig'),
('Patricia', 'Morales', 'patricia.morales@email.com', '09171234522', '156 Alabang-Zapote Rd, Las Pinas'),
('Enrique', 'Castro', 'enrique.castro@email.com', '09171234523', '267 Sucat Rd, Paranaque'),
('Beatriz', 'Soriano', 'beatriz.soriano@email.com', '09171234524', '378 Molino Blvd, Bacoor'),
('Ramon', 'Tan', 'ramon.tan@email.com', '09171234525', '489 Daang Hari, Cavite'),
('Cristina', 'Lim', 'cristina.lim@email.com', '09171234526', '591 Congressional Ave, Quezon City'),
('Eduardo', 'Go', 'eduardo.go@email.com', '09171234527', '612 Visayas Ave, Quezon City'),
('Margarita', 'Sy', 'margarita.sy@email.com', '09171234528', '723 Mindanao Ave, Quezon City'),
('Alejandro', 'Chua', 'alejandro.chua@email.com', '09171234529', '834 Commonwealth Ave, Quezon City'),
('Victoria', 'Ong', 'victoria.ong@email.com', '09171234530', '945 Regalado Ave, Quezon City'),
('Francisco', 'Yap', 'francisco.yap@email.com', '09171234531', '156 Quirino Highway, Novaliches'),
('Dolores', 'Co', 'dolores.co@email.com', '09171234532', '267 Sumulong Highway, Antipolo'),
('Gregorio', 'Yu', 'gregorio.yu@email.com', '09171234533', '378 Marcos Highway, Cainta'),
('Esperanza', 'Lee', 'esperanza.lee@email.com', '09171234534', '489 Ortigas Extension, Taytay'),
('Joaquin', 'Uy', 'joaquin.uy@email.com', '09171234535', '591 Manila East Rd, Rizal'),
('Rosario', 'Ang', 'rosario.ang@email.com', '09171234536', '612 JP Rizal Ave, Makati'),
('Alfredo', 'Wu', 'alfredo.wu@email.com', '09171234537', '723 Gil Puyat Ave, Makati'),
('Pilar', 'Cheng', 'pilar.cheng@email.com', '09171234538', '834 Ayala Ave, Makati'),
('Emilio', 'Huang', 'emilio.huang@email.com', '09171234539', '945 Buendia Ave, Makati'),
('Consuelo', 'Lin', 'consuelo.lin@email.com', '09171234540', '156 Pasay Rd, Makati'),
('Sergio', 'Chen', 'sergio.chen@email.com', '09171234541', '267 Chino Roces Ave, Makati'),
('Remedios', 'Wang', 'remedios.wang@email.com', '09171234542', '378 Kalayaan Ave, Makati'),
('Tomas', 'Li', 'tomas.li@email.com', '09171234543', '489 Jupiter St, Makati'),
('Natividad', 'Zhang', 'natividad.zhang@email.com', '09171234544', '591 Rockwell Dr, Makati'),
('Felipe', 'Domingo', 'felipe.domingo@email.com', '09171234545', '612 Estrella St, Makati'),
('Consolacion', 'Santiago', 'consolacion.santiago@email.com', '09171234546', '723 Pasong Tamo, Makati'),
('Gerardo', 'Navarro', 'gerardo.navarro@email.com', '09171234547', '834 Reposo St, Makati'),
('Milagros', 'Ignacio', 'milagros.ignacio@email.com', '09171234548', '945 Amorsolo St, Makati'),
('Augusto', 'Mercado', 'augusto.mercado@email.com', '09171234549', '156 Leviste St, Makati'),
('Felicidad', 'Salvador', 'felicidad.salvador@email.com', '09171234550', '267 Valero St, Makati')
ON DUPLICATE KEY UPDATE first_name = VALUES(first_name);

-- 75 Customer Accounts (AC-101 to AC-175)
INSERT INTO customer_accounts (customer_id, account_number, account_type, balance, status) VALUES
(1, 'AC-101', 'savings', 125000.00, 'active'),
(1, 'AC-102', 'checking', 85000.00, 'active'),
(2, 'AC-103', 'savings', 250000.00, 'active'),
(2, 'AC-104', 'business', 500000.00, 'active'),
(3, 'AC-105', 'savings', 75000.00, 'active'),
(3, 'AC-106', 'checking', 42000.00, 'active'),
(4, 'AC-107', 'savings', 180000.00, 'active'),
(4, 'AC-108', 'business', 350000.00, 'active'),
(5, 'AC-109', 'savings', 95000.00, 'active'),
(5, 'AC-110', 'checking', 63000.00, 'active'),
(6, 'AC-111', 'savings', 210000.00, 'active'),
(7, 'AC-112', 'checking', 78000.00, 'active'),
(7, 'AC-113', 'business', 420000.00, 'active'),
(8, 'AC-114', 'savings', 145000.00, 'active'),
(9, 'AC-115', 'savings', 310000.00, 'active'),
(9, 'AC-116', 'checking', 92000.00, 'active'),
(10, 'AC-117', 'savings', 67000.00, 'active'),
(10, 'AC-118', 'business', 280000.00, 'active'),
(11, 'AC-119', 'savings', 198000.00, 'active'),
(12, 'AC-120', 'checking', 55000.00, 'active'),
(12, 'AC-121', 'savings', 120000.00, 'active'),
(13, 'AC-122', 'business', 750000.00, 'active'),
(14, 'AC-123', 'savings', 88000.00, 'active'),
(14, 'AC-124', 'checking', 47000.00, 'active'),
(15, 'AC-125', 'savings', 165000.00, 'active'),
(16, 'AC-126', 'business', 620000.00, 'active'),
(16, 'AC-127', 'savings', 95000.00, 'active'),
(17, 'AC-128', 'checking', 72000.00, 'active'),
(18, 'AC-129', 'savings', 230000.00, 'active'),
(18, 'AC-130', 'business', 480000.00, 'active'),
(19, 'AC-131', 'savings', 105000.00, 'active'),
(20, 'AC-132', 'checking', 68000.00, 'active'),
(20, 'AC-133', 'savings', 142000.00, 'active'),
(21, 'AC-134', 'business', 390000.00, 'active'),
(22, 'AC-135', 'savings', 78000.00, 'active'),
(22, 'AC-136', 'checking', 53000.00, 'active'),
(23, 'AC-137', 'savings', 195000.00, 'active'),
(24, 'AC-138', 'business', 550000.00, 'active'),
(24, 'AC-139', 'savings', 112000.00, 'active'),
(25, 'AC-140', 'checking', 85000.00, 'active'),
(26, 'AC-141', 'savings', 175000.00, 'active'),
(26, 'AC-142', 'business', 430000.00, 'active'),
(27, 'AC-143', 'savings', 92000.00, 'active'),
(28, 'AC-144', 'checking', 61000.00, 'active'),
(28, 'AC-145', 'savings', 138000.00, 'active'),
(29, 'AC-146', 'business', 680000.00, 'active'),
(30, 'AC-147', 'savings', 83000.00, 'active'),
(30, 'AC-148', 'checking', 49000.00, 'active'),
(31, 'AC-149', 'savings', 215000.00, 'active'),
(32, 'AC-150', 'business', 520000.00, 'active'),
(33, 'AC-151', 'savings', 97000.00, 'active'),
(33, 'AC-152', 'checking', 74000.00, 'active'),
(34, 'AC-153', 'savings', 188000.00, 'active'),
(35, 'AC-154', 'business', 410000.00, 'active'),
(35, 'AC-155', 'savings', 108000.00, 'active'),
(36, 'AC-156', 'checking', 56000.00, 'active'),
(37, 'AC-157', 'savings', 225000.00, 'active'),
(38, 'AC-158', 'business', 590000.00, 'active'),
(38, 'AC-159', 'savings', 130000.00, 'active'),
(39, 'AC-160', 'checking', 82000.00, 'active'),
(40, 'AC-161', 'savings', 155000.00, 'active'),
(40, 'AC-162', 'business', 470000.00, 'active'),
(41, 'AC-163', 'savings', 100000.00, 'active'),
(42, 'AC-164', 'checking', 67000.00, 'active'),
(42, 'AC-165', 'savings', 148000.00, 'active'),
(43, 'AC-166', 'business', 360000.00, 'active'),
(44, 'AC-167', 'savings', 87000.00, 'active'),
(44, 'AC-168', 'checking', 52000.00, 'active'),
(45, 'AC-169', 'savings', 205000.00, 'active'),
(46, 'AC-170', 'business', 540000.00, 'active'),
(46, 'AC-171', 'savings', 115000.00, 'active'),
(47, 'AC-172', 'checking', 79000.00, 'active'),
(48, 'AC-173', 'savings', 172000.00, 'active'),
(49, 'AC-174', 'business', 450000.00, 'active'),
(50, 'AC-175', 'savings', 135000.00, 'active')
ON DUPLICATE KEY UPDATE balance = VALUES(balance);

-- Bank Transactions - Comprehensive data for all 75 accounts (554 transactions)
-- Transaction Types: 1=Deposit, 2=Withdrawal, 3=Transfer, 4=Payment, 5=Fee
INSERT INTO bank_transactions (transaction_ref, account_id, transaction_type_id, amount, description, created_at) VALUES

-- ============================================
-- AC-101 (account_id=1) Juan Dela Cruz - Savings
-- ============================================
('TXN-2025-0001', 1, 1, 50000.00, 'Initial deposit - savings account', '2025-01-02 09:15:00'),
('TXN-2025-0002', 1, 2, -15000.00, 'ATM withdrawal', '2025-01-07 16:45:00'),
('TXN-2025-0003', 1, 1, 68000.00, 'Salary deposit - January', '2025-02-01 09:00:00'),
('TXN-2025-0004', 1, 4, -5000.00, 'Electric bill payment', '2025-02-10 14:30:00'),
('TXN-2025-0005', 1, 1, 68000.00, 'Salary deposit - February', '2025-03-01 09:00:00'),
('TXN-2025-0006', 1, 2, -20000.00, 'Cash withdrawal', '2025-03-15 11:00:00'),
('TXN-2025-0007', 1, 1, 68000.00, 'Salary deposit - March', '2025-04-01 09:00:00'),
('TXN-2025-0008', 1, 4, -8500.00, 'Water and internet bill', '2025-04-12 10:30:00'),
('TXN-2025-0009', 1, 1, 68000.00, 'Salary deposit - April', '2025-05-01 09:00:00'),
('TXN-2025-0010', 1, 2, -25000.00, 'Emergency withdrawal', '2025-05-20 15:00:00'),
('TXN-2025-0011', 1, 5, -500.00, 'Monthly maintenance fee', '2025-05-31 23:59:00'),
('TXN-2025-0012', 1, 1, 68000.00, 'Salary deposit - May', '2025-06-01 09:00:00'),
('TXN-2025-0013', 1, 3, -10000.00, 'Transfer to checking AC-102', '2025-06-15 10:00:00'),
('TXN-2025-0014', 1, 1, 68000.00, 'Salary deposit - June', '2025-07-01 09:00:00'),
('TXN-2025-0015', 1, 2, -12000.00, 'ATM withdrawal', '2025-07-18 14:00:00'),
('TXN-2025-0016', 1, 1, 68000.00, 'Salary deposit - July', '2025-08-01 09:00:00'),
('TXN-2025-0017', 1, 4, -6200.00, 'Phone bill payment', '2025-08-10 11:30:00'),
('TXN-2025-0018', 1, 1, 68000.00, 'Salary deposit - August', '2025-09-01 09:00:00'),
('TXN-2025-0019', 1, 2, -30000.00, 'Tuition payment withdrawal', '2025-09-12 09:30:00'),
('TXN-2025-0020', 1, 1, 68000.00, 'Salary deposit - September', '2025-10-01 09:00:00'),
('TXN-2025-0021', 1, 1, 68000.00, 'Salary deposit - October', '2025-11-01 09:00:00'),
('TXN-2025-0022', 1, 2, -18000.00, 'Holiday shopping withdrawal', '2025-11-25 14:00:00'),
('TXN-2025-0023', 1, 1, 136000.00, '13th month pay + December salary', '2025-12-01 09:00:00'),
('TXN-2025-0024', 1, 2, -45000.00, 'Christmas expenses withdrawal', '2025-12-20 10:00:00'),
('TXN-2025-0025', 1, 5, -500.00, 'Annual maintenance fee', '2025-12-31 23:59:00'),
('TXN-2026-0001', 1, 1, 70000.00, 'Salary deposit - January 2026', '2026-01-02 09:00:00'),
('TXN-2026-0002', 1, 4, -5500.00, 'Utility bills', '2026-01-15 10:30:00'),
('TXN-2026-0003', 1, 1, 70000.00, 'Salary deposit - February 2026', '2026-02-02 09:00:00'),
('TXN-2026-0004', 1, 2, -22000.00, 'Personal withdrawal', '2026-02-18 14:00:00'),
('TXN-2026-0005', 1, 1, 70000.00, 'Salary deposit - March 2026', '2026-03-02 09:00:00'),

-- ============================================
-- AC-102 (account_id=2) Juan Dela Cruz - Checking
-- ============================================
('TXN-2025-0026', 2, 1, 35000.00, 'Payroll deposit', '2025-01-03 10:30:00'),
('TXN-2025-0027', 2, 4, -12000.00, 'Rent payment', '2025-01-10 09:00:00'),
('TXN-2025-0028', 2, 2, -8000.00, 'Counter withdrawal', '2025-02-05 13:15:00'),
('TXN-2025-0029', 2, 1, 35000.00, 'Monthly allowance deposit', '2025-03-01 09:30:00'),
('TXN-2025-0030', 2, 4, -12000.00, 'Rent payment', '2025-03-10 09:00:00'),
('TXN-2025-0031', 2, 2, -5000.00, 'ATM withdrawal', '2025-04-08 16:00:00'),
('TXN-2025-0032', 2, 1, 35000.00, 'Monthly allowance deposit', '2025-05-01 09:30:00'),
('TXN-2025-0033', 2, 4, -12000.00, 'Rent payment', '2025-05-10 09:00:00'),
('TXN-2025-0034', 2, 1, 10000.00, 'Transfer from savings AC-101', '2025-06-15 10:00:00'),
('TXN-2025-0035', 2, 1, 48000.00, 'February payroll deposit', '2026-02-01 09:15:00'),
('TXN-2025-0036', 2, 4, -12000.00, 'Rent payment', '2026-02-10 09:00:00'),
('TXN-2025-0037', 2, 2, -7000.00, 'Personal withdrawal', '2026-03-05 14:30:00'),

-- ============================================
-- AC-103 (account_id=3) Maria Santos - Savings
-- ============================================
('TXN-2025-0038', 3, 1, 100000.00, 'Wire transfer deposit', '2025-01-05 14:20:00'),
('TXN-2025-0039', 3, 2, -30000.00, 'Large withdrawal', '2025-02-15 14:00:00'),
('TXN-2025-0040', 3, 1, 85000.00, 'Salary deposit', '2025-03-01 09:00:00'),
('TXN-2025-0041', 3, 4, -15000.00, 'Insurance premium', '2025-03-20 11:00:00'),
('TXN-2025-0042', 3, 1, 85000.00, 'Salary deposit', '2025-04-01 09:00:00'),
('TXN-2025-0043', 3, 3, -50000.00, 'Transfer to business AC-104', '2025-05-10 10:00:00'),
('TXN-2025-0044', 3, 1, 85000.00, 'Salary deposit', '2025-06-01 09:00:00'),
('TXN-2025-0045', 3, 2, -20000.00, 'Cash withdrawal', '2025-07-12 15:30:00'),
('TXN-2025-0046', 3, 1, 85000.00, 'Salary deposit', '2025-08-01 09:00:00'),
('TXN-2025-0047', 3, 1, 85000.00, 'Salary deposit', '2025-09-01 09:00:00'),
('TXN-2025-0048', 3, 2, -40000.00, 'Medical expenses', '2025-09-18 10:00:00'),
('TXN-2025-0049', 3, 1, 85000.00, 'Salary deposit', '2025-10-01 09:00:00'),
('TXN-2025-0050', 3, 1, 170000.00, '13th month + December salary', '2025-12-01 09:00:00'),
('TXN-2025-0051', 3, 2, -55000.00, 'Holiday expenses', '2025-12-22 11:00:00'),
('TXN-2026-0006', 3, 1, 88000.00, 'Salary deposit Jan 2026', '2026-01-02 09:00:00'),
('TXN-2026-0007', 3, 1, 88000.00, 'Salary deposit Feb 2026', '2026-02-02 09:00:00'),
('TXN-2026-0008', 3, 1, 78000.00, 'March deposit', '2026-03-01 09:00:00'),
('TXN-2026-0009', 3, 2, -15000.00, 'Grocery withdrawal', '2026-03-07 10:30:00'),

-- ============================================
-- AC-104 (account_id=4) Maria Santos - Business
-- ============================================
('TXN-2025-0052', 4, 1, 250000.00, 'Business revenue deposit', '2025-01-06 11:00:00'),
('TXN-2025-0053', 4, 4, -85000.00, 'Supplier payment - raw materials', '2025-01-20 14:00:00'),
('TXN-2025-0054', 4, 1, 180000.00, 'Client invoice payment', '2025-02-08 10:00:00'),
('TXN-2025-0055', 4, 4, -95000.00, 'Supplier payment', '2025-02-25 14:30:00'),
('TXN-2025-0056', 4, 1, 320000.00, 'Large contract payment', '2025-03-10 09:30:00'),
('TXN-2025-0057', 4, 4, -120000.00, 'Equipment purchase', '2025-04-05 11:00:00'),
('TXN-2025-0058', 4, 1, 275000.00, 'Monthly revenue', '2025-05-03 09:00:00'),
('TXN-2025-0059', 4, 4, -78000.00, 'Office rent and utilities', '2025-05-15 10:00:00'),
('TXN-2025-0060', 4, 1, 290000.00, 'Client payments', '2025-06-05 09:00:00'),
('TXN-2025-0061', 4, 4, -110000.00, 'Payroll disbursement', '2025-06-30 18:00:00'),
('TXN-2025-0062', 4, 1, 350000.00, 'Q3 revenue', '2025-07-10 09:00:00'),
('TXN-2025-0063', 4, 4, -145000.00, 'Tax payment BIR', '2025-07-25 10:00:00'),
('TXN-2025-0064', 4, 1, 400000.00, '13th month business revenue', '2025-12-01 09:00:00'),
('TXN-2025-0065', 4, 4, -200000.00, 'Year-end supplier payments', '2025-12-18 14:00:00'),
('TXN-2026-0010', 4, 1, 320000.00, 'Q1 2026 business deposit', '2026-01-05 10:30:00'),
('TXN-2026-0011', 4, 4, -88000.00, 'January supplier payment', '2026-01-22 14:00:00'),
('TXN-2026-0012', 4, 1, 285000.00, 'February revenue', '2026-02-06 09:00:00'),
('TXN-2026-0013', 4, 4, -92000.00, 'February expenses', '2026-02-20 14:00:00'),

-- ============================================
-- AC-105 (account_id=5) Jose Reyes - Savings
-- ============================================
('TXN-2025-0066', 5, 1, 30000.00, 'Savings deposit', '2025-01-08 09:30:00'),
('TXN-2025-0067', 5, 1, 52000.00, 'Freelance payment', '2025-02-12 10:00:00'),
('TXN-2025-0068', 5, 2, -18000.00, 'Medical expenses withdrawal', '2025-03-05 14:15:00'),
('TXN-2025-0069', 5, 1, 45000.00, 'Project payment', '2025-04-03 09:00:00'),
('TXN-2025-0070', 5, 4, -12000.00, 'Credit card payment', '2025-05-10 13:30:00'),
('TXN-2025-0071', 5, 1, 55000.00, 'Consulting fee', '2025-06-08 10:00:00'),
('TXN-2025-0072', 5, 2, -22000.00, 'Vacation expenses', '2025-07-15 11:00:00'),
('TXN-2025-0073', 5, 1, 48000.00, 'Contract payment', '2025-08-05 09:00:00'),
('TXN-2025-0074', 5, 1, 52000.00, 'Freelance work', '2025-09-08 10:30:00'),
('TXN-2025-0075', 5, 2, -15000.00, 'Home repair expenses', '2025-10-12 14:00:00'),
('TXN-2025-0076', 5, 1, 60000.00, 'Year-end bonus', '2025-12-05 09:00:00'),
('TXN-2026-0014', 5, 1, 50000.00, 'January freelance income', '2026-01-10 09:00:00'),
('TXN-2026-0015', 5, 2, -10000.00, 'Personal withdrawal', '2026-02-15 14:00:00'),

-- ============================================
-- AC-106 (account_id=6) Jose Reyes - Checking
-- ============================================
('TXN-2025-0077', 6, 1, 25000.00, 'Monthly deposit', '2025-01-15 09:00:00'),
('TXN-2025-0078', 6, 2, -8000.00, 'Counter withdrawal', '2025-01-25 13:15:00'),
('TXN-2025-0079', 6, 4, -6500.00, 'Utility bills', '2025-02-15 10:00:00'),
('TXN-2025-0080', 6, 1, 25000.00, 'Monthly deposit', '2025-03-15 09:00:00'),
('TXN-2025-0081', 6, 2, -11000.00, 'Grocery withdrawal', '2025-04-10 14:00:00'),
('TXN-2025-0082', 6, 4, -7200.00, 'Internet and phone bills', '2025-05-15 10:00:00'),
('TXN-2025-0083', 6, 1, 25000.00, 'Monthly deposit', '2025-06-15 09:00:00'),
('TXN-2025-0084', 6, 2, -9000.00, 'Cash withdrawal', '2025-08-08 16:00:00'),
('TXN-2026-0016', 6, 2, -11000.00, 'Grocery withdrawal', '2026-03-03 10:30:00'),

-- ============================================
-- AC-107 (account_id=7) Ana Garcia - Savings
-- ============================================
('TXN-2025-0085', 7, 1, 75000.00, 'Monthly salary deposit', '2025-01-05 09:00:00'),
('TXN-2025-0086', 7, 3, -20000.00, 'Transfer to business AC-108', '2025-01-20 10:00:00'),
('TXN-2025-0087', 7, 1, 75000.00, 'Salary deposit', '2025-02-05 09:00:00'),
('TXN-2025-0088', 7, 2, -15000.00, 'ATM withdrawal', '2025-03-12 14:00:00'),
('TXN-2025-0089', 7, 1, 75000.00, 'Salary deposit', '2025-04-05 09:00:00'),
('TXN-2025-0090', 7, 4, -9800.00, 'Insurance payment', '2025-05-08 10:30:00'),
('TXN-2025-0091', 7, 1, 75000.00, 'Salary deposit', '2025-06-05 09:00:00'),
('TXN-2025-0092', 7, 2, -28000.00, 'Appliance purchase', '2025-07-20 11:00:00'),
('TXN-2025-0093', 7, 1, 75000.00, 'Salary deposit', '2025-08-05 09:00:00'),
('TXN-2025-0094', 7, 1, 150000.00, '13th month + December salary', '2025-12-05 09:00:00'),
('TXN-2025-0095', 7, 2, -35000.00, 'Christmas shopping', '2025-12-19 10:00:00'),
('TXN-2026-0017', 7, 1, 78000.00, 'Salary Jan 2026', '2026-01-05 09:00:00'),
('TXN-2026-0018', 7, 1, 78000.00, 'Salary Feb 2026', '2026-02-05 09:00:00'),

-- ============================================
-- AC-108 (account_id=8) Ana Garcia - Business
-- ============================================
('TXN-2025-0096', 8, 1, 175000.00, 'Business client payment', '2025-01-13 15:30:00'),
('TXN-2025-0097', 8, 4, -65000.00, 'Supplier payment', '2025-02-05 14:00:00'),
('TXN-2025-0098', 8, 1, 190000.00, 'Business contract payment', '2025-03-10 09:30:00'),
('TXN-2025-0099', 8, 4, -72000.00, 'Office supplies and rent', '2025-04-10 11:00:00'),
('TXN-2025-0100', 8, 1, 210000.00, 'Monthly revenue', '2025-05-08 09:00:00'),
('TXN-2025-0101', 8, 4, -80000.00, 'Employee wages', '2025-06-01 18:00:00'),
('TXN-2025-0102', 8, 1, 195000.00, 'Client payments Q3', '2025-07-10 09:00:00'),
('TXN-2025-0103', 8, 1, 280000.00, 'Christmas bonus revenue', '2025-12-03 10:15:00'),
('TXN-2025-0104', 8, 4, -130000.00, 'Year-end payroll', '2025-12-28 18:00:00'),
('TXN-2026-0019', 8, 1, 185000.00, 'Jan 2026 revenue', '2026-01-08 09:00:00'),
('TXN-2026-0020', 8, 4, -68000.00, 'January expenses', '2026-01-25 14:00:00'),

-- ============================================
-- AC-109 (account_id=9) Pedro Ramos - Savings
-- ============================================
('TXN-2025-0105', 9, 1, 42000.00, 'Monthly salary', '2025-01-05 09:00:00'),
('TXN-2025-0106', 9, 4, -5000.00, 'Loan payment', '2025-01-15 09:00:00'),
('TXN-2025-0107', 9, 1, 42000.00, 'Salary deposit', '2025-02-05 09:00:00'),
('TXN-2025-0108', 9, 2, -12000.00, 'Cash withdrawal', '2025-03-10 14:00:00'),
('TXN-2025-0109', 9, 1, 42000.00, 'Salary deposit', '2025-04-05 09:00:00'),
('TXN-2025-0110', 9, 4, -8500.00, 'Utility bills', '2025-05-12 10:00:00'),
('TXN-2025-0111', 9, 1, 42000.00, 'Salary deposit', '2025-06-05 09:00:00'),
('TXN-2025-0112', 9, 2, -15000.00, 'Emergency withdrawal', '2025-07-22 15:00:00'),
('TXN-2025-0113', 9, 1, 42000.00, 'Salary deposit', '2025-08-05 09:00:00'),
('TXN-2025-0114', 9, 1, 84000.00, '13th month + salary', '2025-12-05 09:00:00'),
('TXN-2026-0021', 9, 1, 45000.00, 'Salary Jan 2026', '2026-01-05 09:00:00'),
('TXN-2026-0022', 9, 2, -12000.00, 'January expenses', '2026-01-20 14:00:00'),

-- ============================================
-- AC-110 (account_id=10) Pedro Ramos - Checking
-- ============================================
('TXN-2025-0115', 10, 1, 25000.00, 'Monthly deposit', '2025-02-01 10:00:00'),
('TXN-2025-0116', 10, 4, -6500.00, 'Water and electric bill', '2025-02-20 09:00:00'),
('TXN-2025-0117', 10, 1, 18000.00, 'Side income deposit', '2025-04-05 09:30:00'),
('TXN-2025-0118', 10, 2, -10000.00, 'Cash withdrawal', '2025-05-15 14:00:00'),
('TXN-2025-0119', 10, 1, 20000.00, 'Freelance payment', '2025-07-03 10:00:00'),
('TXN-2025-0120', 10, 4, -7200.00, 'Internet bill', '2025-08-10 10:30:00'),
('TXN-2025-0121', 10, 1, 22000.00, 'Bonus deposit', '2025-11-05 09:00:00'),
('TXN-2026-0023', 10, 4, -6500.00, 'Utility bills Jan 2026', '2026-01-18 10:00:00'),

-- ============================================
-- AC-111 (account_id=11) Rosa Cruz - Savings
-- ============================================
('TXN-2025-0122', 11, 1, 80000.00, 'Salary deposit', '2025-01-05 09:15:00'),
('TXN-2025-0123', 11, 2, -25000.00, 'Medical procedure', '2025-02-12 10:00:00'),
('TXN-2025-0124', 11, 1, 80000.00, 'Salary deposit', '2025-03-05 09:00:00'),
('TXN-2025-0125', 11, 4, -18000.00, 'Health insurance', '2025-04-08 11:00:00'),
('TXN-2025-0126', 11, 1, 80000.00, 'Salary deposit', '2025-05-05 09:00:00'),
('TXN-2025-0127', 11, 2, -12000.00, 'Shopping withdrawal', '2025-06-20 14:00:00'),
('TXN-2025-0128', 11, 1, 80000.00, 'Salary deposit', '2025-07-05 09:00:00'),
('TXN-2025-0129', 11, 1, 80000.00, 'Salary deposit', '2025-09-05 09:00:00'),
('TXN-2025-0130', 11, 1, 160000.00, '13th month + salary', '2025-12-05 09:00:00'),
('TXN-2025-0131', 11, 2, -40000.00, 'Holiday spending', '2025-12-23 11:00:00'),
('TXN-2026-0024', 11, 1, 92000.00, 'Contract payment Feb 2026', '2026-02-06 14:30:00'),

-- ============================================
-- AC-112 (account_id=12) Carlos Torres - Checking
-- ============================================
('TXN-2025-0132', 12, 1, 30000.00, 'Monthly deposit', '2025-01-10 09:00:00'),
('TXN-2025-0133', 12, 2, -12000.00, 'Bill payment withdrawal', '2025-02-05 14:00:00'),
('TXN-2025-0134', 12, 1, 30000.00, 'Monthly deposit', '2025-03-10 09:00:00'),
('TXN-2025-0135', 12, 4, -8000.00, 'Utilities payment', '2025-04-15 10:00:00'),
('TXN-2025-0136', 12, 1, 30000.00, 'Monthly deposit', '2025-05-10 09:00:00'),
('TXN-2025-0137', 12, 2, -15000.00, 'Electronics purchase', '2025-06-22 14:30:00'),
('TXN-2025-0138', 12, 1, 30000.00, 'Monthly deposit', '2025-08-10 09:00:00'),
('TXN-2025-0139', 12, 2, -9500.00, 'ATM withdrawal', '2025-10-08 16:30:00'),
('TXN-2025-0140', 12, 2, -35000.00, 'Holiday shopping withdrawal', '2025-12-05 14:00:00'),

-- ============================================
-- AC-113 (account_id=13) Carlos Torres - Business
-- ============================================
('TXN-2025-0141', 13, 1, 300000.00, 'Business deposit Q1', '2025-01-15 10:00:00'),
('TXN-2025-0142', 13, 4, -125000.00, 'Supplier payments', '2025-02-10 14:00:00'),
('TXN-2025-0143', 13, 1, 280000.00, 'Client invoices Q1', '2025-03-12 09:00:00'),
('TXN-2025-0144', 13, 4, -110000.00, 'Operating expenses', '2025-04-15 11:00:00'),
('TXN-2025-0145', 13, 1, 350000.00, 'Major contract payment', '2025-06-08 09:00:00'),
('TXN-2025-0146', 13, 4, -90000.00, 'Staff salaries', '2025-06-30 18:00:00'),
('TXN-2025-0147', 13, 1, 310000.00, 'Q3 revenue', '2025-09-05 09:00:00'),
('TXN-2025-0148', 13, 4, -155000.00, 'Equipment upgrade', '2025-10-20 11:00:00'),
('TXN-2026-0025', 13, 1, 350000.00, 'Major business deposit Q1 2026', '2026-01-10 10:00:00'),
('TXN-2026-0026', 13, 4, -95000.00, 'January operating expenses', '2026-01-28 14:00:00'),
('TXN-2026-0027', 13, 1, 185000.00, 'Client payment Feb 2026', '2026-02-12 09:00:00'),

-- ============================================
-- AC-114 (account_id=14) Elena Flores - Savings
-- ============================================
('TXN-2025-0149', 14, 1, 55000.00, 'Salary deposit', '2025-01-05 09:00:00'),
('TXN-2025-0150', 14, 3, -45000.00, 'Inter-account transfer', '2025-02-07 16:00:00'),
('TXN-2025-0151', 14, 1, 55000.00, 'Salary deposit', '2025-03-05 09:00:00'),
('TXN-2025-0152', 14, 2, -20000.00, 'Cash withdrawal', '2025-04-18 14:00:00'),
('TXN-2025-0153', 14, 1, 55000.00, 'Salary deposit', '2025-05-05 09:00:00'),
('TXN-2025-0154', 14, 4, -15000.00, 'Insurance premium', '2025-06-10 10:30:00'),
('TXN-2025-0155', 14, 1, 55000.00, 'Salary deposit', '2025-07-05 09:00:00'),
('TXN-2025-0156', 14, 1, 110000.00, '13th month + salary', '2025-12-05 09:00:00'),
('TXN-2026-0028', 14, 1, 145000.00, 'Quarterly revenue deposit', '2026-03-05 14:00:00'),

-- ============================================
-- AC-115 (account_id=15) Miguel Rivera - Savings
-- ============================================
('TXN-2025-0157', 15, 1, 150000.00, 'Investment return deposit', '2025-01-08 09:45:00'),
('TXN-2025-0158', 15, 2, -45000.00, 'Investment purchase withdrawal', '2025-02-20 14:30:00'),
('TXN-2025-0159', 15, 1, 120000.00, 'Dividend income', '2025-04-10 09:00:00'),
('TXN-2025-0160', 15, 3, -30000.00, 'Transfer to checking', '2025-05-15 10:00:00'),
('TXN-2025-0161', 15, 1, 95000.00, 'Rental income', '2025-07-05 09:00:00'),
('TXN-2025-0162', 15, 2, -35000.00, 'Property maintenance', '2025-08-22 14:00:00'),
('TXN-2025-0163', 15, 1, 130000.00, 'Q4 investment returns', '2025-10-08 09:30:00'),
('TXN-2025-0164', 15, 1, 85000.00, 'Year-end bonus', '2025-12-10 09:00:00'),

-- ============================================
-- AC-116 (account_id=16) Miguel Rivera - Checking
-- ============================================
('TXN-2025-0165', 16, 1, 40000.00, 'Monthly deposit', '2025-01-10 09:00:00'),
('TXN-2025-0166', 16, 4, -25000.00, 'Supplier payment', '2025-02-12 13:00:00'),
('TXN-2025-0167', 16, 1, 30000.00, 'Transfer from savings', '2025-05-15 10:00:00'),
('TXN-2025-0168', 16, 4, -18000.00, 'Tax payment', '2025-07-18 10:00:00'),
('TXN-2025-0169', 16, 1, 35000.00, 'Rental income deposit', '2025-09-05 09:00:00'),
('TXN-2025-0170', 16, 2, -12000.00, 'Cash withdrawal', '2025-11-08 14:00:00'),
('TXN-2025-0171', 16, 4, -50000.00, 'Year-end supplier payment', '2025-12-08 11:30:00'),

-- ============================================
-- AC-117 (account_id=17) Sofia Mendoza - Savings
-- ============================================
('TXN-2025-0172', 17, 1, 28000.00, 'Refund deposit', '2025-01-14 10:30:00'),
('TXN-2025-0173', 17, 2, -10000.00, 'Cash withdrawal', '2025-02-25 15:00:00'),
('TXN-2025-0174', 17, 1, 35000.00, 'Salary deposit', '2025-04-05 09:00:00'),
('TXN-2025-0175', 17, 4, -8000.00, 'Phone bill payment', '2025-05-10 10:30:00'),
('TXN-2025-0176', 17, 1, 35000.00, 'Salary deposit', '2025-06-05 09:00:00'),
('TXN-2025-0177', 17, 2, -12000.00, 'Birthday expenses', '2025-08-15 14:00:00'),
('TXN-2025-0178', 17, 1, 35000.00, 'Salary deposit', '2025-10-05 09:00:00'),
('TXN-2026-0029', 17, 2, -15000.00, 'Valentines withdrawal', '2026-02-14 11:00:00'),

-- ============================================
-- AC-118 (account_id=18) Sofia Mendoza - Business
-- ============================================
('TXN-2025-0179', 18, 1, 150000.00, 'Business revenue Q1', '2025-01-20 09:00:00'),
('TXN-2025-0180', 18, 4, -60000.00, 'Inventory purchase', '2025-02-15 14:00:00'),
('TXN-2025-0181', 18, 1, 180000.00, 'Q2 revenue', '2025-04-10 09:00:00'),
('TXN-2025-0182', 18, 3, -40000.00, 'Transfer to savings', '2025-05-20 10:30:00'),
('TXN-2025-0183', 18, 1, 165000.00, 'Q3 revenue', '2025-07-12 09:00:00'),
('TXN-2025-0184', 18, 4, -75000.00, 'Operating costs', '2025-08-25 14:00:00'),
('TXN-2025-0185', 18, 1, 200000.00, 'Q4 revenue', '2025-10-08 09:00:00'),
('TXN-2025-0186', 18, 4, -85000.00, 'Year-end expenses', '2025-12-15 14:00:00'),
('TXN-2026-0030', 18, 3, -60000.00, 'Large transfer Q1 2026', '2026-01-18 10:30:00'),

-- ============================================
-- AC-119 (account_id=19) Antonio Hernandez - Savings
-- ============================================
('TXN-2025-0187', 19, 1, 65000.00, 'Salary deposit', '2025-01-05 09:00:00'),
('TXN-2025-0188', 19, 2, -22000.00, 'Home repair expenses', '2025-03-12 14:00:00'),
('TXN-2025-0189', 19, 1, 65000.00, 'Salary deposit', '2025-04-05 09:00:00'),
('TXN-2025-0190', 19, 4, -9500.00, 'Car insurance payment', '2025-05-20 10:30:00'),
('TXN-2025-0191', 19, 1, 65000.00, 'Salary deposit', '2025-06-05 09:00:00'),
('TXN-2025-0192', 19, 2, -18000.00, 'Vacation withdrawal', '2025-08-10 14:00:00'),
('TXN-2025-0193', 19, 1, 130000.00, '13th month + salary', '2025-12-05 09:00:00'),
('TXN-2025-0194', 19, 2, -35000.00, 'Holiday expenses', '2025-12-22 10:00:00'),
('TXN-2026-0031', 19, 3, -55000.00, 'Transfer to investment account', '2026-03-06 11:15:00'),

-- ============================================
-- AC-120 (account_id=20) Carmen Lopez - Checking
-- ============================================
('TXN-2025-0195', 20, 1, 22000.00, 'Monthly deposit', '2025-01-10 09:00:00'),
('TXN-2025-0196', 20, 4, -8500.00, 'Grocery and bills', '2025-02-15 10:00:00'),
('TXN-2025-0197', 20, 1, 22000.00, 'Monthly deposit', '2025-03-10 09:00:00'),
('TXN-2025-0198', 20, 2, -12000.00, 'Cash withdrawal', '2025-04-22 14:00:00'),
('TXN-2025-0199', 20, 1, 22000.00, 'Monthly deposit', '2025-05-10 09:00:00'),
('TXN-2025-0200', 20, 4, -9000.00, 'Utility payments', '2025-07-12 10:30:00'),
('TXN-2025-0201', 20, 1, 22000.00, 'Monthly deposit', '2025-09-10 09:00:00'),
('TXN-2025-0202', 20, 2, -7000.00, 'ATM withdrawal', '2025-11-05 14:00:00'),
('TXN-2025-0203', 20, 1, 95000.00, 'Year-end commission', '2025-12-10 09:00:00'),

-- ============================================
-- AC-121 (account_id=21) Carmen Lopez - Savings
-- ============================================
('TXN-2025-0204', 21, 1, 95000.00, 'Contract payment received', '2025-01-08 10:15:00'),
('TXN-2025-0205', 21, 2, -18000.00, 'Rent deposit payment', '2025-02-10 14:00:00'),
('TXN-2025-0206', 21, 1, 45000.00, 'Bonus deposit', '2025-04-05 09:00:00'),
('TXN-2025-0207', 21, 3, -25000.00, 'Transfer to checking', '2025-06-12 10:00:00'),
('TXN-2025-0208', 21, 1, 55000.00, 'Side income', '2025-08-08 09:00:00'),
('TXN-2025-0209', 21, 2, -20000.00, 'School fees withdrawal', '2025-10-15 14:00:00'),
('TXN-2025-0210', 21, 1, 70000.00, 'Year-end bonus', '2025-12-08 09:00:00'),

-- ============================================
-- AC-122 (account_id=22) Roberto Martinez - Business
-- ============================================
('TXN-2025-0211', 22, 1, 450000.00, 'Large business deposit Q1', '2025-01-12 09:00:00'),
('TXN-2025-0212', 22, 4, -180000.00, 'Payroll and suppliers', '2025-02-01 18:00:00'),
('TXN-2025-0213', 22, 1, 380000.00, 'Q2 revenue', '2025-04-08 09:00:00'),
('TXN-2025-0214', 22, 4, -165000.00, 'Operating expenses', '2025-05-02 14:00:00'),
('TXN-2025-0215', 22, 1, 420000.00, 'Q3 revenue', '2025-07-10 09:00:00'),
('TXN-2025-0216', 22, 4, -195000.00, 'Equipment and expansion', '2025-08-15 14:00:00'),
('TXN-2025-0217', 22, 1, 500000.00, 'Q4 revenue', '2025-10-05 09:00:00'),
('TXN-2025-0218', 22, 4, -210000.00, 'Year-end expenses', '2025-12-20 14:00:00'),
('TXN-2026-0032', 22, 1, 82000.00, 'Sales deposit Q1 2026', '2026-01-15 09:45:00'),
('TXN-2026-0033', 22, 3, -40000.00, 'Transfer to business account', '2026-01-22 10:00:00'),

-- ============================================
-- AC-123 (account_id=23) Teresa Gonzales - Savings
-- ============================================
('TXN-2025-0219', 23, 1, 48000.00, 'Salary deposit', '2025-01-05 09:00:00'),
('TXN-2025-0220', 23, 2, -15000.00, 'Personal withdrawal', '2025-02-18 14:00:00'),
('TXN-2025-0221', 23, 1, 48000.00, 'Salary deposit', '2025-03-05 09:00:00'),
('TXN-2025-0222', 23, 4, -7500.00, 'Health plan payment', '2025-04-12 10:00:00'),
('TXN-2025-0223', 23, 1, 48000.00, 'Salary deposit', '2025-05-05 09:00:00'),
('TXN-2025-0224', 23, 2, -20000.00, 'Vacation fund withdrawal', '2025-07-08 14:00:00'),
('TXN-2025-0225', 23, 1, 48000.00, 'Salary deposit', '2025-09-05 09:00:00'),
('TXN-2025-0226', 23, 1, 96000.00, '13th month + salary', '2025-12-05 09:00:00'),

-- ============================================
-- AC-124 (account_id=24) Teresa Gonzales - Checking
-- ============================================
('TXN-2025-0227', 24, 1, 20000.00, 'Monthly allowance', '2025-01-08 09:00:00'),
('TXN-2025-0228', 24, 4, -6000.00, 'Internet bill', '2025-02-10 10:00:00'),
('TXN-2025-0229', 24, 1, 20000.00, 'Monthly allowance', '2025-03-08 09:00:00'),
('TXN-2025-0230', 24, 2, -8000.00, 'Cash withdrawal', '2025-05-15 14:00:00'),
('TXN-2025-0231', 24, 1, 20000.00, 'Monthly allowance', '2025-07-08 09:00:00'),
('TXN-2025-0232', 24, 4, -5500.00, 'Phone bill', '2025-09-10 10:00:00'),
('TXN-2026-0034', 24, 1, 230000.00, 'Large business deposit Q1 2026', '2026-03-07 09:30:00'),

-- ============================================
-- AC-125 (account_id=25) Fernando Bautista - Savings
-- ============================================
('TXN-2025-0233', 25, 1, 72000.00, 'Salary deposit', '2025-01-05 09:00:00'),
('TXN-2025-0234', 25, 4, -8500.00, 'Utility bill payment', '2025-02-12 13:45:00'),
('TXN-2025-0235', 25, 1, 72000.00, 'Salary deposit', '2025-03-05 09:00:00'),
('TXN-2025-0236', 25, 2, -25000.00, 'Car repair expenses', '2025-04-20 14:00:00'),
('TXN-2025-0237', 25, 1, 72000.00, 'Salary deposit', '2025-05-05 09:00:00'),
('TXN-2025-0238', 25, 4, -15000.00, 'Insurance premium', '2025-06-15 10:30:00'),
('TXN-2025-0239', 25, 1, 72000.00, 'Salary deposit', '2025-08-05 09:00:00'),
('TXN-2025-0240', 25, 4, -13500.00, 'Internet and phone bill', '2025-11-01 09:00:00'),
('TXN-2025-0241', 25, 1, 144000.00, '13th month + salary', '2025-12-05 09:00:00'),

-- ============================================
-- AC-126 (account_id=26) Isabel Villanueva - Business
-- ============================================
('TXN-2025-0242', 26, 1, 280000.00, 'Consulting revenue Q1', '2025-01-15 09:00:00'),
('TXN-2025-0243', 26, 4, -95000.00, 'Office rent and staff', '2025-02-01 14:00:00'),
('TXN-2025-0244', 26, 1, 310000.00, 'Q2 consulting revenue', '2025-04-12 09:00:00'),
('TXN-2025-0245', 26, 4, -120000.00, 'Project expenses', '2025-05-20 14:00:00'),
('TXN-2025-0246', 26, 1, 260000.00, 'Q3 revenue', '2025-07-08 09:00:00'),
('TXN-2025-0247', 26, 4, -88000.00, 'Marketing campaign', '2025-08-15 14:00:00'),
('TXN-2025-0248', 26, 1, 340000.00, 'Q4 revenue', '2025-10-10 09:00:00'),
('TXN-2025-0249', 26, 4, -145000.00, 'Year-end bonuses', '2025-12-22 14:00:00'),
('TXN-2026-0035', 26, 1, 128000.00, 'Business revenue Feb 2026', '2026-02-18 09:45:00'),

-- ============================================
-- AC-127 (account_id=27) Isabel Villanueva - Savings
-- ============================================
('TXN-2025-0250', 27, 1, 40000.00, 'Personal savings deposit', '2025-01-10 09:00:00'),
('TXN-2025-0251', 27, 2, -22000.00, 'Cash withdrawal', '2025-03-16 16:15:00'),
('TXN-2025-0252', 27, 1, 45000.00, 'Bonus deposit', '2025-05-08 09:00:00'),
('TXN-2025-0253', 27, 2, -15000.00, 'Personal expense', '2025-07-20 14:00:00'),
('TXN-2025-0254', 27, 1, 50000.00, 'Year-end savings', '2025-12-10 09:00:00'),

-- ============================================
-- AC-128 (account_id=28) Ricardo Aquino - Checking
-- ============================================
('TXN-2025-0255', 28, 1, 38000.00, 'Insurance claim deposit', '2025-01-18 09:45:00'),
('TXN-2025-0256', 28, 4, -12000.00, 'Rent payment', '2025-02-10 10:00:00'),
('TXN-2025-0257', 28, 1, 32000.00, 'Monthly deposit', '2025-04-10 09:00:00'),
('TXN-2025-0258', 28, 2, -9000.00, 'ATM withdrawal', '2025-06-15 14:00:00'),
('TXN-2025-0259', 28, 1, 28000.00, 'Monthly deposit', '2025-08-10 09:00:00'),
('TXN-2025-0260', 28, 4, -7500.00, 'Utility bills', '2025-10-12 10:30:00'),
('TXN-2025-0261', 28, 1, 47000.00, 'Pension deposit', '2025-11-04 10:30:00'),

-- ============================================
-- AC-129 (account_id=29) Lucia Castillo - Savings
-- ============================================
('TXN-2025-0262', 29, 1, 90000.00, 'Salary deposit', '2025-01-05 09:00:00'),
('TXN-2025-0263', 29, 2, -30000.00, 'Down payment', '2025-03-10 14:00:00'),
('TXN-2025-0264', 29, 1, 90000.00, 'Salary deposit', '2025-04-05 09:00:00'),
('TXN-2025-0265', 29, 4, -18000.00, 'Car loan payment', '2025-05-15 10:00:00'),
('TXN-2025-0266', 29, 1, 90000.00, 'Salary deposit', '2025-06-05 09:00:00'),
('TXN-2025-0267', 29, 5, -750.00, 'Service charge', '2025-06-30 23:59:00'),
('TXN-2025-0268', 29, 1, 90000.00, 'Salary deposit', '2025-08-05 09:00:00'),
('TXN-2025-0269', 29, 1, 180000.00, '13th month + salary', '2025-12-05 09:00:00'),

-- ============================================
-- AC-130 (account_id=30) Lucia Castillo - Business
-- ============================================
('TXN-2025-0270', 30, 1, 220000.00, 'Business revenue Q1', '2025-01-20 09:00:00'),
('TXN-2025-0271', 30, 4, -85000.00, 'Supplier costs', '2025-02-15 14:00:00'),
('TXN-2025-0272', 30, 1, 195000.00, 'Q2 revenue', '2025-04-18 09:00:00'),
('TXN-2025-0273', 30, 4, -78000.00, 'Office expenses', '2025-06-01 14:00:00'),
('TXN-2025-0274', 30, 1, 250000.00, 'Q3 revenue', '2025-07-15 09:00:00'),
('TXN-2025-0275', 30, 4, -92000.00, 'Payroll', '2025-09-01 18:00:00'),
('TXN-2025-0276', 30, 1, 280000.00, 'Q4 revenue', '2025-10-12 09:00:00'),
('TXN-2025-0277', 30, 2, -19000.00, 'Home repair withdrawal', '2025-11-06 14:00:00'),
('TXN-2026-0036', 30, 4, -7500.00, 'Insurance payment Q1 2026', '2026-03-07 13:00:00'),

-- ============================================
-- AC-131 (account_id=31) Manuel Pascual - Savings
-- ============================================
('TXN-2025-0278', 31, 1, 55000.00, 'Monthly savings deposit', '2025-01-05 09:00:00'),
('TXN-2025-0279', 31, 2, -18000.00, 'Home improvement', '2025-03-15 14:00:00'),
('TXN-2025-0280', 31, 1, 55000.00, 'Salary deposit', '2025-05-05 09:00:00'),
('TXN-2025-0281', 31, 4, -12000.00, 'Insurance payment', '2025-07-10 10:00:00'),
('TXN-2025-0282', 31, 1, 110000.00, '13th month + salary', '2025-12-05 09:00:00'),
('TXN-2025-0283', 31, 2, -25000.00, 'Holiday expenses', '2025-12-20 14:00:00'),

-- ============================================
-- AC-132 (account_id=32) Gloria Fernandez - Checking
-- ============================================
('TXN-2025-0284', 32, 1, 42000.00, 'Payroll deposit', '2025-02-01 09:00:00'),
('TXN-2025-0285', 32, 2, -15000.00, 'Personal expenses', '2025-03-18 14:00:00'),
('TXN-2025-0286', 32, 1, 42000.00, 'Payroll deposit', '2025-04-01 09:00:00'),
('TXN-2025-0287', 32, 4, -8500.00, 'Utility bills', '2025-05-15 10:00:00'),
('TXN-2025-0288', 32, 1, 42000.00, 'Payroll deposit', '2025-06-01 09:00:00'),
('TXN-2025-0289', 32, 2, -20000.00, 'Vacation withdrawal', '2025-08-05 14:00:00'),

-- ============================================
-- AC-133 (account_id=33) Gloria Fernandez - Savings
-- ============================================
('TXN-2025-0290', 33, 1, 60000.00, 'Savings deposit', '2025-01-10 09:00:00'),
('TXN-2025-0291', 33, 3, -15000.00, 'Transfer to checking', '2025-03-10 10:00:00'),
('TXN-2025-0292', 33, 1, 50000.00, 'Bonus deposit', '2025-06-05 09:00:00'),
('TXN-2025-0293', 33, 2, -22000.00, 'Medical expenses', '2025-09-12 14:00:00'),
('TXN-2025-0294', 33, 1, 75000.00, 'Year-end bonus', '2025-12-08 09:00:00'),

-- ============================================
-- AC-134 (account_id=34) Andres De Leon - Business
-- ============================================
('TXN-2025-0295', 34, 1, 180000.00, 'Client payment deposit', '2025-01-12 09:30:00'),
('TXN-2025-0296', 34, 4, -65000.00, 'Operating costs', '2025-02-20 14:00:00'),
('TXN-2025-0297', 34, 1, 200000.00, 'Project milestone payment', '2025-04-08 09:00:00'),
('TXN-2025-0298', 34, 4, -78000.00, 'Staff salaries', '2025-06-01 18:00:00'),
('TXN-2025-0299', 34, 1, 160000.00, 'Year-end bonus deposit', '2025-11-08 11:00:00'),
('TXN-2025-0300', 34, 4, -95000.00, 'Year-end expenses', '2025-12-18 14:00:00'),

-- ============================================
-- AC-135 (account_id=35) Patricia Morales - Savings
-- ============================================
('TXN-2025-0301', 35, 1, 35000.00, 'Monthly deposit', '2025-01-05 09:00:00'),
('TXN-2025-0302', 35, 2, -12000.00, 'ATM withdrawal', '2025-02-22 14:00:00'),
('TXN-2025-0303', 35, 1, 35000.00, 'Salary deposit', '2025-04-05 09:00:00'),
('TXN-2025-0304', 35, 4, -10000.00, 'Car loan payment', '2025-06-12 10:00:00'),
('TXN-2025-0305', 35, 1, 70000.00, '13th month + salary', '2025-12-05 09:00:00'),
('TXN-2026-0037', 35, 1, 58000.00, 'Freelance deposit Mar 2026', '2026-03-08 10:00:00'),

-- ============================================
-- AC-136 (account_id=36) Patricia Morales - Checking
-- ============================================
('TXN-2025-0306', 36, 1, 28000.00, 'Bonus deposit', '2025-02-14 10:45:00'),
('TXN-2025-0307', 36, 4, -9000.00, 'Rent payment', '2025-03-10 10:00:00'),
('TXN-2025-0308', 36, 1, 25000.00, 'Monthly deposit', '2025-05-10 09:00:00'),
('TXN-2025-0309', 36, 2, -8000.00, 'Personal withdrawal', '2025-07-18 14:00:00'),
('TXN-2025-0310', 36, 1, 33000.00, 'Side income', '2025-10-05 09:00:00'),

-- ============================================
-- AC-137 (account_id=37) Enrique Castro - Savings
-- ============================================
('TXN-2025-0311', 37, 1, 85000.00, 'Salary deposit', '2025-01-05 09:00:00'),
('TXN-2025-0312', 37, 2, -28000.00, 'Appliance purchase', '2025-03-20 14:00:00'),
('TXN-2025-0313', 37, 1, 85000.00, 'Salary deposit', '2025-04-05 09:00:00'),
('TXN-2025-0314', 37, 4, -15000.00, 'Insurance premium', '2025-06-15 10:30:00'),
('TXN-2025-0315', 37, 1, 85000.00, 'Salary deposit', '2025-07-05 09:00:00'),
('TXN-2025-0316', 37, 2, -18000.00, 'Travel expenses', '2025-09-18 14:00:00'),
('TXN-2025-0317', 37, 1, 170000.00, '13th month + salary', '2025-12-05 09:00:00'),

-- ============================================
-- AC-138 (account_id=38) Beatriz Soriano - Business
-- ============================================
('TXN-2025-0318', 38, 1, 320000.00, 'Large business deposit Q1', '2025-01-18 09:00:00'),
('TXN-2025-0319', 38, 4, -135000.00, 'Supplier and payroll', '2025-02-28 14:00:00'),
('TXN-2025-0320', 38, 1, 290000.00, 'Q2 revenue', '2025-04-15 09:00:00'),
('TXN-2025-0321', 38, 3, -75000.00, 'Investment transfer', '2025-06-10 10:00:00'),
('TXN-2025-0322', 38, 1, 350000.00, 'Q3 revenue', '2025-07-20 09:00:00'),
('TXN-2025-0323', 38, 4, -160000.00, 'Operating expenses', '2025-09-05 14:00:00'),
('TXN-2025-0324', 38, 1, 280000.00, 'Q4 revenue', '2025-12-05 09:00:00'),
('TXN-2026-0038', 38, 3, -75000.00, 'Investment transfer Q1 2026', '2026-02-10 09:30:00'),

-- ============================================
-- AC-139 (account_id=39) Beatriz Soriano - Savings
-- ============================================
('TXN-2025-0325', 39, 1, 45000.00, 'Personal deposit', '2025-01-12 09:00:00'),
('TXN-2025-0326', 39, 2, -15000.00, 'Cash withdrawal', '2025-04-08 14:00:00'),
('TXN-2025-0327', 39, 1, 55000.00, 'Bonus deposit', '2025-07-05 09:00:00'),
('TXN-2025-0328', 39, 2, -20000.00, 'Shopping withdrawal', '2025-10-18 14:00:00'),
('TXN-2025-0329', 39, 5, -500.00, 'Monthly fee', '2025-12-31 23:59:00'),

-- ============================================
-- AC-140 (account_id=40) Ramon Tan - Checking
-- ============================================
('TXN-2025-0330', 40, 1, 48000.00, 'Salary deposit', '2025-01-05 09:15:00'),
('TXN-2025-0331', 40, 4, -12500.00, 'Rent payment', '2025-02-10 10:00:00'),
('TXN-2025-0332', 40, 1, 48000.00, 'Salary deposit', '2025-03-05 09:00:00'),
('TXN-2025-0333', 40, 2, -9500.00, 'ATM withdrawal', '2025-04-16 16:30:00'),
('TXN-2025-0334', 40, 1, 48000.00, 'Salary deposit', '2025-06-05 09:00:00'),
('TXN-2025-0335', 40, 4, -7800.00, 'Utility bills', '2025-08-12 10:00:00'),
('TXN-2026-0039', 40, 2, -20000.00, 'Cash withdrawal Mar 2026', '2026-03-08 16:00:00'),

-- ============================================
-- AC-141 (account_id=41) Cristina Lim - Savings
-- ============================================
('TXN-2025-0336', 41, 1, 75000.00, 'Rental income deposit', '2025-01-08 10:00:00'),
('TXN-2025-0337', 41, 2, -20000.00, 'Property tax payment', '2025-03-15 14:00:00'),
('TXN-2025-0338', 41, 1, 75000.00, 'Rental income', '2025-05-08 09:00:00'),
('TXN-2025-0339', 41, 4, -18000.00, 'Maintenance expenses', '2025-07-20 10:00:00'),
('TXN-2025-0340', 41, 1, 75000.00, 'Rental income', '2025-09-08 09:00:00'),
('TXN-2025-0341', 41, 1, 75000.00, 'Rental income', '2025-11-08 09:00:00'),

-- ============================================
-- AC-142 (account_id=42) Cristina Lim - Business
-- ============================================
('TXN-2025-0342', 42, 1, 195000.00, 'E-commerce revenue Q1', '2025-01-20 09:00:00'),
('TXN-2025-0343', 42, 4, -82000.00, 'Inventory purchase', '2025-02-15 14:00:00'),
('TXN-2025-0344', 42, 1, 225000.00, 'Q2 sales revenue', '2025-04-20 09:00:00'),
('TXN-2025-0345', 42, 4, -98000.00, 'Shipping and logistics', '2025-06-18 14:00:00'),
('TXN-2025-0346', 42, 1, 260000.00, 'Q3 revenue', '2025-08-10 09:00:00'),
('TXN-2025-0347', 42, 4, -115000.00, 'Year-end inventory', '2025-11-25 14:00:00'),

-- ============================================
-- AC-143 (account_id=43) Eduardo Go - Savings
-- ============================================
('TXN-2025-0348', 43, 1, 55000.00, 'Salary deposit', '2025-01-05 09:00:00'),
('TXN-2025-0349', 43, 3, -50000.00, 'Transfer to investment', '2025-03-07 11:30:00'),
('TXN-2025-0350', 43, 1, 55000.00, 'Salary deposit', '2025-05-05 09:00:00'),
('TXN-2025-0351', 43, 2, -12000.00, 'Personal withdrawal', '2025-07-15 14:00:00'),
('TXN-2025-0352', 43, 1, 55000.00, 'Salary deposit', '2025-09-05 09:00:00'),
('TXN-2025-0353', 43, 1, 110000.00, '13th month + salary', '2025-12-05 09:00:00'),

-- ============================================
-- AC-144 (account_id=44) Margarita Sy - Checking
-- ============================================
('TXN-2025-0354', 44, 1, 32000.00, 'Monthly deposit', '2025-01-10 09:00:00'),
('TXN-2025-0355', 44, 4, -9500.00, 'Bills payment', '2025-02-15 10:00:00'),
('TXN-2025-0356', 44, 1, 32000.00, 'Monthly deposit', '2025-04-10 09:00:00'),
('TXN-2025-0357', 44, 2, -14000.00, 'Travel expenses', '2025-06-22 14:00:00'),
('TXN-2025-0358', 44, 1, 32000.00, 'Monthly deposit', '2025-08-10 09:00:00'),
('TXN-2025-0359', 44, 4, -8000.00, 'Subscription payments', '2025-10-15 10:00:00'),

-- ============================================
-- AC-145 (account_id=45) Margarita Sy - Savings
-- ============================================
('TXN-2025-0360', 45, 1, 65000.00, 'Investment returns', '2025-02-08 09:00:00'),
('TXN-2025-0361', 45, 4, -15000.00, 'Insurance premium', '2025-04-15 10:30:00'),
('TXN-2025-0362', 45, 1, 72000.00, 'Dividend income', '2025-06-10 09:00:00'),
('TXN-2025-0363', 45, 2, -25000.00, 'Emergency fund withdrawal', '2025-08-25 14:00:00'),
('TXN-2025-0364', 45, 1, 58000.00, 'Year-end returns', '2025-12-12 09:00:00'),

-- ============================================
-- AC-146 (account_id=46) Alejandro Chua - Business
-- ============================================
('TXN-2025-0365', 46, 1, 410000.00, 'Import business revenue Q1', '2025-01-18 09:00:00'),
('TXN-2025-0366', 46, 4, -175000.00, 'Import duties and shipping', '2025-02-20 14:00:00'),
('TXN-2025-0367', 46, 1, 380000.00, 'Q2 sales', '2025-04-22 09:00:00'),
('TXN-2025-0368', 46, 4, -155000.00, 'Warehouse and logistics', '2025-06-15 14:00:00'),
('TXN-2025-0369', 46, 1, 450000.00, 'Q3 peak season sales', '2025-08-18 09:00:00'),
('TXN-2025-0370', 46, 4, -190000.00, 'Supplier payments', '2025-10-05 14:00:00'),
('TXN-2025-0371', 46, 1, 520000.00, 'Q4 holiday sales', '2025-11-20 09:00:00'),
('TXN-2025-0372', 46, 4, -220000.00, 'Year-end settlements', '2025-12-28 14:00:00'),
('TXN-2026-0040', 46, 1, 175000.00, 'Sales revenue Mar 2026', '2026-03-08 09:00:00'),

-- ============================================
-- AC-147 (account_id=47) Victoria Ong - Savings
-- ============================================
('TXN-2025-0373', 47, 1, 42000.00, 'Monthly deposit', '2025-01-08 09:00:00'),
('TXN-2025-0374', 47, 2, -18000.00, 'Dental procedure', '2025-03-12 14:00:00'),
('TXN-2025-0375', 47, 1, 42000.00, 'Salary deposit', '2025-05-08 09:00:00'),
('TXN-2025-0376', 47, 4, -10000.00, 'Car loan payment', '2025-07-15 10:00:00'),
('TXN-2025-0377', 47, 1, 42000.00, 'Salary deposit', '2025-09-08 09:00:00'),
('TXN-2025-0378', 47, 1, 84000.00, '13th month + salary', '2025-12-08 09:00:00'),

-- ============================================
-- AC-148 (account_id=48) Victoria Ong - Checking
-- ============================================
('TXN-2025-0379', 48, 1, 20000.00, 'Monthly deposit', '2025-01-12 09:00:00'),
('TXN-2025-0380', 48, 2, -7000.00, 'Personal withdrawal', '2025-02-18 16:00:00'),
('TXN-2025-0381', 48, 1, 20000.00, 'Monthly deposit', '2025-04-12 09:00:00'),
('TXN-2025-0382', 48, 4, -6500.00, 'Internet and cable', '2025-06-15 10:00:00'),
('TXN-2025-0383', 48, 1, 20000.00, 'Monthly deposit', '2025-08-12 09:00:00'),
('TXN-2025-0384', 48, 2, -9000.00, 'Cash withdrawal', '2025-10-20 14:00:00'),

-- ============================================
-- AC-149 (account_id=49) Francisco Yap - Savings
-- ============================================
('TXN-2025-0385', 49, 1, 120000.00, 'Business profit deposit Q1', '2025-01-20 09:00:00'),
('TXN-2025-0386', 49, 2, -35000.00, 'Tuition fees', '2025-03-05 14:00:00'),
('TXN-2025-0387', 49, 1, 95000.00, 'Q2 profit deposit', '2025-04-20 09:00:00'),
('TXN-2025-0388', 49, 3, -40000.00, 'Transfer to spouse account', '2025-06-12 10:00:00'),
('TXN-2025-0389', 49, 1, 110000.00, 'Q3 profit deposit', '2025-07-22 09:00:00'),
('TXN-2025-0390', 49, 4, -22000.00, 'Property tax payment', '2025-09-10 10:30:00'),
('TXN-2025-0391', 49, 1, 135000.00, 'Year-end profit deposit', '2025-12-15 09:00:00'),

-- ============================================
-- AC-150 (account_id=50) Dolores Co - Business
-- ============================================
('TXN-2025-0392', 50, 1, 250000.00, 'Restaurant revenue Q1', '2025-01-22 09:00:00'),
('TXN-2025-0393', 50, 4, -105000.00, 'Food supplies and rent', '2025-02-18 14:00:00'),
('TXN-2025-0394', 50, 1, 280000.00, 'Q2 revenue', '2025-04-25 09:00:00'),
('TXN-2025-0395', 50, 4, -115000.00, 'Staff wages and utilities', '2025-06-01 18:00:00'),
('TXN-2025-0396', 50, 1, 310000.00, 'Q3 summer revenue', '2025-07-28 09:00:00'),
('TXN-2025-0397', 50, 4, -125000.00, 'Operating costs', '2025-09-15 14:00:00'),
('TXN-2025-0398', 50, 1, 350000.00, 'Q4 holiday season revenue', '2025-11-25 09:00:00'),
('TXN-2025-0399', 50, 4, -140000.00, 'Year-end expenses', '2025-12-28 14:00:00'),
('TXN-2025-0400', 50, 5, -500.00, 'Monthly maintenance fee', '2026-03-08 23:59:00'),

-- ============================================
-- AC-151 (account_id=51) Gregorio Yu - Savings
-- ============================================
('TXN-2025-0401', 51, 1, 48000.00, 'Monthly salary', '2025-01-05 09:00:00'),
('TXN-2025-0402', 51, 2, -15000.00, 'Medical checkup', '2025-03-08 14:00:00'),
('TXN-2025-0403', 51, 1, 48000.00, 'Salary deposit', '2025-05-05 09:00:00'),
('TXN-2025-0404', 51, 4, -8500.00, 'Phone and internet', '2025-07-10 10:30:00'),
('TXN-2025-0405', 51, 1, 135000.00, 'Contract milestone Q2', '2025-06-03 10:30:00'),
('TXN-2025-0406', 51, 1, 96000.00, '13th month + salary', '2025-12-05 09:00:00'),

-- ============================================
-- AC-152 (account_id=52) Gregorio Yu - Checking
-- ============================================
('TXN-2025-0407', 52, 1, 25000.00, 'Monthly deposit', '2025-02-05 09:00:00'),
('TXN-2025-0408', 52, 2, -12000.00, 'Rent payment', '2025-03-10 10:00:00'),
('TXN-2025-0409', 52, 1, 25000.00, 'Monthly deposit', '2025-05-05 09:00:00'),
('TXN-2025-0410', 52, 4, -7500.00, 'Utilities', '2025-07-15 10:00:00'),
('TXN-2025-0411', 52, 2, -28000.00, 'Appliance purchase', '2025-06-05 14:00:00'),

-- ============================================
-- AC-153 (account_id=53) Esperanza Lee - Savings
-- ============================================
('TXN-2025-0412', 53, 1, 78000.00, 'Salary deposit', '2025-01-05 09:00:00'),
('TXN-2025-0413', 53, 3, -40000.00, 'Savings transfer', '2025-03-07 11:00:00'),
('TXN-2025-0414', 53, 1, 78000.00, 'Salary deposit', '2025-04-05 09:00:00'),
('TXN-2025-0415', 53, 2, -22000.00, 'Wedding gift', '2025-06-15 14:00:00'),
('TXN-2025-0416', 53, 1, 78000.00, 'Salary deposit', '2025-08-05 09:00:00'),
('TXN-2025-0417', 53, 1, 156000.00, '13th month + salary', '2025-12-05 09:00:00'),

-- ============================================
-- AC-154 (account_id=54) Joaquin Uy - Business
-- ============================================
('TXN-2025-0418', 54, 1, 165000.00, 'Vendor payment received Q1', '2025-01-15 09:15:00'),
('TXN-2025-0419', 54, 4, -68000.00, 'Supplier costs', '2025-02-22 14:00:00'),
('TXN-2025-0420', 54, 1, 185000.00, 'Q2 revenue', '2025-04-18 09:00:00'),
('TXN-2025-0421', 54, 4, -75000.00, 'Operating expenses', '2025-06-20 14:00:00'),
('TXN-2025-0422', 54, 1, 195000.00, 'Q3 revenue', '2025-08-15 09:00:00'),
('TXN-2025-0423', 54, 4, -82000.00, 'Marketing campaign', '2025-10-10 14:00:00'),
('TXN-2025-0424', 54, 1, 210000.00, 'Q4 revenue', '2025-12-10 09:00:00'),

-- ============================================
-- AC-155 (account_id=55) Joaquin Uy - Savings
-- ============================================
('TXN-2025-0425', 55, 1, 45000.00, 'Personal savings', '2025-01-10 09:00:00'),
('TXN-2025-0426', 55, 4, -18000.00, 'Loan amortization', '2025-03-11 13:45:00'),
('TXN-2025-0427', 55, 1, 50000.00, 'Dividend income', '2025-06-08 09:00:00'),
('TXN-2025-0428', 55, 2, -14000.00, 'Travel expenses', '2025-09-20 14:00:00'),
('TXN-2025-0429', 55, 1, 58000.00, 'Year-end deposit', '2025-12-12 09:00:00'),

-- ============================================
-- AC-156 (account_id=56) Rosario Ang - Checking
-- ============================================
('TXN-2025-0430', 56, 1, 33000.00, 'Side income deposit', '2025-02-14 10:15:00'),
('TXN-2025-0431', 56, 4, -9000.00, 'Gym membership and bills', '2025-04-10 10:00:00'),
('TXN-2025-0432', 56, 1, 30000.00, 'Monthly deposit', '2025-06-14 09:00:00'),
('TXN-2025-0433', 56, 2, -11000.00, 'Clothing purchase', '2025-08-22 14:00:00'),
('TXN-2025-0434', 56, 1, 35000.00, 'Freelance income', '2025-10-14 09:00:00'),

-- ============================================
-- AC-157 (account_id=57) Alfredo Wu - Savings
-- ============================================
('TXN-2025-0435', 57, 1, 95000.00, 'Salary deposit', '2025-01-05 09:00:00'),
('TXN-2025-0436', 57, 2, -14000.00, 'Travel expenses withdrawal', '2025-03-16 16:30:00'),
('TXN-2025-0437', 57, 1, 95000.00, 'Salary deposit', '2025-04-05 09:00:00'),
('TXN-2025-0438', 57, 4, -25000.00, 'Car maintenance', '2025-06-18 10:00:00'),
('TXN-2025-0439', 57, 1, 95000.00, 'Salary deposit', '2025-07-05 09:00:00'),
('TXN-2025-0440', 57, 2, -32000.00, 'Gadget purchase', '2025-09-12 14:00:00'),
('TXN-2025-0441', 57, 1, 190000.00, '13th month + salary', '2025-12-05 09:00:00'),

-- ============================================
-- AC-158 (account_id=58) Pilar Cheng - Business
-- ============================================
('TXN-2025-0442', 58, 1, 280000.00, 'Quarterly revenue Q1', '2025-01-20 09:00:00'),
('TXN-2025-0443', 58, 4, -115000.00, 'Raw materials purchase', '2025-02-25 14:00:00'),
('TXN-2025-0444', 58, 1, 310000.00, 'Q2 manufacturing revenue', '2025-04-22 09:00:00'),
('TXN-2025-0445', 58, 4, -130000.00, 'Equipment maintenance', '2025-06-28 14:00:00'),
('TXN-2025-0446', 58, 1, 340000.00, 'Q3 revenue', '2025-08-20 09:00:00'),
('TXN-2025-0447', 58, 4, -145000.00, 'Expansion costs', '2025-10-15 14:00:00'),
('TXN-2025-0448', 58, 1, 380000.00, 'Q4 revenue', '2025-12-18 09:00:00'),

-- ============================================
-- AC-159 (account_id=59) Pilar Cheng - Savings
-- ============================================
('TXN-2025-0449', 59, 1, 60000.00, 'Personal deposit', '2025-01-15 09:00:00'),
('TXN-2025-0450', 59, 2, -20000.00, 'Shopping expenses', '2025-04-10 14:00:00'),
('TXN-2025-0451', 59, 1, 70000.00, 'Profit distribution', '2025-07-12 09:00:00'),
('TXN-2025-0452', 59, 2, -18000.00, 'Personal withdrawal', '2025-10-05 14:00:00'),
('TXN-2025-0453', 59, 5, -500.00, 'Service charge', '2025-12-31 23:59:00'),

-- ============================================
-- AC-160 (account_id=60) Emilio Huang - Checking
-- ============================================
('TXN-2025-0454', 60, 1, 51000.00, 'Monthly deposit', '2025-01-08 09:00:00'),
('TXN-2025-0455', 60, 4, -15000.00, 'Rent and bills', '2025-02-10 10:00:00'),
('TXN-2025-0456', 60, 1, 51000.00, 'Salary deposit', '2025-03-08 09:00:00'),
('TXN-2025-0457', 60, 2, -16000.00, 'School fees withdrawal', '2025-05-06 14:30:00'),
('TXN-2025-0458', 60, 1, 51000.00, 'Salary deposit', '2025-07-08 09:00:00'),
('TXN-2025-0459', 60, 4, -13500.00, 'Internet and phone bill', '2025-09-10 10:00:00'),
('TXN-2025-0460', 60, 1, 51000.00, 'Salary deposit', '2025-11-08 09:00:00'),

-- ============================================
-- AC-161 (account_id=61) Consuelo Lin - Savings
-- ============================================
('TXN-2025-0461', 61, 1, 72000.00, 'Consulting fee deposit', '2025-01-15 10:30:00'),
('TXN-2025-0462', 61, 2, -25000.00, 'Medical procedure', '2025-03-22 14:00:00'),
('TXN-2025-0463', 61, 1, 72000.00, 'Consulting fee', '2025-05-15 09:00:00'),
('TXN-2025-0464', 61, 4, -12000.00, 'Health insurance', '2025-07-10 10:00:00'),
('TXN-2025-0465', 61, 1, 72000.00, 'Consulting fee', '2025-09-15 09:00:00'),
('TXN-2025-0466', 61, 1, 144000.00, '13th month + consulting', '2025-12-15 09:00:00'),

-- ============================================
-- AC-162 (account_id=62) Consuelo Lin - Business
-- ============================================
('TXN-2025-0467', 62, 1, 230000.00, 'Clinic revenue Q1', '2025-01-25 09:00:00'),
('TXN-2025-0468', 62, 4, -95000.00, 'Medical supplies', '2025-02-28 14:00:00'),
('TXN-2025-0469', 62, 1, 255000.00, 'Q2 clinic revenue', '2025-04-28 09:00:00'),
('TXN-2025-0470', 62, 4, -105000.00, 'Staff and utilities', '2025-06-30 18:00:00'),
('TXN-2025-0471', 62, 1, 240000.00, 'Q3 revenue', '2025-08-25 09:00:00'),
('TXN-2025-0472', 62, 4, -110000.00, 'Equipment upgrade', '2025-10-20 14:00:00'),

-- ============================================
-- AC-163 (account_id=63) Sergio Chen - Savings
-- ============================================
('TXN-2025-0473', 63, 1, 45000.00, 'Monthly deposit', '2025-01-08 09:00:00'),
('TXN-2025-0474', 63, 2, -12000.00, 'ATM withdrawal', '2025-03-15 14:00:00'),
('TXN-2025-0475', 63, 1, 45000.00, 'Salary deposit', '2025-05-08 09:00:00'),
('TXN-2025-0476', 63, 4, -8000.00, 'Insurance premium', '2025-07-15 10:00:00'),
('TXN-2025-0477', 63, 1, 45000.00, 'Salary deposit', '2025-09-08 09:00:00'),
('TXN-2025-0478', 63, 1, 90000.00, '13th month + salary', '2025-12-08 09:00:00'),

-- ============================================
-- AC-164 (account_id=64) Remedios Wang - Checking
-- ============================================
('TXN-2025-0479', 64, 1, 30000.00, 'Monthly deposit', '2025-01-10 09:00:00'),
('TXN-2025-0480', 64, 4, -9000.00, 'Monthly bills', '2025-02-15 10:00:00'),
('TXN-2025-0481', 64, 1, 30000.00, 'Monthly deposit', '2025-04-10 09:00:00'),
('TXN-2025-0482', 64, 2, -11000.00, 'Cash withdrawal', '2025-06-18 14:00:00'),
('TXN-2025-0483', 64, 1, 30000.00, 'Monthly deposit', '2025-08-10 09:00:00'),
('TXN-2025-0484', 64, 4, -8500.00, 'Subscription renewals', '2025-10-12 10:00:00'),

-- ============================================
-- AC-165 (account_id=65) Remedios Wang - Savings
-- ============================================
('TXN-2025-0485', 65, 1, 55000.00, 'Investment income', '2025-02-05 09:00:00'),
('TXN-2025-0486', 65, 4, -10000.00, 'Car loan payment', '2025-04-12 10:00:00'),
('TXN-2025-0487', 65, 1, 48000.00, 'Dividend payout', '2025-06-08 09:00:00'),
('TXN-2025-0488', 65, 2, -15000.00, 'Vacation fund', '2025-08-20 14:00:00'),
('TXN-2025-0489', 65, 1, 62000.00, 'Year-end returns', '2025-12-10 09:00:00'),

-- ============================================
-- AC-166 (account_id=66) Tomas Li - Business
-- ============================================
('TXN-2025-0490', 66, 1, 175000.00, 'Tech services revenue Q1', '2025-01-18 09:00:00'),
('TXN-2025-0491', 66, 4, -72000.00, 'Cloud hosting and tools', '2025-02-20 14:00:00'),
('TXN-2025-0492', 66, 1, 195000.00, 'Q2 services revenue', '2025-04-22 09:00:00'),
('TXN-2025-0493', 66, 4, -85000.00, 'Developer salaries', '2025-06-30 18:00:00'),
('TXN-2025-0494', 66, 1, 210000.00, 'Q3 project payments', '2025-08-18 09:00:00'),
('TXN-2025-0495', 66, 4, -78000.00, 'Office and equipment', '2025-10-15 14:00:00'),
('TXN-2025-0496', 66, 1, 230000.00, 'Q4 revenue', '2025-12-20 09:00:00'),

-- ============================================
-- AC-167 (account_id=67) Natividad Zhang - Savings
-- ============================================
('TXN-2025-0497', 67, 1, 38000.00, 'Monthly savings', '2025-01-05 09:00:00'),
('TXN-2025-0498', 67, 2, -11000.00, 'Cash withdrawal', '2025-03-17 16:00:00'),
('TXN-2025-0499', 67, 1, 38000.00, 'Salary deposit', '2025-05-05 09:00:00'),
('TXN-2025-0500', 67, 4, -7500.00, 'Phone bill', '2025-07-10 10:00:00'),
('TXN-2025-0501', 67, 1, 38000.00, 'Salary deposit', '2025-09-05 09:00:00'),
('TXN-2025-0502', 67, 1, 76000.00, '13th month + salary', '2025-12-05 09:00:00'),

-- ============================================
-- AC-168 (account_id=68) Natividad Zhang - Checking
-- ============================================
('TXN-2025-0503', 68, 1, 22000.00, 'Monthly deposit', '2025-01-12 09:00:00'),
('TXN-2025-0504', 68, 2, -8000.00, 'Rent contribution', '2025-02-15 10:00:00'),
('TXN-2025-0505', 68, 1, 22000.00, 'Monthly deposit', '2025-04-12 09:00:00'),
('TXN-2025-0506', 68, 4, -6500.00, 'Grocery expenses', '2025-06-18 10:00:00'),
('TXN-2025-0507', 68, 1, 22000.00, 'Monthly deposit', '2025-08-12 09:00:00'),
('TXN-2025-0508', 68, 2, -9000.00, 'Personal withdrawal', '2025-10-20 14:00:00'),

-- ============================================
-- AC-169 (account_id=69) Felipe Domingo - Savings
-- ============================================
('TXN-2025-0509', 69, 1, 98000.00, 'Investment income Q1', '2025-01-20 09:00:00'),
('TXN-2025-0510', 69, 2, -35000.00, 'Property tax', '2025-03-25 14:00:00'),
('TXN-2025-0511', 69, 1, 85000.00, 'Rental income Q2', '2025-05-20 09:00:00'),
('TXN-2025-0512', 69, 3, -30000.00, 'Transfer to investment', '2025-07-15 10:00:00'),
('TXN-2025-0513', 69, 1, 92000.00, 'Rental income Q3', '2025-09-20 09:00:00'),
('TXN-2025-0514', 69, 5, -750.00, 'Monthly fee', '2025-09-30 23:59:00'),
('TXN-2025-0515', 69, 1, 105000.00, 'Year-end rental + bonus', '2025-12-20 09:00:00'),

-- ============================================
-- AC-170 (account_id=70) Consolacion Santiago - Business
-- ============================================
('TXN-2025-0516', 70, 1, 290000.00, 'Catering business Q1', '2025-01-22 09:00:00'),
('TXN-2025-0517', 70, 4, -120000.00, 'Food supplies and staff', '2025-02-28 14:00:00'),
('TXN-2025-0518', 70, 1, 330000.00, 'Wedding season revenue Q2', '2025-04-25 09:00:00'),
('TXN-2025-0519', 70, 4, -140000.00, 'Operating costs', '2025-06-30 18:00:00'),
('TXN-2025-0520', 70, 1, 275000.00, 'Q3 revenue', '2025-08-22 09:00:00'),
('TXN-2025-0521', 70, 4, -115000.00, 'Equipment purchase', '2025-10-18 14:00:00'),
('TXN-2025-0522', 70, 1, 380000.00, 'Holiday catering Q4', '2025-12-22 09:00:00'),

-- ============================================
-- AC-171 (account_id=71) Consolacion Santiago - Savings
-- ============================================
('TXN-2025-0523', 71, 1, 55000.00, 'Personal savings', '2025-01-10 09:00:00'),
('TXN-2025-0524', 71, 2, -18000.00, 'Health checkup', '2025-04-08 14:00:00'),
('TXN-2025-0525', 71, 1, 55000.00, 'Bonus deposit', '2025-07-10 09:00:00'),
('TXN-2025-0526', 71, 2, -22000.00, 'Home renovation', '2025-10-15 14:00:00'),
('TXN-2025-0527', 71, 1, 80000.00, 'Year-end savings', '2025-12-12 09:00:00'),

-- ============================================
-- AC-172 (account_id=72) Gerardo Navarro - Checking
-- ============================================
('TXN-2025-0528', 72, 1, 35000.00, 'Monthly deposit', '2025-01-08 09:00:00'),
('TXN-2025-0529', 72, 4, -12000.00, 'Monthly bills', '2025-02-10 10:00:00'),
('TXN-2025-0530', 72, 1, 35000.00, 'Monthly deposit', '2025-03-08 09:00:00'),
('TXN-2025-0531', 72, 2, -9000.00, 'Cash withdrawal', '2025-05-12 14:00:00'),
('TXN-2025-0532', 72, 1, 35000.00, 'Monthly deposit', '2025-07-08 09:00:00'),
('TXN-2025-0533', 72, 4, -11000.00, 'Utility payments', '2025-09-10 10:00:00'),
('TXN-2025-0534', 72, 1, 35000.00, 'Monthly deposit', '2025-11-08 09:00:00'),

-- ============================================
-- AC-173 (account_id=73) Milagros Ignacio - Savings
-- ============================================
('TXN-2025-0535', 73, 1, 82000.00, 'Salary deposit', '2025-01-05 09:00:00'),
('TXN-2025-0536', 73, 3, -35000.00, 'Transfer to spouse account', '2025-03-08 11:30:00'),
('TXN-2025-0537', 73, 1, 82000.00, 'Salary deposit', '2025-04-05 09:00:00'),
('TXN-2025-0538', 73, 4, -18000.00, 'Life insurance premium', '2025-06-12 10:00:00'),
('TXN-2025-0539', 73, 1, 82000.00, 'Salary deposit', '2025-07-05 09:00:00'),
('TXN-2025-0540', 73, 2, -25000.00, 'Vacation fund withdrawal', '2025-09-22 14:00:00'),
('TXN-2025-0541', 73, 1, 164000.00, '13th month + salary', '2025-12-05 09:00:00'),
('TXN-2025-0542', 73, 1, 42000.00, 'Dividend deposit', '2025-05-18 09:30:00'),

-- ============================================
-- AC-174 (account_id=74) Augusto Mercado - Business
-- ============================================
('TXN-2025-0543', 74, 1, 210000.00, 'Construction revenue Q1', '2025-01-18 09:00:00'),
('TXN-2025-0544', 74, 4, -95000.00, 'Materials and labor', '2025-02-22 14:00:00'),
('TXN-2025-0545', 74, 1, 240000.00, 'Q2 project payments', '2025-04-20 09:00:00'),
('TXN-2025-0546', 74, 4, -105000.00, 'Equipment rental', '2025-06-25 14:00:00'),
('TXN-2025-0547', 74, 1, 195000.00, 'Q3 payments', '2025-08-18 09:00:00'),
('TXN-2025-0548', 74, 4, -88000.00, 'Supplier payments', '2025-10-12 14:00:00'),
('TXN-2025-0549', 74, 1, 280000.00, 'Year-end project completion', '2025-12-15 09:00:00'),
('TXN-2025-0550', 74, 4, -120000.00, 'Final contractor payments', '2025-12-28 14:00:00'),

-- ============================================
-- AC-175 (account_id=75) Felicidad Salvador - Savings
-- ============================================
('TXN-2025-0551', 75, 1, 62000.00, 'Payroll deposit', '2025-01-05 09:00:00'),
('TXN-2025-0552', 75, 2, -18000.00, 'Personal expenses', '2025-02-20 14:00:00'),
('TXN-2025-0553', 75, 1, 62000.00, 'Salary deposit', '2025-03-05 09:00:00'),
('TXN-2025-0554', 75, 4, -9500.00, 'Health plan payment', '2025-05-10 10:00:00'),
('TXN-2025-0555', 75, 1, 62000.00, 'Salary deposit', '2025-06-05 09:00:00'),
('TXN-2025-0556', 75, 2, -22000.00, 'Emergency withdrawal', '2025-08-15 14:00:00'),
('TXN-2025-0557', 75, 1, 62000.00, 'Salary deposit', '2025-09-05 09:00:00'),
('TXN-2025-0558', 75, 4, -7000.00, 'Phone and internet', '2025-10-10 10:00:00'),
('TXN-2025-0559', 75, 1, 124000.00, '13th month + salary', '2025-12-05 09:00:00'),
('TXN-2025-0560', 75, 2, -30000.00, 'Christmas expenses', '2025-12-22 11:00:00'),
('TXN-2026-0041', 75, 5, -500.00, 'Monthly maintenance fee', '2026-03-08 23:59:00');

-- ========================================
-- 10. COMPREHENSIVE LOANS DATA
-- ========================================

INSERT IGNORE INTO loans (loan_no, loan_type_id, borrower_external_no, principal_amount, interest_rate, start_date, term_months, monthly_payment, current_balance, status, created_by, created_at) VALUES
-- Salary Loans
('LN-1001', 1, 'EMP001', 50000.00, 0.05, '2024-01-01', 12, 4500.00, 45000.00, 'active', 1, '2024-01-01 09:00:00'),
('LN-1003', 1, 'EMP005', 30000.00, 0.05, '2024-02-01', 12, 2700.00, 30000.00, 'active', 1, '2024-02-01 11:15:00'),
('LN-1007', 1, 'EMP004', 25000.00, 0.05, '2024-01-20', 12, 2250.00, 25000.00, 'paid', 1, '2024-01-20 15:10:00'),
('LN-1009', 1, 'EMP008', 40000.00, 0.05, '2024-02-15', 12, 3600.00, 40000.00, 'active', 1, '2024-02-15 14:30:00'),
('LN-1010', 1, 'EMP010', 20000.00, 0.05, '2024-03-01', 12, 1800.00, 20000.00, 'active', 1, '2024-03-01 10:00:00'),
('LN-1015', 1, 'EMP002', 35000.00, 0.05, '2024-11-01', 12, 3150.00, 35000.00, 'active', 1, '2024-11-01 09:00:00'),
('LN-1016', 1, 'EMP004', 18000.00, 0.05, '2024-11-15', 12, 1620.00, 18000.00, 'active', 1, '2024-11-15 11:15:00'),
('LN-1017', 1, 'EMP006', 28000.00, 0.05, '2024-12-01', 12, 2520.00, 28000.00, 'active', 1, '2024-12-01 10:00:00'),
('LN-1018', 1, 'EMP008', 200000.00, 0.05, '2024-09-01', 60, 4000.00, 200000.00, 'active', 1, '2024-09-01 14:30:00'),
('LN-1019', 1, 'EMP010', 35000.00, 0.05, '2024-12-10', 24, 1500.00, 35000.00, 'active', 1, '2024-12-10 10:00:00'),

-- Emergency Loans
('LN-1002', 2, 'EMP003', 20000.00, 0.08, '2024-01-15', 6, 3600.00, 18000.00, 'active', 1, '2024-01-15 10:30:00'),
('LN-1005', 2, 'EMP009', 15000.00, 0.08, '2024-02-10', 6, 2700.00, 15000.00, 'active', 1, '2024-02-10 16:45:00'),
('LN-1008', 2, 'EMP006', 10000.00, 0.08, '2024-02-15', 6, 1800.00, 10000.00, 'defaulted', 1, '2024-02-15 12:00:00'),
('LN-1011', 2, 'EMP002', 12000.00, 0.08, '2024-01-10', 6, 2160.00, 12000.00, 'active', 1, '2024-01-10 11:20:00'),

-- Housing Loans
('LN-1004', 3, 'EMP007', 400000.00, 0.06, '2023-06-01', 60, 8000.00, 320000.00, 'active', 1, '2023-06-01 14:20:00'),
('LN-1012', 3, 'EMP001', 300000.00, 0.06, '2023-08-01', 60, 6000.00, 240000.00, 'active', 1, '2023-08-01 15:30:00'),

-- Education Loans
('LN-1006', 4, 'EMP002', 80000.00, 0.04, '2023-09-01', 24, 3500.00, 56000.00, 'active', 1, '2023-09-01 13:30:00'),
('LN-1013', 4, 'EMP003', 60000.00, 0.04, '2024-01-05', 24, 2600.00, 60000.00, 'active', 1, '2024-01-05 09:15:00'),
('LN-1014', 4, 'EMP009', 45000.00, 0.04, '2024-02-20', 24, 1950.00, 45000.00, 'active', 1, '2024-02-20 16:00:00'),

-- Vehicle Loans
('LN-1020', 5, 'EMP011', 250000.00, 0.07, '2024-03-01', 36, 7500.00, 250000.00, 'active', 1, '2024-03-01 10:00:00'),
('LN-1021', 5, 'EMP013', 180000.00, 0.07, '2024-04-15', 36, 5400.00, 180000.00, 'active', 1, '2024-04-15 14:30:00'),

-- Medical Loans
('LN-1022', 6, 'EMP015', 12000.00, 0.03, '2024-05-01', 12, 1000.00, 12000.00, 'active', 1, '2024-05-01 09:00:00'),
('LN-1023', 6, 'EMP017', 8000.00, 0.03, '2024-06-10', 12, 667.00, 8000.00, 'active', 1, '2024-06-10 11:15:00'),

-- Appliance Loans
('LN-1024', 7, 'EMP019', 15000.00, 0.05, '2024-07-01', 18, 900.00, 15000.00, 'active', 1, '2024-07-01 10:00:00'),
('LN-1025', 7, 'EMP021', 20000.00, 0.05, '2024-08-15', 18, 1200.00, 20000.00, 'active', 1, '2024-08-15 14:30:00'),

-- Additional loans from sample_loan_data.sql (using extended loan types)
-- Note: These use different loan_type_id references based on the new types added above
('LOAN-2024-001', (SELECT id FROM loan_types WHERE code = 'PL'), 'EMP001', 150000.00, 12.5000, '2024-01-15', 36, 5025.00, 120000.00, 'active', 1, '2024-01-15 09:00:00'),
('LOAN-2024-002', (SELECT id FROM loan_types WHERE code = 'HL'), 'EMP002', 1500000.00, 8.5000, '2024-02-01', 240, 12850.00, 1450000.00, 'active', 1, '2024-02-01 11:00:00'),
('LOAN-2024-003', (SELECT id FROM loan_types WHERE code = 'VL'), 'EMP003', 500000.00, 10.0000, '2024-03-10', 60, 10625.00, 450000.00, 'active', 1, '2024-03-10 10:00:00'),
('LOAN-2024-004', (SELECT id FROM loan_types WHERE code = 'EL'), 'EMP004', 50000.00, 15.0000, '2023-12-01', 12, 4500.00, 0.00, 'paid', 1, '2023-12-01 09:00:00'),
('LOAN-2024-005', (SELECT id FROM loan_types WHERE code = 'SL'), 'EMP005', 100000.00, 14.0000, '2024-04-01', 24, 4850.00, 85000.00, 'active', 1, '2024-04-01 09:00:00'),
('LOAN-2024-006', (SELECT id FROM loan_types WHERE code = 'PL'), 'EMP001', 75000.00, 12.5000, '2024-05-15', 24, 3575.00, 65000.00, 'active', 1, '2024-05-15 10:00:00'),
('LOAN-2023-010', (SELECT id FROM loan_types WHERE code = 'PL'), 'EMP002', 100000.00, 12.5000, '2023-01-15', 36, 3350.00, 0.00, 'paid', 1, '2023-01-15 09:00:00'),
('LOAN-2023-015', (SELECT id FROM loan_types WHERE code = 'VL'), 'EMP003', 350000.00, 10.0000, '2023-06-01', 60, 7437.50, 280000.00, 'active', 1, '2023-06-01 09:00:00'),
('LOAN-2024-007', (SELECT id FROM loan_types WHERE code = 'EL'), 'EMP004', 25000.00, 15.0000, '2024-06-01', 12, 2250.00, 18000.00, 'active', 1, '2024-06-01 09:00:00'),
('LOAN-2024-008', (SELECT id FROM loan_types WHERE code = 'HL'), 'EMP005', 800000.00, 8.5000, '2024-07-01', 180, 7960.00, 795000.00, 'pending', 1, '2024-07-01 09:00:00')
ON DUPLICATE KEY UPDATE principal_amount = VALUES(principal_amount);

-- ========================================
-- 10.5. LOAN APPLICATIONS DATA (from subsystem)
-- ========================================

INSERT IGNORE INTO loan_applications (
    id, loan_type_id, full_name, account_number, contact_number, email, job, monthly_salary, 
    user_email, loan_type, loan_terms, loan_amount, purpose, monthly_payment, 
    due_date, status, remarks, file_name, created_at, approved_by, approved_at, 
    next_payment_due, rejected_by, rejected_at, rejection_remarks, 
    proof_of_income, coe_document, pdf_path, pdf_approved, pdf_active, pdf_rejected
) VALUES
-- LOAN APPLICATIONS (using employee names)
(1, 3, 'Kurt Realisan', '1001234567', '09123456789', 'kurtrealisan@gmail.com', NULL, NULL, 'kurtrealisan@gmail.com', 'Home Loan', '24 Months', 5000.00, '0', NULL, NULL, 'Active', 'sdfsdfsdfsd', 'uploads/the-dark-knight-mixed-art-fvy9jfrmv7np7z0r.jpg', '2025-11-01 17:18:39', 'Jerome Malunes', '2025-11-02 17:55:21', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(2, 3, 'Kurt Realisan', '1001234567', '09123456789', 'kurtrealisan@gmail.com', 'Data Analyst', 20000.00, 'kurtrealisan@gmail.com', 'Home Loan', '12 Months', 60000.00, 'For house building purposes', 5558.07, '2026-11-02', 'Rejected', 'Invalid ID', 'uploads/download.jpg', '2025-11-02 04:00:24', NULL, NULL, NULL, 'Jerome Malunes', '2025-11-02 17:29:08', 'Invalid ID', NULL, NULL, NULL, NULL, NULL, NULL),
(3, 2, 'Kurt Realisan', '1001234567', '09123456789', 'kurtrealisan@gmail.com', 'Data Analyst', 20000.00, '', 'Car Loan', '24 Months', 50000.00, 'For personal car purposes ', 2544.79, '2027-11-02', 'Active', 'Thank You!', 'uploads/download.jpg', '2025-11-02 10:44:49', 'Jerome Malunes', '2025-11-02 17:15:51', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(4, 3, 'Kurt Realisan', '1001234567', '09123456789', 'kurtrealisan@gmail.com', 'Data Analyst', 20000.00, '', 'Home Loan', '24 Months', 7000.00, 'For family house ni Carspeso', 356.27, '2027-11-02', 'Rejected', 'The ID is not valid', 'uploads/images.jpg', '2025-11-02 10:55:26', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(5, 1, 'Kurt Realisan', '1001234567', '09123456789', 'kurtrealisan@gmail.com', 'Data Analyst', 20000.00, '', 'Personal Loan', '6 Months', 6000.00, 'For study purposes ', 1059.14, '2026-05-02', 'Rejected', 'sffsdfsd', 'uploads/Jespic.jpg', '2025-11-02 12:45:51', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(6, 3, 'Kurt Realisan', '1001234567', '09123456789', 'kurtrealisan@gmail.com', 'Data Analyst', 20000.00, '', 'Home Loan', '30 Months', 6000.00, 'For housing purposes', 255.78, '2028-05-02', 'Active', 'Thank You!', 'uploads/Jespic.jpg', '2025-11-02 12:47:59', 'Jerome Malunes', '2025-11-02 16:44:48', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(6, 4, 'Kurt Realisan', '1001234567', '09123456789', 'kurtrealisan@gmail.com', 'Data Analyst', 20000.00, '', 'Multi-Purpose Loan', '6 Months', 5000.00, 'For multi purpose only', 882.61, '2026-05-02', 'Approved', 'sdfsdfsd', 'uploads/Jespic.jpg', '2025-11-02 13:38:07', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(8, 4, 'Kurt Realisan', '1001234567', '09123456789', 'kurtrealisan@gmail.com', 'Data Analyst', 20000.00, '', 'Multi-Purpose Loan', '6 Months', 7000.00, 'For purposes only', 1235.66, '2026-05-02', 'Active', 'OK', 'uploads/Jespic.jpg', '2025-11-02 17:01:28', 'Jerome Malunes', '2025-11-03 01:04:11', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(9, 2, 'Clarence Carpeso', '1006789012', '09678901234', 'clarencecarpeso@gmail.com', 'Crossfire Developer', 20000.00, '', 'Car Loan', '6 Months', 10000.00, 'For purposes', 1765.23, '2026-05-02', 'Rejected', 'Invalid ID', 'uploads/Jespic.jpg', '2025-11-02 21:29:52', NULL, NULL, NULL, 'Jerome Malunes', '2025-11-03 05:30:50', 'Invalid ID', NULL, NULL, NULL, NULL, NULL, NULL),
(10, 3, 'Clarence Carpeso', '1006789012', '09678901234', 'clarencecarpeso@gmail.com', 'Crossfire Developer', 20000.00, '', 'Home Loan', '6 Months', 5000.00, 'For buying house parts', 882.61, '2026-05-02', 'Active', 'Thank you!', 'uploads/Jespic.jpg', '2025-11-02 21:47:34', 'Jerome Malunes', '2025-11-03 05:48:14', '2025-12-03', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(11, 4, 'Clarence Carpeso', '1006789012', '09678901234', 'clarencecarpeso@gmail.com', 'Crossfire Developer', 20000.00, '', 'Multi-Purpose Loan', '6 Months', 7000.00, 'For investment', 1235.66, '2026-05-02', 'Active', 'Thank you for applying loans!! Please pay on the exact time', 'uploads/Jespic.jpg', '2025-11-02 22:24:57', 'Jerome Malunes', '2025-11-03 06:38:36', '2025-12-03', NULL, NULL, NULL, NULL, NULL, 'uploads/loan_approved_34_20251106141556.pdf', NULL, NULL, NULL),
(12, 1, 'Clarence Carpeso', '1006789012', '09678901234', 'clarencecarpeso@gmail.com', 'Crossfire Developer', 20000.00, '', 'Personal Loan', '12 Months', 30000.00, 'For funds ', 2779.04, '2026-11-06', 'Rejected', 'Please input a clear picture of valid ID', 'uploads/Jespic.jpg', '2025-11-06 10:56:13', NULL, NULL, NULL, 'Jerome Malunes', '2025-11-06 19:06:39', 'Please input a clear picture of valid ID', 'uploads/Lord, I pray for this (2).png', 'uploads/download.jpg', 'uploads/loan_rejected_35_20251106141541.pdf', NULL, NULL, NULL),
(13, 3, 'Clarence Carpeso', '1006789012', '09678901234', 'clarencecarpeso@gmail.com', 'Crossfire Developer', 20000.00, '', 'Home Loan', '24 Months', 9000.00, 'Bahay namin maliit lamang', 458.06, '2027-11-06', 'Active', 'Congratulations!!', 'uploads/Jespic.jpg', '2025-11-06 11:20:08', 'Jerome Malunes', '2025-11-06 19:57:54', '2025-12-06', NULL, NULL, NULL, 'uploads/the-dark-knight-mixed-art-fvy9jfrmv7np7z0r.jpg', 'uploads/ERD (1).png', 'uploads/loan_approved_36_20251106140535.pdf', NULL, NULL, NULL),
(14, 4, 'Clarence Carpeso', '1006789012', '09678901234', 'clarencecarpeso@gmail.com', 'Crossfire Developer', 20000.00, '', 'Multi-Purpose Loan', '36 Months', 100000.00, 'For family planning', 3716.36, '2028-11-06', 'Active', 'Please be advised', 'uploads/Jespic.jpg', '2025-11-06 13:52:07', 'Jerome Malunes', '2025-11-06 21:52:50', '2025-12-06', NULL, NULL, NULL, 'uploads/the-dark-knight-mixed-art-fvy9jfrmv7np7z0r.jpg', 'uploads/ERD.png', 'uploads/loan_approved_37_20251106145455.pdf', NULL, NULL, NULL),
(15, 2, 'Clarence Carpeso', '1006789012', '09678901234', 'clarencecarpeso@gmail.com', 'Crossfire Developer', 20000.00, '', 'Car Loan', '24 Months', 7000.00, 'pautang ssob', 356.27, '2027-11-06', 'Rejected', 'Please upload a clear picture of ID', 'uploads/Jespic.jpg', '2025-11-06 14:01:54', NULL, NULL, NULL, 'Jerome Malunes', '2025-11-06 22:27:53', 'Please upload a clear picture of ID', 'uploads/Lord, I pray for this (3).png', 'uploads/images.jpg', 'uploads/loan_rejected_38_20251106153300.pdf', NULL, NULL, NULL),
(16, 3, 'Clarence Carpeso', '1006789012', '09678901234', 'clarencecarpeso@gmail.com', 'Crossfire Developer', 20000.00, '', 'Home Loan', '12 Months', 8000.00, 'Bahay Kubo', 741.08, '2026-11-06', 'Active', 'OK', 'uploads/Jespic.jpg', '2025-11-06 14:39:43', 'Jerome Malunes', '2025-11-06 22:42:16', '2025-12-06', NULL, NULL, NULL, 'uploads/download.jpg', 'uploads/images.jpg', 'uploads/loan_approved_39_20251106155223.pdf', NULL, NULL, NULL),
(17, 4, 'Mike Beringuela', '1004567890', '09456789012', 'mikeberinguela@gmail.com', 'Project Manager', 70000.00, '', 'Multi-Purpose Loan', '12 Months', 6000.00, 'For purpose', 555.81, '2026-11-07', 'Pending', NULL, 'uploads/Jespic.jpg', '2025-11-07 13:48:14', NULL, NULL, NULL, NULL, NULL, NULL, 'uploads/download.jpg', 'uploads/images.jpg', NULL, NULL, NULL, NULL),
(18, 3, 'Clarence Carpeso', '1006789012', '09678901234', 'clarencecarpeso@gmail.com', 'Crossfire Developer', 20000.00, '', 'Home Loan', '24 Months', 40000.00, 'oh when the saints , ipaghiganti mo ang iglesiaaaaaaaaaaaa', 2035.83, '2027-11-07', 'Active', 'Maureene', 'uploads/Jespic.jpg', '2025-11-07 17:11:58', 'Jerome Malunes', '2025-11-08 01:15:36', '2025-12-08', NULL, NULL, NULL, 'uploads/images.jpg', 'uploads/633f1770-3587-4d69-99c3-a9871b0818b9.jpg', 'uploads/loan_approved_41_20251107181558.pdf', NULL, NULL, NULL),

(24, 3, 'Juan Carlos Santos', 'SA-2025-001', '09171234567', 'juan.santos@company.com', 'HR Manager', 65000.00, 'juan.santos@company.com', 'Home Loan', '24 Months', 5000.00, 'Home renovation project', NULL, NULL, 'Active', 'Application approved. Good credit history.', 'uploads/valid_id_santos.jpg', '2025-11-01 17:18:39', 'System Administrator', '2025-11-02 17:55:21', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(25, 3, 'Maria Elena Rodriguez', 'SA-2025-002', '09171234568', 'maria.rodriguez@company.com', 'CFO', 200000.00, 'maria.rodriguez@company.com', 'Home Loan', '12 Months', 60000.00, 'House building purposes - Tagaytay property', 5558.07, '2026-11-02', 'Rejected', 'Incomplete documentation', 'uploads/valid_id_rodriguez.jpg', '2025-11-02 04:00:24', NULL, NULL, NULL, 'System Administrator', '2025-11-02 17:29:08', 'Incomplete documentation - please resubmit proof of income', NULL, NULL, NULL, NULL, NULL, NULL),
(26, 2, 'Jose Miguel Cruz', 'SA-2025-003', '09171234569', 'jose.cruz@company.com', 'CTO', 220000.00, 'jose.cruz@company.com', 'Car Loan', '24 Months', 50000.00, 'Personal vehicle purchase - Toyota Fortuner', 2544.79, '2027-11-02', 'Active', 'Approved. Excellent payment capacity.', 'uploads/valid_id_cruz.jpg', '2025-11-02 10:44:49', 'System Administrator', '2025-11-02 17:15:51', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(27, 3, 'Ana Patricia Lopez', 'SA-2025-004', '09171234570', 'ana.lopez@company.com', 'Marketing Director', 120000.00, 'ana.lopez@company.com', 'Home Loan', '24 Months', 7000.00, 'Kitchen and bathroom renovation', 356.27, '2027-11-02', 'Rejected', 'ID verification failed', 'uploads/valid_id_lopez.jpg', '2025-11-02 10:55:26', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(28, 1, 'Roberto Antonio Garcia', 'SA-2025-005', '09171234571', 'roberto.garcia@company.com', 'COO', 200000.00, 'roberto.garcia@company.com', 'Personal Loan', '6 Months', 6000.00, 'Emergency family expenses', 1059.14, '2026-05-02', 'Rejected', 'Exceeded maximum loan count', 'uploads/valid_id_garcia.jpg', '2025-11-02 12:45:51', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(29, 3, 'Carmen Sofia Martinez', 'SA-2025-006', '09171234572', 'carmen.martinez@company.com', 'CS Manager', 55000.00, 'carmen.martinez@company.com', 'Home Loan', '30 Months', 6000.00, 'Condominium down payment', 255.78, '2028-05-02', 'Active', 'First-time homeowner loan approved.', 'uploads/valid_id_martinez.jpg', '2025-11-02 12:47:59', 'System Administrator', '2025-11-02 16:44:48', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(30, 4, 'Fernando Luis Torres', 'SA-2025-007', '09171234573', 'fernando.torres@company.com', 'Sales Manager', 70000.00, 'fernando.torres@company.com', 'Multi-Purpose Loan', '6 Months', 5000.00, 'Business seminar and networking events', 882.61, '2026-05-02', 'Approved', 'Under review for final disbursement.', 'uploads/valid_id_torres.jpg', '2025-11-02 13:38:07', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(31, 4, 'Isabella Rose Flores', 'SA-2025-008', '09171234574', 'isabella.flores@company.com', 'Senior Accountant', 48000.00, 'isabella.flores@company.com', 'Multi-Purpose Loan', '6 Months', 7000.00, 'CPA review course and exam fees', 1235.66, '2026-05-02', 'Active', 'Professional development loan approved.', 'uploads/valid_id_flores.jpg', '2025-11-02 17:01:28', 'System Administrator', '2025-11-03 01:04:11', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(32, 2, 'Miguel Angel Reyes', 'SA-2025-009', '09171234575', 'miguel.reyes@company.com', 'Senior Developer', 85000.00, 'miguel.reyes@company.com', 'Car Loan', '6 Months', 10000.00, 'Vehicle repair and maintenance', 1765.23, '2026-05-02', 'Rejected', 'Insufficient supporting documents', 'uploads/valid_id_reyes.jpg', '2025-11-02 21:29:52', NULL, NULL, NULL, 'System Administrator', '2025-11-03 05:30:50', 'Insufficient supporting documents - please provide vehicle OR/CR', NULL, NULL, NULL, NULL, NULL, NULL),
(33, 3, 'Sofia Grace Villanueva', 'SA-2025-010', '09171234576', 'sofia.villanueva@company.com', 'Marketing Specialist', 42000.00, 'sofia.villanueva@company.com', 'Home Loan', '6 Months', 5000.00, 'Apartment deposit and advance rent', 882.61, '2026-05-02', 'Active', 'Small housing loan approved.', 'uploads/valid_id_villanueva.jpg', '2025-11-02 21:47:34', 'System Administrator', '2025-11-03 05:48:14', '2025-12-03', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(34, 4, 'Carlos Eduardo Mendoza', 'SA-2025-011', '09171234577', 'carlos.mendoza@company.com', 'Software Developer', 55000.00, 'carlos.mendoza@company.com', 'Multi-Purpose Loan', '6 Months', 7000.00, 'Computer upgrade for remote work setup', 1235.66, '2026-05-02', 'Active', 'Work-from-home setup loan approved.', 'uploads/valid_id_mendoza.jpg', '2025-11-02 22:24:57', 'System Administrator', '2025-11-03 06:38:36', '2025-12-03', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(35, 1, 'Patricia Isabel Gutierrez', 'SA-2025-012', '09171234578', 'patricia.gutierrez@company.com', 'Accountant', 35000.00, 'patricia.gutierrez@company.com', 'Personal Loan', '12 Months', 30000.00, 'Family medical emergency', 2779.04, '2026-11-06', 'Rejected', 'Income-to-loan ratio exceeded threshold', 'uploads/valid_id_gutierrez.jpg', '2025-11-06 10:56:13', NULL, NULL, NULL, 'System Administrator', '2025-11-06 19:06:39', 'Income-to-loan ratio exceeded threshold. Consider lower amount.', NULL, NULL, NULL, NULL, NULL, NULL),
(36, 3, 'Ricardo Manuel Herrera', 'SA-2025-013', '09171234579', 'ricardo.herrera@company.com', 'Sales Executive', 40000.00, 'ricardo.herrera@company.com', 'Home Loan', '24 Months', 9000.00, 'House painting and minor repairs', 458.06, '2027-11-06', 'Active', 'Home improvement loan approved.', 'uploads/valid_id_herrera.jpg', '2025-11-06 11:20:08', 'System Administrator', '2025-11-06 19:57:54', '2025-12-06', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(37, 4, 'Gabriela Alejandra Morales', 'SA-2025-014', '09171234580', 'gabriela.morales@company.com', 'CS Representative', 25000.00, 'gabriela.morales@company.com', 'Multi-Purpose Loan', '36 Months', 100000.00, 'Small business startup - online shop', 3716.36, '2028-11-06', 'Active', 'Entrepreneurship support loan approved.', 'uploads/valid_id_morales.jpg', '2025-11-06 13:52:07', 'System Administrator', '2025-11-06 21:52:50', '2025-12-06', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(38, 2, 'Diego Fernando Ramos', 'SA-2025-015', '09171234581', 'diego.ramos@company.com', 'Operations Coordinator', 32000.00, 'diego.ramos@company.com', 'Car Loan', '24 Months', 7000.00, 'Motorcycle purchase for daily commute', 356.27, '2027-11-06', 'Rejected', 'Credit score below minimum requirement', 'uploads/valid_id_ramos.jpg', '2025-11-06 14:01:54', NULL, NULL, NULL, 'System Administrator', '2025-11-06 22:27:53', 'Credit score below minimum requirement. Reapply after 6 months.', NULL, NULL, NULL, NULL, NULL, NULL),
(39, 3, 'Valentina Sofia Castillo', 'SA-2025-016', '09171234582', 'valentina.castillo@company.com', 'Content Creator', 28000.00, 'valentina.castillo@company.com', 'Home Loan', '12 Months', 8000.00, 'Studio apartment furnishing', 741.08, '2026-11-06', 'Active', 'Small housing loan approved for furnishing.', 'uploads/valid_id_castillo.jpg', '2025-11-06 14:39:43', 'System Administrator', '2025-11-06 22:42:16', '2025-12-06', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(40, 4, 'Sebastian Alejandro Vega', 'SA-2025-017', '09171234583', 'sebastian.vega@company.com', 'Junior Developer', 38000.00, 'sebastian.vega@company.com', 'Multi-Purpose Loan', '12 Months', 6000.00, 'Programming bootcamp enrollment', 555.81, '2026-11-07', 'Pending', NULL, 'uploads/valid_id_vega.jpg', '2025-11-07 13:48:14', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(41, 3, 'Camila Esperanza Ruiz', 'SA-2025-018', '09171234584', 'camila.ruiz@company.com', 'Payroll Specialist', 32000.00, 'camila.ruiz@company.com', 'Home Loan', '24 Months', 40000.00, 'Condominium unit for family', 2035.83, '2027-11-07', 'Active', 'Housing loan approved. Good payment track record.', 'uploads/valid_id_ruiz.jpg', '2025-11-07 17:11:58', 'System Administrator', '2025-11-08 01:15:36', '2025-12-08', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),

-- Additional loan applications (varied statuses)
(61, 2, 'Andres Felipe Castro', 'SA-2025-021', '09171234587', 'andres.castro@company.com', 'Warehouse Supervisor', 45000.00, 'andres.castro@company.com', 'Car Loan', '12 Months', 7000.00, 'Vehicle maintenance and registration', 648.44, '2026-11-29', 'Active', 'Dear Andres Felipe Castro,\n\nYour loan is now ACTIVE!\n\nPayment Details:\n- Monthly Payment: ₱648.44\n- First Payment Due: December 29, 2025\n- Final Payment: November 29, 2026\n\nActivated by: System Administrator\nDate: 2025-11-29 09:45:59', 'uploads/valid_id_castro.jpg', '2025-11-29 01:44:55', 'System Administrator', '2025-11-29 09:45:25', '2025-12-29', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(62, 3, 'Mariana Beatriz Ortega', 'SA-2025-022', '09171234588', 'mariana.ortega@company.com', 'Accounts Payable Clerk', 28000.00, 'mariana.ortega@company.com', 'Home Loan', '12 Months', 9000.00, 'Apartment lease deposit', 833.71, '2026-11-29', 'Pending', NULL, 'uploads/valid_id_ortega.jpg', '2025-11-29 01:48:07', NULL, NULL, '2025-12-29', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(63, 4, 'Santiago Ignacio Pena', 'SA-2025-023', '09171234589', 'santiago.pena@company.com', 'System Administrator', 55000.00, 'santiago.pena@company.com', 'Multi-Purpose Loan', '6 Months', 9000.00, 'Home office server equipment', 1588.71, '2026-05-29', 'Approved', 'Dear Santiago Ignacio Pena,\n\nCongratulations! Your loan application for ₱9,000.00 has been APPROVED.\n\nPlease visit our office within 30 days to claim your loan.\n\nLoan Details:\n- Amount: ₱9,000.00\n- Term: 6 Months\n- Monthly Payment: ₱1,588.71\n\nApproved by: System Administrator\nDate: 2025-11-29 09:50:14', 'uploads/valid_id_pena.jpg', '2025-11-29 01:49:58', 'System Administrator', '2025-11-29 09:50:14', '2025-12-29', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),

-- New applications (December 2025 - March 2026)
(64, 1, 'Daniela Fernanda Vargas', 'SA-2025-024', '09171234590', 'daniela.vargas@company.com', 'Social Media Manager', 35000.00, 'daniela.vargas@company.com', 'Personal Loan', '12 Months', 15000.00, 'Wedding preparation expenses', 1389.52, '2026-12-15', 'Approved', 'Personal loan approved for life event.', 'uploads/valid_id_vargas.jpg', '2025-12-15 10:00:00', 'System Administrator', '2025-12-16 09:00:00', '2026-01-15', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(65, 1, 'Alejandro Jose Medina', 'SA-2025-025', '09171234591', 'alejandro.medina@company.com', 'Account Manager', 50000.00, 'alejandro.medina@company.com', 'Personal Loan', '24 Months', 80000.00, 'Family vacation and debt consolidation', 3867.00, '2027-12-20', 'Active', 'Consolidation loan approved.', 'uploads/valid_id_medina.jpg', '2025-12-20 14:00:00', 'System Administrator', '2025-12-21 10:00:00', '2026-01-20', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(66, 2, 'Nicolas Gabriel Silva', 'SA-2025-019', '09171234585', 'nicolas.silva@company.com', 'Sales Representative', 30000.00, 'nicolas.silva@company.com', 'Car Loan', '36 Months', 150000.00, 'Second-hand car purchase for sales visits', 5250.00, '2029-01-10', 'Pending', NULL, 'uploads/valid_id_silva.jpg', '2026-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(67, 4, 'Lucia Esperanza Jimenez', 'SA-2025-020', '09171234586', 'lucia.jimenez@company.com', 'CS Representative', 25000.00, 'lucia.jimenez@company.com', 'Multi-Purpose Loan', '12 Months', 12000.00, 'Online business capital for side hustle', 1111.63, '2027-01-15', 'Rejected', 'Contractual employment - requires guarantor', 'uploads/valid_id_jimenez.jpg', '2026-01-15 09:30:00', NULL, NULL, NULL, 'System Administrator', '2026-01-16 10:00:00', 'Contractual employment status requires a guarantor. Please reapply.', NULL, NULL, NULL, NULL, NULL, NULL),
(68, 3, 'Juan Carlos Santos', 'SA-2025-001', '09171234567', 'juan.santos@company.com', 'HR Manager', 65000.00, 'juan.santos@company.com', 'Home Loan', '36 Months', 200000.00, 'Home extension - additional bedroom', 6950.00, '2029-02-01', 'Active', 'Second housing loan approved. Excellent track record.', 'uploads/valid_id_santos_2.jpg', '2026-02-01 10:00:00', 'System Administrator', '2026-02-02 09:00:00', '2026-03-01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(69, 1, 'Miguel Angel Reyes', 'SA-2025-009', '09171234575', 'miguel.reyes@company.com', 'Senior Developer', 85000.00, 'miguel.reyes@company.com', 'Personal Loan', '6 Months', 25000.00, 'Tech conference registration and travel', 4412.50, '2026-08-15', 'Approved', 'Professional development support.', 'uploads/valid_id_reyes_2.jpg', '2026-02-15 14:00:00', 'System Administrator', '2026-02-16 09:00:00', '2026-03-15', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(70, 2, 'Isabella Rose Flores', 'SA-2025-008', '09171234574', 'isabella.flores@company.com', 'Senior Accountant', 48000.00, 'isabella.flores@company.com', 'Car Loan', '24 Months', 120000.00, 'Used Toyota Vios purchase', 5550.00, '2028-03-01', 'Pending', NULL, 'uploads/valid_id_flores_2.jpg', '2026-03-01 11:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),

-- CARD APPLICATIONS (Credit Card / Debit Card)
(71, NULL, 'Maria Elena Rodriguez', 'SA-2025-002', '09171234568', 'maria.rodriguez@company.com', 'CFO', 200000.00, 'maria.rodriguez@company.com', 'Credit Card', 'N/A', 500000.00, 'Corporate credit card for business expenses', NULL, NULL, 'Active', 'Platinum credit card issued. High credit limit approved.', 'uploads/valid_id_rodriguez_cc.jpg', '2025-10-15 10:00:00', 'System Administrator', '2025-10-16 09:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(72, NULL, 'Jose Miguel Cruz', 'SA-2025-003', '09171234569', 'jose.cruz@company.com', 'CTO', 220000.00, 'jose.cruz@company.com', 'Credit Card', 'N/A', 300000.00, 'Technology purchases and subscriptions', NULL, NULL, 'Active', 'Gold credit card issued for tech purchases.', 'uploads/valid_id_cruz_cc.jpg', '2025-10-20 14:00:00', 'System Administrator', '2025-10-21 10:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(73, NULL, 'Roberto Antonio Garcia', 'SA-2025-005', '09171234571', 'roberto.garcia@company.com', 'COO', 200000.00, 'roberto.garcia@company.com', 'Credit Card', 'N/A', 400000.00, 'Operations procurement credit card', NULL, NULL, 'Active', 'Business credit card approved for operations.', 'uploads/valid_id_garcia_cc.jpg', '2025-11-01 09:00:00', 'System Administrator', '2025-11-02 10:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(74, NULL, 'Ana Patricia Lopez', 'SA-2025-004', '09171234570', 'ana.lopez@company.com', 'Marketing Director', 120000.00, 'ana.lopez@company.com', 'Credit Card', 'N/A', 200000.00, 'Marketing campaign and events credit card', NULL, NULL, 'Approved', 'Approved. Card to be issued within 5 business days.', 'uploads/valid_id_lopez_cc.jpg', '2025-11-15 11:00:00', 'System Administrator', '2025-11-16 09:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(75, NULL, 'Fernando Luis Torres', 'SA-2025-007', '09171234573', 'fernando.torres@company.com', 'Sales Manager', 70000.00, 'fernando.torres@company.com', 'Credit Card', 'N/A', 150000.00, 'Sales entertainment and client meetings', NULL, NULL, 'Approved', 'Standard credit card approved.', 'uploads/valid_id_torres_cc.jpg', '2025-12-01 10:00:00', 'System Administrator', '2025-12-02 09:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(76, NULL, 'Carlos Eduardo Mendoza', 'SA-2025-011', '09171234577', 'carlos.mendoza@company.com', 'Software Developer', 55000.00, 'carlos.mendoza@company.com', 'Credit Card', 'N/A', 100000.00, 'Software subscriptions and tools', NULL, NULL, 'Pending', NULL, 'uploads/valid_id_mendoza_cc.jpg', '2026-01-10 14:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(77, NULL, 'Patricia Isabel Gutierrez', 'SA-2025-012', '09171234578', 'patricia.gutierrez@company.com', 'Accountant', 35000.00, 'patricia.gutierrez@company.com', 'Credit Card', 'N/A', 75000.00, 'Personal credit card application', NULL, NULL, 'Pending', NULL, 'uploads/valid_id_gutierrez_cc.jpg', '2026-01-20 10:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(78, NULL, 'Gabriela Alejandra Morales', 'SA-2025-014', '09171234580', 'gabriela.morales@company.com', 'CS Representative', 25000.00, 'gabriela.morales@company.com', 'Credit Card', 'N/A', 50000.00, 'Personal expenses credit card', NULL, NULL, 'Declined', 'Minimum salary requirement not met for credit card.', 'uploads/valid_id_morales_cc.jpg', '2025-12-10 09:00:00', NULL, NULL, NULL, 'System Administrator', '2025-12-11 10:00:00', 'Minimum salary requirement of ₱30,000 not met.', NULL, NULL, NULL, NULL, NULL, NULL),
(79, NULL, 'Sebastian Alejandro Vega', 'SA-2025-017', '09171234583', 'sebastian.vega@company.com', 'Junior Developer', 38000.00, 'sebastian.vega@company.com', 'Debit Card', 'N/A', 0.00, 'Payroll debit card for salary', NULL, NULL, 'Active', 'Debit card issued for payroll account.', 'uploads/valid_id_vega_dc.jpg', '2025-11-10 10:00:00', 'System Administrator', '2025-11-11 09:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(80, NULL, 'Valentina Sofia Castillo', 'SA-2025-016', '09171234582', 'valentina.castillo@company.com', 'Content Creator', 28000.00, 'valentina.castillo@company.com', 'Debit Card', 'N/A', 0.00, 'Payroll debit card', NULL, NULL, 'Declined', 'Contractual employee - requires regularization.', 'uploads/valid_id_castillo_dc.jpg', '2025-12-05 11:00:00', NULL, NULL, NULL, 'System Administrator', '2025-12-06 09:00:00', 'Contractual employees must be regularized before card issuance.', NULL, NULL, NULL, NULL, NULL, NULL),
(81, NULL, 'Camila Esperanza Ruiz', 'SA-2025-018', '09171234584', 'camila.ruiz@company.com', 'Payroll Specialist', 32000.00, 'camila.ruiz@company.com', 'Credit Card', 'N/A', 60000.00, 'Personal credit card', NULL, NULL, 'Declined', 'Existing loan obligations exceed threshold', 'uploads/valid_id_ruiz_cc.jpg', '2026-02-10 10:00:00', NULL, NULL, NULL, 'System Administrator', '2026-02-11 10:00:00', 'Total existing loan obligations exceed 40% of monthly income.', NULL, NULL, NULL, NULL, NULL, NULL)
ON DUPLICATE KEY UPDATE 
    loan_type_id = VALUES(loan_type_id),
    full_name = VALUES(full_name),
    account_number = VALUES(account_number),
    contact_number = VALUES(contact_number),
    email = VALUES(email),
    job = VALUES(job),
    monthly_salary = VALUES(monthly_salary),
    user_email = VALUES(user_email),
    loan_type = VALUES(loan_type),
    loan_terms = VALUES(loan_terms),
    loan_amount = VALUES(loan_amount),
    purpose = VALUES(purpose),
    monthly_payment = VALUES(monthly_payment),
    due_date = VALUES(due_date),
    status = VALUES(status),
    remarks = VALUES(remarks),
    file_name = VALUES(file_name),
    approved_by = VALUES(approved_by),
    approved_at = VALUES(approved_at),
    next_payment_due = VALUES(next_payment_due),
    rejected_by = VALUES(rejected_by),
    rejected_at = VALUES(rejected_at),
    rejection_remarks = VALUES(rejection_remarks),
    proof_of_income = VALUES(proof_of_income),
    coe_document = VALUES(coe_document),
    pdf_path = VALUES(pdf_path),
    pdf_approved = VALUES(pdf_approved),
    pdf_active = VALUES(pdf_active),
    pdf_rejected = VALUES(pdf_rejected);

INSERT INTO `loan_application_types` (`id`, `name`) VALUES
(2, 'Car Loan'),
(3, 'Home Loan'),
(4, 'Multi-Purpose Loan'),
(1, 'Personal Loan');

INSERT INTO `loan_valid_id` (`id`, `valid_id_type`) VALUES
(1, 'Driver\'s License'),
(2, 'Postal Id'),
(3, 'GSIS'),
(4, 'NBI Clearance'),
(5, 'Passport'),
(6, 'National Id'),
(7, 'UMId'),
(8, 'Voter\'s ID'),
(9, 'PRC ID'),
(10, 'Postal ID'),
(11, 'PhilHealth ID'),
(12, 'Senior Citizen ID');
-- ========================================
-- 11. LOAN PAYMENTS DATA
-- ========================================

INSERT IGNORE INTO loan_payments (loan_id, payment_date, amount, principal_amount, interest_amount, payment_reference, journal_entry_id, created_at) VALUES
-- Loan 1 (EMP001 - Salary Loan)
(1, '2024-02-01', 4500.00, 4000.00, 500.00, 'PAY-2024-02-001', NULL, '2024-02-01 10:00:00'),
(1, '2024-03-01', 4500.00, 4000.00, 500.00, 'PAY-2024-03-001', NULL, '2024-03-01 10:00:00'),
(1, '2024-04-01', 4500.00, 4000.00, 500.00, 'PAY-2024-04-001', NULL, '2024-04-01 10:00:00'),
(1, '2024-05-01', 4500.00, 4000.00, 500.00, 'PAY-2024-05-001', NULL, '2024-05-01 10:00:00'),
(1, '2024-06-01', 4500.00, 4000.00, 500.00, 'PAY-2024-06-001', NULL, '2024-06-01 10:00:00'),
(1, '2024-07-01', 4500.00, 4000.00, 500.00, 'PAY-2024-07-001', NULL, '2024-07-01 10:00:00'),
(1, '2024-08-01', 4500.00, 4000.00, 500.00, 'PAY-2024-08-001', NULL, '2024-08-01 10:00:00'),
(1, '2024-09-01', 4500.00, 4000.00, 500.00, 'PAY-2024-09-001', NULL, '2024-09-01 10:00:00'),
(1, '2024-10-01', 4500.00, 4000.00, 500.00, 'PAY-2024-10-001', NULL, '2024-10-01 10:00:00'),
(1, '2024-11-01', 4500.00, 4000.00, 500.00, 'PAY-2024-11-001', NULL, '2024-11-01 10:00:00'),

-- Loan 2 (EMP003 - Emergency Loan)
(2, '2024-02-15', 3600.00, 3000.00, 600.00, 'PAY-2024-02-002', NULL, '2024-02-15 10:00:00'),
(2, '2024-03-15', 3600.00, 3000.00, 600.00, 'PAY-2024-03-002', NULL, '2024-03-15 10:00:00'),
(2, '2024-04-15', 3600.00, 3000.00, 600.00, 'PAY-2024-04-002', NULL, '2024-04-15 10:00:00'),
(2, '2024-05-15', 3600.00, 3000.00, 600.00, 'PAY-2024-05-002', NULL, '2024-05-15 10:00:00'),

-- Loan 3 (EMP005 - Salary Loan)
(3, '2024-03-01', 2700.00, 2500.00, 200.00, 'PAY-2024-03-003', NULL, '2024-03-01 10:00:00'),
(3, '2024-04-01', 2700.00, 2500.00, 200.00, 'PAY-2024-04-003', NULL, '2024-04-01 10:00:00'),
(3, '2024-05-01', 2700.00, 2500.00, 200.00, 'PAY-2024-05-003', NULL, '2024-05-01 10:00:00'),
(3, '2024-06-01', 2700.00, 2500.00, 200.00, 'PAY-2024-06-003', NULL, '2024-06-01 10:00:00'),
(3, '2024-07-01', 2700.00, 2500.00, 200.00, 'PAY-2024-07-003', NULL, '2024-07-01 10:00:00'),
(3, '2024-08-01', 2700.00, 2500.00, 200.00, 'PAY-2024-08-003', NULL, '2024-08-01 10:00:00'),
(3, '2024-09-01', 2700.00, 2500.00, 200.00, 'PAY-2024-09-003', NULL, '2024-09-01 10:00:00'),
(3, '2024-10-01', 2700.00, 2500.00, 200.00, 'PAY-2024-10-003', NULL, '2024-10-01 10:00:00'),
(3, '2024-11-01', 2700.00, 2500.00, 200.00, 'PAY-2024-11-003', NULL, '2024-11-01 10:00:00'),
(3, '2024-12-01', 2700.00, 2500.00, 200.00, 'PAY-2024-12-003', NULL, '2024-12-01 10:00:00'),

-- Loan 4 (EMP007 - Housing Loan)
(4, '2024-02-01', 8000.00, 6000.00, 2000.00, 'PAY-2024-02-003', NULL, '2024-02-01 10:00:00'),
(4, '2024-03-01', 8000.00, 6000.00, 2000.00, 'PAY-2024-03-004', NULL, '2024-03-01 10:00:00'),
(4, '2024-04-01', 8000.00, 6000.00, 2000.00, 'PAY-2024-04-004', NULL, '2024-04-01 10:00:00'),
(4, '2024-05-01', 8000.00, 6000.00, 2000.00, 'PAY-2024-05-004', NULL, '2024-05-01 10:00:00'),
(4, '2024-06-01', 8000.00, 6000.00, 2000.00, 'PAY-2024-06-004', NULL, '2024-06-01 10:00:00'),
(4, '2024-07-01', 8000.00, 6000.00, 2000.00, 'PAY-2024-07-004', NULL, '2024-07-01 10:00:00'),
(4, '2024-08-01', 8000.00, 6000.00, 2000.00, 'PAY-2024-08-004', NULL, '2024-08-01 10:00:00'),
(4, '2024-09-01', 8000.00, 6000.00, 2000.00, 'PAY-2024-09-004', NULL, '2024-09-01 10:00:00'),
(4, '2024-10-01', 8000.00, 6000.00, 2000.00, 'PAY-2024-10-004', NULL, '2024-10-01 10:00:00'),
(4, '2024-11-01', 8000.00, 6000.00, 2000.00, 'PAY-2024-11-004', NULL, '2024-11-01 10:00:00'),
(4, '2024-12-01', 8000.00, 6000.00, 2000.00, 'PAY-2024-12-004', NULL, '2024-12-01 10:00:00'),

-- Additional recent payments
(15, '2024-12-01', 3150.00, 2800.00, 350.00, 'PAY-2024-12-001', NULL, '2024-12-01 10:00:00'),
(16, '2024-12-15', 1620.00, 1500.00, 120.00, 'PAY-2024-12-002', NULL, '2024-12-15 10:00:00'),
(17, '2024-12-01', 2520.00, 2300.00, 220.00, 'PAY-2024-12-003', NULL, '2024-12-01 10:00:00'),
(18, '2024-12-01', 4000.00, 3000.00, 1000.00, 'PAY-2024-12-004', NULL, '2024-12-01 10:00:00'),
(19, '2024-12-15', 1500.00, 1300.00, 200.00, 'PAY-2024-12-005', NULL, '2024-12-15 10:00:00'),

-- Additional loan payments from sample_loan_data.sql for LOAN-2024-001 through LOAN-2024-008
((SELECT id FROM loans WHERE loan_no = 'LOAN-2024-001' LIMIT 1), '2024-02-15', 5025.00, 3775.00, 1250.00, 'PAY-2024-001', NULL, '2024-02-15 10:00:00'),
((SELECT id FROM loans WHERE loan_no = 'LOAN-2024-001' LIMIT 1), '2024-03-15', 5025.00, 3815.00, 1210.00, 'PAY-2024-002', NULL, '2024-03-15 10:00:00'),
((SELECT id FROM loans WHERE loan_no = 'LOAN-2024-001' LIMIT 1), '2024-04-15', 5025.00, 3855.00, 1170.00, 'PAY-2024-003', NULL, '2024-04-15 10:00:00'),
((SELECT id FROM loans WHERE loan_no = 'LOAN-2024-001' LIMIT 1), '2024-05-15', 5025.00, 3895.00, 1130.00, 'PAY-2024-004', NULL, '2024-05-15 10:00:00'),
((SELECT id FROM loans WHERE loan_no = 'LOAN-2024-001' LIMIT 1), '2024-06-15', 5025.00, 3935.00, 1090.00, 'PAY-2024-005', NULL, '2024-06-15 10:00:00'),
((SELECT id FROM loans WHERE loan_no = 'LOAN-2024-001' LIMIT 1), '2024-07-15', 5025.00, 3975.00, 1050.00, 'PAY-2024-006', NULL, '2024-07-15 10:00:00'),
((SELECT id FROM loans WHERE loan_no = 'LOAN-2024-002' LIMIT 1), '2024-03-01', 12850.00, 2225.00, 10625.00, 'PAY-2024-010', NULL, '2024-03-01 10:00:00'),
((SELECT id FROM loans WHERE loan_no = 'LOAN-2024-002' LIMIT 1), '2024-04-01', 12850.00, 2241.00, 10609.00, 'PAY-2024-011', NULL, '2024-04-01 10:00:00'),
((SELECT id FROM loans WHERE loan_no = 'LOAN-2024-003' LIMIT 1), '2024-04-10', 10625.00, 6458.33, 4166.67, 'PAY-2024-020', NULL, '2024-04-10 10:00:00'),
((SELECT id FROM loans WHERE loan_no = 'LOAN-2024-004' LIMIT 1), '2023-12-15', 4500.00, 3875.00, 625.00, 'PAY-2023-100', NULL, '2023-12-15 10:00:00'),
((SELECT id FROM loans WHERE loan_no = 'LOAN-2024-004' LIMIT 1), '2024-01-15', 4500.00, 3924.00, 576.00, 'PAY-2024-101', NULL, '2024-01-15 10:00:00'),
((SELECT id FROM loans WHERE loan_no = 'LOAN-2024-004' LIMIT 1), '2024-02-15', 4500.00, 3974.00, 526.00, 'PAY-2024-102', NULL, '2024-02-15 10:00:00'),
((SELECT id FROM loans WHERE loan_no = 'LOAN-2024-004' LIMIT 1), '2024-03-15', 4500.00, 4024.00, 476.00, 'PAY-2024-103', NULL, '2024-03-15 10:00:00'),
((SELECT id FROM loans WHERE loan_no = 'LOAN-2024-004' LIMIT 1), '2024-04-15', 4500.00, 4075.00, 425.00, 'PAY-2024-104', NULL, '2024-04-15 10:00:00'),
((SELECT id FROM loans WHERE loan_no = 'LOAN-2024-004' LIMIT 1), '2024-05-15', 4500.00, 4126.00, 374.00, 'PAY-2024-105', NULL, '2024-05-15 10:00:00'),
((SELECT id FROM loans WHERE loan_no = 'LOAN-2024-004' LIMIT 1), '2024-06-15', 4500.00, 4177.00, 323.00, 'PAY-2024-106', NULL, '2024-06-15 10:00:00'),
((SELECT id FROM loans WHERE loan_no = 'LOAN-2024-004' LIMIT 1), '2024-07-15', 4500.00, 4229.00, 271.00, 'PAY-2024-107', NULL, '2024-07-15 10:00:00'),
((SELECT id FROM loans WHERE loan_no = 'LOAN-2024-004' LIMIT 1), '2024-08-15', 4500.00, 4281.00, 219.00, 'PAY-2024-108', NULL, '2024-08-15 10:00:00'),
((SELECT id FROM loans WHERE loan_no = 'LOAN-2024-004' LIMIT 1), '2024-09-15', 4500.00, 4334.00, 166.00, 'PAY-2024-109', NULL, '2024-09-15 10:00:00'),
((SELECT id FROM loans WHERE loan_no = 'LOAN-2024-004' LIMIT 1), '2024-10-15', 4500.00, 4387.00, 113.00, 'PAY-2024-110', NULL, '2024-10-15 10:00:00'),
((SELECT id FROM loans WHERE loan_no = 'LOAN-2024-004' LIMIT 1), '2024-11-15', 4113.00, 4050.00, 63.00, 'PAY-2024-111', NULL, '2024-11-15 10:00:00'),
((SELECT id FROM loans WHERE loan_no = 'LOAN-2024-005' LIMIT 1), '2024-05-01', 4850.00, 3683.33, 1166.67, 'PAY-2024-200', NULL, '2024-05-01 10:00:00'),
((SELECT id FROM loans WHERE loan_no = 'LOAN-2024-005' LIMIT 1), '2024-06-01', 4850.00, 3726.00, 1124.00, 'PAY-2024-201', NULL, '2024-06-01 10:00:00'),
((SELECT id FROM loans WHERE loan_no = 'LOAN-2024-005' LIMIT 1), '2024-07-01', 4850.00, 3769.00, 1081.00, 'PAY-2024-202', NULL, '2024-07-01 10:00:00')
ON DUPLICATE KEY UPDATE amount = VALUES(amount);

-- ========================================
-- 12. COMPREHENSIVE EXPENSE CLAIMS
-- ========================================

INSERT IGNORE INTO expense_claims (claim_no, employee_external_no, expense_date, category_id, amount, description, status, approved_by, approved_at, payment_id, journal_entry_id, created_at) VALUES
-- January 2024 Expenses
('EXP001', 'EMP001', '2024-01-10', 1, 2500.00, 'Office supplies for Q1', 'approved', 1, '2024-01-11 09:00:00', NULL, NULL, '2024-01-10 09:00:00'),
('EXP002', 'EMP002', '2024-01-15', 2, 1500.00, 'Client meeting transportation', 'approved', 1, '2024-01-16 14:30:00', NULL, NULL, '2024-01-15 14:30:00'),
('EXP003', 'EMP003', '2024-01-20', 3, 800.00, 'Team lunch meeting', 'pending', NULL, NULL, NULL, NULL, '2024-01-20 12:00:00'),
('EXP004', 'EMP004', '2024-01-25', 1, 1200.00, 'Marketing materials', 'approved', 1, '2024-01-26 11:00:00', NULL, NULL, '2024-01-25 11:00:00'),
('EXP005', 'EMP005', '2024-01-30', 2, 800.00, 'Site visit transportation', 'approved', 1, '2024-01-31 15:30:00', NULL, NULL, '2024-01-30 15:30:00'),

-- February 2024 Expenses
('EXP006', 'EMP001', '2024-02-01', 4, 150.00, 'Internet bill reimbursement', 'approved', 1, '2024-02-02 10:15:00', NULL, NULL, '2024-02-01 10:15:00'),
('EXP007', 'EMP002', '2024-02-05', 5, 2500.00, 'Office rent payment', 'approved', 1, '2024-02-06 08:30:00', NULL, NULL, '2024-02-05 08:30:00'),
('EXP008', 'EMP003', '2024-02-10', 1, 350.00, 'Office supplies', 'rejected', 1, '2024-02-11 16:45:00', NULL, NULL, '2024-02-10 16:45:00'),
('EXP009', 'EMP004', '2024-02-15', 2, 2000.00, 'Sales conference travel', 'approved', 1, '2024-02-16 11:20:00', NULL, NULL, '2024-02-15 11:20:00'),
('EXP010', 'EMP005', '2024-02-20', 6, 1200.00, 'Payroll software training', 'approved', 1, '2024-02-21 13:10:00', NULL, NULL, '2024-02-20 13:10:00'),
('EXP011', 'EMP006', '2024-02-25', 3, 600.00, 'Customer service team lunch', 'approved', 1, '2024-02-26 12:30:00', NULL, NULL, '2024-02-25 12:30:00'),
('EXP012', 'EMP007', '2024-02-28', 2, 1500.00, 'Sales territory visit', 'approved', 1, '2024-02-29 14:00:00', NULL, NULL, '2024-02-28 14:00:00'),

-- March 2024 Expenses
('EXP013', 'EMP001', '2024-03-01', 7, 5000.00, 'New computer equipment', 'pending', NULL, NULL, NULL, NULL, '2024-03-01 09:30:00'),
('EXP014', 'EMP002', '2024-03-05', 3, 600.00, 'Marketing team dinner', 'approved', 1, '2024-03-06 18:00:00', NULL, NULL, '2024-03-05 18:00:00'),
('EXP015', 'EMP003', '2024-03-10', 1, 800.00, 'Development tools license', 'approved', 1, '2024-03-11 10:45:00', NULL, NULL, '2024-03-10 10:45:00'),
('EXP016', 'EMP004', '2024-03-15', 2, 1200.00, 'Marketing event travel', 'pending', NULL, NULL, NULL, NULL, '2024-03-15 16:20:00'),
('EXP017', 'EMP005', '2024-03-20', 4, 200.00, 'Utilities reimbursement', 'approved', 1, '2024-03-21 11:15:00', NULL, NULL, '2024-03-20 11:15:00'),
('EXP018', 'EMP006', '2024-03-25', 3, 400.00, 'Team building lunch', 'approved', 1, '2024-03-26 13:00:00', NULL, NULL, '2024-03-25 13:00:00'),
('EXP019', 'EMP007', '2024-03-30', 2, 1800.00, 'Client meeting travel', 'approved', 1, '2024-03-31 15:30:00', NULL, NULL, '2024-03-30 15:30:00'),
('EXP020', 'EMP008', '2024-03-31', 1, 300.00, 'Office supplies', 'approved', 1, '2024-04-01 09:00:00', NULL, NULL, '2024-03-31 09:00:00'),

-- Additional expenses for more variety
('EXP021', 'EMP009', '2024-01-12', 6, 1500.00, 'IT certification training', 'approved', 1, '2024-01-13 14:30:00', NULL, NULL, '2024-01-12 14:30:00'),
('EXP022', 'EMP010', '2024-02-08', 3, 500.00, 'Content creation team lunch', 'approved', 1, '2024-02-09 12:00:00', NULL, NULL, '2024-02-08 12:00:00'),
('EXP023', 'EMP001', '2024-03-12', 2, 900.00, 'HR conference attendance', 'approved', 1, '2024-03-13 08:30:00', NULL, NULL, '2024-03-12 08:30:00'),
('EXP024', 'EMP002', '2024-01-18', 1, 600.00, 'Accounting software license', 'approved', 1, '2024-01-19 10:00:00', NULL, NULL, '2024-01-18 10:00:00'),
('EXP025', 'EMP003', '2024-02-22', 7, 3000.00, 'Server maintenance tools', 'pending', NULL, NULL, NULL, NULL, '2024-02-22 16:45:00'),

-- Recent expenses (December 2024)
('EXP026', 'EMP001', '2024-12-01', 1, 1200.00, 'Office supplies for December', 'approved', 1, '2024-12-02 09:00:00', NULL, NULL, '2024-12-01 09:00:00'),
('EXP027', 'EMP003', '2024-12-05', 2, 2500.00, 'Client meeting travel', 'submitted', NULL, NULL, NULL, NULL, '2024-12-05 14:30:00'),
('EXP028', 'EMP005', '2024-12-08', 3, 800.00, 'Team dinner meeting', 'approved', 1, '2024-12-09 12:00:00', NULL, NULL, '2024-12-08 12:00:00'),
('EXP029', 'EMP007', '2024-12-10', 2, 1800.00, 'Sales conference attendance', 'pending', NULL, NULL, NULL, NULL, '2024-12-10 16:20:00'),
('EXP030', 'EMP009', '2024-12-12', 6, 2000.00, 'IT training certification', 'approved', 1, '2024-12-13 11:15:00', NULL, NULL, '2024-12-12 11:15:00'),
('EXP031', 'EMP002', '2024-12-15', 1, 600.00, 'Office supplies', 'draft', NULL, NULL, NULL, NULL, '2024-12-15 10:00:00'),
('EXP032', 'EMP004', '2024-12-18', 3, 450.00, 'Marketing team lunch', 'submitted', NULL, NULL, NULL, NULL, '2024-12-18 12:30:00'),
('EXP033', 'EMP006', '2024-12-20', 2, 1200.00, 'Customer service training', 'approved', 1, '2024-12-21 13:00:00', NULL, NULL, '2024-12-20 13:00:00'),

-- Additional expense tracking sample data
('EXP-2024-001', 'EMP001', '2024-01-15', (SELECT id FROM expense_categories WHERE code = 'TRAVEL'), 2500.00, 'Business trip to Manila for client meeting', 'approved', 1, '2024-01-16 14:20:00', NULL, NULL, '2024-01-15 09:30:00'),
('EXP-2024-002', 'EMP002', '2024-01-18', (SELECT id FROM expense_categories WHERE code = 'MEALS'), 850.00, 'Client dinner meeting at Makati restaurant', 'approved', 1, '2024-01-19 10:30:00', NULL, NULL, '2024-01-18 08:45:00'),
('EXP-2024-003', 'EMP003', '2024-01-20', (SELECT id FROM expense_categories WHERE code = 'OFFICE'), 1200.00, 'Office supplies and stationery', 'submitted', NULL, NULL, NULL, NULL, '2024-01-20 14:20:00'),
('EXP-2024-004', 'EMP001', '2024-01-22', (SELECT id FROM expense_categories WHERE code = 'COMM'), 450.00, 'Mobile phone bill for business calls', 'draft', NULL, NULL, NULL, NULL, '2024-01-22 11:15:00'),
('EXP-2024-005', 'EMP004', '2024-01-25', (SELECT id FROM expense_categories WHERE code = 'TRAINING'), 3500.00, 'Professional certification course', 'approved', 1, '2024-01-26 16:45:00', NULL, NULL, '2024-01-25 16:30:00'),
('EXP-2024-006', 'EMP002', '2024-01-28', (SELECT id FROM expense_categories WHERE code = 'TRAVEL'), 1800.00, 'Taxi fares for client visits', 'rejected', 1, '2024-01-29 09:15:00', NULL, NULL, '2024-01-28 13:20:00'),
('EXP-2024-007', 'EMP005', '2024-01-30', (SELECT id FROM expense_categories WHERE code = 'MEALS'), 650.00, 'Team lunch meeting', 'paid', 1, '2024-01-31 11:20:00', NULL, NULL, '2024-01-30 10:45:00'),
('EXP-2024-008', 'EMP003', '2024-02-02', (SELECT id FROM expense_categories WHERE code = 'OFFICE'), 950.00, 'Computer accessories and cables', 'submitted', NULL, NULL, NULL, NULL, '2024-02-02 09:00:00'),
('EXP-2024-009', 'EMP001', '2024-02-05', (SELECT id FROM expense_categories WHERE code = 'COMM'), 380.00, 'Internet service for home office', 'draft', NULL, NULL, NULL, NULL, '2024-02-05 10:30:00'),
('EXP-2024-010', 'EMP004', '2024-02-08', (SELECT id FROM expense_categories WHERE code = 'TRAVEL'), 3200.00, 'Conference attendance in Cebu', 'approved', 1, '2024-02-09 13:30:00', NULL, NULL, '2024-02-08 14:00:00'),

-- 2025 Expense Claims (Q1-Q4)
('EXP-2025-001', 'EMP001', '2025-01-08', 1, 3200.00, 'Office supplies bulk purchase for new year', 'approved', 1, '2025-01-09 09:00:00', NULL, NULL, '2025-01-08 09:00:00'),
('EXP-2025-002', 'EMP002', '2025-01-15', 2, 4500.00, 'Annual planning meeting travel to Manila', 'approved', 1, '2025-01-16 14:00:00', NULL, NULL, '2025-01-15 08:00:00'),
('EXP-2025-003', 'EMP003', '2025-01-22', 7, 18000.00, 'Server hardware upgrade - Dell PowerEdge', 'approved', 1, '2025-01-23 10:00:00', NULL, NULL, '2025-01-22 09:30:00'),
('EXP-2025-004', 'EMP004', '2025-02-05', 3, 2800.00, 'Marketing team strategy dinner', 'approved', 1, '2025-02-06 11:00:00', NULL, NULL, '2025-02-05 18:00:00'),
('EXP-2025-005', 'EMP005', '2025-02-12', 2, 5200.00, 'Operations conference in Cebu', 'approved', 1, '2025-02-13 10:00:00', NULL, NULL, '2025-02-12 08:00:00'),
('EXP-2025-006', 'EMP006', '2025-02-20', 6, 3500.00, 'Customer service training workshop', 'approved', 1, '2025-02-21 09:00:00', NULL, NULL, '2025-02-20 09:00:00'),
('EXP-2025-007', 'EMP007', '2025-03-03', 2, 6500.00, 'Sales team quarterly road show', 'approved', 1, '2025-03-04 10:00:00', NULL, NULL, '2025-03-03 07:00:00'),
('EXP-2025-008', 'EMP008', '2025-03-10', 1, 1200.00, 'Accounting supplies and forms', 'approved', 1, '2025-03-11 09:00:00', NULL, NULL, '2025-03-10 10:00:00'),
('EXP-2025-009', 'EMP009', '2025-03-18', 7, 25000.00, 'Software licenses - JetBrains annual subscription', 'approved', 1, '2025-03-19 11:00:00', NULL, NULL, '2025-03-18 14:00:00'),
('EXP-2025-010', 'EMP010', '2025-03-25', 3, 1500.00, 'Team building lunch at Greenbelt', 'approved', 1, '2025-03-26 12:00:00', NULL, NULL, '2025-03-25 12:00:00'),
('EXP-2025-011', 'EMP011', '2025-04-02', 4, 980.00, 'Internet bill reimbursement - March work from home', 'approved', 1, '2025-04-03 09:00:00', NULL, NULL, '2025-04-02 10:00:00'),
('EXP-2025-012', 'EMP012', '2025-04-10', 1, 2100.00, 'Filing supplies for tax season', 'approved', 1, '2025-04-11 09:00:00', NULL, NULL, '2025-04-10 09:00:00'),
('EXP-2025-013', 'EMP013', '2025-04-18', 2, 3800.00, 'Client visit travel to Davao', 'approved', 1, '2025-04-19 14:00:00', NULL, NULL, '2025-04-18 08:00:00'),
('EXP-2025-014', 'EMP014', '2025-05-05', 3, 900.00, 'Customer appreciation lunch', 'approved', 1, '2025-05-06 12:00:00', NULL, NULL, '2025-05-05 12:00:00'),
('EXP-2025-015', 'EMP015', '2025-05-12', 5, 8500.00, 'Warehouse lease monthly payment', 'approved', 1, '2025-05-13 10:00:00', NULL, NULL, '2025-05-12 09:00:00'),
('EXP-2025-016', 'EMP016', '2025-05-20', 7, 5500.00, 'Camera and lighting equipment for content', 'approved', 1, '2025-05-21 10:00:00', NULL, NULL, '2025-05-20 14:00:00'),
('EXP-2025-017', 'EMP017', '2025-06-03', 6, 4200.00, 'AWS certification course enrollment', 'approved', 1, '2025-06-04 09:00:00', NULL, NULL, '2025-06-03 10:00:00'),
('EXP-2025-018', 'EMP018', '2025-06-15', 1, 800.00, 'Payroll forms and envelopes', 'approved', 1, '2025-06-16 09:00:00', NULL, NULL, '2025-06-15 10:00:00'),
('EXP-2025-019', 'EMP019', '2025-06-22', 2, 2800.00, 'Client meeting travel to Subic', 'submitted', NULL, NULL, NULL, NULL, '2025-06-22 08:00:00'),
('EXP-2025-020', 'EMP020', '2025-07-01', 3, 650.00, 'Team lunch for new hire welcome', 'approved', 1, '2025-07-02 12:00:00', NULL, NULL, '2025-07-01 12:00:00'),
('EXP-2025-021', 'EMP021', '2025-07-10', 5, 12000.00, 'Insurance premium for warehouse', 'approved', 1, '2025-07-11 10:00:00', NULL, NULL, '2025-07-10 09:00:00'),
('EXP-2025-022', 'EMP022', '2025-07-18', 1, 1800.00, 'Office supplies - printer cartridges', 'approved', 1, '2025-07-19 09:00:00', NULL, NULL, '2025-07-18 10:00:00'),
('EXP-2025-023', 'EMP023', '2025-08-05', 7, 32000.00, 'Network switch and firewall upgrade', 'approved', 1, '2025-08-06 10:00:00', NULL, NULL, '2025-08-05 09:00:00'),
('EXP-2025-024', 'EMP024', '2025-08-15', 6, 2500.00, 'Digital marketing certification', 'approved', 1, '2025-08-16 09:00:00', NULL, NULL, '2025-08-15 08:00:00'),
('EXP-2025-025', 'EMP025', '2025-08-25', 2, 4500.00, 'Client onboarding meeting in Iloilo', 'approved', 1, '2025-08-26 14:00:00', NULL, NULL, '2025-08-25 08:00:00'),
('EXP-2025-026', 'EMP001', '2025-09-05', 3, 2200.00, 'HR team building dinner', 'approved', 1, '2025-09-06 12:00:00', NULL, NULL, '2025-09-05 18:00:00'),
('EXP-2025-027', 'EMP002', '2025-09-15', 2, 8500.00, 'CFO summit conference - BGC', 'approved', 1, '2025-09-16 10:00:00', NULL, NULL, '2025-09-15 08:00:00'),
('EXP-2025-028', 'EMP003', '2025-10-01', 7, 15000.00, 'Developer workstation monitors', 'approved', 1, '2025-10-02 10:00:00', NULL, NULL, '2025-10-01 09:00:00'),
('EXP-2025-029', 'EMP004', '2025-10-10', 3, 3200.00, 'Marketing awards ceremony dinner', 'approved', 1, '2025-10-11 11:00:00', NULL, NULL, '2025-10-10 18:00:00'),
('EXP-2025-030', 'EMP005', '2025-10-20', 5, 8500.00, 'Office rent payment - November advance', 'approved', 1, '2025-10-21 09:00:00', NULL, NULL, '2025-10-20 09:00:00'),
('EXP-2025-031', 'EMP006', '2025-11-05', 4, 1500.00, 'Mobile plan reimbursement Q3', 'approved', 1, '2025-11-06 09:00:00', NULL, NULL, '2025-11-05 10:00:00'),
('EXP-2025-032', 'EMP007', '2025-11-15', 2, 7200.00, 'National sales convention in Clark', 'approved', 1, '2025-11-16 14:00:00', NULL, NULL, '2025-11-15 07:00:00'),
('EXP-2025-033', 'EMP008', '2025-11-25', 1, 2400.00, 'Accounting reference books and journals', 'approved', 1, '2025-11-26 10:00:00', NULL, NULL, '2025-11-25 10:00:00'),
('EXP-2025-034', 'EMP009', '2025-12-02', 6, 5800.00, 'Cloud architecture certification', 'approved', 1, '2025-12-03 09:00:00', NULL, NULL, '2025-12-02 09:00:00'),
('EXP-2025-035', 'EMP010', '2025-12-12', 3, 4500.00, 'Year-end client appreciation dinner', 'approved', 1, '2025-12-13 12:00:00', NULL, NULL, '2025-12-12 18:00:00'),
('EXP-2025-036', 'EMP011', '2025-12-18', 7, 8200.00, 'Additional RAM and SSD upgrades', 'submitted', NULL, NULL, NULL, NULL, '2025-12-18 14:00:00'),
('EXP-2025-037', 'EMP012', '2025-12-22', 1, 1800.00, 'Year-end filing supplies', 'approved', 1, '2025-12-23 09:00:00', NULL, NULL, '2025-12-22 09:00:00'),

-- 2026 Q1 Expense Claims (January - March)
('EXP-2026-001', 'EMP001', '2026-01-05', 1, 4500.00, 'New year office supplies bulk order', 'approved', 1, '2026-01-06 09:00:00', NULL, NULL, '2026-01-05 09:00:00'),
('EXP-2026-002', 'EMP002', '2026-01-10', 2, 6800.00, 'Annual planning retreat in Tagaytay', 'approved', 1, '2026-01-11 14:00:00', NULL, NULL, '2026-01-10 08:00:00'),
('EXP-2026-003', 'EMP003', '2026-01-18', 7, 42000.00, 'Annual cloud hosting renewal - AWS', 'approved', 1, '2026-01-19 10:00:00', NULL, NULL, '2026-01-18 09:00:00'),
('EXP-2026-004', 'EMP004', '2026-01-22', 3, 3200.00, 'Q1 marketing kickoff dinner', 'approved', 1, '2026-01-23 12:00:00', NULL, NULL, '2026-01-22 18:00:00'),
('EXP-2026-005', 'EMP005', '2026-01-28', 5, 8500.00, 'Office rent payment - February', 'approved', 1, '2026-01-29 09:00:00', NULL, NULL, '2026-01-28 09:00:00'),
('EXP-2026-006', 'EMP006', '2026-02-03', 6, 3800.00, 'Customer experience workshop', 'approved', 1, '2026-02-04 09:00:00', NULL, NULL, '2026-02-03 09:00:00'),
('EXP-2026-007', 'EMP007', '2026-02-10', 2, 5600.00, 'Regional sales meeting in Cebu', 'approved', 1, '2026-02-11 14:00:00', NULL, NULL, '2026-02-10 07:00:00'),
('EXP-2026-008', 'EMP008', '2026-02-18', 1, 1500.00, 'Tax filing forms and supplies', 'approved', 1, '2026-02-19 09:00:00', NULL, NULL, '2026-02-18 10:00:00'),
('EXP-2026-009', 'EMP009', '2026-02-25', 7, 12000.00, 'Development laptop - MacBook Pro', 'submitted', NULL, NULL, NULL, NULL, '2026-02-25 14:00:00'),
('EXP-2026-010', 'EMP010', '2026-03-02', 3, 1800.00, 'Team lunch for project milestone', 'approved', 1, '2026-03-03 12:00:00', NULL, NULL, '2026-03-02 12:00:00'),
('EXP-2026-011', 'EMP013', '2026-03-05', 2, 3500.00, 'Client visit to Zamboanga', 'approved', 1, '2026-03-06 14:00:00', NULL, NULL, '2026-03-05 08:00:00'),
('EXP-2026-012', 'EMP015', '2026-03-10', 5, 8500.00, 'Warehouse maintenance and repairs', 'approved', 1, '2026-03-11 10:00:00', NULL, NULL, '2026-03-10 09:00:00'),
('EXP-2026-013', 'EMP018', '2026-03-15', 1, 2200.00, 'Payroll system upgrade supplies', 'pending', NULL, NULL, NULL, NULL, '2026-03-15 10:00:00'),
('EXP-2026-014', 'EMP021', '2026-03-18', 7, 9500.00, 'Warehouse barcode scanners', 'submitted', NULL, NULL, NULL, NULL, '2026-03-18 09:00:00'),
('EXP-2026-015', 'EMP023', '2026-03-22', 6, 4800.00, 'Cybersecurity certification training', 'pending', NULL, NULL, NULL, NULL, '2026-03-22 10:00:00'),
('EXP-2026-016', 'EMP025', '2026-03-25', 2, 4200.00, 'Quarterly client roadshow travel', 'draft', NULL, NULL, NULL, NULL, '2026-03-25 08:00:00')
ON DUPLICATE KEY UPDATE amount = VALUES(amount);

-- ========================================
-- 13. COMPREHENSIVE PAYMENTS DATA
-- ========================================

INSERT IGNORE INTO payments (payment_no, payment_date, payment_type, from_bank_account_id, payee_name, amount, reference_no, memo, status, journal_entry_id, created_by, created_at) VALUES
-- January 2024 Salary Payments
('PAY001', '2024-01-31', 'bank_transfer', 2, 'Juan Carlos Santos', 20500.00, 'SAL-2024-01-001', 'January salary payment', 'completed', NULL, 1, '2024-01-31 10:00:00'),
('PAY002', '2024-01-31', 'bank_transfer', 2, 'Maria Elena Rodriguez', 23000.00, 'SAL-2024-01-002', 'January salary payment', 'completed', NULL, 1, '2024-01-31 10:00:00'),
('PAY003', '2024-01-31', 'bank_transfer', 2, 'Jose Miguel Cruz', 24500.00, 'SAL-2024-01-003', 'January salary payment', 'completed', NULL, 1, '2024-01-31 10:00:00'),
('PAY004', '2024-01-31', 'bank_transfer', 2, 'Ana Patricia Lopez', 18000.00, 'SAL-2024-01-004', 'January salary payment', 'completed', NULL, 1, '2024-01-31 10:00:00'),
('PAY005', '2024-01-31', 'bank_transfer', 2, 'Roberto Antonio Garcia', 26000.00, 'SAL-2024-01-005', 'January salary payment', 'completed', NULL, 1, '2024-01-31 10:00:00'),

-- February 2024 Salary Payments
('PAY011', '2024-02-29', 'bank_transfer', 2, 'Juan Carlos Santos', 20500.00, 'SAL-2024-02-001', 'February salary payment', 'completed', NULL, 1, '2024-02-29 10:00:00'),
('PAY012', '2024-02-29', 'bank_transfer', 2, 'Maria Elena Rodriguez', 23000.00, 'SAL-2024-02-002', 'February salary payment', 'completed', NULL, 1, '2024-02-29 10:00:00'),
('PAY013', '2024-02-29', 'bank_transfer', 2, 'Jose Miguel Cruz', 24500.00, 'SAL-2024-02-003', 'February salary payment', 'completed', NULL, 1, '2024-02-29 10:00:00'),
('PAY014', '2024-02-29', 'bank_transfer', 2, 'Ana Patricia Lopez', 18000.00, 'SAL-2024-02-004', 'February salary payment', 'completed', NULL, 1, '2024-02-29 10:00:00'),
('PAY015', '2024-02-29', 'bank_transfer', 2, 'Roberto Antonio Garcia', 26000.00, 'SAL-2024-02-005', 'February salary payment', 'completed', NULL, 1, '2024-02-29 10:00:00'),

-- March 2024 Salary Payments
('PAY021', '2024-03-15', 'bank_transfer', 2, 'Juan Carlos Santos', 20500.00, 'SAL-2024-03-001', 'March salary payment', 'completed', NULL, 1, '2024-03-15 10:00:00'),
('PAY022', '2024-03-15', 'bank_transfer', 2, 'Maria Elena Rodriguez', 23000.00, 'SAL-2024-03-002', 'March salary payment', 'completed', NULL, 1, '2024-03-15 10:00:00'),
('PAY023', '2024-03-15', 'bank_transfer', 2, 'Jose Miguel Cruz', 24500.00, 'SAL-2024-03-003', 'March salary payment', 'completed', NULL, 1, '2024-03-15 10:00:00'),
('PAY024', '2024-03-15', 'bank_transfer', 2, 'Ana Patricia Lopez', 18000.00, 'SAL-2024-03-004', 'March salary payment', 'completed', NULL, 1, '2024-03-15 10:00:00'),
('PAY025', '2024-03-15', 'bank_transfer', 2, 'Roberto Antonio Garcia', 26000.00, 'SAL-2024-03-005', 'March salary payment', 'completed', NULL, 1, '2024-03-15 10:00:00'),

-- Expense Payments
('PAY031', '2024-01-15', 'check', 1, 'Office Supplies Inc.', 2500.00, 'CHK-2024-001', 'Office supplies payment', 'completed', NULL, 1, '2024-01-15 14:30:00'),
('PAY032', '2024-02-05', 'bank_transfer', 1, 'Building Management', 2500.00, 'RENT-2024-02', 'Office rent payment', 'completed', NULL, 1, '2024-02-05 08:30:00'),
('PAY033', '2024-02-15', 'bank_transfer', 1, 'Travel Agency', 2000.00, 'TRAVEL-2024-001', 'Sales conference travel', 'completed', NULL, 1, '2024-02-15 11:20:00'),
('PAY034', '2024-03-01', 'bank_transfer', 1, 'Tech Solutions Inc.', 5000.00, 'EQUIP-2024-001', 'Computer equipment', 'pending', NULL, 1, '2024-03-01 09:30:00'),
('PAY035', '2024-01-20', 'bank_transfer', 1, 'Software License Co.', 800.00, 'LIC-2024-001', 'Development tools license', 'completed', NULL, 1, '2024-01-20 10:45:00'),

-- Additional recent payments
('PAY036', '2024-12-01', 'bank_transfer', 1, 'Office Equipment Supplier', 15000.00, 'EQUIP-2024-001', 'New office chairs', 'completed', NULL, 1, '2024-12-01 14:30:00'),
('PAY037', '2024-12-05', 'check', 1, 'Marketing Agency', 30000.00, 'MKT-2024-Q4', 'Q4 marketing campaign', 'completed', NULL, 1, '2024-12-05 11:20:00'),
('PAY038', '2024-12-10', 'bank_transfer', 2, 'Software License Co.', 12000.00, 'LIC-2024-001', 'Annual software licenses', 'completed', NULL, 1, '2024-12-10 10:45:00'),
('PAY039', '2024-12-15', 'cash', NULL, 'Office Maintenance', 5000.00, 'MAINT-2024-001', 'Office cleaning services', 'completed', NULL, 1, '2024-12-15 16:00:00'),
('PAY040', '2024-12-20', 'bank_transfer', 3, 'Insurance Provider', 25000.00, 'INS-2024-Q4', 'Quarterly insurance premium', 'pending', NULL, 1, '2024-12-20 09:30:00'),

-- 2025 Payments
('PAY041', '2025-01-31', 'bank_transfer', 2, 'Juan Carlos Santos', 53300.00, 'SAL-2025-01-001', 'January 2025 salary payment', 'completed', NULL, 1, '2025-01-31 10:00:00'),
('PAY042', '2025-01-31', 'bank_transfer', 2, 'Maria Elena Rodriguez', 164000.00, 'SAL-2025-01-002', 'January 2025 salary payment', 'completed', NULL, 1, '2025-01-31 10:00:00'),
('PAY043', '2025-01-31', 'bank_transfer', 2, 'Jose Miguel Cruz', 180400.00, 'SAL-2025-01-003', 'January 2025 salary payment', 'completed', NULL, 1, '2025-01-31 10:00:00'),
('PAY044', '2025-01-31', 'bank_transfer', 2, 'Ana Patricia Lopez', 98400.00, 'SAL-2025-01-004', 'January 2025 salary payment', 'completed', NULL, 1, '2025-01-31 10:00:00'),
('PAY045', '2025-01-31', 'bank_transfer', 2, 'Roberto Antonio Garcia', 164000.00, 'SAL-2025-01-005', 'January 2025 salary payment', 'completed', NULL, 1, '2025-01-31 10:00:00'),
('PAY046', '2025-02-28', 'bank_transfer', 1, 'Office Equipment Supplier', 18000.00, 'EQUIP-2025-001', 'Server hardware upgrade payment', 'completed', NULL, 1, '2025-02-28 14:30:00'),
('PAY047', '2025-03-15', 'bank_transfer', 1, 'JetBrains s.r.o.', 25000.00, 'LIC-2025-001', 'Annual IDE subscription licenses', 'completed', NULL, 1, '2025-03-15 10:00:00'),
('PAY048', '2025-04-30', 'check', 1, 'Marketing Agency Manila', 45000.00, 'MKT-2025-Q1', 'Q1 2025 marketing campaign', 'completed', NULL, 1, '2025-04-30 11:00:00'),
('PAY049', '2025-06-30', 'bank_transfer', 3, 'Insurance Provider', 25000.00, 'INS-2025-Q2', 'Q2 insurance premium', 'completed', NULL, 1, '2025-06-30 09:30:00'),
('PAY050', '2025-07-15', 'bank_transfer', 1, 'AWS Cloud Services', 42000.00, 'CLOUD-2025-H1', 'H1 2025 cloud hosting fees', 'completed', NULL, 1, '2025-07-15 10:00:00'),
('PAY051', '2025-09-30', 'bank_transfer', 3, 'Insurance Provider', 25000.00, 'INS-2025-Q3', 'Q3 insurance premium', 'completed', NULL, 1, '2025-09-30 09:30:00'),
('PAY052', '2025-10-15', 'bank_transfer', 1, 'Network Equipment Supplier', 32000.00, 'EQUIP-2025-002', 'Network switch and firewall', 'completed', NULL, 1, '2025-10-15 14:00:00'),
('PAY053', '2025-12-20', 'bank_transfer', 3, 'Insurance Provider', 25000.00, 'INS-2025-Q4', 'Q4 insurance premium', 'completed', NULL, 1, '2025-12-20 09:30:00'),

-- 2026 Q1 Payments
('PAY054', '2026-01-31', 'bank_transfer', 2, 'Juan Carlos Santos', 53300.00, 'SAL-2026-01-001', 'January 2026 salary payment', 'completed', NULL, 1, '2026-01-31 10:00:00'),
('PAY055', '2026-01-31', 'bank_transfer', 2, 'Maria Elena Rodriguez', 164000.00, 'SAL-2026-01-002', 'January 2026 salary payment', 'completed', NULL, 1, '2026-01-31 10:00:00'),
('PAY056', '2026-01-31', 'bank_transfer', 2, 'Jose Miguel Cruz', 180400.00, 'SAL-2026-01-003', 'January 2026 salary payment', 'completed', NULL, 1, '2026-01-31 10:00:00'),
('PAY057', '2026-01-20', 'bank_transfer', 1, 'AWS Cloud Services', 42000.00, 'CLOUD-2026-001', 'Annual cloud hosting renewal', 'completed', NULL, 1, '2026-01-20 10:00:00'),
('PAY058', '2026-02-28', 'bank_transfer', 2, 'Juan Carlos Santos', 53300.00, 'SAL-2026-02-001', 'February 2026 salary payment', 'completed', NULL, 1, '2026-02-28 10:00:00'),
('PAY059', '2026-02-28', 'bank_transfer', 2, 'Maria Elena Rodriguez', 164000.00, 'SAL-2026-02-002', 'February 2026 salary payment', 'completed', NULL, 1, '2026-02-28 10:00:00'),
('PAY060', '2026-03-15', 'bank_transfer', 2, 'Ana Patricia Lopez', 98400.00, 'SAL-2026-03-004', 'March 2026 salary payment', 'completed', NULL, 1, '2026-03-15 10:00:00'),
('PAY061', '2026-03-20', 'bank_transfer', 3, 'Insurance Provider', 25000.00, 'INS-2026-Q1', 'Q1 2026 insurance premium', 'completed', NULL, 1, '2026-03-20 09:30:00')
ON DUPLICATE KEY UPDATE amount = VALUES(amount);

-- ========================================
-- 14. PAYROLL DATA
-- ========================================

-- Payroll Periods
INSERT IGNORE INTO payroll_periods (period_start, period_end, frequency, status, created_at) VALUES
('2024-01-01', '2024-01-31', 'monthly', 'paid', '2024-01-01 00:00:00'),
('2024-02-01', '2024-02-29', 'monthly', 'paid', '2024-02-01 00:00:00'),
('2024-03-01', '2024-03-31', 'monthly', 'paid', '2024-03-01 00:00:00'),
('2024-04-01', '2024-04-30', 'monthly', 'paid', '2024-04-01 00:00:00'),
('2024-05-01', '2024-05-31', 'monthly', 'paid', '2024-05-01 00:00:00'),
('2024-06-01', '2024-06-30', 'monthly', 'paid', '2024-06-01 00:00:00'),
('2024-07-01', '2024-07-31', 'monthly', 'paid', '2024-07-01 00:00:00'),
('2024-08-01', '2024-08-31', 'monthly', 'paid', '2024-08-01 00:00:00'),
('2024-09-01', '2024-09-30', 'monthly', 'paid', '2024-09-01 00:00:00'),
('2024-10-01', '2024-10-31', 'monthly', 'paid', '2024-10-01 00:00:00'),
('2024-11-01', '2024-11-30', 'monthly', 'paid', '2024-11-01 00:00:00'),
('2024-12-01', '2024-12-31', 'monthly', 'paid', '2024-12-01 00:00:00'),
('2025-01-01', '2025-01-31', 'monthly', 'paid', '2025-01-01 00:00:00'),
('2025-02-01', '2025-02-28', 'monthly', 'paid', '2025-02-01 00:00:00'),
('2025-03-01', '2025-03-31', 'monthly', 'paid', '2025-03-01 00:00:00'),
('2025-04-01', '2025-04-30', 'monthly', 'paid', '2025-04-01 00:00:00'),
('2025-05-01', '2025-05-31', 'monthly', 'paid', '2025-05-01 00:00:00'),
('2025-06-01', '2025-06-30', 'monthly', 'paid', '2025-06-01 00:00:00'),
('2025-07-01', '2025-07-31', 'monthly', 'paid', '2025-07-01 00:00:00'),
('2025-08-01', '2025-08-31', 'monthly', 'paid', '2025-08-01 00:00:00'),
('2025-09-01', '2025-09-30', 'monthly', 'paid', '2025-09-01 00:00:00'),
('2025-10-01', '2025-10-31', 'monthly', 'paid', '2025-10-01 00:00:00'),
('2025-11-01', '2025-11-30', 'monthly', 'paid', '2025-11-01 00:00:00'),
('2025-12-01', '2025-12-31', 'monthly', 'paid', '2025-12-01 00:00:00'),
('2026-01-01', '2026-01-31', 'monthly', 'paid', '2026-01-01 00:00:00'),
('2026-02-01', '2026-02-28', 'monthly', 'paid', '2026-02-01 00:00:00'),
('2026-03-01', '2026-03-31', 'monthly', 'processing', '2026-03-01 00:00:00')
ON DUPLICATE KEY UPDATE period_start = VALUES(period_start);

-- Payroll Runs
INSERT IGNORE INTO payroll_runs (payroll_period_id, run_by_user_id, run_at, total_gross, total_deductions, total_net, status, journal_entry_id) VALUES
(1, 1, '2024-01-31 18:00:00', 250000.00, 45000.00, 205000.00, 'completed', NULL),
(2, 1, '2024-02-29 18:00:00', 255000.00, 46000.00, 209000.00, 'completed', NULL),
(3, 1, '2024-03-31 18:00:00', 260000.00, 47000.00, 213000.00, 'completed', NULL),
(4, 1, '2024-04-30 18:00:00', 265000.00, 48000.00, 217000.00, 'completed', NULL),
(5, 1, '2024-05-31 18:00:00', 270000.00, 49000.00, 221000.00, 'completed', NULL),
(6, 1, '2024-06-30 18:00:00', 275000.00, 50000.00, 225000.00, 'completed', NULL),
(7, 1, '2024-07-31 18:00:00', 280000.00, 51000.00, 229000.00, 'completed', NULL),
(8, 1, '2024-08-31 18:00:00', 285000.00, 52000.00, 233000.00, 'completed', NULL),
(9, 1, '2024-09-30 18:00:00', 290000.00, 53000.00, 237000.00, 'completed', NULL),
(10, 1, '2024-10-31 18:00:00', 295000.00, 54000.00, 241000.00, 'completed', NULL),
(11, 1, '2024-11-30 18:00:00', 300000.00, 55000.00, 245000.00, 'completed', NULL),
(12, 1, '2024-12-31 18:00:00', 305000.00, 56000.00, 249000.00, 'completed', NULL),
-- 2025 Payroll Runs (monthly, all 25 employees)
(13, 1, '2025-01-31 18:00:00', 1615000.00, 290700.00, 1324300.00, 'completed', NULL),
(14, 1, '2025-02-28 18:00:00', 1615000.00, 290700.00, 1324300.00, 'completed', NULL),
(15, 1, '2025-03-31 18:00:00', 1615000.00, 290700.00, 1324300.00, 'completed', NULL),
(16, 1, '2025-04-30 18:00:00', 1615000.00, 290700.00, 1324300.00, 'completed', NULL),
(17, 1, '2025-05-31 18:00:00', 1615000.00, 290700.00, 1324300.00, 'completed', NULL),
(18, 1, '2025-06-30 18:00:00', 1615000.00, 290700.00, 1324300.00, 'completed', NULL),
(19, 1, '2025-07-31 18:00:00', 1615000.00, 290700.00, 1324300.00, 'completed', NULL),
(20, 1, '2025-08-31 18:00:00', 1615000.00, 290700.00, 1324300.00, 'completed', NULL),
(21, 1, '2025-09-30 18:00:00', 1615000.00, 290700.00, 1324300.00, 'completed', NULL),
(22, 1, '2025-10-31 18:00:00', 1615000.00, 290700.00, 1324300.00, 'completed', NULL),
(23, 1, '2025-11-30 18:00:00', 1615000.00, 290700.00, 1324300.00, 'completed', NULL),
(24, 1, '2025-12-31 18:00:00', 1615000.00, 290700.00, 1324300.00, 'completed', NULL),
-- 2026 Q1 Payroll Runs
(25, 1, '2026-01-31 18:00:00', 1615000.00, 290700.00, 1324300.00, 'completed', NULL),
(26, 1, '2026-02-28 18:00:00', 1615000.00, 290700.00, 1324300.00, 'completed', NULL),
(27, 1, '2026-03-15 10:00:00', 1615000.00, 290700.00, 1324300.00, 'finalized', NULL)
ON DUPLICATE KEY UPDATE total_gross = VALUES(total_gross);

-- Comprehensive Payslips for All 25 Employees
INSERT IGNORE INTO payslips (payroll_run_id, employee_external_no, gross_pay, total_deductions, net_pay, payslip_json) VALUES
-- January 2024 Payslips (Run ID 1)
(1, 'EMP001', 65000.00, 11700.00, 53300.00, '{"basic_salary":65000,"sss":1350,"philhealth":975,"pagibig":200,"tax":9175}'),
(1, 'EMP002', 200000.00, 36000.00, 164000.00, '{"basic_salary":200000,"sss":1350,"philhealth":2500,"pagibig":200,"tax":31950}'),
(1, 'EMP003', 220000.00, 39600.00, 180400.00, '{"basic_salary":220000,"sss":1350,"philhealth":2500,"pagibig":200,"tax":35550}'),
(1, 'EMP004', 120000.00, 21600.00, 98400.00, '{"basic_salary":120000,"sss":1350,"philhealth":1800,"pagibig":200,"tax":18250}'),
(1, 'EMP005', 200000.00, 36000.00, 164000.00, '{"basic_salary":200000,"sss":1350,"philhealth":2500,"pagibig":200,"tax":31950}'),
(1, 'EMP006', 55000.00, 9900.00, 45100.00, '{"basic_salary":55000,"sss":1350,"philhealth":825,"pagibig":200,"tax":7525}'),
(1, 'EMP007', 70000.00, 12600.00, 57400.00, '{"basic_salary":70000,"sss":1350,"philhealth":1050,"pagibig":200,"tax":10000}'),
(1, 'EMP008', 48000.00, 8640.00, 39360.00, '{"basic_salary":48000,"sss":1350,"philhealth":720,"pagibig":200,"tax":6370}'),
(1, 'EMP009', 85000.00, 15300.00, 69700.00, '{"basic_salary":85000,"sss":1350,"philhealth":1275,"pagibig":200,"tax":12475}'),
(1, 'EMP010', 42000.00, 7560.00, 34440.00, '{"basic_salary":42000,"sss":1350,"philhealth":630,"pagibig":200,"tax":5380}'),

-- December 2024 Payslips (Run ID 12) - Year End with 13th Month
(12, 'EMP001', 130000.00, 23400.00, 106600.00, '{"basic_salary":65000,"13th_month":65000,"sss":1350,"philhealth":975,"pagibig":200,"tax":20875}'),
(12, 'EMP002', 400000.00, 72000.00, 328000.00, '{"basic_salary":200000,"13th_month":200000,"sss":1350,"philhealth":2500,"pagibig":200,"tax":67950}'),
(12, 'EMP003', 440000.00, 79200.00, 360800.00, '{"basic_salary":220000,"13th_month":220000,"sss":1350,"philhealth":2500,"pagibig":200,"tax":75150}'),
(12, 'EMP004', 240000.00, 43200.00, 196800.00, '{"basic_salary":120000,"13th_month":120000,"sss":1350,"philhealth":1800,"pagibig":200,"tax":39850}'),
(12, 'EMP005', 400000.00, 72000.00, 328000.00, '{"basic_salary":200000,"13th_month":200000,"sss":1350,"philhealth":2500,"pagibig":200,"tax":67950}'),
(12, 'EMP006', 110000.00, 19800.00, 90200.00, '{"basic_salary":55000,"13th_month":55000,"sss":1350,"philhealth":825,"pagibig":200,"tax":17425}'),
(12, 'EMP007', 140000.00, 25200.00, 114800.00, '{"basic_salary":70000,"13th_month":70000,"sss":1350,"philhealth":1050,"pagibig":200,"tax":22600}'),
(12, 'EMP008', 96000.00, 17280.00, 78720.00, '{"basic_salary":48000,"13th_month":48000,"sss":1350,"philhealth":720,"pagibig":200,"tax":15010}'),
(12, 'EMP009', 170000.00, 30600.00, 139400.00, '{"basic_salary":85000,"13th_month":85000,"sss":1350,"philhealth":1275,"pagibig":200,"tax":27775}'),
(12, 'EMP010', 84000.00, 15120.00, 68880.00, '{"basic_salary":42000,"13th_month":42000,"sss":1350,"philhealth":630,"pagibig":200,"tax":12940}'),

-- January 2025 Payslips (Run ID 13) - All 25 employees
(13, 'EMP001', 65000.00, 11700.00, 53300.00, '{"basic_salary":65000,"sss":1350,"philhealth":975,"pagibig":200,"tax":9175}'),
(13, 'EMP002', 200000.00, 36000.00, 164000.00, '{"basic_salary":200000,"sss":1350,"philhealth":2500,"pagibig":200,"tax":31950}'),
(13, 'EMP003', 220000.00, 39600.00, 180400.00, '{"basic_salary":220000,"sss":1350,"philhealth":2500,"pagibig":200,"tax":35550}'),
(13, 'EMP004', 120000.00, 21600.00, 98400.00, '{"basic_salary":120000,"sss":1350,"philhealth":1800,"pagibig":200,"tax":18250}'),
(13, 'EMP005', 200000.00, 36000.00, 164000.00, '{"basic_salary":200000,"sss":1350,"philhealth":2500,"pagibig":200,"tax":31950}'),
(13, 'EMP006', 55000.00, 9900.00, 45100.00, '{"basic_salary":55000,"sss":1350,"philhealth":825,"pagibig":200,"tax":7525}'),
(13, 'EMP007', 70000.00, 12600.00, 57400.00, '{"basic_salary":70000,"sss":1350,"philhealth":1050,"pagibig":200,"tax":10000}'),
(13, 'EMP008', 48000.00, 8640.00, 39360.00, '{"basic_salary":48000,"sss":1350,"philhealth":720,"pagibig":200,"tax":6370}'),
(13, 'EMP009', 85000.00, 15300.00, 69700.00, '{"basic_salary":85000,"sss":1350,"philhealth":1275,"pagibig":200,"tax":12475}'),
(13, 'EMP010', 42000.00, 7560.00, 34440.00, '{"basic_salary":42000,"sss":1350,"philhealth":630,"pagibig":200,"tax":5380}'),
(13, 'EMP011', 55000.00, 9900.00, 45100.00, '{"basic_salary":55000,"sss":1350,"philhealth":825,"pagibig":200,"tax":7525}'),
(13, 'EMP012', 35000.00, 6300.00, 28700.00, '{"basic_salary":35000,"sss":1350,"philhealth":525,"pagibig":200,"tax":4225}'),
(13, 'EMP013', 40000.00, 7200.00, 32800.00, '{"basic_salary":40000,"sss":1350,"philhealth":600,"pagibig":200,"tax":5050}'),
(13, 'EMP014', 25000.00, 4500.00, 20500.00, '{"basic_salary":25000,"sss":1350,"philhealth":375,"pagibig":200,"tax":2575}'),
(13, 'EMP015', 32000.00, 5760.00, 26240.00, '{"basic_salary":32000,"sss":1350,"philhealth":480,"pagibig":200,"tax":3730}'),
(13, 'EMP016', 28000.00, 5040.00, 22960.00, '{"basic_salary":28000,"sss":1350,"philhealth":420,"pagibig":200,"tax":3070}'),
(13, 'EMP017', 38000.00, 6840.00, 31160.00, '{"basic_salary":38000,"sss":1350,"philhealth":570,"pagibig":200,"tax":4720}'),
(13, 'EMP018', 32000.00, 5760.00, 26240.00, '{"basic_salary":32000,"sss":1350,"philhealth":480,"pagibig":200,"tax":3730}'),
(13, 'EMP019', 30000.00, 5400.00, 24600.00, '{"basic_salary":30000,"sss":1350,"philhealth":450,"pagibig":200,"tax":3400}'),
(13, 'EMP020', 25000.00, 4500.00, 20500.00, '{"basic_salary":25000,"sss":1350,"philhealth":375,"pagibig":200,"tax":2575}'),
(13, 'EMP021', 45000.00, 8100.00, 36900.00, '{"basic_salary":45000,"sss":1350,"philhealth":675,"pagibig":200,"tax":5875}'),
(13, 'EMP022', 28000.00, 5040.00, 22960.00, '{"basic_salary":28000,"sss":1350,"philhealth":420,"pagibig":200,"tax":3070}'),
(13, 'EMP023', 55000.00, 9900.00, 45100.00, '{"basic_salary":55000,"sss":1350,"philhealth":825,"pagibig":200,"tax":7525}'),
(13, 'EMP024', 35000.00, 6300.00, 28700.00, '{"basic_salary":35000,"sss":1350,"philhealth":525,"pagibig":200,"tax":4225}'),
(13, 'EMP025', 50000.00, 9000.00, 41000.00, '{"basic_salary":50000,"sss":1350,"philhealth":750,"pagibig":200,"tax":6700}'),

-- February 2025 Payslips (Run ID 14) - same structure, all 25 employees
(14, 'EMP001', 65000.00, 11700.00, 53300.00, '{"basic_salary":65000,"sss":1350,"philhealth":975,"pagibig":200,"tax":9175}'),
(14, 'EMP002', 200000.00, 36000.00, 164000.00, '{"basic_salary":200000,"sss":1350,"philhealth":2500,"pagibig":200,"tax":31950}'),
(14, 'EMP003', 220000.00, 39600.00, 180400.00, '{"basic_salary":220000,"sss":1350,"philhealth":2500,"pagibig":200,"tax":35550}'),
(14, 'EMP004', 120000.00, 21600.00, 98400.00, '{"basic_salary":120000,"sss":1350,"philhealth":1800,"pagibig":200,"tax":18250}'),
(14, 'EMP005', 200000.00, 36000.00, 164000.00, '{"basic_salary":200000,"sss":1350,"philhealth":2500,"pagibig":200,"tax":31950}'),
(14, 'EMP006', 55000.00, 9900.00, 45100.00, '{"basic_salary":55000,"sss":1350,"philhealth":825,"pagibig":200,"tax":7525}'),
(14, 'EMP007', 70000.00, 12600.00, 57400.00, '{"basic_salary":70000,"sss":1350,"philhealth":1050,"pagibig":200,"tax":10000}'),
(14, 'EMP008', 48000.00, 8640.00, 39360.00, '{"basic_salary":48000,"sss":1350,"philhealth":720,"pagibig":200,"tax":6370}'),
(14, 'EMP009', 85000.00, 15300.00, 69700.00, '{"basic_salary":85000,"sss":1350,"philhealth":1275,"pagibig":200,"tax":12475}'),
(14, 'EMP010', 42000.00, 7560.00, 34440.00, '{"basic_salary":42000,"sss":1350,"philhealth":630,"pagibig":200,"tax":5380}'),
(14, 'EMP011', 55000.00, 9900.00, 45100.00, '{"basic_salary":55000,"sss":1350,"philhealth":825,"pagibig":200,"tax":7525}'),
(14, 'EMP012', 35000.00, 6300.00, 28700.00, '{"basic_salary":35000,"sss":1350,"philhealth":525,"pagibig":200,"tax":4225}'),
(14, 'EMP013', 40000.00, 7200.00, 32800.00, '{"basic_salary":40000,"sss":1350,"philhealth":600,"pagibig":200,"tax":5050}'),
(14, 'EMP014', 25000.00, 4500.00, 20500.00, '{"basic_salary":25000,"sss":1350,"philhealth":375,"pagibig":200,"tax":2575}'),
(14, 'EMP015', 32000.00, 5760.00, 26240.00, '{"basic_salary":32000,"sss":1350,"philhealth":480,"pagibig":200,"tax":3730}'),
(14, 'EMP016', 28000.00, 5040.00, 22960.00, '{"basic_salary":28000,"sss":1350,"philhealth":420,"pagibig":200,"tax":3070}'),
(14, 'EMP017', 38000.00, 6840.00, 31160.00, '{"basic_salary":38000,"sss":1350,"philhealth":570,"pagibig":200,"tax":4720}'),
(14, 'EMP018', 32000.00, 5760.00, 26240.00, '{"basic_salary":32000,"sss":1350,"philhealth":480,"pagibig":200,"tax":3730}'),
(14, 'EMP019', 30000.00, 5400.00, 24600.00, '{"basic_salary":30000,"sss":1350,"philhealth":450,"pagibig":200,"tax":3400}'),
(14, 'EMP020', 25000.00, 4500.00, 20500.00, '{"basic_salary":25000,"sss":1350,"philhealth":375,"pagibig":200,"tax":2575}'),
(14, 'EMP021', 45000.00, 8100.00, 36900.00, '{"basic_salary":45000,"sss":1350,"philhealth":675,"pagibig":200,"tax":5875}'),
(14, 'EMP022', 28000.00, 5040.00, 22960.00, '{"basic_salary":28000,"sss":1350,"philhealth":420,"pagibig":200,"tax":3070}'),
(14, 'EMP023', 55000.00, 9900.00, 45100.00, '{"basic_salary":55000,"sss":1350,"philhealth":825,"pagibig":200,"tax":7525}'),
(14, 'EMP024', 35000.00, 6300.00, 28700.00, '{"basic_salary":35000,"sss":1350,"philhealth":525,"pagibig":200,"tax":4225}'),
(14, 'EMP025', 50000.00, 9000.00, 41000.00, '{"basic_salary":50000,"sss":1350,"philhealth":750,"pagibig":200,"tax":6700}'),

-- March through December 2025 (Run IDs 15-24) - use representative runs for key months
-- March 2025 (Run ID 15)
(15, 'EMP001', 65000.00, 11700.00, 53300.00, '{"basic_salary":65000,"sss":1350,"philhealth":975,"pagibig":200,"tax":9175}'),
(15, 'EMP002', 200000.00, 36000.00, 164000.00, '{"basic_salary":200000,"sss":1350,"philhealth":2500,"pagibig":200,"tax":31950}'),
(15, 'EMP003', 220000.00, 39600.00, 180400.00, '{"basic_salary":220000,"sss":1350,"philhealth":2500,"pagibig":200,"tax":35550}'),
(15, 'EMP004', 120000.00, 21600.00, 98400.00, '{"basic_salary":120000,"sss":1350,"philhealth":1800,"pagibig":200,"tax":18250}'),
(15, 'EMP005', 200000.00, 36000.00, 164000.00, '{"basic_salary":200000,"sss":1350,"philhealth":2500,"pagibig":200,"tax":31950}'),
(15, 'EMP006', 55000.00, 9900.00, 45100.00, '{"basic_salary":55000,"sss":1350,"philhealth":825,"pagibig":200,"tax":7525}'),
(15, 'EMP007', 70000.00, 12600.00, 57400.00, '{"basic_salary":70000,"sss":1350,"philhealth":1050,"pagibig":200,"tax":10000}'),
(15, 'EMP008', 48000.00, 8640.00, 39360.00, '{"basic_salary":48000,"sss":1350,"philhealth":720,"pagibig":200,"tax":6370}'),
(15, 'EMP009', 85000.00, 15300.00, 69700.00, '{"basic_salary":85000,"sss":1350,"philhealth":1275,"pagibig":200,"tax":12475}'),
(15, 'EMP010', 42000.00, 7560.00, 34440.00, '{"basic_salary":42000,"sss":1350,"philhealth":630,"pagibig":200,"tax":5380}'),
(15, 'EMP011', 55000.00, 9900.00, 45100.00, '{"basic_salary":55000,"sss":1350,"philhealth":825,"pagibig":200,"tax":7525}'),
(15, 'EMP012', 35000.00, 6300.00, 28700.00, '{"basic_salary":35000,"sss":1350,"philhealth":525,"pagibig":200,"tax":4225}'),
(15, 'EMP013', 40000.00, 7200.00, 32800.00, '{"basic_salary":40000,"sss":1350,"philhealth":600,"pagibig":200,"tax":5050}'),
(15, 'EMP014', 25000.00, 4500.00, 20500.00, '{"basic_salary":25000,"sss":1350,"philhealth":375,"pagibig":200,"tax":2575}'),
(15, 'EMP015', 32000.00, 5760.00, 26240.00, '{"basic_salary":32000,"sss":1350,"philhealth":480,"pagibig":200,"tax":3730}'),
(15, 'EMP016', 28000.00, 5040.00, 22960.00, '{"basic_salary":28000,"sss":1350,"philhealth":420,"pagibig":200,"tax":3070}'),
(15, 'EMP017', 38000.00, 6840.00, 31160.00, '{"basic_salary":38000,"sss":1350,"philhealth":570,"pagibig":200,"tax":4720}'),
(15, 'EMP018', 32000.00, 5760.00, 26240.00, '{"basic_salary":32000,"sss":1350,"philhealth":480,"pagibig":200,"tax":3730}'),
(15, 'EMP019', 30000.00, 5400.00, 24600.00, '{"basic_salary":30000,"sss":1350,"philhealth":450,"pagibig":200,"tax":3400}'),
(15, 'EMP020', 25000.00, 4500.00, 20500.00, '{"basic_salary":25000,"sss":1350,"philhealth":375,"pagibig":200,"tax":2575}'),
(15, 'EMP021', 45000.00, 8100.00, 36900.00, '{"basic_salary":45000,"sss":1350,"philhealth":675,"pagibig":200,"tax":5875}'),
(15, 'EMP022', 28000.00, 5040.00, 22960.00, '{"basic_salary":28000,"sss":1350,"philhealth":420,"pagibig":200,"tax":3070}'),
(15, 'EMP023', 55000.00, 9900.00, 45100.00, '{"basic_salary":55000,"sss":1350,"philhealth":825,"pagibig":200,"tax":7525}'),
(15, 'EMP024', 35000.00, 6300.00, 28700.00, '{"basic_salary":35000,"sss":1350,"philhealth":525,"pagibig":200,"tax":4225}'),
(15, 'EMP025', 50000.00, 9000.00, 41000.00, '{"basic_salary":50000,"sss":1350,"philhealth":750,"pagibig":200,"tax":6700}'),

-- December 2025 (Run ID 24) - Year End with 13th Month
(24, 'EMP001', 130000.00, 23400.00, 106600.00, '{"basic_salary":65000,"13th_month":65000,"sss":1350,"philhealth":975,"pagibig":200,"tax":20875}'),
(24, 'EMP002', 400000.00, 72000.00, 328000.00, '{"basic_salary":200000,"13th_month":200000,"sss":1350,"philhealth":2500,"pagibig":200,"tax":67950}'),
(24, 'EMP003', 440000.00, 79200.00, 360800.00, '{"basic_salary":220000,"13th_month":220000,"sss":1350,"philhealth":2500,"pagibig":200,"tax":75150}'),
(24, 'EMP004', 240000.00, 43200.00, 196800.00, '{"basic_salary":120000,"13th_month":120000,"sss":1350,"philhealth":1800,"pagibig":200,"tax":39850}'),
(24, 'EMP005', 400000.00, 72000.00, 328000.00, '{"basic_salary":200000,"13th_month":200000,"sss":1350,"philhealth":2500,"pagibig":200,"tax":67950}'),
(24, 'EMP006', 110000.00, 19800.00, 90200.00, '{"basic_salary":55000,"13th_month":55000,"sss":1350,"philhealth":825,"pagibig":200,"tax":17425}'),
(24, 'EMP007', 140000.00, 25200.00, 114800.00, '{"basic_salary":70000,"13th_month":70000,"sss":1350,"philhealth":1050,"pagibig":200,"tax":22600}'),
(24, 'EMP008', 96000.00, 17280.00, 78720.00, '{"basic_salary":48000,"13th_month":48000,"sss":1350,"philhealth":720,"pagibig":200,"tax":15010}'),
(24, 'EMP009', 170000.00, 30600.00, 139400.00, '{"basic_salary":85000,"13th_month":85000,"sss":1350,"philhealth":1275,"pagibig":200,"tax":27775}'),
(24, 'EMP010', 84000.00, 15120.00, 68880.00, '{"basic_salary":42000,"13th_month":42000,"sss":1350,"philhealth":630,"pagibig":200,"tax":12940}'),
(24, 'EMP011', 110000.00, 19800.00, 90200.00, '{"basic_salary":55000,"13th_month":55000,"sss":1350,"philhealth":825,"pagibig":200,"tax":17425}'),
(24, 'EMP012', 70000.00, 12600.00, 57400.00, '{"basic_salary":35000,"13th_month":35000,"sss":1350,"philhealth":525,"pagibig":200,"tax":10525}'),
(24, 'EMP013', 80000.00, 14400.00, 65600.00, '{"basic_salary":40000,"13th_month":40000,"sss":1350,"philhealth":600,"pagibig":200,"tax":12250}'),
(24, 'EMP014', 50000.00, 9000.00, 41000.00, '{"basic_salary":25000,"13th_month":25000,"sss":1350,"philhealth":375,"pagibig":200,"tax":7075}'),
(24, 'EMP015', 64000.00, 11520.00, 52480.00, '{"basic_salary":32000,"13th_month":32000,"sss":1350,"philhealth":480,"pagibig":200,"tax":9490}'),
(24, 'EMP016', 56000.00, 10080.00, 45920.00, '{"basic_salary":28000,"13th_month":28000,"sss":1350,"philhealth":420,"pagibig":200,"tax":8110}'),
(24, 'EMP017', 76000.00, 13680.00, 62320.00, '{"basic_salary":38000,"13th_month":38000,"sss":1350,"philhealth":570,"pagibig":200,"tax":11560}'),
(24, 'EMP018', 64000.00, 11520.00, 52480.00, '{"basic_salary":32000,"13th_month":32000,"sss":1350,"philhealth":480,"pagibig":200,"tax":9490}'),
(24, 'EMP019', 60000.00, 10800.00, 49200.00, '{"basic_salary":30000,"13th_month":30000,"sss":1350,"philhealth":450,"pagibig":200,"tax":8800}'),
(24, 'EMP020', 50000.00, 9000.00, 41000.00, '{"basic_salary":25000,"13th_month":25000,"sss":1350,"philhealth":375,"pagibig":200,"tax":7075}'),
(24, 'EMP021', 90000.00, 16200.00, 73800.00, '{"basic_salary":45000,"13th_month":45000,"sss":1350,"philhealth":675,"pagibig":200,"tax":13975}'),
(24, 'EMP022', 56000.00, 10080.00, 45920.00, '{"basic_salary":28000,"13th_month":28000,"sss":1350,"philhealth":420,"pagibig":200,"tax":8110}'),
(24, 'EMP023', 110000.00, 19800.00, 90200.00, '{"basic_salary":55000,"13th_month":55000,"sss":1350,"philhealth":825,"pagibig":200,"tax":17425}'),
(24, 'EMP024', 70000.00, 12600.00, 57400.00, '{"basic_salary":35000,"13th_month":35000,"sss":1350,"philhealth":525,"pagibig":200,"tax":10525}'),
(24, 'EMP025', 100000.00, 18000.00, 82000.00, '{"basic_salary":50000,"13th_month":50000,"sss":1350,"philhealth":750,"pagibig":200,"tax":15700}'),

-- January 2026 Payslips (Run ID 25) - All 25 employees
(25, 'EMP001', 65000.00, 11700.00, 53300.00, '{"basic_salary":65000,"sss":1350,"philhealth":975,"pagibig":200,"tax":9175}'),
(25, 'EMP002', 200000.00, 36000.00, 164000.00, '{"basic_salary":200000,"sss":1350,"philhealth":2500,"pagibig":200,"tax":31950}'),
(25, 'EMP003', 220000.00, 39600.00, 180400.00, '{"basic_salary":220000,"sss":1350,"philhealth":2500,"pagibig":200,"tax":35550}'),
(25, 'EMP004', 120000.00, 21600.00, 98400.00, '{"basic_salary":120000,"sss":1350,"philhealth":1800,"pagibig":200,"tax":18250}'),
(25, 'EMP005', 200000.00, 36000.00, 164000.00, '{"basic_salary":200000,"sss":1350,"philhealth":2500,"pagibig":200,"tax":31950}'),
(25, 'EMP006', 55000.00, 9900.00, 45100.00, '{"basic_salary":55000,"sss":1350,"philhealth":825,"pagibig":200,"tax":7525}'),
(25, 'EMP007', 70000.00, 12600.00, 57400.00, '{"basic_salary":70000,"sss":1350,"philhealth":1050,"pagibig":200,"tax":10000}'),
(25, 'EMP008', 48000.00, 8640.00, 39360.00, '{"basic_salary":48000,"sss":1350,"philhealth":720,"pagibig":200,"tax":6370}'),
(25, 'EMP009', 85000.00, 15300.00, 69700.00, '{"basic_salary":85000,"sss":1350,"philhealth":1275,"pagibig":200,"tax":12475}'),
(25, 'EMP010', 42000.00, 7560.00, 34440.00, '{"basic_salary":42000,"sss":1350,"philhealth":630,"pagibig":200,"tax":5380}'),
(25, 'EMP011', 55000.00, 9900.00, 45100.00, '{"basic_salary":55000,"sss":1350,"philhealth":825,"pagibig":200,"tax":7525}'),
(25, 'EMP012', 35000.00, 6300.00, 28700.00, '{"basic_salary":35000,"sss":1350,"philhealth":525,"pagibig":200,"tax":4225}'),
(25, 'EMP013', 40000.00, 7200.00, 32800.00, '{"basic_salary":40000,"sss":1350,"philhealth":600,"pagibig":200,"tax":5050}'),
(25, 'EMP014', 25000.00, 4500.00, 20500.00, '{"basic_salary":25000,"sss":1350,"philhealth":375,"pagibig":200,"tax":2575}'),
(25, 'EMP015', 32000.00, 5760.00, 26240.00, '{"basic_salary":32000,"sss":1350,"philhealth":480,"pagibig":200,"tax":3730}'),
(25, 'EMP016', 28000.00, 5040.00, 22960.00, '{"basic_salary":28000,"sss":1350,"philhealth":420,"pagibig":200,"tax":3070}'),
(25, 'EMP017', 38000.00, 6840.00, 31160.00, '{"basic_salary":38000,"sss":1350,"philhealth":570,"pagibig":200,"tax":4720}'),
(25, 'EMP018', 32000.00, 5760.00, 26240.00, '{"basic_salary":32000,"sss":1350,"philhealth":480,"pagibig":200,"tax":3730}'),
(25, 'EMP019', 30000.00, 5400.00, 24600.00, '{"basic_salary":30000,"sss":1350,"philhealth":450,"pagibig":200,"tax":3400}'),
(25, 'EMP020', 25000.00, 4500.00, 20500.00, '{"basic_salary":25000,"sss":1350,"philhealth":375,"pagibig":200,"tax":2575}'),
(25, 'EMP021', 45000.00, 8100.00, 36900.00, '{"basic_salary":45000,"sss":1350,"philhealth":675,"pagibig":200,"tax":5875}'),
(25, 'EMP022', 28000.00, 5040.00, 22960.00, '{"basic_salary":28000,"sss":1350,"philhealth":420,"pagibig":200,"tax":3070}'),
(25, 'EMP023', 55000.00, 9900.00, 45100.00, '{"basic_salary":55000,"sss":1350,"philhealth":825,"pagibig":200,"tax":7525}'),
(25, 'EMP024', 35000.00, 6300.00, 28700.00, '{"basic_salary":35000,"sss":1350,"philhealth":525,"pagibig":200,"tax":4225}'),
(25, 'EMP025', 50000.00, 9000.00, 41000.00, '{"basic_salary":50000,"sss":1350,"philhealth":750,"pagibig":200,"tax":6700}'),

-- February 2026 Payslips (Run ID 26)
(26, 'EMP001', 65000.00, 11700.00, 53300.00, '{"basic_salary":65000,"sss":1350,"philhealth":975,"pagibig":200,"tax":9175}'),
(26, 'EMP002', 200000.00, 36000.00, 164000.00, '{"basic_salary":200000,"sss":1350,"philhealth":2500,"pagibig":200,"tax":31950}'),
(26, 'EMP003', 220000.00, 39600.00, 180400.00, '{"basic_salary":220000,"sss":1350,"philhealth":2500,"pagibig":200,"tax":35550}'),
(26, 'EMP004', 120000.00, 21600.00, 98400.00, '{"basic_salary":120000,"sss":1350,"philhealth":1800,"pagibig":200,"tax":18250}'),
(26, 'EMP005', 200000.00, 36000.00, 164000.00, '{"basic_salary":200000,"sss":1350,"philhealth":2500,"pagibig":200,"tax":31950}'),
(26, 'EMP006', 55000.00, 9900.00, 45100.00, '{"basic_salary":55000,"sss":1350,"philhealth":825,"pagibig":200,"tax":7525}'),
(26, 'EMP007', 70000.00, 12600.00, 57400.00, '{"basic_salary":70000,"sss":1350,"philhealth":1050,"pagibig":200,"tax":10000}'),
(26, 'EMP008', 48000.00, 8640.00, 39360.00, '{"basic_salary":48000,"sss":1350,"philhealth":720,"pagibig":200,"tax":6370}'),
(26, 'EMP009', 85000.00, 15300.00, 69700.00, '{"basic_salary":85000,"sss":1350,"philhealth":1275,"pagibig":200,"tax":12475}'),
(26, 'EMP010', 42000.00, 7560.00, 34440.00, '{"basic_salary":42000,"sss":1350,"philhealth":630,"pagibig":200,"tax":5380}'),
(26, 'EMP011', 55000.00, 9900.00, 45100.00, '{"basic_salary":55000,"sss":1350,"philhealth":825,"pagibig":200,"tax":7525}'),
(26, 'EMP012', 35000.00, 6300.00, 28700.00, '{"basic_salary":35000,"sss":1350,"philhealth":525,"pagibig":200,"tax":4225}'),
(26, 'EMP013', 40000.00, 7200.00, 32800.00, '{"basic_salary":40000,"sss":1350,"philhealth":600,"pagibig":200,"tax":5050}'),
(26, 'EMP014', 25000.00, 4500.00, 20500.00, '{"basic_salary":25000,"sss":1350,"philhealth":375,"pagibig":200,"tax":2575}'),
(26, 'EMP015', 32000.00, 5760.00, 26240.00, '{"basic_salary":32000,"sss":1350,"philhealth":480,"pagibig":200,"tax":3730}'),
(26, 'EMP016', 28000.00, 5040.00, 22960.00, '{"basic_salary":28000,"sss":1350,"philhealth":420,"pagibig":200,"tax":3070}'),
(26, 'EMP017', 38000.00, 6840.00, 31160.00, '{"basic_salary":38000,"sss":1350,"philhealth":570,"pagibig":200,"tax":4720}'),
(26, 'EMP018', 32000.00, 5760.00, 26240.00, '{"basic_salary":32000,"sss":1350,"philhealth":480,"pagibig":200,"tax":3730}'),
(26, 'EMP019', 30000.00, 5400.00, 24600.00, '{"basic_salary":30000,"sss":1350,"philhealth":450,"pagibig":200,"tax":3400}'),
(26, 'EMP020', 25000.00, 4500.00, 20500.00, '{"basic_salary":25000,"sss":1350,"philhealth":375,"pagibig":200,"tax":2575}'),
(26, 'EMP021', 45000.00, 8100.00, 36900.00, '{"basic_salary":45000,"sss":1350,"philhealth":675,"pagibig":200,"tax":5875}'),
(26, 'EMP022', 28000.00, 5040.00, 22960.00, '{"basic_salary":28000,"sss":1350,"philhealth":420,"pagibig":200,"tax":3070}'),
(26, 'EMP023', 55000.00, 9900.00, 45100.00, '{"basic_salary":55000,"sss":1350,"philhealth":825,"pagibig":200,"tax":7525}'),
(26, 'EMP024', 35000.00, 6300.00, 28700.00, '{"basic_salary":35000,"sss":1350,"philhealth":525,"pagibig":200,"tax":4225}'),
(26, 'EMP025', 50000.00, 9000.00, 41000.00, '{"basic_salary":50000,"sss":1350,"philhealth":750,"pagibig":200,"tax":6700}'),

-- March 2026 Payslips (Run ID 27) - Current Period
(27, 'EMP001', 65000.00, 11700.00, 53300.00, '{"basic_salary":65000,"sss":1350,"philhealth":975,"pagibig":200,"tax":9175}'),
(27, 'EMP002', 200000.00, 36000.00, 164000.00, '{"basic_salary":200000,"sss":1350,"philhealth":2500,"pagibig":200,"tax":31950}'),
(27, 'EMP003', 220000.00, 39600.00, 180400.00, '{"basic_salary":220000,"sss":1350,"philhealth":2500,"pagibig":200,"tax":35550}'),
(27, 'EMP004', 120000.00, 21600.00, 98400.00, '{"basic_salary":120000,"sss":1350,"philhealth":1800,"pagibig":200,"tax":18250}'),
(27, 'EMP005', 200000.00, 36000.00, 164000.00, '{"basic_salary":200000,"sss":1350,"philhealth":2500,"pagibig":200,"tax":31950}'),
(27, 'EMP006', 55000.00, 9900.00, 45100.00, '{"basic_salary":55000,"sss":1350,"philhealth":825,"pagibig":200,"tax":7525}'),
(27, 'EMP007', 70000.00, 12600.00, 57400.00, '{"basic_salary":70000,"sss":1350,"philhealth":1050,"pagibig":200,"tax":10000}'),
(27, 'EMP008', 48000.00, 8640.00, 39360.00, '{"basic_salary":48000,"sss":1350,"philhealth":720,"pagibig":200,"tax":6370}'),
(27, 'EMP009', 85000.00, 15300.00, 69700.00, '{"basic_salary":85000,"sss":1350,"philhealth":1275,"pagibig":200,"tax":12475}'),
(27, 'EMP010', 42000.00, 7560.00, 34440.00, '{"basic_salary":42000,"sss":1350,"philhealth":630,"pagibig":200,"tax":5380}'),
(27, 'EMP011', 55000.00, 9900.00, 45100.00, '{"basic_salary":55000,"sss":1350,"philhealth":825,"pagibig":200,"tax":7525}'),
(27, 'EMP012', 35000.00, 6300.00, 28700.00, '{"basic_salary":35000,"sss":1350,"philhealth":525,"pagibig":200,"tax":4225}'),
(27, 'EMP013', 40000.00, 7200.00, 32800.00, '{"basic_salary":40000,"sss":1350,"philhealth":600,"pagibig":200,"tax":5050}'),
(27, 'EMP014', 25000.00, 4500.00, 20500.00, '{"basic_salary":25000,"sss":1350,"philhealth":375,"pagibig":200,"tax":2575}'),
(27, 'EMP015', 32000.00, 5760.00, 26240.00, '{"basic_salary":32000,"sss":1350,"philhealth":480,"pagibig":200,"tax":3730}'),
(27, 'EMP016', 28000.00, 5040.00, 22960.00, '{"basic_salary":28000,"sss":1350,"philhealth":420,"pagibig":200,"tax":3070}'),
(27, 'EMP017', 38000.00, 6840.00, 31160.00, '{"basic_salary":38000,"sss":1350,"philhealth":570,"pagibig":200,"tax":4720}'),
(27, 'EMP018', 32000.00, 5760.00, 26240.00, '{"basic_salary":32000,"sss":1350,"philhealth":480,"pagibig":200,"tax":3730}'),
(27, 'EMP019', 30000.00, 5400.00, 24600.00, '{"basic_salary":30000,"sss":1350,"philhealth":450,"pagibig":200,"tax":3400}'),
(27, 'EMP020', 25000.00, 4500.00, 20500.00, '{"basic_salary":25000,"sss":1350,"philhealth":375,"pagibig":200,"tax":2575}'),
(27, 'EMP021', 45000.00, 8100.00, 36900.00, '{"basic_salary":45000,"sss":1350,"philhealth":675,"pagibig":200,"tax":5875}'),
(27, 'EMP022', 28000.00, 5040.00, 22960.00, '{"basic_salary":28000,"sss":1350,"philhealth":420,"pagibig":200,"tax":3070}'),
(27, 'EMP023', 55000.00, 9900.00, 45100.00, '{"basic_salary":55000,"sss":1350,"philhealth":825,"pagibig":200,"tax":7525}'),
(27, 'EMP024', 35000.00, 6300.00, 28700.00, '{"basic_salary":35000,"sss":1350,"philhealth":525,"pagibig":200,"tax":4225}'),
(27, 'EMP025', 50000.00, 9000.00, 41000.00, '{"basic_salary":50000,"sss":1350,"philhealth":750,"pagibig":200,"tax":6700}')
ON DUPLICATE KEY UPDATE gross_pay = VALUES(gross_pay);

-- ========================================
-- 15. COMPLIANCE & AUDIT DATA
-- ========================================

-- Integration Logs
INSERT IGNORE INTO integration_logs (source_system, endpoint, request_type, payload, response, status, error_message, created_at) VALUES
('HRIS', '/api/employees/sync', 'POST', '{"action":"sync","date":"2024-12-01"}', '{"status":"success","records_processed":25}', 'success', NULL, '2024-12-01 08:00:00'),
('HRIS', '/api/payroll/export', 'GET', '{"period":"2024-12","format":"csv"}', '{"status":"success","file_path":"/exports/payroll_2024_12.csv"}', 'success', NULL, '2024-12-15 17:30:00'),
('BANK_API', '/api/transactions/sync', 'POST', '{"account":"BDO","date":"2024-12-15"}', '{"status":"success","transactions":50}', 'success', NULL, '2024-12-15 18:00:00'),
('TAX_SYSTEM', '/api/compliance/submit', 'POST', '{"report_type":"bir","period":"2024-Q4"}', '{"status":"error","code":"VALIDATION_FAILED"}', 'error', 'Missing required field: tax_id', '2024-12-15 19:00:00'),
('ACCOUNTING_SOFTWARE', '/api/journal/import', 'POST', '{"entries":20,"format":"json"}', '{"status":"success","imported":20}', 'success', NULL, '2024-12-15 20:00:00'),
('PAYMENT_GATEWAY', '/api/payments/process', 'POST', '{"amount":50000,"currency":"PHP"}', '{"status":"pending","transaction_id":"TXN123456"}', 'pending', NULL, '2024-12-15 21:00:00'),
('EXPENSE_SYSTEM', '/api/receipts/upload', 'POST', '{"employee_id":"EMP001","amount":2500}', '{"status":"success","receipt_id":"RCP789"}', 'success', NULL, '2024-12-15 22:00:00'),
('LOAN_SYSTEM', '/api/loans/calculate', 'POST', '{"principal":100000,"rate":0.05,"term":12}', '{"status":"success","monthly_payment":8560.75}', 'success', NULL, '2024-12-15 23:00:00'),
('BANK_API', '/api/balance/check', 'GET', '{"account":"BANK001"}', '{"status":"success","balance":2500000}', 'success', NULL, '2024-12-16 08:00:00'),
('HRIS', '/api/attendance/sync', 'POST', '{"date":"2024-12-16"}', '{"status":"success","records":25}', 'success', NULL, '2024-12-16 09:00:00')
ON DUPLICATE KEY UPDATE status = VALUES(status);

-- Audit Logs
INSERT IGNORE INTO audit_logs (user_id, ip_address, action, object_type, object_id, old_values, new_values, additional_info, created_at) VALUES
(1, '192.168.1.100', 'Create Journal Entry', 'journal_entry', 'JE-2025-0001', NULL, '{"amount":10000000,"type":"capital"}', '{"module":"financial_reporting"}', NOW() - INTERVAL 30 DAY),
(1, '192.168.1.101', 'Process Payroll', 'payroll_run', 'PR-2024-12', NULL, '{"employees":25,"total_gross":305000}', '{"period":"2024-12"}', NOW() - INTERVAL 10 DAY),
(1, '192.168.1.102', 'Generate Compliance Report', 'compliance_report', 'CR-2024-Q4', NULL, '{"type":"gaap","score":95}', '{"period":"2024-Q4"}', NOW() - INTERVAL 5 DAY),
(1, '192.168.1.103', 'Approve Expense Claim', 'expense_claim', 'EXP026', '{"status":"submitted"}', '{"status":"approved","approved_by":1}', '{"amount":1200,"category":"office_supplies"}', NOW() - INTERVAL 3 DAY),
(1, '127.0.0.1', 'System Backup', 'system', 'backup_2024_12_15', NULL, '{"status":"completed","size":"5.2GB"}', '{"type":"full_backup"}', NOW() - INTERVAL 1 DAY),
(1, '192.168.1.100', 'Update Account Balance', 'account_balance', 'AB-1001-Q4', '{"balance":500000}', '{"balance":525000}', '{"adjustment":"monthly_interest"}', NOW() - INTERVAL 15 DAY),
(1, '192.168.1.101', 'Export Payroll Data', 'payroll_export', 'PE-2024-12', NULL, '{"format":"csv","records":25}', '{"period":"2024-12"}', NOW() - INTERVAL 12 DAY),
(1, '192.168.1.102', 'View Financial Report', 'financial_report', 'FR-BS-2024-Q4', NULL, NULL, '{"report_type":"balance_sheet","period":"2024-Q4"}', NOW() - INTERVAL 7 DAY),
(1, '127.0.0.1', 'Login', 'user_session', '1', NULL, '{"login_time":"2024-12-15 08:00:00"}', '{"ip":"127.0.0.1"}', NOW() - INTERVAL 20 DAY),
(1, '192.168.1.100', 'Login', 'user_session', '1', NULL, '{"login_time":"2024-12-15 08:30:00"}', '{"ip":"192.168.1.100"}', NOW() - INTERVAL 18 DAY),
(1, '192.168.1.101', 'Create Loan', 'loan', 'LN-1025', NULL, '{"principal":20000,"rate":0.05,"term":18}', '{"borrower":"EMP021","type":"appliance"}', NOW() - INTERVAL 25 DAY),
(1, '192.168.1.102', 'Process Loan Payment', 'loan_payment', 'PAY-2024-12-005', NULL, '{"amount":1500,"principal":1300,"interest":200}', '{"loan_id":19}', NOW() - INTERVAL 8 DAY),
(1, '192.168.1.103', 'Generate Financial Report', 'financial_report', 'FR-IS-2024-Q4', NULL, '{"report_type":"income_statement","period":"2024-Q4"}', '{"format":"pdf"}', NOW() - INTERVAL 5 DAY),

-- Audit logs for expense claims (from expense tracking module)
(1, '192.168.1.100', 'Created', 'expense_claim', '1', NULL, '{"claim_no":"EXP-2024-001","amount":"2500.00","status":"draft"}', '{"description":"Expense claim created"}', '2024-01-15 09:30:00'),
(1, '192.168.1.100', 'Updated', 'expense_claim', '1', '{"status":"draft"}', '{"status":"submitted"}', '{"description":"Status changed from draft to submitted"}', '2024-01-15 10:15:00'),
(1, '192.168.1.101', 'Approved', 'expense_claim', '1', '{"status":"submitted"}', '{"status":"approved"}', '{"description":"Expense claim approved by manager"}', '2024-01-16 14:20:00'),
(1, '192.168.1.100', 'Created', 'expense_claim', '2', NULL, '{"claim_no":"EXP-2024-002","amount":"850.00","status":"draft"}', '{"description":"Expense claim created"}', '2024-01-18 08:45:00'),
(1, '192.168.1.100', 'Updated', 'expense_claim', '2', '{"status":"draft"}', '{"status":"submitted"}', '{"description":"Status changed from draft to submitted"}', '2024-01-18 09:00:00'),
(1, '192.168.1.101', 'Approved', 'expense_claim', '2', '{"status":"submitted"}', '{"status":"approved"}', '{"description":"Expense claim approved by manager"}', '2024-01-19 10:30:00'),
(1, '192.168.1.100', 'Created', 'expense_claim', '3', NULL, '{"claim_no":"EXP-2024-003","amount":"1200.00","status":"draft"}', '{"description":"Expense claim created"}', '2024-01-20 14:20:00'),
(1, '192.168.1.100', 'Updated', 'expense_claim', '3', '{"status":"draft"}', '{"status":"submitted"}', '{"description":"Status changed from draft to submitted"}', '2024-01-20 14:35:00'),
(1, '192.168.1.100', 'Created', 'expense_claim', '4', NULL, '{"claim_no":"EXP-2024-004","amount":"450.00","status":"draft"}', '{"description":"Expense claim created"}', '2024-01-22 11:15:00'),
(1, '192.168.1.100', 'Created', 'expense_claim', '5', NULL, '{"claim_no":"EXP-2024-005","amount":"3500.00","status":"draft"}', '{"description":"Expense claim created"}', '2024-01-25 16:30:00'),
(1, '192.168.1.100', 'Updated', 'expense_claim', '5', '{"status":"draft"}', '{"status":"submitted"}', '{"description":"Status changed from draft to submitted"}', '2024-01-25 16:45:00'),
(1, '192.168.1.101', 'Approved', 'expense_claim', '5', '{"status":"submitted"}', '{"status":"approved"}', '{"description":"Expense claim approved by manager"}', '2024-01-26 16:45:00'),
(1, '192.168.1.100', 'Created', 'expense_claim', '6', NULL, '{"claim_no":"EXP-2024-006","amount":"1800.00","status":"draft"}', '{"description":"Expense claim created"}', '2024-01-28 13:20:00'),
(1, '192.168.1.100', 'Updated', 'expense_claim', '6', '{"status":"draft"}', '{"status":"submitted"}', '{"description":"Status changed from draft to submitted"}', '2024-01-28 13:35:00'),
(1, '192.168.1.101', 'Rejected', 'expense_claim', '6', '{"status":"submitted"}', '{"status":"rejected"}', '{"description":"Expense claim rejected - insufficient documentation"}', '2024-01-29 09:15:00'),
(1, '192.168.1.100', 'Created', 'expense_claim', '7', NULL, '{"claim_no":"EXP-2024-007","amount":"650.00","status":"draft"}', '{"description":"Expense claim created"}', '2024-01-30 10:45:00'),
(1, '192.168.1.100', 'Updated', 'expense_claim', '7', '{"status":"draft"}', '{"status":"submitted"}', '{"description":"Status changed from draft to submitted"}', '2024-01-30 11:00:00'),
(1, '192.168.1.101', 'Approved', 'expense_claim', '7', '{"status":"submitted"}', '{"status":"approved"}', '{"description":"Expense claim approved by manager"}', '2024-01-31 11:20:00'),
(1, '192.168.1.101', 'Paid', 'expense_claim', '7', '{"status":"approved"}', '{"status":"paid"}', '{"description":"Payment processed"}', '2024-01-31 15:30:00')
ON DUPLICATE KEY UPDATE action = VALUES(action);

-- Compliance Reports (2024 + 2025 + Q1 2026)
INSERT IGNORE INTO compliance_reports (report_type, period_start, period_end, generated_date, generated_by, status, file_path, report_data, compliance_score, issues_found, created_at) VALUES
-- 2024 Q4
('gaap', '2024-10-01', '2024-12-31', '2025-01-05 09:00:00', 1, 'completed', '/reports/gaap_2024_q4.pdf', '{"total_assets":15000000,"total_liabilities":5000000,"net_income":2000000,"entries_reviewed":120,"balanced":true}', 98.50, 'Excellent compliance. All transactions properly documented.', '2025-01-05 09:00:00'),
('sox', '2024-10-01', '2024-12-31', '2025-01-07 10:00:00', 1, 'completed', '/reports/sox_2024_q4.pdf', '{"segregation_score":95,"audit_trail":100,"controls":90,"access_controls":92}', 95.00, 'Strong internal controls. Minor improvement needed in approval workflows.', '2025-01-07 10:00:00'),
('bir', '2024-10-01', '2024-12-31', '2025-01-10 14:00:00', 1, 'completed', '/reports/bir_2024_q4.pdf', '{"documentation":98,"tax_calculations":100,"filing":95,"withholding_compliance":97}', 97.50, 'Tax documentation properly maintained. All BIR forms filed on time.', '2025-01-10 14:00:00'),
('ifrs', '2024-10-01', '2024-12-31', '2025-01-12 09:00:00', 1, 'completed', '/reports/ifrs_2024_q4.pdf', '{"revenue_recognition":100,"asset_classification":95,"disclosure":90,"fair_value":92}', 95.00, 'IFRS standards properly implemented. Consider enhancing disclosure notes.', '2025-01-12 09:00:00'),
('sox', '2024-01-01', '2024-03-31', '2024-04-10 10:00:00', 1, 'completed', '/reports/sox_2024_q1.pdf', '{"segregation_score":88,"audit_trail":95,"controls":85,"access_controls":90}', 89.00, 'Good compliance. Some entries created and posted by same user.', '2024-04-10 10:00:00'),
('bir', '2024-01-01', '2024-03-31', '2024-04-15 14:00:00', 1, 'completed', '/reports/bir_2024_q1.pdf', '{"documentation":95,"tax_calculations":100,"filing":90,"withholding_compliance":93}', 95.00, 'Most transactions properly documented. Consider adding more detailed reference numbers.', '2024-04-15 14:00:00'),

-- 2025 Q1  
('gaap', '2025-01-01', '2025-03-31', '2025-04-05 09:00:00', 1, 'completed', '/reports/gaap_2025_q1.pdf', '{"total_assets":19500000,"total_liabilities":5200000,"net_income":2800000,"entries_reviewed":145,"balanced":true}', 97.00, 'Strong compliance. All double-entry principles followed correctly.', '2025-04-05 09:00:00'),
('sox', '2025-01-01', '2025-03-31', '2025-04-08 10:00:00', 1, 'completed', '/reports/sox_2025_q1.pdf', '{"segregation_score":96,"audit_trail":100,"controls":94,"access_controls":95}', 96.25, 'Excellent internal controls. Segregation of duties properly enforced.', '2025-04-08 10:00:00'),
('bir', '2025-01-01', '2025-03-31', '2025-04-12 14:00:00', 1, 'completed', '/reports/bir_2025_q1.pdf', '{"documentation":98,"tax_calculations":100,"filing":97,"withholding_compliance":99}', 98.50, 'BIR compliance excellent. All withholding taxes properly computed and remitted.', '2025-04-12 14:00:00'),
('ifrs', '2025-01-01', '2025-03-31', '2025-04-15 09:00:00', 1, 'completed', '/reports/ifrs_2025_q1.pdf', '{"revenue_recognition":100,"asset_classification":98,"disclosure":95,"fair_value":96}', 97.25, 'IFRS fully compliant. Revenue recognition timing properly applied.', '2025-04-15 09:00:00'),

-- 2025 Q2
('gaap', '2025-04-01', '2025-06-30', '2025-07-05 09:00:00', 1, 'completed', '/reports/gaap_2025_q2.pdf', '{"total_assets":20100000,"total_liabilities":5350000,"net_income":3100000,"entries_reviewed":160,"balanced":true}', 98.00, 'All financial statements balanced. Proper account classification throughout.', '2025-07-05 09:00:00'),
('sox', '2025-04-01', '2025-06-30', '2025-07-08 10:00:00', 1, 'completed', '/reports/sox_2025_q2.pdf', '{"segregation_score":97,"audit_trail":100,"controls":95,"access_controls":96}', 97.00, 'Internal controls strengthened. All approvals properly documented.', '2025-07-08 10:00:00'),
('bir', '2025-04-01', '2025-06-30', '2025-07-12 14:00:00', 1, 'completed', '/reports/bir_2025_q2.pdf', '{"documentation":99,"tax_calculations":100,"filing":98,"withholding_compliance":99}', 99.00, 'Perfect BIR compliance score. All Alphalist entries match tax certificates.', '2025-07-12 14:00:00'),
('ifrs', '2025-04-01', '2025-06-30', '2025-07-15 09:00:00', 1, 'completed', '/reports/ifrs_2025_q2.pdf', '{"revenue_recognition":100,"asset_classification":99,"disclosure":97,"fair_value":98}', 98.50, 'Full IFRS compliance achieved. Disclosure notes comprehensive.', '2025-07-15 09:00:00'),

-- 2025 Q3
('gaap', '2025-07-01', '2025-09-30', '2025-10-05 09:00:00', 1, 'completed', '/reports/gaap_2025_q3.pdf', '{"total_assets":21200000,"total_liabilities":5500000,"net_income":3450000,"entries_reviewed":175,"balanced":true}', 97.50, 'Books balanced. Minor reclassification of prepaid expenses noted.', '2025-10-05 09:00:00'),
('sox', '2025-07-01', '2025-09-30', '2025-10-08 10:00:00', 1, 'completed', '/reports/sox_2025_q3.pdf', '{"segregation_score":98,"audit_trail":100,"controls":96,"access_controls":97}', 97.75, 'SOX controls operating effectively. Audit trail complete.', '2025-10-08 10:00:00'),
('bir', '2025-07-01', '2025-09-30', '2025-10-12 14:00:00', 1, 'completed', '/reports/bir_2025_q3.pdf', '{"documentation":98,"tax_calculations":100,"filing":99,"withholding_compliance":100}', 99.25, 'Outstanding BIR compliance. Zero discrepancies found in Q3 tax filings.', '2025-10-12 14:00:00'),
('ifrs', '2025-07-01', '2025-09-30', '2025-10-15 09:00:00', 1, 'completed', '/reports/ifrs_2025_q3.pdf', '{"revenue_recognition":100,"asset_classification":98,"disclosure":97,"fair_value":97}', 98.00, 'IFRS standards consistently applied. Good fair value measurements.', '2025-10-15 09:00:00'),

-- 2025 Q4
('gaap', '2025-10-01', '2025-12-31', '2026-01-06 09:00:00', 1, 'completed', '/reports/gaap_2025_q4.pdf', '{"total_assets":22500000,"total_liabilities":5700000,"net_income":3800000,"entries_reviewed":190,"balanced":true}', 98.50, 'Year-end financials properly closed. All adjusting entries recorded.', '2026-01-06 09:00:00'),
('sox', '2025-10-01', '2025-12-31', '2026-01-08 10:00:00', 1, 'completed', '/reports/sox_2025_q4.pdf', '{"segregation_score":99,"audit_trail":100,"controls":97,"access_controls":98}', 98.50, 'Year-end SOX review passed. All deficiencies from prior quarters resolved.', '2026-01-08 10:00:00'),
('bir', '2025-10-01', '2025-12-31', '2026-01-12 14:00:00', 1, 'completed', '/reports/bir_2025_q4.pdf', '{"documentation":99,"tax_calculations":100,"filing":100,"withholding_compliance":100}', 99.75, 'Annual BIR compliance near-perfect. All 2316 forms distributed on time.', '2026-01-12 14:00:00'),
('ifrs', '2025-10-01', '2025-12-31', '2026-01-15 09:00:00', 1, 'completed', '/reports/ifrs_2025_q4.pdf', '{"revenue_recognition":100,"asset_classification":99,"disclosure":98,"fair_value":99}', 99.00, 'Annual IFRS review - full compliance. Financial statements ready for external audit.', '2026-01-15 09:00:00'),

-- 2026 Q1
('gaap', '2026-01-01', '2026-03-31', '2026-03-20 09:00:00', 1, 'completed', '/reports/gaap_2026_q1.pdf', '{"total_assets":22500000,"total_liabilities":5500000,"net_income":4200000,"entries_reviewed":85,"balanced":true}', 97.80, 'Q1 books balanced. New revenue recognition policy properly applied.', '2026-03-20 09:00:00'),
('sox', '2026-01-01', '2026-03-31', '2026-03-22 10:00:00', 1, 'completed', '/reports/sox_2026_q1.pdf', '{"segregation_score":98,"audit_trail":100,"controls":96,"access_controls":97}', 97.75, 'Q1 SOX controls effective. New hire access provisioning properly managed.', '2026-03-22 10:00:00'),
('bir', '2026-01-01', '2026-03-31', '2026-03-25 14:00:00', 1, 'generating', NULL, NULL, NULL, NULL, '2026-03-25 14:00:00'),
('ifrs', '2026-01-01', '2026-03-31', '2026-03-28 09:00:00', 1, 'completed', '/reports/ifrs_2026_q1.pdf', '{"revenue_recognition":100,"asset_classification":98,"disclosure":96,"fair_value":97}', 97.75, 'IFRS applied consistently with prior year. No changes in accounting policies.', '2026-03-28 09:00:00')
ON DUPLICATE KEY UPDATE compliance_score = VALUES(compliance_score);

-- ========================================
-- 17. VERIFICATION & SUMMARY QUERIES
-- ========================================

SELECT '=== COMPREHENSIVE DATA INSERTION COMPLETE ===' AS status;

-- Show record counts for all major tables
SELECT 'DATA SUMMARY' AS section, 'Record Counts' AS info;

SELECT 'Users:' AS table_name, COUNT(*) AS record_count FROM users
UNION ALL
SELECT 'Roles:', COUNT(*) FROM roles


UNION ALL
SELECT 'Journal Types:', COUNT(*) FROM journal_types
UNION ALL
SELECT 'Fiscal Periods:', COUNT(*) FROM fiscal_periods
UNION ALL
SELECT 'Employee References:', COUNT(*) FROM employee_refs
UNION ALL
SELECT 'Bank Accounts:', COUNT(*) FROM bank_accounts
UNION ALL
SELECT 'Salary Components:', COUNT(*) FROM salary_components

UNION ALL
SELECT 'Loan Types:', COUNT(*) FROM loan_types


UNION ALL
SELECT 'Loans:', COUNT(*) FROM loans
UNION ALL
SELECT 'Loan Payments:', COUNT(*) FROM loan_payments
UNION ALL
SELECT 'Expense Claims:', COUNT(*) FROM expense_claims
UNION ALL
SELECT 'Payments:', COUNT(*) FROM payments
UNION ALL
SELECT 'Payroll Periods:', COUNT(*) FROM payroll_periods
UNION ALL
SELECT 'Payroll Runs:', COUNT(*) FROM payroll_runs
UNION ALL
SELECT 'Payslips:', COUNT(*) FROM payslips
UNION ALL
SELECT 'Integration Logs:', COUNT(*) FROM integration_logs
UNION ALL
SELECT 'Audit Logs:', COUNT(*) FROM audit_logs
UNION ALL
SELECT 'Compliance Reports:', COUNT(*) FROM compliance_reports

UNION ALL
SELECT 'Loan Applications:', COUNT(*) FROM loan_applications
UNION ALL
SELECT 'Bank Transactions:', COUNT(*) FROM bank_transactions
UNION ALL
SELECT 'Bank Customers:', COUNT(*) FROM bank_customers
UNION ALL
SELECT 'Transaction Types:', COUNT(*) FROM transaction_types;







-- Loan Portfolio Summary
SELECT 
    'LOAN PORTFOLIO SUMMARY' AS section,
    lt.name AS loan_type,
    COUNT(*) AS total_loans,
    SUM(l.principal_amount) AS total_principal,
    SUM(l.current_balance) AS total_outstanding,
    AVG(l.interest_rate * 100) AS avg_interest_rate
FROM loans l
JOIN loan_types lt ON l.loan_type_id = lt.id
GROUP BY lt.id, lt.name
ORDER BY total_principal DESC;

-- Employee Summary
SELECT 
    'EMPLOYEE SUMMARY' AS section,
    department,
    COUNT(*) AS employee_count,
    employment_type
FROM employee_refs
GROUP BY department, employment_type
ORDER BY department, employment_type;

-- Recent Activity Summary
SELECT
    'RECENT ACTIVITY SUMMARY' AS section,
    'Expense Claims (Last 30 days)',
    COUNT(*)
FROM expense_claims
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)

UNION ALL

SELECT 
    'RECENT ACTIVITY SUMMARY',
    'Loan Payments (Last 30 days)',
    COUNT(*)
FROM loan_payments
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)

UNION ALL

SELECT 
    'RECENT ACTIVITY SUMMARY',
    'Payments (Last 30 days)',
    COUNT(*)
FROM payments
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY);

-- ========================================
-- HRIS-PAYROLL INTEGRATION VERIFICATION
-- ========================================
-- This query demonstrates the connection between HRIS and Payroll systems

SELECT 
    'HRIS-PAYROLL CONNECTION' AS verification_type,
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    d.department_name AS department,
    p.position_title AS position,
    er.external_employee_no,
    er.base_monthly_salary AS payroll_base_salary,
    COUNT(DISTINCT ps.id) AS payslip_count,
    SUM(ps.gross_pay) AS total_gross_paid
FROM employee e
LEFT JOIN department d ON e.department_id = d.department_id
LEFT JOIN `position` p ON e.position_id = p.position_id
LEFT JOIN employee_refs er ON er.external_employee_no = CONCAT('EMP', LPAD(e.employee_id, 3, '0'))
LEFT JOIN payslips ps ON ps.employee_external_no = er.external_employee_no
WHERE e.employment_status = 'Active'
GROUP BY e.employee_id, e.first_name, e.last_name, d.department_name, p.position_title, er.external_employee_no, er.base_monthly_salary
ORDER BY e.employee_id
LIMIT 10;

-- Verification: Check employee attendance linked to payroll
SELECT 
    'ATTENDANCE-PAYROLL LINK' AS verification_type,
    er.external_employee_no,
    er.name AS employee_name,
    COUNT(DISTINCT ea.attendance_date) AS attendance_days,
    SUM(ea.hours_worked) AS total_hours,
    SUM(ea.overtime_hours) AS total_overtime,
    COUNT(DISTINCT ps.id) AS payslips_generated
FROM employee_refs er
LEFT JOIN employee_attendance ea ON ea.employee_external_no = er.external_employee_no
LEFT JOIN payslips ps ON ps.employee_external_no = er.external_employee_no
WHERE er.employment_type = 'regular'
GROUP BY er.external_employee_no, er.name
ORDER BY er.external_employee_no
LIMIT 10;

-- Verification: Department and Position summary from HRIS
SELECT 
    'HRIS DEPARTMENT SUMMARY' AS summary_type,
    d.department_name,
    COUNT(DISTINCT e.employee_id) AS total_employees,
    COUNT(DISTINCT p.position_id) AS total_positions,
    SUM(er.base_monthly_salary) AS total_monthly_salary_budget
FROM department d
LEFT JOIN employee e ON e.department_id = d.department_id
LEFT JOIN `position` p ON p.position_id = e.position_id
LEFT JOIN employee_refs er ON er.external_employee_no = CONCAT('EMP', LPAD(e.employee_id, 3, '0'))
GROUP BY d.department_id, d.department_name
ORDER BY total_employees DESC;

SELECT '=== ALL DATA SUCCESSFULLY INSERTED ===' AS final_status;
SELECT '=== ACCOUNTING & FINANCE SYSTEM IS READY FOR TESTING ===' AS ready_status;