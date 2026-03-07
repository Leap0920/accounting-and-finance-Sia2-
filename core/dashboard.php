<?php
require_once '../config/database.php';
require_once '../includes/session.php';

// Require login to access this page
requireLogin();

$current_user = getCurrentUser();

// Fetch KPI Data

// 1. Total Cash (Sum of all active bank accounts)
$total_cash = 0;
$cash_query = "SELECT SUM(current_balance) as total FROM bank_accounts WHERE is_active = 1";
$cash_result = $conn->query($cash_query);
if ($cash_result && $row = $cash_result->fetch_assoc()) {
    $total_cash = $row['total'] ?? 0;
}

// 2. Pending Approvals (Expense Claims Submit + Loan Applications Pending)
$pending_approvals = 0;

// Count pending expense claims
$expense_query = "SELECT COUNT(*) as count FROM expense_claims WHERE status = 'submitted'";
$expense_result = $conn->query($expense_query);
if ($expense_result && $row = $expense_result->fetch_assoc()) {
    $pending_approvals += $row['count'];
}

// Count pending loan applications
$loan_app_query = "SELECT COUNT(*) as count FROM loan_applications WHERE status = 'Pending'";
$loan_app_result = $conn->query($loan_app_query);
if ($loan_app_result && $row = $loan_app_result->fetch_assoc()) {
    $pending_approvals += $row['count'];
}

// 3. Overdue Loans (Active loans with past due date and remaining balance)
$overdue_loans = 0;
$overdue_query = "SELECT COUNT(*) as count FROM loans WHERE status = 'active' AND (next_payment_due < CURRENT_DATE() OR (current_balance > 0 AND next_payment_due IS NULL))";
$overdue_result = $conn->query($overdue_query);
if ($overdue_result && $row = $overdue_result->fetch_assoc()) {
    $overdue_loans = $row['count'];
}

