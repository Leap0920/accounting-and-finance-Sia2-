/**
 * Payroll Management Module - JavaScript
 * Handles client-side interactivity, filtering, and export functions
 */

// Initialize on page load
document.addEventListener('DOMContentLoaded', function () {
    console.log('Payroll Management module initialized');

    // Initialize date inputs with current date
    initializeDateFilters();

    // Add event listeners for tab changes
    addTabEventListeners();

    // Initialize employee selector
    initializeEmployeeSelector();

    // Initialize attendance filters
    initializeAttendanceFilters();
});

/**
 * Initialize date filters with current date range
 */
function initializeDateFilters() {
    const today = new Date();
    const firstDayOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);

    const formatDate = (date) => {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    };

    // Set default date ranges
    const expenseFrom = document.getElementById('expense-date-from');
    const expenseTo = document.getElementById('expense-date-to');
    const transactionFrom = document.getElementById('transaction-date-from');
    const transactionTo = document.getElementById('transaction-date-to');
    const loanFrom = document.getElementById('loan-date-from');
    const loanTo = document.getElementById('loan-date-to');

    if (expenseFrom) expenseFrom.value = formatDate(firstDayOfMonth);
    if (expenseTo) expenseTo.value = formatDate(today);
    if (transactionFrom) transactionFrom.value = formatDate(firstDayOfMonth);
    if (transactionTo) transactionTo.value = formatDate(today);
    if (loanFrom) loanFrom.value = formatDate(firstDayOfMonth);
    if (loanTo) loanTo.value = formatDate(today);
}

/**
 * Add event listeners to tabs for tracking
 */
function addTabEventListeners() {
    const tabs = document.querySelectorAll('.payroll-nav-tabs .nav-link');
    tabs.forEach(tab => {
        tab.addEventListener('shown.bs.tab', function (event) {
            const tabId = event.target.getAttribute('data-bs-target');
            console.log('Switched to tab:', tabId);
        });
    });
}

/**
 * Initialize employee selector
 */
function initializeEmployeeSelector() {
    const employeeSelect = document.getElementById('employee-select');
    if (employeeSelect) {
        console.log('Employee selector initialized');
    }

    // Initialize filters toggle
    initializeFiltersToggle();
}

/**
 * Initialize filters toggle functionality
 */
function initializeFiltersToggle() {
    const toggleBtn = document.querySelector('.btn-toggle-filters');
    const filtersContent = document.getElementById('filters-content');

    if (toggleBtn && filtersContent) {
        // Check if filters are already applied (URL has parameters)
        const urlParams = new URLSearchParams(window.location.search);
        const hasFilters = urlParams.has('search') || urlParams.has('position') ||
            urlParams.has('department') || urlParams.has('type');

        if (hasFilters) {
            // Show filters if they're already applied
            filtersContent.classList.add('show');
            toggleBtn.classList.add('active');
            toggleBtn.setAttribute('aria-expanded', 'true');
        } else {
            // Hide filters by default if no filters applied
            filtersContent.classList.remove('show');
            toggleBtn.classList.remove('active');
            toggleBtn.setAttribute('aria-expanded', 'false');
        }

        console.log('Filters toggle initialized');
    }
}

/**
 * Initialize attendance filters
 */
function initializeAttendanceFilters() {
    const monthFilter = document.getElementById('attendance-month-filter');
    if (monthFilter) {
        monthFilter.addEventListener('change', filterAttendanceByMonth);
        console.log('Attendance filters initialized');
    }
}

/**
 * Toggle filters visibility
 */
function toggleFilters() {
    const toggleBtn = document.querySelector('.btn-toggle-filters');
    const filtersContent = document.getElementById('filters-content');
    const chevron = document.getElementById('filter-chevron');

    if (toggleBtn && filtersContent) {
        const isVisible = filtersContent.classList.contains('show');

        if (isVisible) {
            filtersContent.classList.remove('show');
            toggleBtn.classList.remove('active');
            toggleBtn.setAttribute('aria-expanded', 'false');
            if (chevron) {
                chevron.style.transform = 'rotate(0deg)';
            }
        } else {
            filtersContent.classList.add('show');
            toggleBtn.classList.add('active');
            toggleBtn.setAttribute('aria-expanded', 'true');
            if (chevron) {
                chevron.style.transform = 'rotate(180deg)';
            }
        }
    }
}

/**
 * Change employee selection
 */
