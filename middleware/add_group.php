<?php
session_start();
require_once 'db_config.php';

$conn = new mysqli(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_NAME);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$groupName = $_POST['groupName'];

// Insert into employees table
$stmt = $conn->prepare("INSERT INTO tbl_groups (group_name) VALUES (?)");
$stmt->bind_param("s", $groupName);

if ($stmt->execute()) {

    echo "Group added";

} else {
    echo "Error inserting Group: " . $stmt->error;
}

$stmt->close();
$conn->close();
?>