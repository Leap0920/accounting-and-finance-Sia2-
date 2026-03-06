<?php
require_once '../config/database.php';
require_once '../includes/session.php';

requireLogin();
$current_user = getCurrentUser();

// Ensure soft delete columns exist in loans table
function ensureSoftDeleteColumnsExist($conn)
{
    try {
        // Check if deleted_at column exists
        $checkSql = "SHOW COLUMNS FROM loans LIKE 'deleted_at'";
        $result = $conn->query($checkSql);

        if (!$result || $result->num_rows === 0) {
            // Add deleted_at column
            $alterSql = "ALTER TABLE loans ADD COLUMN deleted_at DATETIME NULL DEFAULT NULL";
            if (!$conn->query($alterSql)) {
                error_log("Failed to add deleted_at column: " . $conn->error);
            }
        }

        // Check if deleted_by column exists
        $checkSql = "SHOW COLUMNS FROM loans LIKE 'deleted_by'";
        $result = $conn->query($checkSql);

        if (!$result || $result->num_rows === 0) {
            // Add deleted_by column
            $alterSql = "ALTER TABLE loans ADD COLUMN deleted_by INT NULL DEFAULT NULL";
            if (!$conn->query($alterSql)) {
                error_log("Failed to add deleted_by column: " . $conn->error);
            }
        }
    } catch (Exception $e) {
        error_log("Error ensuring soft delete columns exist: " . $e->getMessage());
    }
}

// Ensure soft delete columns exist in loan_applications table
function ensureApplicationSoftDeleteColumnsExist($conn)
{
    try {
        // Check if deleted_at column exists
        $checkSql = "SHOW COLUMNS FROM loan_applications LIKE 'deleted_at'";
        $result = $conn->query($checkSql);

        if (!$result || $result->num_rows === 0) {
            // Add deleted_at column
            $alterSql = "ALTER TABLE loan_applications ADD COLUMN deleted_at DATETIME NULL DEFAULT NULL";
            if (!$conn->query($alterSql)) {
                error_log("Failed to add deleted_at column to loan_applications: " . $conn->error);
            }
        }

        // Check if deleted_by column exists
        $checkSql = "SHOW COLUMNS FROM loan_applications LIKE 'deleted_by'";
        $result = $conn->query($checkSql);

        if (!$result || $result->num_rows === 0) {
            // Add deleted_by column
            $alterSql = "ALTER TABLE loan_applications ADD COLUMN deleted_by INT NULL DEFAULT NULL";
            if (!$conn->query($alterSql)) {
                error_log("Failed to add deleted_by column to loan_applications: " . $conn->error);
            }
        }
    } catch (Exception $e) {
        error_log("Error ensuring soft delete columns exist for loan_applications: " . $e->getMessage());
    }
}

// Ensure columns exist before querying
ensureSoftDeleteColumnsExist($conn);
ensureApplicationSoftDeleteColumnsExist($conn);

// Check if deleted_at column exists in loan_applications
$hasAppDeletedAtColumn = false;
try {
    $checkResult = $conn->query("SHOW COLUMNS FROM loan_applications LIKE 'deleted_at'");
    $hasAppDeletedAtColumn = $checkResult && $checkResult->num_rows > 0;
} catch (Exception $e) {
    $hasAppDeletedAtColumn = false;
}

// Get filter parameters
$dateFrom = $_GET['date_from'] ?? '';
$dateTo = $_GET['date_to'] ?? '';
$transactionType = $_GET['transaction_type'] ?? '';
$status = $_GET['status'] ?? '';
$accountNumber = $_GET['account_number'] ?? '';
$applyFilters = isset($_GET['apply_filters']);

// Build query to combine both loans and loan_applications
// This ensures loan applications from the loan subsystem are visible in loan-accounting
// Show only applications for now (since loans table might be empty)
// Set to false to include both loans and applications
// Build query to combine both loans and loan_applications
$showOnlyApplications = false;

// Initial base queries without filters
$loansBaseSql = "SELECT 
        l.id,
        l.loan_no as loan_number,
        l.borrower_external_no as borrower_name,
        l.principal_amount as loan_amount,
        COALESCE(l.interest_rate * 100, COALESCE(lt.interest_rate * 100, 20.00)) as interest_rate,
        l.term_months as loan_term,
        l.start_date,
        DATE_ADD(l.start_date, INTERVAL l.term_months MONTH) as maturity_date,
        l.current_balance as outstanding_balance,
        l.status,
        'loan' as record_type,
        lt.name as loan_type_name,
        NULL as account_number,
        l.created_at,
        u.full_name as created_by_name,
        NULL as contact_number,
        NULL as email,
        NULL as job,
        NULL as monthly_salary,
        NULL as user_email,
        NULL as purpose,
        l.monthly_payment,
        NULL as due_date,
        NULL as next_payment_due,
        NULL as approved_by,
        NULL as approved_at,
        NULL as rejected_by,
        NULL as rejected_at,
        NULL as rejection_remarks,
        NULL as remarks,
        NULL as file_name,
        NULL as proof_of_income,
        NULL as coe_document,
        NULL as pdf_path,
        NULL as application_id
    FROM loans l
    LEFT JOIN loan_types lt ON l.loan_type_id = lt.id
    LEFT JOIN users u ON l.created_by = u.id
    WHERE (l.deleted_at IS NULL OR l.deleted_at = '') 
      AND l.status != 'cancelled'";