function changeEmployee() {
    const employeeSelect = document.getElementById('employee-select');
    const selectedEmployee = employeeSelect.value;

    // Get current payroll period parameters
    const payrollMonth = document.getElementById('payroll-month-select')?.value || '';
    const payrollPeriod = document.getElementById('payroll-period-select')?.value || '';

    // Redirect to same page with employee and payroll period parameters
    const currentUrl = new URL(window.location);

    if (selectedEmployee) {
        currentUrl.searchParams.set('employee', selectedEmployee);
    } else {
        currentUrl.searchParams.delete('employee');
    }

    // Preserve payroll period parameters
    if (payrollMonth) {
        currentUrl.searchParams.set('payroll_month', payrollMonth);
    }
    if (payrollPeriod) {
        currentUrl.searchParams.set('payroll_period', payrollPeriod);
    }

    window.location.href = currentUrl.toString();
}

/**
 * Change payroll period selection
 */
function changePayrollPeriod() {
    const payrollMonth = document.getElementById('payroll-month-select')?.value || '';
    const payrollPeriod = document.getElementById('payroll-period-select')?.value || '';
    const selectedEmployee = document.getElementById('employee-select')?.value || '';

    // Redirect to same page with payroll period parameters
    const currentUrl = new URL(window.location);

    // Preserve employee selection
    if (selectedEmployee) {
        currentUrl.searchParams.set('employee', selectedEmployee);
    }

    // Set payroll period parameters
    if (payrollMonth) {
        currentUrl.searchParams.set('payroll_month', payrollMonth);
    } else {
        currentUrl.searchParams.delete('payroll_month');
    }

    if (payrollPeriod) {
        currentUrl.searchParams.set('payroll_period', payrollPeriod);
    } else {
        currentUrl.searchParams.delete('payroll_period');
    }

    window.location.href = currentUrl.toString();
}

/**
 * Filter expense history based on date range
 */
function filterExpenses() {
    const fromDate = document.getElementById('expense-date-from').value;
    const toDate = document.getElementById('expense-date-to').value;

    if (!fromDate || !toDate) {
        alert('Please select both From and To dates');
        return;
    }

    console.log('Filtering expenses from', fromDate, 'to', toDate);

    // Filter table rows
    const tableBody = document.getElementById('expense-table-body');
    const rows = tableBody.getElementsByTagName('tr');

    let visibleCount = 0;

    for (let i = 0; i < rows.length; i++) {
        const row = rows[i];
        const dateCell = row.cells[0];

        if (dateCell && dateCell.textContent) {
            const rowDate = dateCell.textContent.trim();

            if (rowDate >= fromDate && rowDate <= toDate) {
                row.style.display = '';
                visibleCount++;
            } else {
                row.style.display = 'none';
            }
        }
    }

    // Show message if no results
    if (visibleCount === 0) {
        showNoResultsMessage(tableBody, 5, 'No expenses found for the selected date range');
    } else {
        removeNoResultsMessage(tableBody);
    }
}

/**
 * Filter transaction history based on date range
 */
function filterTransactions() {
    const fromDate = document.getElementById('transaction-date-from').value;
    const toDate = document.getElementById('transaction-date-to').value;

    if (!fromDate || !toDate) {
        alert('Please select both From and To dates');
        return;
    }

    console.log('Filtering transactions from', fromDate, 'to', toDate);

    // Filter table rows
    const tableBody = document.getElementById('transaction-table-body');
    const rows = tableBody.getElementsByTagName('tr');

    let visibleCount = 0;

    for (let i = 0; i < rows.length; i++) {
        const row = rows[i];
        const dateCell = row.cells[0];

        if (dateCell && dateCell.textContent) {
            const rowDate = dateCell.textContent.trim();

            if (rowDate >= fromDate && rowDate <= toDate) {
                row.style.display = '';
                visibleCount++;
            } else {
                row.style.display = 'none';
            }
        }
    }

    // Show message if no results
    if (visibleCount === 0) {
        showNoResultsMessage(tableBody, 6, 'No transactions found for the selected date range');
    } else {
        removeNoResultsMessage(tableBody);
    }
}

/**
 * Filter loan history based on date range
 */
