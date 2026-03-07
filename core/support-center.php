<?php
/**
 * Support Center Page
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
    <title>Support Center - Evergreen Accounting & Finance</title>
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

    <!-- Beautiful Page Header -->
</br>
</br>
</br>
    <div class="container mb-5">
        <div class="row g-4 mb-5">
            <div class="col-md-4">
                <div class="support-topic-card h-100 p-4 border-0 shadow-sm rounded-4 text-center">
                    <div class="topic-icon mb-3">
                        <i class="fas fa-book-reader fa-3x text-teal"></i>
                    </div>
                    <h3 class="h5 fw-bold mb-2">Knowledge Base</h3>
                    <p class="text-muted small mb-0">Browse step-by-step guides for General Ledger, Payroll, and
                        Financial Reporting modules.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="support-topic-card h-100 p-4 border-0 shadow-sm rounded-4 text-center">
                    <div class="topic-icon mb-3">
                        <i class="fas fa-question-circle fa-3x text-gold"></i>
                    </div>
                    <h3 class="h5 fw-bold mb-2">Technical Support</h3>
                    <p class="text-muted small mb-0">Encountering an error or system glitch? Submit a technical help
                        request to our IT team.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="support-topic-card h-100 p-4 border-0 shadow-sm rounded-4 text-center">
                    <div class="topic-icon mb-3">
                        <i class="fas fa-comment-dots fa-3x text-info"></i>
                    </div>
                    <h3 class="h5 fw-bold mb-2">Feature Request</h3>
                    <p class="text-muted small mb-0">Have an idea to improve the application? We'd love to hear your
                        suggestions for new features.</p>
                </div>
            </div>
        </div>

        <div class="row justify-content-center">
            <div class="col-lg-8">
                <h2 class="h4 mb-4 text-teal fw-bold text-center">Frequently Asked Questions</h2>
                <div class="accordion accordion-flush bg-white rounded-4 shadow-sm overflow-hidden" id="faqAccordion">
                    <div class="accordion-item">
                        <h2 class="accordion-header">
                            <button class="accordion-button collapsed py-3 fw-bold" type="button"
                                data-bs-toggle="collapse" data-bs-target="#faq1">
                                <i class="fas fa-lock me-3 text-success"></i>How do I reset my password?
                            </button>
                        </h2>
                        <div id="faq1" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                            <div class="accordion-body text-muted small">
                                Contact the IT Department to reset your password. For security reasons, password resets
                                cannot be done through the application interface. Once your password is reset, you will receive an email from the IT department with login credentials and instructions.
                            </div>
                        </div>
                    </div>
                    <div class="accordion-item">
                        <h2 class="accordion-header">
                            <button class="accordion-button collapsed py-3 fw-bold" type="button"
                                data-bs-toggle="collapse" data-bs-target="#faq2">
                                <i class="fas fa-file-export me-3 text-primary"></i>How can I export
                                reports to PDF?
                            </button>
                        </h2>
                        <div id="faq2" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                            <div class="accordion-body text-muted small">
                                Each module have an export functionality, select the report period and type. Once the data
                                is generated, look for the 'Export to PDF' button at the top header of the results
                                section. This will automatically generate a professional print layout.
                            </div>
                        </div>
                    </div>
                    <div class="accordion-item">
                        <h2 class="accordion-header">
                            <button class="accordion-button collapsed py-3 fw-bold" type="button"
                                data-bs-toggle="collapse" data-bs-target="#faq3">
                                <i class="fas fa-users-cog me-3 text-warning"></i>Can multiple users access the same
                                ledger?
                            </button>
                        </h2>
                        <div id="faq3" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                            <div class="accordion-body text-muted small">
                                Yes, the system supports multi-user collaborative accounting. However, each user action
                                is logged in the system's audit trail to maintain internal control and transparency.
                            </div>
                        </div>
                    </div>
                </div>

                <div class="mt-5 p-4 bg-teal rounded-4 shadow shadow-md text-white text-center">
                    <h3 class="h5 fw-bold mb-3">Still have questions?</h3>
                    <p class="mb-4 opacity-75 small">Contact our support team for personalized assistance.</p>
                    <a href="mailto:support@evergreen-finance.com" class="btn btn-gold btn-lg px-5">
                        <i class="fas fa-envelope me-2"></i>Contact Support Team | Carlo Baclao
                    </a>
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
        .support-topic-card {
            background-color: #fff;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            cursor: pointer;
        }

        .support-topic-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 1rem 3rem rgba(0, 0, 0, .1) !important;
        }

        .text-teal {
            color: #0A3D3D;
        }

        .bg-teal {
            background-color: #0A3D3D !important;
        }

        .text-gold {
            color: #C17817;
        }

        .btn-gold {
            background-color: #C17817;
            border-color: #C17817;
            color: #fff;
            font-weight: 600;
            border-radius: 12px;
        }

        .btn-gold:hover {
            background-color: #a06313;
            border-color: #a06313;
            color: #fff;
        }

        .accordion-button:not(.collapsed) {
            background-color: #f8fbfb;
            color: #0A3D3D;
        }
    </style>
</body>

</html>