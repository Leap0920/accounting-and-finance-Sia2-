<?php
$f = 'c:/xampp/htdocs/accounting-and-finance-Sia2-/assets/js/financial-reporting.js';
$lines = file($f);
echo "Original line count: " . count($lines) . "\n";
$truncated = array_slice($lines, 0, 1305);
file_put_contents($f, implode('', $truncated));
$newLines = file($f);
echo "New line count: " . count($newLines) . "\n";
echo "Done.\n";
