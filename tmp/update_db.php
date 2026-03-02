<?php
require_once '../config/database.php';

$conn = getDBConnection();
if (!$conn) {
    die("Connection failed: " . mysqli_connect_error());
}

$sql = "ALTER TABLE users ADD COLUMN remember_token VARCHAR(255) DEFAULT NULL AFTER is_active";
if (mysqli_query($conn, $sql)) {
    echo "Column 'remember_token' added successfully.";
} else {
    // If column already exists or other error
    echo "Error adding column or column already exists: " . mysqli_error($conn);
}

mysqli_close($conn);
?>