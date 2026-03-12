<?php
require_once '../config/database.php';
require_once '../includes/session.php';

requireLogin();
requireRole(['Administrator']);
$current_user = getCurrentUser();

$active_view = $_GET['view'] ?? 'system-activity';
if (!in_array($active_view, ['system-activity', 'super-audit'], true)) {
    $active_view = 'system-activity';
}

$date_from = $_GET['date_from'] ?? '';
$date_to = $_GET['date_to'] ?? '';
$module = $_GET['module'] ?? '';
$action = $_GET['action'] ?? '';
$user_id = $_GET['user_id'] ?? '';

$sa_date_from = $_GET['sa_date_from'] ?? '';
$sa_date_to = $_GET['sa_date_to'] ?? '';
$sa_module = $_GET['sa_module'] ?? '';
$sa_action_type = $_GET['sa_action_type'] ?? '';
$sa_role = $_GET['sa_role'] ?? '';
$sa_user_id = $_GET['sa_user_id'] ?? '';

function auditTableExists($conn, $table_name)
{
    if (!$conn) {
        return false;
    }

    $safe_table_name = $conn->real_escape_string($table_name);
    $result = $conn->query("SHOW TABLES LIKE '{$safe_table_name}'");

    return $result && $result->num_rows > 0;
}

function formatAuditLabel($value)
{
    return ucwords(str_replace('_', ' ', (string) $value));
}

$has_activity_table = auditTableExists($conn, 'activity_logs');
$has_super_audit_table = auditTableExists($conn, 'super_audit_logs');

$activity_logs = [];
$super_audit_logs = [];
$modules = [];
$actions = [];
$users = [];
$sa_modules = [];
$sa_action_types = [];
$sa_users = [];
$sa_roles = [];

