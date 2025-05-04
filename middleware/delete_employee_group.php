<?php
require_once 'db_config.php';

$conn = new mysqli(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_NAME);

if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

$employee_id = $_GET['employee_id'] ?? null;
$group_id = $_GET['group_id'] ?? null;

if ($employee_id && $group_id) {
    $stmt = $conn->prepare("DELETE FROM employees_groups WHERE employee_id = ? AND group_id = ?");
    $stmt->bind_param("ii", $employee_id, $group_id);
    
    if ($stmt->execute()) {
        echo json_encode(["success" => true]);
    } else {
        echo json_encode(["error" => "Failed to delete record"]);
    }
    
    $stmt->close();
} else {
    echo json_encode(["error" => "Invalid parameters"]);
}

$conn->close();
?>