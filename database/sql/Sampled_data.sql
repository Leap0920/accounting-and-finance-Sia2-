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
-- 2. ACCOUNT TYPES & CHART OF ACCOUNTS
-- ========================================

-- Insert comprehensive account types
INSERT INTO account_types (name, category, description) VALUES
-- Assets
('Current Assets', 'asset', 'Assets expected to be converted to cash within one year'),
('Non-Current Assets', 'asset', 'Long-term assets'),
('Fixed Assets', 'asset', 'Tangible long-term assets'),
('Intangible Assets', 'asset', 'Non-physical assets like patents, trademarks'),
('Accumulated Depreciation', 'asset', 'Contra-asset for depreciation'),

-- Liabilities
('Current Liabilities', 'liability', 'Obligations due within one year'),
('Non-Current Liabilities', 'liability', 'Long-term liabilities'),
('Accrued Liabilities', 'liability', 'Expenses incurred but not yet paid'),
('Deferred Revenue', 'liability', 'Revenue received but not yet earned'),

-- Equity
('Equity', 'equity', 'Owner equity and retained earnings'),
('Capital Stock', 'equity', 'Share capital'),
('Retained Earnings', 'equity', 'Accumulated profits'),

-- Revenue
('Operating Revenue', 'revenue', 'Revenue from primary business operations'),
('Other Revenue', 'revenue', 'Revenue from other sources'),
('Interest Income', 'revenue', 'Interest earned on investments'),

-- Expenses
('Operating Expenses', 'expense', 'Expenses from primary business operations'),
('Administrative Expenses', 'expense', 'General and administrative costs'),
('Cost of Sales', 'expense', 'Direct costs of goods sold'),
('Interest Expense', 'expense', 'Interest paid on loans'),
('Other Expenses', 'expense', 'Non-operating expenses')
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- Get account type IDs
SET @current_assets = (SELECT id FROM account_types WHERE name = 'Current Assets' LIMIT 1);
SET @noncurrent_assets = (SELECT id FROM account_types WHERE name = 'Non-Current Assets' LIMIT 1);
SET @fixed_assets = (SELECT id FROM account_types WHERE name = 'Fixed Assets' LIMIT 1);
SET @intangible_assets = (SELECT id FROM account_types WHERE name = 'Intangible Assets' LIMIT 1);
SET @accum_dep = (SELECT id FROM account_types WHERE name = 'Accumulated Depreciation' LIMIT 1);
SET @current_liabilities = (SELECT id FROM account_types WHERE name = 'Current Liabilities' LIMIT 1);
SET @noncurrent_liabilities = (SELECT id FROM account_types WHERE name = 'Non-Current Liabilities' LIMIT 1);
SET @accrued_liabilities = (SELECT id FROM account_types WHERE name = 'Accrued Liabilities' LIMIT 1);
SET @deferred_revenue = (SELECT id FROM account_types WHERE name = 'Deferred Revenue' LIMIT 1);
SET @equity_type = (SELECT id FROM account_types WHERE name = 'Equity' LIMIT 1);
SET @capital_stock = (SELECT id FROM account_types WHERE name = 'Capital Stock' LIMIT 1);
SET @retained_earnings = (SELECT id FROM account_types WHERE name = 'Retained Earnings' LIMIT 1);
SET @operating_revenue = (SELECT id FROM account_types WHERE name = 'Operating Revenue' LIMIT 1);
SET @other_revenue = (SELECT id FROM account_types WHERE name = 'Other Revenue' LIMIT 1);
SET @interest_income = (SELECT id FROM account_types WHERE name = 'Interest Income' LIMIT 1);
SET @operating_expenses = (SELECT id FROM account_types WHERE name = 'Operating Expenses' LIMIT 1);
SET @admin_expenses = (SELECT id FROM account_types WHERE name = 'Administrative Expenses' LIMIT 1);
SET @cogs = (SELECT id FROM account_types WHERE name = 'Cost of Sales' LIMIT 1);
SET @interest_expense = (SELECT id FROM account_types WHERE name = 'Interest Expense' LIMIT 1);
SET @other_expenses = (SELECT id FROM account_types WHERE name = 'Other Expenses' LIMIT 1);

-- Insert comprehensive chart of accounts
INSERT INTO accounts (code, name, type_id, description, is_active, created_by) VALUES
-- CURRENT ASSETS
('1001', 'Cash on Hand', @current_assets, 'Petty cash fund', TRUE, 1),
('1002', 'Cash in Bank - BDO', @current_assets, 'BDO Unibank current account', TRUE, 1),
('1003', 'Cash in Bank - BPI', @current_assets, 'BPI savings account', TRUE, 1),
('1004', 'Cash in Bank - Metrobank', @current_assets, 'Metrobank payroll account', TRUE, 1),
('1005', 'Cash in Bank - Security Bank', @current_assets, 'Security Bank investment account', TRUE, 1),
('1101', 'Accounts Receivable - Trade', @current_assets, 'Customer receivables', TRUE, 1),
('1102', 'Accounts Receivable - Other', @current_assets, 'Other receivables', TRUE, 1),
('1201', 'Inventory - Raw Materials', @current_assets, 'Raw materials inventory', TRUE, 1),
('1202', 'Inventory - Finished Goods', @current_assets, 'Finished goods inventory', TRUE, 1),
('1203', 'Inventory - Work in Process', @current_assets, 'Work in process inventory', TRUE, 1),
('1301', 'Prepaid Expenses', @current_assets, 'Prepaid rent, insurance, etc.', TRUE, 1),
('1302', 'Prepaid Insurance', @current_assets, 'Insurance premiums paid in advance', TRUE, 1),
('1303', 'Prepaid Rent', @current_assets, 'Rent paid in advance', TRUE, 1),
('1401', 'Other Current Assets', @current_assets, 'Other current assets', TRUE, 1),

-- NON-CURRENT ASSETS
('1501', 'Office Equipment', @fixed_assets, 'Computers, furniture, fixtures', TRUE, 1),
('1502', 'Machinery and Equipment', @fixed_assets, 'Production machinery', TRUE, 1),
('1503', 'Vehicles', @fixed_assets, 'Company vehicles', TRUE, 1),
('1504', 'Building', @fixed_assets, 'Office building', TRUE, 1),
('1505', 'Land', @fixed_assets, 'Land property', TRUE, 1),
('1510', 'Accumulated Depreciation - Equipment', @accum_dep, 'Equipment depreciation', TRUE, 1),
('1511', 'Accumulated Depreciation - Machinery', @accum_dep, 'Machinery depreciation', TRUE, 1),
('1512', 'Accumulated Depreciation - Vehicles', @accum_dep, 'Vehicle depreciation', TRUE, 1),
('1513', 'Accumulated Depreciation - Building', @accum_dep, 'Building depreciation', TRUE, 1),
('1601', 'Intangible Assets', @intangible_assets, 'Patents, trademarks, goodwill', TRUE, 1),
('1602', 'Software Licenses', @intangible_assets, 'Software and licenses', TRUE, 1),
('1701', 'Long-term Investments', @noncurrent_assets, 'Long-term investment securities', TRUE, 1),

-- CURRENT LIABILITIES
('2001', 'Accounts Payable - Trade', @current_liabilities, 'Supplier payables', TRUE, 1),
('2002', 'Accounts Payable - Other', @current_liabilities, 'Other payables', TRUE, 1),
('2101', 'Salaries Payable', @current_liabilities, 'Accrued salaries', TRUE, 1),
('2102', 'Wages Payable', @current_liabilities, 'Accrued wages', TRUE, 1),
('2201', 'Taxes Payable', @current_liabilities, 'Income tax payable', TRUE, 1),
('2202', 'VAT Payable', @current_liabilities, 'Value Added Tax payable', TRUE, 1),
('2203', 'Withholding Tax Payable', @current_liabilities, 'Tax withheld from employees', TRUE, 1),
('2301', 'SSS Payable', @current_liabilities, 'SSS contributions payable', TRUE, 1),
('2302', 'PhilHealth Payable', @current_liabilities, 'PhilHealth contributions payable', TRUE, 1),
('2303', 'Pag-IBIG Payable', @current_liabilities, 'Pag-IBIG contributions payable', TRUE, 1),
('2401', 'Loans Payable - Current', @current_liabilities, 'Short-term loans', TRUE, 1),
('2501', 'Accrued Expenses', @accrued_liabilities, 'Accrued expenses', TRUE, 1),
('2502', 'Accrued Interest', @accrued_liabilities, 'Accrued interest payable', TRUE, 1),
('2601', 'Deferred Revenue', @deferred_revenue, 'Revenue received in advance', TRUE, 1),

-- NON-CURRENT LIABILITIES
('3001', 'Loans Payable - Long Term', @noncurrent_liabilities, 'Long-term bank loans', TRUE, 1),
('3002', 'Bonds Payable', @noncurrent_liabilities, 'Corporate bonds', TRUE, 1),
('3003', 'Mortgage Payable', @noncurrent_liabilities, 'Mortgage loans', TRUE, 1),

-- EQUITY
('4001', 'Capital Stock', @capital_stock, 'Share capital', TRUE, 1),
('4002', 'Additional Paid-in Capital', @equity_type, 'Additional paid-in capital', TRUE, 1),
('4101', 'Retained Earnings', @retained_earnings, 'Accumulated profits', TRUE, 1),
('4102', 'Current Year Profit/Loss', @retained_earnings, 'Current period earnings', TRUE, 1),
('4201', 'Treasury Stock', @equity_type, 'Treasury stock', TRUE, 1),

-- REVENUE
('5001', 'Sales Revenue', @operating_revenue, 'Product sales', TRUE, 1),
('5002', 'Service Revenue', @operating_revenue, 'Service income', TRUE, 1),
('5003', 'Consulting Revenue', @operating_revenue, 'Consulting services', TRUE, 1),
('5004', 'Rental Revenue', @operating_revenue, 'Rental income', TRUE, 1),
('5101', 'Interest Income', @interest_income, 'Bank interest', TRUE, 1),
('5102', 'Dividend Income', @other_revenue, 'Dividend income', TRUE, 1),
('5103', 'Other Income', @other_revenue, 'Miscellaneous income', TRUE, 1),
('5104', 'Gain on Sale of Assets', @other_revenue, 'Gains from asset sales', TRUE, 1),

-- OPERATING EXPENSES
('6001', 'Cost of Goods Sold', @cogs, 'Direct product costs', TRUE, 1),
('6002', 'Cost of Services', @cogs, 'Direct service costs', TRUE, 1),
('6101', 'Salaries and Wages', @operating_expenses, 'Employee compensation', TRUE, 1),
('6102', 'Employee Benefits', @operating_expenses, 'Health insurance, bonuses', TRUE, 1),
('6103', 'Payroll Taxes', @operating_expenses, 'SSS, PhilHealth, Pag-IBIG employer share', TRUE, 1),
('6201', 'Rent Expense', @operating_expenses, 'Office rent', TRUE, 1),
('6202', 'Utilities Expense', @operating_expenses, 'Electricity, water, internet', TRUE, 1),
('6203', 'Office Supplies Expense', @operating_expenses, 'Supplies and materials', TRUE, 1),
('6204', 'Professional Fees', @operating_expenses, 'Legal, accounting, consulting fees', TRUE, 1),
('6205', 'Marketing and Advertising', @operating_expenses, 'Promotional expenses', TRUE, 1),
('6206', 'Transportation and Travel', @operating_expenses, 'Travel costs', TRUE, 1),
('6207', 'Insurance Expense', @operating_expenses, 'Insurance premiums', TRUE, 1),
('6208', 'Depreciation Expense', @operating_expenses, 'Asset depreciation', TRUE, 1),
('6209', 'Repairs and Maintenance', @operating_expenses, 'Equipment maintenance', TRUE, 1),
('6210', 'Communication Expense', @operating_expenses, 'Phone, internet, postage', TRUE, 1),

-- ADMINISTRATIVE EXPENSES
('7001', 'General and Administrative', @admin_expenses, 'General administrative costs', TRUE, 1),
('7002', 'Management Salaries', @admin_expenses, 'Management compensation', TRUE, 1),
('7003', 'Office Equipment Expense', @admin_expenses, 'Office equipment costs', TRUE, 1),
('7004', 'Training and Development', @admin_expenses, 'Employee training', TRUE, 1),
('7005', 'Research and Development', @admin_expenses, 'R&D expenses', TRUE, 1),

-- OTHER EXPENSES
('8001', 'Interest Expense', @interest_expense, 'Loan interest', TRUE, 1),
('8002', 'Bank Charges', @other_expenses, 'Bank fees and charges', TRUE, 1),
('8003', 'Bad Debt Expense', @other_expenses, 'Uncollectible accounts', TRUE, 1),
('8004', 'Loss on Sale of Assets', @other_expenses, 'Losses from asset sales', TRUE, 1),
('8005', 'Miscellaneous Expense', @other_expenses, 'Other expenses', TRUE, 1)
ON DUPLICATE KEY UPDATE name = VALUES(name);

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
-- 7. EXPENSE CATEGORIES
-- ========================================

