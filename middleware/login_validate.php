<?php
session_start();
require_once 'db_config.php';

// Establish database connection
$conn = new mysqli(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_NAME);

// Check connection
if ($conn->connect_error) {
    die("Database connection failed: " . $conn->connect_error);
}

// Process login request
if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $employee_id = $_POST['employee_id'];
    $password = $_POST['password'];

    // Prepare a secure SQL query to prevent SQL injection
    $stmt = $conn->prepare("SELECT password_hash FROM employee_auth WHERE employee_id = ?");
    $stmt->bind_param("i", $employee_id);
    $stmt->execute();
    $stmt->store_result();

    if ($stmt->num_rows > 0) {
        $stmt->bind_result($stored_password_hash);
        $stmt->fetch();

        // Verify password
        if (password_verify($password, $stored_password_hash)) {
            $_SESSION['employee_id'] = $employee_id; // Store employee ID in session
            echo $_SESSION['employee_id'];
        } else {
            echo "Invalid Employee ID or password.";
        }
    } else {
        echo "Employee ID not found.";
    }

    $stmt->close();
}

// Close connection
$conn->close();
?>