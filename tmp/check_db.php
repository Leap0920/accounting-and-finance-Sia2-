<?php
require 'c:\xampp\htdocs\accounting-and-finance-Sia2-\config\database.php';
$res = $conn->query('SELECT COUNT(*) as count FROM loan_applications');
echo "Applications: " . ($res ? $res->fetch_assoc()['count'] : "Error: " . $conn->error) . "\n";
$res = $conn->query('SELECT COUNT(*) as count FROM loans');
echo "Loans: " . ($res ? $res->fetch_assoc()['count'] : "Error: " . $conn->error) . "\n";
$res = $conn->query('SELECT status, COUNT(*) as count FROM loan_applications GROUP BY status');
while ($row = $res->fetch_assoc())
    echo "App Status " . $row['status'] . ": " . $row['count'] . "\n";
?>