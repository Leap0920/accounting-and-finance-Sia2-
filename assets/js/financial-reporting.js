/**
 * Financial Reporting Module
 * Simplified implementation matching the flowchart
 */

// Global variables
let currentReportData = null;
let currentReportType = null;
let reportModal = null;

/**
 * Initialize on page load
 */
document.addEventListener('DOMContentLoaded', function () {
    // Initialize modal (legacy — kept for backward compat)
    const modalElement = document.getElementById('reportModal');
    if (modalElement && window.bootstrap) {
        reportModal = bootstrap.Modal.getOrCreateInstance(modalElement);
    }
});

/**
 * Generate report inline within a tab pane
 */
function generateTabReport(reportType) {
    const outputDiv = document.getElementById('output-' + reportType);
    if (!outputDiv) return;

    // Show loading
    outputDiv.innerHTML = `
        <div class="text-center py-5">
            <div class="spinner-border text-primary" role="status"></div>
            <p class="mt-3 text-muted">Generating report, please wait...</p>
        </div>
    `;

    // Gather parameters from tab-specific inputs
    const params = { report_type: reportType };
    if (reportType === 'balance-sheet') {
        params.as_of_date = $('#bs-date').val();
        params.show_subaccounts = $('#bs-detail').val();
    } else if (reportType === 'income-statement') {
        params.date_from = $('#is-date-from').val();
        params.date_to = $('#is-date-to').val();
    } else if (reportType === 'cash-flow') {
        params.date_from = $('#cf-date-from').val();
        params.date_to = $('#cf-date-to').val();
    } else if (reportType === 'trial-balance') {
        params.date_from = $('#tb-date-from').val();
        params.date_to = $('#tb-date-to').val();
        params.account_type = $('#tb-account-type').val();
    } else if (reportType === 'regulatory-reports') {
        params.date_from = $('#rr-date-from').val();
        params.date_to = $('#rr-date-to').val();
    }

    $.ajax({
        url: 'api/financial-reports.php',
        method: 'GET',
        data: params,
        dataType: 'json',
        success: function (response) {
            if (response.success) {
                currentReportData = response;
                currentReportType = reportType;
                let html = '<div class="report-display">';
                html += `
                    <div class="report-header">
                        <div class="company-name">EVERGREEN ACCOUNTING & FINANCE</div>
                        <h3>${response.report_title}</h3>
                        <div class="report-period">${response.period || response.as_of_date || ''}</div>
                    </div>
                `;

                if (reportType === 'balance-sheet') html += generateBalanceSheetHTML(response);
                else if (reportType === 'income-statement') html += generateIncomeStatementHTML(response);
                else if (reportType === 'cash-flow') html += generateCashFlowHTML(response);
                else if (reportType === 'trial-balance') html += generateTrialBalanceHTML(response);
                else if (reportType === 'regulatory-reports') html += generateRegulatoryReportsHTML(response);
                else html += generateGenericReportHTML(response);

                // Export buttons
                html += `
                    <div class="d-flex justify-content-end gap-2 mt-4 no-print">
                        <button class="btn btn-success btn-sm" onclick="exportReport('excel', this)">
                            <i class="fas fa-file-excel me-1"></i>Export Excel
                        </button>
                        <button class="btn btn-danger btn-sm" onclick="exportReport('pdf', this)">
                            <i class="fas fa-file-pdf me-1"></i>Export PDF
                        </button>
                        <button class="btn btn-secondary btn-sm" onclick="printCurrentReport()">
                            <i class="fas fa-print me-1"></i>Print
                        </button>
                    </div>
                `;
                html += '</div>';
                outputDiv.innerHTML = html;
            } else {
                outputDiv.innerHTML = `<div class="alert alert-danger mt-3"><i class="fas fa-exclamation-triangle me-2"></i>${response.message || 'Failed to generate report'}</div>`;
            }
        },
        error: function () {
            outputDiv.innerHTML = '<div class="alert alert-danger mt-3"><i class="fas fa-exclamation-triangle me-2"></i>Connection error. Please try again.</div>';
        }
    });
}

/**
 * Open report generation modal (legacy)
 */
function openReportModal(reportType) {
    currentReportType = reportType;

    const modal = document.getElementById('reportModal');
    const title = document.getElementById('reportModalTitle');
    const content = document.getElementById('reportModalContent');

    // Set modal title
    const titles = {
        'balance-sheet': 'Balance Sheet',
        'income-statement': 'Income Statement',
        'cash-flow': 'Cash Flow Statement',
        'trial-balance': 'Trial Balance',
        'regulatory-reports': 'Regulatory Reports'
    };

    title.textContent = 'Generate ' + titles[reportType];

    // Show filter options
    content.innerHTML = getReportFilterHTML(reportType);

    // Show modal
    if (reportModal) {
        reportModal.show();
    }
}

/**
 * Get report filter HTML based on type
 */
function getReportFilterHTML(reportType) {
    let html = '<div class="row g-3 mb-4">';

    if (reportType === 'balance-sheet') {
        html += `
            <div class="col-md-6">
                <label class="form-label">As of Date</label>
                <input type="date" class="form-control" id="report-date" value="${new Date().toISOString().split('T')[0]}">
            </div>
            <div class="col-md-6">
                <label class="form-label">Detail Level</label>
                <select class="form-select" id="report-detail">
                    <option value="yes">Detailed</option>
                    <option value="no">Summary</option>
                </select>
            </div>
        `;
    } else {
        const firstDayOfYear = new Date(new Date().getFullYear(), 0, 1).toISOString().split('T')[0];
        const today = new Date().toISOString().split('T')[0];

        html += `
            <div class="col-md-6">
                <label class="form-label">Date From</label>
                <input type="date" class="form-control" id="report-date-from" value="${firstDayOfYear}">
            </div>
            <div class="col-md-6">
                <label class="form-label">Date To</label>
                <input type="date" class="form-control" id="report-date-to" value="${today}">
            </div>
        `;

        if (reportType === 'trial-balance') {
            html += `
                <div class="col-md-12">
                    <label class="form-label">Account Type</label>
                    <select class="form-select" id="report-account-type">
                        <option value="">All Types</option>
                        <option value="asset">Assets</option>
                        <option value="liability">Liabilities</option>
                        <option value="equity">Equity</option>
                        <option value="revenue">Revenue</option>
                        <option value="expense">Expenses</option>
                    </select>
                </div>
            `;
        }
    }

    html += '</div>';

    html += `
        <div class="d-flex justify-content-end gap-2">
            <button class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
            <button class="btn btn-primary" onclick="generateReport('${reportType}')">
                <i class="fas fa-sync-alt me-2"></i>Generate Report
            </button>
        </div>
        <div id="report-content" class="mt-4"></div>
    `;

    return html;
}

