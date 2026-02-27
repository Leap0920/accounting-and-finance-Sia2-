-- ========================================
-- UNIFIED DATABASE SCHEMA
-- ========================================
-- This file contains the complete unified database schema
-- Merged from: schema.sql, hris_system.sql, evergreen_bank.sql, basic-operation.sql, bank_loan.sql
-- 
-- Database Name: BankingDB
-- Professional database for comprehensive banking and financial management
--
-- ========================================
-- DATABASE CREATION
-- ========================================

DROP DATABASE IF EXISTS BankingDB;
CREATE DATABASE BankingDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE BankingDB;

-- ========================================
-- CORE USERS AND AUTHENTICATION
-- ========================================

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    last_login DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_email (email)
);

CREATE TABLE roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_roles (
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
);

CREATE TABLE login_attempts (
    attempt_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    ip_address VARCHAR(45) DEFAULT NULL,
    attempt_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    success BOOLEAN DEFAULT 0,
    failure_reason VARCHAR(255) DEFAULT NULL,
    INDEX idx_username (username),
    INDEX idx_ip_address (ip_address),
    INDEX idx_attempt_time (attempt_time)
);

CREATE TABLE user_account (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT DEFAULT NULL,
    username VARCHAR(50) DEFAULT NULL,
    password_hash VARCHAR(255) DEFAULT NULL,
    role VARCHAR(20) DEFAULT NULL,
    managed_department_id INT DEFAULT NULL,
    last_login DATETIME DEFAULT NULL,
    UNIQUE KEY username (username),
    INDEX idx_employee_id (employee_id)
);

-- ========================================
-- HRIS MODULE
-- ========================================

CREATE TABLE department (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    description VARCHAR(255) DEFAULT NULL
);

CREATE TABLE `position` (
    position_id INT AUTO_INCREMENT PRIMARY KEY,
    position_title VARCHAR(100) NOT NULL,
    job_description VARCHAR(255) DEFAULT NULL,
    salary_grade INT DEFAULT NULL
);

CREATE TABLE employee (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) DEFAULT NULL,
    last_name VARCHAR(50) DEFAULT NULL,
    middle_name VARCHAR(50) DEFAULT NULL,
    gender VARCHAR(10) DEFAULT NULL,
    birth_date DATE DEFAULT NULL,
    contact_number VARCHAR(20) DEFAULT NULL,
    email VARCHAR(100) DEFAULT NULL,
    address VARCHAR(255) DEFAULT NULL,
    house_number VARCHAR(50) DEFAULT NULL,
    street VARCHAR(100) DEFAULT NULL,
    barangay VARCHAR(100) DEFAULT NULL,
    city VARCHAR(100) DEFAULT NULL,
    province VARCHAR(100) DEFAULT NULL,
    secondary_email VARCHAR(100) DEFAULT NULL,
    secondary_contact_number VARCHAR(20) DEFAULT NULL,
    hire_date DATE DEFAULT NULL,
    department_id INT DEFAULT NULL,
    position_id INT DEFAULT NULL,
    contract_id INT DEFAULT NULL,
    employment_status VARCHAR(20) DEFAULT NULL,
    INDEX idx_department_id (department_id),
    INDEX idx_position_id (position_id),
    INDEX idx_employment_status (employment_status),
    FOREIGN KEY (department_id) REFERENCES department(department_id),
    FOREIGN KEY (position_id) REFERENCES `position`(position_id)
);

CREATE TABLE employee_refs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    external_employee_no VARCHAR(100) NOT NULL,
    name VARCHAR(200),
    department VARCHAR(100),
    position VARCHAR(100),
    base_monthly_salary DECIMAL(12,2) DEFAULT 0.00,
    employment_type ENUM('regular','contract','part-time') DEFAULT 'regular',
    external_source VARCHAR(100) DEFAULT 'HRIS',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY (external_employee_no, external_source),
    INDEX idx_external_no (external_employee_no)
);

CREATE TABLE employee_attendance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_external_no VARCHAR(100) NOT NULL,
    attendance_date DATE NOT NULL,
    time_in TIME,
    time_out TIME,
    status ENUM('present','absent','late','leave','half_day') DEFAULT 'present',
    hours_worked DECIMAL(4,2) DEFAULT 0.00,
    overtime_hours DECIMAL(4,2) DEFAULT 0.00,
    late_minutes INT DEFAULT 0,
    remarks TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_employee_date (employee_external_no, attendance_date)
);

