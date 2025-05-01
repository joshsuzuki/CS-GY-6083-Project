<?php
session_start();
header("Content-Type: application/json");
error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once 'db_config.php';

$conn = new mysqli(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_NAME);
$employeeId = $_SESSION['employee_id'];
error_log("Employee ID: " . $employeeId);
var_dump($_SESSION);

if ($conn->connect_error) {
    die(json_encode(["error" => "Database connection failed", "message" => $conn->connect_error]));
}

$sql = "SELECT id, first_name, last_name, salary, hire_date FROM employees WHERE current_employee = TRUE and id = ?";
error_log("sql query: " . $sql);
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $employeeId);

$stmt->execute();

$result = $stmt->get_result();
$employees = [];
while ($row = $result->fetch_assoc()) {
    $employees[] = $row;
}
error_log("SQL Output: " . print_r($employees, true));
echo json_encode($employees);

$conn->close();
?>
