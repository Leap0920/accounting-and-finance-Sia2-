<?php
require_once '../config/database.php';
require_once '../includes/session.php';

requireLogin();
requireRole(['HR Manager']);

$current_user = getCurrentUser();
logSuperAudit('page_visit', 'hr_dashboard', 'Visited HR dashboard', $conn);

$total_employees = 0;
$employees_result = $conn->query("SELECT COUNT(*) AS total FROM employee");
if ($employees_result && $row = $employees_result->fetch_assoc()) {
    $total_employees = (int) ($row['total'] ?? 0);
}

$open_payroll_periods = 0;
$periods_result = $conn->query("SELECT COUNT(*) AS total FROM payroll_periods WHERE status IN ('open', 'processing')");
if ($periods_result && $row = $periods_result->fetch_assoc()) {
    $open_payroll_periods = (int) ($row['total'] ?? 0);
}

$monthly_payroll_runs = 0;
$runs_result = $conn->query("SELECT COUNT(*) AS total FROM payroll_runs WHERE DATE_FORMAT(run_at, '%Y-%m') = DATE_FORMAT(CURDATE(), '%Y-%m')");
if ($runs_result && $row = $runs_result->fetch_assoc()) {
    $monthly_payroll_runs = (int) ($row['total'] ?? 0);
}

$pending_payslips = 0;
$pending_payslips_result = $conn->query("SELECT COUNT(*) AS total FROM payroll_runs WHERE status IN ('draft', 'finalized')");
if ($pending_payslips_result && $row = $pending_payslips_result->fetch_assoc()) {
    $pending_payslips = (int) ($row['total'] ?? 0);
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HR Dashboard - Payroll Management Center</title>
    <link rel="icon" type="image/png" href="../assets/image/LOGO.png">
    <link rel="shortcut icon" type="image/png" href="../assets/image/LOGO.png">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="../assets/css/style.css">
    <link rel="stylesheet" href="../assets/css/dashboard.css">
</head>

<body>
    <?php include '../includes/navbar.php'; ?>

    <main class="dashboard-main">
        <div class="command-header">
            <div class="command-header-left">
                <h1 class="command-title">HR Payroll Control Center</h1>
                <p class="command-subtitle">Restricted workspace for payroll operations and payroll journal review</p>
            </div>
            <div class="command-header-right">
                <div class="active-users">
                    <div class="user-avatars">
                        <span class="avatar-circle" style="background: #0A3D3D; z-index: 1;"><i class="fas fa-user"
                                style="font-size: 12px; color: #fff;"></i></span>
                    </div>
                    <span class="users-status"><strong><?php echo htmlspecialchars($current_user['full_name']); ?></strong> &bull; HR Access</span>
                </div>
            </div>
        </div>

        <div class="alert alert-info border-0 shadow-sm mb-4" role="alert">
            Your account is limited to payroll operations and payroll journal visibility in General Ledger.
        </div>

        <div class="row g-3 mb-5">
            <div class="col-xl-3 col-md-6">
                <div class="kpi-card cash">
                    <div class="kpi-icon">
                        <i class="fas fa-users"></i>
                    </div>
                    <div class="kpi-info">
                        <span class="kpi-label">TOTAL EMPLOYEES</span>
                        <h3 class="kpi-value"><?php echo number_format($total_employees); ?></h3>
                    </div>
                    <div class="kpi-trend">
                        <i class="fas fa-id-badge"></i>
                        <span>HRIS headcount</span>
                    </div>
                </div>
            </div>

            <div class="col-xl-3 col-md-6">
                <div class="kpi-card payroll">
                    <div class="kpi-icon">
                        <i class="fas fa-calendar-check"></i>
                    </div>
                    <div class="kpi-info">
                        <span class="kpi-label">OPEN PAYROLL PERIODS</span>
                        <h3 class="kpi-value"><?php echo number_format($open_payroll_periods); ?></h3>
                    </div>
                    <div class="kpi-trend info">
                        <i class="fas fa-clock"></i>
                        <span>Ready for processing</span>
                    </div>
                </div>
            </div>

            <div class="col-xl-3 col-md-6">
                <div class="kpi-card pending">
                    <div class="kpi-icon">
                        <i class="fas fa-money-check-alt"></i>
                    </div>
                    <div class="kpi-info">
                        <span class="kpi-label">PAYROLL RUNS THIS MONTH</span>
                        <h3 class="kpi-value"><?php echo number_format($monthly_payroll_runs); ?></h3>
                    </div>
                    <div class="kpi-trend warning">
                        <i class="fas fa-calendar-alt"></i>
                        <span>Monthly activity</span>
                    </div>
                </div>
            </div>

            <div class="col-xl-3 col-md-6">
                <div class="kpi-card overdue">
                    <div class="kpi-icon">
                        <i class="fas fa-file-invoice-dollar"></i>
                    </div>
                    <div class="kpi-info">
                        <span class="kpi-label">PENDING PAYSLIPS</span>
                        <h3 class="kpi-value"><?php echo number_format($pending_payslips); ?></h3>
                    </div>
                    <div class="kpi-trend danger">
                        <i class="fas fa-clipboard-list"></i>
                        <span>Needs review</span>
                    </div>
                </div>
            </div>
        </div>

        <div class="section-header">
            <i class="fas fa-user-shield"></i>
            <h2>HR Access Modules</h2>
        </div>

        <div class="row g-4" id="modules">
            <div class="col-lg-6 col-md-6">
                <div class="module-card">
                    <div class="module-icon pm">
                        <i class="fas fa-users-cog"></i>
                    </div>
                    <h3>Payroll Management</h3>
                    <p>Manage attendance-driven payroll calculations, payslips, deductions, and payroll period review.</p>
                    <a href="../modules/payroll-management.php" class="module-link">Access Module <i
                            class="fas fa-arrow-right"></i></a>
                </div>
            </div>

            <div class="col-lg-6 col-md-6">
                <div class="module-card">
                    <div class="module-icon gl">
                        <i class="fas fa-book"></i>
                    </div>
                    <h3>General Ledger</h3>
                    <p>Review payroll journal entries already posted to the ledger without exposing the full accounting workspace.</p>
                    <a href="../modules/general-ledger.php" class="module-link">Open Payroll Journals <i
                            class="fas fa-arrow-right"></i></a>
                </div>
            </div>
        </div>
    </main>

    <div class="container pb-4">
        <?php include '../includes/footer.php'; ?>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="../assets/js/dashboard.js"></script>
    <script src="../assets/js/notifications.js"></script>
    <?php renderSuperAuditTracker('hr_dashboard', '../modules/api/super-audit-tracker.php'); ?>
</body>

</html>