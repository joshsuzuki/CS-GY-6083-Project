<?php
session_start(); // Start session to retrieve employee ID
require_once 'db_config.php';

$conn = new mysqli(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_NAME);

if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

$employee_id = $_SESSION['employee_id'] ?? null;
$new_password = $_POST['new_password'] ?? null;

if ($employee_id && $new_password) {
    // Hash the password securely
    $password_hash = password_hash($new_password, PASSWORD_BCRYPT);

    // Update the password in the employee_auth table
    $stmt = $conn->prepare("UPDATE employee_auth SET password_hash = ? WHERE employee_id = ?");
    $stmt->bind_param("si", $password_hash, $employee_id);

    if ($stmt->execute()) {
        echo json_encode(["success" => true]);
    } else {
        echo json_encode(["error" => "Failed to update password"]);
    }

    $stmt->close();
} else {
    echo json_encode(["error" => "Invalid session or input parameters"]);
}

$conn->close();
?>