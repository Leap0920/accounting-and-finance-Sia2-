<?php
// Suppress error display, but log them
error_reporting(E_ALL);
ini_set('display_errors', 0);
ini_set('log_errors', 1);

require_once '../../config/database.php';
require_once '../../includes/session.php';
require_once __DIR__ . '/payroll-calculation.php';

// Require login to access this API
requireLogin();

header('Content-Type: application/json');

function hasGeneralLedgerRole(array $allowed_roles)
{
    $role = getUserRole();

    return $role !== null && in_array($role, $allowed_roles, true);
}

function isHRGeneralLedgerUser()
{
    return getUserRole() === 'HR Manager';
}

try {
    $action = $_GET['action'] ?? $_POST['action'] ?? '';

    if (!hasGeneralLedgerRole(['Administrator', 'Accounting Admin', 'HR Manager'])) {
        echo json_encode(['success' => false, 'message' => 'Unauthorized access']);
        exit();
    }

    if (isHRGeneralLedgerUser() && !in_array($action, ['get_journal_entry_details', 'get_payroll_journal_entries'], true)) {
        echo json_encode(['success' => false, 'message' => 'HR access is limited to payroll journal viewing']);
        exit();
    }

    switch ($action) {
        case 'get_statistics':
            echo json_encode(getStatistics());
            break;

        case 'get_chart_data':
            echo json_encode(getChartData());
            break;

        case 'get_accounts':
            echo json_encode(getAccounts());
            break;

        case 'get_recent_transactions':
        case 'get_transactions':
            echo json_encode(getRecentTransactions());
            break;

        case 'get_audit_trail':
            echo json_encode(getAuditTrail());
            break;

        case 'get_journal_types':
            echo json_encode(getJournalTypes());
            break;

        case 'get_fiscal_periods':
            echo json_encode(getFiscalPeriods());
            break;

        case 'get_journal_entry_details':
            echo json_encode(getJournalEntryDetails());
            break;

        case 'update_journal_entry':
            echo json_encode(updateJournalEntry());
            break;

        case 'post_journal_entry':
            echo json_encode(postJournalEntry());
            break;

        case 'void_journal_entry':
            echo json_encode(voidJournalEntry());
            break;

        case 'export_accounts':
            echo json_encode(exportAccounts());
            break;

        case 'export_transactions':
            echo json_encode(exportTransactions());
            break;

        case 'get_account_transactions':
            echo json_encode(getAccountTransactions());
            break;

        case 'get_account_types':
            echo json_encode(getAccountTypesList());
            break;

        case 'get_bank_transaction_details':
            echo json_encode(getBankTransactionDetails());
            break;

        case 'get_pending_applications':
            echo json_encode(getPendingApplications());
            break;

        case 'get_application_details':
            echo json_encode(getApplicationDetails());
            break;

        case 'approve_application':
            echo json_encode(approveApplication());
            break;

        case 'decline_application':
            echo json_encode(declineApplication());
            break;

        case 'get_payroll_journal_entries':
            echo json_encode(getPayrollJournalEntries());
            break;

        default:
            echo json_encode(['success' => false, 'message' => 'Invalid action']);
    }

} catch (Exception $e) {
    error_log("General Ledger API Error: " . $e->getMessage());
    error_log("Stack trace: " . $e->getTraceAsString());
    echo json_encode([
        'success' => false,
        'message' => 'An error occurred: ' . $e->getMessage(),
        'error_type' => get_class($e)
    ]);
} catch (Error $e) {
    error_log("General Ledger API Fatal Error: " . $e->getMessage());
    error_log("Stack trace: " . $e->getTraceAsString());
    echo json_encode([
        'success' => false,
        'message' => 'A fatal error occurred: ' . $e->getMessage(),
        'error_type' => get_class($e)
    ]);
}

function getStatistics()
{
    global $conn;

    try {
        // Get total active customer accounts
        $accounts_result = $conn->query("SELECT COUNT(*) as total FROM customer_accounts WHERE status = 'active'");
        $accounts_row = $accounts_result->fetch_assoc();
        $total_accounts = $accounts_row['total'] ?? 0;

        // Get total bank transactions
        $txn_result = $conn->query("SELECT COUNT(*) as total FROM bank_transactions");
        $txn_row = $txn_result->fetch_assoc();
        $total_transactions = $txn_row['total'] ?? 0;

        // Get total audit entries
        $audit_result = $conn->query("SELECT COUNT(*) as total FROM audit_logs");
        $audit_row = $audit_result->fetch_assoc();
        $total_audit = $audit_row['total'] ?? 0;

        // Get total posted payroll runs (finalized or completed)
        $pr_result = $conn->query(
            "SELECT COUNT(*) as total FROM payroll_runs WHERE status IN ('finalized','completed')"
        );
        $pr_row = $pr_result ? $pr_result->fetch_assoc() : ['total' => 0];
        $total_payroll_je = $pr_row['total'] ?? 0;

        return [
            'success' => true,
            'data' => [
                'total_accounts' => $total_accounts,
                'total_transactions' => $total_transactions,
                'total_audit' => $total_audit,
                'total_payroll_je' => $total_payroll_je
            ]
        ];

    } catch (Exception $e) {
        return [
            'success' => true,
            'data' => [
                'total_accounts' => 0,
                'total_transactions' => 0,
                'total_audit' => 0,
                'total_payroll_je' => 0
            ]
        ];
    }
}