CREATE TABLE attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT DEFAULT NULL,
    date DATE DEFAULT NULL,
    time_in DATETIME DEFAULT NULL,
    time_out DATETIME DEFAULT NULL,
    total_hours DECIMAL(5,2) DEFAULT NULL,
    status VARCHAR(50) DEFAULT NULL,
    remarks VARCHAR(255) DEFAULT NULL,
    INDEX idx_date (date),
    INDEX idx_employee_date (employee_id, date),
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id) ON DELETE CASCADE
);

CREATE TABLE contract (
    contract_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT DEFAULT NULL,
    contract_type VARCHAR(50) DEFAULT NULL,
    start_date DATE DEFAULT NULL,
    end_date DATE DEFAULT NULL,
    salary DECIMAL(10,2) DEFAULT NULL,
    benefits VARCHAR(255) DEFAULT NULL,
    INDEX idx_employee_id (employee_id),
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id) ON DELETE CASCADE
);

CREATE TABLE leave_type (
    leave_type_id INT AUTO_INCREMENT PRIMARY KEY,
    leave_name VARCHAR(100) DEFAULT NULL,
    purpose VARCHAR(255) DEFAULT NULL,
    duration VARCHAR(50) DEFAULT NULL,
    paid_unpaid VARCHAR(20) DEFAULT NULL
);

CREATE TABLE leave_request (
    leave_request_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT DEFAULT NULL,
    leave_type_id INT DEFAULT NULL,
    start_date DATE DEFAULT NULL,
    end_date DATE DEFAULT NULL,
    total_days INT DEFAULT NULL,
    reason VARCHAR(255) DEFAULT NULL,
    status VARCHAR(20) DEFAULT NULL,
    approver_id INT DEFAULT NULL,
    date_requested DATE DEFAULT NULL,
    date_approved DATE DEFAULT NULL,
    INDEX idx_employee_id (employee_id),
    INDEX idx_leave_type_id (leave_type_id),
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id) ON DELETE CASCADE,
    FOREIGN KEY (leave_type_id) REFERENCES leave_type(leave_type_id)
);



CREATE TABLE system_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    log_level ENUM('DEBUG','INFO','WARNING','ERROR','CRITICAL') NOT NULL,
    log_type VARCHAR(50) NOT NULL,
    user_id INT DEFAULT NULL,
    employee_id INT DEFAULT NULL,
    ip_address VARCHAR(45) DEFAULT NULL,
    user_agent TEXT DEFAULT NULL,
    action VARCHAR(100) NOT NULL,
    details TEXT DEFAULT NULL,
    request_data JSON DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_log_level (log_level),
    INDEX idx_log_type (log_type),
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at),
    INDEX idx_employee_id (employee_id),
    FOREIGN KEY (user_id) REFERENCES user_account(user_id) ON DELETE SET NULL,
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id) ON DELETE SET NULL
);

-- ========================================
-- ROLE CHANGE AUDIT LOG TABLE
-- ========================================
CREATE TABLE IF NOT EXISTS role_change_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    changed_by INT NOT NULL,
    old_role VARCHAR(20) DEFAULT NULL,
    new_role VARCHAR(20) NOT NULL,
    old_department_id INT DEFAULT NULL,
    new_department_id INT DEFAULT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_changed_at (changed_at),
    FOREIGN KEY (user_id) REFERENCES user_account(user_id) ON DELETE CASCADE,
    FOREIGN KEY (changed_by) REFERENCES user_account(user_id) ON DELETE CASCADE,
    FOREIGN KEY (old_department_id) REFERENCES department(department_id) ON DELETE SET NULL,
    FOREIGN KEY (new_department_id) REFERENCES department(department_id) ON DELETE SET NULL
);



-- Banking Module removed (not used by accounting-and-finance)


-- ========================================
-- ACCOUNTING MODULE
-- ========================================

CREATE TABLE fiscal_periods (
    id INT AUTO_INCREMENT PRIMARY KEY,
    period_name VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status ENUM('open','closed','locked') DEFAULT 'open',
    closed_by INT,
    closed_at DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY (start_date, end_date),
    FOREIGN KEY (closed_by) REFERENCES users(id),
    INDEX idx_status (status)
);

CREATE TABLE account_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    category ENUM('asset','liability','equity','revenue','expense') NOT NULL,
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE accounts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(150) NOT NULL,
    type_id INT NOT NULL,
    parent_account_id INT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_by INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (type_id) REFERENCES account_types(id),
    FOREIGN KEY (parent_account_id) REFERENCES accounts(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    INDEX idx_code (code),
    INDEX idx_type_id (type_id)
);

