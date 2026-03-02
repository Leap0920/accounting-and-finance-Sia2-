<?php
$config_path = __DIR__ . '/config/database.php';
if (!file_exists($config_path)) {
    die("Database config not found at: $config_path");
}
require_once $config_path;

$conn = getDBConnection();
if (!$conn) {
    die("Connection failed: " . mysqli_connect_error());
}

$sql = "ALTER TABLE users ADD COLUMN remember_token VARCHAR(255) DEFAULT NULL AFTER is_active";
if (mysqli_query($conn, $sql)) {
    echo "SUCCESS: Column 'remember_token' added to 'users' table.";
} else {
    echo "INFO: " . mysqli_error($conn);
}

mysqli_close($conn);
?>