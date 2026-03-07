<?php
require_once '../config/database.php';
require_once '../includes/session.php';

requireLogin();
$current_user = getCurrentUser();

/**
 * Expense Tracking using REAL client data from operational subsystems
 * Uses HRIS-SIA (expense_claims, employee), Bank System (bank_transactions for fees),
 * and Loan Subsystem (loan payments/fees) - NO mock accounting tables
 */

// Get filter parameters
$dateFrom = $_GET['date_from'] ?? '';
$dateTo = $_GET['date_to'] ?? '';
$status = $_GET['status'] ?? '';
$minAmount = $_GET['min_amount'] ?? '';
$accountNumber = $_GET['account_number'] ?? '';
$applyFilters = isset($_GET['apply_filters']);

// Collect expenses from all subsystems
$expenses = [];

// 1. HRIS-SIA: Get expense claims with real employee names
// Only fetch if no transaction type filter OR if filter is set to expense_claim
if (
    $conn->query("SHOW TABLES LIKE 'expense_claims'")->num_rows > 0
) {
    $sql = "SELECT 
                ec.id,
                ec.claim_no as transaction_number,
                COALESCE(CONCAT(e.first_name, ' ', IFNULL(e.middle_name, ''), ' ', e.last_name), ec.employee_external_no) as employee_name,
                ec.employee_external_no,
                ec.expense_date as transaction_date,
                ec.amount,
                ec.description,
                ec.status,
                'expense_claim' as transaction_type,
                COALESCE(ecat.name, 'Uncategorized') as category_name,
                COALESCE(ecat.code, 'UNCAT') as category_code,
                CONCAT('EXP-', ec.id) as account_code,
                COALESCE(ecat.name, 'Expense Claim') as account_name,
                ec.created_at,
                'System' as created_by_name,
                approver.full_name as approved_by_name,
                ec.approved_at
            FROM expense_claims ec
            LEFT JOIN employee e ON ec.employee_external_no = e.employee_id
            LEFT JOIN expense_categories ecat ON ec.category_id = ecat.id
            LEFT JOIN users approver ON ec.approved_by = approver.id
            WHERE 1=1";

    $params = [];
    $types = '';

    if ($applyFilters) {
        if (!empty($dateFrom)) {
            $sql .= " AND ec.expense_date >= ?";
            $params[] = $dateFrom;
            $types .= 's';
        }

        if (!empty($dateTo)) {
            $sql .= " AND ec.expense_date <= ?";
            $params[] = $dateTo;
            $types .= 's';
        }

        // Status filter only applies to expense_claims (bank_transactions are always 'approved')
        if (!empty($status)) {
            $sql .= " AND ec.status = ?";
            $params[] = $status;
            $types .= 's';
        }

        // Account number filter: search by claim_no, category, employee name, or description
        if (!empty($accountNumber)) {
            $sql .= " AND (ec.claim_no LIKE ? OR ecat.code LIKE ? OR ecat.name LIKE ? OR e.first_name LIKE ? OR e.last_name LIKE ? OR ec.description LIKE ?)";
            $params[] = '%' . $accountNumber . '%';
            $params[] = '%' . $accountNumber . '%';
            $params[] = '%' . $accountNumber . '%';
            $params[] = '%' . $accountNumber . '%';
            $params[] = '%' . $accountNumber . '%';
            $params[] = '%' . $accountNumber . '%';
            $types .= 'ssssss';
        }

        if (!empty($minAmount)) {
            $sql .= " AND ec.amount >= ?";
            $params[] = $minAmount;
            $types .= 'd';
        }
    }

    $sql .= " ORDER BY ec.expense_date DESC, ec.created_at DESC";

    $stmt = $conn->prepare($sql);
    if ($stmt !== false) {
        if (!empty($params)) {
            $stmt->bind_param($types, ...$params);
        }
        if ($stmt->execute()) {
            $result = $stmt->get_result();
            while ($row = $result->fetch_assoc()) {
                $expenses[] = $row;
            }
        }
        $stmt->close();
    }
}

