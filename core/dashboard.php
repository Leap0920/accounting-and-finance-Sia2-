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

// 5. Active Users (distinct users with activity in the last 15 minutes)
$active_users_count = 1; // At least current user
$active_query = "SELECT COUNT(DISTINCT user_id) as count FROM activity_logs WHERE created_at >= NOW() - INTERVAL 15 MINUTE";
$active_result = $conn->query($active_query);
if ($active_result && $row = $active_result->fetch_assoc()) {
    $active_users_count = max((int) $row['count'], 1);
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

    <!-- Main Content -->
    <main class="dashboard-main">
        <!-- Command Center Header -->
        <div class="command-header">
            <div class="command-header-left">
                <h1 class="command-title">Accounting and Finance</h1>
                <p class="command-subtitle">Enterprise Financial &amp; Module Ecosystem</p>
            </div>
            <div class="command-header-right">
                <div class="active-users">
                    <div class="user-avatars">
                        <span class="avatar-circle" style="background: #0A3D3D; z-index: 3;"><i class="fas fa-user"
                                style="font-size: 12px; color: #fff;"></i></span>
                        <span class="avatar-circle" style="background: #2bb2b2; z-index: 2;"><i class="fas fa-user"
                                style="font-size: 12px; color: #fff;"></i></span>
                    </div>
                    <span class="users-status"><strong><?php echo $active_users_count; ?> Active
                            User<?php echo $active_users_count !== 1 ? 's' : ''; ?></strong> &bull; System Live</span>
                </div>
            </div>
        </div>

        <!-- KPI Section -->
        <div class="row g-3 mb-5">
            <div class="col-xl-3 col-md-6">
                <div class="kpi-card cash">
                    <div class="kpi-icon">
                        <i class="fas fa-wallet"></i>
                    </div>
                    <div class="kpi-info">
                        <span class="kpi-label">TOTAL CASH</span>
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
                        <span class="kpi-label">PENDING APPROVALS</span>
                        <h3 class="kpi-value"><?php echo number_format($pending_approvals); ?></h3>
                    </div>
                    <div class="kpi-trend warning">
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
                        <span class="kpi-label">OVERDUE LOANS</span>
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
                        <span class="kpi-label">UPCOMING PAYROLL</span>
                        <h3 class="kpi-value"><?php echo number_format($upcoming_payroll); ?></h3>
                    </div>
                    <div class="kpi-trend info">
                        <i class="fas fa-calendar-alt"></i>
                        <span>Next cycle preparation</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Module Section Header -->
        <div class="section-header">
            <i class="fas fa-th"></i>
            <h2>Financial Ecosystem Modules</h2>
        </div>

        <div class="row g-4" id="modules">
            <!-- General Ledger -->
            <div class="col-lg-4 col-md-6">
                <div class="module-card">
                    <div class="module-icon gl">
                        <i class="fas fa-book"></i>
                    </div>
                    <h3>General Ledger</h3>
                    <p>Manage the core of your accounting. Double-entry bookkeeping, chart of accounts, and real-time
                        journal entries.</p>
                    <a href="../modules/general-ledger.php" class="module-link">Access Module <i
                            class="fas fa-arrow-right"></i></a>
                </div>
            </div>

            <!-- Financial Reporting -->
            <div class="col-lg-4 col-md-6">
                <div class="module-card">
                    <div class="module-icon fr">
                        <i class="fas fa-chart-bar"></i>
                    </div>
                    <h3>Financial Reporting</h3>
                    <p>Automate Balance Sheets, P&amp;L statements, and Cash Flow analysis with dynamic visualization
                        tools.</p>
                    <a href="../modules/financial-reporting.php" class="module-link">Access Module <i
                            class="fas fa-arrow-right"></i></a>
                </div>
            </div>

            <!-- Loan Accounting -->
            <div class="col-lg-4 col-md-6">
                <div class="module-card">
                    <div class="module-icon la">
                        <i class="fas fa-hand-holding-usd"></i>
                    </div>
                    <h3>Loan Accounting</h3>
                    <p>Track amortizations, interest schedules, and loan portfolios with integrated risk management.</p>
                    <a href="../modules/loan-accounting.php" class="module-link">Access Module <i
                            class="fas fa-arrow-right"></i></a>
                </div>
            </div>

            <!-- Transaction Recording -->
            <div class="col-lg-4 col-md-6">
                <div class="module-card">
                    <div class="module-icon tr">
                        <i class="fas fa-exchange-alt"></i>
                    </div>
                    <h3>Transaction Recording</h3>
                    <p>High-volume transaction processing and reconciliation. Import bank statements and merchant
                        records instantly.</p>
                    <a href="../modules/transaction-reading.php" class="module-link">Access Module <i
                            class="fas fa-arrow-right"></i></a>
                </div>
            </div>

            <!-- Expense Tracking -->
            <div class="col-lg-4 col-md-6">
                <div class="module-card">
                    <div class="module-icon et">
                        <i class="fas fa-receipt"></i>
                    </div>
                    <h3>Expense Tracking</h3>
                    <p>Monitor corporate spending, process reimbursements, and enforce budget policies across the
                        enterprise.</p>
                    <a href="../modules/expense-tracking.php" class="module-link">Access Module <i
                            class="fas fa-arrow-right"></i></a>
                </div>
            </div>

            <!-- Payroll Management -->
            <div class="col-lg-4 col-md-6">
                <div class="module-card">
                    <div class="module-icon pm">
                        <i class="fas fa-users-cog"></i>
                    </div>
                    <h3>Payroll Management</h3>
                    <p>Automate salary distribution, tax withholding, and benefits administration with full compliance
                        tools.</p>
                    <a href="../modules/payroll-management.php" class="module-link">Access Module <i
                            class="fas fa-arrow-right"></i></a>
                </div>
            </div>
        </div>
    </main>

    <div class="container pb-4">
        <?php include '../includes/footer.php'; ?>
    </div>


    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <!-- Custom Dashboard JS -->
    <script src="../assets/js/dashboard.js"></script>
    <script src="../assets/js/notifications.js"></script>
</body>

</html>