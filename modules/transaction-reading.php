<?php
require_once '../config/database.php';
require_once '../includes/session.php';

requireLogin();
$current_user = getCurrentUser();

// Initialize filter variables
$filter_date_from = $_GET['date_from'] ?? '';
$filter_date_to = $_GET['date_to'] ?? '';
$filter_type = $_GET['type'] ?? '';
$filter_status = $_GET['status'] ?? '';
$filter_account = $_GET['account'] ?? '';
$apply_filters = isset($_GET['apply_filters']);

// Fetch transactions from database
$transactions = [];
$hasFilters = false;

if ($apply_filters) {
    $hasFilters = !empty($filter_date_from) || !empty($filter_date_to) ||
        !empty($filter_type) || !empty($filter_status) || !empty($filter_account);
}

// Check which tables exist in the database
$existingTables = [];
$tableCheckResult = $conn->query("SHOW TABLES");
if ($tableCheckResult) {
    while ($tableRow = $tableCheckResult->fetch_row()) {
        $existingTables[] = $tableRow[0];
    }
}

// Check if deleted_at column exists in journal_entries
$hasDeletedAtColumn = false;
if (in_array('journal_entries', $existingTables)) {
    try {
        $checkResult = $conn->query("SHOW COLUMNS FROM journal_entries LIKE 'deleted_at'");
        $hasDeletedAtColumn = $checkResult && $checkResult->num_rows > 0;
    } catch (Exception $e) {
        $hasDeletedAtColumn = false;
    }
}