-- Note: Some categories reference EXP-001 through EXP-005 accounts for backward compatibility
INSERT INTO expense_categories (code, name, account_id, description, is_active) VALUES
('OFFICE', 'Office Supplies', (SELECT id FROM accounts WHERE code = '6203'), 'Office supplies and materials', TRUE),
('TRAVEL', 'Travel & Transportation', (SELECT id FROM accounts WHERE code = '6206'), 'Business travel expenses', TRUE),
('MEALS', 'Meals & Entertainment', (SELECT id FROM accounts WHERE code = '6205'), 'Business meals and entertainment', TRUE),
('UTILITIES', 'Utilities', (SELECT id FROM accounts WHERE code = '6202'), 'Electricity, water, internet', TRUE),
('FACILITIES', 'Facilities', (SELECT id FROM accounts WHERE code = '6201'), 'Office rent and facilities', TRUE),
('TRAINING', 'Training & Development', (SELECT id FROM accounts WHERE code = '7004'), 'Employee training and development', TRUE),
('EQUIPMENT', 'Equipment', (SELECT id FROM accounts WHERE code = '1501'), 'Office equipment and tools', TRUE),
('MARKETING', 'Marketing & Advertising', (SELECT id FROM accounts WHERE code = '6205'), 'Marketing and advertising expenses', TRUE),
('PROFESSIONAL', 'Professional Services', (SELECT id FROM accounts WHERE code = '6204'), 'Legal, accounting, consulting fees', TRUE),
('INSURANCE', 'Insurance', (SELECT id FROM accounts WHERE code = '6207'), 'Insurance premiums', TRUE),
('MAINTENANCE', 'Repairs & Maintenance', (SELECT id FROM accounts WHERE code = '6209'), 'Equipment maintenance and repairs', TRUE),
('COMM', 'Communication', (SELECT id FROM accounts WHERE code = '6210'), 'Phone, internet, and communication costs', TRUE),
('COMMUNICATION', 'Communication Services', (SELECT id FROM accounts WHERE code = '6210'), 'Phone, internet, postage', TRUE)
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- Insert backup accounts for expense categories (if they don't exist)
INSERT IGNORE INTO accounts (code, name, type_id, description, is_active, created_by) VALUES
('EXP-001', 'Travel Expenses', (SELECT id FROM account_types WHERE category = 'expense' LIMIT 1), 'Business travel and transportation costs', TRUE, 1),
('EXP-002', 'Meals & Entertainment', (SELECT id FROM account_types WHERE category = 'expense' LIMIT 1), 'Business meals and client entertainment', TRUE, 1),
('EXP-003', 'Office Supplies', (SELECT id FROM account_types WHERE category = 'expense' LIMIT 1), 'Office supplies and equipment', TRUE, 1),
('EXP-004', 'Communication Expenses', (SELECT id FROM account_types WHERE category = 'expense' LIMIT 1), 'Phone, internet, and communication costs', TRUE, 1),
('EXP-005', 'Training & Development', (SELECT id FROM account_types WHERE category = 'expense' LIMIT 1), 'Employee training and development', TRUE, 1)
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
-- 9. COMPREHENSIVE JOURNAL ENTRIES
-- ========================================

-- Get account IDs for journal entries
SET @cash_hand = (SELECT id FROM accounts WHERE code = '1001');
SET @cash_bdo = (SELECT id FROM accounts WHERE code = '1002');
SET @cash_bpi = (SELECT id FROM accounts WHERE code = '1003');
SET @cash_metro = (SELECT id FROM accounts WHERE code = '1004');
SET @cash_security = (SELECT id FROM accounts WHERE code = '1005');
SET @ar_trade = (SELECT id FROM accounts WHERE code = '1101');
SET @ar_other = (SELECT id FROM accounts WHERE code = '1102');
SET @inventory_raw = (SELECT id FROM accounts WHERE code = '1201');
SET @inventory_finished = (SELECT id FROM accounts WHERE code = '1202');
SET @inventory_wip = (SELECT id FROM accounts WHERE code = '1203');
SET @prepaid_exp = (SELECT id FROM accounts WHERE code = '1301');
SET @prepaid_insurance = (SELECT id FROM accounts WHERE code = '1302');
SET @prepaid_rent = (SELECT id FROM accounts WHERE code = '1303');
SET @equipment = (SELECT id FROM accounts WHERE code = '1501');
SET @machinery = (SELECT id FROM accounts WHERE code = '1502');
SET @vehicles = (SELECT id FROM accounts WHERE code = '1503');
SET @building = (SELECT id FROM accounts WHERE code = '1504');
SET @land = (SELECT id FROM accounts WHERE code = '1505');
SET @accum_dep_equip = (SELECT id FROM accounts WHERE code = '1510');
SET @accum_dep_mach = (SELECT id FROM accounts WHERE code = '1511');
SET @accum_dep_veh = (SELECT id FROM accounts WHERE code = '1512');
SET @accum_dep_build = (SELECT id FROM accounts WHERE code = '1513');
SET @intangible = (SELECT id FROM accounts WHERE code = '1601');
SET @software = (SELECT id FROM accounts WHERE code = '1602');
SET @investments = (SELECT id FROM accounts WHERE code = '1701');

SET @ap_trade = (SELECT id FROM accounts WHERE code = '2001');
SET @ap_other = (SELECT id FROM accounts WHERE code = '2002');
SET @salaries_payable = (SELECT id FROM accounts WHERE code = '2101');
SET @wages_payable = (SELECT id FROM accounts WHERE code = '2102');
SET @taxes_payable = (SELECT id FROM accounts WHERE code = '2201');
SET @vat_payable = (SELECT id FROM accounts WHERE code = '2202');
SET @wht_payable = (SELECT id FROM accounts WHERE code = '2203');
SET @sss_payable = (SELECT id FROM accounts WHERE code = '2301');
SET @philhealth_payable = (SELECT id FROM accounts WHERE code = '2302');
SET @pagibig_payable = (SELECT id FROM accounts WHERE code = '2303');
SET @loan_current = (SELECT id FROM accounts WHERE code = '2401');
SET @accrued_exp = (SELECT id FROM accounts WHERE code = '2501');
SET @accrued_int = (SELECT id FROM accounts WHERE code = '2502');
SET @deferred_rev = (SELECT id FROM accounts WHERE code = '2601');

SET @loan_longterm = (SELECT id FROM accounts WHERE code = '3001');
SET @bonds_payable = (SELECT id FROM accounts WHERE code = '3002');
SET @mortgage_payable = (SELECT id FROM accounts WHERE code = '3003');

SET @capital_stock = (SELECT id FROM accounts WHERE code = '4001');
SET @paid_in_capital = (SELECT id FROM accounts WHERE code = '4002');
SET @retained_earnings = (SELECT id FROM accounts WHERE code = '4101');
SET @current_year_pl = (SELECT id FROM accounts WHERE code = '4102');
SET @treasury_stock = (SELECT id FROM accounts WHERE code = '4201');

SET @sales_revenue = (SELECT id FROM accounts WHERE code = '5001');
SET @service_revenue = (SELECT id FROM accounts WHERE code = '5002');
SET @consulting_revenue = (SELECT id FROM accounts WHERE code = '5003');
SET @rental_revenue = (SELECT id FROM accounts WHERE code = '5004');
SET @interest_income = (SELECT id FROM accounts WHERE code = '5101');
SET @dividend_income = (SELECT id FROM accounts WHERE code = '5102');
SET @other_income = (SELECT id FROM accounts WHERE code = '5103');
SET @gain_sale_assets = (SELECT id FROM accounts WHERE code = '5104');

SET @cogs = (SELECT id FROM accounts WHERE code = '6001');
SET @cost_services = (SELECT id FROM accounts WHERE code = '6002');
SET @salaries_wages = (SELECT id FROM accounts WHERE code = '6101');
SET @employee_benefits = (SELECT id FROM accounts WHERE code = '6102');
SET @payroll_taxes = (SELECT id FROM accounts WHERE code = '6103');
SET @rent_expense = (SELECT id FROM accounts WHERE code = '6201');
SET @utilities_expense = (SELECT id FROM accounts WHERE code = '6202');
SET @office_supplies = (SELECT id FROM accounts WHERE code = '6203');
SET @professional_fees = (SELECT id FROM accounts WHERE code = '6204');
SET @marketing_advertising = (SELECT id FROM accounts WHERE code = '6205');
SET @transportation_travel = (SELECT id FROM accounts WHERE code = '6206');
SET @insurance_expense = (SELECT id FROM accounts WHERE code = '6207');
SET @depreciation_expense = (SELECT id FROM accounts WHERE code = '6208');
SET @repairs_maintenance = (SELECT id FROM accounts WHERE code = '6209');
SET @communication_expense = (SELECT id FROM accounts WHERE code = '6210');

SET @general_admin = (SELECT id FROM accounts WHERE code = '7001');
SET @management_salaries = (SELECT id FROM accounts WHERE code = '7002');
SET @office_equipment_exp = (SELECT id FROM accounts WHERE code = '7003');
SET @training_development = (SELECT id FROM accounts WHERE code = '7004');
SET @research_development = (SELECT id FROM accounts WHERE code = '7005');

SET @interest_expense = (SELECT id FROM accounts WHERE code = '8001');
SET @bank_charges = (SELECT id FROM accounts WHERE code = '8002');
SET @bad_debt_expense = (SELECT id FROM accounts WHERE code = '8003');
SET @loss_sale_assets = (SELECT id FROM accounts WHERE code = '8004');
SET @miscellaneous_expense = (SELECT id FROM accounts WHERE code = '8005');

-- Get journal type IDs
SET @gj_type = (SELECT id FROM journal_types WHERE code = 'GJ');
SET @cr_type = (SELECT id FROM journal_types WHERE code = 'CR');
SET @cd_type = (SELECT id FROM journal_types WHERE code = 'CD');
SET @pr_type = (SELECT id FROM journal_types WHERE code = 'PR');
SET @ap_type = (SELECT id FROM journal_types WHERE code = 'AP');
SET @ar_type = (SELECT id FROM journal_types WHERE code = 'AR');
SET @aj_type = (SELECT id FROM journal_types WHERE code = 'AJ');

-- Get fiscal period IDs
SET @fiscal_q1_2025 = (SELECT id FROM fiscal_periods WHERE period_name = 'FY2025-Q1');
SET @fiscal_q2_2025 = (SELECT id FROM fiscal_periods WHERE period_name = 'FY2025-Q2');
SET @fiscal_q3_2025 = (SELECT id FROM fiscal_periods WHERE period_name = 'FY2025-Q3');
SET @fiscal_q4_2025 = (SELECT id FROM fiscal_periods WHERE period_name = 'FY2025-Q4');
SET @jan_2025 = (SELECT id FROM fiscal_periods WHERE period_name = 'January 2025');
SET @feb_2025 = (SELECT id FROM fiscal_periods WHERE period_name = 'February 2025');
SET @mar_2025 = (SELECT id FROM fiscal_periods WHERE period_name = 'March 2025');
SET @apr_2025 = (SELECT id FROM fiscal_periods WHERE period_name = 'April 2025');
SET @may_2025 = (SELECT id FROM fiscal_periods WHERE period_name = 'May 2025');
SET @jun_2025 = (SELECT id FROM fiscal_periods WHERE period_name = 'June 2025');
SET @jul_2025 = (SELECT id FROM fiscal_periods WHERE period_name = 'July 2025');
SET @aug_2025 = (SELECT id FROM fiscal_periods WHERE period_name = 'August 2025');
SET @sep_2025 = (SELECT id FROM fiscal_periods WHERE period_name = 'September 2025');
SET @oct_2025 = (SELECT id FROM fiscal_periods WHERE period_name = 'October 2025');
SET @nov_2025 = (SELECT id FROM fiscal_periods WHERE period_name = 'November 2025');
SET @dec_2025 = (SELECT id FROM fiscal_periods WHERE period_name = 'December 2025');

-- 2026 Fiscal Period Variables
SET @fiscal_q1_2026 = (SELECT id FROM fiscal_periods WHERE period_name = 'FY2026-Q1');
SET @jan_2026 = (SELECT id FROM fiscal_periods WHERE period_name = 'January 2026');
SET @feb_2026 = (SELECT id FROM fiscal_periods WHERE period_name = 'February 2026');
SET @mar_2026 = (SELECT id FROM fiscal_periods WHERE period_name = 'March 2026');

-- Additional journal type variables
SET @sal_type = (SELECT id FROM journal_types WHERE code = 'SAL');
SET @pur_type = (SELECT id FROM journal_types WHERE code = 'PUR');
SET @bank_type = (SELECT id FROM journal_types WHERE code = 'BANK');

-- ========================================
-- 8.5 BANKING & REPORTING DATA
-- ========================================

-- Populate transaction_types
INSERT INTO transaction_types (type_name, description) VALUES
('Deposit', 'Cash or check deposit into account'),
('Withdrawal', 'Cash withdrawal from account'),
('Transfer In', 'Incoming transfer from another account'),
('Transfer Out', 'Outgoing transfer to another account'),
('Fee', 'Service charge or bank fee'),
('Interest Payment', 'Interest earned on deposits'),
('Loan Payment', 'Payment towards an active loan')
ON DUPLICATE KEY UPDATE description = VALUES(description);

-- Populate bank_customers (50 realistic Filipino customers)
INSERT INTO bank_customers (customer_id, first_name, last_name, email, phone, address) VALUES
(1, 'Juan Carlos', 'Santos', 'juancarlos.santos@gmail.com', '09171234567', 'Makati City, Metro Manila'),
(2, 'Maria Elena', 'Rodriguez', 'mariaelena.rodriguez@yahoo.com', '09181234568', 'BGC, Taguig City'),
(3, 'Jose Miguel', 'Cruz', 'josemiguel.cruz@gmail.com', '09191234569', 'Ortigas, Pasig City'),
(4, 'Ana Patricia', 'Lopez', 'anapatricia.lopez@outlook.com', '09201234570', 'Mandaluyong City'),
(5, 'Roberto Antonio', 'Garcia', 'roberto.garcia@gmail.com', '09211234571', 'Quezon City'),
(6, 'Carmen Sofia', 'Martinez', 'carmen.martinez@yahoo.com', '09221234572', 'San Juan City'),
(7, 'Fernando Luis', 'Torres', 'fernando.torres@gmail.com', '09231234573', 'Pasay City'),
(8, 'Isabella Rose', 'Flores', 'isabella.flores@outlook.com', '09241234574', 'Makati City'),
(9, 'Miguel Angel', 'Reyes', 'miguel.reyes@gmail.com', '09251234575', 'Taguig City'),
(10, 'Sofia Grace', 'Villanueva', 'sofia.villanueva@yahoo.com', '09261234576', 'Mandaluyong City'),
(11, 'Carlos Eduardo', 'Mendoza', 'carlos.mendoza@gmail.com', '09271234577', 'Pasig City'),
(12, 'Patricia Isabel', 'Gutierrez', 'patricia.gutierrez@outlook.com', '09281234578', 'Quezon City'),
(13, 'Ricardo Manuel', 'Herrera', 'ricardo.herrera@gmail.com', '09291234579', 'Manila City'),
(14, 'Gabriela Alejandra', 'Morales', 'gabriela.morales@yahoo.com', '09301234580', 'Makati City'),
(15, 'Diego Fernando', 'Ramos', 'diego.ramos@gmail.com', '09311234581', 'Taguig City'),
(16, 'Renato Jose', 'Bautista', 'renato.bautista@gmail.com', '09171345678', 'Cebu City, Cebu'),
(17, 'Lourdes Marie', 'Dela Cruz', 'lourdes.delacruz@yahoo.com', '09181456789', 'Davao City, Davao del Sur'),
(18, 'Emmanuel Pedro', 'Aquino', 'emmanuel.aquino@gmail.com', '09191567890', 'Iloilo City, Iloilo'),
(19, 'Christine Joy', 'Navarro', 'christine.navarro@outlook.com', '09201678901', 'Cagayan de Oro City'),
(20, 'Antonio Rafael', 'Pascual', 'antonio.pascual@gmail.com', '09211789012', 'Zamboanga City'),
(21, 'Mary Ann', 'Tolentino', 'maryann.tolentino@yahoo.com', '09221890123', 'Bacolod City, Negros Occidental'),
(22, 'Francis Xavier', 'Dimaculangan', 'francis.dimaculangan@gmail.com', '09231901234', 'General Santos City'),
(23, 'Rosario Carmen', 'Evangelista', 'rosario.evangelista@outlook.com', '09242012345', 'Baguio City, Benguet'),
(24, 'Mark Anthony', 'Salazar', 'mark.salazar@gmail.com', '09252123456', 'Angeles City, Pampanga'),
(25, 'Angelica Mae', 'De Leon', 'angelica.deleon@yahoo.com', '09262234567', 'Antipolo City, Rizal'),
(26, 'Raymond Paul', 'Villarosa', 'raymond.villarosa@gmail.com', '09272345678', 'Calamba City, Laguna'),
(27, 'Theresa Marie', 'Santiago', 'theresa.santiago@outlook.com', '09282456789', 'Lipa City, Batangas'),
(28, 'Benedict John', 'Concepcion', 'benedict.concepcion@gmail.com', '09292567890', 'San Fernando, Pampanga'),
(29, 'Jasmine Nicole', 'Del Rosario', 'jasmine.delrosario@yahoo.com', '09302678901', 'Naga City, Camarines Sur'),
(30, 'Vincent James', 'Aguilar', 'vincent.aguilar@gmail.com', '09312789012', 'Legazpi City, Albay'),
(31, 'Catherine Rose', 'Manalo', 'catherine.manalo@outlook.com', '09172890123', 'Lucena City, Quezon'),
(32, 'Daniel Joseph', 'Soriano', 'daniel.soriano@gmail.com', '09182901234', 'Tagaytay City, Cavite'),
(33, 'Eleanor Faith', 'Panganiban', 'eleanor.panganiban@yahoo.com', '09193012345', 'Olongapo City, Zambales'),
(34, 'Gerald Patrick', 'Laurel', 'gerald.laurel@gmail.com', '09203123456', 'Dagupan City, Pangasinan'),
(35, 'Hannah Marie', 'Bondoc', 'hannah.bondoc@outlook.com', '09213234567', 'Urdaneta City, Pangasinan'),
(36, 'Ian Christopher', 'Magbanua', 'ian.magbanua@gmail.com', '09223345678', 'Roxas City, Capiz'),
(37, 'Joanne Patricia', 'Lagman', 'joanne.lagman@yahoo.com', '09233456789', 'Tacloban City, Leyte'),
(38, 'Kenneth Ray', 'Dizon', 'kenneth.dizon@gmail.com', '09243567890', 'Butuan City, Agusan del Norte'),
(39, 'Lovely Grace', 'Magsaysay', 'lovely.magsaysay@outlook.com', '09253678901', 'Tuguegarao City, Cagayan'),
(40, 'Marco Paulo', 'Abad', 'marco.abad@gmail.com', '09263789012', 'Santiago City, Isabela'),
(41, 'Nina Beatriz', 'Ocampo', 'nina.ocampo@yahoo.com', '09273890123', 'Cabanatuan City, Nueva Ecija'),
(42, 'Oliver Martin', 'Enriquez', 'oliver.enriquez@gmail.com', '09283901234', 'Tarlac City, Tarlac'),
(43, 'Princess Dianne', 'Resurreccion', 'princess.resurreccion@outlook.com', '09294012345', 'Meycauayan City, Bulacan'),
(44, 'Raphael Luis', 'Tan', 'raphael.tan@gmail.com', '09304123456', 'Malolos City, Bulacan'),
(45, 'Samantha Claire', 'Lim', 'samantha.lim@yahoo.com', '09314234567', 'Binan City, Laguna'),
(46, 'Timothy John', 'Chua', 'timothy.chua@gmail.com', '09174345678', 'Santa Rosa City, Laguna'),
(47, 'Ursula Anne', 'Go', 'ursula.go@outlook.com', '09184456789', 'Dasmarinas City, Cavite'),
(48, 'Wilhelm Franz', 'Sy', 'wilhelm.sy@gmail.com', '09194567890', 'Imus City, Cavite'),
(49, 'Ximena Rosa', 'Ong', 'ximena.ong@yahoo.com', '09204678901', 'Bacoor City, Cavite'),
(50, 'Zachary Miguel', 'Yu', 'zachary.yu@gmail.com', '09214789012', 'General Trias City, Cavite')
ON DUPLICATE KEY UPDATE first_name = VALUES(first_name);

-- Populate customer_accounts (75 accounts with realistic AC-xxx codes)
INSERT INTO customer_accounts (account_id, customer_id, account_number, account_type, balance, status) VALUES
(1, 1, 'AC-101', 'savings', 185000.00, 'active'),
(2, 1, 'AC-102', 'checking', 92000.00, 'active'),
(3, 2, 'AC-103', 'savings', 520000.00, 'active'),
(4, 2, 'AC-104', 'business', 1250000.00, 'active'),
(5, 3, 'AC-105', 'savings', 310000.00, 'active'),
(6, 4, 'AC-106', 'savings', 175000.00, 'active'),
(7, 5, 'AC-107', 'savings', 420000.00, 'active'),
(8, 5, 'AC-108', 'checking', 88000.00, 'active'),
(9, 6, 'AC-109', 'savings', 95000.00, 'active'),
(10, 7, 'AC-110', 'savings', 130000.00, 'active'),
(11, 8, 'AC-111', 'savings', 72000.00, 'active'),
(12, 9, 'AC-112', 'savings', 245000.00, 'active'),
(13, 10, 'AC-113', 'savings', 68000.00, 'active'),
(14, 11, 'AC-114', 'savings', 110000.00, 'active'),
(15, 12, 'AC-115', 'savings', 55000.00, 'active'),
(16, 13, 'AC-116', 'savings', 85000.00, 'active'),
(17, 14, 'AC-117', 'savings', 42000.00, 'active'),
(18, 15, 'AC-118', 'savings', 78000.00, 'active'),
(19, 3, 'AC-119', 'checking', 195000.00, 'active'),
(20, 7, 'AC-120', 'business', 350000.00, 'active'),
(21, 16, 'AC-121', 'savings', 267500.00, 'active'),
(22, 16, 'AC-122', 'checking', 143000.00, 'active'),
(23, 17, 'AC-123', 'savings', 489000.00, 'active'),
(24, 18, 'AC-124', 'savings', 156800.00, 'active'),
(25, 18, 'AC-125', 'business', 875000.00, 'active'),
(26, 19, 'AC-126', 'savings', 312400.00, 'active'),
(27, 20, 'AC-127', 'savings', 98500.00, 'active'),
(28, 21, 'AC-128', 'savings', 224000.00, 'active'),
(29, 21, 'AC-129', 'checking', 67300.00, 'active'),
(30, 22, 'AC-130', 'savings', 541000.00, 'active'),
(31, 23, 'AC-131', 'savings', 183200.00, 'active'),
(32, 24, 'AC-132', 'savings', 396000.00, 'active'),
(33, 24, 'AC-133', 'business', 1120000.00, 'active'),
(34, 25, 'AC-134', 'savings', 275400.00, 'active'),
(35, 26, 'AC-135', 'savings', 148700.00, 'active'),
(36, 27, 'AC-136', 'savings', 89200.00, 'active'),
(37, 28, 'AC-137', 'savings', 462000.00, 'active'),
(38, 28, 'AC-138', 'checking', 118500.00, 'active'),
(39, 29, 'AC-139', 'savings', 203600.00, 'active'),
(40, 30, 'AC-140', 'savings', 337800.00, 'active'),
(41, 31, 'AC-141', 'savings', 54200.00, 'active'),
(42, 32, 'AC-142', 'savings', 189000.00, 'active'),
(43, 32, 'AC-143', 'business', 760000.00, 'active'),
(44, 33, 'AC-144', 'savings', 125300.00, 'active'),
(45, 34, 'AC-145', 'savings', 298700.00, 'active'),
(46, 35, 'AC-146', 'savings', 73600.00, 'active'),
(47, 36, 'AC-147', 'savings', 412500.00, 'active'),
(48, 37, 'AC-148', 'savings', 167800.00, 'active'),
(49, 37, 'AC-149', 'checking', 84200.00, 'active'),
(50, 38, 'AC-150', 'savings', 236000.00, 'active'),
(51, 39, 'AC-151', 'savings', 18200.00, 'active'),
(52, 40, 'AC-152', 'savings', 592000.00, 'active'),
(53, 40, 'AC-153', 'business', 2480000.00, 'active'),
(54, 41, 'AC-154', 'savings', 145600.00, 'active'),
(55, 42, 'AC-155', 'savings', 287300.00, 'active'),
(56, 42, 'AC-156', 'checking', 93400.00, 'active'),
(57, 43, 'AC-157', 'savings', 178900.00, 'active'),
(58, 44, 'AC-158', 'savings', 356200.00, 'active'),
(59, 45, 'AC-159', 'savings', 112800.00, 'active'),
(60, 45, 'AC-160', 'business', 945000.00, 'active'),
(61, 46, 'AC-161', 'savings', 264500.00, 'active'),
(62, 46, 'AC-162', 'checking', 78900.00, 'active'),
(63, 47, 'AC-163', 'savings', 193200.00, 'active'),
(64, 48, 'AC-164', 'savings', 421700.00, 'active'),
(65, 48, 'AC-165', 'business', 1580000.00, 'active'),
(66, 49, 'AC-166', 'savings', 87400.00, 'active'),
(67, 49, 'AC-167', 'checking', 56200.00, 'active'),
(68, 50, 'AC-168', 'savings', 315600.00, 'active'),
(69, 50, 'AC-169', 'business', 1230000.00, 'active'),
(70, 16, 'AC-170', 'business', 680000.00, 'active'),
(71, 23, 'AC-171', 'checking', 102400.00, 'active'),
(72, 30, 'AC-172', 'business', 890000.00, 'active'),
(73, 34, 'AC-173', 'checking', 76300.00, 'active'),
(74, 39, 'AC-174', 'checking', 45800.00, 'active'),
(75, 41, 'AC-175', 'business', 520000.00, 'active')
ON DUPLICATE KEY UPDATE balance = VALUES(balance);

-- Populate bank_transactions (realistic accounting transactions)
INSERT INTO bank_transactions (transaction_ref, account_id, transaction_type_id, amount, description, created_at) VALUES
-- January 2025 - Deposits (Salary deposits, client payments)
('TXN-2025-0001', 1, 1, 65000.00, 'Cash in - Salary deposit January 2025', '2025-01-15 10:00:00'),
('TXN-2025-0002', 3, 1, 200000.00, 'Cash in - Salary deposit January 2025', '2025-01-15 10:05:00'),
('TXN-2025-0003', 5, 1, 220000.00, 'Cash in - Salary deposit January 2025', '2025-01-15 10:10:00'),
('TXN-2025-0004', 4, 1, 850000.00, 'Cash in - Client payment ABC Corp Invoice INV-2025-001', '2025-01-20 14:30:00'),
('TXN-2025-0005', 7, 1, 200000.00, 'Cash in - Salary deposit January 2025', '2025-01-15 10:15:00'),
('TXN-2025-0006', 20, 1, 450000.00, 'Cash in - Sales collection from XYZ Trading', '2025-01-25 11:00:00'),
-- January 2025 - Withdrawals (Operating expenses)
('TXN-2025-0007', 2, 2, 100000.00, 'Cash out - Office rent payment January', '2025-01-05 09:00:00'),
('TXN-2025-0008', 2, 2, 75000.00, 'Cash out - Utilities payment January', '2025-01-10 14:00:00'),
('TXN-2025-0009', 8, 2, 50000.00, 'Cash out - Office supplies purchase', '2025-01-12 11:30:00'),
-- January 2025 - Transfers
('TXN-2025-0010', 4, 3, 500000.00, 'Transfer money in - From BDO main account', '2025-01-08 09:30:00'),
('TXN-2025-0011', 2, 4, 500000.00, 'Transfer money out - To BPI operations', '2025-01-08 09:30:00'),
-- January 2025 - Interest
('TXN-2025-0012', 3, 6, 4500.00, 'Interest earned - Savings account Jan', '2025-01-31 23:59:00'),
('TXN-2025-0013', 7, 6, 3200.00, 'Interest earned - Savings account Jan', '2025-01-31 23:59:00'),
-- January 2025 - Fees
('TXN-2025-0014', 2, 5, 500.00, 'Bank service fee - January', '2025-01-31 23:00:00'),

-- February 2025
('TXN-2025-0015', 1, 1, 65000.00, 'Cash in - Salary deposit February 2025', '2025-02-14 10:00:00'),
('TXN-2025-0016', 3, 1, 200000.00, 'Cash in - Salary deposit February 2025', '2025-02-14 10:05:00'),
('TXN-2025-0017', 4, 1, 620000.00, 'Cash in - Client payment DEF Industries INV-2025-012', '2025-02-18 15:00:00'),
('TXN-2025-0018', 20, 1, 380000.00, 'Cash in - Sales collection from LMN Corp', '2025-02-22 10:30:00'),
('TXN-2025-0019', 2, 2, 100000.00, 'Cash out - Office rent payment February', '2025-02-03 09:00:00'),
('TXN-2025-0020', 2, 2, 80000.00, 'Cash out - Utilities payment February', '2025-02-08 14:00:00'),
('TXN-2025-0021', 8, 2, 150000.00, 'Cash out - Marketing campaign payment', '2025-02-15 11:00:00'),
('TXN-2025-0022', 3, 6, 5200.00, 'Interest earned - Savings account Feb', '2025-02-28 23:59:00'),
('TXN-2025-0023', 2, 5, 500.00, 'Bank service fee - February', '2025-02-28 23:00:00'),
-- February 2025 - Loan Payment
('TXN-2025-0024', 1, 7, 4500.00, 'Paid loan - Salary loan installment LN-1001', '2025-02-01 10:00:00'),
('TXN-2025-0025', 5, 7, 8000.00, 'Paid loan - Housing loan installment LN-1004', '2025-02-01 10:00:00'),

-- March 2025
('TXN-2025-0026', 1, 1, 65000.00, 'Cash in - Salary deposit March 2025', '2025-03-14 10:00:00'),
('TXN-2025-0027', 4, 1, 950000.00, 'Cash in - Major client payment GHI Group INV-2025-020', '2025-03-10 14:00:00'),
('TXN-2025-0028', 6, 1, 120000.00, 'Cash in - Salary deposit March 2025', '2025-03-14 10:05:00'),
('TXN-2025-0029', 2, 2, 100000.00, 'Cash out - Office rent payment March', '2025-03-03 09:00:00'),
('TXN-2025-0030', 2, 2, 78000.00, 'Cash out - Utilities payment March', '2025-03-07 14:00:00'),
('TXN-2025-0031', 8, 2, 80000.00, 'Cash out - Professional fees legal consultation', '2025-03-20 16:00:00'),
('TXN-2025-0032', 4, 3, 300000.00, 'Transfer money in - From Security Bank investment', '2025-03-15 10:00:00'),
('TXN-2025-0033', 8, 4, 300000.00, 'Transfer money out - To BPI operations', '2025-03-15 10:00:00'),
('TXN-2025-0034', 3, 6, 5800.00, 'Interest earned - Savings account Mar', '2025-03-31 23:59:00'),
('TXN-2025-0035', 1, 7, 4500.00, 'Paid loan - Salary loan installment LN-1001', '2025-03-01 10:00:00'),

-- April 2025 - Q2
('TXN-2025-0036', 4, 1, 720000.00, 'Cash in - Client payment JKL Solutions INV-2025-031', '2025-04-08 11:00:00'),
('TXN-2025-0037', 20, 1, 550000.00, 'Cash in - Sales collection April batch', '2025-04-20 14:00:00'),
('TXN-2025-0038', 1, 1, 65000.00, 'Cash in - Salary deposit April 2025', '2025-04-15 10:00:00'),
('TXN-2025-0039', 2, 2, 100000.00, 'Cash out - Office rent payment April', '2025-04-02 09:00:00'),
('TXN-2025-0040', 2, 2, 82000.00, 'Cash out - Utilities payment April', '2025-04-10 14:00:00'),
('TXN-2025-0041', 8, 2, 35000.00, 'Cash out - Office equipment purchase', '2025-04-18 11:00:00'),
('TXN-2025-0042', 3, 6, 5500.00, 'Interest earned - Savings account Apr', '2025-04-30 23:59:00'),
('TXN-2025-0043', 2, 5, 500.00, 'Bank service fee - April', '2025-04-30 23:00:00'),
('TXN-2025-0044', 5, 7, 8000.00, 'Paid loan - Housing loan installment LN-1004', '2025-04-01 10:00:00'),

-- May 2025
('TXN-2025-0045', 4, 1, 680000.00, 'Cash in - Client payment MNO Holdings INV-2025-042', '2025-05-12 10:30:00'),
('TXN-2025-0046', 20, 1, 420000.00, 'Cash in - Sales collection May batch', '2025-05-22 15:00:00'),
('TXN-2025-0047', 2, 2, 100000.00, 'Cash out - Office rent payment May', '2025-05-02 09:00:00'),
('TXN-2025-0048', 2, 2, 85000.00, 'Cash out - Utilities payment May', '2025-05-09 14:00:00'),
('TXN-2025-0049', 3, 6, 5600.00, 'Interest earned - Savings account May', '2025-05-31 23:59:00'),
('TXN-2025-0050', 1, 7, 4500.00, 'Paid loan - Salary loan installment LN-1001', '2025-05-01 10:00:00'),

-- June 2025
('TXN-2025-0051', 4, 1, 890000.00, 'Cash in - Client payment PQR Corp INV-2025-055', '2025-06-10 11:00:00'),
('TXN-2025-0052', 20, 1, 510000.00, 'Cash in - Sales collection June batch', '2025-06-25 14:00:00'),
('TXN-2025-0053', 2, 2, 100000.00, 'Cash out - Office rent payment June', '2025-06-02 09:00:00'),
('TXN-2025-0054', 8, 2, 45000.00, 'Cash out - Training and development costs', '2025-06-15 16:00:00'),
('TXN-2025-0055', 4, 3, 200000.00, 'Transfer money in - From BDO main account', '2025-06-20 10:00:00'),
('TXN-2025-0056', 2, 4, 200000.00, 'Transfer money out - To BPI operations', '2025-06-20 10:00:00'),
('TXN-2025-0057', 3, 6, 6100.00, 'Interest earned - Savings account Jun', '2025-06-30 23:59:00'),
('TXN-2025-0058', 2, 5, 500.00, 'Bank service fee - June', '2025-06-30 23:00:00'),

-- July 2025 - Q3
('TXN-2025-0059', 4, 1, 780000.00, 'Cash in - Client payment STU Enterprises INV-2025-068', '2025-07-08 10:00:00'),
('TXN-2025-0060', 20, 1, 490000.00, 'Cash in - Sales collection July batch', '2025-07-20 14:00:00'),
('TXN-2025-0061', 2, 2, 100000.00, 'Cash out - Office rent payment July', '2025-07-02 09:00:00'),
('TXN-2025-0062', 2, 2, 88000.00, 'Cash out - Utilities payment July', '2025-07-08 14:00:00'),
('TXN-2025-0063', 5, 7, 8000.00, 'Paid loan - Housing loan installment LN-1004', '2025-07-01 10:00:00'),

-- August 2025
('TXN-2025-0064', 4, 1, 920000.00, 'Cash in - Client payment VWX Corp INV-2025-079', '2025-08-12 11:30:00'),
('TXN-2025-0065', 20, 1, 530000.00, 'Cash in - Sales collection August batch', '2025-08-25 14:00:00'),
('TXN-2025-0066', 2, 2, 100000.00, 'Cash out - Office rent payment August', '2025-08-01 09:00:00'),
('TXN-2025-0067', 8, 2, 120000.00, 'Cash out - IT infrastructure upgrade', '2025-08-20 15:00:00'),
('TXN-2025-0068', 3, 6, 6500.00, 'Interest earned - Savings account Aug', '2025-08-31 23:59:00'),

-- September 2025
('TXN-2025-0069', 4, 1, 850000.00, 'Cash in - Client payment YZA Inc INV-2025-088', '2025-09-10 10:00:00'),
('TXN-2025-0070', 20, 1, 470000.00, 'Cash in - Sales collection September batch', '2025-09-22 14:00:00'),
('TXN-2025-0071', 2, 2, 100000.00, 'Cash out - Office rent payment September', '2025-09-01 09:00:00'),
('TXN-2025-0072', 2, 2, 90000.00, 'Cash out - Utilities payment September', '2025-09-09 14:00:00'),
('TXN-2025-0073', 1, 7, 4500.00, 'Paid loan - Salary loan installment LN-1001', '2025-09-01 10:00:00'),
('TXN-2025-0074', 3, 6, 6800.00, 'Interest earned - Savings account Sep', '2025-09-30 23:59:00'),
('TXN-2025-0075', 2, 5, 500.00, 'Bank service fee - September', '2025-09-30 23:00:00'),

-- October 2025 - Q4
('TXN-2025-0076', 4, 1, 1050000.00, 'Cash in - Major client contract BCD Global INV-2025-095', '2025-10-05 10:00:00'),
('TXN-2025-0077', 20, 1, 580000.00, 'Cash in - Sales collection October batch', '2025-10-20 14:00:00'),
('TXN-2025-0078', 2, 2, 100000.00, 'Cash out - Office rent payment October', '2025-10-01 09:00:00'),
('TXN-2025-0079', 8, 2, 250000.00, 'Cash out - Equipment purchase new workstations', '2025-10-15 11:00:00'),
('TXN-2025-0080', 5, 7, 8000.00, 'Paid loan - Housing loan installment LN-1004', '2025-10-01 10:00:00'),

-- November 2025
('TXN-2025-0081', 4, 1, 980000.00, 'Cash in - Client payment EFG Partners INV-2025-103', '2025-11-08 10:30:00'),
('TXN-2025-0082', 20, 1, 620000.00, 'Cash in - Sales collection November batch', '2025-11-22 14:00:00'),
('TXN-2025-0083', 2, 2, 100000.00, 'Cash out - Office rent payment November', '2025-11-03 09:00:00'),
('TXN-2025-0084', 2, 2, 92000.00, 'Cash out - Utilities payment November', '2025-11-07 14:00:00'),
('TXN-2025-0085', 3, 6, 7200.00, 'Interest earned - Savings account Nov', '2025-11-30 23:59:00'),

-- December 2025
('TXN-2025-0086', 4, 1, 1200000.00, 'Cash in - Year-end client payment HIJ Corp INV-2025-115', '2025-12-05 10:00:00'),
('TXN-2025-0087', 20, 1, 700000.00, 'Cash in - Sales collection December batch', '2025-12-18 14:00:00'),
('TXN-2025-0088', 2, 2, 100000.00, 'Cash out - Office rent payment December', '2025-12-01 09:00:00'),
('TXN-2025-0089', 8, 2, 180000.00, 'Cash out - Year-end bonuses misc expenses', '2025-12-20 15:00:00'),
('TXN-2025-0090', 4, 3, 400000.00, 'Transfer money in - Year-end fund reallocation', '2025-12-15 10:00:00'),
('TXN-2025-0091', 2, 4, 400000.00, 'Transfer money out - To BPI operations year-end', '2025-12-15 10:00:00'),
('TXN-2025-0092', 3, 6, 7800.00, 'Interest earned - Savings account Dec', '2025-12-31 23:59:00'),
('TXN-2025-0093', 2, 5, 500.00, 'Bank service fee - December', '2025-12-31 23:00:00'),
('TXN-2025-0094', 1, 7, 4500.00, 'Paid loan - Final installment salary loan LN-1001', '2025-12-01 10:00:00'),
('TXN-2025-0095', 5, 7, 8000.00, 'Paid loan - Housing loan installment LN-1004', '2025-12-01 10:00:00'),

-- January 2026
('TXN-2026-0001', 4, 1, 880000.00, 'Cash in - Client payment KLM Corp INV-2026-001', '2026-01-10 10:00:00'),
('TXN-2026-0002', 20, 1, 520000.00, 'Cash in - Sales collection January batch', '2026-01-22 14:00:00'),
('TXN-2026-0003', 1, 1, 65000.00, 'Cash in - Salary deposit January 2026', '2026-01-15 10:00:00'),
('TXN-2026-0004', 2, 2, 105000.00, 'Cash out - Office rent payment January 2026', '2026-01-03 09:00:00'),
('TXN-2026-0005', 2, 2, 85000.00, 'Cash out - Utilities payment January 2026', '2026-01-08 14:00:00'),
('TXN-2026-0006', 3, 6, 7500.00, 'Interest earned - Savings account Jan 2026', '2026-01-31 23:59:00'),
('TXN-2026-0007', 5, 7, 8000.00, 'Paid loan - Housing loan installment LN-1004', '2026-01-01 10:00:00'),
('TXN-2026-0008', 2, 5, 500.00, 'Bank service fee - January 2026', '2026-01-31 23:00:00'),

-- February 2026
('TXN-2026-0009', 4, 1, 760000.00, 'Cash in - Client payment NOP Solutions INV-2026-010', '2026-02-08 11:00:00'),
('TXN-2026-0010', 20, 1, 480000.00, 'Cash in - Sales collection February batch', '2026-02-20 14:00:00'),
('TXN-2026-0011', 2, 2, 105000.00, 'Cash out - Office rent payment February 2026', '2026-02-03 09:00:00'),
('TXN-2026-0012', 8, 2, 95000.00, 'Cash out - Marketing campaign Q1 2026', '2026-02-15 15:00:00'),
('TXN-2026-0013', 3, 6, 7800.00, 'Interest earned - Savings account Feb 2026', '2026-02-28 23:59:00'),

-- March 2026
('TXN-2026-0014', 4, 1, 1100000.00, 'Cash in - Major contract QRS Group INV-2026-020', '2026-03-05 10:00:00'),
('TXN-2026-0015', 20, 1, 590000.00, 'Cash in - Sales collection March batch', '2026-03-22 14:00:00'),
('TXN-2026-0016', 2, 2, 105000.00, 'Cash out - Office rent payment March 2026', '2026-03-03 09:00:00'),
('TXN-2026-0017', 2, 2, 88000.00, 'Cash out - Utilities payment March 2026', '2026-03-07 14:00:00'),
('TXN-2026-0018', 4, 3, 350000.00, 'Transfer money in - Q1 fund reallocation', '2026-03-15 10:00:00'),
('TXN-2026-0019', 2, 4, 350000.00, 'Transfer money out - To operations Q1', '2026-03-15 10:00:00'),
('TXN-2026-0020', 3, 6, 8200.00, 'Interest earned - Savings account Mar 2026', '2026-03-31 23:59:00'),
('TXN-2026-0021', 5, 7, 8000.00, 'Paid loan - Housing loan installment LN-1004', '2026-03-01 10:00:00'),
('TXN-2026-0022', 2, 5, 500.00, 'Bank service fee - March 2026', '2026-03-31 23:00:00');

-- Populate missions (stub data for rewards system)
INSERT INTO missions (mission_text, points_value) VALUES
('Complete first deposit', 100.00),
('Set up auto-save', 50.00),
('Refer a friend', 200.00),
('Pay loan on time 3 months', 150.00),
('Open business account', 300.00)
ON DUPLICATE KEY UPDATE mission_text = VALUES(mission_text);

-- Populate report_settings
INSERT INTO report_settings (setting_key, setting_value) VALUES
('default_date_format', 'Y-m-d'),
('currency', 'PHP'),
('company_name', 'Evergreen Solutions Inc.'),
('fiscal_year_start', '01-01'),
('report_logo_path', '/assets/image/logo.png'),
('decimal_places', '2')
ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value);