if ($conn && $has_activity_table) {
    $activity_sql = "SELECT
                        al.id,
                        al.user_id,
                        al.action,
                        al.module,
                        al.details,
                        al.ip_address,
                        al.created_at,
                        u.full_name AS user_name,
                        u.username
                    FROM activity_logs al
                    LEFT JOIN users u ON al.user_id = u.id
                    WHERE 1=1";
    $activity_params = [];
    $activity_types = '';

    if ($date_from !== '') {
        $activity_sql .= ' AND DATE(al.created_at) >= ?';
        $activity_params[] = $date_from;
        $activity_types .= 's';
    }

    if ($date_to !== '') {
        $activity_sql .= ' AND DATE(al.created_at) <= ?';
        $activity_params[] = $date_to;
        $activity_types .= 's';
    }

    if ($module !== '') {
        $activity_sql .= ' AND al.module = ?';
        $activity_params[] = $module;
        $activity_types .= 's';
    }

    if ($action !== '') {
        $activity_sql .= ' AND al.action = ?';
        $activity_params[] = $action;
        $activity_types .= 's';
    }

    if ($user_id !== '') {
        $activity_sql .= ' AND al.user_id = ?';
        $activity_params[] = (int) $user_id;
        $activity_types .= 'i';
    }

    $activity_sql .= ' ORDER BY al.created_at DESC LIMIT 1000';
    $stmt = $conn->prepare($activity_sql);

    if ($stmt) {
        if ($activity_params) {
            $stmt->bind_param($activity_types, ...$activity_params);
        }

        $stmt->execute();
        $result = $stmt->get_result();

        while ($row = $result->fetch_assoc()) {
            $activity_logs[] = $row;
        }

        $stmt->close();
    }

    $result = $conn->query("SELECT DISTINCT module FROM activity_logs WHERE module IS NOT NULL AND module != '' ORDER BY module");
    if ($result) {
        while ($row = $result->fetch_assoc()) {
            $modules[] = $row['module'];
        }
    }

    $result = $conn->query("SELECT DISTINCT action FROM activity_logs WHERE action IS NOT NULL AND action != '' ORDER BY action");
    if ($result) {
        while ($row = $result->fetch_assoc()) {
            $actions[] = $row['action'];
        }
    }

    $result = $conn->query("SELECT DISTINCT u.id, u.full_name, u.username
                            FROM activity_logs al
                            INNER JOIN users u ON al.user_id = u.id
                            ORDER BY u.full_name");
    if ($result) {
        while ($row = $result->fetch_assoc()) {
            $users[] = $row;
        }
    }
}

if ($conn && $has_super_audit_table) {
    $super_sql = "SELECT
                    sal.id,
                    sal.user_id,
                    sal.user_role,
                    sal.action_type,
                    sal.module,
                    sal.element_tag,
                    sal.element_id,
                    sal.element_class,
                    sal.element_text,
                    sal.element_href,
                    sal.page_url,
                    sal.ip_address,
                    sal.created_at,
                    u.full_name AS user_name,
                    u.username
                FROM super_audit_logs sal
                LEFT JOIN users u ON sal.user_id = u.id
                WHERE sal.user_role IN ('Accounting Admin', 'HR Manager')";
    $super_params = [];
    $super_types = '';

    if ($sa_date_from !== '') {
        $super_sql .= ' AND DATE(sal.created_at) >= ?';
        $super_params[] = $sa_date_from;
        $super_types .= 's';
    }

    if ($sa_date_to !== '') {
        $super_sql .= ' AND DATE(sal.created_at) <= ?';
        $super_params[] = $sa_date_to;
        $super_types .= 's';
    }

    if ($sa_module !== '') {
        $super_sql .= ' AND sal.module = ?';
        $super_params[] = $sa_module;
        $super_types .= 's';
    }

    if ($sa_action_type !== '') {
        $super_sql .= ' AND sal.action_type = ?';
        $super_params[] = $sa_action_type;
        $super_types .= 's';
    }

    if ($sa_role !== '') {
        $super_sql .= ' AND sal.user_role = ?';
        $super_params[] = $sa_role;
        $super_types .= 's';
    }

    if ($sa_user_id !== '') {
        $super_sql .= ' AND sal.user_id = ?';
        $super_params[] = (int) $sa_user_id;
        $super_types .= 'i';
    }

    $super_sql .= ' ORDER BY sal.created_at DESC LIMIT 2000';
    $stmt = $conn->prepare($super_sql);

    if ($stmt) {
        if ($super_params) {
            $stmt->bind_param($super_types, ...$super_params);
        }

        $stmt->execute();
        $result = $stmt->get_result();

        while ($row = $result->fetch_assoc()) {
            $super_audit_logs[] = $row;
        }

        $stmt->close();
    }

    $result = $conn->query("SELECT DISTINCT module FROM super_audit_logs WHERE module IS NOT NULL AND module != '' ORDER BY module");
    if ($result) {
        while ($row = $result->fetch_assoc()) {
            $sa_modules[] = $row['module'];
        }
    }

    $result = $conn->query("SELECT DISTINCT action_type FROM super_audit_logs WHERE action_type IS NOT NULL AND action_type != '' ORDER BY action_type");
    if ($result) {
        while ($row = $result->fetch_assoc()) {
            $sa_action_types[] = $row['action_type'];
        }
    }

    $result = $conn->query("SELECT DISTINCT user_role FROM super_audit_logs WHERE user_role IN ('Accounting Admin', 'HR Manager') ORDER BY user_role");
    if ($result) {
        while ($row = $result->fetch_assoc()) {
            $sa_roles[] = $row['user_role'];
        }
    }

    $result = $conn->query("SELECT DISTINCT u.id, u.full_name, u.username
                            FROM super_audit_logs sal
                            INNER JOIN users u ON sal.user_id = u.id
                            WHERE sal.user_role IN ('Accounting Admin', 'HR Manager')
                            ORDER BY u.full_name");
    if ($result) {
        while ($row = $result->fetch_assoc()) {
            $sa_users[] = $row;
        }
    }
}

$activity_count = count($activity_logs);
$super_audit_count = count($super_audit_logs);
$latest_super_audit_date = $super_audit_logs[0]['created_at'] ?? null;

$action_icons = [
    'page_visit' => 'fas fa-door-open',
    'button_click' => 'fas fa-mouse-pointer',
    'link_click' => 'fas fa-link',
    'form_submit' => 'fas fa-paper-plane',
    'modal_open' => 'fas fa-window-maximize',
    'tab_switch' => 'fas fa-layer-group',
    'dropdown_select' => 'fas fa-caret-square-down'
];

$action_badge_classes = [
    'page_visit' => 'audit-badge-page-visit',
    'button_click' => 'audit-badge-button-click',
    'link_click' => 'audit-badge-link-click',
    'form_submit' => 'audit-badge-form-submit',
    'modal_open' => 'audit-badge-modal-open',
    'tab_switch' => 'audit-badge-tab-switch',
    'dropdown_select' => 'audit-badge-dropdown-select'
];
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Activity Log - Accounting and Finance System</title>
    <link rel="icon" type="image/png" href="../assets/image/LOGO.png">
    <link rel="shortcut icon" type="image/png" href="../assets/image/LOGO.png">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.7/css/dataTables.bootstrap5.min.css">
    <link rel="stylesheet" href="../assets/css/style.css">
    <link rel="stylesheet" href="../assets/css/dashboard.css">
    <link rel="stylesheet" href="../assets/css/financial-reporting.css">
    <style>
        .header-info-card .info-item + .info-item {
            border-top: 1px solid #edf2f7;
            margin-top: 0.55rem;
            padding-top: 0.9rem;
        }

        .header-info-card .info-value.stat-count {
            font-size: 1rem;
            font-weight: 700;
            color: #0A3D3D;
        }

        .header-info-card .info-value.stat-date {
            font-weight: 700;
        }

        .reports-section {
            margin-top: 0.5rem;
        }

        .audit-filter-card {
            background: #fff;
            border: 1px solid #e8ecf0;
            border-radius: 16px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.06);
            padding: 1.5rem;
            margin-bottom: 1.5rem;
        }

        .audit-filter-header {
            display: flex;
            align-items: flex-start;
            gap: 0.85rem;
            padding-bottom: 1rem;
            margin-bottom: 1.25rem;
            border-bottom: 1px solid #edf2f7;
        }

        .audit-filter-icon {
            width: 42px;
            height: 42px;
            border-radius: 12px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background: rgba(10, 61, 61, 0.08);
            color: #0A3D3D;
            font-size: 0.95rem;
            flex-shrink: 0;
        }

        .filter-title {
            color: #1a1d21;
            font-size: 0.98rem;
            font-weight: 700;
            margin-bottom: 0.2rem;
        }

        .filter-subtitle {
            color: #718096;
            font-size: 0.84rem;
            line-height: 1.55;
        }

        .audit-filter-card .form-label {
            font-size: 0.78rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            color: #4a5568;
        }

        .audit-filter-card .form-control,
        .audit-filter-card .form-select {
            border-radius: 10px;
            border: 1px solid #d9e2ec;
            min-height: 46px;
            box-shadow: none;
        }

        .audit-filter-card .form-control:focus,
        .audit-filter-card .form-select:focus {
            border-color: #0A3D3D;
            box-shadow: 0 0 0 0.18rem rgba(10, 61, 61, 0.12);
        }

        .audit-filter-card .btn {
            border-radius: 10px;
            font-weight: 600;
        }

        .audit-section-card {
            background: #fff;
            border: 1px solid #e8ecf0;
            border-radius: 16px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.06);
            overflow: hidden;
        }

        .card-header-teal {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
            background: linear-gradient(135deg, #0A3D3D 0%, #165A5A 100%);
            color: #fff;
            padding: 1rem 1.4rem;
        }

        .card-header-teal h5 {
            margin: 0;
            font-size: 0.98rem;
            font-weight: 700;
        }

        .card-body-inner {
            padding: 1.35rem 1.4rem 1.4rem;
        }

        .audit-record-badge {
            background: rgba(255, 255, 255, 0.92);
            color: #1a202c;
            border-radius: 999px;
            font-size: 0.76rem;
            font-weight: 700;
            padding: 0.45rem 0.8rem;
        }

        .audit-pill {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.35rem;
            border-radius: 999px;
            padding: 0.38rem 0.7rem;
            font-size: 0.74rem;
            font-weight: 700;
            line-height: 1;
        }

        .audit-pill-module {
            background: rgba(8, 145, 178, 0.12);
            color: #0c7489;
        }

        .audit-pill-system-action {
            background: rgba(34, 197, 94, 0.12);
            color: #15803d;
        }

        .audit-pill-role-cfo {
            background: rgba(37, 99, 235, 0.12);
            color: #1d4ed8;
        }

        .audit-pill-role-hr {
            background: rgba(22, 163, 74, 0.12);
            color: #15803d;
        }

        .badge-action {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            border-radius: 999px;
            padding: 0.42rem 0.78rem;
            font-size: 0.74rem;
            font-weight: 700;
            line-height: 1;
        }

        .audit-badge-page-visit {
            background: #0891b2;
            color: #fff;
        }

        .audit-badge-button-click {
            background: #2563eb;
            color: #fff;
        }

        .audit-badge-link-click {
            background: #475569;
            color: #fff;
        }

        .audit-badge-form-submit {
            background: #f59e0b;
            color: #1f2937;
        }

        .audit-badge-modal-open {
            background: #7c3aed;
            color: #fff;
        }

        .audit-badge-tab-switch {
            background: #16a34a;
            color: #fff;
        }

        .audit-badge-dropdown-select {
            background: #111827;
            color: #fff;
        }

        .audit-table thead th {
            border-bottom: 1px solid #e5e7eb;
            color: #4a5568;
            font-size: 0.76rem;
            font-weight: 700;
            letter-spacing: 0.04em;
            text-transform: uppercase;
            white-space: nowrap;
        }

        .audit-table tbody td {
            vertical-align: middle;
            padding-top: 0.95rem;
            padding-bottom: 0.95rem;
        }

        .audit-timestamp {
            color: #718096;
            font-size: 0.8rem;
            line-height: 1.45;
        }

        .audit-user strong {
            color: #1a202c;
            font-size: 0.92rem;
        }

        .audit-detail {
            color: #4a5568;
            font-size: 0.88rem;
            line-height: 1.55;
        }

        .audit-element-meta {
            display: flex;
            flex-direction: column;
            gap: 0.25rem;
            font-size: 0.78rem;
            color: #718096;
        }

        .audit-element-meta strong {
            color: #2d3748;
            font-size: 0.86rem;
        }

        .audit-page-url {
            max-width: 250px;
            word-break: break-word;
        }

        .audit-ip {
            display: inline-block;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            padding: 0.25rem 0.5rem;
            color: #334155;
        }

        .audit-empty-state {
            text-align: center;
            padding: 3rem 1rem;
        }

        .audit-empty-state-icon {
            width: 74px;
            height: 74px;
            margin: 0 auto 1rem;
            border-radius: 22px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, rgba(10, 61, 61, 0.08) 0%, rgba(22, 90, 90, 0.14) 100%);
            color: #0A3D3D;
            font-size: 1.6rem;
        }

        .audit-empty-state h5 {
            color: #1a202c;
            font-weight: 700;
            margin-bottom: 0.45rem;
        }

        .audit-empty-state p {
            max-width: 520px;
            margin: 0 auto;
            color: #718096;
            line-height: 1.6;
        }

        @media (max-width: 991px) {
            .card-header-teal {
                flex-direction: column;
                align-items: flex-start;
            }

            .card-body-inner,
            .audit-filter-card,
            .tab-pane-inner {
                padding-left: 1rem;
                padding-right: 1rem;
            }
        }

        @media (max-width: 767px) {
            .audit-filter-header {
                align-items: flex-start;
            }

            .audit-record-badge {
                align-self: flex-start;
            }
        }
    </style>
