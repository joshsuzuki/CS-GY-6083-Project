<?php
require_once 'db_config.php';

$conn = new mysqli(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_NAME);

if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

$entity_id = $_POST['entity_id'] ?? null;
$group_id = $_POST['group_id'] ?? null;

if ($entity_id && $group_id) {
    $stmt = $conn->prepare("INSERT INTO groups_entities (entity_id, group_id) VALUES (?, ?)");
    $stmt->bind_param("ii", $entity_id, $group_id);

    if ($stmt->execute()) {
        echo json_encode(["success" => true]);
    } else {
        echo json_encode(["error" => "Failed to add entity"]);
    }

    $stmt->close();
} else {
    echo json_encode(["error" => "Invalid input parameters"]);
}

$conn->close();
?>