$appsBaseSql = "SELECT 
        la.id + 1000000 as id,
        CONCAT('APP-', la.id) as loan_number,
        COALESCE(la.full_name, la.user_email) as borrower_name,
        COALESCE(la.loan_amount, 0) as loan_amount,
        COALESCE(lt_app.interest_rate * 100, 20.00) as interest_rate,
        CASE 
            WHEN la.loan_terms LIKE '%6%' OR la.loan_terms LIKE '%6 Months%' THEN 6
            WHEN la.loan_terms LIKE '%12%' OR la.loan_terms LIKE '%12 Months%' THEN 12
            WHEN la.loan_terms LIKE '%24%' OR la.loan_terms LIKE '%24 Months%' THEN 24
            WHEN la.loan_terms LIKE '%30%' OR la.loan_terms LIKE '%30 Months%' THEN 30
            WHEN la.loan_terms LIKE '%36%' OR la.loan_terms LIKE '%36 Months%' THEN 36
            ELSE 0
        END as loan_term,
        la.created_at as start_date,
        la.due_date as maturity_date,
        CASE 
            WHEN la.loan_id IS NOT NULL THEN 
                COALESCE(la.loan_amount, 0.00) - COALESCE((
                    SELECT SUM(lp.principal_amount) 
                    FROM loan_payments lp 
                    WHERE lp.loan_id = la.loan_id
                ), 0.00)
            WHEN LOWER(la.status) IN ('approved', 'active') THEN COALESCE(la.loan_amount, 0.00)
            ELSE 0.00
        END as outstanding_balance,
        la.status,
        'application' as record_type,
        COALESCE(lt_app.name, la.loan_type, 'N/A') as loan_type_name,
        la.account_number,
        la.created_at,
        COALESCE(u_app.full_name, la.approved_by) as created_by_name,
        la.contact_number,
        la.email,
        la.job,
        la.monthly_salary,
        la.user_email,
        la.purpose,
        la.monthly_payment,
        la.due_date,
        la.next_payment_due,
        la.approved_by,
        la.approved_at,
        la.rejected_by,
        la.rejected_at,
        la.rejection_remarks,
        la.remarks,
        la.file_name,
        la.proof_of_income,
        la.coe_document,
        la.pdf_path,
        la.id as application_id
    FROM loan_applications la
    LEFT JOIN loan_types lt_app ON la.loan_type_id = lt_app.id
    LEFT JOIN users u_app ON la.approved_by_user_id = u_app.id
    " . ($hasAppDeletedAtColumn ? "WHERE (la.deleted_at IS NULL OR la.deleted_at = '')" : "WHERE 1=1");

// Combine into UNION
$combinedSql = "($loansBaseSql) UNION ALL ($appsBaseSql)";

// Wrap and Apply Global Filters
$whereConditions = [];
$params = [];
$types = '';

if ($applyFilters) {
    if (!empty($dateFrom)) {
        $whereConditions[] = "start_date >= ?";
        $params[] = $dateFrom;
        $types .= 's';
    }
    if (!empty($dateTo)) {
        $whereConditions[] = "start_date <= ?";
        $params[] = $dateTo . ' 23:59:59';
        $types .= 's';
    }
    if (!empty($status)) {
        $whereConditions[] = "LOWER(status) = ?";
        $params[] = strtolower($status);
        $types .= 's';
    }
    if (!empty($accountNumber)) {
        $whereConditions[] = "(loan_number LIKE ? OR borrower_name LIKE ? OR account_number LIKE ?)";
        $searchTerm = "%{$accountNumber}%";
        $params[] = $searchTerm;
        $params[] = $searchTerm;
        $params[] = $searchTerm;
        $types .= 'sss';
    }
}

$whereClause = !empty($whereConditions) ? "WHERE " . implode(" AND ", $whereConditions) : "";
$sql = "SELECT * FROM ($combinedSql) AS combined_results $whereClause ORDER BY start_date DESC, loan_number DESC";


// Execute query with fallback
$loans = [];
$hasResults = false;
$queryError = null;

// Debug: Log the query
error_log("Loan Accounting Query: " . $sql);

if ($conn) {
    // Try the UNION query first
    $stmt = $conn->prepare($sql);

    if ($stmt === false) {
        // Query preparation failed - try simple loans query as fallback
        $queryError = $conn->error;
        error_log("Query preparation failed: " . $queryError);
        // Try a simple loan_applications query as fallback
        $fallbackSql = "SELECT 
            la.id,
            CONCAT('APP-', la.id) as loan_number,
            la.full_name as borrower_name,
            la.loan_amount,
            COALESCE(lt.interest_rate * 100, 20.00) as interest_rate,
            0 as loan_term,
            la.created_at as start_date,
            la.due_date as maturity_date,
            CASE 
                WHEN la.loan_id IS NOT NULL THEN 
                    COALESCE(la.loan_amount, 0.00) - COALESCE((
                        SELECT SUM(lp.principal_amount) 
                        FROM loan_payments lp 
                        WHERE lp.loan_id = la.loan_id
                    ), 0.00)
                WHEN LOWER(la.status) IN ('approved', 'active') THEN COALESCE(la.loan_amount, 0.00)
                ELSE 0.00
            END as outstanding_balance,
            la.status,
            'application' as record_type,
            COALESCE(lt.name, la.loan_type, 'N/A') as loan_type_name,
            la.account_number,
            la.created_at,
            la.approved_by as created_by_name,
            la.contact_number,
            la.email,
            la.job,
            la.monthly_salary,
            la.user_email,
            la.purpose,
            la.monthly_payment,
            la.due_date,
            la.next_payment_due,
            la.approved_by,
            la.approved_at,
            la.rejected_by,
            la.rejected_at,
            la.rejection_remarks,
            la.remarks,
            la.file_name,
            la.proof_of_income,
            la.coe_document,
            la.pdf_path,
            la.id as application_id
        FROM loan_applications la
        LEFT JOIN loan_types lt ON la.loan_type_id = lt.id
        ORDER BY la.id DESC";

        $stmt = $conn->prepare($fallbackSql);
        if ($stmt && $stmt->execute()) {
            $result = $stmt->get_result();
            while ($row = $result->fetch_assoc()) {
                $loans[] = $row;
            }
            $hasResults = count($loans) > 0;
            $queryError = null; // Clear error if fallback worked
            error_log("Fallback query found " . count($loans) . " loan applications");
        } else {
            error_log("Fallback query also failed: " . ($stmt ? $stmt->error : $conn->error));
        }
        if ($stmt)
            $stmt->close();
    } else {
        if (!empty($params)) {
            $stmt->bind_param($types, ...$params);
        }

        if ($stmt->execute()) {
            $result = $stmt->get_result();

            while ($row = $result->fetch_assoc()) {
                $loans[] = $row;
            }

            $hasResults = count($loans) > 0;
            error_log("Loan Accounting: Found " . count($loans) . " loans/applications");
        } else {
            // Execution failed
            $queryError = $stmt->error;
            error_log("Query execution failed: " . $queryError);
        }

        $stmt->close();
    }
}