// Try to load transactions from available tables
try {
    $hasJournalEntries = in_array('journal_entries', $existingTables);
    $hasJournalTypes = in_array('journal_types', $existingTables);
    $hasUsers = in_array('users', $existingTables);
    $hasFiscalPeriods = in_array('fiscal_periods', $existingTables);
    $hasBankTransactions = in_array('bank_transactions', $existingTables);
    $hasTransactionTypes = in_array('transaction_types', $existingTables);
    $hasBankEmployees = in_array('bank_employees', $existingTables);
    $hasCustomerAccounts = in_array('customer_accounts', $existingTables);

    if ($hasJournalEntries && $hasJournalTypes && $hasUsers) {
        $deletedFilter = "je.status != 'voided' AND je.status != 'deleted'";
        if ($hasDeletedAtColumn) {
            $deletedFilter .= " AND (je.deleted_at IS NULL OR je.deleted_at = '' OR je.deleted_at = '0000-00-00 00:00:00')";
        }

        $jeSql = "SELECT 
                    CONCAT('JE-', je.id) as id,
                    je.journal_no as journal_no,
                    je.entry_date as entry_date,
                    jt.code as type_code,
                    jt.name as type_name,
                    je.description,
                    je.reference_no,
                    je.total_debit,
                    je.total_credit,
                    je.status,
                    u.username as created_by,
                    u.full_name as created_by_name,
                    je.created_at,
                    je.posted_at,
                    " . ($hasFiscalPeriods ? "fp.period_name" : "NULL") . " as fiscal_period,
                    'journal' as source
                FROM journal_entries je
                INNER JOIN journal_types jt ON je.journal_type_id = jt.id
                INNER JOIN users u ON je.created_by = u.id
                " . ($hasFiscalPeriods ? "LEFT JOIN fiscal_periods fp ON je.fiscal_period_id = fp.id" : "") . "
                WHERE $deletedFilter";

        $params = [];
        $types = '';

        if (!empty($filter_date_from)) {
            $jeSql .= " AND je.entry_date >= ?";
            $params[] = $filter_date_from;
            $types .= 's';
        }
        if (!empty($filter_date_to)) {
            $jeSql .= " AND je.entry_date <= ?";
            $params[] = $filter_date_to;
            $types .= 's';
        }
        if (!empty($filter_type)) {
            $jeSql .= " AND jt.code = ?";
            $params[] = $filter_type;
            $types .= 's';
        }
        if (!empty($filter_status)) {
            $jeSql .= " AND je.status = ?";
            $params[] = $filter_status;
            $types .= 's';
        }
        if (!empty($filter_account)) {
            $jeSql .= " AND (je.reference_no LIKE ? OR je.description LIKE ?)";
            $params[] = "%{$filter_account}%";
            $params[] = "%{$filter_account}%";
            $types .= 'ss';
        }

        $jeSql .= " ORDER BY je.entry_date DESC, je.created_at DESC";

        $stmt = $conn->prepare($jeSql);
        if ($stmt) {
            if (!empty($params)) {
                $stmt->bind_param($types, ...$params);
            }
            $stmt->execute();
            $result = $stmt->get_result();
            while ($row = $result->fetch_assoc()) {
                $transactions[] = $row;
            }
            $stmt->close();
        } else {
            error_log("Journal entries query preparation failed: " . $conn->error);
        }
    }

    if ($hasBankTransactions && $hasTransactionTypes && $hasCustomerAccounts) {
        $hasBankDeletedAtColumn = false;
        try {
            $checkBankResult = $conn->query("SHOW COLUMNS FROM bank_transactions LIKE 'deleted_at'");
            $hasBankDeletedAtColumn = $checkBankResult && $checkBankResult->num_rows > 0;
        } catch (Exception $e) {
            $hasBankDeletedAtColumn = false;
        }

        $btSql = "SELECT 
                    CONCAT('BT-', bt.transaction_id) as id,
                    bt.transaction_ref as journal_no,
                    DATE(bt.created_at) as entry_date,
                    tt.type_name as type_code,
                    tt.type_name as type_name,
                    COALESCE(bt.description, 'Bank Transaction') as description,
                    bt.transaction_ref as reference_no,
                    CASE WHEN bt.amount > 0 THEN bt.amount ELSE 0 END as total_debit,
                    CASE WHEN bt.amount < 0 THEN ABS(bt.amount) ELSE 0 END as total_credit,
                    'posted' as status,
                    COALESCE(" . ($hasBankEmployees ? "be.employee_name" : "'System'") . ", 'System') as created_by,
                    COALESCE(" . ($hasBankEmployees ? "be.employee_name" : "'System'") . ", 'System') as created_by_name,
                    bt.created_at,
                    bt.created_at as posted_at,
                    DATE_FORMAT(bt.created_at, '%Y-%m') as fiscal_period,
                    'bank' as source
                FROM bank_transactions bt
                INNER JOIN transaction_types tt ON bt.transaction_type_id = tt.transaction_type_id
                " . ($hasBankEmployees ? "LEFT JOIN bank_employees be ON bt.employee_id = be.employee_id" : "") . "
                INNER JOIN customer_accounts ca ON bt.account_id = ca.account_id
                " . ($hasBankDeletedAtColumn ? "WHERE bt.deleted_at IS NULL" : "");

        $btStmt = $conn->prepare($btSql);
        if ($btStmt) {
            $btStmt->execute();
            $btResult = $btStmt->get_result();
            while ($row = $btResult->fetch_assoc()) {
                $transactions[] = $row;
            }
            $btStmt->close();
        }
    }

    usort($transactions, function ($a, $b) {
        return strtotime($b['entry_date']) - strtotime($a['entry_date']);
    });

} catch (Exception $e) {
    error_log("Transaction query error: " . $e->getMessage());
}

// Get statistics
$stats = [
    'total_transactions' => 0,
    'posted_count' => 0,
    'draft_count' => 0,
    'today_count' => 0
];

