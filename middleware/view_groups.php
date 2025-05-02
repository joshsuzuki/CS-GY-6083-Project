<?php
session_start();
header("Content-Type: application/json");
error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once 'db_config.php';
$conn = new mysqli(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_NAME);

if ($conn->connect_error) {
    die(json_encode(["error" => "Database connection failed", "message" => $conn->connect_error]));
}

$sql = "SELECT group_id, group_name FROM tbl_groups";
$stmt = $conn->prepare($sql);
$stmt->execute();
$result = $stmt->get_result();
$stmt->close();
$groups = [];
while ($row = $result->fetch_assoc()) {
    $groups[] = $row;
}
error_log("SQL Output: " . print_r($groups, true));

echo json_encode($groups);

$conn->close();
?>