// Calculate statistics based on filtered results
// This automatically adjusts when filters are applied since $loans array contains only filtered records
$totalLoans = count($loans); // Total count of filtered records
$totalApplications = 0;
$totalAmount = 0;
$totalOutstanding = 0;
$activeLoans = 0;
$pendingApplications = 0;
$actualLoanCount = 0; // Actual loans (not applications)

// Calculate statistics from filtered results
foreach ($loans as $loan) {
    $loanStatus = strtolower($loan['status'] ?? '');
    $loanAmount = floatval($loan['loan_amount'] ?? 0);
    $outstandingBalance = floatval($loan['outstanding_balance'] ?? 0);

    // Add to total amount
    $totalAmount += $loanAmount;

    if ($loan['record_type'] === 'loan') {
        // This is an actual loan record
        $actualLoanCount++;
        $totalOutstanding += $outstandingBalance;
        if ($loanStatus === 'active') {
            $activeLoans++;
        }
    } else {
        // This is an application
        $totalApplications++;

        // Count pending applications
        if ($loanStatus === 'pending') {
            $pendingApplications++;
        }

        // Count approved/active applications as active loans
        if (in_array($loanStatus, ['approved', 'active'])) {
            $activeLoans++;
            // Add outstanding balance for approved/active applications only
            $totalOutstanding += $outstandingBalance;
        }
    }
}

// Since showOnlyApplications is true, all records are applications
// Ensure statistics are accurate for applications mode with filtered data
if ($showOnlyApplications) {
    // All records are applications
    $totalApplications = count($loans);

    // Recalculate statistics from filtered results to ensure accuracy
    // This ensures statistics automatically adjust based on active filters
    $pendingApplications = 0;
    $activeLoans = 0;
    $totalOutstanding = 0;

    foreach ($loans as $loan) {
        $loanStatus = strtolower($loan['status'] ?? '');

        // Count pending applications (from filtered results)
        if ($loanStatus === 'pending') {
            $pendingApplications++;
        }

        // Count approved/active applications as active loans (from filtered results)
        if (in_array($loanStatus, ['approved', 'active'])) {
            $activeLoans++;
            // Add outstanding balance for approved/active applications only
            $totalOutstanding += floatval($loan['outstanding_balance'] ?? 0);
        }
    }
}

// Determine dynamic labels based on selected status filter
$statusLabel = '';
$applicationsLabel = 'Loan Applications';
$activeLoansLabel = 'Active Loans';

