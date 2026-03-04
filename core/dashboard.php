<?php
require_once '../config/database.php';
require_once '../includes/session.php';

// Require login to access this page
requireLogin();

$current_user = getCurrentUser();
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
    <main class="container py-4" id="modules">
        <div class="row g-4">
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