function filterLoans() {
    const fromDate = document.getElementById('loan-date-from').value;
    const toDate = document.getElementById('loan-date-to').value;

    if (!fromDate || !toDate) {
        alert('Please select both From and To dates');
        return;
    }

    console.log('Filtering loans from', fromDate, 'to', toDate);

    // Filter table rows
    const tableBody = document.getElementById('loan-table-body');
    const rows = tableBody.getElementsByTagName('tr');

    let visibleCount = 0;

    for (let i = 0; i < rows.length; i++) {
        const row = rows[i];
        const dateCell = row.cells[0];

        if (dateCell && dateCell.textContent) {
            const rowDate = dateCell.textContent.trim();

            if (rowDate >= fromDate && rowDate <= toDate) {
                row.style.display = '';
                visibleCount++;
            } else {
                row.style.display = 'none';
            }
        }
    }

    // Show message if no results
    if (visibleCount === 0) {
        showNoResultsMessage(tableBody, 6, 'No loans found for the selected date range');
    } else {
        removeNoResultsMessage(tableBody);
    }
}

/**
 * Show "no results" message in table
 */
function showNoResultsMessage(tableBody, colspan, message) {
    removeNoResultsMessage(tableBody);

    const row = document.createElement('tr');
    row.className = 'no-results-row';
    row.innerHTML = `<td colspan="${colspan}" class="text-center text-muted py-4">${message}</td>`;
    tableBody.appendChild(row);
}

/**
 * Remove "no results" message from table
 */
function removeNoResultsMessage(tableBody) {
    const existingMessage = tableBody.querySelector('.no-results-row');
    if (existingMessage) {
        existingMessage.remove();
    }
}

/**
 * Export expenses to Excel (placeholder)
 */
function exportExpenses() {
    console.log('Exporting expenses...');

    // Get visible rows
    const tableBody = document.getElementById('expense-table-body');
    const rows = tableBody.getElementsByTagName('tr');

    let data = [];
    data.push(['Date', 'Description', 'Category', 'Amount', 'Status']);

    for (let i = 0; i < rows.length; i++) {
        const row = rows[i];
        if (row.style.display !== 'none' && !row.classList.contains('no-results-row')) {
            const cells = row.cells;
            if (cells.length >= 5) {
                data.push([
                    cells[0].textContent.trim(),
                    cells[1].textContent.trim(),
                    cells[2].textContent.trim(),
                    cells[3].textContent.trim(),
                    cells[4].textContent.trim()
                ]);
            }
        }
    }

    if (data.length > 1) {
        // Convert to CSV
        const csv = data.map(row => row.join(',')).join('\n');

        // Create download link
        const blob = new Blob([csv], { type: 'text/csv' });
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `expense_history_${new Date().toISOString().split('T')[0]}.csv`;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        window.URL.revokeObjectURL(url);

        console.log('Exported', data.length - 1, 'expense records');
    } else {
        alert('No data to export');
    }
}

/**
 * Export transactions to Excel (placeholder)
 */
function exportTransactions() {
    console.log('Exporting transactions...');

    const tableBody = document.getElementById('transaction-table-body');
    const rows = tableBody.getElementsByTagName('tr');

    let data = [];
    data.push(['Date', 'Type', 'Account', 'Description', 'Amount', 'Status']);

    for (let i = 0; i < rows.length; i++) {
        const row = rows[i];
        if (row.style.display !== 'none' && !row.classList.contains('no-results-row')) {
            const cells = row.cells;
            if (cells.length >= 6) {
                data.push([
                    cells[0].textContent.trim(),
                    cells[1].textContent.trim(),
                    cells[2].textContent.trim(),
                    cells[3].textContent.trim(),
                    cells[4].textContent.trim(),
                    cells[5].textContent.trim()
                ]);
            }
        }
    }

    if (data.length > 1) {
        const csv = data.map(row => row.join(',')).join('\n');
        const blob = new Blob([csv], { type: 'text/csv' });
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `transaction_history_${new Date().toISOString().split('T')[0]}.csv`;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        window.URL.revokeObjectURL(url);

        console.log('Exported', data.length - 1, 'transaction records');
    } else {
        alert('No data to export');
    }
}

/**
 * Export loans to Excel (placeholder)
 */
