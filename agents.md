# 🤖 System Agents & Automation

This document outlines the automated "Agents" and background processes that power the Accounting & Finance system. These components handle real-time synchronization, automatic journal entry generation, and subsystem integrations.

## 📡 Inbound Integration Agents
These agents respond to events in external subsystems and automatically create corresponding financial records in the General Ledger.

### 🏦 Bank Transaction Agent
*   **Trigger:** `after_bank_transaction_insert` (MySQL)
*   **Role:** Monitors customer deposits, withdrawals, and transfers in the Bank system.
*   **Action:** Automatically creates **Cash Receipt (CR)** or **Cash Disbursement (CD)** journal entries.
*   **Mapping:**
    *   **Deposits:** Debit: Cash | Credit: Accounts Receivable
    *   **Withdrawals:** Debit: Accounts Receivable | Credit: Cash

### 💰 Loan Disbursement Agent
*   **Trigger:** `after_loan_disbursement` (MySQL)
*   **Role:** Monitors the Loan Subsystem for disbursed loans.
*   **Action:** Automatically creates **General Journal (GJ)** entries for the disbursement.
*   **Mapping:** Debit: Loan Receivable | Credit: Cash

### 💳 Loan Payment Agent
*   **Trigger:** `after_loan_payment` (MySQL)
*   **Role:** Monitors loan repayment events.
*   **Action:** Automatically splits payments into principal and interest portions and creates **Cash Receipt (CR)** entries.
*   **Mapping:** Debit: Cash | Credit: Loan Receivable (Principal) | Credit: Interest Income (Interest)

## 💼 Internal Module Agents
These agents manage complex internal financial logic within the Accounting system.

### 👥 Payroll Integration Agent
*   **Trigger:** `after_payroll_run_insert` (MySQL)
*   **Module:** `modules/api/payroll-actions.php`
*   **Role:** Bridges the HRIS payroll data with the General Ledger.
*   **Action:** Calculates gross pay, net pay, and mandatory deductions (SSS, PhilHealth, Pag-IBIG) to generate **Payroll (PR)** journal entries.
*   **Mapping:** Debit: Salaries Expense | Credit: Cash/Bank (Net) | Credit: Salaries Payable (Deductions)

### 📊 Expense Processing Agent
*   **Module:** `modules/expense-tracking.php`
*   **Role:** Manages the lifecycle of employee expense claims.
*   **Action:** Validates claims and generates automatic journal entries upon approval.
*   **Mapping:** Debit: [Category] Expense | Credit: Salaries/Accounts Payable

## 🛠️ Operational Maintenance

### Health Monitoring
To verify that all agents are active and functioning correctly, you can run the following SQL command:

```sql
-- Check status of all system triggers
SHOW TRIGGERS WHERE `Trigger` LIKE 'after_%';
```

### Manual Intervention
If an automated event fails to trigger, the following utility scripts can be used to re-sync the systems:

*   `database/sql/install_triggers.php`: Re-installs all automation triggers.
*   `test_db_connection.php`: Verifies that the internal agents can communicate with the data layer.

---
**Last Updated:** March 2026  
**System Version:** 1.1.0-INTEGRATED