/**
 * Generate report
 */
function generateReport(reportType) {
    const contentDiv = document.getElementById('report-content');

    // Show loading state
    contentDiv.innerHTML = `
        <div class="loading-state">
            <div class="loading-spinner"></div>
            <p>Generating report, please wait...</p>
        </div>
    `;

    // Gather parameters for all reports (including regulatory)
    const params = getReportParams(reportType);

    // Make AJAX request
    $.ajax({
        url: 'api/financial-reports.php',
        method: 'GET',
        data: params,
        dataType: 'json',
        success: function (response) {
            if (response.success) {
                currentReportData = response;
                displayReportInModal(reportType, response);
            } else {
                showError(response.message || 'Failed to generate report');
            }
        },
        error: function (xhr, status, error) {
            console.error('AJAX Error:', error);
            showError('Connection error. Please try again.');
        }
    });
}

/**
 * Get report parameters
 */
function getReportParams(reportType) {
    let params = { report_type: reportType };

    if (reportType === 'balance-sheet') {
        params.as_of_date = $('#report-date').val();
        params.show_subaccounts = $('#report-detail').val();
    } else {
        params.date_from = $('#report-date-from').val();
        params.date_to = $('#report-date-to').val();

        if (reportType === 'trial-balance') {
            params.account_type = $('#report-account-type').val();
        }
    }

    return params;
}

/**
 * Display report in modal
 */
function displayReportInModal(reportType, data) {
    const contentDiv = document.getElementById('report-content');

    let html = `
        <div class="report-display">
            <div class="report-header">
                <div class="company-name">EVERGREEN ACCOUNTING & FINANCE</div>
                <h3>${data.report_title}</h3>
                <div class="report-period">${data.period || data.as_of_date}</div>
            </div>
    `;

    // Generate report content based on type
    if (reportType === 'trial-balance') {
        html += generateTrialBalanceHTML(data);
    } else if (reportType === 'balance-sheet') {
        html += generateBalanceSheetHTML(data);
    } else if (reportType === 'income-statement') {
        html += generateIncomeStatementHTML(data);
    } else if (reportType === 'cash-flow') {
        html += generateCashFlowHTML(data);
    } else if (reportType === 'regulatory-reports' || reportType === 'regulatory') {
        html += generateRegulatoryReportsHTML(data);
        // Don't add general export buttons for regulatory reports - they're inside the report HTML
    } else {
        // Fallback for any report type
        html += generateGenericReportHTML(data);
    }

    // Only add export buttons for non-regulatory reports
    if (reportType !== 'regulatory-reports' && reportType !== 'regulatory') {
        html += `
            <div class=" d-flex justify-content-end gap-2 mt-4 no-print">
                <button class="btn btn-success" onclick="exportReport('excel', this)">
                    <i class="fas fa-file-excel me-2"></i>Export Excel
                </button>
                <button class="btn btn-danger" onclick="exportReport('pdf', this)">
                    <i class="fas fa-file-pdf me-2"></i>Export PDF
                </button>
                <button class="btn btn-secondary" onclick="printCurrentReport()">
                    <i class="fas fa-print me-2"></i>Print
                </button>
            </div>
        `;
    }

    html += `</div>`;

    contentDiv.innerHTML = html;
}

/**
 * Generate Trial Balance HTML
 */
function generateTrialBalanceHTML(data) {
    let html = `
        <table class="report-table">
            <thead>
                <tr>
                    <th>Account Code</th>
                    <th>Account Name</th>
                    <th>Type</th>
                    <th style="text-align: right;">Debit</th>
                    <th style="text-align: right;">Credit</th>
                </tr>
            </thead>
            <tbody>
    `;

    if (data.accounts && data.accounts.length > 0) {
        data.accounts.forEach(account => {
            html += `
                <tr>
                    <td><strong>${account.code}</strong></td>
                    <td>${account.name}</td>
                    <td><span class="badge bg-secondary">${account.account_type.toUpperCase()}</span></td>
                    <td class="amount">${formatCurrency(account.total_debit)}</td>
                    <td class="amount">${formatCurrency(account.total_credit)}</td>
                </tr>
            `;
        });
    }

    html += `
            </tbody>
            <tfoot>
                <tr>
                    <td colspan="3"><strong>TOTAL</strong></td>
                    <td class="amount"><strong>${formatCurrency(data.total_debit)}</strong></td>
                    <td class="amount"><strong>${formatCurrency(data.total_credit)}</strong></td>
                </tr>
            </tfoot>
        </table>
    `;

    if (data.is_balanced) {
        html += '<div class="alert alert-success mt-3"><i class="fas fa-check-circle me-2"></i><strong>BALANCED</strong> — Total Debits equal Total Credits.</div>';
    } else {
        const diff = Math.abs((data.total_debit || 0) - (data.total_credit || 0));
        html += `<div class="alert alert-warning mt-3"><i class="fas fa-exclamation-triangle me-2"></i><strong>NOT BALANCED</strong> — Difference of ${formatCurrency(diff)}. Review entries for errors.</div>`;
    }

    return html;
}

/**
 * Generate Balance Sheet HTML
 */
