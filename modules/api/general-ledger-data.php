<?php
// Suppress error display, but log them
error_reporting(E_ALL);
ini_set('display_errors', 0);
ini_set('log_errors', 1);

require_once '../../config/database.php';
require_once '../../includes/session.php';

// Require login to access this API
requireLogin();

header('Content-Type: application/json');

try {
    $action = $_GET['action'] ?? $_POST['action'] ?? '';

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

        case 'get_trial_balance':
            echo json_encode(getTrialBalance());
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
        // Get total GL accounts
        $accounts_result = $conn->query("SELECT COUNT(*) as total FROM accounts WHERE is_active = 1");
        $accounts_row = $accounts_result->fetch_assoc();
        $total_accounts = $accounts_row['total'] ?? 0;

        // Get total posted Transactions
        $je_result = $conn->query("SELECT COUNT(*) as total FROM journal_entries WHERE status = 'posted'");
        $je_row = $je_result->fetch_assoc();
        $total_transactions = $je_row['total'] ?? 0;

        // Get total audit entries
        $audit_result = $conn->query("SELECT COUNT(*) as total FROM audit_logs");
        $audit_row = $audit_result->fetch_assoc();
        $total_audit = $audit_row['total'] ?? 0;

        return [
            'success' => true,
            'data' => [
                'total_accounts' => $total_accounts,
                'total_transactions' => $total_transactions,
                'total_audit' => $total_audit
            ]
        ];

    } catch (Exception $e) {
        return [
            'success' => true,
            'data' => [
                'total_accounts' => 0,
                'total_transactions' => 0,
                'total_audit' => 0
            ]
        ];
    }
}