function exportLoans() {
    console.log('Exporting loans...');

    const tableBody = document.getElementById('loan-table-body');
    const rows = tableBody.getElementsByTagName('tr');

    let data = [];
    data.push(['Date', 'Account Number', 'Type', 'Amount', 'Status', 'Description']);

    for (let i = 0; i < rows.length; i++) {
        const row = rows[i];
        if (row.style.display !== 'none' && !row.classList.contains('no-results-row')) {
            const cells = row.cells;
            if (cells.length >= 6) {
                data.push([
                    cells[0].textContent.trim(),
                    cells[1].textContent.trim(),
                    cells[2].textContent.trim(),
                    cells[3].textContent.trim(),
                    cells[4].textContent.trim(),
                    cells[5].textContent.trim()
                ]);
            }
        }
    }

    if (data.length > 1) {
        const csv = data.map(row => row.join(',')).join('\n');
        const blob = new Blob([csv], { type: 'text/csv' });
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `loan_history_${new Date().toISOString().split('T')[0]}.csv`;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        window.URL.revokeObjectURL(url);

        console.log('Exported', data.length - 1, 'loan records');
    } else {
        alert('No data to export');
    }
}

/**
 * Format currency for display
 */
function formatCurrency(amount) {
    return '₱' + parseFloat(amount).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,');
}

/**
 * Format date for display
 */
function formatDate(dateString) {
    const date = new Date(dateString);
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const year = date.getFullYear();
    return `${month}/${day}/${year}`;
}

/**
 * Print payslip - Receipt style
 */
function printPayslip() {
    // Switch to Overall tab before printing
    const overallTab = document.getElementById('overall-tab');
    const overallPane = document.getElementById('overall');

    if (overallTab && overallPane) {
        // Activate the Overall tab
        const tabInstance = new bootstrap.Tab(overallTab);
        tabInstance.show();

        // Wait for tab transition then print
        setTimeout(() => {
            // Add printing class
            document.body.classList.add('printing');

            // Print the page
            window.print();

            // Remove the printing class after printing
            setTimeout(() => {
                document.body.classList.remove('printing');
            }, 500);
        }, 300);
    } else {
        // Fallback: just print
        document.body.classList.add('printing');
        window.print();
        setTimeout(() => {
            document.body.classList.remove('printing');
        }, 500);
    }
}

/**
 * Filter attendance by month
 */
function filterAttendanceByMonth() {
    const monthFilter = document.getElementById('attendance-month-filter');
    if (monthFilter) {
        const selectedMonth = monthFilter.value;
        console.log('Filtering attendance for month:', selectedMonth);

        // Reload page with month parameter
        const currentUrl = new URL(window.location);
        currentUrl.searchParams.set('attendance_month', selectedMonth);
        window.location.href = currentUrl.toString();
    }
}

/**
 * View expense details
 */
function viewExpense(expenseId) {
    console.log('Viewing expense:', expenseId);
    showPayrollNotification('info', 'Expense Details', 'View details functionality for ID: ' + expenseId);
}

/**
 * Edit expense
 */
function editExpense(expenseId) {
    console.log('Editing expense:', expenseId);
    showPayrollNotification('info', 'Edit Expense', 'Edit functionality for ID: ' + expenseId);
}

/**
 * View transaction details
 */
function viewTransaction(transactionId) {
    console.log('Viewing transaction:', transactionId);
    showPayrollNotification('info', 'Transaction Details', 'View details functionality for ID: ' + transactionId);
}

/**
 * View loan details
 */
function viewLoan(loanId) {
    console.log('Viewing loan:', loanId);
    showPayrollNotification('info', 'Loan Details', 'View details functionality for ID: ' + loanId);
}

/**
 * Show a styled notification modal instead of browser alert/confirm
 * @param {string} type - 'success', 'error', 'info', or 'confirm'
 * @param {string} title - Modal title
 * @param {string} message - Main message body
 * @param {function} callback - Optional callback for confirmation
 */