-- ========================================
-- INITIAL CAPITAL INVESTMENT (January 2025)
-- ========================================

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0001', @gj_type, '2025-01-02', 'Initial capital investment', @jan_2025, 'INV-001', 10000000.00, 10000000.00, 'posted', 1, NOW(), 1);

SET @je1 = LAST_INSERT_ID();

INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je1, @cash_bdo, 5000000.00, 0.00, 'Cash deposit - BDO'),
(@je1, @cash_bpi, 2000000.00, 0.00, 'Cash deposit - BPI'),
(@je1, @equipment, 1000000.00, 0.00, 'Office equipment purchase'),
(@je1, @building, 1500000.00, 0.00, 'Building acquisition'),
(@je1, @land, 500000.00, 0.00, 'Land acquisition'),
(@je1, @capital_stock, 0.00, 10000000.00, 'Owner capital contribution');

-- ========================================
-- BANK LOAN (January 2025)
-- ========================================

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0002', @gj_type, '2025-01-05', 'Bank loan proceeds', @jan_2025, 'LOAN-001', 2000000.00, 2000000.00, 'posted', 1, NOW(), 1);

SET @je2 = LAST_INSERT_ID();

INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je2, @cash_metro, 2000000.00, 0.00, 'Loan proceeds'),
(@je2, @loan_longterm, 0.00, 2000000.00, 'Long-term loan payable');