function generateBalanceSheetHTML(data) {
    let html = '<div class="balance-sheet-report">';
    html += '<div class="formula-banner"><i class="fas fa-calculator me-2"></i>Formula: <code>Assets = Liabilities + Equity</code></div>';

    // ASSETS Section
    html += '<div class="report-section">';
    html += '<h5 class="section-header-financial">ASSETS</h5>';
    html += `
        <table class="report-table-financial">
            <thead>
                <tr>
                    <th style="text-align: left;">ACCOUNT CODE</th>
                    <th style="text-align: left;">ACCOUNT NAME</th>
                    <th style="text-align: right;">AMOUNT</th>
                </tr>
            </thead>
            <tbody>
    `;

    if (data.assets && data.assets.length > 0) {
        data.assets.forEach(account => {
            html += `
                <tr>
                    <td>${account.code}</td>
                    <td>${account.name}</td>
                    <td style="text-align: right;">${formatCurrency(account.balance)}</td>
                </tr>
            `;
        });
    } else {
        html += '<tr><td colspan="3" style="text-align: center; color: #999;">No assets found</td></tr>';
    }

    html += `
            </tbody>
            <tfoot>
                <tr class="total-row">
                    <td colspan="2"><strong>TOTAL ASSETS</strong></td>
                    <td style="text-align: right;"><strong>${formatCurrency(data.total_assets)}</strong></td>
                </tr>
            </tfoot>
        </table>
    </div>
    `;

    // LIABILITIES Section
    html += '<div class="report-section">';
    html += '<h5 class="section-header-financial">LIABILITIES</h5>';
    html += `
        <table class="report-table-financial">
            <thead>
                <tr>
                    <th style="text-align: left;">ACCOUNT CODE</th>
                    <th style="text-align: left;">ACCOUNT NAME</th>
                    <th style="text-align: right;">AMOUNT</th>
                </tr>
            </thead>
            <tbody>
    `;

    if (data.liabilities && data.liabilities.length > 0) {
        data.liabilities.forEach(account => {
            html += `
                <tr>
                    <td>${account.code}</td>
                    <td>${account.name}</td>
                    <td style="text-align: right;">${formatCurrency(account.balance)}</td>
                </tr>
            `;
        });
    } else {
        html += '<tr><td colspan="3" style="text-align: center; color: #999;">No liabilities found</td></tr>';
    }

    html += `
            </tbody>
            <tfoot>
                <tr class="total-row">
                    <td colspan="2"><strong>TOTAL LIABILITIES</strong></td>
                    <td style="text-align: right;"><strong>${formatCurrency(data.total_liabilities)}</strong></td>
                </tr>
            </tfoot>
        </table>
    </div>
    `;

    // EQUITY Section
    html += '<div class="report-section">';
    html += '<h5 class="section-header-financial">EQUITY</h5>';
    html += `
        <table class="report-table-financial">
            <thead>
                <tr>
                    <th style="text-align: left;">ACCOUNT CODE</th>
                    <th style="text-align: left;">ACCOUNT NAME</th>
                    <th style="text-align: right;">AMOUNT</th>
                </tr>
            </thead>
            <tbody>
    `;

    if (data.equity && data.equity.length > 0) {
        data.equity.forEach(account => {
            html += `
                <tr>
                    <td>${account.code}</td>
                    <td>${account.name}</td>
                    <td style="text-align: right;">${formatCurrency(account.balance)}</td>
                </tr>
            `;
        });
    } else {
        html += '<tr><td colspan="3" style="text-align: center; color: #999;">No equity found</td></tr>';
    }

    html += `
            </tbody>
            <tfoot>
                <tr class="total-row">
                    <td colspan="2"><strong>TOTAL EQUITY</strong></td>
                    <td style="text-align: right;"><strong>${formatCurrency(data.total_equity)}</strong></td>
                </tr>
            </tfoot>
        </table>
    </div>
    `;

    // Final Total
    html += `
        <div class="final-total-section">
            <div class="final-total-box">
                <span class="final-total-label">Total Liabilities & Equity:</span>
                <span class="final-total-value">${formatCurrency(data.total_liabilities_equity)}</span>
            </div>
        </div>
    `;

    if (data.is_balanced) {
        html += '<div class="alert alert-success mt-3 no-print"><i class="fas fa-check-circle me-2"></i>Balance Sheet is balanced!</div>';
    } else {
        html += '<div class="alert alert-warning mt-3 no-print"><i class="fas fa-exclamation-triangle me-2"></i>Warning: Balance Sheet is not balanced!</div>';
    }

    html += '</div>'; // Close balance-sheet-report

    return html;
}

/**
 * Generate Income Statement HTML
 */
function generateIncomeStatementHTML(data) {
    let html = '<div class="formula-banner"><i class="fas fa-calculator me-2"></i>Formula: <code>Net Income = Revenue − Expenses</code></div>';

    html += '<h5 class="section-header-financial mt-4 mb-3">REVENUE</h5>';
    html += generateAccountTable(data.revenue, data.total_revenue, 'TOTAL REVENUE');

    html += '<h5 class="section-header-financial mt-4 mb-3">EXPENSES</h5>';
    html += generateAccountTable(data.expenses, data.total_expenses, 'TOTAL EXPENSES');

    const alertClass = data.net_income >= 0 ? 'alert-success' : 'alert-danger';
    const incomeLabel = data.net_income >= 0 ? 'NET INCOME' : 'NET LOSS';
    html += `
        <div class="alert ${alertClass} mt-3">
            <h5 class="mb-1"><strong>${incomeLabel}:</strong> ${formatCurrency(data.net_income)}</h5>
            <small>Profit Margin: ${(data.net_income_percentage || 0).toFixed(2)}%</small>
            <div class="mt-2" style="font-size:0.85rem;">
                <span class="me-3">➕ Revenue: ${formatCurrency(data.total_revenue)}</span>
                <span>➖ Expenses: ${formatCurrency(data.total_expenses)}</span>
            </div>
        </div>
    `;

    return html;
}