if (!empty($status) && $applyFilters) {
    $statusLower = strtolower($status);
    switch ($statusLower) {
        case 'pending':
            $statusLabel = 'Pending';
            $applicationsLabel = 'Total Records';
            $activeLoansLabel = 'Pending Loans';
            break;
        case 'approved':
            $statusLabel = 'Approved';
            $applicationsLabel = 'Total Records';
            $activeLoansLabel = 'Approved Loans';
            break;
        case 'active':
            $statusLabel = 'Active';
            $applicationsLabel = 'Total Records';
            $activeLoansLabel = 'Active Loans';
            break;
        case 'rejected':
            $statusLabel = 'Rejected';
            $applicationsLabel = 'Total Records';
            $activeLoansLabel = 'Rejected Loans';
            break;
        case 'paid':
            $statusLabel = 'Paid';
            $applicationsLabel = 'Total Records';
            $activeLoansLabel = 'Paid Loans';
            break;
        case 'defaulted':
            $statusLabel = 'Defaulted';
            $applicationsLabel = 'Total Records';
            $activeLoansLabel = 'Defaulted Loans';
            break;
        case 'cancelled':
            $statusLabel = 'Cancelled';
            $applicationsLabel = 'Total Records';
            $activeLoansLabel = 'Cancelled Loans';
            break;
        default:
            $statusLabel = ucfirst($status);
            $applicationsLabel = 'Total Records';
            $activeLoansLabel = ucfirst($status) . ' Loans';
            break;
    }
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Loan Accounting - Accounting and Finance System</title>
    <!-- Favicon -->
    <link rel="icon" type="image/png" href="../assets/image/LOGO.png">
    <link rel="shortcut icon" type="image/png" href="../assets/image/LOGO.png">
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <!-- DataTables CSS -->
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.7/css/dataTables.bootstrap5.min.css">
    <!-- Custom CSS -->
    <link rel="stylesheet" href="../assets/css/style.css">
    <link rel="stylesheet" href="../assets/css/dashboard.css">
    <link rel="stylesheet" href="../assets/css/loan-accounting.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- html2pdf -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
    <style>
        .ln-page {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: #f8f9fa;
            min-height: 100vh;
        }

        .ln-container {
            width: 100%;
            max-width: 1600px;
            margin: 0 auto;
            padding: 24px 32px;
        }

        /* Header */
        .ln-header {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            margin-bottom: 28px;
        }

        .ln-header__title {
            font-size: 28px;
            font-weight: 800;
            color: #111827;
            margin: 0;
            letter-spacing: -0.5px;
        }

        .ln-header__subtitle {
            font-size: 14px;
            color: #6b7280;
            margin-top: 4px;
        }

        .ln-btn-export {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 22px;
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

        .ln-btn-export:hover {
            background: #f9fafb;
            border-color: #9ca3af;
            color: #374151;
        }

        /* Stat Cards */
        .ln-stats {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 28px;
        }

        .ln-stat-card {
            background: #fff;
            border: 1px solid #e5e7eb;
            border-radius: 14px;
            padding: 20px 24px;
            position: relative;
        }

        .ln-stat-card__top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 12px;
        }

        .ln-stat-card__label {
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: #6b7280;
        }

        .ln-stat-card__icon {
            width: 36px;
            height: 36px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
        }

        .ln-stat-card__icon--total {
            background: #1e3a5f;
            color: #fff;
        }

        .ln-stat-card__icon--apps {
            background: #f59e0b;
            color: #fff;
        }

        .ln-stat-card__icon--active {
            background: #059669;
            color: #fff;
        }

        .ln-stat-card__icon--outstanding {
            background: #1e3a5f;
            color: #fff;
        }

        .ln-stat-card__value {
            font-size: 32px;
            font-weight: 800;
            color: #111827;
            letter-spacing: -1px;
            margin-bottom: 6px;
        }

        .ln-stat-card__trend {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            font-size: 12px;
            font-weight: 500;
        }

        .ln-stat-card__trend--up {
            color: #059669;
        }

        .ln-stat-card__trend--down {
            color: #dc2626;
        }

        .ln-stat-card__trend span {
            color: #9ca3af;
            font-weight: 400;
        }

        /* Table Section */
        .ln-table-section {
            background: #fff;
            border: 1px solid #e5e7eb;
            border-radius: 14px;
            overflow: hidden;
        }

        /* Table wrapper to prevent horizontal scroll */
        .ln-table-wrapper {
            width: 100%;
            overflow-x: auto;
            overflow-y: visible;
        }

        /* Hide scrollbar but keep functionality */
        .ln-table-wrapper::-webkit-scrollbar {
            height: 0px;
            background: transparent;
        }

        .ln-table-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 20px 24px 16px;
        }

        .ln-table-header__title {
            font-size: 20px;
            font-weight: 700;
            color: #111827;
        }

        .ln-table-header__filters {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .ln-filter-select {
            padding: 7px 14px;
            padding-right: 30px;
            background: #fff;
            border: 1.5px solid #e5e7eb;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 500;
            color: #374151;
            cursor: pointer;
            appearance: none;
            -webkit-appearance: none;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%236b7280' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 10px center;
        }

        .ln-filter-select:focus {
            outline: none;
            border-color: #1a3c3c;
        }

        .ln-filter-date {
            padding: 7px 14px;
            background: #fff;
            border: 1.5px solid #e5e7eb;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 500;
            color: #374151;
            cursor: pointer;
        }

        .ln-search-bar {
            padding: 0 24px 16px;
        }

        .ln-search-bar input {
            width: 100%;
            padding: 10px 16px 10px 42px;
            background: #f9fafb;
            border: 1.5px solid #e5e7eb;
            border-radius: 10px;
            font-size: 14px;
            color: #374151;
            transition: all 0.2s;
        }

        .ln-search-bar input:focus {
            outline: none;
            border-color: #1a3c3c;
            background: #fff;
            box-shadow: 0 0 0 3px rgba(26, 60, 60, 0.08);
        }

        .ln-search-bar__wrap {
            position: relative;
        }

        .ln-search-bar__wrap i {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            color: #9ca3af;
            font-size: 14px;
        }

        /* Main Table */
        .ln-table {
            width: 100%;
            border-collapse: collapse;
            table-layout: auto;
            font-size: 13px;
        }

        /* Override DataTables if it wraps our table */
        #loanTable_wrapper .row:first-child,
        #loanTable_wrapper .row:last-child {
            display: none !important;
        }

        .ln-table thead th {
            padding: 14px 10px !important;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: #6b7280;
            border-bottom: 2px solid #f3f4f6 !important;
            background: #fafafa !important;
            background-image: none !important;
            white-space: nowrap;
            text-align: left;
        }

        .ln-table tbody tr {
            border-bottom: 1px solid #f3f4f6;
            transition: background 0.1s;
        }

        .ln-table tbody tr:hover {
            background: #f9fafb;
        }

        .ln-table tbody td {
            padding: 16px 10px;
            font-size: 13px;
            color: #374151;
            vertical-align: middle;
        }

        /* Specific alignment Column styling */
        .ln-table .col-amount,
        .ln-table .col-monthly,
        .ln-table .col-outstanding {
            text-align: right;
            font-weight: 600;
            font-variant-numeric: tabular-nums;
        }

        .ln-table .col-rate,
        .ln-table .col-type,
        .ln-table .col-status,
        .ln-table .col-action {
            text-align: center;
        }

        .ln-table .journal-no {
            font-weight: 700;
            color: #111827;
            font-size: 11px;
            /* Smaller font */
        }

        .ln-table .date-cell {
            color: #6b7280;
            font-size: 11px;
            /* Smaller font */
        }

        .ln-table .amount-cell {
            font-weight: 600;
            font-variant-numeric: tabular-nums;
            font-size: 11px;
            /* Smaller font */
            text-align: right;
            /* Right align amounts */
        }

        /* Center align specific columns */
        .ln-table .col-rate,
        .ln-table .col-type,
        .ln-table .col-status,
        .ln-table .col-action {
            text-align: center;
        }

        /* Right align amount columns */
        .ln-table .col-amount,
        .ln-table .col-monthly,
        .ln-table .col-outstanding {
            text-align: right;
        }

        /* Borrower avatar - compact version */
        .ln-borrower {
            display: flex;
            align-items: center;
            gap: 6px;
            /* Reduced gap */
        }

        .ln-avatar {
            width: 26px;
            /* Smaller avatar */
            height: 26px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 9px;
            /* Smaller font */
            font-weight: 700;
            color: #fff;
            flex-shrink: 0;
        }

        .ln-avatar--1 {
            background: #6b7280;
        }

        .ln-avatar--2 {
            background: #059669;
        }

        .ln-avatar--3 {
            background: #dc2626;
        }

        .ln-avatar--4 {
            background: #f59e0b;
        }

        .ln-avatar--5 {
            background: #6366f1;
        }

        .ln-avatar--6 {
            background: #1e3a5f;
        }

        .ln-borrower__name {
            font-weight: 500;
            color: #111827;
            font-size: 12px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            max-width: 120px;
            /* Limit name width */
        }

        /* Type badge - compact */
        .ln-type-badge {
            padding: 2px 6px;
            /* Smaller padding */
            border-radius: 4px;
            font-size: 9px;
            /* Smaller font */
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.2px;
            display: inline-block;
        }

        .ln-type-badge--app {
            background: #dbeafe;
            color: #1d4ed8;
        }

        .ln-type-badge--loan {
            background: #dcfce7;
            color: #15803d;
        }

        /* Status badges - compact */
        .ln-status {
            padding: 3px 8px;
            /* Smaller padding */
            border-radius: 20px;
            font-size: 10px;
            /* Smaller font */
            font-weight: 600;
            display: inline-block;
            text-align: center;
            min-width: 60px;
            /* Ensure consistent width */
        }

        .ln-status--approved {
            background: #dcfce7;
            color: #15803d;
        }

        .ln-status--pending {
            background: #fff7ed;
            color: #ea580c;
        }

        .ln-status--active {
            background: #dbeafe;
            color: #1d4ed8;
        }

        .ln-status--rejected {
            background: #fef2f2;
            color: #dc2626;
        }

        .ln-status--defaulted {
            background: #fef2f2;
            color: #dc2626;
        }

        .ln-status--paid {
            background: #ecfdf5;
            color: #059669;
        }

        .ln-status--cancelled {
            background: #f3f4f6;
            color: #6b7280;
        }

        /* Action buttons - compact */
        .ln-action-btn {
            width: 26px;
            /* Smaller buttons */
            height: 26px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background: transparent;
            border: none;
            border-radius: 6px;
            color: #9ca3af;
            cursor: pointer;
            transition: all 0.15s;
            font-size: 11px;
            /* Smaller icons */
            margin: 0 1px;
            /* Small margin between buttons */
        }

        .ln-action-btn:hover {
            background: #f3f4f6;
            color: #374151;
        }

        .ln-action-btn--danger:hover {
            background: #fef2f2;
            color: #dc2626;
        }

        /* Pagination */
        .ln-pagination {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 16px 24px;
            border-top: 1px solid #f3f4f6;
        }

        .ln-pagination__info {
            font-size: 13px;
            color: #059669;
            font-weight: 500;
        }

        .ln-pagination__pages {
            display: flex;
            align-items: center;
            gap: 4px;
        }

        .ln-page-btn {
            padding: 6px 12px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background: transparent;
            border: 1px solid #e5e7eb;
            border-radius: 6px;
            font-size: 13px;
            font-weight: 500;
            color: #6b7280;
            cursor: pointer;
            transition: all 0.15s;
        }

        .ln-page-btn:hover {
            background: #f3f4f6;
        }

        .ln-page-btn.active {
            background: #ea580c;
            color: #fff;
            border-color: #ea580c;
        }

        /* Empty state */
        .ln-empty {
            padding: 60px 20px;
            text-align: center;
        }

        .ln-empty__icon {
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

        .ln-empty__title {
            font-size: 15px;
            font-weight: 600;
            color: #374151;
            margin-bottom: 4px;
        }

        .ln-empty__text {
            font-size: 13px;
            color: #9ca3af;
        }

        /* Footer */
        .ln-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-top: 40px;
            padding: 20px 0;
            border-top: 1px solid #e5e7eb;
        }

        .ln-footer__left {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 13px;
            color: #9ca3af;
        }

        .ln-footer__left i {
            color: #22c55e;
        }

        .ln-footer__links {
            display: flex;
            gap: 24px;
        }

        .ln-footer__links a {
            font-size: 13px;
            color: #6b7280;
            text-decoration: none;
            transition: color 0.15s;
        }

        .ln-footer__links a:hover {
            color: #111827;
        }

        @media print {
            @page {
                size: landscape;
                margin: 0.5cm;
            }

            body * {
                visibility: hidden;
            }

            #loanReportArea,
            #loanReportArea * {
                visibility: visible;
            }

            #loanReportArea {
                position: absolute;
                left: 0;
                top: 0;
                width: 100%;
                margin: 0;
                padding: 0;
            }

            .ln-action-btn,
            .col-action,
            .ln-btn-export,
            .navbar,
            .ln-search-bar,
            .ln-table-header__filters,
            .ln-pagination {
                display: none !important;
            }

            .ln-container {
                max-width: none !important;
                padding: 0 !important;
                width: 100% !important;
            }

            .ln-table {
                font-size: 9pt !important;
                table-layout: auto !important;
            }

            .ln-table th,
            .ln-table td {
                padding: 4pt 2pt !important;
            }

            .ln-stat-card {
                break-inside: avoid;
                border: 1px solid #ddd !important;
                padding: 10pt !important;
            }

            .ln-page {
                background: white !important;
            }
        }

        .ln-table {
            font-size: 11px;
            /* Even smaller on medium screens */
        }

        .ln-table thead th {
            padding: 8px 4px;
            font-size: 8px;
        }

        .ln-table tbody td {
            padding: 10px 4px;
            font-size: 11px;
        }

        .ln-borrower__name {
            max-width: 100px;
        }
        }

        @media (max-width: 992px) {
            .ln-stats {
                grid-template-columns: repeat(2, 1fr);
            }

            .ln-table {
                font-size: 10px;
            }

            .ln-table thead th {
                padding: 6px 3px;
                font-size: 7px;
            }

            .ln-table tbody td {
                padding: 8px 3px;
                font-size: 10px;
            }

            .ln-borrower__name {
                max-width: 80px;
            }

            .ln-avatar {
                width: 22px;
                height: 22px;
                font-size: 8px;
            }
        }

        @media (max-width: 768px) {
            .ln-container {
                padding: 16px;
            }

            .ln-header {
                flex-direction: column;
                gap: 16px;
            }

            .ln-stats {
                grid-template-columns: 1fr;
            }

            .ln-table-header {
                flex-direction: column;
                gap: 12px;
                align-items: flex-start;
            }

            .ln-table-header__filters {
                flex-wrap: wrap;
            }

            .ln-pagination {
                flex-direction: column;
                gap: 12px;
            }

            .ln-footer {
                flex-direction: column;
                gap: 12px;
                text-align: center;
            }
        }
    </style>