-- ========================================
-- INVENTORY PURCHASE (January 2025)
-- ========================================

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0003', @ap_type, '2025-01-10', 'Inventory purchase on account', @jan_2025, 'PO-001', 1500000.00, 1500000.00, 'posted', 1, NOW(), 1);

SET @je3 = LAST_INSERT_ID();

INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je3, @inventory_raw, 800000.00, 0.00, 'Raw materials inventory'),
(@je3, @inventory_finished, 700000.00, 0.00, 'Finished goods inventory'),
(@je3, @ap_trade, 0.00, 1500000.00, 'Trade payable');

-- ========================================
-- SALES REVENUE - CASH (January 2025)
-- ========================================

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0004', @cr_type, '2025-01-15', 'Cash sales', @jan_2025, 'INV-2501', 800000.00, 800000.00, 'posted', 1, NOW(), 1);

SET @je4 = LAST_INSERT_ID();

INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je4, @cash_bdo, 800000.00, 0.00, 'Cash received'),
(@je4, @sales_revenue, 0.00, 800000.00, 'Product sales');

-- ========================================
-- COST OF GOODS SOLD (January 2025)
-- ========================================

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0005', @gj_type, '2025-01-15', 'COGS for sales', @jan_2025, 'INV-2501', 480000.00, 480000.00, 'posted', 1, NOW(), 1);