/**
 * Generate Cash Flow HTML
 */
function generateCashFlowHTML(data) {
    let html = '<div class="formula-banner"><i class="fas fa-calculator me-2"></i>Formula: <code>Net Cash = Operating + Investing + Financing</code></div>';

    // Helper to render a detail section
    function renderSection(title, amount, detailItems) {
        let s = `<h6 class="section-header-financial mt-4 mb-2">${title}</h6>`;
        if (detailItems && detailItems.length > 0) {
            s += '<table class="report-table"><tbody>';
            detailItems.forEach(item => {
                const name = item.name || item.description || item.label || 'Item';
                const val = item.amount || item.value || 0;
                s += `<tr><td style="padding-left:1.5rem">${name}</td><td class="amount">${formatCurrency(val)}</td></tr>`;
            });
            s += `</tbody><tfoot><tr><td><strong>Subtotal</strong></td><td class="amount"><strong>${formatCurrency(amount)}</strong></td></tr></tfoot></table>`;
        } else {
            s += `<table class="report-table"><tbody><tr><td>Total</td><td class="amount"><strong>${formatCurrency(amount)}</strong></td></tr></tbody></table>`;
        }
        return s;
    }

    const details = data.details || {};
    html += renderSection('Cash from Operating Activities', data.cash_from_operations, details.operating);
    html += renderSection('Cash from Investing Activities', data.cash_from_investing, details.investing);
    html += renderSection('Cash from Financing Activities', data.cash_from_financing, details.financing);

    const changeClass = (data.net_cash_change || 0) >= 0 ? 'alert-success' : 'alert-danger';
    html += `
        <div class="alert ${changeClass} mt-4">
            <h5 class="mb-0"><strong>NET CASH CHANGE:</strong> ${formatCurrency(data.net_cash_change)}</h5>
        </div>
    `;
    return html;
}

/**
 * Generate Regulatory Reports HTML - Using REAL data
 */
function generateRegulatoryReportsHTML(data) {
    let html = `
        <div class="regulatory-reports-display">
            <div class="table-responsive">
                <table class="table table-hover table-modern">
                    <thead class="table-light">
                        <tr>
                            <th>Report ID</th>
                            <th>Report Type</th>
                            <th>Period</th>
                            <th>Status</th>
                            <th>Generated Date</th>
                            <th>Compliance Score</th>
                        </tr>
                    </thead>
                    <tbody>
    `;

    if (data.reports && data.reports.length > 0) {
        data.reports.forEach((report) => {
            const statusBadge = report.status === 'Compliant' ? 'bg-success' :
                report.status === 'Pending' ? 'bg-warning' : 'bg-danger';
            const scoreColor = report.compliance_score >= 80 ? 'text-success' :
                report.compliance_score >= 60 ? 'text-warning' : 'text-danger';

            html += `
                <tr>
                    <td><code class="text-primary">${report.report_id || 'N/A'}</code></td>
                    <td><strong>${report.report_type || 'N/A'}</strong></td>
                    <td>${report.period || 'N/A'}</td>
                    <td><span class="badge ${statusBadge}">${report.status || 'N/A'}</span></td>
                    <td>${report.generated_date ? formatDate(report.generated_date) : 'N/A'}</td>
                    <td>
                        <div class="d-flex align-items-center">
                            <div class="progress me-2" style="width: 60px; height: 8px;">
                                <div class="progress-bar ${report.compliance_score >= 80 ? 'bg-success' : report.compliance_score >= 60 ? 'bg-warning' : 'bg-danger'}" 
                                     style="width: ${report.compliance_score || 0}%"></div>
                            </div>
                            <span class="fw-bold ${scoreColor}">${report.compliance_score || 0}%</span>
                        </div>
                    </td>
                </tr>
            `;
        });
    } else {
        html += `
            <tr>
                <td colspan="6" class="text-center text-muted py-4">
                    <i class="fas fa-info-circle fa-2x mb-3"></i>
                    <p class="mb-0">No regulatory reports found for the selected period.</p>
                    <p class="mb-0">Reports are generated based on real data from operational subsystems.</p>
                </td>
            </tr>
        `;
    }

    html += `
                    </tbody>
                </table>
            </div>
            
            <!-- Export Actions -->
            <div class="mt-4 text-center">
                <div class="d-flex justify-content-center gap-2">
                    <button class="btn btn-success" onclick="exportRegulatoryReport(this)">
                        <i class="fas fa-file-excel me-2"></i>Export Excel
                    </button>
                    <button class="btn btn-danger" onclick="printRegulatoryReportPDF(this)">
                        <i class="fas fa-file-pdf me-2"></i>Export PDF
                    </button>
                    <button class="btn btn-secondary" onclick="printRegulatoryReportPDF(this)">
                        <i class="fas fa-print me-2"></i>Print
                    </button>
                </div>
            </div>
        </div>
    `;

    return html;
}

/**
 * Generate Generic Report HTML (fallback)
 */
function generateGenericReportHTML(data) {
    let html = `
        <div class="alert alert-info">
            <h5><i class="fas fa-info-circle me-2"></i>Report Generated Successfully</h5>
            <p class="mb-0">Report type: ${data.report_title || 'Financial Report'}</p>
            <p class="mb-0">Period: ${data.period || 'Current Period'}</p>
            <p class="mb-0">Generated: ${new Date().toLocaleString()}</p>
        </div>
    `;

    if (data.summary) {
        html += `
            <div class="mt-4">
                <h6>Report Summary</h6>
                <div class="bg-light p-3 rounded">
                    <pre class="mb-0">${JSON.stringify(data.summary, null, 2)}</pre>
                </div>
            </div>
        `;
    }

    return html;
}

/**
 * Generate account table helper
 */
