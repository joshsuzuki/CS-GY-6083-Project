<?php
session_start();
require_once 'db_config.php';

$conn = new mysqli(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_NAME);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$employee_id = $_POST['id'];

$stmt = $conn->prepare("UPDATE employees SET current_employee = FALSE WHERE id = ?");
$stmt->bind_param("i", $employee_id);

if ($stmt->execute()) {
    echo "Employee terminated";
} else {
    echo "Error: " . $stmt->error;
}

$stmt->close();
$conn->close();
?>