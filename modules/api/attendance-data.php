<?php
/**
 * AJAX endpoint: returns attendance summary + records for a given employee/month/period.
 * Used by filterAttendanceByMonth() in payroll-management.js to update the attendance
 * section without a full page reload.
 */
require_once '../../config/database.php';
require_once '../../includes/session.php';

requireLogin();

ini_set('display_errors', 0);
error_reporting(0);
header('Content-Type: application/json');

// ── Input ───────────────────────────────────────────────────────────────────
$selected_employee = trim($_GET['employee'] ?? '');
$payroll_month     = trim($_GET['payroll_month'] ?? date('Y-m'));
$payroll_period    = trim($_GET['payroll_period'] ?? '');

// Basic month format sanity check
if (!preg_match('/^\d{4}-\d{2}$/', $payroll_month)) {
    $payroll_month = date('Y-m');
}

// ── Period dates ────────────────────────────────────────────────────────────
$year     = intval(date('Y', strtotime($payroll_month . '-01')));
$month    = intval(date('m', strtotime($payroll_month . '-01')));
$last_day = intval(date('t', strtotime($payroll_month . '-01')));

if ($payroll_period === 'first') {
    $period_start = sprintf('%04d-%02d-01', $year, $month);
    $period_end   = sprintf('%04d-%02d-15', $year, $month);
    $period_label = date('M 1-15, Y', strtotime($period_start));
} elseif ($payroll_period === 'second') {
    $period_start = sprintf('%04d-%02d-16', $year, $month);
    $period_end   = sprintf('%04d-%02d-%02d', $year, $month, $last_day);
    $period_label = date('M 16', strtotime($period_start)) . '-' . date('t, Y', strtotime($period_start));
} else {
    $period_start = sprintf('%04d-%02d-01', $year, $month);
    $period_end   = sprintf('%04d-%02d-%02d', $year, $month, $last_day);
    $period_label = date('F Y', strtotime($payroll_month . '-01'));
}

$display_month = $payroll_month;

// ── Defaults ────────────────────────────────────────────────────────────────
$attendance_data    = [];
$attendance_summary = [
    'present_days' => 0, 'absent_days' => 0, 'late_days' => 0, 'leave_days' => 0,
    'total_days'   => 0, 'total_hours' => 0,  'regular_hours' => 0, 'overtime_hours' => 0,
];