function getChartData()
{
    global $conn;

    try {
        // 1. Account types distribution (by customer account type)
        $result = $conn->query("
            SELECT 
                account_type as type,
                COUNT(*) as count
            FROM customer_accounts
            WHERE status = 'active'
            GROUP BY account_type
        ");

        $account_types = ['labels' => [], 'values' => []];
        while ($row = $result->fetch_assoc()) {
            $account_types['labels'][] = ucfirst($row['type']);
            $account_types['values'][] = (int) $row['count'];
        }

        // 2. Transaction distribution (by Transaction Type)
        $result = $conn->query("
            SELECT 
                tt.type_name as category,
                COUNT(*) as count
            FROM bank_transactions bt
            INNER JOIN transaction_types tt ON bt.transaction_type_id = tt.transaction_type_id
            GROUP BY tt.transaction_type_id, tt.type_name
        ");

        $distribution = ['labels' => [], 'values' => []];
        while ($row = $result->fetch_assoc()) {
            $distribution['labels'][] = $row['category'];
            $distribution['values'][] = (int) $row['count'];
        }

        // 3. Category Summary (by Account Status)
        $result = $conn->query("
            SELECT 
                status,
                COUNT(*) as count
            FROM customer_accounts
            GROUP BY status
        ");
        $category_summary = ['labels' => [], 'values' => []];
        while ($row = $result->fetch_assoc()) {
            $category_summary['labels'][] = ucfirst($row['status']);
            $category_summary['values'][] = (int) $row['count'];
        }

        // 4. Growth (Monthly Transaction Volume)
        $result = $conn->query("
            SELECT 
                DATE_FORMAT(created_at, '%b') as month,
                COUNT(*) as count
            FROM bank_transactions
            GROUP BY month, DATE_FORMAT(created_at, '%Y-%m')
            ORDER BY DATE_FORMAT(created_at, '%Y-%m')
            LIMIT 12
        ");
        $growth = ['labels' => [], 'values' => []];
        while ($row = $result->fetch_assoc()) {
            $growth['labels'][] = $row['month'];
            $growth['values'][] = (int) $row['count'];
        }

        return [
            'success' => true,
            'data' => [
                'account_types' => $account_types,
                'distribution' => $distribution,
                'category_summary' => $category_summary,
                'growth' => $growth
            ]
        ];

    } catch (Exception $e) {
        return [
            'success' => true,
            'data' => [
                'account_types' => [
                    'labels' => ['Assets', 'Liabilities', 'Equity', 'Revenue', 'Expenses'],
                    'values' => [45, 32, 28, 15, 25]
                ],
                'distribution' => [
                    'labels' => ['Sales', 'Purchases', 'Payments', 'Receipts'],
                    'values' => [120, 85, 95, 110]
                ],
                'category_summary' => [
                    'labels' => ['Posted', 'Draft', 'Voided'],
                    'values' => [450, 120, 25]
                ],
                'growth' => [
                    'labels' => ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
                    'values' => [30, 45, 38, 62, 55, 75]
                ]
            ]
        ];
    }
}

function getAccounts()
{
    global $conn;

    try {
        $search = $_GET['search'] ?? '';
        $accountType = $_GET['account_type'] ?? '';
        $sort = $_GET['sort'] ?? 'newest';
        $accounts = [];

        // Base query - building the WHERE clause dynamically
        $whereConditions = ["ca.status = 'active'"];
        $params = [];
        $types = '';

        if ($search) {
            $whereConditions[] = "(CONCAT(bc.first_name, ' ', bc.last_name) LIKE ? OR ca.account_number LIKE ?)";
            $searchParam = "%$search%";
            $params[] = $searchParam;
            $params[] = $searchParam;
            $types .= 'ss';
        }

        if ($accountType) {
            $whereConditions[] = "ca.account_type = ?";
            $params[] = strtolower($accountType);
            $types .= 's';
        }

        $whereClause = implode(" AND ", $whereConditions);

        // Sorting
        $orderBy = "ca.created_at DESC";
        switch ($sort) {
            case 'oldest':
                $orderBy = "ca.created_at ASC";
                break;
            case 'name_asc':
                $orderBy = "account_name ASC";
                break;
            case 'name_desc':
                $orderBy = "account_name DESC";
                break;
            case 'acct_asc':
                $orderBy = "ca.account_number ASC";
                break;
            case 'acct_desc':
                $orderBy = "ca.account_number DESC";
                break;
        }

        // 1. Get total count for pagination (using the filtered WHERE clause)
        $countSql = "SELECT COUNT(*) as total 
                     FROM customer_accounts ca
                     JOIN bank_customers bc ON ca.customer_id = bc.customer_id
                     WHERE $whereClause";
        
        $countStmt = $conn->prepare($countSql);
        if (!empty($params)) {
            $countStmt->bind_param($types, ...$params);
        }
        $countStmt->execute();
        $totalResult = $countStmt->get_result();
        $totalCount = ($totalResult && $row = $totalResult->fetch_assoc()) ? $row['total'] : 0;

        // 2. Query actual data with sorting and pagination
        $sql = "SELECT 
                    ca.account_number,
                    CONCAT(bc.first_name, ' ', bc.last_name) as account_name,
                    ca.account_type,
                    ca.balance as available_balance,
                    ca.created_at
                FROM customer_accounts ca
                JOIN bank_customers bc ON ca.customer_id = bc.customer_id
                WHERE $whereClause
                ORDER BY $orderBy";

        // Add pagination
        $limit = (int) ($_GET['limit'] ?? 25);
        $offset = (int) ($_GET['offset'] ?? 0);
        $sql .= " LIMIT ? OFFSET ?";

        $stmt = $conn->prepare($sql);
        
        $finalParams = $params;
        $finalTypes = $types . 'ii';
        $finalParams[] = $limit;
        $finalParams[] = $offset;
        
        $stmt->bind_param($finalTypes, ...$finalParams);
        $stmt->execute();
        $result = $stmt->get_result();

        while ($row = $result->fetch_assoc()) {
            $accounts[] = [
                'account_number' => $row['account_number'],
                'account_name' => $row['account_name'],
                'account_type' => ucfirst($row['account_type']),
                'available_balance' => (float) $row['available_balance'],
                'source' => 'bank',
                'created_at' => $row['created_at']
            ];
        }

        return [
            'success' => true,
            'data' => $accounts,
            'count' => count($accounts),
            'total' => (int) $totalCount,
            'debug_sort' => $sort // Optional: for debugging
        ];

    } catch (Exception $e) {
        error_log("Error in getAccounts: " . $e->getMessage());
        return [
            'success' => false,
            'message' => 'Database error: ' . $e->getMessage(),
            'data' => []
        ];
    }
}

function getRecentTransactions()
{
    global $conn;

    try {
        $dateFrom = $_GET['date_from'] ?? '';
        $dateTo = $_GET['date_to'] ?? '';
        $type = $_GET['type'] ?? '';

        $sql = "SELECT 
                bt.transaction_id as id,
                bt.transaction_ref as journal_no,
                DATE(bt.created_at) as entry_date,
                COALESCE(bt.description, tt.type_name) as description,
                CASE WHEN bt.amount > 0 THEN bt.amount ELSE 0 END as total_debit,
                CASE WHEN bt.amount < 0 THEN ABS(bt.amount) ELSE 0 END as total_credit,
                'posted' as status,
                tt.type_name as type_name,
                'bank' as source
            FROM bank_transactions bt
            INNER JOIN transaction_types tt ON bt.transaction_type_id = tt.transaction_type_id
            WHERE 1=1";

        $params = [];
        $types = '';

        if ($dateFrom) {
            $sql .= " AND DATE(bt.created_at) >= ?";
            $params[] = $dateFrom;
            $types .= 's';
        }

        if ($dateTo) {
            $sql .= " AND DATE(bt.created_at) <= ?";
            $params[] = $dateTo;
            $types .= 's';
        }

        if ($type) {
            $sql .= " AND tt.type_name LIKE ?";
            $searchType = "%$type%";
            $params[] = $searchType;
            $types .= 's';
        }

        // Get total count
        $countSql = "SELECT COUNT(*) as total FROM ($sql) as count_query";
        $countStmt = $conn->prepare($countSql);
        if (!empty($params)) {
            $countStmt->bind_param($types, ...$params);
        }
        $countStmt->execute();
        $totalCount = $countStmt->get_result()->fetch_assoc()['total'] ?? 0;

        // Add pagination
        $limit = (int) ($_GET['limit'] ?? 25);
        $offset = (int) ($_GET['offset'] ?? 0);
        $sql .= " ORDER BY bt.created_at DESC, bt.transaction_id DESC LIMIT ? OFFSET ?";

        $stmt = $conn->prepare($sql);
        if (!empty($params)) {
            $types .= 'ii';
            $params[] = $limit;
            $params[] = $offset;
            $stmt->bind_param($types, ...$params);
        } else {
            $stmt->bind_param('ii', $limit, $offset);
        }

        $stmt->execute();
        $result = $stmt->get_result();

        $transactions = [];
        while ($row = $result->fetch_assoc()) {
            $transactions[] = [
                'id' => $row['id'],
                'journal_no' => $row['journal_no'],
                'entry_date' => date('M d, Y', strtotime($row['entry_date'])),
                'description' => $row['description'] ?? '-',
                'total_debit' => (float) $row['total_debit'],
                'total_credit' => (float) $row['total_credit'],
                'status' => $row['status'],
                'type_name' => $row['type_name'],
                'source' => $row['source']
            ];
        }

        return [
            'success' => true,
            'data' => $transactions,
            'count' => count($transactions),
            'total' => (int) $totalCount
        ];

    } catch (Exception $e) {
        return [
            'success' => false,
            'message' => 'Database error: ' . $e->getMessage(),
            'data' => []
        ];
    }
}

function getAuditTrail()
{
    global $conn;

    try {
        $dateFrom = $_GET['date_from'] ?? '';
        $dateTo = $_GET['date_to'] ?? '';

        // Query activity_logs table (the actual table name in the system)
        $sql = "
            SELECT 
                al.id,
                al.user_id,
                al.action,
                al.module as object_type,
                al.details as additional_info,
                al.ip_address,
                al.created_at,
                u.username,
                u.full_name
            FROM activity_logs al
            LEFT JOIN users u ON al.user_id = u.id
            WHERE 1=1
        ";

        $params = [];
        $types = '';

        if ($dateFrom) {
            $sql .= " AND DATE(al.created_at) >= ?";
            $params[] = $dateFrom;
            $types .= 's';
        }

        if ($dateTo) {
            $sql .= " AND DATE(al.created_at) <= ?";
            $params[] = $dateTo;
            $types .= 's';
        }

        // Get total count for pagination
        $countSql = "SELECT COUNT(*) as total FROM ($sql) as count_query";
        if (!empty($params)) {
            $countStmt = $conn->prepare($countSql);
            $countStmt->bind_param($types, ...$params);
            $countStmt->execute();
            $countResult = $countStmt->get_result();
        } else {
            $countResult = $conn->query($countSql);
        }
        $totalCount = $countResult->fetch_assoc()['total'] ?? 0;

        // Add pagination
        $limit = (int) ($_GET['limit'] ?? 25);
        $offset = (int) ($_GET['offset'] ?? 0);
        $sql .= " ORDER BY al.created_at DESC LIMIT ? OFFSET ?";

        if (!empty($params)) {
            $types .= 'ii';
            $params[] = $limit;
            $params[] = $offset;
            $stmt = $conn->prepare($sql);
            $stmt->bind_param($types, ...$params);
            $stmt->execute();
            $result = $stmt->get_result();
        } else {
            $stmt = $conn->prepare($sql);
            $stmt->bind_param('ii', $limit, $offset);
            $stmt->execute();
            $result = $stmt->get_result();
        }

        $audit_logs = [];
        while ($row = $result->fetch_assoc()) {
            $audit_logs[] = [
                'id' => $row['id'],
                'action' => ucfirst($row['action']),
                'object_type' => ucfirst($row['object_type']),
                'description' => $row['additional_info'] ?? '',
                'username' => $row['username'] ?? 'System',
                'full_name' => $row['full_name'] ?? 'System',
                'ip_address' => $row['ip_address'] ?? '127.0.0.1',
                'created_at' => date('M d, Y H:i:s', strtotime($row['created_at']))
            ];
        }

        return [
            'success' => true,
            'data' => $audit_logs,
            'count' => count($audit_logs),
            'total' => (int) $totalCount
        ];

    } catch (Exception $e) {
        // Return empty array if table doesn't exist yet
        return [
            'success' => true,
            'data' => [],
            'message' => 'No activity logs available'
        ];
    }
}

function getJournalTypes()
{
    global $conn;

    try {
        $result = $conn->query("SELECT id, code, name, description FROM journal_types WHERE 1=1 ORDER BY code");

        $types = [];
        while ($row = $result->fetch_assoc()) {
            $types[] = [
                'id' => $row['id'],
                'code' => $row['code'],
                'name' => $row['name'],
                'description' => $row['description'] ?? ''
            ];
        }

        return [
            'success' => true,
            'data' => $types
        ];

    } catch (Exception $e) {
        return [
            'success' => false,
            'message' => $e->getMessage(),
            'data' => []
        ];
    }
}

function getFiscalPeriods()
{
    global $conn;

    try {
        $result = $conn->query("
            SELECT id, period_name, start_date, end_date, status 
            FROM fiscal_periods 
            WHERE status = 'open' 
            ORDER BY start_date DESC 
            LIMIT 1
        ");

        $periods = [];
        while ($row = $result->fetch_assoc()) {
            $periods[] = [
                'id' => $row['id'],
                'period_name' => $row['period_name'],
                'start_date' => $row['start_date'],
                'end_date' => $row['end_date'],
                'status' => $row['status']
            ];
        }

        // If no open period, get the most recent one
        if (empty($periods)) {
            $result = $conn->query("
                SELECT id, period_name, start_date, end_date, status 
                FROM fiscal_periods 
                ORDER BY start_date DESC 
                LIMIT 1
            ");
            while ($row = $result->fetch_assoc()) {
                $periods[] = [
                    'id' => $row['id'],
                    'period_name' => $row['period_name'],
                    'start_date' => $row['start_date'],
                    'end_date' => $row['end_date'],
                    'status' => $row['status']
                ];
            }
        }

        return [
            'success' => true,
            'data' => $periods
        ];

    } catch (Exception $e) {
        return [
            'success' => false,
            'message' => $e->getMessage(),
            'data' => []
        ];
    }
}

function getJournalEntryDetails()
{
    global $conn;
    $currentUser = getCurrentUser();

    try {
        $journalId = $_GET['id'] ?? '';

        if (empty($journalId)) {
            return ['success' => false, 'message' => 'Journal entry ID is required'];
        }

        // Get journal entry header
        $sql = "
            SELECT 
                je.*,
                jt.code as type_code,
                jt.name as type_name,
                u.username as created_by_username,
                u.full_name as created_by_name,
                pu.username as posted_by_username,
                pu.full_name as posted_by_name,
                fp.period_name
            FROM journal_entries je
            INNER JOIN journal_types jt ON je.journal_type_id = jt.id
            INNER JOIN users u ON je.created_by = u.id
            LEFT JOIN users pu ON je.posted_by = pu.id
            LEFT JOIN fiscal_periods fp ON je.fiscal_period_id = fp.id
            WHERE je.id = ?
        ";

        $stmt = $conn->prepare($sql);
        $stmt->bind_param('i', $journalId);
        $stmt->execute();
        $result = $stmt->get_result();
        $entry = $result->fetch_assoc();

        if (!$entry) {
            return ['success' => false, 'message' => 'Journal entry not found'];
        }

        if (isHRGeneralLedgerUser() && ($entry['type_code'] ?? '') !== 'PR') {
            return ['success' => false, 'message' => 'HR access is limited to payroll journal entries'];
        }

        // Get journal lines
        $sql = "
            SELECT 
                jl.*,
                a.code as account_code,
                a.name as account_name,
                at.category as account_category
            FROM journal_lines jl
            INNER JOIN accounts a ON jl.account_id = a.id
            INNER JOIN account_types at ON a.type_id = at.id
            WHERE jl.journal_entry_id = ?
            ORDER BY jl.id
        ";

        $stmt = $conn->prepare($sql);
        $stmt->bind_param('i', $journalId);
        $stmt->execute();
        $result = $stmt->get_result();

        $lines = [];
        while ($row = $result->fetch_assoc()) {
            $lines[] = [
                'id' => $row['id'],
                'account_id' => $row['account_id'],
                'account_code' => $row['account_code'],
                'account_name' => $row['account_name'],
                'account_category' => $row['account_category'],
                'debit' => (float) $row['debit'],
                'credit' => (float) $row['credit'],
                'memo' => $row['memo'] ?? ''
            ];
        }

        $entry['lines'] = $lines;
        $can_manage_entry = !isHRGeneralLedgerUser();
        $entry['can_edit'] = $can_manage_entry && ($entry['status'] === 'draft');
        $entry['can_post'] = $can_manage_entry && ($entry['status'] === 'draft');
        $entry['can_void'] = $can_manage_entry && ($entry['status'] === 'posted');

        // Format dates for display
        $entry['created_at'] = $entry['created_at'] ?? null;
        $entry['posted_at'] = $entry['posted_at'] ?? null;

        // For Payroll (PR) entries, attach per-employee breakdown from payslips
        $payslip_breakdown = [];
        $payroll_totals = null;
        if (($entry['type_code'] ?? '') === 'PR') {
            $ps_sql = "SELECT
                ps.employee_external_no,
                CONCAT(e.first_name, ' ', COALESCE(e.middle_name, ''), ' ', e.last_name) as employee_name,
                COALESCE(d.department_name, er.department, '') as department,
                COALESCE(p.position_title, er.position, '') as position,
                COALESCE(c.salary, er.base_monthly_salary, 0) as base_salary,
                ps.gross_pay,
                ps.total_deductions,
                ps.net_pay,
                ps.payslip_json
            FROM payslips ps
            INNER JOIN payroll_runs prun ON ps.payroll_run_id = prun.id
            LEFT JOIN employee_refs er ON er.external_employee_no = ps.employee_external_no
            LEFT JOIN employee e ON e.employee_id = CAST(SUBSTRING(ps.employee_external_no, 4) AS UNSIGNED)
            LEFT JOIN department d ON e.department_id = d.department_id
            LEFT JOIN `position` p ON e.position_id = p.position_id
            LEFT JOIN contract c ON e.contract_id = c.contract_id
            WHERE prun.journal_entry_id = ?
            ORDER BY e.last_name, e.first_name, ps.employee_external_no";

            $ps_stmt = $conn->prepare($ps_sql);
            $ps_stmt->bind_param('i', $journalId);
            $ps_stmt->execute();
            $ps_result = $ps_stmt->get_result();

            $agg = ['gross' => 0, 'wht' => 0, 'sss' => 0, 'philhealth' => 0, 'pagibig' => 0, 'net' => 0];

            while ($ps_row = $ps_result->fetch_assoc()) {
                $gross    = (float) $ps_row['gross_pay'];
                $net      = (float) $ps_row['net_pay'];
                $base_sal = (float) $ps_row['base_salary'];

                // Extract per-employee deductions from payslip_json
                $emp_sss = 0; $emp_ph = 0; $emp_pi = 0; $emp_wht = 0;
                $json_data = !empty($ps_row['payslip_json']) ? json_decode($ps_row['payslip_json'], true) : null;

                if ($json_data && isset($json_data['mandatory_deductions'])) {
                    // New format: deductions stored directly
                    $md = $json_data['mandatory_deductions'];
                    $emp_sss = (float) ($md['sss_employee'] ?? 0);
                    $emp_ph  = (float) ($md['philhealth_employee'] ?? 0);
                    $emp_pi  = (float) ($md['pagibig_employee'] ?? 0);
                    $emp_wht = (float) ($md['withholding_tax'] ?? 0);
                } else {
                    // Fallback: recalculate from prorated_base_salary for older payslips
                    $prorated = 0;
                    if ($json_data && isset($json_data['salary_adjustments']['prorated_base_salary'])) {
                        $prorated = (float) $json_data['salary_adjustments']['prorated_base_salary'];
                    }
                    if ($prorated <= 0) {
                        $prorated = $base_sal;
                    }
                    if ($prorated > 0) {
                        $sss_calc = calculateSSSContribution($prorated);
                        $ph_calc  = calculatePhilHealthContribution($prorated);
                        $pi_calc  = calculatePagIBIGContribution($prorated);
                        $emp_sss  = $sss_calc['employee'];
                        $emp_ph   = $ph_calc['employee'];
                        $emp_pi   = $pi_calc['employee'];
                        $taxable  = $gross - $emp_sss - $emp_ph - $emp_pi;
                        $emp_wht  = calculateBIRWithholdingTax($taxable);
                    }
                }

                $payslip_breakdown[] = [
                    'employee_no'      => $ps_row['employee_external_no'],
                    'name'             => trim(preg_replace('/\s+/', ' ', $ps_row['employee_name'])),
                    'department'       => $ps_row['department'],
                    'position'         => $ps_row['position'],
                    'base_salary'      => $base_sal,
                    'gross_pay'        => $gross,
                    'withholding_tax'  => $emp_wht,
                    'sss'              => $emp_sss,
                    'philhealth'       => $emp_ph,
                    'pagibig'          => $emp_pi,
                    'total_deductions' => (float) $ps_row['total_deductions'],
                    'net_pay'          => $net,
                ];

                $agg['gross']      += $gross;
                $agg['wht']        += $emp_wht;
                $agg['sss']        += $emp_sss;
                $agg['philhealth'] += $emp_ph;
                $agg['pagibig']    += $emp_pi;
                $agg['net']        += $net;
            }

            if (!empty($payslip_breakdown)) {
                $payroll_totals = [
                    'employee_count'     => count($payslip_breakdown),
                    'total_gross'        => round($agg['gross'], 2),
                    'total_wht'          => round($agg['wht'], 2),
                    'total_sss'          => round($agg['sss'], 2),
                    'total_philhealth'   => round($agg['philhealth'], 2),
                    'total_pagibig'      => round($agg['pagibig'], 2),
                    'total_net'          => round($agg['net'], 2),
                ];
            }
        }
        $entry['payslip_breakdown'] = $payslip_breakdown;
        $entry['payroll_totals'] = $payroll_totals;

        return [
            'success' => true,
            'data' => $entry
        ];

    } catch (Exception $e) {
        return [
            'success' => false,
            'message' => $e->getMessage()
        ];
    }
}

function updateJournalEntry()
{
    global $conn;
    $currentUser = getCurrentUser();

    try {
        $data = json_decode(file_get_contents('php://input'), true);

        if (!$data) {
            $data = $_POST;
        }

        $journalEntryId = $data['journal_entry_id'] ?? '';

        if (empty($journalEntryId)) {
            return ['success' => false, 'message' => 'Journal entry ID is required'];
        }

        // Check if entry exists and is draft
        $checkSql = "SELECT status FROM journal_entries WHERE id = ?";
        $checkStmt = $conn->prepare($checkSql);
        $checkStmt->bind_param('i', $journalEntryId);
        $checkStmt->execute();
        $result = $checkStmt->get_result();
        $entry = $result->fetch_assoc();

        if (!$entry) {
            return ['success' => false, 'message' => 'Journal entry not found'];
        }

        if ($entry['status'] !== 'draft') {
            return ['success' => false, 'message' => 'Only draft entries can be edited'];
        }

        // Validate (same as create)
        if (empty($data['lines']) || !is_array($data['lines']) || count($data['lines']) < 2) {
            return ['success' => false, 'message' => 'At least 2 journal lines are required'];
        }

        // Convert account codes to IDs if needed
        foreach ($data['lines'] as &$line) {
            if (!is_numeric($line['account_id'])) {
                $accountCode = $line['account_id'];
                $accountSql = "SELECT id FROM accounts WHERE code = ? LIMIT 1";
                $accountStmt = $conn->prepare($accountSql);
                $accountStmt->bind_param('s', $accountCode);
                $accountStmt->execute();
                $accountResult = $accountStmt->get_result();
                if ($accountRow = $accountResult->fetch_assoc()) {
                    $line['account_id'] = $accountRow['id'];
                } else {
                    return ['success' => false, 'message' => "Account code '$accountCode' not found"];
                }
            }
        }
        unset($line);

        $totalDebit = 0;
        $totalCredit = 0;
        foreach ($data['lines'] as $line) {
            $debit = floatval($line['debit'] ?? 0);
            $credit = floatval($line['credit'] ?? 0);
            $totalDebit += $debit;
            $totalCredit += $credit;
        }

        if (abs($totalDebit - $totalCredit) > 0.01) {
            return ['success' => false, 'message' => 'Total debits must equal total credits'];
        }

        $conn->begin_transaction();

        try {
            // Update journal entry header
            $sql = "
                UPDATE journal_entries 
                SET journal_type_id = ?, entry_date = ?, description = ?, 
                    fiscal_period_id = ?, reference_no = ?, total_debit = ?, total_credit = ?
                WHERE id = ?
            ";

            $stmt = $conn->prepare($sql);
            $refNo = $data['reference_no'] ?? null;
            $stmt->bind_param(
                'issisddi',
                $data['journal_type_id'],
                $data['entry_date'],
                $data['description'],
                $data['fiscal_period_id'],
                $refNo,
                $totalDebit,
                $totalCredit,
                $journalEntryId
            );
            $stmt->execute();

            // Delete existing lines
            $deleteSql = "DELETE FROM journal_lines WHERE journal_entry_id = ?";
            $deleteStmt = $conn->prepare($deleteSql);
            $deleteStmt->bind_param('i', $journalEntryId);
            $deleteStmt->execute();

            // Insert new lines
            $lineSql = "
                INSERT INTO journal_lines 
                (journal_entry_id, account_id, debit, credit, memo)
                VALUES (?, ?, ?, ?, ?)
            ";
            $lineStmt = $conn->prepare($lineSql);

            foreach ($data['lines'] as $line) {
                $debit = floatval($line['debit'] ?? 0);
                $credit = floatval($line['credit'] ?? 0);
                $memo = $line['memo'] ?? '';

                if ($debit > 0 || $credit > 0) {
                    $lineStmt->bind_param('iidds', $journalEntryId, $line['account_id'], $debit, $credit, $memo);
                    $lineStmt->execute();
                }
            }

            // Log to audit trail
            logAuditAction($conn, $currentUser['id'], 'UPDATE', 'journal_entry', $journalEntryId, "Updated journal entry");

            $conn->commit();

            return [
                'success' => true,
                'message' => 'Journal entry updated successfully'
            ];

        } catch (Exception $e) {
            $conn->rollback();
            throw $e;
        }

    } catch (Exception $e) {
        return [
            'success' => false,
            'message' => $e->getMessage()
        ];
    }
}

function postJournalEntry()
{
    global $conn;
    $currentUser = getCurrentUser();

    try {
        $journalEntryId = $_POST['journal_entry_id'] ?? $_GET['id'] ?? '';

        if (empty($journalEntryId)) {
            return ['success' => false, 'message' => 'Journal entry ID is required'];
        }

        $conn->begin_transaction();

        try {
            // Get entry details
            $sql = "SELECT status, fiscal_period_id FROM journal_entries WHERE id = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param('i', $journalEntryId);
            $stmt->execute();
            $result = $stmt->get_result();
            $entry = $result->fetch_assoc();

            if (!$entry) {
                return ['success' => false, 'message' => 'Journal entry not found'];
            }

            if ($entry['status'] !== 'draft') {
                return ['success' => false, 'message' => 'Only draft entries can be posted'];
            }

            // Update status
            $updateSql = "
                UPDATE journal_entries 
                SET status = 'posted', posted_by = ?, posted_at = NOW()
                WHERE id = ?
            ";
            $updateStmt = $conn->prepare($updateSql);
            $updateStmt->bind_param('ii', $currentUser['id'], $journalEntryId);
            $updateStmt->execute();

            // Update account balances
            updateAccountBalances($conn, $journalEntryId, $entry['fiscal_period_id']);

            // Log to audit trail
            logAuditAction($conn, $currentUser['id'], 'POST', 'journal_entry', $journalEntryId, "Posted journal entry");

            $conn->commit();

            return [
                'success' => true,
                'message' => 'Journal entry posted successfully'
            ];

        } catch (Exception $e) {
            $conn->rollback();
            throw $e;
        }

    } catch (Exception $e) {
        return [
            'success' => false,
            'message' => $e->getMessage()
        ];
    }
}

function voidJournalEntry()
{
    global $conn;
    $currentUser = getCurrentUser();

    try {
        $journalEntryId = $_POST['journal_entry_id'] ?? $_GET['id'] ?? '';
        $reason = $_POST['reason'] ?? 'Voided by user';

        if (empty($journalEntryId)) {
            return ['success' => false, 'message' => 'Journal entry ID is required'];
        }

        $conn->begin_transaction();

        try {
            // Get entry details
            $sql = "SELECT status, fiscal_period_id FROM journal_entries WHERE id = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param('i', $journalEntryId);
            $stmt->execute();
            $result = $stmt->get_result();
            $entry = $result->fetch_assoc();

            if (!$entry) {
                return ['success' => false, 'message' => 'Journal entry not found'];
            }

            if ($entry['status'] === 'voided') {
                return ['success' => false, 'message' => 'Journal entry is already voided'];
            }

            // If posted, reverse account balances
            if ($entry['status'] === 'posted') {
                reverseAccountBalances($conn, $journalEntryId, $entry['fiscal_period_id']);
            }

            // Update journal entry status
            $updateSql = "UPDATE journal_entries SET status = 'voided' WHERE id = ?";
            $updateStmt = $conn->prepare($updateSql);
            $updateStmt->bind_param('i', $journalEntryId);
            $updateStmt->execute();

            // If this JE belongs to a payroll run, void the run too so the period can be re-processed
            $prStmt = $conn->prepare(
                "SELECT pr.id FROM payroll_runs pr
                 INNER JOIN journal_entries je ON je.id = pr.journal_entry_id
                 INNER JOIN journal_types jt ON jt.id = je.journal_type_id AND jt.code = 'PR'
                 WHERE pr.journal_entry_id = ?"
            );
            $prStmt->bind_param('i', $journalEntryId);
            $prStmt->execute();
            $prResult = $prStmt->get_result();
            if ($prRow = $prResult->fetch_assoc()) {
                $voidPR = $conn->prepare("UPDATE payroll_runs SET status = 'voided' WHERE id = ?");
                $voidPR->bind_param('i', $prRow['id']);
                $voidPR->execute();
            }

            // Log to audit trail
            logAuditAction($conn, $currentUser['id'], 'VOID', 'journal_entry', $journalEntryId, "Voided journal entry: $reason");

            $conn->commit();

            return [
                'success' => true,
                'message' => 'Journal entry voided successfully'
            ];

        } catch (Exception $e) {
            $conn->rollback();
            throw $e;
        }

    } catch (Exception $e) {
        return [
            'success' => false,
            'message' => $e->getMessage()
        ];
    }
}

// Helper functions
function generateJournalNumber($conn)
{
    $prefix = 'JE';
    $date = date('Ymd');
    $random = strtoupper(substr(md5(uniqid(rand(), true)), 0, 4));
    $journalNo = "$prefix-$date-$random";

    // Check if exists, regenerate if needed
    $checkSql = "SELECT id FROM journal_entries WHERE journal_no = ?";
    $checkStmt = $conn->prepare($checkSql);
    $checkStmt->bind_param('s', $journalNo);
    $checkStmt->execute();
    $result = $checkStmt->get_result();

    if ($result->num_rows > 0) {
        // Regenerate with different random
        $random = strtoupper(substr(md5(uniqid(rand(), true)), 0, 4));
        $journalNo = "$prefix-$date-$random";
    }

    return $journalNo;
}

function updateAccountBalances($conn, $journalEntryId, $fiscalPeriodId)
{
    // Get all journal lines for this entry
    $sql = "
        SELECT account_id, debit, credit 
        FROM journal_lines 
        WHERE journal_entry_id = ?
    ";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param('i', $journalEntryId);
    $stmt->execute();
    $result = $stmt->get_result();

    while ($row = $result->fetch_assoc()) {
        $accountId = $row['account_id'];
        $debit = floatval($row['debit']);
        $credit = floatval($row['credit']);

        // Check if balance record exists
        $checkSql = "SELECT id FROM account_balances WHERE account_id = ? AND fiscal_period_id = ?";
        $checkStmt = $conn->prepare($checkSql);
        $checkStmt->bind_param('ii', $accountId, $fiscalPeriodId);
        $checkStmt->execute();
        $checkResult = $checkStmt->get_result();

        if ($checkResult->num_rows > 0) {
            // Get current balance to calculate new closing balance
            $currentSql = "SELECT opening_balance, debit_movements, credit_movements FROM account_balances WHERE account_id = ? AND fiscal_period_id = ?";
            $currentStmt = $conn->prepare($currentSql);
            $currentStmt->bind_param('ii', $accountId, $fiscalPeriodId);
            $currentStmt->execute();
            $currentResult = $currentStmt->get_result();
            $currentRow = $currentResult->fetch_assoc();

            $newDebitMovements = floatval($currentRow['debit_movements']) + $debit;
            $newCreditMovements = floatval($currentRow['credit_movements']) + $credit;
            $newClosingBalance = floatval($currentRow['opening_balance']) + $newDebitMovements - $newCreditMovements;

            // Update existing balance
            $updateSql = "
                UPDATE account_balances 
                SET debit_movements = ?,
                    credit_movements = ?,
                    closing_balance = ?,
                    last_updated = NOW()
                WHERE account_id = ? AND fiscal_period_id = ?
            ";
            $updateStmt = $conn->prepare($updateSql);
            $updateStmt->bind_param('dddii', $newDebitMovements, $newCreditMovements, $newClosingBalance, $accountId, $fiscalPeriodId);
            $updateStmt->execute();
        } else {
            // Create new balance record
            $insertSql = "
                INSERT INTO account_balances 
                (account_id, fiscal_period_id, opening_balance, debit_movements, credit_movements, closing_balance, last_updated)
                VALUES (?, ?, 0, ?, ?, ?, NOW())
            ";
            $closingBalance = $debit - $credit;
            $insertStmt = $conn->prepare($insertSql);
            $insertStmt->bind_param('iiddd', $accountId, $fiscalPeriodId, $debit, $credit, $closingBalance);
            $insertStmt->execute();
        }
    }
}

function reverseAccountBalances($conn, $journalEntryId, $fiscalPeriodId)
{
    // Get all journal lines and reverse them
    $sql = "
        SELECT account_id, debit, credit 
        FROM journal_lines 
        WHERE journal_entry_id = ?
    ";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param('i', $journalEntryId);
    $stmt->execute();
    $result = $stmt->get_result();

    while ($row = $result->fetch_assoc()) {
        $accountId = $row['account_id'];
        $debit = floatval($row['credit']); // Reverse: debit becomes credit
        $credit = floatval($row['debit']); // Reverse: credit becomes debit

        // Get current balance to calculate new closing balance after reversal
        $currentSql = "SELECT opening_balance, debit_movements, credit_movements FROM account_balances WHERE account_id = ? AND fiscal_period_id = ?";
        $currentStmt = $conn->prepare($currentSql);
        $currentStmt->bind_param('ii', $accountId, $fiscalPeriodId);
        $currentStmt->execute();
        $currentResult = $currentStmt->get_result();

        if ($currentRow = $currentResult->fetch_assoc()) {
            $newDebitMovements = floatval($currentRow['debit_movements']) - $debit;
            $newCreditMovements = floatval($currentRow['credit_movements']) - $credit;
            $newClosingBalance = floatval($currentRow['opening_balance']) + $newDebitMovements - $newCreditMovements;

            // Update balance (subtract instead of add)
            $updateSql = "
                UPDATE account_balances 
                SET debit_movements = ?,
                    credit_movements = ?,
                    closing_balance = ?,
                    last_updated = NOW()
                WHERE account_id = ? AND fiscal_period_id = ?
            ";
            $updateStmt = $conn->prepare($updateSql);
            $updateStmt->bind_param('dddii', $newDebitMovements, $newCreditMovements, $newClosingBalance, $accountId, $fiscalPeriodId);
            $updateStmt->execute();
        }
    }
}

function logAuditAction($conn, $userId, $action, $objectType, $objectId, $description)
{
    try {
        $ipAddress = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
        $additionalInfo = json_encode(['description' => $description]);

        $sql = "
            INSERT INTO audit_logs 
            (user_id, action, object_type, object_id, additional_info, ip_address, created_at)
            VALUES (?, ?, ?, ?, ?, ?, NOW())
        ";

        $objectIdStr = (string) $objectId;
        $stmt = $conn->prepare($sql);
        $stmt->bind_param('isssss', $userId, $action, $objectType, $objectIdStr, $additionalInfo, $ipAddress);
        $stmt->execute();
    } catch (Exception $e) {
        // Silently fail audit logging - don't break the main operation
        error_log("Audit log error: " . $e->getMessage());
    }
}

function exportAccounts()
{
    global $conn;

    try {
        $search = $_GET['search'] ?? '';

        $sql = "
            SELECT 
                a.code,
                a.name,
                at.category as account_type,
                COALESCE(ab.closing_balance, 0) as balance,
                a.is_active
            FROM accounts a
            INNER JOIN account_types at ON a.type_id = at.id
            LEFT JOIN account_balances ab ON a.id = ab.account_id 
                AND ab.fiscal_period_id = (SELECT id FROM fiscal_periods WHERE status = 'open' ORDER BY start_date DESC LIMIT 1)
            WHERE a.is_active = 1
        ";

        $params = [];
        $types = '';

        if ($search) {
            $sql .= " AND (a.name LIKE ? OR a.code LIKE ?)";
            $searchParam = "%$search%";
            $params[] = $searchParam;
            $params[] = $searchParam;
            $types .= 'ss';
        }

        $sql .= " ORDER BY a.code";

        $stmt = $conn->prepare($sql);
        if (!empty($params)) {
            $stmt->bind_param($types, ...$params);
        }
        $stmt->execute();
        $result = $stmt->get_result();

        $accounts = [];
        while ($row = $result->fetch_assoc()) {
            $accounts[] = [
                'code' => $row['code'],
                'name' => $row['name'],
                'type' => ucfirst($row['account_type']),
                'balance' => (float) $row['balance'],
                'status' => $row['is_active'] ? 'Active' : 'Inactive'
            ];
        }

        return [
            'success' => true,
            'data' => $accounts,
            'filename' => 'accounts_export_' . date('Y-m-d') . '.csv'
        ];

    } catch (Exception $e) {
        return [
            'success' => false,
            'message' => $e->getMessage()
        ];
    }
}

function exportTransactions()
{
    global $conn;

    try {
        $dateFrom = $_GET['date_from'] ?? '';
        $dateTo = $_GET['date_to'] ?? '';
        $type = $_GET['type'] ?? '';

        $sql = "
            SELECT 
                je.journal_no,
                je.entry_date,
                jt.name as type_name,
                je.description,
                je.reference_no,
                je.total_debit,
                je.total_credit,
                je.status,
                u.full_name as created_by
            FROM journal_entries je
            INNER JOIN journal_types jt ON je.journal_type_id = jt.id
            INNER JOIN users u ON je.created_by = u.id
            WHERE je.status = 'posted'
        ";

        $params = [];
        $types = '';

        if ($dateFrom) {
            $sql .= " AND je.entry_date >= ?";
            $params[] = $dateFrom;
            $types .= 's';
        }

        if ($dateTo) {
            $sql .= " AND je.entry_date <= ?";
            $params[] = $dateTo;
            $types .= 's';
        }

        if ($type) {
            $sql .= " AND jt.code = ?";
            $params[] = $type;
            $types .= 's';
        }

        $sql .= " ORDER BY je.entry_date DESC, je.journal_no DESC";

        $stmt = $conn->prepare($sql);
        if (!empty($params)) {
            $stmt->bind_param($types, ...$params);
        }
        $stmt->execute();
        $result = $stmt->get_result();

        $transactions = [];
        while ($row = $result->fetch_assoc()) {
            $transactions[] = [
                'journal_no' => $row['journal_no'],
                'entry_date' => $row['entry_date'],
                'type' => $row['type_name'],
                'description' => $row['description'] ?? '',
                'reference_no' => $row['reference_no'] ?? '',
                'debit' => (float) $row['total_debit'],
                'credit' => (float) $row['total_credit'],
                'status' => $row['status'],
                'created_by' => $row['created_by']
            ];
        }

        return [
            'success' => true,
            'data' => $transactions,
            'filename' => 'transactions_export_' . date('Y-m-d') . '.csv'
        ];

    } catch (Exception $e) {
        return [
            'success' => false,
            'message' => $e->getMessage()
        ];
    }
}

function getAccountTransactions()
{
    global $conn;

    try {
        $accountNumber = $_GET['account_code'] ?? '';
        $source = $_GET['source'] ?? 'bank';

        if (empty($accountNumber)) {
            return [
                'success' => false,
                'message' => 'Account number is required'
            ];
        }

        if ($source === 'gl') {
            // Get GL account info with aggregated balance from journal_lines
            $sql = "SELECT 
                        a.code as account_number,
                        a.name as account_name,
                        at.name as account_type,
                        COALESCE((SELECT SUM(jl.debit) - SUM(jl.credit) 
                                  FROM journal_lines jl 
                                  JOIN journal_entries je ON jl.journal_entry_id = je.id 
                                  WHERE jl.account_id = a.id AND je.status = 'posted'), 0) as available_balance
                    FROM accounts a
                    INNER JOIN account_types at ON a.type_id = at.id
                    WHERE a.code = ?
                    LIMIT 1";

            $stmt = $conn->prepare($sql);
            if (!$stmt)
                throw new Exception("Prepare failed: " . $conn->error);
            $stmt->bind_param('s', $accountNumber);
            $stmt->execute();
            $result = $stmt->get_result();
            $accountInfo = $result->fetch_assoc();

            if (!$accountInfo) {
                return ['success' => false, 'message' => 'GL Account not found'];
            }

            // Get journal entries for this account
            $sql = "SELECT 
                        je.entry_date as date,
                        je.journal_no as reference,
                        je.description,
                        jl.debit,
                        jl.credit
                    FROM journal_lines jl
                    INNER JOIN journal_entries je ON jl.journal_entry_id = je.id
                    INNER JOIN accounts a ON jl.account_id = a.id
                    WHERE a.code = ? AND je.status = 'posted'
                    ORDER BY je.entry_date DESC, je.id DESC
                    LIMIT 100";

            $stmt = $conn->prepare($sql);
            if (!$stmt)
                throw new Exception("Prepare failed: " . $conn->error);
            $stmt->bind_param('s', $accountNumber);
            $stmt->execute();
            $result = $stmt->get_result();

            $transactions = [];
            while ($row = $result->fetch_assoc()) {
                $transactions[] = [
                    'date' => $row['date'],
                    'reference' => $row['reference'],
                    'description' => $row['description'],
                    'debit' => (float) $row['debit'],
                    'credit' => (float) $row['credit']
                ];
            }

            return [
                'success' => true,
                'data' => [
                    'account' => [
                        'account_number' => $accountInfo['account_number'],
                        'account_name' => trim($accountInfo['account_name']),
                        'account_type' => $accountInfo['account_type'],
                        'available_balance' => (float) $accountInfo['available_balance'],
                        'source' => 'gl'
                    ],
                    'transactions' => $transactions
                ]
            ];
        }

        // Default BANK system logic
        // Get bank customer account info using ONLY bank-system tables
        $sql = "SELECT 
                    ca.account_number,
                    CONCAT(COALESCE(bc.first_name, ''), ' ', COALESCE(bc.last_name, '')) as account_name,
                    ca.account_type,
                    ca.balance as available_balance
                FROM customer_accounts ca
                INNER JOIN bank_customers bc ON ca.customer_id = bc.customer_id
                WHERE ca.account_number = ?
                LIMIT 1";

        $stmt = $conn->prepare($sql);
        if (!$stmt)
            throw new Exception("Prepare failed: " . $conn->error);
        $stmt->bind_param('s', $accountNumber);
        $stmt->execute();
        $result = $stmt->get_result();
        $accountInfo = $result->fetch_assoc();

        if (!$accountInfo) {
            return [
                'success' => false,
                'message' => 'Account not found'
            ];
        }

        // Get bank transactions for this account
        $sql = "SELECT 
                    DATE(bt.created_at) as date,
                    bt.transaction_ref as reference,
                    COALESCE(bt.description, tt.type_name) as description,
                    CASE WHEN bt.amount > 0 THEN bt.amount ELSE 0 END as debit,
                    CASE WHEN bt.amount < 0 THEN ABS(bt.amount) ELSE 0 END as credit
                FROM bank_transactions bt
                INNER JOIN transaction_types tt ON bt.transaction_type_id = tt.transaction_type_id
                INNER JOIN customer_accounts ca ON bt.account_id = ca.account_id
                WHERE ca.account_number = ?
                ORDER BY bt.created_at DESC
                LIMIT 100";

        $stmt = $conn->prepare($sql);
        if (!$stmt)
            throw new Exception("Prepare failed: " . $conn->error);
        $stmt->bind_param('s', $accountNumber);
        $stmt->execute();
        $result = $stmt->get_result();

        $transactions = [];
        while ($row = $result->fetch_assoc()) {
            $transactions[] = [
                'date' => $row['date'],
                'reference' => $row['reference'],
                'description' => $row['description'],
                'debit' => (float) $row['debit'],
                'credit' => (float) $row['credit']
            ];
        }

        return [
            'success' => true,
            'data' => [
                'account' => [
                    'account_number' => $accountInfo['account_number'],
                    'account_name' => trim($accountInfo['account_name']),
                    'account_type' => $accountInfo['account_type'],
                    'available_balance' => (float) $accountInfo['available_balance'],
                    'source' => 'bank'
                ],
                'transactions' => $transactions
            ]
        ];

    } catch (Exception $e) {
        return [
            'success' => false,
            'message' => $e->getMessage()
        ];
    }
}

function getAccountTypesList()
{
    global $conn;

    try {
        $sql = "SELECT DISTINCT type_name 
                FROM bank_account_types 
                WHERE type_name != 'USD Account'
                ORDER BY type_name";

        $result = $conn->query($sql);
        $types = [];

        if ($result) {
            while ($row = $result->fetch_assoc()) {
                $types[] = $row['type_name'];
            }
        }

        // Filter out USD Account from the results as well (in case query didn't work)
        $types = array_filter($types, function ($type) {
            return strtolower($type) !== 'usd account';
        });

        return [
            'success' => true,
            'data' => array_values($types) // Re-index array
        ];

    } catch (Exception $e) {
        // Return default types if query fails (excluding USD Account)
        return [
            'success' => true,
            'data' => ['Savings', 'Checking', 'Fixed Deposit', 'Loan']
        ];
    }
}

function getBankTransactionDetails()
{
    global $conn;

    try {
        $transactionId = $_GET['id'] ?? '';

        if (empty($transactionId)) {
            return ['success' => false, 'message' => 'Transaction ID is required'];
        }

        $sql = "SELECT 
                    bt.transaction_id,
                    bt.transaction_ref,
                    bt.account_id,
                    bt.transaction_type_id,
                    bt.amount,
                    bt.description,
                    bt.created_at,
                    ca.account_number,
                    tt.type_name as transaction_type
                FROM bank_transactions bt
                INNER JOIN customer_accounts ca ON bt.account_id = ca.account_id
                INNER JOIN transaction_types tt ON bt.transaction_type_id = tt.transaction_type_id
                WHERE bt.transaction_id = ?
                LIMIT 1";

        $stmt = $conn->prepare($sql);
        $stmt->bind_param('i', $transactionId);
        $stmt->execute();
        $result = $stmt->get_result();
        $transaction = $result->fetch_assoc();

        if (!$transaction) {
            return ['success' => false, 'message' => 'Bank transaction not found'];
        }

        return [
            'success' => true,
            'data' => [
                'transaction_ref' => $transaction['transaction_ref'],
                'account_number' => $transaction['account_number'],
                'transaction_type' => $transaction['transaction_type'],
                'amount' => (float) $transaction['amount'],
                'description' => $transaction['description'] ?? 'Bank Transaction',
                'created_at' => $transaction['created_at']
            ]
        ];

    } catch (Exception $e) {
        return [
            'success' => false,
            'message' => $e->getMessage()
        ];
    }
}

// ========================================
// CARD APPLICATION FUNCTIONS
// ========================================

function getPendingApplications()
{
    global $conn;

    try {
        $statusFilter = $_GET['status_filter'] ?? 'all';
        $search = $_GET['search'] ?? '';
        $appNumber = $_GET['app_number'] ?? '';
        $dateFrom = $_GET['date_from'] ?? '';
        $dateTo = $_GET['date_to'] ?? '';
        $sort = $_GET['sort'] ?? 'newest';
        $limit = (int) ($_GET['limit'] ?? 25);
        $offset = (int) ($_GET['offset'] ?? 0);

        $whereClause = "WHERE 1=1";
        $params = [];
        $types = '';

        if ($statusFilter !== 'all') {
            $whereClause .= " AND status = ?";
            $mappedStatus = ($statusFilter === 'rejected' ? 'Rejected' : ucfirst($statusFilter));
            $params[] = $mappedStatus;
            $types .= 's';
        }

        if ($appNumber) {
            $searchPattern = "%$appNumber%";
            // Searches Name, Raw ID, and Formatted ID (e.g. APP-00001)
            $whereClause .= " AND (full_name LIKE ? OR id LIKE ? OR CONCAT('APP-', LPAD(id, 5, '0')) LIKE ?)";
            $params[] = $searchPattern;
            $params[] = $searchPattern;
            $params[] = $searchPattern;
            $types .= 'sss';
        }

        if ($dateFrom) {
            $whereClause .= " AND DATE(created_at) >= ?";
            $params[] = $dateFrom;
            $types .= 's';
        }

        if ($dateTo) {
            $whereClause .= " AND DATE(created_at) <= ?";
            $params[] = $dateTo;
            $types .= 's';
        }

        // Sorting
        $orderBy = "created_at DESC";
        switch ($sort) {
            case 'oldest':
                $orderBy = "created_at ASC";
                break;
            case 'name_asc':
                $orderBy = "full_name ASC";
                break;
            case 'name_desc':
                $orderBy = "full_name DESC";
                break;
            case 'app_asc':
                $orderBy = "id ASC";
                break;
            case 'app_desc':
                $orderBy = "id DESC";
                break;
        }

        $sql = "SELECT 
            id as application_id,
            id as application_number,
            full_name as applicant_name,
            email,
            contact_number as phone_number,
            status as application_status,
            created_at as submitted_at,
            loan_type as selected_cards,
            loan_amount as annual_income
        FROM loan_applications 
        $whereClause
        ORDER BY $orderBy
        LIMIT ? OFFSET ?";

        // Get total count
        $countSql = "SELECT COUNT(*) as total FROM loan_applications $whereClause";
        $countStmt = $conn->prepare($countSql);
        if (!empty($params)) {
            $countStmt->bind_param($types, ...$params);
        }
        $countStmt->execute();
        $totalCount = $countStmt->get_result()->fetch_assoc()['total'] ?? 0;

        // Execute main query
        $finalParams = $params;
        $finalTypes = $types . 'ii';
        $finalParams[] = $limit;
        $finalParams[] = $offset;

        $stmt = $conn->prepare($sql);
        $stmt->bind_param($finalTypes, ...$finalParams);
        $stmt->execute();
        $result = $stmt->get_result();

        $applications = [];
        while ($row = $result->fetch_assoc()) {
            $applications[] = [
                'application_id' => (int) $row['application_id'],
                'application_number' => 'APP-' . str_pad($row['application_id'], 5, '0', STR_PAD_LEFT),
                'applicant_name' => $row['applicant_name'],
                'requested_cards' => $row['selected_cards'],
                'submission_date' => date('M d, Y', strtotime($row['submitted_at'])),
                'status' => strtolower($row['application_status']),
                'account_type' => 'Loan Application',
                'annual_income' => (float) $row['annual_income']
            ];
        }

        return [
            'success' => true,
            'data' => $applications,
            'count' => count($applications),
            'total' => (int) $totalCount
        ];

    } catch (Exception $e) {
        return [
            'success' => false,
            'message' => 'Database error: ' . $e->getMessage(),
            'data' => []
        ];
    }
}

function getApplicationDetails()
{
    global $conn;

    try {
        $applicationId = (int) ($_GET['application_id'] ?? 0);

        if (!$applicationId) {
            return ['success' => false, 'message' => 'Application ID is required'];
        }

        $sql = "SELECT * FROM loan_applications WHERE id = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param('i', $applicationId);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows === 0) {
            return ['success' => false, 'message' => 'Application not found'];
        }

        $row = $result->fetch_assoc();
        $nameParts = explode(' ', $row['full_name']);
        $firstName = $nameParts[0] ?? '';
        $lastName = count($nameParts) > 1 ? implode(' ', array_slice($nameParts, 1)) : '';

        return [
            'success' => true,
            'data' => [
                'application_id' => (int) $row['id'],
                'application_number' => 'APP-' . str_pad($row['id'], 5, '0', STR_PAD_LEFT),
                'application_status' => strtolower($row['status']),
                'submitted_at' => $row['created_at'],
                'applicant_name' => $row['full_name'],
                'first_name' => $firstName,
                'last_name' => $lastName,
                'email' => $row['email'],
                'phone_number' => $row['contact_number'],
                'employment_status' => $row['job'] ?? 'Not Specified',
                'employer_name' => 'N/A',
                'job_title' => $row['job'] ?? 'N/A',
                'annual_income' => (float) ($row['monthly_salary'] ?? 0) * 12,
                'account_type_display' => $row['loan_type'],
                'selected_cards' => [['type' => 'loan', 'name' => $row['loan_type']]],
                'loan_amount' => (float) $row['loan_amount'],
                'loan_terms' => $row['loan_terms'],
                'remarks' => $row['remarks'],
                'date_of_birth' => 'N/A',
                'street_address' => 'N/A',
                'barangay' => 'N/A',
                'city' => 'N/A',
                'state' => 'N/A',
                'zip_code' => 'N/A',
                'ssn' => 'N/A',
                'id_type' => 'Valid ID',
                'id_number' => $row['valid_id_number'] ?? 'N/A',
                'additional_services' => [],
                'terms_accepted' => true,
                'privacy_acknowledged' => true,
                'marketing_consent' => false
            ]
        ];

    } catch (Exception $e) {
        return ['success' => false, 'message' => 'Database error: ' . $e->getMessage()];
    }
}

function approveApplication()
{
    global $conn;
    try {
        $applicationId = (int) ($_POST['application_id'] ?? 0);
        $currentUser = getCurrentUser();

        if (!$applicationId)
            return ['success' => false, 'message' => 'Application ID is required'];

        $sql = "UPDATE loan_applications SET status = 'Approved', approved_at = NOW(), approved_by = ? WHERE id = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param('si', $currentUser['full_name'], $applicationId);

        if ($stmt->execute()) {
            return ['success' => true, 'message' => 'Application approved successfully'];
        }
        return ['success' => false, 'message' => 'Failed to approve application'];
    } catch (Exception $e) {
        return ['success' => false, 'message' => $e->getMessage()];
    }
}

function declineApplication()
{
    global $conn;
    try {
        $applicationId = (int) ($_POST['application_id'] ?? 0);
        $reason = $_POST['reason'] ?? 'No reason provided';
        $currentUser = getCurrentUser();

        if (!$applicationId)
            return ['success' => false, 'message' => 'Application ID is required'];

        $sql = "UPDATE loan_applications SET status = 'Rejected', rejected_at = NOW(), rejected_by = ?, rejection_remarks = ? WHERE id = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param('ssi', $currentUser['full_name'], $reason, $applicationId);

        if ($stmt->execute()) {
            return ['success' => true, 'message' => 'Application declined'];
        }
        return ['success' => false, 'message' => 'Failed to decline application'];
    } catch (Exception $e) {
        return ['success' => false, 'message' => $e->getMessage()];
    }
}

// ========================================
// PAYROLL JOURNAL ENTRIES
// ========================================

function getPayrollJournalEntries()
{
    global $conn;

    try {
        $dateFrom = $_GET['date_from'] ?? '';
        $dateTo   = $_GET['date_to'] ?? '';
        $status   = $_GET['status'] ?? '';

        $sql = "SELECT 
                    pr.id,
                    COALESCE(je.journal_no, CONCAT('PR-', LPAD(pr.id, 4, '0'))) AS journal_no,
                    COALESCE(DATE(je.entry_date), DATE(pr.run_at)) AS entry_date,
                    COALESCE(je.description, CONCAT('Payroll Run - ', DATE_FORMAT(pp.period_start, '%M %Y'))) AS description,
                    pr.total_gross AS total_debit,
                    pr.total_gross AS total_credit,
                    CASE 
                        WHEN je.status IS NOT NULL THEN je.status
                        WHEN pr.status = 'finalized' THEN 'posted'
                        WHEN pr.status = 'completed' THEN 'posted'
                        ELSE pr.status 
                    END AS status,
                    pr.run_at AS created_at,
                    COALESCE(je.created_at, pr.run_at) AS posted_at,
                    'Payroll' AS type_name,
                    'PR' AS type_code,
                    CONCAT(DATE_FORMAT(pp.period_start, '%Y-%m'), ' to ', DATE_FORMAT(pp.period_end, '%Y-%m')) AS period_name,
                    pr.id AS payroll_run_id,
                    pr.total_gross,
                    pr.total_deductions,
                    pr.total_net,
                    pr.status AS payroll_status,
                    pp.period_start,
                    pp.period_end,
                    u.username AS created_by_name,
                    (SELECT COUNT(*) FROM payslips ps WHERE ps.payroll_run_id = pr.id) AS employee_count
                FROM payroll_runs pr
                INNER JOIN payroll_periods pp ON pr.payroll_period_id = pp.id
                LEFT  JOIN journal_entries je ON je.id = pr.journal_entry_id
                LEFT  JOIN users u ON pr.run_by_user_id = u.id
                WHERE 1=1";

        $params = [];
        $types  = '';

        if ($dateFrom) {
            $sql .= " AND DATE(pr.run_at) >= ?";
            $params[] = $dateFrom;
            $types .= 's';
        }
        if ($dateTo) {
            $sql .= " AND DATE(pr.run_at) <= ?";
            $params[] = $dateTo;
            $types .= 's';
        }
        if ($status) {
            // Map GL status filters to payroll_runs + journal_entries statuses
            if ($status === 'posted') {
                $sql .= " AND (pr.status IN ('finalized','completed') OR je.status = 'posted')";
            } elseif ($status === 'voided') {
                $sql .= " AND (je.status = 'voided')";
            } else {
                $sql .= " AND pr.status = ?";
                $params[] = $status;
                $types .= 's';
            }
        }

        $sql .= " ORDER BY pr.run_at DESC, pr.id DESC";

        $stmt = $conn->prepare($sql);
        if (!empty($params)) {
            $stmt->bind_param($types, ...$params);
        }
        $stmt->execute();
        $result = $stmt->get_result();

        $entries = [];
        while ($row = $result->fetch_assoc()) {
            // Build period label
            $period_label = '';
            if ($row['period_start'] && $row['period_end']) {
                $period_label = date('M d', strtotime($row['period_start'])) . ' – ' . date('M d, Y', strtotime($row['period_end']));
            }

            $entries[] = [
                'id'               => $row['id'],
                'journal_no'       => $row['journal_no'],
                'entry_date'       => date('M d, Y', strtotime($row['entry_date'])),
                'entry_date_raw'   => $row['entry_date'],
                'description'      => $row['description'] ?? '-',
                'total_debit'      => (float) $row['total_debit'],
                'total_credit'     => (float) $row['total_credit'],
                'status'           => $row['status'],
                'type_name'        => $row['type_name'],
                'period_label'     => $period_label,
                'period_name'      => $row['period_name'] ?? '-',
                'payroll_run_id'   => $row['payroll_run_id'],
                'total_gross'      => (float) ($row['total_gross'] ?? 0),
                'total_deductions' => (float) ($row['total_deductions'] ?? 0),
                'total_net'        => (float) ($row['total_net'] ?? 0),
                'employee_count'   => (int) ($row['employee_count'] ?? 0),
                'created_by'       => $row['created_by_name'] ?? 'System',
                'posted_at'        => $row['posted_at'] ? date('M d, Y H:i', strtotime($row['posted_at'])) : null,
            ];
        }

        // Summary totals
        $summary_gross = array_sum(array_column($entries, 'total_gross'));
        $summary_deductions = array_sum(array_column($entries, 'total_deductions'));
        $summary_net = array_sum(array_column($entries, 'total_net'));

        return [
            'success' => true,
            'data'    => $entries,
            'count'   => count($entries),
            'summary' => [
                'total_gross'      => $summary_gross,
                'total_deductions' => $summary_deductions,
                'total_net'        => $summary_net
            ]
        ];

    } catch (Exception $e) {
        return [
            'success' => false,
            'message' => 'Database error: ' . $e->getMessage(),
            'data'    => []
        ];
    }
}
?>