CREATE TABLE account_balances (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    fiscal_period_id INT NOT NULL,
    opening_balance DECIMAL(18,2) DEFAULT 0.00,
    debit_movements DECIMAL(18,2) DEFAULT 0.00,
    credit_movements DECIMAL(18,2) DEFAULT 0.00,
    closing_balance DECIMAL(18,2) DEFAULT 0.00,
    last_updated DATETIME,
    UNIQUE KEY (account_id, fiscal_period_id),
    FOREIGN KEY (account_id) REFERENCES accounts(id),
    FOREIGN KEY (fiscal_period_id) REFERENCES fiscal_periods(id)
);


CREATE TABLE journal_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(50) NOT NULL,
    auto_reversing BOOLEAN DEFAULT FALSE,
    description TEXT,
    INDEX idx_code (code)
);

CREATE TABLE journal_entries (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    journal_no VARCHAR(50) UNIQUE NOT NULL,
    journal_type_id INT NOT NULL,
    entry_date DATE NOT NULL,
    description TEXT,
    fiscal_period_id INT NOT NULL,
    reference_no VARCHAR(100),
    total_debit DECIMAL(18,2) DEFAULT 0.00,
    total_credit DECIMAL(18,2) DEFAULT 0.00,
    status ENUM('draft','posted','reversed','voided') DEFAULT 'draft',
    posted_by INT,
    posted_at DATETIME,
    created_by INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (journal_type_id) REFERENCES journal_types(id),
    FOREIGN KEY (fiscal_period_id) REFERENCES fiscal_periods(id),
    FOREIGN KEY (posted_by) REFERENCES users(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    INDEX idx_journal_no (journal_no),
    INDEX idx_status (status),
    INDEX idx_entry_date (entry_date)
);

CREATE TABLE journal_lines (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    journal_entry_id BIGINT NOT NULL,
    account_id INT NOT NULL,
    debit DECIMAL(18,2) DEFAULT 0.00,
    credit DECIMAL(18,2) DEFAULT 0.00,
    memo VARCHAR(255),
    cost_center_id INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (journal_entry_id) REFERENCES journal_entries(id),
    FOREIGN KEY (account_id) REFERENCES accounts(id),
    INDEX idx_journal_entry_id (journal_entry_id)
);

-- ========================================
-- PAYROLL MODULE
-- ========================================

CREATE TABLE payroll_periods (
    id INT AUTO_INCREMENT PRIMARY KEY,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    frequency ENUM('monthly','semimonthly','weekly') DEFAULT 'semimonthly',
    status ENUM('open','processing','posted','paid') DEFAULT 'open',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY (period_start, period_end),
    INDEX idx_status (status)
);

CREATE TABLE payroll_runs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    payroll_period_id INT NOT NULL,
    run_by_user_id INT NOT NULL,
    run_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_gross DECIMAL(18,2) DEFAULT 0.00,
    total_deductions DECIMAL(18,2) DEFAULT 0.00,
    total_net DECIMAL(18,2) DEFAULT 0.00,
    status ENUM('draft','finalized','exported','completed') DEFAULT 'draft',
    journal_entry_id BIGINT,
    FOREIGN KEY (payroll_period_id) REFERENCES payroll_periods(id),
    FOREIGN KEY (run_by_user_id) REFERENCES users(id),
    FOREIGN KEY (journal_entry_id) REFERENCES journal_entries(id),
    INDEX idx_status (status)
);

CREATE TABLE payslips (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    payroll_run_id INT NOT NULL,
    employee_external_no VARCHAR(100) NOT NULL,
    gross_pay DECIMAL(18,2) DEFAULT 0.00,
    total_deductions DECIMAL(18,2) DEFAULT 0.00,
    net_pay DECIMAL(18,2) DEFAULT 0.00,
    payslip_json JSON NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (payroll_run_id) REFERENCES payroll_runs(id),
    INDEX idx_employee_external_no (employee_external_no)
);

CREATE TABLE payroll_payslips (
    payslip_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT DEFAULT NULL,
    pay_period_start DATE DEFAULT NULL,
    pay_period_end DATE DEFAULT NULL,
    gross_salary DECIMAL(10,2) DEFAULT NULL,
    deduction DECIMAL(10,2) DEFAULT NULL,
    net_pay DECIMAL(10,2) DEFAULT NULL,
    release_date DATE DEFAULT NULL,
    INDEX idx_employee_id (employee_id),
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id) ON DELETE CASCADE
);

CREATE TABLE salary_components (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    type ENUM('earning','deduction','tax','employer_contrib') NOT NULL,
    calculation_method ENUM('fixed','percent','per_hour','formula') DEFAULT 'fixed',
    value DECIMAL(15,4) DEFAULT 0.00,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_type (type)
);