// 4. Upcoming Payroll (Open payroll periods)
$upcoming_payroll = 0;
$payroll_query = "SELECT COUNT(*) as count FROM payroll_periods WHERE status IN ('open', 'processing')";
$payroll_result = $conn->query($payroll_query);
if ($payroll_result && $row = $payroll_result->fetch_assoc()) {
    $upcoming_payroll = $row['count'];
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Accounting and Finance System</title>
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
</head>

<body>
    <!-- Navigation -->
    <?php include '../includes/navbar.php'; ?>

    <!-- Page Header -->
    <div class="page-header">
        <div class="container">
            <h2>ACCOUNTING AND FINANCE</h2>
        </div>
    </div>

    <!-- Main Content -->
    <main class="container py-4">
        <!-- KPI Section -->
        <div class="row g-4 mb-5">
            <div class="col-xl-3 col-md-6">
                <div class="kpi-card cash">
                    <div class="kpi-icon">
                        <i class="fas fa-wallet"></i>
                    </div>
                    <div class="kpi-info">
                        <span class="kpi-label">Total Cash</span>
                        <h3 class="kpi-value">₱<?php echo number_format($total_cash, 2); ?></h3>
                    </div>
                    <div class="kpi-trend">
                        <i class="fas fa-chart-line"></i>
                        <span>Real-time balance</span>
                    </div>
                </div>
            </div>

            <div class="col-xl-3 col-md-6">
                <div class="kpi-card pending">
                    <div class="kpi-icon">
                        <i class="fas fa-clock"></i>
                    </div>
                    <div class="kpi-info">
                        <span class="kpi-label">Pending Approvals</span>
                        <h3 class="kpi-value"><?php echo number_format($pending_approvals); ?></h3>
                    </div>
                    <div class="kpi-trend">
                        <i class="fas fa-exclamation-circle"></i>
                        <span>Needs attention</span>
                    </div>
                </div>
            </div>

            <div class="col-xl-3 col-md-6">
                <div class="kpi-card overdue">
                    <div class="kpi-icon">
                        <i class="fas fa-exclamation-triangle"></i>
                    </div>
                    <div class="kpi-info">
                        <span class="kpi-label">Overdue Loans</span>
                        <h3 class="kpi-value text-danger"><?php echo number_format($overdue_loans); ?></h3>
                    </div>
                    <div class="kpi-trend danger">
                        <i class="fas fa-bolt"></i>
                        <span>Immediate action</span>
                    </div>
                </div>
            </div>

            <div class="col-xl-3 col-md-6">
                <div class="kpi-card payroll">
                    <div class="kpi-icon">
                        <i class="fas fa-money-check-alt"></i>
                    </div>
                    <div class="kpi-info">
                        <span class="kpi-label">Upcoming Payroll</span>
                        <h3 class="kpi-value"><?php echo number_format($upcoming_payroll); ?></h3>
                    </div>
                    <div class="kpi-trend info">
                        <i class="fas fa-calendar-alt"></i>
                        <span>Next cycle preparation</span>
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-4" id="modules">
            <!-- General Ledger -->
            <div class="col-lg-4 col-md-6">
                <div class="module-card">
                    <div class="module-icon">
                        <i class="fas fa-book"></i>
                    </div>
                    <h3>General Ledger</h3>
                    <p>Manage your accounts and financial records with precision</p>
                    <a href="../modules/general-ledger.php" class="module-link">Access Module</a>
                </div>
            </div>

            <!-- Financial Reporting -->
            <div class="col-lg-4 col-md-6">
                <div class="module-card">
                    <div class="module-icon">
                        <i class="fas fa-chart-line"></i>
                    </div>
                    <h3>Financial Reporting</h3>
                    <p>Generate and view comprehensive financial reports</p>
                    <a href="../modules/financial-reporting.php" class="module-link">Access Module</a>
                </div>
            </div>

            <!-- Loan Accounting -->
            <div class="col-lg-4 col-md-6">
                <div class="module-card">
                    <div class="module-icon">
                        <i class="fas fa-hand-holding-usd"></i>
                    </div>
                    <h3>Loan Accounting</h3>
                    <p>Track loans and manage lending efficiently</p>
                    <a href="../modules/loan-accounting.php" class="module-link">Access Module</a>
                </div>
            </div>

            <!-- Transaction Reading -->
            <div class="col-lg-4 col-md-6">
                <div class="module-card">
                    <div class="module-icon">
                        <i class="fas fa-exchange-alt"></i>
                    </div>
                    <h3>Transaction Reading</h3>
                    <p>Record and track all financial transactions</p>
                    <a href="../modules/transaction-reading.php" class="module-link">Access Module</a>
                </div>
            </div>

            <!-- Expense Tracking -->
            <div class="col-lg-4 col-md-6">
                <div class="module-card">
                    <div class="module-icon">
                        <i class="fas fa-receipt"></i>
                    </div>
                    <h3>Expense Tracking</h3>
                    <p>Monitor and manage business expenses effectively</p>
                    <a href="../modules/expense-tracking.php" class="module-link">Access Module</a>
                </div>
            </div>

            <!-- Payroll Management -->
            <div class="col-lg-4 col-md-6">
                <div class="module-card">
                    <div class="module-icon">
                        <i class="fas fa-users"></i>
                    </div>
                    <h3>Payroll Management</h3>
                    <p>Handle employee payroll and compensation</p>
                    <a href="../modules/payroll-management.php" class="module-link">Access Module</a>
                </div>
            </div>
        </div>
    </main>

    <!-- Footer -->
    <footer>
        <div class="container">
            <p class="mb-0">&copy; <?php echo date('Y'); ?> Evergreen Accounting & Finance. All rights reserved.</p>
        </div>
    </footer>


    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <!-- Custom Dashboard JS -->
    <script src="../assets/js/dashboard.js"></script>
    <script src="../assets/js/notifications.js"></script>
</body>

</html>