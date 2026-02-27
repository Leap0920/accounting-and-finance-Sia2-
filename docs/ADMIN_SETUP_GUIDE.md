# 📋 Accounting & Finance System - Administrator Setup Guide

> **Complete Step-by-Step Guide for Setting Up the Accounting & Finance System**
> Last Updated: December 2024
> Version: 1.1.0

***

## 📑 Table of Contents

1. [Prerequisites](#-prerequisites)
2. [Step 1: Install and Configure XAMPP](#step-1-install-and-configure-xampp)
3. [Step 2: Start Apache and MySQL Services](#step-2-start-apache-and-mysql-services)
4. [Step 3: Place Project Files](#step-3-place-project-files)
5. [Step 4: Access phpMyAdmin](#step-4-access-phpmyadmin)
6. [Step 5: Import Database Files](#step-5-import-database-files)
7. [Step 6: Access the Application](#step-6-access-the-application)
8. [Step 7: Login to the System](#step-7-login-to-the-system)
9. [Troubleshooting](#-troubleshooting)
10. [System Credentials](#-system-credentials)

***

## 🔧 Prerequisites

Before starting, ensure you have the following:

| Requirement     | Minimum Version       | Recommended    |
| --------------- | --------------------- | -------------- |
| **XAMPP**       | 3.3.0                 | Latest version |
| **PHP**         | 7.4                   | 8.0+           |
| **MySQL**       | 5.7                   | 8.0+           |
| **Apache**      | 2.4                   | Latest         |
| **Web Browser** | Chrome, Firefox, Edge | Latest version |

### Download XAMPP

If you don't have XAMPP installed, download it from:

* 🔗 [https://www.apachefriends.org/download.html](https://www.apachefriends.org/download.html)

***






## Step 1: Install and Configure XAMPP

### 1.1 Installation Location

XAMPP should be installed in the default location:


```
C:\xampp\
```

### 1.2 Verify Installation

After installation, you should have this folder structure:

```
C:\xampp\
├── apache/
├── htdocs/           ← This is where web applications go
├── mysql/
├── php/
└── xampp-control.exe ← Control panel to start/stop services
```

***

## Step 2: Start Apache and MySQL Services

### 2.1 Open XAMPP Control Panel

1. Navigate to `C:\xampp\`
2. Double-click **`xampp-control.exe`** to open the Control Panel

### 2.2 Start Apache

1. Click the **"Start"** button next to **Apache**
2. Wait until the module name turns **GREEN**
3. Status should show: `Running`

### 2.3 Start MySQL

1. Click the **"Start"** button next to **MySQL**
2. Wait until the module name turns **GREEN**
3. Status should show: `Running`

### 2.4 Verify Services Are Running

Your XAMPP Control Panel should look like this:

```
┌─────────────────────────────────────────────────────────┐
│  Module        PID(s)    Port(s)    Actions            │
├─────────────────────────────────────────────────────────┤
│  Apache       [GREEN]    80, 443    Stop | Admin       │
│  MySQL        [GREEN]    3306       Stop | Admin       │
│  FileZilla    [      ]   21         Start              │
│  Mercury      [      ]              Start              │
│  Tomcat       [      ]              Start              │
└─────────────────────────────────────────────────────────┘
```

> ⚠️ **Important:** Both Apache and MySQL must be running (GREEN) before proceeding!

***

## Step 3: Place Project Files

### 3.1 Project Location

The Accounting & Finance project should be placed in:

```
C:\xampp\htdocs\Evergreen\accounting-and-finance\
```

### 3.2 Complete Folder Structure (Evergreen)

Your `htdocs` folder should contain:

```
C:\xampp\htdocs\
└── Evergreen/
    ├── accounting-and-finance/    ← Main Accounting System
    │   ├── assets/
    │   ├── config/
    │   ├── core/
    │   ├── database/
    │   │   └── sql/
    │   │       ├── unified_schema.sql    ← Database schema
    │   │       ├── location_data.sql     ← Philippine location data
    │   │       └── Sampled_data.sql      ← Sample data
    │   ├── docs/
    │   ├── includes/
    │   ├── modules/
    │   └── utils/

```

### 3.3 Verify Files Exist

Make sure these SQL files are present:

| # | File Location                                                        | Description                              |
| - | -------------------------------------------------------------------- | ---------------------------------------- |
| 1 | `accounting-and-finance/database/sql/unified_schema.sql`             | Main database schema (tables, structure) |
| 2 | `accounting-and-finance/database/sql/location_data.sql`              | Philippine provinces, cities, barangays  |
| 3 | `accounting-and-finance/database/sql/Sampled_data.sql`               | Sample data, admin users, test data      |
| 4 | `accounting-and-finance/database/12-14-25 ALTER DB CHANGES HRIS.sql` | HRIS role and supervisor changes         |

***

## Step 4: Access phpMyAdmin

### 4.1 Open phpMyAdmin

1. Open your web browser (Chrome, Firefox, or Edge)
2. Type in the address bar:
   ```
   http://localhost/phpmyadmin/
   ```
3. Press **Enter**

### 4.2 phpMyAdmin Interface

You should see the phpMyAdmin dashboard:

```
┌─────────────────────────────────────────────────────────────────┐
│  phpMyAdmin                                                     │
├──────────────────┬──────────────────────────────────────────────┤
│                  │                                              │
│  Server: MySQL   │   General Settings                          │
│  └── Databases   │   Database server:                          │
│      └── mysql   │   • Server: localhost via TCP/IP            │
│      └── test    │   • Server version: 10.4.xx - MariaDB       │
│      └── ...     │                                              │
│                  │   [Databases] [SQL] [Status] [Export]        │
│                  │                                              │
└──────────────────┴──────────────────────────────────────────────┘
```

***

## Step 5: Import Database Files

### ⚡ IMPORTANT: Import Order

The SQL files **MUST** be imported in this specific order:

| Order | File                                 | Description                                  |
| :---: | ------------------------------------ | -------------------------------------------- |
| **1** | `unified_schema.sql`                 | Creates the database and all tables          |
| **2** | `location_data.sql`                  | Populates Philippine location data           |
| **3** | `Sampled_data.sql`                   | Adds admin users, sample employees, accounts |
| **4** | `12-14-25 ALTER DB CHANGES HRIS.sql` | HRIS role management updates                 |

***

### 5.1 Import: unified_schema.sql (Database Schema)

1. Click on the **"Import"** tab at the top menu
2. Click **"Choose File"** or **"Browse"**
3. Navigate to:
   ```
   C:\xampp\htdocs\Evergreen\accounting-and-finance\database\sql\
   ```
4. Select **`unified_schema.sql`**
5. Make sure these settings are correct:
   * Character set: `utf-8`
   * Format: `SQL`
6. Click **"Go"** or **"Import"** button
7. Wait for success message: ✅ `Import has been successfully finished`

> ⚠️ This creates the `BankingDB` database with all tables!

***

### 5.2 Import: location_data.sql (Philippine Locations)

1. **First, select the BankingDB database** from the left sidebar
2. Click on the **"Import"** tab
3. Click **"Choose File"**
4. Navigate to:
   ```
   C:\xampp\htdocs\Evergreen\accounting-and-finance\database\sql\
   ```
5. Select **`location_data.sql`**
6. Click **"Go"** or **"Import"** button

> ⚠️ **Note:** This file is large (483,000+ lines). Import may take 1-2 minutes.If you get a timeout error, try:- Using the phpMyAdmin SQL tab to paste file contents- Or use MySQL command line

***

### 5.3 Import: Sampled_data.sql (Admin & Sample Data)

1. Ensure **`BankingDB`** is selected in the left sidebar
2. Click on the **"Import"** tab
3. Click **"Choose File"**
4. Navigate to:
   ```
   C:\xampp\htdocs\Evergreen\accounting-and-finance\database\sql\
   ```
5. Select **`Sampled_data.sql`**
6. Click **"Go"** or **"Import"** button
7. Wait for success message

> ✅ **This file creates:**- Admin user account- Sample employees- Chart of accounts- Departments and positions- Sample attendance data
> - Fiscal periods
> - And more...

***

### 5.4 Import: HRIS Migration Script

1. Ensure **`BankingDB`** is selected in the left sidebar
2. Click on the **"Import"** tab
3. Click **"Choose File"**
4. Navigate to:
   ```
   C:\xampp\htdocs\Evergreen\hris-sia\config\migrations\
   ```
5. Select **`12-14-25 ALTER DB CHANGES HRIS.sql`**
6. Click **"Go"** or **"Import"** button
7. Wait for success messages showing:
   * `Manager role migrated to Supervisor`
   * `Department supervisors created!`
   * `=== MIGRATION COMPLETE ===`

***

### 5.5 Verify Database Import

After all imports, your `BankingDB` database should have these key tables:

| Core Tables       | HRIS Tables     | Banking Tables         |
| ----------------- | --------------- | ---------------------- |
| `users`           | `employee`      | `bank_customers`       |
| `roles`           | `department`    | `bank_accounts`        |
| `user_account`    | `position`      | `bank_transactions`    |
| `accounts`        | `attendance`    | `customer_accounts`    |
| `journal_entries` | `leave_request` | `bank_employees`       |
| `fiscal_periods`  | `employee_refs` | `account_applications` |

To verify:

1. Click on **`BankingDB`** in the left sidebar
2. You should see 50+ tables listed

***

## Step 6: Access the Application

### 6.1 Navigate to the Application

Open your web browser and go to:

```
http://localhost/Evergreen/accounting-and-finance/
```

Or directly to the login page:

```
http://localhost/Evergreen/accounting-and-finance/core/login.php
```

### 6.2 URL Structure

| URL                                                                    | Description                     |
| ---------------------------------------------------------------------- | ------------------------------- |
| `http://localhost/Evergreen/accounting-and-finance/`                   | Main entry (redirects to login) |
| `http://localhost/Evergreen/accounting-and-finance/core/login.php`     | Login page                      |
| `http://localhost/Evergreen/accounting-and-finance/core/dashboard.php` | Dashboard (after login)         |

***

## Step 7: Login to the System

### 7.1 Admin Login Credentials

Use these credentials to log in as administrator:

| Field        | Value              |
| ------------ | ------------------ |
| **Email**    | `admin` |
| **Password** | `admin123`         |

### 7.2 After Successful Login

You will be redirected to the **Dashboard** with access to:

* 📊 **Dashboard** - Overview and statistics
* 📈 **Transaction Reading** - View all transactions
* 📒 **General Ledger** - Journal entries and accounts
* 💰 **Payroll Management** - Process employee payroll
* 📑 **Expense Tracking** - Manage expenses
* 📋 **Financial Reporting** - Generate reports
* 🏦 **Loan Accounting** - Manage loans

***

## 🔧 Troubleshooting

### Problem: "Cannot connect to database"

**Solution:**

1. Verify MySQL is running in XAMPP Control Panel
2. Check `config/database.php` settings:
   ```php
   $host = 'localhost';
   $dbname = 'BankingDB';
   $username = 'root';
   $password = '';  // Empty for XAMPP default
   ```

***

### Problem: "User not found" or "Invalid credentials"

**Solution:**

1. Ensure `Sampled_data.sql` was imported successfully
2. Check if the `users` table has the admin user:
   * Go to phpMyAdmin
   * Select `BankingDB` → `users` table
   * Verify [`admin@system.com`](mailto\:admin@system.com) exists
3. Try resetting admin password:
   * Go to: `http://localhost/Evergreen/accounting-and-finance/utils/fix_admin_password.php`

***

### Problem: "Table doesn't exist" errors

**Solution:**

1. Re-import `unified_schema.sql`
2. Make sure `BankingDB` database exists

***

### Problem: Import timeout for large files

**Solution for `location_data.sql`:**

1. Open `C:\xampp\php\php.ini`
2. Find and increase these values:
   ```ini
   max_execution_time = 300
   max_input_time = 300
   memory_limit = 512M
   post_max_size = 200M
   upload_max_filesize = 200M
   ```
3. Restart Apache
4. Try importing again

***

## ✅ Setup Checklist

Use this checklist to verify your setup:

* [ ] XAMPP installed at `C:\xampp\`
* [ ] Apache service is running (GREEN)
* [ ] MySQL service is running (GREEN)
* [ ] Project files in `C:\xampp\htdocs\Evergreen\accounting-and-finance\`
* [ ] `unified_schema.sql` imported successfully
* [ ] `location_data.sql` imported successfully
* [ ] `Sampled_data.sql` imported successfully
* [ ] `12-14-25 ALTER DB CHANGES HRIS.sql` imported successfully
* [ ] Can access `http://localhost/phpmyadmin/`
* [ ] `BankingDB` database exists with 50+ tables
* [ ] Can access `http://localhost/Evergreen/accounting-and-finance/`
* [ ] Can login with [`admin@system.com`](mailto\:admin@system.com) / `admin123`
* [ ] Dashboard loads correctly

***

## 📞 Need Help?

If you encounter issues not covered in this guide:

1. 📖 Check other documentation in the `docs/` folder
2. 🔍 Review error messages in the browser console (F12)
3. 📋 Check XAMPP error logs: `C:\xampp\apache\logs\error.log`
4. 💻 Contact Carlo Baclao for questions!

***

**Document Version:** 1.0
**Created:** December 2024
**Compatible with:** XAMPP 3.3+, PHP 7.4+, MySQL 5.7+