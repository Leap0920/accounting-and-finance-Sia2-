<?php
// Truncate financial-reporting.php to first 565 lines
$file = __DIR__ . '/../modules/financial-reporting.php';
$lines = file($file);
$clean = array_slice($lines, 0, 565);
file_put_contents($file, implode('', $clean));
echo "Done. File truncated to " . count($clean) . " lines.\n";