try {
    if (in_array('journal_entries', $existingTables)) {
        $stats_sql = "SELECT 
                        COUNT(*) as total_transactions,
                        SUM(CASE WHEN status = 'posted' THEN 1 ELSE 0 END) as posted_count,
                        SUM(CASE WHEN status = 'draft' THEN 1 ELSE 0 END) as draft_count,
                        SUM(CASE WHEN DATE(entry_date) = CURDATE() THEN 1 ELSE 0 END) as today_count
                      FROM journal_entries 
                      WHERE status NOT IN ('deleted', 'voided')";

        $result = $conn->query($stats_sql);
        if ($result) {
            $stats = $result->fetch_assoc();
        }
    }
} catch (Exception $e) {
    error_log("Statistics query error: " . $e->getMessage());
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Transaction Recording - Accounting and Finance System</title>
    <link rel="icon" type="image/png" href="../assets/image/LOGO.png">
    <link rel="shortcut icon" type="image/png" href="../assets/image/LOGO.png">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../assets/css/style.css">
    <link rel="stylesheet" href="../assets/css/dashboard.css">
    <link rel="stylesheet" href="../assets/css/transaction-reading.css">
    <style>
        .tr-page {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: #f8f9fa;
            min-height: 100vh;
        }

        .tr-container {
            max-width: 1280px;
            margin: 0 auto;
            padding: 32px 40px;
        }

        /* Header styles now in style.css */

        .tr-btn-import {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 20px;
            background: #fff;
            border: 1.5px solid #d1d5db;
            border-radius: 10px;
            color: #374151;
            font-weight: 600;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.2s;
            text-decoration: none;
        }

        .tr-btn-import:hover {
            background: #f9fafb;
            border-color: #9ca3af;
            color: #374151;
        }

        .tr-btn-new {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 20px;
            background: #1a3c3c;
            border: none;
            border-radius: 10px;
            color: #fff;
            font-weight: 600;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.2s;
            text-decoration: none;
        }

        .tr-btn-new:hover {
            background: #15302f;
            color: #fff;
        }

        .tr-stats {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-bottom: 28px;
        }

        .tr-stat-card {
            background: #fff;
            border: 1px solid #e5e7eb;
            border-radius: 14px;
            padding: 20px 24px;
            position: relative;
        }

        .tr-stat-card__icon {
            width: 40px;
            height: 40px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 16px;
            margin-bottom: 14px;
        }

        .tr-stat-card__icon--total {
            background: #eef2ff;
            color: #4f46e5;
        }

        .tr-stat-card__icon--posted {
            background: #ecfdf5;
            color: #059669;
        }

        .tr-stat-card__icon--draft {
            background: #fff7ed;
            color: #ea580c;
        }

        .tr-stat-card__badge {
            position: absolute;
            top: 20px;
            right: 20px;
            font-size: 12px;
            font-weight: 600;
            padding: 3px 10px;
            border-radius: 20px;
        }

        .tr-stat-card__badge--up {
            background: #ecfdf5;
            color: #059669;
        }

        .tr-stat-card__badge--down {
            background: #fef2f2;
            color: #dc2626;
        }

        .tr-stat-card__label {
            font-size: 13px;
            color: #6b7280;
            margin-bottom: 2px;
            font-weight: 500;
        }

        .tr-stat-card__value {
            font-size: 32px;
            font-weight: 800;
            color: #111827;
            letter-spacing: -1px;
        }

        .tr-table-section {
            background: #fff;
            border: 1px solid #e5e7eb;
            border-radius: 14px;
            overflow: hidden;
        }

        .tr-toolbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 16px 24px;
            border-bottom: 1px solid #f3f4f6;
        }

        .tr-toolbar__left {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .tr-toolbar__right {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .tr-tab-group {
            display: flex;
            background: #f3f4f6;
            border-radius: 8px;
            padding: 3px;
            margin-right: 10px;
        }

        .tr-tab {
            padding: 6px 16px;
            background: transparent;
            border: none;
            border-radius: 6px;
            font-size: 13px;
            font-weight: 500;
            color: #6b7280;
            cursor: pointer;
            transition: all 0.2s;
        }

        .tr-tab.active {
            background: #fff;
            color: #111827;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
            font-weight: 600;
        }

        .tr-tab:hover:not(.active) {
            color: #374151;
        }

        .tr-btn-filter {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 7px 14px;
            background: #fff;
            border: 1.5px solid #e5e7eb;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 500;
            color: #374151;
            cursor: pointer;
            transition: all 0.15s;
        }

        .tr-btn-filter:hover {
            border-color: #d1d5db;
            background: #f9fafb;
        }

        .tr-btn-icon {
            width: 36px;
            height: 36px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background: #fff;
            border: 1.5px solid #e5e7eb;
            border-radius: 8px;
            color: #374151;
            cursor: pointer;
            transition: all 0.15s;
        }

        .tr-btn-icon:hover {
            border-color: #d1d5db;
            background: #f9fafb;
        }

        .tr-btn-export {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 7px 16px;
            background: #059669;
            border: none;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 600;
            color: #fff;
            cursor: pointer;
            transition: all 0.15s;
        }

        .tr-btn-export:hover {
            background: #047857;
        }

        .tr-filter-panel {
            display: none;
            padding: 16px 24px;
            border-bottom: 1px solid #f3f4f6;
            background: #f9fafb;
        }

        .tr-filter-panel.show {
            display: block;
        }

        .tr-table {
            width: 100%;
            border-collapse: collapse;
        }

        .tr-table thead th {
            padding: 12px 16px;
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: #9ca3af;
            border-bottom: 1px solid #f3f4f6;
            background: #fafafa;
        }

        .tr-table tbody tr {
            border-bottom: 1px solid #f3f4f6;
            transition: background 0.1s;
        }

        .tr-table tbody tr:hover {
            background: #f9fafb;
        }

        .tr-table tbody td {
            padding: 16px;
            font-size: 14px;
            color: #374151;
            vertical-align: middle;
        }

        .tr-table .journal-no {
            font-weight: 700;
            color: #111827;
            font-size: 13px;
        }

        .tr-table .date-cell {
            color: #6b7280;
            font-size: 13px;
        }

        .tr-table .amount-cell {
            font-weight: 600;
            text-align: right;
            font-variant-numeric: tabular-nums;
        }

        .tr-type-badge {
            padding: 4px 10px;
            border-radius: 5px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.3px;
            display: inline-block;
        }

        .tr-type-badge--general {
            background: #1e3a5f;
            color: #fff;
        }

        .tr-type-badge--payment {
            background: #f59e0b;
            color: #fff;
        }

        .tr-type-badge--expense {
            background: #ef4444;
            color: #fff;
        }

        .tr-type-badge--revenue {
            background: #22c55e;
            color: #fff;
        }

        .tr-type-badge--journal {
            background: #6366f1;
            color: #fff;
        }

        .tr-type-badge--default {
            background: #6b7280;
            color: #fff;
        }

        .tr-status {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 13px;
            font-weight: 500;
        }

        .tr-status__dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
        }

        .tr-status--posted .tr-status__dot {
            background: #22c55e;
        }

        .tr-status--posted {
            color: #15803d;
        }

        .tr-status--draft .tr-status__dot {
            background: #f59e0b;
        }

        .tr-status--draft {
            color: #b45309;
        }

        .tr-status--reversed .tr-status__dot {
            background: #ef4444;
        }

        .tr-status--reversed {
            color: #dc2626;
        }

        .tr-status--voided .tr-status__dot {
            background: #6b7280;
        }

        .tr-status--voided {
            color: #6b7280;
        }

        .tr-action-btn {
            width: 32px;
            height: 32px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background: transparent;
            border: none;
            border-radius: 6px;
            color: #9ca3af;
            cursor: pointer;
            transition: all 0.15s;
            font-size: 14px;
        }

        .tr-action-btn:hover {
            background: #f3f4f6;
            color: #374151;
        }

        .tr-action-btn--danger:hover {
            background: #fef2f2;
            color: #dc2626;
        }

        .tr-pagination {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 16px 24px;
            border-top: 1px solid #f3f4f6;
        }

        .tr-pagination__info {
            font-size: 13px;
            color: #6b7280;
        }

        .tr-pagination__pages {
            display: flex;
            align-items: center;
            gap: 4px;
        }

        .tr-page-btn {
            width: 32px;
            height: 32px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background: transparent;
            border: none;
            border-radius: 6px;
            font-size: 13px;
            font-weight: 500;
            color: #6b7280;
            cursor: pointer;
            transition: all 0.15s;
        }

        .tr-page-btn:hover {
            background: #f3f4f6;
        }

        .tr-page-btn.active {
            background: #1a3c3c;
            color: #fff;
        }

        .tr-empty {
            padding: 60px 20px;
            text-align: center;
        }

        .tr-empty__icon {
            width: 56px;
            height: 56px;
            border-radius: 14px;
            background: #f3f4f6;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            color: #9ca3af;
            margin-bottom: 16px;
        }

        .tr-empty__title {
            font-size: 15px;
            font-weight: 600;
            color: #374151;
            margin-bottom: 4px;
        }

        .tr-empty__text {
            font-size: 13px;
            color: #9ca3af;
        }

        @media (max-width: 768px) {
            .tr-container {
                padding: 16px;
            }

            .tr-stats {
                grid-template-columns: 1fr;
            }

            .tr-toolbar {
                flex-direction: column;
                gap: 12px;
            }

            .tr-pagination {
                flex-direction: column;
                gap: 12px;
            }
        }
    </style>
</head>

<body class="tr-page">
    <?php include '../includes/navbar.php'; ?>

    <div class="tr-container">
        <!-- Beautiful Page Header -->
        <div class="beautiful-page-header mb-4">
            <div class="container-fluid">
                <div class="row align-items-center">
                    <div class="col-lg-8">
                        <div class="header-content">
                            <h1 class="page-title-beautiful">
                                <i class="fas fa-exchange-alt me-3"></i>
                                Transaction Recording
                            </h1>
                            <p class="page-subtitle-beautiful">
                                Manage and review your financial entries with precision
                            </p>
                        </div>
                    </div>
                    <div class="col-lg-4 text-lg-end">
                        <div class="header-info-card">
                            <div class="info-item">
                                <div class="info-icon">
                                    <i class="fas fa-database"></i>
                                </div>
                                <div class="info-content">
                                    <div class="info-label">Database Status</div>
                                    <div class="info-value status-connected">Connected</div>
                                </div>
                            </div>
                            <div class="info-item">
                                <div class="info-icon">
                                    <i class="fas fa-calendar-alt"></i>
                                </div>
                                <div class="info-content">
                                    <div class="info-label">Current Period</div>
                                    <div class="info-value"><?php echo date('F Y'); ?></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Stats Cards -->
        <div class="tr-stats">
            <div class="tr-stat-card">
                <div class="tr-stat-card__icon tr-stat-card__icon--total"><i class="fas fa-receipt"></i></div>
                <span class="tr-stat-card__badge tr-stat-card__badge--up">+12.5%</span>
                <div class="tr-stat-card__label">Total Transactions</div>
                <div class="tr-stat-card__value"><?php echo number_format($stats['total_transactions'] ?? 0); ?></div>
            </div>
            <div class="tr-stat-card">
                <div class="tr-stat-card__icon tr-stat-card__icon--posted"><i class="fas fa-check-circle"></i></div>
                <span class="tr-stat-card__badge tr-stat-card__badge--up">+8.2%</span>
                <div class="tr-stat-card__label">Posted Entries</div>
                <div class="tr-stat-card__value"><?php echo number_format($stats['posted_count'] ?? 0); ?></div>
            </div>
            <div class="tr-stat-card">
                <div class="tr-stat-card__icon tr-stat-card__icon--draft"><i class="fas fa-file-alt"></i></div>
                <span class="tr-stat-card__badge tr-stat-card__badge--down">-5.1%</span>
                <div class="tr-stat-card__label">Draft Entries</div>
                <div class="tr-stat-card__value"><?php echo number_format($stats['draft_count'] ?? 0); ?></div>
            </div>
        </div>

        <!-- Table Section -->
        <div class="tr-table-section">
            <div class="tr-toolbar">
                <div class="tr-toolbar__left">
                    <div class="tr-tab-group">
                        <button class="tr-tab active" onclick="filterByStatus('all', this)">All</button>
                        <button class="tr-tab" onclick="filterByStatus('posted', this)">Posted</button>
                        <button class="tr-tab" onclick="filterByStatus('draft', this)">Draft</button>
                    </div>
                    <button class="tr-btn-filter" id="btnShowFilters"><i class="fas fa-sliders-h"></i> Filters</button>
                </div>
                <div class="tr-toolbar__right">
                    <button class="tr-btn-icon" onclick="printTable()" title="Print"><i
                            class="fas fa-print"></i></button>
                    <button class="tr-btn-export" onclick="exportToPDF()"><i class="fas fa-download"></i> Export
                        PDF</button>
                </div>
            </div>

            <!-- Filter Panel -->
            <div class="tr-filter-panel" id="filterPanel">
                <form method="GET" action="" id="filterForm">
                    <div class="row g-3 align-items-end">
                        <div class="col-md-3">
                            <label for="date_from" class="form-label"
                                style="font-size:13px;font-weight:500;color:#374151;">Date From</label>
                            <input type="date" class="form-control form-control-sm" id="date_from" name="date_from"
                                value="<?php echo htmlspecialchars($filter_date_from); ?>">
                        </div>
                        <div class="col-md-3">
                            <label for="date_to" class="form-label"
                                style="font-size:13px;font-weight:500;color:#374151;">Date To</label>
                            <input type="date" class="form-control form-control-sm" id="date_to" name="date_to"
                                value="<?php echo htmlspecialchars($filter_date_to); ?>">
                        </div>
                        <div class="col-md-3">
                            <label for="status" class="form-label"
                                style="font-size:13px;font-weight:500;color:#374151;">Status</label>
                            <select class="form-select form-select-sm" id="status" name="status">
                                <option value="">All</option>
                                <option value="posted" <?php echo $filter_status === 'posted' ? 'selected' : ''; ?>>Posted
                                </option>
                                <option value="draft" <?php echo $filter_status === 'draft' ? 'selected' : ''; ?>>Draft
                                </option>
                            </select>
                        </div>
                        <div class="col-md-3 d-flex gap-2">
                            <button type="button" class="btn btn-sm btn-outline-secondary" onclick="clearFilters()"><i
                                    class="fas fa-times me-1"></i>Clear</button>
                            <button type="submit" name="apply_filters" class="btn btn-sm btn-primary"><i
                                    class="fas fa-search me-1"></i>Apply</button>
                        </div>
                    </div>
                </form>
            </div>

            <?php if ($apply_filters && $hasFilters && empty($transactions)): ?>
                <div class="px-4 pt-3">
                    <div class="alert alert-warning mb-0" role="alert" style="font-size:13px;">
                        <i class="fas fa-exclamation-triangle me-2"></i>No transactions match your filter criteria.
                    </div>
                </div>
            <?php endif; ?>

            <!-- Table -->
            <div class="table-responsive">
                <table id="transactionTable" class="tr-table">
                    <thead>
                        <tr>
                            <th>Journal No.</th>
                            <th>Date</th>
                            <th>Type</th>
                            <th>Description</th>
                            <th>Reference</th>
                            <th style="text-align:right;">Debit</th>
                            <th style="text-align:right;">Credit</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php if (empty($transactions)): ?>
                            <tr>
                                <td colspan="9">
                                    <div class="tr-empty">
                                        <div class="tr-empty__icon"><i class="fas fa-inbox"></i></div>
                                        <div class="tr-empty__title">No transaction data available yet</div>
                                        <div class="tr-empty__text">Add sample data using the SQL queries provided in the
                                            documentation.</div>
                                    </div>
                                </td>
                            </tr>
                        <?php else: ?>
                            <?php
                            $total_debit = 0;
                            $total_credit = 0;
                            foreach ($transactions as $trans):
                                $total_debit += $trans['total_debit'];
                                $total_credit += $trans['total_credit'];
                                $type_code = strtolower($trans['type_code'] ?? '');
                                $badge_class = 'tr-type-badge--default';
                                if (strpos($type_code, 'general') !== false || $type_code === 'gj')
                                    $badge_class = 'tr-type-badge--general';
                                elseif (strpos($type_code, 'payment') !== false || $type_code === 'cp' || $type_code === 'cd')
                                    $badge_class = 'tr-type-badge--payment';
                                elseif (strpos($type_code, 'expense') !== false)
                                    $badge_class = 'tr-type-badge--expense';
                                elseif (strpos($type_code, 'revenue') !== false || $type_code === 'cr')
                                    $badge_class = 'tr-type-badge--revenue';
                                elseif (strpos($type_code, 'journal') !== false || $type_code === 'jv')
                                    $badge_class = 'tr-type-badge--journal';
                                ?>
                                <tr data-transaction-id="<?php echo htmlspecialchars($trans['id'], ENT_QUOTES); ?>"
                                    data-status="<?php echo htmlspecialchars($trans['status']); ?>">
                                    <td class="journal-no"><?php echo htmlspecialchars($trans['journal_no']); ?></td>
                                    <td class="date-cell"><?php echo date('M d, Y', strtotime($trans['entry_date'])); ?></td>
                                    <td><span
                                            class="tr-type-badge <?php echo $badge_class; ?>"><?php echo htmlspecialchars(strtoupper($trans['type_code'])); ?></span>
                                    </td>
                                    <td><?php echo htmlspecialchars($trans['description'] ?? '-'); ?></td>
                                    <td style="color:#6b7280;"><?php echo htmlspecialchars($trans['reference_no'] ?? '-'); ?>
                                    </td>
                                    <td class="amount-cell">$<?php echo number_format($trans['total_debit'], 2); ?></td>
                                    <td class="amount-cell">$<?php echo number_format($trans['total_credit'], 2); ?></td>
                                    <td>
                                        <span class="tr-status tr-status--<?php echo htmlspecialchars($trans['status']); ?>">
                                            <span class="tr-status__dot"></span>
                                            <?php echo ucfirst($trans['status']); ?>
                                        </span>
                                    </td>
                                    <td>
                                        <button class="tr-action-btn"
                                            onclick="viewTransactionDetails('<?php echo htmlspecialchars($trans['id'], ENT_QUOTES); ?>')"
                                            title="View Details"><i class="fas fa-eye"></i></button>
                                        <button class="tr-action-btn tr-action-btn--danger"
                                            onclick="deleteTransaction('<?php echo htmlspecialchars($trans['id'], ENT_QUOTES); ?>')"
                                            title="Delete"><i class="fas fa-trash-alt"></i></button>
                                    </td>
                                </tr>
                            <?php endforeach; ?>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>

            <?php if (!empty($transactions)): ?>
                <div class="tr-pagination">
                    <div class="tr-pagination__info">
                        Showing 1 to <?php echo count($transactions); ?> of
                        <?php echo number_format($stats['total_transactions'] ?? count($transactions)); ?> transactions
                    </div>
                    <div class="tr-pagination__pages">
                        <button class="tr-page-btn"><i class="fas fa-chevron-left"></i></button>
                        <button class="tr-page-btn active">1</button>
                        <?php if (($stats['total_transactions'] ?? 0) > 25): ?>
                            <button class="tr-page-btn">2</button>
                            <button class="tr-page-btn">3</button>
                            <button class="tr-page-btn" disabled>...</button>
                            <button class="tr-page-btn"><?php echo ceil(($stats['total_transactions'] ?? 1) / 25); ?></button>
                        <?php endif; ?>
                        <button class="tr-page-btn"><i class="fas fa-chevron-right"></i></button>
                    </div>
                </div>
            <?php endif; ?>
        </div>

        <?php include '../includes/footer.php'; ?>
    </div>

    <!-- Audit Trail Modal -->
    <div class="modal fade" id="auditTrailModal" tabindex="-1" aria-labelledby="auditTrailModalLabel"
        aria-hidden="true">
        <div class="modal-dialog modal-xl">
            <div class="modal-content">
                <div class="modal-header" style="background:#1a3c3c;color:#fff;">
                    <h5 class="modal-title" id="auditTrailModalLabel"><i class="fas fa-history me-2"></i>Audit Trail
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"
                        aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="table-responsive">
                        <table class="table table-sm table-hover">
                            <thead class="table-light">
                                <tr>
                                    <th>Timestamp</th>
                                    <th>User</th>
                                    <th>Action</th>
                                    <th>Object Type</th>
                                    <th>Object ID</th>
                                    <th>IP Address</th>
                                    <th>Details</th>
                                </tr>
                            </thead>
                            <tbody id="auditTrailBody">
                                <tr>
                                    <td colspan="7" class="text-center text-muted">No audit trail data available.</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary" onclick="exportAuditTrail()"><i
                            class="fas fa-download me-1"></i>Export</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Transaction Details Modal -->
    <div class="modal fade" id="transactionDetailsModal" tabindex="-1" aria-labelledby="transactionDetailsModalLabel"
        aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header" style="background:#1a3c3c;color:#fff;">
                    <h5 class="modal-title" id="transactionDetailsModalLabel"><i
                            class="fas fa-file-invoice me-2"></i>Transaction Details</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"
                        aria-label="Close"></button>
                </div>
                <div class="modal-body" id="transactionDetailsBody">
                    <p class="text-center text-muted">Loading transaction details...</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div class="modal fade" id="deleteConfirmModal" tabindex="-1" aria-labelledby="deleteConfirmModalLabel"
        aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-danger text-white">
                    <h5 class="modal-title" id="deleteConfirmModalLabel"><i
                            class="fas fa-exclamation-triangle me-2"></i>Confirm Delete</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"
                        aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p>Are you sure you want to delete this transaction?</p>
                    <p class="text-muted small">It will be moved to the bin station where you can restore it later.</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-danger" id="confirmDeleteBtn"><i
                            class="fas fa-trash me-1"></i>Delete</button>
                </div>
            </div>
        </div>
    </div>

    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <!-- jsPDF for PDF Export -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.8.1/jspdf.plugin.autotable.min.js"></script>
    <!-- Custom JS -->
    <script src="../assets/js/dashboard.js"></script>
    <script src="../assets/js/transaction-reading.js"></script>
    <script src="../assets/js/notifications.js"></script>
    <script>
        function filterByStatus(status, btn) {
            document.querySelectorAll('.tr-tab').forEach(t => t.classList.remove('active'));
            btn.classList.add('active');
            const rows = document.querySelectorAll('#transactionTable tbody tr[data-status]');
            rows.forEach(row => {
                row.style.display = (status === 'all' || row.dataset.status === status) ? '' : 'none';
            });
        }
    </script>
</body>

</html>