function generateAccountTable(accounts, total, totalLabel) {
    let html = `
        <table class="report-table">
            <thead>
                <tr>
                    <th>Account Code</th>
                    <th>Account Name</th>
                    <th style="text-align: right;">Amount</th>
                </tr>
            </thead>
            <tbody>
    `;

    if (accounts && accounts.length > 0) {
        accounts.forEach((account) => {
            html += `
                <tr>
                    <td><strong>${account.code}</strong></td>
                    <td>${account.name}</td>
                    <td class="amount">${formatCurrency(account.balance)}</td>
                </tr>
            `;
        });
    } else {
        html += '<tr><td colspan="3" class="text-center text-muted">No accounts found</td></tr>';
    }

    html += `
            </tbody>
            <tfoot>
                <tr>
                    <td colspan="2"><strong>${totalLabel}</strong></td>
                    <td class="amount"><strong>${formatCurrency(total)}</strong></td>
                </tr>
            </tfoot>
        </table>
    `;

    return html;
}

/**
 * Show error message
 */
function showError(message) {
    const contentDiv = document.getElementById('report-content');
    contentDiv.innerHTML = `
        <div class="alert alert-danger">
            <i class="fas fa-exclamation-triangle me-2"></i>${message}
        </div>
    `;
}

/**
 * Format currency
 */
function formatCurrency(amount) {
    if (amount === null || amount === undefined) {
        return '₱0.00';
    }

    const formatted = Math.abs(amount).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,');
    return amount < 0 ? `(₱${formatted})` : `₱${formatted}`;
}

/**
 * Print current report with proper styling - Enhanced UX
 */
function printCurrentReport() {
    if (!currentReportData) {
        showNotification('Please generate a report first.', 'warning');
        return;
    }

    if (!currentReportType) {
        showNotification('Report type not identified. Please regenerate the report.', 'warning');
        return;
    }

    showNotification('Preparing report for printing...', 'info');

    // Add print-specific body classes based on report type
    document.body.classList.add('printing-report');
    document.body.classList.add(`printing-${currentReportType}`);

    // Ensure report modal is visible if we're printing while it's open
    if (reportModal && document.getElementById('reportModal').classList.contains('show')) {
        // Modal is already open, nothing to do
    }

    // Small delay to ensure CSS is applied
    setTimeout(() => {
        // Focus on print content
        const reportContent = document.querySelector('.report-display, .balance-sheet-report, #report-content');
        if (reportContent) {
            reportContent.focus();
        }

        // Trigger print dialog
        window.print();

        // Clean up after print dialog closes
        setTimeout(() => {
            // Remove print classes
            document.body.classList.remove('printing-report');
            document.body.classList.remove(`printing-${currentReportType}`);

            // Show success message
            showNotification('Print dialog opened. Use your browser\'s print options to save as PDF or print.', 'success');
        }, 100);
    }, 300);
}

/**
 * Export report
 */
function exportReport(format, btn) {
    if (!currentReportData) {
        alert('Please generate a report first.');
        return;
    }

    if (format === 'pdf') {
        // For PDF, use html2pdf for automatic download
        generatePDF(btn);
    } else if (format === 'excel') {
        // Prepare data for Excel export
        exportToExcel();
    } else {
        alert(`Exporting ${currentReportType} report as ${format.toUpperCase()}...\nThis feature will download the report in the selected format.`);
    }
}

/**
 * Generate PDF using html2pdf.js for automatic download
 */
function generatePDF(btn) {
    if (!currentReportData) return;

    // Find the element to export
    let element = null;

    // 1. Try to find the container based on the button context
    if (btn) {
        element = btn.closest('.report-display') ||
            btn.closest('.balance-sheet-report') ||
            btn.closest('.regulatory-reports-display') ||
            btn.closest('.tab-pane.active') ||
            btn.closest('.modal-body');
    }

    // 2. Fallbacks if button context didn't work or wasn't provided
    if (!element) {
        element = document.querySelector('.tab-pane.show.active .report-display') ||
            document.querySelector('.tab-pane.show.active .balance-sheet-report') ||
            document.querySelector('#report-content .report-display') ||
            document.querySelector('#report-content .balance-sheet-report');
    }

    if (!element) {
        // Final fallback: any report display
        element = document.querySelector('.report-display, .balance-sheet-report, .regulatory-reports-display');
    }

    if (!element) {
        alert('Report content area not found! Please ensure the report is visible on screen.');
        return;
    }

    // Determine orientation based on report type
    const orientation = (currentReportType === 'trial-balance' ||
        currentReportType === 'regulatory-reports' ||
        currentReportType === 'regulatory') ? 'landscape' : 'portrait';

    // Configure PDF options
    const opt = {
        margin: [10, 10, 10, 10],
        filename: `${currentReportType}_Report_${new Date().toISOString().split('T')[0]}.pdf`,
        image: { type: 'jpeg', quality: 0.98 },
        html2canvas: {
            scale: 2,
            useCORS: true,
            logging: false,
            letterRendering: true,
            scrollX: 0,
            scrollY: 0,
            windowWidth: document.documentElement.offsetWidth,
            windowHeight: document.documentElement.offsetHeight
        },
        jsPDF: { unit: 'mm', format: 'a4', orientation: orientation },
        pagebreak: { mode: ['avoid-all', 'css', 'legacy'] }
    };

    showNotification('Preparing PDF download...', 'info');

    // Hide buttons before capture
    const buttons = element.querySelectorAll('.no-print, button');
    buttons.forEach(b => b.setAttribute('data-print-original-display', b.style.display));
    buttons.forEach(b => b.style.display = 'none');

    // Use html2pdf to generate and save
    html2pdf().set(opt).from(element).save()
        .then(() => {
            showNotification('Report downloaded successfully!', 'success');
            // Restore buttons
            buttons.forEach(b => b.style.display = b.getAttribute('data-print-original-display') || '');
        })
        .catch(err => {
            console.error('PDF Generation Error:', err);
            // Restore buttons
            buttons.forEach(b => b.style.display = b.getAttribute('data-print-original-display') || '');
            showNotification('Auto-download failed. Opening print dialog...', 'warning');
            printCurrentReport();
        });
}

/**
 * Export report to Excel
 */