function showPayrollNotification(type, title, message, callback = null) {
    const modal = new bootstrap.Modal(document.getElementById('payrollNotificationModal'));
    const header = document.getElementById('notificationModalHeader');
    const titleEl = document.getElementById('notificationModalTitle');
    const headingEl = document.getElementById('notificationModalHeading');
    const messageEl = document.getElementById('notificationModalMessage');
    const iconEl = document.getElementById('notificationModalIcon');
    const closeBtn = document.getElementById('notificationModalCloseBtn');
    const confirmBtn = document.getElementById('notificationModalConfirmBtn');

    // Reset classes
    header.className = 'modal-header border-0 ';
    iconEl.className = 'mb-3 fs-1 ';
    confirmBtn.classList.add('d-none');
    closeBtn.className = 'btn px-4 ';

    // Set content based on type
    switch (type) {
        case 'success':
            header.classList.add('bg-success');
            iconEl.classList.add('fas', 'fa-check-circle', 'text-success');
            closeBtn.classList.add('btn-success');
            break;
        case 'error':
            header.classList.add('bg-danger');
            iconEl.classList.add('fas', 'fa-times-circle', 'text-danger');
            closeBtn.classList.add('btn-danger');
            break;
        case 'confirm':
            header.classList.add('bg-primary');
            iconEl.classList.add('fas', 'fa-question-circle', 'text-primary');
            confirmBtn.classList.remove('d-none');
            confirmBtn.className = 'btn btn-primary px-4';
            closeBtn.classList.add('btn-outline-secondary');
            closeBtn.innerText = 'Cancel';

            // Set up confirm action
            confirmBtn.onclick = function () {
                modal.hide();
                if (callback) callback();
            };
            break;
        default:
            header.classList.add('bg-primary');
            iconEl.classList.add('fas', 'fa-info-circle', 'text-primary');
            closeBtn.classList.add('btn-primary');
    }

    titleEl.innerText = title;
    headingEl.innerText = title;
    messageEl.innerText = message;

    modal.show();
}

/**
 * Finalize payroll for the selected period and post to GL
 */
function finalizePayroll() {
    const payrollMonth = document.getElementById('payroll-month-select')?.value;
    const payrollPeriod = document.getElementById('payroll-period-select')?.value;

    if (!payrollMonth || !payrollPeriod) {
        showPayrollNotification('error', 'Selection Required', 'Please select both payroll month and period.');
        return;
    }

    const periodLabel = document.getElementById('payroll-period-select')?.selectedOptions[0]?.text || payrollPeriod;
    const monthLabel = document.getElementById('payroll-month-select')?.selectedOptions[0]?.text || payrollMonth;

    showPayrollNotification('confirm', 'Confirm Payroll Processing', `Are you sure you want to process and finalize payroll for ${monthLabel} — ${periodLabel}?\n\nThis will create a journal entry in the General Ledger.`, function () {
        // Show loading state on the button
        const btn = document.querySelector('.btn-post-gl');
        let originalHtml = '';
        if (btn) {
            originalHtml = btn.innerHTML;
            btn.disabled = true;
            btn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Posting…';
        }

        $.ajax({
            url: 'api/payroll-actions.php',
            method: 'POST',
            data: {
                action: 'finalize_payroll',
                month: payrollMonth,
                period: payrollPeriod
            },
            success: function (response) {
                if (response.success) {
                    const summary = response.summary
                        ? `\n\nEmployees: ${response.summary.employees}\nGross: ₱${Number(response.summary.total_gross).toLocaleString()}\nNet: ₱${Number(response.summary.total_net).toLocaleString()}`
                        : '';

                    showPayrollNotification('success', 'Success', 'Payroll posted to GL successfully!\nJournal Entry: ' + (response.journal_no || 'N/A') + summary);

                    // Reload after a delay to allow user to see success message
                    setTimeout(() => {
                        window.location.reload();
                    }, 3000);
                } else {
                    showPayrollNotification('error', 'Processing Error', response.error || 'Unknown error');
                    if (btn) { btn.disabled = false; btn.innerHTML = originalHtml; }
                }
            },
            error: function (xhr, status, error) {
                console.error('AJAX Error:', error);
                showPayrollNotification('error', 'Server Error', 'An error occurred during payroll processing. Please check the logs.');
                if (btn) { btn.disabled = false; btn.innerHTML = originalHtml; }
            }
        });
    });
}

// Export functions for global access
window.filterExpenses = filterExpenses;
window.filterTransactions = filterTransactions;
window.filterLoans = filterLoans;
window.exportExpenses = exportExpenses;
window.exportTransactions = exportTransactions;
window.exportLoans = exportLoans;
window.printPayslip = printPayslip;
window.changeEmployee = changeEmployee;
window.changePayrollPeriod = changePayrollPeriod;
window.toggleFilters = toggleFilters;
window.finalizePayroll = finalizePayroll;
window.filterAttendanceByMonth = filterAttendanceByMonth;
window.viewExpense = viewExpense;
window.editExpense = editExpense;
window.viewTransaction = viewTransaction;
window.viewLoan = viewLoan;