SET @je5 = LAST_INSERT_ID();

INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je5, @cogs, 480000.00, 0.00, 'Cost of goods sold'),
(@je5, @inventory_finished, 0.00, 480000.00, 'Inventory reduction');

-- ========================================
-- SERVICE REVENUE - CREDIT (January 2025)
-- ========================================

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0006', @ar_type, '2025-01-20', 'Service revenue on account', @jan_2025, 'INV-2502', 600000.00, 600000.00, 'posted', 1, NOW(), 1);

SET @je6 = LAST_INSERT_ID();

INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je6, @ar_trade, 600000.00, 0.00, 'Customer receivable'),
(@je6, @service_revenue, 0.00, 600000.00, 'Service income');

-- ========================================
-- PAYROLL PROCESSING (January 2025)
-- ========================================

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0007', @pr_type, '2025-01-31', 'January payroll', @jan_2025, 'PR-2501', 500000.00, 500000.00, 'posted', 1, NOW(), 1);

SET @je7 = LAST_INSERT_ID();

INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je7, @salaries_wages, 400000.00, 0.00, 'Employee salaries'),
(@je7, @employee_benefits, 50000.00, 0.00, 'Employee benefits'),
(@je7, @payroll_taxes, 50000.00, 0.00, 'Payroll taxes'),
(@je7, @sss_payable, 0.00, 18000.00, 'SSS payable'),
(@je7, @philhealth_payable, 0.00, 12000.00, 'PhilHealth payable'),
(@je7, @pagibig_payable, 0.00, 5000.00, 'Pag-IBIG payable'),
(@je7, @wht_payable, 0.00, 15000.00, 'Withholding tax payable'),
(@je7, @cash_metro, 0.00, 400000.00, 'Net pay');

-- ========================================
-- RENT EXPENSE (January 2025)
-- ========================================

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0008', @cd_type, '2025-02-01', 'January rent payment', @feb_2025, 'RENT-JAN', 100000.00, 100000.00, 'posted', 1, NOW(), 1);

SET @je8 = LAST_INSERT_ID();

INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je8, @rent_expense, 100000.00, 0.00, 'Office rent'),
(@je8, @cash_bdo, 0.00, 100000.00, 'Cash paid');

-- ========================================
-- UTILITIES EXPENSE (February 2025)
-- ========================================

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0009', @cd_type, '2025-02-05', 'Utilities payment', @feb_2025, 'UTIL-FEB', 75000.00, 75000.00, 'posted', 1, NOW(), 1);

SET @je9 = LAST_INSERT_ID();

INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je9, @utilities_expense, 75000.00, 0.00, 'Electricity and water'),
(@je9, @cash_bdo, 0.00, 75000.00, 'Cash paid');

-- ========================================
-- OFFICE SUPPLIES PURCHASE (February 2025)
-- ========================================

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0010', @cd_type, '2025-02-10', 'Office supplies', @feb_2025, 'SUP-001', 50000.00, 50000.00, 'posted', 1, NOW(), 1);

SET @je10 = LAST_INSERT_ID();

INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je10, @office_supplies, 50000.00, 0.00, 'Office supplies'),
(@je10, @cash_bpi, 0.00, 50000.00, 'Cash paid');

-- ========================================
-- MARKETING EXPENSE (February 2025)
-- ========================================

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0011', @cd_type, '2025-02-15', 'Marketing campaign', @feb_2025, 'MKT-001', 150000.00, 150000.00, 'posted', 1, NOW(), 1);

SET @je11 = LAST_INSERT_ID();

INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je11, @marketing_advertising, 150000.00, 0.00, 'Digital advertising'),
(@je11, @cash_bdo, 0.00, 150000.00, 'Cash paid');

-- ========================================
-- PROFESSIONAL FEES (February 2025)
-- ========================================

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0012', @cd_type, '2025-02-20', 'Legal consultation', @feb_2025, 'LEGAL-001', 80000.00, 80000.00, 'posted', 1, NOW(), 1);

SET @je12 = LAST_INSERT_ID();

INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je12, @professional_fees, 80000.00, 0.00, 'Legal fees'),
(@je12, @cash_bdo, 0.00, 80000.00, 'Cash paid');

-- ========================================
-- INTEREST INCOME (February 2025)
-- ========================================

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0013', @cr_type, '2025-02-28', 'Bank interest earned', @feb_2025, 'INT-FEB', 10000.00, 10000.00, 'posted', 1, NOW(), 1);

SET @je13 = LAST_INSERT_ID();

INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je13, @cash_bdo, 10000.00, 0.00, 'Interest received'),
(@je13, @interest_income, 0.00, 10000.00, 'Bank interest income');

-- ========================================
-- LOAN INTEREST PAYMENT (February 2025)
-- ========================================

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0014', @cd_type, '2025-02-28', 'Loan interest payment', @feb_2025, 'LOAN-INT-FEB', 30000.00, 30000.00, 'posted', 1, NOW(), 1);

SET @je14 = LAST_INSERT_ID();

INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je14, @interest_expense, 30000.00, 0.00, 'Interest on loan'),
(@je14, @cash_metro, 0.00, 30000.00, 'Cash paid');

-- ========================================
-- DEPRECIATION EXPENSE (February 2025)
-- ========================================

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0015', @aj_type, '2025-02-28', 'Monthly depreciation', @feb_2025, 'DEP-FEB', 20000.00, 20000.00, 'posted', 1, NOW(), 1);

SET @je15 = LAST_INSERT_ID();

INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je15, @depreciation_expense, 20000.00, 0.00, 'Equipment depreciation'),
(@je15, @accum_dep_equip, 0.00, 20000.00, 'Accumulated depreciation');

