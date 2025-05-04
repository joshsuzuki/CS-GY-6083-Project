<?php
session_start();
require_once 'db_config.php';

$conn = new mysqli(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_NAME);

if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

$emp_id = $_SESSION['employee_id'] ?? null;

if ($emp_id) {
    $stmt = $conn->prepare("
        SELECT account, entity, counterparty, month, year, amount, n_id_updated_by, dt_last_updated
        FROM balances
        JOIN vw_employee_entity ON balances.entity = vw_employee_entity.entity_id
        WHERE vw_employee_entity.id = ?
    ");
    
    $stmt->bind_param("i", $emp_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $dataArray = [];
    while ($row = $result->fetch_assoc()) {
        $dataArray[] = $row;
    }

    echo json_encode($dataArray); // Outputs JSON for the HTML page

    $stmt->close();
} else {
    echo json_encode(["error" => "Employee ID not found in session"]);
}

$conn->close();
?>