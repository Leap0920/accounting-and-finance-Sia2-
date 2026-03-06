/**
 * Transaction Reading Module JavaScript
 * Handles filtering, export, print, and audit trail functionality
 */

(function () {
    'use strict';

    window.currentTransactionId = null; // Make it globally accessible

    /**
     * Initialize when DOM is ready
     */
    document.addEventListener('DOMContentLoaded', function () {
        initEventHandlers();
        checkUrlFilters();
    });


    /**
     * Initialize all event handlers
     */
    function initEventHandlers() {
        // Show/Hide Filter Panel
        const btnShowFilters = document.getElementById('btnShowFilters');
        const filterPanel = document.getElementById('filterPanel');

        if (btnShowFilters && filterPanel) {
            btnShowFilters.addEventListener('click', function () {
                if (filterPanel.style.display === 'none' || !filterPanel.style.display) {
                    filterPanel.style.display = 'block';
                    this.innerHTML = '<i class="fas fa-times me-1"></i>Hide Filters';
                    this.classList.remove('btn-primary');
                    this.classList.add('btn-secondary');
                } else {
                    filterPanel.style.display = 'none';
                    this.innerHTML = '<i class="fas fa-filter me-1"></i>Apply Filters';
                    this.classList.remove('btn-secondary');
                    this.classList.add('btn-primary');
                }
            });
        }

        // Set max date for date inputs to today
        const today = new Date().toISOString().split('T')[0];
        document.querySelectorAll('input[type="date"]').forEach(input => {
            input.setAttribute('max', today);
        });
    }

    /**
     * Check if filters are applied via URL and show filter panel
     */
    function checkUrlFilters() {
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.has('apply_filters')) {
            const filterPanel = document.getElementById('filterPanel');
            const btnShowFilters = document.getElementById('btnShowFilters');

            if (filterPanel && btnShowFilters) {
                filterPanel.style.display = 'block';
                btnShowFilters.innerHTML = '<i class="fas fa-times me-1"></i>Hide Filters';
                btnShowFilters.classList.remove('btn-primary');
                btnShowFilters.classList.add('btn-secondary');
            }
        }
    }

    /**
     * Clear all filters and reload page
     */
    window.clearFilters = function () {
        window.location.href = window.location.pathname;
    };

    /**
     * Export table data to PDF with professional formatting
     */
    window.exportToPDF = function () {
        const table = document.getElementById('transactionTable');
        const rows = table.querySelectorAll('tbody tr[data-transaction-id]');

        if (rows.length === 0) {
            showNotification('No data available to export', 'warning');
            return;
        }

        showLoading('Generating PDF...');

        try {
            const { jsPDF } = window.jspdf;
            const doc = new jsPDF('portrait', 'mm', 'a4');
            const primaryColor = [27, 62, 62];

            // Header bar
            doc.setFillColor(...primaryColor);
            doc.rect(0, 0, 210, 30, 'F');
            doc.setTextColor(255, 255, 255);
            doc.setFontSize(20);
            doc.setFont('helvetica', 'bold');
            doc.text('EVERGREEN', 14, 15);
            doc.setFontSize(9);
            doc.setFont('helvetica', 'normal');
            doc.text('Secure. Invest. Achieve', 14, 22);

            doc.setFontSize(14);
            doc.setFont('helvetica', 'bold');
            doc.text('Transaction Report', 210 - 14, 15, { align: 'right' });
            doc.setFontSize(9);
            doc.setFont('helvetica', 'normal');
            doc.text('Generated: ' + new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' }), 210 - 14, 22, { align: 'right' });

            // Collect data
            let totalDebit = 0;
            let totalCredit = 0;
            const statusCounts = {};
            const tableData = [];

            rows.forEach(row => {
                const cells = row.querySelectorAll('td');
                if (cells.length >= 8) {
                    const journalNo = cells[0].textContent.trim();
                    const date = cells[1].textContent.trim();
                    const type = cells[2].textContent.trim();
                    const description = cells[3].textContent.trim();
                    const reference = cells[4].textContent.trim();
                    const debit = parseFloat(cells[5].textContent.trim().replace(/[$,]/g, '')) || 0;
                    const credit = parseFloat(cells[6].textContent.trim().replace(/[$,]/g, '')) || 0;
                    const status = cells[7].textContent.trim();

                    totalDebit += debit;
                    totalCredit += credit;
                    statusCounts[status] = (statusCounts[status] || 0) + 1;

                    tableData.push([
                        journalNo, date, type,
                        description.length > 30 ? description.substring(0, 27) + '...' : description,
                        reference,
                        '$' + debit.toLocaleString('en-US', { minimumFractionDigits: 2 }),
                        '$' + credit.toLocaleString('en-US', { minimumFractionDigits: 2 }),
                        status
                    ]);
                }
            });

            // Summary
            doc.setTextColor(0, 0, 0);
            doc.setFontSize(12);
            doc.setFont('helvetica', 'bold');
            doc.text('Summary', 14, 40);
            doc.setFontSize(10);
            doc.setFont('helvetica', 'normal');
            const summaryParts = ['Total: ' + rows.length];
            Object.entries(statusCounts).forEach(([s, c]) => { summaryParts.push(s + ': ' + c); });
            doc.text(summaryParts.join('    '), 14, 47);
            doc.setFont('courier', 'bold');
            doc.text('Debit: $' + totalDebit.toLocaleString('en-US', { minimumFractionDigits: 2 }) + '    Credit: $' + totalCredit.toLocaleString('en-US', { minimumFractionDigits: 2 }), 14, 54);

            // Table
            doc.autoTable({
                startY: 60,
                head: [['Journal No.', 'Date', 'Type', 'Description', 'Ref', 'Debit', 'Credit', 'Status']],
                body: tableData,
                theme: 'grid',
                headStyles: { fillColor: primaryColor, textColor: [255, 255, 255], fontStyle: 'bold', fontSize: 8, halign: 'center', cellPadding: 3 },
                bodyStyles: { fontSize: 8, cellPadding: 3, lineColor: [200, 200, 200], lineWidth: 0.3 },
                columnStyles: {
                    0: { halign: 'left', cellWidth: 22 },
                    1: { halign: 'left', cellWidth: 22 },
                    2: { halign: 'center', cellWidth: 16 },
                    3: { halign: 'left', cellWidth: 40 },
                    4: { halign: 'left', cellWidth: 20 },
                    5: { halign: 'right', cellWidth: 22, font: 'courier' },
                    6: { halign: 'right', cellWidth: 22, font: 'courier' },
                    7: { halign: 'center', cellWidth: 18 }
                },
                alternateRowStyles: { fillColor: [255, 255, 255] },
                styles: { lineColor: [180, 180, 180], lineWidth: 0.3 },
                margin: { left: 14, right: 14 },
                didDrawPage: function (data) {
                    doc.setFontSize(8);
                    doc.setTextColor(128, 128, 128);
                    doc.text('Page ' + data.pageNumber, 105, doc.internal.pageSize.height - 10, { align: 'center' });
                    doc.text('\u00a9 2025 Evergreen Accounting & Finance', 14, doc.internal.pageSize.height - 10);
                }
            });

            // Total row
            const finalY = doc.lastAutoTable.finalY + 5;
            doc.setFillColor(...primaryColor);
            doc.rect(14, finalY, 182, 10, 'F');
            doc.setTextColor(255, 255, 255);
            doc.setFontSize(9);
            doc.setFont('helvetica', 'bold');
            doc.text('TOTAL', 20, finalY + 7);
            doc.setFont('courier', 'bold');
            doc.text('Debit: $' + totalDebit.toLocaleString('en-US', { minimumFractionDigits: 2 }) + '   Credit: $' + totalCredit.toLocaleString('en-US', { minimumFractionDigits: 2 }), 182, finalY + 7, { align: 'right' });

            doc.save('Transaction_Report_' + new Date().toISOString().split('T')[0] + '.pdf');
            hideLoading();
            showNotification('PDF exported successfully!', 'success');
        } catch (error) {
            hideLoading();
            console.error('PDF export error:', error);
            showNotification('Failed to generate PDF: ' + error.message, 'error');
        }
    };



    /**
     * Print transaction table only (strictly hides everything else)
     */
    window.printTable = function () {
        const printStyle = document.createElement('style');
        printStyle.id = 'tr-print-styles';
        printStyle.textContent = `
            @media print {
                @page { 
                    size: landscape; 
                    margin: 10mm;
                }
                
                /* Hide everything except target */
                body > *:not(.tr-container), 
                .tr-container > *:not(.tr-table-section),
                .tr-toolbar, .tr-filter-panel, .tr-pagination, .tr-action-btn,
                nav, .navbar, .sidebar, footer, .modal,
                .tr-table th:last-child, .tr-table td:last-child {
                    display: none !important;
                }
                
                /* Ensure container and table section are visible and clean */
                .tr-container { 
                    padding: 0 !important; 
                    margin: 0 !important; 
                    max-width: 100% !important; 
                    width: 100% !important;
                }
                .tr-table-section { 
                    border: none !important; 
                    box-shadow: none !important; 
                    width: 100% !important;
                    overflow: visible !important;
                }
                
                /* Table styling for print */
                .tr-table { 
                    font-size: 8pt !important; 
                    border: 0.5pt solid #ccc !important;
                    width: 100% !important;
                    table-layout: auto !important;
                }
                .tr-table thead th { 
                    background-color: #f8f9fa !important; 
                    color: #000 !important;
                    font-weight: bold !important;
                    border-bottom: 1pt solid #000 !important;
                    -webkit-print-color-adjust: exact;
                    print-color-adjust: exact;
                }
                .tr-table tbody td { 
                    padding: 4pt 6pt !important;
                    border-bottom: 0.2pt solid #eee !important;
                    word-break: break-word !important;
                }
                .tr-type-badge {
                    border: 0.5pt solid #ddd !important;
                    padding: 0.5pt 3pt !important;
                    background: transparent !important;
                    color: #000 !important;
                }
            }
        `;
        document.head.appendChild(printStyle);
        window.print();
        setTimeout(() => {
            const el = document.getElementById('tr-print-styles');
            if (el) el.remove();
        }, 1000);
    };

    /**
     * View transaction details
     */
    window.viewTransactionDetails = function (transactionId) {
        window.currentTransactionId = transactionId;

        const modal = new bootstrap.Modal(document.getElementById('transactionDetailsModal'));
        const modalBody = document.getElementById('transactionDetailsBody');

        // Show loading state
        modalBody.innerHTML = '<div class="text-center py-4"><div class="spinner-border text-primary" role="status"><span class="visually-hidden">Loading...</span></div><p class="mt-3">Loading transaction details...</p></div>';

        modal.show();

        // Fetch transaction details from API
        fetch(`api/transaction-data.php?action=get_transaction_details&id=${transactionId}`)
            .then(response => response.json())
            .then(data => {
                if (data.success && data.data) {
                    const trans = data.data;
                    const statusClass = {
                        'draft': 'status-draft',
                        'posted': 'status-posted',
                        'reversed': 'status-reversed',
                        'voided': 'status-voided'
                    }[trans.status] || 'badge-secondary';

                    modalBody.innerHTML = `
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <h6 class="text-primary mb-3"><i class="fas fa-info-circle me-2"></i>Transaction Information</h6>
                                <dl class="row mb-0">
                                    <dt class="col-sm-5">Journal No:</dt>
                                    <dd class="col-sm-7"><strong>${trans.journal_no}</strong></dd>
                                    
                                    <dt class="col-sm-5">Type:</dt>
                                    <dd class="col-sm-7"><span class="badge bg-secondary">${trans.type_code}</span> ${trans.type_name}</dd>
                                    
                                    <dt class="col-sm-5">Entry Date:</dt>
                                    <dd class="col-sm-7">${new Date(trans.entry_date).toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' })}</dd>
                                    
                                    <dt class="col-sm-5">Status:</dt>
                                    <dd class="col-sm-7"><span class="badge ${statusClass}">${trans.status.toUpperCase()}</span></dd>
                                    
                                    <dt class="col-sm-5">Reference No:</dt>
                                    <dd class="col-sm-7">${trans.reference_no || '-'}</dd>
                                </dl>
                            </div>
                            <div class="col-md-6">
                                <h6 class="text-primary mb-3"><i class="fas fa-user me-2"></i>User Information</h6>
                                <dl class="row mb-0">
                                    <dt class="col-sm-5">Created By:</dt>
                                    <dd class="col-sm-7">${trans.created_by_name}</dd>
                                    
                                    <dt class="col-sm-5">Created At:</dt>
                                    <dd class="col-sm-7">${new Date(trans.created_at).toLocaleString('en-US')}</dd>
                                    
                                    ${trans.posted_by ? `
                                        <dt class="col-sm-5">Posted By:</dt>
                                        <dd class="col-sm-7">${trans.posted_by_name}</dd>
                                        
                                        <dt class="col-sm-5">Posted At:</dt>
                                        <dd class="col-sm-7">${new Date(trans.posted_at).toLocaleString('en-US')}</dd>
                                    ` : ''}
                                    
                                    <dt class="col-sm-5">Fiscal Period:</dt>
                                    <dd class="col-sm-7">${trans.fiscal_period || 'Not specified'}</dd>
                                </dl>
                            </div>
                        </div>
                        
                        ${trans.description ? `
                            <div class="mb-3">
                                <h6 class="text-primary"><i class="fas fa-comment me-2"></i>Description</h6>
                                <p class="mb-0">${trans.description}</p>
                            </div>
                        ` : ''}
                    `;
                } else {
                    modalBody.innerHTML = `
                        <div class="alert alert-warning">
                            <i class="fas fa-exclamation-triangle me-2"></i>
                            ${data.error || 'Unable to load transaction details. Please try again.'}
                        </div>
                    `;
                }
            })
            .catch(error => {
                console.error('Error loading transaction details:', error);
                modalBody.innerHTML = `
                    <div class="alert alert-danger">
                        <i class="fas fa-exclamation-circle me-2"></i>
                        Error loading transaction details: ${error.message}
                    </div>
                `;
            });
    };

    /**
     * View audit trail for current/all transactions
     */
    window.viewAuditTrail = function (transactionId) {
        if (transactionId) {
            window.currentTransactionId = transactionId;
        }

        const modal = new bootstrap.Modal(document.getElementById('auditTrailModal'));
        const modalBody = document.getElementById('auditTrailBody');
        const modalTitle = document.getElementById('auditTrailModalLabel');

        // Update modal title
        if (transactionId) {
            modalTitle.innerHTML = '<i class="fas fa-history me-2"></i>Audit Trail - Transaction #' + transactionId;
        } else {
            modalTitle.innerHTML = '<i class="fas fa-history me-2"></i>Audit Trail - All Transactions';
        }

        // Show loading state
        modalBody.innerHTML = '<tr><td colspan="7" class="text-center py-4"><div class="spinner-border text-primary" role="status"><span class="visually-hidden">Loading...</span></div><p class="mt-3">Loading audit trail...</p></td></tr>';

        modal.show();

        // Fetch audit trail from API
        const url = transactionId
            ? `api/transaction-data.php?action=get_audit_trail&id=${transactionId}`
            : `api/transaction-data.php?action=get_audit_trail`;

        fetch(url)
            .then(response => response.json())
            .then(data => {
                if (data.success && data.data && data.data.length > 0) {
                    let html = '';
                    data.data.forEach(log => {
                        const timestamp = new Date(log.created_at).toLocaleString('en-US', {
                            year: 'numeric',
                            month: 'short',
                            day: 'numeric',
                            hour: '2-digit',
                            minute: '2-digit'
                        });

                        const actionBadge = {
                            'create': 'badge bg-success',
                            'update': 'badge bg-info',
                            'delete': 'badge bg-danger',
                            'post': 'badge bg-primary',
                            'reverse': 'badge bg-warning',
                            'void': 'badge bg-dark'
                        }[log.action] || 'badge bg-secondary';

                        html += `
                            <tr>
                                <td>${timestamp}</td>
                                <td>${log.full_name || log.username || 'System'}</td>
                                <td><span class="${actionBadge}">${log.action.toUpperCase()}</span></td>
                                <td>${log.object_type}</td>
                                <td>#${log.object_id}</td>
                                <td>${log.ip_address || '-'}</td>
                                <td><small>${log.details || '-'}</small></td>
                            </tr>
                        `;
                    });
                    modalBody.innerHTML = html;
                } else {
                    modalBody.innerHTML = `
                        <tr>
                            <td colspan="7" class="text-center text-muted py-4">
                                <i class="fas fa-info-circle fa-2x mb-3 d-block"></i>
                                <p>No audit trail entries found${transactionId ? ' for this transaction' : ''}.</p>
                                <small>Audit logs will appear here when actions are performed on transactions.</small>
                            </td>
                        </tr>
                    `;
                }
            })
            .catch(error => {
                console.error('Error loading audit trail:', error);
                modalBody.innerHTML = `
                    <tr>
                        <td colspan="7" class="text-center text-danger py-4">
                            <i class="fas fa-exclamation-circle fa-2x mb-3 d-block"></i>
                            <p>Error loading audit trail: ${error.message}</p>
                            <small>Please try again or contact system administrator.</small>
                        </td>
                    </tr>
                `;
            });
    };

    /**
     * Export audit trail
     */
    window.exportAuditTrail = function () {
        showNotification('Audit trail export feature will be available when connected to database', 'info');
    };

    /**
     * Delete transaction (soft delete - move to bin)
     */
    window.deleteTransaction = function (transactionId) {
        console.log('Delete transaction called with ID:', transactionId);
        console.log('Transaction ID type:', typeof transactionId);
        console.log('Transaction ID value:', transactionId);

        if (!transactionId || transactionId === 'undefined' || transactionId === 'null') {
            showNotification('Error: Invalid transaction ID', 'error');
            return;
        }

        // Show custom confirmation modal instead of browser confirm
        const modal = new bootstrap.Modal(document.getElementById('deleteConfirmModal'));
        const confirmBtn = document.getElementById('confirmDeleteBtn');

        // Remove any existing event listeners
        const newConfirmBtn = confirmBtn.cloneNode(true);
        confirmBtn.parentNode.replaceChild(newConfirmBtn, confirmBtn);

        // Add click handler for this specific deletion
        newConfirmBtn.addEventListener('click', function () {
            modal.hide();
            performDeleteTransaction(transactionId);
        });

        modal.show();
    };

    // Actual delete function
    function performDeleteTransaction(transactionId) {
        // Show loading
        showLoading('Moving transaction to bin...');

        // Send the FULL transaction ID (e.g., "JE-12") so the API knows it's a journal entry
        // The API will extract the numeric ID and validate the source
        const url = 'api/transaction-data.php';
        const data = `action=soft_delete_transaction&transaction_id=${encodeURIComponent(transactionId)}`;

        console.log('===== DELETE REQUEST DETAILS =====');
        console.log('Making request to:', url);
        console.log('With data:', data);
        console.log('Full URL will be:', window.location.origin + window.location.pathname.replace('transaction-reading.php', '') + url);
        console.log('==================================');

        fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: data
        })
            .then(response => {
                console.log('===== RESPONSE RECEIVED =====');
                console.log('Response status:', response.status);
                console.log('Response ok:', response.ok);
                console.log('Response type:', response.type);
                console.log('Response URL:', response.url);

                // Check if response is ok before trying to parse JSON
                if (!response.ok) {
                    // Try to get error message from response
                    return response.text().then(text => {
                        console.error('ERROR RESPONSE TEXT:', text);
                        let errorMessage = `HTTP error! status: ${response.status}`;
                        try {
                            const errorData = JSON.parse(text);
                            console.error('Parsed error data:', errorData);
                            if (errorData.error) {
                                errorMessage += ` - ${errorData.error}`;
                            }
                        } catch (e) {
                            console.error('Could not parse error as JSON:', e);
                            // If not JSON, include raw text
                            if (text.length > 0) {
                                errorMessage += ` - ${text.substring(0, 200)}`;
                            }
                        }
                        throw new Error(errorMessage);
                    });
                }

                // Get response text first to debug
                return response.text().then(text => {
                    console.log('Raw response text:', text);
                    try {
                        return JSON.parse(text);
                    } catch (parseError) {
                        console.error('JSON parse error:', parseError);
                        console.error('Response text that failed to parse:', text);
                        throw new Error('Invalid JSON response from server');
                    }
                });
            })
            .then(data => {
                console.log('Response data:', data);
                hideLoading();
                if (data.success) {
                    // Show appropriate message based on what actually happened
                    let message = data.message || 'Transaction processed successfully!';
                    let notificationType = 'success';

                    // If soft delete is not available, explain what happened
                    if (data.soft_delete_available === false) {
                        message = 'Transaction voided successfully! It has been moved to the bin station where you can restore it later.';
                        notificationType = 'info';
                    } else {
                        message = 'Transaction deleted successfully! It has been moved to the bin station where you can restore it later.';
                    }

                    showNotification(message, notificationType);

                    // Immediately remove the row from the table (real-time update)
                    const table = document.getElementById('transactionTable');
                    if (table) {
                        const rowToRemove = table.querySelector(`tr[data-transaction-id="${transactionId}"]`);
                        if (rowToRemove) {
                            // Remove directly from DOM
                            rowToRemove.remove();
                            console.log('Row removed from table');
                        } else {
                            // Fallback: reload page if row not found
                            console.warn('Row not found, reloading page');
                            setTimeout(() => {
                                window.location.reload();
                            }, 1000);
                        }
                    }
                } else {
                    showNotification('Delete failed: ' + (data.error || 'Unknown error'), 'error');
                }
            })
            .catch(error => {
                console.error('Fetch error:', error);
                hideLoading();

                // Try to get more specific error information
                if (error.message.includes('HTTP error! status: 400')) {
                    showNotification('Delete failed: Bad request (400) - Check console for details', 'error');
                } else {
                    showNotification('Delete failed: ' + error.message, 'error');
                }
            });
    };

    /**
     * Get current filter parameters
     */
    function getCurrentFilters() {
        const params = new URLSearchParams();

        const dateFrom = document.getElementById('date_from');
        const dateTo = document.getElementById('date_to');
        const type = document.getElementById('type');
        const status = document.getElementById('status');
        const account = document.getElementById('account');

        if (dateFrom && dateFrom.value) params.append('date_from', dateFrom.value);
        if (dateTo && dateTo.value) params.append('date_to', dateTo.value);
        if (type && type.value) params.append('type', type.value);
        if (status && status.value) params.append('status', status.value);
        if (account && account.value) params.append('account', account.value);

        return params.toString();
    }

    /**
     * Show loading overlay
     */
    function showLoading(message = 'Loading...') {
        const overlay = document.createElement('div');
        overlay.className = 'spinner-overlay';
        overlay.id = 'loadingOverlay';
        overlay.innerHTML = `
            <div class="text-center">
                <div class="spinner-border text-light" role="status">
                    <span class="visually-hidden">Loading...</span>
                </div>
                <p class="text-white mt-3">${message}</p>
            </div>
        `;
        document.body.appendChild(overlay);
    }

    /**
     * Hide loading overlay
     */
    function hideLoading() {
        const overlay = document.getElementById('loadingOverlay');
        if (overlay) {
            overlay.remove();
        }
    }

    /**
     * Show notification toast
     */
    function showNotification(message, type = 'success') {
        const alertClass = type === 'error' ? 'alert-danger' :
            type === 'warning' ? 'alert-warning' :
                type === 'info' ? 'alert-info' : 'alert-success';

        const iconClass = type === 'error' ? 'fa-exclamation-circle' :
            type === 'warning' ? 'fa-exclamation-triangle' :
                type === 'info' ? 'fa-info-circle' : 'fa-check-circle';

        const toast = document.createElement('div');
        toast.className = `alert ${alertClass} alert-dismissible fade show position-fixed top-0 start-50 translate-middle-x mt-3`;
        toast.style.zIndex = '9999';
        toast.style.minWidth = '300px';
        toast.innerHTML = `
            <i class="fas ${iconClass} me-2"></i>
            ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        `;

        document.body.appendChild(toast);

        setTimeout(function () {
            toast.remove();
        }, 5000);
    }

    // Note: Transaction data is now loaded via PHP server-side rendering
    // No need for AJAX data loading

    /**
     * Sample function to populate transaction data (for demo)
     * In production, this would be replaced with actual database queries
     */
    window.loadSampleData = function () {
        showNotification('Sample data loading is disabled. Connect to database to load actual transactions.', 'info');
    };

    /**
     * Sync bank transactions to journal entries
     */
    window.syncBankTransactions = function () {
        const btn = document.getElementById('btnSyncBankTransactions');
        const originalText = btn.innerHTML;

        // Disable button and show loading
        btn.disabled = true;
        btn.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i>Syncing...';

        showLoading('Syncing bank transactions to journal entries...');

        fetch('../modules/api/transaction-data.php?action=sync_bank_transactions', {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        })
            .then(response => response.json())
            .then(data => {
                hideLoading();
                btn.disabled = false;
                btn.innerHTML = originalText;

                if (data.success) {
                    const message = data.synced_count > 0
                        ? `Successfully synced ${data.synced_count} bank transaction(s) to journal entries.`
                        : 'No new bank transactions to sync.';

                    showNotification(message, 'success');

                    if (data.has_errors && data.errors.length > 0) {
                        console.warn('Sync errors:', data.errors);
                        setTimeout(() => {
                            showNotification('Some transactions had errors. Check console for details.', 'warning');
                        }, 2000);
                    }

                    // Reload page after 2 seconds to show new transactions
                    if (data.synced_count > 0) {
                        setTimeout(() => {
                            window.location.reload();
                        }, 2000);
                    }
                } else {
                    showNotification('Error: ' + (data.error || 'Failed to sync bank transactions'), 'error');
                }
            })
            .catch(error => {
                hideLoading();
                btn.disabled = false;
                btn.innerHTML = originalText;
                console.error('Sync error:', error);
                showNotification('Error syncing bank transactions: ' + error.message, 'error');
            });
    };

})();