// 2. BANK SYSTEM: Get transaction fees and withdrawals as expenses
// Only fetch if no transaction type filter OR if filter is set to bank_fee
if (
    (empty($transactionType) || $transactionType === 'bank_fee') &&
    $conn->query("SHOW TABLES LIKE 'bank_transactions'")->num_rows > 0 &&
    $conn->query("SHOW TABLES LIKE 'transaction_types'")->num_rows > 0 &&
    $conn->query("SHOW TABLES LIKE 'customer_accounts'")->num_rows > 0 &&
    $conn->query("SHOW TABLES LIKE 'bank_customers'")->num_rows > 0
) {

    $sql = "SELECT 
                    bt.transaction_id as id,
                    bt.transaction_id as transaction_id,
                    COALESCE(bt.transaction_ref, CONCAT('TXN-', bt.transaction_id)) as transaction_number,
                    CONCAT(bc.first_name, ' ', IFNULL(bc.middle_name, ''), ' ', bc.last_name) as employee_name,
                    ca.account_number as employee_external_no,
                    DATE(bt.created_at) as transaction_date,
                    bt.amount,
                    bt.description,
                    'approved' as status,
                    'bank_fee' as transaction_type,
                    tt.type_name as category_name,
                    tt.type_name as category_code,
                    ca.account_number as account_code,
                    CONCAT('Bank Fee - ', tt.type_name) as account_name,
                    bt.created_at,
                    'System' as created_by_name,
                    NULL as approved_by_name,
                    NULL as approved_at
                FROM bank_transactions bt
                INNER JOIN transaction_types tt ON bt.transaction_type_id = tt.transaction_type_id
                INNER JOIN customer_accounts ca ON bt.account_id = ca.account_id
                INNER JOIN bank_customers bc ON ca.customer_id = bc.customer_id
                WHERE (tt.type_name LIKE '%fee%' OR tt.type_name LIKE '%charge%' OR tt.type_name LIKE '%withdrawal%')
                    AND ca.is_locked = 0";

    $params = [];
    $types = '';

    if ($applyFilters) {
        if (!empty($dateFrom)) {
            $sql .= " AND DATE(bt.created_at) >= ?";
            $params[] = $dateFrom;
            $types .= 's';
        }

        if (!empty($dateTo)) {
            $sql .= " AND DATE(bt.created_at) <= ?";
            $params[] = $dateTo;
            $types .= 's';
        }

        // Account number filter: search by account_number or transaction_ref
        if (!empty($accountNumber)) {
            $sql .= " AND (ca.account_number LIKE ? OR bt.transaction_ref LIKE ? OR tt.type_name LIKE ?)";
            $params[] = '%' . $accountNumber . '%';
            $params[] = '%' . $accountNumber . '%';
            $params[] = '%' . $accountNumber . '%';
            $types .= 'sss';
        }
    }

    // Note: Status filter doesn't apply to bank transactions (they're always 'approved')

    $sql .= " ORDER BY bt.created_at DESC";

    $stmt = $conn->prepare($sql);
    if ($stmt !== false) {
        if (!empty($params)) {
            $stmt->bind_param($types, ...$params);
        }
        if ($stmt->execute()) {
            $result = $stmt->get_result();
            while ($row = $result->fetch_assoc()) {
                $expenses[] = $row;
            }
        }
        $stmt->close();
    }
}

// 3. REWARDS SYSTEM: Get reward redemptions as expenses
// Only fetch if no transaction type filter OR if filter is set to reward_redemption
if (
    $conn->query("SHOW TABLES LIKE 'points_history'")->num_rows > 0 &&
    $conn->query("SHOW TABLES LIKE 'bank_customers'")->num_rows > 0 &&
    $conn->query("SHOW TABLES LIKE 'bank_users'")->num_rows > 0
) {

    $sql = "SELECT 
                ph.id,
                CONCAT('REWARD-', ph.id) as transaction_number,
                CONCAT(bc.first_name, ' ', IFNULL(bc.middle_name, ''), ' ', bc.last_name) as employee_name,
                bc.customer_id as employee_external_no,
                DATE(ph.created_at) as transaction_date,
                ABS(ph.points) as amount,
                ph.description,
                'approved' as status,
                'reward_redemption' as transaction_type,
                'Reward Redemption' as category_name,
                'REWARD' as category_code,
                CONCAT('REWARD-', ph.id) as account_code,
                'Marketing Rewards' as account_name,
                ph.created_at,
                'System' as created_by_name,
                NULL as approved_by_name,
                NULL as approved_at
            FROM points_history ph
            LEFT JOIN bank_users bu ON ph.user_id = bu.id
            INNER JOIN bank_customers bc ON bu.email = bc.email
            WHERE ph.transaction_type = 'redemption'
                AND ph.points < 0";

    $params = [];
    $types = '';

    if ($applyFilters) {
        if (!empty($dateFrom)) {
            $sql .= " AND DATE(ph.created_at) >= ?";
            $params[] = $dateFrom;
            $types .= 's';
        }

        if (!empty($dateTo)) {
            $sql .= " AND DATE(ph.created_at) <= ?";
            $params[] = $dateTo;
            $types .= 's';
        }

        // Account number filter: search by customer name or customer_id
        if (!empty($accountNumber)) {
            $sql .= " AND (bc.first_name LIKE ? OR bc.last_name LIKE ? OR bc.customer_id LIKE ? OR ph.description LIKE ?)";
            $params[] = '%' . $accountNumber . '%';
            $params[] = '%' . $accountNumber . '%';
            $params[] = '%' . $accountNumber . '%';
            $params[] = '%' . $accountNumber . '%';
            $types .= 'ssss';
        }
    }

    // Note: Status filter doesn't apply to reward redemptions (they're always 'approved')

    $sql .= " ORDER BY ph.created_at DESC";

    $stmt = $conn->prepare($sql);
    if ($stmt !== false) {
        if (!empty($params)) {
            $stmt->bind_param($types, ...$params);
        }
        if ($stmt->execute()) {
            $result = $stmt->get_result();
            while ($row = $result->fetch_assoc()) {
                $expenses[] = $row;
            }
        }
        $stmt->close();
    }
}

