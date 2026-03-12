<?php
// Start session if not already started
if (session_status() == PHP_SESSION_NONE) {
    session_start();
}

function getCorePath($file_name)
{
    $script_path = $_SERVER['SCRIPT_NAME'] ?? '';

    if (strpos($script_path, '/core/') !== false) {
        return $file_name;
    }

    if (strpos($script_path, '/modules/') !== false || strpos($script_path, '/utils/') !== false) {
        return '../core/' . $file_name;
    }

    return '../core/' . $file_name;
}

// Function to check if user is logged in
function isLoggedIn()
{
    if (isset($_SESSION['user_id']) && isset($_SESSION['username'])) {
        return true;
    }

    return false;
}

// Function to require login
function requireLogin()
{
    if (!isLoggedIn()) {
        header("Location: " . getCorePath('login.php'));
        exit();
    }
}

// Function to get current user data
function getCurrentUser()
{
    if (isLoggedIn()) {
        return [
            'id' => $_SESSION['user_id'],
            'username' => $_SESSION['username'],
            'email' => $_SESSION['email'] ?? '',
            'full_name' => $_SESSION['full_name'] ?? '',
            'role' => $_SESSION['user_role'] ?? '',
            'role_id' => $_SESSION['role_id'] ?? null
        ];
    }
    return null;
}

function getUserRole()
{
    return $_SESSION['user_role'] ?? null;
}

function getDefaultDashboardFile($role = null)
{
    $role = $role ?? getUserRole();

    return $role === 'HR Manager' ? 'hr-dashboard.php' : 'dashboard.php';
}

function redirectToDefaultDashboard($role = null)
{
    header('Location: ' . getCorePath(getDefaultDashboardFile($role)));
    exit();
}

function requireRole(array $allowed_roles)
{
    requireLogin();

    $user_role = getUserRole();
    if (!$user_role || !in_array($user_role, $allowed_roles, true)) {
        redirectToDefaultDashboard($user_role);
    }
}

// Function to set user session
function setUserSession($user_data)
{
    $_SESSION['user_id'] = $user_data['id'];
    $_SESSION['username'] = $user_data['username'];
    $_SESSION['email'] = $user_data['email'];
    $_SESSION['full_name'] = $user_data['full_name'];
    $_SESSION['role_id'] = $user_data['role_id'] ?? null;
    $_SESSION['user_role'] = $user_data['role_name'] ?? ($user_data['role'] ?? null);
}

// Function to destroy session
function destroyUserSession()
{
    session_unset();
    session_destroy();
}

/**
 * Log user activity to activity_logs table
 * @param string $action - The action performed (e.g., 'login', 'create', 'update', 'delete')
 * @param string $module - The module where action occurred (e.g., 'general_ledger', 'expense_tracking')
 * @param string $details - Additional details about the action
 * @param mysqli $conn - Database connection (optional, will use global if not provided)
 * @return bool - True if logged successfully, false otherwise
 */
function logActivity($action, $module, $details = '', $conn = null)
{
    global $conn;

    // If no connection provided, try to get it
    if (!$conn) {
        // Try to include database config if not already included
        if (!function_exists('getDBConnection')) {
            $db_config_path = __DIR__ . '/../config/database.php';
            if (file_exists($db_config_path)) {
                require_once $db_config_path;
                $conn = $GLOBALS['conn'] ?? null;
            }
        } else {
            $conn = getDBConnection();
        }
    }

    if (!$conn) {
        return false;
    }

    // Get current user
    $user_id = $_SESSION['user_id'] ?? null;
    if (!$user_id) {
        return false;
    }

    // Get IP address
    $ip_address = $_SERVER['REMOTE_ADDR'] ?? '127.0.0.1';

    try {
        // Check if table exists, create if not
        $table_check = $conn->query("SHOW TABLES LIKE 'activity_logs'");
        if ($table_check->num_rows == 0) {
            $create_table_sql = "CREATE TABLE IF NOT EXISTS activity_logs (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT NOT NULL,
                action VARCHAR(100) NOT NULL,
                module VARCHAR(100) NOT NULL,
                details TEXT,
                ip_address VARCHAR(45),
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_user_id (user_id),
                INDEX idx_module (module),
                INDEX idx_action (action),
                INDEX idx_created_at (created_at),
                FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci";

            if (!$conn->query($create_table_sql)) {
                error_log("Failed to create activity_logs table: " . $conn->error);
                return false;
            }
        }

        // Insert activity log
        $stmt = $conn->prepare("INSERT INTO activity_logs (user_id, action, module, details, ip_address) VALUES (?, ?, ?, ?, ?)");
        if (!$stmt) {
            error_log("Failed to prepare activity log statement: " . $conn->error);
            return false;
        }

        $stmt->bind_param('issss', $user_id, $action, $module, $details, $ip_address);
        $result = $stmt->execute();
        $stmt->close();

        return $result;
    } catch (Exception $e) {
        error_log("Failed to log activity: " . $e->getMessage());
        return false;
    }
}