function getChartData()
{
    global $conn;

    try {
        // Account types distribution - join with account_types table
        $result = $conn->query("
            SELECT 
                at.category as type,
                COUNT(*) as count
            FROM accounts a
            INNER JOIN account_types at ON a.type_id = at.id
            WHERE a.is_active = 1 
            GROUP BY at.category
        ");

        $account_types = ['labels' => [], 'values' => []];
        while ($row = $result->fetch_assoc()) {
            $account_types['labels'][] = ucfirst($row['type']);
            $account_types['values'][] = (int) $row['count'];
        }

        // Transaction summary by journal type
        $result = $conn->query("
            SELECT 
                jt.name as category,
                COUNT(*) as count
            FROM journal_entries je
            INNER JOIN journal_types jt ON je.journal_type_id = jt.id
            WHERE je.status = 'posted'
            GROUP BY jt.id, jt.name
        ");

        $transaction_summary = ['labels' => [], 'values' => []];
        while ($row = $result->fetch_assoc()) {
            $transaction_summary['labels'][] = $row['category'];
            $transaction_summary['values'][] = (int) $row['count'];
        }

        return [
            'success' => true,
            'data' => [
                'account_types' => $account_types,
                'transaction_summary' => $transaction_summary
            ]
        ];

    } catch (Exception $e) {
        // Return fallback data if database query fails
        return [
            'success' => true,
            'data' => [
                'account_types' => [
                    'labels' => ['Assets', 'Liabilities', 'Equity', 'Revenue', 'Expenses'],
                    'values' => [45, 32, 28, 15, 25]
                ],
                'transaction_summary' => [
                    'labels' => ['Sales', 'Purchases', 'Payments', 'Receipts'],
                    'values' => [120, 85, 95, 110]
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
        $accounts = [];

        // Use the v_account_balances view which provides accurate GL account balances
        $sql = "SELECT 
            code as account_number,
            name as account_name,
            account_type,
            closing_balance as available_balance
        FROM v_account_balances 
        WHERE 1=1";

        $params = [];
        $types = '';

        if ($search) {
            $sql .= " AND (name LIKE ? OR code LIKE ?)";
            $searchParam = "%$search%";
            $params[] = $searchParam;
            $params[] = $searchParam;
            $types .= 'ss';
        }

        if ($accountType) {
            $sql .= " AND account_type = ?";
            $params[] = strtolower($accountType);
            $types .= 's';
        }

        $sql .= " ORDER BY code";

        // Get total count for pagination
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
        $sql .= " LIMIT ? OFFSET ?";

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

        while ($row = $result->fetch_assoc()) {
            $accounts[] = [
                'account_number' => $row['account_number'],
                'account_name' => $row['account_name'],
                'account_type' => ucfirst($row['account_type']),
                'available_balance' => (float) $row['available_balance'],
                'source' => 'gl'
            ];
        }

        return [
            'success' => true,
            'data' => $accounts,
            'count' => count($accounts),
            'total' => (int) $totalCount
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
                je.id,
                je.journal_no,
                je.entry_date,
                je.description,
                je.total_debit,
                je.total_credit,
                je.status,
                jt.name as type_name,
                'journal' as source
            FROM journal_entries je
            INNER JOIN journal_types jt ON je.journal_type_id = jt.id
            WHERE 1=1";

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
            $sql .= " AND jt.name LIKE ?";
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
        $sql .= " ORDER BY je.entry_date DESC, je.id DESC LIMIT ? OFFSET ?";

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
        $entry['can_edit'] = ($entry['status'] === 'draft');
        $entry['can_post'] = ($entry['status'] === 'draft');
        $entry['can_void'] = ($entry['status'] === 'posted');

        // Format dates for display
        $entry['created_at'] = $entry['created_at'] ?? null;
        $entry['posted_at'] = $entry['posted_at'] ?? null;

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

            // Update status
            $updateSql = "UPDATE journal_entries SET status = 'voided' WHERE id = ?";
            $updateStmt = $conn->prepare($updateSql);
            $updateStmt->bind_param('i', $journalEntryId);
            $updateStmt->execute();

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
            $updateStmt->bind_param('ddddii', $newDebitMovements, $newCreditMovements, $newClosingBalance, $accountId, $fiscalPeriodId);
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
            $updateStmt->bind_param('ddddii', $newDebitMovements, $newCreditMovements, $newClosingBalance, $accountId, $fiscalPeriodId);
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

/**
 * Get Trial Balance using REAL client data from operational subsystems
 * Uses Bank System, Loan Subsystem, and HRIS-SIA data only
 */
function getTrialBalance()
{
    global $conn;

    try {
        $dateFrom = $_GET['date_from'] ?? '';
        $dateTo = $_GET['date_to'] ?? '';

        // Default to current month if no dates provided
        if (empty($dateFrom)) {
            $dateFrom = date('Y-m-01');
        }
        if (empty($dateTo)) {
            $dateTo = date('Y-m-t');
        }

        $accounts = [];
        $totalDebit = 0;
        $totalCredit = 0;

        // 1. BANK SYSTEM: Get bank transactions with real customer accounts (ASSETS)
        if (
            $conn->query("SHOW TABLES LIKE 'bank_transactions'")->num_rows > 0 &&
            $conn->query("SHOW TABLES LIKE 'customer_accounts'")->num_rows > 0 &&
            $conn->query("SHOW TABLES LIKE 'bank_customers'")->num_rows > 0 &&
            $conn->query("SHOW TABLES LIKE 'transaction_types'")->num_rows > 0
        ) {

            $sql = "
                SELECT 
                    ca.account_number as code,
                    CONCAT(bc.first_name, ' ', IFNULL(bc.middle_name, ''), ' ', bc.last_name) as name,
                    'asset' as account_type,
                    COALESCE(SUM(CASE 
                        WHEN tt.type_name LIKE '%deposit%' OR tt.type_name LIKE '%interest%' THEN bt.amount
                        ELSE 0
                    END), 0) as total_debit,
                    COALESCE(SUM(CASE 
                        WHEN tt.type_name LIKE '%withdrawal%' OR tt.type_name LIKE '%transfer%' THEN bt.amount
                        ELSE 0
                    END), 0) as total_credit
                FROM bank_transactions bt
                INNER JOIN customer_accounts ca ON bt.account_id = ca.account_id
                INNER JOIN bank_customers bc ON ca.customer_id = bc.customer_id
                INNER JOIN transaction_types tt ON bt.transaction_type_id = tt.transaction_type_id
                WHERE ca.is_locked = 0
                    AND DATE(bt.created_at) BETWEEN ? AND ?
                GROUP BY ca.account_id, ca.account_number, bc.first_name, bc.middle_name, bc.last_name
            ";

            $stmt = $conn->prepare($sql);
            if ($stmt) {
                $stmt->bind_param('ss', $dateFrom, $dateTo);
                $stmt->execute();
                $result = $stmt->get_result();

                while ($row = $result->fetch_assoc()) {
                    $debitBalance = (float) $row['total_debit'];
                    $creditBalance = (float) $row['total_credit'];
                    $netBalance = $debitBalance - $creditBalance;

                    // Only include accounts with non-zero balances
                    if ($debitBalance > 0 || $creditBalance > 0) {
                        $totalDebit += $debitBalance;
                        $totalCredit += $creditBalance;

                        $accounts[] = [
                            'id' => 'BANK-' . $row['code'],
                            'code' => $row['code'],
                            'name' => trim($row['name']),
                            'account_type' => $row['account_type'],
                            'debit_balance' => $debitBalance,
                            'credit_balance' => $creditBalance,
                            'net_balance' => $netBalance
                        ];
                    }
                }
                $stmt->close();
            }
        }

        // 2. LOAN SUBSYSTEM: Get loan applications with real borrower data (LIABILITIES)
        if ($conn->query("SHOW TABLES LIKE 'loan_applications'")->num_rows > 0) {
            $sql = "
                SELECT 
                    CONCAT('LOAN-', la.id) as code,
                    la.full_name as name,
                    'liability' as account_type,
                    0 as total_debit,
                    COALESCE(SUM(CASE 
                        WHEN la.status IN ('Approved', 'Active', 'Disbursed') THEN la.loan_amount
                        ELSE 0
                    END), 0) as total_credit
                FROM loan_applications la
                WHERE DATE(la.created_at) BETWEEN ? AND ?
                GROUP BY la.id, la.full_name
            ";

            $stmt = $conn->prepare($sql);
            if ($stmt) {
                $stmt->bind_param('ss', $dateFrom, $dateTo);
                $stmt->execute();
                $result = $stmt->get_result();

                while ($row = $result->fetch_assoc()) {
                    $debitBalance = (float) $row['total_debit'];
                    $creditBalance = (float) $row['total_credit'];
                    $netBalance = $creditBalance; // Liabilities are credits

                    // Only include loans with non-zero balances
                    if ($creditBalance > 0) {
                        $totalDebit += $debitBalance;
                        $totalCredit += $creditBalance;

                        $accounts[] = [
                            'id' => 'LOAN-' . str_replace('LOAN-', '', $row['code']),
                            'code' => $row['code'],
                            'name' => trim($row['name']),
                            'account_type' => $row['account_type'],
                            'debit_balance' => $debitBalance,
                            'credit_balance' => $creditBalance,
                            'net_balance' => -$netBalance // Negative for liabilities
                        ];
                    }
                }
                $stmt->close();
            }
        }

        // 3. PAYROLL: Get payroll runs with real employee data (EXPENSES)
        if (
            $conn->query("SHOW TABLES LIKE 'payroll_runs'")->num_rows > 0 &&
            $conn->query("SHOW TABLES LIKE 'payslips'")->num_rows > 0
        ) {

            $sql = "
                SELECT 
                    CONCAT('PAY-', ps.employee_external_no) as code,
                    CONCAT('Employee Payroll - ', ps.employee_external_no) as name,
                    'expense' as account_type,
                    COALESCE(SUM(ps.net_pay), 0) as total_debit,
                    COALESCE(SUM(ps.net_pay), 0) as total_credit
                FROM payroll_runs pr
                INNER JOIN payslips ps ON pr.id = ps.payroll_run_id
                WHERE pr.status IN ('completed', 'finalized')
                    AND DATE(pr.run_at) BETWEEN ? AND ?
                GROUP BY ps.employee_external_no
            ";

            $stmt = $conn->prepare($sql);
            if ($stmt) {
                $stmt->bind_param('ss', $dateFrom, $dateTo);
                $stmt->execute();
                $result = $stmt->get_result();

                while ($row = $result->fetch_assoc()) {
                    $debitBalance = (float) $row['total_debit'];
                    $creditBalance = (float) $row['total_credit'];
                    $netBalance = $debitBalance; // Expenses are debits

                    // Only include accounts with non-zero balances
                    if ($debitBalance > 0) {
                        $totalDebit += $debitBalance;
                        $totalCredit += 0; // Expenses don't have credit balance

                        $accounts[] = [
                            'id' => 'PAY-' . str_replace('PAY-', '', $row['code']),
                            'code' => $row['code'],
                            'name' => trim($row['name']),
                            'account_type' => $row['account_type'],
                            'debit_balance' => $debitBalance,
                            'credit_balance' => 0,
                            'net_balance' => $netBalance
                        ];
                    }
                }
                $stmt->close();
            }
        }

        // Sort accounts by code
        usort($accounts, function ($a, $b) {
            return strcmp($a['code'], $b['code']);
        });

        // Apply pagination
        $totalCount = count($accounts);
        $limit = (int) ($_GET['limit'] ?? 50);
        $offset = (int) ($_GET['offset'] ?? 0);
        $paginatedAccounts = array_slice($accounts, $offset, $limit);

        // Recalculate totals for paginated accounts (or keep full totals)
        $paginatedTotalDebit = 0;
        $paginatedTotalCredit = 0;
        foreach ($paginatedAccounts as $acc) {
            $paginatedTotalDebit += $acc['debit_balance'];
            $paginatedTotalCredit += $acc['credit_balance'];
        }

        return [
            'success' => true,
            'data' => [
                'accounts' => $paginatedAccounts,
                'totals' => [
                    'total_debit' => $totalDebit, // Full totals, not paginated
                    'total_credit' => $totalCredit, // Full totals, not paginated
                    'difference' => abs($totalDebit - $totalCredit)
                ],
                'date_from' => $dateFrom,
                'date_to' => $dateTo
            ],
            'count' => count($paginatedAccounts),
            'total' => $totalCount
        ];

    } catch (Exception $e) {
        return [
            'success' => false,
            'message' => $e->getMessage(),
            'data' => []
        ];
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
            // Get GL account info from accounts table
            $sql = "SELECT 
                        a.code as account_number,
                        a.name as account_name,
                        at.name as account_type,
                        COALESCE(v.closing_balance, 0) as available_balance
                    FROM accounts a
                    INNER JOIN account_types at ON a.type_id = at.id
                    LEFT JOIN v_account_balances v ON a.code = v.code
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
                    COALESCE(bat.type_name, 'Unknown') as account_type,
                    COALESCE(
                        (SELECT SUM(
                            CASE tt.type_name
                                WHEN 'Deposit' THEN bt.amount
                                WHEN 'Transfer In' THEN bt.amount
                                WHEN 'Interest Payment' THEN bt.amount
                                WHEN 'Loan Disbursement' THEN bt.amount
                                WHEN 'Withdrawal' THEN -bt.amount
                                WHEN 'Transfer Out' THEN -bt.amount
                                WHEN 'Service Charge' THEN -bt.amount
                                WHEN 'Loan Payment' THEN -bt.amount
                                ELSE 0
                            END
                        )
                         FROM bank_transactions bt
                         INNER JOIN transaction_types tt ON bt.transaction_type_id = tt.transaction_type_id
                         WHERE bt.account_id = ca.account_id), 
                        0
                    ) as available_balance
                FROM customer_accounts ca
                INNER JOIN bank_customers bc ON ca.customer_id = bc.customer_id
                INNER JOIN bank_account_types bat ON ca.account_type_id = bat.account_type_id
                WHERE ca.account_number = ? AND ca.is_locked = 0
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
        $statusFilter = $_GET['status_filter'] ?? 'pending';
        $search = $_GET['search'] ?? '';
        $limit = (int) ($_GET['limit'] ?? 25);
        $offset = (int) ($_GET['offset'] ?? 0);

        $whereClause = "WHERE 1=1";
        $params = [];
        $types = '';

        if ($statusFilter === 'pending') {
            $whereClause .= " AND status = 'Pending'";
        }

        if ($search) {
            $whereClause .= " AND (full_name LIKE ? OR email LIKE ? OR id LIKE ?)";
            $searchParam = "%$search%";
            $params[] = $searchParam;
            $params[] = $searchParam;
            $params[] = $searchParam;
            $types .= 'sss';
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
        ORDER BY created_at DESC
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
        $types .= 'ii';
        $params[] = $limit;
        $params[] = $offset;

        $stmt = $conn->prepare($sql);
        $stmt->bind_param($types, ...$params);
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
?>