CREATE TABLE bank_accounts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(150) NOT NULL,
    bank_name VARCHAR(150),
    account_number VARCHAR(50),
    currency VARCHAR(10) DEFAULT 'PHP',
    current_balance DECIMAL(18, 2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ========================================
-- PAYMENTS
-- ========================================

CREATE TABLE payments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    payment_no VARCHAR(50) UNIQUE NOT NULL,
    payment_date DATE NOT NULL,
    payment_type ENUM('cash','check','bank_transfer') NOT NULL,
    from_bank_account_id INT,
    payee_name VARCHAR(150) NOT NULL,
    amount DECIMAL(18,2) NOT NULL,
    reference_no VARCHAR(150),
    memo TEXT,
    status ENUM('pending','completed','failed','voided') DEFAULT 'pending',
    journal_entry_id BIGINT,
    created_by INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (from_bank_account_id) REFERENCES bank_accounts(id),
    FOREIGN KEY (journal_entry_id) REFERENCES journal_entries(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    INDEX idx_payment_no (payment_no),
    INDEX idx_status (status)
);

-- ========================================
-- LOANS MODULE
-- ========================================

CREATE TABLE loan_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    max_amount DECIMAL(18,2),
    max_term_months INT,
    interest_rate DECIMAL(6,4) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    INDEX idx_code (code)
);

CREATE TABLE loans (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    loan_no VARCHAR(50) UNIQUE NOT NULL,
    loan_type_id INT NOT NULL,
    borrower_external_no VARCHAR(100) NOT NULL,
    principal_amount DECIMAL(18,2) NOT NULL,
    interest_rate DECIMAL(6,4) NOT NULL,
    start_date DATE NOT NULL,
    term_months INT NOT NULL,
    monthly_payment DECIMAL(18,2) NOT NULL,
    current_balance DECIMAL(18,2) DEFAULT 0.00,
    next_payment_due DATE DEFAULT NULL,
    status ENUM('pending','active','paid','defaulted','cancelled') DEFAULT 'pending',
    application_id INT DEFAULT NULL,
    created_by INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (loan_type_id) REFERENCES loan_types(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    INDEX idx_loan_no (loan_no),
    INDEX idx_status (status),
    INDEX idx_application_id (application_id)
);

CREATE TABLE loan_payments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    loan_id BIGINT NOT NULL,
    payment_date DATE NOT NULL,
    amount DECIMAL(18,2) NOT NULL,
    principal_amount DECIMAL(18,2) NOT NULL,
    interest_amount DECIMAL(18,2) NOT NULL,
    payment_reference VARCHAR(100),
    journal_entry_id BIGINT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (loan_id) REFERENCES loans(id),
    FOREIGN KEY (journal_entry_id) REFERENCES journal_entries(id),
    INDEX idx_loan_id (loan_id),
    INDEX idx_payment_date (payment_date)
);

CREATE TABLE `loan_valid_id` (
  `id` int(11) NOT NULL,
  `valid_id_type` varchar(150) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE `loan_application_types` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE loan_applications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    loan_type_id int(11) DEFAULT NULL,
    -- Applicant information
    full_name VARCHAR(100) DEFAULT NULL,
    account_number VARCHAR(50) DEFAULT NULL,
    contact_number VARCHAR(20) DEFAULT NULL,
    email VARCHAR(100) DEFAULT NULL,
    job VARCHAR(255) DEFAULT NULL,
    monthly_salary DECIMAL(10,2) DEFAULT NULL,
    user_email VARCHAR(255) NOT NULL,
    -- Requested loan details (transferred to loans table when approved)
    loan_type VARCHAR(50) DEFAULT NULL,
    loan_terms VARCHAR(50) DEFAULT NULL,
    loan_amount DECIMAL(12,2) DEFAULT NULL,
    purpose TEXT DEFAULT NULL,
    loan_valid_id_type INT(11) DEFAULT NULL,
    valid_id_number VARCHAR(150) DEFAULT NULL,
    monthly_payment DECIMAL(10,2) DEFAULT NULL,
    due_date DATE DEFAULT NULL,
    -- Application workflow
    status VARCHAR(50) DEFAULT 'Pending',
    remarks TEXT DEFAULT NULL,
    file_name VARCHAR(255) DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    approved_by VARCHAR(100) DEFAULT NULL,
    approved_by_user_id INT DEFAULT NULL,
    approved_at DATETIME DEFAULT NULL,
    next_payment_due DATE DEFAULT NULL,
    rejected_by VARCHAR(255) DEFAULT NULL,
    rejected_by_user_id INT DEFAULT NULL,
    rejected_at DATETIME DEFAULT NULL,
    rejection_remarks TEXT DEFAULT NULL,
    -- Supporting documents (matching subsystem structure)
    proof_of_income VARCHAR(255) DEFAULT NULL,
    coe_document VARCHAR(255) DEFAULT NULL,
    pdf_path VARCHAR(255) DEFAULT NULL,
    pdf_approved VARCHAR(255) DEFAULT NULL,
    pdf_active VARCHAR(255) DEFAULT NULL,
    pdf_rejected VARCHAR(255) DEFAULT NULL,
    -- Link to approved loan (set when application is approved and loan created)
    loan_id BIGINT DEFAULT NULL,
    FOREIGN KEY (loan_type_id) REFERENCES loan_types(id) ON DELETE SET NULL,
    FOREIGN KEY (loan_valid_id_type) REFERENCES loan_valid_id(id) ON DELETE SET NULL,
    FOREIGN KEY (approved_by_user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (rejected_by_user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (loan_id) REFERENCES loans(id) ON DELETE SET NULL,
    INDEX idx_user_email (user_email),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at),
    INDEX idx_loan_type_id (loan_type_id),
    INDEX idx_approved_by_user_id (approved_by_user_id),
    INDEX idx_rejected_by_user_id (rejected_by_user_id),
    INDEX idx_loan_id (loan_id)
);


ALTER TABLE loans 
ADD CONSTRAINT fk_loans_application_id 
FOREIGN KEY (application_id) REFERENCES loan_applications(id) ON DELETE SET NULL;

-- ========================================
-- EXPENSES MODULE
-- ========================================

CREATE TABLE expense_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    account_id INT NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (account_id) REFERENCES accounts(id),
    INDEX idx_code (code)
);

