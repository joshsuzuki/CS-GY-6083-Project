<?php
require_once 'db_config.php';

$conn = new mysqli(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_NAME);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$firstName = $_POST['firstName'];
$lastName = $_POST['lastName'];

$stmt = $conn->prepare("INSERT INTO employees (first_name, last_name) VALUES (?, ?)");
$stmt->bind_param("ss", $firstName, $lastName);

if ($stmt->execute()) {
    echo "Employee added successfully!";
} else {
    echo "Error: " . $stmt->error;
}

$stmt->close();
$conn->close();
?>