function exportToExcel() {
    if (!currentReportData || !currentReportType) {
        alert('No report data available to export.');
        return;
    }

    // Create CSV content based on report type
    let csvContent = '';

    if (currentReportType === 'balance-sheet') {
        csvContent = generateBalanceSheetCSV(currentReportData);
    } else if (currentReportType === 'income-statement') {
        csvContent = generateIncomeStatementCSV(currentReportData);
    } else if (currentReportType === 'trial-balance') {
        csvContent = generateTrialBalanceCSV(currentReportData);
    } else if (currentReportType === 'cash-flow') {
        csvContent = generateCashFlowCSV(currentReportData);
    } else if (currentReportType === 'regulatory-reports') {
        csvContent = generateRegulatoryReportsCSVFromData(currentReportData);
    } else {
        alert('Excel export not supported for this report type yet.');
        return;
    }

    // Create blob and download
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    const url = URL.createObjectURL(blob);

    link.setAttribute('href', url);
    link.setAttribute('download', `${currentReportType}_${new Date().toISOString().split('T')[0]}.csv`);
    link.style.visibility = 'hidden';

    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);

    showNotification('Report exported successfully!', 'success');
}

/**
 * Generate Balance Sheet CSV
 */
function generateBalanceSheetCSV(data) {
    let csv = 'EVERGREEN ACCOUNTING & FINANCE\n';
    csv += 'BALANCE SHEET\n';
    csv += `${data.as_of_date}\n\n`;

    // Assets
    csv += 'ASSETS\n';
    csv += 'Account Code,Account Name,Amount\n';
    if (data.assets && data.assets.length > 0) {
        data.assets.forEach(acc => {
            csv += `${acc.code},${acc.name},${acc.balance}\n`;
        });
    }
    csv += `,,${data.total_assets}\n`;
    csv += `TOTAL ASSETS,,${data.total_assets}\n\n`;

    // Liabilities
    csv += 'LIABILITIES\n';
    csv += 'Account Code,Account Name,Amount\n';
    if (data.liabilities && data.liabilities.length > 0) {
        data.liabilities.forEach(acc => {
            csv += `${acc.code},${acc.name},${acc.balance}\n`;
        });
    }
    csv += `TOTAL LIABILITIES,,${data.total_liabilities}\n\n`;

    // Equity
    csv += 'EQUITY\n';
    csv += 'Account Code,Account Name,Amount\n';
    if (data.equity && data.equity.length > 0) {
        data.equity.forEach(acc => {
            csv += `${acc.code},${acc.name},${acc.balance}\n`;
        });
    }
    csv += `TOTAL EQUITY,,${data.total_equity}\n\n`;

    csv += `Total Liabilities & Equity,,${data.total_liabilities_equity}\n`;

    return csv;
}

/**
 * Generate Income Statement CSV
 */
function generateIncomeStatementCSV(data) {
    let csv = 'EVERGREEN ACCOUNTING & FINANCE\n';
    csv += 'INCOME STATEMENT\n';
    csv += `${data.period}\n\n`;

    csv += 'REVENUE\n';
    csv += 'Account Code,Account Name,Amount\n';
    if (data.revenue && data.revenue.length > 0) {
        data.revenue.forEach(acc => {
            csv += `${acc.code},${acc.name},${acc.balance}\n`;
        });
    }
    csv += `TOTAL REVENUE,,${data.total_revenue}\n\n`;

    csv += 'EXPENSES\n';
    csv += 'Account Code,Account Name,Amount\n';
    if (data.expenses && data.expenses.length > 0) {
        data.expenses.forEach(acc => {
            csv += `${acc.code},${acc.name},${acc.balance}\n`;
        });
    }
    csv += `TOTAL EXPENSES,,${data.total_expenses}\n\n`;

    csv += `NET INCOME,,${data.net_income}\n`;

    return csv;
}

/**
 * Generate Trial Balance CSV
 */
function generateTrialBalanceCSV(data) {
    let csv = 'EVERGREEN ACCOUNTING & FINANCE\n';
    csv += 'TRIAL BALANCE\n';
    csv += `${data.period}\n\n`;

    csv += 'Account Code,Account Name,Type,Debit,Credit\n';
    if (data.accounts && data.accounts.length > 0) {
        data.accounts.forEach(acc => {
            csv += `${acc.code},${acc.name},${acc.account_type},${acc.total_debit},${acc.total_credit}\n`;
        });
    }
    csv += `TOTAL,,,${data.total_debit},${data.total_credit}\n`;

    return csv;
}

/**
 * Generate Cash Flow Statement CSV
 */
function generateCashFlowCSV(data) {
    let csv = 'EVERGREEN ACCOUNTING & FINANCE\n';
    csv += 'CASH FLOW STATEMENT\n';
    csv += `${data.period || data.as_of_date || new Date().toLocaleDateString()}\n\n`;

    csv += 'Category,Amount\n';
    csv += `Cash from Operating Activities,${data.cash_from_operations || 0}\n`;
    csv += `Cash from Investing Activities,${data.cash_from_investing || 0}\n`;
    csv += `Cash from Financing Activities,${data.cash_from_financing || 0}\n`;
    csv += `\nNET CASH CHANGE,${data.net_cash_change || 0}\n`;

    return csv;
}

/**
 * Generate Regulatory Reports CSV from modal data
 */
