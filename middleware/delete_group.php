<?php
header("Content-Type: application/json");
error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once 'db_config.php';

$conn = new mysqli(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_NAME);

if ($conn->connect_error) {
    die(json_encode(["error" => "Database connection failed", "message" => $conn->connect_error]));
}

if (isset($_GET["group_id"])) {
    $groupId = intval($_GET["group_id"]); // Ensure it's an integer

    // 🔹 Use a prepared statement to delete the group safely
    $stmt = $conn->prepare("DELETE FROM tbl_groups WHERE group_id = ?");
    $stmt->bind_param("i", $groupId);

    if ($stmt->execute()) {
        echo json_encode(["success" => "Group deleted successfully"]);
    } else {
        echo json_encode(["error" => "Failed to delete group", "message" => $stmt->error]);
    }

    $stmt->close();
} else {
    echo json_encode(["error" => "Invalid or missing group_id"]);
}

$conn->close();
?>