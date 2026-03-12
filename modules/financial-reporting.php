<?php
require_once '../config/database.php';
require_once '../includes/session.php';

requireLogin();
requireRole(['Administrator', 'Accounting Admin']);
$current_user = getCurrentUser();
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Financial Reporting & Compliance - Accounting and Finance System</title>
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
    <link rel="stylesheet" href="../assets/css/financial-reporting.css">
</head>

<body>
    <!-- Navigation -->
    <?php include '../includes/navbar.php'; ?>

    <!-- Main Content -->
    <main class="container-fluid py-4">
        <!-- Beautiful Page Header -->
        <div class="beautiful-page-header mb-5">
            <div class="container-fluid">
                <div class="row align-items-center">
                    <div class="col-lg-8">
                        <div class="header-content">
                            <h1 class="page-title-beautiful">
                                <i class="fas fa-chart-line me-3"></i>
                                Financial Reporting & Compliance
                            </h1>
                            <p class="page-subtitle-beautiful">
                                Generate comprehensive financial reports and analyze your business performance
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
                <div class="header-actions mt-3">
                    <a href="../core/dashboard.php" class="btn btn-outline-secondary">
                        <i class="fas fa-arrow-left me-1"></i>Back to Dashboard
                    </a>
                </div>
            </div>
        </div>

        <!-- Reports Section: Tab Layout -->
        <div class="reports-section">
            <!-- Tab Navigation -->
            <ul class="nav nav-tabs report-tabs mb-0" id="reportTabs" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" id="tab-bs" data-bs-toggle="tab" data-bs-target="#pane-bs"
                        type="button" role="tab">
                        <i class="fas fa-balance-scale me-2"></i>Balance Sheet
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="tab-is" data-bs-toggle="tab" data-bs-target="#pane-is" type="button"
                        role="tab">
                        <i class="fas fa-chart-line me-2"></i>Income Statement
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="tab-cf" data-bs-toggle="tab" data-bs-target="#pane-cf" type="button"
                        role="tab">
                        <i class="fas fa-money-bill-wave me-2"></i>Cash Flow
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="tab-tb" data-bs-toggle="tab" data-bs-target="#pane-tb" type="button"
                        role="tab">
                        <i class="fas fa-clipboard-list me-2"></i>Trial Balance
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="tab-rr" data-bs-toggle="tab" data-bs-target="#pane-rr" type="button"
                        role="tab">
                        <i class="fas fa-shield-alt me-2"></i>Regulatory
                    </button>
                </li>
            </ul>

            <div class="tab-content report-tab-content" id="reportTabContent">

                <!-- ==============================
                     BALANCE SHEET TAB
                     ============================== -->
                <div class="tab-pane fade show active" id="pane-bs" role="tabpanel">
                    <div class="tab-pane-inner">
                        <div class="tab-description">
                            <i class="fas fa-info-circle me-2"></i>
                            Shows what the company <strong>owns</strong> (Assets), what it <strong>owes</strong>
                            (Liabilities), and the owners' <strong>net stake</strong> (Equity) at a given point in time.
                            <span class="formula-hint">Formula: <code>Assets = Liabilities + Equity</code></span>
                        </div>

                        <!-- KPI Snapshot Row -->
                        <div class="kpi-snapshot-row">
                            <?php
                            // ============================================
                            // BALANCE SHEET KPI SNAPSHOT (All-time, no date filter)
                            // ============================================
                            $deposits = 0;
                            $withdrawals = 0;
                            $transfers_in = 0;
                            $transfers_out = 0;
                            $interest_income = 0;
                            $fees_collected = 0;

                            if (
                                $conn->query("SHOW TABLES LIKE 'bank_transactions'")->num_rows > 0 &&
                                $conn->query("SHOW TABLES LIKE 'transaction_types'")->num_rows > 0
                            ) {
                                foreach ([
                                    ['Deposit', &$deposits],
                                    ['Withdrawal', &$withdrawals],
                                    ['Transfer In', &$transfers_in],
                                    ['Transfer Out', &$transfers_out],
                                    ['Interest Payment', &$interest_income],
                                    ['Fee', &$fees_collected],
                                ] as [$type_name, &$var]) {
                                    $r = $conn->query("SELECT COALESCE(SUM(bt.amount),0) as t FROM bank_transactions bt INNER JOIN transaction_types tt ON bt.transaction_type_id=tt.transaction_type_id WHERE tt.type_name='$type_name'");
                                    if ($r) {
                                        $row = $r->fetch_assoc();
                                        $var = floatval($row['t'] ?? 0);
                                    }
                                }
                            }

                            $loan_disbursed = 0;
                            $loan_payments_total = 0;
                            if ($conn->query("SHOW TABLES LIKE 'loan_applications'")->num_rows > 0) {
                                $r = $conn->query("SELECT COALESCE(SUM(loan_amount),0) as t FROM loan_applications WHERE status IN ('Approved','Active','Disbursed')");
                                if ($r) {
                                    $row = $r->fetch_assoc();
                                    $loan_disbursed = floatval($row['t'] ?? 0);
                                }
                            }
                            if ($conn->query("SHOW TABLES LIKE 'loan_payments'")->num_rows > 0) {
                                $r = $conn->query("SELECT COALESCE(SUM(amount),0) as t FROM loan_payments");
                                if ($r) {
                                    $row = $r->fetch_assoc();
                                    $loan_payments_total = floatval($row['t'] ?? 0);
                                }
                            }
                            if ($conn->query("SHOW TABLES LIKE 'bank_transactions'")->num_rows > 0) {
                                $r = $conn->query("SELECT COALESCE(SUM(bt.amount),0) as t FROM bank_transactions bt INNER JOIN transaction_types tt ON bt.transaction_type_id=tt.transaction_type_id WHERE tt.type_name='Loan Payment'");
                                if ($r) {
                                    $row = $r->fetch_assoc();
                                    $loan_payments_total += floatval($row['t'] ?? 0);
                                }
                            }

                            $bs_assets = ($deposits - $withdrawals) + ($transfers_in - $transfers_out);
                            $loans_receivable = $loan_disbursed - $loan_payments_total;
                            if ($loans_receivable > 0)
                                $bs_assets += $loans_receivable;
                            if ($interest_income > 0)
                                $bs_assets += $interest_income;
                            if ($fees_collected > 0)
                                $bs_assets += $fees_collected;

                            $bs_liabilities = $deposits;
                            if ($conn->query("SHOW TABLES LIKE 'points_history'")->num_rows > 0) {
                                $r = $conn->query("SELECT COALESCE(SUM(points),0) as t FROM points_history");
                                if ($r) {
                                    $row = $r->fetch_assoc();
                                    $bs_liabilities += floatval($row['t'] ?? 0) * 0.01;
                                }
                            }
                            if ($conn->query("SHOW TABLES LIKE 'user_missions'")->num_rows > 0) {
                                $r = $conn->query("SELECT COALESCE(SUM(points_earned),0) as t FROM user_missions WHERE status='completed'");
                                if ($r) {
                                    $row = $r->fetch_assoc();
                                    $bs_liabilities += floatval($row['t'] ?? 0) * 0.01;
                                }
                            }
                            if ($conn->query("SHOW TABLES LIKE 'payroll_runs'")->num_rows > 0) {
                                $r = $conn->query("SELECT COALESCE(SUM(total_net),0) as t FROM payroll_runs WHERE status IN ('completed','finalized')");
                                if ($r) {
                                    $row = $r->fetch_assoc();
                                    $bs_liabilities += floatval($row['t'] ?? 0);
                                }
                            }
                            $bs_equity = $bs_assets - $bs_liabilities;
                            ?>
                            <div class="kpi-box kpi-blue">
                                <div class="kpi-label"><i class="fas fa-coins me-1"></i>Total Assets</div>
                                <div class="kpi-value">₱<?php echo number_format($bs_assets, 0); ?></div>
                                <div class="kpi-note">All-time snapshot</div>
                            </div>
                            <div class="kpi-box kpi-amber">
                                <div class="kpi-label"><i class="fas fa-file-invoice-dollar me-1"></i>Total Liabilities
                                </div>
                                <div class="kpi-value">₱<?php echo number_format($bs_liabilities, 0); ?></div>
                                <div class="kpi-note">All-time snapshot</div>
                            </div>
                            <div class="kpi-box <?php echo $bs_equity >= 0 ? 'kpi-green' : 'kpi-red'; ?>">
                                <div class="kpi-label"><i class="fas fa-university me-1"></i>Equity</div>
                                <div class="kpi-value">₱<?php echo number_format($bs_equity, 0); ?></div>
                                <div class="kpi-note">Assets − Liabilities</div>
                            </div>
                        </div>

                        <!-- Date + Generate -->
                        <div class="tab-generate-row">
                            <div class="tab-filter-group">
                                <label class="tab-filter-label"><i class="fas fa-calendar-alt me-1"></i>As of
                                    Date</label>
                                <input type="date" class="form-control tab-date-input" id="bs-date"
                                    value="<?php echo date('Y-m-d'); ?>">
                            </div>
                            <div class="tab-filter-group">
                                <label class="tab-filter-label"><i class="fas fa-layer-group me-1"></i>Detail
                                    Level</label>
                                <select class="form-select tab-date-input" id="bs-detail">
                                    <option value="yes">Detailed</option>
                                    <option value="no">Summary</option>
                                </select>
                            </div>
                            <button class="btn btn-generate-tab" onclick="generateTabReport('balance-sheet')">
                                <i class="fas fa-file-chart-line me-2"></i>Generate Balance Sheet
                            </button>
                        </div>

                        <!-- Inline Report Output -->
                        <div class="tab-report-output" id="output-balance-sheet"></div>
                    </div>
                </div>

                <!-- ==============================
                     INCOME STATEMENT TAB
                     ============================== -->
                <div class="tab-pane fade" id="pane-is" role="tabpanel">
                    <div class="tab-pane-inner">
                        <div class="tab-description">
                            <i class="fas fa-info-circle me-2"></i>
                            Reports all <strong>funds received</strong> (Revenue) versus all <strong>funds paid
                                out</strong> (Expenses) over a period, resulting in Net Income or Net Loss.
                            <span class="formula-hint">Formula: <code>Net Income = Revenue − Expenses</code></span>
                        </div>

                        <!-- KPI Snapshot Row -->
                        <div class="kpi-snapshot-row">
                            <?php
                            // ============================================
                            // INCOME STATEMENT KPI SNAPSHOT (All-time)
                            // ============================================
                            $is_revenue = 0;
                            $loan_interest_rev = $loan_disbursed * 0.15 / 12;
                            if ($loan_interest_rev > 0)
                                $is_revenue += $loan_interest_rev;
                            if ($loan_payments_total > 0)
                                $is_revenue += $loan_payments_total;
                            if ($deposits > 0)
                                $is_revenue += $deposits;
                            if ($transfers_in > 0)
                                $is_revenue += $transfers_in;

                            $is_expenses = 0;
                            if ($withdrawals > 0)
                                $is_expenses += $withdrawals;
                            if ($transfers_out > 0)
                                $is_expenses += $transfers_out;
                            if ($loan_disbursed > 0)
                                $is_expenses += $loan_disbursed;

                            $rewards_exp = 0;
                            if ($conn->query("SHOW TABLES LIKE 'points_history'")->num_rows > 0) {
                                $r = $conn->query("SELECT COALESCE(SUM(points),0) as t FROM points_history");
                                if ($r) {
                                    $row = $r->fetch_assoc();
                                    $rewards_exp = floatval($row['t'] ?? 0) * 0.01;
                                }
                            }
                            if ($rewards_exp > 0)
                                $is_expenses += $rewards_exp;

                            $missions_exp = 0;
                            if ($conn->query("SHOW TABLES LIKE 'user_missions'")->num_rows > 0) {
                                $r = $conn->query("SELECT COALESCE(SUM(points_earned),0) as t FROM user_missions WHERE status='completed'");
                                if ($r) {
                                    $row = $r->fetch_assoc();
                                    $missions_exp = floatval($row['t'] ?? 0) * 0.01;
                                }
                            }
                            if ($missions_exp > 0)
                                $is_expenses += $missions_exp;

                            $is_net_income = $is_revenue - $is_expenses;
                            ?>
                            <div class="kpi-box kpi-green">
                                <div class="kpi-label"><i class="fas fa-arrow-trend-up me-1"></i>Total Revenue</div>
                                <div class="kpi-value">₱<?php echo number_format($is_revenue, 0); ?></div>
                                <div class="kpi-note">Funds received (cash basis)</div>
                            </div>
                            <div class="kpi-box kpi-red">
                                <div class="kpi-label"><i class="fas fa-arrow-trend-down me-1"></i>Total Expenses</div>
                                <div class="kpi-value">₱<?php echo number_format($is_expenses, 0); ?></div>
                                <div class="kpi-note">All-time snapshot</div>
                            </div>
                            <div class="kpi-box <?php echo $is_net_income >= 0 ? 'kpi-green' : 'kpi-red'; ?>">
                                <div class="kpi-label"><i class="fas fa-calculator me-1"></i>Net Income</div>
                                <div class="kpi-value">₱<?php echo number_format($is_net_income, 0); ?></div>
                                <div class="kpi-note">Revenue − Expenses</div>
                            </div>
                        </div>

                        <!-- Date + Generate -->
                        <div class="tab-generate-row">
                            <div class="tab-filter-group">
                                <label class="tab-filter-label"><i class="fas fa-calendar-alt me-1"></i>Date
                                    From</label>
                                <input type="date" class="form-control tab-date-input" id="is-date-from"
                                    value="<?php echo date('Y-01-01'); ?>">
                            </div>
                            <div class="tab-filter-group">
                                <label class="tab-filter-label"><i class="fas fa-calendar-alt me-1"></i>Date To</label>
                                <input type="date" class="form-control tab-date-input" id="is-date-to"
                                    value="<?php echo date('Y-m-d'); ?>">
                            </div>
                            <button class="btn btn-generate-tab" onclick="generateTabReport('income-statement')">
                                <i class="fas fa-file-chart-line me-2"></i>Generate Income Statement
                            </button>
                        </div>

                        <!-- Inline Report Output -->
                        <div class="tab-report-output" id="output-income-statement"></div>
                    </div>
                </div>

                <!-- ==============================
                     CASH FLOW TAB
                     ============================== -->
                <div class="tab-pane fade" id="pane-cf" role="tabpanel">
                    <div class="tab-pane-inner">
                        <div class="tab-description">
                            <i class="fas fa-info-circle me-2"></i>
                            Tracks actual <strong>cash movements</strong> split into Operating (day-to-day), Investing
                            (assets), and Financing (loans/capital) activities.
                            <span class="formula-hint">Formula:
                                <code>Net Cash = Operating + Investing + Financing</code></span>
                        </div>

                        <!-- KPI Snapshot Row -->
                        <div class="kpi-snapshot-row">
                            <?php
                            $cf_operating = $deposits - $withdrawals + $transfers_in - $transfers_out + $interest_income + $fees_collected;
                            $cf_financing = $loan_payments_total - $loan_disbursed;
                            ?>
                            <div class="kpi-box kpi-teal">
                                <div class="kpi-label"><i class="fas fa-piggy-bank me-1"></i>Cash Balance</div>
                                <div class="kpi-value">₱<?php echo number_format($deposits, 0); ?></div>
                                <div class="kpi-note">Total deposits received</div>
                            </div>
                            <div class="kpi-box <?php echo $cf_operating >= 0 ? 'kpi-green' : 'kpi-red'; ?>">
                                <div class="kpi-label"><i class="fas fa-cogs me-1"></i>Operating</div>
                                <div class="kpi-value">₱<?php echo number_format($cf_operating, 0); ?></div>
                                <div class="kpi-note">Day-to-day cash flow</div>
                            </div>
                            <div class="kpi-box <?php echo $cf_financing >= 0 ? 'kpi-green' : 'kpi-red'; ?>">
                                <div class="kpi-label"><i class="fas fa-handshake me-1"></i>Financing</div>
                                <div class="kpi-value">₱<?php echo number_format($cf_financing, 0); ?></div>
                                <div class="kpi-note">Loan payments − disbursements</div>
                            </div>
                        </div>

                        <!-- Date + Generate -->
                        <div class="tab-generate-row">
                            <div class="tab-filter-group">
                                <label class="tab-filter-label"><i class="fas fa-calendar-alt me-1"></i>Date
                                    From</label>
                                <input type="date" class="form-control tab-date-input" id="cf-date-from"
                                    value="<?php echo date('Y-01-01'); ?>">
                            </div>
                            <div class="tab-filter-group">
                                <label class="tab-filter-label"><i class="fas fa-calendar-alt me-1"></i>Date To</label>
                                <input type="date" class="form-control tab-date-input" id="cf-date-to"
                                    value="<?php echo date('Y-m-d'); ?>">
                            </div>
                            <button class="btn btn-generate-tab" onclick="generateTabReport('cash-flow')">
                                <i class="fas fa-file-chart-line me-2"></i>Generate Cash Flow
                            </button>
                        </div>

                        <!-- Inline Report Output -->
                        <div class="tab-report-output" id="output-cash-flow"></div>
                    </div>
                </div>

                <!-- ==============================
                     TRIAL BALANCE TAB
                     ============================== -->
                <div class="tab-pane fade" id="pane-tb" role="tabpanel">
                    <div class="tab-pane-inner">
                        <div class="tab-description">
                            <i class="fas fa-info-circle me-2"></i>
                            Lists every account with its <strong>Debit</strong> and <strong>Credit</strong> total. In
                            correct double-entry bookkeeping, total Debits must always equal total Credits.
                            <span class="formula-hint">Rule: <code>Total Debits = Total Credits</code></span>
                        </div>

                        <!-- KPI Snapshot Row -->
                        <div class="kpi-snapshot-row">
                            <?php
                            // ============================================
                            // TRIAL BALANCE KPI SNAPSHOT
                            // ============================================
                            $tb_debits = 0;
                            if ($deposits > 0)
                                $tb_debits += $deposits;
                            if ($transfers_in > 0)
                                $tb_debits += $transfers_in;
                            if ($interest_income > 0)
                                $tb_debits += $interest_income;
                            if ($loan_disbursed > 0)
                                $tb_debits += $loan_disbursed;
                            if ($rewards_exp > 0)
                                $tb_debits += $rewards_exp;
                            if ($missions_exp > 0)
                                $tb_debits += $missions_exp;

                            $tb_credits = 0;
                            if ($withdrawals > 0)
                                $tb_credits += $withdrawals;
                            if ($transfers_out > 0)
                                $tb_credits += $transfers_out;
                            if ($fees_collected > 0)
                                $tb_credits += $fees_collected;
                            if ($loan_payments_total > 0)
                                $tb_credits += $loan_payments_total;

                            // Balancing entry
                            $tb_diff = $tb_debits - $tb_credits;
                            if ($tb_diff > 0)
                                $tb_credits += $tb_diff;
                            else
                                $tb_debits += abs($tb_diff);
                            $tb_balanced = abs($tb_debits - $tb_credits) < 0.01;
                            ?>
                            <div class="kpi-box kpi-red">
                                <div class="kpi-label"><i class="fas fa-arrow-up me-1"></i>Total Debits</div>
                                <div class="kpi-value">₱<?php echo number_format($tb_debits, 0); ?></div>
                                <div class="kpi-note">All debit entries</div>
                            </div>
                            <div class="kpi-box kpi-green">
                                <div class="kpi-label"><i class="fas fa-arrow-down me-1"></i>Total Credits</div>
                                <div class="kpi-value">₱<?php echo number_format($tb_credits, 0); ?></div>
                                <div class="kpi-note">All credit entries</div>
                            </div>
                            <div class="kpi-box <?php echo $tb_balanced ? 'kpi-green' : 'kpi-amber'; ?>">
                                <div class="kpi-label"><i class="fas fa-check-circle me-1"></i>Status</div>
                                <div class="kpi-value kpi-status-val">
                                    <?php echo $tb_balanced ? '<i class="fas fa-check-circle"></i> Balanced' : '<i class="fas fa-exclamation-triangle"></i> Review'; ?>
                                </div>
                                <div class="kpi-note"><?php echo $tb_balanced ? 'Debits = Credits' : 'Check entries'; ?>
                                </div>
                            </div>
                        </div>

                        <!-- Date + Generate -->
                        <div class="tab-generate-row">
                            <div class="tab-filter-group">
                                <label class="tab-filter-label"><i class="fas fa-calendar-alt me-1"></i>Date
                                    From</label>
                                <input type="date" class="form-control tab-date-input" id="tb-date-from"
                                    value="<?php echo date('Y-01-01'); ?>">
                            </div>
                            <div class="tab-filter-group">
                                <label class="tab-filter-label"><i class="fas fa-calendar-alt me-1"></i>Date To</label>
                                <input type="date" class="form-control tab-date-input" id="tb-date-to"
                                    value="<?php echo date('Y-m-d'); ?>">
                            </div>
                            <div class="tab-filter-group">
                                <label class="tab-filter-label"><i class="fas fa-tags me-1"></i>Account Type</label>
                                <select class="form-select tab-date-input" id="tb-account-type">
                                    <option value="">All Types</option>
                                    <option value="asset">Assets</option>
                                    <option value="liability">Liabilities</option>
                                    <option value="equity">Equity</option>
                                    <option value="revenue">Revenue</option>
                                    <option value="expense">Expenses</option>
                                </select>
                            </div>
                            <button class="btn btn-generate-tab" onclick="generateTabReport('trial-balance')">
                                <i class="fas fa-file-chart-line me-2"></i>Generate Trial Balance
                            </button>
                        </div>

                        <!-- Inline Report Output -->
                        <div class="tab-report-output" id="output-trial-balance"></div>
                    </div>
                </div>

                <!-- ==============================
                     REGULATORY REPORTS TAB
                     ============================== -->
                <div class="tab-pane fade" id="pane-rr" role="tabpanel">
                    <div class="tab-pane-inner">
                        <div class="tab-description">
                            <i class="fas fa-info-circle me-2"></i>
                            Generates compliance summaries for <strong>BSP</strong> (Bangko Sentral ng Pilipinas),
                            <strong>SEC</strong>, and <strong>internal audits</strong> — pulling real figures from all
                            connected subsystems.
                        </div>

                        <!-- KPI Snapshot Row -->
                        <div class="kpi-snapshot-row">
                            <div class="kpi-box kpi-blue">
                                <div class="kpi-label"><i class="fas fa-landmark me-1"></i>BSP Reports</div>
                                <div class="kpi-value kpi-status-val"><i class="fas fa-check-circle"></i> Available
                                </div>
                                <div class="kpi-note">Bank transaction data</div>
                            </div>
                            <div class="kpi-box kpi-teal">
                                <div class="kpi-label"><i class="fas fa-building me-1"></i>SEC Filings</div>
                                <div class="kpi-value kpi-status-val"><i class="fas fa-check-circle"></i> Available
                                </div>
                                <div class="kpi-note">Corporate compliance</div>
                            </div>
                            <div class="kpi-box kpi-amber">
                                <div class="kpi-label"><i class="fas fa-clipboard-check me-1"></i>Internal Audit</div>
                                <div class="kpi-value kpi-status-val"><i class="fas fa-check-circle"></i> Available
                                </div>
                                <div class="kpi-note">Internal compliance</div>
                            </div>
                        </div>

                        <!-- Date + Generate -->
                        <div class="tab-generate-row">
                            <div class="tab-filter-group">
                                <label class="tab-filter-label"><i class="fas fa-calendar-alt me-1"></i>Date
                                    From</label>
                                <input type="date" class="form-control tab-date-input" id="rr-date-from"
                                    value="<?php echo date('Y-01-01'); ?>">
                            </div>
                            <div class="tab-filter-group">
                                <label class="tab-filter-label"><i class="fas fa-calendar-alt me-1"></i>Date To</label>
                                <input type="date" class="form-control tab-date-input" id="rr-date-to"
                                    value="<?php echo date('Y-m-d'); ?>">
                            </div>
                            <button class="btn btn-generate-tab" onclick="generateTabReport('regulatory-reports')">
                                <i class="fas fa-file-chart-line me-2"></i>Generate Regulatory Report
                            </button>
                        </div>

                        <!-- Inline Report Output -->
                        <div class="tab-report-output" id="output-regulatory-reports"></div>
                    </div>
                </div>

            </div><!-- /.tab-content -->
        </div><!-- /.reports-section -->

        <!-- LEGACY: Report Generation Modal (kept for backward compatibility) -->
        <?php
        // We keep the modal below the tabs — the tab Generate buttons now load inline instead.
        // The openReportModal() function still works if called from elsewhere.
        // The below is dummied out but the JS still targets it.
        ?>
        <!-- Hidden legacy vars for old card grid — remove when fully migrated -->
        <?php
        // Declare vars expected by removed card grid PHP blocks so the page doesn't error
        // (payroll_exp is still used by the old TB card logic which we removed)
        $payroll_exp = 0;
        if ($conn->query("SHOW TABLES LIKE 'payroll_runs'")->num_rows > 0) {
            $r = $conn->query("SELECT COALESCE(SUM(total_net),0) as t FROM payroll_runs WHERE status IN ('completed','finalized')");
            if ($r) {
                $row = $r->fetch_assoc();
                $payroll_exp = floatval($row['t'] ?? 0);
            }
        }
        ?>

        <!-- === REMOVED: Old Card Grid was here === -->
        <!-- === REMOVED: Data Filtering & Search section === -->
        <!-- === REMOVED: Filtered Results section === -->

        <!-- (Spacer for footer breathing room) -->
        <div class="mb-4"></div>

        <!-- DUMMY: PHP vars declared in tabs above are in scope below this point. -->
        <?php
        // Suppress unused-var notices. These were declared in the tab KPI PHP blocks above.
        unset($r, $row);
        ?>

        <!-- ============ END OF OLD CARD GRID (removed) ============ -->

    </main>

    <!-- Report Generation Modal (legacy — kept for openReportModal() backward compat) -->
    <div class="modal fade" id="reportModal" tabindex="-1">
        <div class="modal-dialog modal-xl">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="reportModalTitle">Generate Report</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div id="reportModalContent"></div>
                </div>
            </div>
        </div>
    </div>

    <div class="container-fluid px-5 pb-4">
        <?php include '../includes/footer.php'; ?>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <!-- Custom JS -->
    <script src="../assets/js/dashboard.js"></script>
    <!-- html2pdf -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
    <script src="../assets/js/financial-reporting.js"></script>
    <script src="../assets/js/notifications.js"></script>
</body>

</html>