function generateRegulatoryReportsCSVFromData(data) {
    let csv = 'EVERGREEN ACCOUNTING & FINANCE\n';
    csv += 'REGULATORY REPORTS\n';
    csv += `Generated: ${new Date().toLocaleDateString()}\n\n`;

    // If data contains reports array, use it
    if (data.reports && Array.isArray(data.reports) && data.reports.length > 0) {
        csv += 'Report ID,Report Type,Period,Status,Generated Date,Compliance Score (%)\n';

        data.reports.forEach(report => {
            const escapeCSV = (field) => {
                if (field === null || field === undefined) return '';
                const str = String(field);
                if (str.includes(',') || str.includes('"') || str.includes('\n')) {
                    return `"${str.replace(/"/g, '""')}"`;
                }
                return str;
            };

            csv += `${escapeCSV(report.id || '')},${escapeCSV(report.type || '')},${escapeCSV(report.period || '')},${escapeCSV(report.status || '')},${escapeCSV(report.generatedDate || '')},${escapeCSV(report.score || '')}\n`;
        });

        // Add summary
        csv += '\n';
        csv += `Total Records,${data.reports.length}\n`;

        const compliantCount = data.reports.filter(r => r.status && r.status.toLowerCase().includes('compliant')).length;
        const pendingCount = data.reports.filter(r => r.status && r.status.toLowerCase().includes('pending')).length;

        csv += `Compliant,${compliantCount}\n`;
        csv += `Pending,${pendingCount}\n`;

        if (data.reports.length > 0) {
            const avgScore = data.reports.reduce((sum, r) => sum + parseFloat(r.score || 0), 0) / data.reports.length;
            csv += `Average Compliance Score,${avgScore.toFixed(2)}%\n`;
        }
    } else {
        // Fallback: try to extract from table if available
        const tbody = document.getElementById('regulatory-data-tbody');
        if (tbody) {
            const rows = tbody.querySelectorAll('tr');
            if (rows.length > 0) {
                csv += 'Report ID,Report Type,Period,Status,Generated Date,Compliance Score (%)\n';

                rows.forEach(row => {
                    const cells = row.querySelectorAll('td');
                    if (cells.length >= 6) {
                        const reportId = cells[0].textContent.trim();
                        const reportTypeCol = cells[1].textContent.trim();
                        const period = cells[2].textContent.trim();
                        const status = cells[3].textContent.trim();
                        const generatedDate = cells[4].textContent.trim();
                        const score = cells[5].textContent.trim().replace('%', '').trim();

                        const escapeCSV = (field) => {
                            if (field === null || field === undefined) return '';
                            const str = String(field);
                            if (str.includes(',') || str.includes('"') || str.includes('\n')) {
                                return `"${str.replace(/"/g, '""')}"`;
                            }
                            return str;
                        };

                        csv += `${escapeCSV(reportId)},${escapeCSV(reportTypeCol)},${escapeCSV(period)},${escapeCSV(status)},${escapeCSV(generatedDate)},${escapeCSV(score)}\n`;
                    }
                });
            } else {
                csv += 'No data available\n';
            }
        } else {
            csv += 'No data available\n';
        }
    }

    return csv;
}

/**
 * View Regulatory Report - Step 1 of Flowchart
 */
function viewRegulatoryReport(reportType) {
    const reportTable = document.getElementById('regulatory-report-table');
    const tbody = document.getElementById('regulatory-data-tbody');

    // Report type names for display
    const reportNames = {
        'bsp': 'BSP (Bangko Sentral ng Pilipinas) Reports',
        'sec': 'SEC (Securities and Exchange Commission) Filings',
        'internal': 'Internal Compliance Templates'
    };

    // Show loading state
    tbody.innerHTML = `
        <tr>
            <td colspan="6" class="text-center py-4">
                <div class="loading-spinner"></div>
                <p class="mt-2 text-muted">Loading ${reportNames[reportType]}...</p>
            </td>
        </tr>
    `;

    // Show the report table (Step 2 of flowchart)
    reportTable.style.display = 'block';

    // Simulate loading data
    setTimeout(() => {
        displayRegulatoryReportData(reportType);
    }, 1500);
}

/**
 * Display Regulatory Report Data - Step 2 of Flowchart
 * DISABLED - No real regulatory data available from subsystems
 */
function displayRegulatoryReportData(reportType) {
    const tbody = document.getElementById('regulatory-data-tbody');

    // Show message that regulatory reports are not available
    tbody.innerHTML = `
        <tr>
            <td colspan="6" class="text-center text-muted py-4">
                <i class="fas fa-info-circle fa-2x mb-3"></i>
                <p class="mb-0">Regulatory reports are not available.</p>
                <p class="mb-0">This feature requires real regulatory data from operational subsystems.</p>
            </td>
        </tr>
    `;

    showNotification('Regulatory reports are not available with real data', 'warning');
}

/**
 * Export Regulatory Report - Step 4 of Flowchart
 */
function exportRegulatoryReport() {
    const tbody = document.getElementById('regulatory-data-tbody');
    const rows = tbody.querySelectorAll('tr');

    if (rows.length === 0) {
        showNotification('No data to export', 'warning');
        return;
    }

    // Get report type from the table header or stored value
    let reportType = 'regulatory';
    const reportTypeLabel = document.querySelector('.card-header.bg-success h5');
    if (reportTypeLabel) {
        const text = reportTypeLabel.textContent.toLowerCase();
        if (text.includes('bsp')) reportType = 'bsp';
        else if (text.includes('sec')) reportType = 'sec';
        else if (text.includes('internal')) reportType = 'internal';
    }

    showNotification('Exporting regulatory report...', 'info');

    // Extract data from table rows
    const reportData = [];
    rows.forEach(row => {
        const cells = row.querySelectorAll('td');
        if (cells.length >= 6) {
            const reportId = cells[0].textContent.trim();
            const reportTypeCol = cells[1].textContent.trim();
            const period = cells[2].textContent.trim();
            const status = cells[3].textContent.trim();
            const generatedDate = cells[4].textContent.trim();
            const score = cells[5].textContent.trim();

            reportData.push({
                id: reportId,
                type: reportTypeCol,
                period: period,
                status: status,
                generatedDate: generatedDate,
                score: score.replace('%', '').trim()
            });
        }
    });

    // Generate CSV content
    const csvContent = generateRegulatoryReportCSV(reportData, reportType);

    // Create blob and download
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    const url = URL.createObjectURL(blob);

    const reportTypeNames = {
        'bsp': 'BSP',
        'sec': 'SEC',
        'internal': 'Internal',
        'regulatory': 'Regulatory'
    };

    link.setAttribute('href', url);
    link.setAttribute('download', `${reportTypeNames[reportType]}_Report_${new Date().toISOString().split('T')[0]}.csv`);
    link.style.visibility = 'hidden';

    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);

    showNotification('Regulatory report exported successfully!', 'success');
}