function shouldTrackSuperAudit()
{
    if (!isLoggedIn()) {
        return false;
    }

    return in_array(getUserRole(), ['Accounting Admin', 'HR Manager'], true);
}

function ensureSuperAuditTable($conn)
{
    if (!$conn) {
        return false;
    }

    $table_check = $conn->query("SHOW TABLES LIKE 'super_audit_logs'");
    if ($table_check && $table_check->num_rows > 0) {
        return true;
    }

    $create_table_sql = "CREATE TABLE IF NOT EXISTS super_audit_logs (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        user_role VARCHAR(100) NOT NULL,
        action_type ENUM('page_visit','button_click','link_click','form_submit','modal_open','tab_switch','dropdown_select') NOT NULL,
        module VARCHAR(100) NOT NULL,
        element_tag VARCHAR(50) DEFAULT NULL,
        element_id VARCHAR(200) DEFAULT NULL,
        element_class VARCHAR(500) DEFAULT NULL,
        element_text VARCHAR(500) DEFAULT NULL,
        element_href VARCHAR(500) DEFAULT NULL,
        page_url VARCHAR(500) DEFAULT NULL,
        ip_address VARCHAR(45) DEFAULT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_super_audit_user_id (user_id),
        INDEX idx_super_audit_role (user_role),
        INDEX idx_super_audit_module (module),
        INDEX idx_super_audit_action_type (action_type),
        INDEX idx_super_audit_created_at (created_at),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci";

    return (bool) $conn->query($create_table_sql);
}

function logSuperAudit($action_type, $module, $details = '', $conn = null, array $metadata = [])
{
    global $conn;

    if (!shouldTrackSuperAudit()) {
        return false;
    }

    if (!$conn) {
        if (!function_exists('getDBConnection')) {
            $db_config_path = __DIR__ . '/../config/database.php';
            if (file_exists($db_config_path)) {
                require_once $db_config_path;
                $conn = $GLOBALS['conn'] ?? null;
            }
        } else {
            $conn = getDBConnection();
        }
    }

    if (!$conn || !ensureSuperAuditTable($conn)) {
        return false;
    }

    $user_id = $_SESSION['user_id'] ?? null;
    $user_role = getUserRole();
    if (!$user_id || !$user_role) {
        return false;
    }

    $ip_address = $_SERVER['REMOTE_ADDR'] ?? '127.0.0.1';
    $element_tag = $metadata['element_tag'] ?? null;
    $element_id = $metadata['element_id'] ?? null;
    $element_class = $metadata['element_class'] ?? null;
    $element_text = $metadata['element_text'] ?? $details;
    $element_href = $metadata['element_href'] ?? null;
    $page_url = $metadata['page_url'] ?? ($_SERVER['REQUEST_URI'] ?? null);

    try {
        $stmt = $conn->prepare(
            'INSERT INTO super_audit_logs (user_id, user_role, action_type, module, element_tag, element_id, element_class, element_text, element_href, page_url, ip_address)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'
        );

        if (!$stmt) {
            error_log('Failed to prepare super audit statement: ' . $conn->error);
            return false;
        }

        $stmt->bind_param(
            'issssssssss',
            $user_id,
            $user_role,
            $action_type,
            $module,
            $element_tag,
            $element_id,
            $element_class,
            $element_text,
            $element_href,
            $page_url,
            $ip_address
        );

        $result = $stmt->execute();
        $stmt->close();

        return $result;
    } catch (Exception $e) {
        error_log('Failed to log super audit activity: ' . $e->getMessage());
        return false;
    }
}