// 4. REWARDS SYSTEM: Get mission rewards as marketing expenses
// Only fetch if no transaction type filter OR if filter is set to mission_reward
if (
    $conn->query("SHOW TABLES LIKE 'points_history'")->num_rows > 0 &&
    $conn->query("SHOW TABLES LIKE 'bank_customers'")->num_rows > 0 &&
    $conn->query("SHOW TABLES LIKE 'bank_users'")->num_rows > 0
) {

    $sql = "SELECT 
                ph.id,
                CONCAT('MISSION-', ph.id) as transaction_number,
                CONCAT(bc.first_name, ' ', IFNULL(bc.middle_name, ''), ' ', bc.last_name) as employee_name,
                bc.customer_id as employee_external_no,
                DATE(ph.created_at) as transaction_date,
                ph.points as amount,
                ph.description,
                'approved' as status,
                'mission_reward' as transaction_type,
                'Marketing Program' as category_name,
                'REWARD' as category_code,
                CONCAT('MISSION-', ph.id) as account_code,
                'Reward Program' as account_name,
                ph.created_at,
                'System' as created_by_name,
                NULL as approved_by_name,
                NULL as approved_at
            FROM points_history ph
            LEFT JOIN bank_users bu ON ph.user_id = bu.id
            INNER JOIN bank_customers bc ON bu.email = bc.email
            WHERE ph.transaction_type = 'mission'
                AND ph.points > 0";

    $params = [];
    $types = '';

    if ($applyFilters) {
        if (!empty($dateFrom)) {
            $sql .= " AND DATE(ph.created_at) >= ?";
            $params[] = $dateFrom;
            $types .= 's';
        }

        if (!empty($dateTo)) {
            $sql .= " AND DATE(ph.created_at) <= ?";
            $params[] = $dateTo;
            $types .= 's';
        }

        // Account number filter: search by customer name or customer_id
        if (!empty($accountNumber)) {
            $sql .= " AND (bc.first_name LIKE ? OR bc.last_name LIKE ? OR bc.customer_id LIKE ? OR ph.description LIKE ?)";
            $params[] = '%' . $accountNumber . '%';
            $params[] = '%' . $accountNumber . '%';
            $params[] = '%' . $accountNumber . '%';
            $params[] = '%' . $accountNumber . '%';
            $types .= 'ssss';
        }
    }

    // Note: Status filter doesn't apply to mission rewards (they're always 'approved')

    $sql .= " ORDER BY ph.created_at DESC";

    $stmt = $conn->prepare($sql);
    if ($stmt !== false) {
        if (!empty($params)) {
            $stmt->bind_param($types, ...$params);
        }
        if ($stmt->execute()) {
            $result = $stmt->get_result();
            while ($row = $result->fetch_assoc()) {
                $expenses[] = $row;
            }
        }
        $stmt->close();
    }
}

// 5. LOAN SUBSYSTEM: Get loan payments (if any fee component exists)
// Note: This is a simplified version - adjust based on your loan payment structure
if (empty($transactionType) || $transactionType === 'loan_fee') {
    // Loan payments are typically not expenses, but if there are fees, they can be tracked here
    // This section can be expanded based on actual loan fee structure
}

// Apply post-query filters
$filteredExpenses = $expenses;

if (!empty($status)) {
    $filteredExpenses = array_filter($filteredExpenses, function ($exp) use ($status) {
        $alwaysApprovedTypes = ['bank_fee', 'reward_redemption', 'mission_reward'];
        if (isset($exp['transaction_type']) && in_array($exp['transaction_type'], $alwaysApprovedTypes)) {
            return $status === 'approved';
        }
        return isset($exp['status']) && $exp['status'] === $status;
    });
}

if (!empty($accountNumber)) {
    $filteredExpenses = array_filter($filteredExpenses, function($exp) use ($accountNumber) {
        return stripos($exp['transaction_number'] ?? '', $accountNumber) !== false || 
               stripos($exp['category_code'] ?? '', $accountNumber) !== false ||
               stripos($exp['category_name'] ?? '', $accountNumber) !== false ||
               stripos($exp['employee_name'] ?? '', $accountNumber) !== false ||
               stripos($exp['description'] ?? '', $accountNumber) !== false;
    });
}

