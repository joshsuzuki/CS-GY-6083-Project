<?php
require_once 'db_config.php';

$conn = new mysqli(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_NAME);

if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

$group_id = $_GET['group_id'] ?? null;

if ($group_id) {
    $stmt = $conn->prepare("SELECT entity_id, group_id FROM groups_entities WHERE group_id = ?");
    $stmt->bind_param("i", $group_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $dataArray = [];
    while ($row = $result->fetch_assoc()) {
        $dataArray[] = $row;
    }

    echo json_encode($dataArray);
    $stmt->close();
} else {
    echo json_encode(["error" => "Missing group_id parameter"]);
}

$conn->close();
?>