</head>

<body>
    <?php include '../includes/navbar.php'; ?>

    <main class="container-fluid py-4">
        <div class="beautiful-page-header mb-5">
            <div class="container-fluid">
                <div class="row align-items-center">
                    <div class="col-lg-7">
                        <div class="header-content">
                            <h1 class="page-title-beautiful">
                                <i class="fas fa-history me-3"></i>
                                Activity Log
                            </h1>
                            <p class="page-subtitle-beautiful">
                                Review system events and the full CFO or HR behavioral audit stream from one administrator console.
                            </p>
                        </div>
                    </div>
                    <div class="col-lg-5 text-lg-end">
                        <div class="header-info-card">
                            <div class="info-item">
                                <div class="info-icon">
                                    <i class="fas fa-database"></i>
                                </div>
                                <div class="info-content">
                                    <div class="info-label">System Activity</div>
                                    <div class="info-value"><?php echo $activity_count; ?></div>
                                </div>
                            </div>
                            <div class="info-item">
                                <div class="info-icon">
                                    <i class="fas fa-user-shield"></i>
                                </div>
                                <div class="info-content">
                                    <div class="info-label">Super Audit</div>
                                    <div class="info-value"><?php echo $super_audit_count; ?></div>
                                </div>
                            </div>
                            <div class="info-item">
                                <div class="info-icon">
                                    <i class="fas fa-calendar-alt"></i>
                                </div>
                                <div class="info-content">
                                    <div class="info-label">Latest Audit</div>
                                    <div class="info-value"><?php echo $latest_super_audit_date ? date('M d, Y', strtotime($latest_super_audit_date)) : 'N/A'; ?></div>
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

        <div class="reports-section">
            <ul class="nav nav-tabs report-tabs mb-0" id="auditTabs" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link <?php echo $active_view === 'system-activity' ? 'active' : ''; ?>" id="system-activity-tab"
                        data-bs-toggle="tab" data-bs-target="#system-activity-pane" type="button" role="tab"
                        aria-controls="system-activity-pane" aria-selected="<?php echo $active_view === 'system-activity' ? 'true' : 'false'; ?>">
                        <i class="fas fa-list me-2"></i>System Activity
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link <?php echo $active_view === 'super-audit' ? 'active' : ''; ?>" id="super-audit-tab"
                        data-bs-toggle="tab" data-bs-target="#super-audit-pane" type="button" role="tab"
                        aria-controls="super-audit-pane" aria-selected="<?php echo $active_view === 'super-audit' ? 'true' : 'false'; ?>">
                        <i class="fas fa-user-shield me-2"></i>Super Audit
                    </button>
                </li>
            </ul>

            <div class="tab-content report-tab-content" id="auditTabsContent">
                <div class="tab-pane fade <?php echo $active_view === 'system-activity' ? 'show active' : ''; ?>" id="system-activity-pane" role="tabpanel" aria-labelledby="system-activity-tab">
                    <div class="tab-pane-inner">
                        <div class="audit-filter-card">
                            <div class="audit-filter-header">
                                <div class="audit-filter-icon">
                                    <i class="fas fa-filter"></i>
                                </div>
                                <div>
                                    <div class="filter-title">Filter System Activity</div>
                                    <div class="filter-subtitle">Track high-level user actions and system events across the platform with fast filtering by date, module, action, and user.</div>
                                </div>
                            </div>

                            <form method="GET" class="row g-3">
                                <input type="hidden" name="view" value="system-activity">
                                <div class="col-md-3">
                                    <label for="date_from" class="form-label">From Date</label>
                                    <input type="date" class="form-control" id="date_from" name="date_from" value="<?php echo htmlspecialchars($date_from); ?>">
                                </div>
                                <div class="col-md-3">
                                    <label for="date_to" class="form-label">To Date</label>
                                    <input type="date" class="form-control" id="date_to" name="date_to" value="<?php echo htmlspecialchars($date_to); ?>">
                                </div>
                                <div class="col-md-2">
                                    <label for="module" class="form-label">Module</label>
                                    <select class="form-select" id="module" name="module">
                                        <option value="">All Modules</option>
                                        <?php foreach ($modules as $module_option): ?>
                                            <option value="<?php echo htmlspecialchars($module_option); ?>" <?php echo $module === $module_option ? 'selected' : ''; ?>>
                                                <?php echo htmlspecialchars(formatAuditLabel($module_option)); ?>
                                            </option>
                                        <?php endforeach; ?>
                                    </select>
                                </div>
                                <div class="col-md-2">
                                    <label for="action" class="form-label">Action</label>
                                    <select class="form-select" id="action" name="action">
                                        <option value="">All Actions</option>
                                        <?php foreach ($actions as $action_option): ?>
                                            <option value="<?php echo htmlspecialchars($action_option); ?>" <?php echo $action === $action_option ? 'selected' : ''; ?>>
                                                <?php echo htmlspecialchars(formatAuditLabel($action_option)); ?>
                                            </option>
                                        <?php endforeach; ?>
                                    </select>
                                </div>
                                <div class="col-md-2">
                                    <label for="user_id" class="form-label">User</label>
                                    <select class="form-select" id="user_id" name="user_id">
                                        <option value="">All Users</option>
                                        <?php foreach ($users as $user): ?>
                                            <option value="<?php echo $user['id']; ?>" <?php echo (string) $user_id === (string) $user['id'] ? 'selected' : ''; ?>>
                                                <?php echo htmlspecialchars($user['full_name']); ?>
                                            </option>
                                        <?php endforeach; ?>
                                    </select>
                                </div>
                                <div class="col-12">
                                    <div class="filter-actions">
                                        <button type="submit" class="btn btn-primary btn-lg me-3 px-4">
                                            <i class="fas fa-search me-2"></i>Apply Filters
                                        </button>
                                        <a href="activity-log.php?view=system-activity" class="btn btn-outline-secondary btn-lg px-3">
                                            <i class="fas fa-times me-1"></i>Clear
                                        </a>
                                    </div>
                                </div>
                            </form>
                        </div>

                        <div class="audit-section-card mt-2">
                            <div class="card-header-teal">
                                <h5><i class="fas fa-list me-2"></i>System Activity Logs</h5>
                                <span class="audit-record-badge"><?php echo $activity_count; ?> records</span>
                            </div>
                            <div class="card-body-inner">
                                <?php if ($activity_count > 0): ?>
                                    <div class="table-responsive">
                                        <table class="table table-hover audit-table" id="activityTable">
                                            <thead>
                                                <tr>
                                                    <th>Timestamp</th>
                                                    <th>User</th>
                                                    <th>Module</th>
                                                    <th>Action</th>
                                                    <th>Details</th>
                                                    <th>IP Address</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <?php foreach ($activity_logs as $log): ?>
                                                    <tr>
                                                        <td>
                                                            <div class="audit-timestamp">
                                                                <?php echo date('M d, Y', strtotime($log['created_at'])); ?><br>
                                                                <?php echo date('H:i:s', strtotime($log['created_at'])); ?>
                                                            </div>
                                                        </td>
                                                        <td>
                                                            <div class="audit-user">
                                                                <strong><?php echo htmlspecialchars($log['user_name'] ?? 'Unknown'); ?></strong><br>
                                                                <small class="text-muted"><?php echo htmlspecialchars($log['username'] ?? ''); ?></small>
                                                            </div>
                                                        </td>
                                                        <td><span class="audit-pill audit-pill-module"><?php echo htmlspecialchars(formatAuditLabel($log['module'] ?? 'Unknown')); ?></span></td>
                                                        <td><span class="audit-pill audit-pill-system-action"><?php echo htmlspecialchars(formatAuditLabel($log['action'] ?? 'Unknown')); ?></span></td>
                                                        <td><div class="audit-detail"><?php echo htmlspecialchars($log['details'] ?? 'No details'); ?></div></td>
                                                        <td><code class="small audit-ip"><?php echo htmlspecialchars($log['ip_address'] ?? 'N/A'); ?></code></td>
                                                    </tr>
                                                <?php endforeach; ?>
                                            </tbody>
                                        </table>
                                    </div>
                                <?php else: ?>
                                    <div class="audit-empty-state">
                                        <div class="audit-empty-state-icon">
                                            <i class="fas fa-history"></i>
                                        </div>
                                        <h5>No system activity found</h5>
                                        <p>Try widening the date range or clearing some filters. This view shows module-level events recorded across the platform.</p>
                                    </div>
                                <?php endif; ?>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="tab-pane fade <?php echo $active_view === 'super-audit' ? 'show active' : ''; ?>" id="super-audit-pane" role="tabpanel" aria-labelledby="super-audit-tab">
                    <div id="super-audit"></div>
                    <div class="tab-pane-inner">
                        <div class="audit-filter-card">
                            <div class="audit-filter-header">
                                <div class="audit-filter-icon">
                                    <i class="fas fa-user-shield"></i>
                                </div>
                                <div>
                                    <div class="filter-title">Filter Super Audit</div>
                                    <div class="filter-subtitle">Inspect every recorded click, form submit, modal open, tab switch, and page movement from CFO and HR users.</div>
                                </div>
                            </div>

                            <form method="GET" class="row g-3">
                                <input type="hidden" name="view" value="super-audit">
                                <div class="col-md-2">
                                    <label for="sa_date_from" class="form-label">From Date</label>
                                    <input type="date" class="form-control" id="sa_date_from" name="sa_date_from" value="<?php echo htmlspecialchars($sa_date_from); ?>">
                                </div>
                                <div class="col-md-2">
                                    <label for="sa_date_to" class="form-label">To Date</label>
                                    <input type="date" class="form-control" id="sa_date_to" name="sa_date_to" value="<?php echo htmlspecialchars($sa_date_to); ?>">
                                </div>
                                <div class="col-md-2">
                                    <label for="sa_module" class="form-label">Module</label>
                                    <select class="form-select" id="sa_module" name="sa_module">
                                        <option value="">All Modules</option>
                                        <?php foreach ($sa_modules as $module_option): ?>
                                            <option value="<?php echo htmlspecialchars($module_option); ?>" <?php echo $sa_module === $module_option ? 'selected' : ''; ?>>
                                                <?php echo htmlspecialchars(formatAuditLabel($module_option)); ?>
                                            </option>
                                        <?php endforeach; ?>
                                    </select>
                                </div>
                                <div class="col-md-2">
                                    <label for="sa_action_type" class="form-label">Action Type</label>
                                    <select class="form-select" id="sa_action_type" name="sa_action_type">
                                        <option value="">All Types</option>
                                        <?php foreach ($sa_action_types as $action_type_option): ?>
                                            <option value="<?php echo htmlspecialchars($action_type_option); ?>" <?php echo $sa_action_type === $action_type_option ? 'selected' : ''; ?>>
                                                <?php echo htmlspecialchars(formatAuditLabel($action_type_option)); ?>
                                            </option>
                                        <?php endforeach; ?>
                                    </select>
                                </div>
                                <div class="col-md-2">
                                    <label for="sa_role" class="form-label">Role</label>
                                    <select class="form-select" id="sa_role" name="sa_role">
                                        <option value="">All Roles</option>
                                        <?php foreach ($sa_roles as $role_option): ?>
                                            <option value="<?php echo htmlspecialchars($role_option); ?>" <?php echo $sa_role === $role_option ? 'selected' : ''; ?>>
                                                <?php echo htmlspecialchars($role_option); ?>
                                            </option>
                                        <?php endforeach; ?>
                                    </select>
                                </div>
                                <div class="col-md-2">
                                    <label for="sa_user_id" class="form-label">User</label>
                                    <select class="form-select" id="sa_user_id" name="sa_user_id">
                                        <option value="">All Users</option>
                                        <?php foreach ($sa_users as $user): ?>
                                            <option value="<?php echo $user['id']; ?>" <?php echo (string) $sa_user_id === (string) $user['id'] ? 'selected' : ''; ?>>
                                                <?php echo htmlspecialchars($user['full_name']); ?>
                                            </option>
                                        <?php endforeach; ?>
                                    </select>
                                </div>
                                <div class="col-12">
                                    <div class="filter-actions">
                                        <button type="submit" class="btn btn-primary btn-lg me-3 px-4">
                                            <i class="fas fa-search me-2"></i>Apply Filters
                                        </button>
                                        <a href="activity-log.php?view=super-audit#super-audit" class="btn btn-outline-secondary btn-lg px-3">
                                            <i class="fas fa-times me-1"></i>Clear
                                        </a>
                                    </div>
                                </div>
                            </form>
                        </div>

                        <div class="audit-section-card mt-2">
                            <div class="card-header-teal">
                                <h5><i class="fas fa-user-shield me-2"></i>Super Audit Timeline</h5>
                                <span class="audit-record-badge"><?php echo $super_audit_count; ?> records</span>
                            </div>
                            <div class="card-body-inner">
                                <?php if ($super_audit_count > 0): ?>
                                    <div class="table-responsive">
                                        <table class="table table-hover audit-table" id="superAuditTable">
                                            <thead>
                                                <tr>
                                                    <th>Timestamp</th>
                                                    <th>User</th>
                                                    <th>Role</th>
                                                    <th>Module</th>
                                                    <th>Action Type</th>
                                                    <th>Element</th>
                                                    <th>Page</th>
                                                    <th>IP Address</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <?php foreach ($super_audit_logs as $log): ?>
                                                    <?php $role_badge = $log['user_role'] === 'HR Manager' ? 'audit-pill-role-hr' : 'audit-pill-role-cfo'; ?>
                                                    <?php $action_icon = $action_icons[$log['action_type']] ?? 'fas fa-circle'; ?>
                                                    <?php $action_badge_class = $action_badge_classes[$log['action_type']] ?? 'audit-badge-link-click'; ?>
                                                    <tr>
                                                        <td>
                                                            <div class="audit-timestamp">
                                                                <?php echo date('M d, Y', strtotime($log['created_at'])); ?><br>
                                                                <?php echo date('H:i:s', strtotime($log['created_at'])); ?>
                                                            </div>
                                                        </td>
                                                        <td>
                                                            <div class="audit-user">
                                                                <strong><?php echo htmlspecialchars($log['user_name'] ?? 'Unknown'); ?></strong><br>
                                                                <small class="text-muted"><?php echo htmlspecialchars($log['username'] ?? ''); ?></small>
                                                            </div>
                                                        </td>
                                                        <td><span class="audit-pill <?php echo $role_badge; ?>"><?php echo htmlspecialchars($log['user_role']); ?></span></td>
                                                        <td><span class="audit-pill audit-pill-module"><?php echo htmlspecialchars(formatAuditLabel($log['module'])); ?></span></td>
                                                        <td>
                                                            <span class="badge-action <?php echo $action_badge_class; ?>">
                                                                <i class="<?php echo $action_icon; ?>"></i><?php echo htmlspecialchars(formatAuditLabel($log['action_type'])); ?>
                                                            </span>
                                                        </td>
                                                        <td>
                                                            <div class="audit-element-meta">
                                                                <div><strong><?php echo htmlspecialchars($log['element_text'] ?: 'No label captured'); ?></strong></div>
                                                                <?php if (!empty($log['element_id'])): ?><div>ID: <?php echo htmlspecialchars($log['element_id']); ?></div><?php endif; ?>
                                                                <?php if (!empty($log['element_tag'])): ?><div>Tag: <?php echo htmlspecialchars($log['element_tag']); ?></div><?php endif; ?>
                                                                <?php if (!empty($log['element_href'])): ?><div>Target: <?php echo htmlspecialchars($log['element_href']); ?></div><?php endif; ?>
                                                            </div>
                                                        </td>
                                                        <td><div class="audit-page-url small text-muted"><?php echo htmlspecialchars($log['page_url'] ?: 'N/A'); ?></div></td>
                                                        <td><code class="small audit-ip"><?php echo htmlspecialchars($log['ip_address'] ?? 'N/A'); ?></code></td>
                                                    </tr>
                                                <?php endforeach; ?>
                                            </tbody>
                                        </table>
                                    </div>
                                <?php else: ?>
                                    <div class="audit-empty-state">
                                        <div class="audit-empty-state-icon">
                                            <i class="fas fa-user-shield"></i>
                                        </div>
                                        <h5>No super audit records found</h5>
                                        <p>Once CFO or HR users start navigating modules and pressing actions, their detailed behavioral trail will appear here.</p>
                                    </div>
                                <?php endif; ?>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <div class="container-fluid px-5 pb-4">
        <?php include '../includes/footer.php'; ?>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.7/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.7/js/dataTables.bootstrap5.min.js"></script>
    <script src="../assets/js/dashboard.js"></script>
    <script src="../assets/js/notifications.js"></script>

    <script>
        $(document).ready(function () {
            if ($('#activityTable').length) {
                $('#activityTable').DataTable({
                    pageLength: 25,
                    order: [[0, 'desc']],
                    columnDefs: [
                        { orderable: false, targets: [4, 5] }
                    ],
                    language: {
                        search: 'Search activities:',
                        lengthMenu: 'Show _MENU_ activities per page',
                        info: 'Showing _START_ to _END_ of _TOTAL_ activities',
                        infoEmpty: 'No activities found',
                        infoFiltered: '(filtered from _MAX_ total activities)'
                    }
                });
            }

            if ($('#superAuditTable').length) {
                $('#superAuditTable').DataTable({
                    pageLength: 25,
                    order: [[0, 'desc']],
                    columnDefs: [
                        { orderable: false, targets: [5, 6, 7] }
                    ],
                    language: {
                        search: 'Search super audit:',
                        lengthMenu: 'Show _MENU_ audit events per page',
                        info: 'Showing _START_ to _END_ of _TOTAL_ audit events',
                        infoEmpty: 'No audit events found',
                        infoFiltered: '(filtered from _MAX_ total audit events)'
                    }
                });
            }

            if (window.location.hash === '#super-audit') {
                const superAuditTab = document.querySelector('#super-audit-tab');
                if (superAuditTab) {
                    bootstrap.Tab.getOrCreateInstance(superAuditTab).show();
                }
            }

            document.querySelectorAll('#auditTabs button[data-bs-toggle="tab"]').forEach(function (tabButton) {
                tabButton.addEventListener('shown.bs.tab', function (event) {
                    if (event.target.id === 'super-audit-tab') {
                        history.replaceState(null, '', 'activity-log.php?view=super-audit#super-audit');
                    } else {
                        history.replaceState(null, '', 'activity-log.php?view=system-activity');
                    }
                });
            });
        });
    </script>
</body>

</html>