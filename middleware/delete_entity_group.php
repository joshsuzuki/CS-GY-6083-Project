<?php
require_once 'db_config.php';

$conn = new mysqli(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_NAME);

if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

$entity_id = $_GET['entity_id'] ?? null;
$group_id = $_GET['group_id'] ?? null;

if ($entity_id && $group_id) {
    $stmt = $conn->prepare("DELETE FROM groups_entities WHERE entity_id = ? AND group_id = ?");
    $stmt->bind_param("ii", $entity_id, $group_id);

    if ($stmt->execute()) {
        echo json_encode(["success" => true]);
    } else {
        echo json_encode(["error" => "Failed to delete record"]);
    }

    $stmt->close();
} else {
    echo json_encode(["error" => "Invalid parameters"]);
}

$conn->close();
?>