function renderSuperAuditTracker($module, $tracker_url)
{
    if (!isLoggedIn()) {
        return;
    }

    $current_user_role = getUserRole();

    echo '<script>';
    echo 'window.currentUserRole = ' . json_encode($current_user_role) . ';';
    echo 'window.currentModule = ' . json_encode($module) . ';';
    echo 'window.superAuditTrackerUrl = ' . json_encode($tracker_url) . ';';
    echo '</script>';
    echo PHP_EOL;
    echo '<script src="../assets/js/super-audit-tracker.js"></script>';
    echo PHP_EOL;
}

/**
 * Create a system notification (for external systems like banking, payments, etc.)
 * @param string $type - Notification type: 'banking', 'payment', 'reconciliation', 'alert', 'system', 'transaction'
 * @param string $title - Notification title
 * @param string $message - Notification message
 * @param string $priority - Priority: 'low', 'medium', 'high', 'urgent'
 * @param string $related_module - Related module (optional)
 * @param string $related_id - Related record ID (optional)
 * @param array $metadata - Additional metadata as array (optional)
 * @param mysqli $conn - Database connection (optional)
 * @return bool - True if created successfully, false otherwise
 */
function createSystemNotification($type, $title, $message, $priority = 'medium', $related_module = null, $related_id = null, $metadata = null, $conn = null)
{
    global $conn;

    // If no connection provided, try to get it
    if (!$conn) {
        $db_config_path = __DIR__ . '/../config/database.php';
        if (file_exists($db_config_path)) {
            require_once $db_config_path;
            $conn = $GLOBALS['conn'] ?? null;
        }
    }

    if (!$conn) {
        return false;
    }

    try {
        // Check if table exists, create if not
        $table_check = $conn->query("SHOW TABLES LIKE 'system_notifications'");
        if ($table_check->num_rows == 0) {
            $create_table_sql = "CREATE TABLE IF NOT EXISTS system_notifications (
                id INT AUTO_INCREMENT PRIMARY KEY,
                notification_type ENUM('banking', 'payment', 'reconciliation', 'alert', 'system', 'transaction') NOT NULL,
                title VARCHAR(255) NOT NULL,
                message TEXT NOT NULL,
                priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
                status ENUM('unread', 'read', 'archived') DEFAULT 'unread',
                related_module VARCHAR(100),
                related_id VARCHAR(100),
                metadata JSON,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                read_at DATETIME NULL,
                INDEX idx_type (notification_type),
                INDEX idx_status (status),
                INDEX idx_priority (priority),
                INDEX idx_created_at (created_at),
                INDEX idx_related (related_module, related_id)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci";

            if (!$conn->query($create_table_sql)) {
                error_log("Failed to create system_notifications table: " . $conn->error);
                return false;
            }
        }

        // Validate type
        $valid_types = ['banking', 'payment', 'reconciliation', 'alert', 'system', 'transaction'];
        if (!in_array($type, $valid_types)) {
            $type = 'system';
        }

        // Validate priority
        $valid_priorities = ['low', 'medium', 'high', 'urgent'];
        if (!in_array($priority, $valid_priorities)) {
            $priority = 'medium';
        }

        // Prepare metadata JSON
        $metadata_json = null;
        if ($metadata !== null && is_array($metadata)) {
            $metadata_json = json_encode($metadata);
        }

        // Insert notification
        $stmt = $conn->prepare("INSERT INTO system_notifications (notification_type, title, message, priority, related_module, related_id, metadata) VALUES (?, ?, ?, ?, ?, ?, ?)");
        if (!$stmt) {
            error_log("Failed to prepare system notification statement: " . $conn->error);
            return false;
        }

        $stmt->bind_param('sssssss', $type, $title, $message, $priority, $related_module, $related_id, $metadata_json);
        $result = $stmt->execute();
        $stmt->close();

        return $result;
    } catch (Exception $e) {
        error_log("Failed to create system notification: " . $e->getMessage());
        return false;
    }
}

