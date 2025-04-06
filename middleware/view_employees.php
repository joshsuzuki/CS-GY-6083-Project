<?php
header("Content-Type: application/json");
error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once 'db_config.php';

$conn = new mysqli(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_NAME);

if ($conn->connect_error) {
    die(json_encode(["error" => "Database connection failed", "message" => $conn->connect_error]));
}

$sql = "SELECT id, first_name, last_name, salary, hire_date FROM employees WHERE current_employee = TRUE";
$result = $conn->query($sql);

$employees = [];
while ($row = $result->fetch_assoc()) {
    $employees[] = $row;
}

echo json_encode($employees);

$conn->close();
?>