-- ========================================
-- CUSTOMER PAYMENT (March 2025)
-- ========================================

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0016', @cr_type, '2025-03-05', 'Payment from ABC Corp', @mar_2025, 'CR-1001', 400000.00, 400000.00, 'posted', 1, NOW(), 1);

SET @je16 = LAST_INSERT_ID();

INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je16, @cash_bpi, 400000.00, 0.00, 'Cash received'),
(@je16, @ar_trade, 0.00, 400000.00, 'AR collection');

-- ========================================
-- EQUIPMENT PURCHASE (March 2025)
-- ========================================

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0017', @ap_type, '2025-03-10', 'Purchase computers', @mar_2025, 'INV-2001', 250000.00, 250000.00, 'posted', 1, NOW(), 1);

SET @je17 = LAST_INSERT_ID();

INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je17, @equipment, 250000.00, 0.00, 'Equipment purchased'),
(@je17, @ap_trade, 0.00, 250000.00, 'AP to supplier');

-- ========================================
-- DRAFT ENTRY (March 2025)
-- ========================================

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, created_by) 
VALUES ('JE-2025-0018', @gj_type, '2025-03-15', 'Depreciation for March', @mar_2025, 'ADJ-DEP', 20000.00, 20000.00, 'draft', 1);

SET @je18 = LAST_INSERT_ID();

INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je18, @depreciation_expense, 20000.00, 0.00, 'Monthly depreciation'),
(@je18, @accum_dep_equip, 0.00, 20000.00, 'Accum. depreciation');

-- ========================================
-- TRANSPORTATION EXPENSE (March 2025)
-- ========================================

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0019', @cd_type, '2025-03-20', 'Fuel and maintenance', @mar_2025, 'TRANS-001', 15000.00, 15000.00, 'posted', 1, NOW(), 1);

SET @je19 = LAST_INSERT_ID();

INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je19, @transportation_travel, 15000.00, 0.00, 'Fuel'),
(@je19, @cash_hand, 0.00, 15000.00, 'Cash');

-- ========================================
-- SERVICE REVENUE - CASH (March 2025)
-- ========================================

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0020', @cr_type, '2025-03-25', 'Consulting services', @mar_2025, 'INV-5001', 300000.00, 300000.00, 'posted', 1, NOW(), 1);

SET @je20 = LAST_INSERT_ID();

INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je20, @cash_bdo, 300000.00, 0.00, 'Cash received'),
(@je20, @consulting_revenue, 0.00, 300000.00, 'Consulting revenue');

-- ========================================
-- ADDITIONAL JOURNAL ENTRIES (Q2 2025 - Q1 2026)
-- ========================================

-- Q2 2025: April
INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0021', @cr_type, '2025-04-05', 'Cash in - Client payment JKL Solutions', @apr_2025, 'CR-2025-004', 720000.00, 720000.00, 'posted', 1, '2025-04-05 14:00:00', 1);
SET @je21 = LAST_INSERT_ID();
INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je21, @cash_bdo, 720000.00, 0.00, 'Cash received from JKL Solutions'),
(@je21, @sales_revenue, 0.00, 720000.00, 'Sales revenue - April');

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0022', @cd_type, '2025-04-10', 'Cash out - Vendor payment ABC Suppliers PO-2025-012', @apr_2025, 'CD-2025-004', 180000.00, 180000.00, 'posted', 1, '2025-04-10 10:00:00', 1);
SET @je22 = LAST_INSERT_ID();
INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je22, @ap_trade, 180000.00, 0.00, 'Settled trade payable'),
(@je22, @cash_bdo, 0.00, 180000.00, 'Cash disbursement');

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0023', @pr_type, '2025-04-30', 'Payroll disbursement - April 2025', @apr_2025, 'PR-2504', 520000.00, 520000.00, 'posted', 1, '2025-04-30 18:00:00', 1);
SET @je23 = LAST_INSERT_ID();
INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je23, @salaries_wages, 420000.00, 0.00, 'Employee salaries April'),
(@je23, @employee_benefits, 50000.00, 0.00, 'Employee benefits April'),
(@je23, @payroll_taxes, 50000.00, 0.00, 'Payroll taxes April'),
(@je23, @sss_payable, 0.00, 19000.00, 'SSS contributions'),
(@je23, @philhealth_payable, 0.00, 13000.00, 'PhilHealth contributions'),
(@je23, @pagibig_payable, 0.00, 5000.00, 'Pag-IBIG contributions'),
(@je23, @wht_payable, 0.00, 16000.00, 'Withholding tax'),
(@je23, @cash_metro, 0.00, 417000.00, 'Net payroll disbursement'),
(@je23, @salaries_payable, 0.00, 50000.00, 'Accrued benefits payable');

-- May 2025
INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0024', @cr_type, '2025-05-12', 'Cash in - Sales collection MNO Holdings', @may_2025, 'CR-2025-005', 680000.00, 680000.00, 'posted', 1, '2025-05-12 11:00:00', 1);
SET @je24 = LAST_INSERT_ID();
INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je24, @cash_bpi, 680000.00, 0.00, 'Cash received from MNO Holdings'),
(@je24, @service_revenue, 0.00, 680000.00, 'Service revenue - May');

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0025', @cd_type, '2025-05-15', 'Cash out - Insurance premium quarterly payment', @may_2025, 'INS-2025-Q2', 45000.00, 45000.00, 'posted', 1, '2025-05-15 09:00:00', 1);
SET @je25 = LAST_INSERT_ID();
INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je25, @insurance_expense, 45000.00, 0.00, 'Insurance premium Q2'),
(@je25, @cash_bdo, 0.00, 45000.00, 'Cash paid');

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0026', @aj_type, '2025-05-31', 'Monthly depreciation - May 2025', @may_2025, 'DEP-MAY', 25000.00, 25000.00, 'posted', 1, '2025-05-31 17:00:00', 1);
SET @je26 = LAST_INSERT_ID();
INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je26, @depreciation_expense, 25000.00, 0.00, 'Monthly depreciation'),
(@je26, @accum_dep_equip, 0.00, 12500.00, 'Equipment depreciation'),
(@je26, @accum_dep_build, 0.00, 12500.00, 'Building depreciation');

-- June 2025
INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0027', @cr_type, '2025-06-10', 'Cash in - Client payment PQR Corp contract', @jun_2025, 'CR-2025-006', 890000.00, 890000.00, 'posted', 1, '2025-06-10 14:30:00', 1);
SET @je27 = LAST_INSERT_ID();
INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je27, @cash_bdo, 890000.00, 0.00, 'Cash received from PQR Corp'),
(@je27, @sales_revenue, 0.00, 650000.00, 'Product sales'),
(@je27, @service_revenue, 0.00, 240000.00, 'Service revenue');

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0028', @cd_type, '2025-06-20', 'Cash out - Paid loan monthly installment LOAN-2024-001', @jun_2025, 'LOAN-PAY-JUN', 5025.00, 5025.00, 'posted', 1, '2025-06-20 10:00:00', 1);
SET @je28 = LAST_INSERT_ID();
INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je28, @loan_current, 3935.00, 0.00, 'Loan principal repayment'),
(@je28, @interest_expense, 1090.00, 0.00, 'Loan interest'),
(@je28, @cash_bdo, 0.00, 5025.00, 'Cash paid for loan installment');

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0029', @pr_type, '2025-06-30', 'Payroll disbursement - June 2025', @jun_2025, 'PR-2506', 530000.00, 530000.00, 'posted', 1, '2025-06-30 18:00:00', 1);
SET @je29 = LAST_INSERT_ID();
INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je29, @salaries_wages, 430000.00, 0.00, 'Employee salaries June'),
(@je29, @employee_benefits, 50000.00, 0.00, 'Employee benefits June'),
(@je29, @payroll_taxes, 50000.00, 0.00, 'Payroll taxes June'),
(@je29, @sss_payable, 0.00, 19500.00, 'SSS contributions'),
(@je29, @philhealth_payable, 0.00, 13500.00, 'PhilHealth contributions'),
(@je29, @pagibig_payable, 0.00, 5000.00, 'Pag-IBIG contributions'),
(@je29, @wht_payable, 0.00, 17000.00, 'Withholding tax'),
(@je29, @cash_metro, 0.00, 425000.00, 'Net payroll disbursement'),
(@je29, @salaries_payable, 0.00, 50000.00, 'Accrued benefits payable');

-- Q3 2025: July-September
INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0030', @cr_type, '2025-07-08', 'Cash in - Client payment STU Enterprises', @jul_2025, 'CR-2025-007', 780000.00, 780000.00, 'posted', 1, '2025-07-08 11:00:00', 1);
SET @je30 = LAST_INSERT_ID();
INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je30, @cash_bdo, 780000.00, 0.00, 'Cash received from STU Enterprises'),
(@je30, @sales_revenue, 0.00, 780000.00, 'Sales revenue - July');

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0031', @cd_type, '2025-08-12', 'Cash out - IT infrastructure upgrade', @aug_2025, 'EQUIP-2025-003', 350000.00, 350000.00, 'posted', 1, '2025-08-12 14:00:00', 1);
SET @je31 = LAST_INSERT_ID();
INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je31, @equipment, 350000.00, 0.00, 'IT equipment purchased'),
(@je31, @cash_bdo, 0.00, 350000.00, 'Cash paid');

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0032', @cr_type, '2025-08-25', 'Cash in - Sales collection August batch', @aug_2025, 'CR-2025-008', 530000.00, 530000.00, 'posted', 1, '2025-08-25 14:00:00', 1);
SET @je32 = LAST_INSERT_ID();
INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je32, @cash_bpi, 530000.00, 0.00, 'Cash received - sales batch'),
(@je32, @service_revenue, 0.00, 530000.00, 'Service revenue - August');

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0033', @aj_type, '2025-09-30', 'Monthly depreciation - Q3 2025 catch-up', @sep_2025, 'DEP-Q3', 75000.00, 75000.00, 'posted', 1, '2025-09-30 17:00:00', 1);
SET @je33 = LAST_INSERT_ID();
INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je33, @depreciation_expense, 75000.00, 0.00, 'Q3 depreciation'),
(@je33, @accum_dep_equip, 0.00, 25000.00, 'Equipment depreciation'),
(@je33, @accum_dep_build, 0.00, 25000.00, 'Building depreciation'),
(@je33, @accum_dep_veh, 0.00, 12500.00, 'Vehicle depreciation'),
(@je33, @accum_dep_mach, 0.00, 12500.00, 'Machinery depreciation');

-- Q4 2025: October-December
INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0034', @cr_type, '2025-10-05', 'Cash in - Major contract BCD Global', @oct_2025, 'CR-2025-010', 1050000.00, 1050000.00, 'posted', 1, '2025-10-05 10:00:00', 1);
SET @je34 = LAST_INSERT_ID();
INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je34, @cash_bdo, 1050000.00, 0.00, 'Cash received from BCD Global'),
(@je34, @sales_revenue, 0.00, 800000.00, 'Product sales'),
(@je34, @consulting_revenue, 0.00, 250000.00, 'Consulting services');

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0035', @cd_type, '2025-10-15', 'Cash out - Equipment purchase new workstations', @oct_2025, 'PO-2025-015', 250000.00, 250000.00, 'posted', 1, '2025-10-15 11:00:00', 1);
SET @je35 = LAST_INSERT_ID();
INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je35, @equipment, 250000.00, 0.00, 'New computer workstations'),
(@je35, @cash_bdo, 0.00, 250000.00, 'Cash paid');

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0036', @cr_type, '2025-11-08', 'Cash in - Client payment EFG Partners', @nov_2025, 'CR-2025-011', 980000.00, 980000.00, 'posted', 1, '2025-11-08 10:30:00', 1);
SET @je36 = LAST_INSERT_ID();
INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je36, @cash_bdo, 980000.00, 0.00, 'Cash received from EFG Partners'),
(@je36, @sales_revenue, 0.00, 980000.00, 'Sales revenue - November');

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0037', @pr_type, '2025-11-30', 'Payroll disbursement - November 2025', @nov_2025, 'PR-2511', 550000.00, 550000.00, 'posted', 1, '2025-11-30 18:00:00', 1);
SET @je37 = LAST_INSERT_ID();
INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je37, @salaries_wages, 450000.00, 0.00, 'Employee salaries November'),
(@je37, @employee_benefits, 50000.00, 0.00, 'Employee benefits November'),
(@je37, @payroll_taxes, 50000.00, 0.00, 'Payroll taxes November'),
(@je37, @sss_payable, 0.00, 20000.00, 'SSS contributions'),
(@je37, @philhealth_payable, 0.00, 14000.00, 'PhilHealth contributions'),
(@je37, @pagibig_payable, 0.00, 5000.00, 'Pag-IBIG contributions'),
(@je37, @wht_payable, 0.00, 18000.00, 'Withholding tax'),
(@je37, @cash_metro, 0.00, 443000.00, 'Net payroll disbursement'),
(@je37, @salaries_payable, 0.00, 50000.00, 'Accrued benefits payable');

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0038', @cr_type, '2025-12-05', 'Cash in - Year-end client payment HIJ Corp', @dec_2025, 'CR-2025-012', 1200000.00, 1200000.00, 'posted', 1, '2025-12-05 10:00:00', 1);
SET @je38 = LAST_INSERT_ID();
INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je38, @cash_bdo, 1200000.00, 0.00, 'Cash received from HIJ Corp'),
(@je38, @sales_revenue, 0.00, 900000.00, 'Product sales Q4'),
(@je38, @service_revenue, 0.00, 300000.00, 'Service revenue Q4');

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2025-0039', @aj_type, '2025-12-31', 'Year-end depreciation and adjustments', @dec_2025, 'ADJ-YE-2025', 100000.00, 100000.00, 'posted', 1, '2025-12-31 17:00:00', 1);
SET @je39 = LAST_INSERT_ID();
INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je39, @depreciation_expense, 100000.00, 0.00, 'Year-end depreciation catch-up'),
(@je39, @accum_dep_equip, 0.00, 35000.00, 'Equipment depreciation'),
(@je39, @accum_dep_build, 0.00, 30000.00, 'Building depreciation'),
(@je39, @accum_dep_veh, 0.00, 20000.00, 'Vehicle depreciation'),
(@je39, @accum_dep_mach, 0.00, 15000.00, 'Machinery depreciation');