<body>
    <!-- Navigation -->
    <?php include '../includes/navbar.php'; ?>

    <!-- Main Content -->
    <div class="ln-page">
        <div class="ln-container">
            <!-- Header -->
            <div class="ln-header">
                <div>
                    <h1 class="ln-header__title">Loan Management Dashboard</h1>
                    <p class="ln-header__subtitle">Real-time overview of your current loan portfolio and active
                        applications.</p>
                </div>
                <button class="ln-btn-export" onclick="exportToPDF()">
                    <i class="fas fa-file-pdf"></i> Export PDF
                </button>
            </div>

            <!-- Report Area (Target for PDF) -->
            <div id="loanReportArea">
                <div class="ln-stats">
                    <div class="ln-stat-card">
                        <div class="ln-stat-card__top">
                            <div class="ln-stat-card__label">Total Loans</div>
                            <div class="ln-stat-card__icon ln-stat-card__icon--total"><i
                                    class="fas fa-file-invoice-dollar"></i></div>
                        </div>
                        <div class="ln-stat-card__value"><?php echo number_format($totalLoans); ?></div>
                        <div class="ln-stat-card__trend ln-stat-card__trend--up">
                            <i class="fas fa-trending-up" style="font-size:11px;">↗</i> +12% <span>vs last month</span>
                        </div>
                    </div>
                    <div class="ln-stat-card">
                        <div class="ln-stat-card__top">
                            <div class="ln-stat-card__label"><?php echo htmlspecialchars($applicationsLabel); ?></div>
                            <div class="ln-stat-card__icon ln-stat-card__icon--apps"><i class="fas fa-file-alt"></i>
                            </div>
                        </div>
                        <div class="ln-stat-card__value">
                            ₱<?php echo $totalAmount >= 1000000 ? number_format($totalAmount / 1000000, 1) . 'M' : number_format($totalAmount); ?>
                        </div>
                        <div class="ln-stat-card__trend ln-stat-card__trend--up">
                            <i style="font-size:11px;">↗</i> +5% <span>vs last month</span>
                        </div>
                    </div>
                    <div class="ln-stat-card">
                        <div class="ln-stat-card__top">
                            <div class="ln-stat-card__label"><?php echo htmlspecialchars($activeLoansLabel); ?></div>
                            <div class="ln-stat-card__icon ln-stat-card__icon--active"><i
                                    class="fas fa-exchange-alt"></i>
                            </div>
                        </div>
                        <div class="ln-stat-card__value"><?php echo number_format($activeLoans); ?></div>
                        <div class="ln-stat-card__trend ln-stat-card__trend--down">
                            <i style="font-size:11px;">↘</i> -2% <span>vs last month</span>
                        </div>
                    </div>
                    <div class="ln-stat-card">
                        <div class="ln-stat-card__top">
                            <div class="ln-stat-card__label">Outstanding Balance</div>
                            <div class="ln-stat-card__icon ln-stat-card__icon--outstanding"><i
                                    class="fas fa-wallet"></i>
                            </div>
                        </div>
                        <div class="ln-stat-card__value">
                            ₱<?php echo $totalOutstanding >= 1000000 ? number_format($totalOutstanding / 1000000, 1) . 'M' : number_format($totalOutstanding); ?>
                        </div>
                        <div class="ln-stat-card__trend ln-stat-card__trend--up">
                            <i style="font-size:11px;">↗</i> +8% <span>vs last month</span>
                        </div>
                    </div>
                </div>

                <!-- Loan History Table Section -->
                <div class="ln-table-section">
                    <div class="ln-table-header">
                        <div class="ln-table-header__title">Loan History</div>
                        <div class="ln-table-header__filters">
                            <select class="ln-filter-select" id="filterStatus" onchange="applyInlineFilter()">
                                <option value="" <?php echo empty($status) ? 'selected' : ''; ?>>Status: All</option>
                                <option value="pending" <?php echo strtolower($status) === 'pending' ? 'selected' : ''; ?>>
                                    Pending</option>
                                <option value="Approved" <?php echo $status === 'Approved' ? 'selected' : ''; ?>>Approved
                                </option>
                                <option value="active" <?php echo strtolower($status) === 'active' ? 'selected' : ''; ?>>
                                    Active</option>
                                <option value="Rejected" <?php echo $status === 'Rejected' ? 'selected' : ''; ?>>Rejected
                                </option>
                                <option value="paid" <?php echo $status === 'paid' ? 'selected' : ''; ?>>Paid</option>
                                <option value="defaulted" <?php echo $status === 'defaulted' ? 'selected' : ''; ?>>
                                    Defaulted
                                </option>
                            </select>
                            <input type="date" class="ln-filter-date" id="filterDateFrom" title="Date From"
                                onchange="applyInlineFilter()" value="<?php echo htmlspecialchars($dateFrom); ?>">
                            <input type="date" class="ln-filter-date" id="filterDateTo" title="Date To"
                                onchange="applyInlineFilter()" value="<?php echo htmlspecialchars($dateTo); ?>">
                        </div>
                    </div>

                    <!-- Search Bar -->
                    <div class="ln-search-bar">
                        <div class="ln-search-bar__wrap">
                            <i class="fas fa-search"></i>
                            <input type="text" id="loanSearchInput"
                                placeholder="Search by Loan No., Borrower Name, or Amount..."
                                onkeyup="filterLoanTable()">
                        </div>
                    </div>

                    <?php if ($queryError): ?>
                        <div style="padding: 24px;">
                            <div class="alert alert-danger mb-0">
                                <i class="fas fa-exclamation-triangle me-2"></i>
                                <strong>Database Query Error:</strong> <?php echo htmlspecialchars($queryError); ?>
                            </div>
                        </div>
                    <?php elseif (!$hasResults): ?>
                        <div class="ln-empty">
                            <div class="ln-empty__icon"><i class="fas fa-search"></i></div>
                            <div class="ln-empty__title">
                                <?php echo $applyFilters ? 'No Matching Loans Found' : 'No Loan Data Available'; ?>
                            </div>
                            <div class="ln-empty__text">
                                <?php echo $applyFilters ? 'Try adjusting your filters.' : 'Loan applications will appear here.'; ?>
                            </div>
                        </div>
                    <?php else: ?>
                        <div class="ln-table-wrapper">
                            <table class="ln-table" id="loanTable">
                                <thead>
                                    <tr>
                                        <th class="col-type">Type</th>
                                        <th class="col-loanno">Loan No.</th>
                                        <th class="col-borrower">Borrower/Applicant</th>
                                        <th class="col-loantype">Loan Type</th>
                                        <th class="col-startdate">Start Date</th>
                                        <th class="col-maturity">Maturity</th>
                                        <th class="col-amount">Loan Amount</th>
                                        <th class="col-rate">Rate</th>
                                        <th class="col-monthly">Monthly</th>
                                        <th class="col-outstanding">Outstanding</th>
                                        <th class="col-status">Status</th>
                                        <th class="col-action">Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <?php foreach ($loans as $index => $loan):
                                        $avatarColor = ($index % 6) + 1;
                                        $initials = '';
                                        $nameParts = explode(' ', $loan['borrower_name'] ?? '');
                                        if (count($nameParts) >= 2) {
                                            $initials = strtoupper(substr($nameParts[0], 0, 1) . substr($nameParts[1], 0, 1));
                                        } elseif (count($nameParts) == 1) {
                                            $initials = strtoupper(substr($nameParts[0], 0, 2));
                                        }
                                        $loanStatus = strtolower($loan['status'] ?? 'pending');
                                        ?>
                                        <tr data-status="<?php echo htmlspecialchars($loanStatus); ?>">
                                            <td>
                                                <?php if ($loan['record_type'] === 'application'): ?>
                                                    <span class="ln-type-badge ln-type-badge--app">APP</span>
                                                <?php else: ?>
                                                    <span class="ln-type-badge ln-type-badge--loan">LOAN</span>
                                                <?php endif; ?>
                                            </td>
                                            <td class="journal-no"><?php echo htmlspecialchars($loan['loan_number']); ?></td>
                                            <td>
                                                <div class="ln-borrower">
                                                    <div class="ln-avatar ln-avatar--<?php echo $avatarColor; ?>">
                                                        <?php echo $initials; ?>
                                                    </div>
                                                    <span
                                                        class="ln-borrower__name"><?php echo htmlspecialchars($loan['borrower_name']); ?></span>
                                                </div>
                                            </td>
                                            <td><?php echo htmlspecialchars($loan['loan_type_name'] ?? 'N/A'); ?></td>
                                            <td class="date-cell"><?php echo date('M d, Y', strtotime($loan['start_date'])); ?>
                                            </td>
                                            <td class="date-cell">
                                                <?php if (!empty($loan['maturity_date'])): ?>
                                                    <?php echo date('M d, Y', strtotime($loan['maturity_date'])); ?>
                                                <?php elseif (!empty($loan['due_date'])): ?>
                                                    <?php echo date('M d, Y', strtotime($loan['due_date'])); ?>
                                                <?php else: ?>
                                                    <span style="color:#ccc;">—</span>
                                                <?php endif; ?>
                                            </td>
                                            <td class="amount-cell">₱<?php echo number_format($loan['loan_amount'], 2); ?></td>
                                            <td style="text-align:center;">
                                                <?php echo number_format($loan['interest_rate'], 1); ?>%
                                            </td>
                                            <td class="amount-cell">
                                                <?php if (!empty($loan['monthly_payment'])): ?>
                                                    ₱<?php echo number_format($loan['monthly_payment'], 2); ?>
                                                <?php else: ?>
                                                    <span style="color:#ccc;">—</span>
                                                <?php endif; ?>
                                            </td>
                                            <td class="amount-cell">
                                                <?php if (isset($loan['outstanding_balance']) && $loan['outstanding_balance'] > 0): ?>
                                                    ₱<?php echo number_format($loan['outstanding_balance'], 2); ?>
                                                <?php else: ?>
                                                    <span style="color:#ccc;">—</span>
                                                <?php endif; ?>
                                            </td>
                                            <td>
                                                <span class="ln-status ln-status--<?php echo $loanStatus; ?>">
                                                    <?php echo ucfirst($loan['status']); ?>
                                                </span>
                                            </td>
                                            <td class="col-action">
                                                <button class="ln-action-btn"
                                                    onclick="<?php echo $loan['record_type'] === 'application' ? 'viewApplicationDetails(' . $loan['application_id'] . ')' : 'viewLoanDetails(' . $loan['id'] . ')'; ?>"
                                                    title="View Details"><i class="fas fa-eye"></i></button>
                                                <button class="ln-action-btn ln-action-btn--danger"
                                                    onclick="<?php echo $loan['record_type'] === 'application' ? 'deleteApplication(' . $loan['application_id'] . ')' : 'deleteLoan(' . $loan['id'] . ')'; ?>"
                                                    title="Delete"><i class="fas fa-trash-alt"></i></button>
                                            </td>
                                        </tr>
                                    <?php endforeach; ?>
                                </tbody>
                            </table>
                        </div>

                        <!-- Pagination -->
                        <div class="ln-pagination">
                            <div class="ln-pagination__info">
                                Showing <?php echo count($loans); ?> of <?php echo number_format($totalLoans); ?> results
                            </div>
                            <div class="ln-pagination__pages">
                                <button class="ln-page-btn">Previous</button>
                                <button class="ln-page-btn active">1</button>
                                <?php if ($totalLoans > 20): ?>
                                    <button class="ln-page-btn">2</button>
                                    <button class="ln-page-btn">3</button>
                                <?php endif; ?>
                                <button class="ln-page-btn">Next</button>
                            </div>
                        </div>
                    <?php endif; ?>
                </div>

                <!-- Footer -->
                <div class="ln-footer">
                    <div class="ln-footer__left">
                        <i class="fas fa-shield-alt"></i>
                        Evergreen Accounting & Finance <?php echo date('Y'); ?>
                    </div>
                    <div class="ln-footer__links">
                        <a href="#">Privacy Policy</a>
                        <a href="#">Support</a>
                        <a href="#">Terms</a>
                    </div>
                </div> <!-- Close loanReportArea -->
            </div> <!-- Close ln-container -->
        </div> <!-- Close ln-page -->



        <!-- Inline Filter & Search JS -->
        <script>
            function applyInlineFilter() {
                const status = document.getElementById('filterStatus').value;
                const dateFrom = document.getElementById('filterDateFrom').value;
                const dateTo = document.getElementById('filterDateTo').value;

                const params = new URLSearchParams();
                if (status) params.set('status', status);
                if (dateFrom) params.set('date_from', dateFrom);
                if (dateTo) params.set('date_to', dateTo);

                if (status || dateFrom || dateTo) {
                    params.set('apply_filters', '1');
                }

                // Redirect to apply server-side filters
                window.location.href = window.location.pathname + (params.toString() ? ('?' + params.toString()) : '');
            }

            function filterLoanTable() {
                // This function is now handled in loan-accounting.js
            }
        </script>





        <!-- Loan Details Modal -->
        <div class="modal fade" id="loanDetailsModal" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header bg-primary text-white">
                        <h5 class="modal-title"><i class="fas fa-file-invoice-dollar me-2"></i>Loan Details</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body" id="loanDetailsBody">
                        <!-- Content loaded via JavaScript -->
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Audit Trail Modal -->
        <div class="modal fade" id="auditTrailModal" tabindex="-1">
            <div class="modal-dialog modal-xl">
                <div class="modal-content">
                    <div class="modal-header bg-primary text-white">
                        <h5 class="modal-title"><i class="fas fa-history me-2"></i>Loan Audit Trail</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="table-responsive">
                            <table class="table table-sm table-hover">
                                <thead class="table-light">
                                    <tr>
                                        <th>Date & Time</th>
                                        <th>User</th>
                                        <th>Action</th>
                                        <th>Loan No.</th>
                                        <th>Details</th>
                                        <th>IP Address</th>
                                    </tr>
                                </thead>
                                <tbody id="auditTrailBody">
                                    <!-- Content loaded via JavaScript -->
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-success" onclick="exportAuditTrail()">
                            <i class="fas fa-file-excel me-1"></i>Export Audit Trail
                        </button>
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
                        <h5 class="modal-title" id="deleteConfirmModalLabel">
                            <i class="fas fa-exclamation-triangle me-2"></i>Confirm Delete
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"
                            aria-label="Close"></button>
                    </div>
                    <div class="modal-body" id="deleteConfirmBody">
                        <p>Are you sure you want to delete this item?</p>
                        <p class="text-muted small">This action cannot be undone.</p>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="button" class="btn btn-danger" id="confirmDeleteBtn">
                            <i class="fas fa-trash me-1"></i>Delete
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- jQuery -->
        <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
        <!-- Bootstrap JS -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <!-- DataTables JS -->
        <script src="https://cdn.datatables.net/1.13.7/js/jquery.dataTables.min.js"></script>
        <script src="https://cdn.datatables.net/1.13.7/js/dataTables.bootstrap5.min.js"></script>
        <!-- Custom JS -->
        <script src="../assets/js/loan-accounting.js"></script>
        <script src="../assets/js/notifications.js"></script>
</body>

</html>