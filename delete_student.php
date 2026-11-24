
<?php
require_once 'config/database.php';

if (!isset($_GET['id']) || !is_numeric($_GET['id'])) {
    header("Location: index.php");
    exit;
}

$id = (int) $_GET['id'];

try {
    $stmt = $pdo->prepare("DELETE FROM students WHERE id = :id");
    $stmt->execute([':id' => $id]);

    header("Location: index.php");
    exit;

} catch (PDOException $e) {
    die("Delete failed: " . htmlspecialchars($e->getMessage()));
}
