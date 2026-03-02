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
    <nav class="navbar navbar-expand-lg navbar-custom">
        <div class="container-fluid px-4">
            <div class="logo-section">
                <div class="logo-circle">
                    <img src="../assets/image/LOGO.png" alt="Evergreen Logo" class="logo-img">
                </div>
                <div class="logo-text">
                    <h1>EVERGREEN</h1>
                    <p>Secure. Invest. Achieve</p>
                </div>
            </div>

            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>

            <div class="collapse navbar-collapse justify-content-center" id="navbarNav">
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link active" href="dashboard.php">
                            <i class="fas fa-home me-1"></i>Home
                        </a>
                    </li>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="modulesDropdown" role="button"
                            data-bs-toggle="dropdown" aria-expanded="false">
                            <i class="fas fa-th-large me-1"></i>Modules
                        </a>
                        <ul class="dropdown-menu dropdown-menu-custom" aria-labelledby="modulesDropdown">
                            <li><a class="dropdown-item" href="../modules/general-ledger.php"><i
                                        class="fas fa-book me-2"></i>General Ledger</a></li>
                            <li><a class="dropdown-item" href="../modules/financial-reporting.php"><i
                                        class="fas fa-chart-line me-2"></i>Financial Reporting</a></li>
                            <li><a class="dropdown-item" href="../modules/loan-accounting.php"><i
                                        class="fas fa-hand-holding-usd me-2"></i>Loan Accounting</a></li>
                            <li>
                                <hr class="dropdown-divider">
                            </li>
                            <li><a class="dropdown-item" href="../modules/transaction-reading.php"><i
                                        class="fas fa-exchange-alt me-2"></i>Transaction Reading</a></li>
                            <li><a class="dropdown-item" href="../modules/expense-tracking.php"><i
                                        class="fas fa-receipt me-2"></i>Expense Tracking</a></li>
                            <li><a class="dropdown-item" href="../modules/payroll-management.php"><i
                                        class="fas fa-users me-2"></i>Payroll Management</a></li>
                        </ul>
                    </li>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="reportsDropdown" role="button"
                            data-bs-toggle="dropdown" aria-expanded="false">
                            <i class="fas fa-file-alt me-1"></i>Reports
                        </a>
                        <ul class="dropdown-menu dropdown-menu-custom" aria-labelledby="reportsDropdown">
                            <li><a class="dropdown-item" href="../modules/financial-reporting.php"><i
                                        class="fas fa-chart-bar me-2"></i>Financial Statements</a></li>
                            <li><a class="dropdown-item" href="../modules/financial-reporting.php"><i
                                        class="fas fa-money-bill-wave me-2"></i>Cash Flow Report</a></li>
                            <li><a class="dropdown-item" href="../modules/expense-tracking.php"><i
                                        class="fas fa-clipboard-list me-2"></i>Expense Summary</a></li>
                            <li><a class="dropdown-item" href="../modules/payroll-management.php"><i
                                        class="fas fa-wallet me-2"></i>Payroll Report</a></li>
                        </ul>
                    </li>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="settingsDropdown" role="button"
                            data-bs-toggle="dropdown" aria-expanded="false">
                            <i class="fas fa-cog me-1"></i>Settings
                        </a>
                        <ul class="dropdown-menu dropdown-menu-custom" aria-labelledby="settingsDropdown">
                            <li><a class="dropdown-item" href="../modules/bin-station.php"><i
                                        class="fas fa-trash-alt me-2"></i>Bin Station</a></li>
                            <li>
                                <hr class="dropdown-divider">
                            </li>
                            <li><a class="dropdown-item" href="../modules/database-settings.php"><i
                                        class="fas fa-database me-2"></i>Database Settings</a></li>
                        </ul>
                    </li>
                </ul>
            </div>

            <div class="d-flex align-items-center gap-3">
                <!-- Notifications -->
                <div class="dropdown d-none d-md-block">
                    <a class="nav-icon-btn" href="#" id="notificationsDropdown" role="button" data-bs-toggle="dropdown"
                        aria-expanded="false">
                        <i class="fas fa-bell"></i>
                        <span class="notification-badge">3</span>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end dropdown-menu-custom notifications-dropdown"
                        aria-labelledby="notificationsDropdown">
                        <li class="dropdown-header">Notifications</li>
                        <li>
                            <hr class="dropdown-divider">
                        </li>
                        <li class="dropdown-item text-center text-muted"><small>Loading notifications...</small></li>
                        <li>
                            <hr class="dropdown-divider">
                        </li>
                        <li><a class="dropdown-item text-center small" href="../modules/activity-log.php">View All
                                Notifications</a></li>
                    </ul>
                </div>

                <!-- User Profile Dropdown -->
                <div class="dropdown">
                    <a class="user-profile-btn" href="#" id="userDropdown" role="button" data-bs-toggle="dropdown"
                        aria-expanded="false">
                        <i class="fas fa-user-circle me-2"></i>
                        <span
                            class="d-none d-lg-inline"><?php echo htmlspecialchars($current_user['full_name']); ?></span>
                        <i class="fas fa-chevron-down ms-2 d-none d-lg-inline"></i>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end dropdown-menu-custom" aria-labelledby="userDropdown">
                        <li class="dropdown-header">
                            <div class="user-dropdown-header">
                                <i class="fas fa-user-circle fa-2x"></i>
                                <div>
                                    <strong><?php echo htmlspecialchars($current_user['full_name']); ?></strong>
                                    <small><?php echo htmlspecialchars($current_user['username']); ?></small>
                                </div>
                            </div>
                        </li>
                        <li>
                            <hr class="dropdown-divider">
                        </li>
                        <li><a class="dropdown-item" href="../modules/activity-log.php"><i
                                    class="fas fa-history me-2"></i>Activity Log</a></li>
                        <li>
                            <hr class="dropdown-divider">
                        </li>
                        <li><a class="dropdown-item text-danger" href="#" data-bs-toggle="modal"
                                data-bs-target="#logoutModal"><i class="fas fa-sign-out-alt me-2"></i>Logout</a></li>
                    </ul>
                </div>
            </div>
        </div>
    </nav>

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

    <!-- Logout Confirmation Modal -->
    <div class="modal fade" id="logoutModal" tabindex="-1" aria-labelledby="logoutModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg"
                style="border-radius: 20px; overflow: hidden; background-color: #0A3D3D; color: white;">
                <div class="modal-header border-0 pb-0 justify-content-end">
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"
                        style="opacity: 0.8;"></button>
                </div>
                <div class="modal-body p-5 text-center">
                    <div class="mb-4">
                        <div class="d-inline-flex align-items-center justify-content-center bg-white rounded-circle"
                            style="width: 90px; height: 90px; background: rgba(255, 255, 255, 0.1) !important;">
                            <i class="fas fa-sign-out-alt fa-3x" style="color: white;"></i>
                        </div>
                    </div>
                    <h2 class="mb-3 fw-bold" style="letter-spacing: 1px;">Ready to Leave?</h2>
                    <p class="mb-0" style="color: rgba(255, 255, 255, 0.85); font-size: 1.1rem; line-height: 1.6;">You
                        are about to securely log out of your session. Make sure all your accounting work is saved.</p>
                </div>
                <div class="modal-footer border-0 justify-content-center pb-5 px-4 gap-3">
                    <button type="button" class="btn px-4 py-2 fw-semibold" data-bs-dismiss="modal"
                        style="border: 2px solid rgba(255,255,255,0.3); color: white; border-radius: 12px; min-width: 140px; background: transparent; transition: all 0.3s;">Go
                        Back</button>
                    <a href="logout.php" class="btn px-4 py-2 fw-semibold shadow-sm"
                        style="background: white; color: #0A3D3D; border: 2px solid white; border-radius: 12px; min-width: 140px; transition: all 0.3s;">Yes,
                        Logout</a>
                </div>
            </div>
        </div>
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