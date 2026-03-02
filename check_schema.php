<?php
require_once 'config/database.php';
$result = $conn->query("DESCRIBE loan_applications");
while ($row = $result->fetch_assoc()) {
    print_r($row);
}
?>