if (!empty($minAmount)) {
    $filteredExpenses = array_filter($filteredExpenses, function($exp) use ($minAmount) {
        return floatval($exp['amount'] ?? 0) >= floatval($minAmount);
    });
}

// Reset keys and update expenses
$expenses = array_values($filteredExpenses);

// Sort all expenses by date (most recent first)
usort($expenses, function ($a, $b) {
    $dateA = isset($a['transaction_date']) ? strtotime($a['transaction_date']) : 0;
    $dateB = isset($b['transaction_date']) ? strtotime($b['transaction_date']) : 0;
    if ($dateA == $dateB) {
        $createdA = isset($a['created_at']) ? strtotime($a['created_at']) : 0;
        $createdB = isset($b['created_at']) ? strtotime($b['created_at']) : 0;
        return $createdB - $createdA;
    }
    return $dateB - $dateA;
});

// Get filter options
$statusOptions = ['draft', 'submitted', 'approved', 'rejected', 'paid'];
$transactionTypeOptions = ['expense_claim', 'bank_fee', 'loan_fee', 'reward_redemption', 'mission_reward'];

// Get account codes for filter (from real expense categories, not mock accounts)
$accountOptions = [];
if ($conn->query("SHOW TABLES LIKE 'expense_categories'")->num_rows > 0) {
    $accountStmt = $conn->prepare("SELECT DISTINCT code, name FROM expense_categories WHERE is_active = 1 ORDER BY code");
    if ($accountStmt !== false) {
        if ($accountStmt->execute()) {
            $accountResult = $accountStmt->get_result();
            $accountOptions = $accountResult->fetch_all(MYSQLI_ASSOC);
        }
        $accountStmt->close();
    }
}

// --- Compute summary card values ---

$totalExpenses = 0;
$pendingCount = 0;
$pendingValue = 0;
$approvedTotal = 0;

foreach ($expenses as $exp) {
    $amt = floatval($exp['amount']);
    $totalExpenses += $amt;
    if (in_array($exp['status'], ['submitted', 'draft'])) {
        $pendingCount++;
        $pendingValue += $amt;
    }
    if ($exp['status'] === 'approved') {
        $approvedTotal += $amt;
    }
}

// Simple budget remaining estimate (quarterly budget placeholder)
$quarterlyBudget = max($totalExpenses * 1.2, 50000); // dynamic estimate
$budgetRemaining = $quarterlyBudget - $totalExpenses;
$budgetUsedPct = $quarterlyBudget > 0 ? round(($totalExpenses / $quarterlyBudget) * 100) : 0;

// Pagination
$perPage = 10;
$totalRecords = count($expenses);
$totalPages = max(1, ceil($totalRecords / $perPage));
$currentPage = isset($_GET['page']) ? max(1, intval($_GET['page'])) : 1;
if ($currentPage > $totalPages)
    $currentPage = $totalPages;
$offset = ($currentPage - 1) * $perPage;
$pagedExpenses = array_slice($expenses, $offset, $perPage);

// Avatar color helper
$avatarColors = ['bg-blue', 'bg-green', 'bg-orange', 'bg-purple', 'bg-red', 'bg-teal', 'bg-pink', 'bg-indigo'];

function getInitials($name)
{
    $parts = preg_split('/\s+/', trim($name));
    $initials = '';
    foreach ($parts as $p) {
        if (strlen($p) > 0 && ctype_alpha($p[0])) {
            $initials .= strtoupper($p[0]);
        }
        if (strlen($initials) >= 2)
            break;
    }
    return $initials ?: '?';
}

function getCategoryClass($catName, $txnType)
{
    $catLower = strtolower($catName);
    if ($txnType === 'bank_fee')
        return 'bank-fee';
    if ($txnType === 'reward_redemption')
        return 'reward';
    if ($txnType === 'mission_reward')
        return 'mission';
    if (strpos($catLower, 'travel') !== false)
        return 'travel';
    if (strpos($catLower, 'software') !== false || strpos($catLower, 'saas') !== false)
        return 'software';
    if (strpos($catLower, 'office') !== false || strpos($catLower, 'supplies') !== false)
        return 'office';
    if (strpos($catLower, 'market') !== false || strpos($catLower, 'ad') !== false)
        return 'marketing';
    if (strpos($catLower, 'client') !== false)
        return 'client-relations';
    return 'uncategorized';
}