-- Q1 2026: January-March
INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2026-0001', @cr_type, '2026-01-10', 'Cash in - Client payment KLM Corp new contract', @jan_2026, 'CR-2026-001', 880000.00, 880000.00, 'posted', 1, '2026-01-10 10:00:00', 1);
SET @je40 = LAST_INSERT_ID();
INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je40, @cash_bdo, 880000.00, 0.00, 'Cash received from KLM Corp'),
(@je40, @sales_revenue, 0.00, 880000.00, 'Sales revenue - January 2026');

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2026-0002', @pr_type, '2026-01-31', 'Payroll disbursement - January 2026', @jan_2026, 'PR-2601', 560000.00, 560000.00, 'posted', 1, '2026-01-31 18:00:00', 1);
SET @je41 = LAST_INSERT_ID();
INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je41, @salaries_wages, 460000.00, 0.00, 'Employee salaries January 2026'),
(@je41, @employee_benefits, 50000.00, 0.00, 'Employee benefits'),
(@je41, @payroll_taxes, 50000.00, 0.00, 'Payroll taxes'),
(@je41, @sss_payable, 0.00, 20500.00, 'SSS contributions'),
(@je41, @philhealth_payable, 0.00, 14500.00, 'PhilHealth contributions'),
(@je41, @pagibig_payable, 0.00, 5000.00, 'Pag-IBIG contributions'),
(@je41, @wht_payable, 0.00, 18000.00, 'Withholding tax'),
(@je41, @cash_metro, 0.00, 452000.00, 'Net payroll disbursement'),
(@je41, @salaries_payable, 0.00, 50000.00, 'Accrued benefits payable');

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2026-0003', @cr_type, '2026-02-08', 'Cash in - Client payment NOP Solutions', @feb_2026, 'CR-2026-002', 760000.00, 760000.00, 'posted', 1, '2026-02-08 11:00:00', 1);
SET @je42 = LAST_INSERT_ID();
INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je42, @cash_bpi, 760000.00, 0.00, 'Cash received from NOP Solutions'),
(@je42, @service_revenue, 0.00, 760000.00, 'Service revenue - February 2026');

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2026-0004', @cd_type, '2026-02-15', 'Cash out - Marketing campaign Q1 2026', @feb_2026, 'MKT-2026-Q1', 95000.00, 95000.00, 'posted', 1, '2026-02-15 15:00:00', 1);
SET @je43 = LAST_INSERT_ID();
INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je43, @marketing_advertising, 95000.00, 0.00, 'Marketing campaign Q1 2026'),
(@je43, @cash_bdo, 0.00, 95000.00, 'Cash paid');

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2026-0005', @cr_type, '2026-03-05', 'Cash in - Major contract QRS Group', @mar_2026, 'CR-2026-003', 1100000.00, 1100000.00, 'posted', 1, '2026-03-05 10:00:00', 1);
SET @je44 = LAST_INSERT_ID();
INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je44, @cash_bdo, 1100000.00, 0.00, 'Cash received from QRS Group'),
(@je44, @sales_revenue, 0.00, 850000.00, 'Product sales Q1 2026'),
(@je44, @consulting_revenue, 0.00, 250000.00, 'Consulting services Q1 2026');

INSERT IGNORE INTO journal_entries (journal_no, journal_type_id, entry_date, description, fiscal_period_id, reference_no, total_debit, total_credit, status, posted_by, posted_at, created_by) 
VALUES ('JE-2026-0006', @pr_type, '2026-03-31', 'Payroll disbursement - March 2026', @mar_2026, 'PR-2603', 570000.00, 570000.00, 'posted', 1, '2026-03-31 18:00:00', 1);
SET @je45 = LAST_INSERT_ID();
INSERT IGNORE INTO journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
(@je45, @salaries_wages, 470000.00, 0.00, 'Employee salaries March 2026'),
(@je45, @employee_benefits, 50000.00, 0.00, 'Employee benefits'),
(@je45, @payroll_taxes, 50000.00, 0.00, 'Payroll taxes'),
(@je45, @sss_payable, 0.00, 21000.00, 'SSS contributions'),
(@je45, @philhealth_payable, 0.00, 15000.00, 'PhilHealth contributions'),
(@je45, @pagibig_payable, 0.00, 5000.00, 'Pag-IBIG contributions'),
(@je45, @wht_payable, 0.00, 19000.00, 'Withholding tax'),
(@je45, @cash_metro, 0.00, 460000.00, 'Net payroll disbursement'),
(@je45, @salaries_payable, 0.00, 50000.00, 'Accrued benefits payable');

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
-- 16. ACCOUNT BALANCES - EXPLICIT POSITIVE VALUES
-- ========================================

-- First calculate from journal entries dynamically
INSERT IGNORE INTO account_balances (account_id, fiscal_period_id, opening_balance, debit_movements, credit_movements, closing_balance, last_updated)
SELECT 
    a.id as account_id,
    fp.id as fiscal_period_id,
    0.00 as opening_balance,
    COALESCE(SUM(jl.debit), 0.00) as debit_movements,
    COALESCE(SUM(jl.credit), 0.00) as credit_movements,
    COALESCE(SUM(jl.debit), 0.00) - COALESCE(SUM(jl.credit), 0.00) as closing_balance,
    NOW() as last_updated
FROM accounts a
CROSS JOIN fiscal_periods fp
LEFT JOIN journal_lines jl ON a.id = jl.account_id
LEFT JOIN journal_entries je ON jl.journal_entry_id = je.id AND je.fiscal_period_id = fp.id AND je.status = 'posted'
WHERE a.is_active = 1
GROUP BY a.id, fp.id
ON DUPLICATE KEY UPDATE 
    debit_movements = VALUES(debit_movements),
    credit_movements = VALUES(credit_movements),
    closing_balance = VALUES(closing_balance),
    last_updated = VALUES(last_updated);

-- Override with explicit positive balances for key accounts (FY2025-Q1 through FY2026-Q1)
-- This ensures financial reports show realistic positive numbers
-- Assets = Liabilities + Equity (Accounting Equation: ₱19.5M = ₱5.2M + ₱14.3M)

-- FY2025-Q1 Balances (January - March 2025)
SET @fy2025q1 = (SELECT id FROM fiscal_periods WHERE period_name = 'FY2025-Q1' LIMIT 1);

UPDATE account_balances SET opening_balance = 10000000.00, debit_movements = 2500000.00, credit_movements = 1800000.00, closing_balance = 10700000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '1001' LIMIT 1) AND fiscal_period_id = @fy2025q1;
UPDATE account_balances SET opening_balance = 0.00, debit_movements = 1850000.00, credit_movements = 950000.00, closing_balance = 900000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '1002' LIMIT 1) AND fiscal_period_id = @fy2025q1;
UPDATE account_balances SET opening_balance = 0.00, debit_movements = 750000.00, credit_movements = 250000.00, closing_balance = 500000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '1003' LIMIT 1) AND fiscal_period_id = @fy2025q1;
UPDATE account_balances SET opening_balance = 0.00, debit_movements = 1200000.00, credit_movements = 100000.00, closing_balance = 1100000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '1004' LIMIT 1) AND fiscal_period_id = @fy2025q1;
UPDATE account_balances SET opening_balance = 0.00, debit_movements = 350000.00, credit_movements = 50000.00, closing_balance = 300000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '1005' LIMIT 1) AND fiscal_period_id = @fy2025q1;
UPDATE account_balances SET opening_balance = 0.00, debit_movements = 5000000.00, credit_movements = 250000.00, closing_balance = 4750000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '1006' LIMIT 1) AND fiscal_period_id = @fy2025q1;
UPDATE account_balances SET opening_balance = 0.00, debit_movements = 1500000.00, credit_movements = 250000.00, closing_balance = 1250000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '1007' LIMIT 1) AND fiscal_period_id = @fy2025q1;

-- Liabilities (credit normal - positive closing = credit balance)
UPDATE account_balances SET opening_balance = 0.00, debit_movements = 400000.00, credit_movements = 1200000.00, closing_balance = 800000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '2001' LIMIT 1) AND fiscal_period_id = @fy2025q1;
UPDATE account_balances SET opening_balance = 0.00, debit_movements = 100000.00, credit_movements = 650000.00, closing_balance = 550000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '2002' LIMIT 1) AND fiscal_period_id = @fy2025q1;
UPDATE account_balances SET opening_balance = 0.00, debit_movements = 50000.00, credit_movements = 600000.00, closing_balance = 550000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '2003' LIMIT 1) AND fiscal_period_id = @fy2025q1;
UPDATE account_balances SET opening_balance = 0.00, debit_movements = 200000.00, credit_movements = 1300000.00, closing_balance = 1100000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '2004' LIMIT 1) AND fiscal_period_id = @fy2025q1;
UPDATE account_balances SET opening_balance = 0.00, debit_movements = 100000.00, credit_movements = 550000.00, closing_balance = 450000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '2005' LIMIT 1) AND fiscal_period_id = @fy2025q1;
UPDATE account_balances SET opening_balance = 0.00, debit_movements = 50000.00, credit_movements = 350000.00, closing_balance = 300000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '2006' LIMIT 1) AND fiscal_period_id = @fy2025q1;
UPDATE account_balances SET opening_balance = 0.00, debit_movements = 100000.00, credit_movements = 550000.00, closing_balance = 450000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '2007' LIMIT 1) AND fiscal_period_id = @fy2025q1;
UPDATE account_balances SET opening_balance = 0.00, debit_movements = 150000.00, credit_movements = 1150000.00, closing_balance = 1000000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '2008' LIMIT 1) AND fiscal_period_id = @fy2025q1;

-- Equity (credit normal)
UPDATE account_balances SET opening_balance = 0.00, debit_movements = 0.00, credit_movements = 10000000.00, closing_balance = 10000000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '3001' LIMIT 1) AND fiscal_period_id = @fy2025q1;
UPDATE account_balances SET opening_balance = 0.00, debit_movements = 0.00, credit_movements = 2500000.00, closing_balance = 2500000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '3002' LIMIT 1) AND fiscal_period_id = @fy2025q1;
UPDATE account_balances SET opening_balance = 0.00, debit_movements = 0.00, credit_movements = 1800000.00, closing_balance = 1800000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '3003' LIMIT 1) AND fiscal_period_id = @fy2025q1;

-- Revenue (credit normal)
UPDATE account_balances SET opening_balance = 0.00, debit_movements = 0.00, credit_movements = 3500000.00, closing_balance = 3500000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '4001' LIMIT 1) AND fiscal_period_id = @fy2025q1;
UPDATE account_balances SET opening_balance = 0.00, debit_movements = 0.00, credit_movements = 1200000.00, closing_balance = 1200000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '4002' LIMIT 1) AND fiscal_period_id = @fy2025q1;
UPDATE account_balances SET opening_balance = 0.00, debit_movements = 0.00, credit_movements = 450000.00, closing_balance = 450000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '4003' LIMIT 1) AND fiscal_period_id = @fy2025q1;
UPDATE account_balances SET opening_balance = 0.00, debit_movements = 0.00, credit_movements = 350000.00, closing_balance = 350000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '4004' LIMIT 1) AND fiscal_period_id = @fy2025q1;

