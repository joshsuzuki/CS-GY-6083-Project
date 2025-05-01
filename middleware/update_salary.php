<?php
session_start();
require_once 'db_config.php';

$conn = new mysqli(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_NAME);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$employee_id = $_POST['id'];
$employee_salary = $_POST['salary'];

$stmt = $conn->prepare("UPDATE employees SET salary = ? WHERE id = ?");
$stmt->bind_param("di", $employee_salary, $employee_id);

if ($stmt->execute()) {
    echo "Salary updated successfully!";
} else {
    echo "Error: " . $stmt->error;
}

$stmt->close();
$conn->close();
?>