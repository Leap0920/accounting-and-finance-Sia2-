<?php
/**
 * Payroll Actions API
 * Handles processing and finalizing payroll, including GL posting
 */

// Suppress error display to prevent JSON corruption; errors still logged
ini_set('display_errors', 0);
error_reporting(E_ALL);

require_once '../../config/database.php';
require_once '../../includes/session.php';
require_once 'payroll-calculation.php';

// Require login
if (!isLoggedIn()) {
    header('Content-Type: application/json');
    echo json_encode(['success' => false, 'error' => 'Authentication required']);
    exit;
}

$action = $_POST['action'] ?? ($_GET['action'] ?? '');

if ($action === 'finalize_payroll') {
    finalizePayroll($conn);
} elseif ($action === 'preview_payroll') {
    previewPayroll($conn);
} else {
    header('Content-Type: application/json');
    echo json_encode(['success' => false, 'error' => 'Invalid action']);
    exit;
}

function finalizePayroll($conn)
{
    header('Content-Type: application/json');

    $month = $_POST['month'] ?? '';
    $period = $_POST['period'] ?? '';

    if (empty($month) || empty($period)) {
        echo json_encode(['success' => false, 'error' => 'Month and period are required']);
        return;
    }

    // Validate month format (YYYY-MM)
    if (!preg_match('/^\d{4}-\d{2}$/', $month)) {
        echo json_encode(['success' => false, 'error' => 'Invalid month format']);
        return;
    }

    if (!in_array($period, ['first', 'second', 'full'])) {
        echo json_encode(['success' => false, 'error' => 'Invalid period value']);
        return;
    }

    // Determine date range
    $date_from = '';
    $date_to = '';
    $last_day = date('t', strtotime($month . '-01'));

    if ($period === 'first') {
        $date_from = $month . '-01';
        $date_to = $month . '-15';
    } elseif ($period === 'second') {
        $date_from = $month . '-16';
        $date_to = $month . '-' . $last_day;
    } else {
        $date_from = $month . '-01';
        $date_to = $month . '-' . $last_day;
    }

    // Prepare per-employee duplicate check (replaces blanket period-level block)
    // This allows processing employees in batches — only skip individuals already processed
    $emp_dup_stmt = $conn->prepare(
        "SELECT ps.id FROM payslips ps
         INNER JOIN payroll_runs pr ON ps.payroll_run_id = pr.id
         INNER JOIN payroll_periods pp ON pr.payroll_period_id = pp.id
         LEFT JOIN journal_entries je ON je.id = pr.journal_entry_id
         WHERE ps.employee_external_no = ?
         AND pp.period_start = ? AND pp.period_end = ?
         AND pr.status IN ('finalized','completed')
         AND (je.id IS NULL OR je.status != 'voided')
         LIMIT 1"
    );

    // Check if specific employees were selected
    $selected_employees_json = $_POST['selected_employees'] ?? '';
    $selected_employees = [];
    if (!empty($selected_employees_json)) {
        $selected_employees = json_decode($selected_employees_json, true);
        if (!is_array($selected_employees)) {
            $selected_employees = [];
        }
    }

    // 1. Fetch all active employees
    $employees_query = "SELECT 
                            e.employee_id, 
                            e.first_name, 
                            e.last_name, 
                            er.external_employee_no,
                            c.salary as contract_salary,
                            er.base_monthly_salary
                        FROM employee e 
                        INNER JOIN employee_refs er ON e.employee_id = CAST(SUBSTRING(er.external_employee_no, 4) AS UNSIGNED)
                        LEFT JOIN contract c ON e.contract_id = c.contract_id
                        WHERE e.employment_status = 'active'";

    $employees_result = $conn->query($employees_query);
    if (!$employees_result) {
        echo json_encode(['success' => false, 'error' => 'Failed to fetch employees: ' . $conn->error]);
        return;
    }

    $payroll_results = [];
    $total_gross = 0;
    $total_sss = 0;
    $total_philhealth = 0;
    $total_pagibig = 0;
    $total_wht = 0;
    $total_net = 0;
    $total_other_deductions = 0;

    // Pre-fetch other deductions once (not per employee)
    $other_deductions_total_per_emp = 0;
    $deductions_res = $conn->query("SELECT code, value FROM salary_components WHERE type = 'deduction' AND is_active = 1");
    if ($deductions_res) {
        while ($ded = $deductions_res->fetch_assoc()) {
            if (!in_array($ded['code'], ['SSS_EMP', 'PAGIBIG_EMP', 'PHILHEALTH_EMP', 'WHT'])) {
                $other_deductions_total_per_emp += floatval($ded['value'] ?? 0);
            }
        }
    }

    // 2. Calculate payroll for each employee
    $skipped_employees = [];
    while ($emp = $employees_result->fetch_assoc()) {
        $ext_no = $emp['external_employee_no'];

        // Skip employees not in the selected list (if a selection was provided)
        if (!empty($selected_employees) && !in_array($ext_no, $selected_employees)) {
            continue;
        }

        // Skip employees who already have an active (non-voided) payslip for this period
        $emp_dup_stmt->bind_param("sss", $ext_no, $date_from, $date_to);
        $emp_dup_stmt->execute();
        if ($emp_dup_stmt->get_result()->fetch_assoc()) {
            $skipped_employees[] = trim($emp['first_name'] . ' ' . $emp['last_name']);
            continue;
        }

        // Use existing calculation function
        $calc = calculatePayrollFromAttendance($conn, $ext_no, $date_from, $date_to);

        if ($calc && isset($calc['salary_adjustments'])) {
            $adj = $calc['salary_adjustments'];
            $gross = $adj['gross_salary'] ?? 0;

            // Mandatory contributions
            $basic_for_contrib = $adj['prorated_base_salary'] ?? ($emp['contract_salary'] > 0 ? $emp['contract_salary'] : $emp['base_monthly_salary']);
            $sss = calculateSSSContribution($basic_for_contrib);
            $philhealth = calculatePhilHealthContribution($basic_for_contrib);
            $pagibig = calculatePagIBIGContribution($basic_for_contrib);

            // Taxable income
            $taxable = $gross - $sss['employee'] - $philhealth['employee'] - $pagibig['employee'];
            $wht = calculateBIRWithholdingTax($taxable);

            $net = ($calc['salary_adjustments']['net_salary_before_tax'] ?? $gross) - $sss['employee'] - $philhealth['employee'] - $pagibig['employee'] - $wht - $other_deductions_total_per_emp;

            $payroll_results[] = [
                'employee_no' => $ext_no,
                'gross' => $gross,
                'sss' => $sss['employee'],
                'philhealth' => $philhealth['employee'],
                'pagibig' => $pagibig['employee'],
                'wht' => $wht,
                'net' => $net,
                'other_deductions' => $other_deductions_total_per_emp,
                'calc_json' => json_encode($calc)
            ];

            $total_gross += $gross;
            $total_sss += $sss['employee'];
            $total_philhealth += $philhealth['employee'];
            $total_pagibig += $pagibig['employee'];
            $total_wht += $wht;
            $total_net += $net;
            $total_other_deductions += $other_deductions_total_per_emp;
        }
    }

    if (empty($payroll_results)) {
        if (!empty($skipped_employees)) {
            $count = count($skipped_employees);
            if ($count <= 3) {
                $names = implode(', ', $skipped_employees);
            } else {
                $names = implode(', ', array_slice($skipped_employees, 0, 3)) . ' and ' . ($count - 3) . ' more';
            }
            echo json_encode(['success' => false, 'error' => "All $count selected employees have already been processed for this period. Skipped: $names"]);
        } else {
            echo json_encode(['success' => false, 'error' => 'No payroll data found for the selected period']);
        }
        return;
    }

    // Helper: get account ID by code using prepared statement
    $acct_stmt = $conn->prepare("SELECT id FROM accounts WHERE code = ? AND is_active = 1 LIMIT 1");
    $getAccountId = function ($code) use ($acct_stmt) {
        $acct_stmt->bind_param("s", $code);
        $acct_stmt->execute();
        $res = $acct_stmt->get_result();
        $row = $res->fetch_assoc();
        return $row ? (int)$row['id'] : null;
    };

    // Pre-validate required GL accounts exist before starting the transaction
    $acc_salaries_expense = $getAccountId('6101'); // Salaries and Wages (Expense)
    $acc_salaries_payable = $getAccountId('2101'); // Salaries Payable (Liability)
    $acc_wht_payable      = $getAccountId('2203'); // Withholding Tax Payable
    $acc_sss_payable      = $getAccountId('2301'); // SSS Payable
    $acc_ph_payable       = $getAccountId('2302'); // PhilHealth Payable
    $acc_pi_payable       = $getAccountId('2303'); // Pag-IBIG Payable

    if (!$acc_salaries_expense || !$acc_salaries_payable) {
        echo json_encode(['success' => false, 'error' => 'Required GL accounts missing (6101 Salaries Expense or 2101 Salaries Payable). Please set up the Chart of Accounts first.']);
        return;
    }

    // Lookup journal type 'PR' (Payroll) dynamically
    $jt_res = $conn->query("SELECT id FROM journal_types WHERE code = 'PR' LIMIT 1");
    $jt_row = $jt_res ? $jt_res->fetch_assoc() : null;
    if (!$jt_row) {
        echo json_encode(['success' => false, 'error' => 'Journal type "PR" (Payroll) not found. Please run the database seed.']);
        return;
    }
    $journal_type_id = (int)$jt_row['id'];

    // 3. Start Transaction
    $conn->begin_transaction();

    try {
        // Find or create payroll period
        $period_check = $conn->prepare("SELECT id FROM payroll_periods WHERE period_start = ? AND period_end = ? LIMIT 1");
        $period_check->bind_param("ss", $date_from, $date_to);
        $period_check->execute();
        $period_res = $period_check->get_result();

        if ($row = $period_res->fetch_assoc()) {
            $period_id = (int)$row['id'];
        } else {
            $freq = ($period === 'full') ? 'monthly' : 'semimonthly';
            $insert_period = $conn->prepare("INSERT INTO payroll_periods (period_start, period_end, frequency, status, created_at) VALUES (?, ?, ?, 'processing', NOW())");
            $insert_period->bind_param("sss", $date_from, $date_to, $freq);
            $insert_period->execute();
            $period_id = $conn->insert_id;
        }

        $total_deductions = $total_gross - $total_net;
        $user_id = (int)($_SESSION['user_id'] ?? 1);

        // Create payroll_run record
        $run_stmt = $conn->prepare("INSERT INTO payroll_runs (payroll_period_id, run_at, total_gross, total_deductions, total_net, status, run_by_user_id) 
                      VALUES (?, NOW(), ?, ?, ?, 'finalized', ?)");
        $run_stmt->bind_param("idddi", $period_id, $total_gross, $total_deductions, $total_net, $user_id);
        $run_stmt->execute();
        $run_id = $conn->insert_id;

        // Create payslips
        $payslip_stmt = $conn->prepare("INSERT INTO payslips (payroll_run_id, employee_external_no, gross_pay, total_deductions, net_pay, payslip_json, created_at) VALUES (?, ?, ?, ?, ?, ?, NOW())");
        foreach ($payroll_results as $pr) {
            $emp_deductions = $pr['gross'] - $pr['net'];
            $payslip_stmt->bind_param("isddds", $run_id, $pr['employee_no'], $pr['gross'], $emp_deductions, $pr['net'], $pr['calc_json']);
            $payslip_stmt->execute();
        }

        // 4. Create GL Journal Entry
        $journal_no = 'PR-' . date('Ymd') . '-' . strtoupper(substr(uniqid(), -4));
        $period_desc = ($period === 'full') ? 'Full Month' : ($period === 'first' ? '1st Half' : '2nd Half');
        $description = "Payroll — $month ($period_desc)";

        // Get active fiscal period covering the payroll end date
        $fp_stmt = $conn->prepare("SELECT id FROM fiscal_periods WHERE status = 'open' AND start_date <= ? AND end_date >= ? ORDER BY start_date DESC LIMIT 1");
        $fp_stmt->bind_param("ss", $date_to, $date_to);
        $fp_stmt->execute();
        $fp_res = $fp_stmt->get_result();
        $fp_row = $fp_res->fetch_assoc();
        if (!$fp_row) {
            // Fallback: most recent open fiscal period
            $fp_res2 = $conn->query("SELECT id FROM fiscal_periods WHERE status = 'open' ORDER BY start_date DESC LIMIT 1");
            $fp_row = $fp_res2 ? $fp_res2->fetch_assoc() : null;
        }
        if (!$fp_row) {
            // Auto-create a quarterly fiscal period for the payroll date
            $q = ceil(intval(date('m', strtotime($date_to))) / 3);
            $qStart = date('Y', strtotime($date_to)) . '-' . str_pad(($q - 1) * 3 + 1, 2, '0', STR_PAD_LEFT) . '-01';
            $qEnd = date('Y-m-t', strtotime(date('Y', strtotime($date_to)) . '-' . str_pad($q * 3, 2, '0', STR_PAD_LEFT) . '-01'));
            $qName = 'FY' . date('Y', strtotime($date_to)) . '-Q' . $q;
            $fp_create = $conn->prepare("INSERT INTO fiscal_periods (period_name, start_date, end_date, status) VALUES (?, ?, ?, 'open') ON DUPLICATE KEY UPDATE id=LAST_INSERT_ID(id)");
            $fp_create->bind_param("sss", $qName, $qStart, $qEnd);
            $fp_create->execute();
            $fiscal_period_id = $conn->insert_id;
            if (!$fiscal_period_id) {
                throw new Exception('No open fiscal period found and failed to create one. Please create a fiscal period first.');
            }
        } else {
            $fiscal_period_id = (int)$fp_row['id'];
        }

        $je_stmt = $conn->prepare("INSERT INTO journal_entries (journal_no, entry_date, journal_type_id, description, total_debit, total_credit, status, fiscal_period_id, created_by, created_at) 
                     VALUES (?, ?, ?, ?, ?, ?, 'posted', ?, ?, NOW())");
        $je_stmt->bind_param("ssisddii", $journal_no, $date_to, $journal_type_id, $description, $total_gross, $total_gross, $fiscal_period_id, $user_id);
        $je_stmt->execute();
        $je_id = $conn->insert_id;

        // Link journal entry to payroll run
        $upd_run = $conn->prepare("UPDATE payroll_runs SET journal_entry_id = ? WHERE id = ?");
        $upd_run->bind_param("ii", $je_id, $run_id);
        $upd_run->execute();

        // 5. Create Journal Lines  (Debit Expense / Credit Liabilities)
        $line_stmt = $conn->prepare("INSERT INTO journal_lines (journal_entry_id, account_id, memo, debit, credit) VALUES (?, ?, ?, ?, ?)");
        $zero = 0.00;

        // --- DEBIT: Salaries & Wages Expense (6101) for total gross ---
        $memo_dr = 'Salaries & Wages Expense';
        $line_stmt->bind_param("iisdd", $je_id, $acc_salaries_expense, $memo_dr, $total_gross, $zero);
        $line_stmt->execute();

        // --- CREDITS: individual liability accounts ---
        $credit_lines = [
            ['acct' => $acc_salaries_payable, 'amount' => $total_net,          'memo' => 'Net Salaries Payable'],
            ['acct' => $acc_wht_payable,      'amount' => $total_wht,          'memo' => 'Withholding Tax Payable'],
            ['acct' => $acc_sss_payable,      'amount' => $total_sss,          'memo' => 'SSS Contributions Payable'],
            ['acct' => $acc_ph_payable,       'amount' => $total_philhealth,   'memo' => 'PhilHealth Contributions Payable'],
            ['acct' => $acc_pi_payable,       'amount' => $total_pagibig,      'memo' => 'Pag-IBIG Contributions Payable'],
        ];

        // Other deductions → Accounts Receivable - Other (1102) if applicable
        if ($total_other_deductions > 0) {
            $acc_other = $getAccountId('1102');
            if ($acc_other) {
                $credit_lines[] = ['acct' => $acc_other, 'amount' => $total_other_deductions, 'memo' => 'Other Payroll Deductions'];
            }
        }

        $actual_credit_total = 0;
        foreach ($credit_lines as $cl) {
            if ($cl['acct'] && $cl['amount'] > 0) {
                $line_stmt->bind_param("iisdd", $je_id, $cl['acct'], $cl['memo'], $zero, $cl['amount']);
                $line_stmt->execute();
                $actual_credit_total += $cl['amount'];
            }
        }

        // Handle rounding difference so debits = credits
        $rounding_diff = round($total_gross - $actual_credit_total, 2);
        if (abs($rounding_diff) > 0.001) {
            $rounding_memo = 'Payroll Rounding Adjustment';
            if ($rounding_diff > 0) {
                // Credits are short — add difference to Salaries Payable
                $line_stmt->bind_param("iisdd", $je_id, $acc_salaries_payable, $rounding_memo, $zero, $rounding_diff);
            } else {
                // Credits exceed debit — reduce via a small debit line
                $abs_diff = abs($rounding_diff);
                $line_stmt->bind_param("iisdd", $je_id, $acc_salaries_payable, $rounding_memo, $abs_diff, $zero);
            }
            $line_stmt->execute();
        }

        // 6. Update account_balances for each affected account
        $balance_upsert = $conn->prepare(
            "INSERT INTO account_balances (account_id, fiscal_period_id, debit_movements, credit_movements, closing_balance, last_updated)
             VALUES (?, ?, ?, ?, ? - ?, NOW())
             ON DUPLICATE KEY UPDATE
                debit_movements  = debit_movements  + VALUES(debit_movements),
                credit_movements = credit_movements + VALUES(credit_movements),
                closing_balance  = closing_balance + VALUES(debit_movements) - VALUES(credit_movements),
                last_updated     = NOW()"
        );

        // Debit side: Salaries Expense
        $balance_upsert->bind_param("iidddd", $acc_salaries_expense, $fiscal_period_id, $total_gross, $zero, $total_gross, $zero);
        $balance_upsert->execute();

        // Credit side: each liability account
        foreach ($credit_lines as $cl) {
            if ($cl['acct'] && $cl['amount'] > 0) {
                $balance_upsert->bind_param("iidddd", $cl['acct'], $fiscal_period_id, $zero, $cl['amount'], $zero, $cl['amount']);
                $balance_upsert->execute();
            }
        }

        // Update payroll period status
        $upd_period = $conn->prepare("UPDATE payroll_periods SET status = 'posted' WHERE id = ?");
        $upd_period->bind_param("i", $period_id);
        $upd_period->execute();

        $conn->commit();

        echo json_encode([
            'success' => true,
            'message' => 'Payroll processed and posted to GL',
            'journal_no' => $journal_no,
            'journal_entry_id' => $je_id,
            'run_id' => $run_id,
            'summary' => [
                'total_gross' => $total_gross,
                'total_deductions' => $total_deductions,
                'total_net' => $total_net,
                'employees' => count($payroll_results)
            ]
        ]);

    } catch (Exception $e) {
        $conn->rollback();
        echo json_encode(['success' => false, 'error' => 'Database error: ' . $e->getMessage()]);
    }
}

/**
 * Preview payroll calculations for all active employees (read-only, no DB writes)
 */
function previewPayroll($conn)
{
    header('Content-Type: application/json');

    $month = $_POST['month'] ?? ($_GET['month'] ?? '');
    $period = $_POST['period'] ?? ($_GET['period'] ?? '');

    if (empty($month) || empty($period)) {
        echo json_encode(['success' => false, 'error' => 'Month and period are required']);
        return;
    }

    if (!preg_match('/^\d{4}-\d{2}$/', $month)) {
        echo json_encode(['success' => false, 'error' => 'Invalid month format']);
        return;
    }

    if (!in_array($period, ['first', 'second', 'full'])) {
        echo json_encode(['success' => false, 'error' => 'Invalid period value']);
        return;
    }

    $last_day = date('t', strtotime($month . '-01'));
    if ($period === 'first') {
        $date_from = $month . '-01';
        $date_to = $month . '-15';
    } elseif ($period === 'second') {
        $date_from = $month . '-16';
        $date_to = $month . '-' . $last_day;
    } else {
        $date_from = $month . '-01';
        $date_to = $month . '-' . $last_day;
    }

    // Fetch all active employees with department and position info
    $employees_query = "SELECT 
                            e.employee_id, 
                            e.first_name, 
                            e.last_name, 
                            er.external_employee_no,
                            c.salary as contract_salary,
                            er.base_monthly_salary,
                            COALESCE(d.department_name, er.department, '') as department,
                            COALESCE(p.position_title, er.position, '') as position
                        FROM employee e 
                        INNER JOIN employee_refs er ON e.employee_id = CAST(SUBSTRING(er.external_employee_no, 4) AS UNSIGNED)
                        LEFT JOIN contract c ON e.contract_id = c.contract_id
                        LEFT JOIN department d ON e.department_id = d.department_id
                        LEFT JOIN `position` p ON e.position_id = p.position_id
                        WHERE e.employment_status = 'active'
                        ORDER BY e.last_name, e.first_name";

    $employees_result = $conn->query($employees_query);
    if (!$employees_result) {
        echo json_encode(['success' => false, 'error' => 'Failed to fetch employees: ' . $conn->error]);
        return;
    }

    // Prepare per-employee status check for the preview
    $status_stmt = $conn->prepare(
        "SELECT ps.id, pr.status as run_status, je.status as je_status
         FROM payslips ps
         INNER JOIN payroll_runs pr ON ps.payroll_run_id = pr.id
         INNER JOIN payroll_periods pp ON pr.payroll_period_id = pp.id
         LEFT JOIN journal_entries je ON je.id = pr.journal_entry_id
         WHERE ps.employee_external_no = ?
         AND pp.period_start = ? AND pp.period_end = ?
         AND pr.status IN ('finalized','completed')
         ORDER BY ps.id DESC LIMIT 1"
    );

    // Pre-fetch other deductions
    $other_deductions_total_per_emp = 0;
    $deductions_res = $conn->query("SELECT code, value FROM salary_components WHERE type = 'deduction' AND is_active = 1");
    if ($deductions_res) {
        while ($ded = $deductions_res->fetch_assoc()) {
            if (!in_array($ded['code'], ['SSS_EMP', 'PAGIBIG_EMP', 'PHILHEALTH_EMP', 'WHT'])) {
                $other_deductions_total_per_emp += floatval($ded['value'] ?? 0);
            }
        }
    }

    $employees = [];
    $total_gross = 0;
    $total_deductions = 0;
    $total_net = 0;

    while ($emp = $employees_result->fetch_assoc()) {
        $ext_no = $emp['external_employee_no'];
        $name = trim($emp['first_name'] . ' ' . $emp['last_name']);

        $calc = calculatePayrollFromAttendance($conn, $ext_no, $date_from, $date_to);

        if ($calc && isset($calc['salary_adjustments'])) {
            $adj = $calc['salary_adjustments'];
            $gross = $adj['gross_salary'] ?? 0;

            $basic_for_contrib = $adj['prorated_base_salary'] ?? ($emp['contract_salary'] > 0 ? $emp['contract_salary'] : $emp['base_monthly_salary']);
            $sss = calculateSSSContribution($basic_for_contrib);
            $philhealth = calculatePhilHealthContribution($basic_for_contrib);
            $pagibig = calculatePagIBIGContribution($basic_for_contrib);

            $taxable = $gross - $sss['employee'] - $philhealth['employee'] - $pagibig['employee'];
            $wht = calculateBIRWithholdingTax($taxable);

            $net = ($adj['net_salary_before_tax'] ?? $gross) - $sss['employee'] - $philhealth['employee'] - $pagibig['employee'] - $wht - $other_deductions_total_per_emp;
            $emp_deductions = $gross - $net;

            // Determine per-employee processing status for this period
            $emp_status = 'pending';
            $status_stmt->bind_param("sss", $ext_no, $date_from, $date_to);
            $status_stmt->execute();
            $status_row = $status_stmt->get_result()->fetch_assoc();
            if ($status_row) {
                if (isset($status_row['je_status']) && $status_row['je_status'] === 'voided') {
                    $emp_status = 'voided';
                } else {
                    $emp_status = 'processed';
                }
            }

            $employees[] = [
                'employee_no'  => $ext_no,
                'name'         => $name,
                'department'   => $emp['department'],
                'position'     => $emp['position'],
                'gross'        => round($gross, 2),
                'sss'          => round($sss['employee'], 2),
                'philhealth'   => round($philhealth['employee'], 2),
                'pagibig'      => round($pagibig['employee'], 2),
                'wht'          => round($wht, 2),
                'other'        => round($other_deductions_total_per_emp, 2),
                'deductions'   => round($emp_deductions, 2),
                'net'          => round($net, 2),
                'status'       => $emp_status
            ];

            $total_gross += $gross;
            $total_deductions += $emp_deductions;
            $total_net += $net;
        }
    }

    echo json_encode([
        'success' => true,
        'employees' => $employees,
        'summary' => [
            'total_employees' => count($employees),
            'total_gross' => round($total_gross, 2),
            'total_deductions' => round($total_deductions, 2),
            'total_net' => round($total_net, 2)
        ]
    ]);
}