-- Expenses (debit normal)
UPDATE account_balances SET opening_balance = 0.00, debit_movements = 1850000.00, credit_movements = 0.00, closing_balance = 1850000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '5001' LIMIT 1) AND fiscal_period_id = @fy2025q1;
UPDATE account_balances SET opening_balance = 0.00, debit_movements = 450000.00, credit_movements = 0.00, closing_balance = 450000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '5002' LIMIT 1) AND fiscal_period_id = @fy2025q1;
UPDATE account_balances SET opening_balance = 0.00, debit_movements = 280000.00, credit_movements = 0.00, closing_balance = 280000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '5003' LIMIT 1) AND fiscal_period_id = @fy2025q1;
UPDATE account_balances SET opening_balance = 0.00, debit_movements = 350000.00, credit_movements = 0.00, closing_balance = 350000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '5004' LIMIT 1) AND fiscal_period_id = @fy2025q1;
UPDATE account_balances SET opening_balance = 0.00, debit_movements = 180000.00, credit_movements = 0.00, closing_balance = 180000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '5005' LIMIT 1) AND fiscal_period_id = @fy2025q1;
UPDATE account_balances SET opening_balance = 0.00, debit_movements = 250000.00, credit_movements = 0.00, closing_balance = 250000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '5006' LIMIT 1) AND fiscal_period_id = @fy2025q1;
UPDATE account_balances SET opening_balance = 0.00, debit_movements = 340000.00, credit_movements = 0.00, closing_balance = 340000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '5007' LIMIT 1) AND fiscal_period_id = @fy2025q1;

-- FY2026-Q1 Balances (January - March 2026)
SET @fy2026q1 = (SELECT id FROM fiscal_periods WHERE period_name = 'FY2026-Q1' LIMIT 1);

-- Assets
UPDATE account_balances SET opening_balance = 10700000.00, debit_movements = 3200000.00, credit_movements = 2100000.00, closing_balance = 11800000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '1001' LIMIT 1) AND fiscal_period_id = @fy2026q1;
UPDATE account_balances SET opening_balance = 900000.00, debit_movements = 2100000.00, credit_movements = 1200000.00, closing_balance = 1800000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '1002' LIMIT 1) AND fiscal_period_id = @fy2026q1;
UPDATE account_balances SET opening_balance = 500000.00, debit_movements = 850000.00, credit_movements = 400000.00, closing_balance = 950000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '1003' LIMIT 1) AND fiscal_period_id = @fy2026q1;
UPDATE account_balances SET opening_balance = 1100000.00, debit_movements = 600000.00, credit_movements = 200000.00, closing_balance = 1500000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '1004' LIMIT 1) AND fiscal_period_id = @fy2026q1;
UPDATE account_balances SET opening_balance = 300000.00, debit_movements = 200000.00, credit_movements = 50000.00, closing_balance = 450000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '1005' LIMIT 1) AND fiscal_period_id = @fy2026q1;
UPDATE account_balances SET opening_balance = 4750000.00, debit_movements = 500000.00, credit_movements = 500000.00, closing_balance = 4750000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '1006' LIMIT 1) AND fiscal_period_id = @fy2026q1;
UPDATE account_balances SET opening_balance = 1250000.00, debit_movements = 300000.00, credit_movements = 300000.00, closing_balance = 1250000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '1007' LIMIT 1) AND fiscal_period_id = @fy2026q1;

-- Liabilities
UPDATE account_balances SET opening_balance = 800000.00, debit_movements = 500000.00, credit_movements = 950000.00, closing_balance = 1250000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '2001' LIMIT 1) AND fiscal_period_id = @fy2026q1;
UPDATE account_balances SET opening_balance = 550000.00, debit_movements = 200000.00, credit_movements = 450000.00, closing_balance = 800000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '2002' LIMIT 1) AND fiscal_period_id = @fy2026q1;
UPDATE account_balances SET opening_balance = 550000.00, debit_movements = 100000.00, credit_movements = 350000.00, closing_balance = 800000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '2003' LIMIT 1) AND fiscal_period_id = @fy2026q1;
UPDATE account_balances SET opening_balance = 1100000.00, debit_movements = 300000.00, credit_movements = 700000.00, closing_balance = 1500000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '2004' LIMIT 1) AND fiscal_period_id = @fy2026q1;
UPDATE account_balances SET opening_balance = 450000.00, debit_movements = 150000.00, credit_movements = 400000.00, closing_balance = 700000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '2005' LIMIT 1) AND fiscal_period_id = @fy2026q1;
UPDATE account_balances SET opening_balance = 300000.00, debit_movements = 100000.00, credit_movements = 250000.00, closing_balance = 450000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '2006' LIMIT 1) AND fiscal_period_id = @fy2026q1;

-- Equity
UPDATE account_balances SET opening_balance = 10000000.00, debit_movements = 0.00, credit_movements = 0.00, closing_balance = 10000000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '3001' LIMIT 1) AND fiscal_period_id = @fy2026q1;
UPDATE account_balances SET opening_balance = 2500000.00, debit_movements = 0.00, credit_movements = 500000.00, closing_balance = 3000000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '3002' LIMIT 1) AND fiscal_period_id = @fy2026q1;
UPDATE account_balances SET opening_balance = 1800000.00, debit_movements = 0.00, credit_movements = 700000.00, closing_balance = 2500000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '3003' LIMIT 1) AND fiscal_period_id = @fy2026q1;

-- Revenue
UPDATE account_balances SET opening_balance = 3500000.00, debit_movements = 0.00, credit_movements = 4200000.00, closing_balance = 7700000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '4001' LIMIT 1) AND fiscal_period_id = @fy2026q1;
UPDATE account_balances SET opening_balance = 1200000.00, debit_movements = 0.00, credit_movements = 1500000.00, closing_balance = 2700000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '4002' LIMIT 1) AND fiscal_period_id = @fy2026q1;
UPDATE account_balances SET opening_balance = 450000.00, debit_movements = 0.00, credit_movements = 550000.00, closing_balance = 1000000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '4003' LIMIT 1) AND fiscal_period_id = @fy2026q1;
UPDATE account_balances SET opening_balance = 350000.00, debit_movements = 0.00, credit_movements = 450000.00, closing_balance = 800000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '4004' LIMIT 1) AND fiscal_period_id = @fy2026q1;

-- Expenses
UPDATE account_balances SET opening_balance = 1850000.00, debit_movements = 2400000.00, credit_movements = 0.00, closing_balance = 4250000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '5001' LIMIT 1) AND fiscal_period_id = @fy2026q1;
UPDATE account_balances SET opening_balance = 450000.00, debit_movements = 600000.00, credit_movements = 0.00, closing_balance = 1050000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '5002' LIMIT 1) AND fiscal_period_id = @fy2026q1;
UPDATE account_balances SET opening_balance = 280000.00, debit_movements = 350000.00, credit_movements = 0.00, closing_balance = 630000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '5003' LIMIT 1) AND fiscal_period_id = @fy2026q1;
UPDATE account_balances SET opening_balance = 350000.00, debit_movements = 450000.00, credit_movements = 0.00, closing_balance = 800000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '5004' LIMIT 1) AND fiscal_period_id = @fy2026q1;
UPDATE account_balances SET opening_balance = 180000.00, debit_movements = 250000.00, credit_movements = 0.00, closing_balance = 430000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '5005' LIMIT 1) AND fiscal_period_id = @fy2026q1;
UPDATE account_balances SET opening_balance = 250000.00, debit_movements = 320000.00, credit_movements = 0.00, closing_balance = 570000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '5006' LIMIT 1) AND fiscal_period_id = @fy2026q1;
UPDATE account_balances SET opening_balance = 340000.00, debit_movements = 430000.00, credit_movements = 0.00, closing_balance = 770000.00 WHERE account_id = (SELECT id FROM accounts WHERE code = '5007' LIMIT 1) AND fiscal_period_id = @fy2026q1;

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
SELECT 'Account Types:', COUNT(*) FROM account_types
UNION ALL
SELECT 'Accounts:', COUNT(*) FROM accounts
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
SELECT 'Expense Categories:', COUNT(*) FROM expense_categories
UNION ALL
SELECT 'Loan Types:', COUNT(*) FROM loan_types
UNION ALL
SELECT 'Journal Entries:', COUNT(*) FROM journal_entries
UNION ALL
SELECT 'Journal Lines:', COUNT(*) FROM journal_lines
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
SELECT 'Account Balances:', COUNT(*) FROM account_balances
UNION ALL
SELECT 'Loan Applications:', COUNT(*) FROM loan_applications
UNION ALL
SELECT 'Bank Transactions:', COUNT(*) FROM bank_transactions
UNION ALL
SELECT 'Bank Customers:', COUNT(*) FROM bank_customers
UNION ALL
SELECT 'Transaction Types:', COUNT(*) FROM transaction_types;

-- Verify account balances are calculated correctly
SELECT 
    'ACCOUNT BALANCE VERIFICATION' AS check_type,
    COUNT(*) as total_accounts,
    SUM(CASE WHEN closing_balance > 0 THEN 1 ELSE 0 END) as debit_balance_accounts,
    SUM(CASE WHEN closing_balance < 0 THEN 1 ELSE 0 END) as credit_balance_accounts,
    SUM(CASE WHEN closing_balance = 0 THEN 1 ELSE 0 END) as zero_balance_accounts
FROM account_balances;

-- Trial balance check
SELECT 
    'TRIAL BALANCE CHECK' AS check_type,
    SUM(debit_movements) as total_debits,
    SUM(credit_movements) as total_credits,
    SUM(debit_movements) - SUM(credit_movements) as difference,
    CASE 
        WHEN ABS(SUM(debit_movements) - SUM(credit_movements)) < 0.01 THEN 'BALANCED'
        ELSE 'UNBALANCED'
    END as status
FROM account_balances;

-- Check GAAP compliance (should show balanced books)
SELECT 
    'GAAP Compliance Check' as check_type,
    SUM(jl.debit) as total_debits,
    SUM(jl.credit) as total_credits,
    CASE 
        WHEN ABS(SUM(jl.debit) - SUM(jl.credit)) < 0.01 THEN 'BALANCED'
        ELSE 'UNBALANCED'
    END as status
FROM journal_lines jl
INNER JOIN journal_entries je ON jl.journal_entry_id = je.id
WHERE je.status = 'posted';

-- Check SOX compliance (segregation of duties)
SELECT 
    'SOX Compliance Check' as check_type,
    COUNT(*) as total_entries,
    SUM(CASE WHEN created_by != posted_by THEN 1 ELSE 0 END) as segregated_entries,
    ROUND((SUM(CASE WHEN created_by != posted_by THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) as segregation_percentage
FROM journal_entries
WHERE status = 'posted';

-- Check BIR compliance (documentation)
SELECT 
    'BIR Compliance Check' as check_type,
    COUNT(*) as total_entries,
    SUM(CASE WHEN reference_no IS NOT NULL AND reference_no != '' THEN 1 ELSE 0 END) as documented_entries,
    ROUND((SUM(CASE WHEN reference_no IS NOT NULL AND reference_no != '' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) as documentation_percentage
FROM journal_entries
WHERE status = 'posted';

-- Financial Summary
SELECT 
    'FINANCIAL SUMMARY' AS section,
    'Total Assets' AS category,
    SUM(CASE WHEN at.category = 'asset' THEN ab.closing_balance ELSE 0 END) AS amount
FROM account_balances ab
JOIN accounts a ON ab.account_id = a.id
JOIN account_types at ON a.type_id = at.id
WHERE ab.fiscal_period_id = (SELECT id FROM fiscal_periods WHERE period_name = 'FY2025-Q1' LIMIT 1)

UNION ALL

SELECT 
    'FINANCIAL SUMMARY',
    'Total Liabilities',
    SUM(CASE WHEN at.category = 'liability' THEN ab.closing_balance ELSE 0 END)
FROM account_balances ab
JOIN accounts a ON ab.account_id = a.id
JOIN account_types at ON a.type_id = at.id
WHERE ab.fiscal_period_id = (SELECT id FROM fiscal_periods WHERE period_name = 'FY2025-Q1' LIMIT 1)

UNION ALL

SELECT 
    'FINANCIAL SUMMARY',
    'Total Equity',
    SUM(CASE WHEN at.category = 'equity' THEN ab.closing_balance ELSE 0 END)
FROM account_balances ab
JOIN accounts a ON ab.account_id = a.id
JOIN account_types at ON a.type_id = at.id
WHERE ab.fiscal_period_id = (SELECT id FROM fiscal_periods WHERE period_name = 'FY2025-Q1' LIMIT 1)

UNION ALL

SELECT 
    'FINANCIAL SUMMARY',
    'Total Revenue',
    SUM(CASE WHEN at.category = 'revenue' THEN ab.closing_balance ELSE 0 END)
FROM account_balances ab
JOIN accounts a ON ab.account_id = a.id
JOIN account_types at ON a.type_id = at.id
WHERE ab.fiscal_period_id = (SELECT id FROM fiscal_periods WHERE period_name = 'FY2025-Q1' LIMIT 1)

UNION ALL

SELECT 
    'FINANCIAL SUMMARY',
    'Total Expenses',
    SUM(CASE WHEN at.category = 'expense' THEN ab.closing_balance ELSE 0 END)
FROM account_balances ab
JOIN accounts a ON ab.account_id = a.id
JOIN account_types at ON a.type_id = at.id
WHERE ab.fiscal_period_id = (SELECT id FROM fiscal_periods WHERE period_name = 'FY2025-Q1' LIMIT 1);

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
    'Journal Entries (Last 30 days)' AS activity,
    COUNT(*) AS count
FROM journal_entries
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)

UNION ALL

SELECT 
    'RECENT ACTIVITY SUMMARY',
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
