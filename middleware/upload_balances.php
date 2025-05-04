<?php
session_start();
require_once 'db_config.php';

$conn = new mysqli(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_NAME);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

if ($_SERVER["REQUEST_METHOD"] === "POST" && isset($_FILES["csvFile"])) {
    $emp_id = $_SESSION['employee_id']; // Get employee ID from session
    $file = $_FILES["csvFile"]["tmp_name"];

    if (($handle = fopen($file, "r")) !== FALSE) {
        fgetcsv($handle); // Skip header row
        while (($data = fgetcsv($handle, 1000, ",")) !== FALSE) {
            $stmt = $conn->prepare("INSERT INTO balances_stage (account, entity, counterparty, month, year, amount, operation) VALUES (?, ?, ?, ?, ?, ?, ?)");
            $stmt->bind_param("iiiiids", $data[0], $data[1], $data[2], $data[3], $data[4], $data[5], $data[6]);
            $stmt->execute();
            $stmt->close();
        }
        fclose($handle);

        // Fetch balances_stage data and output it as JSON
        $result = $conn->query("SELECT * FROM balances_stage");

        if ($result) {
            $dataArray = [];
            while ($row = $result->fetch_assoc()) {
                $dataArray[] = $row;
            }
            echo "<script>console.log(" . json_encode($dataArray) . ");</script>";
        }

        $sp_stmt = $conn->prepare("CALL sp_validate_and_merge_to_balance(?)");
        $sp_stmt->bind_param("i", $emp_id);
        $sp_stmt->execute();
        $sp_stmt->close();

        header("Location: ../frontend/balances/upload_balances.html");
        exit(); // Ensure script execution stops after redirection

    } else {
        echo "Error reading CSV file.";
    }
} else {
    echo "Invalid request.";
}

$conn->close();
?>