// ── Attendance query ─────────────────────────────────────────────────────────
if ($selected_employee) {

    // Extract numeric employee_id from "EMP001" format
    $employee_id = null;
    if (preg_match('/EMP(\d+)/i', $selected_employee, $m)) {
        $employee_id = intval($m[1]);
    } elseif (is_numeric($selected_employee)) {
        $employee_id = intval($selected_employee);
    } else {
        $stmt = $conn->prepare(
            "SELECT employee_id FROM employee
             WHERE CONCAT('EMP', LPAD(employee_id, 3, '0')) = ? LIMIT 1"
        );
        if ($stmt) {
            $stmt->bind_param('s', $selected_employee);
            $stmt->execute();
            $r = $stmt->get_result()->fetch_assoc();
            if ($r) $employee_id = intval($r['employee_id']);
            $stmt->close();
        }
    }

    if ($employee_id && $employee_id > 0) {

        $status_case = "CASE
            WHEN LOWER(status_col) = 'present'  THEN 'present'
            WHEN LOWER(status_col) = 'absent'   THEN 'absent'
            WHEN LOWER(status_col) = 'late'     THEN 'late'
            WHEN LOWER(status_col) = 'leave'    THEN 'leave'
            WHEN LOWER(status_col) LIKE '%half%' THEN 'half_day'
            ELSE 'present' END";

        if ($payroll_period === 'first' || $payroll_period === 'second') {
            $sql = "SELECT * FROM (
                SELECT
                    DATE(a.date) as date,
                    TIME(a.time_in) as time_in,
                    TIME(a.time_out) as time_out,
                    CASE WHEN LOWER(a.status)='present' THEN 'present'
                         WHEN LOWER(a.status)='absent'  THEN 'absent'
                         WHEN LOWER(a.status)='late'    THEN 'late'
                         WHEN LOWER(a.status)='leave'   THEN 'leave'
                         WHEN LOWER(a.status) LIKE '%half%' THEN 'half_day'
                         ELSE 'present' END as status,
                    COALESCE(a.total_hours, CASE
                        WHEN a.time_in IS NOT NULL AND a.time_out IS NOT NULL
                            THEN TIMESTAMPDIFF(HOUR,a.time_in,a.time_out)+(TIMESTAMPDIFF(MINUTE,a.time_in,a.time_out)%60)/60.0
                        WHEN a.time_in IS NOT NULL AND DATE(a.date) < CURDATE() THEN 8.00
                        WHEN a.time_in IS NOT NULL
                            THEN TIMESTAMPDIFF(HOUR,a.time_in,NOW())+(TIMESTAMPDIFF(MINUTE,a.time_in,NOW())%60)/60.0
                        ELSE 0.00 END) as hours_worked,
                    0.00 as overtime_hours,
                    CASE WHEN TIME(a.time_in)>'08:00:00' AND TIME(a.time_in)<='09:00:00'
                         THEN TIMESTAMPDIFF(MINUTE,'08:00:00',TIME(a.time_in)) ELSE 0 END as late_minutes,
                    COALESCE(a.remarks,'') as remarks, 'hris' as source
                FROM attendance a
                WHERE a.employee_id = ? AND DATE(a.date) BETWEEN ? AND ?

                UNION ALL

                SELECT
                    ea.attendance_date as date, ea.time_in, ea.time_out,
                    CASE WHEN LOWER(ea.status)='present' THEN 'present'
                         WHEN LOWER(ea.status)='absent'  THEN 'absent'
                         WHEN LOWER(ea.status)='late'    THEN 'late'
                         WHEN LOWER(ea.status)='leave'   THEN 'leave'
                         WHEN LOWER(ea.status) LIKE '%half%' THEN 'half_day'
                         ELSE 'present' END as status,
                    COALESCE(ea.hours_worked,0.00) as hours_worked,
                    COALESCE(ea.overtime_hours,0.00) as overtime_hours,
                    COALESCE(ea.late_minutes,0) as late_minutes,
                    COALESCE(ea.remarks,'') as remarks, 'accounting' as source
                FROM employee_attendance ea
                WHERE ea.employee_external_no = ? AND ea.attendance_date BETWEEN ? AND ?
            ) combined ORDER BY date DESC";

            $stmt = $conn->prepare($sql);
            if ($stmt) {
                $stmt->bind_param('isssss',
                    $employee_id, $period_start, $period_end,
                    $selected_employee, $period_start, $period_end
                );
            }
        } else {
            $sql = "SELECT * FROM (
                SELECT
                    DATE(a.date) as date,
                    TIME(a.time_in) as time_in,
                    TIME(a.time_out) as time_out,
                    CASE WHEN LOWER(a.status)='present' THEN 'present'
                         WHEN LOWER(a.status)='absent'  THEN 'absent'
                         WHEN LOWER(a.status)='late'    THEN 'late'
                         WHEN LOWER(a.status)='leave'   THEN 'leave'
                         WHEN LOWER(a.status) LIKE '%half%' THEN 'half_day'
                         ELSE 'present' END as status,
                    COALESCE(a.total_hours, CASE
                        WHEN a.time_in IS NOT NULL AND a.time_out IS NOT NULL
                            THEN TIMESTAMPDIFF(HOUR,a.time_in,a.time_out)+(TIMESTAMPDIFF(MINUTE,a.time_in,a.time_out)%60)/60.0
                        WHEN a.time_in IS NOT NULL AND DATE(a.date) < CURDATE() THEN 8.00
                        WHEN a.time_in IS NOT NULL
                            THEN TIMESTAMPDIFF(HOUR,a.time_in,NOW())+(TIMESTAMPDIFF(MINUTE,a.time_in,NOW())%60)/60.0
                        ELSE 0.00 END) as hours_worked,
                    0.00 as overtime_hours,
                    CASE WHEN TIME(a.time_in)>'08:00:00' AND TIME(a.time_in)<='09:00:00'
                         THEN TIMESTAMPDIFF(MINUTE,'08:00:00',TIME(a.time_in)) ELSE 0 END as late_minutes,
                    COALESCE(a.remarks,'') as remarks, 'hris' as source
                FROM attendance a
                WHERE a.employee_id = ? AND DATE_FORMAT(a.date,'%Y-%m') = ?

                UNION ALL

                SELECT
                    ea.attendance_date as date, ea.time_in, ea.time_out,
                    CASE WHEN LOWER(ea.status)='present' THEN 'present'
                         WHEN LOWER(ea.status)='absent'  THEN 'absent'
                         WHEN LOWER(ea.status)='late'    THEN 'late'
                         WHEN LOWER(ea.status)='leave'   THEN 'leave'
                         WHEN LOWER(ea.status) LIKE '%half%' THEN 'half_day'
                         ELSE 'present' END as status,
                    COALESCE(ea.hours_worked,0.00) as hours_worked,
                    COALESCE(ea.overtime_hours,0.00) as overtime_hours,
                    COALESCE(ea.late_minutes,0) as late_minutes,
                    COALESCE(ea.remarks,'') as remarks, 'accounting' as source
                FROM employee_attendance ea
                WHERE ea.employee_external_no = ? AND DATE_FORMAT(ea.attendance_date,'%Y-%m') = ?
            ) combined ORDER BY date DESC";

            $stmt = $conn->prepare($sql);
            if ($stmt) {
                $stmt->bind_param('isss',
                    $employee_id, $display_month,
                    $selected_employee, $display_month
                );
            }
        }

        if (!empty($stmt)) {
            $stmt->execute();
            $result = $stmt->get_result();
            $seen   = [];
            while ($row = $result->fetch_assoc()) {
                $dk = $row['date'];
                // Recalculate overtime for HRIS records
                if ($row['source'] === 'hris' && floatval($row['hours_worked']) > 8.0) {
                    $row['overtime_hours'] = floatval($row['hours_worked']) - 8.0;
                    $row['hours_worked']   = 8.0;
                }
                // Prefer accounting source over HRIS for same date
                if (!isset($seen[$dk]) || $row['source'] === 'accounting') {
                    $seen[$dk] = $row;
                }
            }
            $attendance_data = array_values($seen);
            usort($attendance_data, fn($a, $b) => strtotime($b['date']) - strtotime($a['date']));
            $stmt->close();
        }

        // ── Merge approved leaves ──────────────────────────────────────────
        $leave_q = "SELECT lr.start_date, lr.end_date, lr.reason, lt.leave_name
                    FROM leave_request lr
                    LEFT JOIN leave_type lt ON lr.leave_type_id = lt.leave_type_id
                    WHERE lr.employee_id = ?
                    AND (UPPER(TRIM(lr.status)) = 'APPROVED' OR LOWER(TRIM(lr.status)) = 'approved')";

        if ($payroll_period === 'first' || $payroll_period === 'second') {
            $leave_q .= " AND lr.start_date <= ? AND lr.end_date >= ?";
            $lv = $conn->prepare($leave_q);
            if ($lv) $lv->bind_param('iss', $employee_id, $period_end, $period_start);
        } else {
            $m_start = $display_month . '-01';
            $m_end   = date('Y-m-t', strtotime($display_month . '-01'));
            $leave_q .= " AND lr.start_date <= ? AND lr.end_date >= ?";
            $lv = $conn->prepare($leave_q);
            if ($lv) $lv->bind_param('iss', $employee_id, $m_end, $m_start);
        }

        if (!empty($lv)) {
            $lv->execute();
            $lv_result = $lv->get_result();

            $att_dates = [];
            foreach ($attendance_data as $r) $att_dates[date('Y-m-d', strtotime($r['date']))] = true;

            while ($leave = $lv_result->fetch_assoc()) {
                $cur = new DateTime($leave['start_date']);
                $end = new DateTime($leave['end_date']);
                while ($cur <= $end) {
                    $ds = $cur->format('Y-m-d');
                    $in_range = ($payroll_period === 'first' || $payroll_period === 'second')
                        ? ($ds >= $period_start && $ds <= $period_end)
                        : ($cur->format('Y-m') === $display_month);

                    if ($in_range && !isset($att_dates[$ds])) {
                        $attendance_data[] = [
                            'date'           => $ds,
                            'time_in'        => null,
                            'time_out'       => null,
                            'status'         => 'leave',
                            'hours_worked'   => 0.00,
                            'overtime_hours' => 0.00,
                            'late_minutes'   => 0,
                            'remarks'        => 'Leave: ' . ($leave['leave_name'] ?? 'Approved Leave') . ' - ' . ($leave['reason'] ?? ''),
                            'source'         => 'hris_leave',
                        ];
                        $att_dates[$ds] = true;
                    }
                    $cur->modify('+1 day');
                }
            }
            usort($attendance_data, fn($a, $b) => strtotime($b['date']) - strtotime($a['date']));
            $lv->close();
        }
    }

    // ── Summary ──────────────────────────────────────────────────────────────
    foreach ($attendance_data as $row) {
        $attendance_summary['total_days']++;
        $attendance_summary['total_hours']    += floatval($row['hours_worked']);
        $attendance_summary['overtime_hours'] += floatval($row['overtime_hours']);
        switch ($row['status']) {
            case 'present':
                $attendance_summary['present_days']++;
                $attendance_summary['regular_hours'] += floatval($row['hours_worked']);
                break;
            case 'late':
                $attendance_summary['late_days']++;
                $attendance_summary['present_days']++;
                $attendance_summary['regular_hours'] += floatval($row['hours_worked']);
                break;
            case 'absent':   $attendance_summary['absent_days']++; break;
            case 'leave':    $attendance_summary['leave_days']++;  break;
            case 'half_day':
                $attendance_summary['present_days']++;
                $attendance_summary['regular_hours'] += floatval($row['hours_worked']);
                break;
        }
    }
}