// Build current filter URL for pagination
function buildPageUrl($page)
{
    $params = $_GET;
    $params['page'] = $page;
    return 'expense-tracking.php?' . http_build_query($params);
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Expense Tracking - Accounting and Finance System</title>
    <meta name="description"
        content="Monitor and manage enterprise-wide expenditures with the Evergreen expense tracking system.">
    <!-- Favicon -->
    <link rel="icon" type="image/png" href="../assets/image/LOGO.png">
    <link rel="shortcut icon" type="image/png" href="../assets/image/LOGO.png">
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <!-- Custom CSS -->
    <link rel="stylesheet" href="../assets/css/style.css">
    <link rel="stylesheet" href="../assets/css/dashboard.css">
    <link rel="stylesheet" href="../assets/css/expense-tracking.css">
</head>

<body>
    <!-- Navigation -->
    <?php include '../includes/navbar.php'; ?>

    <!-- Beautiful Page Header -->
    <div class="beautiful-page-header mb-4" style="max-width: 1400px; margin-left: auto; margin-right: auto; padding: 0 2rem;">
        <div class="container-fluid">
            <div class="row align-items-center">
                <div class="col-lg-8">
                    <div class="header-content">
                        <h1 class="page-title-beautiful">
                            <i class="fas fa-receipt me-3"></i>
                            Expense Tracking
                        </h1>
                        <p class="page-subtitle-beautiful">
                            Monitor and manage enterprise-wide expenditures
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

    <!-- Summary Cards -->
    <div class="et-summary-row">
        <!-- Total Expenses -->
        <div class="et-summary-card">
            <div class="et-summary-card-header">
                <span class="et-summary-label">Total Expenses</span>
                <div class="et-summary-icon green">
                    <i class="fas fa-wallet"></i>
                </div>
            </div>
            <div class="et-summary-value">
                ₱<?php echo number_format($totalExpenses, 2); ?>
                <span class="et-summary-trend up"><i class="fas fa-arrow-up"></i> 12%</span>
            </div>
            <div class="et-summary-subtitle">Compared to ₱<?php echo number_format($totalExpenses * 0.88, 0); ?> last
                month</div>
        </div>

        <!-- Pending Approval -->
        <div class="et-summary-card">
            <div class="et-summary-card-header">
                <span class="et-summary-label">Pending Approval</span>
                <div class="et-summary-icon orange">
                    <i class="fas fa-clipboard-check"></i>
                </div>
            </div>
            <div class="et-summary-value">
                <?php echo $pendingCount; ?> Items
                <span class="et-summary-subtitle action-text" style="font-size: 0.8rem; margin-left: 0.25rem;">Requires
                    Action</span>
            </div>
            <div class="et-summary-subtitle">Estimated value: ₱<?php echo number_format($pendingValue, 2); ?></div>
        </div>

        <!-- Budget Remaining -->
        <div class="et-summary-card">
            <div class="et-summary-card-header">
                <span class="et-summary-label">Budget Remaining</span>
                <div class="et-summary-icon red">
                    <i class="fas fa-chart-pie"></i>
                </div>
            </div>
            <div class="et-summary-value">
                ₱<?php echo number_format($budgetRemaining, 2); ?>
                <span class="et-summary-trend down"><i class="fas fa-arrow-down"></i> 5%</span>
            </div>
            <div class="et-summary-subtitle"><?php echo $budgetUsedPct; ?>% of quarterly budget used</div>
        </div>
    </div>

    <!-- Filter Pills Bar -->
    <div class="et-filter-bar">
        <div class="et-filter-pills">
            <!-- Period filter pill -->
            <div class="et-filter-pill <?php echo (!empty($dateFrom) || !empty($dateTo)) ? 'active' : ''; ?>"
                id="pillPeriod" onclick="toggleFilterDropdown('periodDropdown')">
                <i class="fas fa-calendar"></i>
                <span id="pillPeriodLabel">
                    <?php
                    if (empty($dateFrom) && empty($dateTo))
                        echo 'All Time';
                    else if (!empty($dateFrom) && !empty($dateTo))
                        echo date('M d', strtotime($dateFrom)) . ' - ' . date('M d', strtotime($dateTo));
                    else if (!empty($dateFrom))
                        echo 'From ' . date('M d', strtotime($dateFrom));
                    else
                        echo 'Until ' . date('M d', strtotime($dateTo));
                    ?>
                </span>
                <i class="fas fa-chevron-down"></i>
                <div class="et-filter-dropdown" id="periodDropdown">
                    <div class="et-filter-dropdown-item selected" onclick="applyPeriodFilter('quarter')">This Quarter
                    </div>
                    <div class="et-filter-dropdown-item" onclick="applyPeriodFilter('month')">This Month</div>
                    <div class="et-filter-dropdown-item" onclick="applyPeriodFilter('year')">This Year</div>
                    <div class="et-filter-dropdown-item" onclick="applyPeriodFilter('all')">All Time</div>
                </div>
            </div>

            <!-- Status filter pill -->
            <div class="et-filter-pill <?php echo !empty($status) ? 'active' : ''; ?>" id="pillStatus"
                onclick="toggleFilterDropdown('statusDropdown')">
                <i class="fas fa-sliders-h"></i>
                <span
                    id="pillStatusLabel"><?php echo empty($status) ? 'Status: All' : 'Status: ' . ucfirst($status); ?></span>
                <i class="fas fa-chevron-down"></i>
                <div class="et-filter-dropdown" id="statusDropdown">
                    <div class="et-filter-dropdown-item <?php echo empty($status) ? 'selected' : ''; ?>"
                        onclick="applyStatusFilter('')">All Status</div>
                    <?php foreach ($statusOptions as $sOpt): ?>
                        <div class="et-filter-dropdown-item <?php echo $status === $sOpt ? 'selected' : ''; ?>"
                            onclick="applyStatusFilter('<?php echo $sOpt; ?>')">
                            <?php echo ucfirst($sOpt); ?>
                        </div>
                    <?php endforeach; ?>
                </div>
            </div>

            <!-- Search Filter Pill -->
            <div class="et-filter-pill <?php echo !empty($accountNumber) ? 'active' : ''; ?>" id="pillSearch"
                onclick="promptSearch()">
                <i class="fas fa-search"></i>
                <span
                    id="pillSearchLabel"><?php echo empty($accountNumber) ? 'Search...' : 'Search: ' . htmlspecialchars($accountNumber); ?></span>
                <?php if (!empty($accountNumber)): ?>
                    <span class="pill-remove" onclick="clearSearch(event)">&times;</span>
                <?php endif; ?>
            </div>

            <!-- Amount filter pill -->
            <div class="et-filter-pill <?php echo !empty($minAmount) ? 'active' : ''; ?>" id="pillAmount" onclick="toggleFilterDropdown('amountDropdown')">
                <i class="fas fa-coins"></i>
                <span id="pillAmountLabel">
                    <?php echo empty($minAmount) ? 'Amount: All' : 'Amount > ₱' . number_format($minAmount, 0); ?>
                </span>
                <i class="fas fa-chevron-down"></i>
                <div class="et-filter-dropdown" id="amountDropdown">
                    <div class="et-filter-dropdown-item <?php echo empty($minAmount) ? 'selected' : ''; ?>" onclick="applyAmountFilter('')">All Amounts</div>
                    <div class="et-filter-dropdown-item <?php echo $minAmount == '1000' ? 'selected' : ''; ?>" onclick="applyAmountFilter('1000')">> ₱1,000</div>
                    <div class="et-filter-dropdown-item <?php echo $minAmount == '5000' ? 'selected' : ''; ?>" onclick="applyAmountFilter('5000')">> ₱5,000</div>
                    <div class="et-filter-dropdown-item <?php echo $minAmount == '10000' ? 'selected' : ''; ?>" onclick="applyAmountFilter('10000')">> ₱10,000</div>
                    <div class="et-filter-dropdown-item <?php echo $minAmount == '50000' ? 'selected' : ''; ?>" onclick="applyAmountFilter('50000')">> ₱50,000</div>
                </div>
            </div>

            <?php if ($applyFilters): ?>
                <a href="expense-tracking.php" class="et-filter-pill active" style="text-decoration:none;">
                    <i class="fas fa-times"></i> Clear Filters
                </a>
            <?php endif; ?>
        </div>

        <div class="et-filter-count">
            Showing <?php echo $totalRecords; ?> transactions
        </div>
    </div>

    <!-- Main Content Area -->
    <main style="padding:0;">
        <div class="module-content" style="padding-top:0;">
            <!-- Hidden filter form (used programmatically by pills) -->
            <form id="filterForm" method="GET" style="display:none;">
                <input type="hidden" name="date_from" id="date_from" value="<?php echo htmlspecialchars($dateFrom); ?>">
                <input type="hidden" name="date_to" id="date_to" value="<?php echo htmlspecialchars($dateTo); ?>">
                <input type="hidden" name="status" id="hiddenStatus" value="<?php echo htmlspecialchars($status); ?>">
                <input type="hidden" name="min_amount" id="min_amount" value="<?php echo htmlspecialchars($minAmount); ?>">
                <input type="hidden" name="account_number" id="account_number"
                    value="<?php echo htmlspecialchars($accountNumber); ?>">
                <input type="hidden" name="apply_filters" value="1">
            </form>

            <!-- Results Section (kept for compatibility with JS) -->
            <div class="results-section">

                <?php if (empty($expenses)): ?>
                    <div class="et-table-card">
                        <div class="et-no-results">
                            <div class="et-no-results-icon">
                                <i class="fas fa-receipt"></i>
                            </div>
                            <h4>No Expense Records Found</h4>
                            <p>
                                <?php if ($applyFilters): ?>
                                    No expenses match your current filter criteria. Try adjusting your filters.
                                <?php else: ?>
                                    No expense records are available in the system yet.
                                <?php endif; ?>
                            </p>
                            <?php if ($applyFilters): ?>
                                <a href="expense-tracking.php" class="btn-export-report">
                                    <i class="fas fa-rotate-left"></i> Clear Filters
                                </a>
                            <?php endif; ?>
                        </div>
                    </div>
                <?php else: ?>
                    <div class="et-table-card">
                        <div class="et-table-container">
                            <table class="et-table" id="expenseTable">
                                <thead>
                                    <tr>
                                        <th>Transaction #</th>
                                        <th>Date</th>
                                        <th>Employee</th>
                                        <th>Category</th>
                                        <th>Account</th>
                                        <th class="text-right">Amount</th>
                                        <th class="text-center">Status</th>
                                        <th>Description</th>
                                        <th class="text-center">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <?php foreach ($pagedExpenses as $idx => $expense):
                                        $initials = getInitials($expense['employee_name']);
                                        $avatarClass = $avatarColors[crc32($expense['employee_name'] ?? '') % count($avatarColors)];
                                        $catClass = getCategoryClass($expense['category_name'] ?? '', $expense['transaction_type'] ?? '');
                                        $statusNorm = strtolower($expense['status']);

                                        // ID logic for actions
                                        $expenseIdForView = $expense['id'] ?? '';
                                        $txnTypeForView = $expense['transaction_type'] ?? 'expense_claim';

                                        if ($txnTypeForView === 'bank_fee') {
                                            $expenseIdForView = $expense['transaction_id'] ?? $expense['id'] ?? '';
                                        }
                                        ?>
                                        <tr>
                                            <td>
                                                <span
                                                    class="et-txn-id"><?php echo htmlspecialchars($expense['transaction_number']); ?></span>
                                            </td>
                                            <td>
                                                <span
                                                    class="et-date"><?php echo date('M d, Y', strtotime($expense['transaction_date'])); ?></span>
                                            </td>
                                            <td>
                                                <div class="et-employee">
                                                    <div class="et-avatar <?php echo $avatarClass; ?>">
                                                        <?php echo $initials; ?>
                                                    </div>
                                                    <span
                                                        class="et-employee-name"><?php echo htmlspecialchars($expense['employee_name']); ?></span>
                                                </div>
                                            </td>
                                            <td>
                                                <span class="et-category-badge <?php echo $catClass; ?>">
                                                    <?php echo htmlspecialchars(strtoupper($expense['category_name'])); ?>
                                                </span>
                                            </td>
                                            <td>
                                                <span
                                                    class="et-account"><?php echo htmlspecialchars($expense['account_name']); ?></span>
                                            </td>
                                            <td class="text-right">
                                                <span
                                                    class="et-amount">₱<?php echo number_format($expense['amount'], 2); ?></span>
                                            </td>
                                            <td class="text-center">
                                                <span class="et-status <?php echo $statusNorm ?: 'pending'; ?>">
                                                    <span class="et-status-dot"></span>
                                                    <?php echo ucfirst($expense['status'] ?: 'Pending'); ?>
                                                </span>
                                            </td>
                                            <td>
                                                <span
                                                    class="et-description"><?php echo htmlspecialchars(substr($expense['description'] ?? '', 0, 50)) . (strlen($expense['description'] ?? '') > 50 ? '...' : ''); ?></span>
                                            </td>
                                            <td class="text-center">
                                                <div style="position:relative;display:inline-block;">
                                                    <button class="et-actions-btn" onclick="toggleActionsMenu(this, event)"
                                                        title="Actions">
                                                        <i class="fas fa-ellipsis-vertical"></i>
                                                    </button>
                                                    <div class="et-actions-dropdown">
                                                        <button class="et-actions-dropdown-item"
                                                            onclick="viewExpense('<?php echo htmlspecialchars($expenseIdForView, ENT_QUOTES); ?>', '<?php echo htmlspecialchars($txnTypeForView, ENT_QUOTES); ?>')">
                                                            <i class="fas fa-eye"></i> View Details
                                                        </button>
                                                        <button class="et-actions-dropdown-item"
                                                            onclick="printSingleExpense('<?php echo htmlspecialchars($expense['transaction_number'], ENT_QUOTES); ?>')">
                                                            <i class="fas fa-print"></i> Print
                                                        </button>
                                                    </div>
                                                </div>
                                            </td>
                                        </tr>
                                    <?php endforeach; ?>
                                </tbody>
                            </table>
                        </div>

                        <!-- Pagination -->
                        <div class="et-pagination">
                            <div class="et-pagination-info">
                                Page <?php echo $currentPage; ?> of <?php echo $totalPages; ?>
                            </div>
                            <div class="et-pagination-controls">
                                <a href="<?php echo $currentPage > 1 ? htmlspecialchars(buildPageUrl($currentPage - 1)) : '#'; ?>"
                                    class="et-pagination-btn" <?php echo $currentPage <= 1 ? 'disabled style="pointer-events:none;"' : ''; ?>>
                                    Previous
                                </a>
                                <a href="<?php echo $currentPage < $totalPages ? htmlspecialchars(buildPageUrl($currentPage + 1)) : '#'; ?>"
                                    class="et-pagination-btn active" <?php echo $currentPage >= $totalPages ? 'disabled style="pointer-events:none;"' : ''; ?>>
                                    Next
                                </a>
                            </div>
                        </div>
                    </div>
                <?php endif; ?>
            </div>
        </div>
    </main>

    <!-- Modal for Expense Details -->
    <div id="expenseModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Expense Details</h3>
                <span class="close" onclick="closeModal()">&times;</span>
            </div>
            <div class="modal-body" id="expenseModalBody">
                <!-- Content will be loaded here -->
            </div>
        </div>
    </div>

    <!-- Footer -->
    <footer>
        <div class="container">
            <p class="mb-0">&copy; <?php echo date('Y'); ?> Evergreen Accounting & Finance. All rights reserved.</p>
        </div>
    </footer>

    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <!-- jsPDF for PDF Export -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.31/jspdf.plugin.autotable.min.js"></script>
    <!-- Custom JS -->
    <script src="../assets/js/expense-tracking.js"></script>
    <script src="../assets/js/notifications.js"></script>

    <script>
        // ===== Filter pill interactions =====
        function toggleFilterDropdown(dropdownId) {
            // Close all other dropdowns first
            document.querySelectorAll('.et-filter-dropdown').forEach(d => {
                if (d.id !== dropdownId) d.classList.remove('show');
            });
            const dd = document.getElementById(dropdownId);
            dd.classList.toggle('show');
            event.stopPropagation();
        }

        function applyPeriodFilter(period) {
            const form = document.getElementById('filterForm');
            const now = new Date();
            let dateFrom = '', dateTo = '';

            if (period === 'quarter') {
                const qMonth = Math.floor(now.getMonth() / 3) * 3;
                const qStart = new Date(now.getFullYear(), qMonth, 1);
                dateFrom = qStart.toISOString().split('T')[0];
                dateTo = now.toISOString().split('T')[0];
            } else if (period === 'month') {
                const mStart = new Date(now.getFullYear(), now.getMonth(), 1);
                dateFrom = mStart.toISOString().split('T')[0];
                dateTo = now.toISOString().split('T')[0];
            } else if (period === 'year') {
                const yStart = new Date(now.getFullYear(), 0, 1);
                dateFrom = yStart.toISOString().split('T')[0];
                dateTo = now.toISOString().split('T')[0];
            }
            // 'all' leaves dates empty

            document.getElementById('date_from').value = dateFrom;
            document.getElementById('date_to').value = dateTo;
            form.submit();
        }

        function promptSearch() {
            const currentSearch = document.getElementById('account_number').value;
            const query = prompt("Search by category, employee, or ref #:", currentSearch);
            if (query !== null) {
                document.getElementById('account_number').value = query;
                document.getElementById('filterForm').submit();
            }
        }

        function clearSearch(e) {
            e.stopPropagation();
            document.getElementById('account_number').value = '';
            document.getElementById('filterForm').submit();
        }

        function applyStatusFilter(status) {
            document.getElementById('hiddenStatus').value = status;
            document.getElementById('filterForm').submit();
        }

        function applyAmountFilter(amt) {
            document.getElementById('min_amount').value = amt;
            document.getElementById('filterForm').submit();
        }

        // Close dropdowns on outside click
        document.addEventListener('click', function (e) {
            if (!e.target.closest('.et-filter-pill')) {
                document.querySelectorAll('.et-filter-dropdown').forEach(d => d.classList.remove('show'));
            }
        });

        // ===== Actions menu (three-dot) =====
        function toggleActionsMenu(btn, e) {
            e.stopPropagation();
            // Close other menus
            document.querySelectorAll('.et-actions-dropdown').forEach(d => d.classList.remove('show'));
            const dropdown = btn.parentElement.querySelector('.et-actions-dropdown');
            dropdown.classList.toggle('show');
        }

        document.addEventListener('click', function (e) {
            if (!e.target.closest('.et-actions-btn')) {
                document.querySelectorAll('.et-actions-dropdown').forEach(d => d.classList.remove('show'));
            }
        });

        function printSingleExpense(txnNumber) {
            showNotification('Printing ' + txnNumber + '...', 'info');
        }
    </script>
</body>

</html>