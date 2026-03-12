<?php
/**
 * Navigation Component
 * This file is included in various modules and core pages.
 * It uses relative paths starting from the project root (../)
 * to ensure consistency across modules.
 */

// Determine active page
$current_page = basename($_SERVER['PHP_SELF']);

// Use the existing $current_user from the including page, 
// or fetch it if not already available
if (!isset($current_user)) {
    if (function_exists('getCurrentUser')) {
        $current_user = getCurrentUser();
    }
}

$current_user_role = function_exists('getUserRole') ? getUserRole() : ($current_user['role'] ?? null);
$is_hr_manager = ($current_user_role === 'HR Manager');
$home_path = $is_hr_manager ? '../core/hr-dashboard.php' : '../core/dashboard.php';
?>

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
                    <a class="nav-link <?php echo in_array($current_page, ['dashboard.php', 'hr-dashboard.php']) ? 'active' : ''; ?>"
                        href="<?php echo $home_path; ?>">
                        <i class="fas fa-home me-1"></i>Home
                    </a>
                </li>
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle <?php echo in_array($current_page, ['general-ledger.php', 'financial-reporting.php', 'loan-accounting.php', 'transaction-reading.php', 'expense-tracking.php', 'payroll-management.php']) ? 'active' : ''; ?>"
                        href="#" id="modulesDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                        <i class="fas fa-th-large me-1"></i>Modules
                    </a>
                    <ul class="dropdown-menu dropdown-menu-custom" aria-labelledby="modulesDropdown">
                        <?php if ($is_hr_manager): ?>
                        <li><a class="dropdown-item" href="../modules/general-ledger.php"><i
                                    class="fas fa-book me-2"></i>General Ledger</a></li>
                        <li><a class="dropdown-item" href="../modules/payroll-management.php"><i
                                    class="fas fa-users me-2"></i>Payroll Management</a></li>
                        <?php else: ?>
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
                        <?php endif; ?>
                    </ul>
                </li>

                <?php if (!$is_hr_manager): ?>
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle <?php echo in_array($current_page, ['bin-station.php']) ? 'active' : ''; ?>"
                        href="#" id="settingsDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                        <i class="fas fa-cog me-1"></i>Settings
                    </a>
                    <ul class="dropdown-menu dropdown-menu-custom" aria-labelledby="settingsDropdown">
                        <li><a class="dropdown-item" href="../modules/bin-station.php"><i
                                    class="fas fa-trash-alt me-2"></i>Bin
                                Station</a></li>

                    </ul>
                </li>
                <?php endif; ?>
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
                        <hr class="dropdown-divider mt-0">
                    </li>
                    <div id="notification-list" class="notification-scroll-area">
                        <li class="dropdown-item text-center text-muted"><small>Loading notifications...</small></li>
                    </div>
                    <li>
                        <hr class="dropdown-divider mb-0">
                    </li>
                    <?php if (!$is_hr_manager): ?>
                    <li><a class="dropdown-item text-center small" href="../modules/activity-log.php">View All
                            Notifications</a></li>
                    <?php endif; ?>
                </ul>
            </div>

            <!-- User Profile Dropdown -->
            <div class="dropdown">
                <a class="user-profile-btn" href="#" id="userDropdown" role="button" data-bs-toggle="dropdown"
                    aria-expanded="false">
                    <i class="fas fa-user-circle me-2"></i>
                    <span class="d-none d-lg-inline">
                        <?php echo htmlspecialchars($current_user['full_name'] ?? 'User'); ?>
                    </span>
                    <i class="fas fa-chevron-down ms-2 d-none d-lg-inline"></i>
                </a>
                <ul class="dropdown-menu dropdown-menu-end dropdown-menu-custom" aria-labelledby="userDropdown">
                    <li class="dropdown-header">
                        <div class="user-dropdown-header">
                            <i class="fas fa-user-circle fa-2x"></i>
                            <div>
                                <strong>
                                    <?php echo htmlspecialchars($current_user['full_name'] ?? 'User'); ?>
                                </strong>
                                <small>
                                    <?php echo htmlspecialchars($current_user['username'] ?? ''); ?>
                                </small>
                            </div>
                        </div>
                    </li>
                    <li>
                        <hr class="dropdown-divider">
                    </li>
                    <?php if (!$is_hr_manager): ?>
                    <li><a class="dropdown-item" href="../modules/activity-log.php"><i
                                class="fas fa-history me-2"></i>Activity Log</a></li>
                    <li>
                        <hr class="dropdown-divider">
                    </li>
                    <?php endif; ?>
                    <li><a class="dropdown-item text-danger" href="#" data-bs-toggle="modal"
                            data-bs-target="#logoutModal"><i class="fas fa-sign-out-alt me-2"></i>Logout</a></li>
                </ul>
            </div>
        </div>
    </div>
</nav>

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
                <a href="../core/logout.php" class="btn px-4 py-2 fw-semibold shadow-sm"
                    style="background: white; color: #0A3D3D; border: 2px solid white; border-radius: 12px; min-width: 140px; transition: all 0.3s;">Yes,
                    Logout</a>
            </div>
        </div>
    </div>
</div>