// ── Available months for dropdown ───────────────────────────────────────────
$months_sql = "SELECT DISTINCT DATE_FORMAT(a.date,'%Y-%m') as month FROM attendance a
               UNION SELECT DISTINCT DATE_FORMAT(lr.start_date,'%Y-%m') FROM leave_request lr WHERE UPPER(TRIM(lr.status))='APPROVED'
               UNION SELECT DISTINCT DATE_FORMAT(lr.end_date,'%Y-%m')   FROM leave_request lr WHERE UPPER(TRIM(lr.status))='APPROVED'
               UNION SELECT DISTINCT DATE_FORMAT(ea.attendance_date,'%Y-%m') FROM employee_attendance ea
               ORDER BY month DESC";
$mr = $conn->query($months_sql);
$available_months = [];
if ($mr) { while ($row = $mr->fetch_assoc()) $available_months[] = $row['month']; }
$cur_m = date('Y-m');
if (!in_array($cur_m, $available_months)) array_unshift($available_months, $cur_m);
$available_months = array_values(array_unique($available_months));
rsort($available_months);
if (empty($available_months)) $available_months = [$cur_m];

echo json_encode([
    'success'          => true,
    'display_month'    => $display_month,
    'period_label'     => $period_label,
    'summary'          => $attendance_summary,
    'records'          => $attendance_data,
    'available_months' => $available_months,
]);