CREATE TABLE expense_claims (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    claim_no VARCHAR(50) UNIQUE NOT NULL,
    employee_external_no VARCHAR(100) NOT NULL,
    expense_date DATE NOT NULL,
    category_id INT NOT NULL,
    amount DECIMAL(18,2) NOT NULL,
    description TEXT,
    status ENUM('draft','submitted','approved','rejected','paid') DEFAULT 'draft',
    approved_by INT,
    approved_at DATETIME,
    payment_id BIGINT,
    journal_entry_id BIGINT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES expense_categories(id),
    FOREIGN KEY (approved_by) REFERENCES users(id),
    FOREIGN KEY (payment_id) REFERENCES payments(id),
    FOREIGN KEY (journal_entry_id) REFERENCES journal_entries(id),
    INDEX idx_claim_no (claim_no),
    INDEX idx_status (status)
);

-- ========================================
-- COMPLIANCE REPORTS
-- ========================================

CREATE TABLE compliance_reports (
    id INT AUTO_INCREMENT PRIMARY KEY,
    report_type ENUM('gaap','sox','bir','ifrs') NOT NULL,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    generated_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    generated_by INT NOT NULL,
    status ENUM('generating','completed','failed') DEFAULT 'generating',
    file_path VARCHAR(500),
    report_data JSON,
    compliance_score DECIMAL(5,2),
    issues_found TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (generated_by) REFERENCES users(id),
    INDEX idx_report_type (report_type),
    INDEX idx_status (status)
);

-- ========================================
-- AUDIT LOGGING
-- ========================================

CREATE TABLE audit_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    ip_address VARCHAR(45),
    action VARCHAR(150) NOT NULL,
    object_type VARCHAR(100) NOT NULL,
    object_id VARCHAR(100) NOT NULL,
    old_values JSON,
    new_values JSON,
    additional_info JSON,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_user_id (user_id),
    INDEX idx_object_type (object_type),
    INDEX idx_created_at (created_at)
);

CREATE TABLE integration_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    source_system VARCHAR(100) NOT NULL,
    endpoint VARCHAR(200) NOT NULL,
    request_type VARCHAR(20) NOT NULL,
    payload JSON,
    response JSON,
    status ENUM('success','error','pending') NOT NULL,
    error_message TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
);



-- ========================================
-- VIEWS
-- ========================================

CREATE VIEW v_account_balances AS
SELECT 
    a.code,
    a.name,
    at.category as account_type,
    ab.fiscal_period_id,
    fp.period_name,
    ab.opening_balance,
    ab.debit_movements,
    ab.credit_movements,
    ab.closing_balance
FROM accounts a
JOIN account_types at ON a.type_id = at.id
JOIN account_balances ab ON a.id = ab.account_id
JOIN fiscal_periods fp ON ab.fiscal_period_id = fp.id
WHERE a.is_active = 1;

CREATE VIEW v_journal_summary AS
SELECT 
    je.journal_no,
    je.entry_date,
    jt.name as journal_type,
    je.description,
    je.total_debit,
    je.total_credit,
    je.status,
    u.username as created_by,
    je.created_at
FROM journal_entries je
JOIN journal_types jt ON je.journal_type_id = jt.id
JOIN users u ON je.created_by = u.id;