/**
 * Generate Regulatory Report CSV
 */
function generateRegulatoryReportCSV(data, reportType) {
    const reportTypeNames = {
        'bsp': 'BSP (Bangko Sentral ng Pilipinas) Reports',
        'sec': 'SEC (Securities and Exchange Commission) Filings',
        'internal': 'Internal Compliance Templates',
        'regulatory': 'Regulatory Reports'
    };

    let csv = 'EVERGREEN ACCOUNTING & FINANCE\n';
    csv += `${reportTypeNames[reportType] || 'REGULATORY REPORTS'}\n`;
    csv += `Generated: ${new Date().toLocaleDateString()}\n\n`;

    // CSV Headers
    csv += 'Report ID,Report Type,Period,Status,Generated Date,Compliance Score (%)\n';

    // CSV Data Rows
    if (data && data.length > 0) {
        data.forEach(report => {
            // Escape commas and quotes in CSV
            const escapeCSV = (field) => {
                if (field === null || field === undefined) return '';
                const str = String(field);
                if (str.includes(',') || str.includes('"') || str.includes('\n')) {
                    return `"${str.replace(/"/g, '""')}"`;
                }
                return str;
            };

            csv += `${escapeCSV(report.id)},${escapeCSV(report.type)},${escapeCSV(report.period)},${escapeCSV(report.status)},${escapeCSV(report.generatedDate)},${escapeCSV(report.score)}\n`;
        });
    }

    // Add summary
    csv += '\n';
    csv += `Total Records,${data.length}\n`;

    const compliantCount = data.filter(r => r.status.toLowerCase().includes('compliant')).length;
    const pendingCount = data.filter(r => r.status.toLowerCase().includes('pending')).length;

    csv += `Compliant,${compliantCount}\n`;
    csv += `Pending,${pendingCount}\n`;

    if (data.length > 0) {
        const avgScore = data.reduce((sum, r) => sum + parseFloat(r.score || 0), 0) / data.length;
        csv += `Average Compliance Score,${avgScore.toFixed(2)}%\n`;
    }

    return csv;
}

/**
 * Print Regulatory Report - Step 4 of Flowchart
 */
function printRegulatoryReport() {
    const reportTable = document.getElementById('regulatory-report-table');

    if (!reportTable || reportTable.style.display === 'none') {
        showNotification('No report data to print', 'warning');
        return;
    }

    showNotification('Preparing report for printing...', 'info');

    // Add print-specific body class
    document.body.classList.add('printing-report');
    document.body.classList.add('printing-regulatory-reports');

    // Trigger print dialog
    setTimeout(() => {
        window.print();

        // Remove print classes after printing
        document.body.classList.remove('printing-report');
        document.body.classList.remove('printing-regulatory-reports');
    }, 500);
}

/**
 * Print Regulatory Report as PDF
 */
function printRegulatoryReportPDF(btn) {
    const reportTable = document.getElementById('regulatory-report-table');

    if (!reportTable || reportTable.style.display === 'none') {
        showNotification('No report data to export', 'warning');
        return;
    }

    showNotification('Preparing PDF export...', 'info');

    const opt = {
        margin: [10, 10, 10, 10],
        filename: `Regulatory_Report_${new Date().toISOString().split('T')[0]}.pdf`,
        image: { type: 'jpeg', quality: 0.98 },
        html2canvas: {
            scale: 2,
            useCORS: true,
            logging: false,
            scrollX: 0,
            scrollY: 0
        },
        jsPDF: { unit: 'mm', format: 'a4', orientation: 'landscape' }
    };

    // Hide buttons during export
    const container = btn ? btn.closest('.regulatory-reports-display') : reportTable;
    const buttons = container ? container.querySelectorAll('.no-print, button') : [];
    buttons.forEach(b => b.style.setProperty('display', 'none', 'important'));

    html2pdf().set(opt).from(reportTable).save()
        .then(() => {
            showNotification('Regulatory report downloaded successfully!', 'success');
            buttons.forEach(b => b.style.display = '');
        })
        .catch(err => {
            console.error('PDF Error:', err);
            buttons.forEach(b => b.style.display = '');
            showNotification('Auto-download failed. Opening print dialog...', 'warning');
            printRegulatoryReport();
        });
}

/**
 * Format date helper
 */
function formatDate(dateString) {
    return new Date(dateString).toLocaleDateString();
}

/**
 * Refresh all reports
 */
function refreshAllReports() {
    showNotification('Refreshing all report data...', 'info');
    setTimeout(() => {
        location.reload();
    }, 500);
}

/**
 * Show notification
 */
function showNotification(message, type = 'info') {
    const alertClass = type === 'success' ? 'alert-success' :
        type === 'error' ? 'alert-danger' :
            type === 'warning' ? 'alert-warning' : 'alert-info';
    const iconClass = type === 'success' ? 'check-circle' :
        type === 'error' ? 'exclamation-triangle' :
            type === 'warning' ? 'exclamation-triangle' : 'info-circle';

    const notification = `
        <div class="alert ${alertClass} alert-dismissible fade show position-fixed" 
             style="top: 20px; right: 20px; z-index: 9999; min-width: 300px;" role="alert">
            <i class="fas fa-${iconClass} me-2"></i>
            ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    `;

    document.body.insertAdjacentHTML('beforeend', notification);

    setTimeout(() => {
        const alerts = document.querySelectorAll('.alert.position-fixed');
        if (alerts.length > 0) {
            const lastAlert = alerts[alerts.length - 1];
            if (lastAlert) {
                const bsAlert = bootstrap.Alert.getOrCreateInstance(lastAlert);
                bsAlert.close();
            }
        }
    }, 5000);
}