<?php
/**
 * Privacy Policy Page
 */

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
    <title>Privacy Policy - Evergreen Accounting & Finance</title>
    <!-- Favicon -->
    <link rel="icon" type="image/png" href="../assets/image/LOGO.png">
    <link rel="shortcut icon" type="image/png" href="../assets/image/LOGO.png">
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
    <!-- Custom CSS -->
    <link rel="stylesheet" href="../assets/css/style.css" />
    <link rel="stylesheet" href="../assets/css/dashboard.css" />
</head>

<body>
    <!-- Navigation -->
    <?php include '../includes/navbar.php'; ?>



    <div class="container mb-5">
        <div class="row justify-content-center">
            <div class="col-lg-10">
                <div class="card border-0 shadow-sm p-4 p-md-5" style="border-radius: 20px;">
                    <section class="mb-5">
                        <h2 class="h4 mb-4 text-teal fw-bold"><i class="fas fa-info-circle me-2"></i>Introduction</h2>
                        <p class="text-muted leading-relaxed">
                            Welcome to <strong>Evergreen Accounting & Finance</strong>. We are committed to protecting
                            your privacy and ensuring the security of your financial information. This Privacy Policy
                            outlines how we collect, use, and safeguard the data you entrust to us while using our
                            enterprise financial management system.
                        </p>
                    </section>

                    <section class="mb-5">
                        <div class="row g-4">
                            <div class="col-md-6">
                                <div class="p-4 bg-light rounded-4 h-100">
                                    <h3 class="h5 mb-3 fw-bold text-dark"><i
                                            class="fas fa-database me-2 text-teal"></i>Information We Collect</h3>
                                    <ul class="list-unstyled text-muted small">
                                        <li class="mb-2"><i class="fas fa-check-circle text-success me-2"></i>User
                                            profile information (name, email, role)</li>
                                        <li class="mb-2"><i class="fas fa-check-circle text-success me-2"></i>Financial
                                            transaction records and ledger entries</li>
                                        <li class="mb-2"><i class="fas fa-check-circle text-success me-2"></i>Loan
                                            applications and repayment schedules</li>
                                        <li class="mb-2"><i class="fas fa-check-circle text-success me-2"></i>System
                                            activity logs for security auditing</li>
                                    </ul>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="p-4 bg-light rounded-4 h-100">
                                    <h3 class="h5 mb-3 fw-bold text-dark"><i class="fas fa-cogs me-2 text-gold"></i>How
                                        We Use Data</h3>
                                    <ul class="list-unstyled text-muted small">
                                        <li class="mb-2"><i class="fas fa-check-circle text-teal me-2"></i>To process
                                            and record financial transactions</li>
                                        <li class="mb-2"><i class="fas fa-check-circle text-teal me-2"></i>To generate
                                            accurate financial reports and audits</li>
                                        <li class="mb-2"><i class="fas fa-check-circle text-teal me-2"></i>To identify
                                            and prevent fraudulent activities</li>
                                        <li class="mb-2"><i class="fas fa-check-circle text-teal me-2"></i>To maintain
                                            system integrity and track user actions</li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </section>



                    <section>
                        <h2 class="h4 mb-4 text-teal fw-bold"><i class="fas fa-handshake me-2"></i>Data Sharing &
                            Disclosure</h2>
                        <p class="text-muted leading-relaxed">
                            Evergreen Accounting & Finance does not sell, trade, or rent your personal or financial data
                            to third parties. We only share information with authorized system administrators and
                            regulatory bodies when required by law or to complete requested financial operations within
                            the ecosystem.
                        </p>
                        <div class="mt-4 p-3 border-start border-teal border-4 bg-light">
                            <p class="mb-0 fst-italic small text-muted">
                                "Our commitment to financial transparency is matched only by our dedication to client
                                confidentiality." — The Cybersecurity Team
                            </p>
                        </div>
                    </section>
                </div>
            </div>
        </div>
    </div>

    <div class="container-fluid px-5 pb-4 mt-5">
        <?php include '../includes/footer.php'; ?>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <style>
        .leading-relaxed {
            line-height: 1.7;
        }

        .bg-light {
            background-color: #f8fbfb !important;
        }

        .text-teal {
            color: #0A3D3D;
        }

        .text-gold {
            color: #C17817;
        }

        .border-teal {
            border-color: #0A3D3D !important;
        }
    </style>
</body>

</html>