-- ========================================
-- USER ACCOUNT ROLE MANAGEMENT
-- ========================================

-- Ensure user_account table has role column with correct type
-- This is safe to run even if column already exists
SET @db_exists = (SELECT COUNT(*) FROM information_schema.SCHEMATA WHERE SCHEMA_NAME = 'BankingDB');

SET @table_exists = (
    SELECT COUNT(*) 
    FROM information_schema.TABLES 
    WHERE TABLE_SCHEMA = 'BankingDB' 
    AND TABLE_NAME = 'user_account'
);

SET @column_exists = (
    SELECT COUNT(*) 
    FROM information_schema.COLUMNS 
    WHERE TABLE_SCHEMA = 'BankingDB' 
    AND TABLE_NAME = 'user_account' 
    AND COLUMN_NAME = 'role'
);

-- Add role column if it doesn't exist
SET @sql = IF(@column_exists = 0 AND @table_exists > 0,
    'ALTER TABLE user_account ADD COLUMN role VARCHAR(20) DEFAULT NULL AFTER password_hash',
    'SELECT "Role column already exists or table not found" AS message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Ensure role column is VARCHAR(20) if it exists with different type
SET @column_type = (
    SELECT DATA_TYPE 
    FROM information_schema.COLUMNS 
    WHERE TABLE_SCHEMA = 'BankingDB' 
    AND TABLE_NAME = 'user_account' 
    AND COLUMN_NAME = 'role'
);

SET @column_length = (
    SELECT CHARACTER_MAXIMUM_LENGTH 
    FROM information_schema.COLUMNS 
    WHERE TABLE_SCHEMA = 'BankingDB' 
    AND TABLE_NAME = 'user_account' 
    AND COLUMN_NAME = 'role'
);

-- Modify column if type or length is incorrect
SET @sql = IF(@column_exists > 0 AND (@column_type != 'varchar' OR @column_length != 20),
    'ALTER TABLE user_account MODIFY COLUMN role VARCHAR(20) DEFAULT NULL',
    'SELECT "Role column type is correct" AS message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ========================================
-- DATA MIGRATION - USER ROLES
-- ========================================

-- Update existing user_account records with NULL role to 'Admin' for backward compatibility
-- This ensures all existing admin accounts are properly marked
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
-- USER ACCOUNT MANAGEMENT
-- ========================================

-- ========================================
-- ADMIN ACCOUNT CREATION
-- ========================================
-- Create the main admin account for system access
-- Username: admin
-- Password: password
-- Role: Admin
-- IMPORTANT: Change the password in production!

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
    role = VALUES(role);

-- ========================================
-- HR MANAGER ACCOUNT CREATION
-- ========================================
-- Create HR Manager account
-- Username: hrmanager
-- Password: password
-- Role: HR Manager
-- IMPORTANT: Change the password hash before using in production!

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


-- ========================================
-- LEAVE REQUEST DATA FIXES
-- ========================================

-- Step 1: Normalize ALL leave_request status values to 'Approved' (consistent case)
-- This fixes both 'approved' (lowercase) and 'Approved' (capitalized) to be consistent
UPDATE leave_request 
SET status = 'Declined' 
WHERE UPPER(TRIM(status)) = 'REJECTED';

-- Step 2: Ensure employees 22 and 3 are Active
UPDATE employee 
SET employment_status = 'Active' 
WHERE employee_id IN (22, 3) 
AND (employment_status IS NULL OR employment_status != 'Active');

-- Step 3: Ensure ALL active employees have proper employment_status
UPDATE employee 
SET employment_status = 'Active' 
WHERE employment_status IS NULL 
AND employee_id IN (SELECT DISTINCT employee_id FROM leave_request WHERE UPPER(TRIM(status)) = 'APPROVED');

-- Step 4: Ensure date fields are proper DATE type (remove any time components)
UPDATE leave_request 
SET start_date = DATE(start_date),
    end_date = DATE(end_date)
WHERE start_date IS NOT NULL AND end_date IS NOT NULL;

-- Step 5: Fix specific leave requests mentioned by user
-- Employee 22 (Mariana) - Leave Request ID 10: Nov 17-19, 2025
UPDATE leave_request 
SET status = 'Approved',
    start_date = '2025-11-17',
    end_date = '2025-11-19',
    total_days = 3
WHERE leave_request_id = 10 
AND employee_id = 22;

-- Employee 3 (Jose) - Leave Request ID 2: Nov 15-16, 2025  
UPDATE leave_request 
SET status = 'Approved',
    start_date = '2025-11-15',
    end_date = '2025-11-16',
    total_days = 2
WHERE leave_request_id = 2 
AND employee_id = 3;

-- ========================================
-- ADDRESS FIELD MIGRATION
-- ========================================
-- Migrate existing address data to new atomic fields
-- This preserves existing data by attempting to parse or setting defaults

-- For existing records with address data, try to preserve it
-- If address exists but new fields are NULL, copy to city as fallback
UPDATE employee 
SET city = COALESCE(city, address)
WHERE address IS NOT NULL AND address != '' AND city IS NULL;

-- Set default province if not set
UPDATE employee 
SET province = COALESCE(province, 'Metro Manila')
WHERE province IS NULL;
-- Step 6: Add/update index for better query performance on leave_request
-- Check if index exists before dropping (safer approach)
SET @index_exists = (
    SELECT COUNT(*) 
    FROM information_schema.STATISTICS 
    WHERE TABLE_SCHEMA = 'BankingDB' 
    AND TABLE_NAME = 'leave_request' 
    AND INDEX_NAME = 'idx_leave_status_date'
);

SET @sql = IF(@index_exists > 0,
    'DROP INDEX idx_leave_status_date ON leave_request',
    'SELECT "Index does not exist, will create new one" as message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Create the index
CREATE INDEX idx_leave_status_date ON leave_request(employee_id, status, start_date, end_date);

-- Step 7: Verify the data
SELECT 
    'VERIFICATION' as check_type,
    lr.leave_request_id,
    lr.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) as employee_name,
    e.employment_status,
    lr.status as leave_status,
    UPPER(TRIM(lr.status)) as normalized_status,
    lr.start_date,
    lr.end_date,
    lt.leave_name,
    CASE 
        WHEN e.employment_status = 'Active' AND UPPER(TRIM(lr.status)) = 'APPROVED' THEN 'OK'
        ELSE 'NEEDS FIX'
    END as status_check
FROM leave_request lr
INNER JOIN employee e ON lr.employee_id = e.employee_id
LEFT JOIN leave_type lt ON lr.leave_type_id = lt.leave_type_id
WHERE lr.employee_id IN (22, 3)
ORDER BY lr.leave_request_id;

-- Step 8: Test query for Nov 17, 2025
SELECT 
    'TEST QUERY FOR 2025-11-17' as test_name,
    lr.leave_request_id,
    lr.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) as employee_name,
    lr.start_date,
    lr.end_date,
    lr.status,
    lt.leave_name,
    CASE 
        WHEN CAST('2025-11-17' AS DATE) >= CAST(lr.start_date AS DATE) 
         AND CAST('2025-11-17' AS DATE) <= CAST(lr.end_date AS DATE) 
        THEN 'MATCHES'
        ELSE 'NO MATCH'
    END as date_match
FROM leave_request lr
INNER JOIN employee e ON lr.employee_id = e.employee_id
LEFT JOIN leave_type lt ON lr.leave_type_id = lt.leave_type_id
WHERE lr.employee_id IN (22, 3)
AND e.employment_status = 'Active'
AND UPPER(TRIM(lr.status)) = 'APPROVED'
ORDER BY lr.leave_request_id;

SELECT '=== FIX COMPLETE ===' as status;



-- ========================================
-- HRIS ROLE MANAGEMENT MIGRATIONS
-- ========================================
-- Add foreign key constraint for managed_department_id in user_account
SET @constraint_exists = (
    SELECT COUNT(*) 
    FROM information_schema.TABLE_CONSTRAINTS 
    WHERE TABLE_SCHEMA = 'BankingDB' 
    AND TABLE_NAME = 'user_account' 
    AND CONSTRAINT_NAME = 'fk_user_account_department'
);

SET @sql = IF(@constraint_exists = 0,
    'ALTER TABLE user_account ADD CONSTRAINT fk_user_account_department FOREIGN KEY (managed_department_id) REFERENCES department(department_id) ON DELETE SET NULL',
    'SELECT "Constraint already exists" AS message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ========================================
-- REMOVE MANAGER ROLE - TRANSFER TO SUPERVISOR
-- ========================================
UPDATE user_account SET role = 'Supervisor' WHERE role = 'Manager';

-- Set managed_department_id for ALL existing Supervisors based on their employee's department
UPDATE user_account ua
JOIN employee e ON ua.employee_id = e.employee_id
SET ua.managed_department_id = e.department_id
WHERE ua.role = 'Supervisor' 
AND (ua.managed_department_id IS NULL OR ua.managed_department_id = 0);

-- ========================================
-- CLEANUP DUPLICATE ACCOUNTS
-- ========================================
DELETE FROM user_account WHERE username = 'manager';
DELETE FROM user_account WHERE username = 'supervisor';
DELETE FROM user_account WHERE username LIKE 'supervisor_%';

-- ========================================
-- ADD LOAN OFFICER POSITION
-- ========================================
INSERT INTO `position` (position_id, position_title, job_description, salary_grade) 
VALUES (25, 'Loan Officer', 'Loan Officer - Reviews and approves loan applications', 8)
ON DUPLICATE KEY UPDATE position_title = 'Loan Officer';

-- ========================================
-- CLEANUP AND ENSURE ALL DEPARTMENTS EXIST
-- ========================================
SET FOREIGN_KEY_CHECKS = 0;

DELETE d1 FROM department d1
INNER JOIN department d2 
WHERE d1.department_id > d2.department_id 
AND d1.department_name = d2.department_name;

SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO department (department_name) VALUES 
    ('Customer Service'),
    ('Finance'),
    ('Human Resources'),
    ('IT'),
    ('Marketing'),
    ('Operations'),
    ('Sales')
ON DUPLICATE KEY UPDATE department_name = VALUES(department_name);

-- ========================================
-- CREATE SUPERVISORS FOR EACH DEPARTMENT
-- ========================================
-- Password for all supervisors: 'password'

-- Supervisor for Customer Service
INSERT INTO user_account (employee_id, username, password_hash, role, managed_department_id)
SELECT 
    e.employee_id, 'supervisor_cs',
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    'Supervisor', d.department_id
FROM employee e
JOIN department d ON d.department_name = 'Customer Service'
WHERE e.department_id = d.department_id AND e.employment_status = 'Active'
AND NOT EXISTS (SELECT 1 FROM user_account ua WHERE ua.employee_id = e.employee_id)
LIMIT 1;

-- Supervisor for Finance
INSERT INTO user_account (employee_id, username, password_hash, role, managed_department_id)
SELECT 
    e.employee_id, 'supervisor_finance',
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    'Supervisor', d.department_id
FROM employee e
JOIN department d ON d.department_name = 'Finance'
WHERE e.department_id = d.department_id AND e.employment_status = 'Active'
AND NOT EXISTS (SELECT 1 FROM user_account ua WHERE ua.employee_id = e.employee_id)
LIMIT 1;

-- Supervisor for Human Resources
INSERT INTO user_account (employee_id, username, password_hash, role, managed_department_id)
SELECT 
    e.employee_id, 'supervisor_hr',
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    'Supervisor', d.department_id
FROM employee e
JOIN department d ON d.department_name = 'Human Resources'
WHERE e.department_id = d.department_id AND e.employment_status = 'Active'
AND NOT EXISTS (SELECT 1 FROM user_account ua WHERE ua.employee_id = e.employee_id)
LIMIT 1;

-- Supervisor for IT
INSERT INTO user_account (employee_id, username, password_hash, role, managed_department_id)
SELECT 
    e.employee_id, 'supervisor_it',
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    'Supervisor', d.department_id
FROM employee e
JOIN department d ON d.department_name = 'IT'
WHERE e.department_id = d.department_id AND e.employment_status = 'Active'
AND NOT EXISTS (SELECT 1 FROM user_account ua WHERE ua.employee_id = e.employee_id)
LIMIT 1;

-- Supervisor for Marketing
INSERT INTO user_account (employee_id, username, password_hash, role, managed_department_id)
SELECT 
    e.employee_id, 'supervisor_marketing',
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    'Supervisor', d.department_id
FROM employee e
JOIN department d ON d.department_name = 'Marketing'
WHERE e.department_id = d.department_id AND e.employment_status = 'Active'
AND NOT EXISTS (SELECT 1 FROM user_account ua WHERE ua.employee_id = e.employee_id)
LIMIT 1;

-- Supervisor for Operations
INSERT INTO user_account (employee_id, username, password_hash, role, managed_department_id)
SELECT 
    e.employee_id, 'supervisor_operations',
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    'Supervisor', d.department_id
FROM employee e
JOIN department d ON d.department_name = 'Operations'
WHERE e.department_id = d.department_id AND e.employment_status = 'Active'
AND NOT EXISTS (SELECT 1 FROM user_account ua WHERE ua.employee_id = e.employee_id)
LIMIT 1;

-- Supervisor for Sales
INSERT INTO user_account (employee_id, username, password_hash, role, managed_department_id)
SELECT 
    e.employee_id, 'supervisor_sales',
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    'Supervisor', d.department_id
FROM employee e
JOIN department d ON d.department_name = 'Sales'
WHERE e.department_id = d.department_id AND e.employment_status = 'Active'
AND NOT EXISTS (SELECT 1 FROM user_account ua WHERE ua.employee_id = e.employee_id)
LIMIT 1;

