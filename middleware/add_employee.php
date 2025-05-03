<?php
session_start();
require_once 'db_config.php';

$conn = new mysqli(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_NAME);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$firstName = $_POST['firstName'];
$lastName = $_POST['lastName'];
$defaultPassword = "default";
$hashedPassword = password_hash($defaultPassword, PASSWORD_DEFAULT);

// Insert into employees table
$stmt = $conn->prepare("INSERT INTO employees (first_name, last_name) VALUES (?, ?)");
$stmt->bind_param("ss", $firstName, $lastName);

if ($stmt->execute()) {
    $employeeId = $stmt->insert_id; // Get the auto-generated employee ID

    // Insert into employee_auth table
    $authStmt = $conn->prepare("INSERT INTO employee_auth (employee_id, password_hash) VALUES (?, ?)");
    $authStmt->bind_param("is", $employeeId, $hashedPassword);

    if ($authStmt->execute()) {
        header("Location: ../frontend/employees/view_employees.html");
        exit();

    } else {
        echo "Error inserting authentication details: " . $authStmt->error;
    }

    $authStmt->close();
} else {
    echo "Error inserting employee: " . $stmt->error;
}

$stmt->close();
$conn->close();
?>