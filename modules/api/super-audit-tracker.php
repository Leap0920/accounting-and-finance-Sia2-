<?php
require_once '../../config/database.php';
require_once '../../includes/session.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit();
}

requireLogin();

if (!shouldTrackSuperAudit()) {
    echo json_encode(['success' => true, 'skipped' => true]);
    exit();
}

$raw_body = file_get_contents('php://input');
$payload = json_decode($raw_body, true);

if (!is_array($payload)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Invalid payload']);
    exit();
}

$allowed_action_types = [
    'page_visit',
    'button_click',
    'link_click',
    'form_submit',
    'modal_open',
    'tab_switch',
    'dropdown_select'
];

$action_type = $payload['action_type'] ?? '';
if (!in_array($action_type, $allowed_action_types, true)) {
    http_response_code(422);
    echo json_encode(['success' => false, 'message' => 'Invalid action type']);
    exit();
}

$sanitize = static function ($value, $max_length) {
    if (!is_scalar($value)) {
        return null;
    }

    $value = trim(strip_tags((string) $value));
    if ($value === '') {
        return null;
    }

    return mb_substr($value, 0, $max_length);
};

$module = $sanitize($payload['module'] ?? '', 100);
if (!$module) {
    http_response_code(422);
    echo json_encode(['success' => false, 'message' => 'Module is required']);
    exit();
}

$details = $sanitize($payload['element_text'] ?? ($payload['details'] ?? ''), 500);
$metadata = [
    'element_tag' => $sanitize($payload['element_tag'] ?? '', 50),
    'element_id' => $sanitize($payload['element_id'] ?? '', 200),
    'element_class' => $sanitize($payload['element_class'] ?? '', 500),
    'element_text' => $details,
    'element_href' => $sanitize($payload['element_href'] ?? '', 500),
    'page_url' => $sanitize($payload['page_url'] ?? '', 500)
];

$logged = logSuperAudit($action_type, $module, $details ?? '', $conn, $metadata);

if (!$logged) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Failed to record audit event']);
    exit();
}

echo json_encode(['success' => true]);
